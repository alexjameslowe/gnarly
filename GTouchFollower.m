//
//  GTouchFollower.m
//  RidiculousMissile3
//
//  Created by Alexander  Lowe on 5/5/11.
//  Copyright 2011 Codequark. See Licence.
//

#import "GTouchFollower.h"
#import "GEvent.h"
#import "GRenderable.h"
#import "GnarlySettings.h"


@implementation GTouchFollower

@synthesize followSpeed;






- (id) init:(NSString *)key ownsEvents:(BOOL)owns addLineToRootOrParent:(BOOL)oneOrTheOther atIndex:(int)index {
self= [super init:key];
ownsEvents = owns;
addLineToRoot = oneOrTheOther;
addLineAt = index;    
stackFollow = 0;
followSpeed = 5;
following = NO;
followFF = NO;

    if(ownsEvents == YES) {
    [self addEL:@"T_START" withCallback:@"startLine"   andObserver:self];
    [self addEL:@"T_MOVE"  withCallback:@"drawLine"    andObserver:self];
    }
    
    return self; 
}


/**
 * accesors for the total length.
 *
 */
- (void) setTotalLength:(float)len {
//take no action
}
- (float) totalLength {
    
    if(followLine) {
    return followLine.totalLength;
    } else {
    return 0;
    }
    
}



/**
 * accesors for the reached end condition.
 *
 */
- (void) setReachedEnd:(BOOL)bl {
//take no action
}
- (BOOL) reachedEnd {
    if(followLine) {
    return followLine.reachedEnd;
    } else {
    return NO;
    }
}




/**
 * start up the line if it hasn't been started yet.
 *
 */
- (void) startLine:(GEvent *)evt {
evt.keepBubbling = NO;

[self startLine];

/*
    if(!followLine) {
   
    followLine = [[GTouchLine alloc] init];
    
        if(addLineToRoot == YES) {
        [root addChild:followLine];
        } else {
        [parent addChild:followLine];    
        }
   
    } else {
    
    [followLine clearLine];
    following = NO;
    followFF = NO;
    xDiff = 0;
    yDiff = 0;
    stackFollow = 0;
    currPt = CGPointMake(x, y);
    targPt = CGPointMake(x, y);
    
    }*/
    
}


- (void) startLine {

    
    if(!followLine) {
        
    followLine = [[GTouchLine alloc] init];
        
        if(addLineToRoot == YES) {
            if(addLineAt < 0) {
            [root addChild:followLine];
            } else {
            [root addChild:followLine at:addLineAt];     
            }
        } else {
            if(addLineAt < 0) {
            [parent addChild:followLine]; 
            } else {
            [parent addChild:followLine at:addLineAt];   
            }
        }
        
    } else {
        
        [followLine clearLine];
        following = NO;
        followFF = NO;
        xDiff = 0;
        yDiff = 0;
        stackFollow = 0;
        currPt = CGPointMake(x, y);
        targPt = CGPointMake(x, y);
        
    }
    
}


/**
 * draw the line as the touch is moving.
 *
 */
- (void) drawLine:(GEvent *)evt {
evt.keepBubbling = NO;
[self drawLineX:gamePoint.x andY:gamePoint.y];
/*
   if(followFF == NO) {
    followFF = YES;
    currPt = CGPointMake(x, y);
    targPt = CGPointMake(x, y);
    following = YES;
    [followLine startDrawX:gamePoint.x andY:gamePoint.y];
    }
    
[followLine addX:gamePoint.x andY:gamePoint.y];
*/
    
}



- (void) drawLineX:(float)xCoord andY:(float)yCoord {

    if(followFF == NO) {
        followFF = YES;
        currPt = CGPointMake(x, y);
        targPt = CGPointMake(x, y);
        following = YES;
        [followLine startDrawX:xCoord andY:yCoord];
    }
    
    [followLine addX:xCoord andY:yCoord];
    
}





/**
 * as we're rendering, manually do the animation as it eats up each
 * segment on the line path.
 *
 */
- (GRenderable *) render {

    if(following == YES) {
    stackFollow++;
    
    ratio = stackFollow/followSpeed;
 
    x = currPt.x + xDiff*ratio;
    y = currPt.y + yDiff*ratio;
    
        if(followLine.reachedEnd == NO) {
        rotation = currRotation + rotationDiff*ratio;
        }
        
        if(stackFollow == followSpeed) {
        stackFollow = 0;
        currPt = targPt;
        targPt = [followLine getNext];
        
        xDiff = targPt.x - currPt.x;
        yDiff = targPt.y - currPt.y;
        
        CGPoint niceRotation =  [GMath normalizeRotationFrom:rotation To:(atan2f(yDiff, xDiff)*gRadToDeg)];
        currRotation = niceRotation.x;
        rotationDiff = niceRotation.y - niceRotation.x;
        }
    }
    
return [super render];
    
}



/**
 * remove the follow line on destruction.
 *
 */
- (void) destroy {

NSLog(@"TOUCH FOLLOWER DEALLOCING.");
    
   // if(addLineToRoot == YES) {
   // followLine.unglue = YES;
   // [root removeChild:followLine];
   
   // } else {
    //followLine.unglue = YES;
    //[parent removeChild:followLine];
   // }
   [followLine destroy];    

[super destroy];
    
}

@end
