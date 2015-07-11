//
//  RGApplication.m
//  RubyGens
//
//  Created by Tyrone Trevorrow on 20/05/2015.
//  Copyright (c) 2015 Chatspry. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "RGApplication.h"
#import "GBCli.h"
#import "RGMRubyContext.h"

@interface RGApplication ()
@property (nonatomic, strong) RGMRubyContext *ruby;
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, readwrite, strong) GBSettings *settings;
@end

@implementation RGApplication

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ruby = [RGMRubyContext new];
    }
    return self;
}

- (void) runWithSettings:(GBSettings *)settings
{
    self.settings = settings;
    
    NSString *modelPath = [self.settings objectForKey: @"model"];
    if (modelPath) {
        NSString *rubyCode = [NSString stringWithFormat: @"$model = Cocoa::NSManagedObjectModel._alloc._initWithContentsOfURL(Cocoa::NSURL._fileURLWithPath(\"%@\"))", modelPath];
        [self.ruby evaluateMRuby: rubyCode];
    }
    
    NSArray *inputFiles = [settings arguments];
    [self processTemplates: inputFiles];
}

- (void) processTemplates: (NSArray*) inputFiles
{
    RGMRubyClassValue *merbClass = [self.ruby classWithName: @"MERB"];
    NSFileManager *fm = [NSFileManager new];
    for (NSString *inputFilePath in inputFiles) {
        if (![fm fileExistsAtPath: inputFilePath isDirectory: nil]) {
            fprintf(stderr, "error: file does not exist: %s\n", inputFilePath.UTF8String);
            exit(EXIT_FAILURE);
        }
        RGMRubyObjectValue *merb = [merbClass newObject];
        RGMRubyValue *returnVal = [merb callMethodName: @"convert" arguments: [self.ruby valueForString: inputFilePath], nil];
        NSString *returnStr = [returnVal stringValue];
        printf("%s\n", returnStr.UTF8String);
    }
}

@end
