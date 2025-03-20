#!/bin/bash

# バックアップディレクトリの設定
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# 一時ディレクトリの作成
TMP_DIR=$(mktemp -d)
echo "一時ディレクトリを作成: $TMP_DIR"

# Elasticsearchのバックアップ
echo "Elasticsearchのバックアップを開始..."
curl -X PUT "http://elasticsearch:9200/_snapshot/backup" -H "Content-Type: application/json" -d '{
    "type": "fs",
    "settings": {
        "location": "/backup/elasticsearch"
    }
}'

curl -X PUT "http://elasticsearch:9200/_snapshot/backup/snapshot_${DATE}?wait_for_completion=true"

# Prometheusのバックアップ
echo "Prometheusのバックアップを開始..."
cp -r /prometheus/* "${TMP_DIR}/prometheus/"

# Grafanaのバックアップ
echo "Grafanaのバックアップを開始..."
cp -r /var/lib/grafana/* "${TMP_DIR}/grafana/"

# ログファイルのバックアップ
echo "ログファイルのバックアップを開始..."
cp -r /var/log/* "${TMP_DIR}/logs/"

# バックアップの圧縮
echo "バックアップを圧縮..."
cd "${TMP_DIR}"
tar czf "${BACKUP_DIR}/backup_${DATE}.tar.gz" ./*

# 古いバックアップの削除
echo "古いバックアップを削除..."
find "${BACKUP_DIR}" -name "backup_*.tar.gz" -mtime +${RETENTION_DAYS} -delete

# 一時ディレクトリの削除
echo "一時ディレクトリを削除..."
rm -rf "${TMP_DIR}"

echo "バックアップが完了しました" 