//
//  GFontMap.h
//  BraveRocket
//
//  Created by Alexander Lowe on 7/9/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import <Foundation/Foundation.h>

//@class fontTexture;

@interface GFontMap : NSObject {
    
    int _numFrames;
    
    float **_allFrames;
    
    float _kerning;
    
}


- (void) setWidth:(float *)widths height:(float *)heights x:(float *)xCoords y:(float *)yCoords yCorrection:(float *)correctionY defaultYPosition:(int *)defaultYPos kerning:(float)kern lineHeight:(float)lineHeight length:(int)len;

- (int) calculateEncoding:(int)uni;

- (float) calculateBufferForCurrentCharacter:(int)currentUnicode andPreviousCharacter:(int)prevUnicode;

- (float *) getFrameFromMappedEncoding:(int)encoded;

- (int) numFrames;
- (void) setNumFrames:(int)n;

- (float) kerning;
- (void) setKerning:(float)k;

@end
