//
//  GTweenGroup.m
//  BraveRocket
//
//  Created by Alexander Lowe on 1/31/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//


#import "GTween.h"
#import "GTweenGroup.h"
#import "GBox.h"
#import "GSurface.h"
#import "Gnarly.h"
#import "GEaseEquation.h"
#import "GNode.h"
#import "GAnimation.h"
#import "GTweenInfo.h"
#import "GAnimationPool.h"

//The basic structure of this animation library is the GTweenGroup (hereafter "Group").
//A Group includes a set of tweens which are all running at the same time. Like an object animating its x,y coordinates while it's opacity fades to zero.
//These tweens
//
//The main thing is that
//

//For the decrement function
//Meditate upon this point: We can have groups within groups within groups nested down to an arbitrary level.
//Now, imagine that during the course of animation, within one of these nested structures, the last tween object in a
//particular group has ended. That may not seem to be of any consequence. But what if its parent group is the last
//element among its siblings? Furthermore, what if IT'S parent group is the last among its siblings? What if every
//single one of the parent groups of that tween is the last among its siblings right up to the root level?
//
//  [group]
//      [group]
//          [group]
//
//              [group]
//              [/group]
//
//              [group]
//              [/group]
//
//          [/group]
//
//          [group]
//
//              [group]
//              [/group]
//
//              [group]
//
//              [Tween A]
//              [Tween B]
//              [Tween C]
//
//              [/group]
//
//          [/group]
//      [/group]
//  [/group]
//
//  So here we see that Tween C is the last tween in this big structure. It's the last tween of the last sub-group of the last sub-group
//  etc. etc. all the way to the root.
//
//  This "Tween C" is special, because if this big group structure has a structure that's supposed to fire sequentially AFTERWARDS, then
//  Tween C is last one, and that's the tween with which we will perform the surgery to join the next sequential group into the
//  animation chain.
//
//  Now you might think to yourself- "hey Alex, why don't you just have empty objects which signify the starting and closing of a group?
//  If a group has a sequential tween, then why don't you just have group object representations in the chain of animations? That way, the
//  group object itself would trigger the next group." See, there would end up being ALOT of these empty group objects, and they would
//  take up ALOT of space in the animation chain. The animation loop would spend unacceptably large amounts of time cranking through
//  grouping placeholders. For that reason, the animation chain is made up of only GTween objects.
//
//  So now you know the lay of the land. You know why the last tween of any group is significant. So, meditating on this issue of the last
//  tween, the critical idea is that if a tween ends, we can't release it without due consideration, ##because it has business with the
//  higher levels of grouping##. The last tween MAY be called upon to facilitate a surgery to bring a sequential tween structure into
//  the fold. It can't do that job if we destroy it too soon. Keep these thoughts in mind as you read further in this function.


// So when you have mixed commands of "add in parallel", "add in sequence" what can you expect to see in your animation?
//
// 0.0 - 0.1 - 0.2
//              |
//               --1.0
//                 |
//                  -- 2.0
//
// The above is analogous to the listing:
// append 0.0 in parallel.
// append 0.1 in parallel.
// append 0.2 in parallel.
// append 1.0 in sequence.
// append 2.0 in sequence.
//
// But now what happens if we add a new tween in parallel? the question we have is- "well, parallel to what?"
//
//
// 0.0 - 0.1 - 0.2 - ##0.3##
//              |
//               --1.0
//                 |
//                  -- 2.0
//
// If you add 0.3 in parallel, it joins the "root" parallel branch. fine, but what if you want it to be in parallel with 2.0?
// In that case, make another subgroup of course!
//
// append 0.0 in parallel.
// append 0.1 in parallel.
// append 0.2 in parallel.
// append 1.0 in sequence.
//
// append subgroup. start subgroup.
//     append in parallel: 2.0
//     append in parallel: 2.1
//     append in parallel: 2.2
// end subgroup.
//
// and the listing would look like:
//
// 0.0 - 0.1 - 0.2
//              |
//               --1.0
//                 |
//                  -- 2.0 - 2.1 - 2.2
//

