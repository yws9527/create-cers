# 给本地localhost域名添加https证书

本文介绍如何给本地域名localhost添加证书，但此方法仅限在开发环境使用。**在生产环境中，强烈禁止使用自签名证书**。

#### 用shell脚本一键生成

```shell
sh ./create.sh
```



### **<u>OR</u>**



#### 1. 创建认证中心（Certificate authority，CA）

生成RootCA.pem， RootCA.key 以及 RootCA.crt:

```sh
openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout rootca/RootCA.key -out rootca/RootCA.pem -subj "/C=US/CN=Top-Root-CA"

openssl x509 -outform pem -in rootca/RootCA.pem -out rootca/RootCA.crt
```

Example-Root-CA是一个用例的名称，实际使用中可以把它为你自己要的名字。

#### 2. 域名证书

假设有两个本地机器域名fake1.local和fake2.local，这两个域名使用hosts文件将其指向127.0.0.1。

创建domains.conf列出所有的本地域名：

```sh
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = 192.168.3.73
DNS.1 = localhost
DNS.2 = fake1.local
DNS.3 = fake2.local
```

生成localhost.key， localhost.csr以及localhost.crt文件：

```sh
openssl req -new -nodes -newkey rsa:2048 -keyout server/server.key -out server/server.csr -subj "/C=CN/ST=Guandong/L=Shenzhen/O=Example-Certificates/CN=localhost.local"

openssl x509 -req -sha256 -days 1024 -in server/server.csr -CA rootca/RootCA.pem -CAkey rootca/RootCA.key -CAcreateserial -extfile openssl.conf -out server/server.crt
```

示例里的省份，城市可以替换为自己的地址。

配置webserver，这里的示例使用的是apache（其他服务器自助百度）：

```apache
SSLEngine on
SSLCertificateFile "C:/example/localhost.crt"
SSLCertificateKeyFile "C:/example/localhost.key"
```

#### 3. Webpack配置

```javascript
devServer: {
  ...
  server: {
    type: 'spdy',
    options: {
      key: 'xxx/server/server.key',
      cert: 'xxx/server/server.crt',
    },
  }
}
```

#### 4. Vite配置

> **<u>vite中[http2 与 proxy互斥]</u>**

```javascript
# 原文：启用 TLS + HTTP/2。注意：当 server.proxy 被使用时，将会仅使用 TLS

server {
  ...
  https: {
    key: 'D:/WORKSPACE/PLAY/create-cers/server/server.key',
    cert: 'D:/WORKSPACE/PLAY/create-cers/server/server.crt',
  },
}
```



#### 5. 信任本地CA

站点加载有关自签名证书时会有警告。为了获得绿色锁，必须将新的本地CA添加到受信任的根证书颁发机构。

**Windows 10: Chrome, IE11 以及 Edge**

Windows 10是能识别.crt文件，右键RootCA.crt文件，然后执行安装，就会弹出导入证书的窗口。

这样Chrome，IE11以及Edge就会显示绿色锁。



