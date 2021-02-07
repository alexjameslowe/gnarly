//
//  GGestureDoubleTouch.m
//  BraveRocket
//
//  Created by Alexander Lowe on 11/24/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//

#import "GGestureDoubleTouch.h"
#import "GEventDoubleTouch.h"
#import "GEventTouchObject.h"

@implementation GGestureDoubleTouch


+ (BOOL) gestureHasTouchMove {
    return NO;
}
+ (BOOL) gestureHasTouchEnd {
    return YES;
}

- (id) init {
    self = [super init];
    touchEndCount = 0;
    touchStartCount = 0;
    doubleTouchDownWasDetected = NO;
    return self;
}


- (void) touchStarted:(CGPoint)gamePoint {
  
    if(!gEventTouchObject0) {
    gEventTouchObject0 = gEventTouchObject;
    date0 = [[NSDate alloc] init];
    } else
    if(!gEventTouchObject1) {
    gEventTouchObject1 = gEventTouchObject;
    date1 = [[NSDate alloc] init];
        
    NSTimeInterval intervalSinceDate = [date1 timeIntervalSinceDate:date0];
    [date0 release];
    [date1 release];
    date0 = nil;
    date1 = nil;
        
        if(gEventTouchObject0 && gEventTouchObject1) {
            
            if(gEventTouchObject0.touchEnded == NO && gEventTouchObject1.touchEnded == NO) {

            CGPoint gP0 = gEventTouchObject0.gamePoint;
            CGPoint gp1 = gEventTouchObject1.gamePoint;
                
                float hyp = hypotf(gP0.x - gp1.x, gP0.y - gp1.y);
                
                //count anything less than that as simultaneous.
                if(intervalSinceDate < 0.2 && hyp > 20) {
                //NSLog(@"!!!! %f%@%f",(float)intervalSinceDate,@" hyp: ",hyp);
                GEventDoubleTouch *evt = [[GEventDoubleTouch alloc]
                                          init:[GEventDoubleTouch START] bubbles:YES gamePoint:gamePoint andLifeCycle:0];
                [self dispatchEvent:evt];
                doubleTouchDownWasDetected = YES;
                }
                
            }
            
        }
        
    }
    
}

- (void) touchMoved:(CGPoint)gamePoint {}

- (void) touchEnded:(CGPoint)gamePoint {
    
    if(gEventTouchObject == gEventTouchObject0 || gEventTouchObject == gEventTouchObject1) {
        
        if(gEventTouchObject == gEventTouchObject0) {
        gEventTouchObject0 = nil;
        }
        if(gEventTouchObject == gEventTouchObject1) {
        gEventTouchObject1 = nil;
        }
        
        if(doubleTouchDownWasDetected) {
        touchEndCount++;
            
            if(touchEndCount == 2) {
            doubleTouchDownWasDetected = NO;
            touchEndCount = 0;
            GEventDoubleTouch *evt = [[GEventDoubleTouch alloc] init:[GEventDoubleTouch END] bubbles:YES gamePoint:gamePoint andLifeCycle:2];
            [self dispatchEvent:evt];
            }
                
        }
        
    }
    
}


@end
