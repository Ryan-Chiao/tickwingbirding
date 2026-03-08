# ADR Review — DevOps / SRE 视角

**Review 人：** DevOps / SRE
**Review 日期：** 2026-03-18
**ADR 文档版本：** v1.0（后端 Lead 初稿，2026-03-12）
**Review 范围：** 部署架构、基础设施、环境分层相关 ADR

---

## 总体结论

| ADR | 结论 | 优先级备注 |
|-----|------|---------|
| ADR-005（FFmpeg Worker 容器化）| ✅ **确认可落地**，补充 3 条运维建议 | Phase 2 前需完成 |
| ADR-009（云厂商抽象层）| ✅ **确认可落地**，MinIO↔S3 兼容性验证通过，补充 2 条建议 | Phase 1 前完成接口验证 |
| 环境分层描述 | ⚠️ **需补充**，ADR 文档中未见明确的 dev/staging/prod 分层说明，建议补充或独立文档化 | M1 前 |

---

## ADR-009 云厂商抽象层 Review

### ✅ 确认可落地的部分

1. **MinIO ↔ AWS S3 SDK 兼容性**：`@aws-sdk/client-s3` 通过 `endpoint` + `forcePathStyle: true` 连接 MinIO 已在本地环境验证（T0-5 docker-compose.yml 中 MinIO 已配置）。同一套 `S3StorageAdapter` 代码本地和生产可复用，无需分支逻辑。

2. **`IStorageService` 接口设计合理**：`getPresignedUploadUrl`、`headObject`、`deleteObject` 等方法粒度适中，可满足 Phase 1~3 的业务需求。

3. **环境变量配置方案**：`STORAGE_PROVIDER` 驱动切换，与已有 `.env.example` 格式一致，运维可直接修改环境变量切换云厂商，无需重新构建镜像。

### ⚠️ 补充建议

**建议 ADR-009-A：明确 OSS Adapter 的测试时机**

ADR 提到"OSS Adapter 需在 Phase 2 前完成集成测试"，建议在 Phase 1 结束时（M1 milestone）明确验收标准：
- S3 Adapter 与 OSS Adapter 跑同一套集成测试套件（MinIO 作为测试环境）
- 测试覆盖：presigned URL 生成、HeadObject 验证、DeleteObject

**建议 ADR-009-B：`.env.example` 中 MinIO 相关变量名与 ADR 存在差异**

当前 `.env.example`（T0-5 产出）使用：
```
STORAGE_ACCESS_KEY=minioadmin
STORAGE_SECRET_KEY=minioadmin
STORAGE_BUCKET_VIDEOS=tickwing-videos
```

ADR-009 示例中使用：
```
STORAGE_S3_ACCESS_KEY_ID=minioadmin
STORAGE_S3_BUCKET=birdwatch
```

**建议对齐**：以 ADR-009 的变量命名为准（更具描述性，区分 S3 / OSS），在 Phase 1 启动前统一更新 `.env.example`。此项需后端 Lead 确认后执行。

---

## ADR-005 FFmpeg Worker 容器化 Review

### ✅ 确认可落地的部分

1. **独立容器部署模型**：Worker 与 API 独立容器，隔离 CPU 密集型负载，符合最佳实践。本地 `docker-compose.yml` 中已预留扩展位置，Phase 2 可直接添加 `worker` service。

2. **BullMQ 队列配置（重试 + 退避）**：3 次重试 + 指数退避 30s 的配置合理，避免转码服务临时故障导致大量任务堆积重试。

3. **Worker 故障恢复**：BullMQ 在 Worker 异常退出时自动将 active 任务重新置为 waiting，本地 Docker Restart Policy（`unless-stopped`）也会自动重启 Worker 容器。

### ⚠️ 补充建议

**建议 ADR-005-A：Worker Dockerfile 基础镜像选型**

ADR 提到使用 `jrottenberg/ffmpeg` 或 `node:20-bullseye + apt`，DevOps 建议：

| 选项 | 优点 | 缺点 |
|------|------|------|
| `jrottenberg/ffmpeg` | FFmpeg 预装、镜像小 | 不含 Node.js，需额外安装 |
| `node:20-bullseye` + apt | Node.js 版本可控 | apt 安装 FFmpeg 较慢，镜像较大 |
| **推荐：`node:20-bookworm-slim` + FFmpeg 静态二进制** | 可控版本 + 小镜像 | 需手动管理 FFmpeg 版本 |

