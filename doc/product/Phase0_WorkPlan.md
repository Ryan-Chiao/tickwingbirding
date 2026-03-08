# Phase 0 — 项目启动与澄清：详细工作安排

**阶段目标：** 冻结需求范围，完成技术选型与架构设计，建立开发基础设施，对齐全团队
**阶段周期：** 2026-03-10 ~ 2026-03-21（2 周）
**里程碑：** M0 — 项目 Kickoff 完成
**上游文档：** `doc/product/Tickwing_PRD_v2.3.md`

---

## 总览：任务 × 负责人

| #    | 任务             | 负责人     | 协作方        | 产出物                           | 截止日   |
| ---- | -------------- | ------- | ---------- | ----------------------------- | ----- |
| T0-1 | PRD 评审与定稿      | PM      | 全员         | PRD v2.2 定稿确认                 | 03-12 |
| T0-2 | 架构设计文档 (ADR)   | 后端 Lead | 前端、DevOps  | `doc/architecture/ADR.md`     | 03-17 |
| T0-3 | UI/UX 设计规范 v1  | 设计师     | Web 前端、移动端 | `doc/design/` 设计规范            | 03-19 |
| T0-4 | Monorepo 仓库初始化 | DevOps  | 后端、Web 前端  | Git 仓库 + 基础骨架                 | 03-17 |
| T0-5 | 本地开发环境搭建       | DevOps  | 后端         | Docker Compose + 文档           | 03-19 |
| T0-6 | CI/CD 流水线基础版   | DevOps  | 后端、Web 前端  | GitHub Actions 配置             | 03-21 |
| T0-7 | 视频上传转码技术 Spike | 后端      | DevOps     | Spike 验证报告                    | 03-19 |
| T0-8 | QA 测试策略文档      | QA      | PM、后端      | `doc/testing/TestStrategy.md` | 03-21 |
| T0-9 | 风险清单定稿         | PM      | 全员         | 风险登记册                         | 03-21 |

---

## T0-1 PRD 评审与定稿

### 负责人
**PM（产品经理）**

### 协作方
全体团队成员参与评审

### 工作内容
1. 组织 PRD v2.2 全员评审会议（建议 2h）
2. 逐章 walkthrough，重点对齐：
   - 第 3 章：角色权限是否清晰，有无遗漏场景
   - 第 4 章：业务流程是否可执行，特别是审核策略（先发后审）
   - 第 5 章：P0 需求是否合理，验收标准是否可量化
   - 第 9 章：数据模型是否满足后端需求
   - 第 13 章：各 Phase 排期是否可行
3. 收集所有反馈意见，评估是否需要变更
4. 更新 PRD 版本号并冻结 P0 范围

### 条件约束
- 必须在 Phase 0 的 **第 3 天前**完成，否则后续任务无法启动
- 评审不通过的条目需记录到变更请求中，不可口头解决

### 注意事项
- 确保每位团队成员**提前阅读** PRD，会上不做全文朗读
- 争议条目记录但不在会上反复讨论，限时 10 分钟/条，超时则线下跟进
- 移动端工程师在 Phase 0-4 暂无开发任务，但**必须参与评审**以理解全局

