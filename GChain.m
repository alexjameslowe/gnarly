//
//  GChain.m
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 7/29/11.
//  
//

#import "GChain.h"

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                                                                        //
    // An abstract class to handle chains. A chain is a different way of collecting object than arrays.       //
    // It handles a specific problem of grouping objects that need to be rapidly looped without the overhead  //
    // of NSMutableArray. It's fast and lightweight. The trade-off is there is no searching or                //
    // indexing.                                                                                              //
    //                                                                                                        //
    // Note that this class inherits from GChainLink, meaning that chains themselves can be linked together   //
    // to form a chain. So meta-chains of an arbitrary number of dimensions can be formed.                    //
    //                                                                                                        //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation GChain

@synthesize isEmpty,shielded;
@synthesize length;


- (id) init {
isEmpty = YES;
length = 0;
scanPos = 0;
return [super init];
}


///////////////
//           //
//  A  P  I  //
//           //
///////////////


- (GChainLink *) getFirstLink {
return firstLink;
}
- (GChainLink *) getLastLink {
    return lastLink;
}

/**
 * loops forward. zooms through the links in a while loop, with each link pointing to the next one.
 *
 */
- (void) loopForward {

GChainLink *link = firstLink;

    while(link) {
    GChainLink *n = link.next;
    [link analyze];
    link = n;
    }
}


/**
 * loops backward. zooms through the links in a while loop, with each link pointing to the previous one.
 *
 */
- (void) loopBackward {

GChainLink *link = lastLink;

    while(link) {
    GChainLink *n = link.prev;
    [link analyze];
    link = n;
    }

}


/**
 * append a link to the back of the chain.
 *
 */
- (void) addLink:(GChainLink *)link {
    
    if(isEmpty == YES) {
    isEmpty = NO;
    firstLink = link;
    lastLink = link;
    } else {
    lastLink.next = link;
    link.prev = lastLink;

    lastLink.isLast = NO;
    lastLink = link;
   
    }
    
length++;
link.chain = self;

}





/**
 * remove a link from anywhere in the chain. the chain will reset to its empty state if
 * the only link is removed. the link is destroyed at the end of the function. does nothing
 * if the link does not belong to the chain.
 *
 */
/*
- (void) removeLink:(GChainLink *)link {

    if(link.chain == self) {
    
        if(link.prev) {
        link.prev.next = link.next;
            if(link.next) {
            link.next.prev = link.prev;
            }
        } else {
        link.isFirst = NO;
        
            if(link.next) {
            link.next.isFirst = YES;
            } else {
            firstLink = nil;
            lastLink = nil;
            isEmpty = YES;
                //THIS IS NEW. TEST THIS MUCHO.
                link.next = nil;
            }
            
        }
        
        if(link.next) {
        link.next.prev = link.prev;
        } else {
        link.isLast = NO;
        
            if(link.prev) {
            link.prev.isLast = YES;
            } else {
            firstLink = nil;
            lastLink = nil;
            isEmpty = YES;
                //THIS IS NEW. TEST THIS MUCHO.
                link.next = nil;
            }
        
        }
    
    length--;
    [link destroy];
    [link release];
    }
    
}*/
- (void) removeLink:(GChainLink *)link {

    if(link.chain == self) {
        
        if(link.prev) {
            if(link.next) {
            link.next.prev = link.prev;
            } else {
            lastLink = link.prev;
            }
        link.prev.next = link.next;
        } else {
            
            if(link.next) {
            firstLink = link.next;
            link.next.prev = nil;
            link.next = nil;
            } else {
            firstLink = nil;
            lastLink = nil;
            isEmpty = YES;
            }
            
            
        }
        
    length--;
    [link destroy];
    [link release];
    }
    
}


- (GChainLink *) getLinkAt:(int)index {
return nil;
}


/**
 *
 *
 */
- (GChainLink *) scanForward {
scanPos++;

    if(scanPos == 1) {
    scanNext = firstLink;
    scanPrev = firstLink;
    return firstLink;
    } else {
    scanNext = scanPrev.next;
    scanPrev = scanNext;
    return scanNext;
    }

}
- (GChainLink *) scanBackward {

    if(scanPos == length) {
    scanPos--;
    scanNext = lastLink;
    scanPrev = lastLink;
    return lastLink;
    } else {
    scanPos--;
    scanNext = scanPrev.prev;
    scanPrev = scanNext;
    return scanNext;
    }

}
- (void) resetScan {
scanPos = 0;
}



/**
 * just empty out the chain. destroy all chain links.
 *
 */
- (void) empty {

GChainLink *link = firstLink;

    while(link) {
    GChainLink *n = link.next;
        //if(link.isLast) {
        //NSLog(@"Chain Is Emptying: link: %@%@",link,@" isLast=YES");
        //} else {
        //NSLog(@"Chain Is Emptying: link: %@%@",link,@" isLast=NO");
        //}
    [self removeLink:link];
    link = n;
    }

}


/**
 * the destroy method.
 *
 */
- (void) destroy {
    [self empty];
    [self release];
}



@end
