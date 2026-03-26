# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/).
# Copyright 2025-present Datadog, Inc.

################################################################################
# Datadog Agent Container Definition (available regardless of create_task_definition)
################################################################################

output "container_definition" {
  description = "Datadog agent container definition to merge into your own task definition."
  value       = one(local.dd_agent_container)
}

output "datadog_volumes" {
  description = "Volumes required by the Datadog agent container."
  value       = local.modified_volumes
}

################################################################################
# Task Definition Outputs (only available when create_task_definition = true)
################################################################################

output "container_definitions" {
  description = "A list of valid container definitions provided as a single valid JSON document."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].container_definitions : null
}

output "cpu" {
  description = "Number of cpu units used by the task."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].cpu : null
}

output "enable_fault_injection" {
  description = "Enables fault injection and allows for fault injection requests to be accepted from the task's containers."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].enable_fault_injection : null
}

output "ephemeral_storage" {
  description = "The amount of ephemeral storage to allocate for the task."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].ephemeral_storage : null
}

output "execution_role_arn" {
  description = "ARN of the task execution role."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].execution_role_arn : null
}

output "family" {
  description = "A unique name for your task definition."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].family : null
}

output "inference_accelerator" {
  description = "Inference accelerator settings."
  value       = null
}

output "ipc_mode" {
  description = "IPC resource namespace to be used for the containers."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].ipc_mode : null
}

output "memory" {
  description = "Amount (in MiB) of memory used by the task."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].memory : null
}

output "network_mode" {
  description = "Docker networking mode to use for the containers."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].network_mode : null
}

output "pid_mode" {
  description = "Process namespace to use for the containers."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].pid_mode : null
}

output "placement_constraints" {
  description = "Rules that are taken into consideration during task placement."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].placement_constraints : null
}

output "proxy_configuration" {
  description = "Configuration block for the App Mesh proxy."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].proxy_configuration : null
}

output "requires_compatibilities" {
  description = "Set of launch types required by the task."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].requires_compatibilities : null
}

output "runtime_platform" {
  description = "Runtime platform configuration for the task definition."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].runtime_platform : null
}

output "skip_destroy" {
  description = "Whether to retain the old revision when the resource is destroyed or replacement is necessary."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].skip_destroy : null
}

output "tags" {
  description = "Key-value map of resource tags."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].tags : null
}

output "task_role_arn" {
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].task_role_arn : null
}

output "track_latest" {
  description = "Whether should track latest ACTIVE task definition on AWS or the one created with the resource stored in state."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].track_latest : null
}

output "volume" {
  description = "Configuration block for volumes that containers in your task may use."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].volume : null
}

# Attribute reference outputs

output "arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].arn : null
}

output "arn_without_revision" {
  description = "ARN of the Task Definition with the trailing revision removed."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].arn_without_revision : null
}

output "revision" {
  description = "Revision of the task in a particular family."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].revision : null
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including inherited tags."
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].tags_all : null
}
