//
//  GEventTouchObject.h
//  BraveRocket
//
//  Created by Alexander Lowe on 11/9/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//

//
//  GTouchLink.h
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 7/29/11.
//
//

#import "GChainLink.h"
#import "GChain.h"


@class GEventTouchObject;

@interface GEventTouchChain : GChain {
    
    CGPoint testPoint;
    int whichTouchTest;
    GEventTouchObject *linkWithClosestDistance;
    float currentClosestDistance;
    
}

@property (nonatomic, assign) CGPoint testPoint;
@property (nonatomic, readonly) int whichTouchTest;
@property (nonatomic, assign) GEventTouchObject *linkWithClosestDistance;
@property (nonatomic, assign) float currentClosestDistance;

- (void) resetWithTestPoint:(CGPoint)point;

- (void) setToTestTouchMoved;
- (void) setToTestTouchEnded;
- (void) setToCullTouchEnded;

@end



@class GEventDispatcher;

@interface GEventTouchObject : GChainLink {
    
    GEventTouchChain *touchChain;
    CGPoint gamePoint;    
    int touchLifeCycleCode;
    BOOL touchEnded;
    
    NSMutableDictionary *eventsZOrderDictionary;
    
    BOOL singleFrameEdgeCase_wasTouchStartRecognized;
    BOOL singleFrameEdgeCase_extremelyRapidTouchesEndHappened;
    
    BOOL availableForTouchStartTest;
    
    
}

- (BOOL) wasEventDispatchedForThisLink:(NSString *)evtCode;

- (id) initWithGamePoint:(CGPoint)gPoint;
- (void) declareClosestAndUpdateGamePoint:(CGPoint)point promoteToLifeCycleStage:(int)lifeCycle;
- (void) singleFrameEdgeCase_deferredSetTouchEndedToYES;

@property (nonatomic, assign) CGPoint gamePoint;
@property (nonatomic, readonly) BOOL touchEnded;

@property (nonatomic, assign) BOOL  singleFrameEdgeCase_wasTouchStartRecognized,
                                    singleFrameEdgeCase_extremelyRapidTouchesEndHappened;

@property (nonatomic, assign) BOOL availableForTouchStartTest;


@end
