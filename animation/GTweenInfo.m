//
//  GTweenInfo.m
//  BraveRocket
//
//  Created by Alexander Lowe on 4/7/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import "GTweenInfo.h"
#import "GNode.h"

@implementation GTweenInfo

@synthesize target;
@synthesize isTargetAlive;

- (id) initWithTarget:(GNode *)animationTarget isTargetAlive:(BOOL)isAlive {
    self = [super init];
    target = animationTarget;
    isTargetAlive = isAlive;
    return self;
}

@end
