package secrets_test

import (
	"testing"

	sdk "github.com/bitwarden/sdk-go"
)

func TestVwAccess(t *testing.T) {
	apiURL := ""
	identityURL := ""
	accessToken := ""

	bitwardenClient, _ := sdk.NewBitwardenClient(&apiURL, &identityURL)
	err := bitwardenClient.AccessTokenLogin(accessToken, nil)
	if err != nil {
		panic(err)
	}
}
