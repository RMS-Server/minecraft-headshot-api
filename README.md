# Minecraft Headshot API

一个高性能的 Minecraft 玩家头像 API 服务，支持获取任何正版玩家的头像。本项目使用 PHP 开发，提供 WebP 格式的图像输出，支持缓存机制，适合用于各类 Minecraft 社区网站、论坛、皮肤站等场景。

[English](README_EN.md) | 简体中文

## ✨ 特点

- 🚀 **快速响应**：集成缓存机制，减少 API 调用
- 🎨 **WebP 格式**：更小的文件体积，更好的图像质量
- 🔧 **简单集成**：RESTful API 设计，使用方便
- 🛡️ **错误处理**：完善的错误处理机制
- 💾 **资源优化**：支持浏览器缓存，节省带宽

## 🔥 现成API

`http://api.rms.net.cn/head/XRain666`

## 🚀 快速开始

### 环境要求

- PHP >= 7.4
- Nginx/Apache
- PHP 扩展：
  - GD 扩展（图像处理）
  - cURL 扩展（API 请求）
  - WebP 支持

### 🚀 一键部署（推荐）

#### Linux 系统（Ubuntu/Debian/CentOS）

复制以下命令到终端直接运行：

```bash
curl -fsSL https://raw.githubusercontent.com/RMS-Server/minecraft-headshot-api/master/scripts/install.sh | sudo bash
```

或者使用 wget：

```bash
wget -qO- https://raw.githubusercontent.com/RMS-Server/minecraft-headshot-api/master/scripts/install.sh | sudo bash
```

#### Windows 系统

以管理员身份打开 PowerShell，运行：

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/RMS-Server/minecraft-headshot-api/master/scripts/install.bat" -OutFile "install.bat"; .\install.bat
```

或者手动下载：

```batch
curl -o install.bat https://raw.githubusercontent.com/RMS-Server/minecraft-headshot-api/master/scripts/install.bat && install.bat
```

### 手动安装步骤

如果一键部署遇到问题，可以手动安装：

1. 克隆仓库：
```bash
git clone https://github.com/RMS-Server/minecraft-headshot-api.git
```

2. 安装依赖：
```bash
composer install
```

3. 配置 Web 服务器：
将网站根目录指向 `public` 文件夹，并配置 URL 重写规则。

### Nginx 配置

项目提供了一个示例 Nginx 配置文件 `nginx.conf.example`。使用步骤：

1. 复制示例配置文件：
```bash
cp nginx.conf.example nginx.conf
```

2. 修改配置文件中的以下内容：
   - `server_name`: 改为你的域名
   - `root`: 改为你的项目 public 目录的实际路径
   - `fastcgi_pass`: 根据你的 PHP-FPM 配置调整
   - 日志路径: 设置适合你的环境的日志路径

3. 测试配置：
```bash
nginx -t
```

4. 重启 Nginx：
```bash
systemctl restart nginx
```


### 基本重写规则

如果你想使用自己的 Nginx 配置，确保至少包含以下重写规则：

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

## 📦 使用方法

### 基本用法

- 获取玩家头像（使用缓存）：
  ```
  GET /head/{username}
  ```

  示例：
  ```
  http://your-domain/head/Notch
  ```

- 获取玩家头像（不使用缓存）：
  ```
  GET /head/{username}/nocache
  ```

  示例：
  ```
  http://your-domain/head/Notch/nocache
  ```

- 获取API调用次数：
  ```
  GET /uses
  ```

  示例：
  ```
  http://your-domain/uses
  ```

### 响应格式

- 成功：返回 WebP 格式的头像图片
- 失败：返回 JSON 格式的错误信息
```json
{
    "error": "错误信息"
}
```

## 🔨 开发说明

### 项目结构

```
/
├── public/           # 公共访问目录
│   └── index.php    # 入口文件
├── src/             # 源代码目录
│   ├── Controllers/ # 控制器
│   ├── Services/    # 服务层
│   └── Cache/       # 缓存处理
├── cache/           # 缓存目录
├── composer.json    # 依赖配置
└── README.md        # 项目说明
```

### 缓存机制

- **本地缓存**：默认路由 `/head/{username}` 会缓存已获取的头像，有效期 7 天
- **HTTP 缓存**：默认路由配置浏览器缓存，有效期 1 小时
- **无缓存模式**：使用 `/head/{username}/nocache` 路由可跳过所有缓存，始终获取最新头像
- **错误缓存**：临时缓存无效的用户名，避免重复请求


## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交改动：`git commit -m 'Add some AmazingFeature'`
4. 推送分支：`git push origin feature/AmazingFeature`
5. 提交 Pull Request

## 📄 开源协议

本项目采用 GPL 协议 - 查看 [LICENSE](LICENSE) 文件了解详情