//
//  ObjectSnapshot.swift
//  RubyGens
//
//  Created by Tyrone Trevorrow on 13/07/2015.
//  Copyright © 2015 Chatspry. All rights reserved.
//

import Foundation

@objc protocol RubyCompatibleSnapshottable : NSObjectProtocol {
    var rubyCompatibleKeyValueCodingKeys: [String] { get }
}

extension RubyCompatibleSnapshottable {
    
    var rubyCompatibleKeyValueCodingKeys: [String] {
        return keyValueCodingKeysFromProperties
    }
    
    var keyValueCodingKeysFromProperties: [String] {
        var cls: AnyClass? = self.dynamicType
        var properties = [String]()
        while cls != nil && cls != NSObject.self {
            var count: UInt32 = 0
            let propListPtr = class_copyPropertyList(cls, &count)
            let propList = Array(UnsafeBufferPointer(start: propListPtr, count: Int(count)))
            for prop in propList {
                let propName = String(CString: property_getName(prop), encoding: NSUTF8StringEncoding)!
                properties.append(propName)
            }
            cls = class_getSuperclass(cls)
        }
        return properties
    }
    
    var rubyCompatibleSnapshot: [String : AnyObject] {
        return [:]
    }
}

class ObjectSnapshot {
    let ruby: RGMRubyContext
    
    init(ruby: RGMRubyContext) {
        self.ruby = ruby
    }
    
    // Given a ruby-compatible object node in an object graph, will return a ruby value
    // which internally is a ruby hash populated with the data from the object graph
    func rubyValue(object: RubyCompatibleSnapshottable) -> RGMRubyObjectValue {
        // TODO
        return RGMRubyObjectValue()
    }
    
    // Given a ruby-compatible object node in an object graph, will return a Swift dictionary
    // representation of that object graph which can be encoded into ruby objects
    func rubyCompatibleRepresentation(object: RubyCompatibleSnapshottable) -> [String : AnyObject] {
        // TODO
        return [:]
    }
    
}

