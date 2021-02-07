//
//  GEventDoubleTouch.m
//  BraveRocket
//
//  Created by Alexander Lowe on 11/24/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//


#import "GEventDoubleTouch.h"
#import "GGestureDoubleTouch.h"

@implementation GEventDoubleTouch

@synthesize gamePoint;
@synthesize lifeCycle;

- (id)init:(NSString *)cd bubbles:(BOOL)bbls gamePoint:(CGPoint)pt andLifeCycle:(int)lCycle {
    
    self = [super init:cd bubbles:bbls];
    
    gamePoint = pt;
    lifeCycle = lCycle;
    
    return self;
}


+ (NSString *) START {
[GGestureDoubleTouch injectForEventListeners];
return @"vmdje";
}
+ (NSString *) END {
[GGestureDoubleTouch injectForEventListeners];
return @"pvmdkw";
}
+ (NSString *) MOVE {
[GGestureDoubleTouch injectForEventListeners];
return @"wuqixn";
}


@end
