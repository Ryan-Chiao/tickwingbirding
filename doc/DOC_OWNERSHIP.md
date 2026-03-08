# 文档空间分配与归档规范

**维护人：** PM
**生效日期：** 2026-03-08
**适用范围：** 全团队

---

## 核心原则

1. **按角色归档**：每个文档目录有明确的归属角色（Owner），该角色对目录下的文档负有编写和维护责任
2. **单一职责**：一份文档只归属一个目录，避免重复存放
3. **协作透明**：非 Owner 可以提交 Review 意见或 PR，但最终合并权归 Owner

---

## 文档空间分配

| 目录                  | Owner       | 职责范围                       | 典型产出物                                                         |
| ------------------- | ----------- | -------------------------- | ------------------------------------------------------------- |
| `doc/product/`      | **PM**      | PRD、需求文档、风险登记册、版本变更记录      | `Tickwing_PRD_v2.3.md`、`RiskRegister.md`、`Phase*_WorkPlan.md` |
| `doc/architecture/` | **后端 Lead** | 架构决策记录、系统设计、数据模型变更         | `ADR.md`、`Spike_VideoTranscode.md`                            |
| `doc/api/`          | **后端 Lead** | API 文档、OpenAPI 规范、接口变更日志   | `openapi.yaml`、`API_Changelog.md`                             |
| `doc/design/`       | **设计师**     | 设计规范、Design Token、线框图、交互说明 | `DesignSystem.md`、`Wireframes/`                               |
| `doc/testing/`      | **QA**      | 测试策略、测试计划、测试报告、缺陷分析        | `TestStrategy.md`、`TestReport_M*.md`                          |
| `doc/operations/`   | **DevOps**  | 开发环境文档、部署手册、CI/CD 说明、运维手册  | `LocalDevSetup.md`、`CI_CD_Guide.md`                           |
| `doc/meeting/`      | **PM**      | 会议纪要、里程碑评审报告、决策记录          | `M0_Review.md`、`Sprint*_Retro.md`                             |
| `doc/phase{N}/`     | **PM**      | 各阶段按角色拆分的工作计划              | `P{N}_{角色}.md`                                                |

---

## 各角色文档职责速查

### PM（产品经理）
```
doc/product/          ← Owner
doc/meeting/          ← Owner
doc/phase{N}/         ← Owner（工作计划分发）
```

### 后端 Lead（后端工程师 #1）
```
doc/architecture/     ← Owner
doc/api/              ← Owner
```

### 后端 #2（后端工程师 #2）
```
doc/architecture/     ← 协作（Spike 报告存放于此）
```

### Web 前端工程师
```
doc/design/           ← Review 协作方
doc/api/              ← Review 协作方
```

### 移动端工程师
```
doc/design/           ← Review 协作方
```

### 设计师
```
doc/design/           ← Owner
```

### DevOps / SRE
```
doc/operations/       ← Owner
```

### QA 工程师
```
doc/testing/          ← Owner
```

---

## 文件命名规范

| 类型 | 命名格式 | 示例 |
|------|---------|------|
| 阶段工作计划 | `P{阶段}_{角色英文}.md` | `P0_BackendLead.md` |
| 里程碑评审纪要 | `M{N}_Review.md` | `M0_Review.md` |
| Sprint 回顾 | `Sprint{N}_Retro.md` | `Sprint1_Retro.md` |
| ADR | `ADR.md`（统一文件，按编号分章节） | — |
| Spike 报告 | `Spike_{主题}.md` | `Spike_VideoTranscode.md` |
| 测试报告 | `TestReport_M{N}.md` | `TestReport_M1.md` |

---

## 变更流程

1. 新增目录需经 PM 审批并更新本文件
2. 文档 Owner 变更需在本文件中记录并通知全员
3. 跨目录引用使用相对路径，不复制文件
