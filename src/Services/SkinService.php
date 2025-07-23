<?php

namespace App\Services;

use App\Cache\CacheManager;
use Exception;
use GdImage;
use Intervention\Image\ImageManager;
use Intervention\Image\Drivers\Gd\Driver;

class SkinService
{
    private const MOJANG_API_URL = 'https://api.mojang.com/users/profiles/minecraft/';
    private const TEXTURE_API_URL = 'https://sessionserver.mojang.com/session/minecraft/profile/';
    private CacheManager $cacheManager;
    private StatsManager $statsManager;
    
    /**
     * 错误代码定义
     */
    private const ERROR_CODES = [
        'PLAYER_NOT_FOUND' => [
            'code' => 404,
            'message' => '玩家不存在或不是正版用户'
        ],
        'SKIN_NOT_FOUND' => [
            'code' => 404,
            'message' => '无法获取玩家皮肤信息'
        ],
        'DOWNLOAD_FAILED' => [
            'code' => 500,
            'message' => '下载皮肤失败'
        ],
        'PROCESS_FAILED' => [
            'code' => 500,
            'message' => '处理图片失败'
        ]
    ];

    public function __construct()
    {
        $this->cacheManager = new CacheManager();
        $this->statsManager = new StatsManager();
    }

    /**
     * 获取玩家头像
     */
    public function getPlayerHead(string $username): string
    {
        $this->statsManager->incrementApiCall();
        
        try {
            $cachedAvatar = $this->cacheManager->getCachedAvatar($username);
            if ($cachedAvatar !== null) {
                return $cachedAvatar;
            }

            $uuid = $this->getPlayerUUID($username);
            
            $skinUrl = $this->getPlayerSkinUrl($uuid);
            
            $skinData = $this->downloadSkin($skinUrl);
            
            $avatarData = $this->processHeadImage($skinData);

            $this->cacheManager->cacheAvatar($username, $avatarData);

            return $avatarData;
        } catch (Exception $e) {
            http_response_code($this->getErrorCode($e->getMessage()));
            
            header('Content-Type: application/json; charset=utf-8');
            return json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
        }
    }

    /**
     * 获取玩家头像（不使用缓存）
     */
    public function getPlayerHeadNoCache(string $username): string
    {
        $this->statsManager->incrementApiCall();
        
        try {
            $uuid = $this->getPlayerUUID($username);
            
            $skinUrl = $this->getPlayerSkinUrl($uuid);
            
            $skinData = $this->downloadSkin($skinUrl);
            
            $avatarData = $this->processHeadImage($skinData);

            return $avatarData;
        } catch (Exception $e) {
            http_response_code($this->getErrorCode($e->getMessage()));
            
            header('Content-Type: application/json; charset=utf-8');
            return json_encode([
                'success' => false,
                'error' => $e->getMessage()
            ], JSON_UNESCAPED_UNICODE);
        }
    }
    
    /**
     * 获取玩家UUID
     */
    private function getPlayerUUID(string $username): string
    {
        $response = @file_get_contents(self::MOJANG_API_URL . urlencode($username));
        
        if ($response === false) {
            throw new Exception(self::ERROR_CODES['PLAYER_NOT_FOUND']['message']);
        }
        
        $data = json_decode($response, true);
        if (!isset($data['id'])) {
            throw new Exception(self::ERROR_CODES['PLAYER_NOT_FOUND']['message']);
        }
        
        return $data['id'];
    }
    
    /**
     * 获取玩家皮肤URL
     */
    private function getPlayerSkinUrl(string $uuid): string
    {
        $response = @file_get_contents(self::TEXTURE_API_URL . $uuid);
        if ($response === false) {
            throw new Exception(self::ERROR_CODES['SKIN_NOT_FOUND']['message']);
        }
        
        $data = json_decode($response, true);
        if (!isset($data['properties'][0]['value'])) {
            throw new Exception(self::ERROR_CODES['SKIN_NOT_FOUND']['message']);
        }
        
        $textureData = json_decode(base64_decode($data['properties'][0]['value']), true);
        if (!isset($textureData['textures']['SKIN']['url'])) {
            throw new Exception(self::ERROR_CODES['SKIN_NOT_FOUND']['message']);
        }
        
        return $textureData['textures']['SKIN']['url'];
    }
    
    /**
     * 下载皮肤
     */
    private function downloadSkin(string $url): string
    {
        $skinData = @file_get_contents($url);
        if ($skinData === false) {
            throw new Exception(self::ERROR_CODES['DOWNLOAD_FAILED']['message']);
        }
        return $skinData;
    }
    
    /**
     * 处理头像图片
     */
    private function processHeadImage(string $skinData): string
    {
        $skin = @imagecreatefromstring($skinData);
        if (!$skin) {
            throw new Exception(self::ERROR_CODES['PROCESS_FAILED']['message']);
        }
        
        imagealphablending($skin, true);
        imagesavealpha($skin, true);
        
        $canvas = imagecreatetruecolor(16, 16);
        if (!$canvas) {
            throw new Exception(self::ERROR_CODES['PROCESS_FAILED']['message']);
        }
        
        imagealphablending($canvas, false);
        imagesavealpha($canvas, true);
        
        $transparent = imagecolorallocatealpha($canvas, 0, 0, 0, 127);
        imagefill($canvas, 0, 0, $transparent);
        
        imagealphablending($canvas, true);
        
        imagecopyresized($canvas, $skin, 1, 1, 8, 8, 14, 14, 8, 8);
        
        for ($y = 0; $y < 16; $y++) {
            for ($x = 0; $x < 16; $x++) {
                $srcX = 40 + intval($x * 8 / 16);
                $srcY = 8 + intval($y * 8 / 16);
                
                $color = imagecolorat($skin, $srcX, $srcY);
                
                $r = ($color >> 16) & 0xFF;
                $g = ($color >> 8) & 0xFF;
                $b = $color & 0xFF;
                $a = ($color >> 24) & 0x7F;
                
                if (!($r == 0 && $g == 0 && $b == 0) && $a < 127) {
                    imagesetpixel($canvas, $x, $y, $color);
                }
            }
        }
        
        $finalHead = imagecreatetruecolor(128, 128);
        if (!$finalHead) {
            throw new Exception(self::ERROR_CODES['PROCESS_FAILED']['message']);
        }
        
        imagealphablending($finalHead, false);
        imagesavealpha($finalHead, true);
        
        $finalTransparent = imagecolorallocatealpha($finalHead, 0, 0, 0, 127);
        imagefill($finalHead, 0, 0, $finalTransparent);
        
        imagealphablending($finalHead, true);
        
        imagecopyresized($finalHead, $canvas, 0, 0, 0, 0, 128, 128, 16, 16);
        
        ob_start();
        imagewebp($finalHead, null, 90);
        $imageData = ob_get_clean();
        
        imagedestroy($skin);
        imagedestroy($canvas);
        imagedestroy($finalHead);
        
        return $imageData;
    }

    /**
     * 获取错误代码
     */
    private function getErrorCode(string $message): int
    {
        foreach (self::ERROR_CODES as $error) {
            if ($error['message'] === $message) {
                return $error['code'];
            }
        }
    }
} 