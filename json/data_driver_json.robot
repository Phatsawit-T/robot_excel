*** Settings ***
Documentation       ตัวอย่างการใช้งาน my_reader.py กับ parameter dual_key=False
...
...                 เมื่อ dual_key=False → arguments dict จะเก็บเฉพาะ key แบบ ${var}
...                 เมื่อ dual_key=True    → arguments dict จะเก็บทั้ง ${var} และ var
...
...                 ตัวอย่างนี้แสดงการเข้าถึง DataDriver suite/test variables
...                 และการใช้ bare key (ไม่มี ${...}) ผ่าน DataDriver_TEST_DATA

Library             DataDriver
...                     file=${CURDIR}/data.json
...                     reader_class=${CURDIR}/my_reader_json.py

Suite Setup         Log DataDriver Suite Variables


*** Test Cases ***
Log variable    [Template]    Log Variable When dual_key Is False
    ${None}    # robotcode: ignore


*** Keywords ***
Log DataDriver Suite Variables
    [Documentation]    Log suite-level variables ที่ DataDriver inject ให้ (scope=Suite)
    Log    ${DataDriver_DATA_DICT}    formatter=repr    # robotcode: ignore
    Log    ${DataDriver_DATA_LIST}    formatter=repr    # robotcode: ignore

Log Variable When dual_key Is False
    [Documentation]    Log test-level variables ที่ DataDriver inject ให้ (scope=Test)
    ...
    ...    เมื่อ dual_key=False จะเห็น arguments dict มีเฉพาะ key แบบ ${var}
    Log    ${DataDriver_TEST_DATA}    formatter=repr    # robotcode: ignore
    Log    ${DataDriver_TEST_DATA.arguments}    formatter=repr    # robotcode: ignore
