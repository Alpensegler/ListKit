//
//  Compile.swift
//  ListKitTests
//
//  Created by Frain on 2022/6/29.
//

import XCTest
@testable import ListKitNext

class CompileTests: XCTestCase {
    struct TestStruct1: DataSource {
        typealias Item = Int
        
        var source = [1, 2, 3]
    }
    
    func testCompile() {
        _ = TestStruct1()
    }
}

