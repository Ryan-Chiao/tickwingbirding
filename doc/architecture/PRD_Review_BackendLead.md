# PRD v2.2 评审意见 — 后端 Lead

**评审人：** 后端 Lead
**评审日期：** 2026-03-10
**PM 回复日期：** 2026-03-09
**评审范围：** PRD v2.2 第 8 章（技术方案）、第 9 章（数据模型）、第 10 章（API 规范）
**状态：** ✅ 已关闭（所有问题均已处理，PRD 已更新至 v2.3，ADR 已同步）

---

## 一、总体结论

PRD v2.2 技术方案整体合理，可支撑后端实现。技术栈选择认同（NestJS + PostgreSQL + Redis + BullMQ）。
以下列出需要讨论或修改的具体问题，按优先级分类。

---

## 二、数据模型（第 9 章）问题清单

### 🔴 P0 — 必须修改，影响核心功能

#### DM-01：缺少 `refresh_tokens` 表

**问题：** PRD DDL 中未定义 Refresh Token 的存储表。ADR-003 需要决策 Refresh Token 存储位置（Redis 或 DB），无论哪种方案，当前 DDL 均不完整。

**建议方案（供 PM 确认）：**
```sql
CREATE TABLE refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  token_hash  VARCHAR(255) UNIQUE NOT NULL,  -- 存 hash，不存明文
  device_info TEXT,                           -- User-Agent 等
  expires_at  TIMESTAMPTZ NOT NULL,
  revoked_at  TIMESTAMPTZ,                    -- 吊销时间
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token_hash);
```

如果选择纯 Redis 存储，则此表可省略，但需在 ADR-003 中明确记录。

---

#### DM-02：`feeders.bind_code` 无过期时间字段

**问题：** 绑定码（`bind_code`）应有时效性（如 15 分钟），当前表结构无 `bind_code_expires_at` 字段，存在安全风险——旧绑定码永久有效。

**建议：**
```sql
-- 在 feeders 表新增
bind_code_expires_at  TIMESTAMPTZ,
```

---

### 🟡 P1 — 建议修改，影响稳定性或性能

#### DM-03：用户统计计数字段并发风险

**问题：** `users` 表的 `follower_count`、`following_count`、`video_count` 为冗余计数字段，直接 `UPDATE users SET follower_count = follower_count + 1` 在高并发下存在竞争条件，且与实际关系表数据可能不一致。

**建议：** 这是常见设计权衡，建议在 ADR 中明确更新策略：
- 方案 A：数据库层使用行级锁 + 事务（简单但锁粒度大）
- 方案 B：Redis 原子计数 + 异步同步到 DB（推荐，与 BullMQ 方案一致）
- 方案 C：查询时实时 COUNT（无冗余风险，但性能差，不推荐）

**推荐 方案 B**，在 ADR-001 或 ADR-003 中记录。

---

#### DM-04：`bird_tags` 鸟种名称无规范化

**问题：** `bird_tags.bird_name` 为自由文本，同一鸟种可能被标注为"白鹭"、"大白鹭"、"中白鹭"等，导致搜索和统计困难。

**建议：** Phase 0 阶段可接受自由文本，但建议 Phase 3（社区功能）前引入 `bird_species`（鸟种字典表），`bird_tags` 通过外键关联：
```sql
-- 未来引入，Phase 0 不强制
CREATE TABLE bird_species (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  common_name     VARCHAR(100) UNIQUE NOT NULL,  -- 常用名
  scientific_name VARCHAR(150),
  family          VARCHAR(100),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
```
此项为 **Phase 3 前决策**，Phase 0 暂不修改 DDL。

---

#### DM-05：`notifications` 表缺少生命周期策略

**问题：** 通知表无归档/清理机制，长期运行后数据量膨胀，影响查询性能。

**建议：** 新增 `archived_at` 字段，由 BullMQ 定时 Worker 执行归档（90 天后）：
```sql
-- 在 notifications 表新增
archived_at  TIMESTAMPTZ,
```
同时建议补充索引：
```sql
CREATE INDEX idx_notifications_cleanup ON notifications(created_at)
  WHERE archived_at IS NULL;
```

---

#### DM-06：`videos` 表缺少 `recorded_at` 索引

**问题：** 观鸟社区的核心使用场景之一是"某时间段内的观测记录"，`recorded_at` 字段无索引，时间范围查询性能差。

**建议：**
```sql
CREATE INDEX idx_videos_recorded ON videos(recorded_at DESC)
  WHERE status = 'ready';
```

---

### 🟢 P2 — 信息确认，不影响开发启动

#### DM-07：公有喂鸟器视频的 `uploader_id` 处理

**问题：** 设备自动上传的视频，`uploader_id` 应指向谁？

