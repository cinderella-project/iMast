#!/usr/bin/env python3
import subprocess
import glob
import sys
import re
from typing import Any
import json
import os

if len(sys.argv) < 4:
    print("Usage: " + sys.argv[0] + " [Path to DerivedData] [Config] [Platform] [App filename]")
    exit(1)
    

def call_process(args: list[str]):
    process = subprocess.run(args, capture_output=True, text=True)
    process.check_returncode()
    return process.stdout.strip()

def list_get(src: list, i: int, fallback):
    if len(src) <= i:
        return fallback
    return src[i]

def semver_to_parts(input: str):
    parts = input.split(".", maxsplit=2)
    return {
        "major": list_get(parts, 0, "0"),
        "minor": list_get(parts, 1, "0"),
        "patch": list_get(parts, 2, "0"),
    }

output: dict[str, Any] = {
    "build_os_version": call_process(["sw_vers", "--productVersion"]),
    "build_os_version_extra": call_process(["sw_vers", "--productVersionExtra"]),
    "build_os_build": call_process(["sw_vers", "--buildVersion"]),
    "build_machine_arch": call_process(["uname", "-m"]),
    "build_machine_name": call_process(["uname", "-n"]),
}

output["build_os_version_parts"] = semver_to_parts(output["build_os_version"])

# Step 1. Get Xcode Version
RE_XCODEBUILD_VERSION = re.compile(r"^Xcode ([0-9\.]+)\nBuild version ([0-9A-Za-z]+)$")
xcodebuild_version_process = call_process(["xcodebuild", "-version"])
xcodebuild_version = RE_XCODEBUILD_VERSION.match(xcodebuild_version_process)
xcode_version_parts = xcodebuild_version.group(1).split(".", maxsplit=2)
output["xcode_version"] = xcodebuild_version.group(1)
output["xcode_version_parts"] = semver_to_parts(xcodebuild_version.group(1))
output["xcode_build"] = xcodebuild_version.group(2)

# Step 2. Get File Sizes

files = {}
executables = {}
directories = {}
prefix = sys.argv[1] + "/Build/Products/" + sys.argv[2] + "-" + sys.argv[3]

entire_size = 0
executable_size = 0

for file in glob.iglob(prefix + "/*.app/**", recursive=True):
    if not os.path.isfile(file):
        if os.path.isdir(file):
            dir_size = 0
            for f in glob.iglob(file + "/**", recursive=True):
                if not os.path.isfile(f):
                    continue
                dir_size += os.path.getsize(f)
            directories[file[len(prefix):]] = dir_size
        continue
    files[file[len(prefix):]] = os.path.getsize(file)
    entire_size += os.path.getsize(file)
    if os.access(file, os.X_OK):
        executables[file[len(prefix):]] = os.path.getsize(file)
        executable_size += os.path.getsize(file)

output["files"] = files
output["directories"] = directories
output["executables"] = executables
output["entire_size"] = entire_size
output["entire_executable_size"] = executable_size

print(json.dumps(output, indent=4))