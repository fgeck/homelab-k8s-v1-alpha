package cmd

import (
    "github.com/spf13/cobra"
    "github.com/fgeck/homelab-k8s/src/pkg/talos"
)

var talosCmd = &cobra.Command{
    Use:   "talos",
    Short: "Manage Talos nodes",
}

func init() {
    talosCmd.AddCommand(
        talos.GenerateSecretsCmd(),
        talos.GenerateConfigsCmd(),
        talos.SetupNodesCmd(),
        talos.UpdateNodesCmd(),
        talos.ResetNodesCmd(),
    )
}
