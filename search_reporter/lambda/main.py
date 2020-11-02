"""
This lambda posts a daily update on key search metrics to wellcome's
#wc-search slack channel
"""

import json
import os

from weco_datascience.logging import get_logger

from slack import build_slack_payload, post_to_slack
from src.date import get_time_windows
from src.metrics import MetricCalculator

log = get_logger(__name__)

dates = get_time_windows()

m = MetricCalculator()
log.info("calculating metrics")
metrics = m.get_metrics(dates["start"], dates["end"])
comparison_metrics = m.get_metrics(
    dates["comparison_start"], dates["comparison_end"]
)

log.info("building payload for slack")
slack_payload = build_slack_payload(
    metrics=metrics,
    comparison_metrics=comparison_metrics
)

log.info(slack_payload)
post_to_slack(slack_payload)
