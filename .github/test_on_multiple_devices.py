#!/usr/bin/env python3
import subprocess
import json

IOS_LATEST = "26.4"
IOS_17 = "17.5"
IOS_16 = "16.4" # our minimum requirements
DEVICES = [
    ("iPhone_6_9", "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max", IOS_LATEST),
    ("iPhone_6_5", "com.apple.CoreSimulator.SimDeviceType.iPhone-11-Pro-Max", IOS_LATEST),
    ("iPhone_6_3", "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro", IOS_LATEST),
    ("iPhone_6_1", "com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro", IOS_LATEST),
    ("iPhone_5_5", "com.apple.CoreSimulator.SimDeviceType.iPhone-8-Plus", IOS_16),
    ("iPhone_4_7", "com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation", IOS_LATEST),
    # iPhone 4_0 → SE 1st gen, iOS 15.x
    # iPhone 3_5 → 4s, iOS 9.x
    ("iPad_13_0", "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB", IOS_LATEST),
    ("iPad_11_0", "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-11-inch-M5-12GB", IOS_LATEST),
    ("iPad_12_9", "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-12-9-inch-6th-generation-8GB", IOS_LATEST),
    ("iPad_10_5", "com.apple.CoreSimulator.SimDeviceType.iPad-Air--3rd-generation-", IOS_LATEST),
    ("iPad_9_7", "com.apple.CoreSimulator.SimDeviceType.iPad--6th-generation-", IOS_17),
]

subprocess.run(["xcrun", "simctl", "delete", "all"], check=True)

done_ioses = set[str]()

current_runtimes: dict[str, dict[str, str]] = json.loads(subprocess.run(["xcrun", "simctl", "runtime", "list", "-j"], check=True, capture_output=True).stdout.decode())
for runtime in current_runtimes.values():
    if not runtime["runtimeIdentifier"].startswith("com.apple.CoreSimulator.SimRuntime.iOS-"):
        continue
    done_ioses.add(runtime["version"])

p = subprocess.Popen(["node", "mock_server/index.ts"])

try:
    for device_key, device_type, ios_version in DEVICES:
        if ios_version not in done_ioses:
            retry = 0
            while True:
                try:
                    print(f"::group::Downloading iOS {ios_version} runtime... (retry {retry})", flush=True)
                    subprocess.run(["xcrun", "xcodebuild", "-downloadPlatform", "iOS", "-buildVersion", ios_version], check=True)
                    done_ioses.add(ios_version)
                    break
                except subprocess.CalledProcessError:
                    retry += 1
                    if retry >= 3:
                        raise
                finally:
                    print("::endgroup::")
        subprocess.run(["xcrun", "simctl", "create", device_key, device_type, "com.apple.CoreSimulator.SimRuntime.iOS-" + ios_version.replace(".", "-")], check=True)
        print(f"::group::Booting {device_key} (iOS {ios_version}, {device_type})", flush=True)
        subprocess.run(["xcrun", "simctl", "bootstatus", device_key, "-b"], check=True)
        subprocess.run(["xcrun", "simctl", "shutdown", device_key], check=True)
        print("::endgroup::")
        print(f"::group::Testing on {device_key} (iOS {ios_version}, {device_type})", flush=True)
        p = subprocess.Popen(["xcpretty", "-c"], stdin=subprocess.PIPE)
        assert p.stdin is not None
        subprocess.run([
            "xcrun", "xcodebuild", "test",
            "-workspace", "iMast.xcworkspace",
            "-scheme", "iMast iOS",
            "-destination", "platform=iOS Simulator,arch=arm64,name=" + device_key,
            "-resultBundlePath", "test_results/" + device_key,
        ], stdout=p.stdin, check=True)
        p.stdin.close()
        p.wait()
        print("::endgroup::")
finally:
    p.terminate()