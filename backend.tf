# backend.tf
terraform {
  backend "s3" {
    bucket = "467.devops.candidate.exam"
    key    = "rajkumar.singh" # Replace with your first and last name
    region = "ap-south-1"
  }
}