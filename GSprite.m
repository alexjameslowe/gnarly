//
//  Box.m
//  reboot_2
//
//  Created by Alexander  Lowe on 6/24/09.
//  Copyright 2009. See Licence.
//

#import "GSprite.h"
#import "GAtlas.h"
#import "GSpriteMap.h"
#import "GTexture.h"
#import "GSurface.h"
#import "GExistence.h"

#import "GEvent.h"





@implementation GSprite

static int boundTexInd=-1;
static BOOL removeFromCausalChain = YES;

//static BOOL *existenceArray;
//static int currentExistenceRegime = 0;
//static int currentExistenceCount;

static GSpriteMap *_cachedMap;
static GSpriteMap *_firstMap;
static GSpriteMap *_useMap;

static GTexture *_cachedTexture;
static GTexture *_firstTexture;
static GTexture *_useTexture;

static GAtlas *_cachedAtlas;
static GAtlas *_firstAtlas;
static GAtlas *_useAtlas;

static BOOL _useCachedOrFirst = NO;
static BOOL _atlasSpecified = NO;

@synthesize numFrames;

@synthesize temporal_willSpriteNotifyOfDestruction;




/**
 * A convenience function to init a sprite. use the GSprite's useLastAtlas/useFirstAtlas functions procedurally to 
 * guide how this function fires.
 *
 * If 
 *
 * [GSprite useFirstAtlas]
 * GSprite *sp = [[GSprite alloc] init]
 * 
 * then, the sprite will use the first map and texture. else, if 
 *
 * [GSprite useLastAtlas]
 * GSprite *sp = [[GSprite alloc] init]
 *
 * the sprite will use the last map and texture pair that was loaded.
 *
 * if you use the procedural + (void) useTexture:(NSString *)tex andMap:(NSString *)map function,
 * it will override either of these two options.
 *
 * the default behavior is to useTheFirstAtlas.
 *
 * This will throw an error if the key does not correspond to texture data.
 *
 */
- (id) init:(NSString *)key {
    
    self = [super init];
    
    isSpriteDesroyed = NO;

        if(!key) {

            if(_atlasSpecified == YES) {
            
            textureObject = _useTexture;
            spriteMap = _useMap;
            
            } else {
        
                if(_useCachedOrFirst == YES) {
                textureObject = _cachedTexture;
                spriteMap = _cachedMap;
                } else {
                textureObject = _firstTexture;
                spriteMap  = _firstMap;
                }
            
            }
        
        } else {
            
        //NSLog(@"[GSurface getCurrentView]: %@",[GSurface getCurrentView]);
        
        GAtlas *at = [[GSurface getCurrentView] getAtlas:key];
        atlasObject = at;
        textureObject = at.texture;
        spriteMap = at.map;
        _useTexture = textureObject;
        _useMap = spriteMap;
        _useAtlas = atlasObject;
        _atlasSpecified = YES;
            
        
        }
        
    _key = key;
    
        if(!textureObject) {
            
        NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
        // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
        NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
        NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
        [array removeObject:@""];
        
        //NSLog(@"Caller: %@",[self findCallerMethod]);
        NSLog(@"Stack = %@", [array objectAtIndex:0]);
        NSLog(@"Framework = %@", [array objectAtIndex:1]);
        NSLog(@"Memory address = %@", [array objectAtIndex:2]);
        NSLog(@"Class caller = %@", [array objectAtIndex:3]);
        NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    
        [NSException raise:@"Error: GSprite -> init" format:@"The key '%@%@",_key,@"' does not correspond to texture data."];
        return nil;
        }

    numFrames = spriteMap.numFrames;
    
    texInd = textureObject.uID;
    
    GLuint *pointer = textureObject.address;
    texData = *pointer;
    
    //set the allFrames variable, which is a
    //2 dimensional C array of floats.
    _allFrames = [spriteMap getAllFrames];
    	
	textureVertices = [GSprite setTexVertsWidth:textureObject.textureWidth height:textureObject.textureHeight viewWidth:10 viewHeight:10];
	[self rectWidth:10 andHeight:10];
	[self regX:0 andY:0];
	
	numberOfVertices = 4;
	
	_minX = 0;
	_minY = 0;
	
    _width  = 10;
	_height = 10;
		
//return [super init];
    return self;
}



