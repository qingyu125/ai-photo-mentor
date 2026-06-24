# AI 摄影导师 · 项目分析

> 一个运行在浏览器里的"AI 摄影私教"。打开网页就调用摄像头，实时给取景画面打分，并用语音 + AR 叠加层告诉你该怎么调整：人物偏左、光线太暗、头有点歪、笑一个……按下快门后还能给一张完整分析报告。

---

## 一、产品定位与目标用户

- **形态**：纯前端 Web App（无后端、无账号、无登录），单 HTML 文件即可运行
- **入口**：[`app.html`](./app.html)
- **部署**：静态托管即可（GitHub Pages / Vercel / Netlify 都能跑）
- **目标用户**：旅行打卡、聚会合影、内容创作等"想拍好但没系统学过摄影"的普通人
- **核心价值**：把专业摄影师的"经验直觉"——三分法、面部朝向、微笑引导、稳定持机——量化成屏幕上的分数和语音，**让人一次成片**。

---

## 二、目录与文件清单

```
gh-pages/
├── index.html              # 产品介绍/落地页（含 Hero、四能力、场景、价值、商业模式、Live Demo）
├── app.html                # ★ 摄影 App 主入口（所有功能都在这一个文件里）
├── _shared/
│   └── fonts/              # 自定义字体：InstrumentSans / GeistMono
├── assets/                 # index.html 用的封面图（hero / 4 能力 / 场景图）
├── .nojekyll               # 让 GitHub Pages 不忽略 _shared/ 目录
├── deploy.ps1              # 一键推送到 GitHub 的 PowerShell 脚本
└── README.md               # 本文件
```

### 1. `app.html`（主程序，唯一带业务逻辑的文件）

整个 App 浓缩在一个 HTML 文件里，结构上分三块：

| 模块 | 作用 |
|---|---|
| `<style>` | 全部 UI 样式（玻璃拟态、AR 网格、评分环、Toast、Review 弹层等） |
| `<body>` 布局 | 启动页 → 取景区 → 拍照回看层 |
| `<script>` | 摄像头 / AI 推理 / 评分 / 语音 / AR 绘制 / 拍照保存 |

> 之所以做成单文件，是为了 **零构建、零依赖、零后端**：双击/丢到 Pages 就能用。代价是文件较大（≈ 1600 行），所以源码里按注释分了 12 个区块。

#### 关键区块一览（按代码顺序）

1. **CONFIG** — 所有可调阈值：分析节流 250ms、语音冷却 2500ms、人脸检测输入 320、微笑阈值 0.55、头部倾斜警告 8° / 严重 18°、背景整洁度阈值 0.18 / 0.32 等
2. **DOM 引用** — 用 `$('id')` 把所有需要的元素集中起来
3. **state** — 全局可变状态：流对象、摄像头朝向、语音开关、模式、上一帧数据、当前分数、检测模型是否就绪等
4. **Utility** — `showToast` / `setHudMessage` / `isMobileDevice` / `shouldMirrorCamera` / **语音三件套**（`loadVoices` / `ensureVoices` / `unlockSpeech` / `pickChineseVoice` / `speak`）
5. **startCamera** — 申请摄像头权限、播放、调整 overlay canvas、应用镜像、启动分析循环
6. **loadFaceModel** — 动态加载 face-api.js（≈ 4MB），并并行加载三个模型：人脸检测 / 68 关键点 / 表情
7. **detectFaces** — 实际推理入口；为了性能，**每 4 帧才跑一次**人脸检测
8. **analyzeFrame** — 纯像素级分析（亮度、对比度、上下半屏亮度差、中央/边缘亮度、边缘密度）
9. **calcStability** — 帧差法估计手抖程度
10. **AR 绘制** — `drawGrid`（三分线） / `drawLevel`（水平仪） / `drawFaceBoxes`（人脸框） / `drawCompass`（构图偏移箭头 + "往左挪一点"文字）
11. **computeScores** — 把上面所有指标折算成 5 个子分 + 1 个综合分
12. **renderScores** — 写回 UI（顶部评分环、5 个 pill、HUD 提示），并触发语音
13. **generateLiveHint** — 优先级排队生成下一条建议（光线 → 人脸 → 构图 → 头部倾斜 → 微笑 → 背景 → 稳定度）
14. **capture** — 拍照：闪光、生成全分辨率 JPEG、播报分数、显示回看弹层
15. **Event Bindings** — 启动 / 翻转 / 静音 / 快门 / 相册 / 模式切换 / 保存

