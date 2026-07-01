# SillyTavern Docker 一键部署

这个目录提供了一个 Linux 云服务器部署脚本，适合服务器已经安装 Docker 的情况。

脚本支持两种部署方式：

- 官方镜像部署：直接拉取 `ghcr.io/sillytavern/sillytavern:latest`
- 源码构建部署：适合你会修改 SillyTavern 源代码的情况

## 快速开始

把 `sillytavern-onekey.sh` 复制到服务器后执行：

```bash
chmod +x sillytavern-onekey.sh
sudo ./sillytavern-onekey.sh
```

启动后访问：

```text
http://你的服务器IP:8000
```

如果想换端口，比如使用 `8080`：

```bash
sudo PORT=8080 ./sillytavern-onekey.sh
```

## 部署你修改过的源码

如果你会修改源代码，建议把完整项目复制或克隆到服务器，然后用源码构建模式启动。

例如：

```bash
git clone https://github.com/DraDai/Aowu-SillyTavern.git SillyTavern
cd SillyTavern
sudo MODE=source ./deploy/sillytavern-onekey.sh
```

也可以手动指定源码目录：

```bash
sudo MODE=source SOURCE_DIR=/path/to/SillyTavern ./deploy/sillytavern-onekey.sh
```

之后每次改完源码并同步到服务器后，重新构建并启动：

```bash
cd /opt/sillytavern
sudo docker compose build --pull
sudo docker compose up -d
```

## 脚本会创建什么

脚本会创建 `/opt/sillytavern`，并把数据目录挂载出来：

```text
/opt/sillytavern/config
/opt/sillytavern/data
/opt/sillytavern/plugins
/opt/sillytavern/extensions
```

这些目录用于保存配置、角色数据、聊天数据、插件和第三方扩展。重建镜像或重启容器时，这些数据不会丢失。

## 常用命令

查看容器状态：

```bash
cd /opt/sillytavern
sudo docker compose ps
```

查看日志：

```bash
cd /opt/sillytavern
sudo docker compose logs -f
```

更新官方镜像部署：

```bash
cd /opt/sillytavern
sudo docker compose pull
sudo docker compose up -d
```

更新源码构建部署：

```bash
cd /opt/sillytavern
sudo docker compose build --pull
sudo docker compose up -d
```

停止服务：

```bash
cd /opt/sillytavern
sudo docker compose down
```

## 注意事项

如果需要从公网访问，请在云服务器安全组或防火墙中放行 TCP `8000` 端口。

如果长期暴露到公网，建议再加一层 HTTPS 和访问认证，可以使用 Caddy、Nginx 或云厂商网关做反向代理。
