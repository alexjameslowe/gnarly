//
//  GEventSingleTouch.m
//  BraveRocket
//
//  Created by Alexander Lowe on 11/12/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//

#import "GGestureSingleTouch.h"
#import "GEventSingleTouch.h"

@implementation GGestureSingleTouch


+ (BOOL) gestureHasTouchMove {
    return YES;//NO;
}
+ (BOOL) gestureHasTouchEnd {
    return YES;
}

- (void) touchStarted:(CGPoint)gamePoint {
GEventSingleTouch *evt = [[GEventSingleTouch alloc] init:[GEventSingleTouch START] bubbles:YES gamePoint:gamePoint andLifeCycle:0];
[self dispatchEvent:evt];
}

- (void) touchMoved:(CGPoint)gamePoint {
GEventSingleTouch *evt = [[GEventSingleTouch alloc] init:[GEventSingleTouch MOVE] bubbles:NO gamePoint:gamePoint andLifeCycle:1];
[self dispatchEvent:evt];
}

- (void) touchEnded:(CGPoint)gamePoint {
GEventSingleTouch *evt = [[GEventSingleTouch alloc] init:[GEventSingleTouch END] bubbles:YES gamePoint:gamePoint andLifeCycle:2];
[self dispatchEvent:evt];
}


@end
