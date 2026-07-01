# ViaBare

A minimalist, CLI-only automated script to build a highly optimized, anti-probing network infrastructure. 

Unlike other bloated UI panels or script engines that demand premium, expensive VPS lines, **ViaBare is built on the first principles of transport-layer and routing-layer optimization.** It utilizes Cloudflare's Anycast edge network to salvage cheap, high-latency VPS instances, extracting every ounce of performance out of your bare-metal server.

---

## ✨ Features & Architecture

* **Zero-GUI / Bare-Metal Execution:** Both client and server run natively on bare-metal cores, minimizing system overhead.
* **Intelligent Routing Layer:** Leveraging Cloudflare CDN and localized IP optimization to dramatically reduce backbone network packet loss and latency.
* **Anti-Probing Reverse Proxy:** Powered by **OpenResty (Nginx + Lua)**. It intercepts traffic, dynamically handling configuration subscription URLs via Lua scripts, while hiding the underlying sing-box core behind a benign homepage to defeat active scanning.
* **Automated Security:** Full ACME integration with automated Cloudflare API/Token domain verification and zero-downtime certificate renewal.
* **Clean Egress Transport:** Optional Warp integration to clean up dirty egress IPs and prevent endpoint blockage.

---

## 🛠️ Prerequisites

* A clean VPS running Debian / Ubuntu (even the cheapest, lowest-spec instance will work!).
* A domain name pointed to Cloudflare.
* A Cloudflare API Token.

---

## 🚀 Quick Start

Run the following command on your server to start the automated installation. The script is highly optimized to guide you through the process seamlessly:

```bash
curl -fsSLO https://raw.githubusercontent.com/Bruceey/ViaBare/main/viabare.sh
chmod +x viabare.sh
./viabare.sh <cf托管域名>
```

---

## 🔍 Technical Insights (Why it works)

1. **Multiplexing via OpenResty:** By proxying WebSocket traffic through OpenResty, the architecture relies on long-lived connections and multiplexing, bypassing TCP's frequent handshakes and slow-start bottlenecks on poor networks.
2. **Deterministic Bitwise Controls:** All configuration files and keys created by this script are governed by strict bitwise permission controls (`chmod 600`), preventing sensitive Token exposure.
3. **Robust Input Handling:** Built with robust shell scripting standard (`read -r`), preventing unexpected backslash escapes during domain or token insertion.