package main

import (
	"fmt"
	"github.com/fgeck/homelab-k8s/src/cmd"
	"github.com/fgeck/homelab-k8s/src/pkg/config"
	"os"
)

func main() {
	// Load YAML configuration
	cfg, err := config.LoadConfig("secrets/values.yaml")
	if err != nil {
		fmt.Printf("Error loading config: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Loaded configuration for cluster: %s\n", cfg.ScriptConfigs.ClusterName)

	// Execute CLI
	if err := cmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
