package chart

import (
	"fmt"

	"github.com/spf13/cobra"
)

func UpstallChartCmd() *cobra.Command {
	chartUpstallCmd := &cobra.Command{
		Use:   "upstall",
		Short: "Installs or upgrades a chart for a given name. the name will be looked up in the directories in ./helm directory",
		Run: func(cmd *cobra.Command, args []string) {
			name, _ := cmd.Flags().GetString("name")
			fmt.Printf("Installing or upgrading Helm chart: %s\n", name)
		},
	}
	chartUpstallCmd.Flags().StringP("name", "n", "", "Name of the local chart (required)")
	chartUpstallCmd.MarkFlagRequired("name")
	return chartUpstallCmd
}
