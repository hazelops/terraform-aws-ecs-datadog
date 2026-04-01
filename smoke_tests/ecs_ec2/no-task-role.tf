# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/).
# Copyright 2025-present Datadog, Inc.

# Verifies that the module works when task role creation is disabled
# (e.g., when the role is managed by a parent module)
module "no_task_role" {
  source = "../../modules/ecs_ec2"

  dd_api_key       = var.dd_api_key
  dd_site          = var.dd_site
  family           = "${var.test_prefix}-no-task-role"
  create_task_role = false
  create_service   = false

  tags = {
    Test = "no-task-role"
  }
}

output "no_task_role_task_arn" {
  value = module.no_task_role.arn
}
