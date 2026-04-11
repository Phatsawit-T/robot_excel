# DataDriver — คู่มืออธิบาย Arguments

> Robot Framework DataDriver v1.11.2  
> ใช้เป็น Library Listener ไม่ได้ให้ keywords — ทำงานโดย inject test cases ก่อน suite รัน

---

## การ import

```robotframework
*** Settings ***
Library    DataDriver
...    file=my_data.xlsx
...    sheet_name=Sheet1
...    reader_class=${CURDIR}/my_reader.py
...    dual_key=True
```

---

## Arguments ทั้งหมด

### 1. `file`
| | |
|---|---|
| **Type** | `str \| None` |
| **Default** | `None` |

path ของไฟล์ข้อมูลที่จะอ่าน รองรับหลายรูปแบบ:

| ค่าที่ใส่ | พฤติกรรม |
|---|---|
| `None` | หาไฟล์ `.csv` ที่มีชื่อเดียวกับ `.robot` ในโฟลเดอร์เดียวกัน |
| `.xlsx` (แค่ extension) | หาไฟล์ `.xlsx` ที่มีชื่อเดียวกับ `.robot` |
| `data.xlsx` (relative path) | หาไฟล์ใน directory เดียวกับ `.robot` |
| `/full/path/data.xlsx` (absolute path) | ใช้ path ที่กำหนดตรงๆ |

```robotframework
Library    DataDriver    file=${CURDIR}/data.xlsx
Library    DataDriver    file=.xlsx          # หา suite_name.xlsx อัตโนมัติ
Library    DataDriver                        # หา suite_name.csv อัตโนมัติ
```

> **หมายเหตุ:** พฤติกรรมนี้ขึ้นอยู่กับ `file_search_strategy` ด้วย

---

### 2. `encoding`
| | |
|---|---|
| **Type** | `Encodings \| Any` |
| **Default** | `cp1252` |

encoding ของไฟล์ CSV — ใช้เฉพาะ CSV/TSV เท่านั้น ไม่มีผลกับ Excel

| ค่าที่นิยมใช้ | คำอธิบาย |
|---|---|
| `cp1252` | Windows Western European (default) |
| `utf_8` | UTF-8 — แนะนำสำหรับภาษาไทยและ Unicode |
| `utf_16` | UTF-16 |
| `iso-8859-1` / `latin-1` | Latin-1 |
| `ascii` | ASCII เท่านั้น |

```robotframework
Library    DataDriver    file=data.csv    encoding=utf_8
```

---

### 3. `dialect`
| | |
|---|---|
| **Type** | `str` |
| **Default** | `Excel-EU` |

กำหนดรูปแบบการอ่านไฟล์ CSV — ใช้เฉพาะ CSV/TSV เท่านั้น

| ค่า | delimiter | quotechar | lineterminator |
|---|---|---|---|
| `Excel-EU` *(default)* | `;` | `"` | `\r\n` |
| `excel` | `,` | `"` | `\r\n` |
| `excel-tab` | `\t` | `"` | `\r\n` |
| `unix` | `,` | `"` | `\n` |
| `UserDefined` | กำหนดเองผ่าน options ด้านล่าง | — | — |

```robotframework
Library    DataDriver    file=data.csv    dialect=excel
Library    DataDriver    file=data.csv    dialect=UserDefined    delimiter=|    lineterminator=\n
```

---

### 4. `delimiter`
| | |
|---|---|
| **Type** | `str` |
| **Default** | `;` |

ตัวคั่น column ใน CSV — มีผลเฉพาะเมื่อ `dialect=UserDefined`

```robotframework
Library    DataDriver    dialect=UserDefined    delimiter=,
Library    DataDriver    dialect=UserDefined    delimiter=|
```

---

### 5. `quotechar`
| | |
|---|---|
| **Type** | `str` |
| **Default** | `"` |

ตัวอักษรที่ใช้ครอบค่าที่มี delimiter อยู่ข้างใน — มีผลเฉพาะเมื่อ `dialect=UserDefined`

```robotframework
# ค่าที่มี comma อยู่ใน quotechar จะไม่ถูกตัดเป็น column ใหม่
# เช่น "Hello, World" → ค่าเดียว ไม่ใช่สอง column
Library    DataDriver    dialect=UserDefined    quotechar="
```

