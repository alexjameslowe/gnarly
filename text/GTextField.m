//
//  GLText.m
//  barf_26
//
//  Created by Alexander  Lowe on 1/18/10.
//  Copyright 2010 Alex Lowe.
//

#import "GTextField.h"
#import "GTexture.h"
#import "GSprite.h"
#import "GRenderable.h"
#import "GSprite.h"
#import "GNode.h"
#import "GFont.h"
#import "GFontMap.h"


///////////////////////////////////////////////////////////////////////////
//
// A basic text field. Emphasis on 'basic'.
//
///////////////////////////////////////////////////////////////////////////



@implementation GTextField

//the dictionary holding a reference to all of the font textures in use. Each texture is
//matched to a key, and the key is the name of the font.
static NSMutableDictionary* fontTextures;

//the dictionary holding reference to all of the font maps in use. Each map is matched to
//a key, and the key is the name of the font.
static NSMutableDictionary* fontMaps;

//a dictionary which keeps track of the number of text fields are initiated with a specific font.
//if that number goes down to zero, then the font texture is destroyed.
static NSMutableDictionary* fontInstances;

//we keep track of the total number of text fields. when we get to 0 we release the above dictionaries.
static int totalNumberOfTextFields = 0;

@synthesize text;

@synthesize niceWords;

@synthesize textColor;

@synthesize stackWidth;

@synthesize singleLine;


/**
 * init a single label of text with the font string and the size.
 * by default, the text field will be a single line. the width
 * can be set with the textWidth property after initialization.
 *
 */
- (id) initWithFont:(NSString *)font size:(int)sz andSpacing:(float)spcng {

self = [super init];
    
totalNumberOfTextFields++;

fontSize = (float)sz;
    
spacing = spcng;

fontRatio = _screenHiResScale*0.38*((float)sz/12);

textWidth = 0;

prevLength = 0;

prevSpace = 0;

textColor = 0xFFFFFF;

totalWidth = 0;

niceWords = YES;

fontString = font;

prevStringWasEmpty = NO;

deletionPeriod = 10;
stackDeletion = 0;
    
singleLine = NO;
    
centerCharacters = NO;
    
text = @"";
[text retain];

//manage the font textures.
[self manageFontTextures];

/////// 2017-01-20 THIS THREW AN ERROR. ////////////
////create a test-character to measure the line-height.
//GFont *testChar = [[GFont alloc] initFrom:fontTexture andFontMap:fontMap];
//[testChar setChr:32];
//float lineHeight = testChar.uniformHeight*fontRatio*spacing;
//[testChar release];
////////////

return self;

}

- (GRenderable *)render {
[GFont setBoundTexIndManaully:-99];
[GSprite setBoundTexIndManually:-99];
return [super render];
}



/**
 * A function to help the TextField class manage the memory of the font textures. Everytime a new text field is created, this function
 * will see if the font texture is already cached in the fontTextures dictionary. If it is, then use it instead of allocating more
 * resources unecessarily.
 *
 */
- (void) manageFontTextures {
    
    //if the dictionary of font textures does not exist yet, then create it.
    if(!fontTextures) {
    fontTextures = [[NSMutableDictionary alloc] init];
    }
    
    //the dictionary of the font-maps.
    if(!fontMaps) {
    fontMaps = [[NSMutableDictionary alloc] init];
    }
    
    //the dictionary of number-of-instances of a particular font-type.
    if(!fontInstances) {
    fontInstances = [[NSMutableDictionary alloc] init];
    }
    
//get the number of times this font has been used in a text field.
NSNumber *num = [fontInstances valueForKey:fontString];
    
    //////////////////////////////////////////////////////////////////////////
    //if a textfield with the this particular font has already been created,
    //then just tick up the number of instances in the fontInstances dictionary.
    if(num) {
    int numVal = [num intValue];
    numVal++;
    [fontInstances setValue:[NSNumber numberWithInt:numVal] forKey:fontString];
    fontTexture = [fontTextures valueForKey:fontString];
    fontMap = [fontMaps valueForKey:fontString];
        
    } 
    
    //////////////////////////////////////////////////////////////////////////
    //else, if this is the first text field to use this particular font, then
    //create the fontTexture variable, and assign it to the fontTextures dictionary,
    //and also make a note in the fontInstances dictionary.
    else {
        
    NSString *mapClassName = [NSString stringWithFormat:@"G%@%@",fontString,@"Map"];
    //get the map object. ask it- hey map- what's your texture name? it says: It's xyz. so you check to see if
    //it already exists. if it already exists, then we're going to 
        
    NSString *textureFilename = [NSString stringWithFormat:@"G%@%@",fontString,@"Tex"];
        
    //generate the main texture and add it to the dictionary.
    //also generate a font-map and add it to its own dictionary.
    fontTexture = [GPNGTexture getTexture:textureFilename];
            //NSLog(@"creating font map %@",mapClassName);
    fontMap = [[NSClassFromString(mapClassName) alloc] init];
        
    [fontTextures setValue:fontTexture forKey:fontString];
    [fontMaps setValue:fontMap forKey:fontString];
    [fontInstances setValue:[NSNumber numberWithInt:1] forKey:fontString];
        
    //we only want one reference for the texture, which is the one in the dictionary.
    [fontTexture release];
    [fontMap release];
    }
    
}



