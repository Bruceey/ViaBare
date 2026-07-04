# 基于 Cloudflare CDN + OpenResty + Sing-box 的代理方案

一个适用于低成本 VPS 的代理部署方案，整体采用 **Cloudflare CDN → OpenResty → Sing-box** 的架构，通过 Shell 一键脚本完成部署。

## 项目特点

- Cloudflare CDN 边缘节点接入，可使用优选 IP
- Cloudflare 主动回源，无需 Cloudflare Tunnel
- OpenResty 作为统一入口，负责流量分流
- Sing-box 仅作为后端代理核心，不直接暴露公网
- 接入 WARP 作为出口
- 一键自动部署，配置简单
- 支持防主动探测

## 架构

```text
客户端
    │
    ▼
Cloudflare CDN（开启小黄云）
    │
    ▼
OpenResty
    │
    ▼
Sing-box
    │
    ▼
 Warp
    │
    ▼
Internet
```

## 工作原理

所有客户端流量首先进入 Cloudflare CDN，由 Cloudflare 回源至 VPS 上的 OpenResty。

OpenResty 根据访问路径进行分流：

- 正常访问域名时，返回网站页面；
- 代理路径转发给 Sing-box 处理。

由于 Sing-box 不直接对公网提供服务，因此可以有效降低主动探测风险，同时隐藏真实代理服务。

**网站主页:**

![网站主页](./config/index.png) 

## 优势

- 相较于 Cloudflare Tunnel，少一层转发，延迟更低
- 无需运行 cloudflared，更稳定、更省资源
- Cloudflare 隐藏源站 IP，提高安全性
- 支持优选 IP，改善接入质量
- 适合线路质量不好、以及ip出口质量差的 VPS

## 使用要求

部署前请确保：

- 已拥有一个域名
- 域名已托管到 Cloudflare
- 添加DNS解析记录，且开启 Cloudflare 代理（小黄云）
- VPS 开放443 端口

## 安装

```bash
curl -fsSLO https://raw.githubusercontent.com/Bruceey/ViaBare/main/viabare.sh
chmod +x viabare.sh
./viabare.sh <cf托管域名> # 如 ./viabare.sh example.com
```

## 免责声明

本项目仅供学习、研究及合法用途使用，请遵守所在地法律法规。