---

### 6. `escapechar`
| | |
|---|---|
| **Type** | `str` |
| **Default** | `\\` |

ตัวอักษร escape ใน CSV — มีผลเฉพาะเมื่อ `dialect=UserDefined`

```robotframework
Library    DataDriver    dialect=UserDefined    escapechar=\\
```

---

### 7. `doublequote`
| | |
|---|---|
| **Type** | `bool` |
| **Default** | `True` |

กำหนดวิธี escape `quotechar` ภายใน quoted field — มีผลเฉพาะเมื่อ `dialect=UserDefined`

| ค่า | พฤติกรรม |
|---|---|
| `True` | ใช้ `""` แทน `"` ภายใน field (มาตรฐาน CSV) |
| `False` | ใช้ `escapechar` นำหน้าแทน |

---

### 8. `skipinitialspace`
| | |
|---|---|
| **Type** | `bool` |
| **Default** | `False` |

ตัดช่องว่างที่อยู่หลัง delimiter ออกหรือไม่ — มีผลเฉพาะเมื่อ `dialect=UserDefined`

```
# ตัวอย่าง CSV:  name; age
# skipinitialspace=False → age มี space นำหน้า = " age"
# skipinitialspace=True  → age ไม่มี space      = "age"
```

---

### 9. `lineterminator`
| | |
|---|---|
| **Type** | `str` |
| **Default** | `\r\n` |

ตัวอักษรที่ใช้ขึ้นบรรทัดใหม่ใน CSV — มีผลเฉพาะเมื่อ `dialect=UserDefined`

| ค่า | ใช้กับ |
|---|---|
| `\r\n` | Windows (default) |
| `\n` | Unix / macOS |

---

### 10. `sheet_name` 🏷
| | |
|---|---|
| **Type** | `str \| int` |
| **Default** | `0` |

ชื่อหรือ index ของ sheet ใน Excel ที่จะอ่าน — ใช้เฉพาะ `.xls` / `.xlsx`

| ค่า | พฤติกรรม |
|---|---|
| `0` | sheet แรก (default) |
| `1` | sheet ที่สอง |
| `"Sheet1"` | sheet ชื่อ "Sheet1" (case-sensitive) |
| `"2nd Sheet"` | sheet ชื่อ "2nd Sheet" |

```robotframework
Library    DataDriver    file=data.xlsx    sheet_name=0
Library    DataDriver    file=data.xlsx    sheet_name=TestData
```

---

### 11. `reader_class` 🏷
| | |
|---|---|
| **Type** | `AbstractReaderClass \| str \| None` |
| **Default** | `None` |

กำหนด reader class ที่ใช้อ่านไฟล์ข้อมูล

| ค่า | พฤติกรรม |
|---|---|
| `None` | เลือก reader อัตโนมัติจาก file extension |
| `"csv_reader"` | ใช้ built-in csv reader |
| `"generic_csv_reader"` | ใช้ built-in generic csv reader |
| `"${CURDIR}/my_reader.py"` | ใช้ custom reader จาก path |
| `"my_module.MyReader"` | ใช้ class จาก Python module |

```robotframework
# ใช้ custom reader
Library    DataDriver
...    file=${CURDIR}/data.xlsx
...    reader_class=${CURDIR}/my_reader.py

# ใช้ custom reader พร้อม kwargs เพิ่มเติม
Library    DataDriver
...    reader_class=${CURDIR}/my_reader.py
...    file_search_strategy=None
...    file=${CURDIR}/data.json    # ส่งเข้า self.kwargs ใน custom reader
...    dual_key=True               # ส่งเข้า self.kwargs ใน custom reader
```

> **การเขียน custom reader:** สืบทอดจาก `AbstractReaderClass` และ implement `get_data_from_source()` ที่ return `list[TestCaseData]`  
> kwargs พิเศษที่ส่งมาเข้าถึงได้ผ่าน `self.kwargs`

---

### 12. `file_search_strategy` 🏷
| | |
|---|---|
| **Type** | `str` |
| **Default** | `PATH` |

กำหนดวิธีที่ DataDriver ค้นหาไฟล์ข้อมูล

