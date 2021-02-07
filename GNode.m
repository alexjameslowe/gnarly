//
//  GGroup.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 10/18/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GNode.h"
#import "GPop.h"
#import "GSurface.h"
#import "GDop.h"
#import "GExistence.h"


@implementation GExistenceCounter

@synthesize doesGNodeExist;
@synthesize countOfExistenceWatchers;

- (id) init {
self = [super init];
doesGNodeExist = YES;
countOfExistenceWatchers = 0;
return self;
}

@end



@implementation GNode




//screen dimensions.
static int SCREEN_WIDTH;
static int SCREEN_HEIGHT;
static float CENTER_X;
static float CENTER_Y;
static BOOL ISRETINA;
static float SCREEN_HIRES;

//ANIMATION_TESTS_9583///////////
//comment this in so that you can see the number of nodes in existence.
//int numInst = 0;
/////////////////////////////////////

@synthesize nextCache,prevCache;
@synthesize nextSibling,prevSibling,parent;
@synthesize numChildren;
@synthesize isLast,isFirst,isMainDefault,isRootChild,isCached,isUnglued,prevNextAreUpToDate;
@synthesize x,y,scaleX,scaleY,rotation,opacity;
@synthesize affineInverse;
@synthesize totalWatchTouches;
@synthesize name;

//GLayerMemoryObject
@synthesize isObjectDestroyed;

//bluetooth
@synthesize btMsgId,btMrrId;
@synthesize serveMirror;

//GTouchBehavior protocol property
@synthesize isDelegateARenderableObject;

@synthesize animationLayer_passiveAnimationChange, animationLayer_nodeWasDestroyed;
@synthesize animationLayer_numberOfTweens, animationLayer_animationCurrentCode, animationLayer_numberOfTweensInPassiveAlteration;


+ (void) decrementAndLogNumberOfInstances {
//    numInstances = numInstances-1;
//    NSLog(@"GNode: numInstances:    %i",numInstances);
}


- (id) init {

self = [super init];

    //ANIMATION_TESTS_9583///////////
    //comment this in so that you can see the number of nodes in existence.
    //numInst++;
    //NSLog(@"GNode: init: %@%@%i",self,@" number of nodes: ",numInst);
    /////////////////////////////////////
    
animationLayer_nodeWasDestroyed = NO;
animationLayer_passiveAnimationChange = NO;
animationLayer_numberOfTweens = 0;
animationLayer_animationCurrentCode = 0;
animationLayer_numberOfTweensInPassiveAlteration = 0;
    
_releasedResoucesWasCalled = NO;
    
root = [GSurface getCurrentView];

isRootChild = NO;
isCached = YES;
isUnglued = NO;

totalWatchTouches = NO;

affineInverse = malloc(sizeof(float)*6);
affineInverse[0] = 1;
affineInverse[1] = 0;
affineInverse[2] = 0;
affineInverse[3] = 0;
affineInverse[4] = 1;
affineInverse[5] = 0;
    
affineInverseSafety = YES;

x = 0;
y = 0;
scaleX = 1;
scaleY = 1;
rotation = 0;
opacity = 1;

usePopper = NO;
//usePopOrDop = YES;
usePopOrDop = NO;
    
prevNextAreUpToDate = YES;

popper = [[GPop alloc] initWithOwner:self];
    
existenceWatchersWereIssued = NO;

    //set the private properties
    _screenWidth = SCREEN_WIDTH;
    _screenHeight = SCREEN_HEIGHT;
    _screenCenterX = CENTER_X;
    _screenCenterY = CENTER_Y;
    _screenIsRetina = ISRETINA;
    _screenHiResScale = SCREEN_HIRES;

//this object can act as a touch delegate, but memory management needs to
//know if a given GTouchBehavior object is a renderable object or not, because
//of the management of retain counts.
isDelegateARenderableObject = YES;

    //only cache if this is not being created as the
    //main default parent node.
    if(isMainDefault == NO) {
    [root addToCacheChain:self];
    }
    
[self convertToPop];
next = popper;
popper.prev = self;
    
return self;
}



