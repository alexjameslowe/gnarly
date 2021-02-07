//
//  GVector3.m
//  CosmicDolphin_7_5
//
//  Created by Alexander  Lowe on 3/14/13.
//  Copyright (c) 2013 Alex Lowe. See Licence.
//

#import "GVector3.h"

@implementation GVector3

@synthesize i,j,k;

    /**
     * init with the make functions.
     *
     */
    + (GVector3 *)make {
    return [[[GVector3 alloc] init] autorelease];
    }
    + (GVector3 *)makeI:(float)i J:(float)j K:(float)k {
    return [[[GVector3 alloc] initI:i J:j K:k] autorelease];
    }
    + (GVector3 *)makeUnitI {
    return [[[GVector3 alloc] initI:1 J:0 K:0] autorelease];
    }
    + (GVector3 *)makeUnitJ {
    return [[[GVector3 alloc] initI:0 J:1 K:0] autorelease];
    }
    + (GVector3 *)makeUnitK {
    return [[[GVector3 alloc] initI:0 J:0 K:1] autorelease];
    }


 	- (id) init {
 	i = 1;
 	j = 1;
    k = 1;
    return self;
 	}
    - (id) initI:(float)iC J:(float)jC K:(float)kC {
    i = iC;
    j = jC;
    k = kC;
    return self;
    }

    /**
     * get the angle between this and another 3-vector.
     *
     */
    - (float) angleBetween:(GVector3 *)vec2 {
    float m1 = self.mag;
    float m2 = vec2.mag;
    float d = [self dot:vec2];
    float angle = acosf(d/(m1*m2));
        if([self cross:vec2].k < 0) {
        angle = -angle;
        }
    return angle;
    }


    /**
     * rotate around the z axis. ang is in radians.
     *
     */
    - (void) rotateZ:(float)ang {
    float iO = i;
    float jO = j;
        
    i = iO*cosf(ang) - jO*sinf(ang);
    j = iO*sinf(ang) + jO*cosf(ang);
    }



    /**
     * return this dotted with another 3-vector.
     *
     */
    - (float)dot:(GVector3 *)vec3 {
    return i*vec3.i + j*vec3.j + k*vec3.k;
    }
    
    /**
     * return this crossed with another 3-vector.
     *
     */
    - (GVector3 *) cross:(GVector3 *)vec3 {
    return [[[GVector3 alloc] initI:(j*vec3.k - vec3.j*k) J:-1*(i*vec3.k - vec3.i*k) K:(i*vec3.j - vec3.i*j)] autorelease];
    }

    
   /**
    * return new vector resulting from adding vec3 to this one.
    *
    */
    - (GVector3 *) plus:(GVector3 *)vec3 {
    return [[[GVector3 alloc] initI:i+vec3.i J:j+vec3.j K:k+vec3.k] autorelease];
    }
    

   /**
    * return new vector resulting from subtracting vec3 from this one.
    *
    */
    - (GVector3 *)minus:(GVector3 *)vec3 {
    return [[[GVector3 alloc] initI:i-vec3.i J:j-vec3.j K:k-vec3.k] autorelease];
    }
    

   /**
    * rescale the vector.
    *
    */
    - (void)rescale:(float)sc {
    i *= sc;
    j *= sc;
    k *= sc;
    }
    
    
    /**
     * return the magnitude.
     *
     */
    - (float) mag  {
    return sqrtf(i*i + j*j + k*k);
    }
 
    /**
     * set the magnitude.
     *
     */
    - (void)setMag:(float)newMag {
    float m = self.mag;
    
    	if(m != 0) {
    	i = newMag*i/m;
    	j = newMag*j/m;
    	k = newMag*k/m;
    	} else {
    	i = 0.5774;
    	j = 0.5774;
    	k = 0.5774;
    	}
    }
    
    /**
     * return a clone. the newMag is optional. if set, it will 
     * return a vector pointing in the same direction, but with
     * a magnitude of newMag.
     *
     */
    - (GVector3 *)clone {
    return [[[GVector3 alloc] initI:i J:j K:k] autorelease];
    }
    - (GVector3 *)cloneWithNewMag:(float)m {
    GVector3 *v = [[GVector3 alloc] initI:i J:j K:k];
    v.mag = m;
    return [v autorelease];
    }

@end