/**
 * A function to help the TextField class manage the memory of the font textures. Everytime a text field gets zeroed out or deleted, this function
 * will be called. It will keep track of how many text fields are still living which use this particular font. If this is last text field which uses
 * the font, then the texture is no longer needed and it is ejected from the fontTextures dictionary and deallocs.
 *
 */
- (void) decrementFont {
    
    //get the number of times this font has been used in a text field.
    NSNumber *num = [fontInstances valueForKey:fontString];
    
    //////////////////////////////////////////////////////////////////////////
    //if this is the last text field which has a particular font, then the 
    //font gets deleted, and the instance tracking NSNumber gets deleted.
    if(num) {
    int numVal = [num intValue];
    numVal--;
        
        if(numVal <= 0) {
        [fontTextures  removeObjectForKey:fontString];
        [fontInstances removeObjectForKey:fontString];
        [fontMaps      removeObjectForKey:fontString];
        } else {
        [fontInstances setValue:[NSNumber numberWithInt:numVal] forKey:fontString];
        }
    } 
}




/////////////
//         //
//  A P I  //
//         //
/////////////


/**
 * Set the text-width, change the font-size and the line spacing. Reflow the text if necessary.
 *
 */
- (void) setTextFieldWidth:(float)width {
BOOL resetText = (width != textFieldWidth);
textWidth = width*_screenHiResScale;
textFieldWidth = width;

    //only reset the text if the value has changed.
    if(resetText) {
        if(text) {
        self.text = text;
        }
    }
}
- (float) textFieldWidth {
    return textFieldWidth;
}

- (void) setLineSpacing:(float)spc {
BOOL resetText = (spc != spacing);
spacing = spc;
    
    //only reset the text if the value has changed.
    if(resetText) {
        if(text) {
        self.text = text;
        }
    }
}
- (float) lineSpacing {
    return spacing;
}

- (void) setFontSize:(int)fSize {
BOOL resetText = (fSize != fontSize);
fontSize = (float)fSize;
fontRatio = _screenHiResScale*0.38*((float)fSize/12);
    
    //only reset the text if the value has changed.
    if(resetText) {
        if(text) {
        self.text = text;
        }
    }
}
- (int) fontSize {
    return fontSize;
}


- (void) setCenterCharacters:(BOOL)yesOrNo {
    BOOL resetText = (yesOrNo != centerCharacters);
    centerCharacters = yesOrNo;
    
    //only reset the text if the value has changed.
    if(resetText) {
        if(text) {
            self.text = text;
        }
    }

}
- (BOOL) centerCharacters {
    return centerCharacters;
}


- (void) setCenterJustify:(BOOL)yesOrNo {
BOOL resetText = (yesOrNo != centerJustify);
centerJustify = yesOrNo;
    
    if(resetText) {
        if(text) {
            self.text = text;
        }
    }
}
- (BOOL) centerJustify {
    return centerJustify;
}


