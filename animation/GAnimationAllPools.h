//
//  GAnimationPool.h
//  BraveRocket
//
//  Created by Alexander Lowe on 10/31/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import <Foundation/Foundation.h>

@class GTweenGroup;
@class GAnimation;
@class GAnimationPool;

/*
@interface GAnimationPool : NSObject {
    
    GTweenGroup *nextInPool;
    GTweenGroup *prevInPool;
    GTweenGroup *lastInPool;
    GTweenGroup *firstInPool;
    
}

- (void) addToPool:(GTweenGroup *)group;

- (void) removeFromPool:(GTweenGroup *)group;

- (void) drainPool;

@property (nonatomic, assign) GTweenGroup *nextInPool, *prevInPool, *lastInPool, *firstInPool;

@end
*/


@interface GAnimationAllPools : NSObject {
    
    NSMutableDictionary *allPools;
    
    NSMutableArray *poolStack;
    
    GAnimation *animationEngine;
    
    GAnimationPool *currentPool;
    
    BOOL isDestroyed;
    
}

- (id) initWithEngine:(GAnimation *)engine;

- (void) addToPool:(GTweenGroup *)group withGroupStackLength:(int)groupStackLength;

- (void) removeFromPool:(GTweenGroup *)group;

- (void) beginPool:(NSString *)poolName;

- (void) endPool;

- (void) drainPool:(NSString *)poolName;

- (void) pausePool:(NSString *)poolName;

- (void) unpausePool:(NSString *)poolName;

- (void) destroy;


@end
