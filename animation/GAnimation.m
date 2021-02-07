//
//  GLEasing.m
//  TankGame11
//
//  Created by Alexander  Lowe on 5/25/09.
//  Copyright 2009. See Licence.
//

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  The current work gave us some really good stuff. A lot of the nasty logic is contained in GTweenGroup.
//
//  The render-loop for this layer is a chain of GTween objects, chained by nextTween,prevTween.
//  Groups are not represented by dummy objects in the render-loop. This is in contrast to the render code for OpenGL.
//  Within a group, tweens and tween objects are chained by prevSibling, nextSibling.
//
//  Tweens cannot be sequentially connected. Only Groups can be sequentially connected.
//  A group can only have one sequential connection. In a chain of 5 sequential groups, each one only knows about its neighbor.
//  If a group has a sequential connection then it’s connected with the nextSequence/prevSequence properties.
//
//  Next steps:
//  1) Right now there’s a hook so that you can return an animation object. Then later on at you leisure you can call the pause function on it.
//  So this opens up a world of per-tween-object commands.
//
//  2) The above returned objects need to hook into memory management.
//
//  3) Things like loopable tweens.
//
//  4) Parameterizable tween-templates.
//
//
//  all of the tween object should be stored on separate chains for destruction, just like how GNodes are.
//  It’s way easier if the destruction loop is different from the render loop, because then we won’t have to worry about hunting down all of the sequence
//  groups.
//
//  to make a structure repeatable, we need to have prev-next and then _prev,_next and when one disassociated from one it migrates to the other. That way
//  when the animation structure is complete everything’s ready to loop again with the _prev,_next references.
//
//  I want to be able to do things like this:
//
//  [a openGroupAndLoop:10]
//
//  [a closeGroup]
//
//  and the group will loop 10 times. and then inside there, you can get it to take the iteration as a parameter and change up what goes on like
//  do even or odd stuff. 
//
//  Another todo: test4_2 is broken. See the AnimationTest surface. test4_2 involves the pause/unpause functions.
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


#import "GTweenGroup.h"
#import "GTween.h"
#import "GAnimation.h"
#import "GBox.h"
#import "GSurface.h"
#import "Gnarly.h"
#import "GEaseEquation.h"
#import "GNode.h"
#import "GTweenStrategy.h"
#import "GTweenInfo.h"
#import "GAnimationAllPools.h"




@implementation GAnimation

/**
 * create the singleton instance of the animation layer.
 *
 */
- (id) init {
    
self = [super init];


    //singleton = self;
    repeatDestructionLoop = NO;
    inDestructionProcess = NO;
    rootTweenGroup = [[GTweenGroup alloc] initWithAutoDestruct:NO andEngine:self];
    rootTweenGroup.isRootTweenGroup = YES;
    rootTweenGroup.name = @"ROOT_TWEEN_GROUP";
    
    animationPools = [[GAnimationAllPools alloc] initWithEngine:self];
    
    inNakedContext = YES;
    addTweensInParallel = YES;
    goalMode = 0;
    goalModeFromOrTo = NO;
    exposurePolicy = 94;
    
return self;
}


- (GTweenGroup *) getRootTweenGroup {
return rootTweenGroup;
}



/**
 * run all of the animation objects.
 *
 */
