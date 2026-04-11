#!/usr/bin/env python3
import sqlite3
import os.path
import sys
import shutil

def dict_factory(cursor: sqlite3.Cursor, row: sqlite3.Row) -> dict[str, object]:
    d: dict[str, object] = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d

def main(xcresult_path: str, output_dir: str):
    conn = sqlite3.connect(os.path.join(xcresult_path, "database.sqlite3"))
    conn.row_factory = dict_factory
    attachments = conn.execute("""
        SELECT
            Attachments.name AS attachment_name,
            Attachments.xcResultKitPayloadRefId AS attachment_payload_id,
            Attachments.filenameOverride AS attachment_filename_override,
            TestPlanConfigurations.name AS config_name,
            TestPlans.name AS test_plan_name
        FROM Attachments
        LEFT JOIN Activities ON Attachments.activity_fk = Activities.rowid
        LEFT JOIN TestCaseRuns ON Activities.testCaseRun_fk = TestCaseRuns.rowid
        LEFT JOIN TestSuiteRuns ON TestCaseRuns.testSuiteRun_fk = TestSuiteRuns.rowid
        LEFT JOIN TestableRuns ON TestSuiteRuns.testableRun_fk = TestableRuns.rowid
        LEFT JOIN TestPlanRuns ON TestableRuns.testPlanRun_fk = TestPlanRuns.rowid
        LEFT JOIN TestPlanConfigurations ON TestPlanRuns.configuration_fk = TestPlanConfigurations.rowid
        LEFT JOIN TestPlans ON TestPlanConfigurations.testPlan_fk = TestPlans.rowid
        WHERE Attachments.name LIKE 'AppStore_%'
    """)
    for attachment in attachments:
        print(attachment)
        filename = f"{attachment['test_plan_name']}/{attachment['config_name']}/{attachment['attachment_name']}"
        filename += os.path.splitext(attachment['attachment_filename_override'])[1]
        os.makedirs(os.path.dirname(os.path.join(output_dir, filename)), exist_ok=True)
        shutil.copyfile(
            os.path.join(xcresult_path, "Data", "data." + attachment['attachment_payload_id']),
            os.path.join(output_dir, filename)
        )


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])