+ (void) setScreenW:(int)w H:(int)h cX:(float)x cY:(float)y hiResScale:(float)screenHiResScale isRetina:(BOOL)isRetina {
    SCREEN_WIDTH = w;
    SCREEN_HEIGHT = h;
    CENTER_X = x;
    CENTER_Y = y;
    ISRETINA = isRetina;
    SCREEN_HIRES = screenHiResScale;
}



/**
 * do not use this method in practice. This method is only used for a single special box on the root level- the main default
 * parent. This special box is the default parent for all boxes. This is so that there is never a box with a nil parent. 
 * All boxes are guaranteed to have a parent which is also a box. This gets us out of having to have a bunch of conditionals
 * in the rendering code to test for parent existence in order to calculate global transformation numbers as well as visibility
 * and touch sensitivity.
 *
 */
 

- (id) startAsMainDefault:(GSurface *)view {

isMainDefault = YES;

root = view;

return [self init];

}



/**
   http://stackoverflow.com/questions/3402234/properties-in-dealloc-release-then-set-to-nil-or-simply-release
 **/
 

- (void) calcAffine {
    
    if(!parent) {
    return;
    }
    
float rad = 0.01745*rotation;

float sCos = cos(rad);
float sSin = sin(rad);
float sCosScX = sCos/scaleX;
float sSinScX = sSin/scaleX;
float sCosScY = sCos/scaleY;
float sSinScY = sSin/scaleY;

/// HERE'S THE ARRAY WITH THE VALUES.
// [a00  a01 a02 
//  a10  a11 a12]
    
//NSLog(@"calcAffine: pointer: %p%@%@%@%p%@%@",self,
//      @"  class: ",[self class],@" parent: ",parent,@" parent class: ",[parent class]);
 
//float *f = parent.affineInverse;
float *f = *affineInversePointer;
    
//peform all the transformation arithmetic.
affineInverse[0] = sCosScX*f[0] + sSinScX*f[3];
affineInverse[1] = sCosScX*f[1] + sSinScX*f[4];
affineInverse[2] = sCosScX*f[2] + sSinScX*f[5] -sSinScX*y - sCosScX*x;
affineInverse[3] = -sSinScY*f[0] + sCosScY*f[3];
affineInverse[4] = -sSinScY*f[1] + sCosScY*f[4];
affineInverse[5] = -sSinScY*f[2] + sCosScY*f[5] + sSinScY*x - sCosScY*y;

}

/**
 * when an instance is recorded as a parent, then we also need to be able to tell the 
 * child about the pointer to the safety variable.
 *
 */
- (BOOL *) getAffineInverseSafetyPointer {
return &affineInverseSafety;
}
- (float **) getAffineInversePointer {
return &affineInverse;
}



/**
 * coordinate transformations.
 *
 */

- (CGPoint) globalToLocal:(CGPoint)global {
//return CGPointMake( (a00*global.x + a01*global.y + a02), (a10*global.x + a11*global.y + a12) );
return CGPointMake( (affineInverse[0]*global.x + affineInverse[1]*global.y + affineInverse[2]), (affineInverse[3]*global.x + affineInverse[4]*global.y + affineInverse[5]) );
}
- (CGPoint) localToGlobal:(CGPoint)local {
//we would need to calculate a second set of affine coefficients if we wanted to do a local-to-global
//transformation. I don't want the render loop doing all that arithmetic, especially since a need for 
//local-to-global is usually a sign that you should take your project for a walk down code-refactoring lane.
return CGPointMake(0,0);
}



/**
 * these are functions which add/remove a tween from this object.
 * this is for caching purposes only, so that the GAnimation classes
 * can do batch processes on animations on a per-target basis.
 *
 */
