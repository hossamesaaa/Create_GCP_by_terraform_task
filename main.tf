// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("${var.credentials}")}"
 project     = "${var.gcp_project}" 
 region      = "${var.vpc_region}"
}

// Create VPC
resource "google_compute_network" "vpc" {
 name                    = "${var.name}-vpc"
 auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "public-subnet" {
 name          = "${var.name}-public-subnet"
 ip_cidr_range = "${var.public-subnet_cidr}"
 network       =  google_compute_network.vpc.id
 region      = "${var.region-eu}"
}

resource "google_compute_subnetwork" "private-subnet" {
 name          = "${var.name}-private-subnet"
 ip_cidr_range = "${var.private-subnet_cidr}"
 network       =  google_compute_network.vpc.id
 region        = "${var.region-us}"
}


// VPC firewall configuration
resource "google_compute_firewall" "firewall" {
  name    = "${var.name}-firewall"
  network       =  google_compute_network.vpc.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  target_tags = ["${var.name}-vpc"]

  source_ranges = ["0.0.0.0/0"]
}



# Cloud Router
# https://www.terraform.io/docs/providers/google/r/compute_router.html
resource "google_compute_router" "router" {
  name    = "router"
  region  = google_compute_subnetwork.private-subnet.region
  network = google_compute_network.vpc.id
  bgp {
    asn            = 64514
    advertise_mode = "CUSTOM"
  }
}

# NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name          = google_compute_subnetwork.private-subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    
  }
}

