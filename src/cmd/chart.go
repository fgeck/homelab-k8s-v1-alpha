package cmd

import (
	"github.com/fgeck/homelab-k8s/src/pkg/chart"
	"github.com/spf13/cobra"
)

var chartCmd = &cobra.Command{
	Use:   "chart",
	Short: "Install/Update a single chart",
}

func init() {
	chartCmd.AddCommand(
		chart.UpstallChartCmd(),
	)
}
