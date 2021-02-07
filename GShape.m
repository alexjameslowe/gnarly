//
//  Shape.m
//  barf_38
//
//  Created by Alexander  Lowe on 4/17/10.
//  Copyright 2010 Alex Lowe.
//

#import "GShape.h"
#import "GBox.h"
#import "GRenderable.h"

@implementation GShape

@synthesize lineWidth;


-(id) initWithNumberOfVertices:(int)num {

numberOfVertices = num*2;

numActiveVerts = 0;

arrLength = 0;

lineWidth = 1;

coordVertices = (GLfloat *) malloc(sizeof(float)*numberOfVertices*2);

return [super init];

}


/**
 * line to x and y. the first coord establishes the beginning of the array. there is no moveTo function.
 *
 *
 */
- (void) lineToX:(float)xCoord andY:(float)yCoord {

	if(arrLength <= numberOfVertices) {

	coordVertices[arrLength] = xCoord;
	coordVertices[arrLength + 1] = yCoord;
 
	arrLength += 2;
	
	numActiveVerts++;
 
	}

}


/**
 * alter the [vertIndex]th vertex with a new x and y coordinate. will take effect immediately.
 *
 *
 */
- (void) alter:(int)vertIndex newX:(float)xCrd newY:(float)yCrd {
    
    if(vertIndex < numActiveVerts) {
    int ind = vertIndex*2;
    coordVertices[ind] = xCrd;
    coordVertices[ind + 1] = yCrd;        
    }
    
}


/**
 * clear the array. makes the line available for redrawing.
 *
 */
- (void) clear {

numActiveVerts = 0;

arrLength = 0;

}




- (GRenderable *) render {

	float alpha = opacity*parent.opacity;
    
	glPushMatrix();
    
    //NSLog(@"numActiveVerts: %i",numActiveVerts);

    glLineWidth(lineWidth);
	glColor4f(red, green, blue, alpha);   
	glTranslatef(x, y, 0);
	glRotatef(rotation, 0.0, 0.0, 1.0); 
	glScalef(scaleX, scaleY, 1.0);
	glVertexPointer(2, GL_FLOAT, 0, coordVertices);
	//glDrawArrays(GL_LINE_STRIP, 0, numActiveVerts);
    glDrawArrays(GL_TRIANGLE_FAN, 0, numActiveVerts);
    
	//if this has no children, then pop the matrix.
	//if(usePopper == NO) {
	//	glPopMatrix();
    //}
	
return [super render];
}



- (void) dealloc {
    
[super dealloc];
    
}

@end
