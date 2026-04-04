# 비용 알림 — Free Tier 초과 시 이메일 알림
resource "aws_budgets_budget" "zero_spend" {
  name         = "fabbit-${var.environment}-zero-spend"
  budget_type  = "COST"
  limit_amount = "0.01"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }
}
