# Fargate Container Definition Example

This example shows how to use the module in container-definition-only mode (`create_task_definition = false`). The module outputs the Datadog agent container definition and required volumes, which you can merge into your own `aws_ecs_task_definition`.

## Usage

* Create a [Datadog API Key](https://app.datadoghq.com/organization-settings/api-keys)
* Create a `terraform.tfvars` file
  * Set the `dd_api_key` to the Datadog API Key (required)
  * (Optional) Set `dd_service`, `dd_env`, `dd_version` for Unified Service Tagging
  * (Optional) Set `dd_site` to the [Datadog destination site](https://docs.datadoghq.com/getting_started/site/)
* Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

### Example Module

```hcl
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
```
