---
lang: zh-CN
page_id: inference-apis/images
permalink: /inference-apis/images.html
title: 图像
parent: 推理 API
nav_order: 3
description: "使用 Routero 密钥与公开模型名，通过兼容 OpenAI 的 Images API 生成和编辑图像。"
---

# 图像

通过 Routero 兼容 OpenAI 的 Images API，根据文本提示词生成图像，或编辑已有图像。Routero 为所选供应商转换请求，并返回图像响应。

## 调用前准备

- 使用具有目标图像模型访问权限的 Routero 虚拟密钥。
- 将 `YOUR_IMAGE_MODEL` 替换为组织中配置的**公开模型名（Public Model Name）**。模型需要支持你调用的操作，参见[模型管理]({% link zh-CN/core-gateway/models.md %})。
- 使用本页面显示的 API 地址，确保它与创建密钥的部署环境一致。

| 端点 | 方法 | 用途 | 请求格式 |
|---|---|---|---|
| `/v1/images/generations` | POST | 根据提示词生成图像 | JSON |
| `/v1/images/edits` | POST | 编辑上传的图像 | Multipart 表单 |

---

## 生成图像

### curl

```bash
curl {{ site.api_base_url }}/v1/images/generations \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "YOUR_IMAGE_MODEL",
    "prompt": "日落时分的城市天际线，水彩画风格",
    "n": 1
  }'
```

### Python（OpenAI SDK）

安装 `openai` 包，然后将客户端指向 Routero：

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    base_url="{{ site.api_base_url }}/v1",
)

response = client.images.generate(
    model="YOUR_IMAGE_MODEL",
    prompt="日落时分的城市天际线，水彩画风格",
    n=1,
)
```

### 常用参数

| 参数 | 类型 | 说明 |
|---|---|---|
| `model` | string | 当前密钥有权访问的图像模型的公开模型名。 |
| `prompt` | string | 对目标图像的描述。 |
| `n` | integer | 生成数量，支持的数量取决于模型。 |
| `size` | string | 输出尺寸，例如 `1024x1024`；可用值取决于模型。 |
| `quality` | string | 图像质量，需要所选模型支持。 |
| `response_format` | string | 对支持选择返回格式的模型，可使用 `url` 或 `b64_json`。 |

建议先使用必需字段调用，再添加模型支持的可选参数。尺寸、质量档位和输出格式由具体模型决定。

---

## 读取和保存结果

响应包含 `data` 数组。根据模型和请求的格式，每张图像可能返回 URL 或 Base64 数据。URL 响应示例：

```json
{
  "created": 1718000000,
  "data": [
    {"url": "https://example.com/generated-image.png"}
  ]
}
```

对于上面的 Python 响应，可以保存 Base64 图像，或输出下载地址：

```python
import base64
from pathlib import Path

for index, image in enumerate(response.data or []):
    if image.b64_json:
        Path(f"image-{index}.png").write_bytes(
            base64.b64decode(image.b64_json)
        )
    elif image.url:
        print(image.url)
```

文件扩展名应与模型的输出格式一致。对于 URL 结果，请在供应商的链接过期前下载保存。

---

## 编辑图像

使用 multipart 表单提交原图和提示词。将 `input.png` 替换为本地图片文件，并选择支持图像编辑的模型。

```bash
curl {{ site.api_base_url }}/v1/images/edits \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -F "model=YOUR_IMAGE_MODEL" \
  -F "image[]=@input.png" \
  -F "prompt=保留主体，将背景替换为雪山景色"
```

对于支持多图输入的模型，可以重复 `image[]` 字段。仅当模型支持蒙版编辑时，才添加 `-F "mask=@mask.png"`。图片格式、文件大小、图片数量和蒙版要求取决于所选模型。让 curl 自动设置 multipart 的 `Content-Type` 和 boundary。

使用前面创建的 Python 客户端：

```python
with open("input.png", "rb") as image:
    response = client.images.edit(
        model="YOUR_IMAGE_MODEL",
        image=image,
        prompt="保留主体，将背景替换为雪山景色",
    )
```

编辑结果采用相同的图像响应结构，可以使用前面的示例保存。

---

## 供应商扩展选项

部分图像模型提供通用 OpenAI 参数之外的选项。使用 OpenAI SDK 的 `extra_body` 请求选项传入供应商扩展字段，具体字段需要所选模型和 Routero 适配器支持。SDK 与 HTTP JSON 的写法参见[供应商扩展参数]({% link zh-CN/integration/api-calling.md %}#供应商扩展参数)。

请求失败时，请根据错误信息检查密钥的模型权限、模型支持的参数以及输入限制。

## 相关内容

→ [视频]({% link zh-CN/inference-apis/videos.md %}) · [模型]({% link zh-CN/inference-apis/models.md %}) · [API 调用]({% link zh-CN/integration/api-calling.md %})

→ OpenAI API 参考：[生成图像](https://developers.openai.com/api/reference/resources/images/methods/generate) · [编辑图像](https://developers.openai.com/api/reference/resources/images/methods/edit)
