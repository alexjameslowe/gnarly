//
//  GEventTouchObject.m
//  BraveRocket
//
//  Created by Alexander Lowe on 11/9/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//

#import "GEventTouchObject.h"
#import "GChain.h"
#import "GEventDispatcher.h"
#import "GEvent.h"

@implementation GEventTouchChain
@synthesize testPoint;
@synthesize whichTouchTest;
@synthesize linkWithClosestDistance;
@synthesize currentClosestDistance;

- (id) init {
    self = [super init];
    currentClosestDistance = -1;
    return self;
}

- (void) resetWithTestPoint:(CGPoint)point {
currentClosestDistance = -1;
testPoint = point;
}

- (void) setToTestTouchMoved {
    whichTouchTest = 1;
}
- (void) setToTestTouchEnded {
    whichTouchTest = 2;
}
- (void) setToCullTouchEnded {
    whichTouchTest = 3;
}

@end


@implementation GEventTouchObject;

@synthesize gamePoint;

@synthesize touchEnded;

@synthesize singleFrameEdgeCase_wasTouchStartRecognized, singleFrameEdgeCase_extremelyRapidTouchesEndHappened;

@synthesize availableForTouchStartTest;

/**
 * init with x and y.
 *
 */
- (id) initWithGamePoint:(CGPoint)gPoint {
    self = [super init];
    gamePoint = gPoint;
    touchLifeCycleCode = 0;
    touchEnded = NO;
    
    eventsZOrderDictionary = [[NSMutableDictionary alloc] init];
    singleFrameEdgeCase_wasTouchStartRecognized = NO;
    singleFrameEdgeCase_extremelyRapidTouchesEndHappened = NO;
    
    availableForTouchStartTest = YES;
    return self;
}

/**
 * If you're new to this code then don't worry yet about this single-frame-edge-case. Familiarize yourself with the correlation loops
 * on GSurface, the GGestureRecognizers and the implict dependency injection in the GEventDispatcher addEL, removeEL functions. When
 *you've wrapped your head around that, then circle back to this single-frame-edge-case and see what it's about.
 *
 */
- (void) singleFrameEdgeCase_deferredSetTouchEndedToYES {
touchEnded = YES;
}


- (BOOL) wasEventDispatchedForThisLink:(NSString *)evtCode {
    if([eventsZOrderDictionary objectForKey:evtCode]) {
    return true;
    }

[eventsZOrderDictionary setObject:@"_" forKey:evtCode];
return false;
}


/**
 * this function is called solely within the
 * auspices of the GSurface touchesStarted touchedMoved touchesEnded functions.
 *
 * when a point is declared the closest point to a particular ui-touch object it's going to receive this message,
 * which will update the touchLifeCycleCode as well as the gamePoint.
 *
 */
- (void) declareClosestAndUpdateGamePoint:(CGPoint)point promoteToLifeCycleStage:(int)lifeCycle {
gamePoint = point;
touchLifeCycleCode = lifeCycle;
    
    //If the touchLifeCycle code is 2, then we're going to
    //set the touchEnded flag to yes, and this will make it available
    //for destruction at the end of the frame on GSurface. If it's ended
    //then there's no point have it hang around.
    //
    //If you're new to this code then don't worry yet about this single-frame-edge-case. Familiarize yourself with the correlation loops
    //on GSurface, the GGestureRecognizers and the implict dependency injection in the GEventDispatcher addEL, removeEL functions. When
    //you've wrapped your head around that, then circle back to this single-frame-edge-case and see what it's about. For the time being
    //just think of this conditional as setting the touchEnded=YES.
    if(touchLifeCycleCode == 2) {
        
        //single-frame-edge-case: if the delegates touchesStarted and touchesEnded on the GSurface get triggered in the exact same frame.
        //In that case, it's conceivable that the touchEnded=YES will get set on this particular GEventTouchObject before the link ever makes
        //it to the GEventDispatcher touches-started conditions. In that case, the link will never be called on the GGestureRecongizer instances,
        //and that would bollix things up. The touch-end would fire but the touch-start would be lost.
        //
        //Well, to compensate for this, we have a bit of machinery in here to guarantee that this object gets recognized as a touch-start
        //before it ever gets recognized as a touch end. If singleFrameEdgeCase_wasTouchStartRecognized has been left at its default value
        //of "NO", then that means that it hasn't had a chance to run through the GGestureRecognizers as a touch-start yet. So instead
        //of immediately setting touchEnded=YES here, we're going to set this other variable, also a "singleFrameEdgeCase_" variable.
        //These particular variables basically defer setting the touch-end until after it's had a chance to run through the the
        //touch-started GGestureRecognizers.
        if(singleFrameEdgeCase_wasTouchStartRecognized) {
        touchEnded = YES;
        } else {
        singleFrameEdgeCase_extremelyRapidTouchesEndHappened = YES;
        }
        
    }
}


/**
 * on analyze, fire the proper event, or the delegate function.
 *
 */
- (void) analyze {
    
    if(!touchChain) {
    touchChain = (GEventTouchChain *)chain;
    }
    
CGPoint testPoint = touchChain.testPoint;
int lifeCycleTest = touchChain.whichTouchTest;
    
    if(lifeCycleTest == 3) {
    availableForTouchStartTest = NO;
        if(touchEnded == YES) {
        [chain removeLink:self];
        return;
        }
    }
    
    //this conditional is so that only touches which are in the current test will be applied.
    //the lifecycle test codes go 1,2,3 (start, move, end) and the touchLifeCycleCode starts out
    //at 0. When one of these links wins the loop contest it gets updated with the test code.
    //So when the touches-moved test fires it's only going to operated on the points that
    // *haven't previously passed the touches-moved test*. The touches-end test goes the same way.
    //that way we're not double-counting anything.
    if(touchLifeCycleCode < lifeCycleTest) {
        
    float currentClosestDistance = touchChain.currentClosestDistance;
    float dist = hypotf( gamePoint.x - testPoint.x , gamePoint.y - testPoint.y );
   
        if(currentClosestDistance < 0) {
        
        currentClosestDistance = dist;
        touchChain.linkWithClosestDistance = self;
            
        } else
        if(dist <= currentClosestDistance) {
        
        currentClosestDistance = dist;
        touchChain.linkWithClosestDistance = self;
        
        }
        
    }
    
}

- (void) dealloc {
[eventsZOrderDictionary release];
[super dealloc];
}

@end
