---
id: prompt-example-template-v1
title: Example Template
summary: Example prompt template per canonical spec
model: generic
owner: agent
version: v1
last_updated: 2025-11-13
tags: [example]
variables:
  - name: example_var
    description: Example variable
    required: false
safety:
  constraints:
    - no destructive operations
  escalation:
    - ask user before making irreversible changes
---

## Usage
- When to use: demonstration only.
- Invocation notes: n/a
- Expected outputs: artifacts under 03-outputs/sample-tool/

## Prompt
This is an example. Variable: {{example_var}}

## Examples
- Input: foo → Output: bar

## Change-log
- v1 (2025-11-13): Initial version.