/*
- (void) cacheTweenSet:(GTweenSet *)tweenSet {

    if(lastTweenSet) {
    lastTweenSet.nextNodeSet = tweenSet;
    tweenSet.prevNodeSet = lastTweenSet;
    
    lastTweenSet = tweenSet;
    lastTweenSet.nextNodeSet = nil;
    } else {
    firstTweenSet = tweenSet;
    lastTweenSet = tweenSet;
    }

}
- (void) uncacheTweenSet:(GTweenSet *)tweenSet {

    if(tweenSet.prevNodeSet) {
    tweenSet.prevNodeSet.nextNodeSet = tweenSet.nextNodeSet;
    } else {
    firstTweenSet = tweenSet.nextNodeSet;
    }
    if(tweenSet.nextNodeSet) {
    tweenSet.nextNodeSet.prevNodeSet = tweenSet.prevNodeSet;
    } else {
    lastTweenSet = tweenSet.prevNodeSet;
    }
    
tweenSet.nextNodeSet = nil;
tweenSet.prevNodeSet = nil;
}*/



- (GNode *) prevKill {
return prevKill;
}
- (void) setPrevKill:(GNode *)pk {
prevKill = pk;
}
- (GNode *) nextKill {
return nextKill;
}
- (void) setNextKill:(GNode *)nk {
nextKill = nk;
}



/**
 * conveinence functions so that the parent, prevSibling, nextSibling properties can stay read-only.
 *
 * Also, setting the variables directly without using the synthisized accessors is handy because it 
 * will not send a release message to the object that occupied that spot previously.
 * http://stackoverflow.com/questions/3402234/properties-in-dealloc-release-then-set-to-nil-or-simply-release
 *
 *
 */

/*
- (void) setParentRef:(GNode *)par {
parent = par;
affineInverseSafetyPointer = [par getAffineInverseSafetyPointer];
affineInversePointer = [par getAffineInversePointer];
}*/

- (void) setParentRef:(GNode *)par {
    //if(par == nil) {
    //[parent release];
    //parent = nil;
    //} else {
    parent = par;
    affineInverseSafetyPointer = [par getAffineInverseSafetyPointer];
    affineInversePointer = [par getAffineInversePointer];
    //[parent retain];
    //}
}
- (void) setPrevRef:(GNode *)prv {
prevSibling = prv;
}
- (void) setNextRef:(GNode *)nxt {
nextSibling = nxt;
}
- (void) setNextCacheRef:(GNode *)nxt {
nextCache = nxt;
}
- (void) setPrevCacheRef:(GNode *)prv {
prevCache = prv;
}





/**
 * get the last element in the chain of this object, even if it's just a reference to self.
 *
 */

- (GRenderable *) getLast  {
   // if(usePopper == YES) {
   // return popOrDop;
   // } else {
   // return (GRenderable *)self;
   // }
    return popper;
}


/**
 * get the next link after this object's chain.
 *
 */

- (GRenderable *) getNext {
    //if(usePopper == YES) {
    //return popOrDop.next;
    ///} else {
    //return next;
    //}
    return popper.next;

}



/**
 * Manage the first and last children. They are handy references to have around.
 *
 */

- (void) assignFirstChild:(GNode *)first {

    if(firstChild) {
    firstChild.isFirst = NO;
    }
    
firstChild = first;
first.isFirst = YES;
}
- (void) assignLastChild:(GNode *)last {
	
    if(lastChild) {
    lastChild.isLast = NO;
    }
    
lastChild = last;
last.isLast = YES;

}



/**
 * add or remove a child from the chain of prevSibling, nextSibling references.
 * 
 * #NOTE# This is different from the prev/next reference chain. The latter is designed
 * so that the entire tree structure can be read out in a single, non-recursive loop
 * the the GSurface level. the former is designed to give you easy access to sets 
 * of ancestors for batch processes.
 *
 */

- (void) addToSiblingChain:(GNode *)child withPrev:(GNode *)prv andNext:(GNode *)nxt {

    //do not presume that the prevSibling/nextSiblings exist.
    if(prv) {
    [prv setNextRef:child];
    }
    
    if(nxt) {
    [nxt setPrevRef:child];
    }

[child setPrevRef:prv];
[child setNextRef:nxt];

}



/**
 * remove the child from the sibling chain.
 *
 *
 */

