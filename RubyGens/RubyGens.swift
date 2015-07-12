//
//  RubyGens.swift
//  RubyGens
//
//  Created by Tyrone Trevorrow on 12/07/2015.
//  Copyright © 2015 Chatspry. All rights reserved.
//

import Foundation
import CoreData

class StandardErrorOutputStream: OutputStreamType {
    func write(string: String) {
        fputs(string, stderr)
    }
}

let stdErr = StandardErrorOutputStream()

class RubyGens {
    let ruby = RGMRubyContext()
    var model: NSManagedObjectModel?
    var settings: GBSettings!
    
    func run(settings: GBSettings) {
        self.settings = settings
        if let modelPath = settings.objectForKey("model") {
            let rubyCode = "$model = Cocoa::NSManagedObjectModel._alloc._initWithContentsOfURL(Cocoa::NSURL._fileURLWithPath(\"\(modelPath)\"))"
            ruby.evaluateMRuby(rubyCode)
        }
        process(settings.arguments as? [String])
    }
    
    func process(templates: [String]?) {
        guard let inputFiles = templates else { return }
        let merbClass = ruby.classWithName("MERB")
        let fm = NSFileManager()
        for inputFilePath in inputFiles {
            if !fm.fileExistsAtPath(inputFilePath) {
                print("error: file does not exist \(inputFilePath)", stdErr, appendNewline: true)
                exit(EXIT_FAILURE)
            }
            let merb = merbClass.newObject()
            let returnVal = merb.callMethodName("convert", argumentList: [ruby.valueForString(inputFilePath)])
            let returnStr = returnVal.stringValue()
            print(returnStr, appendNewline: true)
        }
    }
}