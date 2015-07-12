//
//  RGMRubyContext.m
//  RubyGens
//
//  Created by Tyrone Trevorrow on 11/07/2015.
//  Copyright © 2015 Chatspry. All rights reserved.
//

// We're keeping this file Objective-C, because that "C" part
// in "Objective-C" means it'll _always_ be better at interfacing
// with C than Swift will.

#import "RGMRubyContext.h"
#import "mruby.h"
#import "mruby/compile.h"
#import "mruby/string.h"
#import "cocoa.h"

@interface RGMRubyValue ()
@property (nonatomic, strong) RGMRubyContext *context;
@end

@interface RGMRubyContext () {
    @public
    mrb_state *_mrb;
    struct BridgeSupportStructTable *_struct_table;
    struct BridgeSupportConstTable *_const_table;
    struct BridgeSupportEnumTable *_enum_table;
}
@end

@implementation RGMRubyValue {
    @public
    mrb_value _val;
}

+ (instancetype) value: (mrb_value) value context: (RGMRubyContext*) context
{
    Class cls = [RGMRubyValue class];
    if (mrb_type(value) == MRB_TT_CLASS) {
        cls = [RGMRubyClassValue class];
    } else if (mrb_type(value) == MRB_TT_OBJECT) {
        cls = [RGMRubyObjectValue class];
    }
    RGMRubyValue *v = [cls new];
    v->_val = value;
    v.context = context;
    return v;
}

- (NSString*) debugDescription
{
    mrb_value mrb_str = mrb_inspect(self.context->_mrb, _val);
    return [[NSString alloc] initWithBytes: RSTRING_PTR(mrb_str) length: RSTRING_LEN(mrb_str) encoding: NSUTF8StringEncoding];
}

- (NSString*) stringValue
{
    if (mrb_string_p(_val)) {
        return [[NSString alloc] initWithBytes: RSTRING_PTR(_val) length: RSTRING_LEN(_val) encoding: NSUTF8StringEncoding];
    } else {
        return nil;
    }
}

- (NSNumber*) numberValue
{
    if (mrb_fixnum_p(_val)) {
        mrb_int num = mrb_fixnum(_val);
        return @(num);
    } else if (mrb_float_p(_val)) {
        mrb_float f = mrb_float(_val);
        return @(f);
    } else {
        return nil;
    }
}

@end

@implementation RGMRubyObjectValue

- (RGMRubyValue*) callMethodName:(NSString *)method argumentList:(NSArray<RGMRubyValue *> *)args
{
    __block mrb_value *vals = calloc(args.count, sizeof(mrb_value));
    [args enumerateObjectsUsingBlock:^(RGMRubyValue * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        vals[idx] = obj->_val;
    }];
    
    mrb_value return_value = mrb_funcall_argv(self.context->_mrb, _val, mrb_intern_cstr(self.context->_mrb, method.UTF8String), (mrb_int) args.count, vals);
    free(vals);
    vals = NULL;
    
    return [RGMRubyValue value: return_value context: self.context];
}

- (RGMRubyValue*) callMethodName:(NSString *)method arguments:(RGMRubyValue *)arg, ...
{
    NSMutableArray *argList = [NSMutableArray new];
    va_list args;
    va_start(args, arg);
    for (RGMRubyValue *currentArg = arg; currentArg != nil; currentArg = va_arg(args, RGMRubyValue*)) {
        [argList addObject: currentArg];
    }
    va_end(args);
    return [self callMethodName: method argumentList: argList];
}

@end

@implementation RGMRubyClassValue

- (RGMRubyObjectValue*) newObject
{
    return [self newObjectWithArgumentList: nil];
}

- (RGMRubyObjectValue*) newObjectWithArguments:(RGMRubyValue *)arg, ...
{
    NSMutableArray *argList = [NSMutableArray new];
    va_list args;
    va_start(args, arg);
    for (RGMRubyValue *currentArg = arg; currentArg != nil; currentArg = va_arg(args, RGMRubyValue*)) {
        [argList addObject: currentArg];
    }
    va_end(args);
    return [self newObjectWithArgumentList: argList];
}

- (RGMRubyObjectValue*) newObjectWithArgumentList:(NSArray<RGMRubyValue *> *)args
{
    __block mrb_value *vals = calloc(args.count, sizeof(mrb_value));
    [args enumerateObjectsUsingBlock:^(RGMRubyValue * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        vals[idx] = obj->_val;
    }];
    struct RClass *c = (struct RClass *) mrb_basic_ptr(_val);
    mrb_value return_value = mrb_obj_new(self.context->_mrb, c, (mrb_int) args.count, vals);
    return [RGMRubyObjectValue value: return_value context: self.context];
}

@end

@implementation RGMRubyContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mrb = mrb_open();
        load_cocoa_bridgesupport(_mrb, _struct_table, _const_table, _enum_table);
    }
    return self;
}

- (RGMRubyValue*) evaluateMRuby:(NSString *)mrubyCode
{
    mrb_value val = mrb_load_string(_mrb, mrubyCode.UTF8String);
    [self logRubyException];
    return [RGMRubyValue value: val context: self];
}

- (RGMRubyValue*) exception
{
    if (_mrb->exc == nil) {
        return nil;
    } else {
        return [RGMRubyValue value: mrb_obj_value(_mrb->exc) context: self];
    }
}

- (RGMRubyClassValue*) classWithName:(NSString *)className
{
    struct RClass *class_value = mrb_class_get(_mrb, className.UTF8String);
    return [RGMRubyClassValue value: mrb_obj_value(class_value) context: self];
}

- (RGMRubyValue*) valueForNumber:(NSNumber *)number
{
    RGMRubyValue *v = [RGMRubyValue new];
    v.context = self;
    
    // TODO: Numbers -- THE WORST
    return v;
}

- (RGMRubyValue*) valueForString:(NSString *)string
{
    RGMRubyValue *v = [RGMRubyValue new];
    v->_val = mrb_str_new(_mrb, string.UTF8String, (mrb_int) string.length);
    v.context = self;
    return v;
}

- (BOOL) logRubyException
{
    if (self.exception) {
        fprintf(stderr, "%s\n", self.exception.debugDescription.UTF8String);
    }
    return NO;
}

- (void) dealloc
{
    mrb_close(_mrb);
    _mrb = NULL;
}

@end
