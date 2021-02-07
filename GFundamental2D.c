//
//  GFundamental.c
//  BraveRocket
//
//  Created by Alexander Lowe on 3/8/14.
//  Copyright (c) 2014 Alexander Lowe. See Licence.
//

#include <stdio.h>
#include "GFundamental2D.h"
#include "math.h"

/** 
 * the make functions for the datastructures that we're using.
 *
 */
GPoint2D GPoint2DMake(float xCoord, float yCoord) {
    GPoint2D p;
    p.x = xCoord;
    p.y = yCoord;
    return p;
}
GBoundaryInfo2D GBoundaryInfo2DMake(bool inside, GVector2D displacement) {
    GBoundaryInfo2D inf;
    inf.inside = inside;
    inf.displacement = displacement;
    return inf;
}

GIntersectionInfo2D GIntersectionInfo2DMake(bool intersects, GPoint2D point) {
    GIntersectionInfo2D inf;
    inf.hasIntersection = intersects;
    inf.intersection = point;
    return inf;
}

GAABB2D GAABB2DMake(float aabbMinX, float aabbMaxX, float aabbMinY, float aabbMaxY){
    GAABB2D aabb;
    aabb.aabbMinX = aabbMinX;
    aabb.aabbMaxX = aabbMaxX;
    aabb.aabbMinY = aabbMinY;
    aabb.aabbMaxY = aabbMaxY;
    return aabb;
}

/**
 * transform a point with a new set of basis vectors.
 *
 */
GPoint2D GTransformPointWithBasis2D(GPoint2D point, GVector2D xUnit, GVector2D yUnit) {
GVector2D pointX = GVector2DGetRescale(xUnit, point.x);
GVector2D pointY = GVector2DGetRescale(yUnit, point.y);
return GPoint2DMake(pointX.i+pointY.i, pointX.j+pointY.j);
}



/**
 * the goal test. the calculateDisplacement parameter determines whether or not 
 * the a passed goal-test will also include the displacement vector which is the 
 * the vector pointing in the same direction of kVec which will place the 'ball'
 * directly colinear with goal1 and goal2.
 *
 * The details for this are in Book 2, pgs 229-237. We can elect to calculate the
 * the displacement vector with the calculateDisplacement parameter.
 *
 */
GBoundaryInfo2D GGoalTest2D(GPoint2D goal1, GPoint2D goal2, GPoint2D kPoint, GVector2D kVec, bool calculateDisplacement) {
    
    GVector2D kToG1 = GVector2DMake((goal1.x - kPoint.x), (goal1.y - kPoint.y));
    GVector2D kToG2 = GVector2DMake((goal2.x - kPoint.x), (goal2.y - kPoint.y));
    
    GVector2D cross1 = GVector2DCross(kVec, kToG1);
    GVector2D cross2 = GVector2DCross(kVec, kToG2);
    
        //take an early exit if the first test fails.
        if(cross1.k*cross2.k > 0) {
        return GBoundaryInfo2DMake(false, GVector2DMake(0,0));
        }
    
    //continue on to the second test.
    GVector2D g1xg2 = GVector2DCross(kToG1, kToG2);
    
    //we could calculate this cross product again, but why would we?
    //it's just the negative of cross1. it would be a waste of time to calculate it again.
    GVector2D g1xK;// = GVector2DCross(kToG1, kVec);
    g1xK.i = 0;//-cross1.i;
    g1xK.j = 0;//-cross1.j;
    g1xK.k = -cross1.k;
    
    //if the cross products are of different sign, then we pass the test.
    //if(cross1.k*cross2.k < 0 && g1xg2.k*g1xK.k > 0) {
    if(g1xg2.k*g1xK.k > 0) {
    
        //See Book 2 for the details of the displacement conditional.
        if(calculateDisplacement == true) {
            float u1 = kVec.i;
            float v1 = kVec.j;
            float x1 = kPoint.x;
            float y1 = kPoint.y;
            
            float u2 = goal2.x - goal1.x;
            float v2 = goal2.y - goal1.y;
            float x2 = goal1.x;
            float y2 = goal1.y;
            float scalingFactor =(u2*(y2-y1) - v2*(x2-x1))/(u2*v1 - u1*v2);
            
            GVector2D displacement = GVector2DMake(
                                                   u1*scalingFactor,
                                                   v1*scalingFactor
                                                   );
            
            return GBoundaryInfo2DMake(true, displacement);
        }
        
        return GBoundaryInfo2DMake(true, GVector2DMake(0,0));
    }
    
    return GBoundaryInfo2DMake(false, GVector2DMake(0,0));
}



/**
 * This uses some math from the goal test. For the details, see Book 2, pg 229-239.
 *
 */
