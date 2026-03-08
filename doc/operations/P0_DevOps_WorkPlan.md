# Phase 0 DevOps 工作计划

**项目：** Tickwing — 观鸟者社区平台
**角色：** DevOps / SRE
**周期：** 2026-03-10 ~ 2026-03-21
**文档归档：** `doc/operations/`
**状态：** 待批准

---

## 任务总览

| 任务 ID | 任务名称 | 角色 | 截止日 | 状态 |
|---------|---------|------|--------|------|
| T0-4 | Monorepo 仓库初始化 | Lead | 03-17 | 待执行 |
| T0-5 | 本地开发环境搭建 | Lead | 03-19 | 待执行 |
| T0-6 | CI/CD 流水线基础版 | Lead | 03-21 | 待执行 |
| T0-2 | 架构 ADR Review | Review | 03-18 | 待执行 |

---

## T0-4 Monorepo 仓库初始化

**截止：** 03-17（与 T0-5 衔接）

### T0-4-1 创建 Monorepo 目录骨架

按如下结构创建目录（含占位文件）：

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
│   │   │   ├── common/
│   │   │   ├── config/
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
│   └── mobile/               # React Native（Phase 6 填充）
│       └── .gitkeep
├── packages/
│   ├── shared-types/         # 前后端共享 TypeScript 类型
│   ├── eslint-config/        # 统一 ESLint 配置
│   └── tsconfig/             # 统一 TypeScript 配置
├── docker/
│   ├── docker-compose.yml
│   ├── docker-compose.prod.yml
│   ├── init-scripts/
│   └── Dockerfile.*
├── .github/
│   ├── workflows/
│   └── pull_request_template.md
├── doc/                      # 项目文档（现有内容）
├── turbo.json
├── pnpm-workspace.yaml
├── package.json
├── .gitignore
├── .nvmrc
├── .env.example
└── README.md
```

### T0-4-2 配置 Monorepo 工具链

| 文件 | 内容 |
|------|------|
| `pnpm-workspace.yaml` | 声明 `apps/*` 和 `packages/*` 为 workspace |
| `turbo.json` | 配置 `build / lint / typecheck / test` pipeline |
| `.nvmrc` | `20` |
| 根 `package.json` | `engines: { node: ">=20", pnpm: ">=8" }` + workspace 脚本 |

### T0-4-3 初始化 NestJS 骨架（`apps/api/`）

- 使用 `@nestjs/cli` 初始化项目
- 创建 `modules/` 下各模块占位目录（auth / user / video / feeder / community / notification / admin）
- TypeScript 严格模式（`strict: true`）
- 继承 `packages/tsconfig/` base 配置

### T0-4-4 初始化 Next.js 骨架（`apps/web/`）

- 使用 `create-next-app` 初始化，App Router 模式
- 创建 `components/ hooks/ store/ api/ i18n/ utils/` 占位目录
- `i18n/zh-CN.json` 初始化为空对象 `{}`
- TypeScript 严格模式，继承 `packages/tsconfig/` base 配置

### T0-4-5 统一代码规范配置

| 配置项 | 说明 |
|--------|------|
| `packages/eslint-config/` | `@typescript-eslint/recommended` 规则，供 api 和 web 共用 |
| `packages/tsconfig/` | `base.json`（strict: true）+ `nextjs.json` / `nestjs.json` extends |
| Prettier | 2 空格、单引号、trailing comma all、printWidth 120 |
| husky | pre-commit hook |
| lint-staged | staged `.ts/.tsx` 文件执行 `eslint --fix` + `prettier --write` |

### T0-4-6 基础文件

| 文件 | 内容说明 |
|------|---------|
| `.gitignore` | `node_modules` `.env` `.env.*` `dist` `.turbo` `uploads` `*.log` `.DS_Store` |
| `.env.example` | 所有环境变量分组注释，变量名使用 `tickwing` 前缀，**不含真实密钥** |
| `README.md` | 项目简介 + 快速启动（6 行命令）+ 技术栈 + 文档链接 |
| `.github/pull_request_template.md` | PR 模板：变更描述 / 测试说明 / checklist |

### T0-4-7 Git 分支策略

创建并推送初始分支结构，在 `doc/operations/` 归档分支规范说明：

| 分支 | 用途 | 规则 |
|------|------|------|
| `main` | 生产分支 | 仅通过 PR 合并；CI 通过 + 1 人 approve（T0-6 配置保护规则） |
| `develop` | 开发主干 | 日常开发基于此分支；CI 通过 + 1 人 approve |
| `feature/*` | 功能分支 | 从 `develop` 切出，完成后 PR → `develop` |
| `hotfix/*` | 紧急修复 | 从 `main` 切出，完成后 PR → `main` 并同步 `develop` |

PR 标题格式遵循 Conventional Commits：`feat:` / `fix:` / `chore:` / `docs:` / `refactor:`

> 注：分支保护规则（require CI pass + 1 approve）在 **T0-6** CI 配置完成后在 GitHub 仓库设置中启用。

### T0-4-8 初始化 `packages/shared-types/`

创建以下文件，供后续 Phase 1 后端与前端共用类型定义：

```
packages/shared-types/
├── package.json          # name: "@tickwing/shared-types"
├── tsconfig.json         # extends ../../packages/tsconfig/base.json
└── src/
    ├── index.ts          # 统一导出入口（空，Phase 1 填充）
    ├── user.ts           # User 相关 interface 占位
    ├── video.ts          # Video 相关 interface 占位
    └── feeder.ts         # Feeder 相关 interface 占位
```

占位 interface 示例（`src/user.ts`）：
```typescript
// TODO: Phase 1 填充完整定义
export interface UserBase {
  id: string;
  username: string;
  email: string;
  createdAt: string;
}
```

`package.json` 关键字段：
```json
{
  "name": "@tickwing/shared-types",
  "version": "0.0.1",
  "main": "./src/index.ts",
  "exports": { ".": "./src/index.ts" }
}
```

**验收要求：**
- [ ] `pnpm install` 成功
- [ ] `apps/api`: `pnpm dev` 启动返回 Hello World
- [ ] `apps/web`: `pnpm dev` 启动显示 Next.js 默认页面
- [ ] `pnpm lint` 和 `pnpm typecheck` 通过
- [ ] `.env.example` 分组注释完整，无真实密钥
- [ ] `README.md` 含快速启动步骤
- [ ] `develop` 分支已推送到远端
- [ ] `packages/shared-types/` 含 `package.json` + 占位 `src/index.ts`

---

## T0-5 本地开发环境搭建

**截止：** 03-19

### T0-5-1 编写 `docker/docker-compose.yml`

| 服务 | 镜像 | 端口 | 用途 |
|------|------|------|------|
| postgres | `postgres:16-alpine` | 5432:5432 | 主数据库 |
| redis | `redis:7-alpine` | 6379:6379 | 缓存 + BullMQ |
| minio | `minio/minio` | 9000:9000, 9001:9001 | 本地对象存储 |
| mailhog | `mailhog/mailhog` | 1025:1025, 8025:8025 | 本地邮件测试 |

- 全部服务使用 **named volume**（前缀 `tickwing_`），不挂载到项目目录
- 提供 `docker-compose.prod.yml` 占位文件（Phase 1 填充）

### T0-5-2 编写初始化脚本

| 文件 | 内容 |
|------|------|
| `docker/init-scripts/init-db.sql` | 创建数据库 `tickwing_dev`，设置时区 UTC |
| `docker/init-scripts/init-minio.sh` | 创建 bucket：`tickwing-videos` / `tickwing-avatars` / `tickwing-thumbnails` |

### T0-5-3 `.env.example` 完整内容

```bash
# ===== Database =====
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=tickwing_dev
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
STORAGE_BUCKET_VIDEOS=tickwing-videos
STORAGE_BUCKET_AVATARS=tickwing-avatars
STORAGE_BUCKET_THUMBNAILS=tickwing-thumbnails
STORAGE_REGION=us-east-1

# ===== Mail (MailHog for local) =====
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_FROM=noreply@tickwing.dev

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

### T0-5-4 撰写开发者文档 `doc/operations/LocalDevSetup.md`

内容结构：
1. 前置条件（Docker Desktop / Node.js 20.x / pnpm）
2. 一键启动步骤（6 行命令）
3. 各服务访问地址与默认凭证
4. 常见问题排查（端口冲突 / Docker 内存不足 / Windows WSL2 注意事项）

**验收要求：**
- [ ] `docker compose up -d` 全部服务启动成功
- [ ] PostgreSQL 可连接，数据库 `tickwing_dev` 已创建
- [ ] Redis 可连接
- [ ] MinIO Console `http://localhost:9001` 可访问，三个 bucket 已创建
- [ ] MailHog `http://localhost:8025` 可访问
- [ ] `doc/operations/LocalDevSetup.md` 完成

---

## T0-6 CI/CD 流水线基础版

**截止：** 03-21

### T0-6-1 编写 `.github/workflows/ci.yml`

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
      - Setup Node.js 20.x
      - Setup pnpm（含 store 缓存）
      - pnpm install（含 Turborepo 缓存）
      - pnpm lint
      - pnpm typecheck
      - pnpm test
      - pnpm build
```

约束：
- Phase 0 **仅做 CI**，不含 CD（自动部署 Phase 1 实现）
- CI 运行时间目标 **< 5 分钟**
- 使用 Turborepo 远程缓存 + pnpm store GitHub Actions 缓存

### T0-6-2 配置 GitHub 分支保护规则

在 GitHub 仓库 Settings → Branches 中为 `main` 和 `develop` 分别配置：

| 规则项 | 设置值 |
|--------|--------|
| Require status checks to pass | ✅ 勾选 `ci` job |
| Require branches to be up to date | ✅ 勾选 |
| Require pull request reviews | ✅ 至少 1 人 approve |
| Dismiss stale reviews on new commits | ✅ 勾选 |
| Do not allow bypassing the above settings | ✅ 勾选（管理员也受约束） |

**验收要求：**
- [ ] PR 创建后自动触发 CI
- [ ] lint + typecheck + test + build 全部 pass
- [ ] CI 失败时 PR 不可合并（`main` 和 `develop` 均受保护）
- [ ] 未经 1 人 approve 时 PR 不可合并
- [ ] CI 运行时间 < 5 分钟

---

## T0-2 架构 ADR Review（Review 角色）

**截止：** 03-18

### T0-2-1 Review 内容

Review `doc/architecture/ADR.md` 中部署基础设施相关决策：

| ADR | 关注点 |
|-----|--------|
| ADR-009（云厂商抽象层） | MinIO/S3/OSS 切换方案是否可落地；抽象层接口是否足够 |
| ADR-005（视频转码方案） | FFmpeg Worker 容器化方案是否合理；资源限制建议 |
| 环境分层 | dev / staging / prod 分层描述是否清晰 |

产出：`doc/operations/ADR_Review_DevOps.md`

---

## 执行时间线

```
03-10 Mon  ── 准备工作，熟悉 PRD 和 ADR
03-12 Wed  ── T0-4 启动：创建仓库骨架，配置 pnpm + Turborepo
03-13 Thu  ── T0-4：NestJS + Next.js 骨架、ESLint/Prettier/husky
03-14 Fri  ── T0-4 完成 ✅ 提交 PR，后端/前端 Review
03-17 Mon  ── T0-5 启动：docker-compose.yml + 初始化脚本
03-18 Tue  ── T0-5：环境变量 + 开发者文档 ｜ T0-2 Review ADR
03-19 Wed  ── T0-5 完成 ✅ 后端 Lead 验证通过
03-20 Thu  ── T0-6 启动：GitHub Actions CI 配置
03-21 Fri  ── T0-6 完成 ✅ ｜ M0 里程碑评审演示（仓库 & 环境 & CI）
```

---

## 产出物清单

| 产出物 | 路径 | 对应任务 |
|--------|------|---------|
| Monorepo 骨架 | 仓库根目录 | T0-4 |
| shared-types 包占位 | `packages/shared-types/` | T0-4-8 |
| Docker Compose | `docker/docker-compose.yml` | T0-5 |
| DB 初始化脚本 | `docker/init-scripts/init-db.sql` | T0-5 |
| MinIO 初始化脚本 | `docker/init-scripts/init-minio.sh` | T0-5 |
| 本地开发者文档 | `doc/operations/LocalDevSetup.md` | T0-5 |
| CI 流水线 | `.github/workflows/ci.yml` | T0-6-1 |
| GitHub 分支保护规则 | GitHub 仓库设置（无文件产出） | T0-6-2 |
| ADR Review 意见 | `doc/operations/ADR_Review_DevOps.md` | T0-2 |

---

*文档状态：待 Review → 批准后开始执行*
