//
//  GSpriteMap.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/15/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GSpriteMap.h"
#import "Gnarly.h"

@implementation GSpriteMap


static float SCREEN_K; 
static int TEX_WIDTH;
static int TEX_HEIGHT;



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
 * used to set some class properties which are inherited into corresponding private variables
 * by the instances of this class. 
 *
 */
+ (void) setScreenK:(float)k {
SCREEN_K = k;
}
+ (void) setTexWidth:(int)w andHeight:(int)h {
TEX_WIDTH = w;
TEX_HEIGHT = h;
}


/**
 * create the sprite map. perform all of the heavy lifting here so that the
 * frame accessor methods will work brilliantly fast.
 *
 * this came in handy
 * http://www.eskimo.com/~scs/cclass/int/sx9b.html
 *
 */
- (void) setWidth:(float *)wdth
           height:(float *)hght
                x:(float *)xCds
                y:(float *)yCds
           scaleX:(float *)scX
           scaleY:(float *)scY
             regX:(float *)rgX
             regY:(float *)rgY
         rotation:(float *)rot
           length:(int)len {

//set the private variables here.
_screenK = SCREEN_K;
_texWidth = TEX_WIDTH;
_texHeight = TEX_HEIGHT;

//set the scale so that we have the option of
//having screen-independent sprites if we want.
float scale = _screenK;
    

//set the number of frames so that the sprite associated with this map
//will know about it, and also so that the dealloc function will be
//able to clear out the rather sizeable 2 dimensional array.
_numFrames = len;

//create the 2dimensional array, which is an array of pointers.
//the first level needs to contain enough memory to store the
//pointers, so we use float * to calculate the number of bytes.
//the second level stores float values, so we use regular float
//to calculate the number of bytes for each array of frame values.
int numBytesD1 = len * sizeof(float *);
int numBytesD2 = sizeof(float)*20;
_allFrames = malloc(numBytesD1);
    
    float hiResScale = [[Gnar ly] screenHiResScale];
    //0 1 2 3 8 9 10 11

    //loop through and create the 2dimensional frame array.
    //we're doing all the hard work and arithmetic in here 
    //so that the frame accessor functions will work as 
    //fast as possible at render time.
    for(int k=0; k<len; k++) {
    _allFrames[k]  = malloc(numBytesD2);
        
    //LOWE 2014-05-11 RETINA#########
    _allFrames[k][0] = wdth[k]*hiResScale;
    _allFrames[k][1] = hght[k]*hiResScale;
    _allFrames[k][2] = rgX[k]*hiResScale;
    _allFrames[k][3] = rgY[k]*hiResScale;
    //###############################
    //_allFrames[k][0] = wdth[k];
    //_allFrames[k][1] = hght[k];
    //_allFrames[k][2] = rgX[k];
    //_allFrames[k][3] = rgY[k];
    //###############################
        
    _allFrames[k][4] = wdth[k]*scale;
    _allFrames[k][5] = hght[k]*scale;
    _allFrames[k][6] = rgX[k]*scale;
    _allFrames[k][7] = rgY[k]*scale;

    //make the regular coordinate array points
    //LOWE 2014-05-11 RETINA#########
    float _minX = -hiResScale*rgX[k];
    float _minY = -hiResScale*rgY[k];
    //###############################
    //float _minX = -rgX[k];
    //float _minY = -rgY[k];
    //###############################
        
        
    //LOWE 2014-05-11 RETINA#########
    float w = wdth[k]*hiResScale;
    float h = hght[k]*hiResScale;
    //###############################
    //float w = wdth[k];
    //float h = hght[k];
    //###############################

    _allFrames[k][8] = _minX;
    _allFrames[k][9] = _minY + h;
    _allFrames[k][10] = _minY;
    _allFrames[k][11] = _minX + w;
    
    //make the uniform coordinate array points
    float _minX2 = -rgX[k]*scale;
    float _minY2 = -rgY[k]*scale;
    float w2 = wdth[k]*scale;
    float h2 = hght[k]*scale;
    
    _allFrames[k][12] = _minX2;
    _allFrames[k][13] = _minY2 + h2;
    _allFrames[k][14] = _minY2;
    _allFrames[k][15] = _minX2 + w2;
    
    //set the texture vertices.
    //LOWE 2014-05-11 RETINA#########
    float wF = (wdth[k]*hiResScale)/_texWidth;
    float hF = (hght[k]*hiResScale)/_texHeight;
    float xF = (xCds[k]*hiResScale)/_texWidth;
    float yF = (yCds[k]*hiResScale)/_texHeight;
    //###############################
    //float wF = wdth[k]/_texWidth;
    //float hF = hght[k]/_texHeight;
    //float xF = xCds[k]/_texWidth;
    //float yF = yCds[k]/_texHeight;
    //###############################
    
    _allFrames[k][16] = xF;
	_allFrames[k][17] = hF + yF;
	_allFrames[k][18] = yF;
	_allFrames[k][19] = wF + xF;

    }
    
}


- (int) texWidth {
return _texWidth;
}
- (int) texHeight {
return _texHeight;
}
- (void) setTexWidth:(int)tW {
//take no action.
}
- (void) setTexHeight:(int)tH {
//take no action.
}


- (int) numFrames {
return _numFrames;
}
- (void) setNumFrames:(int)n {
//take no action.
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
