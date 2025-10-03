provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = "nam.pham"
      ManagedBy   = "terraform"
    }
  }
}


