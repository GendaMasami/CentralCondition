#!/bin/bash

# テスト用のデータを作成
echo "テストデータの作成を開始します..."

# Elasticsearchのテストデータ
curl -X POST "http://elasticsearch:9200/test_index/_doc" -H "Content-Type: application/json" -d '{
  "test_field": "test_value",
  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
}'

# Prometheusのテストデータ
echo "prometheus_test_metric 1" > /prometheus/test_data.txt

# Grafanaのテストデータ
echo "grafana_test_data" > /var/lib/grafana/test_data.txt

# バックアップの実行
echo "バックアップを実行します..."
/backup/backup.sh

# バックアップファイルの確認
echo "バックアップファイルを確認します..."
BACKUP_FILE=$(ls -t /backup/backup_*.tar.gz | head -n1)
if [ -z "$BACKUP_FILE" ]; then
    echo "エラー: バックアップファイルが見つかりません"
    exit 1
fi

echo "バックアップファイル: $BACKUP_FILE"

# バックアップの整合性チェック
echo "バックアップの整合性チェックを実行します..."
tar -tzf "$BACKUP_FILE" > /dev/null
if [ $? -ne 0 ]; then
    echo "エラー: バックアップファイルが破損しています"
    exit 1
fi

# 復元テスト
echo "復元テストを実行します..."
/backup/restore.sh "$BACKUP_FILE"

# 復元後のデータ確認
echo "復元後のデータを確認します..."

# Elasticsearchのデータ確認
ES_RESTORE_CHECK=$(curl -s "http://elasticsearch:9200/test_index/_search" | grep -c "test_value")
if [ "$ES_RESTORE_CHECK" -eq 0 ]; then
    echo "エラー: Elasticsearchのデータが正しく復元されていません"
    exit 1
fi

# Prometheusのデータ確認
PROM_RESTORE_CHECK=$(cat /prometheus/test_data.txt | grep -c "prometheus_test_metric")
if [ "$PROM_RESTORE_CHECK" -eq 0 ]; then
    echo "エラー: Prometheusのデータが正しく復元されていません"
    exit 1
fi

# Grafanaのデータ確認
GRAFANA_RESTORE_CHECK=$(cat /var/lib/grafana/test_data.txt | grep -c "grafana_test_data")
if [ "$GRAFANA_RESTORE_CHECK" -eq 0 ]; then
    echo "エラー: Grafanaのデータが正しく復元されていません"
    exit 1
fi

echo "テストが正常に完了しました！" 