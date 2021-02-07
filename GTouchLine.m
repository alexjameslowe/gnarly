//
//  GTouchLine.m
//  RidiculousMissile3
//
//  Created by Alexander  Lowe on 5/5/11.
//  Copyright 2011 Codequark. See Licence.
//

#import "GTouchLine.h"
#import "GRenderable.h"


@implementation GTouchLine

@synthesize tangentAngle;
@synthesize reachedEnd;
@synthesize totalLength;



- (id) init {

self = [super init];

totalLength = 0;

numActiveVerts = 0;
numActiveCoords = 0;
currentCoordLength = 600;
coordVertices = malloc(sizeof(GLfloat)*currentCoordLength*2);



    /////////////////////////////
    numActiveVerts1 = 0;
    numActiveCoords1 = 0;
    currentCoordLength1 = 300;
    cVerts1 = malloc(sizeof(GLfloat)*currentCoordLength1*2);
    
    
    numActiveVerts2 = 0;
    numActiveCoords2 = 0;
    currentCoordLength2 = 120;
    cVerts2 = malloc(sizeof(GLfloat)*currentCoordLength2*2);
    
    
    numActiveVerts3 = 0;
    numActiveCoords3 = 0;
    currentCoordLength3 = 60;
    cVerts3 = malloc(sizeof(GLfloat)*currentCoordLength3*2);
    
    
    numActiveVerts4 = 0;
    numActiveCoords4 = 0;
    currentCoordLength4 = 40;
    cVerts4 = malloc(sizeof(GLfloat)*currentCoordLength4*2);
    
    popStack1 = 0;
    popStack2 = 0;
    popStack3 = 0;
    popStack4 = 0;
    
    ////////////////////////////

internalCount = 0;
tangentAngle = 0;
reachedEnd = NO;
prevSlope = 0;
stackPoint = 0;

return self;

}



- (void) populateRescalingArraysX:(float)xCoord andY:(float)yCoord {

    popStack1++;
    popStack2++;
    popStack3++;
    popStack4++;
    
    
    if(popStack4 == 8) {
    popStack4 = 0;
        
        if(numActiveCoords4 >= currentCoordLength4) {
        currentCoordLength4 += 30;
        cVerts4 = realloc(cVerts4,sizeof(GLfloat)*currentCoordLength4*2);
        }  
    
    cVerts4[numActiveVerts4]   = xCoord;
    cVerts4[numActiveVerts4+1] = yCoord;
        
    numActiveVerts4 += 2;
    numActiveCoords4 += 1; 
        
    }
        
        
    if(popStack3 == 6) {
    popStack3 = 0;
        
            
        if(numActiveCoords3 >= currentCoordLength3) {
        currentCoordLength3 += 30;
        cVerts3 = realloc(cVerts3,sizeof(GLfloat)*currentCoordLength3*2);
        }  
        
    cVerts3[numActiveVerts3]   = xCoord;
    cVerts3[numActiveVerts3+1] = yCoord;
            
    numActiveVerts3 += 2;
    numActiveCoords3 += 1; 
            
    }
            
           
    if(popStack2 == 4) {
    popStack2 = 0;
                
        if(numActiveCoords2 >= currentCoordLength2) {
        currentCoordLength2 += 30;
        cVerts2 = realloc(cVerts2,sizeof(GLfloat)*currentCoordLength2*2);
        } 
        
        cVerts2[numActiveVerts2]   = xCoord;
        cVerts2[numActiveVerts2+1] = yCoord;
                
    numActiveVerts2 += 2;
    numActiveCoords2 += 1; 
                
    } 
                
                
    if(popStack1 == 2) {
    popStack1 = 0;
                    
        if(numActiveCoords1 >= currentCoordLength1) {
        currentCoordLength1 += 30;
        cVerts1 = realloc(cVerts1,sizeof(GLfloat)*currentCoordLength1*2);
        } 
        
        cVerts1[numActiveVerts1]   = xCoord;
        cVerts1[numActiveVerts1+1] = yCoord;
                    
    numActiveVerts1 += 2;
    numActiveCoords1 += 1; 
                    
    }
    
    
    
}