**PM 已决策（memory 记录）：** 使用系统账号 `system_feeder`，需在数据初始化时 seed 此账号，并在开发文档中明确。

---

## 三、API 规范（第 10 章）问题清单

### 🟡 P1 — 建议补充

#### API-01：上传完成回调缺少安全验证机制

**问题：** `POST /api/v1/videos/upload/complete` 接口在客户端直传 S3 后调用，当前规范未说明如何验证"文件确实已上传到 S3"，存在伪造回调风险。

**建议：** 在 ADR-004 中明确验证机制（如验证 S3 ETag、或使用 S3 Event Notification 服务端回调）。

---

#### API-02：设备端 API 缺少限流规范

**问题：** `POST /api/v1/device/upload` 和 `POST /api/v1/device/heartbeat` 使用 API Key 认证，但未说明限流策略，单设备可能刷接口。

**建议：** 在 ADR-006 中补充设备端限流规则（如心跳最多 1次/分钟，上传最多 10次/小时）。

---

#### API-03：`GET /api/v1/videos` Feed 接口需明确排序和过滤规范

**问题：** 视频 Feed 接口当前规范中无排序字段说明（时间排序？热度排序？），游标分页的 cursor 字段格式也未定义。

**建议：** 在 ADR-006 API Schema 草案中补充查询参数规范：
```
GET /api/v1/videos?cursor=<opaque_token>&limit=20&sort=latest|popular&bird=<name>&feeder_id=<id>
```

---

### 🟢 P2 — 确认

#### API-04：`PUT /api/v1/notifications/read` 语义

HTTP 语义上 `PUT` 用于替换，批量标记已读建议改为 `PATCH /api/v1/notifications/read` 更准确，或 `POST /api/v1/notifications/mark-read`。

---

## 四、技术栈立场（第 8 章）

| 技术点 | PRD 建议 | 后端 Lead 立场 |
|--------|---------|---------------|
| 后端框架 | NestJS | ✅ 认同 |
| ORM | TypeORM 或 Prisma（待定） | **倾向 Prisma**，理由见 ADR-002 |
| 队列 | BullMQ | ✅ 认同 |
| 认证 | JWT + Argon2 | ✅ 认同，Argon2id 优先于 bcrypt |
| 全文搜索 | PostgreSQL FTS → OpenSearch | ✅ 认同分阶段升级策略 |
| Monorepo 工具 | Turborepo（推荐）或 Nx | **选 Turborepo**，轻量适合当前团队规模 |

---

## 五、工作量评估

| Phase           | PRD 工期 | 后端 Lead 评估   | 备注                                   |
| --------------- | ------ | ------------ | ------------------------------------ |
| Phase 1（账户系统）   | 4 周    | ✅ 合理         | Auth + User 模块相对独立                   |
| Phase 2（视频 MVP） | 4 周    | ⚠️ 偏紧        | 视频上传 + 转码 + HLS 联调复杂，建议预留 1 周 buffer |
| Phase 3（社区）     | 4 周    | ✅ 合理         | 评论/点赞/关注均为标准实现                       |
| Phase 4（管理后台）   | 3 周    | ✅ 合理         | 以 CRUD + 状态流转为主                      |
| Phase 5（喂鸟器接入）  | 4 周    | ⚠️ 取决于固件 SDK | OQ-6 未决策，风险项                         |
| Phase 6（全端发布）   | 6 周    | ✅ 合理         | 含性能优化和移动端联调                          |

**关注点：** Phase 2 视频处理链路（上传 → 转码 → HLS → CDN）是最高技术风险点，建议 Phase 0 Spike 结论作为 Phase 2 排期依据。

---

## 六、需 PM 决策的问题（✅ 全部已决策）

| # | 问题 | 决策结果 | 生效版本 |
|---|------|---------|---------|
| Q-BE-01 | Refresh Token 存储 | ✅ **DB 表**（多设备管理 + 审计需求） | v2.3 |
| Q-BE-02 | `bind_code` 有效期 | ✅ **15 分钟** | v2.3 |
| Q-BE-03 | Phase 2 buffer | ✅ **接受，4 周 → 5 周**，M2 顺延至 05-22 | v2.3 |
| Q-BE-04 | 通知归档策略 | ✅ **90 天**，`archived_at` 已加入 DDL | v2.3 |

---

## 七、后续跟进（已在 ADR.md 中落实）

| 事项 | ADR | 状态 |
|------|-----|------|
| Refresh Token 改用 DB 表 | ADR-003 | ✅ 已更新 |
| 上传回调安全验证（HeadObject + Event Notification 双保险） | ADR-004 | ✅ 已更新 |
| 设备端限流规则 + Feed 查询参数 | ADR-006 | ✅ 已包含（初版已涵盖） |
| 计数字段并发更新策略（Redis 方案 B） | ADR-010 | ✅ 新增 |