/**
 * The most complicated accessor ever. Writes the text. Creates characters
 * if they are needed- destroys the ones that aren't. Does some managing
 * of the texture data. Every 10 sets, the non-used characters are destroyed.
 *
 * If you zero out the text-field with an empty string, then the texture will be
 * decremented. If all of the text fields with this specific font (the one the text
 * field was created with) are zeroed out, then the font texture will be destroyed.
 * If one of the textfields is then given a non-empty string, then the texture will
 * be recreated.
 *
 */
- (void) setText:(NSString *)textString {
    
// 65 A. 66 B. 67 C ...
//32 = unicode space.

[text release];

text = textString;

[text retain];

float stackX = 0;
float stackY = 0;

BOOL lineHeightWasSet = NO;
float lineHeight = 0;

int len = (int)textString.length;
int numToReset = len;

    if(prevLength < len) {
    numToReset = prevLength;
    }
    
int outerBound = len - numChildren + numToReset;

GNode *resetChar = firstCharacter;
GFont *prevSpaceChar;
    
    /////////////////////////////////////////////////////////////////
    //if the previous string was empty, then the font texture needs 
    //to be incremented/created.
    if(prevStringWasEmpty == YES && len != 0) {
    [self manageFontTextures];
    }
    
    /////////////////////////////////////////////////////////////
    //if the string is empty, then kill all of the characters and
    //decrement/destroy the font texture
    if(len == 0) {
    prevStringWasEmpty = YES;
    [self empty];
    [self decrementFont];
    } 
    
    //////////////////////////////////////////////////////////////
    //if the string is not empty, the perform the text operations
    //as usual
    else {
    prevStringWasEmpty = NO;
        
    GFont *firstInThisLineChar = nil;
    GFont *firstInNewLineChar = nil;
    int firstInThisLineIndex = 0;

        //reset the old characters
        for(int h=0; h<numToReset; h++) {
            
        //this has the effect of grabbing the [h]th symbol from the array.
        GFont *chr = (GFont *) resetChar;
        resetChar = resetChar.nextSibling;
        
        lastCharacter = chr;
        
        unichar uni = [textString characterAtIndex:h];
            
            if(h == 0) {
            firstInLine = 0;
            firstCharacter = chr;
            }
        
            if(uni == 32) {
            prevSpace = h;
            prevSpaceChar = chr;
            }
            
            //new line character.
            if(uni != '\n') {
            [chr setChr:uni];
            [chr setColor:textColor];
                
            stackX += chr.previousCharacterBuffer;
            
            chr.x = stackX;
            chr.scaleX = fontRatio;
            chr.scaleY = fontRatio;
            chr.y = stackY + chr.correctionY*fontRatio;
            stackX += chr.buffer*fontRatio;
                
                //if we're going to center the characters,
                //then we're going to re-register each character
                //and then shift the x-y position by the same amount
                //this is for text-animations.
                if(centerCharacters) {
                float wDiv2 = chr.width/2;
                float hDiv2 = chr.height/2;
                [chr regX:wDiv2 andY:hDiv2];
                chr.x += wDiv2*fontRatio;
                chr.y += hDiv2*fontRatio;
                }
            
                //make sure that the totalWidth is updated.
                if(stackX > totalWidth) {
                totalWidth = stackX;
                }
            
            chr.visible = YES;
                
                //See the conditional (prevSpace > firstInLine)
                //below for an explanation of this.
                if(h == firstInLine) {
                firstInThisLineChar = chr;
                }
                
                //if we have a text width, then we're going to have to check for an overflow.
                if(textWidth != 0) {
                    
                    if(stackX >= textWidth && singleLine == NO) {
                        
                    //the character which will be last character on this
                    //line after we break the line to maintain the width.
                    int goToPrevious = 0;
                    GFont *goToPrevChar;
                        
                        //if the previous-space is in this line,
                        //then we're going to break it the line on that space-character
                        if(prevSpace > firstInLine) {
                        goToPrevChar = prevSpaceChar;
                        goToPrevious = prevSpace;
                        
                        //we need this firstInNewLine character because each time a new-line is created,
                        //we need to get the first and the last character of the current-line and perform
                        //a shift of the x-coordinates for the case of center-justified text.
                        firstInNewLineChar = (GFont *)prevSpaceChar.nextSibling;
                        firstInLine = prevSpace + 1;
                        }
                        
                        //otherwise, this line has no space and so we're going to insert a dash.
                        //we need at least two characters to exist before the current chr.
                        //there's a lot of rules about breaking lines on dashes, but I'm only going
                        //to say- if there is no space in this line of text, then break it on a dash
                        //http://englishplus.com/grammar/00000129.htm
                        else
                            if(chr.prevSibling) {
                                if(chr.prevSibling.prevSibling) {
                                    
                                //ok so we passed the character-existence requirements. So now: This chr overflows. The previous
                                //one does not. So what we're going to do is put a dash before the *previous* character. Why
                                //that one? See, we don't want the darned DASH character to overflow the width. So we have to kick
                                //both this character and the one before it (if one exists) down to the next line. Just draw it
                                //out on a piece of paper if you don't trust me.
                                goToPrevChar = [[GFont alloc] initFrom:fontTexture andFontMap:fontMap];
                                [self addChild:goToPrevChar before:chr.prevSibling];
                                [goToPrevChar setChr:45];
                                
                                //get the x-coordinate. we have to build it from scratch here because the stackX has gone
                                //past this point.
                                GFont *beforeDash = (GFont *)goToPrevChar.prevSibling;
                                float xCoord = beforeDash.x + beforeDash.buffer*fontRatio + beforeDash.previousCharacterBuffer*fontRatio;
                                
                                //scale and position
                                goToPrevChar.scaleX = fontRatio;
                                goToPrevChar.scaleY = fontRatio;
                                goToPrevChar.x = xCoord;
                                goToPrevChar.y = stackY + goToPrevChar.correctionY*fontRatio;
                                    
                                    //if we're going to center the characters,
                                    //then we're going to re-register each character
                                    //and then shift the x-y position by the same amount
                                    //this is for text-animations.
                                    if(centerCharacters) {
                                    float wDiv2 = goToPrevChar.width/2;
                                    float hDiv2 = goToPrevChar.height/2;
                                    [goToPrevChar regX:wDiv2 andY:hDiv2];
                                    goToPrevChar.x += wDiv2*fontRatio;
                                    goToPrevChar.y += hDiv2*fontRatio;
                                    }
                                
                                //and here's the index where the dash will be residing.
                                //note negative 2. because we're placing this dash 2 characters back.
                                goToPrevious = h - 2;
                                
                                //reset this. this will be the index of the first character in the new line.
                                firstInLine = h - 1;
                                }
                                
                            }
                        
                            /////NEW ///////////
                            if(goToPrevious != 0 && centerJustify) {
                                GFont *loopChar = (firstInThisLineChar) ? firstInThisLineChar : (GFont *)firstCharacter;
                                float xShift = (textWidth - (goToPrevChar.x + goToPrevChar.width - firstInThisLineChar.x))/2;
                                
                                for(int m=firstInThisLineIndex; m<=goToPrevious; m++) {
                                    loopChar.x += xShift;
                                    loopChar = (GFont *)loopChar.nextSibling;
                                }
                            }
                            
                        //See, when a new-line is created, we know its first-character. We need the first character that was created
                        //for THIS line and THAT character was calculated when this line was created. firstInNewLineChar is always
                        //one line ahead of this calculation, so we cache it in this firstInThisLineChar variable so that firstInThisLineChar
                        //points to the correct line.
                        firstInThisLineChar = firstInNewLineChar;
                        firstInThisLineIndex = firstInLine;
                        ////////////////
                        
                        stackX = 0;
                        stackY += chr.uniformHeight*fontRatio*spacing;
                        
                        if(niceWords == YES && goToPrevious != 0) {
                            
                            GFont *loop = goToPrevChar;
                            
                            //Did this [g]th character just overflow past our text-width?
                            //so what we're going to do is we're going to grab the last
                            //space that we encountered back there, and we're going to start looping
                            //from that space up to this [g]th character and start a new line.
                            for(int k=goToPrevious+1; k<=h; k++) {
                                
                                GFont *chr2 = (GFont *)loop.nextSibling;
                                loop = chr2;
                                stackX += chr2.previousCharacterBuffer*fontRatio;
                                chr2.x = stackX;
                                chr2.y = stackY + chr2.correctionY*fontRatio;
                                
                                chr2.scaleX = fontRatio;
                                chr2.scaleY = fontRatio;
                                stackX += chr2.buffer*fontRatio;
                                
                                    //if we're going to center the characters,
                                    //then we're going to re-register each character
                                    //and then shift the x-y position by the same amount
                                    //this is for text-animations.
                                    if(centerCharacters) {
                                    float wDiv2 = chr2.width/2;
                                    float hDiv2 = chr2.height/2;
                                    [chr2 regX:wDiv2 andY:hDiv2];
                                    chr2.x += wDiv2*fontRatio;
                                    chr2.y += hDiv2*fontRatio;
                                    }
                                
                                //make sure that the totalWidth is updated.
                                if(stackX > totalWidth) {
                                    totalWidth = stackX;
                                }
                                
                            }
                            
                        }
                        
                    } else
                        
                    //else, if it hasn't overflowed the width of the text field but we've reached the
                    //last character of the text, then we're going to have to do the same thing as above
                    //for the center-justified text. granb the first-character in this line, the last-character,
                    //calculate a shift and then move everything over.
                    //if(h == outerBound-1 && centerJustify) {
                    if(h == len-1 && centerJustify) {
                        
                        GFont *loopChar = (firstInThisLineChar) ? firstInThisLineChar : (GFont *)firstCharacter;
                        float xShift = (textWidth - (chr.x + chr.width - firstInThisLineChar.x))/2;
                        
                        for(int m=firstInThisLineIndex; m<=(len-1); m++) {
                            loopChar.x += xShift;
                            loopChar = (GFont *)loopChar.nextSibling;
                        }
                        
                    }
                    
                }
                
            }
            
            //else, it was a new-line character
            else {
            
                //if we're supposed to center-justify the text and we have a new-line, then this line
                //has to be center-justified.
                if(centerJustify) {
                    GFont *loopChar = (firstInThisLineChar) ? firstInThisLineChar : (GFont *)firstCharacter;
                    GFont *prevChar = (GFont *)chr.prevSibling;
                    
                    //if there was a previous character- i.e. if we're not looking at the very first character of the text-field.
                    //then get the shift and loop through and shift everything over.
                    if(prevChar) {
                        
                    //Note that we're calculating the shift with the prevChar. Why? because the current chr is
                    //a new-line and it's supposed to be invisible and not really have a width or an x-position.
                    //so it only makes sense to calculate this with the *previous* character.
                    float xShift = (textWidth - (prevChar.x + prevChar.width - firstInThisLineChar.x))/2;
                        
                        for(int m=firstInThisLineIndex; m<h; m++) {
                            loopChar.x += xShift;
                            loopChar = (GFont *)loopChar.nextSibling;
                        }
                        
                    //reset these guys so that the next line will be able to tell what its first-character and first-index will be.
                    //note that in the loop above we excluding g and here we're excluding it as well. Why? Again, because this
                    //is a new-line character. It's supposed to just create a new-line. It's not supposed to have any representation
                    //like coordinates or width. For all intents and purposes, it's invisible.
                    firstInLine = h+1;
                    firstInThisLineIndex = firstInLine;
                    }
                    
                }
                
            [chr setChr:32];
            stackX = 0;
            stackY += chr.uniformHeight*fontRatio*spacing;
            
            }
        }
        
        
        //create the new characters.
        for(int g=numToReset; g<outerBound; g++) {
        unichar uni = [textString characterAtIndex:g];
        GFont *chr = [[GFont alloc] initFrom:fontTexture andFontMap:fontMap];
        lastCharacter = chr;
            
            if(!lineHeightWasSet) {
            lineHeight = chr.uniformHeight*fontRatio*spacing;
            lineHeightWasSet = YES;
            }
            
            if(g == 0) {
            firstCharacter = chr;
            firstInLine = 0;
            }
            
            if(uni == 32) {
            prevSpace = g;
            prevSpaceChar = chr;
            }
        
            //newline character.
            if(uni != '\n') {
            [chr setColor:textColor];
            [self addChild:chr];
            [chr setChr:uni];
                
            stackX += chr.previousCharacterBuffer*fontRatio;
                
                if(stackX < 0) {
                stackX = 0;
                }

            chr.x = stackX;
            chr.scaleX = fontRatio;
            chr.scaleY = fontRatio;

            chr.y = stackY + chr.correctionY*fontRatio;
            stackX += chr.buffer*fontRatio;
                
                //if we're going to center the characters,
                //then we're going to re-register each character
                //and then shift the x-y position by the same amount
                //this is for text-animations.
                if(centerCharacters) {
                float wDiv2 = chr.width/2;
                float hDiv2 = chr.height/2;
                [chr regX:wDiv2 andY:hDiv2];
                chr.x += wDiv2*fontRatio;
                chr.y += hDiv2*fontRatio;
                }
                
                
                //See the conditional (prevSpace > firstInLine)
                //below for an explanation of this.
                if(g == firstInLine) {
                firstInThisLineChar = chr;
                }

                //if we have a text width, then we're going to have to check for an overflow.
                if(textWidth != 0) {
                    
                    if(stackX >= textWidth && singleLine == NO) {
                        
                    //the character which will be last character on this
                    //line after we break the line to maintain the width.
                    int goToPrevious = 0;
                    GFont *goToPrevChar;
                        
                        //if the previous-space is in this line,
                        //then we're going to break the line on that space-character.
                        //We're also going to record the firstInLine index, which is the index of
                        //the first character in the NEW line, and we're going to also record a reference
                        //to the character itself.
                        //We have one edge-case, which is that this the character that pushed us over the edge might be
                        //a space-character. In that case, there will be no "nextSibling" to the prevSpaceChar.
                        //in other words, prevSpace+1 will be beyond "g".
                        if(prevSpace > firstInLine) {
                        goToPrevChar = prevSpaceChar;
                        goToPrevious = prevSpace;
                            
                        //we need this firstInNewLine character because each time a new-line is created,
                        //we need to get the first and the last character of the current-line and perform
                        //a shift of the x-coordinates for the case of center-justified text.
                        firstInNewLineChar = (GFont *)prevSpaceChar.nextSibling;
                        firstInLine = prevSpace + 1;
                            
                        }
                        
                        //otherwise, this line has no space and so we're going to insert a dash.
                        //we need at least two characters to exist before the current chr.
                        //there's a lot of rules about breaking lines on dashes, but I'm only going
                        //to say- if there is no space in this line of text, then break it on a dash
                        //http://englishplus.com/grammar/00000129.htm
                        else
                        if(chr.prevSibling) {
                            if(chr.prevSibling.prevSibling) {
                                
                            //ok so we passed the character-existence requirements. So now: This chr overflows. The previous
                            //one does not. So what we're going to do is put a dash before the *previous* character. Why
                            //that one? See, we don't want the darned DASH character to overflow the width. So we have to kick
                            //both this character and the one before it (if one exists) down to the next line. Just draw it
                            //out on a piece of paper if you don't trust me.
                            goToPrevChar = [[GFont alloc] initFrom:fontTexture andFontMap:fontMap];
                            [self addChild:goToPrevChar before:chr.prevSibling];
                            [goToPrevChar setChr:45];
                                
                            //get the x-coordinate. we have to build it from scratch here because the stackX has gone
                            //past this point.
                            GFont *beforeDash = (GFont *)goToPrevChar.prevSibling;
                            float xCoord = beforeDash.x + beforeDash.buffer*fontRatio + goToPrevChar.previousCharacterBuffer*fontRatio;
                                
                            //scale and position
                            goToPrevChar.scaleX = fontRatio;
                            goToPrevChar.scaleY = fontRatio;
                            goToPrevChar.x = xCoord;
                            goToPrevChar.y = stackY + goToPrevChar.correctionY*fontRatio;
                                
                                //if we're going to center the characters,
                                //then we're going to re-register each character
                                //and then shift the x-y position by the same amount
                                //this is for text-animations.
                                if(centerCharacters) {
                                float wDiv2 = goToPrevChar.width/2;
                                float hDiv2 = goToPrevChar.height/2;
                                [goToPrevChar regX:wDiv2 andY:hDiv2];
                                goToPrevChar.x += wDiv2*fontRatio;
                                goToPrevChar.y += hDiv2*fontRatio;
                                }
          
                            //and here's the index where the dash will be residing.
                            //note negative 2. because we're placing this dash 2 characters back.
                            goToPrevious = g - 2;
                            
                            //reset this. this will be the index of the first character in the new line.
                            firstInLine = g - 1;
                                
                            /////NEW
                            //reset this. this will be the first character of the in the new line.
                            firstInNewLineChar = (GFont *)chr.prevSibling;
                            ///////////////////
                            }
                        
                        }
                        
                    /////NEW ///////////
                        if(goToPrevious != 0 && centerJustify) {
                        GFont *loopChar = (firstInThisLineChar) ? firstInThisLineChar : (GFont *)firstCharacter;
                        float xShift = (textWidth - (goToPrevChar.x + goToPrevChar.width - firstInThisLineChar.x))/2;
                            
                            for(int m=firstInThisLineIndex; m<=goToPrevious; m++) {
                            loopChar.x += xShift;
                            loopChar = (GFont *)loopChar.nextSibling;
                            }
                        }
                        
                    //See, when a new-line is created, we know its first-character. We need the first character that was created
                    //for THIS line and THAT character was calculated when this line was created. firstInNewLineChar is always
                    //one line ahead of this calculation, so we cache it in this firstInThisLineChar variable so that firstInThisLineChar
                    //points to the correct line.
                    firstInThisLineChar = firstInNewLineChar;
                    firstInThisLineIndex = firstInLine;
                    ////////////////
                    

                    stackX = 0;
                    stackY += chr.uniformHeight*fontRatio*spacing;
                    
                        if(niceWords == YES && goToPrevious != 0) {
                        GFont *loop = goToPrevChar;
                        
                            //Did this [g]th character just overflow past our text-width?
                            //so what we're going to do is we're going to grab the last
                            //space that we encountered back there, and we're going to start looping
                            //from that space up to this [g]th character and start a new line.
                            for(int k=goToPrevious+1; k<=g; k++) {
                                
                            GFont *chr3 = (GFont *)loop.nextSibling;
                            loop = chr3;
                            stackX += chr3.previousCharacterBuffer*fontRatio;
                            chr3.x = stackX;
                            chr3.y = stackY + chr3.correctionY*fontRatio;
                            chr3.scaleX = fontRatio;
                            chr3.scaleY = fontRatio;
                            stackX += chr3.buffer*fontRatio;
                                
                                //if we're going to center the characters,
                                //then we're going to re-register each character
                                //and then shift the x-y position by the same amount
                                //this is for text-animations.
                                if(centerCharacters) {
                                float wDiv2 = chr3.width/2;
                                float hDiv2 = chr3.height/2;
                                [chr3 regX:wDiv2 andY:hDiv2];
                                chr3.x += wDiv2*fontRatio;
                                chr3.y += hDiv2*fontRatio;
                                }
                                
                                //make sure that the totalWidth is updated.
                                if(stackX > totalWidth) {
                                totalWidth = stackX;
                                }
                            
                            }
                        
                        }
                    
                    } else
                    
                    //else, if it hasn't overflowed the width of the text field but we've reached the
                    //last character of the text, then we're going to have to do the same thing as above
                    //for the center-justified text. granb the first-character in this line, the last-character,
                    //calculate a shift and then move everything over.
                    if(g == outerBound-1 && centerJustify) {
                        
                    GFont *loopChar = (firstInThisLineChar) ? firstInThisLineChar : (GFont *)firstCharacter;
                    float xShift = (textWidth - (chr.x + chr.width - firstInThisLineChar.x))/2;
                        
                        for(int m=firstInThisLineIndex; m<=(outerBound-1); m++) {
                        loopChar.x += xShift;
                        loopChar = (GFont *)loopChar.nextSibling;
                        }
                        
                    }

                }
            
            //if a unicode newline, then create a new line.
            } else {
                
            [self addChild:chr];
                
                //if we're supposed to center-justify the text and we have a new-line, then this line
                //has to be center-justified.
                if(centerJustify) {
                GFont *loopChar = (firstInThisLineChar) ? firstInThisLineChar : (GFont *)firstCharacter;
                GFont *prevChar = (GFont *)chr.prevSibling;
                    
                    //if there was a previous character- i.e. if we're not looking at the very first character of the text-field.
                    //then get the shift and loop through and shift everything over.
                    if(prevChar) {
                        
                    //Note that we're calculating the shift with the prevChar. Why? because the current chr is
                    //a new-line and it's supposed to be invisible and not really have a width or an x-position.
                    //so it only makes sense to calculate this with the *previous* character.
                    float xShift = (textWidth - (prevChar.x + prevChar.width - firstInThisLineChar.x))/2;
                    
                        for(int m=firstInThisLineIndex; m<g; m++) {
                        loopChar.x += xShift;
                        loopChar = (GFont *)loopChar.nextSibling;
                        }
                        
                    //reset these guys so that the next line will be able to tell what its first-character and first-index will be.
                    //note that in the loop above we excluding g and here we're excluding it as well. Why? Again, because this
                    //is a new-line character. It's supposed to just create a new-line. It's not supposed to have any representation
                    //like coordinates or width. For all intents and purposes, it's invisible.
                    firstInLine = g+1;
                    firstInThisLineIndex = firstInLine;
                    }
                    
                }
                
            stackX = 0;
            stackY += chr.uniformHeight*fontRatio;
            [chr setChr:32]; //a space.
            //[self addChild:chr];
            }
        
        }
    
        
	
        /////////////////////////////////////////////////
        //turn off the old characters that are not used,
        //or delete the ones that are not used.	
        if(stackDeletion == deletionPeriod) {
        stackDeletion = 0;
        
        //GRenderable *tmp = lastCharacter;
        //changed this. it was grabbing the last character no
        //matter what and deleting it.
        GNode *tmp;
            if(lastCharacter) {
            tmp = lastCharacter.nextSibling;
            } else {
            tmp = nil;
            }
        GFont *nxt;
            
            while(tmp) {
            nxt = (GFont *)tmp.nextSibling;
            [tmp destroy];
            tmp = nxt;
            }
    
        } else {
        stackDeletion++;
           
        //GFont *tmp = (GFont *)lastCharacter;
        //changed this. it was grabbing the last character no
        //matter what and hiding it.
        
        GNode *tmp;
            if(lastCharacter) {
            tmp = lastCharacter.nextSibling;
            } else {
            tmp = nil;
            }
            
        GFont *nxt;
            
            while(tmp) {
            nxt = (GFont *)tmp.nextSibling;
            tmp.visible = NO;
            tmp = nxt;
            }
            
        }
        
    }
    
//set the stack widths and heights. the stackY is always missing one line-height,
//but that's why we recorded it already so that we could just use it here.
stackHeight = stackY + lineHeight;
stackWidth = stackX;
prevLength = numChildren;	
}



