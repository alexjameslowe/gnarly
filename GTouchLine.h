//
//  GTouchLine.h
//  RidiculousMissile3
//
//  Created by Alexander  Lowe on 5/5/11.
//  Copyright 2011 Codequark. See Licence.
//

#import "GBox.h"


@interface GTouchLine : GBox {
   
int numActiveVerts;
int numActiveCoords;
int currentCoordLength;

float totalLength;


int internalCount;


int stackPoint;
CGPoint prevPt0;
CGPoint prevPt1;
CGPoint currPt;
CGPoint prevPt;


float prevAngle;
float prevDistance;
int prevResolution;
int prevNumInterp;
float prevSlope;





/////////////////////
    int numActiveVerts1;
    int numActiveCoords1;
    int currentCoordLength1;
    GLfloat *cVerts1;

    
    int numActiveVerts2;    
    int numActiveCoords2;
    int currentCoordLength2;
    GLfloat *cVerts2;

    
    int numActiveVerts3;
    int numActiveCoords3;
    int currentCoordLength3;
    GLfloat *cVerts3;


    int numActiveVerts4;
    int numActiveCoords4;
    int currentCoordLength4;
    GLfloat *cVerts4;
    
    
    int popStack1;
    int popStack2;
    int popStack3;
    int popStack4;
//////////////////////


float tangentAngle;
BOOL reachedEnd;
      
}

@property (nonatomic, assign) float tangentAngle;
@property (nonatomic, readonly) BOOL reachedEnd;
@property (nonatomic, readonly) float totalLength;


//- (void) drawDottedBezierFrom:(CGPoint)pt0 To:(CGPoint)pt1 startSlope:(float)slope0 endSlope:(float)slope1;

- (void) populateRescalingArraysX:(float)xCoord andY:(float)yCoord;

- (CGPoint) getNext;

- (void) addX:(float)xCoord andY:(float)yCoord;

- (void) startDrawX:(float)xCoord andY:(float)yCoord;

- (void) clearLine;


@end
