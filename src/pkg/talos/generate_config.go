package talos

import (
    "fmt"
    "github.com/spf13/cobra"
)

func GenerateConfigsCmd() *cobra.Command {
    return &cobra.Command{
        Use:   "generateConfigs",
        Short: "Generate configuration files for Talos",
        Run: func(cmd *cobra.Command, args []string) {
            fmt.Println("Generating configuration files for Talos...")
        },
    }
}
