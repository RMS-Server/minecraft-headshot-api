#!/bin/bash

# Minecraft Headshot API - 一键安装脚本
# 作者: XRain
# 适用系统: Ubuntu/Debian/CentOS/RHEL

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 项目配置
PROJECT_REPO="https://github.com/XRain66/minecraft-headshot-api.git"
PROJECT_NAME="minecraft-headshot-api"
INSTALL_DIR="/var/www/$PROJECT_NAME"
TEMP_DIR="/tmp/$PROJECT_NAME-install"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        DISTRO=$ID
        VERSION=$VERSION_ID
    else
        log_error "无法检测操作系统版本"
        exit 1
    fi
    log_info "检测到操作系统: $OS"
}

# 检测是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root权限运行此脚本"
        log_info "使用方法: curl -fsSL https://raw.githubusercontent.com/XRain66/minecraft-headshot-api/master/scripts/install.sh | sudo bash"
        exit 1
    fi
}

# 清理临时文件
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "清理临时文件完成"
    fi
}

# 错误处理
error_exit() {
    log_error "安装过程中出现错误，正在清理..."
    cleanup
    exit 1
}

# 更新系统包
update_system() {
    log_info "更新系统包..."
    case $DISTRO in
        ubuntu|debian)
            apt update && apt upgrade -y
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                dnf update -y
            else
                yum update -y
            fi
            ;;
        *)
            log_warning "未知的发行版，跳过系统更新"
            ;;
    esac
}

# 安装基础软件包
install_base_packages() {
    log_info "安装基础软件包..."
    case $DISTRO in
        ubuntu|debian)
            apt install -y curl wget unzip git software-properties-common
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                dnf install -y curl wget unzip git
            else
                yum install -y curl wget unzip git
            fi
            ;;
    esac
}

# 安装PHP
install_php() {
    log_info "检查PHP安装状态..."
    
    if command -v php &> /dev/null; then
        PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
        log_info "检测到PHP版本: $PHP_VERSION"
        
        if [ "$(printf '%s\n' "7.4" "$PHP_VERSION" | sort -V | head -n1)" = "7.4" ]; then
            log_success "PHP版本满足要求 (>= 7.4)"
        else
            log_error "PHP版本过低，需要 >= 7.4"
            exit 1
        fi
    else
        log_info "安装PHP..."
        case $DISTRO in
            ubuntu|debian)
                add-apt-repository ppa:ondrej/php -y
                apt update
                apt install -y php8.1 php8.1-fpm php8.1-cli php8.1-common php8.1-gd php8.1-curl php8.1-mbstring php8.1-json
                ;;
            centos|rhel)
                if [ "$VERSION" == "7" ]; then
                    yum install -y epel-release
                    yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
                    yum-config-manager --enable remi-php81
                else
                    dnf install -y epel-release
                    dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
                    dnf module enable php:remi-8.1 -y
                fi
                yum install -y php php-fpm php-cli php-common php-gd php-curl php-mbstring php-json
                ;;
            fedora)
                dnf install -y php php-fpm php-cli php-common php-gd php-curl php-mbstring php-json
                ;;
        esac
    fi
}

# 检查PHP扩展
check_php_extensions() {
    log_info "检查PHP扩展..."
    
    REQUIRED_EXTENSIONS=("gd" "curl" "json" "mbstring")
    MISSING_EXTENSIONS=()
    
    for ext in "${REQUIRED_EXTENSIONS[@]}"; do
        if ! php -m | grep -q "^$ext$"; then
            MISSING_EXTENSIONS+=($ext)
        fi
    done
    
    if [ ${#MISSING_EXTENSIONS[@]} -eq 0 ]; then
        log_success "所有必需的PHP扩展已安装"
    else
        log_error "缺少PHP扩展: ${MISSING_EXTENSIONS[*]}"
        exit 1
    fi
    
    # 检查WebP支持
    if php -r "if (function_exists('imagewebp')) { echo 'WebP supported'; } else { echo 'WebP not supported'; exit(1); }" &> /dev/null; then
        log_success "WebP支持已启用"
    else
        log_warning "WebP支持未启用，请检查GD扩展配置"
    fi
}

# 安装Composer
install_composer() {
    log_info "检查Composer安装状态..."
    
    if command -v composer &> /dev/null; then
        log_success "Composer已安装"
    else
        log_info "安装Composer..."
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer
        chmod +x /usr/local/bin/composer
        log_success "Composer安装完成"
    fi
}

# 安装Nginx
install_nginx() {
    log_info "检查Nginx安装状态..."
    
    if command -v nginx &> /dev/null; then
        log_success "Nginx已安装"
    else
        log_info "安装Nginx..."
        case $DISTRO in
            ubuntu|debian)
                apt install -y nginx
                ;;
            centos|rhel|fedora)
                if command -v dnf &> /dev/null; then
                    dnf install -y nginx
                else
                    yum install -y nginx
                fi
                ;;
        esac
        log_success "Nginx安装完成"
    fi
}

# 下载项目代码
download_project() {
    log_info "下载项目代码..."
    
    # 清理之前的临时目录
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    
    # 创建临时目录
    mkdir -p "$TEMP_DIR"
    
    # 克隆项目
    if git clone "$PROJECT_REPO" "$TEMP_DIR"; then
        log_success "项目代码下载完成"
    else
        log_error "项目代码下载失败"
        exit 1
    fi
    
    # 创建安装目录
    if [ -d "$INSTALL_DIR" ]; then
        log_info "备份现有安装..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # 移动项目到安装目录
    mkdir -p "$(dirname "$INSTALL_DIR")"
    mv "$TEMP_DIR" "$INSTALL_DIR"
    
    log_success "项目安装到: $INSTALL_DIR"
}

