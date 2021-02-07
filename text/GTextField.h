//
//  GLText.h
//  barf_26
//
//  Created by Alexander  Lowe on 1/18/10.
//  Copyright 2010 Alex Lowe.
//

#import <Foundation/Foundation.h>
#import "GBox.h"

@class GTexture;
@class GNode;
@class GFontMap;
@class GFont;


@interface GTextField : GBox {

float textWidth;
float textFieldWidth;
    
float fontSize;

float fontRatio;

NSString *text;

int prevLength;

int prevSpace;
    
int firstInLine;

BOOL niceWords;

int textColor;

//the actual width of the text field.
float totalWidth;

//the number of frames between deletion for
//non-used characters.
int deletionPeriod;

//the advancing index to compare to deletionPeriod.
int stackDeletion;

BOOL prevStringWasEmpty;
    
GTexture *fontTexture;
    
GFontMap *fontMap;

NSString *fontString;

GNode *firstCharacter;

GNode *lastCharacter;

float spacing;

float stackWidth;
    
float stackHeight;
    
//float lineHeight;
    
BOOL singleLine;
    
BOOL centerCharacters;
    
BOOL centerJustify;

}

- (void) manageFontTextures;
- (void) decrementFont;

@property (nonatomic, readonly) float stackWidth;

@property (nonatomic, assign) BOOL niceWords;


/////////////
//         //
//  A P I  //
//         //
/////////////

- (id) initWithFont:(NSString *)font size:(int)sz andSpacing:(float)spcng;

- (void) setText:(NSString *)text;

- (void) setTextFieldWidth:(float)width;
- (float) textFieldWidth;

- (void) setLineSpacing:(float)spc;
- (float) lineSpacing;

- (void) setFontSize:(int)fSize;
- (int) fontSize;

- (void) setCenterCharacters:(BOOL)yesOrNo;
- (BOOL) centerCharacters;

- (void) setCenterJustify:(BOOL)yesOrNo;
- (BOOL) centerJustify;

@property (nonatomic, assign) int textColor;

@property (nonatomic, assign) BOOL singleLine;

@property (nonatomic, readonly) NSString *text;



@end 
