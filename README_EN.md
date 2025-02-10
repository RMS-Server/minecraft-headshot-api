# Minecraft Headshot API

A high-performance Minecraft player head avatar API service that retrieves head avatars for any legitimate Minecraft player. Built with PHP, this service provides WebP image output with caching support, perfect for Minecraft communities, forums, and skin servers.

English | [简体中文](README.md)

## ✨ Features

- 🚀 **Fast Response**: Integrated caching mechanism to reduce API calls
- 🎨 **WebP Format**: Smaller file size with better image quality
- 🔧 **Easy Integration**: RESTful API design for simple implementation
- 🛡️ **Error Handling**: Robust error handling mechanism
- 💾 **Resource Optimization**: Browser caching support for bandwidth saving

## 🔥 Ready-to-Use API

Try it now: `http://api.rms.net.cn/head/XRain666`

## 🚀 Quick Start

### Requirements

- PHP >= 7.4
- Nginx/Apache
- PHP Extensions:
  - GD Extension (Image Processing)
  - cURL Extension (API Requests)
  - WebP Support

### Installation

1. Clone the repository:
```bash
git clone https://github.com/XRain66/minecraft-headshot-api.git
```

2. Install dependencies:
```bash
composer install
```

3. Configure Web Server:
Point your web root to the `public` folder and set up URL rewriting rules.

### Nginx Configuration

The project provides an example Nginx configuration file `nginx.conf.example`. Follow these steps:

1. Copy the example configuration file:
```bash
cp nginx.conf.example nginx.conf
```

2. Modify the following in the configuration file:
   - `server_name`: Change to your domain
   - `root`: Change to your project's actual public directory path
   - `fastcgi_pass`: Adjust according to your PHP-FPM configuration
   - Log paths: Set appropriate log paths for your environment

3. Test the configuration:
```bash
nginx -t
```

4. Restart Nginx:
```bash
systemctl restart nginx
```

Note: For security reasons, `nginx.conf` has been added to `.gitignore` and will not be committed to version control.

### Basic Rewrite Rules

If you prefer to use your own Nginx configuration, ensure it includes at least these rewrite rules:

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

## 📦 Usage

### Basic Usage

Get player head avatar:
```
GET /head/{username}
```

Example:
```
http://your-domain/head/Notch
```

### Response Format

- Success: Returns WebP format head avatar image
- Failure: Returns JSON format error message
```json
{
    "error": "Error message"
}
```

## 🔨 Development

### Project Structure

```
/
├── public/           # Public directory
│   └── index.php    # Entry point
├── src/             # Source code
│   ├── Controllers/ # Controllers
│   ├── Services/    # Services
│   └── Cache/       # Cache handling
├── cache/           # Cache directory
├── composer.json    # Dependencies
└── README.md        # Documentation
```

### Caching Mechanism

- Local Cache: Cache retrieved avatars
- HTTP Cache: Browser cache with 30-day expiration
- Error Cache: Temporary cache for invalid usernames

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/AmazingFeature`
3. Commit your changes: `git commit -m 'Add some AmazingFeature'`
4. Push to the branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details