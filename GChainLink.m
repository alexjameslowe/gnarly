//
//  GChainLink.m
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 7/29/11.
//  
//

#import "GChainLink.h"
#import "GChain.h"

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                                                                             //
    // The fundamental unit of GChain. This object has references to the previous and next siblings in the Chain.  // 
    //                                                                                                             //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
            
@implementation GChainLink


@synthesize prev,next;
@synthesize isFirst,isLast;
@synthesize chain;


- (id) init {
isFirst = NO;
isLast = NO;
return [super init];
}


- (void) analyze {};

- (void) destroy {};




@end
