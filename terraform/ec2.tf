resource "aws_iam_instance_profile" "this" {
  name = "${var.environment}_ec2_role"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}

resource "aws_iam_policy" "s3_access" {
  name   = "${var.environment}_s3_access"
  policy = data.aws_iam_policy_document.s3_access.json

  tags = var.tags
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}_ec2_role"

  assume_role_policy = data.aws_iam_policy_document.ec2_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  policy_arn = aws_iam_policy.s3_access.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_instance" "this" {
  ami                     = data.aws_ami.this.id
  disable_api_termination = false
  ebs_optimized           = true
  iam_instance_profile    = aws_iam_instance_profile.this.name
  instance_type           = "t3a.small"
  key_name                = aws_key_pair.generated.key_name
  monitoring              = true
  subnet_id               = module.vpc.private_subnets[1]

  vpc_security_group_ids = [aws_security_group.this.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 3
    http_tokens                 = "required"
  }

  tags = merge(var.tags, {
    "Name"        = var.environment
    "backup"      = true
    "Patch Group" = "A"
  })

  volume_tags = merge(var.tags, { "Name" = "${var.environment}_vol" })

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  user_data = <<-EOF
      #!/bin/bash
      # Update packages on the system
      sudo yum update -y

      # Install S3 Mount
      wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
      sudo yum install ./mount-s3.rpm -y
      rm -f ./mount-s3.rpm

      # Create mount point directory
      sudo mkdir /mount_s3
      sudo mount-s3 ${module.s3.s3_bucket_id} /mount_s3
    EOF

  lifecycle {
    ignore_changes = [user_data, ami, vpc_security_group_ids]
  }
}

resource "aws_security_group" "this" {
  name        = var.environment
  description = "${var.environment} security group for owncloud"
  vpc_id      = module.vpc.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "egress" {
  from_port         = 0
  protocol          = -1
  security_group_id = aws_security_group.this.id
  to_port           = 0
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}