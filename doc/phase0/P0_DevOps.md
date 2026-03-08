# Phase 0 工作计划 — DevOps / SRE

**阶段：** Phase 0 — 项目启动与澄清
**周期：** 2026-03-10 ~ 2026-03-21
**上游文档：** `doc/product/Tickwing_PRD_v2.3.md`
**完整工作计划：** `doc/product/Phase0_WorkPlan.md`

---

## 你在 Phase 0 的任务

| # | 任务 | 角色 | 截止日 | 产出物 |
|---|------|------|--------|--------|
| T0-1 | PRD 评审与定稿 | — | 03-12 | （不要求参与，但推荐旁听） |
| T0-2 | 架构设计文档 (ADR) | Review | 03-18 | Review 部署架构相关 ADR |
| T0-4 | Monorepo 仓库初始化 | **Lead** | 03-17 | Git 仓库 + 骨架代码 |
| T0-5 | 本地开发环境搭建 | **Lead** | 03-19 | Docker Compose + 开发者文档 |
| T0-6 | CI/CD 流水线基础版 | **Lead** | 03-21 | GitHub Actions 配置 |

---

## T0-4 Monorepo 仓库初始化（Lead）

**时间：** 03-12 ~ 03-14（3 天）

### 协作方
- 后端 Lead：确认后端 NestJS 模块结构
- Web 前端：确认 Next.js 项目骨架

### 工作内容

#### 1. 创建 Git 仓库

仓库名：**`tickwingbirding`**（已由产品负责人确认）

初始化 Monorepo 结构：

```
tickwingbirding/
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
│   │   │   ├── app/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── store/
│   │   │   ├── api/
│   │   │   ├── i18n/
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
│   ├── docker-compose.yml
│   ├── docker-compose.prod.yml
│   ├── init-scripts/         # 数据库/MinIO 初始化脚本
│   └── Dockerfile.*
├── .github/
│   ├── workflows/
│   └── pull_request_template.md
├── doc/                      # 项目文档（已有内容）
├── turbo.json
├── pnpm-workspace.yaml
├── package.json
├── .gitignore
├── .nvmrc
├── .env.example
└── README.md
```

#### 2. Monorepo 工具与包管理

- 包管理器：**pnpm**（在 `pnpm-workspace.yaml` 中配置 workspace）
- 构建编排：**Turborepo**（配置 `turbo.json`）
- Node.js 版本：**LTS 20.x**（写入 `.nvmrc` 和 `package.json engines`）

#### 3. Git 分支策略

- `main` — 生产分支，仅通过 PR 合并，需 CI 通过 + 1 人 approve
- `develop` — 开发主干，日常开发基于此分支
- `feature/*` — 功能分支，从 develop 切出
- `hotfix/*` — 紧急修复，从 main 切出
- 创建 PR 模板 `.github/pull_request_template.md`

#### 4. 基础配置文件

| 文件 | 内容 |
|------|------|
| `.gitignore` | node_modules, .env, .env.*, dist, .turbo, uploads, *.log, .DS_Store |
| `.nvmrc` | `20` |
| `.env.example` | 所有环境变量分组注释（见 T0-5 细节） |
| `README.md` | 项目简介 + 快速启动步骤 + 技术栈 + 文档链接 |
| ESLint | 统一配置在 `packages/eslint-config/`，extends @typescript-eslint |
| Prettier | 统一配置（2 空格，单引号，trailing comma，120 字符行宽） |
| husky | pre-commit hook 执行 lint-staged |
| lint-staged | 对 staged 的 .ts/.tsx 文件执行 eslint --fix + prettier --write |

### 条件约束
- 仓库名 `tickwingbirding`
- 包管理器 **pnpm**，不使用 npm 或 yarn
- TypeScript **严格模式** (`strict: true`)
- Node.js **LTS 20.x**

### 注意事项
- `mobile/` 目录先创建 `.gitkeep` 占位，Phase 6 前不填充
- `doc/` 直接放在仓库内，不用 submodule
- `.env.example` **绝对不能包含真实密钥**
- `packages/shared-types/` 放前后端共享的 TS 类型（User, Video, Feeder 等 interface）

### 验收要求
- [ ] 仓库推送到 GitHub
- [ ] `pnpm install` 成功
- [ ] `apps/api`: `pnpm dev` 启动返回 Hello World
- [ ] `apps/web`: `pnpm dev` 启动显示 Next.js 默认页面
- [ ] `pnpm lint` 和 `pnpm typecheck` 通过
- [ ] `.env.example` 完整（分组注释）
- [ ] `README.md` 含快速启动步骤
- [ ] 后端 Lead 和 Web 前端 Review 通过

---

## T0-5 本地开发环境搭建（Lead）

**时间：** 03-17 ~ 03-19（3 天）

### 协作方
- 后端 Lead：验证后端服务可连接

### 工作内容

#### 1. Docker Compose 编写

`docker/docker-compose.yml` 包含以下服务：

| 服务 | 镜像 | 端口映射 | 用途 |
|------|------|---------|------|
| postgres | `postgres:16-alpine` | 5432:5432 | 主数据库 |
| redis | `redis:7-alpine` | 6379:6379 | 缓存 + BullMQ |
| minio | `minio/minio` | 9000:9000, 9001:9001 | 本地对象存储 |
| mailhog | `mailhog/mailhog` | 1025:1025, 8025:8025 | 本地邮件测试 |

所有数据使用 **named volume**，不挂载到项目目录。

#### 2. 初始化脚本

