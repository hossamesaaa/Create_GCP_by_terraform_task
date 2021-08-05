

################public_instance############################

resource "google_compute_instance" "public" {
  name         = "public-instance"
  machine_type = "e2-medium"
  zone         = "us-east1-b"

  tags = ["${var.name}-public-instance"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

   network_interface {
    network      ="${var.name}-vpc"  
    subnetwork  = google_compute_subnetwork.public-subnet.id

    access_config {
      // Ephemeral IP
    }
   }
  
  

}


################private_instance############################
resource "google_compute_instance" "private" {
  name         = "private-instance"
  machine_type = "e2-medium"
  zone        = "us-central1-a"
  
  tags = ["${var.name}-private-instance"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
    }
    
   network_interface {
     network      ="${var.name}-vpc"      
     subnetwork  = google_compute_subnetwork.private-subnet.id
     
   }

   
}