### 2. `index.html`（产品落地页）

不带摄像头权限的"演示页"，给访问者讲故事用。结构：

- **Top Nav** — 固定顶部，毛玻璃背景
- **Hero** — 标题 + 副标题 + 渐变 CTA 按钮 + 手机模型
- **痛点区** — 5 个常见拍不好照片的场景
- **四能力区** — 智能构图 / 光线 / 姿态 / 语音+AR，每个配一张 `assets/` 里的图
- **怎么用** — 4 步流程图
- **场景区** — 旅行 / 聚会 / 亲子 / 自拍 / 创作 / 宠物 6 张卡
- **价值区** — 效率 / 商业 / 社会 + 商业模式（C 端订阅 / 硬件合作 / 内容 / 社交）
- **Live Demo** — 用 CSS 模拟一个会动的取景框（不调用摄像头），引导用户点 CTA 去 `app.html`
- **CTA + Footer**
- 底部有一个动画脚本，让 Demo 区里的人物轮廓和分数在几个状态间循环

### 3. `assets/`（图片资源）

| 文件 | 用途 |
|---|---|
| `hero_1280x720.jpg` | 落地页 Hero 背景 |
| `feature_composition_1152x864.jpg` | "智能构图"能力配图 |
| `feature_lighting_1152x864.jpg` | "光线判断"能力配图 |
| `feature_pose_1152x864.jpg` | "姿态引导"能力配图 |
| `feature_voice_1152x864.jpg` | "语音播报"能力配图 |
| `scenarios_1280x720.jpg` | "覆盖每个场景"区配图 |

### 4. `_shared/fonts/`

- `InstrumentSans-Regular.ttf` / `InstrumentSans-Bold.ttf` — 标题与正文英文/数字字体
- `GeistMono-Regular.ttf` — 等宽字体（用于代码块、徽章）
- 落地页用 `@font-face` 引用；`app.html` 不引用字体，全用系统默认（为了在弱网/移动端首屏快）

### 5. `.nojekyll`

GitHub Pages 默认用 Jekyll 处理静态站点，会忽略以下划线开头的目录。把这个空文件放根目录告诉 Pages "**别用 Jekyll**"，`_shared/fonts/` 才能正常被引用。

### 6. `deploy.ps1`

一行 `git init && git add . && git commit && git push` 的 PowerShell 封装。**它不是 App 的一部分**，只是发布工具，不影响产品功能。

---

## 三、核心功能详解

### 1. 实时多维度评分（5 子分 + 1 综合分）

| 子分 | 计算逻辑 |
|---|---|
| **构图** | 检测到人脸时，理想位置在三分线交点；偏离越多扣分；主体过小（<2%画面）或过大（>20%）再扣。再按"主体大小 15–45%"给一点奖励分 |
| **光线** | 全图平均亮度映射到 0–100；过暗 <30、过亮 >200 都大幅扣分；额外用"上 1/2 比下 1/2 亮多少"判逆光 |
| **表情/微笑** | 模型返回的 `happy` 概率 × 100，作为微笑分；阈值 ≥75 优秀、≥45 尚可、<45 建议笑 |
| **姿态** | 用 68 关键点算出双眼连线的倾斜角；|roll| ≤8° 良好、8–18° 警告、>18° 严重 |
| **稳定度** | 帧差法：与上一帧采样像素亮度差的均值，越接近 0 越稳 |
| **背景整洁度** | 用稀疏网格算局部亮度梯度，得到"边缘密度"；0.18 以下整洁、0.32 以上杂乱 |

**综合分** = 加权和：

