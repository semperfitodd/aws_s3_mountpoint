resource "aws_key_pair" "generated" {
  depends_on = [tls_private_key.default]
  key_name   = var.environment
  public_key = tls_private_key.default.public_key_openssh

  tags = var.tags
}

resource "aws_secretsmanager_secret" "pem" {
  name        = "${var.environment}_${random_string.this.result}"
  description = "Keypair (${var.environment}) - private key"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "pem" {
  secret_id     = aws_secretsmanager_secret.pem.id
  secret_string = tls_private_key.default.private_key_pem
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
}