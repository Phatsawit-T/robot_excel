*** Settings ***
Documentation       ตัวอย่างการใช้งาน my_reader.py กับ parameter dual_key=False
...
...                 เมื่อ dual_key=False → arguments dict จะเก็บเฉพาะ key แบบ ${var}
...                 เมื่อ dual_key=True    → arguments dict จะเก็บทั้ง ${var} และ var
...
...                 ตัวอย่างนี้แสดงการเข้าถึง DataDriver suite/test variables
...                 และการใช้ bare key (ไม่มี ${...}) ผ่าน DataDriver_TEST_DATA

Library             DataDriver
...                     file=${CURDIR}/data.xlsx
...                     reader_class=${CURDIR}/my_reader.py
...                     sheet_name=dual_key
...                     dual_key=${False}

Suite Setup         Log DataDriver Suite Variables


*** Test Cases ***
Log variable    [Template]    Log Variable When dual_key Is False
    ${None}    # robotcode: ignore

Log personal info    [Template]    Log Personal Information
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

Log Personal Information
    [Documentation]    ตัวอย่าง use case: ดึงข้อมูลส่วนตัวจาก arguments dict
    ...
    ...    ใช้ bare key (first_name, last_name ฯลฯ) เข้าถึงค่าโดยตรง
    ...    ต้องเปิด dual_key=True จึงจะใช้ bare key ได้

    VAR    ${info}=    ${DataDriver_TEST_DATA.get('arguments')}    # robotcode: ignore
    ${message}=    Catenate    SEPARATOR=${\n}
    ...    <b>${{'=' * ${15}}} Personal Information ${{'=' * ${15}}}</b>
    ...    First Name : ${info['first_name']}
    ...    Last Name    : ${info['last_name']}
    ...    Email    : ${info['email']}
    ...    Gender    : ${info['gender']}
    ...    <b>${{'=' * ${50}}}</b>

    Set Test Message    *HTML*${message}    html=${True}