- (GNode *)clone {
    GSprite *sp = [[GSprite alloc] init:_key];
    sp.frame = self.frame;
    sp.scaleX = scaleX;
    sp.scaleY = scaleY;
    sp.x = x;
    sp.y = y;
    sp.rotation = rotation;
    sp.color = self.color;
    sp.opacity = self.opacity;
    return sp;
}



+ (void) setRemoveFromCausalChainOnDestruction:(BOOL)yesOrNo {
removeFromCausalChain = yesOrNo;
}


/**
 * you have to use the procedural useAtlas function before you init sprites this way or
 * you're going to have white blocks instead of textured objects.
 *
 */
- (id) init {
return [self init:nil];
}


/**
 * we use a comparison of the texInd to the boundTexInd in the render function of this
 * class to determine whether or not we need to bind a new block of texture data to render
 * a different texture. There's some overhead involved in the binding process, so we don't
 * do it unless we need to. for example, if there's just a single texture for all of your
 * sprites, then it's a waste of time to bind the texture data more than once.
 *
 * However, if the rendering gets to a new texture, then the texture data is going to be re-bound.
 * Also, loading textures in the background will require a rebinding of the texture data, or
 * stuff might get screwed up. (See EAGLSharegroup for more info)
 * It is this last requirement that this function is supposed to satisfy. When a new texture 
 * gets loaded, we're going to have to update the boundTexInd variable to force a rebind of 
 * the texture data the very next time any GSprite's render function gets called.
 */
+ (void) newTextureRequiresBoundIndexUpdate:(int)newInt {
boundTexInd = newInt;
}
+ (int) getBoundTextInt {
    return boundTexInd;
}


/**
 * This is used in the text classes. Does 
 *
 */
+ (void) setBoundTexIndManually:(int)newInt {
boundTexInd = newInt;
}


/**
 * set the cached and first pair or textures and maps so that two specialized init functions
 * can make use of this information quickly to get sprites off the ground without a whole 
 * bunch of calling to the surface object.
 *
 */
+ (void) setFirstAtlas:(GAtlas *)fAtlas andCachedAtlas:(GAtlas *)cAtlas {
_firstTexture = fAtlas.texture;
_cachedTexture = cAtlas.texture;
_firstMap = fAtlas.map;
_cachedMap = cAtlas.map;
_firstAtlas = fAtlas;
_cachedAtlas = cAtlas;
}


/**
 * use these hooks procedurally before you instantiate sprite object to 
 * control how the init function behaves- whether it takes the atlas
 * data as the first loaded pair or the last loaded pair.
 *
 */
+ (void) useLastAtlas {
_atlasSpecified = NO;
_useCachedOrFirst = YES;
}
+ (void) useFirstAtlas {
_atlasSpecified = NO;
_useCachedOrFirst = NO;
}
+ (void) useAtlas:(NSString *)key {
_atlasSpecified = YES;
GAtlas *at = [[GSurface getCurrentView] getAtlas:key];
_useTexture = at.texture;
_useMap = at.map;
_useAtlas = at;
}



/***
 * reset the dimensions of this object. handy to use this once before calling goToFrameX:andY:
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



/***
 * the main rendering code.
 *
 */