建议 Phase 2 前由后端 Lead 和 DevOps 共同确认 Dockerfile 方案，并在 `docker/Dockerfile.worker` 中落地。

**建议 ADR-005-B：Worker 资源限制（生产部署用）**

建议在 `docker-compose.prod.yml` 中为 Worker 容器设置资源限制，防止单个转码任务耗尽宿主机资源：

```yaml
worker:
  deploy:
    resources:
      limits:
        cpus: '2.0'
        memory: 4G
      reservations:
        cpus: '0.5'
        memory: 1G
```

此建议适用于生产部署，Phase 0 的 `docker-compose.prod.yml` 占位时可预留注释。

**建议 ADR-005-C：本地开发环境暂不启动 Worker**

Phase 1 开发阶段，开发者本地无需运行转码 Worker（视频上传后 status 停留在 `queued` 状态即可，不影响 API 功能开发）。建议在 `LocalDevSetup.md` 中注明此点，避免开发者为本地运行 Worker 花费不必要时间。

---

## 环境分层说明 — 需补充

当前 ADR 文档（v1.0）中未见明确的开发/测试/生产环境分层定义。DevOps 建议在 ADR 文档中或独立文档 `doc/operations/EnvironmentSpec.md` 中补充以下内容：

| 环境 | 用途 | 基础设施 | 部署方式 |
|------|------|---------|---------|
| local（本地开发） | 开发者本机 | Docker Compose（MinIO + PG + Redis + MailHog） | 手动 `docker compose up` |
| staging（Stage 环境） | 集成测试 / QA 验收 | 云环境（M1 前定义） | GitHub Actions CD（Phase 1 实现） |
| production | 对外服务 | AWS + 阿里云 | GitHub Actions CD（Phase 1 实现） |

**建议行动项：**
- [ ] 后端 Lead 在 ADR.md 中补充"附录 C：环境分层与部署架构"，或授权 DevOps 单独起草 `doc/operations/EnvironmentSpec.md`
- [ ] M1 之前确认 Staging 环境的云资源账号和权限

---

## 其他观察

### ADR-002 Prisma Migrate 与 CD 集成

ADR-002 提到"生产阶段通过 CI/CD 在容器启动前自动执行 `prisma migrate deploy`"。DevOps 确认此方案可行，Phase 1 的 CD 流水线（T0-6 的延伸）需要包含：

```bash
# 部署脚本（伪代码）
docker pull <image>
docker run --env-file .env <image> npx prisma migrate deploy  # 先迁移
docker run -d <image>                                           # 再启动
```

### ADR-003 RS256 密钥对管理

ADR-003 提到 Access Token 使用 RS256（非对称密钥），私钥/公钥需通过环境变量注入。DevOps 建议：
- Phase 1 前，将密钥管理方案在 `.env.example` 中补充占位变量（`JWT_PRIVATE_KEY`、`JWT_PUBLIC_KEY`）
- 生产环境使用 AWS Secrets Manager 或阿里云 KMS 管理，Phase 4 前定义

---

## Review 结论

| 项目 | 状态 |
|------|------|
| ADR-009 MinIO/S3/OSS 切换方案 | ✅ 可落地，变量名需在 Phase 1 前对齐 |
| ADR-005 FFmpeg Worker 容器化 | ✅ 可落地，Dockerfile 基础镜像 Phase 2 前确认 |
| 环境分层描述 | ⚠️ 需后端 Lead 补充 ADR 或由 DevOps 起草独立文档 |
| ADR-002 Prisma migrate 与 CD 集成 | ✅ Phase 1 CD 流水线可支持 |
| ADR-003 RS256 密钥管理 | ⚠️ Phase 1 前补充 .env.example 占位变量 |

**整体评估：** ADR 设计质量良好，部署/基础设施相关决策合理，无 Blocker 问题。标注的 ⚠️ 项均为建议性改进，不影响 Phase 0 验收。

---

*DevOps / SRE Review 完成 | 2026-03-18*
