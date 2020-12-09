terraform {
  required_version = ">= 0.12"
}

provider "google" {
  project = "dev-shakahl-com"
  region  = "eu-west3"
  zone    = "eu-west3-a"
}

provider "github" {
  owner = "shakahl"
  #organization = "shakahl"
  anonymous    = false
}

terraform {
  backend "gcs" {
    bucket = "shakahl-devops"
    prefix = "github.com/helm-charts"
  }
}
