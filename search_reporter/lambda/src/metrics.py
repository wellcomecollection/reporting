import humanize
import stringcase
from weco_datascience.logging import get_logger

from date import report_yesterday_or_last_week
from elastic import get_data

log = get_logger(__name__)


class MetricCalculator():
    def __init__(self):
        self.data_store = {}

    def get_data(self, start, end):
        date_hash = hash((start, end))
        if date_hash not in self.data_store:
            log.info(f"fetching data for time window: {start} - {end}")
            self.data_store[date_hash] = get_data(start, end)
        return self.data_store[date_hash]

    def _get_searches(self, start, end):
        df = self.get_data(start, end)
        searches = df["event"].value_counts()["Search"]
        return {
            "formatted": humanize.intcomma(searches),
            "value": searches
        }

    def _get_sessions(self, start, end):
        df = self.get_data(start, end)
        sessions = len(df["anonymousId"].unique())
        return {
            "formatted": humanize.intcomma(sessions),
            "value": sessions
        }

    def _get_clicks_per_search(self, start, end):
        df = self.get_data(start, end)
        event_counts = df["event"].value_counts()
        clicks_per_search = (
            event_counts["Search result selected"] / event_counts["Search"]
        )
        return {
            "formatted": str(int(100 * clicks_per_search)) + "%",
            "value": clicks_per_search
        }

    def _get_median_click_position(self, start, end):
        df = self.get_data(start, end)
        median = df["data_position"].dropna().median()
        return {
            "formatted": str(int(median)),
            "value": median
        }

    def _get_conversion(self, start, end):
        raise NotImplementedError

    def _get_searches_with_no_results(self, start, end):
        df = self.get_data(start, end)
        searches = df["event"].value_counts()["Search"]
        searches_with_no_results = df["data_totalResults"].value_counts()[0]
        percentage = searches_with_no_results * 100 // int(searches)
        return {
            "formatted": str(percentage) + "%",
            "value": percentage
        }

    def _get_sessions_with_clicks(self, start, end):
        df = self.get_data(start, end)
        n_sessions = len(df["anonymousId"].unique())
        with_clicks = sum([
            1
            for _, group in df.groupby("anonymousId")
            if "Search result selected" in group["event"].values
        ])
        percentage = with_clicks * 100 // n_sessions
        return {
            "formatted": str(percentage) + "%",
            "value": percentage
        }

    def get_metrics(self, start, end):
        metrics = {
            "searches": self._get_searches(start, end),
            "sessions": self._get_sessions(start, end),
            "clicks_per_search": self._get_clicks_per_search(start, end),
            "median_click_position": self._get_median_click_position(start, end),
            "searches_with_no_results": self._get_searches_with_no_results(start, end),
            "sessions_with_clicks": self._get_sessions_with_clicks(start, end),
        }
        return metrics


def compare(metrics, comparison_metrics, alpha=0.05):
    window = report_yesterday_or_last_week()
    message = ""
    for key, value in metrics.items():
        formatted_key = stringcase.sentencecase(key)
        formatted_value = value['formatted']
        value = metrics[key]["value"]
        comparison = comparison_metrics[key]["value"]

        if value > comparison * (1 + alpha):
            change_direction = "increase"
            percentage = abs(int(100 * (1-(value / comparison))))
            message += (
                f"*{formatted_key}:* {formatted_value}\n"
                f"That's a {percentage}% {change_direction} from {window}\n"
            )

        elif value * (1 + alpha) < comparison:
            change_direction = "decrease"
            percentage = abs(int(100 * (1-(value / comparison))))
            message += (
                f"*{formatted_key}:* {formatted_value}\n"
                f"That's a {percentage}% {change_direction} from {window}"
            )
        else:
            message += (
                f"*{formatted_key}:* {formatted_value}\n"
                f"That's a roughly the same as it was {window}"
            )

    return message
