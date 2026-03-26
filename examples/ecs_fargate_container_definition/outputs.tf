# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/).
# Copyright 2025-present Datadog, Inc.

output "task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}

output "container_definition" {
  value = module.datadog_agent.container_definition
}

output "datadog_volumes" {
  value = module.datadog_agent.datadog_volumes
}
