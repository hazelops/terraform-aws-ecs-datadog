// Unless explicitly stated otherwise all files in this repository are licensed
// under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2025-present Datadog, Inc.

package test

import (
	"encoding/json"
	"log"

	"github.com/aws/aws-sdk-go-v2/service/ecs/types"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// TestContainerDefinitionOnly tests the module with create_task_definition = false
// and APM/DogStatsD sockets enabled
func (s *ECSFargateSuite) TestContainerDefinitionOnly() {
	log.Println("TestContainerDefinitionOnly: Running test...")

	output := terraform.OutputMap(s.T(), s.terraformOptions, "container-definition-only")

	// Task definition outputs should be null when create_task_definition = false
	s.Equal("", output["family"], "Task family should be empty when create_task_definition is false")
	s.Equal("", output["arn"], "Task ARN should be empty when create_task_definition is false")
	s.Equal("", output["container_definitions"], "Task container_definitions should be empty when create_task_definition is false")

	// container_definition output should be present (the Datadog agent container)
	s.NotEmpty(output["container_definition"], "container_definition output should be present")

	var agentContainer types.ContainerDefinition
	err := json.Unmarshal([]byte(output["container_definition"]), &agentContainer)
	s.NoError(err, "Failed to parse container_definition output")

	s.Equal("datadog-agent", *agentContainer.Name, "Agent container name should be datadog-agent")
	s.Equal("public.ecr.aws/datadog/agent:latest", *agentContainer.Image, "Unexpected agent image")

	// Verify port mappings are present
	AssertPortMapping(s.T(), agentContainer, PortUDP)
	AssertPortMapping(s.T(), agentContainer, PortTCP)

	// Verify socket mount point (APM socket enabled)
	AssertMountPoint(s.T(), agentContainer, MountDdSocket)

	// Verify environment variables
	expectedEnvVars := map[string]string{
		"DD_API_KEY":   "test-api-key",
		"DD_SITE":      "datadoghq.com",
		"DD_TAGS":      "team:cont-p, owner:container-monitoring",
		"ECS_FARGATE":  "true",
		"DD_SERVICE":   "test-service",
	}
	AssertEnvVars(s.T(), agentContainer, expectedEnvVars)

	// Verify health check is present
	s.NotNil(agentContainer.HealthCheck, "Agent health check should be defined")
	s.Contains(agentContainer.HealthCheck.Command, "/probe.sh", "Agent health check command should include probe.sh")

	// Verify datadog_volumes output is present
	s.NotEmpty(output["datadog_volumes"], "datadog_volumes output should be present")

	var volumes []map[string]interface{}
	err = json.Unmarshal([]byte(output["datadog_volumes"]), &volumes)
	s.NoError(err, "Failed to parse datadog_volumes output")
	s.Greater(len(volumes), 0, "Should have at least one volume (dd-sockets)")

	// Verify dd-sockets volume is present (since APM socket is enabled)
	foundSocketVolume := false
	for _, vol := range volumes {
		if vol["name"] == "dd-sockets" {
			foundSocketVolume = true
			break
		}
	}
	s.True(foundSocketVolume, "dd-sockets volume should be present when APM socket is enabled")
}

// TestContainerDefinitionOnlyMinimal tests the module with create_task_definition = false
// and all Datadog features disabled
func (s *ECSFargateSuite) TestContainerDefinitionOnlyMinimal() {
	log.Println("TestContainerDefinitionOnlyMinimal: Running test...")

	output := terraform.OutputMap(s.T(), s.terraformOptions, "container-definition-only-minimal")

	// Task definition outputs should be null
	s.Equal("", output["family"], "Task family should be empty when create_task_definition is false")
	s.Equal("", output["arn"], "Task ARN should be empty when create_task_definition is false")

	// container_definition output should be present
	s.NotEmpty(output["container_definition"], "container_definition output should be present")

	var agentContainer types.ContainerDefinition
	err := json.Unmarshal([]byte(output["container_definition"]), &agentContainer)
	s.NoError(err, "Failed to parse container_definition output")

	s.Equal("datadog-agent", *agentContainer.Name, "Agent container name should be datadog-agent")
	s.Equal("public.ecr.aws/datadog/agent:latest", *agentContainer.Image, "Unexpected agent image")

	// Verify basic environment variables
	expectedEnvVars := map[string]string{
		"DD_API_KEY":  "test-api-key",
		"ECS_FARGATE": "true",
	}
	AssertEnvVars(s.T(), agentContainer, expectedEnvVars)

	// Verify no socket mount points when features are disabled
	s.Equal(0, len(agentContainer.MountPoints), "Expected no mount points when features are disabled")

	// Verify datadog_volumes output is present (may be empty list)
	s.NotEmpty(output["datadog_volumes"], "datadog_volumes output should be present")
}
