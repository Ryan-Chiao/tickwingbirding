# Phase 0 工作计划 — 后端 Lead（后端工程师 #1）

**阶段周期：** 2026-03-10 ~ 2026-03-21
**上游文档：** `doc/product/Tickwing_PRD_v2.3.md`
**完整工作计划：** `doc/product/Phase0_WorkPlan.md`

---

## 你的任务总览

| # | 任务 | 角色 | 截止日 | 产出物 |
|---|------|------|--------|--------|
| T0-1 | PRD 评审 | **评审** | 03-12 | 评审意见反馈 |
| T0-2 | 架构设计文档 (ADR) | **主责** | 03-17 | `doc/architecture/ADR.md` |
| T0-7 | 视频 Spike Review | **评审** | 03-19 | Review 签字 |

---

## T0-1 参与 PRD 评审（03-10 ~ 03-12）

你需要在 PRD 评审会前完成以下准备：

**提前阅读范围：**
- 重点阅读 PRD v2.2 的 **第 8 章（技术方案）、第 9 章（数据模型）、第 10 章（API 规范）**
- 评估数据模型的 DDL 是否满足后端实现需求
- 评估 API 端点设计是否合理、是否有遗漏

**评审会上需要回答的问题：**
- 数据模型是否需要修改？（如有，具体列出）
- 技术栈选择是否认同？（NestJS / Prisma vs TypeORM / BullMQ 等）
- 各 Phase 的后端工作量评估是否合理？

---

## T0-2 架构设计文档 ADR（03-12 ~ 03-17）⭐ 主要任务

### 前置条件
- T0-1（PRD 评审）已完成
- 已阅读并理解 PRD v2.2 全文

### 你需要做什么

产出 `doc/architecture/ADR.md`，包含以下 **9 个架构决策记录**：

| ADR # | 决策主题 | 核心问题 |
|-------|---------|----------|
| ADR-001 | 后端框架选型 | NestJS 模块划分：auth / user / video / feeder / community / admin / notification 七模块边界如何定？模块间依赖规则？ |
| ADR-002 | 数据库与 ORM | TypeORM 还是 Prisma？迁移策略怎么做？为什么选这个？ |
| ADR-003 | 认证方案 | JWT Access Token 过期时间、Refresh Token 存储位置（Redis？DB？HttpOnly Cookie？）、Token 黑名单怎么实现？ |
| ADR-004 | 文件上传方案 | 客户端直传 S3/OSS 的 Presigned URL 签名流程、分片上传策略、上传完成回调机制 |
| ADR-005 | 视频转码方案 | FFmpeg Worker 用进程模型还是容器化？BullMQ 队列配置（并发数、重试策略）、HLS 输出规格 |
| ADR-006 | 前后端通信 | RESTful API 设计规范细节、统一错误码体系设计、分页方案（游标 vs offset）、OpenAPI 自动生成方式 |
| ADR-007 | i18n 方案 | 前端语言包格式（JSON）、后端错误消息 code-based 映射、翻译文件目录结构（`i18n/zh-CN.json`） |
| ADR-008 | 坐标脱敏方案 | 存储层保留原始精度，展示层截断至小数点后 2 位的实现方式（数据库触发器？应用层？API 序列化？） |
| ADR-009 | 云厂商抽象层 | 对象存储接口封装设计，S3 / OSS 一套代码切换的具体方案（Adapter 模式？配置驱动？） |

### 每个 ADR 的格式

```markdown
## ADR-XXX: [决策主题]

### 状态
Accepted / Proposed / Superseded

### 背景
为什么需要做这个决策？有什么约束？

### 决策
最终选择了什么方案？

### 理由
为什么选这个方案？对比了哪些备选方案？

### 后果
这个决策带来的影响、风险、需要注意的事项
```

### 额外产出

除了 9 个 ADR 之外，还需要：

1. **Monorepo 目录结构确认**：Review 并确认/调整 Phase0_WorkPlan 中的目录结构
2. **数据模型修改建议**：如果 PRD 中的 DDL 需要改动，列出具体修改项提交给 PM
3. **API Schema 草案**：对 PRD 中关键 API（auth/register、videos/upload）补充请求/响应 JSON Schema

### 关键技术约束（已决策，需在 ADR 中体现）

- **视频规格**：≤ 2 分钟、H.265 编码、最高 2K (2560×1440)、≤ 300MB
- **云厂商**：同时支持 AWS S3 和阿里云 OSS，本地用 MinIO
- **语言**：首发仅简体中文，架构预留 i18n（语言包独立）
- **坐标脱敏**：前端精度 ±1km
- **审核策略**：先发后审
- **仓库名**：`tickwingbirding`
- **包管理器**：pnpm
- **TypeScript 严格模式**：`strict: true`

### HLS 转码输出规格建议

| 档位 | 分辨率 | 码率 | 适用场景 |
|------|--------|------|---------|
| 360p | 640×360 | 800kbps | 移动端弱网 |
| 720p | 1280×720 | 2.5Mbps | 默认档位 |
| 1080p | 1920×1080 | 5Mbps | 高清（源视频为 2K 时生成） |

HLS 分片建议：`-hls_time 6 -hls_list_size 0`

### 需要协作的人

| 协作对象 | 协作内容 | 建议时间 |
|---------|---------|---------|
| Web 前端 | ADR-006 前后端通信规范、ADR-007 i18n 方案 | 03-13 或 03-14 约 30min 对齐 |
| DevOps | ADR-004 本地 MinIO 方案、ADR-009 云厂商抽象 | 03-13 约 30min 对齐 |
| PM | 数据模型修改建议（如有）| 03-17 ADR 完成后提交 |

### 验收要求
- [ ] `doc/architecture/ADR.md` 文件产出，包含 9 个 ADR
- [ ] 每个 ADR 状态为 `Accepted` 或 `Proposed`，无 "待定"
- [ ] Monorepo 目录结构图确认
- [ ] 数据模型修改建议提交（如有）
- [ ] Web 前端、DevOps 完成 Review 并确认

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 8、9、10 章
- [NestJS Modules](https://docs.nestjs.com/modules)
- [ADR 格式 — Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [BullMQ 文档](https://docs.bullmq.io/)
- [Prisma vs TypeORM 对比](https://www.prisma.io/docs/orm/more/comparisons/prisma-and-typeorm)

---

## T0-7 Review 视频 Spike 报告（03-19）

后端 #2 完成视频上传转码 Spike 后，你需要：

1. Review `doc/architecture/Spike_VideoTranscode.md`
2. 确认以下结论是否可靠：
   - MinIO ↔ S3 SDK 兼容性
   - FFmpeg HLS 输出规格
   - BullMQ 队列模型
3. 签字确认或提出修改意见

---

## 你的时间线

```
03-10 Mon  PRD 评审会（全员，2h）
03-11 Tue  PRD 反馈收集
03-12 Wed  T0-2 启动：ADR 编写开始
03-13 Thu  T0-2：ADR 编写 + 与前端/DevOps 对齐会
03-14 Fri  T0-2：ADR 编写
03-17 Mon  T0-2 完成 ✅，提交 Review
03-18 Tue  T0-2 处理 Review 反馈
03-19 Wed  T0-7 Review Spike 报告
03-21 Fri  M0 里程碑评审会（你主讲架构方案，约 30min）
```
