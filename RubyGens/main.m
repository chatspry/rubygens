//
//  main.m
//  RubyGens
//
//  Created by Tyrone Trevorrow on 20/05/2015.
//  Copyright (c) 2015 Chatspry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGApplication.h"
#import "GBCli.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        GBOptionsHelper *options = [[GBOptionsHelper alloc] init];
        options.applicationName = ^{
            return [[NSProcessInfo processInfo] processName];
        };
        options.applicationVersion = ^{ return @"1.0.0"; };
        options.printHelpHeader = ^{ return @"%APPNAME %APPVERSION\n\nUSAGE: %APPNAME [options] <template input files>\n       %APPNAME --help"; };
        [options registerSeparator: @"OPTIONS:"];
        [options registerOption: 'm' long: @"model" description: @"Path to the xcdatamodeld" flags: GBOptionRequiredValue];
        [options registerOption: 'g' long: @"output-dir-generated" description: @"Path for the generated machine files, files output to the human dir if this is not provided" flags: GBOptionRequiredValue];
        [options registerOption: 'o' long: @"output-dir" description: @"Path for the generated human files, defaults to current dir" flags: GBOptionRequiredValue];
        [options registerOption: '?' long: @"help" description: @"Prints out this help" flags: GBOptionNoValue|GBOptionInvisible];
        [options registerOption: 'v' long: @"version" description: @"Prints out this help" flags: GBOptionNoValue|GBOptionInvisible];
        [options registerOption: 0 long: @"input-paths" description: @"Template input files" flags: GBOptionRequiredValue|GBOptionNoCmdLine|GBOptionInvisible];
        
        GBSettings *factoryDefaults = [GBSettings settingsWithName: @"Defaults" parent: nil];
        // TODO: Put any default command line options in factoryDefaults
        
        GBSettings *providedSettings = [GBSettings settingsWithName: @"Provided" parent: factoryDefaults];
        GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
        [parser registerOptions: options];
        [parser registerSettings: providedSettings];
        [parser parseOptionsWithArguments: argv count: argc];
        
        if ([providedSettings boolForKey: @"help"] || argc <= 1) {
            [options printHelp];
            return EXIT_SUCCESS;
        }
        
        if ([providedSettings arguments].count == 0) {
            fprintf(stderr, "error: no input files\n");
            [options printHelp];
            return EXIT_FAILURE;
        }
        
        [options printValuesFromSettings: providedSettings];
        
        RGApplication *application = [RGApplication new];
        [application runWithSettings: providedSettings];
    }
    return 0;
}
