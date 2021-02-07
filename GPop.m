//
//  GPop.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 10/17/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.

#import "GPop.h"


@implementation GPop


- (id) initWithOwner:(GNode *)own {
self = [super init];
owner = own;
isPop = YES;
    
name2 = @"Popper";
return self;
}


/**
 * the only thing the popper has to do is pop, 
 * and then return the nextSib. 
 *
 */
- (GRenderable *) render {
//NSLog(@"GPop: render");
glPopMatrix();
return next;
}


@end
