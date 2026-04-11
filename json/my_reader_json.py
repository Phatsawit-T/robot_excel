import json
from DataDriver.AbstractReaderClass import AbstractReaderClass
from DataDriver.ReaderConfig import TestCaseData


class my_reader_json(AbstractReaderClass):
    def get_data_from_source(self):
        """อ่านข้อมูลจากไฟล์ JSON และแปลงเป็น list ของ TestCaseData

        Returns:
            list[TestCaseData]: ข้อมูลทุก object พร้อมส่งให้ DataDriver
        """
        file_path = self.reader_config.file

        with open(file_path, encoding="utf-8") as f:
            data_list = json.load(f)

        test_data = []
        for i, record in enumerate(data_list, start=1):
            test_data.append(
                TestCaseData(f"data {i}", record, tags=[], documentation="")
            )

        return test_data