- (void) runTweens {

//GTween *twn = firstTween;
GTween *twn = rootTweenGroup.firstParallelTween;
GTween *nxt;
BOOL processTween = YES;

//ANIMATION_TESTS_9583///////////
//comment this in so that you can see the number of tweens going on at any time.
//int num = 0;
/////////////////////////////////////
    
    
    while(twn) {
    nxt = twn.nextTween;
    GEaseEquation *eq = twn.equation;
    processTween = YES;
     
    //ANIMATION_TESTS_9583///////////
    //comment this in so that you can see the number of tweens going on at any time.
    //num++;
    /////////////////////////////////////
        
        //a couple of contingencies here.
        //1: the node was destroyed. In that case, there's a couple of different things that can happen
        //      node-destroyed: the animation can continue on as though nothing has happened. it will simply ignore the node.
        //      node-destroyed: all tweens for that node will be destroyed. immediate parent groups of those tweens that have
        //                      on-orphan methods will be called.
        //
        //2: all tweens connected to that node have been called upon to destroy.
        //   in that case, destroy the tweens like usual, and if there is an on-destroy methods
        //   for that tween group, then execute them.
        
        if(twn.target.animationLayer_passiveAnimationChange) {
        GNode *targ = twn.target;
            
            //Ok- this loop encounteres an (targ._animationUpdate != twn.animationUpdate) it's going
            //to eliminate the that tween right here, immediately. Then it's going to tick up an variable
            //called animationUpdateCounter. the node always checks in inside this block to see if the
            //animationUpdateCounter was changed. if it wasn't then that means that the update has gone through
            //and we can turn the _passiveAnimationChange to NO. (unless the node was destroyed in which a case, it will stay at YES).

            if(targ.animationLayer_nodeWasDestroyed) {

            [twn.parentGroup rectifyWithTween:twn andGroup:nil forDestroy:NO];
                
            processTween = NO;
            }
            
            else
            if(targ.animationLayer_animationCurrentCode != twn.animationCurrentCode) {
                
            [twn.parentGroup rectifyWithTween:twn andGroup:nil forDestroy:NO];
                
            processTween = NO;
            }
            
        }
        
        
        if(processTween) {
        
            if(twn.delayCnt < twn.delay) {
                
            twn.delayCnt++;
            
            } else {
                
                //if if the tween is just starting, then send out the start callback, or start event.
                if(twn.pos == 0) {
                    
                    [twn setStartAndDeltaValuesToModeTween];
                    
                    [twn.parentGroup performStartCallback:twn];
                    
                }
                    
            float v = [eq runStart:twn.startPoint delta:twn.interval time:twn.pos duration:twn.dur];
            [twn run:v];
            twn.pos++;
                
                if(twn.pos == twn.dur+1) {
                    
                    if(twn.isFinished == NO) {
                    twn.isFinished = YES;
                    [twn.parentGroup rectifyWithTween:twn andGroup:nil forDestroy:NO];
                    }
                    
                }
                    
            }
            
        }
     
    twn = nxt;
    }
    
    //ANIMATION_TESTS_9583///////////
    //comment this in so that you can see the number of tweens going on at any time.
    //NSLog(@"num-tweens: %i",num);
    /////////////////////////////////////
    
}



/**
 * The cleanup function, called by the GSurface owner.
 * destroy every single tween. only one release should be necessary.
 *
 */
- (void) destroyAllTweens {
    
    if(!inDestructionProcess) {
    inDestructionProcess = YES;
        
    [animationPools destroy];
    animationPools = nil;
        
    GTween *twn = rootTweenGroup.firstParallelTween; //firstTween;
    GTween *nxt;

        while(twn) {
        //loop through only this time we're going to just decrement instead of rendering the animations.
        nxt = twn.nextTween;
            
        [twn.parentGroup rectifyWithTween:twn andGroup:nil forDestroy:NO];
            
        twn = nxt;
            
            //if in the process of decrementing, the first tween is reset, then that means
            //that we have to repeat the loop and keep going until all of the tweens are gone.
            //why does the first tween get reset? haha remember, we have sequence tweens that are
            //going to add themselves into the mix by virtue of the decrement function.
            if(!twn && rootTweenGroup.firstParallelTween) {
            twn = rootTweenGroup.firstParallelTween;
            }
            
        }
        
    }
    
}

+ (GAnimation *) getEngine {
    return [[GSurface getCurrentView] getAnimationLayer];
}


/**
 * a handy hook internally so that we can rapidly tell if we're supposed to expose an animation.
 * a helper function to decode the policy codes.
 *
 */
- (BOOL) isAnimationObjectExposable {
return (exposurePolicy == [GAnimation EXPOSURE_EXPOSE_ANIMATION_AND_AUTO_RENDER] ||
        exposurePolicy == [GAnimation EXPOSURE_EXPOSE_ANIMATION_RENDERING_WILL_WAIT]);
}

- (void) dealloc {
[rootTweenGroup release];
[groupStack release];
[super dealloc];
}



  /////////////
  //         //
  //  A P I  //
  //         //
  /////////////


/**
 * this is for debugging.
 *
 */
- (void) debugNameForGroup:(NSString *)name {
DEBUG_NAME = name;
}


