package cmd

import (
    "github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
    Use:   "homelab",
    Short: "Homelab CLI for managing Kubernetes and Talos configurations",
}

// Execute runs the root command
func Execute() error {
    return rootCmd.Execute()
}

func init() {
    rootCmd.AddCommand(talosCmd, clusterCmd, chartCmd, secretsCmd)
}
