# Configure the Google Cloud provider
provider "google" {
  project = "your-project-id"
}

# List of 10 zones across different regions
variable "zones" {
  default = [
    "us-east4-a", "us-east4-b", "us-east4-c",
    "us-west2-a", "us-west2-b", "us-west2-c",
    "europe-west2-a", "europe-west2-b", "europe-west2-c",
    "asia-east1-a"
  ]
}

# Create a random password for the instances
resource "random_password" "instance_password" {
  length  = 16
  special = true
}

# Create 10 Windows Server instances
resource "google_compute_instance" "windows_instance" {
  count        = 10
  name         = "windows-instance-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = var.zones[count.index]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    windows-startup-script-ps1 = <<-EOT
      # Set the same password for all instances
      $password = ConvertTo-SecureString "${random_password.instance_password.result}" -AsPlainText -Force
      Set-LocalUser -Name "Administrator" -Password $password

      # Enable WinRM for Ansible
      Enable-PSRemoting -Force
      winrm quickconfig -q
      winrm set winrm/config/service '@{AllowUnencrypted="true"}'
      winrm set winrm/config/service/auth '@{Basic="true"}'
      New-NetFirewallRule -Name "WinRM 5985" -DisplayName "WinRM 5985" -Protocol TCP -LocalPort 5985
    EOT
  }

  # Allow RDP and WinRM access
  tags = ["rdp", "winrm"]
}

# Firewall rule to allow RDP and WinRM access (create for each network if necessary)
resource "google_compute_firewall" "rdp_winrm" {
  name    = "allow-rdp-winrm"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["3389", "5985"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["rdp", "winrm"]
}

# Output the instance names and IPs (format consistent with previous version)
output "instance_names" {
  value = google_compute_instance.windows_instance[*].name
}

output "instance_ips" {
  value = google_compute_instance.windows_instance[*].network_interface[0].access_config[0].nat_ip
}

output "common_password" {
  value     = random_password.instance_password.result
  sensitive = true
}

# Additional output for zone information (optional)
output "instance_zones" {
  value = google_compute_instance.windows_instance[*].zone
}
