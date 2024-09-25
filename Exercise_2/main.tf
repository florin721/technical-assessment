provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2a"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2b"
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.5.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2c"
  tags = {
    Name = "public-subnet-3"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2b"
  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.6.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-west-2c"
  tags = {
    Name = "private-subnet-3"
  }
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "example-igw"
  }
}

resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_2" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_3" {
  domain = "vpc"
}

resource "aws_nat_gateway" "example_nat_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "example-nat-gateway-1"
  }
}

resource "aws_nat_gateway" "example_nat_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  tags = {
    Name = "example-nat-gateway-2"
  }
}

resource "aws_nat_gateway" "example_nat_3" {
  allocation_id = aws_eip.nat_eip_3.id
  subnet_id     = aws_subnet.public_subnet_3.id
  tags = {
    Name = "example-nat-gateway-3"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example_nat_1.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example_nat_2.id
  }

  tags = {
    Name = "private-route-table-2"
  }
}

resource "aws_route_table" "private_rt_3" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example_nat_3.id
  }

  tags = {
    Name = "private-route-table-3"
  }
}

resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id
}

resource "aws_route_table_association" "private_rt_assoc_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_rt_3.id
}

resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.example.id

  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80         
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"       
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb-security-group"
  }
}


resource "aws_security_group" "k8s_nodes_sg" {
  name        = "k8s-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.example.id

  ingress {
    description = "Allow traffic from ALB on NodePort 30080"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"              
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-nodes-security-group"
  }
}


resource "aws_security_group_rule" "lb_sg_egress_to_k8s_nodes" {
  type                     = "egress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_sg.id
  source_security_group_id = aws_security_group.k8s_nodes_sg.id
  description              = "Allow outbound traffic to worker nodes on NodePort 30080"

  lifecycle {
    ignore_changes = all
    create_before_destroy = true
  }
}

resource "aws_eks_cluster" "example" {
  name     = "example-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id,
      aws_subnet.private_subnet_3.id,
    ]
    security_group_ids = [aws_security_group.k8s_nodes_sg.id]
  }

  tags = {
    Name = "example-eks-cluster"
  }
}


resource "aws_launch_template" "eks_node_launch_template" {
  name = "eks-node-launch-template"

  vpc_security_group_ids = [aws_security_group.k8s_nodes_sg.id]

  instance_type = "t3.medium" 

  user_data = filebase64("${path.module}/eks-user-data.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-worker-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id
  ]
  node_group_name = "example-node-group"

  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }

  launch_template {
    id      = aws_launch_template.eks_node_launch_template.id
    version = "1"
  }

  lifecycle {
    ignore_changes = [
      launch_template[0].version  
    ]
  }

  tags = {
    Name = "example-eks-node-group"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "example-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  ]

  tags = {
    Name = "eks-cluster-role"
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "example-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]

  tags = {
    Name = "eks-node-role"
  }
}

resource "aws_lb" "k8s_lb" {
  name               = "k8s-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id
  ]

  tags = {
    Name = "k8s-lb"
  }
}

resource "aws_lb_listener" "k8s_lb_listener" {
  load_balancer_arn = aws_lb.k8s_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_target_group.arn
  }
}

resource "aws_lb_target_group" "k8s_target_group" {
  name        = "k8s-target-group"
  port        = 30080            
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.example.id

  health_check {
    protocol            = "HTTP"
    path                = "/"   
    port                = "30080"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 6
  }
}


data "aws_instances" "eks_nodes" {
  filter {
    name   = "tag:eks:cluster-name"
    values = [aws_eks_cluster.example.name]
  }

  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.example.node_group_name]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
  
}

resource "aws_lb_target_group_attachment" "k8s_node_targets" {
for_each = toset(data.aws_instances.eks_nodes.ids)

target_group_arn = aws_lb_target_group.k8s_target_group.arn
target_id        = each.key
port             = 30080
}