//  TODO.
//  I still don't have a very good hold on how to reuse a tween structure. It's sort of a one-way-trip.
//  when a tween ends, it excises itself from the chain, and after a while the structure is peppered with
//  tweens that are out-of-chain. We would have to do something where it stores the tweens and groups on separate chains
//  and then when you want to reuse an animation structure, it blasts through the whole animation structure and resets
//  everything. that's the only way. it will have to have an alternate set of links- "permanent links". the prev/nextSibling
//  references changes, but then we need a set of 'permanent' perm_prevSibling/perm_nextSibling links.


@implementation GTweenGroup

@synthesize numOfElements;

@synthesize numberOfTargetRetainsInSubtree, numberOfTargetDestructionFlagsInSubtree;

@synthesize name;

@synthesize isGroupOfRawTweens;

@synthesize lastParallelTween,firstParallelTween;

@synthesize parentGroup, firstParallelGroup, lastParallelGroup;

@synthesize nextInPool, prevInPool;

@synthesize storedAppendInParallel;

@synthesize nextSequence, prevSequence, nextSibling, prevSibling;

@synthesize pool;

@synthesize appendedInParallel;

@synthesize isRootTweenGroup,isChildOfRoot;

@synthesize willTweenGroupAutoDestruct;

@synthesize groupContainsFromModeTweens;

//ANIMATION_TESTS_9583/////////
//int numGTweenGroupInst = 0;
///////////////////////////////////


- (id) initWithAutoDestruct:(BOOL)autoDestruct andEngine:(GAnimation *)engine {
    
    self = [super init];
    
    animationEngine = engine;
    
    willTweenGroupAutoDestruct = autoDestruct;
    
    numOfElements = 0;
    
    isGroupOfRawTweens = NO;
    
    targetWasReleased = NO;
    
    isChildOfRoot = NO;
    
    newFirstElement = NO;
    newLastElement = NO;
    
    groupContainsFromModeTweens = NO;
    
    //ANIMATION_TESTS_9583//////
    //numGTweenGroupInst++;
    ////////////////////////////////
    
    return self;
    
}



/**
 * some functions for the loose-memory coupling between these animation objects
 * and the targets they're supposed to operate upon. Note that we won't release
 * a target if this group is not a self-destructing group, and that depends 
 * on the exposure-policy of the animation declaration.
 *
 */
- (void) takeResponsibilityForReleasingTarget:(GBox *)box {
    targetWasReleased = NO;
    target = box;
    numberOfTargetRetainsInSubtree = 1;
}
- (BOOL) releaseTargetIfThisGroupHasResponsibility {
    if(target && !targetWasReleased && willTweenGroupAutoDestruct) {
        
    BOOL nodeScheduledForDestruction = target.animationLayer_nodeWasDestroyed;
        
    [target release];
    targetWasReleased = YES;
        
    return nodeScheduledForDestruction;
    }
    
return NO;
}


- (void) setLastSequenceGroupToNil {
    lastSequenceGroup = nil;
}


