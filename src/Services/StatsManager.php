<?php

namespace App\Services;

class StatsManager
{
    private string $statsFile;

    public function __construct()
    {
        $cacheDir = dirname(__DIR__, 2) . '/cache/';
        if (!is_dir($cacheDir)) {
            mkdir($cacheDir, 0777, true);
        }
        $this->statsFile = $cacheDir . 'stats.json';
    }

    /**
     * 增加API调用次数
     */
    public function incrementApiCall(): void
    {
        $stats = $this->getStats();
        $stats['total_calls']++;
        $stats['last_updated'] = date('Y-m-d H:i:s');
        $this->saveStats($stats);
    }

    /**
     * 获取总调用次数
     */
    public function getTotalCalls(): int
    {
        $stats = $this->getStats();
        return $stats['total_calls'];
    }

    /**
     * 获取统计信息
     */
    private function getStats(): array
    {
        if (!file_exists($this->statsFile)) {
            return [
                'total_calls' => 0,
                'created_at' => date('Y-m-d H:i:s'),
                'last_updated' => date('Y-m-d H:i:s')
            ];
        }

        $content = file_get_contents($this->statsFile);
        if ($content === false) {
            return [
                'total_calls' => 0,
                'created_at' => date('Y-m-d H:i:s'),
                'last_updated' => date('Y-m-d H:i:s')
            ];
        }

        $stats = json_decode($content, true);
        if (!is_array($stats) || !isset($stats['total_calls'])) {
            return [
                'total_calls' => 0,
                'created_at' => date('Y-m-d H:i:s'),
                'last_updated' => date('Y-m-d H:i:s')
            ];
        }

        return $stats;
    }

    /**
     * 保存统计信息
     */
    private function saveStats(array $stats): bool
    {
        return file_put_contents($this->statsFile, json_encode($stats, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT)) !== false;
    }
}