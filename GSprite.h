//
//  PVR.h
//  22_research_4
//
//  Created by Alexander  Lowe on 11/10/09.
//  Copyright 2009 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>
#import "GBox.h"


@class GAtlas;
@class GSpriteMap;
@class GTexture;

@interface GSprite : GBox {

GLuint texData;

float **_allFrames;

int texInd;

NSString *_key;

GSpriteMap *spriteMap;
GTexture *textureObject;
GAtlas *atlasObject;

int _frame;
int numFrames;
    
BOOL isSpriteDesroyed;
    
    
//BOOL temporal_willSpriteNotifyOfDestruction;
    
}

//private functions
+ (GLfloat *) setTexVertsWidth:(NSInteger)fullWidth height:(NSInteger)fullHeight viewWidth:(int)partialWidth viewHeight:(int)partialHeight;
+ (void) newTextureRequiresBoundIndexUpdate:(int)newInt;
+ (void) setBoundTexIndManually:(int)newInt;
- (void) resetTexVertsWidth:(NSInteger)fullWidth height:(NSInteger)fullHeight viewWidth:(int)pWdth viewHeight:(int)pHght X:(float)xCrd Y:(float)yCrd;
- (void) resetCellDimsWidth:(int)w andHeight:(int)h;
- (id) init;

+ (int) getBoundTextInt;



/////////////
//         //
//  A P I  //
//         //
/////////////


//init.
- (id) init:(NSString *)key;

@property (nonatomic, readonly) int numFrames;

//use cached resources.
+ (void) setFirstAtlas:(GAtlas *)fAtlas andCachedAtlas:(GAtlas *)cAtlas;
+ (void) useLastAtlas;
+ (void) useFirstAtlas;
+ (void) useAtlas:(NSString *)key;

@property (nonatomic, assign) BOOL temporal_willSpriteNotifyOfDestruction;

//frame accessor.
- (void) goTo:(int)index;

- (int) frame;
- (void) setFrame:(int)f;

- (NSString *) key;
- (void) setKey:(NSString *)k;


@end