- (void) addChildGroup:(GTweenGroup *)newGroup {
    newGroup.parentGroup = self;
    
    //tick up the number of animation targets
    numberOfTargetRetainsInSubtree += newGroup.numberOfTargetRetainsInSubtree;
    
    //if YES, then this newGroup contains at least one "from" mode tween.
    //We have to keep track of which groups contain from-mode tweens and which don't.
    if(newGroup.groupContainsFromModeTweens) {
    self.groupContainsFromModeTweens = YES;
    }
    
    //if there isn't a first-parallel-group then we append it in parallel regardless.
    //obviously with only single group it's meaningless to speak of "sequence".
    if(!firstParallelGroup) {
        
    //The boundaries must be up-to-date at all times. The last and first parallel group as well
    //as the last and first parallel tween.
    firstParallelGroup = newGroup;
    lastParallelGroup = newGroup;
        
    firstParallelTween = newGroup.firstParallelTween;
    lastParallelTween = newGroup.lastParallelTween;
        
    }
    
    //this second case assumes that at least one group has been added.
    //the logic that follows is concerned with the differences between
    //parallel and sequential groups and we can't do anything unless there
    //is a group to start with.
    else {
        
        //if we're supposed to append this in parallel, then we're going to join
        //the parallel tween objects.
        //
        //Two handshakes must be done. Each the parallel groups must link to each-other.
        //And the boundary parallel tweens of successive parallel groups must link together.
        //The tween-linking is so that the there is always a flat chain of tween objects
        //for the render-loop to blast through. The group-linking is to facilitate sequences.
        //
        //The boundaries must be up-to-date at all times. The last and first parallel group as well
        //as the last and first parallel tween.
        if(newGroup.appendedInParallel == YES) {
            
        //introduce the tweens so that we have an unbroken line to parallel tweens between groups
        lastParallelGroup.lastParallelTween.nextTween = newGroup.firstParallelTween;
        newGroup.firstParallelTween.prevTween = lastParallelGroup.lastParallelTween;
        
        //perform the handshake so that each parallel group knows about its next of kin.
        lastParallelGroup.nextSibling = newGroup;
        newGroup.prevSibling = lastParallelGroup;
            
        //set this to the be the lastParallelTween of this latest group. because this newGroup
        //as well as its child groups were fully enumerated, we are guaranteed that the newGroup.lastParallelTween
        //is up-to-date.
        lastParallelTween = newGroup.lastParallelTween;
            
        //record the last parallel group
        //and tag this as the last parallel group.
        lastParallelGroup = newGroup;
        
        //set this to nil.
        lastSequenceGroup = nil;
            
        }
        
        //else it's in sequence. instead of joining to the tweens,
        //we're just going to join the groups. See, in the case of parallel tweens, it's pretty easy to find the first
        //and last parallel tween in a group and then join them. in the case of sequential tweens, it's not so easy.
        //so instead we just do this thing where we tell the groups themselves what group is sequentially next or prev.
        else {
            
            //tack it onto the last parallel group. perform a handshake with the next/prev sequence link.
            if(!lastSequenceGroup) {
            lastParallelGroup.nextSequence = newGroup;
            newGroup.prevSequence = lastParallelGroup;
            } else {
            lastSequenceGroup.nextSequence = newGroup;
            newGroup.prevSequence = lastSequenceGroup;
            }
        
        //update the boundary. we only have the ending boundary.
        lastSequenceGroup = newGroup;
            
        }
        
    }
    
numOfElements++;
}


/**
 * this function is used to just add a raw tween object directly to this group.
 * the only linking that we have to do here is with the next-previous parallel tween,
 * and update the boundary.
 *
 */
- (void) addParallelTween:(GTween *)twn {
    
twn.target.animationLayer_numberOfTweens++;

twn.parentGroup = self;

isGroupOfRawTweens = YES;
    
    if(!firstParallelTween) {
    firstParallelTween = twn;
    lastParallelTween = twn;
    }
    
    else {
    lastParallelTween.nextTween = twn;
    twn.prevTween = lastParallelTween;
        
    lastParallelTween.nextSibling = twn;
    twn.prevSibling = lastParallelTween;
        
    lastParallelTween = twn;
    }
    
    //if YES, then this is a "from" mode tween. As soon as this tween is added to the root animation group,
    //we want the "from" value to be invoked. Otherwise, it looks a little janky because the box sits there
    //for one frame before being set at it's "from" starting point. So we have to keep track of which groups
    //contain from-mode tweens and which don't.
    if(twn.goalModeFromOrTo) {
    self.groupContainsFromModeTweens = YES;
    }
    
numOfElements++;
}