/**
 * Change the appending mode to sequence of parallel. The default is parallel.
 * Groups that are appended in parallel will all run at the same time.
 * Groups that are appended in sequence will run after each other one at a time.
 *
 * NOTE: this option works different depending on the context. If you're within the context of a group,
 * you can set this option once and will hold sway for all the direct children of that group. Below,
 * the second group of animations will come after the first.
 *
 * [GAnimation openGroup];
 *
 *    [GAnimation inSequence];
 *
 *     [GAnimation beginSet:testBox];
 *     [GAnimation animate:@"x"       duration:30 delay:0 end:200 easing:@"easeOutQuad"];
 *     [GAnimation animate:@"y"       duration:30 delay:0 end:200 easing:@"easeOutQuad"];
 *     [GAnimation endSet];
 *
 *     [GAnimation beginSet:testBox];
 *     [GAnimation animate:@"opacity"  duration:30 delay:0 end:0.5 easing:@"easeOutQuad"];
 *     [GAnimation animate:@"rotation" duration:30 delay:0 end:20  easing:@"easeOutQuad"];
 *     [GAnimation endSet];
 *
 * [GAnimation closeGroup];
 *
 *
 * But outside of any group context, this setting will revert back to inParallel when the group
 * closes. Below, these two animations will run in parallel, even though [GAnimation inSequence]
 * is called. The reaseon is that it's getting reset to inParallel the first time endSet is called.
 *
 * [GAnimation inSequence];
 *
 * [GAnimation beginSet:testBox];
 * [GAnimation animate:@"x"       duration:30 delay:0 end:200 easing:@"easeOutQuad"];
 * [GAnimation animate:@"y"       duration:30 delay:0 end:200 easing:@"easeOutQuad"];
 * [GAnimation endSet];
 *
 * [GAnimation beginSet:testBox];
 * [GAnimation animate:@"opacity"  duration:30 delay:0 end:0.5 easing:@"easeOutQuad"];
 * [GAnimation animate:@"rotation" duration:30 delay:0 end:20  easing:@"easeOutQuad"];
 * [GAnimation endSet];
 *
 *
 * NOW, those two animation groups will proceed in sequence, the second coming after the first.
 *
 * [GAnimation beginSet:testBox];
 * [GAnimation animate:@"x"       duration:30 delay:0 end:200 easing:@"easeOutQuad"];
 * [GAnimation animate:@"y"       duration:30 delay:0 end:200 easing:@"easeOutQuad"];
 * [GAnimation endSet];
 *
 * [GAnimation inSequence];
 *
 * [GAnimation beginSet:testBox];
 * [GAnimation animate:@"opacity"  duration:30 delay:0 end:0.5 easing:@"easeOutQuad"];
 * [GAnimation animate:@"rotation" duration:30 delay:0 end:20  easing:@"easeOutQuad"];
 * [GAnimation endSet];
 *
 *
 */
- (void) inSequence {
    addTweensInParallel = NO;
}
- (void) inParallel {
    addTweensInParallel = YES;
}

/**
 * You can only use these functions within the context of [beginSet] [endSet]. They will have no effect anywhere
 * else. What these do is affect the goal-mode.
 * In Absolute Mode, tweening to opacity 0.2 will animate the opacity to 0.2.
 * In Relative Mode, tweening to opacity 0.2 will *add* 0.2 to the current opacity.
 * In Ratio Mode, tweening to opacity 0.2 will *add* 20% to the current opacity. NOT
 *
 */
- (void) goalModeAbsolute {
    goalMode = 0;
}
- (void) goalModeRelative {
    goalMode = 1;
}

/**
 * regardless of whether in absolute or relative mode, we can additionally set another dimension of the goal-mode:
 * "from" or "to" in "to" mode, we take the current position of an object as the start of the animation, and we 
 * then give it a new place to go TO. In "from" mode, we take the current position of an object as the end of the animation
 * and we then give it a new place to start FROM.
 *
 */
- (void) goalModeFrom {
    goalModeFromOrTo = YES;
}
- (void) goalModeTo {
    goalModeFromOrTo = NO;
}

//- (void) goalModeRatio {
//    goalMode = 2;
//}



/**
 * Open or close a group. These should not do anything inside the context of begin-set/end-set. I should write that in.
 *
 *
 */
