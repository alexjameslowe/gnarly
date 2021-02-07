//
//  GFont.m
//  CosmicDolphin_7_5
//
//  Created by Alexander  Lowe on 3/24/13.
//  Copyright (c) 2013 Alex Lowe. See Licence.
//


#import "GFont.h"
#import "GTexture.h"
#import "GSprite.h"
#import "GRenderable.h"
#import "GSprite.h"
#import "GFontMap.h"

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//  The basic character class                                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////


@implementation GFont

@synthesize buffer, puncBuffer, uniformHeight;
@synthesize correctionY;
@synthesize previousCharacterBuffer;
@synthesize unicode, arrayIndex;
static int boundTexInd=-1;


//static int numInst = 0;


/**
 * init with a texture
 *
 */
- (id) initFrom:(GTexture *)tex andFontMap:(GFontMap *)fMap {
    
self = [super init];
    
//numInst++;
//NSLog(@"GFont: number of instances: %i",numInst);
    
fontMap = fMap;

uniformHeight = 70;
    
previousCharacterBuffer = 0;

GLuint *pointer = tex.address;
texData = *pointer;

textureVertices = [GSprite setTexVertsWidth:tex.textureWidth height:tex.textureHeight viewWidth:10 viewHeight:10];
[self rectWidth:10 andHeight:10];
[self regX:0 andY:0];
	
numberOfVertices = 4;

visible = YES;

texInd = tex.uID;
    
_minX = 0;
_minY = 0;

return self;

}

+ (void) setBoundTexIndManaully:(int)ind {
boundTexInd = ind;
}



/***
 * reset the dimensions of this object. 
 *
 */
- (void) resetCellDimsWidth:(int)w andHeight:(int)h {
    
    _width  = w;
    _height = h;
    
    coordVertices[0] = _minX;
    coordVertices[1] = _minY + h;
    coordVertices[2] = _minX;
    coordVertices[3] = _minY;
    coordVertices[4] = _minX + w;
    coordVertices[5] = _minY;
    coordVertices[6] = _minX + w;
    coordVertices[7] = _minY + h;
    
}
/*
 
 - (void) regX:(float)regX andY:(float)regY {
 
 _minX = -regX;
	_minY = -regY;
 
 //if(!coordVertices) {
 //coordVertices = (GLfloat*) malloc(sizeof(GLfloat)*(8));
 //}
 
 bnds = CGRectMake(_minX, _minY, _width, _height);
 
 numberOfVertices = 4;
 
	coordVertices[0] = _minX;
	coordVertices[1] = _minY + _height;
	coordVertices[2] = _minX;
	coordVertices[3] = _minY;
	coordVertices[4] = _minX + _width;
	coordVertices[5] = _minY;
	coordVertices[6] = _minX + _width;
	coordVertices[7] = _minY + _height;
 
 }
 
 */


/***
 * allows the programmer to change the texture vertices at run-time.
 *
 *  ### NOTE ###
 *  This function does not function in Portrait mode. 
 *
 */
- (void) resetTexVertsWidth:(NSInteger)fullWidth height:(NSInteger)fullHeight viewWidth:(int)pWdth viewHeight:(int)pHght X:(float)xCrd Y:(float)yCrd {
    
    float widthFraction  = pWdth  / (float)fullWidth;
    float heightFraction = pHght / (float)fullHeight;
    
    float xFrac = xCrd / (float)fullWidth;
    float yFrac = yCrd / (float)fullHeight;
    
	textureVertices[0] = xFrac;
	textureVertices[1] = heightFraction + yFrac;
	textureVertices[2] = xFrac;
	textureVertices[3] = yFrac;
	textureVertices[4] = widthFraction + xFrac;
	textureVertices[5] = yFrac;
	textureVertices[6] = widthFraction + xFrac;
	textureVertices[7] = heightFraction + yFrac; 
    
}




/**
 * take the unicode integer and make this character light up with the corresponding textured
 * character with all of the kerning and whatnot.
 *
 * this is a good source for this:
 * http://www.joelonsoftware.com/articles/Unicode.html
 *
 */
- (void) setChr:(int)uni {
    
    //set the unicode.
    int u = uni;
    unicode = u;
    
    //we take the crazy unicode integer and we filter it down to the compressed array integer
    u = [fontMap calculateEncoding:u];
    arrayIndex = u;
    
    //then we get the previous sibling
    GFont *f = (GFont *)prevSibling;
    
    //and we get the 'retroactive' buffer from the previous character. i.e. if we have "A" and the previous
    //character is "V" then we might want to move "A" just a little bit farther away to enforce some space with "V"
    //previousCharacterBuffer = [fontMap calculateBufferForCurrentCharacter:u andPreviousCharacter:f.unicode];
    previousCharacterBuffer = [fontMap calculateBufferForCurrentCharacter:uni andPreviousCharacter:f.unicode];
    
    //get the frame, cache the width and height
    float* frame = [fontMap getFrameFromMappedEncoding:u];
    float width = frame[0];
    float height = frame[1];
    
    //reset these guys to zero before the next call.
    _minX = 0;
    _minY = 0;
    
    //and then reset the dimesions and texture coordinates of this object.
    [self resetCellDimsWidth:width andHeight:height];
    [self resetTexVertsWidth:512 height:512 viewWidth:width viewHeight:height X:frame[2] Y:frame[3]];

    //set the buffer and the the correction-y.
    buffer = self.width + [fontMap kerning];

    correctionY = frame[4];
    
}

