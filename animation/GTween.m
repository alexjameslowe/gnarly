//
//  GTween.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/13/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GTween.h"
#import "GSprite.h"
#import "GAnimation.h"
#import "GTweenInfo.h"


@implementation GTween

static NSString *DEBUG_NAME;

//ANIMATION_TESTS_9583
//static int numTweensAllocated = 0;
/////////////////

@synthesize isFirst,isLast;

@synthesize name;

@synthesize parentGroup;

@synthesize animationCurrentCode;

@synthesize equation;

@synthesize delay,dur,delayCnt,pos;

@synthesize goal,startPoint,interval;

@synthesize startEvt,endEvt;

@synthesize startTarg,endTarg;

@synthesize nextTween,prevTween,nextSequence,prevSequence,prevSibling,nextSibling;

@synthesize goalMode;

@synthesize goalModeFromOrTo;

@synthesize isFinished;


+ (void) debugNameForTween:(NSString *)debugName {
    DEBUG_NAME = debugName;
}

- (id) initWithTarget:(GNode *)targ easing:(NSString *)ease delay:(int)del duration:(int)duration goal:(float)animationGoal {
    
    self = [super init];
    
    NSString *es = @"GEase_";
    GEaseEquation *eq = [[NSClassFromString([es stringByAppendingString:ease]) alloc] init];
    
    isFinished   = NO;
    equation     = eq;
    goal         = animationGoal;
    pos          = 0;
    delay        = del;
    dur          = duration;
    self.target  = targ;
    
    numTimesRelease = 0;
    
    targetWasDestroyed = NO;
    
    name = DEBUG_NAME;
    
    //ANIMATION_TESTS_9583
    //numTweensAllocated++;
    /////////////////
    
    return self;
    
}


+ (GTween *) tweenProp:(NSString *)prop 
            duration:(int)dur 
               delay:(int)del 
                 goal:(float)goal
              easing:(NSString *)ease
          withTarget:(GNode *)targ {
            
NSString *nm = @"GTween_";
NSString *es = @"GEase_";

GTween *twn = [[NSClassFromString([nm stringByAppendingString:prop]) alloc] init];
GEaseEquation *eq = [[NSClassFromString([es stringByAppendingString:ease]) alloc] init];

twn.isFinished   = NO;
twn.equation     = eq;
twn.goal         = goal;
twn.pos          = 0;
twn.delay        = del;
twn.dur          = dur;
twn.target       = targ;

//twn.startPoint   = [twn getStartPoint];
//twn.interval     = goal - twn.startPoint;

return twn;
}

/*
+ (GTween *) tweenProp:(NSString *)prop
              duration:(int)dur
                 delay:(int)del
                   end:(float)goal
                easing:(NSString *)ease
            withTarget:(GNode *)targ {
    
    NSString *nm = @"GTween_";
    NSString *es = @"GEase_";
    
    GTween *twn = [[NSClassFromString([nm stringByAppendingString:prop]) alloc] init];
    GEaseEquation *eq = [[NSClassFromString([es stringByAppendingString:ease]) alloc] init];
    
    twn.isFinished   = NO;
    twn.equation     = eq;
    twn.endPoint     = goal;
    twn.pos          = 0;
    twn.delay        = del;
    twn.dur          = dur;
    twn.target       = targ;
    
    //twn.startPoint   = [twn getStartPoint];
    //twn.interval     = goal - twn.startPoint;
    
    return twn;
}
*/


- (void) setStartAndDeltaValuesFromModeTween {
    
    //So, if FROM, then we're going to take the end-point as the current-point
    //and the goal parameter, we're going to treat that as the start-point. so
    //so notice that we're going to start the tween from that start-point manually
    //with the call to 'run'.
    if(goalModeFromOrTo) {

        float currentPoint = [self getStartPoint];
        
        //if we're in absolute-mode, then the endpoint is just the endpoint
        if(goalMode == 0) {
        startPoint = goal;
        endPoint = currentPoint;
        [self run:startPoint];
            
        interval = endPoint - startPoint;
        }
        
        //else we're in relative mode, so we're going to re-adjust the endpoint.
        //the value that the tween was initialized with we're going to treat as a delta.
        else
        if(goalMode == 1) {
        startPoint = currentPoint+goal;
        endPoint = currentPoint;
        [self run:startPoint];
            
        interval = endPoint - startPoint;
        }
        
    }
    
}


/**
 * this is so that when an animation begins, it will caculate the starting point and interval.
 *
 */

