# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/).
# Copyright 2025-present Datadog, Inc.

variable "dd_api_key" {
  description = "Datadog API Key"
  type        = string
}

variable "dd_service" {
  description = "The service name for UST tagging in Datadog"
  type        = string
  default     = null
}

variable "dd_env" {
  description = "The environment for UST tagging in Datadog"
  type        = string
  default     = null
}

variable "dd_version" {
  description = "The version for UST tagging in Datadog"
  type        = string
  default     = null
}

variable "dd_site" {
  description = "Datadog Site"
  type        = string
  default     = "datadoghq.com"
}

variable "task_family_name" {
  description = "The ECS task family name"
  type        = string
  default     = "my-app"
}
