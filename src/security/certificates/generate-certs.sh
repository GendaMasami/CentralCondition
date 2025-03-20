#!/bin/bash

# 証明書を保存するディレクトリを作成
mkdir -p certs

# ルートCAの証明書と秘密鍵を生成
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/ca.key -out certs/ca.crt \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=CentralCondition/CN=CentralCondition CA"

# サーバー証明書の秘密鍵を生成
openssl genrsa -out certs/server.key 2048

# サーバー証明書の署名要求（CSR）を生成
openssl req -new -key certs/server.key -out certs/server.csr \
  -subj "/C=JP/ST=Tokyo/L=Tokyo/O=CentralCondition/CN=*.centralcondition.com"

# サーバー証明書を生成
openssl x509 -req -days 365 -in certs/server.csr \
  -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial \
  -out certs/server.crt

# 証明書のパーミッションを設定
chmod 600 certs/*.key
chmod 644 certs/*.crt 