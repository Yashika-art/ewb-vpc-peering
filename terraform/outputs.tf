output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "vpc_ids" {
  value = { vpc_a = aws_vpc.a.id, vpc_b = aws_vpc.b.id }
}

output "instance_ids" {
  value = {
    bastion = aws_instance.bastion.id
    app_a   = aws_instance.app_a.id
    app_b   = aws_instance.app_b.id
  }
}

output "peering_id" {
  value = var.enable_peering ? aws_vpc_peering_connection.a_b[0].id : "not created (baseline phase)"
}
