package secrets

import (
    "fmt"
    "github.com/spf13/cobra"
)

func PushSecretsCmd() *cobra.Command {
    return &cobra.Command{
        Use:   "pushSecrets",
        Short: "Push secrets/values.yaml, secrets/secrets.yaml, talos/_out/talosconfig to Vaultwarden",
        Run: func(cmd *cobra.Command, args []string) {
            fmt.Println("Pushing secrets to Vaultwarden...")
        },
    }
}
