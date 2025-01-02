package cluster

import (
	"fmt"

	"github.com/spf13/cobra"
)

func ResetClusterCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "reset",
		Short: "Reset the Kubernetes cluster",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("Resetting Kubernetes cluster...")
		},
	}
}
