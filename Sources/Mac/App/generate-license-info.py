#!/usr/bin/python3

import plistlib
import json

licenses = []

base = "Sources/iOS/App/Settings.bundle/"

with open(base + "com.mono0926.LicensePlist.plist", "rb") as f:
    for link in plistlib.load(f)["PreferenceSpecifiers"]:
        if link["Type"] != "PSChildPaneSpecifier":
            continue
        with open(base + link["File"] + ".plist", "rb") as f:
            licenses.append({
                "title": link["Title"],
                "text": plistlib.load(f)["PreferenceSpecifiers"][0]["FooterText"]
            })

with open("Sources/Mac/App/Generated/licenses.json", "w") as f:
    json.dump(licenses, f, ensure_ascii=False, indent="\t")