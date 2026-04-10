*** Settings ***
Library             DataDriver
...                     file=${CURDIR}/data.xlsx    
...                     reader_class=${CURDIR}/my_reader.py    # ใส่ Path เต็มหรือใช้ ${CURDIR}
...                     sheet_name=Sheet1    # นี่จะไปอยู่ใน self.kwargs
Library             Collections

Test Template       Sum info


*** Tasks ***
Run Test script    # robotcode: ignore


*** Keywords ***
Sum info
    [Arguments]    ${A}    ${B}

    ${massage}    Catenate    SEPARATOR=${\n}
    ...    value a = ${A}
    ...    value b = ${B}
    ...    sum is : ${A + ${{(${B})}}}
    ...    -------------------------------

    Log    ${massage}    console=${True}
