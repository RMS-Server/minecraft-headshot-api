<?php
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;
use DI\Container;

require __DIR__ . '/../vendor/autoload.php';

// 创建DI容器
$container = new Container();
$container->set('App\Services\SkinService', function() {
    return new App\Services\SkinService();
});
$container->set('App\Services\StatsManager', function() {
    return new App\Services\StatsManager();
});

AppFactory::setContainer($container);
$app = AppFactory::create();

// 错误处理中间件
$app->addErrorMiddleware(true, true, true);

// 头像API路由
$app->get('/head/{username}', function (Request $request, Response $response, array $args) {
    $username = $args['username'];
    
    try {
        // 获取皮肤服务实例
        $skinService = $this->get('App\Services\SkinService');
        
        // 获取并处理头像
        $result = $skinService->getPlayerHead($username);
        
        // 检查是否是错误响应（JSON格式）
        $isError = substr($result, 0, 1) === '{';
        
        if ($isError) {
            // 如果是错误响应，设置JSON Content-Type
            $response = $response->withHeader('Content-Type', 'application/json; charset=utf-8');
        } else {
            // 如果是图片响应，设置WebP Content-Type和缓存
            $response = $response->withHeader('Content-Type', 'image/webp')
                                ->withHeader('Cache-Control', 'public, max-age=3600');
        }
        
        // 写入响应数据
        $response->getBody()->write($result);
        return $response;
    } catch (Exception $e) {
        $response = $response->withStatus(500)
                            ->withHeader('Content-Type', 'application/json; charset=utf-8');
        $response->getBody()->write(json_encode([
            'success' => false,
            'error' => $e->getMessage()
        ]));
        return $response;
    }
});

// API使用统计查询路由
$app->get('/uses', function (Request $request, Response $response, array $args) {
    try {
        $statsManager = $this->get('App\Services\StatsManager');
        $totalCalls = $statsManager->getTotalCalls();
        
        $result = [
            'success' => true,
            'total_calls' => $totalCalls,
            'message' => "API总调用次数: {$totalCalls}"
        ];
        
        $response = $response->withHeader('Content-Type', 'application/json; charset=utf-8');
        $response->getBody()->write(json_encode($result, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
        return $response;
    } catch (Exception $e) {
        $response = $response->withStatus(500)
                            ->withHeader('Content-Type', 'application/json; charset=utf-8');
        $response->getBody()->write(json_encode([
            'success' => false,
            'error' => $e->getMessage()
        ], JSON_UNESCAPED_UNICODE));
        return $response;
    }
});

// 运行应用
$app->run(); 