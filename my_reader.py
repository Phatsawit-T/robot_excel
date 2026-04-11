"""
my_reader.py — Custom DataDriver Reader for Excel (.xlsx)
==========================================================

Reader class สำหรับใช้กับ Robot Framework DataDriver library
รองรับการอ่าน column header แบบไม่มี ``${...}`` ครอบ
พร้อม option ควบคุมพฤติกรรมการ map key และการแปลง type

Usage ใน Robot Framework
-------------------------

.. code:: robotframework

    *** Settings ***
    Library    DataDriver
    ...    file=${CURDIR}/data.xlsx
    ...    reader_class=${CURDIR}/my_reader.py
    ...    sheet_name=Sheet1
    ...    dual_key=True
    ...    preserve_types=True

kwargs
------
sheet_name : str | int, optional
    ชื่อ sheet หรือ index (0-based) ของ sheet ที่จะอ่าน
    Default: 0 (sheet แรก)

dual_key : bool, optional  [Default: True]
    ควบคุมรูปแบบ key ที่เก็บใน arguments dict

    - ``True``  -> เก็บทั้งสองแบบพร้อมกัน คือ ``${username}`` และ ``username``
                   DataDriver ใช้ ``${username}`` สำหรับ map เข้า keyword argument
                   ส่วน ``username`` ใช้เข้าถึงโดยตรงผ่าน DataDriver_TEST_DATA
    - ``False`` -> เก็บเฉพาะ ``${username}`` แบบ DataDriver มาตรฐาน

    ตัวอย่าง arguments dict เมื่อ dual_key=True:

    .. code:: python

        {
            "${username}": "demo",   # DataDriver ใช้ map เข้า keyword argument
            "username":    "demo",   # เข้าถึงได้โดยตรงโดยไม่ต้องใส่ ${...}
        }

    ตัวอย่างการเข้าถึงใน keyword:

    .. code:: robotframework

        *** Keywords ***
        My Keyword
            [Arguments]    ${username}    ${password}
            # DataDriver map ค่าเข้ามาผ่าน ${username} ตามปกติ

            # หรือเข้าถึงโดยตรงผ่าน DataDriver_TEST_DATA โดยไม่ต้องใส่ ${...}
            ${val}=    Evaluate    $DataDriver_TEST_DATA['arguments']['username']

preserve_types : bool, optional  [Default: True]
    ควบคุมการแปลง type ของค่าจาก Excel

    - ``True``  -> รักษา type ที่เหมาะสม เช่น int, float, datetime
                   (ผ่าน _normalize_value)
    - ``False`` -> แปลงทุกค่าเป็น string ด้วย str() ตรงๆ

    ตัวอย่างผลลัพธ์:

    +-----------------------+---------------------+----------------------+
    | ค่าใน Excel           | preserve_types=True | preserve_types=False |
    +=======================+=====================+======================+
    | 1.0 (number)          | 1 (int)             | "1.0"                |
    | 2025-01-01 (date)     | "2025-01-01 ..."    | "2025-01-01 ..."     |
    | NaN (empty cell)      | "" (empty string)   | "nan"                |
    | " hello " (string)    | "hello" (stripped)  | " hello "            |
    +-----------------------+---------------------+----------------------+

Special Columns (ไม่ถูก map เป็น argument)
------------------------------------------
- ``*** Test Cases ***`` / ``*** Tasks ***`` -> ชื่อ test case
- ``[Tags]``                                 -> tags (คั่นด้วย ``,`` หรือ ``;``)
- ``[Documentation]``                        -> documentation ของแต่ละ test case
"""

import math
from datetime import datetime

import pandas as pd
from DataDriver.AbstractReaderClass import AbstractReaderClass
from DataDriver.ReaderConfig import TestCaseData


_SPECIAL_COLUMNS = frozenset(
    {
        "*** test cases ***",
        "*** tasks ***",
        "*test cases*",
        "*tasks*",
        "[tags]",
        "[documentation]",
    }
)


