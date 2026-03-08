# Tickwing 🐦

**观鸟者社区平台** — 记录、分享、探索鸟类世界

## 技术栈

| 层       | 技术                      |
| ------- | ----------------------- |
| 后端 API  | NestJS + TypeScript     |
| Web 前端  | Next.js 14 (App Router) |
| 移动端     | React Native (Phase 6)  |
| 数据库     | PostgreSQL 16           |
| 缓存 / 队列 | Redis 7 + BullMQ        |
| 对象存储    | MinIO (本地) /云厂商策略（待定）   |
| 包管理     | pnpm (Monorepo)         |
| 构建编排    | Turborepo               |

## 快速启动

### 前置条件

- [Node.js 20.x](https://nodejs.org/)
- [pnpm 8+](https://pnpm.io/installation)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### 启动步骤

```bash
# 1. 克隆仓库
git clone https://github.com/your-org/tickwingbirding.git && cd tickwingbirding

# 2. 复制环境变量
cp .env.example .env

# 3. 启动基础服务（PostgreSQL / Redis / MinIO / MailHog）
docker compose -f docker/docker-compose.yml up -d

# 4. 安装依赖
pnpm install

# 5. 启动后端 API（http://localhost:3000）
pnpm --filter @tickwing/api dev

# 6. 启动 Web 前端（http://localhost:3001）
pnpm --filter @tickwing/web dev
```

### 服务地址

| 服务 | 地址 | 说明 |
|------|------|------|
| API | http://localhost:3000 | NestJS 后端 |
| Web | http://localhost:3001 | Next.js 前端 |
| MinIO Console | http://localhost:9001 | 对象存储管理 |
| MailHog | http://localhost:8025 | 本地邮件测试 |
| PostgreSQL | localhost:5432 | 数据库 |
| Redis | localhost:6379 | 缓存 |

## 常用命令

```bash
pnpm lint          # 代码检查
pnpm typecheck     # TypeScript 类型检查
pnpm test          # 运行测试
pnpm build         # 全量构建
```

## 文档

- [本地开发环境搭建](doc/operations/LocalDevSetup.md)
- [架构决策记录 (ADR)](doc/architecture/ADR.md)
- [产品需求文档 (PRD)](doc/product/Tickwing_PRD_v2.3.md)
- [API 文档](doc/api/)

## 分支策略

| 分支 | 用途 |
|------|------|
| `main` | 生产分支，仅 PR 合并 |
| `develop` | 开发主干 |
| `feature/*` | 功能分支，从 develop 切出 |
| `hotfix/*` | 紧急修复，从 main 切出 |
