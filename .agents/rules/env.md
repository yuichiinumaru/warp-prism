---
id: env-governance
title: Environment Variable Governance
scope: universal
applies_to: [all-governed-repos]
triggers: [env, environment, model, llm model, api key, secret]
priority: critical
status: active
trigger: always_on
---

NUNCA mude env vars sem ser solicitado, principalmente modelos de LLM, ainda que você tenha modificado um antes e tenha achado estranho. Assuma que o user modificou depois e não reverta a mudança dele.
