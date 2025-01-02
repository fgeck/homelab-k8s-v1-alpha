package cmd

import (
	"github.com/fgeck/homelab-k8s/src/pkg/secrets"
	"github.com/spf13/cobra"
)

var secretsCmd = &cobra.Command{
	Use:   "secrets",
	Short: "Push//Pull secrets to/from Vaultwarden",
}

func init() {
	secretsCmd.AddCommand(
		secrets.PushSecretsCmd(),
		secrets.PullSecretsCmd(),
	)
}
