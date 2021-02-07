//
//  GMath.m
//  RidiculousMissile3
//
//  Created by Alexander  Lowe on 5/17/11.
//  Copyright 2011 Codequark. See Licence.
//

#import "GMath.h"


///////////////////////////////////////
//                                   //
//   Miscellaneous math utilities.   //
//                                   //
///////////////////////////////////////


@implementation GMath




/**
 * returns a random float between two boundaries.
 *
 */
+ (float) randomFloatFrom:(float)floor To:(float)ceiling {
    return  (ceiling - floor)*(arc4random() % 100)*0.01 + floor;
}


/**
 * returns a random integer between two boundaries.
 *
 */
+ (int) randomIntFrom:(int)flr To:(int)ceiling {
return round([GMath randomFloatFrom:flr To:ceiling]);
}

/*
+ (float) floatSkew:(float)rat from:(float)floor To:(float)ceiling {
    if(rat < 0 || rat > 1) {
    [NSException raise:@"Error" format:@"GMath: floatSkew: the ratio %f%@",rat,@" is out of range"];
    }
float rand01 = (arc4random() % 100)*0.01;
//y = x + (1-x)*(x^0.5)*skew
float skew = rand01 + (1-rand01)*(pow(rand01,(0.5)))*rat;
return  (ceiling - floor)*skew + floor;
}

+ (float) intSkew:(float)rat from:(float)floor To:(float)ceiling {
    if(rat < 0 || rat > 1) {
        [NSException raise:@"Error" format:@"GMath: intSkew: the ratio %f%@",rat,@" is out of range"];
    }
    float rand01 = (arc4random() % 100)*0.01;
    float skew = rand01 + (1-rand01)*(pow(rand01,(0.5)))*rat;
    return  roundf((ceiling - floor)*skew + floor);
}
*/



/**
 * these use some clever functions to skew a random variable towards the floor or
 * ceiling. the ratio in the first argument is the skewing paramter, [0,1] (inclusive).
 * when it's near 0, all random numbers will tend toward zero. Near 0.5, the random
 * numbers will be about equal. Near 1, all the random numbers will tend towards 1.
 *
 *
 */
+ (float) floatSkew:(float)rat from:(float)floor To:(float)ceiling {
    if(rat < 0 || rat > 1) {
    [NSException raise:@"Error" format:@"GMath: floatSkew: the ratio %f%@",rat,@" is out of range"];
    }
    
float ratio = 2*rat - 1;
float skew;
float rand01 = (arc4random() % 100)*0.01;
    
    if(ratio < 0) {
    ratio = -ratio;
    //skew towards the floor. y = x - (1-x^2)*x*skew
    //you can increase the effect of the skewing towards the floor by increasing the exponent.
    skew = rand01 - (1-powf(rand01,2)*rand01)*rat;
    } else {
    //skew towards the ceiling. y = x + (1-x)*(x^0.5)*skew
    //you can increase the effect of the skewing towards the ceiling by decreasing the exponent. (> 0)
    skew = rand01 + (1-rand01)*(powf(rand01,(0.5)))*rat;
    }
    
return (ceiling - floor)*skew + floor;
}

+ (int) intSkew:(float)rat from:(float)floor To:(float)ceiling {
    if(rat < 0 || rat > 1) {
    [NSException raise:@"Error" format:@"GMath: intSkew: the ratio %f%@",rat,@" is out of range"];
    }
    
float ratio = 2*rat - 1;
float skew;
float rand01 = (arc4random() % 100)*0.01;
    
    if(ratio < 0) {
    ratio = -ratio;
    //skew towards the floor. y = x - (1-x^2)*x*skew
    //you can increase the effect of the skewing towards the floor by increasing the exponent.
    skew = rand01 - (1-powf(rand01,2)*rand01)*rat;
    } else {
    //skew towards the ceiling. y = x + (1-x)*(x^0.5)*skew
    //you can increase the effect of the skewing towards the ceiling by decreasing the exponent. (> 0)
    skew = rand01 + (1-rand01)*(powf(rand01,(0.5)))*rat;
    }
    
return round((ceiling - floor)*skew + floor);
}


/**
 * for angular animation. for a starting angle animating to an ending angle.
 * this will figure out what the delta d should be such that the starting angle + d = ending angle.
 * This function assumes nothing about the starting and ending angles. They can be on the interval
 * [-Infinity Infinity].
 *
 * Ok- this is a really good function. Actually, I think this is the first time I've ever nailed this
 * terrible rotation dilemma. It is a notoriously difficult riddle to undo. This should find its way
 * into every client-side library I ever write. sheee-yit.
 *
 * startAng and endAng are both in degrees.
 *
 */
+ (float) getDeltaAngleFrom:(float)startAng To:(float)endAng {
    
    float start = startAng;
    float end = endAng;
    float start360Pileup = 0;
    
    if(start > 360) {
        while(start > 360) {
            start -= 360;
            start360Pileup += 360;
        }
    } else
        if(start < 0) {
            while(start < 0) {
                start += 360;
                start360Pileup -= 360;
            }
        }
    if(end > 360) {
        while(end > 360) {
            end -= 360;
        }
    } else
        if(end < 0) {
            while(end < 0) {
                end += 360;
            }
        }
    
    float endM360 = end-360;
    float endP360 = end+360;
    float endPlusPileOn;
    float dA1 = fabsf(end-start);
    float dA2 = fabsf(endM360-start);
    float dA3 = fabsf(endP360-start);
    
    if(dA1<dA2) {
        if(dA1<dA3) {
            //dA1 is smallest
            endPlusPileOn = end + start360Pileup;
            return endPlusPileOn - startAng;
        } else {
            //dA3 is smallest
            endPlusPileOn = endP360 + start360Pileup;
            return endPlusPileOn - startAng;
        }
    } else {
        if(dA2<dA3) {
            //dA2 is smallest
            endPlusPileOn = endM360 + start360Pileup;
            return endPlusPileOn - startAng;
        } else {
            //dA3 is smallest
            endPlusPileOn = endP360 + start360Pileup;
            return endPlusPileOn - startAng;
        }
    }
}



