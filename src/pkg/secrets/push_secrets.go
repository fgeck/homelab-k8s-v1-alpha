package secrets

import (
    "fmt"
    "github.com/spf13/cobra"
)

func PullSecretsCmd() *cobra.Command {
    return &cobra.Command{
        Use:   "pullSecrets",
        Short: "Pull secrets/values.yaml, secrets/secrets.yaml, talos/_out/talosconfig from Vaultwarden",
        Run: func(cmd *cobra.Command, args []string) {
            fmt.Println("Pulling secrets from Vaultwarden...")
        },
    }
}
