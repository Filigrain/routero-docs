---
lang: zh-CN
page_id: core-gateway/multi-tenancy
permalink: /core-gateway/multi-tenancy.html
title: 多租户
parent: 核心网关
nav_order: 7
description: "组织、团队、用户和客户——Routero 的分层租户模型。"
---

# 多租户

Routero AI 以四级层级来组织访问权限、支出和模型权限。每一级都可拥有自己的预算、限流和角色分配。

```
Organization (Workspace)
  └── Teams
        └── Users (internal)
              └── Customers (end-users / external)
```

---

## 组织（工作区）

最顶层的隔离边界。每个组织拥有：
- 自己的一套模型和供应商配置
- 独立的预算、限流和支出追踪
- 独立的审计日志
- 自己的 SAML/SSO 和 SCIM 配置（企业版）

在 Routero Cloud 中，一个组织对应你的公司。在私有部署或单租户云中，你可以为不同的业务单元、子公司或客户租户创建多个组织。

---

## 团队

组织内部的细分单位。团队是费用分摊和访问控制的主要单位：
- 每个团队拥有独立的预算和限流
- 团队成员继承团队级别的模型访问权限
- 团队支出汇总至组织仪表板
- RBAC 角色分配以团队为作用范围

```bash
# 创建一个团队
curl -X POST https://api.routero.ai/team/new \
  -H "Authorization: Bearer $ADMIN_KEY" \
  -d '{"team_alias": "data-science", "max_budget": 2000, "budget_duration": "1mo"}'
```

---

## 用户

内部用户（员工）拥有各自的身份标识，并具备：
- 个人 API 密钥（可选），可与团队密钥并存
- 角色分配（Admin、Developer、Auditor、Finance 或 Custom）
- 按用户的支出追踪和每日活动报告
- 通过 SCIM 或手动管理进行预配/注销

---

## 客户（最终用户）

对于在 Routero 上构建多租户 SaaS 产品的团队，`customer` 实体代表你的最终用户：
- 在任意请求上附加 `customer_id`，以追踪按客户的支出
- 设置按客户的预算和限流
- 通过 `/customer/daily/activity` 查看按客户的每日活动
- 适用于在面向消费者的应用中强制执行合理使用限额

```python
response = client.chat.completions.create(
    model="smart/balanced",
    messages=[...],
    extra_body={"user": "customer_alice_123"},  # 将支出追踪到此最终用户
)
```

---

## 切换组织

拥有多个组织访问权限的用户通过 `/user/switch_org` 切换上下文。活动组织由 `X-Organization-Id` 标头或请求体中的 `organization_id` 字段解析得出——管理 API 调用使用其中已设置的那一个；若两者均未设置，则使用密钥的默认组织。
