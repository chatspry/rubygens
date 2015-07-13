//
//  RubyGensTests.swift
//  RubyGensTests
//
//  Created by Tyrone Trevorrow on 13/07/2015.
//  Copyright © 2015 Chatspry. All rights reserved.
//

import XCTest
import Quick
import Nimble

class ObjectSnapshotSpec: QuickSpec {
    
    override func spec() {
        describe("snapshottable objects") {
            it("has specific key-value-coding keys derived from properties") {
                class A: NSObject, RubyCompatibleSnapshottable {
                    @objc var X: String!
                    @objc var Y: String!
                    @objc var Z: String!
                }
                class B: A {
                    @objc var A: String!
                }
                let object = A()
                let aProps = object.keyValueCodingKeysFromProperties
                expect(aProps).to(contain("X", "Y", "Z"))
                let b = B()
                let bProps = b.keyValueCodingKeysFromProperties
                expect(bProps).to(contain("X", "Y", "Z", "A"))
            }
        }
    }
}
