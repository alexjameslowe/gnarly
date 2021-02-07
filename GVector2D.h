//
//  Header.h
//  BraveRocket
//
//  Created by Alexander Lowe on 3/7/14.
//  Copyright (c) 2014 Alexander Lowe. See Licence.
//

#ifndef BraveRocket_Header_h
#define BraveRocket_Header_h
typedef struct {
    float i;
    float j;
    float k;
} GVector2D;


GVector2D GVector2DMake(float iComp, float jComp);

GVector2D GVector2DMakeWithK(float iComp, float jComp, float kComp);

float GVector2DDot(GVector2D v1, GVector2D v2);

float GVector2DGetMag(GVector2D v);

void GVector2DNormalize(GVector2D *v);

void GVector2DSetMag(GVector2D *v, float newMag);

GVector2D GVector2DCross(GVector2D v1, GVector2D v2);

GVector2D GVector2DCrossWithKUnitPositive(GVector2D v1);

GVector2D GVector2DCrossWithKUnitNegtive(GVector2D v1);

float GVector2DAngleBetween(GVector2D v1, GVector2D v2);

void GVector2DRotateDegrees(GVector2D *v, float ang);

float GVector2DProj(GVector2D v1, GVector2D v2);

GVector2D GVector2DPlus(GVector2D v1, GVector2D v2);

GVector2D GVector2DClone(GVector2D v, float newMag);

GVector2D GVector2DMinus(GVector2D v1, GVector2D v2);

void GVector2DRescale(GVector2D *v, float sc);

GVector2D GVector2DGetRescale(GVector2D v, float sc);





#endif


