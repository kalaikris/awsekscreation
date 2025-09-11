resource "aws_security_group" "eks_node_sg" {
  name_prefix = "eks-node-sg"
  vpc_id      = module.vpc.vpc_id

  description = "Security group for EKS worker nodes"

  ingress {
    description      = "Allow all traffic from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["10.0.0.0/16"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-sg"
  }
}
