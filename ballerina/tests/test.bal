// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/test;

@test:Config
isolated function testParseSchemaFile() returns error? {
    Schema schema = check parseSchemaFile(getCopybookPath("copybook-1"));
    json expected = check io:fileReadJson(getSchemaPath("copybook-1"));
    json actual = check schema.toString().fromJsonString();
    test:assertEquals(actual, expected);
}

@test:Config {
    dataProvider: testConvertorDataProvider
}
isolated function testConvertor(string copybookFilePath, string inputFilePath) returns error? {
    Convertor convertor = check new (copybookFilePath);
    string[] input = check io:fileReadLines(inputFilePath);
    foreach string line in input {
        map<json> jsonData = check (check convertor.toJson(line)).get("data").ensureType();
        string output = check convertor.toCopybook(jsonData);
        test:assertEquals(output, line);
    }
}

isolated function testConvertorDataProvider() returns [string, string][] {
    [string, string][] filePaths = [];
    foreach int i in 1 ... 5 {
        filePaths.push([getCopybookPath(string `copybook-${i}`), getInputPath(string `input-${i}`)]);
    }
    return filePaths;
}

@test:Config
isolated function testConvertorWithTargetRecordName() returns error? {
    Convertor convertor = check new (getCopybookPath("copybook-6"));
    string[] input = check io:fileReadLines(getInputPath("input-6"));
    foreach string line in input {
        map<json> jsonData = check (check convertor.toJson(line, "DATA-DETAIL-REGISTRY")).get("data").ensureType();
        string output = check convertor.toCopybook(jsonData, "DATA-DETAIL-REGISTRY");
        test:assertEquals(output, line);
    }
}

@test:Config
isolated function testConvertorFromCopybook() returns error? {
    Convertor convertor = check new (getCopybookPath("copybook-7"));
    string[] input = check io:fileReadLines(getInputPath("input-7"));
    foreach string line in input {
        Copybook copybook = check convertor.fromCopybook(line, "Record2");
        string output = check convertor.toCopybook(copybook, "Record2");
        test:assertEquals(output, line);
    }
}
