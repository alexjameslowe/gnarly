//
//  Shape.h
//  barf_38
//
//  Created by Alexander  Lowe on 4/17/10.
//  Copyright 2010 Alex Lowe.
//

#import <Foundation/Foundation.h>
#import "GBox.h"

@interface GShape : GBox {

int numActiveVerts;

int arrLength;

float lineWidth;

}


-(id) initWithNumberOfVertices:(int)num;

- (void) lineToX:(float)xCoord andY:(float)yCoord;

- (void) clear;

- (void) alter:(int)vertIndex newX:(float)xCrd newY:(float)yCrd;

@property (nonatomic, assign) float lineWidth;

@end