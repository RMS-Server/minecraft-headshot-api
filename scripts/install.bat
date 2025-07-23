@echo off
chcp 65001 >nul
title Minecraft Headshot API - 一键安装脚本

REM Minecraft Headshot API - Windows 一键安装脚本
REM 作者: XRain
REM 适用系统: Windows 10/11

setlocal enabledelayedexpansion

REM 颜色定义
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM 项目配置
set "PROJECT_REPO=https://github.com/XRain66/minecraft-headshot-api.git"
set "PROJECT_NAME=minecraft-headshot-api"
set "INSTALL_DIR=C:\inetpub\wwwroot\%PROJECT_NAME%"
set "TEMP_DIR=%TEMP%\%PROJECT_NAME%-install"

echo =========================================
echo   Minecraft Headshot API 一键安装脚本
echo =========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorLevel% == 0 (
    echo %GREEN%[INFO]%NC% 检测到管理员权限
) else (
    echo %RED%[ERROR]%NC% 请以管理员身份运行此脚本
    echo %YELLOW%[INFO]%NC% 右键点击脚本文件，选择"以管理员身份运行"
    pause
    exit /b 1
)

REM 检查Git安装
:check_git
echo %BLUE%[INFO]%NC% 检查Git安装状态...
git --version >nul 2>&1
if %errorLevel% == 0 (
    echo %GREEN%[SUCCESS]%NC% Git已安装
) else (
    echo %RED%[ERROR]%NC% Git未安装
    echo.
    echo %YELLOW%[GUIDE]%NC% Git安装指南:
    echo   1. 访问 https://git-scm.com/download/win
    echo   2. 下载并安装Git for Windows
    echo   3. 安装时选择"Add Git to PATH"
    echo.
    set /p "continue=是否已安装Git? (y/n): "
    if /i "!continue!" == "y" goto check_git
    if /i "!continue!" == "yes" goto check_git
    echo %YELLOW%[INFO]%NC% 请安装Git后重新运行脚本
    pause
    exit /b 1
)

REM 检查PHP安装
:check_php
echo %BLUE%[INFO]%NC% 检查PHP安装状态...
php -v >nul 2>&1
if %errorLevel% == 0 (
    for /f "tokens=2" %%i in ('php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;"') do set "PHP_VERSION=%%i"
    echo %GREEN%[SUCCESS]%NC% 检测到PHP版本: !PHP_VERSION!
    
    REM 检查PHP版本是否满足要求
    for /f "tokens=1,2 delims=." %%a in ("!PHP_VERSION!") do (
        set "MAJOR=%%a"
        set "MINOR=%%b"
    )
    
    if !MAJOR! gtr 7 (
        echo %GREEN%[SUCCESS]%NC% PHP版本满足要求 ^(^>= 7.4^)
    ) else if !MAJOR! equ 7 (
        if !MINOR! geq 4 (
            echo %GREEN%[SUCCESS]%NC% PHP版本满足要求 ^(^>= 7.4^)
        ) else (
            goto php_install_guide
        )
    ) else (
        goto php_install_guide
    )
) else (
    goto php_install_guide
)
goto check_php_extensions

:php_install_guide
echo %RED%[ERROR]%NC% PHP未安装或版本过低 ^(需要 ^>= 7.4^)
echo.
echo %YELLOW%[GUIDE]%NC% PHP安装指南:
echo   1. 访问 https://windows.php.net/download/
echo   2. 下载 PHP 8.1 Thread Safe 版本
echo   3. 解压到 C:\php
echo   4. 将 C:\php 添加到系统PATH环境变量
echo   5. 复制 php.ini-production 为 php.ini
echo   6. 编辑 php.ini，启用以下扩展:
echo      - extension=gd
echo      - extension=curl
echo      - extension=mbstring
echo      - extension=openssl
echo.
set /p "continue=是否已安装PHP? (y/n): "
if /i "!continue!" == "y" goto check_php
if /i "!continue!" == "yes" goto check_php
echo %YELLOW%[INFO]%NC% 请安装PHP后重新运行脚本
pause
exit /b 1

