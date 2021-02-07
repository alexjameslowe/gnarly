//
//  GAnimationPool.m
//  BraveRocket
//
//  Created by Alexander Lowe on 10/31/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import "GAnimationPool.h"
#import "GTweenGroup.h"

@implementation GAnimationPool

@synthesize nextInPool, prevInPool, lastInPool, firstInPool;

@synthesize inDestroy;

- (id) init {
    self = [super init];
    numGroups = 0;
    inDestroy = NO;
    return self;
}

- (void) addToPool:(GTweenGroup *)group {
    
    if(!firstInPool) {
        numGroups++;
        
        firstInPool = group;
        lastInPool = group;
        
    } else {
        numGroups++;
        
        lastInPool.nextInPool = group;
        group.prevInPool = lastInPool;
        
        lastInPool = group;
        
    }
    
}

- (void) removeFromPool:(GTweenGroup *)group {
    
numGroups--;
    
    if(group.prevInPool) {
        group.prevInPool.nextInPool = group.nextInPool;
    } else {
        firstInPool = group.nextInPool;
        firstInPool.prevInPool = nil;
    }
    
    if(group.nextInPool) {
        group.nextInPool.prevInPool = group.prevInPool;
    } else {
        lastInPool = group.prevInPool;
        lastInPool.nextInPool = nil;
    }
    
}


- (void) drainPool {
    
    if(firstInPool) {
        
        GTweenGroup *group = firstInPool;
        GTweenGroup *next;
        
        self.inDestroy = YES;
        
        while(group) {
            
            [group retain];
            [group destroy];
            
            //the groups get removed from the pool in the rectify call.
            next = group.nextInPool;
        
            [group release];
             group = next;
        }
        
    }
    
}

- (void) pausePool {
    
    if(firstInPool) {
        
    GTweenGroup *group = firstInPool;
    GTweenGroup *next;
        
        while(group) {
        [group pause];
        next = group.nextInPool;
        group = next;
        }
        
    }
    
}
- (void) unpausePool {
    
    if(firstInPool) {
        
        GTweenGroup *group = firstInPool;
        GTweenGroup *next;
        
        while(group) {
            [group unpause];
            next = group.nextInPool;
            group = next;
        }
        
    }
    
}

@end
