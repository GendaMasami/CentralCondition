#!/bin/bash

# 監査設定
AUDIT_DIR="/audit"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${AUDIT_DIR}/internal_audit_${DATE}.json"

# 監査項目の定義
declare -A AUDIT_ITEMS=(
    ["system_metrics"]="CPU、メモリ、ディスク使用率の確認"
    ["security_logs"]="セキュリティ関連ログの確認"
    ["access_logs"]="アクセスログの確認"
    ["backup_status"]="バックアップ状態の確認"
    ["service_status"]="サービス状態の確認"
)

# 監査結果の初期化
echo "{" > "$REPORT_FILE"
echo "  \"audit_date\": \"$(date -Iseconds)\"," >> "$REPORT_FILE"
echo "  \"items\": {" >> "$REPORT_FILE"

# システムメトリクスの監査
echo "    \"system_metrics\": {" >> "$REPORT_FILE"
CPU_USAGE=$(curl -s http://node-exporter:9100/metrics | grep 'node_cpu_seconds_total{mode="idle"}' | awk '{print $2}')
MEMORY_USAGE=$(curl -s http://node-exporter:9100/metrics | grep 'node_memory_MemAvailable_bytes' | awk '{print $2}')
DISK_USAGE=$(curl -s http://node-exporter:9100/metrics | grep 'node_filesystem_avail_bytes' | awk '{print $2}')

echo "      \"cpu_usage\": $CPU_USAGE," >> "$REPORT_FILE"
echo "      \"memory_usage\": $MEMORY_USAGE," >> "$REPORT_FILE"
echo "      \"disk_usage\": $DISK_USAGE," >> "$REPORT_FILE"
echo "      \"status\": \"$(if [ $(echo "$CPU_USAGE < 80" | bc) -eq 1 ] && [ $(echo "$MEMORY_USAGE < 75" | bc) -eq 1 ]; then echo "OK"; else echo "WARNING"; fi)\"" >> "$REPORT_FILE"
echo "    }," >> "$REPORT_FILE"

# セキュリティログの監査
echo "    \"security_logs\": {" >> "$REPORT_FILE"
SECURITY_EVENTS=$(curl -s -X GET "http://elasticsearch:9200/security-*/_count" | jq '.count')
echo "      \"total_events\": $SECURITY_EVENTS," >> "$REPORT_FILE"
echo "      \"status\": \"$(if [ $SECURITY_EVENTS -gt 0 ]; then echo "OK"; else echo "WARNING"; fi)\"" >> "$REPORT_FILE"
echo "    }," >> "$REPORT_FILE"

# アクセスログの監査
echo "    \"access_logs\": {" >> "$REPORT_FILE"
ACCESS_EVENTS=$(curl -s -X GET "http://elasticsearch:9200/nginx-access-*/_count" | jq '.count')
echo "      \"total_events\": $ACCESS_EVENTS," >> "$REPORT_FILE"
echo "      \"status\": \"$(if [ $ACCESS_EVENTS -gt 0 ]; then echo "OK"; else echo "WARNING"; fi)\"" >> "$REPORT_FILE"
echo "    }," >> "$REPORT_FILE"

# バックアップ状態の監査
echo "    \"backup_status\": {" >> "$REPORT_FILE"
BACKUP_COUNT=$(ls -1 /backup/backup_*.tar.gz 2>/dev/null | wc -l)
echo "      \"backup_count\": $BACKUP_COUNT," >> "$REPORT_FILE"
echo "      \"status\": \"$(if [ $BACKUP_COUNT -ge 1 ]; then echo "OK"; else echo "WARNING"; fi)\"" >> "$REPORT_FILE"
echo "    }," >> "$REPORT_FILE"

# サービス状態の監査
echo "    \"service_status\": {" >> "$REPORT_FILE"
SERVICES=("prometheus" "grafana" "elasticsearch" "logstash" "kibana")
for service in "${SERVICES[@]}"; do
    STATUS=$(docker inspect $service --format='{{.State.Status}}')
    echo "      \"$service\": \"$STATUS\"," >> "$REPORT_FILE"
done
echo "      \"status\": \"$(if [ $(docker ps -q | wc -l) -eq ${#SERVICES[@]} ]; then echo "OK"; else echo "WARNING"; fi)\"" >> "$REPORT_FILE"
echo "    }" >> "$REPORT_FILE"

# 監査結果の終了
echo "  }" >> "$REPORT_FILE"
echo "}" >> "$REPORT_FILE"

# 監査結果の通知
if grep -q "WARNING" "$REPORT_FILE"; then
    echo "監査で警告が検出されました。詳細は $REPORT_FILE を確認してください。"
    exit 1
else
    echo "監査が正常に完了しました。"
fi 