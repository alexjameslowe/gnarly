//
//  GTouchLink.m
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 7/29/11.
//  
//

#import "GTouchLink.h"
#import "GChain.h"
#import "GEventDispatcher.h"
#import "GEvent.h"
#import "GEventTouchObject.h"


@implementation GTouchLink

@synthesize singleTouch,touchEnd;
@synthesize whichTouch, howManyTouches;
@synthesize eventToDispatch;


/**
 * init with x and y.
 *
 */
/*
- (id) initWithGamePoint:(CGPoint)gPoint
         eventDispatcher:(GEventDispatcher *)evtDispatcher
         eventToDispatch:(GEvent *)evt
        eventTouchObject:(GEventTouchObject *)evtTouchObject {
    
self = [super init];
gamePoint = gPoint;
whichTouch = 0;
howManyTouches = 0;
    
eventToDispatch = evt;
box = evtDispatcher;
eventTouchObject = evtTouchObject;
return self;
}
 */
- (id) initWithEvent:(GEvent *)evt
         eventDispatcher:(GEventDispatcher *)evtDispatcher
        eventTouchObject:(GEventTouchObject *)evtTouchObject {
    
    self = [super init];
    whichTouch = 0;
    howManyTouches = 0;
    
    eventToDispatch = evt;
    box = evtDispatcher;
    eventTouchObject = evtTouchObject;
    return self;
}




/**
 * accessors for the box (GEventDispatcher actually, but the box class used to contain all renderable logic, so
 * this property was called box and I haven't gotten around to changing it.)
 *
 * at any rate, this is set up to cache the delegate for the box for easy access in the analyze function. I intensely dislike
 * calling properties in performance-sensitive parts of the code.
 *
 */
- (GEventDispatcher *) box {
return box;
}
- (void) setBox:(GEventDispatcher *)b {
box = b;
}


/**
 * on analyze, fire the proper event, or the delegate function.
 *
 */
//You touch down with two touches. The second one will dispatch the event, and it has an event string.
//Fine. well, now you release both touches. The second one *already* dispatched that event string. it can't
//dispatch the same event-string twice. each g-event-touch-object can only dispatch a particular event once.
//so this whole business with START_END  or START_END_MOVE- that's not going to work. at least not in the
//way I'm thinking about it now.

/*
- (void) analyze {
    
    if(![eventTouchObject wasEventDispatchedForThisLink:eventToDispatch.evtCode]) {
        
        NSLog(@"##############################################");
        NSLog(@"##                                          ##");
        NSLog(@"##                DISPATCH                  ##");
        NSLog(@"##                                          ##");
        NSLog(@"##############################################");
        
    [box dispatch:eventToDispatch];
    } else {
        
        
    NSLog(@"NOWAYJOSE! %@",eventToDispatch.evtCode);
        
    }
[chain removeLink:self];
}
 */

- (void) analyze {
[box dispatch:eventToDispatch]; 
[chain removeLink:self];
}


@end
