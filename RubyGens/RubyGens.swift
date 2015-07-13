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

extension String {
    var ASCIIChar: CChar? {
        return self.cStringUsingEncoding(NSASCIIStringEncoding)?[0]
    }
}

let stdErr = StandardErrorOutputStream()

class RubyGens {
    let ruby = RGMRubyContext()
    var model: NSManagedObjectModel?
    var settings: GBSettings!
    
    init() {
        let options = GBOptionsHelper()
        options.applicationName = {
            return NSProcessInfo.processInfo().processName
        }
        options.applicationVersion = {
            return "1.0.0"
        }
        options.printHelpHeader = {
            return "%APPNAME %APPVERSION\n\nUSAGE: %APPNAME [options] <template input files>\n       %APPNAME --help"
        }
        
        options.registerSeparator("OPTIONS:")
        options.registerOption("m".ASCIIChar!, long: "model", description: "Path to the xcdatamodeld", flags: [.RequiredValue])
        options.registerOption("g".ASCIIChar!, long: "output-dir-generated", description: "Path for the generated machine files, files output to the human dir if this is not provided", flags: [.RequiredValue])
        options.registerOption("o".ASCIIChar!, long: "output-dir", description: "Path for the generated human files, defaults to current dir", flags: [.RequiredValue])
        options.registerOption("?".ASCIIChar!, long: "help", description: "Prints out this help", flags: [.NoValue, .Invisible])
        options.registerOption("v".ASCIIChar!, long: "version", description: "Prints out this help", flags: [.NoValue, .Invisible])
        options.registerOption(0, long: "input-paths", description: "Template input files", flags: [.RequiredValue, .NoCmdLine, .Invisible])
        
        let factoryDefaults = GBSettings(name: "Defaults", parent: nil)
        let providedSettings = GBSettings(name: "Provided", parent: factoryDefaults)
        let parser = GBCommandLineParser()
        parser.registerOptions(options)
        parser.registerSettings(providedSettings)
        parser.parseOptionsWithArguments(Process.unsafeArgv, count: Process.argc)
        
        if providedSettings.boolForKey("help") || Process.arguments.count <= 1 {
            options.printHelp()
            exit(EXIT_SUCCESS)
        }
        
        if providedSettings.arguments.count == 0 {
            print("error: no input files", target: stdErr)
            exit(EXIT_FAILURE)
        }
        
        // For debugging
        options.printValuesFromSettings(providedSettings)
        
        self.settings = providedSettings
    }
    
    func run() {
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