- (void) addX:(float)xCoord andY:(float)yCoord {
    
    /////////////////////////////////////////////////////////
    // do some math. calulate the angle of the between the current
    // input and the previous point. get the number of dotted lines
    // that would be in a straight line between the two points.
    float ang  = atan2f((yCoord - prevPt0.y), (xCoord - prevPt0.x));        
    float dist = hypotf((yCoord - prevPt0.y), (xCoord - prevPt0.x));
    int resolution = floor(dist/10);
    float properDist = 10*resolution;
    
    ///////////////////////////////////////////////////////////////////////////////////
    // make the current point, which is set so that a whole number of dotted lines will
    // fit between it and the immediate previous point, prevPt0.
    currPt = CGPointMake( ((properDist*cos(ang))+prevPt0.x), ((properDist*sin(ang))+prevPt0.y));  
    
    
        ///////////////////////////////////////////////////////////////////////
        // the first time through, there will not be the prevPt1, so we have to
        // wait until the second time through, when prevPt1 will exist. this is
        // so that we'll have have three points from which to calculate the proper
        // smooth sanding slope of the cubic bezier curve.
        if(stackPoint == 1) {
        
        /////////////////////////////////////////////////
        // do some preliminary math. calculate the slope.
        // as well as a couple of trig numbers.
       /* float slope = 0;
        float dY;
        float dX;
            
        float deltaX0 = prevPt0.x-prevPt1.x;
        float deltaX1 = currPt.x-prevPt0.x;
        
        BOOL vertical = NO;
            
            ///////////////////////////////////////////////////////////////
            // calculate the sanding slope. make sure it's not pathological.
            if(deltaX0 != 0 && deltaX1 != 0) {
            dY = 0.5*( ((prevPt0.y-prevPt1.y)/deltaX0) - ((currPt.y-prevPt0.y)/deltaX1) );
            dX = 1;
            } else {
            dY = 0;
            vertical = YES;
            dX = 1;
            }
            
        slope = dY/dX;*/
        
        float prevY = prevPt1.y;
        float prevX = prevPt1.x;
        float sn = sin(prevAngle);
        float cs = cos(prevAngle);
        
            /////////////////////////////////
            //if there's three or less points, 
            //then just draw dotted lines.
            //if(prevResolution < 4 || vertical == YES) {
         //   if(prevResolution < 5) {
        
                for(int j=1; j<=prevResolution; j++) {
            
                    if(numActiveCoords >= currentCoordLength) {
                    currentCoordLength += 30;
                    coordVertices = realloc(coordVertices,sizeof(GLfloat)*currentCoordLength*2);
                    }
            
                float yCoord = prevY + 10*sn;
                float xCoord = prevX + 10*cs;
                
                totalLength += 10;
            
                coordVertices[numActiveVerts]   = xCoord;
                coordVertices[numActiveVerts+1] = yCoord;
                
                [self populateRescalingArraysX:xCoord andY:yCoord];
            
                numActiveVerts += 2;
                numActiveCoords += 1; 
            
                prevY = yCoord;
                prevX = xCoord;
            
                }
            
         //   } 
            
            ///////////////////////////////////////////
            // else, if there's more than three points, 
            // then draw a bezier curve.
          //  else {
          // [self drawDottedBezierFrom:prevPt1 To:prevPt0 startSlope:prevSlope endSlope:slope];    
          // }
            
        //prevSlope = slope;
    
        } else {
    
        stackPoint = 1;
        
        }
        
    
    ///////////////////////////////////////////////
    // set all the values for the next time around.
    prevAngle = ang;
    prevResolution = resolution;
    prevDistance = dist;
    prevPt1 = prevPt0;
    prevPt0 = currPt;
    
}





- (void) startDrawX:(float)xCoord andY:(float)yCoord {
prevPt0 = CGPointMake(xCoord, yCoord);
}