- (void) removeFromSiblingChain:(GNode *)child {

    if(child.prevSibling) {
    [child.prevSibling setNextRef:child.nextSibling];
    }
    if(child.nextSibling) {
    [child.nextSibling setPrevRef:child.prevSibling];
    }
    
[child setPrevRef:nil];
[child setNextRef:nil];
}


/**
 * contract. get rid of the dopper, and manage the prev/next chain.
 *
 */
- (void) contract {
 /*   if(numChildren == 0) {
    next = dopper.next;
    next.prev = self;
    usePopper = NO;
    [dopper release];
    dopper = nil;
    } else {
    [self convertToPop];
    //the ob's next sibling is the popper.
    [lastChild getLast].next = popper;
	
	//the popper's previous sibling is the last link
	//in the ob's chain
    popper.prev = [lastChild getLast];
    }
*/

}


/**
 * this is called as soon as the last child has been removed from this object.
 * it converts the popper to the dopper, and the dopper calls contract on this
 * object which will contract this object so that 
 *
 */
- (void) convertToDop {
/*
    //create the dopper if necessary
    if(!dopper) {
    dopper = [[GDop alloc] initWithOwner:self];
    }
    
    //If this object has been removed from the display list, then
    //that means that the prev/next variables are out-of-date, and
    //are not safe to access. They may point to objects that have
    //been deleted or reassigned.
    if(prevNextAreUpToDate == YES) {

    //set the prev next properties.
    dopper.next = popper.next;
    dopper.prev = popper.prev;
        
        //-[Block setPrev:]: message sent to deallocated instance 0x1d58a250

        if(dopper.next) {
        dopper.next.prev = dopper;//popper.next.prev;  //this threw an error ##2014-02-22
        }
        if(dopper.prev) {
        dopper.prev.next = dopper;//popper.prev.next;
        }
        
    }
    
usePopper = YES;
usePopOrDop = NO;
    
popOrDop = dopper;
*/

}
- (void) convertToPop {
    
    //if(dopper) {
    //popper.next = dopper.next;
    //popper.prev = dopper.prev;
    
    //    if(popper.next) {
    //    popper.next.prev = popper;
    //    }
    //    if(popper.prev) {
    //    popper.prev.next = popper;
    //    }
    
    //[dopper release];
    //dopper = nil;
    
    //} else {
    
        //If this object has been removed from the display list, then
        //that means that the prev/next variables are out-of-date, and
        //are not safe to access. They may point to objects that have
        //been deleted or reassigned.
    //    if(prevNextAreUpToDate == YES) {
    //    popper.next = next;
    
    //        if(next) {
    //        next.prev = popper; //-[Block setPrev:]: message sent to deallocated instance 0x1d555b70
    //        }
            
    //   }
    
    //}
    
usePopper = YES;
usePopOrDop = YES;
popOrDop = popper;
}



/**
 * the render function. return the next renderable object.
 *
 */

- (GRenderable *) render {
return next;
}


/**
 * The GSurface needs this function to exist so that it can clear out
 * this object completely no matter what.
 *
 */
- (void) deepDestroy {
    
    if(numChildren > 0) {
    GRenderable *boundary = [self getLast];
    GRenderable *f = self.next;
    GRenderable *f2;
    
    BOOL keepGoing = YES;

        while(keepGoing) {
        f2 = f.next;
               
            if(f2 == boundary) {
            keepGoing = NO;
            }
        
            if(f != self) {
            [f releaseResources]; 
            }
        f = f2;
        }
    
    } else {
        
        //New 2014-02-09 not sure if this will do any good or not.
        if(popper) {
        [popper release];
        popper = nil;
        }
        if(dopper) {
        [dopper release];
        dopper = nil;
        }
        
    }

//destroy all of the resouces associated with this object. 
[self releaseResources];

}



/**
 * This function is called by the GExistence class. It gets called when there are no more existence watchers
 * to watch this node, but the node still exists. In that case, a state variable needs to get reset, and the 
 * existence counter is going to get deallocated and set to nil.
 *
 */
- (void) resetExistence {
existenceWatchersWereIssued = NO;
[existenceCounter release];
existenceCounter = nil;
}




/////////////
//         //
//  A P I  //
//         //
/////////////



