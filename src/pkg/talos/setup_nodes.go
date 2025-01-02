package talos

import (
    "fmt"
    "github.com/spf13/cobra"
)

func SetupNodesCmd() *cobra.Command {
    return &cobra.Command{
        Use:   "setupNodes",
        Short: "Setup nodes of Talos",
        Run: func(cmd *cobra.Command, args []string) {
            fmt.Println("Setting up nodes of Talos...")
        },
    }
}