/**
 * override these accessors.
 *
 */
- (void) setWidth:(float)wdth {
//take no action
}
- (float)width {
    if(singleLine) {
    return stackWidth*scaleX;
    } else {
    return textWidth;
    }
}
- (void) setHeight:(float)hght {
//take no action.
}
- (float) height {
    return stackHeight;
}



/**
 * deallocate. tell the firstChr to release the static arrays,
 * and then kill it.
 *
 */

- (void) releaseResources {
    
    totalNumberOfTextFields--;
    
    if(totalNumberOfTextFields == 0) {
        
        [fontTextures removeAllObjects];
        [fontTextures release];
        fontTextures = nil;
        
        [fontMaps removeAllObjects];
        [fontMaps release];
        fontMaps = nil;
        
        [fontInstances removeAllObjects];
        [fontInstances release];
        fontInstances = nil;
        
    }
   
    if(![text isEqualToString:@""]) {
        [self decrementFont];
    }
    
    [text release];
    
    [super releaseResources];
    
}

/*
- (void) dealloc {
    
totalNumberOfTextFields--;

    if(totalNumberOfTextFields == 0) {
    
    [fontTextures removeAllObjects];
    [fontTextures release];
    fontTextures = nil;
    
    [fontMaps removeAllObjects];
    [fontMaps release];
    fontMaps = nil;
    
    [fontInstances removeAllObjects];
    [fontInstances release];
    fontInstances = nil;
        
    }
 
    if(![text isEqualToString:@""]) {
    [self decrementFont];
    }
 
 [super dealloc];

}
 */




@end


