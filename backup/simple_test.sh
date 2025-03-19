#!/bin/sh

# テスト用のデータを作成
echo "テストデータの作成を開始します..."

# Elasticsearchのテストデータ
curl -X POST "http://elasticsearch:9200/test_index/_doc" -H "Content-Type: application/json" -d "{\"test_field\": \"test_value\", \"timestamp\": \"$(date -u +\"%Y-%m-%dT%H:%M:%SZ\")\"}"

# Prometheusのテストデータ
echo "prometheus_test_metric 1" > /prometheus/test_data.txt

# Grafanaのテストデータ
echo "grafana_test_data" > /var/lib/grafana/test_data.txt

echo "テストが正常に完了しました！"
