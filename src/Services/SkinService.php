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
        // 增加API调用计数
        $this->statsManager->incrementApiCall();
        
        try {
            // 检查缓存
            $cachedAvatar = $this->cacheManager->getCachedAvatar($username);
            if ($cachedAvatar !== null) {
                return $cachedAvatar;
            }

            // 获取玩家UUID
            $uuid = $this->getPlayerUUID($username);
            
            // 获取皮肤URL
            $skinUrl = $this->getPlayerSkinUrl($uuid);
            
            // 下载皮肤
            $skinData = $this->downloadSkin($skinUrl);
            
            // 处理头像
            $avatarData = $this->processHeadImage($skinData);

            // 保存到缓存
            $this->cacheManager->cacheAvatar($username, $avatarData);

            return $avatarData;
        } catch (Exception $e) {
            // 设置正确的 HTTP 状态码
            http_response_code($this->getErrorCode($e->getMessage()));
            
            // 返回 JSON 格式的错误信息
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
        // 使用 @ 抑制警告，并在 try-catch 中处理错误
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
        // 回退到GD库实现，但使用更简洁的方法
        $skin = @imagecreatefromstring($skinData);
        if (!$skin) {
            throw new Exception(self::ERROR_CODES['PROCESS_FAILED']['message']);
        }
        
        // 启用alpha混合
        imagealphablending($skin, true);
        imagesavealpha($skin, true);
        
        // 创建16x16的高分辨率画布（2倍放大）
        $canvas = imagecreatetruecolor(16, 16);
        if (!$canvas) {
            throw new Exception(self::ERROR_CODES['PROCESS_FAILED']['message']);
        }
        
        // 启用alpha混合
        imagealphablending($canvas, true);
        imagesavealpha($canvas, true);
        
        // 设置透明背景
        $transparent = imagecolorallocatealpha($canvas, 0, 0, 0, 127);
        imagefill($canvas, 0, 0, $transparent);
        
        // 将基础头部放大到14x14并居中放置（留1像素边距）
        imagecopyresized($canvas, $skin, 1, 1, 8, 8, 14, 14, 8, 8);
        
        // 将帽子层放大到整个16x16画布
        imagecopyresized($canvas, $skin, 0, 0, 40, 8, 16, 16, 8, 8);
        
        // 最终放大到128x128
        $finalHead = imagecreatetruecolor(128, 128);
        if (!$finalHead) {
            throw new Exception(self::ERROR_CODES['PROCESS_FAILED']['message']);
        }
        
        // 启用alpha混合
        imagealphablending($finalHead, true);
        imagesavealpha($finalHead, true);
        
        // 使用最近邻插值算法放大
        imagecopyresized($finalHead, $canvas, 0, 0, 0, 0, 128, 128, 16, 16);
        
        // 输出为WEBP
        ob_start();
        imagewebp($finalHead, null, 90);
        $imageData = ob_get_clean();
        
        // 清理资源
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
        return 500; // 默认服务器错误
    }
} 