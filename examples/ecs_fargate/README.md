# ECS Fargate Example

This example showcases a simple ECS Fargate Task Definition with out of the box Datadog instrumentation.

## Usage

* Create a [Datadog API Key](https://app.datadoghq.com/organization-settings/api-keys)
* Create a `terraform.tfvars` file
  * Set the `dd_api_key` to the Datadog API Key (required)
  * Set the `dd_service` to the name of the service you want to use to filter for the resource in Datadog
  * Set the `dd_site` to the [Datadog destination site](https://docs.datadoghq.com/getting_started/site/) for your metrics, traces, and logs
  * (Optional) Set `task_family_name` to the name of the task family (default: "dummy-terraform-app")
* Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

### Example Module

```hcl
module "datadog_ecs_fargate_task" {
  source  = "DataDog/ecs-datadog/aws//modules/ecs_fargate"

  # Configure Datadog
  dd_api_key                       = var.dd_api_key
  dd_site                          = var.dd_site
  dd_service                       = var.dd_service
  dd_tags                          = "team:cont-p, owner:container-monitoring"
  dd_essential                     = true
  dd_is_datadog_dependency_enabled = true

  dd_dogstatsd = {
    enabled                  = true
    dogstatsd_cardinality    = "high",
    origin_detection_enabled = true,
  }

  dd_apm = {
    enabled = true,
  }

  dd_log_collection = {
    enabled = true,
  }

  # Configure Task Definition
  family = "datadog-terraform-app"
  container_definitions = jsonencode([
    {
      name      = "datadog-dogstatsd-app",
      image     = "ghcr.io/datadog/apps-dogstatsd:main",
      essential = false,
    },
    {
      name      = "datadog-apm-app",
      image     = "ghcr.io/datadog/apps-tracegen:main",
      essential = true,
    },
  ])
  volumes = [
    {
      name = "app-volume"
    }
  ]
  runtime_platform = {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  requires_compatibilities = ["FARGATE"]
}
```

## Options

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create_task_definition` | Whether to create the `aws_ecs_task_definition` resource. Set to `false` to only output the Datadog agent container definition and volumes. | `bool` | `true` | no |
| `dd_api_key` | Datadog API Key (mutually exclusive with `dd_api_key_secret`) | `string` | `null` | yes* |
| `dd_api_key_secret` | Datadog API Key Secret ARN | `object({arn=string})` | `null` | yes* |
| `dd_site` | Datadog destination site | `string` | `"datadoghq.com"` | no |
| `dd_service` | Service name for UST tagging | `string` | `null` | no |
| `dd_env` | Environment for UST tagging | `string` | `null` | no |
| `dd_version` | Version for UST tagging | `string` | `null` | no |
| `dd_tags` | Custom Datadog tags | `string` | `null` | no |
| `dd_apm` | APM configuration (enabled, profiling, data_streams, etc.) | `object` | `{}` | no |
| `dd_dogstatsd` | DogStatsD configuration (enabled, cardinality, origin_detection) | `object` | `{}` | no |
| `dd_log_collection` | Log collection via FluentBit/Firelens | `object` | `{}` | no |
| `dd_cws` | Cloud Workload Security configuration | `object` | `{}` | no |
| `family` | Task definition family name | `string` | `null` | when `create_task_definition = true` |
| `container_definitions` | JSON-encoded list of your container definitions | `any` | `"[]"` | when `create_task_definition = true` |
| `cpu` | Task CPU units | `number` | `256` | no |
| `memory` | Task memory (MiB) | `number` | `512` | no |
| `execution_role` | Existing IAM execution role | `object` | `null` | no |
| `task_role` | Existing IAM task role | `object` | `null` | no |
| `volumes` | Additional volume definitions | `list` | `[]` | no |
| `runtime_platform` | OS and CPU architecture | `object` | `null` | no |

\* One of `dd_api_key` or `dd_api_key_secret` is required.

## Outputs

| Name | Description |
|------|-------------|
| `container_definition` | Datadog agent container definition (always available) |
| `datadog_volumes` | Volumes required by the Datadog agent (always available) |
| `arn` | Task definition ARN (only when `create_task_definition = true`) |
| `arn_without_revision` | Task definition ARN without revision |
| `container_definitions` | Full container definitions JSON from the task definition |
| `cpu` | Task CPU units |
| `memory` | Task memory |
| `execution_role_arn` | Execution role ARN |
| `task_role_arn` | Task role ARN |
| `family` | Task definition family |
| `revision` | Task definition revision |
| `volume` | Volume configuration |

## Container Definition Only Mode

If you want to manage the `aws_ecs_task_definition` yourself, set `create_task_definition = false`:

```hcl
module "datadog_agent" {
  source = "DataDog/ecs-datadog/aws//modules/ecs_fargate"

  create_task_definition = false
  dd_api_key             = var.dd_api_key
}

resource "aws_ecs_task_definition" "this" {
  family                   = "my-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode(concat(
    [module.datadog_agent.container_definition],
    [your_containers...]
  ))

  dynamic "volume" {
    for_each = module.datadog_agent.datadog_volumes
    content {
      name = volume.value.name
    }
  }
}
```

See [examples/ecs_fargate_container_definition](../ecs_fargate_container_definition/) for the full example.
