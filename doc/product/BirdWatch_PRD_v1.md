# 🐦 BirdWatch Community — 产品需求与系统设计文档 v1.0

**项目代号：** BirdWatch  
**文档版本：** v1.0  
**创建日期：** 2026-03-08  
**状态：** 草稿 · 待评审

---

## 目录

1. [项目概述](#1-项目概述)
2. [用户角色定义](#2-用户角色定义)
3. [核心功能需求](#3-核心功能需求)
4. [技术架构设计](#4-技术架构设计)
5. [数据库设计](#5-数据库设计)
6. [API 设计规范](#6-api-设计规范)
7. [开发路线图](#7-开发路线图)
8. [技术栈选择](#8-技术栈选择)

---

## 1. 项目概述

### 1.1 产品定位

BirdWatch 是一个面向观鸟爱好者的社区平台，连接人与自然。用户可以分享观鸟视频、通过智能喂鸟器自动采集鸟类活动画面，并在社区内交流讨论。

### 1.2 核心价值主张

| 价值点 | 描述 |
|--------|------|
| 🎥 内容共享 | 用户上传观鸟视频，与社区分享发现 |
| 🤖 智能采集 | 智能喂鸟器自动拍摄并上传鸟类活动视频 |
| 🌐 社区互动 | 点赞、评论、关注、鸟种标注 |
| 📊 数据洞察 | 鸟类出现频率、地理分布统计 |

### 1.3 目标用户

- 休闲观鸟爱好者（主要群体）
- 专业鸟类学研究者
- 自然摄影师
- 智能硬件（喂鸟器）用户

---

## 2. 用户角色定义

```
┌─────────────────────────────────────────────────┐
│                  用户角色体系                     │
├──────────────┬──────────────┬───────────────────┤
│   访客        │   注册用户   │      管理员        │
│  (Guest)     │   (User)    │    (Admin)         │
├──────────────┼──────────────┼───────────────────┤
│ • 浏览公开视频 │ • 所有访客权限 │ • 所有用户权限     │
│ • 搜索内容    │ • 上传视频    │ • 用户管理         │
│ • 查看用户主页 │ • 点赞/评论   │ • 内容审核         │
│              │ • 关注用户    │ • 数据统计         │
│              │ • 绑定喂鸟器  │ • 系统配置         │
│              │ • 管理个人喂鸟器│ • 喂鸟器管理      │
└──────────────┴──────────────┴───────────────────┘
```

---

## 3. 核心功能需求

### 3.1 用户系统 (Auth & Profile)

**注册/登录**
- [ ] 邮箱 + 密码注册
- [ ] Google / Apple 第三方登录（后期）
- [ ] JWT Token 认证
- [ ] 忘记密码 / 邮件重置

**个人资料**
- [ ] 头像、昵称、个人简介
- [ ] 所在地区（用于地图展示）
- [ ] 观鸟经验等级（新手/爱好者/专家）
- [ ] 上传视频列表
- [ ] 关注/粉丝列表

### 3.2 视频系统 (Video)

**手动上传**
- [ ] 支持 MP4 / MOV 格式，最大 500MB
- [ ] 上传时填写：标题、描述、拍摄地点、鸟种标注
- [ ] 视频缩略图自动生成
- [ ] 公开 / 私有 设置

**自动上传（喂鸟器）**
- [ ] 喂鸟器通过 API Key 推送视频
- [ ] 自动关联绑定用户（私有喂鸟器）
- [ ] 公有喂鸟器视频归入公共频道

**视频播放**
- [ ] 流媒体播放（HLS 协议）
- [ ] 视频质量自适应
- [ ] 支持手机横竖屏

### 3.3 喂鸟器系统 (Feeder)

```
喂鸟器类型：
┌─────────────────────┬──────────────────────────┐
│   私有喂鸟器          │      公有喂鸟器            │
│  (Private Feeder)   │   (Public Feeder)        │
├─────────────────────┼──────────────────────────┤
│ • 绑定特定用户账户    │ • 不绑定任何用户            │
│ • 视频归属该用户      │ • 视频归入公共池            │
│ • 用户可管理设备      │ • 由管理员管理              │
│ • 设备状态实时查看    │ • 可能有赞助商信息           │
└─────────────────────┴──────────────────────────┘
```

**喂鸟器管理**
- [ ] 用户扫码/输入序列号绑定喂鸟器
- [ ] 查看设备在线状态
- [ ] 设置拍摄计划（定时/触发式）
- [ ] 解绑喂鸟器

### 3.4 社区互动 (Community)

- [ ] 点赞视频
- [ ] 评论（支持回复嵌套，最多2层）
- [ ] 关注用户
- [ ] 消息通知（点赞/评论/关注）
- [ ] 视频举报

### 3.5 发现与搜索 (Discovery)

- [ ] 首页Feed流（关注的人 + 推荐）
- [ ] 按鸟种搜索
- [ ] 按地区筛选
- [ ] 按喂鸟器筛选
- [ ] 热门/最新排序

### 3.6 管理后台 (Admin Dashboard)

- [ ] 用户列表管理（封禁/解封）
- [ ] 视频审核队列
- [ ] 喂鸟器管理
- [ ] 数据统计仪表盘
  - 日活用户
  - 视频上传量
  - 各鸟种出现频率
- [ ] 系统公告发布

---

## 4. 技术架构设计

### 4.1 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        客户端层                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  │
│  │  Web App  │  │ iOS App  │  │Android   │  │ 喂鸟器固件  │  │
│  │(React)   │  │(后期)    │  │(后期)    │  │(MQTT/HTTP) │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────┬──────┘  │
└───────┼─────────────┼─────────────┼───────────────┼─────────┘
        │             │             │               │
        └─────────────┴──────┬──────┘               │
                             ▼                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    API 网关层 (Nginx)                         │
│              负载均衡 / 限流 / SSL终止                         │
└─────────────────────────┬───────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  用户服务     │  │  视频服务     │  │  设备服务     │
│ (Node.js)   │  │ (Node.js)   │  │ (Node.js)   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                  │
       └────────┬─────────┘                  │
                ▼                           ▼
┌──────────────────────┐    ┌──────────────────────┐
│   PostgreSQL         │    │   Redis              │
│   (主数据库)          │    │   (缓存/Session)      │
└──────────────────────┘    └──────────────────────┘
                                    
┌──────────────────────────────────────────────┐
│           云存储 (AWS S3 / 阿里云OSS)          │
│         视频文件 / 缩略图 / 头像               │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│           视频处理服务 (FFmpeg)                │
│    转码 / 生成HLS / 提取缩略图                  │
└──────────────────────────────────────────────┘
```

### 4.2 前端架构

```
前端 (React + TypeScript)
├── src/
│   ├── pages/          # 页面组件
│   │   ├── Home/       # 首页Feed
│   │   ├── Video/      # 视频详情
│   │   ├── Profile/    # 用户主页
│   │   ├── Upload/     # 上传页
│   │   ├── Feeder/     # 喂鸟器管理
│   │   └── Admin/      # 管理后台
│   ├── components/     # 通用组件
│   ├── hooks/          # 自定义Hook
│   ├── store/          # 状态管理(Zustand)
│   ├── api/            # API请求封装
│   └── utils/          # 工具函数
```

---

## 5. 数据库设计

### 5.1 核心数据表

**users（用户表）**
```sql
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       VARCHAR(255) UNIQUE NOT NULL,
  username    VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  avatar_url  TEXT,
  bio         TEXT,
  location    VARCHAR(100),
  role        ENUM('user', 'admin') DEFAULT 'user',
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMP DEFAULT NOW(),
  updated_at  TIMESTAMP DEFAULT NOW()
);
```

**feeders（喂鸟器表）**
```sql
CREATE TABLE feeders (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  serial_number VARCHAR(50) UNIQUE NOT NULL,  -- 设备序列号
  name         VARCHAR(100),
  type         ENUM('private', 'public') DEFAULT 'private',
  owner_id     UUID REFERENCES users(id),     -- NULL = 公有喂鸟器
  location_name VARCHAR(200),
  latitude     DECIMAL(10, 8),
  longitude    DECIMAL(11, 8),
  is_online    BOOLEAN DEFAULT false,
  api_key      VARCHAR(255) UNIQUE NOT NULL,  -- 设备认证密钥
  last_seen_at TIMESTAMP,
  created_at   TIMESTAMP DEFAULT NOW()
);
```

**videos（视频表）**
```sql
CREATE TABLE videos (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title        VARCHAR(200) NOT NULL,
  description  TEXT,
  uploader_id  UUID REFERENCES users(id),     -- NULL = 公有喂鸟器上传
  feeder_id    UUID REFERENCES feeders(id),   -- NULL = 手动上传
  upload_type  ENUM('manual', 'feeder') NOT NULL,
  visibility   ENUM('public', 'private') DEFAULT 'public',
  status       ENUM('processing', 'ready', 'failed') DEFAULT 'processing',
  -- 文件信息
  raw_url      TEXT,        -- 原始文件
  hls_url      TEXT,        -- 转码后播放地址
  thumbnail_url TEXT,
  duration     INTEGER,     -- 秒
  file_size    BIGINT,      -- 字节
  -- 元数据
  location_name VARCHAR(200),
  latitude     DECIMAL(10, 8),
  longitude    DECIMAL(11, 8),
  recorded_at  TIMESTAMP,
  -- 统计
  view_count   INTEGER DEFAULT 0,
  like_count   INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,
  created_at   TIMESTAMP DEFAULT NOW()
);
```

**bird_tags（鸟种标注表）**
```sql
CREATE TABLE bird_tags (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id  UUID REFERENCES videos(id) ON DELETE CASCADE,
  bird_name VARCHAR(100) NOT NULL,   -- 中文名
  scientific_name VARCHAR(150),      -- 学名
  tagged_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

**comments（评论表）**
```sql
CREATE TABLE comments (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id  UUID REFERENCES videos(id) ON DELETE CASCADE,
  user_id   UUID REFERENCES users(id),
  parent_id UUID REFERENCES comments(id),  -- NULL = 顶层评论
  content   TEXT NOT NULL,
  is_deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**likes（点赞表）**
```sql
CREATE TABLE likes (
  user_id  UUID REFERENCES users(id),
  video_id UUID REFERENCES videos(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, video_id)
);
```

**follows（关注关系表）**
```sql
CREATE TABLE follows (
  follower_id  UUID REFERENCES users(id),
  following_id UUID REFERENCES users(id),
  created_at   TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);
```

---

## 6. API 设计规范

### 6.1 基础规范

- 基础路径：`/api/v1`
- 格式：JSON
- 认证：`Authorization: Bearer <JWT Token>`
- 设备认证：`X-API-Key: <Feeder API Key>`

### 6.2 核心 API 端点

**认证模块**
```
POST   /api/v1/auth/register      # 注册
POST   /api/v1/auth/login         # 登录
POST   /api/v1/auth/logout        # 登出
POST   /api/v1/auth/refresh       # 刷新Token
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
```

**用户模块**
```
GET    /api/v1/users/:id          # 获取用户信息
PUT    /api/v1/users/me           # 更新个人资料
POST   /api/v1/users/me/avatar    # 上传头像
GET    /api/v1/users/:id/videos   # 用户的视频列表
POST   /api/v1/users/:id/follow   # 关注用户
DELETE /api/v1/users/:id/follow   # 取消关注
```

**视频模块**
```
GET    /api/v1/videos             # 视频列表(Feed/搜索)
POST   /api/v1/videos/upload      # 上传视频（手动）
GET    /api/v1/videos/:id         # 视频详情
PUT    /api/v1/videos/:id         # 更新视频信息
DELETE /api/v1/videos/:id         # 删除视频
POST   /api/v1/videos/:id/like    # 点赞
DELETE /api/v1/videos/:id/like    # 取消点赞
GET    /api/v1/videos/:id/comments # 获取评论
POST   /api/v1/videos/:id/comments # 发表评论
```

**喂鸟器模块**
```
GET    /api/v1/feeders            # 我的喂鸟器列表
POST   /api/v1/feeders/bind       # 绑定喂鸟器
DELETE /api/v1/feeders/:id/bind   # 解绑喂鸟器
GET    /api/v1/feeders/:id        # 喂鸟器详情
GET    /api/v1/feeders/public     # 公有喂鸟器列表

# 设备端API（用API Key认证）
POST   /api/v1/device/upload      # 设备上传视频
POST   /api/v1/device/heartbeat   # 设备心跳
```

**管理后台**
```
GET    /api/v1/admin/users        # 用户管理
PUT    /api/v1/admin/users/:id    # 更新用户状态
GET    /api/v1/admin/videos       # 视频审核列表
PUT    /api/v1/admin/videos/:id   # 审核视频
GET    /api/v1/admin/feeders      # 喂鸟器管理
GET    /api/v1/admin/stats        # 数据统计
```

---

## 7. 开发路线图

### Phase 1 — MVP（第1-2个月）✅ 当前目标

**目标：能跑通核心流程**

- [ ] **Week 1-2：** 项目初始化 + 用户注册登录
- [ ] **Week 3-4：** 视频上传 + 基础播放
- [ ] **Week 5-6：** 视频列表 + 详情页
- [ ] **Week 7-8：** 点赞评论 + 个人主页

**交付物：** 可运行的 Web MVP，用户可以注册、上传、播放视频

---

### Phase 2 — 喂鸟器集成（第3个月）

- [ ] 喂鸟器设备API设计与实现
- [ ] 私有/公有喂鸟器管理界面
- [ ] 设备状态监控

---

### Phase 3 — 社区功能（第4个月）

- [ ] 关注系统 + 个性化Feed
- [ ] 消息通知系统
- [ ] 鸟种标注 + 搜索

---

### Phase 4 — 管理后台（第5个月）

- [ ] 完整管理后台
- [ ] 数据统计仪表盘
- [ ] 内容审核系统

---

### Phase 5 — 移动端（第6个月+）

- [ ] iOS App（React Native）
- [ ] Android App（React Native）

---

## 8. 技术栈选择

### 8.1 最终技术决策

| 层级 | 技术 | 选择理由 |
|------|------|---------|
| **前端框架** | React + TypeScript | 生态最大，学习资源丰富，适合新手 |
| **前端样式** | Tailwind CSS | 高效，无需手写CSS，快速成型 |
| **前端状态** | Zustand | 比Redux简单10倍 |
| **后端框架** | Node.js + Express | JS全栈，降低学习成本 |
| **数据库** | PostgreSQL | 功能强大，适合生产环境 |
| **缓存** | Redis | Session管理 + 数据缓存 |
| **视频存储** | 云存储(S3/OSS) | 专业存储，CDN加速 |
| **视频处理** | FFmpeg | 业界标准，免费 |
| **容器化** | Docker + Docker Compose | 环境一致，部署简单 |
| **认证** | JWT + bcrypt | 标准方案 |

### 8.2 开发工具

| 工具 | 用途 |
|------|------|
| VS Code | 代码编辑器 |
| Postman | API测试 |
| TablePlus | 数据库管理 |
| Git + GitHub | 版本控制 |

---

## 下一步行动

**✅ 本文档完成后，下一步是：**

1. **搭建开发环境** — 安装Node.js, PostgreSQL, Docker
2. **初始化项目结构** — 前后端代码骨架
3. **实现用户注册登录** — 第一个可运行的功能

---

*文档维护：随项目进展持续更新*

# BirdWatch Community PRD v2.0

项目代号: BirdWatch  
文档版本: v2.0  
文档日期: 2026-03-08  
文档状态: Draft for Review  
适用范围: Web + iOS + Android + 设备端(智能喂鸟器) + 管理后台

---

## 1. 文档目标

本 PRD 目标是把 BirdWatch 从概念文档升级为可执行的商业项目需求基线，用于:

- 产品、研发、测试、运维、数据、运营的跨团队对齐
- 分阶段排期、资源评估、验收标准制定
- 上线后的持续迭代与质量门禁

---

## 2. 产品愿景与范围

### 2.1 产品愿景

BirdWatch 是一个连接观鸟爱好者、智能喂鸟硬件和生态数据的社区平台。  
用户既可以手动上传观鸟视频，也可以通过绑定喂鸟器自动采集视频，形成持续的内容流和社区互动。

### 2.2 商业目标 (12个月)

- 建立稳定的 UGC + 设备内容供给双引擎
- 建立活跃社区，提高留存与互动深度
- 支撑未来会员、设备订阅、品牌合作等商业化能力

### 2.3 北极星指标与核心 KPI

| 指标 | 定义 | 目标(上线后6个月) |
| --- | --- | --- |
| WAU | 周活跃用户数 | >= 30,000 |
| WUV | 周上传有效视频用户数 | >= 6,000 |
| Device Active Rate | 周活跃喂鸟器占比 | >= 55% |
| D30 Retention | 新用户30日留存 | >= 25% |
| Moderation SLA | 视频审核处理时长P95 | <= 24h |
| Playback Success | 视频播放成功率 | >= 99.0% |

### 2.4 In Scope (v2 范围)

- 用户系统: 注册登录、资料、权限、账号安全
- 视频系统: 手动上传、设备自动上传、转码播放、可见性
- 喂鸟器系统: 私有/公有设备管理、绑定解绑、状态心跳
- 社区系统: 点赞、评论、关注、举报、通知
- 发现系统: Feed、搜索、筛选、排序
- 管理后台: 用户治理、内容审核、设备管理、运营看板
- 多端支持: Web、iOS、Android

### 2.5 Out of Scope (当前版本不做)

- 实时直播
- 复杂社交关系(群组、私信IM)
- 自动物种识别模型训练平台
- 多租户SaaS隔离能力

---

## 3. 用户角色与权限

### 3.1 角色定义

- Guest: 游客，未登录
- User: 注册用户
- Moderator: 内容审核员
- Admin: 平台管理员
- Device: 设备身份(喂鸟器 API 客户端)

### 3.2 权限矩阵 (核心)

| 能力 | Guest | User | Moderator | Admin | Device |
| --- | --- | --- | --- | --- | --- |
| 浏览公开视频 | Y | Y | Y | Y | N |
| 上传手动视频 | N | Y | Y | Y | N |
| 点赞评论关注 | N | Y | Y | Y | N |
| 举报内容 | N | Y | Y | Y | N |
| 审核视频 | N | N | Y | Y | N |
| 管理用户状态 | N | N | N | Y | N |
| 管理公有喂鸟器 | N | N | N | Y | N |
| 上传设备视频 | N | N | N | N | Y |

---

## 4. 关键业务流程

### 4.1 手动上传流程

1. 用户提交视频元数据并请求上传凭证
2. 客户端直传对象存储(分片/断点续传)
3. 服务端记录 `video=uploaded`
4. 异步转码队列触发 FFmpeg 任务
5. 转码成功后 `video=ready` 并生成 HLS 与缩略图
6. 若需要审核，进入审核队列后再公开

### 4.2 私有喂鸟器自动上传流程

1. 用户绑定设备(扫码或输入序列号 + 绑定码)
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
3. 审核结果: 通过、下架、限流、封禁上传者
4. 审核动作写入审计日志

---

## 5. 功能需求 (FRD)

优先级定义:

- P0: 上线必需
- P1: 重要增强
- P2: 可延期

### 5.1 账户与身份 (AUTH)

| ID | 需求 | 优先级 | 验收标准 |
| --- | --- | --- | --- |
| FR-AUTH-001 | 邮箱注册与登录 | P0 | 成功注册后可获取访问令牌 |
| FR-AUTH-002 | 刷新令牌与安全退出 | P0 | 刷新令牌过期后需重新登录 |
| FR-AUTH-003 | 找回密码(邮件) | P0 | 过期链接不可用 |
| FR-AUTH-004 | 第三方登录(Apple/Google) | P1 | 账号可与邮箱账号合并 |
| FR-AUTH-005 | 风险登录告警 | P1 | 新设备登录触发通知 |

### 5.2 用户资料与社交关系 (USER)

| ID | 需求 | 优先级 | 验收标准 |
| --- | --- | --- | --- |
| FR-USER-001 | 个人资料编辑(头像/昵称/简介/地区) | P0 | 修改后 5 秒内多端可见 |
| FR-USER-002 | 用户主页与作品列表 | P0 | 支持公开/私有内容过滤 |
| FR-USER-003 | 关注/取关 | P0 | 关系变更实时反映在计数上 |
| FR-USER-004 | 黑名单与隐私设置 | P1 | 被拉黑用户无法互动 |

### 5.3 视频上传与处理 (VIDEO)

| ID | 需求 | 优先级 | 验收标准 |
| --- | --- | --- | --- |
| FR-VIDEO-001 | 手动上传 MP4/MOV(<=1GB) | P0 | 大文件支持断点续传 |
| FR-VIDEO-002 | 视频元数据(标题/描述/位置/鸟种标签) | P0 | 标题必填，长度校验 |
| FR-VIDEO-003 | 可见性(public/private/unlisted) | P0 | 私有视频不可被搜索 |
| FR-VIDEO-004 | 自动转码 HLS 多码率 | P0 | 转码失败可重试，最多3次 |
| FR-VIDEO-005 | 缩略图自动生成 | P0 | 默认抓取关键帧，支持手动替换 |
| FR-VIDEO-006 | 播放器自适应清晰度 | P0 | 弱网下自动降码率 |
| FR-VIDEO-007 | 转码任务运营重跑 | P1 | 管理端可手动重跑任务 |

### 5.4 喂鸟器管理 (FEEDER)

| ID | 需求 | 优先级 | 验收标准 |
| --- | --- | --- | --- |
| FR-FEEDER-001 | 设备绑定/解绑 | P0 | 绑定码一次性使用 |
| FR-FEEDER-002 | 设备身份认证(API Key + 签名) | P0 | 无效签名请求拒绝 |
| FR-FEEDER-003 | 心跳上报与在线状态 | P0 | 心跳超时自动离线 |
| FR-FEEDER-004 | 私有/公有设备类型管理 | P0 | 公有设备无 owner_id |
| FR-FEEDER-005 | 设备上传视频 | P0 | 视频正确归属私有用户或公共池 |
| FR-FEEDER-006 | 拍摄计划配置(定时/触发) | P1 | 配置变更10秒内下发 |

### 5.5 社区互动 (COMMUNITY)

| ID | 需求 | 优先级 | 验收标准 |
| --- | --- | --- | --- |
| FR-COMM-001 | 点赞/取消点赞 | P0 | 幂等，重复操作不报错 |
| FR-COMM-002 | 评论与二级回复 | P0 | 最大2层，支持删除占位 |
| FR-COMM-003 | 举报视频/评论 | P0 | 举报后进入审核队列 |
| FR-COMM-004 | 通知中心(点赞/评论/关注/审核) | P1 | 未读数实时更新 |

### 5.6 发现与搜索 (DISCOVERY)

| ID | 需求 | 优先级 | 验收标准 |
| --- | --- | --- | --- |
| FR-DISC-001 | 首页Feed(关注 + 推荐) | P0 | 冷启动有基础推荐策略 |
| FR-DISC-002 | 搜索(鸟种/地区/喂鸟器/用户) | P0 | 返回结果支持分页 |
| FR-DISC-003 | 排序(最新/热门) | P0 | 热门策略按近7天加权 |
| FR-DISC-004 | 地图模式浏览 | P1 | 可切换区域热度层 |

### 5.7 管理后台 (ADMIN)

| ID | 需求 | 优先级 | 验收标准 |
| --- | --- | --- | --- |
| FR-ADMIN-001 | 用户管理(封禁/解封/角色) | P0 | 操作写入审计日志 |
| FR-ADMIN-002 | 视频审核队列 | P0 | 支持批量审核 |
| FR-ADMIN-003 | 设备管理(公有设备配置) | P0 | 设备状态可筛选 |
| FR-ADMIN-004 | 运营指标看板 | P0 | 至少覆盖 DAU、上传量、播放成功率 |
| FR-ADMIN-005 | 公告发布 | P1 | 指定端与用户分组可见 |

---

## 6. 非功能需求 (NFR)

### 6.1 性能与可用性

| ID | 要求 |
| --- | --- |
| NFR-PERF-001 | 首页Feed接口 P95 < 300ms (不含首包CDN延迟) |
| NFR-PERF-002 | 视频首帧时间 P95 < 2.5s |
| NFR-AVL-001 | 核心API月可用性 >= 99.9% |
| NFR-AVL-002 | 对象存储与转码任务失败可重试 |

### 6.2 可扩展性

- 初期采用模块化单体 + 异步队列架构，避免过早微服务化
- 按业务域拆分模块: auth/user/video/feeder/community/admin
- 所有外部依赖经接口层封装，便于后续替换云厂商与基础设施

### 6.3 安全与合规

| ID | 要求 |
| --- | --- |
| NFR-SEC-001 | 全链路 HTTPS/TLS1.2+ |
| NFR-SEC-002 | 密码哈希采用 Argon2 或 bcrypt(成本参数可配置) |
| NFR-SEC-003 | Token 与 API Key 支持轮换与吊销 |
| NFR-SEC-004 | 上传文件类型与恶意内容扫描 |
| NFR-SEC-005 | 审计日志保存 >= 180 天 |

### 6.4 可观测性

- 结构化日志: request_id, user_id, device_id, video_id
- 指标监控: API延迟、错误率、队列堆积、转码耗时、播放失败率
- 告警策略: P1(服务不可用), P2(性能退化), P3(指标异常)
- 分布式追踪: 关键链路可追踪到上传/转码/发布

---

## 7. 信息架构与多端策略

### 7.1 端能力边界

| 端 | 核心能力 |
| --- | --- |
| Web | 完整社区功能 + 管理后台入口 |
| iOS | 上传/播放/互动/设备绑定 |
| Android | 上传/播放/互动/设备绑定 |
| Admin Web | 用户治理、审核、运营与设备管理 |

### 7.2 多端一致性原则

- 统一 Design Token 与组件规范
- API 契约统一，由后端 OpenAPI 生成 SDK
- 功能灰度发布策略一致(按用户分组和比例)

---

## 8. 技术方案 (建议基线)

### 8.1 架构原则

- 先快后稳: MVP 快速验证，但不牺牲核心边界
- 领域分层: API 层、应用层、领域层、基础设施层
- 异步优先: 上传后异步处理，避免长事务
- 事件驱动: 视频状态变化通过事件广播

### 8.2 推荐技术栈

| 层级 | 技术建议 | 说明 |
| --- | --- | --- |
| Web | Next.js + TypeScript | SEO与内容站点能力更好 |
| Mobile | React Native + TypeScript | iOS/Android 代码复用 |
| Backend | Node.js + NestJS | 模块化与可维护性强 |
| DB | PostgreSQL | 强一致事务与复杂查询 |
| Cache/Queue | Redis + BullMQ | 缓存、限流、异步任务 |
| Object Storage | S3/OSS/COS | 视频与静态文件 |
| Transcode | FFmpeg Worker | HLS多码率输出 |
| Search | PostgreSQL FTS(初期) / OpenSearch(中后期) | 按规模升级 |
| Deploy | Docker + CI/CD | 一致化部署 |

### 8.3 部署分层

- Edge/CDN: 静态资源与视频分发
- API Gateway: 鉴权、限流、灰度、路由
- Application: 业务服务
- Worker: 转码、缩略图、通知异步任务
- Data: PostgreSQL、Redis、对象存储

---

## 9. 数据模型与状态机

### 9.1 核心实体

- users
- feeders
- videos
- bird_tags
- comments
- likes
- follows
- reports
- notifications
- moderation_logs

### 9.2 视频状态机

`uploaded -> queued -> processing -> ready`  
`processing -> failed`  
`ready -> hidden` (审核下架)  
`failed -> queued` (重试)

### 9.3 设备状态机

`unbound -> bound_private`  
`unbound -> public_managed`  
`bound_private/public_managed -> offline -> online` (由心跳驱动)

---

## 10. API 规范

### 10.1 通用规范

- Base Path: `/api/v1`
- Auth: `Authorization: Bearer <token>`
- Device Auth: `X-Device-Key`, `X-Device-Signature`, `X-Timestamp`
- 分页: 优先游标分页 `next_cursor`
- 幂等: 上传创建接口支持 `Idempotency-Key`
- 错误码格式:

```json
{
  "code": "VIDEO_NOT_FOUND",
  "message": "Video does not exist",
  "request_id": "req_xxx"
}
```

### 10.2 核心接口分组

- `auth/*`
- `users/*`
- `videos/*`
- `feeders/*`
- `community/*`
- `notifications/*`
- `admin/*`
- `device/*`

---

## 11. 数据统计与分析

### 11.1 事件埋点

- user_signup
- user_login
- video_upload_started
- video_upload_completed
- video_play_started
- video_play_failed
- feeder_bind_success
- feeder_upload_completed
- like_created
- comment_created

### 11.2 看板分层

- 业务看板: DAU/WAU、留存、上传量、活跃设备率
- 内容看板: 审核积压、热门物种、热点地区
- 技术看板: API延迟、错误率、转码队列积压、CDN命中率

---

## 12. 工程实施步骤 (标准流程)

### Phase 0: 项目启动与澄清 (2周)

- 输出物:
  - PRD v2.0 定稿
  - 架构 ADR(关键技术决策记录)
  - 风险清单与里程碑
- Exit Criteria:
  - 范围冻结 (P0/P1)
  - 团队角色明确
  - 开发环境与仓库策略确定

### Phase 1: 基础设施与账户系统 (3周)

- 范围:
  - Monorepo初始化
  - CI/CD、环境分层(dev/stage/prod)
  - Auth与用户资料 P0
- Exit Criteria:
  - 注册登录可用
  - 安全基线通过(密码、Token、限流)
  - 单元测试覆盖率达到最低门槛

### Phase 2: 视频主链路 MVP (4周)

- 范围:
  - 手动上传、转码、播放、详情页
  - 可见性与基础审核
- Exit Criteria:
  - 上传->可播成功率 >= 98%
  - 播放成功率 >= 99%
  - 关键接口压测达标

### Phase 3: 喂鸟器接入 (4周)

- 范围:
  - 绑定解绑
  - 设备鉴权、心跳、自动上传
  - 私有/公有归属逻辑
- Exit Criteria:
  - 设备上传链路稳定
  - 在线状态准确率 >= 95%
  - 归属数据无错配

### Phase 4: 社区与发现 (4周)

- 范围:
  - 点赞评论关注举报通知
  - Feed与搜索
- Exit Criteria:
  - Feed接口性能达标
  - 审核SLA可观测且可追责

### Phase 5: 管理后台与商业化准备 (3周)

- 范围:
  - 用户治理
  - 内容审核台
  - 设备管理与运营看板
- Exit Criteria:
  - 审核流程闭环
  - 关键报表准确率 >= 99%

### Phase 6: 移动端发布与扩展 (6周)

- 范围:
  - iOS/Android 正式版发布
  - 崩溃与性能优化
- Exit Criteria:
  - Crash-free sessions >= 99.5%
  - 应用商店首版上线

---

## 13. 质量保障与发布门禁

### 13.1 测试策略

- 单元测试: 业务核心逻辑
- 集成测试: DB、缓存、队列、对象存储联动
- E2E测试: 注册、上传、播放、评论、设备上传主链路
- 性能测试: Feed与播放接口
- 安全测试: 鉴权、注入、越权、上传漏洞

### 13.2 门禁标准

- PR 必须通过 lint + test + typecheck
- 关键模块代码评审至少 1 名 reviewer
- 发布前必须通过 smoke test
- S1/S2 缺陷未清零不得发布生产

---

## 14. 运维与SRE要求

- 环境: dev / stage / prod 严格隔离
- 数据备份: PostgreSQL 每日全量 + 增量日志
- 灾备目标:
  - RPO <= 15 分钟
  - RTO <= 1 小时
- 灰度发布: 按用户比例逐步放量
- 回滚策略: 保留前一版本镜像与数据库回滚脚本

---

## 15. 风险与应对

| 风险 | 影响 | 应对 |
| --- | --- | --- |
| 视频成本快速增长 | 高 | 分层存储 + 转码策略优化 + CDN策略 |
| 审核压力导致体验下降 | 高 | 规则初筛 + 人工复核 + SLA监控 |
| 设备协议不稳定 | 中 | 设备SDK标准化 + 回放重传机制 |
| 多端一致性问题 | 中 | 统一API契约 + 自动化E2E |
| 冷启动内容不足 | 中 | 公有喂鸟器优先供给 + 运营任务 |

---

## 16. 待确认事项 (Open Questions)

- 是否在首发版本引入第三方登录(Apple/Google)
- 是否引入地理位置隐私模糊机制(如坐标脱敏)
- 公有喂鸟器内容是否允许商业赞助位
- 是否在首发版本支持多语言(中/英)

---

## 17. 附录: 第一里程碑交付清单 (M1)

M1 目标日期建议: 2026-04-30

- PRD/架构评审完成并冻结 P0
- 仓库初始化与CI流水线可用
- Auth + User Profile 上线到 stage
- 手动上传到转码到播放链路打通
- 可观测性最小集(日志、指标、告警)上线

---

文档维护原则:

- 每个迭代结束更新一次变更记录
- 新增需求必须标注优先级、业务价值、技术影响
- 涉及跨团队影响的条目必须补充验收标准