- (void) setStartAndDeltaValuesToModeTween {
    
    if(!goalModeFromOrTo) {
    
    float currentPoint = [self getStartPoint];
    
        //if we're in absolute-mode, then the endpoint is just the endpoint
        if(goalMode == 0) {
        startPoint = currentPoint;
        endPoint = goal;
            
        interval = endPoint - startPoint;
        }
        
        //else we're in relative mode, so we're going to re-adjust the endpoint.
        //the value that the tween was initialized with we're going to treat as a delta.
        else
        if(goalMode == 1) {
        startPoint = currentPoint;
        endPoint = currentPoint+goal;

        interval = endPoint - startPoint;
        }
        
    }

}

/*
- (void) setStartAndDeltaValues {
    float currentPoint = [self getStartPoint];
    
    //if we're in absolute-mode, then the endpoint is just the endpoint
    if(goalMode == 0) {
        
        //the goal mode can also be FROM or TO.
        //So, if FROM, then we're going to take the end-point as the current-point
        //and the goal parameter, we're going to treat that as the start-point. so
        //so notice that we're going to start the tween from that start-point manually
        //with the call to 'run'.
        if(goalModeFromOrTo) {
        startPoint = goal;
        endPoint = currentPoint;
        [self run:startPoint];
        }
        //else, if TO
        else {
        startPoint = currentPoint;
        endPoint = goal;
        }
        
    interval = endPoint - startPoint;
    }
    
    //else we're in relative mode, so we're going to re-adjust the endpoint.
    //the value that the tween was initialized with we're going to treat as a delta.
    else
        if(goalMode == 1) {
            
            //the goal mode can also be FROM or TO.
            //notice that we're going to start the tween from
            //that start-point manually with the call to 'run'.
            //So, if FROM
            if(goalModeFromOrTo) {
            startPoint = currentPoint+goal;
            endPoint = currentPoint;
            [self run:startPoint];
            }
            //else, if TO
            else {
            startPoint = currentPoint;
            endPoint = currentPoint+goal;
            }
            
        interval = endPoint - startPoint;
        }
    
    //else, we're in ratio mode, which is another flavor of relative. we're going
    //to re-adjust the endpoing, and this time we're going to treat the end-value
    //from the initialization as a ratio to apply to the starting point.
    //else
    //if(goalMode == 2) {
    //endPoint = startPoint*(1 + endPoint);
    //interval = endPoint - startPoint;
    //}
    
}
*/



/**
 * put together a tween info object.
 *
 */
- (GTweenInfo *) getInfoObject {

GNode *animationTarget = self.target;
    BOOL isTargetAlive = animationTarget.animationLayer_nodeWasDestroyed;
GTweenInfo *tweenInfo = [[GTweenInfo alloc] initWithTarget:animationTarget isTargetAlive:isTargetAlive];
    
return tweenInfo;
}



/**
 * reset the tween. reset the important values so that the thing will just start off
 * again right from the beginning.
 *
 */
- (void) reset {
pos = 0;
delayCnt = 0;
isFinished = NO;
}


/**
 * the expected behavior for a tween reversal is that it will take the same time
 * to go backwards as it does forwards. So the duration on the way back should be
 * exactly what the position of the tween is currently at.
 *
 */
- (void) reverse {
dur = pos;
endPoint = startPoint;
startPoint = [self getStartPoint];
delayCnt = 0;
isFinished = NO;
interval = endPoint - startPoint;
}



/////////////
//         //
//  A P I  //
//         //
/////////////



/**
 * run the animation. the position needs to be incremented in all tweens which extend Tween.
 *
 */
- (void) run:(float)val {}



/**
 * override this in the implementation for the individual tweens.
 *
 */
- (float) getStartPoint {
return 0;
}



/**
 * override this in the implementation to set what kind of target you want you 
 * can type-cast it to GSprite for example, if your run function needs to alter the
 * frame property.
 *
 */
- (GNode *) target {
return nil;
}
- (void) setTarget:(GNode *)targ {}

- (void) setTargetWasDestroyed {
targetWasDestroyed = YES;
}


/**
 * clean up. the only objects alloc'ed for this is object is the equation, and possibly the tweenSetOwner.
 *
 */
- (void) dealloc {
    
    if(!targetWasDestroyed) {
        if(self.target.animationLayer_passiveAnimationChange) {
        self.target.animationLayer_numberOfTweensInPassiveAlteration--;
            if(self.target.animationLayer_numberOfTweensInPassiveAlteration <= 0) {
            self.target.animationLayer_numberOfTweensInPassiveAlteration = 0;
            self.target.animationLayer_passiveAnimationChange = NO;
            }
        }
    }

   [equation release];
    
    //ANIMATION_TESTS_9583///////////
    //comment this in so that you can see the GNode objects deallocate.
    //numTweensAllocated--;
    //NSLog(@"GTween deallocing. %@%@%i%@%@",NSStringFromClass([self class]),@"  number of tweens alive: ",numTweensAllocated,@" name:",name);
    /////////////////////////////////////
    

    //#if gDebug_LogDealloc == gYES
    //NSLog(@"dealloc: GTween");
    //#endif
	
[super dealloc];

}