# 安装项目依赖
install_project_dependencies() {
    log_info "安装项目依赖..."
    
    cd "$INSTALL_DIR"
    
    if [ ! -f "composer.json" ]; then
        log_error "未找到composer.json文件"
        exit 1
    fi
    
    composer install --no-dev --optimize-autoloader
    log_success "项目依赖安装完成"
}

# 设置目录权限
setup_permissions() {
    log_info "设置目录权限..."
    
    # 创建缓存目录
    mkdir -p "$INSTALL_DIR/cache"
    
    # 设置所有者
    chown -R www-data:www-data "$INSTALL_DIR"
    
    # 设置权限
    chmod -R 755 "$INSTALL_DIR"
    chmod -R 777 "$INSTALL_DIR/cache"
    
    log_success "目录权限设置完成"
}

# 配置Nginx
configure_nginx() {
    log_info "配置Nginx..."
    
    # 获取服务器IP或域名
    SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")
    
    log_info "检测到服务器IP: $SERVER_IP"
    echo "请输入域名 (直接回车使用 $SERVER_IP): "
    read -r DOMAIN_NAME
    
    if [ -z "$DOMAIN_NAME" ]; then
        DOMAIN_NAME="$SERVER_IP"
    fi
    
    # 创建Nginx配置文件
    NGINX_CONF_FILE="/etc/nginx/sites-available/$PROJECT_NAME"
    NGINX_CONF_LINK="/etc/nginx/sites-enabled/$PROJECT_NAME"
    
    cat > "$NGINX_CONF_FILE" << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;
    index index.php index.html;
    root $INSTALL_DIR/public;

    # Slim Framework 重写规则
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    # PHP 文件处理
    location ~ \.php$ {
        try_files \$uri =404;
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    # 图片缓存设置
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|webp)$ {
        expires      30d;
        error_log off;
        access_log off;
        add_header Cache-Control "public, no-transform";
    }

    # JS/CSS缓存设置
    location ~ .*\.(js|css)?$ {
        expires      12h;
        error_log off;
        access_log off;
    }

    # 日志配置
    access_log  /var/log/nginx/${PROJECT_NAME}_access.log;
    error_log   /var/log/nginx/${PROJECT_NAME}_error.log;
}
EOF

    # 创建软链接
    if [ ! -L "$NGINX_CONF_LINK" ]; then
        ln -s "$NGINX_CONF_FILE" "$NGINX_CONF_LINK"
    fi
    
    # 删除默认配置
    if [ -L "/etc/nginx/sites-enabled/default" ]; then
        rm "/etc/nginx/sites-enabled/default"
    fi
    
    # 测试配置
    if nginx -t; then
        log_success "Nginx配置文件创建成功"
    else
        log_error "Nginx配置文件有错误"
        exit 1
    fi
}

# 启动服务
start_services() {
    log_info "启动服务..."
    
    # 启动PHP-FPM
    case $DISTRO in
        ubuntu|debian)
            systemctl enable php8.1-fpm
            systemctl start php8.1-fpm
            ;;
        centos|rhel|fedora)
            systemctl enable php-fpm
            systemctl start php-fpm
            ;;
    esac
    
    # 启动Nginx
    systemctl enable nginx
    systemctl restart nginx
    
    log_success "服务启动完成"
}

# 运行测试
run_tests() {
    log_info "运行环境测试..."
    
    # 检查服务状态
    if systemctl is-active --quiet nginx; then
        log_success "Nginx运行正常"
    else
        log_error "Nginx未运行"
    fi
    
    if systemctl is-active --quiet php-fpm || systemctl is-active --quiet php8.1-fpm; then
        log_success "PHP-FPM运行正常"
    else
        log_error "PHP-FPM未运行"
    fi
    
    # 测试API端点
    log_info "测试API端点..."
    sleep 2
    
    if curl -s "http://localhost/uses" > /dev/null; then
        log_success "API端点测试通过"
    else
        log_warning "API端点测试失败，请检查配置"
    fi
}

# 显示安装结果
show_installation_result() {
    echo ""
    echo "========================================="
    log_success "安装完成！"
    echo "========================================="
    echo ""
    echo "项目信息:"
    echo "  项目路径: $INSTALL_DIR"
    echo "  访问地址: http://$DOMAIN_NAME"
    echo ""
    echo "API使用示例:"
    echo "  获取头像: http://$DOMAIN_NAME/head/XRain666"
    echo "  无缓存获取: http://$DOMAIN_NAME/head/XRain666/nocache"
    echo "  查看调用次数: http://$DOMAIN_NAME/uses"
    echo ""
    echo "管理命令:"
    echo "  重启Nginx: systemctl restart nginx"
    echo "  重启PHP-FPM: systemctl restart php-fpm"
    echo "  查看错误日志: tail -f /var/log/nginx/${PROJECT_NAME}_error.log"
    echo "  查看访问日志: tail -f /var/log/nginx/${PROJECT_NAME}_access.log"
    echo ""
    echo "项目目录结构:"
    echo "  配置文件: $INSTALL_DIR/nginx.conf.example"
    echo "  缓存目录: $INSTALL_DIR/cache"
    echo "  Web根目录: $INSTALL_DIR/public"
    echo ""
}

# 主函数
main() {
    echo "========================================="
    echo "  Minecraft Headshot API 一键安装脚本"
    echo "========================================="
    echo ""
    
    # 设置错误处理
    trap error_exit ERR
    
    detect_os
    check_root
    
    log_info "开始安装..."
    
    update_system
    install_base_packages
    install_php
    check_php_extensions
    install_composer
    install_nginx
    download_project
    install_project_dependencies
    setup_permissions
    configure_nginx
    start_services
    run_tests
    cleanup
    show_installation_result
    
    log_success "一键安装完成！"
}

# 运行主函数
main "$@"