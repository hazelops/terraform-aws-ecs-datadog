# Datadog Terraform Modules for AWS ECS Tasks

[![License](https://img.shields.io/badge/license-Apache--2.0-blue)](https://github.com/DataDog/terraform-aws-lambda-datadog/blob/main/LICENSE)

Use this [Terraform module](https://registry.terraform.io/modules/DataDog/ecs-datadog/aws/latest) to install Datadog monitoring for AWS Elastic Container Service tasks.

This Terraform module wraps the [aws_ecs_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) resource and automatically configures your task definition for Datadog monitoring.

For more information on the ECS Fargate module, reference the submodule [documentation](https://github.com/DataDog/terraform-aws-ecs-datadog/blob/main/modules/ecs_fargate/README.md).

For more information on the ECS on EC2 module, reference the submodule [documentation](https://github.com/DataDog/terraform-aws-ecs-datadog/blob/main/modules/ecs_ec2/README.md).

If you encounter any issues, please open a GitHub issue to let us know.

## Usage

### ECS Fargate

```hcl
module "datadog_ecs_fargate_task" {
  source  = "DataDog/ecs-datadog/aws//modules/ecs_fargate"

  # Datadog Configuration
  dd_api_key_secret = {
    arn = "arn:aws:secretsmanager:us-east-1:0000000000:secret:example-secret"
  }
  dd_tags = "team:cont-p, owner:container-monitoring"

  # Task Configuration
  family = "example-app"
  container_definitions = jsonencode([
    {
      name      = "datadog-dogstatsd-app",
      image     = "ghcr.io/datadog/apps-dogstatsd:main",
    }
  ])
}
```

### ECS Fargate — Container Definition Only

Set `create_task_definition = false` to get the Datadog agent container definition and volumes without creating a task definition. This lets you merge them into your own `aws_ecs_task_definition`:

```hcl
module "datadog_agent" {
  source = "DataDog/ecs-datadog/aws//modules/ecs_fargate"

  create_task_definition = false

  dd_api_key_secret = {
    arn = "arn:aws:secretsmanager:us-east-1:0000000000:secret:example-secret"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "my-app"
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
```

### ECS on EC2

```hcl
module "datadog_agent" {
  source  = "DataDog/ecs-datadog/aws//modules/ecs_ec2"

  # Datadog Configuration
  dd_api_key_secret = {
    arn = "arn:aws:secretsmanager:us-east-1:0000000000:secret:example-secret"
  }
  dd_tags = "team:ecs-xp, owner:container-monitoring"
  dd_cluster_name = "my-ecs-cluster"

  # Task Definition
  family = "datadog-agent-daemon"

  # Daemon Service
  cluster_arn = "arn:aws:ecs:us-east-1:0000000000:cluster/my-cluster"
}
```

## Examples

- [ECS Fargate — Full Task Definition](examples/ecs_fargate/) — Module creates and manages the task definition
- [ECS Fargate — Container Definition Only](examples/ecs_fargate_container_definition/) — Module outputs container definition for use in your own task definition
