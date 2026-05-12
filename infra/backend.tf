terraform {
  backend "s3" {
    bucket       = "mm-interview"
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
    profile      = "Tom"
  }
}