# Phase 0 工作计划 — UI/UX 设计师

**阶段周期：** 2026-03-10 ~ 2026-03-21
**上游文档：** `doc/product/Tickwing_PRD_v2.3.md`
**完整工作计划：** `doc/product/Phase0_WorkPlan.md`

---

## 你的任务总览

| # | 任务 | 角色 | 截止日 | 产出物 |
|---|------|------|--------|--------|
| T0-1 | PRD 评审 | **评审** | 03-12 | 评审意见反馈 |
| T0-3 | UI/UX 设计规范 v1 | **主责** | 03-19 | Design Token + 线框图 + 组件清单 |

---

## T0-1 参与 PRD 评审（03-10 ~ 03-12）

**提前阅读范围：**
- 重点阅读 PRD v2.2 的 **第 2 章（产品愿景、价值主张、目标用户）** — 理解产品调性
- 重点阅读 PRD v2.2 的 **第 5 章（功能需求）** — 了解需要设计哪些页面和功能
- 重点阅读 PRD v2.2 的 **第 7 章（多端策略）** — 了解各端能力边界

**评审会上需要关注的：**
- 产品调性是否清晰？（自然、清新、专业）
- 有无特殊交互需求？（视频播放器、上传进度、喂鸟器状态展示）
- 管理后台的复杂度如何？

---

## T0-3 UI/UX 设计规范 v1（03-12 ~ 03-19）⭐ 主要任务

### 前置条件
- T0-1（PRD 评审）完成，产品范围已冻结

### 产出物清单

| # | 产出物 | 格式 | 存放位置 | 截止日 |
|---|-------|------|---------|--------|
| 1 | Design Token | JSON 或 CSS Variables | `doc/design/DesignTokens.json` | 03-17 |
| 2 | 核心页面线框图 (6页) | Figma / Sketch / PNG | `doc/design/wireframes/` | 03-19 |
| 3 | 组件清单 | Markdown | `doc/design/ComponentList.md` | 03-19 |
| 4 | 多端适配说明 | Markdown | `doc/design/ResponsiveGuide.md` | 03-19 |

### 1. Design Token 定义

**必须包含的 Token 类别：**

| 类别 | 需定义内容 | 说明 |
|------|-----------|------|
| 色彩 | 主色 / 辅助色 / 中性色（灰阶）/ 语义色（success/warning/error/info） | 用语义化命名，如 `color-bg-primary` 而非 `color-white`，为未来暗色模式预留 |
| 排版 | 字体家族 / 字号阶梯 (xs~3xl) / 行高 / 字重 | 中文字体优先（思源黑体 / 苹方 / 系统默认） |
| 间距 | 基础间距单位 (4px grid)，阶梯：4/8/12/16/24/32/48/64 | Tailwind 默认间距体系可作参考 |
| 圆角 | none / sm / md / lg / full | |
| 阴影 | none / sm / md / lg | |
| 边框 | 默认边框颜色和宽度 | |

**输出格式参考：**

```json
{
  "color": {
    "primary": { "50": "#f0fdf4", "500": "#22c55e", "900": "#14532d" },
    "neutral": { "50": "#fafafa", "500": "#737373", "900": "#171717" },
    "semantic": {
      "success": "#22c55e",
      "warning": "#f59e0b",
      "error": "#ef4444",
      "info": "#3b82f6"
    }
  },
  "fontSize": {
    "xs": "12px", "sm": "14px", "base": "16px", "lg": "18px", "xl": "20px"
  },
  "spacing": {
    "1": "4px", "2": "8px", "3": "12px", "4": "16px", "6": "24px", "8": "32px"
  }
}
```

### 2. 核心页面线框图

**Phase 0 需要交付的 6 个页面线框图（中等保真度即可，高保真稿 Phase 1 初交付）：**

| # | 页面 | 设计要点 |
|---|------|---------|
| 1 | **首页 Feed** | 视频卡片列表（区分手动上传 vs 喂鸟器自动拍摄的标识）、筛选/排序 bar、关注/推荐 tab |
| 2 | **视频详情页** | 播放器区域、标题描述、鸟种标签、点赞评论区、作者信息卡片 |
| 3 | **个人主页** | 头像/昵称/简介、关注/粉丝数、作品网格列表、tab（作品/喂鸟器/点赞） |
| 4 | **上传页** | 视频选择/拖拽区、元数据表单（标题/描述/位置/鸟种）、上传进度条、可见性选择 |
| 5 | **注册/登录页** | 邮箱+密码表单、找回密码入口、社交登录区域预留（首发灰色占位） |
| 6 | **管理后台框架** | 侧边栏导航结构（用户管理/视频审核/设备管理/统计看板/公告/举报）、主内容区布局 |

