#!/usr/bin/env python3
from glob import iglob
import os
import plistlib
import subprocess
import json
import sys
import shutil

TEST_PRODUCT_PATH="./iMast_iOS.xctestproducts"

IOS_LATEST = "27.0"
IOS_26 = "26.5"
IOS_17 = "17.5"
IOS_16 = "16.4" # our minimum requirements
DEVICES = [
    # our_device_key, apple device key, iOS version, should test all locales
    ("iPhone_6_9", "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max", IOS_LATEST, False),
    ("iPhone_6_5", "com.apple.CoreSimulator.SimDeviceType.iPhone-11-Pro-Max", IOS_LATEST, False),
    ("iPhone_6_3", "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro", IOS_LATEST, False),
    ("iPhone_6_1", "com.apple.CoreSimulator.SimDeviceType.iPhone-14", IOS_LATEST, False),
    ("iPhone_5_5", "com.apple.CoreSimulator.SimDeviceType.iPhone-8-Plus", IOS_16, True), # test all because oldest iOS
    ("iPhone_4_7", "com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation", IOS_LATEST, True), # test all because smallest iPhone
    # iPhone 4_0 → SE 1st gen, iOS 15.x
    # iPhone 3_5 → 4s, iOS 9.x
    ("iPad_13_0", "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB", IOS_LATEST, True), # test all because latest iPadOS
    ("iPad_11_0", "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-11-inch-M5-12GB", IOS_LATEST, False),
    ("iPad_12_9", "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-12-9-inch-6th-generation-8GB", IOS_LATEST, False),
    ("iPad_10_5", "com.apple.CoreSimulator.SimDeviceType.iPad-Air--3rd-generation-", IOS_26, False),
    ("iPad_9_7", "com.apple.CoreSimulator.SimDeviceType.iPad--6th-generation-", IOS_17, False),
]

# sorry for excluded locale peoples, but these will (still) tested for "should test all locales" devices,
# so we probably not miss something
NOT_PRIMARY_CONFIGURATIONS = [
    "Chinese, Simplified (China mainland)",
    "Chinese, Traditional (Taiwan)",
    "Korean (South Korea)",
]

subprocess.run(["xcrun", "simctl", "delete", "all"], check=True)

done_ioses = set[str]()

current_runtimes: dict[str, dict[str, str]] = json.loads(subprocess.run(["xcrun", "simctl", "runtime", "list", "-j"], check=True, capture_output=True).stdout.decode())
for runtime in current_runtimes.values():
    if not runtime["runtimeIdentifier"].startswith("com.apple.CoreSimulator.SimRuntime.iOS-"):
        continue
    done_ioses.add(runtime["version"])

mock_server = subprocess.Popen(["node", "mock_server/index.ts"])

def swap_runner_if_needed(current_ios: str):
    if current_ios not in [IOS_16]:
        return
    print(f"::group::Swap XCTRunner", flush=True)
    sdk_path = subprocess.run(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], check=True).stdout.strip().decode("ascii")
    xctrunner_path = sdk_path + "/../../Library/Xcode/Agents/XCTRunner.app"
    with open(xctrunner_path + "/Info.plist", "rb") as f:
        runner_info_plist = plistlib.load(f)
    for runner_app in iglob(TEST_PRODUCT_PATH + "/Binaries/*/Debug-iphonesimulator/*-Runner.app"):
        print("Modifying", runner_app)
        with open(runner_app + "/Info.plist", "rb") as f:
            orig_info_plist = plistlib.load(f)
        runner_bin = runner_app + "/" + orig_info_plist["CFBundleExecutable"]
        os.unlink(runner_bin)
        shutil.copy2(xctrunner_path + "/XCTRunner", runner_bin)
        new_info_plist = {}
        for k in runner_info_plist:
            v = runner_info_plist[k]
            if isinstance(v,  str) and v.startswith("$("):
                v = orig_info_plist[k]
            new_info_plist[k] = v
        with open(runner_app + "/Info.plist", "wb") as f:
            plistlib.dump(new_info_plist, f, fmt=plistlib.FMT_BINARY)
        subprocess.run(["codesign", "-s", "-", "-f", runner_app], check=True)
    print("::endgroup::")

try:
    for device_key, device_type, ios_version, should_test_all_locales in DEVICES:
        if device_key not in sys.argv:
            continue
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
            retry = 0
            while True:
                try:
                    print(f"::group::Building iOS {ios_version} dyld_shared_cache... (retry {retry})", flush=True)
                    subprocess.run(["xcrun", "simctl", "runtime", "dyld_shared_cache", "update", "com.apple.CoreSimulator.SimRuntime.iOS-" + ios_version.replace(".", "-")], check=True)
                    break
                except subprocess.CalledProcessError:
                    retry += 1
                    if retry >= 3:
                        raise
                finally:
                    print("::endgroup::")
        if os.environ.get("DOWNLOAD_ONLY") == "yes":
            continue
        subprocess.run(["xcrun", "simctl", "create", device_key, device_type, "com.apple.CoreSimulator.SimRuntime.iOS-" + ios_version.replace(".", "-")], check=True)
        print(f"::group::Booting {device_key} (iOS {ios_version}, {device_type})", flush=True)
        subprocess.run(["xcrun", "simctl", "bootstatus", device_key, "-b"], check=True)
        print("::endgroup::")
        swap_runner_if_needed(ios_version)
        retry = 0
        while True:
            try:
                shutil.rmtree("test_results")
            except:
                pass
            print(f"::group::Testing on {device_key}, {retry} Try (iOS {ios_version}, {device_type})", flush=True)
            try:
                subprocess.run([
                    "xcrun", "xcodebuild", "test-without-building",
                    "-testProductsPath", TEST_PRODUCT_PATH,
                    "-destination", "platform=iOS Simulator,arch=arm64,name=" + device_key,
                    "-parallel-testing-enabled", "NO",
                    "-retry-tests-on-failure",
                    "-resultBundlePath", "test_results/" + device_key + ".xcresult",
                    *[
                        a
                        for c in (NOT_PRIMARY_CONFIGURATIONS if not should_test_all_locales else [])
                        for a in ("-skip-test-configuration", c)
                    ],
                ], check=True)
                break
            except subprocess.CalledProcessError:
                retry += 1
                if retry >= 3:
                    raise
            finally:
                print("::endgroup::")
        subprocess.run(["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", f"test_results/{device_key}.xcresult"], check=True)
finally:
    mock_server.terminate()