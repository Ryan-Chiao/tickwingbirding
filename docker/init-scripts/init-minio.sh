#!/bin/sh
# Tickwing MinIO 初始化脚本
# 在 minio-init 容器中执行，创建默认 bucket

set -e

MINIO_HOST="http://minio:9000"
ACCESS_KEY="${MINIO_ROOT_USER:-minioadmin}"
SECRET_KEY="${MINIO_ROOT_PASSWORD:-minioadmin}"

echo "Waiting for MinIO to be ready..."
sleep 3

# 配置 MinIO Client
mc alias set tickwing "$MINIO_HOST" "$ACCESS_KEY" "$SECRET_KEY"

# 创建 bucket（已存在则跳过）
mc mb --ignore-existing tickwing/tickwing-videos
mc mb --ignore-existing tickwing/tickwing-avatars
mc mb --ignore-existing tickwing/tickwing-thumbnails

# 设置 public 读取策略（缩略图和头像允许公开访问）
mc anonymous set download tickwing/tickwing-avatars
mc anonymous set download tickwing/tickwing-thumbnails

echo "MinIO buckets initialized:"
mc ls tickwing