GIntersectionInfo2D GCalculateIntersection2D(GPoint2D startV1, GPoint2D startV2, GVector2D v1, GVector2D v2) {
 
//calculate the determinant.
float determinant = v2.i*v1.j - v1.i*v2.j;
    
    //if zero, then exit early.
    if(determinant == 0) {
    return GIntersectionInfo2DMake(false, GPoint2DMake(0, 0));
    }
    
//see factor 'a', Book 2, pg 235.
float scale = (v2.i*(startV2.y - startV1.y) - v2.j*(startV2.x - startV1.x))/determinant;
    
//the scaling factor applied to v1 will take you to the intersection point starting from the origin of v1- startV1.
return GIntersectionInfo2DMake(true, GPoint2DMake(startV1.x + scale*v1.i, startV1.y + scale*v2.j));

}



/**
 * For two vectors v1 and v2, we're going to calculate the intersection of the bisectors of both vectors, assuming one exists.
 * See Book 2, pg 237-239 for the kind of use-case that this function is supposed to ease, and that math behind this.
 * The vectors have to start from the same point.
 *
 */
GIntersectionInfo2D GCalculateIntersectionOfBisectors2D(GPoint2D startPoint, GVector2D v1, GVector2D v2) {
    
    //this should have worked, but it didn't for some reason.
    //GVector2D bisec1 = GVector2DPlus(   GVector2DGetRescale(v1, GVector2DDot(v1,v2)),  GVector2DGetRescale(v2, GVector2DDot(v1,v1)));
    //GVector2D bisec2 = GVector2DMinus(  GVector2DGetRescale(v1, GVector2DDot(v2,v2)),  GVector2DGetRescale(v2, GVector2DDot(v2,v1)));
    
    //using the cross product to resolve the ambiguity.
    GVector2D cross = GVector2DCross(v1,v2);
    GVector2D bisec1;
    GVector2D bisec2;

        //if one way, then do one thing. If the other, then do the other. god bless cross-products.
        if(cross.k > 1) {
        bisec1 = GVector2DCrossWithKUnitNegtive(v1);
        bisec2 = GVector2DCrossWithKUnitPositive(v2);
        } else {
        bisec1 = GVector2DCrossWithKUnitNegtive(v1);
        bisec2 = GVector2DCrossWithKUnitPositive(v2);
        }

    GPoint2D startBisec1 = GPoint2DMake(startPoint.x + 0.5*v1.i, startPoint.y + 0.5*v1.j);
    GPoint2D startBisec2 = GPoint2DMake(startPoint.x + 0.5*v2.i, startPoint.y + 0.5*v2.j);
    
    return GCalculateIntersection2D(startBisec1, startBisec2, bisec1, bisec2);
    
}




/**
 * is the test point inside a general (convex or concave) boundary?
 *
 */
GBoundaryInfo2D GIsPointInsideGeneralBoundary2D(GPoint2D test, GPoint2D *allPoints, int countOfAllPoints) {

GVector2D dirVec = GVector2DMake(0,1);
int numGoals=0;
int j=0;
int len = countOfAllPoints;

//this may cause trouble.
GPoint2D p1;
GPoint2D p2;
    
    for(j=0; j<len; j++) {
    //set up the two goal posts.
    p1 = allPoints[j];
		
        if(j==len-1) {
        p2 = allPoints[0];
        } else {
        p2 = allPoints[j+1];
        }
		
    GBoundaryInfo2D ret = GGoalTest2D(p1, p2, test, dirVec, false);
        
        if(ret.inside == true) {
        numGoals++;
        }
			
    }
	
    GVector2D displacement;
    displacement.i = 0;
    displacement.j = 0;
    
    if(numGoals % 2 == 0) {
        return GBoundaryInfo2DMake(false, displacement);
    } else {
        return GBoundaryInfo2DMake(true, displacement);
    }
    
}


/**
 * is the test point inside a convex boundary? A bit faster than the general case because the geometry
 * of convex shapes allows us to take an early exit from the loop.
 *
 */
GBoundaryInfo2D GIsPointInsideConvexBoundary2D(GPoint2D test, GPoint2D *allPoints, int countOfAllPoints) {
    
    GVector2D dirVec = GVector2DMake(0,1);
    int j=0;
    int len = countOfAllPoints;
    
    int numGoals = 0;
    
    //this may cause trouble.
    GPoint2D p1;
    GPoint2D p2;
    GBoundaryInfo2D boundaryInfo;
    
    for(j=0; j<len; j++) {
    //set up the two goal posts.
    p1 = allPoints[j];
		
        if(j==len-1) {
        p2 = allPoints[0];
        } else {
        p2 = allPoints[j+1];
        }
		
        GBoundaryInfo2D bInfo = GGoalTest2D(p1, p2, test, dirVec, false);
        
        //unlike the general case, for convex shapes we can make this more efficient
        //by taking an early exit from the loop if a single goal-test passes.
        if(bInfo.inside == true) {
        boundaryInfo = bInfo;
        numGoals++;
            if(numGoals == 2) {
            break;
            }
        }
    }
	
    if(numGoals % 2 == 0) {
    return GBoundaryInfo2DMake(false, GVector2DMake(0,0));
    } else {
    return boundaryInfo;
    }
}


