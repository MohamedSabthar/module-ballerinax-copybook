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

import ballerina/jballerina.java;

isolated distinct class DataItem {
    *Node;

    isolated function getLevel() returns int = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function getName() returns string = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function getElementCount() returns int = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function isNumeric() returns boolean = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function isSigned() returns boolean = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function getReadLength() returns int = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function isDecimal() returns boolean {
        return self.isNumeric() && self.getFloatingPointLength() != 0;
    }

    isolated function getFloatingPointLength() returns int = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function getPicture() returns string = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function getRedefinedItemName() returns string? = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function getPossibleEnumValues() returns string[]? = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function getDefaultValue() returns string? = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function isBinary() returns boolean = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function getPackLength() returns int = @java:Method {
        'class: "io.ballerina.lib.copybook.runtime.converter.Utils"
    } external;

    isolated function accept(Visitor visitor, anydata data = ()) {
        visitor.visitDataItem(self, data);
    }

    isolated function toString() returns string {
        return externToString(self);
    }

    isolated function hasImpliedSeperator() returns boolean {
        return self.getPicture().includes("V");
    }
}
