# Phase 0 工作计划 — 后端工程师 #2

**阶段周期：** 2026-03-10 ~ 2026-03-21
**上游文档：** `doc/product/Tickwing_PRD_v2.3.md`
**完整工作计划：** `doc/product/Phase0_WorkPlan.md`

---

## 你的任务总览

| # | 任务 | 角色 | 截止日 | 产出物 |
|---|------|------|--------|--------|
| T0-1 | PRD 评审 | **评审** | 03-12 | 评审意见反馈 |
| T0-7 | 视频上传转码技术 Spike | **主责** | 03-19 | `doc/architecture/Spike_VideoTranscode.md` |

---

## T0-1 参与 PRD 评审（03-10 ~ 03-12）

**提前阅读范围：**
- 重点阅读 PRD v2.2 的 **第 4 章（业务流程，特别是 4.1 手动上传和 4.5 审核策略）**
- 重点阅读 PRD v2.2 的 **第 9.3 节（视频状态机）**
- 了解视频从上传到播放的完整链路

---

## T0-7 视频上传转码技术 Spike（03-17 ~ 03-19）⭐ 主要任务

### 前置条件
- T0-5（Docker 本地环境）已就绪或至少 MinIO + Redis 可用
- 准备 2-3 个测试视频文件（H.265 编码、2K 分辨率、约 100MB 大小）
- 本地安装 FFmpeg（或使用 Docker 镜像 `jrottenberg/ffmpeg`）

### 目的

在 Phase 2 正式开发前，花 **2-3 天做概念验证（PoC）**，降低视频链路的技术风险。这不是生产代码，只需要验证方案可行性。

### 需要验证的 6 个点

#### 1. MinIO ↔ S3 SDK 兼容性

```
目标：确认 @aws-sdk/client-s3 能直连 MinIO
步骤：
  1. 安装 @aws-sdk/client-s3
  2. 配置 endpoint 指向 localhost:9000
  3. 创建 bucket
  4. 生成 PutObject Presigned URL
  5. 用 curl 或代码通过 Presigned URL 上传文件
  6. 验证文件可读取
结论记录：是否完全兼容？有无差异？
```

#### 2. 分片上传（Multipart Upload）

```
目标：验证 300MB 大文件的分片上传流程
步骤：
  1. 调用 CreateMultipartUpload 获取 uploadId
  2. 将文件分为 5MB 的 part，逐个 UploadPart
  3. 调用 CompleteMultipartUpload 合并
  4. 验证合并后文件完整性（MD5 校验）
结论记录：分片大小推荐值？上传耗时？
```

#### 3. FFmpeg 转码 HLS 多码率

```
目标：输入 H.265/2K 视频，输出 HLS 三档码率
命令参考：

# 360p
ffmpeg -i input.mp4 -vf scale=640:360 -c:v libx264 -b:v 800k \
  -c:a aac -b:a 128k -hls_time 6 -hls_list_size 0 output_360p.m3u8

# 720p
ffmpeg -i input.mp4 -vf scale=1280:720 -c:v libx264 -b:v 2500k \
  -c:a aac -b:a 128k -hls_time 6 -hls_list_size 0 output_720p.m3u8

# 1080p
ffmpeg -i input.mp4 -vf scale=1920:1080 -c:v libx264 -b:v 5000k \
  -c:a aac -b:a 128k -hls_time 6 -hls_list_size 0 output_1080p.m3u8

# Master playlist
需要手动创建 master.m3u8 指向三个子流

记录：每种分辨率的转码耗时、输出文件大小
```

#### 4. HLS 播放验证

```
目标：在浏览器中播放生成的 HLS
步骤：
  1. 将 HLS 文件上传到 MinIO
  2. 创建简单 HTML 页面，引入 hls.js
  3. 加载 master.m3u8，验证自适应码率切换
  4. 模拟弱网（Chrome DevTools 限速），观察降码率行为
结论记录：播放是否流畅？码率切换是否正常？
```

#### 5. BullMQ 队列模型

