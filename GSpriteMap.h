//
//  GSpriteMap.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/15/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>


@interface GSpriteMap : NSObject {

int _numFrames;

float _screenK;

float **_allFrames;

int _texWidth;

int _texHeight;
	
}

- (int) texWidth;
- (int) texHeight;
- (void) setTexWidth:(int)tW;
- (void) setTexHeight:(int)tH;

- (float **) getAllFrames;

- (int) numFrames;
- (void) setNumFrames:(int)n;

+ (void) setScreenK:(float)k;

+ (void) setTexWidth:(int)w andHeight:(int)h;

- (void) setWidth:(float *)wdth height:(float *)hght x:(float *)xCds y:(float *)yCds scaleX:(float *)scX scaleY:(float *)scY regX:(float *)rgX regY:(float *)rgY rotation:(float *)rot length:(int)len;
 
@end