GBoundaryInfo2D GIsPointInsideConvexBoundaryWithXYDisplacement2D(GPoint2D test, GPoint2D *allPoints, int countOfAllPoints, float xDisp, float yDisp) {
    
GVector2D dirVec = GVector2DMake(0,1);
int j=0;
int len = countOfAllPoints;

//this may cause trouble.
GPoint2D p1;
GPoint2D p2;
GBoundaryInfo2D boundaryInfo;
    
int numGoals = 0;
    
    for(j=0; j<len; j++) {
    //set up the two goal posts.
    p1 = allPoints[j];
		
        if(j==len-1) {
        p2 = allPoints[0];
        } else {
        p2 = allPoints[j+1];
        }
        
    p1.x += xDisp;
    p2.x += xDisp;
    p1.y += yDisp;
    p2.y += yDisp;
    
    GBoundaryInfo2D bInfo = GGoalTest2D(p1, p2, test, dirVec, false);
        
        //unlike the general case, for convex shapes we can make this more efficient
        //by taking an early exit from the loop if a single goal-test passes.
        if(bInfo.inside == true) {
        boundaryInfo = bInfo;
        numGoals++;
            if(numGoals == 2) {
            break;
            }
            
        }
        
    }
    
    if(numGoals % 2 == 0) {
    return GBoundaryInfo2DMake(false, GVector2DMake(0,0));
    } else {
    return boundaryInfo;
    }

}



/**
 * is the test point moving with a given velocity inside a general (convex or concave) boundary?
 *
 */
GBoundaryInfo2D GIsPointWithVelocityInsideGeneralBoundary2D(GPoint2D test, GVector2D velocity, GPoint2D *allPoints, int countOfAllPoints) {
//make a new vector that's just the reversal of the test point's velocity on the way into the boundary.
//The desired displacement vector in this case will be some multiple of this reversal.
GVector2D dirVec = GVector2DMake(-velocity.i, -velocity.j);
    
    int numGoals=0;
    int j=0;
    int len = countOfAllPoints;
    
    //this may cause trouble.
    GPoint2D p1;
    GPoint2D p2;
    GBoundaryInfo2D boundaryInfo;
    
    //set up the two goal posts and perform the goal-test with each one.
    for(j=0; j<len; j++) {
    p1 = allPoints[j];
		
        if(j==len-1) {
        p2 = allPoints[0];
        } else {
        p2 = allPoints[j+1];
        }
		
    boundaryInfo = GGoalTest2D(p1, p2, test, dirVec, true);
        
        if(boundaryInfo.inside == true) {
        numGoals++;
        }
        
    }
	

    if(numGoals % 2 == 0) {
    return GBoundaryInfo2DMake(false, GVector2DMake(0,0));
    } else {
    return boundaryInfo;
    }
    
}


/**
 * is the test point moving with a given velocity inside a convex boundary? 
 * A bit faster than the general case because the geometry
 * of convex shapes allows us to take an early exit from the loop.
 *
 */
GBoundaryInfo2D GIsPointWithVelocityInsideConvexBoundary2D(GPoint2D test, GVector2D velocity, GPoint2D *allPoints, int countOfAllPoints) {
//make a new vector that's just the reversal of the test point's velocity on the way into the boundary.
//The desired displacement vector in this case will be some multiple of this reversal.
GVector2D dirVec = GVector2DMake(-velocity.i, -velocity.j);

int j=0;
int len = countOfAllPoints;
    
//this may cause trouble.
GPoint2D p1;
GPoint2D p2;
GBoundaryInfo2D boundaryInfo;
int numGoals = 0;
    
    //set up the two goal posts and perform the goal-test with each one.
    for(j=0; j<len; j++) {
    p1 = allPoints[j];
		
        if(j==len-1) {
        p2 = allPoints[0];
        } else {
        p2 = allPoints[j+1];
        }
		
        GBoundaryInfo2D bInfo = GGoalTest2D(p1, p2, test, dirVec, false);
        
        //unlike the general case, for convex shapes we can make this more efficient
        //by taking an early exit from the loop if a single goal-test passes.
        if(bInfo.inside == true) {
            boundaryInfo = bInfo;
            numGoals++;
                if(numGoals == 2) {
                break;
                }
            
        }
        
    }
	
    if(numGoals % 2 == 0) {
    return GBoundaryInfo2DMake(false, GVector2DMake(0,0));
    } else {
    return boundaryInfo;
    }
}
