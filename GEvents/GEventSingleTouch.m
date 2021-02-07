//
//  GEventSingleTouch.m
//  BraveRocket
//
//  Created by Alexander Lowe on 11/13/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//

#import "GEventSingleTouch.h"
#import "GGestureSingleTouch.h"

@implementation GEventSingleTouch

@synthesize gamePoint;
@synthesize lifeCycle;

- (id)init:(NSString *)cd bubbles:(BOOL)bbls gamePoint:(CGPoint)pt andLifeCycle:(int)lCycle {
    
    self = [super init:cd bubbles:bbls];
    
    gamePoint = pt;
    lifeCycle = lCycle;
    
    return self;
}


+ (NSString *) START {
[GGestureSingleTouch injectForEventListeners];
return @"0fdj3";
}
+ (NSString *) END {
[GGestureSingleTouch injectForEventListeners];
return @"kcj38";
}
+ (NSString *) MOVE {
[GGestureSingleTouch injectForEventListeners];
return @"cn37";
}


@end