/**
 * Draws an approximate quadratic bezier curve from pt0 to pt1 with the starting and ending slopes
 * slope0 and slope1 with dotted lines. Generally, sloppy line-drawing code will only draw smooth curves
 * if the user input comes very slowly. The framerate will cause the line to be a bunch of straight segments
 * if the user's finger is moving quickly. Drawing beziers is how we can reliably generate smooth dotted lines 
 * no matter how rapid the user draws his/her finger around the touch screen. An important mechanic.
 *
 *//*
- (void) drawDottedBezierFrom:(CGPoint)pt0 To:(CGPoint)pt1 startSlope:(float)slope0 endSlope:(float)slope1 {
 

//////////////////////////////////
// do some preliminary math here
float deltaX = pt1.x - pt0.x;
float deltaY = pt1.y - pt0.y;
float distance = hypotf(deltaX, deltaY);


////////////////////////////////////////////////////////////////////////////
// tells the code which side of the anchor point the control point should be.
int direction = deltaX/abs(deltaX);


///////////////////////////////////////////////////////
// fix the x distance of the control points from the
// anchor points. 20% the total distance is reasonable.
float controlDeltaX = distance/5;


///////////////////////////////////////////////////////
// define the anchor points with the above information.
float c0x = pt0.x + controlDeltaX*direction;
float c0y = [self yFuncX:c0x fromPoint:pt0 andSlope:slope0];

float c1x = pt1.x - controlDeltaX*direction;
float c1y = [self yFuncX:c1x fromPoint:pt1 andSlope:slope1];

 
 
 ///////////////////////////////////////////////////////////
 // calculate the total number of segments we're going to use
 // to approximae the cubic bezier curve. divide it by twice
 // the length of a dash.
 int resolution = floor(distance/20);
 
 
 ///////////////////////////////
 //set the prevX and Y initially
 float prevX = pt0.x;
 float prevY = pt0.y;
 
     //////////////////////////////////////////////////////////////////////
     // for each segment of the approximation, we want to draw dotted lines.
     for(int h=1; h<=resolution; h++) {
 
    float k = h;
    float h = resolution;
    float p = k/h;
 
    /////////////////////////////////////////////////
    // calculate the point on the cubic bezier curve
    float currX = (1-p)*(1-p)*(1-p)*pt0.x + 3*(1-p)*(1-p)*p*c0x + 3*(1-p)*p*p*c1x + p*p*p*pt1.x;
    float currY = (1-p)*(1-p)*(1-p)*pt0.y + 3*(1-p)*(1-p)*p*c0y + 3*(1-p)*p*p*c1y + p*p*p*pt1.y;
 
 
    //calculate the dX,dY between the two cubic bezier points
    float dX = currX - prevX;
    float dY = currY - prevY;
    
    //get the distance between the two cubic bezier points
    float dist = hypotf(dX, dY);
    
    //estimate how many dotted lines there's going to be.
    int numInterp = floor(dist/10);
 
    //slope between the two points.
    float slope = 0;
    
    //are the points vertical
    BOOL vertical = NO;
    
    //if the points are vertical, we need to know which one is above the other.
    int verticalDirection = 1;
    
    //the amount of x change between two dotted dashes.
    
    float deltaX = 0;// = dX/numInterp;
         if(numInterp > 0) {
         deltaX = dX/numInterp;
         }
    
    
         //////////////////////////////////////////////////
         // normalize the slope and record and make a note
         // if the line between the two points is vertical
         // and if so, what direction its going.
         if(dX != 0) {
         slope = dY/dX;
         } else {
         slope = 0;
         vertical = YES;
         verticalDirection = dY/abs(dY);
         }

 
         /////////////////////////////////////////////////
         // draw the dotted lines. if we're running out of
         // memory in the arrays, then allocate more.
         for(int i=1; i<=numInterp; i++) {
 
         float bX;
         float bY;
  
             //////////////////////////////////////////////////
             //calculate the point. allow for a vertical case.
             if(vertical == NO) {
             bX = prevX + deltaX*i;
             bY = prevY + deltaX*i*slope;
             } else {
             bX = prevX;
             bY = prevY + verticalDirection*i*10;                
             }
       
            if(numActiveCoords >= currentCoordLength) {
            currentCoordLength += 30;
            coordVertices = realloc(coordVertices,sizeof(GLfloat)*currentCoordLength*2);
            }
 
        coordVertices[numActiveVerts]   = bX;
        coordVertices[numActiveVerts+1] = bY;
 
        numActiveVerts += 2;
        numActiveCoords += 1;                   
 
        }
 
 
     //////////////////////////////////////////////////////////////////
     // reset the previous point to the current point here at the end.       
     prevX = currX;
     prevY = currY;
     } 
 
 }*/







