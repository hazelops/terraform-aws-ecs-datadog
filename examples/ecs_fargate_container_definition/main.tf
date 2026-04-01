# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/).
# Copyright 2025-present Datadog, Inc.

################################################################################
# Datadog Agent Container Definition Only
#
# This example shows how to get Datadog agent container definition and volumes
# without creating a task definition, so you can merge them into your own.
################################################################################

module "datadog_agent" {
  source = "DataDog/ecs-datadog/aws//modules/ecs_fargate"

  create_task_definition = false

  dd_api_key = var.dd_api_key
  dd_site    = var.dd_site

  dd_service = var.dd_service
  dd_env     = var.dd_env
  dd_version = var.dd_version

  dd_dogstatsd = {
    enabled = true
  }

  dd_apm = {
    enabled = true
  }
}

################################################################################
# Your own Task Definition
################################################################################

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode(concat(
    [module.datadog_agent.container_definition],
    [
      {
        name      = "my-app"
        image     = "my-app:latest"
        essential = true
        portMappings = [
          {
            containerPort = 8080
            protocol      = "tcp"
          }
        ]
      }
    ]
  ))

  dynamic "volume" {
    for_each = module.datadog_agent.datadog_volumes
    content {
      name = volume.value.name
    }
  }
}
