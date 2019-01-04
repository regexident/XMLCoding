//
//  XMLSimpleContentTests.swift
//  XMLCodingTests
//
//  Created by Vincent Esche on 1/3/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import XCTest
@testable import XMLCoding

class XMLSimpleContentTests: XCTestCase {
    func testStringItem() {
        let string = "foo"
        
        let subject: XMLSimpleContent = .string(string)
        
        XCTAssertEqual(subject.string, string)
        
        XCTAssertNil(subject.data)
    }
    
    func testDataItem() {
        let string = "foo"
        let data = string.data(using: .utf8)!
        
        let subject: XMLSimpleContent = .data(data)
        
        XCTAssertEqual(subject.data, data)
        XCTAssertEqual(subject.string, string)
    }
}
