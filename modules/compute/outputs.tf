output "compute_instance_id" {
  value = aws_instance.compute_spot.id
}

output "compute_public_ip" {
  value = aws_instance.compute_spot.public_ip
}

output "compute_security_group_id" {
  value = aws_security_group.compute_sg.id
}

output "compute_sg_id" {
  value = aws_security_group.compute_sg.id
}

