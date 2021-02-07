//
//  GAnimationPool.h
//  BraveRocket
//
//  Created by Alexander Lowe on 10/31/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import <Foundation/Foundation.h>

@class GTweenGroup;

@interface GAnimationPool : NSObject {
    
    GTweenGroup *nextInPool;
    GTweenGroup *prevInPool;
    GTweenGroup *lastInPool;
    GTweenGroup *firstInPool;
    
    int numGroups;
    BOOL inDestroy;
    
}

- (void) addToPool:(GTweenGroup *)group;

- (void) removeFromPool:(GTweenGroup *)group;

- (void) drainPool;

- (void) pausePool;

- (void) unpausePool;

@property (nonatomic, assign) BOOL inDestroy;

@property (nonatomic, assign) GTweenGroup *nextInPool, *prevInPool, *lastInPool, *firstInPool;

@end
