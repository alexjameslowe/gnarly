//
//  GFundamental.h
//  BraveRocket
//
//  Created by Alexander Lowe on 3/8/14.
//  Copyright (c) 2014 Alexander Lowe. See Licence.
//

#ifndef BraveRocket_GFundamental_h
#define BraveRocket_GFundamental_h
#include "stdbool.h"
#include "GVector2D.h"

typedef struct {
    float x;
    float y;
} GPoint2D;

typedef struct {
    bool inside;
    GVector2D displacement;
} GBoundaryInfo2D;

typedef struct {
    bool hasIntersection;
    GPoint2D intersection;
} GIntersectionInfo2D;

typedef struct {
    float aabbMinX;
    float aabbMaxX;
    float aabbMinY;
    float aabbMaxY;
} GAABB2D;

GPoint2D testPoint1;
GPoint2D testPoint2;

GPoint2D GPoint2DMake(float xCoord, float yCoord);

GBoundaryInfo2D GBoundaryInfo2DMake(bool inside, GVector2D displacement);

GIntersectionInfo2D GIntersectionInfo2DMake(bool intersects, GPoint2D point);

GBoundaryInfo2D GGoalTest2D(GPoint2D goal1, GPoint2D goal2, GPoint2D kicker, GVector2D dirVec, bool includeIntersct);

GBoundaryInfo2D GIsPointInsideGeneralBoundary2D(GPoint2D test, GPoint2D *allPoints, int countOfAllPoints);

GBoundaryInfo2D GIsPointWithVelocityInsideGeneralBoundary2D(GPoint2D test, GVector2D velocity, GPoint2D *allPoints, int countOfAllPoints);

GBoundaryInfo2D GIsPointInsideConvexBoundary2D(GPoint2D test, GPoint2D *allPoints, int countOfAllPoints);

GBoundaryInfo2D GIsPointInsideConvexBoundaryWithXYDisplacement2D(GPoint2D test, GPoint2D *allPoints, int countOfAllPoints, float xDisp, float yDisp);

GBoundaryInfo2D GIsPointWithVelocityInsideConvexBoundary2D(GPoint2D test, GVector2D velocity, GPoint2D *allPoints, int countOfAllPoints);

GPoint2D GTransformPointWithBasis2D(GPoint2D point, GVector2D xUnit, GVector2D yUnit);

GIntersectionInfo2D GCalculateIntersection2D(GPoint2D startV1, GPoint2D startV2, GVector2D v1, GVector2D v2);

GIntersectionInfo2D GCalculateIntersectionOfBisectors2D(GPoint2D startPoint, GVector2D v1, GVector2D v2);

GAABB2D GAABB2DMake(float aabbMinX, float aabbMaxX, float aabbMinY, float aabbMaxY);



#endif