/*
- (void) setChr:(int)uni {
//http://www.joelonsoftware.com/articles/Unicode.html
int u = uni;
unicode = u;
    
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
    
previousCharacterBuffer = 0;
    
    NSLog(@"Unicode: %i%@%i",uni,@"  u:",u);
    
    //we have some annoying things in here: certain combinations
    //of character look just horrible. the spacing is wrong we have another
    //corrective buffer to retroactively adjust the stackX of the GTextField so
    //that this letter has nice-looking spacing.
    if(u == 65 || u == 84 || u == 86 || u == 89) {

    GFont *f = (GFont *)prevSibling;
        
        if(f) {
        
        int prevUnicode = f.unicode;
            
        //NSLog(@"?????? %i%@%i",prevUnicode,@"  u:",u);
            
            //if YA
            if(u == 65 && prevUnicode == 89) {
            previousCharacterBuffer = -5;
            }
            
            //if AY
            else
            if(u == 89 && prevUnicode == 65) {
            previousCharacterBuffer = -5;
            }
            
            //if AT
            else
            if(u == 65 && prevUnicode == 84) {
            previousCharacterBuffer = -5;
            }
            
            //if TA
            else
            if(u == 84 && prevUnicode == 65) {
            previousCharacterBuffer = -5;
            }
            
            //if AV
            else
            if(u == 65 && prevUnicode == 86) {
            previousCharacterBuffer = -5;
            }

            //if VA
            else
            if(u == 86 && prevUnicode == 65) {
            previousCharacterBuffer = -5;
            }
            
        }
        
    }
    
    //if(prevSibling)
 
    //u = 48;
    
    //NSLog(@"unicode: %i",u);
    //NSLog(@"widths: %i",widths[u]);
    //NSLog(@"heights: %i",heights[u]);
    //NSLog(@"cartX: %i",cartX[u]);
    //NSLog(@"cartY: %i",cartY[u]);
    

[self resetCellDimsWidth:widths[u] andHeight:heights[u]];
[self resetTexVertsWidth:512 height:512 viewWidth:widths[u] viewHeight:heights[u] X:cartX[u] Y:cartY[u]];
    
//    [self resetCellDimsWidth:512 andHeight:512];
//    [self resetTexVertsWidth:512 height:512 viewWidth:512 viewHeight:512 X:0 Y:0];

    buffer = self.width + bffrs[u]*_screenHiResScale;
puncBuffer = bffrs2[u];
correctionY = corrY[u];

}
*/



/***
 * the main rendering code.
 *
 */
- (GRenderable *) render {
    
float alpha = opacity*parent.opacity;    
glPushMatrix();
    
    //NSLog(@"alpha: %f",alpha);
    
    /*
    if(visible) {
        
        if(texInd != boundTexInd) {
        boundTexInd = texInd;
        glBindTexture(GL_TEXTURE_2D, texData);
	    }
        
    glColor4f(red, green, blue, alpha);     
    glTranslatef(x, y, 0);
    glRotatef(rotation, 0.0, 0.0, 1.0); 
    glScalef(scaleX, scaleY, 1.0);
    glVertexPointer(2, GL_FLOAT, 0, coordVertices);
    
    glTexCoordPointer(2, GL_FLOAT, 0, textureVertices);      
    glDrawArrays(GL_TRIANGLE_FAN, 0, numberOfVertices);
    
    }*/
    
    if(visible) {
    
        if(texInd != boundTexInd) {
            boundTexInd = texInd;
            glBindTexture(GL_TEXTURE_2D, texData);
        }
        
        if(alpha < 1) {
            
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            glColor4f(red, green, blue, alpha);
            glTranslatef(x, y, 0);
            glRotatef(rotation, 0.0, 0.0, 1.0);
            glScalef(scaleX, scaleY, 1.0);
            glVertexPointer(2, GL_FLOAT, 0, coordVertices);
            
            glTexCoordPointer(2, GL_FLOAT, 0, textureVertices);
            // glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            
            glDrawArrays(GL_TRIANGLE_FAN, 0, numberOfVertices);
            
            // glDisableClientState(GL_TEXTURE_COORD_ARRAY);
            // glDisable(GL_TEXTURE_2D);
            
            glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
            
        } else {
            
            glColor4f(red, green, blue, 1.0f);
            glTranslatef(x, y, 0);
            glRotatef(rotation, 0.0, 0.0, 1.0);
            glScalef(scaleX, scaleY, 1.0);
            glVertexPointer(2, GL_FLOAT, 0, coordVertices);
            
            glTexCoordPointer(2, GL_FLOAT, 0, textureVertices);
            // glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            
            glDrawArrays(GL_TRIANGLE_FAN, 0, numberOfVertices);
            
            // glDisableClientState(GL_TEXTURE_COORD_ARRAY);
            //glDisable(GL_TEXTURE_2D);
            
        }
        
    }

	
        //If this object has children, then leave it up to the popper to call the popMatrix function.
		//if(usePopper == NO) {
		//glPopMatrix();
		//}
  
    return next;
}


/**
 * release the texture vertices before we deallocate.
 *
 */
- (void) releaseResources {
    free(textureVertices);
    textureVertices = nil;
    [super releaseResources];
}


//- (void) dealloc {
//    numInst--;
//  NSLog(@"dealloc: numInst: %i",numInst);
//    [super dealloc];
//}




@end
