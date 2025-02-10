<?php

namespace App\Services;

use Exception;
use GdImage;

class SkinService
{
    private const MOJANG_API_URL = 'https://api.mojang.com/users/profiles/minecraft/';
    private const TEXTURE_API_URL = 'https://sessionserver.mojang.com/session/minecraft/profile/';
    
    /**
     * 获取玩家头像
     */
    public function getPlayerHead(string $username): string
    {
        // 获取玩家UUID
        $uuid = $this->getPlayerUUID($username);
        
        // 获取皮肤URL
        $skinUrl = $this->getPlayerSkinUrl($uuid);
        
        // 下载皮肤
        $skinData = $this->downloadSkin($skinUrl);
        
        // 处理头像
        return $this->processHeadImage($skinData);
    }
    
    /**
     * 获取玩家UUID
     */
    private function getPlayerUUID(string $username): string
    {
        $response = file_get_contents(self::MOJANG_API_URL . urlencode($username));
        if ($response === false) {
            throw new Exception('无法获取玩家信息');
        }
        
        $data = json_decode($response, true);
        if (!isset($data['id'])) {
            throw new Exception('玩家不存在');
        }
        
        return $data['id'];
    }
    
    /**
     * 获取玩家皮肤URL
     */
    private function getPlayerSkinUrl(string $uuid): string
    {
        $response = file_get_contents(self::TEXTURE_API_URL . $uuid);
        if ($response === false) {
            throw new Exception('无法获取皮肤信息');
        }
        
        $data = json_decode($response, true);
        if (!isset($data['properties'][0]['value'])) {
            throw new Exception('无法获取皮肤数据');
        }
        
        $textureData = json_decode(base64_decode($data['properties'][0]['value']), true);
        if (!isset($textureData['textures']['SKIN']['url'])) {
            throw new Exception('无效的皮肤数据');
        }
        
        return $textureData['textures']['SKIN']['url'];
    }
    
    /**
     * 下载皮肤
     */
    private function downloadSkin(string $url): string
    {
        $skinData = file_get_contents($url);
        if ($skinData === false) {
            throw new Exception('无法下载皮肤');
        }
        return $skinData;
    }
    
    /**
     * 处理头像图片
     */
    private function processHeadImage(string $skinData): string
    {
        // 创建原始图片
        $skin = imagecreatefromstring($skinData);
        if (!$skin) {
            throw new Exception('无法处理皮肤图片');
        }
        
        // 创建新图片
        $head = imagecreatetruecolor(8, 8);
        if (!$head) {
            throw new Exception('无法创建头像图片');
        }
        
        // 复制头部区域（8x8像素）
        imagecopy($head, $skin, 0, 0, 8, 8, 8, 8);
        
        // 放大图片
        $finalHead = imagecreatetruecolor(128, 128);
        if (!$finalHead) {
            throw new Exception('无法创建最终头像');
        }
        
        // 使用最近邻插值算法放大
        imagecopyresampled($finalHead, $head, 0, 0, 0, 0, 128, 128, 8, 8);
        
        // 输出为WEBP
        ob_start();
        imagewebp($finalHead, null, 90);
        $imageData = ob_get_clean();
        
        // 清理资源
        imagedestroy($skin);
        imagedestroy($head);
        imagedestroy($finalHead);
        
        return $imageData;
    }
} 