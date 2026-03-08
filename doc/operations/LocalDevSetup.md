# 本地开发环境搭建指南

**项目：** Tickwing — 观鸟者社区平台
**维护：** DevOps / SRE
**适用人群：** 所有开发人员

---

## 前置条件

在开始之前，请确保已安装以下工具：

| 工具 | 版本要求 | 安装链接 |
|------|---------|---------|
| Docker Desktop | 4.x+ | https://www.docker.com/products/docker-desktop/ |
| Node.js | 20.x (LTS) | https://nodejs.org/ 或使用 nvm |
| pnpm | 8.x+ | `npm install -g pnpm` |
| Git | 2.x+ | https://git-scm.com/ |

> **Windows 用户注意：** Docker Desktop 需要启用 WSL2 后端。请参考[官方文档](https://docs.docker.com/desktop/wsl/)完成 WSL2 配置。

---

## 一键启动（6 步）

```bash
# 1. 克隆仓库
git clone https://github.com/your-org/tickwingbirding.git
cd tickwingbirding

# 2. 切换到正确的 Node.js 版本
nvm use   # 或手动确认 node -v 为 20.x

# 3. 复制环境变量文件
cp .env.example .env

# 4. 启动基础设施服务
docker compose -f docker/docker-compose.yml up -d

# 5. 安装所有依赖
pnpm install

# 6. 启动开发服务
pnpm --filter @tickwing/api dev   # 后端 API
pnpm --filter @tickwing/web dev   # Web 前端（新终端窗口）
```

---

## 服务访问地址 & 默认凭证

| 服务 | 地址 | 用户名 | 密码 |
|------|------|--------|------|
| API 后端 | http://localhost:3000 | — | — |
| Web 前端 | http://localhost:3001 | — | — |
| MinIO Console | http://localhost:9001 | `minioadmin` | `minioadmin` |
| MailHog Web UI | http://localhost:8025 | — | — |
| PostgreSQL | localhost:5432 | `postgres` | （见 .env） |
| Redis | localhost:6379 | — | — |

---

## 环境变量说明

`.env.example` 已包含所有变量的分组注释。复制为 `.env` 后按需修改：

- **DATABASE_PASSWORD**：本地随意设置，建议与 `.env.example` 保持一致（`your_password_here` 仅为占位）
- **JWT_ACCESS_SECRET / JWT_REFRESH_SECRET**：本地可使用任意字符串，生产必须是高强度随机值
- **STORAGE_* 变量**：本地使用 MinIO，无需修改默认值

---

## 常用开发命令

```bash
# 代码检查
pnpm lint

# TypeScript 类型检查
pnpm typecheck

# 运行单元测试
pnpm test

# 全量构建
pnpm build

# 仅启动后端
pnpm --filter @tickwing/api dev

# 仅启动前端
pnpm --filter @tickwing/web dev

# 停止所有 Docker 服务
docker compose -f docker/docker-compose.yml down

# 停止并清除数据（慎用！会删除数据库数据）
docker compose -f docker/docker-compose.yml down -v
```

---

## 常见问题排查

### 问题 1：端口被占用

**现象：** `docker compose up` 报错 `port is already allocated`

**排查：**

```bash
# 查看占用端口的进程（Windows PowerShell）
netstat -ano | findstr :5432

# 查看占用端口的进程（Mac/Linux）
lsof -i :5432
```

**解决：** 停止占用端口的进程，或修改 `docker/docker-compose.yml` 中的端口映射。常见端口冲突：
- 5432：本地已安装 PostgreSQL → 停止本地 PostgreSQL 服务
- 6379：本地已安装 Redis → 停止本地 Redis 服务

---

### 问题 2：Docker Desktop 内存不足

**现象：** 容器反复重启，或 MinIO 启动失败

**解决：** Docker Desktop → Settings → Resources → Memory 设置为至少 **4GB**

---

### 问题 3：MinIO 初始化失败（bucket 未创建）

**现象：** `tickwing-videos` 等 bucket 不存在

**手动创建：**

```bash
# 重新运行初始化容器
docker compose -f docker/docker-compose.yml run --rm minio-init
```

---

### 问题 4：pnpm install 失败（workspace 依赖解析错误）

**现象：** `@tickwing/shared-types` 等 workspace 包找不到

**解决：**

```bash
# 清理缓存后重新安装
pnpm store prune
pnpm install
```

---

### 问题 5：Windows WSL2 相关问题

**现象：** Docker 容器无法启动，或文件权限错误

**检查 WSL2 是否启用：**

```powershell
# PowerShell（管理员）
wsl --status
```

**注意事项：**
- 项目文件请放在 WSL2 文件系统内（如 `~/projects/`），而非 Windows 路径（`/mnt/c/`），否则文件监听（HMR）会失效
- Docker Desktop 需要在 Settings → General 中勾选 "Use WSL 2 based engine"

---

### 问题 6：`pnpm dev` 启动后 API 无法访问

**检查：**

1. 确认 `.env` 中 `APP_PORT=3000`
2. 确认 PostgreSQL 容器运行中：`docker compose -f docker/docker-compose.yml ps`
3. 查看 API 日志：`pnpm --filter @tickwing/api dev` 的终端输出

---

## 数据库连接信息

使用任意 PostgreSQL 客户端（如 TablePlus、DBeaver）连接本地数据库：

| 字段 | 值 |
|------|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `tickwing_dev` |
| User | `postgres` |
| Password | （见 `.env` 中 `DATABASE_PASSWORD`） |

---

*如遇本文档未覆盖的问题，请在仓库 Issue 中提交，或联系 DevOps。*
