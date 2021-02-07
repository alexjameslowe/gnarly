//
//  Box.m
//  reboot_2
//
//  Created by Alexander  Lowe on 6/24/09.
//  Copyright 2009. See Licence.
//


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                         //
//  Box.                                                                                                   //        
//  The main unit of the Gnarly framework. A platform for generating 2D display objects whose memory       //
//  is managed by the GSurface class. Performs display list logic, collision detection, touch detection,   //
//  line-of-sight, event listening/dispatching and animation.                                              //
//                                                                                                         //                                                                                               
/////////////////////////////////////////////////////////////////////////////////////////////////////////////



#import "GBox.h"

@implementation GBox


//core
@synthesize _minX,_minY;

@synthesize uId;


 /**
  * the init method.
  */
  
  - (id) init {
  
  self = [super init];
  
  _minX = 0;
  _minY = 0;
  numberOfVertices = 4;
  
  coordVertices = (GLfloat*) malloc(sizeof(GLfloat)*(8));
  coordVertices[0] = 1;
  coordVertices[1] = 1;
  coordVertices[2] = 1;
  coordVertices[3] = 1;
  coordVertices[4] = 1;
  coordVertices[5] = 1;
  coordVertices[6] = 1;
  coordVertices[7] = 1;
  
  [self setColor:0xFFFFFF];
  
  return self;

  }





////////////
// Render //
////////////


/***
 * the main rendering code.
 */

- (GRenderable *) render {

  //  if(parent) {


    //TODO- should be a compiler setting to specify it opacity should inherit from the parent.
	float alpha = opacity*parent.opacity;
	
	/////////////// masking stuff ///////////////////
	
	/// heartbreaking- this works perfectly well, but not on
	// the iPod touch.
	//glEnable( GL_STENCIL_TEST ); 
	//glClearStencil( 0x0); 
	//glStencilFunc( GL_NEVER, 0x0, 0x0 );
	//glStencilOp(GL_INCR, GL_INCR, GL_INCR);

	////////////////////////////////////////////////
    
        //NSLog(@"NAME2: %@%@%i",name,@"  ",numberOfVertices);
    
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY); 
    
    //NSLog(@"PUSH %@",name);
	glPushMatrix();
    
        if(opacity < 1) {
        //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        }
	  
	  //using OpenGL API might be a little faster than doing the
	  //arithmetic in this case.
	  //http://nehe.gamedev.net/data/lessons/lesson.asp?lesson=44
	  //http://www.gamedev.net/topic/594833-glgetfloatvenum4x4farr-funny-business-bug/
	  //GLfloat Matrix[16];
	  //glGetFloatv(GL_MODELVIEW_MATRIX, Matrix);
	  //glReadPixels
	  //http://msdn.microsoft.com/en-us/library/ms537248
	      
	glColor4f(red, green, blue, alpha);
	glTranslatef(x, y, 0);
	glRotatef(rotation, 0.0, 0.0, 1.0); 
	glScalef(scaleX, scaleY, 1.0);
	glVertexPointer(2, GL_FLOAT, 0, coordVertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, numberOfVertices);
    
        //If this object has children, then leave it up to the popper to call the popMatrix function.
		//if(usePopper == NO) {
        //NSLog(@"POP1 %@",name);
		//glPopMatrix();
		//}
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY); 
    glEnable(GL_TEXTURE_2D);
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);  


    return [super render];
    
  //  } else {
  //  return [self getNext];
  //  }
    
}




/////////////
//         //
//  A P I  //
//         //
/////////////


- (void)resetScrollingShit {}

/***
 * a handy method so the programmer can reset the registration point on the fly.
 *
 */
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




/**
 * makes this box a rectangle of width w and height h.
 *
 */
- (void) rectWidth:(float)w andHeight:(float)h {
_width = w;
_height = h;
bnds = CGRectMake(_minX, _minY, _width, _height);

    //if(!coordVertices) {
    //coordVertices = (GLfloat*) malloc(sizeof(GLfloat)*(8));
    //}
    
coordVertices[0] = _minX;
coordVertices[1] = _minY + h;
coordVertices[2] = _minX;
coordVertices[3] = _minY;
coordVertices[4] = _minX + w;
coordVertices[5] = _minY;
coordVertices[6] = _minX + w;
coordVertices[7] = _minY + h;
numberOfVertices = 4;
}


- (void) rectWidth:(float)w andHeight:(float)h color:(int)hex {
_width = w;
_height = h;
bnds = CGRectMake(_minX, _minY, _width, _height);
    
    numberOfVertices = 4;

    //if(!coordVertices) {
    //coordVertices = (GLfloat*) malloc(sizeof(GLfloat)*(8));
    //}
    
    coordVertices[0] = _minX;
    coordVertices[1] = _minY + h;
    coordVertices[2] = _minX;
    coordVertices[3] = _minY;
    coordVertices[4] = _minX + w;
    coordVertices[5] = _minY;
    coordVertices[6] = _minX + w;
    coordVertices[7] = _minY + h;

red = ((float)((hex & 0xFF0000) >> 16))/255.0;
green = ((float)((hex & 0xFF00) >> 8))/255.0;
blue = ((float)(hex & 0xFF))/255.0;
colorHx = hex;
}


