//
//  GChainLink.h
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 7/29/11.
//  
//

@class GChain;

@interface GChainLink : NSObject {

@private
GChainLink *prev;
GChainLink *next;
BOOL isFirst;
BOOL isLast;

@public
GChain *chain;
    
}

- (void) analyze;

- (void) destroy;

@property (nonatomic, assign) GChainLink *prev;
@property (nonatomic, assign) GChainLink *next;

@property (nonatomic, assign) GChain *chain;

@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isLast;

@end