- (void) openGroup {
inNakedContext = NO;
    
    if(inBeginSetEndSetContext) {
    [NSException raise:@"ERROR" format:@"Syntax Error: openGroup: You can't use this function inside a pair of beginSet/endSet calls"];
    }
    
    if(exposableTweenGroup) {
    [NSException raise:@"ERROR" format:@"Syntax Error: openGroup: You have evidently set the exposure policy to expose a previous animation. But you didn't retrieve it with the exposeAnimation function at the end of the declarative listing. This ain't a pizza joint. If you declare that you want the animation exposed, then you have to come pick it up. You can't just leave us twisting in the wind by the phone like junior prom night 1998. Not that I'm carrying a grudge over that or anything."];
    }
    
    if(!groupStack) {
    groupStack = [[NSMutableArray alloc] init];
    }
    
GTweenGroup *group = [[GTweenGroup alloc] initWithAutoDestruct:(![self isAnimationObjectExposable]) andEngine:self];
    
[groupStack addObject:group];
    
currentTweenGroup = group;
    
currentTweenGroup.name = DEBUG_NAME;

//add this group to the pool, if one exists.
[animationPools addToPool:currentTweenGroup withGroupStackLength:(int)[groupStack count]];

//do two things here. first, we're going to store the current addTweensInParallel
//and then we're going to reset the addTweensInParallel back to YES. We just opened
//up a group, so we want to start out fresh. each level has its own addTweensToParallel setting
//and setting it in one won't affect the others.
group.storedAppendInParallel = addTweensInParallel;
addTweensInParallel = YES;
    
}


- (void) closeGroup {
    
//restore the addTweensInParallel to the stored value. whatever was going on
//in the interior of the group, we're now outside of the group and so we have
//to use the addTweenInParallel setting that pertains to this context.
//addTweensInParallel = currentTweenGroup.storedAppendInParallel;
    
//try to set the engine-wide destroy callback if possible. if there's already a destroy callback
//or if there is no engine-wide callback, then it will take no action. it's polite, see.
//[currentTweenGroup setEngineWideDestroyPolitely:engineWideDestroyCallback withObserver:engineWideDestroyObserver];
    
GTweenGroup *child = currentTweenGroup;
    
    if([groupStack count] > 1) {
        
    //if we're not at the root level, then we're going to just restore the old append-in-parallel option
    //here and then asssign it to the currentTweenGroup, before the reference to that object is reset below.
    addTweensInParallel = currentTweenGroup.storedAppendInParallel;
    currentTweenGroup.appendedInParallel = addTweensInParallel;
        
    GTweenGroup *childGroup = (GTweenGroup *)[groupStack lastObject];
        
    [groupStack removeLastObject];
    GTweenGroup *parentGroup = (GTweenGroup *)[groupStack lastObject];
        
        if(childGroup.groupContainsFromModeTweens) {
        //NSLog(@"childGroup.groupContainsFromModeTweens is firing!!!");
        }
        
    [parentGroup addChildGroup:childGroup];
        
    currentTweenGroup = (GTweenGroup *)[groupStack lastObject];
    }
    
    else {
        
    //if we're at the root tween group, then we're still going to set the append-in-parallel option
    //on the currentTweenGroup, but then we're going to reset that value to YES.
    currentTweenGroup.appendedInParallel = currentTweenGroup.storedAppendInParallel;
    addTweensInParallel = YES;

        
    //assign the root group. it needs to have a parent group in order to keep
    //bubbling logic sane within the GTweenGroup class.
    child.isChildOfRoot = YES;
        
        /*
        if(child.groupContainsFromModeTweens) {
            NSLog(@"??????  groupContainsFromModeTweens");
        GTween *tweenInChildGroup = child.firstParallelTween;
            
            while(tweenInChildGroup) {
            [tweenInChildGroup setStartAndDeltaValuesFromModeTween];
            tweenInChildGroup = tweenInChildGroup.nextTween;
            }
            
        }*/
    [child setStartAndDeltaValuesOnGroupFromModeTweens];
        
    [rootTweenGroup addChildGroup:child];
        
        if([self isAnimationObjectExposable]) {
        exposableTweenGroup = currentTweenGroup;
        }
        
    [groupStack removeLastObject];
    }
    

}

/**
 * a set of procedural functions to help you create animations without the need to code all the data into a string.
 * this one begins a set of animations for a single target.
 *
 *  [GAnimation beginSet:someTarg];
 *  [GAnimation animate:@"x" duration:100 delay:0 end:300 easing:@"easeInOutQuad"];
 *  [GAnimation animate:@"y" duration:200 delay:8 end:200 easing:@"easeInOutQuad"];
 *  [GAnimation onStart:@"someFunc" startObs:someObs onEnd:@"someOtherFunc" onEndObs:someOtherObs];
 *  GTweenSet *set = [GAnimation endSet];
 *
 */
- (void) beginSet:(GBox *)box {
    
    if(inBeginSetEndSetContext == YES) {
    [NSException raise:@"ERROR" format:@"Syntax Error: Wrong! Wrong! Wrong! You can't nest beginSet/endSet calls, or call beginSet/endSet out of order."];
    }
    
[box retain];
[self goalModeAbsolute];
[self goalModeTo];
[self openGroup];
proceduralTarget = box;
inBeginSetEndSetContext = YES;
}

