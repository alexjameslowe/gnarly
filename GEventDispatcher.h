//
//  GEventDispatcher.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 10/18/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import <objc/message.h>
#import "GNode.h"


@interface GTouchObject : NSObject {
float x;
float y;
}

@property (nonatomic, assign) float x,y;
@end



@class GEvent;

@interface GEventDispatcher : GNode {

    //dictionary of event listeners.
    NSMutableDictionary *listeners;
    
    NSMutableArray *currentTouches;
    //NSMutableArray *gestureRecognizers;
    NSMutableDictionary *gestureRecognizersExist;
    NSMutableArray *gestureRecognizersTouchStart;
    NSMutableArray *gestureRecognizersTouchEnd;
    NSMutableArray *gestureRecognizersTouchMove;

	BOOL watchTouches;
    
	int watchTouchHistory;
    
	BOOL watchTouchStart;

	BOOL watchTouchEnd;
    
	BOOL watchDoubleTouch;

    BOOL watchTouchMove;
    
    int numListeners;
    
    GEventDispatcher *flat;
    
    //single touch object
    UITouch *touch1;
    
    //double touch object
	UITouch *touch2;
    
    //touch point in game coordinatess
	CGPoint gamePoint;
	CGPoint viewPoint1;
    
    BOOL _touchShield;
    
    }

@property (nonatomic, retain) GEventDispatcher *flat;

- (void) flatten:(BOOL)yesOrNo withObj:(GEventDispatcher *)disp;
- (void) addEL:(NSString *)evt withCallback:(NSString *)cllbck andObserver:(id)obs;
- (void) removeEL:(NSString *)evt;
- (void) dispatch:(GEvent *)evt;

- (void) setTouchShield:(BOOL)shld;
- (BOOL) touchShield;

- (void) addEL_addGestureReconizerInjections;
- (void) removeEL_addGestureReconizerInjections;

- (void) testTouchMovedEnded;
- (void) testTouchDown;

//test for touch down.
- (BOOL) touchPointTest:(CGPoint)collPt;



@end
