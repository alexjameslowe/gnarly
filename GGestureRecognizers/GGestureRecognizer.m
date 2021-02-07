//
//  GGestureRecognizer.m
//  BraveRocket
//
//  Created by Alexander Lowe on 11/12/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//

#import "GGestureRecognizer.h"
#import "GTouchLink.h"
#import "GEventDispatcher.h"
#import "GSurface.h"
#import "GChain.h"
#import "GEvent.h"
#import "GEventTouchObject.h"

@implementation GGestureRecognizer

@synthesize injectionMetaObject;

- (void) setSurface:(GSurface *)surf andEventDispatcher:(GEventDispatcher *)evtDisp {
    root = surf;
    eventDispatcher = evtDisp;
}

- (void) setEventObjectLink:(GEventTouchObject *)link {
gEventTouchObject = link;
}

+ (BOOL) gestureHasTouchMove {
    return YES;
}
+ (BOOL) gestureHasTouchEnd {
    return YES;
}


+ (void) injectForEventListeners {
    
GGestureRecognizerInjectionMetaObject *metaObject = [[GGestureRecognizerInjectionMetaObject alloc] initWithClass:self
                                                                                                      touchStart:YES
                                                                                                       touchMove:[self gestureHasTouchMove]
                                                                                                        touchEnd:[self gestureHasTouchEnd]];
    
[GEvent injectGestureRecognizer:metaObject];
    
}




/**
 * The three delegates for these GGestureRecognizer classes: touch-started, touch-moved, touch-ended.
 * Whether it's a double-tap, swipe, pinch, whatever weird gesture it is, it's ultimately made up of
 * touches-started, touches-moved and touches-ended.
 *
 */
- (void) touchStarted:(CGPoint)gamePoint {}

- (void) touchMoved:(CGPoint)gamePoint {}

- (void) touchEnded:(CGPoint)gamePoint {}

/**
 * dispatch an event for the event-listening code. we're doing the same thing in here that we did in the
 * old system, which is create a link, hand the event off to it, and install then add that link to a special chain
 * on the GSurface object. What that chain does is loop *backward* through the links and dispatch the event for
 * each one. The *backwards-ness* is to preserve the expected behavior for z-ordering. If an display-object covers another
 * display object on the screen the expected behavior is that it will shield objects underneath it from touches.
 *
 *
 */
/*
- (void) dispatchEvent:(GEvent *)evt {
CGPoint gamePoint;
    
NSLog(@"GGestureRecognizer! dispatchEvent");
    
GTouchLink *tlk = [[GTouchLink alloc] initWithGamePoint:gamePoint
                                        eventDispatcher:eventDispatcher
                                        eventToDispatch:evt
                                       eventTouchObject:gEventTouchObject];
    
//NSLog(@"GGestureRecognizer: dispatchEvent: %@",tlk);

[root.touchChain addLink:tlk];
}
*/

- (void) dispatchEvent:(GEvent *)evt {
    GTouchLink *tlk = [[GTouchLink alloc] initWithEvent:evt
                                            eventDispatcher:eventDispatcher
                                           eventTouchObject:gEventTouchObject];
    
    [root.touchChain addLink:tlk];
}


@end