REM 检查PHP扩展
:check_php_extensions
echo %BLUE%[INFO]%NC% 检查PHP扩展...

set "REQUIRED_EXTENSIONS=gd curl json mbstring"
set "MISSING_EXTENSIONS="

for %%ext in (%REQUIRED_EXTENSIONS%) do (
    php -m | findstr /i "%%ext" >nul 2>&1
    if !errorLevel! neq 0 (
        if "!MISSING_EXTENSIONS!" == "" (
            set "MISSING_EXTENSIONS=%%ext"
        ) else (
            set "MISSING_EXTENSIONS=!MISSING_EXTENSIONS! %%ext"
        )
    )
)

if "!MISSING_EXTENSIONS!" == "" (
    echo %GREEN%[SUCCESS]%NC% 所有必需的PHP扩展已安装
) else (
    echo %RED%[ERROR]%NC% 缺少PHP扩展: !MISSING_EXTENSIONS!
    echo %YELLOW%[GUIDE]%NC% 请在php.ini中启用以下扩展:
    for %%ext in (!MISSING_EXTENSIONS!) do (
        echo   - extension=%%ext
    )
    echo.
    set /p "continue=是否已启用扩展? (y/n): "
    if /i "!continue!" == "y" goto check_php_extensions
    if /i "!continue!" == "yes" goto check_php_extensions
    echo %YELLOW%[INFO]%NC% 请启用必需扩展后重新运行脚本
    pause
    exit /b 1
)

REM 检查WebP支持
php -r "if (function_exists('imagewebp')) { echo 'WebP supported'; } else { echo 'WebP not supported'; exit(1); }" >nul 2>&1
if %errorLevel% == 0 (
    echo %GREEN%[SUCCESS]%NC% WebP支持已启用
) else (
    echo %YELLOW%[WARNING]%NC% WebP支持未启用，请检查GD扩展配置
)

REM 检查Composer
:check_composer
echo %BLUE%[INFO]%NC% 检查Composer安装状态...
composer --version >nul 2>&1
if %errorLevel% == 0 (
    echo %GREEN%[SUCCESS]%NC% Composer已安装
) else (
    echo %RED%[ERROR]%NC% Composer未安装
    echo.
    echo %YELLOW%[GUIDE]%NC% Composer安装指南:
    echo   1. 访问 https://getcomposer.org/download/
    echo   2. 下载并运行 Composer-Setup.exe
    echo   3. 按照安装向导完成安装
    echo.
    set /p "continue=是否已安装Composer? (y/n): "
    if /i "!continue!" == "y" goto check_composer
    if /i "!continue!" == "yes" goto check_composer
    echo %YELLOW%[INFO]%NC% 请安装Composer后重新运行脚本
    pause
    exit /b 1
)

REM 下载项目代码
:download_project
echo %BLUE%[INFO]%NC% 下载项目代码...

REM 清理临时目录
if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%"
)

REM 克隆项目
git clone "%PROJECT_REPO%" "%TEMP_DIR%"
if %errorLevel% neq 0 (
    echo %RED%[ERROR]%NC% 项目代码下载失败
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% 项目代码下载完成

REM 备份现有安装
if exist "%INSTALL_DIR%" (
    echo %BLUE%[INFO]%NC% 备份现有安装...
    for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
        for /f "tokens=1-2 delims=: " %%x in ('time /t') do (
            set "BACKUP_SUFFIX=%%c%%a%%b_%%x%%y"
        )
    )
    move "%INSTALL_DIR%" "%INSTALL_DIR%.backup.!BACKUP_SUFFIX!"
)

REM 创建安装目录
if not exist "C:\inetpub\wwwroot\" (
    mkdir "C:\inetpub\wwwroot\"
)

REM 移动项目到安装目录
move "%TEMP_DIR%" "%INSTALL_DIR%"
echo %GREEN%[SUCCESS]%NC% 项目安装到: %INSTALL_DIR%

