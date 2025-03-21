# 使用 Flutter 官方 Docker 镜像
FROM cirrusci/flutter:latest  

# 创建一个非 root 用户 flutter
RUN useradd -m flutter  

# 创建 /app 目录，并赋予 flutter 用户权限
RUN mkdir -p /app && chown -R flutter:flutter /app

# 切换到 flutter 用户
USER flutter

# 设置工作目录
WORKDIR /app  

# 复制代码到容器
COPY . .  

# 运行 flutter doctor（确保 SDK 正常）
RUN flutter doctor --verbose  

# 安装 Flutter 依赖
RUN flutter pub get  

# 运行 Flutter Web 服务器
CMD ["flutter", "run", "-d", "chrome", "--web-port", "8080", "--web-hostname", "0.0.0.0"]