/**
 * override this function to return the synchronization data.
 *
 */
/*
- (GMirrorPacket)mirrorOut {
GMirrorPacket g;
g.float1 = x;
g.float2 = y;
return g;
}
*/

/**
 * override this function to do stuff with the synchronization data.
 *
 */
//- (void)mirrorIn:(GMirrorPacket)data {}



/**
 * readonly root ref.
 *
 */
- (GSurface *) root {
return root;
}
- (void) setRoot:(GSurface *)rt {
//take no action
}



/**
 * percent XY getters and setters.
 *
 */
- (float) percentX {
    return percentX;
}
- (float) percentY {
    return percentY;
}
- (void) setPercentX:(float)pX {
percentX = pX;
x = _screenWidth*(pX/100.0f);
}
- (void) setPercentY:(float)pY {
percentY = pY;
y = _screenHeight*(pY/100.0f);
}


/**
 * legacy x and y. these will set and get the xy coords as through 
 * the we're in a pre-retina environment.
 *
 */
- (float) legacyX {
    return x/_screenHiResScale;
}
- (float) legacyY {
    return y/_screenHiResScale;
}
- (void) setLegacyX:(float)lgcyX {
    x = lgcyX*_screenHiResScale;
}
- (void) setLegacyY:(float)lgcyY {
    y = lgcyY*_screenHiResScale;
}


/**
 * you can bind a single pointer to this object, and when this object is destroyed,
 * that pointer will get set to nil, and you can run tests with it without getting 
 * a terrible EXC_BAD_ACCESS error.
 *
 */
//- (void) bindPointer:(GNode *)pointer {
//hasBoundPointer = YES;
//boundPointer = &pointer;
//}
//- (void) clearBoundPointer {
//hasBoundPointer = NO;
//boundPointer = nil;
//}


/**
 * This is the preferred way of testing to see whether a GNode object exists or not.
 * use the test function of the GExistence instance. Note: You are responsible for releasing
 * GExistence instances on your own.
 *
 */
- (GExistence *) getExistence {
    
    if(existenceWatchersWereIssued == NO) {
    existenceWatchersWereIssued = YES;
    existenceCounter = [[GExistenceCounter alloc] init];
    }

return [[GExistence alloc] initWithCounter:existenceCounter andNode:self];
}


/**
 * by default, a GNode's touchBehavior is simply itself.
 * therefore, the these functions will fire at the appropriate
 * time, and you'll be able to do whatever you want. Or, you
 * can build a custom class to act as the touch delegate if
 * you want some other funky thing to happen but you don't want to
 * have more subclasses of game sprites and things.
 *
 *
 */
- (GRenderable *) touchTarget {
return self;
}
- (void) setTouchTarget:(GRenderable *)tTarg {
//take no action.
}
- (void) touchStart:(CGPoint)gamePoint {}

- (void) touchMove:(CGPoint)gamePoint {}

- (void) touchEnd:(CGPoint)gamePoint {}

- (void) touchDouble:(CGPoint)gamePoint {}



/**
 * add a child to the display list. if it's already on the display list, then it 
 * will get swapped to the front. if it's already on a different parent, then it
 * will get reparented to this object.
 *
 */
- (void) addChild:(GNode *)child {

    if(child) {
        
	    //if the object is on the display list,
	    //reparent it.
		if(child.parent) {
        [child removeFromParent];
		}
        
    //uncache this
    [root removeFromCacheChain:child];
	
	//set the parent
	[child setParentRef:self];
	
	//increment.
	numChildren++;
	
	    //handshake. introduce the ends of the chain
        //so they are connected at the next iteration of the loop.
		if(numChildren != 1) {
		
        GRenderable *l = [lastChild getLast];
		child.prev = l;
		l.next = child;
        [self addToSiblingChain:child withPrev:lastChild andNext:nil];
    
		} else {
        
        //set the prev and next.
		child.prev = self;
		next = child;
        [self assignFirstChild:child];
        [self addToSiblingChain:child withPrev:nil andNext:nil];
		}
        
    //the ob's next sibling is the popper.
    [child getLast].next = popper;
	
	//the popper's previous sibling is the last link
	//in the ob's chain
    popper.prev = [child getLast];
    
    [self assignLastChild:child];
    
    //set this so that the child knows that the its prev/next
    //properties are up-to-date with the display list.
    //[child setPrevNextAreUpToDate:YES];
    }


}