### 验收要求
- [ ] PRD v2.2 状态标记为 🟢 已定稿
- [ ] 全员签字/回复确认（邮件或协作工具留痕）
- [ ] 变更请求清单归档到 `doc/meeting/`
- [ ] P0 需求范围冻结，后续变更需走变更流程

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md`
- `doc/product/Tickwing_PRD_v1.md`（背景参考）

---

## T0-2 架构设计文档 (ADR)

### 负责人
**后端 Lead（后端工程师 #1）**

### 协作方
- Web 前端工程师：确认前后端交互方式、i18n 方案
- DevOps：确认部署架构与本地开发环境方案
- PM：确认架构是否满足 PRD 非功能需求

### 工作内容
1. **整体架构决策记录**，至少覆盖以下 ADR：

| ADR # | 决策主题 | 需确认内容 |
|-------|---------|-----------|
| ADR-001 | 后端框架选型 | NestJS 模块划分策略，确认 auth/user/video/feeder/community/admin/notification 七个模块的边界 |
| ADR-002 | 数据库与 ORM | PostgreSQL + TypeORM 还是 Prisma？迁移策略如何？ |
| ADR-003 | 认证方案 | JWT Access + Refresh Token 的具体实现方案：过期时间、存储位置、黑名单机制 |
| ADR-004 | 文件上传方案 | 客户端直传 S3/OSS 的签名流程，分片上传策略，本地开发用 MinIO 的兼容性验证 |
| ADR-005 | 视频转码方案 | FFmpeg Worker 进程模型、BullMQ 队列配置、HLS 输出规格（分辨率档位、码率） |
| ADR-006 | 前后端通信 | RESTful API 规范、错误码体系、分页方案（游标 vs offset）、OpenAPI 自动生成 |
| ADR-007 | i18n 方案 | 前端语言包格式（JSON）、后端错误码 code-based 映射、翻译文件目录结构 |
| ADR-008 | 坐标脱敏方案 | 存储层精确坐标，展示层截断至小数点后 2 位的具体实现方式 |
| ADR-009 | 云厂商抽象层 | 对象存储接口封装，如何做到 S3/OSS 一套代码切换 |

2. **数据模型 Review**：Review PRD v2.2 第 9 章的 DDL，提出修改建议并定稿
3. **API 端点确认**：Review PRD v2.2 第 10 章的 API 列表，补充请求/响应 schema 草案
4. **Monorepo 目录结构设计**：确认项目代码组织方式

### 条件约束
- 必须在 T0-1（PRD 评审）完成后开始
- ADR 文档格式统一为：`背景 → 决策 → 理由 → 后果 → 状态`
- 每个 ADR 必须有明确的决策结论，不可留"待定"

### 注意事项
- **不要过度设计**：Phase 1-2 是 MVP，架构可以简单但边界要清晰
- 重点考虑本地开发的便利性：开发者 `docker compose up` 后应能一键启动所有依赖
- HLS 转码的输出规格建议：
  - 360p (640×360, 800kbps) — 移动端弱网
  - 720p (1280×720, 2.5Mbps) — 默认
  - 1080p (1920×1080, 5Mbps) — 高清（源视频为 2K 时生成）
- 视频时长上限 2 分钟、大小上限 300MB（H.265/2K），需在上传接口做校验
- 必须考虑 AWS 和阿里云的 **SDK 差异**，抽象层设计参考 `@aws-sdk/client-s3` 和 `ali-oss` 的 API 区别

### 验收要求
- [ ] `doc/architecture/ADR.md` 文件产出，包含至少 9 个 ADR
- [ ] 每个 ADR 有明确的状态：`Accepted` / `Proposed` / `Superseded`
- [ ] Monorepo 目录结构图产出
- [ ] 数据模型修改建议提交（如有），PM 评审后更新 PRD
- [ ] Web 前端、DevOps 完成 Review 并签字确认

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 8、9、10 章
- [NestJS 官方文档 — Modules](https://docs.nestjs.com/modules)
- [ADR 格式参考 — Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [BullMQ 文档](https://docs.bullmq.io/)

---

## T0-3 UI/UX 设计规范 v1

### 负责人
**UI/UX 设计师**

### 协作方
- Web 前端工程师：确认组件实现可行性、Tailwind CSS 约束
- 移动端工程师：确认移动端适配要求
- PM：确认设计方向与品牌调性

### 工作内容
1. **Design Token 定义**（Phase 0 必须交付）：
   - 色彩系统：主色、辅助色、中性色、语义色（成功/警告/错误/信息）
   - 排版：字体家族、字号阶梯、行高、字重
   - 间距：基础间距单位（4px / 8px grid）
   - 圆角、阴影、边框
   - 暗色模式是否预留（建议首发不做，但 Token 层预留）

2. **核心页面线框图**（Phase 0 交付，高保真稿 Phase 1 初交付即可）：
   - 首页 Feed
   - 视频详情页（播放器 + 评论区）
   - 个人主页
   - 上传页
   - 注册 / 登录页
   - 管理后台框架（侧边栏导航结构）

3. **组件库规划**：列出 Phase 1-2 需要的基础组件清单
   - Button、Input、Avatar、Card、Modal、Toast、Tab、Pagination 等
   - 视频播放器组件的交互规范
   - 空状态、加载中、错误状态的统一样式

4. **多端适配原则**：
   - Web 响应式断点（移动端 < 768px、平板 768-1024px、桌面 > 1024px）
   - 移动 App 与 Web 的差异点说明

### 条件约束
- Design Token 和线框图必须在 Phase 0 结束前交付
- 高保真稿可以在 Phase 1 前两天交付（给前端留衔接时间）
- 设计工具不限（Figma / Sketch / 其他），但 Token 需导出为 JSON/CSS 变量供前端使用
- 首发版本仅简体中文，文案长度按中文预估

### 注意事项
- 观鸟社区的调性应偏向**自然、清新、专业**，避免过于花哨
- 视频是核心内容，设计需突出视频卡片的视觉层级
- 考虑 Feed 中既有"用户手动上传"也有"喂鸟器自动拍摄"的视频，需要在 UI 上有区分标识
- 管理后台设计可以简洁为主，不需要和前台同等精细度
- 首发不做暗色模式，但 Design Token 层建议用语义化命名（如 `color-bg-primary` 而非 `color-white`）

### 验收要求
- [ ] Design Token 文件产出（JSON 或 CSS Variables），存放到 `doc/design/`
- [ ] 核心页面线框图产出（至少覆盖上述 6 个页面）
- [ ] 组件清单产出（Phase 1-2 所需）
- [ ] Web 前端和移动端工程师 Review 通过

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 2.2（价值主张）、第 7 章（多端策略）
- [Tailwind CSS 默认配置](https://tailwindcss.com/docs/theme)
- 竞品参考：eBird、Merlin Bird ID、iNaturalist 的视觉风格

---

## T0-4 Monorepo 仓库初始化

### 负责人
**DevOps / SRE**

### 协作方
- 后端 Lead：确认后端项目骨架、NestJS 模块结构
- Web 前端：确认 Next.js 项目骨架

### 工作内容
1. **创建 Git 仓库**，初始化 Monorepo 结构：

```
birdwatch/
├── apps/
│   ├── api/                  # NestJS 后端
│   │   ├── src/
│   │   │   ├── modules/
│   │   │   │   ├── auth/
│   │   │   │   ├── user/
│   │   │   │   ├── video/
│   │   │   │   ├── feeder/
│   │   │   │   ├── community/
│   │   │   │   ├── notification/
│   │   │   │   └── admin/
│   │   │   ├── common/       # 共享装饰器、拦截器、管道
│   │   │   ├── config/       # 环境配置
│   │   │   └── main.ts
│   │   ├── test/
│   │   └── package.json
│   ├── web/                  # Next.js Web 端
│   │   ├── src/
│   │   │   ├── app/          # App Router 页面
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── store/
│   │   │   ├── api/
│   │   │   ├── i18n/         # 语言包目录
│   │   │   │   └── zh-CN.json
│   │   │   └── utils/
│   │   └── package.json
│   └── mobile/               # React Native (Phase 6 再填充)
│       └── .gitkeep
├── packages/
│   ├── shared-types/         # 前后端共享 TypeScript 类型
│   ├── eslint-config/        # 统一 ESLint 配置
│   └── tsconfig/             # 统一 TypeScript 配置
├── docker/
│   ├── docker-compose.yml    # 本地开发环境
│   ├── docker-compose.prod.yml
│   └── Dockerfile.*
├── .github/
│   └── workflows/            # CI/CD 配置
├── doc/                      # 已有的文档目录（软链或直接包含）
├── turbo.json                # Turborepo 配置
├── package.json              # Root package.json
├── .gitignore
├── .env.example
└── README.md
```

2. **Monorepo 工具选型与配置**：
   - 推荐 **Turborepo**（简单高效）或 Nx（功能更全但较重）
   - 配置 workspace 依赖管理（pnpm workspace 推荐）
   - 配置统一的 TypeScript 严格模式

3. **Git 分支策略**确定：
   - `main` — 生产分支，仅通过 PR 合并
   - `develop` — 开发主干
   - `feature/*` — 功能分支
   - `hotfix/*` — 紧急修复
   - PR 模板创建

4. **基础配置文件**：
   - `.gitignore`（含 node_modules、.env、dist、uploads 等）
   - `.env.example`（列出所有需要的环境变量，含注释）
   - `README.md`（项目简介 + 快速启动指南）
   - ESLint + Prettier 统一配置
   - husky + lint-staged（pre-commit 检查）

### 条件约束
- 仓库名建议 `tickwingbirding`（全小写）
- 包管理器统一使用 **pnpm**（性能好、磁盘节省）
- Node.js 版本锁定（建议 LTS 20.x），在 `.nvmrc` 或 `package.json engines` 中声明
- TypeScript 严格模式 (`strict: true`)，项目初始就启用，避免后期补债

### 注意事项
- `mobile/` 目录先创建占位，Phase 6 前不需要实际内容
- `doc/` 目录可以直接放在仓库根目录（当前结构），也可以通过 git submodule 管理——建议直接放在仓库内，简单可靠
- `.env.example` 中**绝对不能包含真实密钥**，只放占位符和注释
- `packages/shared-types/` 是前后端共享的 TypeScript 类型定义（如 User、Video、Feeder 的接口类型），确保前后端类型一致

### 验收要求
- [ ] Git 仓库创建并推送到 GitHub
- [ ] `pnpm install` 成功，无报错
- [ ] `apps/api` 可以 `pnpm dev` 启动（返回 Hello World 即可）
- [ ] `apps/web` 可以 `pnpm dev` 启动（显示默认 Next.js 页面即可）
- [ ] ESLint + Prettier + TypeScript 检查全部通过
- [ ] `pnpm lint` 和 `pnpm typecheck` 命令可用
- [ ] `.env.example` 包含所有预期环境变量（含注释说明）
- [ ] `README.md` 包含快速启动步骤
- [ ] 分支策略文档写入仓库或 `doc/architecture/`

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 8 章（技术方案）
- [Turborepo 官方指南](https://turbo.build/repo/docs)
- [pnpm Workspaces](https://pnpm.io/workspaces)

---

## T0-5 本地开发环境搭建

### 负责人
**DevOps / SRE**

### 协作方
- 后端 Lead：确认后端所需的基础设施服务

### 工作内容
1. **编写 `docker-compose.yml`**，包含以下服务：

| 服务 | 镜像 | 端口 | 用途 |
|------|------|------|------|
| PostgreSQL | `postgres:16-alpine` | 5432 | 主数据库 |
| Redis | `redis:7-alpine` | 6379 | 缓存 + BullMQ 队列 |
| MinIO | `minio/minio` | 9000 / 9001 | 本地模拟 S3/OSS 对象存储 |
| MailHog | `mailhog/mailhog` | 1025 / 8025 | 本地邮件测试（注册验证、密码找回） |

2. **初始化脚本**：
   - 数据库初始化 SQL（创建数据库和基础 schema）
   - MinIO 默认 bucket 创建（`birdwatch-videos`、`birdwatch-avatars`、`birdwatch-thumbnails`）
   - Redis 无需特殊初始化

3. **环境变量文档化**：
   - 在 `.env.example` 中列出所有变量并分组注释
   - 提供 `.env.development` 模板（本地开发预填值）

4. **开发者文档**：
   - 撰写 `doc/operations/LocalDevSetup.md`
   - 包含：前置条件安装、一键启动步骤、常见问题排查

### 条件约束
- 开发者在安装好 Docker Desktop、Node.js、pnpm 后，应能通过以下命令完成环境搭建：
  ```bash
  git clone <repo>
  cd birdwatch
  cp .env.example .env
  docker compose up -d
  pnpm install
  pnpm dev
  ```
- MinIO 必须兼容 AWS S3 API（这是 MinIO 的默认行为，但需验证上传签名流程）

### 注意事项
- Docker Compose 中所有数据使用 named volume，避免直接挂载到项目目录
- PostgreSQL 的 data volume 不要加到 `.gitignore` 忘记说明——这个是 Docker 管理的，不在项目目录内
- MinIO 的 Access Key / Secret Key 在本地环境使用固定值（如 `minioadmin`），在 `.env.example` 中说明
- MailHog 的 Web UI 在 `http://localhost:8025`，开发者可以在这里查看发出的邮件
- Windows 用户可能需要 WSL2，在文档中注明

### 验收要求
- [ ] `docker compose up -d` 全部服务启动成功
- [ ] PostgreSQL 可连接，数据库已创建
- [ ] Redis 可连接
- [ ] MinIO Web Console 可访问 (`http://localhost:9001`)，默认 bucket 已创建
- [ ] MailHog Web UI 可访问 (`http://localhost:8025`)
- [ ] `doc/operations/LocalDevSetup.md` 文档完成
- [ ] 至少 1 名后端工程师按照文档完成环境搭建验证

### 可参考文档
- [MinIO Docker 部署](https://min.io/docs/minio/container/index.html)
- [MailHog GitHub](https://github.com/mailhog/MailHog)

---

## T0-6 CI/CD 流水线基础版

### 负责人
**DevOps / SRE**

### 协作方
- 后端 Lead、Web 前端：确认构建和测试命令

### 工作内容
1. **GitHub Actions 基础流水线**：

```yaml
# 触发条件：push 到 develop/main，或 PR 创建
# 步骤：
#   1. Checkout 代码
#   2. Setup Node.js + pnpm
#   3. pnpm install (with cache)
#   4. pnpm lint        (ESLint)
#   5. pnpm typecheck   (TypeScript)
#   6. pnpm test         (单元测试)
#   7. pnpm build       (构建检查)
```

2. **PR 检查配置**：
   - PR 标题格式检查（建议 Conventional Commits：`feat:` / `fix:` / `chore:` 等）
   - 至少 1 人 approve 才可合并
   - CI 全部通过才可合并

3. **环境分层准备**（配置文件和文档，实际部署在 Phase 1）：
   - `dev` — 开发环境
   - `stage` — 预发布环境
   - `prod` — 生产环境

### 条件约束
- Phase 0 只需完成 CI 部分（代码检查 + 测试 + 构建）
- CD（自动部署）在 Phase 1 完成
- CI 运行时间控制在 **5 分钟以内**

### 注意事项
- 使用 Turborepo 的缓存能力加速 CI
- pnpm store 做 GitHub Actions 缓存，避免每次重新下载
- 暂时不需要 Docker 镜像构建（Phase 1 再加）
- commit message 格式建议从项目初始就规范，避免后期补债

### 验收要求
- [ ] PR 创建后自动触发 CI
- [ ] lint + typecheck + test + build 全部 pass
- [ ] CI 失败时 PR 不可合并
- [ ] 至少 1 人 approve 规则生效
- [ ] CI 配置文件已提交到 `.github/workflows/`

### 可参考文档
- [GitHub Actions — Node.js Workflow](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-nodejs)
- [Turborepo + GitHub Actions](https://turbo.build/repo/docs/ci/github-actions)

---

## T0-7 视频上传转码技术 Spike

### 负责人
**后端工程师 #2**

### 协作方
- 后端 Lead：Review 方案
- DevOps：MinIO 环境支持

### 工作内容

**目的：** 在 Phase 2 正式开发前，用 2-3 天做概念验证，降低视频链路技术风险。

验证内容：

| # | 验证项 | 具体要求 |
|---|--------|---------|
| 1 | MinIO 兼容性 | 使用 `@aws-sdk/client-s3` 连接 MinIO，验证 Presigned URL 上传是否正常工作 |
| 2 | 分片上传 | 模拟客户端分片上传（multipart upload）到 MinIO，验证 300MB 文件上传 |
| 3 | FFmpeg 转码 | 本地安装 FFmpeg，输入 H.265/2K 视频，输出 HLS 多码率（360p/720p/1080p），记录转码耗时 |
| 4 | HLS 播放验证 | 生成的 HLS 文件通过 hls.js 在浏览器中播放，验证自适应码率 |
| 5 | BullMQ 队列 | 创建简单的 BullMQ Worker，模拟"接收任务 → 调用 FFmpeg → 更新状态"流程 |
| 6 | 缩略图提取 | FFmpeg 从视频中提取关键帧作为缩略图（3 张候选） |

### 条件约束
- 这是**概念验证**，不需要写生产级代码
- 产出为验证报告 + 示例代码片段，不合入主分支
- 需要准备 2-3 个测试视频文件（H.265/2K/~100MB）
- 必须基于本地 Docker 环境（MinIO + Redis）完成

### 注意事项
- H.265 解码需要 FFmpeg 编译时包含 `libx265`，验证 Docker 镜像中是否自带
- MinIO 的 Presigned URL 与 AWS S3 的行为有细微差异，重点测试：
  - `PutObject` Presigned URL 生成与使用
  - `multipartUpload` 流程（CreateMultipartUpload → UploadPart → CompleteMultipartUpload）
- HLS 输出建议使用 `-hls_time 6 -hls_list_size 0` 参数，每个分片 6 秒
- 记录每种分辨率的转码耗时和输出文件大小，作为后续容量规划的依据

### 验收要求
- [ ] Spike 报告产出，存放 `doc/architecture/Spike_VideoTranscode.md`
- [ ] 报告包含：方案选择、验证结果、遇到的问题与解决方案、性能数据
- [ ] 后端 Lead Review 通过
- [ ] 确认 MinIO ↔ S3 SDK 兼容性结论
- [ ] 确认 FFmpeg HLS 输出规格（码率档位、分片时长）
- [ ] 确认 BullMQ 队列模型可行

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 4.1（上传流程）、第 9.3（视频状态机）
- [FFmpeg HLS 输出](https://trac.ffmpeg.org/wiki/Encode/H.264#losslessh.264)
- [hls.js](https://github.com/video-dev/hls.js/)
- [AWS S3 SDK v3 — Presigned URL](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-s3/)
- [BullMQ 快速入门](https://docs.bullmq.io/guide/quick-start)

---

## T0-8 QA 测试策略文档

### 负责人
**QA 工程师**

### 协作方
- PM：确认验收标准
- 后端 Lead：确认技术栈对应的测试工具

### 工作内容
1. **编写测试策略文档** `doc/testing/TestStrategy.md`，包含：

| 章节 | 内容 |
|------|------|
| 测试范围 | 各 Phase 的测试范围定义 |
| 测试分层 | 单元 / 集成 / E2E / 性能 / 安全 的职责划分与占比 |
| 工具选型 | Jest / Playwright / k6 / OWASP ZAP 等确认 |
| 覆盖率目标 | 单元测试最低覆盖率门槛（建议核心模块 ≥ 80%） |
| E2E 用例清单 | Phase 1-2 的关键链路 E2E 用例列表（不需要写脚本，只需列出用例） |
| 缺陷管理 | 缺陷分级标准（S1-S4）、缺陷流转流程 |
| 发布门禁 | 各环境的发布门禁标准（复述 PRD 14.2 并细化） |
| 自动化策略 | 哪些测试自动化、哪些手动、自动化的优先级排序 |

2. **缺陷分级标准**定义：

| 等级 | 定义 | 示例 | 修复时限 |
|------|------|------|---------|
| S1 | 系统不可用 / 数据丢失 | 注册崩溃、视频上传后丢失 | 4h 内修复 |
| S2 | 核心功能不可用 | 播放失败、无法评论 | 24h 内修复 |
| S3 | 功能受限但有 workaround | 排序不生效、缩略图显示错误 | 当前 Sprint 内修复 |
| S4 | 体验问题 | 文案错误、样式偏移 | 排入 backlog |

### 条件约束
- Phase 0 只需产出策略文档，不需要写测试代码
- 实际测试脚本从 Phase 1 开始随开发同步编写

### 注意事项
- 测试环境应与开发环境隔离（至少数据库实例不同）
- 考虑 Testcontainers 做集成测试的数据库隔离
- 安全测试不需要 Phase 0 就规划细节，但需要在策略文档中占位

### 验收要求
- [ ] `doc/testing/TestStrategy.md` 产出
- [ ] 缺陷分级标准定义完成
- [ ] Phase 1-2 E2E 关键用例清单列出（至少 10 条）
- [ ] PM 和后端 Lead Review 通过

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 14 章（质量保障）
- [Jest 官方文档](https://jestjs.io/)
- [Playwright 官方文档](https://playwright.dev/)

---

## T0-9 风险清单定稿

### 负责人
**PM（产品经理）**

### 协作方
全体团队成员

### 工作内容
1. 基于 PRD v2.2 第 16 章的风险表，扩展为正式的**风险登记册**
2. 每个风险项补充：
   - 发生概率（高/中/低）
   - 影响程度（高/中/低）
   - 缓解措施的 owner 和截止日期
   - 当前状态（已缓解 / 监控中 / 未处理）
3. 新增基于 Phase 0 讨论中发现的风险项
4. 建立风险 Review 节奏：每个 Sprint 回顾会中 review 一次

### 条件约束
- 风险清单在 Phase 0 结束前定稿
- 每个 Milestone 评审时更新

### 注意事项
- 不要列过多低概率风险，聚焦 TOP 10
- 与 T0-7（Spike）的结果关联：Spike 发现的技术风险需补充到清单中

### 验收要求
- [ ] 风险登记册产出，存放 `doc/product/RiskRegister.md`
- [ ] 至少覆盖 PRD 中的 7 项风险 + Spike 发现的风险
- [ ] 每项风险有明确 owner
- [ ] 全员 Review 通过

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 16 章（风险与应对）

---

## Phase 0 时间线（按天）

```
Week 1 (03-10 ~ 03-14)
─────────────────────────────────────────────────────────
Mon 03-10  │ T0-1 PRD 评审会
Tue 03-11  │ T0-1 反馈收集与 PRD 定稿
Wed 03-12  │ T0-2 架构设计启动 │ T0-3 设计规范启动 │ T0-4 仓库初始化启动
Thu 03-13  │ T0-2 ADR 编写     │ T0-3 Token 定义   │ T0-4 仓库搭建
Fri 03-14  │ T0-2 ADR 编写     │ T0-3 线框图       │ T0-4 仓库完成 ✅

Week 2 (03-17 ~ 03-21)
─────────────────────────────────────────────────────────
Mon 03-17  │ T0-2 ADR 完成 ✅  │ T0-5 Docker 环境   │ T0-7 Spike 启动
Tue 03-18  │ T0-2 Review       │ T0-5 Docker 环境   │ T0-7 Spike 验证
Wed 03-19  │ T0-3 设计完成 ✅  │ T0-5 环境完成 ✅   │ T0-7 Spike 完成 ✅
Thu 03-20  │ T0-6 CI/CD 搭建   │ T0-8 测试策略      │ T0-9 风险清单
Fri 03-21  │ T0-6 CI 完成 ✅   │ T0-8 完成 ✅       │ T0-9 完成 ✅
           │ ──── M0 里程碑评审会 ────
```

### M0 里程碑评审会议程 (03-21 下午)

| 时间 | 内容 | 主讲 |
|------|------|------|
| 14:00-14:20 | PRD 定稿确认 & OQ 决策回顾 | PM |
| 14:20-14:50 | 架构方案 & ADR 宣讲 | 后端 Lead |
| 14:50-15:10 | 设计规范 & 线框图展示 | 设计师 |
| 15:10-15:20 | 休息 | — |
| 15:20-15:40 | 仓库 & 开发环境 & CI 演示 | DevOps |
| 15:40-15:55 | Spike 结果分享 | 后端 #2 |
| 15:55-16:10 | 测试策略概要 | QA |
| 16:10-16:25 | 风险 Review | PM |
| 16:25-16:40 | Phase 1 范围确认 & 任务认领 | PM + 全员 |
| 16:40-17:00 | Q&A & 会议纪要 | PM |

---

## Phase 0 Exit Criteria（总验收）

以下全部满足后，Phase 0 结束，正式进入 Phase 1：

- [ ] PRD v2.2 全员确认定稿，P0 需求范围冻结
- [ ] ADR 文档完成并通过评审，关键技术决策有明确结论
- [ ] Design Token + 核心页面线框图交付
- [ ] Monorepo 仓库创建，骨架代码可运行
- [ ] 本地开发环境一键可启动（Docker Compose），开发者文档验证通过
- [ ] CI 流水线可用（lint + typecheck + test + build 自动运行）
- [ ] 视频 Spike 完成，技术方案可行性确认
- [ ] 测试策略文档产出
- [ ] 风险登记册定稿
- [ ] M0 里程碑评审会完成，会议纪要归档到 `doc/meeting/M0_Review.md`
