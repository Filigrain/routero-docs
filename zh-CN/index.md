---
lang: zh-CN
page_id: index
permalink: /
title: 快速开始
nav_order: 1
description: "三步上手：添加模型、创建密钥、发出第一个请求。"
---

# 快速开始

三步让第一个请求通过 Routero：**添加模型**、**创建密钥**，然后从你的应用里**使用该密钥**。如果你已在用 OpenAI SDK，最后一步只需改一行 `base_url`。

{: .note }
**前提条件：** 组织管理员账号，且你的组织已被分配了供应商。Routero 采用邀请制，模型引用的是平台管理员分配给组织的供应商密钥——如果列表里没有你需要的供应商，请联系管理员。

---

## 第 1 步 —— 添加模型

在侧边栏打开 **Models**，选择 **+ Add Model**。

![Models 页面，带 + Add Model 按钮](/assets/images/quickstart/quickstart-models-list.png)

在 **Add Model** 抽屉中：

1. **Provider** —— 选择一个已分配给你组织的供应商。
2. **Model Name** —— 选择一个模型，或选 “All {Provider} Models” 一次暴露该供应商的全部模型。
3. **Public Model Name** —— 你的应用发给 Routero 的别名。这就是第 3 步里 `model` 要用的值。可保留默认或重命名。

其余保持默认，点击 **Add Model**（可先用 **Test Connect** 验证供应商可达）。

![Add Model 抽屉——供应商、模型名，以及你将要调用的公开模型名](/assets/images/quickstart/quickstart-add-model.png)

{: .note }
供应商列表为空？说明平台管理员尚未给你的组织分配供应商密钥——请联系管理员添加。

---

## 第 2 步 —— 创建密钥

打开 **API Keys**，选择 **+ Create New Key**。

![API Keys 页面，带 + Create New Key 按钮](/assets/images/quickstart/quickstart-api-keys-list.png)

在 **Create New Key** 抽屉中：

1. **Key Name** —— 密钥的名称。
2. **Models** —— 该密钥可调用哪些模型。默认 “All Proxy Models”，也可选择具体模型。
3.（可选）**Budget & Rate Limits** —— 设置支出上限或 TPM/RPM 限制。

点击 **Create Key**。会弹出 **Save your Key** 对话框，显示新的虚拟密钥（`sk-…`）——**立即复制，它只显示一次。**

![Create New Key 抽屉，以及显示 sk-… 虚拟密钥的 Save-your-Key 对话框](/assets/images/quickstart/quickstart-create-key.png)

![Save your Key 对话框——复制虚拟密钥，仅显示一次](/assets/images/quickstart/quickstart-key-created.png)

---

## 第 3 步 —— 使用密钥

用你的密钥把任意 OpenAI SDK——或普通 HTTP 客户端——指向 Routero，并请求第 1 步设置的**公开模型名（Public Model Name）**。

```python
from openai import OpenAI

client = OpenAI(
    api_key="sk-...YOUR_KEY...",          # 第 2 步拿到的虚拟密钥
    base_url="https://api.routero.ai/v1",
)

response = client.chat.completions.create(
    model="openai/gpt-5.5",               # 第 1 步设置的公开模型名
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

```bash
curl https://api.routero.ai/v1/chat/completions \
  -H "Authorization: Bearer sk-...YOUR_KEY..." \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.5",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

该请求会出现在你的[平台仪表板](https://platform.routero.ai)的用量与支出视图中。其他端点（向量、图像、模型列表）参见[推理 API]({% link zh-CN/inference-apis.md %})。

---

## 接下来

- **让编码助手经由 Routero** —— [Cursor]({% link zh-CN/integration/cursor.md %})、[Claude Code]({% link zh-CN/integration/claude-code.md %})、[Codex]({% link zh-CN/integration/codex.md %})。
- **添加 AI 能力**（护栏、提示词、记忆、缓存）—— [AI 能力]({% link zh-CN/advanced-features.md %})。
- **设置支出预算** —— [预算限额]({% link zh-CN/observability/budget-limits.md %})。