/**
 * insert a child into a specific position of the display list. this is safe. index can be negative.
 * will fail over to addChild. 
 * 
 * this thing will put the child at the index. If you specify 0, it will be at the 0th position
 * when this function is through.
 *
 */
- (void) addChild:(GNode *)child at:(int)index {

//grab the reference node.
GNode *ref = [self getChildAt:index];

    //if the reference exists (it's not guaranteed), then 
    //use the addChild:before: function.
    if(ref) {
    [self addChild:child before:ref];
    } else {
    [self addChild:child];
    }
}


/**
 * a simple convenience function so that this child can remove itself regardless
 * if whether or not it's a root child or an ordinary child.
 *
 */
- (void) removeFromParent {
    if(isRootChild == YES) {
    [root removeChild:self];
    } else {
    [parent removeChild:self];
    }
}




/**
 * add a child after the reference node. if ref is nil, then this
 * function will fail over to addChild. if ref does not belong
 * to this object, then this function will take no action.
 *
 */
- (void) addChild:(GNode *)child after:(GNode *)ref {

    if(child.isUnglued == NO) {

        //if the ref exists (it's not guaranteed),
        if(ref) {
        
            //filter out nonsense.
            if(ref.parent == self) {
            
                //if we're supposed to just add it to the back,
                //then we can use the addChild function.
                if(ref.isLast) {
                [self addChild:child];
                } else {
                
                    //create it if it doesn't already exist.
                    if(!popper) {
                    popper = [[GPop alloc] initWithOwner:self];
                    }
                
            
                    //remove and reparent.
                    if(child.parent) {
                    [child removeFromParent];
                    }
                    
                //uncache this
                [root removeFromCacheChain:child];
                
                //perform the handshake.
                GRenderable *childLast = [child getLast];
                GRenderable *refLast = [ref getLast];
                GRenderable *refNext = refLast.next;
                
                childLast.next = refNext;
                    if(refNext) {
                    refNext.prev = childLast;
                    }
                
                refLast.next = child;
                child.prev = refLast;
                
                //add this guy to the sibling chain.
                [self addToSiblingChain:child withPrev:ref andNext:ref.nextSibling];
                
                //use that shit.
                usePopper = YES;
                
                //increment.
                numChildren++;
                    
                //set the parent
                [child setParentRef:self];
                    
                //set this so that the child knows that the its prev/next
                //properties are up-to-date with the display list.
                [child setPrevNextAreUpToDate:YES];
            
                }
        
            } 
        
        } else {
        [self addChild:child];
        }
    
    }

}



/**
 * add a child before the reference node. if ref is nil, then this
 * function will fail over to addChild. if ref does not belong
 * to this object, then this function will take no action.
 *
 */
- (void) addChild:(GNode *)child before:(GNode *)ref {
    
    if(child.isUnglued == NO) {
        
        //the reference child is not guaranteed to exist.
        if(ref) {
            
            //filter out nonsense.
            if(ref.parent == self) {
                
                //remove and reparent.
                if(child.parent) {
                    [child removeFromParent];
                }
                
                //uncache this
                [root removeFromCacheChain:child];
                
                //manage the firstChild thing.
                if(ref.isFirst == YES) {
                    ref.isFirst = NO;
                    child.isFirst = YES;
                    firstChild = child;
                }
                
                //perform the handshake.
                GRenderable *childLast = [child getLast];
                GRenderable *refPrev = ref.prev;
                
                childLast.next = ref;
                ref.prev = childLast;
                
                child.prev = refPrev;
                if(refPrev) {
                    refPrev.next = child;
                }
                
                //add this guy to the sibling chain.
                [self addToSiblingChain:child withPrev:ref.prevSibling andNext:ref];
                
                //use the popper.
                usePopper = YES;
                
                //increment.
                numChildren++;
                
                //set the parent
                [child setParentRef:self];
                
                //set this so that the child knows that the its prev/next
                //properties are up-to-date with the display list.
                [child setPrevNextAreUpToDate:YES];
                
            }
            
        } else {
            [self addChild:child];
        }
        
    }
    
}


