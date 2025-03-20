# システム依存関係マップ

このドキュメントは、システム内の主要なコンポーネントと外部サービス・ライブラリとの依存関係を示しています。

## コアアプリケーションコンポーネント

### フロントエンドアプリケーション
- **依存サービス**:
  - バックエンドAPIサーバー（API通信）
  - 認証・認可サービス（ユーザー認証）
  - AWS CloudFront（コンテンツ配信）
  - Sentry（エラー監視）
- **主要ライブラリ**:
  - React 18.x
  - Redux 4.x
  - Material UI 5.x
  - Axios 1.x

### バックエンドAPIサーバー
- **依存サービス**:
  - PostgreSQL（データ永続化）
  - Redis（キャッシング）
  - AWS S3（ファイル保存）
  - 認証・認可サービス（認証検証）
  - AI連携サービス（AI処理）
  - Elasticsearch（ログ管理）
  - RabbitMQ（メッセージング）
  - Docker（実行環境）
  - Sentry（エラー監視）
- **主要ライブラリ**:
  - Node.js 18.x
  - Express 4.x
  - Prisma 4.x
  - JWT 9.x

### 認証・認可サービス
- **依存サービス**:
  - PostgreSQL（ユーザー情報永続化）
  - Redis（トークンキャッシュ）
  - Docker（実行環境）
- **主要ライブラリ**:
  - Passport 0.6.x
  - JWT 9.x

### AI連携サービス
- **依存サービス**:
  - TensorFlow/PyTorch（機械学習モデル）
  - OpenAI API（外部AI API）
  - PostgreSQL（結果保存）
  - AWS S3（ファイル保存）
  - Docker（実行環境）
- **主要ライブラリ**:
  - Python 3.11.x
  - FastAPI 0.98.x
  - TensorFlow 2.x / PyTorch 2.x

### バッチ処理サービス
- **依存サービス**:
  - PostgreSQL（データ処理）
  - RabbitMQ（メッセージング）
  - AWS SES（メール送信）
  - Docker（実行環境）
- **主要ライブラリ**:
  - Node.js 18.x
  - cron 2.x

### 分析サービス
- **依存サービス**:
  - PostgreSQL（データ分析）
  - Elasticsearch（ログ分析）
  - Docker（実行環境）
- **主要ライブラリ**:
  - Python 3.11.x
  - pandas 2.x
  - numpy 1.x

## インフラストラクチャコンポーネント

### コンテナ化環境
- Docker -> Kubernetes -> AWS EKS

### データストレージ
- PostgreSQL -> AWS RDS（マネージドサービス）
- Redis（自己管理またはElastiCache）
- AWS S3
- Elasticsearch

### 外部クラウドサービス
- AWS CloudFront
- AWS Route53
- AWS RDS
- AWS EKS
- AWS S3
- AWS SES
- AWS CloudWatch
- AWS ECR

### モニタリングツール
- Prometheus -> Kubernetes
- Grafana -> Prometheus
- AWS CloudWatch
- Sentry

### CI/CD
- GitHub Actions -> AWS ECR, ArgoCD, SonarQube
- ArgoCD -> Kubernetes
- SonarQube

### AI/ML
- TensorFlow
- PyTorch
- OpenAI API

### メッセージング
- RabbitMQ

## 依存関係マトリックス

| コンポーネント | フロントエンド | バックエンド | 認証サービス | AIサービス | バッチ処理 | 分析サービス |
|--------------|--------------|------------|------------|-----------|-----------|------------|
| PostgreSQL   |              | ✓          | ✓          | ✓         | ✓         | ✓          |
| Redis        |              | ✓          | ✓          |           |           |            |
| S3           |              | ✓          |            | ✓         |           |            |
| RabbitMQ     |              | ✓          |            |           | ✓         |            |
| Docker       |              | ✓          | ✓          | ✓         | ✓         | ✓          |
| Kubernetes   |              | ✓          | ✓          | ✓         | ✓         | ✓          |
| Elasticsearch|              | ✓          |            |           |           | ✓          |
| Sentry       | ✓            | ✓          |            |           |           |            |
| TensorFlow   |              |            |            | ✓         |           |            |
| PyTorch      |              |            |            | ✓         |           |            |
| OpenAI API   |              |            |            | ✓         |           |            |
| CloudFront   | ✓            |            |            |           |           |            |
| SES          |              |            |            |           | ✓         |            |

## 外部サービス接続情報

### AWS サービス
- **リージョン**: ap-northeast-1（東京）
- **アカウント管理**: AWS IAM
- **アクセス方法**: AWS SDK、Terraform

### 外部API
- **OpenAI API**
  - **認証方式**: APIキー
  - **レート制限**: 1000リクエスト/分
  - **使用モデル**: GPT-4

### モニタリングサービス
- **Sentry**
  - **プロジェクト**: frontend-app, backend-api
  - **アラート設定**: Slack, Email