/**
 * end the current procedurally-defined GTweenSet. When we end a tween group, that tween group
 * assumes responsibility for releasing the target.
 *
 */
- (void) endSet {
    
    if(inBeginSetEndSetContext == NO) {
    [NSException raise:@"ERROR" format:@"Syntax Error: Wrong! Wrong! Wrong! You can't nest beginSet/endSet calls, or call beginSet/endSet out of order."];
    }
    
inBeginSetEndSetContext = NO;
[currentTweenGroup takeResponsibilityForReleasingTarget:proceduralTarget];
[self closeGroup];
}



/**
 * set the exposure policy. this should only be set before any procedural groups are called.
 * you can't start an animation group and then call this inside. aint' gonna fly.
 *
 */
- (void) setExposurePolicy:(int)policy {
    if(policy != 92 && policy != 93 && policy != 94) {
    [NSException raise:@"ERROR" format:@"exposurePolicy: policy is not recognized. You entered %i",policy];
    }
exposurePolicy = policy;
}

+ (int) EXPOSURE_EXPOSE_ANIMATION_AND_AUTO_RENDER {
return 92;
}
+ (int) EXPOSURE_EXPOSE_ANIMATION_RENDERING_WILL_WAIT {
return 93;
}
+ (int) EXPOSURE_CONCEAL_ANIMATION_AUTO_RENDER {
return 94;
}

/**
 * expose the animation to the outside world. this function will complain if you're using
 * it wrong, and also it will reset the policy back to EXPOSURE_CONCEAL_ANIMATION_AUTO_RENDER
 *
 */
- (GTweenGroup *) exposeAnimation {

    if([groupStack count] > 0) {
    [NSException raise:@"ERROR" format:@"exposeAnimation. You can't use this function inside any group."];
    } else
    if(![self isAnimationObjectExposable]){
    [NSException raise:@"ERROR" format:@"exposeAnimation. You must set the immediacy-policy to one of the EXPOSE_ANIMATION policies"];
    } else {
    [self setExposurePolicy:[GAnimation EXPOSURE_CONCEAL_ANIMATION_AUTO_RENDER]];
    GTweenGroup *exposedAnimation = exposableTweenGroup;
    exposableTweenGroup = nil;
    return exposedAnimation;
    }
    
[NSException raise:@"ERROR" format:@"exposeAnimation. Unknown error."];
return nil;
}


/**
 * a handy little function. make a timer. this comes in handy in a surprising number of cases.
 *
 */
- (void) timer:(int)duration {
[self animate:@"time" duration:duration delay:0 end:1 easing:@"easeNone"];
}


/**
 * add an animation to the current procedurally-defined GTweenSet.
 *
 *
 */
- (void) animate:(NSString *)prop
        duration:(int)dur
           delay:(int)del
             end:(float)goal
          easing:(NSString *)ease {
        
    //GTween *twn = [GTween tweenProp:prop duration:dur delay:del end:goal easing:ease withTarget:proceduralTarget];
    //twn.animationCurrentCode = proceduralTarget.animationLayer_animationCurrentCode;
    //twn.goalMode = goalMode;
    //[currentTweenGroup addParallelTween:twn];
    
    
    NSString *nm = @"GTween_";
    
    GTween *twn = [[NSClassFromString([nm stringByAppendingString:prop]) alloc]
                   initWithTarget:proceduralTarget
                   easing:ease
                   delay:del
                   duration:dur
                   goal:goal];
    
    twn.animationCurrentCode = proceduralTarget.animationLayer_animationCurrentCode;
    twn.goalMode = goalMode;
    twn.goalModeFromOrTo = goalModeFromOrTo;
    
    [currentTweenGroup addParallelTween:twn];
    
    
}

/**
 * animate, but pass in a self-contained tween strategy
 *
 */
- (void) animate:(GTweenStrategy *)strategy {
[strategy setTarget:proceduralTarget];

[strategy performStrategy];
    
NSMutableArray *arr = [strategy exposeStrategyTweens];
    
    int len = (int)[arr count];
    int i=0;
    
    for(i=0; i<len; i++) {
    GTween *twn = (GTween *)[arr objectAtIndex:i];
    twn.animationCurrentCode = proceduralTarget.animationLayer_animationCurrentCode;
    twn.goalMode = goalMode;
    [currentTweenGroup addParallelTween:twn];
    }
    
[strategy release];
}


