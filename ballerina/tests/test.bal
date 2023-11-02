import ballerina/test;
import ballerina/io;

@test:Config
isolated function testConvertor() returns error? {
    Converter convertor = check new("mainfram.cob");
    string originalContent = check io:fileReadString("resp.txt");

    map<json> val = check convertor.toJson(originalContent);
    string recreatedContent = check convertor.toCopybook(val);
    
    check io:fileWriteString("red.txt", recreatedContent);
    test:assertEquals(recreatedContent, originalContent);
}