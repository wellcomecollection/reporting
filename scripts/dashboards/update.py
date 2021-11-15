import json
import os
from pathlib import Path

import httpx

from credentials import kibana_url

print("Building .ndjson file for bulk upload")
data_path = Path("/data/")
import_file = data_path / "import.ndjson"

file_paths = sorted(data_path.glob("*.json"))
with open(import_file, "w") as outfile:
    for file_path in file_paths:
        with open(file_path, "r", encoding="utf-8") as infile:
            json.dump(json.load(infile), outfile)
            outfile.write("\n")

print("Importing dashboards")
request = httpx.post(
    f"{kibana_url}/s/search/api/saved_objects/_import",
    files={"file": open("/data/import.ndjson", "rb")},
    params={"overwrite": "true"},
    headers={"kbn-xsrf": "true"},
)

print(request.json())

print("Deleting .ndjson file")
os.remove(import_file)
