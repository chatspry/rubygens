//
//  RGApplication.m
//  RubyGens
//
//  Created by Tyrone Trevorrow on 20/05/2015.
//  Copyright (c) 2015 Chatspry. All rights reserved.
//

#import "RGApplication.h"
#import "GBCli.h"
#import "mruby.h"
#import "cocoa.h"

@interface RGApplication ()
@property (nonatomic, assign) mrb_state *mrb;
@property (nonatomic, assign) struct BridgeSupportStructTable *struct_table;
@property (nonatomic, assign) struct BridgeSupportConstTable *const_table;
@property (nonatomic, assign) struct BridgeSupportEnumTable *enum_table;
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

- (void) run
{
    
}

- (void) dealloc
{
    mrb_close(self.mrb);
    self.mrb = nil;
}

@end