- (void) performStartCallback:(GTween *)tween {
    if(startCllbck != nil) {
    //[startObs performSelector:startCllbck withObject:tween.target];
        
        //if the observer is still alive, then we're going
        //to see if we can fire the ending-callback.
        if(!startObs.isObjectDestroyed) {
        [startObs performSelector:startCllbck withObject:tween.target];
        }
        //else, we've encountered a dead object so in that case we're going to
        //just take this opportunity to release it.
        else {
        [startObs release];
        startObs = nil;
        }
        
        
        
    }
}



/**
 * When the last or first parallel tween of the group is replaced or ends during animation,
 * these bubbling functions will update as many parents as they can. the parent group might ALSO
 * be the first/last sibling in its set, as well as IT parent etc etc and this is the concept
 * of right and left contours. So this will update the last/first parallel tween up the contours
 * as far as it can. When it can't go any further, then it will make the handshake between tweens
 * so that the chain of prevTween/nextTween will be maintained.
 *
 *
 */
- (void) updateLeftContour:(GTween *)twn {
firstParallelTween = twn;
    
    if(!prevSibling) {
    
        if(parentGroup) {
        [parentGroup updateLeftContour:twn];
        }
        
    } else {
        
    prevSibling.lastParallelTween.nextTween = twn;
    twn.prevTween = prevSibling.lastParallelTween;
        
    }
    
}
- (void) updateRightContour:(GTween *)twn {
lastParallelTween = twn;
    
    if(!nextSibling) {
        
        if(parentGroup) {
        [parentGroup updateRightContour:twn];
        }
        
    } else {
        
    nextSibling.firstParallelTween.prevTween = twn;
    twn.nextTween = nextSibling.firstParallelTween;
        
    }
    
}


//Why set the prevTween/nextTween to nil? because we need the tween boundary
//to be ISOLATED at this point. otherwise when chain_maintainTweenPrevNextTweens
//fires on twn-end it's going to reference a tween which may have been deleted.
//that's the first HOLY TRUTH here. let the countour-update handle the handshake between groups.
//
//Right- see Alex, the new firstParallelGroup? there might be a new one assigned because of the
//mutation. Well, guess what? That firstParallelGroup.firstParallelTween VERY WELL could be associated
//with the friggin group that just ended. It's gone. Kaput. Not around no more. Bye bye. So what we're gonna
//have to do here is get rid of that association.
//
//Now wait a minute, Alex, we're setting that association to nil? Shouldn't we be performing the handshake
//to maintain the prev-next tween links? Well that's what the darned contour updating is for, genius. Let
//the contour updaters worry about those handshakes.
- (void) chain_maintainTweenBoundGroups {
    
    if(firstParallelGroup) {
    firstParallelTween = firstParallelGroup.firstParallelTween;
      
        if(newFirstElement) {
        firstParallelTween.prevTween = nil;
        }
        
    } else {
    firstParallelTween = nil;
    }
    
    if(lastParallelGroup) {
    lastParallelTween = lastParallelGroup.lastParallelTween;
        
        if(newLastElement) {
        lastParallelTween.nextTween = nil;
        }
        
    } else {
    lastParallelTween = nil;
    }
    
}

