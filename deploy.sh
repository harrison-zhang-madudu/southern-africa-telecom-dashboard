#!/bin/bash

# 自动部署脚本 - 将构建产物推送到 gh-pages 分支

set -e

echo "开始部署..."

# 1. 构建项目
echo "1. 构建项目..."
npm run build

# 2. 进入 dist 目录
echo "2. 进入 dist 目录..."
cd dist

# 3. 初始化 git
echo "3. 初始化 git..."
git init
git add -A
git commit -m "Deploy: $(date '+%Y-%m-%d %H:%M:%S')"

# 4. 推送到 gh-pages 分支
echo "4. 推送到 gh-pages 分支..."
git push -f https://github.com/harrison-zhang-madudu/southern-africa-telecom-dashboard.git main:gh-pages

echo "部署完成！"
echo "访问地址: https://harrison-zhang-madudu.github.io/southern-africa-telecom-dashboard/"