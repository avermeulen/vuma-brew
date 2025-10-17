# ☕ VumaBrew

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Status](https://img.shields.io/badge/status-in_progress-orange)](#)
[![Built with ❤️ in South Africa](https://img.shields.io/badge/built_with_%E2%9D%A4%EF%B8%8F-in_South_Africa-red)](#)


**Brew it locally. Serve it globally.**

VumaBrew is a self-hosted Git-push deployment platform for Node.js and Vite apps.  
Push your code, pour a cup, and your app’s already live.

---

### 🚀 Quick Start

```bash
# install on your server
curl -fsSL https://raw.githubusercontent.com/andrevermeulen/vuma-brew/main/install-server.sh | sudo bash

# install CLI on your local machine
curl -fsSL https://raw.githubusercontent.com/andrevermeulen/vuma-brew/main/install-client.sh | bash

# create and deploy your first app
deploy new myapp
git push production main
