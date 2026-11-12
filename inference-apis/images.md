---
lang: en
page_id: inference-apis/images
title: Images
parent: Inference APIs
nav_order: 3
description: "Generate and edit images through the OpenAI-compatible Images API, using your Routero key and public model name."
---

# Images

Generate an image from a text prompt, or edit an existing image, through Routero's OpenAI-compatible Images API. Routero translates the request for the selected provider and returns an image response.

## Before you start

- Use a Routero virtual key that can access the image model.
- Replace `YOUR_IMAGE_MODEL` with the **Public Model Name** configured in your organization. The model must support the operation you call. See [Models]({% link core-gateway/models.md %}).
- Use the API address shown on this site for the deployment where your key was created.

| Endpoint | Method | Purpose | Request format |
|---|---|---|---|
| `/v1/images/generations` | POST | Generate images from a prompt | JSON |
| `/v1/images/edits` | POST | Edit uploaded images | Multipart form data |

---

## Generate an image

### curl

```bash
curl {{ site.api_base_url }}/v1/images/generations \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "YOUR_IMAGE_MODEL",
    "prompt": "A watercolour of a city skyline at sunset",
    "n": 1
  }'
```

### Python (OpenAI SDK)

Install the `openai` package, then point the client at Routero:

```python
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    base_url="{{ site.api_base_url }}/v1",
)

response = client.images.generate(
    model="YOUR_IMAGE_MODEL",
    prompt="A watercolour of a city skyline at sunset",
    n=1,
)
```

### Common parameters

| Parameter | Type | Description |
|---|---|---|
| `model` | string | Public Model Name of an image model your key can access. |
| `prompt` | string | Description of the image to generate. |
| `n` | integer | Number of images. Supported counts depend on the model. |
| `size` | string | Output size, for example `1024x1024`. Accepted values depend on the model. |
| `quality` | string | Image quality, when supported by the model. |
| `response_format` | string | `url` or `b64_json`, for models that support choosing the response format. |

Start with the required fields and add optional parameters supported by your model. Image dimensions, quality levels, and output formats are model-specific.

---

## Read and save the result

The response contains a `data` array. Depending on the model and requested format, each image can contain a URL or Base64-encoded data. A URL response looks like this:

```json
{
  "created": 1718000000,
  "data": [
    {"url": "https://example.com/generated-image.png"}
  ]
}
```

With the Python response above, save Base64 images or print the download URLs:

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

Use a filename extension that matches the model's output format. Download URL-based results before the provider's URLs expire.

---

## Edit an image

Send the image and prompt as multipart form data. Replace `input.png` with a local image file, and choose a model that supports image editing.

```bash
curl {{ site.api_base_url }}/v1/images/edits \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -F "model=YOUR_IMAGE_MODEL" \
  -F "image[]=@input.png" \
  -F "prompt=Keep the subject and replace the background with a snowy mountain scene"
```

For models that accept multiple images, repeat the `image[]` field. Add `-F "mask=@mask.png"` only when the model supports mask-based editing. Image formats, file sizes, image counts, and mask requirements depend on the selected model. Let curl set the multipart `Content-Type` and boundary.

Using the Python client above:

```python
with open("input.png", "rb") as image:
    response = client.images.edit(
        model="YOUR_IMAGE_MODEL",
        image=image,
        prompt="Keep the subject and replace the background with a snowy mountain scene",
    )
```

The result uses the same image response structure; save it using the example above.

---

## Provider-specific options

Some image models offer options beyond the common OpenAI parameters. Use the OpenAI SDK's `extra_body` request option for provider-specific fields, and choose fields supported by the selected model and Routero adapter. See [Provider-specific parameters]({% link integration/api-calling.md %}#provider-specific-parameters) for the SDK and HTTP JSON formats.

If a request fails, check the error message, your key's model permissions, and the model's supported parameters and input limits.

## Related

→ [Videos]({% link inference-apis/videos.md %}) · [Models]({% link inference-apis/models.md %}) · [Calling the API]({% link integration/api-calling.md %})

→ OpenAI API reference: [Generate images](https://developers.openai.com/api/reference/resources/images/methods/generate) · [Edit images](https://developers.openai.com/api/reference/resources/images/methods/edit)
