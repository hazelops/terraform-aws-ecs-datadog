# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/).
# Copyright 2025-present Datadog, Inc.

################################################################################
# Container Definition Only: No Task Definition Created
################################################################################

# Verifies that the module can output the Datadog agent container definition
# and volumes without creating an aws_ecs_task_definition resource
module "dd_container_definition_only" {
  source = "../../modules/ecs_ec2"

  create_task_definition = false
  create_service         = false

  dd_api_key = var.dd_api_key
  dd_site    = var.dd_site
  dd_tags    = "team:cont-p, owner:container-monitoring"
  family     = "${var.test_prefix}-container-def-only"

  dd_dogstatsd = {
    enabled        = true
    socket_enabled = true
  }

  dd_apm = {
    enabled        = true
    socket_enabled = true
  }

  dd_log_collection = {
    enabled = false
  }
}

# Verifies that the module can output just the container definition with all
# Datadog features disabled
module "dd_container_definition_only_minimal" {
  source = "../../modules/ecs_ec2"

  create_task_definition = false
  create_service         = false

  dd_api_key = var.dd_api_key
  family     = "${var.test_prefix}-container-def-only-minimal"

  dd_dogstatsd = {
    enabled = false
  }

  dd_apm = {
    enabled = false
  }

  dd_log_collection = {
    enabled = false
  }
}

output "container_def_only_dd_agent" {
  value = module.dd_container_definition_only.container_definition
}

output "container_def_only_dd_volumes" {
  value = module.dd_container_definition_only.datadog_volumes
}