- (void) chain_maintainTweenBoundTweens {
    
    if(firstParallelTween) {
        
        if(newFirstElement) {
        firstParallelTween.prevTween = nil;
        }
        
    } else {
    firstParallelTween = nil;
    }
    
    if(lastParallelTween) {
        
        if(newLastElement) {
        lastParallelTween.nextTween = nil;
        }
        
    } else {
    lastParallelTween = nil;
    }
    
}



 
 - (void) chain_maintainGroupPrevNextSiblings:(GTweenGroup *)groupJustEnded {
 
    GTweenGroup *nextInSeq = groupJustEnded.nextSequence;

    if(nextInSeq) {

    nextInSeq.prevSibling = groupJustEnded.prevSibling;
    nextInSeq.nextSibling = groupJustEnded.nextSibling;

    newSequence = YES;
    newSequenceGroup = nextInSeq;
     
         if(nextInSeq.prevSibling) {
         nextInSeq.prevSibling.nextSibling = nextInSeq;
         } else {
         firstParallelGroup = nextInSeq;
         }
         
         if(nextInSeq.nextSibling) {
         nextInSeq.nextSibling.prevSibling = nextInSeq;
         } else {
         lastParallelGroup = nextInSeq;
         }
         
    } else {
         
         if(groupJustEnded.prevSibling) {
         groupJustEnded.prevSibling.nextSibling = groupJustEnded.nextSibling;
         } else {
         firstParallelGroup = groupJustEnded.nextSibling;
         newFirstElement = YES;
         }
         
         if(groupJustEnded.nextSibling) {
         groupJustEnded.nextSibling.prevSibling = groupJustEnded.prevSibling;
         } else {
         lastParallelGroup = groupJustEnded.prevSibling;
         newLastElement = YES;
         }
     
     }
 
 }





- (void) chain_maintainTweenPrevNextSiblings:(GTween *)twnJustEnded {
    
    //make sure that the sibling chain links are updated.
    //this allows us to know what the first and last parallel tween in this group are.
    //Also, we're setting the prevTween/nextTween to nil here for the same
    //reason as the chain_maintainTweenBound function. See the comments up there
    //for more details.
    if(twnJustEnded.prevSibling) {
    twnJustEnded.prevSibling.nextSibling = twnJustEnded.nextSibling;
    } else {
    newFirstElement = YES;
    firstParallelTween = twnJustEnded.nextSibling;
    //this line below is now handled by: chain_maintainTweenBoundTweens
    //firstParallelTween.prevTween = nil;
    }
    if(twnJustEnded.nextSibling) {
    twnJustEnded.nextSibling.prevSibling = twnJustEnded.prevSibling;
    } else {
    newLastElement = YES;
    lastParallelTween = twnJustEnded.prevSibling;
    //this line below is now handled by: chain_maintainTweenBoundTweens
    //lastParallelTween.nextTween = nil;
    }
    
}


//when the last tween of a group is finished, this will perform the necessary
//handshake to cut the group out.
- (void) chain_maintainTweenPrevNextTweens:(GTween *)twnJustEnded {
    
    if(twnJustEnded.prevTween) {
    twnJustEnded.prevTween.nextTween = twnJustEnded.nextTween;
    }

    if(twnJustEnded.nextTween) {
    twnJustEnded.nextTween.prevTween = twnJustEnded.prevTween;
    }
    
twnJustEnded.prevTween = nil;
twnJustEnded.nextTween = nil;
}


- (void) setStartAndDeltaValuesOnGroupFromModeTweens {
    
    if(self.groupContainsFromModeTweens) {
    GTween *tweenInChildGroup = self.firstParallelTween;
    
        while(tweenInChildGroup) {
        [tweenInChildGroup setStartAndDeltaValuesFromModeTween];
        tweenInChildGroup = tweenInChildGroup.nextTween;
        }
        
    }
    
}


/**
 Thought Experiment 1: Three groups. A B C. A and C are long. B is short. So B ends first. When the last tween of B ends, the tween boundaries of A and C have to shake hands? When does this happen?
 
 Answer: It happens when the last tween of B ends. This code fires:
 
 if(twnJustEnded) {
 
     //maintain [prev/next]Sibling links, [first/last]ParallelTween
     [self chain_maintainTweenPrevNextSiblings:twnJustEnded];
     
     //maintain the [prev/next]Tween links
     [self chain_maintainTweenPrevNextTweens:twnJustEnded];
     
And the chain_maintainTweenPrevNextTweens performs that handshake. So before the Group B is even sent through the rectify process, the tween boundaries of A and C are joined.
 
 
 Thought Experiment 2:
 
 We have an animation structure
 
  A
    B /B
    C /C
    D /D
 /A
 
 Groups B C D are nested in A. B C D are sequentially connected. So, how does the handshake happen between the inner B,C,D and the boundary of A? See, the B C D are *sequential* so that means that only one of them is "in play" at a time. So that means that when B is done, C is the new first-group/last-group which triggers a refresh of the contours. And when C is done, D is the new first-group/last-group which triggers a refresh of the contours. And the contour refreshing performs the handshake.
 
 
 **/



