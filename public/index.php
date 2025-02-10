<?php
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;
use DI\Container;

require __DIR__ . '/../vendor/autoload.php';

// 创建DI容器
$container = new Container();
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
        $imageData = $skinService->getPlayerHead($username);
        
        // 设置响应头
        $response = $response->withHeader('Content-Type', 'image/webp')
                            ->withHeader('Cache-Control', 'public, max-age=3600');
        
        // 写入图片数据
        $response->getBody()->write($imageData);
        return $response;
    } catch (Exception $e) {
        // 错误处理
        $response = $response->withStatus(500);
        $response->getBody()->write(json_encode([
            'error' => $e->getMessage()
        ]));
        return $response->withHeader('Content-Type', 'application/json');
    }
});

// 运行应用
$app->run(); 