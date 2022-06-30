resource "aws_ecs_service" "single_page_application_service" {
  name            = "single-page-application-service"                        # Naming our first service
  cluster         = "${aws_ecs_cluster.single_page_application.id}"          # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.single_page_application.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3                                                        # Setting the number of containers we want deployed to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_name = "${aws_ecs_task_definition.single_page_application.family}"
    container_port = 3000
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 80
    to_port   = 3000
    protocol  = "tcp"
    # Only allowing traffic in from the load balancer security group
   security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
}

