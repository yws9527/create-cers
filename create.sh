#!/bin/sh

# 查看KEY信息
# openssl req -text -noout -in server.key
# 查看CSR信息
# openssl req -text -noout -in server.csr
# 查看证书信息
# openssl x509 -noout -text -in server.crt


# 清除旧证书
rm -rf rootca/* server/*


########## CA根证书 ##########

# 生成根证书
openssl req -x509 -nodes -new -sha256 -days 3650 -newkey rsa:2048 -keyout rootca/RootCA.key -out rootca/RootCA.pem -subj "/C=US/CN=Top-Root-CA"

# 生成根凭证 crt 文件
openssl x509 -outform pem -in rootca/RootCA.pem -out rootca/RootCA.crt


########## 服务器证书 ##########

# 生成证书请求 csr 文件
openssl req -new -nodes -newkey rsa:2048 -keyout server/server.key -out server/server.csr -subj "/C=CN/ST=Guandong/L=Shenzhen/O=Top/CN=h2.top"

# 生成凭证 crt 文件
openssl x509 -req -sha256 -days 3650 -in server/server.csr -CA rootca/RootCA.pem -CAkey rootca/RootCA.key -CAcreateserial -extfile openssl.conf -out server/server.crt
