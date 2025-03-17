# Declare input variables
variable "NAME" {
  description = "Full Name"
  type        = string
  default     = "Rajkumar Singh"
}

variable "EMAIL" {
  description = "Email Address"
  type        = string
  default     = "rajkumarsingh07@gmail.com"
}

variable "AWS_REGION" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1" # Set this to your preferred AWS region
}

# Create a private subnet
resource "aws_subnet" "private_subnet_new" {
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = "10.0.13.0/24" # Hardcoded CIDR block
  availability_zone = "ap-south-1a"  # Change this if needed

  tags = {
    Name = "private-subnet"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate the route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet_new.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create a security group for the Lambda function
resource "aws_security_group" "lambda_sg" {
  vpc_id = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-security-group"
  }
}

# Create the Lambda function
resource "aws_lambda_function" "lambda1" {
  function_name = "devops-exam-lambda1"
  role          = data.aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_new.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      API_ENDPOINT = "https://6fhjjqbmad.execute-api.eu-west-1.amazonaws.com/candidate-email_serverless_lambda_stage/data"
      SUBNET_ID    = aws_subnet.private_subnet_new.id
      NAME         = var.NAME
      EMAIL        = var.EMAIL
    }
  }
}

# Null resource to package and upload Lambda
resource "null_resource" "lambda_package_and_upload" {
  provisioner "local-exec" {
    command = "aws lambda update-function-code --function-name devops-exam-lambda1 --zip-file fileb://lambda.zip --region ${var.AWS_REGION}"
  }
}

# Output the subnet ID for use in the Jenkins pipeline
output "subnet_id" {
  value = aws_subnet.private_subnet_new.id
}

output "name" {
  value = var.NAME
}

output "email" {
  value = var.EMAIL
}
