package talos

import (
    "fmt"
    "github.com/spf13/cobra"
)

func ResetNodesCmd() *cobra.Command {
    return &cobra.Command{
        Use:   "resetNodes",
        Short: "Resets all nodes of Talos",
        Run: func(cmd *cobra.Command, args []string) {
            fmt.Println("Resetting nodes...")
        },
    }
}
