# Create an IAM role for the Web Servers.
resource "aws_iam_role" "web_iam_role" {
    name = "web_iam_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
#Define iam policy
resource "aws_iam_instance_profile" "web_instance_profile" {
    name = "web_instance_profile"
    role = "web_iam_role"
}

resource "aws_iam_role_policy" "web_iam_role_policy" {
  name = "web_iam_role_policy"
  role = "${aws_iam_role.web_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::my-terraform-bucket-nov"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::my-terraform-bucket-nov/*"]
    }
  ]
}
EOF
}
#Create a S3 Bucket
resource "aws_s3_bucket" "my-terraform-bucket-nov" {
    bucket = "my-terraform-bucket-nov"
    acl = "private"
    versioning {
            enabled = true
    }
    tags = {
        Name = "my-terraform-bucket-nov"
    }
}
#Create Ec2 Instance with IAM Role
resource "aws_instance" "build" {
    ami = "ami-0cfd0973db26b893b" # Amazon Linux 2023 AMI 2023.2.20231113.0 x86_64 HVM kernel-6.1
    availability_zone = "eu-west-2a"
    instance_type = "t2.micro"
    key_name = "jenkinskeypair"  
    iam_instance_profile = "${aws_iam_instance_profile.web_instance_profile.id}"
}