- 人像模式：`构图×0.30 + 光线×0.25 + 表情×0.15 + 稳定度×0.10 + 背景×0.20`
- 其他模式：`构图×0.30 + 光线×0.25 + 稳定度×0.15 + 背景×0.30`

### 2. AR 叠加层

在 `overlay` canvas 上实时画：

- **三分线网格**（半透明白） — 帮用户对齐
- **人脸框 + 标签**（绿框 "人脸 92%"） — 直观看到检测结果
- **构图偏移箭头**（黄圈 + 十字 + 虚线箭头 + "往左挪一点"） — 实时告诉用户该往哪边挪
- **水平仪**（黄线） — 当 |roll| > 0.04（约 2.3°）时显示
- **HUD 文字提示**（顶部胶囊） — 配合语音播报，色条随分数变化（绿/黄/红）

### 3. 智能语音播报

- 触发条件：每条建议文本发生变化时调用 `speak()`
- 防刷屏：`VOICE_COOLDOWN_MS = 2500ms` 冷却
- 静音：右上角 🔊 按钮可关，关掉后只在 HUD 显示
- 关键时刻会强制播报：切换模式 "已切换到人像模式"、拍照后 "已拍摄，综合评分 85 分"、开启/关闭语音 "语音引导已开启"
- **iOS Safari 兼容**：
  - 首次进入页面时（`startBtn` 点击）在用户手势内预热 `speechSynthesis.speak(' ')` 解锁音频通道
  - 监听 `voiceschanged` 事件，拿到中文 voice 后显式赋值（部分 iOS 版本不指定 voice 会静默）
  - 任何拍照/保存按钮点击都会再调一次 `unlockSpeech()` 防止 Safari 长时间无交互后锁住
- 视觉反馈：播报时左上角绿点呼吸动画

### 4. 拍照 + 智能回看

按下快门：

1. 整屏白色闪光 200ms
2. 用一个离屏 canvas 按 `videoWidth × videoHeight` 全分辨率截一帧（不缩放，保证画质）
3. 编码成 JPEG（质量 0.92）作为 dataURL
4. 写入左上角"相册"小图
5. 语音播报分数
6. 弹出回看弹层：
   - 顶部最大 45vh 显示照片
   - 中间一行操作按钮：**关闭 / 再拍一张 / 保存到相册**
   - 下方可滚动区域展示完整分析报告（综合分 + 5 子分 + 表情 + 头部倾斜 + 改进建议）

**保存逻辑**（按设备自适应）：

- **iPhone / Android（支持 Web Share）**：用 `navigator.canShare({files})` 检测，把 Blob 包成 `File` 调 `navigator.share()`，系统分享面板里有"存储到照片"选项 → 直达相册
- **PC**：`<a download>` 触发下载到"下载"文件夹
- **老 iOS 没装 share polyfill**：用 `target="_blank"` 新窗口打开图片，用户长按 → "存储到照片"
- **终极兜底**：用 `window.open` 写一个最简 HTML 页只放图片，引导长按保存

### 5. 设备自适应（PC vs 手机）

| 行为 | PC | 手机 |
|---|---|---|
| 摄像头镜像 | **永远镜像**（PC 摄像头 ≈ 永远"自拍视角"，不镜像会反着） | 前置镜像 / 后置不镜像 |
| 保存图片 | `<a download>` 下载 | Web Share API 分享到相册 |
| UI 触摸 | 鼠标点击 | 关闭页面整体滚动、只在 review 报告里允许滚 |

判断依据：`navigator.userAgent` 是否包含 `Mobi|Android|iPhone|iPad|iPod|...`。

### 6. 4 种拍摄模式

底栏中部模式选择：

- **人像**：默认；综合分里表情权重 15%
- **风景**：表情权重为 0；背景/稳定度权重更高
- **静物**：同上，但阈值更适合静物
- **自动**：根据检测到的人脸数量在两种权重间切换

切换时弹 Toast + 语音播报。

---

## 四、技术栈与依赖

