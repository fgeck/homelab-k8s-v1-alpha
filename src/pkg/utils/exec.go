package utils

import (
	"os/exec"
)

// ExecuteCommand runs a command with arguments and logs the output.
func ExecuteCommand(name string, args ...string) error {
	LogInfo("Executing: %s %v", name, args)
	cmd := exec.Command(name, args...)
	cmd.Stdout = logrus.StandardLogger().Out
	cmd.Stderr = logrus.StandardLogger().Out
	return cmd.Run()
}
