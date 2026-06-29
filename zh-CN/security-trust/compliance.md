---
lang: zh-CN
page_id: security-trust/compliance
permalink: /security-trust/compliance.html
title: 合规
parent: 安全与信任
nav_order: 2
description: "SOC 2 Type II、HIPAA BAA、ISO 27001、GDPR DPA——Routero AI 的合规态势。"
---

# 合规

Routero AI 专为受监管的企业打造。本页汇总当前的认证情况，以及获取合规文件所需的条件。

---

## 认证

| 标准 | 状态 | 说明 |
|---|---|---|
| **SOC 2 Type II** | 现行有效 | 年度审计。报告可在签署 NDA 后提供给企业版客户。 |
| **HIPAA BAA** | 可提供 | 企业版套餐。需要专用部署（单租户云或私有部署）。 |
| **ISO 27001** | 进行中 | 目标认证时间：2026 年下半年。 |
| **GDPR DPA** | 可提供 | 含欧盟标准合同条款（SCC）。面向所有欧盟客户提供。 |
| **PCI DSS** | 未认证 | Routero 不处理支付卡数据。 |

---

## SOC 2 Type II

年度 SOC 2 Type II 审计涵盖：
- **安全性**——访问控制、加密、日志
- **可用性**——正常运行时间监控、事件响应、DR/BCP
- **保密性**——数据分类与处理
- **处理完整性**——准确、完整且及时的处理

如需索取报告：请联系你的解决方案工程师，或发送邮件至 compliance@routero.ai 并附上贵公司的详细信息。

---

## HIPAA

HIPAA 业务伙伴协议（BAA）面向使用专用部署的企业版客户提供。该 BAA 涵盖 Routero 对可能出现在元数据中的受保护健康信息（PHI）的处理（审计日志条目、密钥归属）。

{: .note }
Routero 从不存储提示词与响应内容——这是一项核心隐私特性。BAA 涵盖的是审计元数据。贵组织在内容层面的 PHI 处理义务仍由你自行承担。

---

## GDPR

针对欧盟客户，Routero 提供：
- **数据处理协议（DPA）**——涵盖 Routero 作为数据处理者的角色
- **标准合同条款（SCC）**——用于欧盟境外的数据传输
- **子处理者清单**——AWS（针对欧盟部署使用新加坡 / 欧盟西区），可应请求提供

可通过位于 `eu-west-1` 或 `eu-central-1` 的单租户云实现欧盟境内的数据驻留。→ [数据驻留与地域]({% link zh-CN/deployment/data-residency.md %})

---

## 中国 PIPL

针对在中国大陆开展业务的客户，Routero 的中国北京部署（`cn-north-1`，光环新网账户）可提供符合 PIPL 要求的中国境内数据驻留。参见[数据驻留与地域]({% link zh-CN/deployment/data-residency.md %})。

---

## 索取合规文件

请联系 [compliance@routero.ai](mailto:compliance@routero.ai) 或你的解决方案工程师，以索取：
- SOC 2 Type II 报告
- 安全问卷答复
- GDPR DPA 与 SCC
- HIPAA BAA
- 渗透测试执行摘要
