# AI 摄影导师 · GitHub Pages 部署

把当前目录部署到 GitHub Pages，1-2 分钟后即可通过 HTTPS 公网链接访问，手机直接打开就能用。

## ⚡ 30 秒快速开始

### ① 创建 GitHub 仓库
1. 打开 https://github.com/new
2. 填写：
   - **Repository name**: `ai-photo-mentor`（可改成别的名字）
   - **Public**（必须公开，免费 Pages 才能用）
3. **不要**勾选 Add README / .gitignore / License
4. 点 **Create repository**
5. 复制仓库地址，格式类似：`https://github.com/你的用户名/ai-photo-mentor.git`

### ② 修改 deploy.ps1
用记事本打开 `deploy.ps1`，把第 8 行：
```
$GIT_URL = 'https://github.com/YOUR_USERNAME/ai-photo-mentor.git'
```
改成刚才复制的真实地址，例如：
```
$GIT_URL = 'https://github.com/zhangsan/ai-photo-mentor.git'
```
保存。

### ③ 运行部署
右键 `deploy.ps1` → **"使用 PowerShell 运行"**

第一次推送会要求输入 GitHub 凭据：
- **Username**: 你的 GitHub 用户名
- **Password**: 粘贴 **Personal Access Token**（不是登录密码！）

> 没有 Token？打开 https://github.com/settings/tokens/new
> - Note: 随便填（如 `deploy`）
> - Expiration: 选 `No expiration` 或 `7 days`
> - 勾选 `repo`
> - 点 **Generate token**，复制生成的字符串

### ④ 开启 GitHub Pages
进入你的 GitHub 仓库页面：
- **Settings** → **Pages**
- **Source**: `Deploy from a branch`
- **Branch**: `main` / `/ (root)`，点 **Save**

### ⑤ 访问
等待 1-2 分钟（首次 3-5 分钟），然后访问：

```
https://你的用户名.github.io/ai-photo-mentor/app.html
https://你的用户名.github.io/ai-photo-mentor/
```

手机浏览器直接打开 `app.html` 那个链接，首次会弹出摄像头权限授权。

---

## 📦 目录结构

```
gh-pages/
├── index.html              # 产品介绍页
├── app.html                # 摄影 App 主入口
├── _shared/fonts/          # 字体
├── assets/                 # 图片
├── .nojekyll               # 防止 GitHub Pages 忽略 _shared 目录
├── deploy.ps1              # 一键部署脚本
└── README.md               # 本文件
```

## 🔄 重新部署

修改 `index.html` 或 `app.html` 后，再次右键运行 `deploy.ps1` 即可。

## ❓ 常见问题

**Q: 推送时提示 403 / authentication failed？**
A: 密码处必须用 Personal Access Token，不是 GitHub 登录密码。

**Q: 访问链接显示 404？**
A: 等 3-5 分钟。GitHub Pages 首次部署需要时间。也可以去 Settings → Pages 看部署状态。

**Q: 打开 app.html 后摄像头还是没反应？**
A:
1. 确认地址是 `https://` 开头（HTTP 协议下浏览器拒绝授权）
2. 确认浏览器是最新版 Chrome / Safari / Edge
3. 浏览器地址栏左侧的权限图标里，确认摄像头权限是"允许"

**Q: 怎么换成自己的用户名和仓库名？**
A: 改 `deploy.ps1` 第 8 行的 `GIT_URL` 即可。

## 🧹 临时调试模式（不需要部署到 GitHub 时使用）

如果想本地快速测试，但又不想推到 GitHub，可以用 Python 自带的服务器（无需任何安装）：
```bash
cd gh-pages
python -m http.server 8000
```
然后浏览器打开 `http://127.0.0.1:8000/app.html`（注意：localhost/127.0.0.1 允许 HTTP 调用摄像头）。
