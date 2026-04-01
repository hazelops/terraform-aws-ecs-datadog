// Unless explicitly stated otherwise all files in this repository are licensed
// under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2025-present Datadog, Inc.

package test

import (
	"log"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// TestNoTaskRole tests that the Fargate module works when task role creation is disabled
func (s *ECSFargateSuite) TestNoTaskRole() {
	log.Println("TestNoTaskRole: Running test...")

	taskArn := terraform.Output(s.T(), s.terraformOptions, "no_task_role_fargate_arn")
	s.Contains(taskArn, s.testPrefix+"-no-task-role", "Task ARN should contain the correct family name")
}
