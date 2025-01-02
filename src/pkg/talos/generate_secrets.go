package talos

import (
    "fmt"
    "github.com/spf13/cobra"
)

func GenerateSecretsCmd() *cobra.Command {
    return &cobra.Command{
        Use:   "generateSecrets",
        Short: "Generate secrets for Talos",
        Run: func(cmd *cobra.Command, args []string) {
            fmt.Println("Generating secrets for Talos...")
        },
    }
}