**设计关键提示：**
- Feed 中**喂鸟器自动拍摄**的视频需要有视觉区分（如小图标、边框颜色或角标）
- 视频时长上限 2 分钟，播放器需显示时长
- 上传页的鸟种标签支持多选（从鸟种库搜索添加）
- 评论最多 2 层嵌套
- 管理后台可以用简洁的表格+表单风格，不需要前台那样精美

### 3. 组件清单

列出 Phase 1-2 开发需要的所有基础组件：

**基础 UI 组件：**
- Button（Primary / Secondary / Ghost / Danger）
- Input（Text / Password / Textarea / Search）
- Select / Dropdown
- Avatar（带在线状态指示器，为喂鸟器状态复用）
- Card（视频卡片、用户卡片）
- Modal / Dialog
- Toast / Notification
- Tab
- Pagination / Infinite Scroll
- Badge / Tag（鸟种标签）
- Skeleton / Loading

**业务组件：**
- VideoPlayer（HLS 播放器，含全屏/进度/码率切换）
- VideoCard（缩略图+标题+作者+统计）
- CommentList（含二级回复）
- UploadDropzone（拖拽上传+进度条）
- UserCard（头像+昵称+关注按钮）
- BirdTagSelector（鸟种搜索选择器）
- FeederStatusBadge（在线/离线状态）

### 4. 多端适配说明

```
响应式断点：
- Mobile:  < 768px  （单列布局）
- Tablet:  768px ~ 1024px（两列布局）
- Desktop: > 1024px（三列布局 + 侧边栏）

Feed 视频卡片：
- Mobile:  全宽单列
- Tablet:  两列网格
- Desktop: 三列网格

管理后台：
- Mobile:  不强制适配（可简单响应式）
- Desktop: 侧边栏 + 主内容区
```

### 品牌调性指引

| 维度 | 方向 | 避免 |
|------|------|------|
| 整体风格 | 自然、清新、专业 | 过于花哨、暗黑系 |
| 主色调 | 绿色系（自然/生态感）| 饱和度过高的荧光色 |
| 图标风格 | 线性或微填充 | 拟物化/3D 图标 |
| 圆角 | 中等圆角（8-12px）| 直角或全圆 |
| 图片处理 | 保持自然色彩 | 重滤镜 |

### 需要协作的人

| 协作对象 | 协作内容 | 建议时间 |
|---------|---------|---------|
| PM | 确认产品调性和品牌方向 | 03-12 约 30min |
| Web 前端 | 确认 Tailwind 约束、组件实现可行性 | 03-14 或 03-17 约 30min |
| 移动端 | 确认 RN 组件适配要求（简短对齐即可） | 03-17 约 15min |

### 验收要求
- [ ] Design Token 文件产出（JSON 或 CSS Variables）
- [ ] 6 个核心页面线框图产出
- [ ] 组件清单产出（基础 UI + 业务组件）
- [ ] 多端适配说明产出
- [ ] Web 前端和移动端 Review 通过

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 2.2（价值主张）、第 5 章（功能需求）、第 7 章（多端策略）
- [Tailwind CSS Colors](https://tailwindcss.com/docs/customizing-colors)
- 竞品视觉参考：[eBird](https://ebird.org)、[Merlin Bird ID](https://merlin.allaboutbirds.org)、[iNaturalist](https://www.inaturalist.org)

---

## 你的时间线

```
03-10 Mon  PRD 评审会（全员，2h）
03-11 Tue  PRD 反馈
03-12 Wed  T0-3 启动：与 PM 对齐品牌调性，开始 Design Token
03-13 Thu  Design Token 定义
03-14 Fri  线框图：首页 Feed + 视频详情
03-17 Mon  线框图：个人主页 + 上传页 + Design Token 完成 ✅
03-18 Tue  线框图：注册登录 + 管理后台框架
03-19 Wed  T0-3 完成 ✅：组件清单 + 适配说明 + 提交 Review
03-21 Fri  M0 里程碑评审会（你主讲设计规范，约 20min）
```
