//
//  GFontMap.m
//  BraveRocket
//
//  Created by Alexander Lowe on 7/9/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//
// //http://www.joelonsoftware.com/articles/Unicode.html
//
//
// Here are some really handy diagnostic strings:
//
//the ordinary lowercase. These are ones that can sit flush on the bottom because they are flat on the bottom
//textField.text = @"rmnvwxzrvnm";
//
//lowercase with a bottom curve. These guys actually dip a little below the line because they have a curve on the bottom.
//it's just a subtle little aesthetic point with fonts.
//textField.text = @"abcdeosu";
//
//test string for the bottom curve lowercase. You can use this string to eyeball the correction-y to the
//bottom-curve lowercase letters with pure dead reckoning.
//textField.text = @"xaz xbz xcz xdz xez xoz xsz xuz";
//
//Same for upper-case
//textField.text = @"ADEFHIKLMNPRTVWXYZ";
//textField.text = @"CGJOQSU";
//textField.text = @"XCZ XGZ XJZ XOZ XQZ XSZ XUZ";

#import "GFontMap.h"
#import "Gnarly.h"

@implementation GFontMap



/**
 * return a reference to the _allFrames variable. used by GSprite upon instantiation
 * so that it will know about all its frames without having to spend a call in the
 * frame accessor querying the sprite map object.
 *
 */
- (float **) getAllFrames {
    return _allFrames;
}



/**
 * call this function inside init to set all of the arrays and whatnot.
 *
 */
/*
- (void) setWidth:(float *)widths height:(float *)heights x:(float *)xCoords y:(float *)yCoords yCorrection:(float *)correctionY defaultYPosition:(int *)defaultYPos kerning:(float)kern lineHeight:(float)lineHeight length:(int)len {
    
    _numFrames = len;
    
    _kerning = kern;
    
    int numBytesD1 = len * sizeof(float *);
    int numBytesD2 = sizeof(float)*5;
    _allFrames = malloc(numBytesD1);
    
    for(int k=0; k<len; k++) {
    _allFrames[k]  = malloc(numBytesD2);

    _allFrames[k][0] = widths[k];
    _allFrames[k][1] = heights[k];
    _allFrames[k][2] = xCoords[k];
    _allFrames[k][3] = yCoords[k];
    _allFrames[k][4] = correctionY[k];
    }
    
}
*/

/*
 
 //the default y-coordinate of this character.
 //0 means the top of the line. (think ")
 //1 means it'll be centered vertically. (think -)
 //2 means the bottom - character-height. Handy for lowercase letters, which have subtly different heights but should all be about flush to the bottom.
 
 */
- (void) setWidth:(float *)widths height:(float *)heights x:(float *)xCoords y:(float *)yCoords
      yCorrection:(float *)correctionY defaultYPosition:(int *)defaultYPos
        kerning:(float)kern lineHeight:(float)lineHeight length:(int)len {
    
    _numFrames = len;
    
    _kerning = kern;
    
    int numBytesD1 = len * sizeof(float *);
    int numBytesD2 = sizeof(float)*5;
    _allFrames = malloc(numBytesD1);
    

    for(int k=0; k<len; k++) {
        _allFrames[k]  = malloc(numBytesD2);
        
        _allFrames[k][0] = widths[k];
        _allFrames[k][1] = heights[k];
        _allFrames[k][2] = xCoords[k];
        _allFrames[k][3] = yCoords[k];
        
        int defaultYPosMode = defaultYPos[k];
        float corrY = correctionY[k];
    
        
            //if 1, then we're going to make the default y-position such that the character's
            //bottom edge if flush with the bottom of the line, and the correction-y will add onto that default position.
            if(defaultYPosMode == 1) {
            corrY = corrY + (lineHeight -  heights[k])/2;
            //corrY = corrY + lineHeight - heights[k];
            }
        
            //if 2, then the default y-position will be such that the character is placed vertically aligned in the middle
            //of the line and the correction-y will add onto that default position.
            else
            if(defaultYPosMode == 2) {
            corrY = corrY + lineHeight - heights[k];
            //corrY = 42;// corrY + (lineHeight -  heights[k])/2;
            //NSLog(@"defaultYPosMode == 2: corrY: %f%@%i",corrY,@" index:",k);
            }
        
            else {
            corrY = corrY;
            } 
        
        
        
        //NSLog(@"corrY: %f%@%i%@%i",corrY,@" index:",k,@" defaultYPosMode:",defaultYPosMode);
        
        //_allFrames[k][4] = correctionY[k];
    _allFrames[k][4] = corrY;
    }
    
}

- (float *) getFrameFromMappedEncoding:(int)encoded {
return _allFrames[encoded];
}



/**
 * take the unicode character and return the index to the array. You can cut it up any way you like.
 * See http://unicode-table.com/en/
 */
- (int) calculateEncoding:(int)uni {
int u = uni;
    
    //there isn't anything before unicode 32. so we start the geometric arrays at character 32.
    //So 32 is the space character but the arrays START right there so 32 is the 0th element.
    //so we're going to just shave off 32 right here.
    u -= 32;
    
    //8217 is the right single quotation make. I'm sure there will
    //be other special cases to accomadate here. I chose to place
    //the lionshare of the characters in the arrays for performance sake,
    //instead of having giant piles of conditionals here.
    if(uni == 8217) {
        u = 7;
    }
    
    //here's the degree symbol. there's a big blank stretch between the } character (u=93) and the degree character.
    if(uni == 176) {
        u = 94;
    }
    
return u;
}



- (float) calculateBufferForCurrentCharacter:(int)currentUnicode andPreviousCharacter:(int)prevUnicode {
    return 0;
}





- (int) numFrames {
    return _numFrames;
}
- (void) setNumFrames:(int)n {
    //take no action.
}

- (float) kerning {
    return _kerning;
}
- (void) setKerning:(float)k {
    //take no action
}


/**
 * cleanup
 *
 */
- (void) dealloc {
    
    //have to loop through the frames and destroy
    //them individually. freeing the array itself
    //prematurely will only eliminate the array
    //of pointers, but leave the blocks of memory
    //allocated for each frame still intact.
    for(int i=0; i<_numFrames; i++) {
        free(_allFrames[i]);
    }
    
    //death.    
    free(_allFrames);
    
    //more death.
    [super dealloc];
    
}


@end
