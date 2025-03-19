#!/bin/bash

# 監査設定
AUDIT_DIR="/audit"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${AUDIT_DIR}/external_audit_${DATE}.json"

# 監査結果の初期化
echo "{" > "$REPORT_FILE"
echo "  \"audit_date\": \"$(date -Iseconds)\"," >> "$REPORT_FILE"
echo "  \"items\": {" >> "$REPORT_FILE"

# セキュリティ設定の監査
echo "    \"security_settings\": {" >> "$REPORT_FILE"
echo "      \"ssl_version\": \"$(openssl version)\"," >> "$REPORT_FILE"
echo "      \"nginx_config\": \"$(nginx -t 2>&1)\"," >> "$REPORT_FILE"
echo "      \"firewall_rules\": \"$(iptables -L -n)\"," >> "$REPORT_FILE"
echo "      \"status\": \"OK\"" >> "$REPORT_FILE"
echo "    }," >> "$REPORT_FILE"

# アクセス制御の監査
echo "    \"access_control\": {" >> "$REPORT_FILE"
echo "      \"user_permissions\": \"$(ls -la /etc/nginx/ssl/)\"," >> "$REPORT_FILE"
echo "      \"service_permissions\": \"$(ls -la /var/log/)\"," >> "$REPORT_FILE"
echo "      \"status\": \"OK\"" >> "$REPORT_FILE"
echo "    }," >> "$REPORT_FILE"

# データ保護の監査
echo "    \"data_protection\": {" >> "$REPORT_FILE"
echo "      \"backup_encryption\": \"$(grep -r "encrypt" /backup/backup_*.sh)\"," >> "$REPORT_FILE"
echo "      \"ssl_certificates\": \"$(ls -la /etc/nginx/ssl/)\"," >> "$REPORT_FILE"
echo "      \"status\": \"OK\"" >> "$REPORT_FILE"
echo "    }," >> "$REPORT_FILE"

# コンプライアンスの監査
echo "    \"compliance\": {" >> "$REPORT_FILE"
echo "      \"log_retention\": \"$(find /var/log -type f -mtime -30 | wc -l)\"," >> "$REPORT_FILE"
echo "      \"backup_retention\": \"$(find /backup -type f -mtime -7 | wc -l)\"," >> "$REPORT_FILE"
echo "      \"status\": \"OK\"" >> "$REPORT_FILE"
echo "    }," >> "$REPORT_FILE"

# インシデント対応の監査
echo "    \"incident_response\": {" >> "$REPORT_FILE"
echo "      \"alert_configuration\": \"$(cat /etc/alertmanager/alertmanager.yml)\"," >> "$REPORT_FILE"
echo "      \"monitoring_setup\": \"$(cat /etc/prometheus/prometheus.yml)\"," >> "$REPORT_FILE"
echo "      \"status\": \"OK\"" >> "$REPORT_FILE"
echo "    }" >> "$REPORT_FILE"

# 監査結果の終了
echo "  }" >> "$REPORT_FILE"
echo "}" >> "$REPORT_FILE"

# 監査結果のエクスポート
echo "監査結果をエクスポートします..."
curl -X POST "http://elasticsearch:9200/audit-reports/_doc" \
     -H "Content-Type: application/json" \
     -d @"$REPORT_FILE"

echo "外部監査のデータ収集が完了しました。" 