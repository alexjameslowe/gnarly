//
//  GOptionsAndResouceList.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/16/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GOptionAndResourceList.h"
#import "GResource.h"


@implementation GOptionAndResourceList

@synthesize resources;
@synthesize preloaderClassName,preloaderResourceKey,pauseClassName,pauseResourceKey,preloaderSpriteClassName;
@synthesize hasPreloader,hasPause,willSurfacePauseOnReturnFromBackground,hasPreloaderSprite;

- (id) init {

self = [super init];

resources = [[NSMutableArray alloc] init];
hasPreloader = NO;
hasPause = NO;
willSurfacePauseOnReturnFromBackground = NO;
hasPreloaderSprite = NO;

return self;

}

/**
 * add a resource. sent it a release message to guarantee that the 
 * only surviving reference is in the array.
 *
 */
- (void) addResource:(GResource *)rec {
[resources addObject:rec];
[rec release];
}


- (void) dealloc {
[resources release];
[super dealloc];
}

@end
