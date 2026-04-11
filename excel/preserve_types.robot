*** Settings ***
Documentation       ตัวอย่างการใช้งาน my_reader.py กับ parameter preserve_types
...
...                 preserve_types=True    (default)
...                 รักษา type ของข้อมูลจาก Excel เช่น int, float, datetime, bool
...
...                 preserve_types=False
...                 แปลงทุกค่าเป็น string ด้วย str() ตรงๆ

Library             DataDriver
...                     file=${CURDIR}/data.xlsx
...                     reader_class=${CURDIR}/my_reader.py
...                     sheet_name=preserve_types
...                     preserve_types=False

Test Template       Log Data Type


*** Tasks ***    Data
Run Test Script    ${data}    # robotcode: ignore


*** Keywords ***
Log Data Type
    [Documentation]    Log ค่าและ type ของ data ที่รับมาจาก DataDriver
    [Arguments]    ${data}
    ${message}    Catenate    SEPARATOR=${\n}
    ...    ${\n}data    : ${data}
    ...    data type : ${{type($data)}}

    Log    ${message}    console=${True}
