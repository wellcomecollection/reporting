# Scripts

## Get dashboards

Save kibana dashboards (and their related child objects, eg visualisations) as json, using the [kibana saved objects export API](https://www.elastic.co/guide/en/kibana/master/saved-objects-api-export.html).

```sh
docker compose up --build get_dashboards
```

NB You'll need a valid set of AWS credentials which can assume the `platform-developer` role in order to fetch elastic credentials.

## Update dashboards

Update kibana saved objects using the json from the script above. This uses the [kibana saved objects import API](https://www.elastic.co/guide/en/kibana/master/saved-objects-api-import.html).

```sh
docker compose up --build update_dashboards
```

NB You'll need a valid set of AWS credentials which can assume the `platform-developer` role in order to fetch elastic credentials.
