//
//  GTouchLink.h
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 7/29/11.
//  
//

#import "GChainLink.h"

@class GEventDispatcher;
@class GEvent;
@class GEventTouchObject;

@interface GTouchLink : GChainLink {
    
GEventDispatcher *box;
    
BOOL singleTouch;

BOOL touchEnd;
    
int whichTouch;
int howManyTouches;

//CGPoint gamePoint;

GEvent *eventToDispatch;
GEventTouchObject *eventTouchObject;
    
}

@property (nonatomic, assign) BOOL singleTouch;

@property (nonatomic, assign) BOOL touchEnd;

@property (nonatomic, assign) int whichTouch, howManyTouches;

@property (nonatomic, assign) GEvent *eventToDispatch;

- (GEventDispatcher *) box;

- (void) setBox:(GEventDispatcher *)b;

//- (id) initWithGamePoint:(CGPoint)gPoint
//         eventDispatcher:(GEventDispatcher *)evtDispatcher
//         eventToDispatch:(GEvent *)evt
//        eventTouchObject:(GEventTouchObject *)evtTouchObject;

- (id) initWithEvent:(GEvent *)evt
     eventDispatcher:(GEventDispatcher *)evtDispatcher
    eventTouchObject:(GEventTouchObject *)evtTouchObject;



@end
