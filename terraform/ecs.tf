## ECS cluster
resource "aws_ecs_cluster" "reporting_aggregations_cluster" {
  name = "reporting_aggregations"
}

## Scheduled tasks
module "scheduled_task" {
  source              = "./modules/scheduled_ecs_task"
  name                = "aggregate_relevance_metrics"
  schedule_expression = "cron(0 6 * * ? *)" 
  cluster_arn         = "${aws_ecs_cluster.reporting_aggregations_cluster.arn}"

  container_definitions = <<EOF
    [{
        "name": "aggregate_relevance_metrics",
        "image": "harrisonpim/aggregate_relevance_metrics:latest",
        "cpu": 512,
        "memory": 512,
        "essential": true,
        "portMappings": [{
            "containerPort": 80,
            "hostPort": 80
        }]
    }]
    EOF
}
