//
//  GPop.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 10/17/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//


#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "GRenderable.h"
@class GNode;

@interface GPop : GRenderable {

GNode *owner;

}

- (id) initWithOwner:(GNode *)own;


@end
