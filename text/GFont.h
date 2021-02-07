//
//  GFont.h
//  CosmicDolphin_7_5
//
//  Created by Alexander  Lowe on 3/24/13.
//  Copyright (c) 2013 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>

#import "GBox.h"
@class GFontMap;

@class GTexture;

@interface GFont : GBox {

NSString *character;
    
GFontMap *fontMap;

GLuint texData;

float buffer;

float puncBuffer;

float uniformHeight;

int texInd;

float correctionY;
    
float previousCharacterBuffer;
    
int unicode;
    
int arrayIndex;

}


- (id) initFrom:(GTexture *)tex andFontMap:(GFontMap *)fMap;

- (void) setChr:(int)uni;

- (void) resetCellDimsWidth:(int)w andHeight:(int)h;

+ (void) setBoundTexIndManaully:(int)ind;

- (void) resetTexVertsWidth:(NSInteger)fullWidth height:(NSInteger)fullHeight viewWidth:(int)pWdth viewHeight:(int)pHght X:(float)xCrd Y:(float)yCrd;


@property (nonatomic, readonly) float buffer;

@property (nonatomic, readonly) float puncBuffer;

@property (nonatomic, assign) float uniformHeight;

@property (nonatomic, assign) float correctionY;

@property (nonatomic, readonly) int unicode, arrayIndex;

@property (nonatomic, assign) float previousCharacterBuffer;

@end

