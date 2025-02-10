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

### 安装步骤

1. 克隆仓库：
```bash
git clone https://github.com/yourusername/minecraft-headshot-api.git
```

2. 安装依赖：
```bash
composer install
```

3. 配置 Web 服务器：
将网站根目录指向 `public` 文件夹，并配置 URL 重写规则。

### Nginx 配置示例

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

## 📦 使用方法

### 基本用法

获取玩家头像：
```
GET /head/{username}
```

示例：
```
http://your-domain/head/Notch
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

- 本地缓存：缓存已获取的头像
- HTTP 缓存：配置浏览器缓存，有效期 30 天
- 错误缓存：临时缓存无效的用户名

## 📝 开发计划

- [ ] 支持自定义图片尺寸
- [ ] 添加 API 访问频率限制
- [ ] 支持更多图片格式
- [ ] 添加用户认证机制
- [ ] 优化缓存策略

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/AmazingFeature`
3. 提交改动：`git commit -m 'Add some AmazingFeature'`
4. 推送分支：`git push origin feature/AmazingFeature`
5. 提交 Pull Request

## 📄 开源协议

本项目采用 MIT 协议 - 查看 [LICENSE](LICENSE) 文件了解详情

## 👨‍💻 作者

XRain

## 🙏 鸣谢

- [Minecraft](https://www.minecraft.net/) - 提供游戏和 API 支持
- [Slim Framework](https://www.slimframework.com/) - PHP 微框架
- [Mojang API](https://wiki.vg/Mojang_API) - 官方 API 文档 