- (GRenderable *) render {

	glPushMatrix();
    
        //don't bind the texture if we don't need to.
        if(texInd != boundTexInd) {
        boundTexInd = texInd;
        glBindTexture(GL_TEXTURE_2D, texData);
	    }
    
       
        if(opacity < 1) {
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
        glColor4f(red, green, blue, opacity);
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
        

	 //If this object has children, then leave it up to the popper to call the popMatrix function.
		//if(usePopper == NO) {
        //NSLog(@"POP1 %@",name);
		//glPopMatrix();
		//}
        
        if(totalWatchTouches == YES) {
        [self testTouchMovedEnded];
        }
        
    return next;
    
   // } else {
    
   // return [self getNext];
    
   // }

}



/***
 * sets the texture vertices specifically to deal with the
 * irritating power-of-two rule.
 */
+ (GLfloat *) setTexVertsWidth:(NSInteger)fullWidth height:(NSInteger)fullHeight viewWidth:(int)partialWidth viewHeight:(int)partialHeight {
	GLfloat *newVerts = (GLfloat*) malloc(sizeof(GLfloat)*(8));
	float widthFraction  = partialWidth  / (float)fullWidth;
	float heightFraction = partialHeight / (float)fullHeight;
	
        //bottom left
		newVerts[0] = 0;
		newVerts[1] = heightFraction;
    
        //top left
		newVerts[2] = 0;
		newVerts[3] = 0;
    
        //top right
		newVerts[4] = widthFraction;
		newVerts[5] = 0;
    
        //bottom right
	    newVerts[6] = widthFraction;
		newVerts[7] = heightFraction;  
	
	return newVerts;
}



/***
 * allows the programmer to change the texture vertices at run-time.
 *
 */
- (void) resetTexVertsWidth:(NSInteger)fullWidth height:(NSInteger)fullHeight viewWidth:(int)pWdth viewHeight:(int)pHght X:(float)xCrd Y:(float)yCrd {

float widthFraction  = pWdth  / (float)fullWidth;
float heightFraction = pHght / (float)fullHeight;

float xFrac = xCrd / (float)fullWidth;
float yFrac = yCrd / (float)fullHeight;

    //bottom left
	textureVertices[0] = xFrac;
	textureVertices[1] = heightFraction + yFrac;
    
    //top left
	textureVertices[2] = xFrac;
	textureVertices[3] = yFrac;
    
    //top right
	textureVertices[4] = widthFraction + xFrac;
	textureVertices[5] = yFrac;
    
    //bottom right
	textureVertices[6] = widthFraction + xFrac;
	textureVertices[7] = heightFraction + yFrac; 

}


///////////////
//           //
//   A P I   //
//           //
///////////////


/***
 * seeks to the [index]th frame registered in the sprite map. wondefully minimal code. No arithmetic
 * or objective C calls. This is one of the functions that has to go *fast*.
 *
 * This one does a little bit of checking to make sure that the frame index is sane. It will
 * wrap it around if it's negative, and throw an error if it's insane.
 *
 */
- (void) goTo:(int)index {
    
    if(isUnglued) {
    return;
    }
    
    //this is a booby trap to try and see if this thing is throwing an
    //fit over the sprite map being dealloced.
    if(spriteMap) {
    //
    }

    if(index < 0) {
    index = numFrames + index;
    }
    
    if(isnan(index) || index < 0 || index >= numFrames) {
    [NSException raise:@"Error: GSprite -> init" format:@"The index is either NaN or out of bounds. index= %i%@%i",index,@" numFrames=",numFrames];
    return;
    }


_frame = index;

float *frm = _allFrames[index];

    numberOfVertices = 4;    
   
        //if(useUniformDimensions == NO) {
    
        _width  = frm[0];
        _height = frm[1];
        _minX = -frm[2];
        _minY = -frm[3]; 
        bnds = CGRectMake(_minX, _minY, _width, _height);
           
        coordVertices[0] = frm[8];  //_minX;
        coordVertices[1] = frm[9];  //_minY + height;
        
        coordVertices[2] = frm[8];  //_minX;
        coordVertices[3] = frm[10]; //_minY;
        
        coordVertices[4] = frm[11];//_minX + width;
        coordVertices[5] = frm[10]; //_minY;
        
        coordVertices[6] = frm[11]; //_minX + width;
        coordVertices[7] = frm[9];  //_minY + height;
    
       // } else {
            
       // _width  = frm[4];
       // _height = frm[5];
       // _minX = -frm[6];
       // _minY = -frm[7];
       // bnds = CGRectMake(_minX, _minY, _width, _height);
        
       // coordVertices[0] = frm[12]; //_minX;
       // coordVertices[1] = frm[13]; //_minY + _height;
        
       // coordVertices[2] = frm[12]; //_minX;
       // coordVertices[3] = frm[14]; //_minY;
        
       // coordVertices[4] = frm[15]; //_minX + _width;
       // coordVertices[5] = frm[14]; //_minY;
        
       // coordVertices[6] = frm[15]; //_minX + _width;
       // coordVertices[7] = frm[13]; //_minY + _height;
        
       // }
    
    //bottom left
    textureVertices[0] = frm[16];
	textureVertices[1] = frm[17];
	
    //top left
    textureVertices[2] = frm[16];
	textureVertices[3] = frm[18];
	
    //top right
    textureVertices[4] = frm[19];
	textureVertices[5] = frm[18];
	
    //bottom right
    textureVertices[6] = frm[19];
	textureVertices[7] = frm[17];
    
}



/**
 * exact duplicate of the goTo functions. could call it here but why not
 * just copy the code and avoid the extra objective c message?
 *
 */
-(void) setFrame:(int)f {
    
_frame = f;
    
    if(isUnglued) {
    return;
    }
    
    //this is a booby trap to try and see if this thing is throwing an
    //fit over the sprite map being dealloced.
    if(spriteMap) {
    //
    }

float *frm = _allFrames[f];

    numberOfVertices = 4;    
   
        //if(useUniformDimensions == NO) {
        _width  = frm[0];
        _height = frm[1];
        _minX = -frm[2];
        _minY = -frm[3]; 
        bnds = CGRectMake(_minX, _minY, _width, _height);
    
        coordVertices[0] = frm[8];  //_minX;
        coordVertices[1] = frm[9];  //_minY + height;
        coordVertices[2] = frm[8];  //_minX;
        coordVertices[3] = frm[10]; //_minY;
        coordVertices[4] = frm[11]; //_minX + width;
        coordVertices[5] = frm[10]; //_minY;
        coordVertices[6] = frm[11]; //_minX + width;
        coordVertices[7] = frm[9];  //_minY + height;
    
        //} else {
        //_width  = frm[4];
        //_height = frm[5];
        //_minX = -frm[6];
        //_minY = -frm[7];
        //bnds = CGRectMake(_minX, _minY, _width, _height);
        
       // coordVertices[0] = frm[12]; //_minX;
       // coordVertices[1] = frm[13]; //_minY + _height;
       // coordVertices[2] = frm[12]; //_minX;
       // coordVertices[3] = frm[14]; //_minY;
       // coordVertices[4] = frm[15]; //_minX + _width;
       // coordVertices[5] = frm[14]; //_minY;
       // coordVertices[6] = frm[15]; //_minX + _width;
       // coordVertices[7] = frm[13]; //_minY + _height;
        
       // }
        
    textureVertices[0] = frm[16];
	textureVertices[1] = frm[17];
	textureVertices[2] = frm[16];
	textureVertices[3] = frm[18];
	textureVertices[4] = frm[19];
	textureVertices[5] = frm[18];
	textureVertices[6] = frm[19];
	textureVertices[7] = frm[17];
}
- (int) frame {
return _frame;
}



/**
 * return the key for the atlas
 *
 */
- (NSString *) key {
    return _key;
}
- (void) setKey:(NSString *)k {
    //take no action
}





/**
 * free the texture vertices
 *
 */
- (void) releaseResources {
    
    if(temporal_willSpriteNotifyOfDestruction) {
    GEvent *destroy = [[GEvent alloc] init:@"SPRITE_WAS_DESTROYED" bubbles:YES];
    [root dispatch:destroy];
    }
    
free(textureVertices);
[super releaseResources];
}


@end
