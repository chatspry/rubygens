//
//  RGApplication.h
//  RubyGens
//
//  Created by Tyrone Trevorrow on 20/05/2015.
//  Copyright (c) 2015 Chatspry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GBSettings;

@interface RGApplication : NSObject
@property (nonatomic, readonly, strong) GBSettings *settings;

- (void) runWithSettings: (GBSettings*) settings;

@end