`docker/init-scripts/` 下：
- `init-db.sql` — 创建数据库 `birdwatch_dev`
- `init-minio.sh` — 创建默认 bucket：`birdwatch-videos`、`birdwatch-avatars`、`birdwatch-thumbnails`

#### 3. 环境变量文档化

`.env.example` 内容（分组注释）：

```bash
# ===== Database =====
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=birdwatch_dev
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password_here

# ===== Redis =====
REDIS_HOST=localhost
REDIS_PORT=6379

# ===== Object Storage (MinIO for local, S3/OSS for prod) =====
STORAGE_PROVIDER=minio          # minio | s3 | oss
STORAGE_ENDPOINT=http://localhost:9000
STORAGE_ACCESS_KEY=minioadmin
STORAGE_SECRET_KEY=minioadmin
STORAGE_BUCKET_VIDEOS=birdwatch-videos
STORAGE_BUCKET_AVATARS=birdwatch-avatars
STORAGE_BUCKET_THUMBNAILS=birdwatch-thumbnails
STORAGE_REGION=us-east-1

# ===== Mail (MailHog for local) =====
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_FROM=noreply@birdwatch.dev

# ===== JWT =====
JWT_ACCESS_SECRET=your_access_secret_here
JWT_REFRESH_SECRET=your_refresh_secret_here
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# ===== App =====
APP_PORT=3000
APP_URL=http://localhost:3000
WEB_PORT=3001
WEB_URL=http://localhost:3001
```

提供 `.env.development` 模板（本地预填值，gitignore 但有说明）。

#### 4. 开发者文档

撰写 `doc/operations/LocalDevSetup.md`，包含：
- 前置条件（Docker Desktop、Node.js 20.x、pnpm）
- 一键启动步骤（6 行命令）
- 各服务的访问地址和默认凭证
- 常见问题排查（端口冲突、Docker 内存不足、Windows WSL2 注意事项）

### 注意事项
- MinIO Access Key / Secret Key 本地环境用 `minioadmin`
- MailHog Web UI 在 `http://localhost:8025`
- Windows 用户需要 WSL2，文档中注明
- PostgreSQL data volume 由 Docker 管理，不在项目目录内

### 验收要求
- [ ] `docker compose up -d` 全部服务启动成功
- [ ] PostgreSQL 可连接，数据库 `birdwatch_dev` 已创建
- [ ] Redis 可连接
- [ ] MinIO Console 可访问 `http://localhost:9001`，默认 bucket 已创建
- [ ] MailHog 可访问 `http://localhost:8025`
- [ ] `doc/operations/LocalDevSetup.md` 完成
- [ ] 后端 Lead 按文档验证通过

---

## T0-6 CI/CD 流水线基础版（Lead）

**时间：** 03-20 ~ 03-21（2 天）

### 协作方
- 后端 Lead、Web 前端：确认构建和测试命令

### 工作内容

#### GitHub Actions 流水线

`.github/workflows/ci.yml`：

```yaml
# 触发条件
on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [develop, main]

# 步骤
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - Checkout 代码
      - Setup Node.js 20.x + pnpm (with cache)
      - pnpm install
      - pnpm lint          # ESLint
      - pnpm typecheck     # TypeScript 类型检查
      - pnpm test          # 单元测试
      - pnpm build         # 构建检查
```

#### PR 规则配置

GitHub 仓库设置：
- `develop` 和 `main` 分支保护：CI 通过 + 至少 1 人 approve
- PR 标题格式推荐 Conventional Commits：`feat:` / `fix:` / `chore:` / `docs:`

### 条件约束
- Phase 0 只做 CI（代码检查 + 测试 + 构建）
- CD（自动部署）Phase 1 再实现
- CI 运行时间控制在 **5 分钟以内**

### 注意事项
- 使用 Turborepo 缓存加速 CI
- pnpm store 做 GitHub Actions 缓存
- 暂不需要 Docker 镜像构建

### 验收要求
- [ ] PR 创建后自动触发 CI
- [ ] lint + typecheck + test + build 全部 pass
- [ ] CI 失败时 PR 不可合并
- [ ] 1 人 approve 规则生效
- [ ] CI 运行时间 < 5 分钟

---

## T0-2 架构设计 ADR（Review）

**时间：** 03-17 ~ 03-18

### 你需要做的
Review 后端 Lead 的 ADR 文档中与部署/基础设施相关的决策：
- ADR-009（云厂商抽象层）：确认 MinIO/S3/OSS 切换方案可行
- ADR-005（视频转码方案）：确认 FFmpeg Worker 的容器化方案
- 确认 ADR 中对开发/测试/生产环境的分层描述

---

## 你的时间线

```
03-10 Mon  ──  （推荐旁听 PRD 评审会）
03-11 Tue  ──  （准备工作）
03-12 Wed  ──  T0-4 启动：创建仓库、配置 pnpm + Turborepo
03-13 Thu  ──  T0-4：NestJS + Next.js 骨架搭建、ESLint/Prettier/husky
03-14 Fri  ──  T0-4 完成 ✅ 提交 PR，后端/前端 Review
03-17 Mon  ──  T0-5 启动：编写 docker-compose.yml + 初始化脚本
03-18 Tue  ──  T0-5：环境变量文档 + 开发者文档 │ T0-2 Review ADR
03-19 Wed  ──  T0-5 完成 ✅ 后端 Lead 验证通过
03-20 Thu  ──  T0-6 启动：GitHub Actions CI 配置
03-21 Fri  ──  T0-6 完成 ✅ │ M0 里程碑评审会（你负责仓库&环境&CI 演示，15:20-15:40 时段）
```