/**
 * is a number within a tolerance of another number? 
 *
 */
+ (BOOL) isNumber:(float)num withinTolerance:(float)tol of:(float)targ {
float t = tol*targ;

    if(num > targ - t && num < targ + t) {
    return YES;
    }

return NO;
}


/**
 * returns a code for which quadant we're in. 
 * 0 means x+, y+.
 * 1 means x+, y-.
 * 2 means x-, y-.
 * 3 means x-, y+.
 * 4 means on x axis.
 * 5 means on y axis.
 * 6 means at origin.
 *
 */
+ (int) resolveQuadrantFromX:(float)x andY:(float)y {

    if(x == 0 && y == 0 ) {
    return 6;
    }
    if(y == 0) {
    return 4;
    }
    if(x == 0) {
    return 5;
    }

    //means we're either in quadrant 0 or quadrant 2.
    if(x/y > 0) {

        if(x > 0) {
        return 0;
        } else {
        return 2;
        }
    
    } else {
    //means we're either in quadrant 0 or 3.
    
        if(x > 0) {
        return 1;
        } else {
        return 3;
        }
    
    }


}


/**
 * returns y as a function of x using a point with a slope. A handy function. should be in some geometry package.
 *
 */
+ (float) yFuncX:(float)input fromPoint:(CGPoint)pt andSlope:(float)slope {
    return (slope*(pt.x - input) + pt.y);
}

/**
 * returns the intersection of two lines defined by two points and two slopes.
 *
 */
+ (CGPoint) getIntersectionFrom:(CGPoint)pt0 fromSlope:(float)slope0 And:(CGPoint)pt1 andSlope:(float)slope1 {
    
    if(slope0 == slope1) {
        return CGPointMake(NAN, NAN);
    } else {
        float intX = (pt1.y - pt0.y + slope0*pt0.x - slope1*pt1.x)/(slope0 - slope1);
        float intY = pt0.y + slope0*intX - slope0*pt0.x;
        return CGPointMake(intX, intY);
    }
    
}



+ (CGPoint) getIntersectionFromPt00:(CGPoint)pt00 Pt01:(CGPoint)pt01 AndPt10:(CGPoint)pt10 andPt11:(CGPoint)pt11 {

float slope0 = (pt01.y - pt00.y)/(pt01.x - pt00.x);
float slope1 = (pt11.y - pt10.y)/(pt11.x - pt10.x);
    
    if(slope0 == slope1) {
    return CGPointMake(NAN, NAN);
    } else {
    float intX = (pt10.y - pt00.y + slope0*pt00.x - slope1*pt10.x)/(slope0 - slope1);
    float intY = pt00.y + slope0*intX - slope0*pt00.x;
    return CGPointMake(intX, intY);
    }
    
}




/**
 * assuming we're dealing with a [0 360] system and that the start and the
 * end are within a single rotation, this will return transition-friendly
 * start and end rotations in a CGPoint x=start y=end.
 *
 */

+ (CGPoint) normalizeRotationFrom:(float)start To:(float)end {
    
CGPoint pt;

  //////////////////////////////////////////////////////////////////////
  //if end,start are the same sign, then start it in the [0 360] system.
  if(fabsf(end + start) > fabsf(end)) {
    
  //////////////////////////
  //perform the conversion.
  pt = [GMath convertTo0_360:CGPointMake(start, end)];
  
      ////////////////////////////////////////////////////////////////
      //if it straddles the discontinuity in the [0 360] system, then
      //convert it to [-180 180] and return.
      //if(fabsf(pt.y - pt.x) > 180) {
      if(fabs(pt.y - pt.x) > 180) {
      return [GMath convertTo_neg180_pos180:pt];
      } 
      //////////////////////////////////
      //else, return the [0 360] coords.
      else {
      return pt;
      }
      
  } 
  ////////////////////////////////////////////////////////////////////////
  //if they are different in sign, then start it in the [-180 180] system.
  else {
      
  /////////////////////////
  //perform the conversion.
  pt = [GMath convertTo_neg180_pos180:CGPointMake(start, end)]; 
  

      ////////////////////////////////////////////////////////////////
      //if it straddles the discontinuity in the [-180 180] system, then
      //convert it to [0 360] and return.    
      //if(fabsf(pt.y - pt.x) > 180) {
      if(fabs(pt.y - pt.x) > 180) {
      return [GMath convertTo0_360:pt];
      } 
      //////////////////////////////////
      //else, return the [-180 180] coords.      
      else {
      return pt;
      }
      
   }
  
}


+ (CGPoint) convertTo0_360:(CGPoint)pt {
    
float end = pt.y;
float start = pt.x;

    if(start < 0) {
    start += 360;
    } else
    if(start >= 360) {
    start -= 360;
    }
    if(end < 0) {
    end += 360;
    } else
    if(end >= 360) {
    end -= 360;
    }

return CGPointMake(start, end);
}

+ (CGPoint) convertTo_neg180_pos180:(CGPoint)pt {
    
    float end = pt.y;
    float start = pt.x;
    
    if(start < -180) {
    start += 360;
    } else 
    if(start > 180) {
    start -= 360;
    }
    if(end < -180) {
    end += 360;
    } else 
    if(end > 180) {
    end -= 360;
    }
    
return CGPointMake(start, end);
}




@end
