package cluster

import (
	"fmt"
	"path/filepath"

	"github.com/fgeck/homelab-k8s/src/pkg/utils"

	"github.com/spf13/cobra"
)

func SetupClusterCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "setup",
		Short: "Installs all helm charts in the Kubernetes cluster",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("Setting up Kubernetes cluster...")
		},
	}
}

// SetupCluster performs the cluster setup tasks.
func setup() error {
	utils.LogInfo("START: Helm Repo Add/Update and Dependency Build")

	// Add Helm repositories
	helmRepos := map[string]string{
		"kube-vip":    "https://kube-vip.github.io/helm-charts",
		"longhorn":    "https://charts.longhorn.io",
		"traefik":     "https://traefik.github.io/charts",
		"jetstack":    "https://charts.jetstack.io",
		"crowdsec":    "https://crowdsecurity.github.io/helm-charts",
		"bitnami":     "https://charts.bitnami.com/bitnami",
		"signoz":      "https://charts.signoz.io",
		"keel":        "https://charts.keel.sh",
		"vaultwarden": "https://guerzon.github.io/vaultwarden",
		"uptime-kuma": "https://dirsigler.github.io/uptime-kuma-helm",
	}

	for name, url := range helmRepos {
		if err := utils.ExecuteCommand("helm", "repo", "add", name, url); err != nil {
			return fmt.Errorf("failed to add Helm repo '%s': %w", name, err)
		}
	}

	// Update Helm repositories
	if err := utils.ExecuteCommand("helm", "repo", "update"); err != nil {
		return fmt.Errorf("failed to update Helm repositories: %w", err)
	}

	// Build Helm dependencies
	chartDir := filepath.Join(scriptDir, "helm")
	if err := utils.ExecuteCommand("helm", "dependency", "build", chartDir); err != nil {
		return fmt.Errorf("failed to build Helm dependencies: %w", err)
	}
	utils.LogSuccess("DONE: Helm Repo Add/Update and Dependency Build")

	// Helm upgrade/install commands
	utils.LogInfo("START: Helm Upgrade/Install")

	installations := []struct {
		namespace string
		release   string
		chartPath string
		values    []string
	}{
		{"kube-system", "bootstrap", "1-bootstrap", []string{"1-bootstrap/values.yaml", "secrets/values.yaml"}},
		{"default", "persistence", "2-persistence", []string{"2-persistence/values.yaml", "secrets/values.yaml"}},
		{"monitoring", "monitoring", "3-monitoring", []string{"3-monitoring/values.yaml", "secrets/values.yaml"}},
		{"media", "media", "4-media", []string{"4-media/values.yaml", "secrets/values.yaml"}},
	}

	for _, inst := range installations {
		utils.LogInfo("Installing %s in namespace %s", inst.release, inst.namespace)
		if err := utils.ExecuteCommand("kubectl", "config", "set-context", "--current", fmt.Sprintf("--namespace=%s", inst.namespace)); err != nil {
			return fmt.Errorf("failed to set namespace to '%s': %w", inst.namespace, err)
		}

		helmArgs := []string{"upgrade", inst.release, filepath.Join(chartDir, inst.chartPath), "--install"}
		for _, valueFile := range inst.values {
			helmArgs = append(helmArgs, "-f", filepath.Join(scriptDir, valueFile))
		}

		if err := utils.ExecuteCommand("helm", helmArgs...); err != nil {
			return fmt.Errorf("failed to upgrade/install %s: %w", inst.release, err)
		}
		utils.LogSuccess("DONE: Installed %s", inst.release)
	}

	// Restart deployments (workaround for stuck Helm upgrades)
	restarts := []struct {
		resource  string
		namespace string
	}{
		{"deployment/kube-vip-cloud-provider", "kube-system"},
		{"daemonset/kube-vip", "kube-system"},
	}

	for _, restart := range restarts {
		utils.LogInfo("Restarting %s in namespace %s", restart.resource, restart.namespace)
		if err := utils.ExecuteCommand("kubectl", "rollout", "restart", restart.resource, "-n", restart.namespace); err != nil {
			return fmt.Errorf("failed to restart %s: %w", restart.resource, err)
		}
	}

	utils.LogSuccess("DONE: Helm Upgrade/Install")
	return nil
}
