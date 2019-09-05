# Search tracking

Code for this has yet to be migrated and [lives here](https://github.com/wellcometrust/search-logger).

## Source
[We use Segment analytics.js](https://segment.com/docs/sources/website/analytics.js/),
and tracks search actions on https://wellcomecollection.org/works.

This is then piped to [AWS Kinesis](https://aws.amazon.com/kinesis/).


## Sink
The data is stored in the `tracking_search` index of the reporting Elasticsearch cluster.

### Schema
```JS
{
  event: String,
  // This is the same for a person's browser session
  anonymousId: String,
  timestamp: Date,
  /**
    * This is only populated when someone is from inside the building
    * e.g. StaffCorporateDevices, Wellcome-WiFi
    */
  network: String,
  /**
    * what toggles where set / unset for this event
    * e.g. { "toggles.toggle_betaBar": false, "toggles.toggle_alphaBar": true }
    */
  toggles: Object<String, Boolean>,
  /** Any event specific data
    * e.g. The query that was set 
    * { "page": 2, "query": "snout" }
    */
  data: Object<String, any>
};
```



