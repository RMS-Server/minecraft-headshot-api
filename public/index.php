<?php
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\Factory\AppFactory;
use DI\Container;

require __DIR__ . '/../vendor/autoload.php';

$container = new Container();
$container->set('App\Services\SkinService', function() {
    return new App\Services\SkinService();
});
$container->set('App\Services\StatsManager', function() {
    return new App\Services\StatsManager();
});

AppFactory::setContainer($container);
$app = AppFactory::create();

$app->addErrorMiddleware(true, true, true);

$app->get('/head/{username}', function (Request $request, Response $response, array $args) {
    $username = $args['username'];
    
    try {
        $skinService = $this->get('App\Services\SkinService');
        
        $result = $skinService->getPlayerHead($username);
        
        $isError = substr($result, 0, 1) === '{';
        
        if ($isError) {
            $response = $response->withHeader('Content-Type', 'application/json; charset=utf-8');
        } else {
            $response = $response->withHeader('Content-Type', 'image/webp')
                                ->withHeader('Cache-Control', 'public, max-age=3600');
        }
        
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

$app->get('/head/{username}/nocache', function (Request $request, Response $response, array $args) {
    $username = $args['username'];
    
    try {
        $skinService = $this->get('App\Services\SkinService');
        
        $result = $skinService->getPlayerHeadNoCache($username);
        
        $isError = substr($result, 0, 1) === '{';
        
        if ($isError) {
            $response = $response->withHeader('Content-Type', 'application/json; charset=utf-8');
        } else {
            $response = $response->withHeader('Content-Type', 'image/webp')
                                ->withHeader('Cache-Control', 'no-cache, no-store, must-revalidate')
                                ->withHeader('Pragma', 'no-cache')
                                ->withHeader('Expires', '0');
        }
        
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

$app->run(); 