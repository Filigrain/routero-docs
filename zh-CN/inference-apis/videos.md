---
lang: zh-CN
page_id: inference-apis/videos
permalink: /inference-apis/videos.html
title: 视频
parent: 推理 API
nav_order: 5
description: "通过 Routero 兼容 OpenAI 的视频接口创建任务、查询状态并下载生成结果。"
---

# 视频

Routero 为组织中配置的视频模型提供兼容 OpenAI 的视频接口。视频生成采用异步任务流程：先创建任务，再查询状态，完成后下载结果。

## 调用前准备

- 使用具有目标视频模型访问权限的 Routero 虚拟密钥。
- 将 `YOUR_VIDEO_MODEL` 替换为模型的**公开模型名（Public Model Name）**，并选择支持相应文生视频或图生视频流程的模型，参见[模型管理]({% link zh-CN/core-gateway/models.md %})。
- 使用本页面显示的 API 地址，确保它与创建密钥的部署环境一致。

| 端点 | 方法 | 用途 |
|---|---|---|
| `/v1/videos` | POST | 创建视频生成任务 |
| `/v1/videos/{video_id}` | GET | 查询任务状态和元数据 |
| `/v1/videos/{video_id}/content` | GET | 下载生成的 MP4 视频 |

---

## 1. 创建任务

```bash
curl {{ site.api_base_url }}/v1/videos \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "YOUR_VIDEO_MODEL",
    "prompt": "镜头缓慢掠过日落时平静的海面"
  }'
```

响应是视频任务对象，例如：

```json
{
  "id": "video_...",
  "object": "video",
  "status": "queued"
}
```

请完整保存返回的 `id`，后续请求使用这个 Routero 任务 ID。创建任务成功表示任务已提交，视频仍需要等待生成完成。

### 常用参数

| 参数 | 类型 | 说明 |
|---|---|---|
| `model` | string | 当前密钥有权访问的视频模型的公开模型名。 |
| `prompt` | string | 对目标视频的描述。 |
| `seconds` | string | 请求的视频时长，例如 `"5"`，需要模型支持该取值。 |
| `size` | string | 请求的输出尺寸，例如 `"1280x720"`，需要模型支持该取值。 |
| `input_reference` | file | 支持图生视频的模型使用的参考图片，见下文。 |

可用时长、分辨率、宽高比和默认值由所选模型决定。Routero 会将通用字段映射为供应商的请求格式。

---

## 2. 查询状态

将 `RETURNED_VIDEO_ID` 替换为创建请求返回的完整 ID。将 ID 放入 HTTP URL 路径时，请先进行 URL 编码。

```bash
curl {{ site.api_base_url }}/v1/videos/RETURNED_VIDEO_ID \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY"
```

| 状态 | 含义 | 后续操作 |
|---|---|---|
| `queued` | 排队中 | 继续轮询 |
| `in_progress` | 生成中 | 继续轮询 |
| `completed` | 已完成 | 下载视频 |
| `failed` | 生成失败 | 查看 `error` 字段 |

部分供应商还可能返回 `cancelled`、`expired` 等终态。遇到失败终态时停止轮询并检查错误信息。建议每隔几秒查询一次，避免连续高频请求。

---

## 3. 下载视频

任务状态为 `completed` 后，使用相同的 Routero 任务 ID 和密钥下载：

```bash
curl {{ site.api_base_url }}/v1/videos/RETURNED_VIDEO_ID/content \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  --output video.mp4
```

响应内容为视频二进制数据，需要保存为文件。请在供应商提供的下载有效期内保存结果。

---

## Python：创建、轮询和下载

安装提供 `client.videos` 的 `openai` 包版本。下面的示例每 5 秒查询一次，最多等待 10 分钟：

```python
import time
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    base_url="{{ site.api_base_url }}/v1",
)

video = client.videos.create(
    model="YOUR_VIDEO_MODEL",
    prompt="镜头缓慢掠过日落时平静的海面",
)
print("Task ID:", video.id)

terminal_states = {"completed", "failed", "cancelled", "canceled", "expired"}
deadline = time.monotonic() + 600

while video.status not in terminal_states:
    if time.monotonic() >= deadline:
        raise TimeoutError(f"Still waiting for video task {video.id}")
    time.sleep(5)
    video = client.videos.retrieve(video.id)

if video.status != "completed":
    raise RuntimeError(f"Video task {video.id}: {video.status}; {video.error}")

content = client.videos.download_content(video.id)
content.write_to_file("video.mp4")
```

客户端停止轮询或等待超时，不会取消上游任务。保留任务 ID 后可继续查询，避免重复创建相同任务。

---

## 使用参考图片

对于支持图生视频的模型，通过 `input_reference` 上传参考图片：

```bash
curl {{ site.api_base_url }}/v1/videos \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -F "model=YOUR_VIDEO_MODEL" \
  -F "prompt=微风轻轻吹过画面中的景物" \
  -F "input_reference=@first-frame.png"
```

让 curl 自动设置 multipart 的 `Content-Type` 和 boundary。支持的图片格式、尺寸和参考图用途取决于所选模型。

## 供应商扩展选项

视频供应商可能提供参考素材、音频或生成设置等扩展选项。OpenAI SDK 提供 `extra_body` 来传入额外请求字段；具体选项需要所选模型和 Routero 适配器支持，参见[供应商扩展参数]({% link zh-CN/integration/api-calling.md %}#供应商扩展参数)。

任务列表、remix 等操作的支持情况取决于供应商。使用本文创建、查询和下载流程以外的操作前，请先确认所选模型是否支持。

API 请求失败时，请检查返回的错误信息、模型权限、输入参数及速率限制。任务提交成功后仍可能生成失败，因此需要继续检查最终状态。

## 相关内容

→ [图像]({% link zh-CN/inference-apis/images.md %}) · [模型]({% link zh-CN/inference-apis/models.md %}) · [API 调用]({% link zh-CN/integration/api-calling.md %})

→ [OpenAI Videos API 参考（历史接口规范）](https://developers.openai.com/api/reference/resources/videos)