REM 安装项目依赖
:install_dependencies
echo %BLUE%[INFO]%NC% 安装项目依赖...
cd /d "%INSTALL_DIR%"

if not exist "composer.json" (
    echo %RED%[ERROR]%NC% 未找到composer.json文件
    pause
    exit /b 1
)

composer install --no-dev --optimize-autoloader
if %errorLevel% == 0 (
    echo %GREEN%[SUCCESS]%NC% 项目依赖安装完成
) else (
    echo %RED%[ERROR]%NC% 项目依赖安装失败
    pause
    exit /b 1
)

REM 创建缓存目录
:setup_directories
echo %BLUE%[INFO]%NC% 创建必要目录...
if not exist "%INSTALL_DIR%\cache" (
    mkdir "%INSTALL_DIR%\cache"
    echo %GREEN%[INFO]%NC% 创建缓存目录: %INSTALL_DIR%\cache
)

REM 设置目录权限
icacls "%INSTALL_DIR%" /grant "IIS_IUSRS:(OI)(CI)F" /T >nul 2>&1
icacls "%INSTALL_DIR%\cache" /grant "Everyone:(OI)(CI)F" /T >nul 2>&1
echo %GREEN%[SUCCESS]%NC% 目录权限设置完成

REM Web服务器配置指南
:web_server_guide
echo.
echo =========================================
echo %GREEN%[SUCCESS]%NC% 安装完成！
echo =========================================
echo.
echo 项目信息:
echo   项目路径: %INSTALL_DIR%
echo   Web根目录: %INSTALL_DIR%\public
echo   缓存目录: %INSTALL_DIR%\cache
echo.

echo %YELLOW%[GUIDE]%NC% Web服务器配置指南:
echo.
echo 请选择您要使用的Web服务器:
echo   1. IIS (推荐)
echo   2. Apache
echo   3. PHP内置服务器 (仅用于开发测试)
echo   4. 显示完整配置信息
echo.
set /p "server_choice=请选择 (1-4): "

if "!server_choice!" == "1" goto iis_guide
if "!server_choice!" == "2" goto apache_guide
if "!server_choice!" == "3" goto php_server
if "!server_choice!" == "4" goto show_all_config
goto web_server_guide

