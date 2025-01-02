package utils

import (
	"github.com/sirupsen/logrus"
)

var logger = logrus.New()

func init() {
	logger.SetFormatter(&logrus.TextFormatter{
		FullTimestamp: true,
	})
}

func LogInfo(format string, args ...interface{}) {
	logger.Infof(format, args...)
}

func LogSuccess(format string, args ...interface{}) {
	logger.Infof("\033[1;32m"+format+"\033[0m", args...)
}

func LogError(format string, args ...interface{}) {
	logger.Errorf("\033[1;31m"+format+"\033[0m", args...)
}
