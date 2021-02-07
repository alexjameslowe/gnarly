//
//  GChain.h
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 7/29/11.
//  
//

#import "GChainLink.h"


@interface GChain : GChainLink {

GChainLink* firstLink;
GChainLink* lastLink;

GChainLink* scanPrev;
GChainLink* scanNext;
int scanPos;

BOOL isEmpty;

BOOL shielded;
    
int length;
    
    


    
}

- (GChainLink *) getFirstLink;

- (GChainLink *) getLastLink;

- (void) loopForward;

- (void) loopBackward;

- (void) addLink:(GChainLink *)link;

- (void) removeLink:(GChainLink *)link;

- (GChainLink *) scanForward;

- (GChainLink *) scanBackward;

- (void) resetScan;

- (void) empty;

- (void) destroy;

@property (nonatomic, readonly) BOOL isEmpty;

@property (nonatomic, assign) BOOL shielded;

@property (nonatomic, readonly) int length;

@end
