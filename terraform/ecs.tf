## ECS cluster
resource "aws_ecs_cluster" "reporting_aggregations_cluster" {
  name = "reporting_aggregations"
}

## Scheduled tasks
module "scheduled_task_search_relevance_explicit_NDCG" {
  source              = "./modules/scheduled_ecs_task"
  name                = "search_relevance_explicit_NDCG"
  schedule_expression = "cron(0 6 * * ? *)"
  cluster_arn         = "${aws_ecs_cluster.reporting_aggregations_cluster.arn}"

  container_definitions = <<EOF
    [{
        "name": "search_relevance_explicit_NDCG",
        "image": "harrisonpim/search_relevance_explicit_NDCG:latest",
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

module "scheduled_task_search_relevance_explicit_precision" {
  source              = "./modules/scheduled_ecs_task"
  name                = "search_relevance_explicit_precision"
  schedule_expression = "cron(0 6 * * ? *)"
  cluster_arn         = "${aws_ecs_cluster.reporting_aggregations_cluster.arn}"

  container_definitions = <<EOF
    [{
        "name": "search_relevance_explicit_precision",
        "image": "harrisonpim/search_relevance_explicit_precision:latest", 
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

# n.b. the images in the container definitions above don't actually exist yet.
# they still need to be built and pushed to ECR/dockerhub at some point.