/**
 * super simple. just add this guy before the first child.
 * "addInBack" refers to the z-order. if you use this, the child
 * will appear behind all the elements, at the bottom of the z-stack.
 *
 */
- (void) addInBack:(GNode *)child {
[self addChild:child before:firstChild];
}




/**
 * remove a child from the display list.
 *
 *
 */
- (void) removeChild:(GNode *)child {
    
    if(child.isUnglued == NO) {
 
	    //take no action if the object
	    //does not belong to us here.
		if(child.parent == self) {
            
        //cache this
        [root addToCacheChain:child];
        
		//set to null.
        [child setParentRef:nil];
            
		    //if this is the only child on the object.
			if(numChildren == 1) {
            
				//update this state.
				if(child.isLast == YES) {
				child.isLast = NO;		
				}
            
            next = popper;
            popper.prev = self;
                
            //set these guys to nil, because this is the last child
            //to get removed, and so they need to reset.
            lastChild = nil;
            firstChild = nil;
            
		    } else {
		    
		    	//update the lastChild, firstChild references,
                //and manage the properties.
				if(child.isLast == YES) {
				child.isLast = NO;
                lastChild = child.prevSibling;
				lastChild.isLast = YES;
				}
                if(child.isFirst == YES) {
                child.isFirst = NO;
                firstChild = child.nextSibling;
                firstChild.isFirst = YES;
                }
		    
		    //we're going to take the neighbors and introduce
		    //them to each other. that cuts ob right out of the
		    //display list. it can get back on later, or it can die.
            GRenderable *l2 = [child getLast].next;
		    GRenderable *p2 = child.prev;
                
		    	if(l2) {
		    	l2.prev = p2;
		    	}		    	
                if(p2) {
                p2.next = l2;
                }
     
		    }
            
        //remove from the prevSibling/nextSibling reference chain.
        [self removeFromSiblingChain:child];
            
        //set this so that the child knows that the its prev/next
        //properties are NOT up-to-date with the display list.
        //[child setPrevNextAreUpToDate:NO];
        

        //////////////////////////////////////////////////////////////////////////////////
        //OK- SO, These can't get reset to nil, because we might be in the middle of
        //rendering this child, and it will point to nil which means that the following
        //children won't get rendered, and that will cause a push-pop mismatch.
        //child.prev = nil;
        //[child getLast].next = nil;
        //////////////////////////////////////////////////////////////////////////////////
            
		//decrement.
		numChildren--;
		} 

    }

}

- (GNode *)clone {
    return nil;
}



/**
 * get the first child
 *
 */
- (GNode *) getFirstChild {
    return firstChild;
}



/**
 * get the [index]th child of this object. You'll notice that there aren't any
 * arrays of children getting stored in this code. you have to use a loop
 * to access a child at a particular index.
 *
 * you can use negative indices in here- it will wrap around to the back
 * of the children chain. -1 will get the last child, -2 the second-to-last, etc etc.
 *
 */
- (GNode *) getChildAt:(int)index {

GNode *nd = nil;
   
    //filter out nonsense. 
    if(isnan(index) == NO) {
    int targ = index;

        //convert to a positive integer.
        if(index < 0) {
        targ = numChildren + index; 
        }
        
        //filter out nonsense.
        if(targ >= 0 && targ < numChildren) {
        
        int ind = 0;
        nd = firstChild;
            if(!nd) {
            return nil;
            }
        //NSAssert((!nd),@"GNode -> getChildAt: Something has gone wrong. code 0.");
        
        
            //loop, and see throw an error if anything crazy happens.
            while(ind < targ) {
            nd = nd.nextSibling;
            //NSAssert((!nd),@"GNode -> getChildAt: Something has gone wrong. code 1. index: %d",ind);
            ind++;
            }
            
        }
    
    }
    
return nd;
}