| 类别 | 选型 | 说明 |
|---|---|---|
| 框架 | **纯原生 JS**，无 React/Vue | 单文件，零构建 |
| UI 样式 | **原生 CSS** + CSS 变量 + backdrop-filter | 玻璃拟态、深色主题 |
| 摄像头 | `navigator.mediaDevices.getUserMedia` | 必须 HTTPS 或 localhost |
| 人脸 AI | **[face-api.js](https://github.com/justadudewhohacks/face-api.js)** 0.22.2 | 三个模型：TinyFaceDetector / 68 Landmarks / FaceExpression |
| 模型来源 | `cdn.jsdelivr.net/npm/@vladmandic/face-api/model` | 首次加载约 4MB |
| 语音 | Web Speech API (`speechSynthesis`) | 内置 |
| 图像保存 | Web Share API + `<a download>` | 移动端/桌面端自适应 |
| 部署 | 任意静态托管 | GitHub Pages / Vercel / Netlify / 自建 nginx |

**无后端、无数据库、无第三方 API key**——所有数据计算都在用户浏览器里完成，**完全离线可用**（第一次加载完模型后断网也能继续用）。

---

## 五、关键设计取舍

1. **单文件 vs 多模块**
   - 选单文件是为了零部署门槛。如果你打算二次开发，建议把 `<script>` 拆成 `camera.js / analyzer.js / ai.js / ar.js / voice.js` 这几个 ES Module。

2. **像素分析为主、AI 兜底**
   - 即便 face-api.js 加载失败或网络断了，亮度/对比度/稳定度/边缘密度这些"传统 CV"指标仍能工作，会自动降级成"无 AI 模式"继续给分。

3. **人脸检测每 4 帧跑一次**
   - 关键点 + 表情推理较重，全跑会掉帧。每 4 帧一次（约 1 秒 15 次）在视觉流畅度和 AI 准确性之间平衡。

4. **分析 canvas 用 160px 宽**
   - 视频动辄 1920×1080，对全分辨率做边缘检测会卡死。降到 160 宽做粗算，统计量仍然准确。

5. **iOS 语音解锁**
   - Safari 在用户手势外调 `speechSynthesis.speak()` 会静默失败。代码里把"开启摄像头"按钮当作"热身手势"，预热一次；同时给拍照、保存按钮都加了 `unlockSpeech()` 兜底。

6. **没有自动连拍**
   - 自动按快门容易拍到闭眼/抖动的瞬间。App 只做"实时引导"，最终按不按快门永远交给用户。

---

## 六、可拓展方向

- **WebGPU / TFLite 加速人脸推理** — 当前每 4 帧 1 次检测，复杂场景仍可感受到延迟
- **录制短视频** — 用 `MediaRecorder` 录 3 秒，给出"动态构图"评分
- **多人合影优化** — `pickLargestFace` 只取最大一张脸；改成多人布局均衡评估
- **本地相册（多张照片）** — 当前相册按钮只显示最近一张，可改成 grid
- **PWA 离线安装** — 加 `manifest.json` + Service Worker，可"添加到主屏幕"伪装成原生 App
- **模型替换为 MediaPipe Face Landmarker** — Google 的新方案精度更高、体积更小

---

## 七、文件级快速对照

| 想了解… | 看哪里 |
|---|---|
| App 怎么启动 | `app.html` `startBtn.addEventListener` 块 |
| 评分怎么算 | `computeScores()` 函数 |
| 语音在 iOS 上为什么之前没声音、修复后流程 | `speak()` / `unlockSpeech()` / `ensureVoices()` |
| 拍照后怎么存 | `reviewSave` 的 click handler |
| 拍照后分析报告长什么样 | `capture()` 里拼 HTML 的部分 |
| 落地页文案/章节 | `index.html` 里的 `<section>` |
| 怎么改 UI 配色 | `app.html` 顶部 CSS：`#00d4aa` 是主色，`#7c5cfc` 是辅助色 |

---

## 八、隐私声明

- 所有视频帧 **不上传任何服务器**——App 没有后端
- AI 模型在浏览器本地运行
- 摄像头权限随时可在浏览器地址栏关闭
- 保存到本地相册的图片完全由用户主动触发