@end



/**
 * different kinds of tweens. if you need a new one, just add it in, and make sure
 * that you follow the convention of '_'+property-name.
 *
 */
@implementation GTween_x

- (void) run:(float)val {
gNodeTarg.x = val;
}
- (float) getStartPoint {
return gNodeTarg.x;
}
- (void) setTarget:(GNode *)targ {
gNodeTarg = targ;
}
- (GNode *) target {
return gNodeTarg;
}

@end

@implementation GTween_y 

- (void) run:(float)val {
gNodeTarg.y = val;
}
- (float) getStartPoint {
return gNodeTarg.y;
}
- (void) setTarget:(GNode *)targ {
gNodeTarg = targ;
}
- (GNode *) target {
return gNodeTarg;
}

@end

@implementation GTween_opacity

- (void) run:(float)val {
gNodeTarg.opacity = val;
}
- (float) getStartPoint {
return gNodeTarg.opacity;
}
- (void) setTarget:(GNode *)targ {
gNodeTarg = targ;
}
- (GNode *)target {
return gNodeTarg;
}



@end

@implementation GTween_rotation

- (void) run:(float)val {
gNodeTarg.rotation = val;
}
- (float) getStartPoint {
return gNodeTarg.rotation;
}
- (void) setTarget:(GNode *)targ {
gNodeTarg = targ;
}
- (GNode *)target {
return gNodeTarg;
}


@end

@implementation GTween_scaleX

- (void) run:(float)val {
gNodeTarg.scaleX = val;
}
- (float) getStartPoint {
return gNodeTarg.scaleX;
}
- (void) setTarget:(GNode *)targ {
gNodeTarg = targ;
}
- (GNode *) target {
return gNodeTarg;
}


@end

@implementation GTween_scaleY

- (void) run:(float)val {
gNodeTarg.scaleY = val;
}
- (float) getStartPoint {
return gNodeTarg.scaleY;
}
- (void) setTarget:(GNode *)targ {
gNodeTarg = targ;
}
- (GNode *) target {
return gNodeTarg;
}


@end

@implementation GTween_scale

- (void) run:(float)val {
gNodeTarg.scaleY = val;
gNodeTarg.scaleX = val;
}
- (float) getStartPoint {
return gNodeTarg.scaleX;
}
- (void) setTarget:(GNode *)targ {
gNodeTarg = targ;
}
- (GNode *) target {
return gNodeTarg;
}

@end



@implementation GTween_frame

- (void) run:(float)val {
gSpriteTarg.frame = floor(val);
}
- (float) getStartPoint {
return (float) gSpriteTarg.frame;
}
- (void) setTarget:(GNode *)targ {
gSpriteTarg = (GSprite *)targ;
}
- (GNode *) target {
return gSpriteTarg;
}

@end


@implementation GTween_red

- (void) run:(float)val {
    gBoxTarg.red = val;
}
- (float) getStartPoint {
    return gBoxTarg.red;
}
- (void) setTarget:(GNode *)targ {
    gBoxTarg = (GBox *)targ;
}
- (GNode *) target {
    return gBoxTarg;
}


@end


@implementation GTween_green

- (void) run:(float)val {
    gBoxTarg.green = val;
}
- (float) getStartPoint {
    return gBoxTarg.green;
}
- (void) setTarget:(GNode *)targ {
    gBoxTarg = (GBox *)targ;
}
- (GNode *) target {
    return gBoxTarg;
}

@end


@implementation GTween_blue

- (void) run:(float)val {
    gBoxTarg.blue = val;
}
- (float) getStartPoint {
    return gBoxTarg.blue;
}
- (void) setTarget:(GNode *)targ {
    gBoxTarg = (GBox *)targ;
}
- (GNode *) target {
    return gBoxTarg;
}

@end


@implementation GTween_time

- (void) run:(float)val {
    //objTarg.blue = val;
}
- (float) getStartPoint {
    return 0;// gBoxTarg.blue;
}
- (void) setTarget:(GNode *)targ {
    gNodeTarg = targ;
}
- (GNode *) target {
    return gNodeTarg;
}

@end
