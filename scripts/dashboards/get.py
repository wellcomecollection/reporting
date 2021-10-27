import json

import httpx

from credentials import kibana_url

export_response = (
    httpx.post(
        f"{kibana_url}/s/search/api/saved_objects/_export",
        data={"type": "dashboard", "includeReferencesDeep": True},
        headers={"kbn-xsrf": "true"},
    )
    .read()
    .decode("utf-8")
)

saved_objects = export_response.split("\n")
print(f"Found {len(saved_objects)} saved objects")

for object in saved_objects:
    parsed_object = json.loads(object)
    try:
        file_name = f"{parsed_object['type']}-{parsed_object['id']}.json"

        print(f"Writing object to file: {file_name}")
        with open(f"/data/{file_name}", "w", encoding="utf-8") as f:
            json.dump(parsed_object, f, ensure_ascii=False, indent=4)
    except KeyError:
        print(parsed_object)