/**
 * We have the germ of a theory here about how these mutations should occur. There will be three phases:
 *
 * Phase 1: Maintain first and last elements (first/last parallel-group, first/last parallel-tween)
 * This boundary is facilitated by the sibling chains.
 * 
 * Phase 2: Isolate the boundary. The left-boundary should point to nil on the prev side, and the right-boundary should
 * point to nil on the next side. 
 *
 * Phase 3: If the group is not empty, then update contours. The boundary of group will be joined to the larger structure at this point.
 * If the group is empty, then this group has ended so pass it onto the parent group, and the 3 phases will begin there.
 *
 */
- (void) rectifyWithTween:(GTween *)twnJustEnded andGroup:(GTweenGroup *)grpJustEnded forDestroy:(BOOL)forDestroy {

numOfElements--;
    

    if(twnJustEnded) {
        
        //maintain [prev/next]Sibling links, [first/last]ParallelTween
        [self chain_maintainTweenPrevNextSiblings:twnJustEnded];
        
        //maintain the [prev/next]Tween links
        [self chain_maintainTweenPrevNextTweens:twnJustEnded];
        
        //last task before contour updates:
        //maintain the tween boundary, and isolate this group.
        [self chain_maintainTweenBoundTweens];
        
    } else {
        
        //this group needs to know how many animations targets were destroyed prematurely
        //inside the group that just ended. This is so we don't fire off ending-callbacks
        //if every animation target in the subtree has been destroyed.
        //See: Notes Gnarly Animation Touchstone numberOfTargetRetainsInSubtree.txt
        numberOfTargetDestructionFlagsInSubtree += grpJustEnded.numberOfTargetDestructionFlagsInSubtree;
    
        //maintain [prev/next]Group, [first/last]ParallelGroup
        [self chain_maintainGroupPrevNextSiblings:grpJustEnded];
        
        //last task before contour updates:
        //maintain the tween boundary, and isolate this group.
        [self chain_maintainTweenBoundGroups];
        
    }
    
        
    //if this thing is not empty yet, then we may have to
    //update the right and left contours of the tree with the
    //boundary-tweens.
    if(numOfElements > 0) {
        
        //targ.animationLayer_nodeWasDestroyed
        
        //if we have a newSequence group, then we're going to tell it to update its own
        //contours. We do that because unlike the parallel-groups, this new-sequence-group
        //was never added to the chain. What I'm saying here is that it will need to perform
        //a handshake regardless of whether or not its a newFirst or newLast element. Updating ]
        //the contours from THIS group will guarantee that the tween boundaries of THIS group
        //will be propagated upward. AHA! But this new-sequence group might have appeared in the MIDDLE
        //i.e. in order to perform the handshake to join it into the sequence of tweens we're going
        //to have to update the contours starting from new-sequence group, NOT this group.
        //Note that this is not a circumstance we'd ever find ourselves in with parallel-tweens. Parallel tweens
        //are always added to the END of their groups, not the MIDDLE.
        if(newSequence) {
            
        [newSequenceGroup updateLeftContour:newSequenceGroup.firstParallelTween];
            
        [newSequenceGroup updateRightContour:newSequenceGroup.lastParallelTween];
            
            //if this is the root
            
            if(isRootTweenGroup) {
            [newSequenceGroup setStartAndDeltaValuesOnGroupFromModeTweens];
            }
            
        newSequence = NO;
        newSequenceGroup = nil;
            
        } else {
        
            //update left contour with new first-parallel-tween
            if(newFirstElement) {
            newFirstElement = NO;
            [self updateLeftContour:firstParallelTween];
            }
            
            //update right contour with new last-parallel-tween
            //else
            if(newLastElement) {
            newLastElement = NO;
            [self updateRightContour:lastParallelTween];
            }
            
        }
    
    }
    
    //else, this group is empty, so we're going to tell the parent that
    //the group has finished
    else {
        
    BOOL targetScheduledForDestruction = [self releaseTargetIfThisGroupHasResponsibility];
    
        
        //if the target was destroyed FIRST, then we have to mark it on the
        //tween object so that it will know not to attempt to interact with the
        //target during its own destruction
        if(targetScheduledForDestruction && twnJustEnded) {
        [twnJustEnded setTargetWasDestroyed];
        }
        
        //if the target was destroyed, then tick this up.
        //This is so we don't fire off ending-callbacks if every animation target in the subtree has been destroyed.
        //See: Notes Gnarly Animation Touchstone numberOfTargetRetainsInSubtree.txt
        if(targetScheduledForDestruction) {
        numberOfTargetDestructionFlagsInSubtree++;
        }
        
    //this is the final evaluation of these two variables. If the number of times encountered destroyed targets
    //is equal to the number of times that this tree retained targets, then that means that all targets in this
    //subtree have been destroyed. the expected behavior here is that the ending-callback will NOT fire.
    BOOL allTargetsInSubtreeWereAlreadyDestroyed = (numberOfTargetRetainsInSubtree == numberOfTargetDestructionFlagsInSubtree);
        
        //if this thing is not in a destruction call, then we're going to fire off
        //the ending callback, if one exists.
        if(!forDestroy) {
            
            if(endCllbck != nil) {
                
                //if the observer is still alive, then we're going
                //to see if we can fire the ending-callback.
                if(!endObs.isObjectDestroyed) {
                    
                    if(!allTargetsInSubtreeWereAlreadyDestroyed) {
                    GTweenInfo *tweenInfo = [twnJustEnded getInfoObject];
                    [endObs performSelector:endCllbck withObject:tweenInfo];
                    [tweenInfo release];
                    }
                    
                }
                //else, we've encountered a dead object so in that case we're going to
                //just take this opportunity to release it.
                else {
                [endObs release];
                endObs = nil;
                }
                
            }
            //if(endCllbck != nil && !allTargetsInSubtreeWereAlreadyDestroyed) {
            //GTweenInfo *tweenInfo = [twnJustEnded getInfoObject];
            //[endObs performSelector:endCllbck withObject:tweenInfo];
            //[tweenInfo release];
            //}
            
        }
        
        //if this pool is being drained, then we don't need to remove this group
        //from the pool, because the drain function is already doing that.
        if(pool) {
        [pool removeFromPool:self];
        }

        if(parentGroup) {
        [parentGroup rectifyWithTween:nil andGroup:self forDestroy:forDestroy];
        parentGroup = nil;
        }
        
    }
    
    
    if(twnJustEnded) {
    [twnJustEnded release];
    } else {
    [grpJustEnded release];
    }

}


