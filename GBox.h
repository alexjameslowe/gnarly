//
//  Box.h
//  reboot_2
//
//  Created by Alexander  Lowe on 6/24/09.
//  Copyright 2009. See Licence.
//



#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <OpenGLES/ES1/gl.h>
#import "GEventDispatcher.h"


@interface GBox : GEventDispatcher {      
//@interface GBox : NSObject {
    
    
    NSString *uID;
    
	//color
	float red;
	float green;
	float blue;
    int colorHx;
	
	//dimensions
	float _width;
	float _height;
	CGRect bnds;
    
	//open gl variables.
	GLfloat *coordVertices;
	GLfloat *textureVertices;
	int numberOfVertices;
	
	//registration point variables
	float _minX;
	float _minY;

}

///////////////
//           //
//  Private  //
//           //
///////////////

//the upper-left corner of a 2d sprite.

@property (nonatomic, readonly) float _minX;
@property (nonatomic, readonly) float _minY;



/////////////
//         //
//  A P I  //
//         //
/////////////

@property (nonatomic, assign) NSString *uId;


//////////////
// override //
//////////////


- (BOOL) hitTestCircle:(CGPoint)colPt;
- (BOOL) hitTestRect:(CGPoint)collPt;


/////////////////
// displayable //
/////////////////

- (void)resetScrollingShit;


//width and height properties. probably is not worth it 
//to expose a setter for these.
- (void) setWidth:(float)val;
- (float) width;
- (void) setHeight:(float)val;
- (float) height;
- (void) setR:(float)r G:(float)g B:(float)b;


- (float) red;
- (float) green;
- (float) blue;
- (void) setRed:(float)r;
- (void) setGreen:(float)g;
- (void) setBlue:(float)b;


//reset the registration point, around which the object transforms
- (void) regX:(float)regX andY:(float)regY;

//define the rectangular boundary of the object
- (void) rectWidth:(float)w andHeight:(float)h;
- (void) rectWidth:(float)w andHeight:(float)h color:(int)hex;

//set the color
- (void) setColor:(int)hex;
- (int) color;

//get the edges. won't jive with rotation.
- (float) leftEdge;
- (void) setLeftEdge:(float)f;
- (float) rightEdge;
- (void) setRightEdge:(float)f;
- (float) topEdge;
- (void) setTopEdge:(float)f;
- (float) bottomEdge;
- (void) setBottomEdge:(float)f;



@end