- (GNode *)clone {
    GBox *bx = [[GBox alloc] init];
    [bx rectWidth:_width andHeight:_height color:colorHx];
    bx.scaleX = scaleX;
    bx.scaleY = scaleY;
    bx.x = x;
    bx.y = y;
    bx.rotation = rotation;
    [bx regX:-_minX andY:-_minY];
    bx.opacity = self.opacity;
    return bx;
}



/***
 * sets the color of this sprite with a hexadecimal. this 
 * is cool because it opens the door for color tweening with 
 * the Tweener.
 *
 */
- (void) setColor:(int)hex {
	red = ((float)((hex & 0xFF0000) >> 16))/255.0;
	green = ((float)((hex & 0xFF00) >> 8))/255.0;
	blue = ((float)(hex & 0xFF))/255.0;
    colorHx = hex;
}
- (int) color {
return colorHx;
}

/**
 * set the rgb channels. all arguments are ratios [0,1]
 *
 *
 */
- (void) setR:(float)r G:(float)g B:(float)b {
red = r;
green = g;
blue = b;
}


- (float) red {
return red;
}
- (float) green {
return green;
}
- (float) blue {
return blue;
}
- (void) setRed:(float)r {
red = r;
}
- (void) setGreen:(float)g {
green = g;
}
- (void) setBlue:(float)b {
blue = b;
}


/***
 * these are the functions to set the width and height 
 * actually by setting the scaleX and scaleY.
 *
 */
- (void) setWidth:(float)val {
scaleX = val/_width;
}
- (float) width {
return _width;
}
- (void) setHeight:(float)val {
scaleY = val/_height;
}
- (float) height {
return _height;
}


/**
 * get the edges.
 * will not jive with rotation.
 *
 */
- (float) leftEdge {
return x-scaleX*_minX;
}
- (void) setLeftEdge:(float)f {
//take no action
}
- (float) rightEdge {
return x+scaleX*(_width-_minX);
}
- (void) setRightEdge:(float)f {
//take no action
}
- (float) topEdge {
return y-scaleY*_minY;
}
- (void) setTopEdge:(float)f {
//take no action
}
- (float) bottomEdge {
return y+scaleY*(_height-_minY);
}
- (void) setBottomEdge:(float)f {
//take no action
}





/////////////////////////
// collision detection //
/////////////////////////





/**
 * checks to see if a point collides with the rectangular boundary. rotation friendly.
 *
 */
- (BOOL) hitTestRect:(CGPoint)collPt {
CGPoint pt = CGPointMake(0, 0);

float rad = -0.01745*self.rotation;

pt.x = (collPt.x - x)*cos(rad) - (collPt.y - y)*sin(rad);
pt.y = (collPt.x - x)*sin(rad) + (collPt.y - y)*cos(rad); 

  if(CGRectContainsPoint(bnds, pt) == YES) {
  return YES;
  } else {
  return NO;
  }
return NO;
}



/***
 * if the two sprites are center-registered circles, this method
 * will test to see if they have collided.
 */
- (BOOL) hitTestCircle:(CGPoint)colPt {
	if(hypot((x - colPt.x) , (y - colPt.y)) <= self.width/2) {
	return YES;	
	} else {
	return NO;
	}
}



/**
 * transforms a game point on the root level to a local point in this coordinate system,
 * and sees if there's an intersection. this is where all that linear algebra comes in handy.
 *
 */
- (BOOL) touchPointTest:(CGPoint)collPt {

CGPoint pt = CGPointMake(0,0);
// [a00  a01 a02 
//  a10  a11 a12]
    
pt.x = affineInverse[0]*collPt.x + affineInverse[1]*collPt.y + affineInverse[2];
pt.y = affineInverse[3]*collPt.x + affineInverse[4]*collPt.y + affineInverse[5];
    
    //NSLog(@" ");
    //NSLog(@"- - touchPointTest- - - - - -");
    //NSLog(@" collPt.x: %f%@%f",collPt.x,@" collPt.y: %f",collPt.y);
    //NSLog(@" pt.x: %f%@%f",pt.x,@" pt.y: %f",pt.y);
    //NSLog(@"_minX: %f%@%f%@%f%@%f",_minX,@" _minY:",_minY,@" _width:",_width,@" _height:",_height);
    //NSLog(@" ");

CGRect rct = CGRectMake(_minX, _minY, _width, _height);
    
	if(CGRectContainsPoint(rct, pt) == YES) {
	return YES;
	} else {
	return NO;
	}

}

/*
- (void) testTouchDown {
    
    if(parent.totalWatchTouches == NO) {
        
        if(_width == 400) {
            watchTouches = YES;
        //NSLog(@"AAAAA!!! %@",(watchTouches)? @"Well" : @"Hell");
        //totalWatchTouches = YES;
        }
        
    }
    
    [super testTouchDown];
    
    if(totalWatchTouches) {
        NSLog(@"width: %f",_width);
    } else {
        //NSLog(@"")
    }
    

}
*/





//////////////
// clean up //
//////////////


/***
 * dealloc the 
 *
 */
- (void) dealloc {
    
//    #if gDebug_LogDealloc == gYES
//    NSLog(@"dealloc: GBox %@",self.name);
//    #endif

free(coordVertices);
	
[super dealloc];

}


@end
