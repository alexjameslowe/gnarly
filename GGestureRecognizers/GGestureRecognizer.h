//
//  GGestureRecognizer.h
//  BraveRocket
//
//  Created by Alexander Lowe on 11/12/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//

@class GSurface;
@class GEventDispatcher;
@class GEvent;
@class GEventTouchObject;
@class GGestureRecognizerInjectionMetaObject;

#import "GChainLink.h"



@interface GGestureRecognizer : GChainLink {
    
    GSurface *root;
    GEventDispatcher *eventDispatcher;
    GEventTouchObject *gEventTouchObject;
    GGestureRecognizerInjectionMetaObject *injectionMetaObject;
    
}

- (void) setEventObjectLink:(GEventTouchObject *)link;
- (void) setSurface:(GSurface *)surf andEventDispatcher:(GEventDispatcher *)evtDisp;

@property (nonatomic, assign) GGestureRecognizerInjectionMetaObject *injectionMetaObject;

/////////////
//         //
//  A P I  //
//         //
/////////////

+ (BOOL) gestureHasTouchMove;
+ (BOOL) gestureHasTouchEnd;
+ (void) injectForEventListeners;

- (void) touchStarted:(CGPoint)gamePoint;
- (void) touchMoved:(CGPoint)gamePoint;
- (void) touchEnded:(CGPoint)gamePoint;
- (void) dispatchEvent:(GEvent *)evt;

@end
