- from https://docs.aws.amazon.com/AmazonECS/latest/developerguide/scheduled_tasks.html        
    - from https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
        ```
        aws events put-rule --schedule-expression "cron(0 12 * * ? *)" --name MyRule1
        ```