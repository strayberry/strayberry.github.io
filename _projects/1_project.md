---
layout: page
title: "DaG: Cross-Modal-Guided Token Compression"
description: Training-free token compression for long-context AV-LLM inference.
img: assets/img/projects/dag.svg
importance: 1
category: research
---

DaG 面向长上下文音视频多模态推理场景，目标是在尽量保持精度的前提下，降低推理延迟与显存开销。

我主导了以下核心设计：

- 文本/音频引导的视觉 token 压缩策略
- 动态音频保留预算（adaptive retained-audio budgeting）
- video-level feature caching，减少重复问答的预处理成本

评测侧覆盖 accuracy、throughput、TTFT、prefill latency 与 GPU memory 等指标，并完成评测 pipeline 的工程适配。

相关论文：{% cite dag2026 %}