- (void) setFirstParallelTween:(GTween *)twn {
    firstParallelTween = twn;
    twn.prevTween = nil;
}
- (void) setLastParallelTween:(GTween *)twn {
    lastParallelTween = twn;
    twn.nextTween = nil;
}



- (void) setStartCallback:(NSString *)cllbkName withObserver:(id <GLayerMemoryObject>)obs {
    startCllbck = NSSelectorFromString([cllbkName stringByAppendingString:@":"]);
    startObs = obs;
    [obs retain];
}
- (void) setEndCallback:(NSString *)cllbkName withObserver:(id <GLayerMemoryObject>)obs {
    endCllbck = NSSelectorFromString([cllbkName stringByAppendingString:@":"]);
    endObs = obs;
    [obs retain];
}
- (void) setDestroyCallback:(NSString *)cllbkName withObserver:(id <GLayerMemoryObject>)obs {
    destroyCllbck = NSSelectorFromString([cllbkName stringByAppendingString:@":"]);
    destroyObs = obs;
    [obs retain];
}
/*
- (void) setEngineWideDestroyPolitely:(SEL)cllbk withObserver:(id <GLayerMemoryObject>)obs {
    if(!destroyCllbck && cllbk && obs) {
        destroyCllbck = cllbk;
        destroyObs = obs;
    }
}
*/


