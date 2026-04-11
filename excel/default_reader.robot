*** Settings ***
Documentation       ตัวอย่างการใช้งาน my_reader.py ด้วยค่า default
...
...                 reader_class : my_reader.py
...                 dual_key    : True    (default)
...                 preserve_types : True    (default)
...
...                 Sheet: default_reader
...                 Columns: A (int), B (int | datetime)
...
...                 Row 1-3 → A + B สำเร็จ (int + int)
...                 Row 4    → A + B ล้มเหลว (int + datetime)

Library             DataDriver
...                     file=${CURDIR}/data.xlsx
...                     reader_class=${CURDIR}/my_reader.py
...                     sheet_name=default_reader
Library             RPA.Excel.Files
Library             Collections

Suite Teardown      Create Excel Report
Test Teardown       Set Test Status to Dic
Test Template       Sum


*** Tasks ***
Run Test Script    ${None}    # robotcode: ignore


*** Keywords ***
Sum
    [Documentation]    บวก A + B แล้ว log ค่าและ type ของแต่ละตัวแปร
    [Arguments]    ${A}    ${B}
    ${message}    Catenate    SEPARATOR=${\n}
    ...    value A = ${A}${SPACE * 3}data type: ${{type($A)}}
    ...    value B = ${B}${SPACE * 3}data type: ${{type($B)}}
    ...    sum    = ${A + ${B}}
    ...    -------------------------------

    Log    ${message}    console=${True}

Set Test Status to Dic
    Set To Dictionary    ${DataDriver_TEST_DATA.arguments}    Test_Status=${TEST_STATUS}    # robotcode: ignore

Create Excel Report
    RPA.Excel.Files.Create Workbook    path=${CURDIR}/data.xlsx    sheet_name=report

    RPA.Excel.Files.Append Rows To Worksheet
    ...    content=${{ [{"Test Case Name": d["test_case_name"], **d["arguments"]} for d in $DataDriver_DATA_LIST] }}    # robotcode: ignore
    ...    header=${True}
    RPA.Excel.Files.Save Workbook    path=${OUTPUT_DIR}/report.xlsx