/**
 * empty this object of all its children.
 *
 */
- (void) empty {
    
    GNode *firstSib = firstChild;
    GNode *nextSib;

    while(firstSib) {
    nextSib = firstSib.nextSibling;
    [firstSib destroy];
    firstSib = nextSib;
    }
}



/**
 * at any time, you can empty out the tweens with function. this will destroy
 * the tweens. if you want to do complicated things like pausing, reversing,
 * then you have to call the appropriate functions on the GTweenSet objects
 * themselves and take an OOP approach.
 *
 */
/*
- (void) destroyTweens {
GTweenSet *tmp = firstTweenSet;
GTweenSet *nxt;

    while(tmp) {
    nxt = tmp.nextNodeSet;
    [tmp destroy];
    tmp = nxt;
    }

firstTweenSet = nil;
lastTweenSet = nil;
}
*/


/**
 * destroy only the resources available to this object. will not
 * destroy any of the ancestors of this object. if you have any 
 * references that need to be un-retained, do that here, and don't
 * forget to call [super releaseResources] in your override.
 *
 */
- (void) releaseResources {

//set this to yes. When GLayerMemoryObjects are destroyed,
//they have to set this to YES so that all of the layers know
//to begin releasing them when they are encountered.
self.isObjectDestroyed = YES;

//these 4 lines will trigger a passive destruction of all the tweens
//of this object. this and the above isObjectDestroyed is going to
//have to become a single deal some day soon when I make the layer-system formal.
animationLayer_nodeWasDestroyed = YES;
animationLayer_passiveAnimationChange = YES;
animationLayer_animationCurrentCode++;
animationLayer_numberOfTweensInPassiveAlteration = animationLayer_numberOfTweens;
    
_releasedResoucesWasCalled = YES;

free(affineInverse);
  
affineInverseSafety = NO;
  
    if(existenceWatchersWereIssued == YES) {
    existenceCounter.doesGNodeExist = NO;
    }
    
    //if([self retainCount] > 1) {
    //NSLog(@"GNode: releaseResources: self.retainCount > 1: %i",(int)[self retainCount]);
    //NSLog(@"GNode: class: %@",[self class]);
    //}
        
[super releaseResources];
}


/*
////////////////
//Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
- (void) dealloc {
    [GNode decrementAndLogNumberOfInstances];
    //numInstances = numInstances-1;
    //NSLog(@"dealloc: GNode: numInstances: %i",numInstances);
    //NSLog(@"dealloc gnode id: %i%@%i",gnode_id,@"  numInstances: ",numInstances);
    [super dealloc];
}
/////////////////
*/


/**
 * the destruction function. You do not need to override this.
 * If you do override it, the super function must be called.
 * All this has to do is manage the object's chain membership.
 * all of the actual resource reclaimation goes on in the 
 * releaseResources function, so if you want to override that, you can.
 * In theory, you shouldn't have to ever rely on dealloc with Gnarly.
 *
 */
- (void) destroy {
    
    if(isUnglued == NO) {
    
        //remove from the parent object, if necessary.
        if(self.parent) {
        [self removeFromParent];
        }
        
        //remove from cache chain, if neccessary.
        if(isCached == YES) {
        [root removeFromCacheChain:self];
        isCached = NO;
        }
        
    isUnglued = YES;
        
    //add this object to the GSurface's kill chain.
    [root addToKillChain:self];

    }

}



- (void) dealloc {
    
    //NSLog(@"HEY!");
    
    //ANIMATION_TESTS_9583///////////
    //comment this in so that you can see the GNode objects deallocate.
    //numInst--;
    //NSLog(@"GNode deallocing %@%@%i",self,@" number of nodes: ",numInst);
    /////////////////////////////////////
    
    if(!_releasedResoucesWasCalled) {
        NSLog(@"###ATTENTION!! ###ATTENTION! WE HAVE AN EARLY RELEASE HERE! %@",self);
    }
    
    //NSLog(@"DEALLOCING!! %@",[self class]);
    [super dealloc];
}

@end
