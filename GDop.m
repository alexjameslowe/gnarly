//
//  GDop.m
//  CosmicDolphin_7_2
//
//  Created by Alexander  Lowe on 12/12/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GDop.h"
#import "GNode.h"


@implementation GDop

/**
 * the only thing the popper has to do is pop, 
 * and then return the nextSib. 
 *
 */
- (GRenderable *) render {
glPopMatrix();
[owner contract];
return next;
}

@end
