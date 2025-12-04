
variable "sns-name" {
  default = "Resized-Image-SNS-Topic"
  type    = string
}

variable "email" {
  default = "the.fire.dragon.mac@gmail.com" ##add your email
  type    = string
}

locals {
  pillow_layer_arn = "arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p311-Pillow:9"
}
