//Launch Template

resource "aws_launch_template" "this" {
  name_prefix   = "asg-spot-lt-"
  image_id      = var.asg_ami_id
  instance_type = var.asg_instance_type
  key_name      = var.asg_key_name

  vpc_security_group_ids = var.asg_security_group_ids

user_data = base64encode(
  replace(
    var.asg_user_data,
    "$${ASG_S3_BUCKET}",
    var.asg_s3_bucket_name
  )
)


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "asg-spot-instance"
      Role = "asg"
    }
  }
}

//ASG

resource "aws_autoscaling_group" "this" {
  name             = "asg-spot-web"
  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  vpc_zone_identifier = var.asg_public_subnet_ids

  target_group_arns = [
    var.asg_target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 60

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this.id
        version            = "$Latest"
      }

      override {
        instance_type = "t3.micro"
      }

      override {
        instance_type = "t3a.micro"
      }
    }
  }

  tag {
    key                 = "Name"
    value               = "asg-spot-web"
    propagate_at_launch = true
  }
}
