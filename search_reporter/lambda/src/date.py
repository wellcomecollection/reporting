from datetime import date, timedelta
import os
from weco_datascience.logging import get_logger

log = get_logger(__name__)


def report_yesterday_or_last_week():
    if date.today().weekday() == 0:
        window = "last week"
    elif date.today().weekday() in [1, 2, 3, 4]:
        window = "yesterday"
    else:
        log.info("I don't work weekends")
        exit(1)
    return window


def get_time_windows():
    window = report_yesterday_or_last_week()
    if window == "last week":
        date_window = {
            "start": str(date.today() - timedelta(weeks=1)),
            "end": str(date.today()),
            "comparison_start": str(date.today() - timedelta(weeks=2)),
            "comparison_end": str(date.today() - timedelta(weeks=1)),
        }

    elif window == "yesterday":
        # if today is any other weekday, report on the previous day
        date_window = {
            "start": str(date.today() - timedelta(days=1)),
            "end": str(date.today()),
            "comparison_start": str(date.today() - timedelta(days=2)),
            "comparison_end": str(date.today() - timedelta(days=1)),
        }

    return date_window
