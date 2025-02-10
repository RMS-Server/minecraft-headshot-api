<?php

namespace App\Cache;

class CacheManager
{
    private string $cacheDir;
    private const CACHE_EXPIRE_DAYS = 30;

    public function __construct()
    {
        $this->cacheDir = dirname(__DIR__, 2) . '/cache/avatars/';
        if (!is_dir($this->cacheDir)) {
            mkdir($this->cacheDir, 0777, true);
        }
    }

    /**
     * 获取缓存的头像
     */
    public function getCachedAvatar(string $username): ?string
    {
        $cachePath = $this->getCachePath($username);
        
        if (!file_exists($cachePath)) {
            return null;
        }

        // 检查缓存是否过期
        $fileTime = filemtime($cachePath);
        if ($fileTime === false || (time() - $fileTime) > (self::CACHE_EXPIRE_DAYS * 24 * 60 * 60)) {
            unlink($cachePath);
            return null;
        }

        return file_get_contents($cachePath);
    }

    /**
     * 保存头像到缓存
     */
    public function cacheAvatar(string $username, string $imageData): bool
    {
        $cachePath = $this->getCachePath($username);
        return file_put_contents($cachePath, $imageData) !== false;
    }

    /**
     * 获取缓存文件路径
     */
    private function getCachePath(string $username): string
    {
        return $this->cacheDir . strtolower($username) . '.webp';
    }
} 