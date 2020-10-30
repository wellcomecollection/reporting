import json
import os

import httpx
import stringcase
from weco_datascience.credentials import get_secrets
from weco_datascience.logging import get_logger

from date import report_yesterday_or_last_week
from metrics import compare

log = get_logger(__name__)


def format_metric(key, value):
    formatted_key = stringcase.sentencecase(key)
    return f"*{formatted_key}:* {value}"


def build_slack_payload(metrics, comparison_metrics):
    return {
        "blocks": [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": ":bar_chart: How's search doing?"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"{report_yesterday_or_last_week().capitalize()}, we saw"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": compare(metrics, comparison_metrics)
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "Take a look at the full dashboard: https://reporting.wellcomecollection.org/s/search/"
                }
            },
        ]
    }


def post_to_slack(payload):
    secret = get_secrets("reporting/slack_webhook_url")
    resp = httpx.post(secret["webhook_url"], json=payload)

    log.info(f"Sent payload to Slack: {resp}")

    if resp.status_code != 200:
        log.info("Non-200 response from Slack")

        log.info("Request:")
        log.info(json.dumps(payload, indent=2, sort_keys=True))

        log.info("Response:")
        log.info(resp.text)
