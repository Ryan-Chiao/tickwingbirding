# 架构决策记录 (Architecture Decision Records)

**项目：** Tickwing 观鸟者社区平台
**维护者：** 后端 Lead
**创建日期：** 2026-03-12
**最后更新：** 2026-03-09（基于 PM v2.3 回复终稿）
**参考 PRD：** `doc/product/Tickwing_PRD_v2.3.md`

---

## 目录

- [ADR-001 后端框架与模块划分](#adr-001-后端框架与模块划分)
- [ADR-002 数据库与 ORM 选型](#adr-002-数据库与-orm-选型)
- [ADR-003 认证方案](#adr-003-认证方案)
- [ADR-004 文件上传方案](#adr-004-文件上传方案)
- [ADR-005 视频转码方案](#adr-005-视频转码方案)
- [ADR-006 前后端通信规范](#adr-006-前后端通信规范)
- [ADR-007 i18n 国际化方案](#adr-007-i18n-国际化方案)
- [ADR-008 坐标脱敏方案](#adr-008-坐标脱敏方案)
- [ADR-009 云厂商抽象层](#adr-009-云厂商抽象层)
- [ADR-010 计数字段并发更新策略](#adr-010-计数字段并发更新策略)
- [附录 A：Monorepo 目录结构](#附录-a-monorepo-目录结构)
- [附录 B：关键 API Schema 草案](#附录-b-关键-api-schema-草案)

---

## ADR-001 后端框架与模块划分

### 状态

Accepted

### 背景

项目采用 Node.js 生态，需要一个结构化、可维护的后端框架。业务涵盖用户、视频、喂鸟器、社区、通知、管理后台等多个独立领域，模块边界清晰至关重要，否则后期维护成本极高。

### 决策

使用 **NestJS** 作为后端框架，采用**模块化单体（Modular Monolith）**架构，按业务领域划分 7 个顶级模块：

| 模块 | 路径 | 职责 |
|------|------|------|
| `AuthModule` | `modules/auth/` | 注册、登录、Token 管理、密码重置 |
| `UserModule` | `modules/user/` | 用户资料、关注关系、头像上传 |
| `VideoModule` | `modules/video/` | 视频上传、播放、点赞、评论、标注 |
| `FeederModule` | `modules/feeder/` | 设备绑定/解绑、心跳、配置推送 |
| `CommunityModule` | `modules/community/` | 举报 |
| `NotificationModule` | `modules/notification/` | 通知创建、查询、已读标记 |
| `AdminModule` | `modules/admin/` | 用户管理、视频审核、设备管理、统计 |

**模块依赖规则（防止循环依赖）：**

```
允许依赖方向（单向）：
  AdminModule    → UserModule, VideoModule, FeederModule, CommunityModule
  VideoModule    → UserModule, FeederModule, NotificationModule
  CommunityModule → UserModule, VideoModule
  NotificationModule → (无业务模块依赖，仅依赖 infra)
  所有模块       → AuthModule（Guard）, CommonModule, ConfigModule

禁止：
  UserModule ↛ VideoModule（避免循环）
  AuthModule ↛ 任何业务模块
```

**共享层（`common/`）：**

```
common/
├── decorators/       # @CurrentUser, @Roles, @Public
├── guards/           # JwtAuthGuard, RolesGuard, DeviceAuthGuard
├── interceptors/     # LoggingInterceptor, ResponseTransformInterceptor
├── filters/          # GlobalExceptionFilter
├── pipes/            # ValidationPipe 配置
├── dto/              # 通用 DTO（分页、错误响应）
└── utils/            # coord-mask.util, file-size.util 等
```

### 理由

- NestJS 的 DI 容器和装饰器模式天然适配领域模块化，减少样板代码
- 模块化单体在 M6 之前足够，微服务拆分的时机应由实际流量压力驱动，而非提前过度设计
- 备选方案 **Fastify + 纯手写路由** 缺乏约定，团队协作成本高；**Express + 无框架** 同理
- 备选方案 **Hono**：性能优秀但生态和 TS 集成成熟度不如 NestJS

### 后果

- 所有 PR 中不得出现跨模块的直接 `import`（应通过 NestJS 模块导出机制共享）
- Worker（BullMQ）进程独立部署，通过 NestJS 的 `@nestjs/bullmq` 包集成，不单独维护另一套 DI 容器
- Phase 5 喂鸟器设备接入时，`FeederModule` 需扩展 MQTT 支持，可在模块内部新增 `FeederMqttService`，不影响其他模块

---

## ADR-002 数据库与 ORM 选型

### 状态

Accepted

### 背景

项目使用 PostgreSQL 作为主数据库（PRD 已决策）。需要选择 ORM 工具处理 Schema 管理、类型安全查询和迁移。主要候选为 **Prisma** 和 **TypeORM**。

### 决策

选择 **Prisma** 作为 ORM，迁移策略使用 **Prisma Migrate（开发阶段）+ migrate deploy（生产阶段）**。

**Schema 文件位置：** `apps/api/prisma/schema.prisma`

**迁移策略：**

```
开发阶段：
  npx prisma migrate dev --name <描述>   # 自动生成迁移文件并应用
  npx prisma db push                     # 快速原型（不生成迁移文件）

生产阶段：
  npx prisma migrate deploy              # 仅应用已有迁移，不生成新迁移
  # 通过 CI/CD 在容器启动前自动执行
```

**Seed 数据：** `apps/api/prisma/seed.ts`，用于初始化 `system_feeder` 系统账号和基础数据。

### 理由

| 对比维度 | Prisma | TypeORM |
|---------|--------|---------|
| 类型安全 | ✅ 完全自动生成，无需手写类型 | ⚠️ 需手动维护 Entity 类型 |
| 迁移可靠性 | ✅ 声明式 Schema，迁移文件可审查 | ⚠️ `synchronize: true` 生产环境危险 |
| 查询体验 | ✅ 流畅的链式 API，复杂关联查询友好 | ⚠️ 复杂查询需写 QueryBuilder |
| 学习曲线 | ✅ 较低，Schema 语言直观 | ⚠️ 装饰器繁琐，概念较多 |
| NestJS 集成 | ✅ 官方 `@nestjs/prisma` 支持 | ✅ 官方 `@nestjs/typeorm` 支持 |
| Raw SQL | ✅ `$queryRaw` 支持 | ✅ 完整支持 |

TypeORM 的 `synchronize: true` 在生产环境误用的历史事故较多，Prisma 的显式迁移文件更安全。

### 后果

- 所有数据库 Schema 变更必须通过 `prisma migrate dev` 生成迁移文件，**禁止直接修改生产库**
- `PrismaService` 封装为全局 Provider，各模块注入使用
- 复杂聚合查询（如统计）使用 `$queryRaw` 或 `$queryRawUnsafe`（需参数化防注入）
- Prisma Client 在容器启动时自动生成（`postinstall` 脚本）

---

## ADR-003 认证方案

### 状态

Accepted

### 背景

需要实现用户注册/登录认证体系，满足：
- Web 端和移动端通用
- 支持 Token 无感刷新
- 支持登出（Token 失效）
- 密码安全存储

### 决策

**认证体系：JWT（Access Token + Refresh Token）双 Token 方案**

**密码哈希：Argon2id**（优于 bcrypt，抵御 GPU 暴力破解）

```
Access Token：
  - 算法：RS256（非对称，便于后续多服务验证）
  - 过期时间：15 分钟
  - Payload：{ sub: userId, role: 'user'|'moderator'|'admin', jti, iat, exp }

Refresh Token：
  - 格式：opaque token（随机 32 字节，hex 编码，存 SHA-256 hash）
  - 过期时间：30 天
  - 存储：DB 表 refresh_tokens（PM 决策，Q-BE-01）
  - 旋转策略：每次 refresh 请求签发新 Refresh Token，旧 Token 标记 revoked_at
```

**Refresh Token 表结构（PRD v2.3 DDL）：**

```sql
CREATE TABLE refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  token_hash  VARCHAR(255) UNIQUE NOT NULL,  -- SHA-256 hash，不存明文
  device_info TEXT,                           -- User-Agent 等，支持多设备管理
  expires_at  TIMESTAMPTZ NOT NULL,
  revoked_at  TIMESTAMPTZ,                    -- 吊销时间（旋转或登出时设置）
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token_hash);
```

**选择 DB 表而非 Redis 的 PM 决策理由：**
- 需支持多设备管理（用户可查看并吊销特定设备的登录状态）
- 需要吊销审计日志（`revoked_at` 记录）
- Redis 故障时全量用户需重新登录，风险过高

**Token 黑名单（登出实现）：**

```
登出时：
  1. 将 Access Token 的 jti 写入 Redis blacklist（TTL = Access Token 剩余有效期，轻量短期）
  2. 将 refresh_tokens 表对应记录设置 revoked_at = NOW()

请求验证时：
  1. 验证 JWT 签名和过期时间
  2. 检查 jti 是否在 Redis blacklist（O(1)，Access Token 有效期内）
```

**设备端认证（喂鸟器）：** 独立的 API Key + HMAC-SHA256 签名方案，不使用 JWT。

```
Header：
  X-Device-Key: <api_key>
  X-Device-Signature: HMAC-SHA256(api_secret, method+path+timestamp+body_hash)
  X-Timestamp: <unix_timestamp>

验证规则：
  - 时间戳偏差不超过 ±5 分钟（防重放）
  - Signature 每次请求不同（含时间戳）
```

### 理由

- Access Token 15 分钟过期：平衡安全性与用户体验（Token 泄露窗口小）
- Refresh Token 存 DB 表（PM 决策 Q-BE-01）：支持多设备管理、吊销审计，比纯 Redis 方案更具可靠性；Access Token 黑名单仍用 Redis（TTL 短，不需要持久化）
- RS256 而非 HS256：非对称签名，未来若引入独立服务可直接验签，无需共享 secret
- Argon2id vs bcrypt：Argon2id 是 Password Hashing Competition 冠军，内存硬度更强
- Refresh Token 旋转（RTR）：有效防止 Refresh Token 泄露后被持续使用；旧 token 标记 `revoked_at` 而非物理删除，保留审计链

### 后果

- Redis 用于 Access Token 黑名单（短期，TTL≤15min），可容忍短暂不可用（重启后黑名单清空，但 Access Token 最多 15 分钟后自然过期）
- DB（refresh_tokens 表）为 Refresh Token 强依赖，需在迁移脚本中包含此表
- RS256 需维护密钥对（私钥签名，公钥验签），通过环境变量注入，**严禁提交 .env**
- 每个 Access Token 包含 `jti`（JWT ID），生成时写入 payload
- 定期清理 `refresh_tokens` 表中已过期且 `revoked_at IS NOT NULL` 的记录（BullMQ 定时 Job）
- `AuthModule` 导出 `JwtAuthGuard`，其他模块直接使用

---

## ADR-004 文件上传方案

### 状态

Accepted

### 背景

视频文件最大 300MB，若通过后端服务器转发上传，带宽和内存压力极大。需要客户端直传方案，同时保证安全性（不暴露存储凭证）和上传完成的可靠回调。

### 决策

**客户端直传 Presigned URL 方案（服务端签名，客户端直传）**

**上传流程：**

```
1. 客户端 → 后端：POST /api/v1/videos/upload
   Body: { filename, file_size, duration, mime_type }

2. 后端验证：
   - 文件大小 ≤ 300MB
   - 时长 ≤ 120 秒（由客户端声明，转码完成后校验实际时长）
   - mime_type in ['video/mp4', 'video/quicktime', 'video/x-matroska']

3. 后端 → 客户端：
   {
     "upload_id": "vid_xxx",        // 本次上传的业务 ID
     "presigned_url": "https://...", // 有效期 15 分钟
     "method": "PUT",
     "fields": {}                   // S3 POST 表单字段（如用 POST 方式）
   }
   同时在 DB 创建 video 记录，status = 'uploaded'，raw_url 设为目标路径

4. 客户端 → S3/OSS：PUT <presigned_url>（直传，不经过后端）

5. 客户端 → 后端：POST /api/v1/videos/upload/complete
   Body: { upload_id, etag }        // etag 由 S3/OSS 客户端上传响应返回

6. 后端双保险验证（PM 采纳 API-01）：
   步骤一（主验证）：调用 S3 HeadObject，确认：
     - 文件 Key 存在
     - ETag 与客户端上报的一致
     - Content-Length 与注册时声明的 file_size 一致（防偷换文件）
   步骤二（异步补充验证，可选）：S3 Event Notification → SQS → Worker 二次确认
     - 对于大文件上传（Multipart），HeadObject 的 ETag 为复合值，步骤一降级为仅校验文件存在性
     - S3 Event Notification 作为兜底，确保漏网的伪造回调最终被发现

   验证通过后：
   → 将 video.status 更新为 'queued'
   → 投入 BullMQ transcode 队列
```

**分片上传策略（大文件 > 50MB）：**

```
使用 S3 Multipart Upload API：
  - 客户端请求分片 Presigned URL 列表（每片 10MB）
  - 客户端并行上传各分片
  - 全部完成后调用 /upload/complete，后端执行 CompleteMultipartUpload
```

**存储路径规范：**

```
原始视频：  raw/{year}/{month}/{video_id}.{ext}
HLS 输出：  hls/{video_id}/index.m3u8
            hls/{video_id}/360p/seg_000.ts ...
缩略图：    thumbnails/{video_id}.jpg
头像：      avatars/{user_id}/{timestamp}.{ext}
```

### 理由

- Presigned URL 不暴露 AWS/OSS 凭证，安全性高
- 直传减少后端带宽消耗，300MB 视频若走后端中转，单并发即占 300MB 内存
- 双保险验证（HeadObject + S3 Event Notification）：单纯依赖客户端上报 ETag 可被伪造；HeadObject 为同步强验证，Event Notification 为异步兜底
- Multipart Upload 时 ETag 为复合值（`etag-N` 格式）不可直接比对，因此大文件降级为校验文件存在性 + 文件大小
- 备选方案"后端接收流式上传"：内存压力大，带宽瓶颈，不采用

### 后果

- 后端需维护 `StorageService`（见 ADR-009），封装 presigned URL 生成逻辑
- 客户端上传 SDK 需处理网络中断的断点续传（借助 S3 Multipart 的 uploadId）
- Presigned URL 有效期 15 分钟，超时未上传的 video 记录需定时清理（BullMQ 定时 Job）
- 本地开发环境使用 MinIO，MinIO 完全兼容 S3 API，Presigned URL 流程无需修改

---

## ADR-005 视频转码方案

### 状态

Accepted

### 背景

用户上传原始视频（最高 2K H.265，最大 300MB），需转码为多码率 HLS 流以适配不同网络环境和设备。转码为 CPU 密集型任务，需异步处理，不能阻塞 API 服务。

### 决策

**FFmpeg Worker + BullMQ 队列方案**

**Worker 部署模型：独立进程（Docker 容器化）**

```
API 服务（NestJS）
    │ 投入队列
    ▼
Redis（BullMQ Queue: video-transcode）
    │ 消费任务
    ▼
FFmpeg Worker（独立 Docker 容器）
    │ 转码完成
    ▼
对象存储（HLS 分片 + 缩略图）
    │ 更新状态
    ▼
Notification（通知用户转码完成）
```

**HLS 输出规格：**

| 档位 | 分辨率 | 视频码率 | 音频 | 适用场景 |
|------|--------|---------|------|---------|
| 360p | 640×360 | 800kbps | AAC 96k | 移动端弱网 |
| 720p | 1280×720 | 2.5Mbps | AAC 128k | 默认档位 |
| 1080p | 1920×1080 | 5Mbps | AAC 192k | 高清（源视频 ≥ 1080p 时生成） |

**FFmpeg 核心参数：**

```bash
ffmpeg -i input.{ext} \
  # 720p 流
  -filter:v:0 scale=1280:720 -c:v:0 libx264 -b:v:0 2500k -preset fast -profile:v high \
  -c:a:0 aac -b:a:0 128k \
  # 360p 流
  -filter:v:1 scale=640:360  -c:v:1 libx264 -b:v:1 800k  -preset fast \
  -c:a:1 aac -b:a:1 96k \
  # HLS 输出
  -f hls \
  -hls_time 6 \
  -hls_list_size 0 \
  -hls_flags independent_segments \
  -master_pl_name index.m3u8 \
  output/%v/seg_%03d.ts
```

**BullMQ 队列配置：**

```typescript
const transcodeQueue = {
  name: 'video-transcode',
  defaultJobOptions: {
    attempts: 3,                    // 失败最多重试 3 次
    backoff: { type: 'exponential', delay: 30_000 },  // 指数退避
    removeOnComplete: { count: 100 },   // 保留最近 100 条成功记录
    removeOnFail: { count: 500 },       // 保留最近 500 条失败记录
  },
  concurrency: 2,   // 单 Worker 容器并发 2 个转码任务（视 CPU 核数调整）
}
```

**缩略图提取：**

```bash
# 从视频 3 秒处截取第一帧
ffmpeg -i input -ss 00:00:03 -frames:v 1 -q:v 2 thumbnail.jpg
```

**状态流转（转码过程中）：**

```
queued → processing（Worker 开始处理）
processing → ready（转码成功，HLS 上传完成，发通知）
processing → failed（转码失败，已达最大重试次数）
failed → queued（手动或自动重新入队，最多 3 次）
```

### 理由

- **独立容器 vs 进程内线程**：FFmpeg 转码是 CPU 密集型，与 NestJS 事件循环共进程会阻塞 API。独立容器隔离故障，可独立扩缩容
- **libx264 vs H.265（输出）**：H.265 编码时间约为 H.264 的 2-3 倍，HLS 兼容性较差。输出用 H.264 AVC，兼容性最佳，源文件 H.265 输入无问题
- **BullMQ vs 自建队列**：BullMQ 基于 Redis，支持延迟任务、重试、进度上报，与项目已有的 Redis 复用
- **Docker 容器化 Worker**：便于在生产环境独立部署多个 Worker 实例水平扩展

### 后果

- Worker 容器需预装 FFmpeg（使用 `jrottenberg/ffmpeg` 或 `node:20-bullseye` + apt 安装）
- 转码失败 3 次后，video.status = 'failed'，通知用户重新上传
- Worker 异常退出时，BullMQ 会自动将 active 状态的任务重新置为 waiting
- Phase 0 Spike（T0-7）需验证 MinIO ↔ S3 SDK 兼容性及 FFmpeg HLS 输出的完整性

---

## ADR-006 前后端通信规范

### 状态

Accepted

### 背景

前端（Web + Mobile）与后端 API 的通信需要统一规范，包括：URL 风格、错误码体系、分页方案、API 文档生成。规范不统一会导致前端处理错误分支困难，联调效率低下。

### 决策

**一、RESTful API 设计规范**

```
Base Path: /api/v1
资源命名: 复数名词（users, videos, feeders）
资源操作: 标准 HTTP 方法（GET/POST/PUT/PATCH/DELETE）
嵌套资源: 最多一层（/videos/:id/comments，不做 /videos/:id/comments/:cid/replies）
```

**二、统一响应格式**

```typescript
// 成功响应
{
  "data": <payload>,
  "meta": {                     // 仅分页接口包含
    "next_cursor": "xxx",
    "has_more": true,
    "total": 1234               // 仅 offset 分页包含
  }
}

// 错误响应
{
  "code": "VIDEO_NOT_FOUND",    // 机器可读错误码（大写下划线）
  "message": "视频不存在",       // 人类可读消息（中文，首发仅中文）
  "request_id": "req_xxx",      // 便于日志追踪
  "details": []                 // 可选，validation 错误详情
}
```

**三、错误码体系**

```
格式：{模块}_{错误类型}

HTTP 状态码映射：
  400 → 参数错误（INVALID_PARAMS, VALIDATION_FAILED）
  401 → 未认证（UNAUTHORIZED, TOKEN_EXPIRED, TOKEN_INVALID）
  403 → 无权限（FORBIDDEN, INSUFFICIENT_ROLE）
  404 → 资源不存在（USER_NOT_FOUND, VIDEO_NOT_FOUND, FEEDER_NOT_FOUND）
  409 → 冲突（EMAIL_ALREADY_EXISTS, USERNAME_TAKEN, ALREADY_LIKED）
  422 → 业务逻辑错误（VIDEO_TOO_LARGE, VIDEO_TOO_LONG, FEEDER_ALREADY_BOUND）
  429 → 限流（RATE_LIMIT_EXCEEDED）
  500 → 服务器内部错误（INTERNAL_ERROR）

完整错误码表维护于：doc/api/error-codes.md（Phase 1 前产出）
```

**四、分页方案**

```typescript
// 游标分页（Feed 类接口，默认方案）
GET /api/v1/videos?cursor=<opaque>&limit=20&sort=latest

Response:
{
  "data": [...],
  "meta": { "next_cursor": "xxx", "has_more": true }
}

// Cursor 实现：Base64(JSON({ id, created_at }))，后端解码后转为 WHERE 条件
// 优点：性能稳定，无"幽灵数据"（offset 分页在数据更新时会跳过或重复）

// Offset 分页（管理后台，允许随机翻页）
GET /api/v1/admin/users?page=1&limit=20

Response:
{
  "data": [...],
  "meta": { "page": 1, "limit": 20, "total": 500 }
}
```

**五、OpenAPI 文档生成**

```typescript
// 使用 @nestjs/swagger 装饰器自动生成
// 所有 DTO 使用 @ApiProperty() 标注
// 端点访问：/api/docs（开发环境开启，生产环境通过 API Key 保护）
```

**六、设备端限流（补充 PRD API-02）**

```
设备心跳：最多 1 次/分钟/设备
设备上传：最多 10 次/小时/设备
普通接口：100 次/分钟/IP（未登录），300 次/分钟/用户（已登录）
实现：Redis + @nestjs/throttler
```

### 理由

- 游标分页在视频 Feed 场景下性能优于 offset（无需 COUNT(*) 且翻页稳定）
- 错误码大写下划线格式：前端可直接 switch-case 处理，无需字符串匹配
- NestJS Swagger 装饰器方案：代码即文档，避免手动维护 OpenAPI YAML 脱节

### 后果

- 所有 DTO 类必须使用 `class-validator` 注解 + `@ApiProperty()` 双标注
- `ResponseTransformInterceptor` 负责统一包装响应格式，Controller 直接返回数据
- `GlobalExceptionFilter` 负责将所有异常转换为统一错误响应格式
- `request_id` 由中间件在请求入口注入到 `cls-hooked` 上下文，全链路可追踪

---

## ADR-007 i18n 国际化方案

### 状态

Accepted

### 背景

首发版本仅支持简体中文，但架构需预留 i18n 扩展能力，避免未来国际化时大规模重构。

### 决策

**前端语言包方案：**

```
apps/web/src/i18n/
├── zh-CN.json        # 简体中文（首发唯一语言包）
└── index.ts          # 语言包加载器（预留多语言切换接口）
```

语言包 Key 格式：`{模块}.{组件}.{key}`，例如：

```json
{
  "auth.login.title": "登录",
  "auth.login.email_placeholder": "请输入邮箱",
  "video.upload.size_limit": "视频大小不能超过 300MB",
  "error.VIDEO_NOT_FOUND": "视频不存在"
}
```

**后端错误消息方案：Code-Based Mapping**

```typescript
// 后端仅返回 code（机器可读），不返回特定语言的消息
// 前端根据 code 在语言包中查找对应文案

// 后端 error-codes.ts
export const ERROR_MESSAGES: Record<string, string> = {
  VIDEO_NOT_FOUND: '视频不存在',      // 作为 fallback / 日志用途
  EMAIL_ALREADY_EXISTS: '该邮箱已被注册',
  // ...
}

// 实际 API 响应
{
  "code": "VIDEO_NOT_FOUND",
  "message": "视频不存在",   // 后端返回的是当前配置语言（首发 zh-CN）
  "request_id": "req_xxx"
}
```

**后续扩展路径（Phase 6 或国际化需求时）：**

1. 前端：在 i18n 目录新增 `en-US.json`，切换语言时加载对应包
2. 后端：接收 `Accept-Language` Header，返回对应语言的 message
3. 无需修改 API 协议，仅扩展语言包文件

### 理由

- 语言包独立于业务代码，增加新语言只需添加 JSON 文件
- Code-based 错误码体系（ADR-006）天然支持前端本地化错误消息
- 首发不引入 `next-i18next`/`i18next` 等库，避免为零需求引入依赖；预留目录结构即可

### 后果

- 所有用户可见文本必须通过语言包引用，**禁止硬编码汉字于组件内**（Web 前端规范）
- 后端错误 code 为唯一接口契约，message 为辅助，前端不应依赖 message 做逻辑判断
- 语言包文件由 Web 前端 Lead 维护，后端 Lead 维护错误码表 `doc/api/error-codes.md`

---

## ADR-008 坐标脱敏方案

### 状态

Accepted

### 背景

喂鸟器和视频的地理位置数据需要脱敏后对外展示（精度 ±1km），防止泄露用户隐私（家庭住址、稀有鸟种精确位置）。原始坐标需要完整保留用于内部分析。

### 决策

**应用层序列化脱敏方案（在 API Response 序列化时截断）**

```typescript
// 脱敏逻辑：截断至小数点后 2 位
// 纬度精度：小数点后 2 位 ≈ 1.11km，满足 ±1km 要求
// 经度精度：小数点后 2 位 ≈ 0.79km（赤道），同样满足

// apps/api/src/common/utils/coord-mask.util.ts
export function maskCoordinate(value: number): number {
  return Math.round(value * 100) / 100;  // 保留 2 位小数
}

// DTO 序列化时应用（使用 class-transformer）
export class VideoLocationDto {
  @Transform(({ value }) => maskCoordinate(value))
  @ApiProperty({ example: 39.91 })
  display_lat: number;

  @Transform(({ value }) => maskCoordinate(value))
  @ApiProperty({ example: 116.39 })
  display_lng: number;

  // 原始坐标 latitude / longitude 不包含在公开 DTO 中
}
```

**存储层设计（双字段存储）：**

```sql
-- 保留 PRD 中的双字段设计
latitude      DECIMAL(10, 8),  -- 原始精度，仅后端读取
longitude     DECIMAL(11, 8),  -- 原始精度，仅后端读取
display_lat   DECIMAL(10, 2),  -- 预计算脱敏值（写入时计算，读取性能好）
display_lng   DECIMAL(11, 2),  -- 预计算脱敏值
```

**写入时预计算脱敏值：**

```typescript
// 在 Service 层写入时同时计算 display 值
async createVideo(dto: CreateVideoDto) {
  await this.prisma.video.create({
    data: {
      ...dto,
      display_lat: maskCoordinate(dto.latitude),
      display_lng: maskCoordinate(dto.longitude),
    }
  });
}
```

### 理由

- **应用层 vs 数据库触发器**：触发器难以测试、难以版本控制，且不同 DB 语法不同；应用层脱敏代码可单元测试，逻辑透明
- **应用层 vs 查询时计算**：双字段存储（预计算）在查询时无额外计算开销，读性能好
- **2 位小数精度**：纬度方向 1° ≈ 111km，0.01° ≈ 1.11km，满足 ±1km 要求

### 后果

- 所有包含地理坐标的公开 API Response 必须使用脱敏 DTO，**原始坐标字段禁止出现在公开 DTO 中**
- Admin API 可返回原始坐标（需 Admin 角色 Guard）
- `maskCoordinate` 工具函数需要单元测试覆盖（边界：极点、负坐标）
- 历史数据若坐标格式变更，需 Migration 脚本重新计算 display 值

---

## ADR-009 云厂商抽象层

### 状态

Accepted

### 背景

项目需要同时支持 AWS S3 和阿里云 OSS（PRD 8.4 云厂商双栈策略），本地开发使用 MinIO。三者 API 有差异，业务代码不应直接依赖特定云厂商 SDK。

### 决策

**Adapter 模式 + 配置驱动切换**

```typescript
// 抽象接口（contracts）
// apps/api/src/infra/storage/storage.interface.ts

export interface IStorageService {
  /** 生成预签名上传 URL */
  getPresignedUploadUrl(key: string, expiresIn?: number): Promise<PresignedUploadResult>;

  /** 生成预签名下载 URL（私有对象） */
  getPresignedDownloadUrl(key: string, expiresIn?: number): Promise<string>;

  /** 验证对象是否存在（通过 HeadObject 获取 ETag） */
  headObject(key: string): Promise<{ etag: string; size: number } | null>;

  /** 删除对象 */
  deleteObject(key: string): Promise<void>;

  /** 批量删除 */
  deleteObjects(keys: string[]): Promise<void>;

  /** 获取公有对象 URL（CDN URL） */
  getPublicUrl(key: string): string;
}
```

```typescript
// 具体实现

// S3 Adapter（覆盖 AWS S3 + MinIO，二者 API 完全兼容）
// apps/api/src/infra/storage/s3.adapter.ts
import { S3Client, PutObjectCommand, HeadObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

export class S3StorageAdapter implements IStorageService {
  private client: S3Client;
  constructor(config: S3Config) {
    this.client = new S3Client({
      region: config.region,
      endpoint: config.endpoint,   // MinIO: 'http://localhost:9000'
      forcePathStyle: config.forcePathStyle,  // MinIO 需要 true
      credentials: { accessKeyId: config.accessKeyId, secretAccessKey: config.secretAccessKey },
    });
  }
  // ... 实现各方法
}

// OSS Adapter
// apps/api/src/infra/storage/oss.adapter.ts
import OSS from 'ali-oss';

export class OssStorageAdapter implements IStorageService {
  private client: OSS;
  // ... 实现各方法（阿里云 OSS SDK 封装）
}
```

```typescript
// 工厂与 NestJS 模块注册
// apps/api/src/infra/storage/storage.module.ts

@Module({
  providers: [
    {
      provide: 'STORAGE_SERVICE',
      useFactory: (config: ConfigService): IStorageService => {
        const provider = config.get('STORAGE_PROVIDER'); // 's3' | 'oss'
        if (provider === 'oss') return new OssStorageAdapter({ ... });
        return new S3StorageAdapter({ ... });  // 默认 S3/MinIO
      },
      inject: [ConfigService],
    },
  ],
  exports: ['STORAGE_SERVICE'],
})
export class StorageModule {}
```

**环境变量配置（`.env.example`）：**

```env
# 存储提供商: s3 (AWS/MinIO) | oss (阿里云)
STORAGE_PROVIDER=s3

# S3 / MinIO
STORAGE_S3_BUCKET=birdwatch
STORAGE_S3_REGION=us-east-1
STORAGE_S3_ACCESS_KEY_ID=minioadmin
STORAGE_S3_SECRET_ACCESS_KEY=minioadmin
STORAGE_S3_ENDPOINT=http://localhost:9000   # MinIO 本地端点（生产留空使用 AWS 默认）
STORAGE_S3_FORCE_PATH_STYLE=true            # MinIO 需要 true，AWS 为 false
STORAGE_CDN_BASE_URL=http://localhost:9000/birdwatch  # CDN/公有访问前缀

# 阿里云 OSS（仅 STORAGE_PROVIDER=oss 时生效）
STORAGE_OSS_BUCKET=birdwatch
STORAGE_OSS_REGION=oss-cn-hangzhou
STORAGE_OSS_ACCESS_KEY_ID=
STORAGE_OSS_ACCESS_KEY_SECRET=
STORAGE_OSS_CDN_BASE_URL=
```

### 理由

- **Adapter 模式**：业务代码只依赖 `IStorageService` 接口，切换云厂商只需修改环境变量
- **S3 兼容 MinIO**：`@aws-sdk/client-s3` 通过 `endpoint` 参数即可连接 MinIO，本地开发零额外代码
- **OSS SDK 独立封装**：阿里云 OSS 的 Presigned URL API 与 S3 有差异，需独立实现但接口对齐
- **备选方案"统一 S3 接口代理 OSS"**：阿里云支持 S3 兼容 API，但 Presigned URL 签名算法有细节差异，稳定性不如原生 SDK

### 后果

- `packages/shared-types/` 中定义 `PresignedUploadResult` 等共享类型
- 所有 `VideoModule`、`UserModule` 中的文件操作通过注入 `'STORAGE_SERVICE'` 使用，不直接引用 SDK
- 切换云厂商只需修改 `.env`，无需修改业务代码
- OSS Adapter 需要在 Phase 2 前完成集成测试（与 S3 Adapter 跑同一套测试套件）

---

## ADR-010 计数字段并发更新策略

### 状态

Accepted

### 背景

`users` 表的 `follower_count`、`following_count`、`video_count` 为冗余统计字段（PRD DDL DM-03 问题）。直接对这些字段执行 `UPDATE ... SET count = count + 1` 在高并发（如热门用户被大量关注）场景下存在竞争条件，且 DB 行锁粒度较大。PM 决策：保留冗余字段，采用方案 B 更新。

### 决策

**Redis 原子计数 + BullMQ 异步同步到 DB（方案 B）**

**写入流程：**

```
用户 A 关注用户 B 时：
  1. 写入 follows 表（关系主表，强一致）
  2. Redis INCR bw:user:{B_id}:follower_count（原子操作，O(1)）
  3. Redis INCR bw:user:{A_id}:following_count

定时同步（BullMQ 定时 Job，每 60 秒执行）：
  1. 扫描 Redis 中 bw:user:*:follower_count 有变动的 key
  2. 批量 UPDATE users SET follower_count = <redis_value> WHERE id = <user_id>
  3. 清空已同步的 Redis 计数 delta

读取流程（API 返回用户信息时）：
  - 优先读 Redis 实时值（如存在）
  - Redis miss 时回落到 DB 字段值
```

**Redis Key 设计：**

```
bw:user:{user_id}:follower_count   → Integer（绝对值，非增量）
bw:user:{user_id}:following_count  → Integer
bw:user:{user_id}:video_count      → Integer

初始化：首次写入时从 DB 读取当前值作为基准
TTL：无（持久化，随 DB 同步刷新）
```

**数据不一致容忍策略：**

```
- 允许 Redis 与 DB 之间存在最多 60 秒的延迟（定时同步间隔）
- 服务重启时，Redis 计数重新从 DB 加载（冷启动）
- 定时 Job 故障时，DB 字段值保持上次同步值（计数可能落后，不影响业务正确性）
- 关键校验（如付费功能）不依赖冗余计数字段，直接 COUNT(*) 查询
```

### 理由

| 方案 | 优点 | 缺点 |
|------|------|------|
| 方案 A：DB 行级锁 + 事务 | 强一致 | 热点用户场景下锁竞争严重，吞吐量低 |
| **方案 B：Redis 原子计数（选定）** | 高吞吐，无锁 | 短暂不一致（≤60s），需维护 Redis |
| 方案 C：实时 COUNT(*) | 无冗余 | 每次请求都 COUNT，性能差，不可接受 |

Redis `INCR` 命令是原子操作，天然避免并发竞争；60 秒同步延迟对展示类数据（粉丝数、视频数）完全可接受。

### 后果

- `UserModule` 的关注/取消关注操作必须同时写 Redis 计数（在 Service 层，数据库事务提交后）
- `VideoModule` 的视频创建/删除操作同步更新 `bw:user:{id}:video_count`
- 新增 BullMQ 定时 Job `sync-user-counts`（每 60 秒），放于 `infra/queue/` 模块
- 冷启动脚本：应用启动时检查 Redis 中各用户计数 key，不存在则从 DB 批量预热

---

## 附录 A：Monorepo 目录结构

> 基于 Phase0_WorkPlan T0-4 方案，后端 Lead Review 确认如下，含后端模块细化。

```
tickwingbirding/                     # 仓库名
├── apps/
│   ├── api/                         # NestJS 后端
│   │   ├── src/
│   │   │   ├── modules/
│   │   │   │   ├── auth/
│   │   │   │   │   ├── auth.module.ts
│   │   │   │   │   ├── auth.controller.ts
│   │   │   │   │   ├── auth.service.ts
│   │   │   │   │   ├── strategies/      # passport-jwt strategy
│   │   │   │   │   └── dto/
│   │   │   │   ├── user/
│   │   │   │   ├── video/
│   │   │   │   │   ├── workers/         # BullMQ Processor
│   │   │   │   │   └── ...
│   │   │   │   ├── feeder/
│   │   │   │   ├── community/
│   │   │   │   ├── notification/
│   │   │   │   └── admin/
│   │   │   ├── infra/                   # 基础设施层（新增）
│   │   │   │   ├── storage/             # ADR-009 存储抽象层
│   │   │   │   │   ├── storage.interface.ts
│   │   │   │   │   ├── storage.module.ts
│   │   │   │   │   ├── s3.adapter.ts
│   │   │   │   │   └── oss.adapter.ts
│   │   │   │   ├── queue/               # BullMQ 队列配置
│   │   │   │   └── cache/               # Redis 操作封装
│   │   │   ├── common/
│   │   │   │   ├── decorators/
│   │   │   │   ├── guards/
│   │   │   │   ├── interceptors/
│   │   │   │   ├── filters/
│   │   │   │   ├── pipes/
│   │   │   │   ├── dto/
│   │   │   │   └── utils/
│   │   │   │       └── coord-mask.util.ts   # ADR-008
│   │   │   ├── config/
│   │   │   │   └── configuration.ts         # 环境变量类型安全配置
│   │   │   └── main.ts
│   │   ├── prisma/
│   │   │   ├── schema.prisma
│   │   │   ├── migrations/
│   │   │   └── seed.ts
│   │   ├── test/
│   │   └── package.json
│   ├── web/                         # Next.js Web 端（前端 Lead 主责）
│   │   ├── src/
│   │   │   ├── app/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── store/
│   │   │   ├── api/
│   │   │   ├── i18n/                # ADR-007
│   │   │   │   ├── zh-CN.json
│   │   │   │   └── index.ts
│   │   │   └── utils/
│   │   └── package.json
│   └── mobile/                      # Phase 6 填充
│       └── .gitkeep
├── packages/
│   ├── shared-types/                # 前后端共享 TS 类型
│   │   └── src/
│   │       ├── api.types.ts         # API 请求/响应类型
│   │       ├── storage.types.ts     # 存储相关类型
│   │       └── index.ts
│   ├── eslint-config/
│   └── tsconfig/
│       ├── base.json
│       ├── nestjs.json
│       └── nextjs.json
├── docker/
│   ├── docker-compose.yml           # 本地开发（PostgreSQL + Redis + MinIO）
│   ├── docker-compose.prod.yml
│   ├── Dockerfile.api
│   └── Dockerfile.worker            # 独立转码 Worker 镜像
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── doc/
├── turbo.json
├── pnpm-workspace.yaml
├── package.json
├── .gitignore
├── .env.example
└── README.md
```

**与 Phase0_WorkPlan 的调整：**
- 新增 `apps/api/src/infra/` 层（存储抽象、队列、缓存封装）
- 新增 `docker/Dockerfile.worker`（独立转码容器，ADR-005）
- `packages/shared-types/` 细化为三个类型文件

---

## 附录 B：关键 API Schema 草案

### B-1：POST /api/v1/auth/register — 用户注册

**Request：**

```json
{
  "email": "user@example.com",         // required, email 格式
  "username": "bird_lover_42",         // required, 3-50字符, 字母数字下划线
  "password": "Secure@Pass123",        // required, ≥8位, 含大小写+数字
  "experience": "beginner"             // optional, enum: beginner|enthusiast|expert, 默认 beginner
}
```

**Response 201：**

```json
{
  "data": {
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "user@example.com",
      "username": "bird_lover_42",
      "experience": "beginner",
      "role": "user",
      "created_at": "2026-03-12T10:00:00.000Z"
    },
    "access_token": "eyJhbGciOiJSUzI1NiIsInR...",
    "refresh_token": "a3f8b2c1d4e5f6...",   // opaque token
    "expires_in": 900                         // Access Token 有效期（秒）
  }
}
```

**错误码：**

| HTTP | Code | 触发条件 |
|------|------|---------|
| 400 | `VALIDATION_FAILED` | 参数格式错误 |
| 409 | `EMAIL_ALREADY_EXISTS` | 邮箱已注册 |
| 409 | `USERNAME_TAKEN` | 用户名已被使用 |

---

### B-2：POST /api/v1/videos/upload — 请求上传凭证

**Request Header：**

```
Authorization: Bearer <access_token>
Idempotency-Key: <client_generated_uuid>   // 幂等键，防重复创建
```

**Request Body：**

```json
{
  "title": "白鹭觅食",                      // required, 1-200字符
  "description": "今天在西湖拍到白鹭...",   // optional, max 2000字符
  "filename": "video_2026031201.mp4",      // required, 原始文件名
  "file_size": 157286400,                  // required, 字节（≤314572800 即 300MB）
  "duration": 87,                          // required, 秒（≤120）
  "mime_type": "video/mp4",               // required, enum: video/mp4|video/quicktime|video/x-matroska
  "visibility": "public",                  // optional, enum: public|private|unlisted, 默认 public
  "location_name": "西湖景区",             // optional
  "latitude": 30.2445,                    // optional, DECIMAL(10,8)
  "longitude": 120.1453,                  // optional, DECIMAL(11,8)
  "recorded_at": "2026-03-12T08:30:00Z"  // optional, 实际拍摄时间
}
```

**Response 201：**

```json
{
  "data": {
    "upload_id": "vid_7f3a9b2c1d4e5f6a",   // 本次上传业务 ID，后续 complete 接口使用
    "presigned_url": "https://s3.amazonaws.com/birdwatch/raw/2026/03/vid_7f3a9b2c1d4e5f6a.mp4?X-Amz-Algorithm=...",
    "method": "PUT",
    "expires_at": "2026-03-12T10:15:00Z",    // Presigned URL 过期时间（15分钟后）
    "max_file_size": 314572800               // 服务端允许的最大文件字节数
  }
}
```

**错误码：**

| HTTP | Code | 触发条件 |
|------|------|---------|
| 400 | `VALIDATION_FAILED` | 参数格式错误 |
| 422 | `VIDEO_TOO_LARGE` | file_size > 300MB |
| 422 | `VIDEO_TOO_LONG` | duration > 120秒 |
| 422 | `UNSUPPORTED_FORMAT` | mime_type 不在允许列表 |
| 401 | `UNAUTHORIZED` | 未登录 |

---

*文档版本：v1.0 | 后端 Lead 初稿 | 2026-03-12*
*待 Web 前端 Lead、DevOps Review 后更新为 Accepted 状态*
