---
lang: en
page_id: inference-apis/videos
title: Videos
parent: Inference APIs
nav_order: 5
description: "Create a video task, check its status, and download the result through Routero's OpenAI-compatible video endpoints."
---

# Videos

Routero exposes OpenAI-compatible video endpoints for the video models configured in your organization. Video generation is asynchronous: create a task, check its status, and download the result after it completes.

## Before you start

- Use a Routero virtual key that can access the video model.
- Replace `YOUR_VIDEO_MODEL` with the model's **Public Model Name**. Choose a model that supports your text-to-video or image-to-video workflow. See [Models]({% link core-gateway/models.md %}).
- Use the API address shown on this site for the deployment where your key was created.

| Endpoint | Method | Purpose |
|---|---|---|
| `/v1/videos` | POST | Create a video generation task |
| `/v1/videos/{video_id}` | GET | Read task status and metadata |
| `/v1/videos/{video_id}/content` | GET | Download the generated MP4 video |

---

## 1. Create a task

```bash
curl {{ site.api_base_url }}/v1/videos \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "YOUR_VIDEO_MODEL",
    "prompt": "A slow camera move over a calm ocean at sunset"
  }'
```

The response is a video task object. For example:

```json
{
  "id": "video_...",
  "object": "video",
  "status": "queued"
}
```

Save the complete returned `id`. Use this Routero task ID for subsequent requests. Creating the task successfully does not mean the video has finished generating.

### Common parameters

| Parameter | Type | Description |
|---|---|---|
| `model` | string | Public Model Name of a video model your key can access. |
| `prompt` | string | Description of the video to generate. |
| `seconds` | string | Requested duration, for example `"5"`, if supported by the model. |
| `size` | string | Requested output size, for example `"1280x720"`, if supported by the model. |
| `input_reference` | file | Reference image for a model that supports image-to-video generation; see below. |

Accepted durations, resolutions, aspect ratios, and defaults depend on the selected model. Routero maps the common fields to the provider's request format.

---

## 2. Check the status

Replace `RETURNED_VIDEO_ID` with the complete ID returned by the create request. URL-encode the ID when inserting it into an HTTP URL path.

```bash
curl {{ site.api_base_url }}/v1/videos/RETURNED_VIDEO_ID \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY"
```

| Status | Meaning | Next step |
|---|---|---|
| `queued` | Waiting to run | Continue polling |
| `in_progress` | Generating | Continue polling |
| `completed` | Generation completed | Download the video |
| `failed` | Generation failed | Read the `error` field |

Some providers may also report terminal states such as `cancelled` or `expired`. Stop polling for terminal failures and inspect the returned error. Poll every few seconds, rather than continuously.

---

## 3. Download the video

After the task reaches `completed`, download it using the same Routero task ID and key:

```bash
curl {{ site.api_base_url }}/v1/videos/RETURNED_VIDEO_ID/content \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  --output video.mp4
```

The response contains video bytes, rather than JSON. Save the result before the provider's download availability expires.

---

## Python: create, poll, and download

Install an `openai` package version that provides `client.videos`. This example polls every five seconds for up to ten minutes:

```python
import time
from openai import OpenAI

client = OpenAI(
    api_key="YOUR_ROUTERO_KEY",
    base_url="{{ site.api_base_url }}/v1",
)

video = client.videos.create(
    model="YOUR_VIDEO_MODEL",
    prompt="A slow camera move over a calm ocean at sunset",
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

A client-side polling timeout does not cancel the upstream task. Keep the task ID so you can check it again later, instead of creating a duplicate task.

---

## Use a reference image

For a model that supports image-to-video generation, upload a reference image as `input_reference`:

```bash
curl {{ site.api_base_url }}/v1/videos \
  -H "Authorization: Bearer YOUR_ROUTERO_KEY" \
  -F "model=YOUR_VIDEO_MODEL" \
  -F "prompt=A gentle breeze moves through the scene" \
  -F "input_reference=@first-frame.png"
```

Let curl set the multipart `Content-Type` and boundary. Accepted image formats, dimensions, and reference-image roles depend on the selected model.

## Provider-specific options

Video providers may offer additional controls for reference assets, audio, or generation settings. The OpenAI SDK provides `extra_body` for extra request fields; use options supported by the selected model and Routero adapter. See [Provider-specific parameters]({% link integration/api-calling.md %}#provider-specific-parameters).

Task listing and remix operations are provider-dependent. Check support for your selected model before using operations beyond the create, status, and download workflow described here.

If an API request fails, check the returned error, model access, input parameters, and rate limits. A successful task submission can still end in a generation failure; always inspect the terminal status.

## Related

→ [Images]({% link inference-apis/images.md %}) · [Models]({% link inference-apis/models.md %}) · [Calling the API]({% link integration/api-calling.md %})

→ [OpenAI Videos API reference (historical contract)](https://developers.openai.com/api/reference/resources/videos)
