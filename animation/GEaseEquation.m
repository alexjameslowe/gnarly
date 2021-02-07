//
//  GEaseEquation.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/13/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

//https://github.com/danro/jquery-easing/blob/master/jquery.easing.js
//http://easings.net
//http://www.timotheegroleau.com/Flash/experiments/easing_function_generator.htm
//http://gizma.com/easing/
#import "GEaseEquation.h"

@implementation GEaseEquation

- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
return 0;
}

//- (void) dealloc {
//
//    #if gDebug_LogDealloc == gYES 
//    //NSLog(@"dealloc: GEaseEquation");
//    #endif
//    
//[super dealloc];
//
//}

@end



/**
 * Easing equation function for a simple linear tweening, with no easing.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
@implementation GEase_easeNone

- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
return c*t/d + b;
}

@end

@implementation GEase_easeInCubic

//Easing equation function for a cubic (t^3) easing in: accelerating from zero velocity.
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
//return c*(t/=d)*t*t + b;
t/=d;
return c*t*t*t + b;
}

@end

@implementation GEase_easeOutCubic

//Easing equation function for a cubic (t^3) easing out: decelerating from zero velocity.
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
//return c*((t=t/d-1)*t*t + 1) + b;
t=t/d-1;
return c*(t*t*t + 1) + b;
}

@end

@implementation GEase_easeInOutCubic

//Easing equation function for a cubic (t^3) easing in/out: acceleration until halfway, then deceleration.
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
//if ((t/=d/2) < 1) return c/2*t*t*t + b;
//return c/2*((t-=2)*t*t + 2) + b;
t/=d/2;
    
    if(t < 1) {
    return c/2*t*t*t + b;
    } else {
    t -= 2;
    return c/2*(t*t*t + 2) + b;
    }
    
}

@end

/**
 * Easing equation function for a quadratic (t^2) easing in: accelerating from zero velocity.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
@implementation GEase_easeInQuad

//Easing equation function for a quadratic (t^2) easing in: accelerating from zero velocity. 
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
//return c*(t/=d)*t + b;
t/=d;
return c*t*t + b;
}

@end

/**
 * Easing equation function for a quadratic (t^2) easing out: decelerating to zero velocity.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
@implementation GEase_easeOutQuad

//Easing equation function for a quadratic (t^2) easing out: decelerating to zero velocity.
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
//return -c *(t/=d)*(t-2) + b;
t/=d;
return -c *t*(t-2) + b;
}
		
@end

/**
 * Easing equation function for a quadratic (t^2) easing in/out: acceleration until halfway, then deceleration.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
@implementation GEase_easeInOutQuad

//Easing equation function for a quadratic (t^2) easing in/out: acceleration until halfway, then deceleration.
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
//if ((t/=d/2) < 1) return c/2*t*t + b;
//return -c/2 * ((--t)*(t-2) - 1) + b;
t/=d/2;

    if(t < 1) {
    return c/2*t*t + b;
    } else {
    t--;
    return -c/2 * (t*(t-2) - 1) + b;
    }
    
}

@end

/**
 * Easing equation function for a bounce (exponentially decaying parabolic bounce) easing in: accelerating from zero velocity.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */

@implementation GEase_easeInBounce
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
return c - [self runBounce:0 delta:c time:d-t duration:d];
}

- (float) runBounce:(float)b delta:(float)c time:(float)t duration:(float)d {

    /*
    if ((t/=d) < (1/2.75)) {
    return c*(7.5625*t*t) + b;
    } else if (t < (2/2.75)) {
    return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
    } else if (t < (2.5/2.75)) {
    return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
    } else {
    return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
    }*/
    
    t/=d;
    
    if (t < (1/2.75)) {
    return c*(7.5625*t*t) + b;
    } else if (t < (2/2.75)) {
    t-=(1.5/2.75);
    return c*(7.5625*t*t + .75) + b;
    } else if (t < (2.5/2.75)) {
    t-=(2.25/2.75);
    return c*(7.5625*t*t + .9375) + b;
    } else {
    t-=(2.625/2.75);
    return c*(7.5625*t*t + .984375) + b;
    }
    
}
        
@end

/**
 * Easing equation function for a bounce (exponentially decaying parabolic bounce) easing out: decelerating from zero velocity.
 *
 * @param t		Current time (in frames or seconds).
 * @param b		Starting value.
 * @param c		Change needed in value.
 * @param d		Expected easing duration (in frames or seconds).
 * @return		The correct value.
 */
@implementation GEase_easeOutBounce
	
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
    /*
    if ((t/=d) < (1/2.75)) {
    return c*(7.5625*t*t) + b;
    } else if (t < (2/2.75)) {
    return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
    } else if (t < (2.5/2.75)) {
    return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
    } else {
    return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
    }*/
    
t/=d;
    
    if (t < (1/2.75)) {
    return c*(7.5625*t*t) + b;
    } else if (t < (2/2.75)) {
    t-=(1.5/2.75);
    return c*(7.5625*t*t + .75) + b;
    } else if (t < (2.5/2.75)) {
    t-=(2.25/2.75);
    return c*(7.5625*t*t + .9375) + b;
    } else {
    t-=(2.625/2.75);
    return c*(7.5625*t*t + .984375) + b;
    }
    
}
        
@end


@implementation GEase_easeInBack

- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
    float s= 2.5;//1.70158;
    t/=d;
    return c*t*t*((s+1)*t - s) + b;
}

@end


@implementation GEase_easeOutBack

- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d {
    float s = 2.5;//1.70158;
    t=t/d-1;
    return c*(t*t*((s+1)*t + s) + 1) + b;
}

@end


/**
 
 function(t:Number, b:Number, c:Number, d:Number):Number {
	var ts:Number=(t/=d)*t;
	var tc:Number=ts*t;
	return b+c*(3.0025*tc*ts + -5.6525*ts*ts + -2.7*tc + 9.2*ts + -2.85*t);
 }
 
 
 
 **/


