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

class DataCoercer {
    private final Schema schema;

    isolated function init(Schema schema) {
        self.schema = schema;
    }

    isolated function coerceData(GroupValue data) returns map<json>|error {
        return self.coerce(data, self.schema).cloneWithType();
    }

    // TODO: fix this sample implementation
    private isolated function coerce(GroupValue data, Node parentNode) returns GroupValue {
        GroupValue coercedValue = {};

        foreach [string, anydata] [name, 'field] in data.entries() {
            Node? node = self.findNodeByName(parentNode, name);
            if node is () {
                continue;
            }
            if 'field is string|string[] {
                // TODO: handle these errors and return array of errors
                anydata|error val = coerceDataItemValue('field, <DataItem>node);
                if val !is error {
                    coercedValue[name] = val;
                }

            } else if 'field is GroupValue {
                coercedValue[name] = self.coerce('field, node);
            } else if 'field is GroupValue[] {
                GroupValue[] corecedArray = [];
                foreach GroupValue groupValue in 'field {
                    corecedArray.push(self.coerce(groupValue, node));
                }
                coercedValue[name] = corecedArray;
            }
        }
        return coercedValue;
    }

    private isolated function findNodeByName(Node node, string name) returns Node? {
        if node is Schema && name == node.getTypeDefinitions()[0].getName() {
            foreach var child in node.getTypeDefinitions() {
                if child.getName() == name {
                    return child;
                }
            }
        }
        if node is GroupItem {
            foreach var child in node.getChildren() {
                if child.getName() == name {
                    return child;
                }
            }
        }
        if node is DataItem && name == node.getName() {
            return node;
        }
        return;
    }
}

isolated function coerceDataItemValue(string|string[] data, DataItem dataItem) returns anydata|error {
    // Trim to remove spaces allocated for sing or Z prefix in decimal
    // TODO: validate with picture clause
    if data is string {
        if dataItem.isDecimal() {
            string decimalString = data.trim();
            check validateMaxByte(decimalString, dataItem);
            return decimal:fromString(decimalString);
        }
        if dataItem.isNumeric() {
            string intString = data.trim();
            check validateMaxByte(intString, dataItem);
            return int:fromString(intString);
        }
        check validateMaxByte(data, dataItem);
        return data;
    }
    anydata[] elements = [];
    if dataItem.isDecimal() {
        foreach string element in data {
            string decimalString = element.trim();
            check validateMaxByte(decimalString, dataItem);
            elements.push(check decimal:fromString(decimalString));
        }
        return elements;
    }
    if dataItem.isNumeric() {
        foreach string element in data {
            string intString = element.trim();
            check validateMaxByte(intString, dataItem);
            elements.push(check int:fromString(intString));
        }
        return elements;
    }
    foreach string element in data {
        check validateMaxByte(element, dataItem);
    }
    return data;
}

isolated function validateMaxByte(string value, DataItem dataItem) returns error? {
    if dataItem.isDecimal() {
        int? seperatorIndex = value.indexOf(".");
        int wholeNumberMaxLength = dataItem.getReadLength() - dataItem.getFloatingPointLength() - 1;
        if (seperatorIndex is int && seperatorIndex > wholeNumberMaxLength) || (seperatorIndex is () && value.length() > wholeNumberMaxLength) {
            return error Error(string `The whole number part of decimal value ${value} exceeds the maximum byte size of ${wholeNumberMaxLength}`);
        }
        if seperatorIndex is int && value.substring(seperatorIndex + 1).length() > dataItem.getFloatingPointLength() {
            return error Error(string `The fractional part of the decimal value ${value} exceeds the maximum byte size of ${dataItem.getFloatingPointLength()}`);
        }
    }
    if value.length() > dataItem.getReadLength() {
        return error Error(string `Value ${value} exceeds the max byte size ${dataItem.getReadLength()}`);
    }
}