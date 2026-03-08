# Phase 0 工作计划 — Web 前端工程师

**阶段周期：** 2026-03-10 ~ 2026-03-21
**上游文档：** `doc/product/Tickwing_PRD_v2.3.md`
**完整工作计划：** `doc/product/Phase0_WorkPlan.md`

---

## 你的任务总览

| #    | 任务             | 角色     | 截止日   | 产出物               |
| ---- | -------------- | ------ | ----- | ----------------- |
| T0-1 | PRD 评审         | **评审** | 03-12 | 评审意见反馈            |
| T0-2 | 架构设计 ADR       | **协作** | 03-17 | 确认前后端通信 & i18n 方案 |
| T0-3 | 设计规范           | **协作** | 03-19 | 确认组件实现可行性         |
| T0-4 | Monorepo 仓库初始化 | **协作** | 03-17 | 确认 Next.js 骨架     |

---

## T0-1 参与 PRD 评审（03-10 ~ 03-12）

**提前阅读范围：**
- 重点阅读 PRD v2.2 的 **第 5 章（功能需求）** — 了解每个页面需要什么功能
- 重点阅读 PRD v2.2 的 **第 7 章（多端策略）** — 了解 Web 端的能力边界
- 重点阅读 PRD v2.2 的 **第 10 章（API 规范）** — 了解前后端数据交互
- 重点阅读 PRD v2.2 的 **第 6.5 节（i18n）** — 语言包架构

**评审会上需要关注的：**
- 页面数量和复杂度是否在 Phase 排期内可完成？
- API 接口设计是否满足前端数据需求？
- 是否有需要特殊交互的组件？（如视频播放器、分片上传进度条）

---

## T0-2 协作：架构设计 ADR Review（03-13 ~ 03-14）

后端 Lead 会主动找你对齐以下两个 ADR，你需要准备意见：

### ADR-006 前后端通信

你需要确认和表达意见的内容：
- **API 响应格式**：是否统一为 `{ code, message, data, request_id }` ？
- **分页方案**：Feed 用游标分页（`next_cursor`）你是否熟悉？实现有无困难？
- **错误处理**：前端如何统一处理 API 错误？建议使用 axios interceptor 还是 fetch wrapper？
- **OpenAPI → TypeScript 类型自动生成**：是否采用？工具选型（如 `openapi-typescript`）

### ADR-007 i18n 方案

你需要确认：
- 语言包格式用 JSON（如 `i18n/zh-CN.json`）是否 OK？
- 推荐 i18n 库：`next-intl` / `react-i18next` / 其他？
- 语言包目录放在 `apps/web/src/i18n/` 是否合理？
- 后端错误码（如 `VIDEO_NOT_FOUND`）前端怎么映射为中文提示？

**建议时间：** 03-13 或 03-14 与后端 Lead 约 30 分钟对齐

---

## T0-3 协作：设计规范 Review（03-14 ~ 03-19）

设计师产出 Design Token 和线框图后，你需要 Review：

**你需要确认的内容：**
- Design Token 的命名方式是否可以直接映射到 Tailwind CSS 配置？
- 组件清单中是否有实现难度高的组件？提前标注
- 视频播放器组件的交互规范是否可实现？（全屏、进度条、码率切换）
- 响应式断点（移动端 < 768px、平板 768-1024px、桌面 > 1024px）是否合理？

**产出：** Review 意见反馈给设计师

---

## T0-4 协作：Monorepo Web 端骨架（03-12 ~ 03-14）

DevOps 初始化 Monorepo 时，你需要配合确认 `apps/web/` 的骨架结构：

**你需要确认的内容：**
- Next.js 版本（建议最新稳定版 14.x/15.x）
- 使用 App Router 还是 Pages Router？（建议 App Router）
- 目录结构是否符合你的开发习惯：

```
apps/web/src/
├── app/              # App Router 页面
│   ├── (auth)/       # 注册/登录（layout group）
│   ├── (main)/       # 主站（Feed/详情/主页）
│   ├── admin/        # 管理后台
│   └── layout.tsx
├── components/       # 通用 UI 组件
│   ├── ui/           # 基础组件 (Button, Input...)
│   └── business/     # 业务组件 (VideoCard, CommentList...)
├── hooks/            # 自定义 Hook
├── store/            # Zustand store
├── api/              # API 请求封装
├── i18n/             # 语言包
│   └── zh-CN.json
├── lib/              # 第三方库封装
└── utils/            # 工具函数
```

- 基础依赖确认：Tailwind CSS / Zustand / axios (或 fetch) / hls.js
- 是否需要 `next.config.js` 的特殊配置？

**建议时间：** 03-12 或 03-13 与 DevOps 约 15 分钟对齐

---

## 你的时间线

```
03-10 Mon  PRD 评审会（全员，2h）
03-11 Tue  PRD 反馈
03-12 Wed  与 DevOps 对齐 Web 骨架结构
03-13 Thu  与后端 Lead 对齐 ADR-006/007（约 30min）
03-14 Fri  Review 设计师初稿（如已产出）
03-17 Mon  继续 Review ADR + 设计稿
03-18 Tue  Review 设计稿
03-19 Wed  Design Review 完成，确认组件可行性
03-20 Thu  （无硬性任务，可提前调研 Phase 1 技术方案）
03-21 Fri  M0 里程碑评审会（参与全程，无主讲）
```

### Phase 1 预习建议（如有空闲时间）

Phase 1 你将主责 Web 端注册/登录/资料页面，建议提前调研：
- Next.js App Router 的最佳实践
- Zustand 状态管理 + JWT Token 存储方案
- 表单验证库选型（react-hook-form / zod）
- Tailwind CSS 组件库选型（shadcn/ui / headless UI）
