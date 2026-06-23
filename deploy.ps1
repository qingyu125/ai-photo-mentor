# ============================================================
#  AI 摄影导师 · GitHub Pages 一键部署脚本
#  - 编码: UTF-8 with BOM (PowerShell 5 中文系统必须)
#  - 使用: 编辑下方 GIT_URL，右键 → "使用 PowerShell 运行"
#  - 依赖: Git for Windows + GitHub Personal Access Token
# ============================================================

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# ========== 配置（必填）==========
$GIT_URL = 'https://github.com/qingyu125/ai-photo-mentor.git'  # ← 改成你的仓库地址
$BRANCH  = 'main'
$COMMIT_MSG = 'deploy: AI 摄影导师静态站点'
$GH_USER  = 'qingyu125'                                         # ← 改成你的 GitHub 用户名
$GH_REPO  = 'ai-photo-mentor'                                   # ← 改成你的仓库名（用于解析 Pages URL）
# ===================================

Write-Host ''
Write-Host '===========================================' -ForegroundColor Cyan
Write-Host '  AI 摄影导师 · GitHub Pages 一键部署'  -ForegroundColor Cyan
Write-Host '===========================================' -ForegroundColor Cyan
Write-Host ''

if ($GIT_URL -match 'YOUR_USERNAME') {
    Write-Host '[X] 请先编辑本文件，把 GIT_URL 改成你的 GitHub 仓库地址。' -ForegroundColor Red
    Write-Host '    例如：https://github.com/qingyu125/ai-photo-mentor.git' -ForegroundColor Yellow
    Write-Host ''
    pause
    exit 1
}

# 检查 git
try { git --version | Out-Null } catch {
    Write-Host '❌ 未安装 git，请先安装 Git for Windows：' -ForegroundColor Red
    Write-Host '   https://git-scm.com/download/win' -ForegroundColor Yellow
    Write-Host ''
    pause
    exit 1
}

# 初始化仓库（如果还没有 .git）
if (-not (Test-Path '.git')) {
    Write-Host '→ 初始化 git 仓库...' -ForegroundColor Yellow
    # 优先用 git init -b 创建指定分支（git 2.28+）
    & git init -b $BRANCH 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        # 旧版 git 兜底：init 后用 symbolic-ref 改默认分支
        & git init 2>&1 | Out-Null
        & git symbolic-ref HEAD "refs/heads/$BRANCH" 2>&1 | Out-Null
    }
    & git config user.email 'deploy@local' 2>&1 | Out-Null
    & git config user.name  'Deploy Bot'    2>&1 | Out-Null
}

# 关闭 CRLF 转换（避免 PowerShell 误把 git 警告当异常抛出）
& git config core.autocrlf false 2>&1 | Out-Null

# 配置 remote
$remoteUrl = ''
try {
    $remoteUrl = & git remote get-url origin
} catch {
    $remoteUrl = ''
}
if ($remoteUrl -ne $GIT_URL) {
    Write-Host '→ 配置远程仓库...' -ForegroundColor Yellow
    try { & git remote remove origin | Out-Null } catch { }
    & git remote add origin $GIT_URL
}

# 添加所有文件并提交
Write-Host '→ 添加文件并提交...' -ForegroundColor Yellow
& git add -A 2>&1 | Out-Null
$hasChanges = $false
try { $hasChanges = (& git status --porcelain 2>&1) -ne '' } catch { $hasChanges = $false }
if ($hasChanges) {
    & git commit -m $COMMIT_MSG 2>&1 | Out-Null
}

# 推送
Write-Host "→ 推送到 $GIT_URL 的 $BRANCH 分支..." -ForegroundColor Yellow
git push -u origin $BRANCH --force

if ($LASTEXITCODE -eq 0) {
    Write-Host ''
    Write-Host '[OK] 推送成功！' -ForegroundColor Green
    Write-Host ''
    Write-Host '接下来请到 GitHub 仓库页面：' -ForegroundColor Cyan
    Write-Host '  Settings -> Pages -> Source 选择 "Deploy from a branch"' -ForegroundColor White
    Write-Host "  Branch 选择 '$BRANCH' / '(root)'，然后保存" -ForegroundColor White
    Write-Host ''
    Write-Host '等待 1-2 分钟后访问（首次部署可能需要 3-5 分钟）：' -ForegroundColor Cyan
    # 优先使用显式配置的 GH_USER / GH_REPO，否则从 GIT_URL 解析
    if (-not $GH_USER -or -not $GH_REPO) {
        if ($GIT_URL -match '^https://github\.com/([^/]+)/([^/]+?)(?:\.git)?$') {
            $GH_USER = $Matches[1]
            $GH_REPO = $Matches[2]
        }
    }
    $pagesUrl = "https://$GH_USER.github.io/$GH_REPO"
    Write-Host "  App:  $pagesUrl/app.html" -ForegroundColor Green
    Write-Host "  Home: $pagesUrl/" -ForegroundColor Green
} else {
    Write-Host ''
    Write-Host '[X] 推送失败，请检查：' -ForegroundColor Red
    Write-Host '  1. GitHub 仓库是否存在且为 Public' -ForegroundColor White
    Write-Host '  2. 凭据是否正确（用户名 + Personal Access Token）' -ForegroundColor White
    Write-Host '  3. 网络是否通畅' -ForegroundColor White
    Write-Host ''
    Write-Host '需要 Personal Access Token？打开：' -ForegroundColor Yellow
    Write-Host '  https://github.com/settings/tokens/new' -ForegroundColor Yellow
}

Write-Host ''
pause
