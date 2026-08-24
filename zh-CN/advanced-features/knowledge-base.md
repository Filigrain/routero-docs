---
lang: zh-CN
page_id: advanced-features/knowledge-base
permalink: /advanced-features/knowledge-base.html
title: 知识库
parent: AI 能力
nav_order: 5
description: "上传一次你的文档——Routero 自动解析、分块、向量化并建立索引，并在每个请求中检索相关段落注入提示词。"
---

# 知识库

知识库让你的应用基于**你自己的文档**给出有依据的回答。在仪表板中上传文件，Routero 会解析、分块、向量化并建立索引。在每个引用该知识库的请求上，相关段落会被检索出来并注入提示词——无需运营向量存储，也无需自建 RAG 管道。

知识库适合**共享的、相对稳定的参考资料**——产品手册、规章制度、FAQ、技术规格。若需要按用户积累的事实与会话历史，请使用[记忆即服务]({% link zh-CN/advanced-features/memory-service.md %})；两者可在同一请求上组合使用。

---

## 工作原理

**摄取（仪表板）。** 上传文档后，它会经历四个阶段，每个阶段都能在文档列表中看到：

```
待处理 → 解析中 → 向量化中 → 就绪（或失败）
```

1. **解析** —— 文件被转换为 Markdown（PDF 文本、Office 文档、纯文本）。
2. **分块** —— Markdown 按标题切分，一个分块绝不会横跨两个章节，表格保持完整。每个分块都带有其标题路径（例如 `手册 > 安全 > 密钥`）。
3. **向量化与索引** —— 平台的内部嵌入服务将每个分块转换为向量并建立索引。你的密钥不会产生任何模型费用，内容也不会发送给外部供应商。

重复上传同一文件是无操作——文档按内容哈希去重。失败的文档可以再次上传（或重建索引）重试。

**检索（请求时）。** 在默认的**自动检索**模式下，每个引用知识库的请求会：

1. 网关用会话中最近几轮用户消息构造查询。
2. 在知识库中搜索最相似的分块（默认前 5 条，且需高于相似度阈值）。
3. 命中的段落会被插入到最后一条用户消息中，并带有一段头部说明，告诉模型把这些内容当作**参考资料而非指令**——防止文档内容实施提示词注入。
4. 如果没有任何分块超过阈值，请求照常进行——检索直接跳过。

检索**失败开放（fail-open）**：出现任何问题，请求仍会正常通过，只是不带知识上下文。每个请求只能引用一个知识库。

知识库钩子在 AI 能力钩子中最后运行，位于记忆上下文注入之后：

```
GuardrailHook → PromptHook → TokenSavingPlanHook → MemoryHook → KnowledgeHook
```

---

## 支持的文档

| 类型 | 处理方式 |
|---|---|
| Markdown、纯文本、CSV、JSON | 按原文解析 |
| **带文本层**的 PDF | 具备版面感知的文本提取；复杂表格可能被展平 |
| Word、Excel、PowerPoint（`.docx/.xlsx/.pptx` 及旧版 `.doc/.xls/.ppt`） | 转换为 Markdown |

{: .warning }
> **不支持扫描版 PDF** —— 没有文本层的 PDF 会明确报错（未启用 OCR）。请改传文本版导出文件。

限制：**单个文件 32 MB**，**单个文档 500 页**。超限文档会失败并给出明确提示。

---

## 激活

```python
response = client.chat.completions.create(
    model="openai/gpt-5.5",
    messages=[{"role": "user", "content": "年付方案的退款政策是什么？"}],
    extra_body={"knowledge_base_id": "product-handbook"},
)
```

`knowledge_base_id` 可在顶层或 `metadata` 内传入。该 ID 会在请求转发前被剥离。知识库也可以[通过策略绑定]({% link zh-CN/core-gateway/policies.md %})，从而在密钥或模型上自动激活——请求中显式传入的 `knowledge_base_id` 仍然优先。

在 **Playground** 中，可在 Advanced Settings 下选择知识库，针对在线模型试用检索效果。

---

## 创建知识库

打开 **AI Capabilities → Knowledge**，选择 **Create Knowledge Base**。表单包含：

- **Name（名称）** —— 在组织内唯一（如 `product-handbook`）。
- **Description（描述）** —— 可选。
- **Engine（引擎）** —— 平台的向量索引。默认引擎适用于所有场景。
- **Retrieval mode（检索方式）** —— **Automatic（自动检索**，默认）在每个请求前检索，兼容任何模型；**Tool（工具调用**）改为向模型提供一个搜索工具，需要支持工具调用的模型。

{: .note }
引擎及其嵌入模型在**创建时固定** —— 事后更改会使所有已索引向量失效。若要更换配置，请新建一个知识库并重新上传文档。

![Knowledge 页面——知识库列表，含引擎、检索方式、文档数与分块数](/assets/images/knowledge-base/knowledge-list.png)

![Create Knowledge Base 抽屉——名称、描述、引擎与检索方式](/assets/images/knowledge-base/create-knowledge-base.png)

{: .beta }
> **工具调用模式为实验性功能。** 目前受支持的路径是自动检索；工具调用模式尚未完成。生产流量请保持 Automatic。

---

## 管理文档

打开某个知识库进入详情视图：嵌入模型、向量维度、实时的文档数与分块数，以及两个标签页——**Documents** 与 **Test retrieval**。

**Documents** 标签页是语料的家：

- **上传** —— 点击或拖入文件，支持一次多个。列表显示实时的 "x of y ready" 计数，并在文档处理期间自动刷新。
- **每个文档的状态** —— 就绪 / 待处理 / 解析中 / 向量化中 / 失败，失败时会显示错误信息。
- **预览** —— 点击文件名，可逐字查看被索引的解析后 Markdown。
- **Re-index（重建索引）** —— 对单个文档重新运行索引（复用已解析的 Markdown）。
- **删除** —— 移除该文档及其所有已索引分块。

![知识库详情视图——Documents 标签页，含上传区、状态与分块数](/assets/images/knowledge-base/knowledge-documents.png)

---

## 检索测试

**Test retrieval** 标签页运行的正是网关在请求时执行的同一搜索。像用户一样输入一个问题，可调整返回条数，然后搜索：你会看到每个分块及其相似度得分、来源文件与位置——这些就是会被注入提示词的段落。低于阈值的查询不会返回任何结果，模型看到的也正是如此。

![Test retrieval 标签页——一个查询与来自已索引文档的带得分分块](/assets/images/knowledge-base/knowledge-retrieval-test.png)

---

## 组织隔离与权限

- **按组织作用域限定。** 知识库属于一个组织；每个已索引向量都带有组织标记，搜索始终按你的组织过滤。
- **谁能管理。** 组织管理员可创建、删除知识库，上传、重建索引与删除文档。普通成员可查看知识库并运行检索测试。

---

## 与网关其余部分的组合

- **策略** —— 将知识库绑定到[策略]({% link zh-CN/core-gateway/policies.md %})，使其在密钥或模型上自动激活。
- **记忆 / 提示词 / 护栏 / Token 节省** —— 其余 [AI 能力]({% link zh-CN/advanced-features.md %})在护栏之后按正常顺序作用于同一请求；护栏始终在知识上下文加入之前检查调用方的原始输入。
- **Playground** —— 在 Advanced Settings 下选择知识库，实测有依据的回答。

→ 关于将知识库绑定到密钥与模型，参见 [策略]({% link zh-CN/core-gateway/policies.md %})。
