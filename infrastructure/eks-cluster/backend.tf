# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket-name"
#     key            = "eks/${var.env}/terraform.tfstate"
#     region         = "us-east-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
