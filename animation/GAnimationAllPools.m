//
//  GAnimationPool.m
//  BraveRocket
//
//  Created by Alexander Lowe on 10/31/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import "GAnimationAllPools.h"
#import "GTweenGroup.h"
#import "GAnimation.h"
#import "GAnimationPool.h"


@implementation GAnimationAllPools


- (id) initWithEngine:(GAnimation *)engine {
    
    self = [super init];
    
    animationEngine = engine;
    
    allPools = [[NSMutableDictionary alloc] init];
    
    poolStack = [[NSMutableArray alloc] init];
    
    isDestroyed = NO;
    
    return self;
    
}

/**
 */
- (void) addToPool:(GTweenGroup *)group withGroupStackLength:(int)groupStackLength {

//Ah! ok- immediately I see that this animation pool has a problem- we really NEED to be
//able to wrap a structure in beginPool/endPool. Otherwise we have to
//repeat the "pool" function again and again for complex animation structures.
//The critical thing is that we only want groups *on the same level as the pool* to be
//added to the pool. We don't want *nested* groups to be added to the pool.
    
//So the way I solved that was in the addToPool function in GAnimationPools it just has
//to compare the length of the pool-stack to the length of the group-stack.
//If they're equal, then that means that the group was opened on the same level as the
//pool, so in that case, add the group to the pool. So that explains this
//groupStackLength == [poolStack count] condition.
    
    if(currentPool && groupStackLength == [poolStack count]) {
    [currentPool addToPool:group];
    group.pool = currentPool;
    }
    
}



- (void) removeFromPool:(GTweenGroup *)group {
   
    if(group.pool) {
    [group.pool removeFromPool:group];
    group.pool = nil;
    }
    
}


- (void) beginPool:(NSString *)poolName {
    
GAnimationPool *pool = (GAnimationPool *)[allPools objectForKey:poolName];
    
    if(!pool) {
    pool = [[GAnimationPool alloc] init];
    [allPools setObject:pool forKey:poolName];
    }

[poolStack addObject:pool];
    
currentPool = pool;
    
}

- (void) endPool {
    if([poolStack count] > 0) {
    currentPool = (GAnimationPool *)[poolStack lastObject];
    [poolStack removeLastObject];
        
        if([poolStack count] == 0) {
        currentPool = nil;
        }
        
    } else {
    currentPool = nil;
    }
}


- (void) drainPool:(NSString *)poolName {
GAnimationPool *pool = (GAnimationPool *)[allPools objectForKey:poolName];
    if(pool) {
    [pool drainPool];
    }
}


- (void) pausePool:(NSString *)poolName {
    GAnimationPool *pool = (GAnimationPool *)[allPools objectForKey:poolName];
    if(pool) {
        [pool pausePool];
    }
}
- (void) unpausePool:(NSString *)poolName {
    GAnimationPool *pool = (GAnimationPool *)[allPools objectForKey:poolName];
    if(pool) {
        [pool unpausePool];
    }
}


- (void) destroy {
    
    if(!isDestroyed) {
    isDestroyed = YES;
    [poolStack removeAllObjects];
    [allPools removeAllObjects];
    [poolStack release];
    [allPools release];

    [self release];
    }
    
}



@end
