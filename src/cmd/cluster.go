package cmd

import (
	"github.com/fgeck/homelab-k8s/src/pkg/cluster"
	"github.com/spf13/cobra"
)

var clusterCmd = &cobra.Command{
	Use:   "cluster",
	Short: "Setup/Reset Kubernetes Cluster using helm upgrade --install / uninstall",
}

func init() {
	clusterCmd.AddCommand(
		cluster.SetupClusterCmd(),
		cluster.ResetClusterCmd(),
	)
}