- (void) clearLine {
    
free(coordVertices);

internalCount = 0;
reachedEnd = NO;
    
numActiveVerts = 0;
numActiveCoords = 0;

stackPoint = 0;
    
currentCoordLength = 300;
coordVertices = malloc(sizeof(GLfloat)*currentCoordLength*2);


    popStack1 = 0;
    popStack2 = 0;
    popStack3 = 0;
    popStack4 = 0;
    
    free(cVerts1);
    free(cVerts2);
    free(cVerts3);
    free(cVerts4);
    
    numActiveVerts1 = 0;
    numActiveCoords1 = 0;
    currentCoordLength1 = 300;
    cVerts1 = malloc(sizeof(GLfloat)*currentCoordLength1*2);
    
    
    numActiveVerts2 = 0;
    numActiveCoords2 = 0;
    currentCoordLength2 = 120;
    cVerts2 = malloc(sizeof(GLfloat)*currentCoordLength2*2);
    
    
    numActiveVerts3 = 0;
    numActiveCoords3 = 0;
    currentCoordLength3 = 60;
    cVerts3 = malloc(sizeof(GLfloat)*currentCoordLength3*2);
    
    
    numActiveVerts4 = 0;
    numActiveCoords4 = 0;
    currentCoordLength4 = 40;
    cVerts4 = malloc(sizeof(GLfloat)*currentCoordLength4*2);

}


/**
 * get the next point offset points 
 *
 */
- (CGPoint) getNext { 
    
    CGPoint pt;
    
    if(internalCount+2 < numActiveVerts) {
    pt = CGPointMake(coordVertices[internalCount], coordVertices[internalCount+1]); 
    internalCount+=2;
    } else {
    reachedEnd = YES;
    pt = CGPointMake(coordVertices[numActiveVerts-2], coordVertices[numActiveVerts-1]);
    }
    
    tangentAngle = atan2f((pt.x - prevPt.x), (pt.y - prevPt.y)) - M_PI/2; 
    prevPt = pt;
    return pt;  

}



- (GRenderable *) render {

   float sc = parent.scaleX;
        
    //float alpha = opacity*parent.opacity;
        
    glPushMatrix();
    
    glLineWidth(2.0f);
    glColor4f(red, green, blue, opacity);   
    
        if(sc <= 1 && sc >= 0.8) {
        glVertexPointer(2, GL_FLOAT, 0, coordVertices);
        glDrawArrays(GL_LINES, 0, numActiveCoords);
        } else
        if(sc < 0.8 && sc >= 0.6) {
        glVertexPointer(2, GL_FLOAT, 0, cVerts1);
        glDrawArrays(GL_LINES, 0, numActiveCoords1);    
        } else
        if(sc < 0.6 && sc >= 0.4) {
        glVertexPointer(2, GL_FLOAT, 0, cVerts2);
        glDrawArrays(GL_LINES, 0, numActiveCoords2);              
        } else
        if(sc < 0.4 && sc >= 0.2) {
        glVertexPointer(2, GL_FLOAT, 0, cVerts3);
        glDrawArrays(GL_LINES, 0, numActiveCoords3);               
        } else {
        glVertexPointer(2, GL_FLOAT, 0, cVerts4);
        glDrawArrays(GL_LINES, 0, numActiveCoords4);               
        }
    
    //if(usePopper == NO) {
    //glPopMatrix();
    //}

return next;
}   



/**
 * free the coordinate vertices and call the super function.
 *
 */
- (void) destroy {

NSLog(@"TOUCH LINE DEALLOCING");
    
free(cVerts1);
free(cVerts2);
free(cVerts3);
free(cVerts4);
    
[super destroy];
    
}


@end
