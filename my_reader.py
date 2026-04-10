from DataDriver.AbstractReaderClass import AbstractReaderClass
from DataDriver.ReaderConfig import TestCaseData
import pandas as pd
import math
from datetime import datetime

_SPECIAL_COLUMNS = {
    "*** test cases ***",
    "*** tasks ***",
    "*test cases*",
    "*tasks*",
    "[tags]",
    "[documentation]",
}


class my_reader(AbstractReaderClass):

    def _normalize_value(self, value):
        """Normalize value จาก Excel ให้ safe + preserve type"""

        # 1. Handle NaN / None
        if value is None:
            return ""
        if isinstance(value, float) and math.isnan(value):
            return ""

        # 2. Handle datetime
        if isinstance(value, (datetime, pd.Timestamp)):
            return value.strftime("%Y-%m-%d %H:%M:%S")

        # 3. Handle float ที่เป็น integer เช่น 1.0 → 1
        if isinstance(value, float):
            if value.is_integer():
                return int(value)
            return value

        # 4. Handle string → strip
        if isinstance(value, str):
            return value.strip()

        # 5. default → return ตาม type เดิม
        return value

    def get_data_from_source(self):
        sheet = self.reader_config.sheet_name
        if sheet is None:
            sheet = 0

        df = pd.read_excel(
            self.reader_config.file,
            sheet_name=sheet,
            engine="openpyxl",   # ชัดเจน ป้องกัน engine เพี้ยน
        )

        # ไม่ fillna("") เพื่อ preserve type → ไป handle ทีหลัง

        col_map = {col: col.strip().lower() for col in df.columns}

        test_data = []

        for _, row in df.iterrows():
            test_case_name = None
            tags = []
            doc = ""
            args = {}

            for col in df.columns:
                raw_value = row[col]
                value = self._normalize_value(raw_value)
                normalized = col_map[col]

                # ===== special columns =====
                if normalized in ("*** test cases ***", "*test cases*",
                                  "*** tasks ***", "*tasks*"):
                    test_case_name = value or None

                elif normalized == "[tags]":
                    if value:
                        tags = [
                            t.strip()
                            for t in str(value).replace(";", ",").split(",")
                            if t.strip()
                        ]

                elif normalized == "[documentation]":
                    doc = str(value)

                else:
                    key = col if col.startswith("${") else f"${{{col.strip()}}}"
                    args[key] = value

            test_data.append(TestCaseData(test_case_name, args, tags, doc))

        return test_data