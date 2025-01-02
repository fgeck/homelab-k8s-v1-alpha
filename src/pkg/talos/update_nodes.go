package talos

import (
    "fmt"
    "github.com/spf13/cobra"
)

func UpdateNodesCmd() *cobra.Command {
    return &cobra.Command{
        Use:   "updateNodes",
        Short: "Update nodes of Talos",
        Run: func(cmd *cobra.Command, args []string) {
            fmt.Println("Updating nodes of Talos...")
        },
    }
}
