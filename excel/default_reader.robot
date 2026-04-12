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
    ${message}=    Catenate    SEPARATOR=${\n}
    ...    value A = ${A}${SPACE * 3}data type: ${{type($A)}}
    ...    value B = ${B}${SPACE * 3}data type: ${{type($B)}}
    ...    sum    = ${A + ${B}}
    ...    -------------------------------

    Log    ${message}    console=${True}

Set Test Status to Dic
    Set To Dictionary    ${DataDriver_TEST_DATA.arguments}    Test_Status=${TEST_STATUS}    # robotcode: ignore

Create Excel Report
    VAR    ${content}=  
    ...    ${{ [{"Test Case Name": d["test_case_name"], **d["arguments"]} for d in $DataDriver_DATA_LIST] }}    # robotcode: ignore

    RPA.Excel.Files.Create Workbook    path=${CURDIR}/data.xlsx    sheet_name=report
    RPA.Excel.Files.Append Rows To Worksheet
    ...    content=${content}    # robotcode: ignore
    ...    header=${True}

    ${end_column}=    Convert int to Excel column    ${{ len($content[0].keys()) }}
    Set Styles    range_string=A1:${end_column}1    bold=${True}    italic=${True}    cell_fill=#8DB4E2
    Set Styles to value    dic=${content}    value=PASS    bold=${True}    color=green
    Set Styles to value    dic=${content}    value=FAIL    bold=${True}    color=red

    Auto Size Columns    A    ${end_column}    width=${20}

    RPA.Excel.Files.Save Workbook    path=${OUTPUT_DIR}/report.xlsx

# -------------------------------------------------------------------------------------
# ============================= Excel Helper Keyword ==================================
# -------------------------------------------------------------------------------------

Set Styles to value
    [Arguments]
    ...    ${dic}    ${value}    ${font_name}=${None}    ${family}=${None}    ${size}=${None}
    ...    ${bold}=${False}    ${italic}=${False}    ${underline}=${False}    ${strikethrough}=${False}
    ...    ${cell_fill}=${None}    ${color}=${None}    ${align_horizontal}=${None}    ${align_vertical}=${None}
    ...    ${number_format}=${None}    ${width}=${EMPTY}

    FOR    ${row_num}    ${row_data}    IN ENUMERATE    @{dic}
        FOR    ${column_index}    IN    @{{ [index for index, (key, value) in enumerate(${row_data}.items()) if "${value}" in str(value)] }}
            ${column_string}=    Convert int to Excel column    ${column_index + 1}
            RPA.Excel.Files.Set Styles
            ...    range_string=${column_string}${row_num + 2}
            ...    bold=${bold}
            ...    cell_fill=${cell_fill}
            ...    color=${color}
            ...    size=${size}
            ...    font_name=${font_name}
            ...    family=${family}
            ...    italic=${italic}
            ...    underline=${underline}
            ...    strikethrough=${strikethrough}
            ...    align_horizontal=${align_horizontal}
            ...    align_vertical=${align_vertical}
            ...    number_format=${number_format}
            IF    '${width}' != '${EMPTY}'
                Auto Size Columns    ${column_string}    ${column_string}    width=${width}
            END
        END
    END

Convert int to Excel column
    [Arguments]    ${number}
    VAR    ${column}=
    WHILE    ${number} > 0
        VAR    ${number}=    ${number - 1}
        VAR    ${column}=    ${{ chr(65 + (${number} % 26)) }}${column}
        VAR    ${number}=    ${number // 26}
    END
    RETURN    ${column}
