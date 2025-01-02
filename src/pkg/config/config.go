package config

type Config struct {
	ScriptConfigs struct {
		ClusterName           string `yaml:"clusterName"`
		Gateway               string `yaml:"gateway"`
		FinalControlPlaneIp   string `yaml:"finalControlPlaneIp"`
		FinalWorker1Ip        string `yaml:"finalWorker1Ip"`
		FinalWorker2Ip        string `yaml:"finalWorker2Ip"`
		CurrentControlPlaneIp string `yaml:"currentControlPlaneIp"`
		CurrentWorker1Ip      string `yaml:"currentWorker1Ip"`
		CurrentWorker2Ip      string `yaml:"currentWorker2Ip"`
	} `yaml:"scriptConfigs"`

	Global struct {
		NFS struct {
			Server string `yaml:"server"`
		} `yaml:"nfs"`
	} `yaml:"global"`

	Bootstrap struct {
		IpRanges struct {
			RangeDefault string `yaml:"range_default"`
			CidrEdge     string `yaml:"cidr_edge"`
		} `yaml:"ip_ranges"`
	} `yaml:"bootstrap"`

	Storage struct {
		Longhorn struct {
			SMB struct {
				Server   string `yaml:"server"`
				Username string `yaml:"username"`
				Password string `yaml:"password"`
			} `yaml:"smb"`
		} `yaml:"longhorn"`
	} `yaml:"storage"`

	// Add other fields following the same pattern
}
