//
//  RGMRubyContext.h
//  RubyGens
//
//  Created by Tyrone Trevorrow on 11/07/2015.
//  Copyright © 2015 Chatspry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RGMRubyValue : NSObject

- (NSString*) stringValue;
- (NSNumber*) numberValue;

@end

@interface RGMRubyObjectValue : RGMRubyValue
- (RGMRubyValue*) callMethodName: (NSString*) method argumentList: (NSArray<RGMRubyValue*>*) args;
- (RGMRubyValue*) callMethodName: (NSString*) method arguments: (RGMRubyValue*) arg, ... NS_REQUIRES_NIL_TERMINATION;

@end

@interface RGMRubyClassValue : RGMRubyObjectValue
- (RGMRubyObjectValue*) newObject;
- (RGMRubyObjectValue*) newObjectWithArgumentList: (NSArray<RGMRubyValue*>*) args;
- (RGMRubyObjectValue*) newObjectWithArguments: (RGMRubyValue*) arg, ... NS_REQUIRES_NIL_TERMINATION;

@end

@interface RGMRubyContext : NSObject

- (RGMRubyValue*) evaluateMRuby: (NSString*) mrubyCode;
- (RGMRubyValue*) exception;

- (RGMRubyClassValue*) classWithName: (NSString*) className;

- (RGMRubyValue*) valueForString: (NSString*) string;
- (RGMRubyValue*) valueForNumber: (NSNumber*) number;

@end
