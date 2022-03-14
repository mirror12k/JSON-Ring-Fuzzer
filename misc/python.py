#!/usr/bin/env python3

import json


with open("data.json", "r") as f:
    data = f.read()

obj = json.loads(data)

with open("data.json", "w") as f:
    f.write(json.dumps(obj))
