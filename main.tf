provider "aws" {
  version = "~> 2.0"
  region = "us-east-1"
  profile = "Personal_Profile"
}

resource "aws_ecr_repository" "single_page_application_repo" {
  name = "single_page_application_repo"
}
