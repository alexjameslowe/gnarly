//
//  GExistence.h
//  CosmicDolphin_7_9
//
//  Created by Alexander Lowe on 2/1/14.
//  Copyright (c) 2014 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>

@class GExistenceCounter;
@class GNode;

@interface GExistence : NSObject {
        
GExistenceCounter *existenceCounter;
GNode *node;
    
BOOL *isNodeStillAlive;
BOOL *lockedBooleanIsNodeStillAlive;
int *lockedCountOfExistenceWatchers;
    
}

- (id) initWithLockedCounter:(int *)counterPointer andLockedBoolean:(BOOL *)boolPointer;
- (id) initWithCounter:(GExistenceCounter *)eCounter andNode:(GNode *)node;
- (BOOL) test;

@end