:iis_guide
echo.
echo %BLUE%[IIS配置指南]%NC%
echo.
echo 1. 打开IIS管理器 (运行 inetmgr)
echo 2. 右键点击"网站" -^> "添加网站"
echo 3. 设置以下信息:
echo    - 网站名称: %PROJECT_NAME%
echo    - 物理路径: %INSTALL_DIR%\public
echo    - 端口: 80 (或其他可用端口)
echo 4. 确保安装了URL重写模块 (下载: https://www.iis.net/downloads/microsoft/url-rewrite)
echo 5. 在网站根目录已自动创建 web.config 文件
echo.

REM 创建web.config文件
echo ^<?xml version="1.0" encoding="UTF-8"?^> > "%INSTALL_DIR%\public\web.config"
echo ^<configuration^> >> "%INSTALL_DIR%\public\web.config"
echo     ^<system.webServer^> >> "%INSTALL_DIR%\public\web.config"
echo         ^<rewrite^> >> "%INSTALL_DIR%\public\web.config"
echo             ^<rules^> >> "%INSTALL_DIR%\public\web.config"
echo                 ^<rule name="Slim" patternSyntax="Wildcard"^> >> "%INSTALL_DIR%\public\web.config"
echo                     ^<match url="*" /^> >> "%INSTALL_DIR%\public\web.config"
echo                     ^<conditions^> >> "%INSTALL_DIR%\public\web.config"
echo                         ^<add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" /^> >> "%INSTALL_DIR%\public\web.config"
echo                         ^<add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" /^> >> "%INSTALL_DIR%\public\web.config"
echo                     ^</conditions^> >> "%INSTALL_DIR%\public\web.config"
echo                     ^<action type="Rewrite" url="index.php" /^> >> "%INSTALL_DIR%\public\web.config"
echo                 ^</rule^> >> "%INSTALL_DIR%\public\web.config"
echo             ^</rules^> >> "%INSTALL_DIR%\public\web.config"
echo         ^</rewrite^> >> "%INSTALL_DIR%\public\web.config"
echo     ^</system.webServer^> >> "%INSTALL_DIR%\public\web.config"
echo ^</configuration^> >> "%INSTALL_DIR%\public\web.config"

echo %GREEN%[SUCCESS]%NC% web.config文件已创建
goto installation_complete

:apache_guide
echo.
echo %BLUE%[Apache配置指南]%NC%
echo.
echo 1. 确保Apache已安装并启用mod_rewrite模块
echo 2. 在Apache配置文件中添加虚拟主机:
echo.
echo ^<VirtualHost *:80^>
echo     ServerName your-domain.com
echo     DocumentRoot "%INSTALL_DIR%\public"
echo     DirectoryIndex index.php
echo.
echo     ^<Directory "%INSTALL_DIR%\public"^>
echo         AllowOverride All
echo         Require all granted
echo     ^</Directory^>
echo ^</VirtualHost^>
echo.

REM 创建.htaccess文件
echo ^<IfModule mod_rewrite.c^> > "%INSTALL_DIR%\public\.htaccess"
echo     RewriteEngine On >> "%INSTALL_DIR%\public\.htaccess"
echo     RewriteCond %%{REQUEST_FILENAME} !-f >> "%INSTALL_DIR%\public\.htaccess"
echo     RewriteCond %%{REQUEST_FILENAME} !-d >> "%INSTALL_DIR%\public\.htaccess"
echo     RewriteRule . /index.php [L] >> "%INSTALL_DIR%\public\.htaccess"
echo ^</IfModule^> >> "%INSTALL_DIR%\public\.htaccess"

echo %GREEN%[SUCCESS]%NC% .htaccess文件已创建
goto installation_complete

:php_server
echo.
echo %BLUE%[PHP内置服务器]%NC%
echo.
echo %YELLOW%[WARNING]%NC% PHP内置服务器仅适用于开发测试，不建议用于生产环境
echo.
echo 启动开发服务器...
cd /d "%INSTALL_DIR%\public"
echo %GREEN%[INFO]%NC% 服务器启动在: http://localhost:8080
echo %GREEN%[INFO]%NC% 按 Ctrl+C 停止服务器
echo.
echo API使用示例:
echo   获取头像: http://localhost:8080/head/XRain666
echo   无缓存获取: http://localhost:8080/head/XRain666/nocache
echo   查看调用次数: http://localhost:8080/uses
echo.
php -S localhost:8080
goto end

:show_all_config
echo.
echo =========================================
echo %BLUE%[完整配置信息]%NC%
echo =========================================
echo.
echo 项目路径: %INSTALL_DIR%
echo Web根目录: %INSTALL_DIR%\public
echo 缓存目录: %INSTALL_DIR%\cache
echo.
echo API端点:
echo   获取头像: http://your-domain/head/{username}
echo   无缓存获取: http://your-domain/head/{username}/nocache
echo   查看调用次数: http://your-domain/uses
echo.
echo 配置文件:
echo   IIS: %INSTALL_DIR%\public\web.config
echo   Apache: %INSTALL_DIR%\public\.htaccess
echo   Nginx示例: %INSTALL_DIR%\nginx.conf.example
echo.
goto installation_complete

:installation_complete
echo.
echo =========================================
echo %GREEN%[SUCCESS]%NC% 一键安装完成！
echo =========================================
echo.
echo 后续步骤:
echo 1. 根据上面的配置指南设置Web服务器
echo 2. 访问您的网站测试API功能
echo 3. 查看项目文档了解更多配置选项
echo.
echo 如需帮助，请访问: https://github.com/XRain66/minecraft-headshot-api
echo.

:end
pause
exit /b 0