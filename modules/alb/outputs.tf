output "alb_dns_name" { value = aws_lb.alb.dns_name }
output "alb_arn_suffix" { value = aws_lb.alb.arn_suffix }
output "tg_front_arn" { value = aws_lb_target_group.front.arn }
output "tg_back_arn" { value = aws_lb_target_group.back.arn }
output "tg_front_arn_suffix" { value = aws_lb_target_group.front.arn_suffix }
output "tg_back_arn_suffix" { value = aws_lb_target_group.back.arn_suffix }
