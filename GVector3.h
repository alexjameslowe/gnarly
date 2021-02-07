//
//  GVector3.h
//  CosmicDolphin_7_5
//
//  Created by Alexander  Lowe on 3/14/13.
//  Copyright (c) 2013 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>

@interface GVector3 : NSObject {

float i;
float j;
float k;

}

@property (nonatomic, assign) float i,j,k;

+ (GVector3 *)make;
+ (GVector3 *)makeI:(float)i J:(float)j K:(float)k;
+ (GVector3 *)makeUnitI;
+ (GVector3 *)makeUnitJ;
+ (GVector3 *)makeUnitK;


- (id) initI:(float)iC J:(float)jC K:(float)kC;

/**
 * return this dotted with another 3-vector.
 *
 */
- (float)dot:(GVector3 *)vec3;

/**
 * get the angle between this and another vector. radians.
 *
 */
- (float) angleBetween:(GVector3 *)vec2;

/**
 * rotate around the z axis. radians.
 *
 */
- (void) rotateZ:(float)ang;

/**
 * return this crossed with another 3-vector.
 *
 */
- (GVector3 *) cross:(GVector3 *)vec3;

/**
 * return new vector resulting from adding vec3 to this one.
 *
 */
- (GVector3 *) plus:(GVector3 *)vec3;

/**
 * return new vector resulting from subtracting vec3 from this one.
 *
 */
- (GVector3 *)minus:(GVector3 *)vec3;

/**
 * rescale the vector.
 *
 */
- (void)rescale:(float)sc;

/**
 * return the magnitude.
 *
 */
- (float) mag;

/**
 * set the magnitude.
 *
 */
- (void)setMag:(float)newMag;

/**
 * return a clone. the newMag is optional. if set, it will 
 * return a vector pointing in the same direction, but with
 * a magnitude of newMag.
 *
 */
- (GVector3 *)clone;
- (GVector3 *)cloneWithNewMag:(float)m;


@end
