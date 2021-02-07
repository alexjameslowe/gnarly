//
//  GTweenInfo.h
//  BraveRocket
//
//  Created by Alexander Lowe on 4/7/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import <Foundation/Foundation.h>

@class GNode;

@interface GTweenInfo : NSObject {
    
    GNode *target;
    BOOL isTargetAlive;
    
}

- (id) initWithTarget:(GNode *)target isTargetAlive:(BOOL)isAlive;

@property (nonatomic, readonly) GNode *target;
@property (nonatomic, readonly) BOOL isTargetAlive;

@end