/**
 * destroy the tweens related to a target. 
 *
 * This triggers a passive change. All of the old tweens have an out-of-date animationCurrentCode.
 * when they hit the render loop in the engine they're going to get destroyed.
 *
 */
- (void) destroyTweensForTarget:(GBox *)target {
    target.animationLayer_passiveAnimationChange = YES;
    target.animationLayer_animationCurrentCode++;
    target.animationLayer_numberOfTweensInPassiveAlteration = target.animationLayer_numberOfTweens;
}



/**
 * add callbacks to the current procedurally-defined GTweenSet. This step is optional.
 *
 *
 */
- (void) onStart:(NSString *)strt startObs:(id <GLayerMemoryObject>)sObs {

[currentTweenGroup setStartCallback:strt withObserver:sObs];

}
- (void) onEnd:(NSString *)end endObs:(id <GLayerMemoryObject>)eObs {

[currentTweenGroup setEndCallback:end withObserver:eObs];
    
}


/**
 * the pool functions.
 *
 */
- (void) beginPool:(NSString *)poolName {
[animationPools beginPool:poolName];
}
- (void) endPool {
[animationPools endPool];
}
- (void) drainPool:(NSString *)poolName {
[animationPools drainPool:poolName];
}

- (void) pausePool:(NSString *)poolName {
[animationPools pausePool:poolName];
}
- (void) unpausePool:(NSString *)poolName {
[animationPools unpausePool:poolName];
}



///////////////////////
//                   //
//  class-level API  //
//                   //
///////////////////////


/**
 * Or, you can call it statically. this is basically for legacy support. the way to do this going forward
 * is to grab a reference to the surface's animation engine reference with getEngine and then call all your functions.
 *
 */
+ (void) openGroup {
[[GAnimation getEngine] openGroup];
}
+ (void) closeGroup {
[[GAnimation getEngine] closeGroup];
}
+ (void) debugNameForGroup:(NSString *)name {
[[GAnimation getEngine] debugNameForGroup:name];
}
+ (void) beginSet:(GBox *)box {
[[GAnimation getEngine] beginSet:box];
}
+ (void) animate:(NSString *)prop duration:(int)dur delay:(int)del end:(float)goal easing:(NSString *)ease {
[[GAnimation getEngine] animate:prop duration:dur delay:del end:goal easing:ease];
}
+ (void) timer:(int)duration {
[[GAnimation getEngine] timer:duration];
}
+ (void) animate:(GTweenStrategy *)strategy {
[[GAnimation getEngine] animate:strategy];
}
+ (void) onStart:(NSString *)strt startObs:(id <GLayerMemoryObject>)sObs {
[[GAnimation getEngine] onStart:strt startObs:sObs];
}
+ (void) onEnd:(NSString *)end endObs:(id <GLayerMemoryObject>)eObs {
[[GAnimation getEngine] onEnd:end endObs:eObs];
}
+ (void) endSet {
[[GAnimation getEngine] endSet];
}
+ (void) inSequence {
[[GAnimation getEngine] inSequence];
}
+ (void) inParallel {
[[GAnimation getEngine] inParallel];
}
+ (void) goalModeAbsolute {
[[GAnimation getEngine] goalModeAbsolute];
}
+ (void) goalModeRelative {
[[GAnimation getEngine] goalModeRelative];
}
+ (void) goalModeFrom {
[[GAnimation getEngine] goalModeFrom];
}

+ (void) goalModeTo {
[[GAnimation getEngine] goalModeTo];
}

//+ (void) goalModeRatio {
//[[GAnimation getEngine] goalModeRatio];
//}

+ (void) destroyTweensForTarget:(GBox *)target {
[[GAnimation getEngine] destroyTweensForTarget:target];
}
+ (void) setExposurePolicy:(int)policy {
[[GAnimation getEngine] setExposurePolicy:policy];
}
+ (GTweenGroup *) exposeAnimation {
return [[GAnimation getEngine] exposeAnimation];
}


+ (void) beginPool:(NSString *)poolName {
[[GAnimation getEngine] beginPool:poolName];
}
+ (void) endPool {
[[GAnimation getEngine] endPool];
}
+ (void) drainPool:(NSString *)poolName {
[[GAnimation getEngine] drainPool:poolName];
}

+ (void) pausePool:(NSString *)poolName {
[[GAnimation getEngine] pausePool:poolName];
}
+ (void) unpausePool:(NSString *)poolName {
[[GAnimation getEngine] unpausePool:poolName];
}





@end