| ค่า | พฤติกรรม |
|---|---|
| `PATH` | ค้นหาตาม path ปกติ — absolute, relative, หรือ auto-detect จากชื่อ suite |
| `REGEX` | ค้นหาไฟล์ที่ตรงกับ `file_regex` ใน directory ที่กำหนด |
| `None` | ไม่ validate file เลย — ใช้เมื่อ source ไม่ใช่ไฟล์ เช่น database, API, หรือ custom reader |

```robotframework
# กรณี custom reader ที่ไม่ได้อ่านจากไฟล์จริงๆ
Library    DataDriver
...    reader_class=${CURDIR}/my_reader_json.py
...    file_search_strategy=None
...    file=${CURDIR}/data.json
```

---

### 13. `file_regex` 🏷
| | |
|---|---|
| **Type** | `str` |
| **Default** | `(?i)(.*?)(\.csv)` |

regex pattern สำหรับค้นหาไฟล์ข้อมูล — ใช้เฉพาะเมื่อ `file_search_strategy=REGEX`

```robotframework
# ค้นหาไฟล์ .xlsx ใน directory
Library    DataDriver
...    file_search_strategy=REGEX
...    file_regex=(?i)(.*?)(\.xlsx)
```

---

### 14. `include` 🏷
| | |
|---|---|
| **Type** | `str \| None` |
| **Default** | `None` |

กรอง test case ที่จะรัน โดยเลือกเฉพาะที่มี tag ตรงกัน — เป็น alternative ของ `--include` ใน CLI

```robotframework
Library    DataDriver    include=smoke
Library    DataDriver    include=1OR2        # tag 1 หรือ tag 2
Library    DataDriver    include=1AND2       # มี tag 1 และ tag 2 พร้อมกัน
```

> **ความแตกต่างจาก CLI `--include`:** ถ้าใส่ option นี้ใน Library import จะ override CLI option

---

### 15. `exclude` 🏷
| | |
|---|---|
| **Type** | `str \| None` |
| **Default** | `None` |

กรอง test case ที่จะรัน โดยข้ามที่มี tag ตรงกัน — เป็น alternative ของ `--exclude` ใน CLI

```robotframework
Library    DataDriver    exclude=wip
Library    DataDriver    include=smoke    exclude=slow    # รัน smoke แต่ไม่รัน slow
```

---

### 16. `handle_template_tags` 🏷
| | |
|---|---|
| **Type** | `TagHandling` |
| **Default** | `UnsetTags` |

กำหนดวิธีจัดการ tags ของ template test case กับ test cases ที่ generated

| ค่า | พฤติกรรม |
|---|---|
| `UnsetTags` *(default)* | ลบ tag ของ template ออกจาก generated tests ที่มี tag กำหนดมาจาก data file |
| `DefaultTags` | ใช้ tag ของ template เป็น default — ถ้า data file มี tag จะ override |
| `NoTags` | ไม่ใช้ tag ของ template เลย generated tests ใช้เฉพาะ tag จาก data file |

```robotframework
Library    DataDriver    handle_template_tags=DefaultTags
```

---

### 17. `listseperator` 🏷
| | |
|---|---|
| **Type** | `str` |
| **Default** | `,` |

ตัวคั่นสำหรับ parse ค่า List (`@{var}`) และ Dictionary (`&{var}`) จาก data file

```robotframework
Library    DataDriver    listseperator=,
```

ตัวอย่างใน data file:

| `@{tags}` | ผลลัพธ์ (listseperator=`,`) |
|---|---|
| `smoke,regression,slow` | `["smoke", "regression", "slow"]` |

> **หมายเหตุ:** typo ในชื่อ argument ตัวจริง (`listseperator` ไม่ใช่ `listseparator`) — ต้องใช้ตามนี้

---

### 18. `config_keyword` 🏷
| | |
|---|---|
| **Type** | `str \| None` |
| **Default** | `None` |

ชื่อ keyword ที่จะถูกเรียกก่อน DataDriver เริ่มอ่านข้อมูล — ใช้สำหรับ generate หรือ modify config แบบ dynamic

keyword นี้จะได้รับ config dictionary เป็น argument และต้อง return dictionary ที่อัปเดตแล้วกลับมา

```robotframework
*** Settings ***
Library    DataDriver    config_keyword=Setup DataDriver Config

*** Keywords ***
Setup DataDriver Config
    [Arguments]    ${config}
    # สร้างไฟล์ข้อมูล dynamic ก่อนรัน
    Create File    ${CURDIR}/generated.csv    *** Test Cases ***,${var}\nRow1,hello
    ${new_config}=    Create Dictionary    file=generated.csv
    RETURN    ${new_config}
```