```
目标：验证 BullMQ + Redis 的任务队列基本流程
步骤：
  1. 创建 video-transcode 队列
  2. 添加一个转码任务 (videoId, inputPath, outputPath)
  3. Worker 接收任务，调用 FFmpeg 命令
  4. 任务完成后更新状态（模拟数据库状态更新）
  5. 测试失败重试（模拟 FFmpeg 失败，验证重试 3 次逻辑）
配置建议：
  - 并发数：先设为 2（后续根据服务器配置调整）
  - 重试策略：最多 3 次，指数退避
结论记录：队列是否稳定？任务状态流转是否正确？
```

#### 6. 缩略图提取

```
目标：从视频中提取关键帧作为缩略图
命令参考：
  ffmpeg -i input.mp4 -vf "select=eq(ptype\,I),scale=640:-1" \
    -frames:v 3 -vsync vfr thumb_%02d.jpg
结论记录：提取质量是否可用？耗时？
```

### 产出物格式

`doc/architecture/Spike_VideoTranscode.md`，包含：

```markdown
# 视频上传转码 Spike 报告

## 验证环境
- OS / Docker 版本 / FFmpeg 版本 / Node.js 版本
- 测试视频规格（编码、分辨率、时长、大小）

## 验证结果

### 1. MinIO 兼容性
- 结论：✅ 通过 / ❌ 不通过
- 发现的问题：...
- 解决方案：...

### 2. 分片上传
- 结论 + 推荐分片大小 + 耗时数据

### 3. FFmpeg 转码
- 各档位转码耗时表
- 输出文件大小表
- 推荐的 FFmpeg 参数

### 4. HLS 播放
- 结论 + 截图证明

### 5. BullMQ 队列
- 结论 + 配置建议

### 6. 缩略图提取
- 结论 + 示例图

## 风险与建议
- 发现的风险项（需同步到 T0-9 风险清单）
- 对 Phase 2 实现的建议
```

### 条件约束
- 这是概念验证，**不需要写生产级代码**
- 示例代码放在独立目录（如 `spike/video-transcode/`），不合入主分支
- 必须基于本地 Docker 环境完成

### 注意事项
- H.265 **解码**大多数 FFmpeg 构建都支持，但 **编码** 需要 `libx265`。我们只需解码（输入是 H.265），输出用 H.264（`libx264`），浏览器兼容性更好
- MinIO Presigned URL 默认过期时间最长 7 天，与 AWS S3 一致
- 如果转码耗时过长（>输入视频时长的 3 倍），需要在报告中标注，作为容量规划输入

### 验收要求
- [ ] `doc/architecture/Spike_VideoTranscode.md` 产出
- [ ] 6 个验证点全部有明确结论（✅ 或 ❌ + 解决方案）
- [ ] 包含性能数据（转码耗时、文件大小）
- [ ] 后端 Lead Review 通过

### 可参考文档
- `doc/product/Tickwing_PRD_v2.3.md` 第 4.1（上传流程）、第 9.3（视频状态机）
- [FFmpeg HLS Muxer](https://ffmpeg.org/ffmpeg-formats.html#hls-2)
- [hls.js GitHub](https://github.com/video-dev/hls.js/)
- [AWS S3 SDK v3 — Presigned URL](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-s3/)
- [BullMQ Guide](https://docs.bullmq.io/guide/quick-start)

---

## 你的时间线

```
03-10 Mon  PRD 评审会（全员，2h）
03-11 Tue  PRD 反馈
03-12~16   协助后端 Lead（如需讨论 ADR），准备 Spike 测试视频
03-17 Mon  T0-7 Spike 启动：MinIO 兼容性 + 分片上传
03-18 Tue  T0-7：FFmpeg 转码 + HLS 播放 + BullMQ
03-19 Wed  T0-7 完成 ✅：缩略图 + 整理报告 + 提交 Review
03-21 Fri  M0 里程碑评审会（你主讲 Spike 结果，约 15min）
```
