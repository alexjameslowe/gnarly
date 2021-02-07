//
//  GExistence.m
//  CosmicDolphin_7_9
//
//  Created by Alexander Lowe on 2/1/14.
//  Copyright (c) 2014 Alex Lowe. See Licence.
//

#import "GExistence.h"
#import "GNode.h"

///////////////////////////////////////////////////////////////////////////////////////////
//                                                                                       //
//  This class is meant to be a safe way to tell if a GNode has been deleted.            //
//  The idea is that upon request, a GNode will provide an instance of GExistence        //
//  to the outside world. You can use the test function to see if the GNode              //
//  has deleted, and you'll never have to worry about EXC_BAD_ACCESS run-time errors.    //
//                                                                                       //
//  When a GExistence object is issued, There are 2 internal                             //
//  primitive variables inside GNode which get allocated, but are never freed by         //
//  the GNode itself. What happens is that the memory ownership is transferred           //
//  to the GExistence objects, and then the last of them that watched a particular       //
//  GNode is gone, the original memory allocated in the GNode will get freed.            //
//                                                                                       //
///////////////////////////////////////////////////////////////////////////////////////////

@implementation GExistence


/**
 * init the object with pointers the counter and the boolean, which stick around
 * after the GNode deallocates and after this 
 *
 */
- (id) initWithLockedCounter:(int *)counterPointer andLockedBoolean:(BOOL *)boolPointer {
self = [super init];

    lockedBooleanIsNodeStillAlive = boolPointer;
    lockedCountOfExistenceWatchers = counterPointer;
    isNodeStillAlive = &lockedBooleanIsNodeStillAlive[0];
    
return self;
}

- (id) initWithCounter:(GExistenceCounter *)eCounter andNode:(GNode *)nd; {
    self = [super init];
    
    node = nd;
    existenceCounter = eCounter;
    existenceCounter.countOfExistenceWatchers++;
 
    return self;
}



/**
 * free the memory from the original object if this is the last of the existence watchers
 * that watched that object.
 *
 */
- (void) dealloc {
    
existenceCounter.countOfExistenceWatchers--;

    if(existenceCounter.countOfExistenceWatchers <= 0) {
        
        //if the node still exists and there are no more existence
        //watchers, then we're going to reset the existence with
        //the resetExistence function which will destroy the
        //existence counter.
        if(existenceCounter.doesGNodeExist == YES) {
        [node resetExistence];
        }
        
        //otherwise, just kill it right here.
        else {
        [existenceCounter release];
        }
        
    existenceCounter = nil;
    }
    
[super dealloc];
}

/////////////
//         //
//  A P I  //
//         //
/////////////

/**
 * use this function to test to see if to see if the object which issued it is still alive.
 * In theory, this is perfectly safe. The pointer will always point to the original boolean
 * and you'll never get an EXC_BAD_ACCESS error. In theory.
 *
 */
- (BOOL) test {
return existenceCounter.doesGNodeExist;
}

@end