> **Use case หลัก:** สร้างไฟล์ข้อมูลแบบ dynamic, เลือกไฟล์ตาม environment, หรือดึงข้อมูลจาก external source ก่อน suite เริ่ม

---

### 19. `optimize_pabot` 🏷
| | |
|---|---|
| **Type** | `PabotOpt` |
| **Default** | `Equal` |

ปรับ strategy การกระจาย test cases เมื่อใช้ร่วมกับ [Pabot](https://github.com/mkorpela/pabot) (parallel executor)

| ค่า | พฤติกรรม |
|---|---|
| `Equal` *(default)* | แบ่ง test cases เป็นกลุ่มขนาดเท่าๆ กันตามจำนวน processes |
| `Binary` | แบ่งแบบ decreasing size เพื่อ balance load ได้ดีขึ้น |
| `Atomic` | ไม่จัดกลุ่ม — แต่ละ test case รันใน thread แยก (overhead สูงสุด) |

ตัวอย่างการแบ่ง `Binary` กับ 40 tests / 8 threads:

```
P01–P04: กลุ่มละ 5 tests
P05–P08: กลุ่มละ 3 tests
P09–P16: กลุ่มละ 1 test
```

```robotframework
Library    DataDriver    optimize_pabot=Binary
```

> ต้องใช้ Pabot v1.10.0+ และเปิด `--pabotlib` ด้วย

---

### 20. `**kwargs`
| | |
|---|---|
| **Type** | `Any` |
| **Default** | — |

arguments พิเศษที่ส่งต่อไปยัง custom reader ผ่าน `self.kwargs`

ใช้สำหรับส่งค่า config เพิ่มเติมที่ DataDriver เองไม่รู้จัก เช่น `dual_key`, `preserve_types`, หรือ path ไฟล์สำหรับ reader ที่ไม่ใช่ Excel

```robotframework
Library    DataDriver
...    reader_class=${CURDIR}/my_reader.py
...    file=${CURDIR}/data.xlsx
...    dual_key=True           # → self.kwargs['dual_key']
...    preserve_types=True     # → self.kwargs['preserve_types']
...    my_custom_option=hello  # → self.kwargs['my_custom_option']
```

เข้าถึงใน custom reader:

```python
def get_data_from_source(self):
    dual_key = self.kwargs.get("dual_key", "True")
    preserve_types = self.kwargs.get("preserve_types", "True")
```

---

## สรุปภาพรวม

```
Arguments
├── ไฟล์ข้อมูล
│   ├── file                  path ของไฟล์
│   ├── sheet_name            sheet ของ Excel
│   ├── file_search_strategy  วิธีค้นหาไฟล์ (PATH / REGEX / None)
│   └── file_regex            regex สำหรับ REGEX strategy
│
├── CSV Dialect (ใช้กับ CSV/TSV เท่านั้น)
│   ├── encoding              encoding ของไฟล์
│   ├── dialect               รูปแบบ CSV (Excel-EU / excel / excel-tab / unix / UserDefined)
│   ├── delimiter             ตัวคั่น column
│   ├── quotechar             ตัวครอบค่า
│   ├── escapechar            ตัว escape
│   ├── doublequote           escape quotechar ด้วย ""
│   ├── skipinitialspace      ตัด space หลัง delimiter
│   └── lineterminator        ตัวขึ้นบรรทัดใหม่
│
├── Reader
│   ├── reader_class          custom reader class
│   └── **kwargs              ส่งต่อไปยัง custom reader
│
├── Filtering
│   ├── include               รันเฉพาะ tag ที่กำหนด
│   ├── exclude               ข้าม tag ที่กำหนด
│   └── handle_template_tags  จัดการ tag ของ template test
│
├── อื่นๆ
│   ├── listseperator         ตัวคั่นสำหรับ List/Dict values
│   ├── config_keyword        keyword ที่รันก่อน DataDriver เริ่มทำงาน
│   └── optimize_pabot        strategy การ parallel ด้วย Pabot
```

---

*อ้างอิงจาก DataDriver v1.11.2 source code และ docstring*