class my_reader(AbstractReaderClass):
    """Custom DataDriver Reader สำหรับไฟล์ Excel (.xlsx)

    รับ kwargs เพิ่มเติมผ่าน DataDriver Library import:
        - ``dual_key``       (bool): เก็บ key ทั้งแบบ ``${var}`` และ ``var`` พร้อมกัน
        - ``preserve_types`` (bool): รักษา type ของค่าจาก Excel แทนการแปลงเป็น string ทั้งหมด
    """

    # ------------------------------------------------------------------
    # Private: kwarg parsing
    # ------------------------------------------------------------------

    @staticmethod
    def _parse_bool_kwarg(value, default: bool) -> bool:
        """แปลงค่า kwarg ที่รับมาจาก Robot Framework เป็น bool

        Robot Framework ส่ง kwargs มาเป็น string เสมอ ("True" / "False")
        จึงไม่สามารถใช้ bool() ตรงๆ ได้ เพราะ bool("False") == True

        Args:
            value:          ค่าดิบจาก self.kwargs (str หรือ bool)
            default (bool): ค่า default ที่ใช้เมื่อ value เป็น None

        Returns:
            bool
        """
        if value is None:
            return default
        if isinstance(value, bool):
            return value
        return str(value).strip().casefold() == "true"

    # ------------------------------------------------------------------
    # Private: value normalization
    # ------------------------------------------------------------------

    def _normalize_value(self, value):
        """แปลงค่าจาก Excel cell ให้อยู่ในรูปแบบที่เหมาะสมสำหรับ Robot Framework

        กฎการแปลง (เรียงตามลำดับ priority):
            1. None / NaN              -> "" (empty string)
            2. datetime / Timestamp    -> "YYYY-MM-DD HH:MM:SS" (string)
            3. float ที่เป็น int จริง  -> int  เช่น 1.0 -> 1
            4. float ทั่วไป            -> float ตามเดิม
            5. str                     -> strip whitespace หัวท้าย
            6. อื่นๆ                   -> คืนค่าตาม type เดิม

        Args:
            value: ค่าดิบจาก pandas cell

        Returns:
            str | int | float: ค่าที่ normalize แล้ว
        """
        if value is None:
            return ""
        if isinstance(value, float) and math.isnan(value):
            return ""
        if isinstance(value, (datetime, pd.Timestamp)):
            return value.strftime("%Y-%m-%d %H:%M:%S")
        if isinstance(value, float):
            return int(value) if value.is_integer() else value
        if isinstance(value, str):
            return value.strip()
        return value

    def _get_cell_value(self, raw_value, preserve_types: bool):
        """แปลงค่า cell ตาม mode ที่เลือก

        Args:
            raw_value:              ค่าดิบจาก pandas
            preserve_types (bool):  True  -> ผ่าน _normalize_value (รักษา type)
                                    False -> แปลงเป็น str ตรงๆ

        Returns:
            str | int | float: ค่าที่พร้อมใช้งาน
        """
        if preserve_types:
            return self._normalize_value(raw_value)
        return str(raw_value)

    # ------------------------------------------------------------------
    # Private: argument key building
    # ------------------------------------------------------------------

    @staticmethod
    def _build_arg_entry(col: str, value, dual_key: bool) -> dict:
        """สร้าง argument entry สำหรับ 1 column

        Args:
            col (str):       ชื่อ column จาก Excel (มีหรือไม่มี ``${...}`` ก็ได้)
            value:           ค่าที่แปลงแล้ว
            dual_key (bool): True  -> {${col}: value, col: value}
                             False -> {${col}: value}

        Returns:
            dict: argument entry พร้อม update เข้า args dict
        """
        bare_key = col.strip().removeprefix("${").removesuffix("}")
        wrapped_key = f"${{{bare_key}}}"

        if dual_key:
            return {wrapped_key: value, bare_key: value}
        return {wrapped_key: value}

    # ------------------------------------------------------------------
    # Main entry point (called by DataDriver)
    # ------------------------------------------------------------------

    def get_data_from_source(self):
        """อ่านข้อมูลจาก Excel และแปลงเป็น list ของ TestCaseData

        DataDriver เรียก method นี้ 1 ครั้งก่อน suite เริ่มรัน
        แล้วใช้ผลลัพธ์สร้าง test cases อัตโนมัติ

        Returns:
            list[TestCaseData]: ข้อมูลทุก row พร้อมส่งให้ DataDriver
        """
        sheet = (
            self.reader_config.sheet_name
            if self.reader_config.sheet_name is not None
            else 0
        )
        dual_key = self._parse_bool_kwarg(self.kwargs.get("dual_key"), default=True)
        preserve_types = self._parse_bool_kwarg(
            self.kwargs.get("preserve_types"), default=True
        )

        df = pd.read_excel(
            self.reader_config.file,
            sheet_name=sheet,
            engine="openpyxl",  # ระบุ engine ชัดเจน ป้องกัน engine เพี้ยนตาม pandas version
        )

        # lowercase mapping สำหรับ case-insensitive special column matching
        col_map = {col: col.strip().lower() for col in df.columns}

        test_data = []
        for _, row in df.iterrows():
            test_case_name = None
            tags = []
            doc = ""
            args = {}

            for col in df.columns:
                cell_value = self._get_cell_value(row[col], preserve_types)
                normalized_col = col_map[col]

                if normalized_col in (
                    "*** test cases ***",
                    "*test cases*",
                    "*** tasks ***",
                    "*tasks*",
                ):
                    test_case_name = cell_value or None

                elif normalized_col == "[tags]":
                    if cell_value:
                        tags = [
                            t.strip()
                            for t in str(cell_value).replace(";", ",").split(",")
                            if t.strip()
                        ]

                elif normalized_col == "[documentation]":
                    doc = str(cell_value)

                else:
                    args.update(self._build_arg_entry(col, cell_value, dual_key))

            test_data.append(TestCaseData(test_case_name, args, tags, doc))

        return test_data
