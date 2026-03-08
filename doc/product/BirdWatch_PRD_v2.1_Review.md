# 🐦 BirdWatch Community — 产品需求文档 (PRD for Review)

**项目代号：** BirdWatch  
**文档版本：** v2.1 — Review Draft  
**创建日期：** 2026-03-08  
**最后更新：** 2026-03-08  
**文档状态：** 🟡 待评审 (Pending Review)  
**适用范围：** Web + iOS + Android + 设备端 (智能喂鸟器) + 管理后台  
**文档维护人：** PM (Claude)

---

## 变更记录

| 版本 | 日期 | 变更说明 | 作者 |
|------|------|---------|------|
| v1.0 | 2026-03-08 | 初版草稿，定义产品方向与基础技术方案 | 产品负责人 |
| v2.0 | 2026-03-08 | 升级为商业项目基线，补充 KPI、NFR、状态机、测试策略 | 产品负责人 |
| v2.1 | 2026-03-08 | 整合 v1/v2，调整 Phase 顺序，补充团队分工与验收标准，完善数据模型 | PM (Claude) |

---

## 目录

1. [文档目标](#1-文档目标)
2. [产品愿景与范围](#2-产品愿景与范围)
3. [用户角色与权限](#3-用户角色与权限)
4. [关键业务流程](#4-关键业务流程)
5. [功能需求 (FRD)](#5-功能需求-frd)
6. [非功能需求 (NFR)](#6-非功能需求-nfr)
7. [信息架构与多端策略](#7-信息架构与多端策略)
8. [技术方案](#8-技术方案)
9. [数据模型与状态机](#9-数据模型与状态机)
10. [API 规范](#10-api-规范)
11. [数据统计与分析](#11-数据统计与分析)
12. [团队角色与任务分工](#12-团队角色与任务分工)
13. [工程实施步骤与里程碑](#13-工程实施步骤与里程碑)
14. [质量保障与发布门禁](#14-质量保障与发布门禁)
15. [运维与 SRE 要求](#15-运维与-sre-要求)
16. [风险与应对](#16-风险与应对)
17. [待确认事项 (Open Questions)](#17-待确认事项-open-questions)
18. [附录](#18-附录)

---

## 1. 文档目标

本 PRD 是 BirdWatch 项目的可执行需求基线，用于：

- 产品、研发、测试、运维、数据、运营的**跨团队对齐**
- 分阶段排期、资源评估、**验收标准制定**
- 上线后的持续迭代与**质量门禁**
- 作为所有子文档（技术设计文档、测试计划、运维手册）的**上游依据**

---

## 2. 产品愿景与范围

### 2.1 产品愿景

BirdWatch 是一个连接观鸟爱好者、智能喂鸟硬件和生态数据的社区平台。用户既可以手动上传观鸟视频，也可以通过绑定喂鸟器自动采集视频，形成持续的内容流和社区互动。

### 2.2 核心价值主张

| 价值点 | 描述 |
|--------|------|
| 🎥 内容共享 | 用户上传观鸟视频，与社区分享发现 |
| 🤖 智能采集 | 智能喂鸟器自动拍摄并上传鸟类活动视频 |
| 🌐 社区互动 | 点赞、评论、关注、鸟种标注 |
| 📊 数据洞察 | 鸟类出现频率、地理分布统计 |

### 2.3 目标用户

- **休闲观鸟爱好者**（主要群体）— 希望记录与分享日常观鸟
- **专业鸟类学研究者** — 需要数据化的鸟类分布与行为记录
- **自然摄影师** — 作品展示与社区交流
- **智能硬件用户** — 已购买或计划购买喂鸟器的家庭用户

### 2.4 商业目标 (12 个月)

- 建立稳定的 UGC + 设备内容供给双引擎
- 建立活跃社区，提高留存与互动深度
- 支撑未来会员、设备订阅、品牌合作等商业化能力

### 2.5 北极星指标与核心 KPI

| 指标 | 定义 | 目标 (上线后 6 个月) |
|------|------|---------------------|
| WAU | 周活跃用户数 | ≥ 30,000 |
| WUV | 周上传有效视频用户数 | ≥ 6,000 |
| Device Active Rate | 周活跃喂鸟器占比 | ≥ 55% |
| D30 Retention | 新用户 30 日留存 | ≥ 25% |
| Moderation SLA | 视频审核处理时长 P95 | ≤ 24h |
| Playback Success | 视频播放成功率 | ≥ 99.0% |

### 2.6 In Scope (本版本范围)

- 用户系统：注册登录、资料、权限、账号安全
- 视频系统：手动上传、设备自动上传、转码播放、可见性
- 喂鸟器系统：私有/公有设备管理、绑定解绑、状态心跳
- 社区系统：点赞、评论、关注、举报、通知
- 发现系统：Feed、搜索、筛选、排序
- 管理后台：用户治理、内容审核、设备管理、运营看板
- 多端支持：Web、iOS、Android

### 2.7 Out of Scope (当前版本不做)

- 实时直播
- 复杂社交关系（群组、私信 IM）
- 自动物种识别模型训练平台
- 多租户 SaaS 隔离能力

---

## 3. 用户角色与权限

### 3.1 角色定义

| 角色 | 说明 |
|------|------|
| Guest | 游客，未登录，仅可浏览与搜索 |
| User | 注册用户，可上传、互动、管理个人设备 |
| Moderator | 内容审核员，可处理审核队列 |
| Admin | 平台管理员，拥有全部管理权限 |
| Device | 设备身份（喂鸟器 API 客户端） |

### 3.2 权限矩阵

| 能力           | Guest | User | Moderator | Admin | Device |
| ------------ | ----- | ---- | --------- | ----- | ------ |
| 浏览公开视频       | ✅     | ✅    | ✅         | ✅     | —      |
| 搜索内容         | ✅     | ✅    | ✅         | ✅     | —      |
| 查看用户主页       | ✅     | ✅    | ✅         | ✅     | —      |
| 上传手动视频       | —     | ✅    | ✅         | ✅     | —      |
| 点赞 / 评论 / 关注 | —     | ✅    | ✅         | ✅     | —      |
| 举报内容         | —     | ✅    | ✅         | ✅     | —      |
| 绑定 / 管理个人喂鸟器 | —     | ✅    | ✅         | ✅     | —      |
| 审核视频 / 评论    | —     | —    | ✅         | ✅     | —      |
| 管理用户状态       | —     | —    | —         | ✅     | —      |
| 管理公有喂鸟器      | —     | —    | —         | ✅     | —      |
| 系统配置 / 公告    | —     | —    | —         | ✅     | —      |
| 上传设备视频       | —     | —    | —         | —     | ✅      |
| 设备心跳上报       | —     | —    | —         | —     | ✅      |

---

## 4. 关键业务流程

### 4.1 手动上传流程

1. 用户提交视频元数据并请求上传凭证
2. 客户端直传对象存储（分片 / 断点续传）
3. 服务端记录 `video = uploaded`
4. 异步转码队列触发 FFmpeg 任务
5. 转码成功后 `video = ready`，生成 HLS 与缩略图
6. 若需审核，进入审核队列后再公开

### 4.2 私有喂鸟器自动上传流程

1. 用户绑定设备（扫码或输入序列号 + 绑定码）
2. 设备心跳上报在线状态
3. 设备提交视频上传任务并上传文件
4. 平台按 `owner_id` 归属视频所有权
5. 转码与审核完成后进入对应用户内容流

### 4.3 公有喂鸟器自动上传流程

1. 管理员创建公有设备并配置地理信息
2. 设备按 API Key 上传
3. 视频归属 `public_feeder_pool`
4. 平台按规则分发到公共频道与推荐流

### 4.4 内容治理流程

1. 用户举报或系统规则命中
2. 进入审核队列，支持自动分级
3. 审核结果：通过、下架、限流、封禁上传者
4. 审核动作写入审计日志

---

## 5. 功能需求 (FRD)

优先级定义：
- **P0**：上线必需
- **P1**：重要增强
- **P2**：可延期

### 5.1 账户与身份 (AUTH)

| ID | 需求 | 优先级 | 验收标准 |
|----|------|--------|---------|
| FR-AUTH-001 | 邮箱注册与登录 | P0 | 成功注册后可获取访问令牌 |
| FR-AUTH-002 | 刷新令牌与安全退出 | P0 | 刷新令牌过期后需重新登录 |
| FR-AUTH-003 | 找回密码 (邮件) | P0 | 过期链接不可用 |
| FR-AUTH-004 | 第三方登录 (Apple/Google) | P1 | 账号可与邮箱账号合并 |
| FR-AUTH-005 | 风险登录告警 | P1 | 新设备登录触发通知 |

### 5.2 用户资料与社交关系 (USER)

| ID | 需求 | 优先级 | 验收标准 |
|----|------|--------|---------|
| FR-USER-001 | 个人资料编辑 (头像/昵称/简介/地区) | P0 | 修改后 5 秒内多端可见 |
| FR-USER-002 | 用户主页与作品列表 | P0 | 支持公开/私有内容过滤 |
| FR-USER-003 | 关注 / 取关 | P0 | 关系变更实时反映在计数上 |
| FR-USER-004 | 黑名单与隐私设置 | P1 | 被拉黑用户无法互动 |

### 5.3 视频上传与处理 (VIDEO)

| ID | 需求 | 优先级 | 验收标准 |
|----|------|--------|---------|
| FR-VIDEO-001 | 手动上传 MP4/MOV (≤ 1GB) | P0 | 大文件支持断点续传 |
| FR-VIDEO-002 | 视频元数据 (标题/描述/位置/鸟种标签) | P0 | 标题必填，长度校验 |
| FR-VIDEO-003 | 可见性 (public / private / unlisted) | P0 | 私有视频不可被搜索 |
| FR-VIDEO-004 | 自动转码 HLS 多码率 | P0 | 转码失败可重试，最多 3 次 |
| FR-VIDEO-005 | 缩略图自动生成 | P0 | 默认抓取关键帧，支持手动替换 |
| FR-VIDEO-006 | 播放器自适应清晰度 | P0 | 弱网下自动降码率 |
| FR-VIDEO-007 | 转码任务运营重跑 | P1 | 管理端可手动重跑任务 |

### 5.4 喂鸟器管理 (FEEDER)

| ID | 需求 | 优先级 | 验收标准 |
|----|------|--------|---------|
| FR-FEEDER-001 | 设备绑定 / 解绑 | P0 | 绑定码一次性使用 |
| FR-FEEDER-002 | 设备身份认证 (API Key + 签名) | P0 | 无效签名请求拒绝 |
| FR-FEEDER-003 | 心跳上报与在线状态 | P0 | 心跳超时自动离线 |
| FR-FEEDER-004 | 私有 / 公有设备类型管理 | P0 | 公有设备无 owner_id |
| FR-FEEDER-005 | 设备上传视频 | P0 | 视频正确归属私有用户或公共池 |
| FR-FEEDER-006 | 拍摄计划配置 (定时/触发) | P1 | 配置变更 10 秒内下发 |

### 5.5 社区互动 (COMMUNITY)

| ID | 需求 | 优先级 | 验收标准 |
|----|------|--------|---------|
| FR-COMM-001 | 点赞 / 取消点赞 | P0 | 幂等，重复操作不报错 |
| FR-COMM-002 | 评论与二级回复 | P0 | 最大 2 层，支持删除占位 |
| FR-COMM-003 | 举报视频 / 评论 | P0 | 举报后进入审核队列 |
| FR-COMM-004 | 通知中心 (点赞/评论/关注/审核) | P1 | 未读数实时更新 |

### 5.6 发现与搜索 (DISCOVERY)

| ID | 需求 | 优先级 | 验收标准 |
|----|------|--------|---------|
| FR-DISC-001 | 首页 Feed (关注 + 推荐) | P0 | 冷启动有基础推荐策略 |
| FR-DISC-002 | 搜索 (鸟种/地区/喂鸟器/用户) | P0 | 返回结果支持分页 |
| FR-DISC-003 | 排序 (最新/热门) | P0 | 热门策略按近 7 天加权 |
| FR-DISC-004 | 地图模式浏览 | P1 | 可切换区域热度层 |

### 5.7 管理后台 (ADMIN)

| ID | 需求 | 优先级 | 验收标准 |
|----|------|--------|---------|
| FR-ADMIN-001 | 用户管理 (封禁/解封/角色) | P0 | 操作写入审计日志 |
| FR-ADMIN-002 | 视频审核队列 | P0 | 支持批量审核 |
| FR-ADMIN-003 | 设备管理 (公有设备配置) | P0 | 设备状态可筛选 |
| FR-ADMIN-004 | 运营指标看板 | P0 | 至少覆盖 DAU、上传量、播放成功率 |
| FR-ADMIN-005 | 公告发布 | P1 | 指定端与用户分组可见 |

---

## 6. 非功能需求 (NFR)

### 6.1 性能与可用性

| ID | 要求 |
|----|------|
| NFR-PERF-001 | 首页 Feed 接口 P95 < 300ms（不含首包 CDN 延迟） |
| NFR-PERF-002 | 视频首帧时间 P95 < 2.5s |
| NFR-AVL-001 | 核心 API 月可用性 ≥ 99.9% |
| NFR-AVL-002 | 对象存储与转码任务失败可重试 |

### 6.2 可扩展性

- 初期采用**模块化单体 + 异步队列**架构，避免过早微服务化
- 按业务域拆分模块：auth / user / video / feeder / community / admin
- 所有外部依赖经接口层封装，便于后续替换云厂商与基础设施

### 6.3 安全与合规

| ID | 要求 |
|----|------|
| NFR-SEC-001 | 全链路 HTTPS / TLS 1.2+ |
| NFR-SEC-002 | 密码哈希采用 Argon2 或 bcrypt（成本参数可配置） |
| NFR-SEC-003 | Token 与 API Key 支持轮换与吊销 |
| NFR-SEC-004 | 上传文件类型与恶意内容扫描 |
| NFR-SEC-005 | 审计日志保存 ≥ 180 天 |

### 6.4 可观测性

- **结构化日志**：request_id, user_id, device_id, video_id
- **指标监控**：API 延迟、错误率、队列堆积、转码耗时、播放失败率
- **告警策略**：P1（服务不可用）、P2（性能退化）、P3（指标异常）
- **分布式追踪**：关键链路可追踪到上传 → 转码 → 发布

---

## 7. 信息架构与多端策略

### 7.1 端能力边界

| 端 | 核心能力 |
|----|---------|
| Web | 完整社区功能 + 管理后台入口 |
| iOS | 上传 / 播放 / 互动 / 设备绑定 |
| Android | 上传 / 播放 / 互动 / 设备绑定 |
| Admin Web | 用户治理、审核、运营与设备管理 |

### 7.2 多端一致性原则

- 统一 Design Token 与组件规范
- API 契约统一，由后端 OpenAPI 生成 SDK
- 功能灰度发布策略一致（按用户分组和比例）

---

## 8. 技术方案

### 8.1 架构原则

- **先快后稳**：MVP 快速验证，但不牺牲核心边界
- **领域分层**：API 层 → 应用层 → 领域层 → 基础设施层
- **异步优先**：上传后异步处理，避免长事务
- **事件驱动**：视频状态变化通过事件广播

### 8.2 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                         客户端层                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │  Web App  │  │ iOS App  │  │ Android  │  │ 喂鸟器固件  │  │
│  │(Next.js) │  │  (RN)    │  │  (RN)    │  │(MQTT/HTTP) │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────┬──────┘  │
└───────┼─────────────┼─────────────┼───────────────┼─────────┘
        │             │             │               │
        └─────────────┴──────┬──────┘               │
                             ▼                      ▼
┌─────────────────────────────────────────────────────────────┐
│               API Gateway (Nginx / Cloud LB)                │
│            鉴权 · 限流 · 灰度 · SSL · 路由                    │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│            Application Layer (NestJS Monolith)              │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐ │
│  │  Auth  │ │  User  │ │ Video  │ │ Feeder │ │Community │ │
│  │ Module │ │ Module │ │ Module │ │ Module │ │  Module  │ │
│  └────────┘ └────────┘ └────────┘ └────────┘ └──────────┘ │
│  ┌────────┐ ┌────────────┐                                 │
│  │ Admin  │ │Notification│                                 │
│  │ Module │ │   Module   │                                 │
│  └────────┘ └────────────┘                                 │
└───────────┬─────────────┬───────────────────────────────────┘
            │             │
    ┌───────┴───┐    ┌────┴────┐
    ▼           ▼    ▼         ▼
┌────────┐ ┌────────┐ ┌──────────────────┐
│ Postgre│ │ Redis  │ │  BullMQ Workers  │
│  SQL   │ │        │ │ (转码/通知/清理)  │
└────────┘ └────────┘ └──────────────────┘

┌──────────────────────────────────────────────┐
│           Object Storage (S3 / OSS / COS)    │
│         视频文件 · 缩略图 · 头像 · HLS 分片    │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│              CDN / Edge Layer                 │
│           静态资源与视频内容分发                 │
└──────────────────────────────────────────────┘
```

### 8.3 推荐技术栈

| 层级 | 技术建议 | 说明 |
|------|---------|------|
| Web 前端 | Next.js + TypeScript | SEO 与内容站点能力更好 |
| 前端样式 | Tailwind CSS | 高效快速成型 |
| 前端状态 | Zustand | 轻量，学习成本低 |
| Mobile | React Native + TypeScript | iOS / Android 代码复用 |
| Backend | Node.js + NestJS | 模块化与可维护性强，TS 全栈 |
| DB | PostgreSQL | 强一致事务与复杂查询 |
| Cache / Queue | Redis + BullMQ | 缓存、限流、异步任务 |
| Object Storage | S3 / OSS / COS | 视频与静态文件 |
| Transcode | FFmpeg Worker | HLS 多码率输出 |
| Search | PostgreSQL FTS (初期) → OpenSearch (中后期) | 按规模升级 |
| Deploy | Docker + CI/CD | 一致化部署 |
| 认证 | JWT + Argon2/bcrypt | 标准方案 |

### 8.4 部署分层

- **Edge / CDN**：静态资源与视频分发
- **API Gateway**：鉴权、限流、灰度、路由
- **Application**：业务服务（模块化单体）
- **Worker**：转码、缩略图、通知异步任务
- **Data**：PostgreSQL、Redis、对象存储

---

## 9. 数据模型与状态机

### 9.1 核心实体关系

```
users ──< videos         (一对多: 用户上传视频)
users ──< comments       (一对多: 用户发表评论)
users ──< likes          (一对多: 用户点赞)
users ──< follows        (多对多: 关注关系)
users ──< feeders        (一对多: 用户绑定设备)
feeders ──< videos       (一对多: 设备产生视频)
videos ──< comments      (一对多: 视频下的评论)
videos ──< likes         (一对多: 视频的点赞)
videos ──< bird_tags     (一对多: 视频的鸟种标注)
videos ──< reports       (一对多: 视频举报)
users ──< notifications  (一对多: 用户的通知)
```

### 9.2 核心数据表 DDL

**users（用户表）**
```sql
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         VARCHAR(255) UNIQUE NOT NULL,
  username      VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  avatar_url    TEXT,
  bio           TEXT,
  location      VARCHAR(100),
  experience    VARCHAR(20) DEFAULT 'beginner',  -- beginner / enthusiast / expert
  role          VARCHAR(20) DEFAULT 'user',      -- user / moderator / admin
  is_active     BOOLEAN DEFAULT true,
  follower_count  INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  video_count     INTEGER DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
```

**feeders（喂鸟器表）**
```sql
CREATE TABLE feeders (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  serial_number VARCHAR(50) UNIQUE NOT NULL,
  name          VARCHAR(100),
  type          VARCHAR(20) DEFAULT 'private',  -- private / public
  owner_id      UUID REFERENCES users(id) ON DELETE SET NULL,
  location_name VARCHAR(200),
  latitude      DECIMAL(10, 8),
  longitude     DECIMAL(11, 8),
  is_online     BOOLEAN DEFAULT false,
  api_key       VARCHAR(255) UNIQUE NOT NULL,
  bind_code     VARCHAR(20),                    -- 一次性绑定码
  last_seen_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_feeders_owner ON feeders(owner_id);
CREATE INDEX idx_feeders_type ON feeders(type);
```

**videos（视频表）**
```sql
CREATE TABLE videos (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         VARCHAR(200) NOT NULL,
  description   TEXT,
  uploader_id   UUID REFERENCES users(id) ON DELETE SET NULL,
  feeder_id     UUID REFERENCES feeders(id) ON DELETE SET NULL,
  upload_type   VARCHAR(20) NOT NULL,            -- manual / feeder
  visibility    VARCHAR(20) DEFAULT 'public',    -- public / private / unlisted
  status        VARCHAR(20) DEFAULT 'uploaded',  -- uploaded / queued / processing / ready / failed / hidden
  -- 文件信息
  raw_url       TEXT,
  hls_url       TEXT,
  thumbnail_url TEXT,
  duration      INTEGER,       -- 秒
  file_size     BIGINT,        -- 字节
  -- 元数据
  location_name VARCHAR(200),
  latitude      DECIMAL(10, 8),
  longitude     DECIMAL(11, 8),
  recorded_at   TIMESTAMPTZ,
  -- 统计 (冗余计数，异步更新)
  view_count    INTEGER DEFAULT 0,
  like_count    INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,
  -- 审核
  moderation_status VARCHAR(20) DEFAULT 'pending',  -- pending / approved / rejected
  moderated_by  UUID REFERENCES users(id),
  moderated_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_videos_uploader ON videos(uploader_id);
CREATE INDEX idx_videos_feeder ON videos(feeder_id);
CREATE INDEX idx_videos_status ON videos(status);
CREATE INDEX idx_videos_visibility ON videos(visibility);
CREATE INDEX idx_videos_created ON videos(created_at DESC);
```

**bird_tags（鸟种标注表）**
```sql
CREATE TABLE bird_tags (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id        UUID REFERENCES videos(id) ON DELETE CASCADE,
  bird_name       VARCHAR(100) NOT NULL,
  scientific_name VARCHAR(150),
  tagged_by       UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_bird_tags_video ON bird_tags(video_id);
CREATE INDEX idx_bird_tags_name ON bird_tags(bird_name);
```

**comments（评论表）**
```sql
CREATE TABLE comments (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id   UUID REFERENCES videos(id) ON DELETE CASCADE,
  user_id    UUID REFERENCES users(id) ON DELETE SET NULL,
  parent_id  UUID REFERENCES comments(id) ON DELETE CASCADE,
  content    TEXT NOT NULL,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_comments_video ON comments(video_id);
CREATE INDEX idx_comments_parent ON comments(parent_id);
```

**likes（点赞表）**
```sql
CREATE TABLE likes (
  user_id    UUID REFERENCES users(id) ON DELETE CASCADE,
  video_id   UUID REFERENCES videos(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, video_id)
);
```

**follows（关注关系表）**
```sql
CREATE TABLE follows (
  follower_id  UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id),
  CHECK (follower_id != following_id)
);
CREATE INDEX idx_follows_following ON follows(following_id);
```

**reports（举报表）**
```sql
CREATE TABLE reports (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id   UUID REFERENCES users(id),
  target_type   VARCHAR(20) NOT NULL,       -- video / comment / user
  target_id     UUID NOT NULL,
  reason        VARCHAR(50) NOT NULL,       -- spam / inappropriate / copyright / other
  description   TEXT,
  status        VARCHAR(20) DEFAULT 'pending',  -- pending / resolved / dismissed
  resolved_by   UUID REFERENCES users(id),
  resolved_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_target ON reports(target_type, target_id);
```

**notifications（通知表）**
```sql
CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  type        VARCHAR(30) NOT NULL,    -- like / comment / follow / moderation / system
  title       VARCHAR(200),
  body        TEXT,
  data        JSONB,                   -- 携带跳转所需的 video_id / user_id 等
  is_read     BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
```

**moderation_logs（审计日志表）**
```sql
CREATE TABLE moderation_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  operator_id UUID REFERENCES users(id),
  action      VARCHAR(50) NOT NULL,     -- approve / reject / ban / unban / hide / delete
  target_type VARCHAR(20) NOT NULL,     -- video / comment / user / feeder
  target_id   UUID NOT NULL,
  reason      TEXT,
  metadata    JSONB,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_moderation_logs_target ON moderation_logs(target_type, target_id);
CREATE INDEX idx_moderation_logs_operator ON moderation_logs(operator_id);
CREATE INDEX idx_moderation_logs_created ON moderation_logs(created_at DESC);
```

### 9.3 视频状态机

```
uploaded ──→ queued ──→ processing ──→ ready
                            │
                            ▼
                          failed ──→ queued (重试，最多 3 次)

ready ──→ hidden (审核下架)
```

### 9.4 设备状态机

```
unbound ──→ bound_private    (用户绑定)
unbound ──→ public_managed   (管理员配置)

bound_private ──→ unbound    (用户解绑)

bound_private / public_managed:
  offline ←──→ online        (由心跳驱动，超时自动离线)
```

---

## 10. API 规范

### 10.1 通用规范

- **Base Path**：`/api/v1`
- **Auth**：`Authorization: Bearer <token>`
- **Device Auth**：`X-Device-Key` + `X-Device-Signature` + `X-Timestamp`
- **分页**：优先游标分页 `next_cursor`；管理后台可用 offset 分页
- **幂等**：上传创建接口支持 `Idempotency-Key`
- **错误码格式**：

```json
{
  "code": "VIDEO_NOT_FOUND",
  "message": "Video does not exist",
  "request_id": "req_xxx"
}
```

### 10.2 核心接口分组

| 分组 | 前缀 | 说明 |
|------|------|------|
| 认证 | `auth/*` | 注册、登录、Token 刷新、密码找回 |
| 用户 | `users/*` | 资料、主页、关注关系 |
| 视频 | `videos/*` | 上传、播放、元数据、点赞、评论 |
| 喂鸟器 | `feeders/*` | 绑定、解绑、列表、详情 |
| 社区 | `community/*` | 举报 |
| 通知 | `notifications/*` | 通知列表、已读标记 |
| 管理 | `admin/*` | 用户管理、视频审核、设备管理、统计 |
| 设备 | `device/*` | 设备上传、心跳（API Key 认证） |

### 10.3 核心端点详情

**认证模块**
```
POST   /api/v1/auth/register          # 注册
POST   /api/v1/auth/login             # 登录
POST   /api/v1/auth/logout            # 登出
POST   /api/v1/auth/refresh           # 刷新 Token
POST   /api/v1/auth/forgot-password   # 忘记密码
POST   /api/v1/auth/reset-password    # 重置密码
```

**用户模块**
```
GET    /api/v1/users/:id              # 获取用户信息
PUT    /api/v1/users/me               # 更新个人资料
POST   /api/v1/users/me/avatar        # 上传头像
GET    /api/v1/users/:id/videos       # 用户的视频列表
GET    /api/v1/users/:id/followers    # 粉丝列表
GET    /api/v1/users/:id/following    # 关注列表
POST   /api/v1/users/:id/follow       # 关注用户
DELETE /api/v1/users/:id/follow       # 取消关注
```

**视频模块**
```
GET    /api/v1/videos                 # 视频列表 (Feed / 搜索)
POST   /api/v1/videos/upload          # 请求上传凭证
POST   /api/v1/videos/upload/complete # 上传完成回调
GET    /api/v1/videos/:id             # 视频详情
PUT    /api/v1/videos/:id             # 更新视频信息
DELETE /api/v1/videos/:id             # 删除视频
POST   /api/v1/videos/:id/like        # 点赞
DELETE /api/v1/videos/:id/like        # 取消点赞
GET    /api/v1/videos/:id/comments    # 获取评论
POST   /api/v1/videos/:id/comments    # 发表评论
DELETE /api/v1/videos/:id/comments/:cid # 删除评论
```

**喂鸟器模块**
```
GET    /api/v1/feeders                # 我的喂鸟器列表
POST   /api/v1/feeders/bind           # 绑定喂鸟器
DELETE /api/v1/feeders/:id/bind       # 解绑喂鸟器
GET    /api/v1/feeders/:id            # 喂鸟器详情
GET    /api/v1/feeders/public         # 公有喂鸟器列表
GET    /api/v1/feeders/:id/videos     # 喂鸟器视频列表
```

**通知模块**
```
GET    /api/v1/notifications          # 通知列表
PUT    /api/v1/notifications/read     # 批量标记已读
GET    /api/v1/notifications/unread-count  # 未读数
```

**举报模块**
```
POST   /api/v1/reports                # 提交举报
```

**设备端 API（API Key 认证）**
```
POST   /api/v1/device/upload          # 设备上传视频
POST   /api/v1/device/heartbeat       # 设备心跳
GET    /api/v1/device/config          # 获取设备配置 (拍摄计划等)
```

**管理后台**
```
GET    /api/v1/admin/users            # 用户列表
PUT    /api/v1/admin/users/:id        # 更新用户状态 (封禁/解封/角色)
GET    /api/v1/admin/videos           # 视频审核列表
PUT    /api/v1/admin/videos/:id/moderate  # 审核视频
GET    /api/v1/admin/feeders          # 喂鸟器管理列表
PUT    /api/v1/admin/feeders/:id      # 更新喂鸟器配置
GET    /api/v1/admin/reports          # 举报列表
PUT    /api/v1/admin/reports/:id      # 处理举报
GET    /api/v1/admin/stats            # 数据统计
POST   /api/v1/admin/announcements    # 发布公告
```

---

## 11. 数据统计与分析

### 11.1 事件埋点

| 事件 | 说明 |
|------|------|
| user_signup | 用户注册 |
| user_login | 用户登录 |
| video_upload_started | 开始上传 |
| video_upload_completed | 上传完成 |
| video_play_started | 开始播放 |
| video_play_failed | 播放失败 |
| feeder_bind_success | 设备绑定成功 |
| feeder_upload_completed | 设备上传完成 |
| like_created | 点赞 |
| comment_created | 评论 |
| search_executed | 搜索执行 |
| notification_opened | 通知打开 |

### 11.2 看板分层

- **业务看板**：DAU / WAU、留存、上传量、活跃设备率
- **内容看板**：审核积压、热门物种、热点地区
- **技术看板**：API 延迟、错误率、转码队列积压、CDN 命中率

---

## 12. 团队角色与任务分工

### 12.1 推荐团队配置

| 角色 | 人数 | 职责概述 |
|------|------|---------|
| 项目经理 (PM) | 1 | 需求管理、排期、跨团队协调、文档维护、风险跟踪 |
| 后端工程师 | 2 | API 开发、数据库、转码服务、设备接入 |
| Web 前端工程师 | 1 | Next.js Web 端 + Admin 管理后台 |
| 移动端工程师 | 1-2 | React Native iOS / Android |
| UI/UX 设计师 | 1 | 交互设计、视觉规范、Design Token |
| QA 工程师 | 1 | 测试计划、自动化测试、性能测试 |
| DevOps / SRE | 0.5 (兼任) | CI/CD、部署、监控、告警 |

### 12.2 各 Phase 任务分工矩阵

> **L** = Lead (主责)，**S** = Support (辅助)，**R** = Review (评审)

| 任务域 | PM | 后端 | Web 前端 | 移动端 | 设计 | QA | DevOps |
|--------|-----|------|---------|--------|------|-----|--------|
| **Phase 0: 项目启动** | | | | | | | |
| PRD 定稿与评审 | L | R | R | R | R | R | — |
| 架构设计 (ADR) | S | L | S | S | — | — | R |
| UI/UX 设计规范 | R | — | S | S | L | — | — |
| 开发环境与仓库 | S | S | S | — | — | — | L |
| **Phase 1: 基础设施与账户** | | | | | | | |
| Monorepo + CI/CD | — | S | S | — | — | — | L |
| Auth 模块 (后端) | — | L | — | — | — | S | — |
| 注册 / 登录 / 资料 (Web) | — | S | L | — | S | S | — |
| 安全基线验证 | R | S | — | — | — | L | S |
| **Phase 2: 视频主链路 MVP** | | | | | | | |
| 上传 / 转码 / 存储 (后端) | — | L | — | — | — | S | S |
| 视频列表 / 详情 / 播放 (Web) | — | S | L | — | S | S | — |
| 点赞 / 评论 (后端 + Web) | — | L | S | — | — | S | — |
| 个人主页 (Web) | — | S | L | — | S | — | — |
| 性能压测 | R | S | — | — | — | L | S |
| **Phase 3: 社区与发现** | | | | | | | |
| 关注系统 + Feed | — | L | S | — | — | S | — |
| 搜索与筛选 | — | L | S | — | S | S | — |
| 通知系统 | — | L | S | — | S | S | — |
| 举报 | — | S | S | — | — | L | — |
| **Phase 4: 管理后台** | | | | | | | |
| 用户治理 & 内容审核 (后端) | — | L | — | — | — | S | — |
| Admin Dashboard (Web) | — | S | L | — | S | S | — |
| 运营看板与统计 | S | L | S | — | — | R | S |
| **Phase 5: 喂鸟器集成** | | | | | | | |
| 设备 API & 鉴权 (后端) | — | L | — | — | — | S | S |
| 设备管理界面 (Web) | — | S | L | — | S | S | — |
| 心跳 & 状态监控 | — | L | — | — | — | S | S |
| 设备端协议联调 | R | L | — | — | — | L | — |
| **Phase 6: 移动端发布** | | | | | | | |
| RN 框架搭建 & 共享组件 | — | S | S | L | S | — | — |
| 核心功能移植 (上传/播放/互动) | — | S | — | L | S | S | — |
| 设备绑定 (移动端) | — | S | — | L | S | S | — |
| 应用商店提审 | L | — | — | S | — | S | — |
| Crash & 性能优化 | — | — | — | L | — | L | S |

### 12.3 关键协作约定

- **每日站会**：15 分钟，各成员同步进度与阻塞
- **每周 Demo**：周五下午，演示本周交付物
- **代码评审**：所有 PR 至少 1 名 reviewer 批准
- **设计评审**：每个 Phase 开始前完成该 Phase 的设计稿评审
- **Sprint 周期**：2 周一个 Sprint，Sprint 结束前完成回顾

---

## 13. 工程实施步骤与里程碑

> ⚠️ **Phase 顺序调整说明**：根据项目优先级，喂鸟器集成（Phase 5）调整到管理后台（Phase 4）之后、移动端（Phase 6）之前实施。这样可以先确保平台核心体验稳定，再接入硬件设备，最后发布移动端。

### Phase 0: 项目启动与澄清（2 周）

**目标**：冻结范围，对齐团队

- [ ] PRD v2.1 定稿（本文档评审通过）
- [ ] 架构 ADR（关键技术决策记录）
- [ ] UI/UX 设计规范 v1（Design Token、组件库方向）
- [ ] 风险清单与里程碑确认
- [ ] Monorepo 仓库创建、分支策略确定

**Exit Criteria**：范围冻结 (P0/P1)，团队角色明确，开发环境与仓库策略确定

**里程碑**：M0 — 项目 Kickoff 完成

---

### Phase 1: 基础设施与账户系统（3 周）

**目标**：注册登录可用，安全基线通过

- [ ] Monorepo 初始化 (NestJS + Next.js)
- [ ] CI/CD 流水线搭建，环境分层 (dev / stage / prod)
- [ ] PostgreSQL + Redis 部署
- [ ] Auth 模块：注册、登录、Token 刷新、密码找回
- [ ] 用户资料：头像、昵称、简介、地区
- [ ] 安全基线：密码哈希、Token 过期、API 限流

**Exit Criteria**：注册登录可用，安全基线通过，单元测试覆盖率达到最低门槛

**里程碑**：M1 — 账户系统上线 Stage

---

### Phase 2: 视频主链路 MVP（4 周）

**目标**：上传 → 转码 → 播放 全链路跑通

- [ ] 视频上传（断点续传、直传 S3/OSS）
- [ ] FFmpeg 转码 Worker (BullMQ)
- [ ] HLS 多码率输出 + 缩略图生成
- [ ] 视频列表页 + 详情页 + 播放器
- [ ] 点赞、评论（含二级回复）
- [ ] 个人主页与作品列表
- [ ] 可见性控制 (public / private / unlisted)

**Exit Criteria**：上传 → 可播成功率 ≥ 98%，播放成功率 ≥ 99%，关键接口压测达标

**里程碑**：M2 — Web MVP 可内测

---

### Phase 3: 社区与发现（4 周）

**目标**：社区互动与内容发现基础能力

- [ ] 关注系统
- [ ] 首页 Feed（关注 + 推荐，含冷启动策略）
- [ ] 搜索与筛选（鸟种、地区、用户）
- [ ] 通知系统（点赞、评论、关注、审核结果）
- [ ] 举报功能

**Exit Criteria**：Feed 接口性能达标，审核 SLA 可观测且可追责

**里程碑**：M3 — 社区功能上线

---

### Phase 4: 管理后台（3 周）

**目标**：审核流程闭环，运营可自助

- [ ] Admin Dashboard 框架搭建
- [ ] 用户管理（封禁 / 解封 / 角色调整）
- [ ] 视频审核队列（支持批量审核）
- [ ] 举报处理
- [ ] 运营指标看板（DAU、上传量、播放成功率）
- [ ] 系统公告发布

**Exit Criteria**：审核流程闭环，关键报表准确率 ≥ 99%

**里程碑**：M4 — 管理后台上线

---

### Phase 5: 喂鸟器集成（4 周）⬅️ 原 Phase 3，调整至管理后台之后

**目标**：设备接入链路稳定，归属逻辑正确

- [ ] 设备 API 设计与实现（API Key + 签名认证）
- [ ] 设备绑定 / 解绑（扫码 / 序列号 + 绑定码）
- [ ] 心跳上报与在线状态管理
- [ ] 设备自动上传视频
- [ ] 私有 / 公有归属逻辑
- [ ] 设备管理界面（Web Admin 扩展）
- [ ] 拍摄计划配置下发

**Exit Criteria**：设备上传链路稳定，在线状态准确率 ≥ 95%，归属数据无错配

**里程碑**：M5 — 喂鸟器接入验证完成

---

### Phase 6: 移动端发布（6 周）

**目标**：iOS / Android 首版上线

- [ ] React Native 框架搭建与共享组件
- [ ] 核心功能移植：上传、播放、互动、Feed、通知
- [ ] 设备绑定（移动端扫码）
- [ ] 崩溃与性能优化
- [ ] 应用商店审核与上架

**Exit Criteria**：Crash-free sessions ≥ 99.5%，应用商店首版上线

**里程碑**：M6 — 全端发布

---

### 整体时间线概览

```
Week:  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
       ├──┤  ├─────┤  ├────────┤  ├────────┤  ├──────┤  ├────────┤  ├───────────────┤
       P0     P1        P2          P3         P4        P5          P6
      启动   基础设施    视频MVP     社区发现   管理后台   喂鸟器      移动端
             账户系统                                     集成        发布
       M0    M1         M2          M3         M4        M5          M6
```

---

## 14. 质量保障与发布门禁

### 14.1 测试策略

| 测试类型 | 范围 | 工具建议 |
|---------|------|---------|
| 单元测试 | 业务核心逻辑 | Jest |
| 集成测试 | DB、缓存、队列、对象存储联动 | Jest + Testcontainers |
| E2E 测试 | 注册、上传、播放、评论、设备上传主链路 | Playwright (Web) / Detox (Mobile) |
| 性能测试 | Feed 与播放接口 | k6 / Artillery |
| 安全测试 | 鉴权、注入、越权、上传漏洞 | OWASP ZAP / 手动渗透 |

### 14.2 门禁标准

- PR 必须通过 lint + test + typecheck
- 关键模块代码评审至少 1 名 reviewer
- 发布前必须通过 smoke test
- S1 / S2 缺陷未清零不得发布生产

---

## 15. 运维与 SRE 要求

- **环境**：dev / stage / prod 严格隔离
- **数据备份**：PostgreSQL 每日全量 + 增量日志
- **灾备目标**：RPO ≤ 15 分钟，RTO ≤ 1 小时
- **灰度发布**：按用户比例逐步放量
- **回滚策略**：保留前一版本镜像与数据库回滚脚本

---

## 16. 风险与应对

| 风险 | 影响 | 应对措施 | Owner |
|------|------|---------|-------|
| 视频成本快速增长 | 高 | 分层存储 + 转码策略优化 + CDN 策略 | 后端 + DevOps |
| 审核压力导致体验下降 | 高 | 规则初筛 + 人工复核 + SLA 监控 | PM + QA |
| 设备协议不稳定 | 中 | 设备 SDK 标准化 + 回放重传机制 | 后端 |
| 多端一致性问题 | 中 | 统一 API 契约 + 自动化 E2E | 全团队 |
| 冷启动内容不足 | 中 | 公有喂鸟器优先供给 + 运营任务 | PM |
| 关键人员离职 | 中 | 文档驱动 + 代码评审 + 知识分享 | PM |
| 移动端审核被拒 | 低 | 提前研究平台政策，预留 buffer | 移动端 + PM |

---

## 17. 待确认事项 (Open Questions)

| # | 问题 | 影响范围 | 决策截止日期 | 当前倾向 |
|---|------|---------|------------|---------|
| OQ-1 | 是否在首发版本引入第三方登录 (Apple/Google)？ | Auth, Phase 1 | Phase 0 结束前 | 建议 P1，首发后迭代 |
| OQ-2 | 是否引入地理位置隐私模糊机制（坐标脱敏）？ | 视频表、喂鸟器表 | Phase 2 开始前 | 建议引入，精度降至 ±1km |
| OQ-3 | 公有喂鸟器内容是否允许商业赞助位？ | 视频 Feed、管理后台 | Phase 5 开始前 | 待商业讨论 |
| OQ-4 | 是否在首发版本支持多语言 (中/英)？ | 全端 | Phase 0 结束前 | 建议初版仅中文 |
| OQ-5 | 视频上传大小限制是 500MB 还是 1GB？ | 存储成本、转码策略 | Phase 2 开始前 | 建议 1GB（支持长时间喂鸟器录像） |
| OQ-6 | 设备固件 SDK 由谁提供？是否已有现成方案？ | Phase 5 排期 | Phase 4 结束前 | 待确认 |

---

## 18. 附录

### 18.1 第一里程碑交付清单 (M1)

M1 目标日期建议：**2026-04-17**

- [ ] PRD / 架构评审完成并冻结 P0
- [ ] 仓库初始化与 CI 流水线可用
- [ ] Auth + User Profile 上线到 stage
- [ ] 安全基线通过（密码、Token、限流）
- [ ] 可观测性最小集（日志、指标、告警）上线

### 18.2 文档清单与维护计划

| 文档 | 维护人 | 更新频率 |
|------|--------|---------|
| PRD (本文档) | PM | 每个 Phase 开始前更新 |
| 技术设计文档 (TDD) | 后端 Lead | 每个 Phase 开始前产出 |
| API 文档 (OpenAPI) | 后端 | 随代码自动生成 |
| UI/UX 设计稿 | 设计师 | 每个 Phase 开始前交付 |
| 测试计划 | QA | 每个 Phase 开始前产出 |
| 运维手册 | DevOps | Phase 1 产出，持续更新 |
| 设备接入协议文档 | 后端 | Phase 5 开始前产出 |

### 18.3 文档维护原则

- 每个迭代结束更新一次变更记录
- 新增需求必须标注优先级、业务价值、技术影响
- 涉及跨团队影响的条目必须补充验收标准
- 所有产品文档由 PM 统一维护和发布

---

## 📋 需要你协助的 TODO

> 以下事项需要产品负责人确认或提供信息，请逐项回复：

**🔴 阻塞性（影响 Phase 0 结束）：**

1. **OQ-1 决策**：首发版本是否包含第三方登录？（影响 Auth 模块工作量估算）
不需要
2. **OQ-4 决策**：首发版本是否需要多语言？（影响全端工作量）
不需要，首发版本仅需要简体中文，英文语言在全部上线后再进行翻译，项目语言包保持独立，这样我我仅需配置不同语言包就可以继续更新了
3. **团队配置确认**：上述 12.1 的团队配置是否符合实际？是否有人员限制？
没有人员限制
4. **里程碑日期确认**：M1 暂定 2026-04-17（Phase 0 从下周开始计），是否可接受？
可以
**🟡 重要（影响 Phase 1-2 开始）：**

5. **OQ-2 决策**：是否需要坐标脱敏？（影响数据库字段设计）
需要
6. **OQ-5 决策**：视频大小上限 500MB 还是 1GB？（影响上传策略与成本估算）
视频暂时设定为：2分钟以内，H.265编码、2k分辨率的影片，据此估算大小上限
7. **云厂商选择**：AWS / 阿里云 / 其他？（影响基础设施搭建）
同时考虑AWS和aliyun，最好是有cli功能的，我需要帮我搭建。测试阶段在本地进行测试
8. **设计师资源**：是否已有设计师，还是需要招聘/外包？
设计师资源已经完善。

**🟢 可延后（Phase 4 之前确认即可）：**

9. **OQ-3 决策**：公有喂鸟器是否允许商业赞助位？
10. **OQ-6 决策**：设备固件 SDK 来源？是否有硬件合作方提供？
关于喂鸟器部分，最后实现，设备SDK暂时还未确认

---

*文档维护人：PM (Claude) · 下次更新预计：Phase 0 评审会后*
