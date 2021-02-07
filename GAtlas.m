//
//  GAtlas.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/16/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GAtlas.h"
#import "GTexture.h"
#import "GSpriteMap.h"
#import "GSprite.h"

@implementation GAtlas

@synthesize texture;
@synthesize map;
@synthesize numFrames;

- (id) initTexture:(GTexture *)tex andMap:(GSpriteMap *)mp {

self = [super init];

self.texture = tex;
self.map = mp;
numFrames = map.numFrames;
        
return self;

}



//this will destroy the causal link and take all of the linked.
- (void) dealloc {
[self.texture release];
[self.map release];
[super dealloc];
}

@end
