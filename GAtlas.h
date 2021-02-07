//
//  GAtlas.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/16/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>


////////////////////////////////////////////////////////
//                                                    //
//  a simple pairing of texture and sprite map data.  //
//  to be installed in the _atlasDictionary.          //
//                                                    //
////////////////////////////////////////////////////////

@class GTexture;
@class GSpriteMap;
@class GSprite;

@interface GAtlas: NSObject {

GTexture *texture;

GSpriteMap *map;
    
int numFrames;

}

- (id) initTexture:(GTexture *)tex andMap:(GSpriteMap *)mp;


@property (nonatomic, retain) GTexture *texture;
@property (nonatomic, retain) GSpriteMap *map;

//@property (nonatomic, readonly) int numFrames;
@property (nonatomic, assign) int numFrames;

@end
