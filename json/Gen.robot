*** Settings ***
Library     FakerLibrary
Library     JSONLibrary


*** Variables ***
${DATA_ROWS}    ${2000}

*** Test Cases ***
generate json file
    ${json_str}=    FakerLibrary.Json    num_rows=${DATA_ROWS}    indent=${None}

    JSONLibrary.Dump Json To File    dest_file=${CURDIR}/data.json    json_object=${{json.loads($json_str)}}
