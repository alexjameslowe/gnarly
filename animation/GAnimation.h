//
//  GLEasing.h
//  TankGame11
//
//  Created by Alexander  Lowe on 5/25/09.
//  Copyright 2009. See Licence.
//

#import <Foundation/Foundation.h>

#import "../GLayerMemoryObject.h"
@class GTween;
@class GBox;
@class GNode;
@class GTweenGroup;
@class GTweenStrategy;
@class GAnimationAllPools;
#import "GTweenInfo.h"



/*
@class GAnimation;

@interface GAnimationAPI : NSObject {

GAnimation *animationEngine;

}

- (id) initWithEngine:(GAnimation *)engine;

- (void) openGroup;
- (void) closeGroup;

- (void) debugNameForGroup:(NSString *)name;

- (void) beginSet:(GBox *)box;
- (void) animate:(NSString *)prop duration:(int)dur delay:(int)del end:(float)goal easing:(NSString *)ease;
- (void) onStart:(NSString *)strt startObs:(id)sObs;
- (void) onEnd:(NSString *)end endObs:(id)eObs;
- (void) onDestroy:(NSString *)end endObs:(id)eObs engineWide:(BOOL)eng;
- (void) clearEngineWideOnDestroy;
- (void) endSet;

- (void) inSequence;
- (void) inParallel;

- (void) goalModeAbsolute;
- (void) goalModeRelative;
- (void) goalModeRatio;

- (void) destroyTweensForTarget:(GBox *)target;

- (void) setExposurePolicy:(int)policy;

- (GTweenGroup *) exposeAnimation;

@end
*/
 
 

@interface GAnimation : NSObject {

GTween *firstTween;
GTween *lastTween;
GTweenGroup *lastRootSequenceGroup;
    
BOOL inDestructionProcess;
BOOL repeatDestructionLoop;
    
    
NSMutableArray *groupStack;
    
GTweenGroup *rootTweenGroup;

GTweenGroup *currentTweenGroup;
    
GAnimationAllPools *animationPools;

BOOL inNakedContext;

BOOL addTweensInParallel;
    
BOOL inBeginSetEndSetContext;

GBox *proceduralTarget;

int goalMode;
    
BOOL goalModeFromOrTo;

id engineWideDestroyObserver;

SEL engineWideDestroyCallback;

int exposurePolicy;

GTweenGroup *exposableTweenGroup;

NSString *DEBUG_NAME;

}

- (void) destroyAllTweens;

- (void) runTweens;

//- (void) resetLastTween:(GTween *)twn;
//- (void) resetFirstTween:(GTween *)twn;

- (GTweenGroup *) getRootTweenGroup;

- (BOOL) isAnimationObjectExposable;

  /////////////
  //         //
  //  A P I  //
  //         //
  /////////////


- (void) openGroup;
- (void) closeGroup;

- (void) beginSet:(GBox *)box;
- (void) timer:(int)duration;
- (void) animate:(NSString *)prop duration:(int)dur delay:(int)del end:(float)goal easing:(NSString *)ease;
- (void) animate:(GTweenStrategy *)strategy;
- (void) onStart:(NSString *)strt startObs:(id <GLayerMemoryObject>)sObs;
- (void) onEnd:(NSString *)end endObs:(id <GLayerMemoryObject>)eObs;
- (void) endSet;
- (void) beginPool:(NSString *)poolName;
- (void) endPool;
- (void) drainPool:(NSString *)poolName;
- (void) pausePool:(NSString *)poolName;
- (void) unpausePool:(NSString *)poolName;

- (void) inSequence;
- (void) inParallel;

- (void) goalModeAbsolute;
- (void) goalModeRelative;
- (void) goalModeFrom;
- (void) goalModeTo;
//- (void) goalModeRatio;

- (void) destroyTweensForTarget:(GBox *)target;

- (void) setExposurePolicy:(int)policy;
- (GTweenGroup *) exposeAnimation;

- (void) debugNameForGroup:(NSString *)name;


+ (GAnimation *) getEngine;

//+ (GAnimationAPI *) getAPI;
//+ (void) returnAPI:(GAnimationAPI *)api;

+ (void) openGroup;
+ (void) closeGroup;

+ (void) beginSet:(GBox *)box;
+ (void) timer:(int)duration;
+ (void) animate:(NSString *)prop duration:(int)dur delay:(int)del end:(float)goal easing:(NSString *)ease;
+ (void) animate:(GTweenStrategy *)strategy;
+ (void) onStart:(NSString *)strt startObs:(id <GLayerMemoryObject>)sObs;
+ (void) onEnd:(NSString *)end endObs:(id <GLayerMemoryObject>)eObs;
+ (void) endSet;
+ (void) beginPool:(NSString *)poolName;
+ (void) endPool;
+ (void) drainPool:(NSString *)poolName;
+ (void) pausePool:(NSString *)poolName;
+ (void) unpausePool:(NSString *)poolName;

+ (void) inSequence;
+ (void) inParallel;

+ (void) goalModeAbsolute;
+ (void) goalModeRelative;
+ (void) goalModeFrom;
+ (void) goalModeTo;
//+ (void) goalModeRatio;

+ (void) destroyTweensForTarget:(GBox *)target;

+ (void) setExposurePolicy:(int)policy;
+ (GTweenGroup *) exposeAnimation;

+ (void) debugNameForGroup:(NSString *)name;

+ (int) EXPOSURE_EXPOSE_ANIMATION_AND_AUTO_RENDER;
+ (int) EXPOSURE_EXPOSE_ANIMATION_RENDERING_WILL_WAIT;
+ (int) EXPOSURE_CONCEAL_ANIMATION_AUTO_RENDER;



@end
