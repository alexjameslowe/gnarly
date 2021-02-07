//
//  File.c
//  BraveRocket
//
//  Created by Alexander Lowe on 3/7/14.
//  Copyright (c) 2014 Alexander Lowe. See Licence.
//

#include <stdio.h>
#include "GVector2D.h"
#include "math.h"



GVector2D GVector2DMake(float iComp, float jComp) {
    GVector2D v;
    v.i = iComp;
    v.j = jComp;
    v.k = 0;
    return v;
}

/*
 museum of american indian 
 
 lobster truck - see twitter
 
 eastern market -> 7th hill pizza
 */

GVector2D GVector2DMakeWithK(float iComp, float jComp, float kComp) {
    GVector2D v;
    v.i = iComp;
    v.j = jComp;
    v.k = kComp;
    return v;
}

float GVector2DDot(GVector2D v1, GVector2D v2) {
return v1.i*v2.i + v1.j*v2.j;
}

float GVector2DGetMag(GVector2D v) {
return sqrtf(v.i*v.i + v.j*v.j);
}

void GVector2DSetMag(GVector2D *v, float newMag) {
    float m = GVector2DGetMag(*v);
    if(m != 0) {
        v->i = newMag*v->i/m;
        v->j = newMag*v->j/m;
    } else {
        v->i = 0.7071;
        v->j = 0.7071;
    }
}

void GVector2DNormalize(GVector2D *v) {
float m = GVector2DGetMag(*v);
v->i = v->i/m;
v->j = v->j/m;
}

GVector2D GVector2DCross(GVector2D v1, GVector2D v2) {
//return GVector2DMakeWithK((v1.j*v2.k - v2.j*v1.k), -1*(v1.i*v2.k - v2.i*v1.k), (v1.i*v2.j - v2.i*v1.j));
return GVector2DMakeWithK(0, 0, (v1.i*v2.j - v2.i*v1.j));
}


GVector2D GVector2DCrossWithKUnitPositive(GVector2D v1) {
//return GVector2DMakeWithK((v1.j*v2.k - v2.j*v1.k), -1*(v1.i*v2.k - v2.i*v1.k), (v1.i*v2.j - v2.i*v1.j));
return GVector2DMake((v1.j*1), -1*(v1.i*1));
}

GVector2D GVector2DCrossWithKUnitNegtive(GVector2D v1) {
//return GVector2DMakeWithK((v1.j*v2.k - v2.j*v1.k), -1*(v1.i*v2.k - v2.i*v1.k), (v1.i*v2.j - v2.i*v1.j));
return GVector2DMake((v1.j*-1), -1*(v1.i*-1));
}


float GVector2DAngleBetween(GVector2D v1, GVector2D v2) {
float m1 = GVector2DGetMag(v1);
float m2 = GVector2DGetMag(v2);
float d = GVector2DDot(v1, v2);
float angle = acosf(d/(m1*m2));
GVector2D cross = GVector2DCross(v1, v2);
    if(cross.k < 0) {
    angle = -angle;
    }
return angle;
}


/**
 * rotate the vector. in degrees. notice that this function takes a reference, not a value.
 *
 */
void GVector2DRotateDegrees(GVector2D *v, float ang) {
float iO = v->i;
float jO = v->j;
float a = 0.017453*ang;
    
v->i = iO*cosf(a) - jO*sinf(a);
v->j = iO*sinf(a) + jO*cosf(a);
}


/**
 * project v1 onto v2
 *
 */
float GVector2DProj(GVector2D v1, GVector2D v2) {
return GVector2DDot(v1, v2)/GVector2DGetMag(v2);
}


GVector2D GVector2DPlus(GVector2D v1, GVector2D v2) {
return GVector2DMake(v1.i + v2.i , v1.j + v2.j);
}


GVector2D GVector2DMinus(GVector2D v1, GVector2D v2) {
return GVector2DMake(v1.i - v2.i , v1.j - v2.j);
}


void GVector2DRescale(GVector2D *v, float sc) {
v->i *= sc;
v->j *= sc;
}

GVector2D GVector2DGetRescale(GVector2D v, float sc) {
GVector2D newVec;
newVec.i = v.i*sc;
newVec.j = v.j*sc;
return newVec;
}


GVector2D GVector2DClone(GVector2D v, float newMag) {
float m = GVector2DGetMag(v);
GVector2D newVec;
    if(m != 0) {
    newVec.i = newMag*v.i/m;
    newVec.j = newMag*v.j/m;
    } else {
    newVec.i = 0.7071;
    newVec.j = 0.7071;
    }
return newVec;
}

