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
#import "mruby.h"
#import "mruby/compile.h"
#import "mruby/string.h"
#import "cocoa.h"

@interface RGApplication ()
@property (nonatomic, assign) mrb_state *mrb;
@property (nonatomic, assign) struct BridgeSupportStructTable *struct_table;
@property (nonatomic, assign) struct BridgeSupportConstTable *const_table;
@property (nonatomic, assign) struct BridgeSupportEnumTable *enum_table;
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, readwrite, strong) GBSettings *settings;
@end

@implementation RGApplication

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mrb = mrb_open();
        load_cocoa_bridgesupport(self.mrb, self.struct_table, self.const_table, self.enum_table);
    }
    return self;
}

- (void) runWithSettings:(GBSettings *)settings
{
    self.settings = settings;
    
    NSString *modelPath = [self.settings objectForKey: @"model"];
    if (modelPath) {
        NSString *rubyCode = [NSString stringWithFormat: @"$model = Cocoa::NSManagedObjectModel._alloc._initWithContentsOfURL(Cocoa::NSURL._fileURLWithPath(\"%@\"))", modelPath];
        [self executeRubyCode: rubyCode];
        if (self.mrb->exc) {
            return;
        }
    }
    
    NSArray *inputFiles = [settings arguments];
    [self processTemplates: inputFiles];
}

- (void) processTemplates: (NSArray*) inputFiles
{
    struct RClass *merbClass = mrb_class_get(self.mrb, "MERB");
    NSFileManager *fm = [NSFileManager new];
    for (NSString *inputFilePath in inputFiles) {
        if (![fm fileExistsAtPath: inputFilePath isDirectory: nil]) {
            fprintf(stderr, "error: file does not exist: %s\n", inputFilePath.UTF8String);
            exit(EXIT_FAILURE);
        }
        mrb_value merbInstance = mrb_obj_new(self.mrb, merbClass, 0, NULL);
        mrb_value merbVal = mrb_funcall(self.mrb, merbInstance, "convert", 1, mrb_str_new_cstr(self.mrb, inputFilePath.UTF8String));
        if ([self logRubyException]) {
            exit(EXIT_FAILURE);
        }
        char *templateOutput = mrb_str_to_cstr(self.mrb, merbVal);
        if (!templateOutput) {
            fprintf(stderr, "error: template did not produce string: %s\n", inputFilePath.UTF8String);
            exit(EXIT_FAILURE);
        }
        printf("%s\n", templateOutput);
    }
}

- (mrb_value) executeRubyCode: (NSString*) code
{
    mrb_value val = mrb_load_string(self.mrb, code.UTF8String);
    [self logRubyException];
    return val;
}

- (BOOL) logRubyException
{
    if (self.mrb->exc) {
        mrb_value obj = mrb_funcall(self.mrb, mrb_obj_value(self.mrb->exc), "inspect", 0);
        fwrite(RSTRING_PTR(obj), RSTRING_LEN(obj), 1, stdout);
        putc('\n', stdout);
        return YES;
    }
    return NO;
}

- (void) dealloc
{
    mrb_close(self.mrb);
    self.mrb = nil;
}

@end