/**
 * The cleanup function. This is basically the logic on the layer of the
 * GAnimation cleanup, and this should be folded into that code as well to avoid duplication
 *
 */
- (void) destroyAllTweens {
    
    [self retain];
    
    GTween *first = firstParallelTween;
    GTween *twn = first;
    GTween *nxt;
    
    int iteration = 0;
    
    while(twn) {
        
    iteration++;
        
        //loop through only this time we're going to just decrement instead of rendering the animations.
        //this will find all of the tweens as well as next-sequence groups and eliminate them.
        nxt = twn.nextTween;
        [twn.parentGroup rectifyWithTween:twn andGroup:nil forDestroy:YES];
        twn = nxt;
        
        //reset in case of sequence.
        if(firstParallelTween != first) {
        twn = firstParallelTween;
        }
        
    }
    
    [self release];
    
}



- (void) dealloc {
    
    //ANIMATION_TESTS_9583/////////
    //numGTweenGroupInst--;
    //NSLog(@"GTweenGroup deallocing. Number of GTweenGroup instances: %i%@%@",numGTweenGroupInst,@"  self: ",self);
    ///////////////////////////////////

    
    if(endObs) {
    [endObs release];
    endObs = nil;
    }
    if(startObs) {
    [startObs release];
    startObs = nil;
    }
    if(destroyObs) {
    [destroyObs release];
    destroyObs = nil;
    }

[super dealloc];
}




/////////////
//         //
//  A P I  //
//         //
/////////////

/**
 *
 *
 */
- (void) destroy {
    if(!isDestroyed) {
    isDestroyed = YES;
    [self pause];
    [self destroyAllTweens];
        
    //right now they get released in the rectify call.
    //so you might be tempted to call [self release]
    //here, but DON'T.
    }
}




/**
 * this is just going to slice the animation right out of the 
 * main animaiton loop.
 *
 */
- (void) pause {
    
    GTween *startBound = firstParallelTween;
    GTween *endBound = lastParallelTween;
    

    if(startBound && endBound) {
        
        //maintain the parallel chain of animation objects
        if(startBound.prevTween) {
        startBound.prevTween.nextTween = endBound.nextTween;
        } else {
        [[animationEngine getRootTweenGroup] setFirstParallelTween:endBound.nextTween];
        }
        if(endBound.nextTween) {
        endBound.nextTween.prevTween = startBound.prevTween;
        } else {
        [[animationEngine getRootTweenGroup] setLastParallelTween:startBound.prevTween];
        }
        
        //and then cut this group off from the outside.
        //it should not point to outside tweens.
        if(startBound.nextTween) {
        startBound.nextTween.prevTween = nil;
        }
        if(endBound.prevTween) {
        endBound.prevTween.nextTween = nil;
        }
        
        //maintain the sibling of animation groups.
        //note that we're not making any special allowances for the nextSequence
        //if one exists. the reason for this is that expected behavior for this is that
        //the next sequence group will NOT animation if you pause this group. if you slice
        //this group of of the mix, its going to take it nextSequence group with it.
        //This should be testing.
        if(prevSibling) {
        prevSibling.nextSibling = nextSibling;
        } else {
        parentGroup.firstParallelGroup = nextSibling;
        }
        
        if(nextSibling) {
        nextSibling.prevSibling = prevSibling;
        } else {
        parentGroup.lastParallelGroup = prevSibling;
        }
        
    }
    

    
}

- (void) unpause {
[[[GAnimation getEngine] getRootTweenGroup] addChildGroup:self];
}



@end
