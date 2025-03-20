#!/bin/bash

# バックアップファイルの確認
BACKUP_FILE=$1
if [ -z "$BACKUP_FILE" ]; then
    echo "使用方法: $0 <バックアップファイル>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "エラー: バックアップファイル '$BACKUP_FILE' が見つかりません"
    exit 1
fi

# 一時ディレクトリの作成
TMP_DIR=$(mktemp -d)
echo "一時ディレクトリを作成: $TMP_DIR"

# バックアップの展開
echo "バックアップを展開..."
tar -xzf "$BACKUP_FILE" -C "$TMP_DIR"

# Elasticsearchの復元
echo "Elasticsearchを復元..."
curl -X POST "http://elasticsearch:9200/_snapshot/backup/snapshot_${DATE}/_restore?wait_for_completion=true"

# Prometheusの復元
echo "Prometheusを復元..."
rm -rf /prometheus/*
cp -r "${TMP_DIR}/prometheus/"* /prometheus/

# Grafanaの復元
echo "Grafanaを復元..."
rm -rf /var/lib/grafana/*
cp -r "${TMP_DIR}/grafana/"* /var/lib/grafana/

# ログファイルの復元
echo "ログファイルを復元..."
cp -r "${TMP_DIR}/logs/"* /var/log/

# サービスの再起動
echo "サービスを再起動..."
docker-compose restart prometheus grafana

# 一時ディレクトリの削除
echo "一時ディレクトリを削除..."
rm -rf "$TMP_DIR"

echo "復元が完了しました" 