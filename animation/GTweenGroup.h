//
//  GTweenGroup.h
//  BraveRocket
//
//  Created by Alexander Lowe on 1/31/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

@class GTweenSet;
@class GTween;
@class GBox;
@class GNode;
@class GTweenInfo;
@class GAnimation;
@class GAnimationPool;
#import "../GLayerMemoryObject.h"


@interface GTweenGroup : NSObject {
    
    NSString *name;
    
    //
    BOOL newFirstElement;
    BOOL newLastElement;
    BOOL newSequence;
    
    
    
    //the start/end callback
    SEL endCllbck;
    SEL startCllbck;
    SEL destroyCllbck;
    
    //the start/end event
    NSString *startEvt;
    NSString *endEvt;
    NSString *destroyEvt;
    
    //the start/end observer
    id <GLayerMemoryObject> endObs;
    id <GLayerMemoryObject> startObs;
    id <GLayerMemoryObject> destroyObs;
    
    //the start/end target.
    id startTarg;
    id endTarg;
    id destroyTarg;
    
    GAnimation *animationEngine;
    
    GTween *lastParallelTween;
    
    GTween *firstParallelTween;
    
    BOOL appenededInParallel;
    
    BOOL storedAppendInParallel;
    
    BOOL isGroupOfRawTweens;
    
    int numOfElements;
        
    BOOL isRootTweenGroup;
    BOOL isChildOfRoot;
    
    GTweenGroup *parentGroup;
    GTweenGroup *lastSequenceGroup;
    
    GTweenGroup *lastParallelGroup;
    GTweenGroup *firstParallelGroup;
    
    GTweenGroup *newSequenceGroup;
    
    GTweenGroup *nextSequence;
    GTweenGroup *prevSequence;
    GTweenGroup *nextSibling;
    GTweenGroup *prevSibling;
    GTweenGroup *nextInPool;
    GTweenGroup *prevInPool;
    
    GAnimationPool *pool;
    
    GBox *target;
    BOOL targetWasReleased;
    
    BOOL willTweenGroupAutoDestruct;
    
    BOOL isDestroyed;
    BOOL allTweensDestroyed;
    
    BOOL groupContainsFromModeTweens;
    
    int numberOfTargetRetainsInSubtree;
    int numberOfTargetDestructionFlagsInSubtree;
    
    
    
}

@property (nonatomic, assign) int numberOfTargetRetainsInSubtree, numberOfTargetDestructionFlagsInSubtree;

@property (nonatomic, readonly) BOOL willTweenGroupAutoDestruct;

@property (nonatomic, assign) BOOL isRootTweenGroup, isChildOfRoot;

@property (nonatomic, assign) NSString *name;

@property (nonatomic, assign) int numOfElements;

@property (nonatomic, assign) BOOL appendedInParallel;

@property (nonatomic, assign) BOOL storedAppendInParallel;

@property (nonatomic, assign) BOOL isGroupOfRawTweens;

@property (nonatomic, assign) GTween *lastParallelTween,*firstParallelTween;//,*lastSequenceTween;

@property (nonatomic, assign) GTweenGroup *parentGroup, *firstParallelGroup, *lastParallelGroup;

@property (nonatomic, assign) GTweenGroup *nextSequence, *prevSequence, *nextSibling, *prevSibling;

@property (nonatomic, assign) GTweenGroup *nextInPool, *prevInPool;

@property (nonatomic, assign) GAnimationPool *pool;

@property (nonatomic, assign) BOOL groupContainsFromModeTweens;


///////////

- (void) chain_maintainGroupPrevNextSiblings:(GTweenGroup *)groupJustEnded;

- (void) chain_maintainTweenPrevNextSiblings:(GTween *)twnJustEnded;

- (void) chain_maintainTweenPrevNextTweens:(GTween *)twnJustEnded;

- (void) chain_maintainTweenBoundGroups;

- (void) chain_maintainTweenBoundTweens;

- (void) updateRightContour:(GTween *)twn;

- (void) updateLeftContour:(GTween *)twn;

- (void) rectifyWithTween:(GTween *)twnJustEnded andGroup:(GTweenGroup *)grpJustEnded forDestroy:(BOOL)forDestroy;


///////////






- (id) initWithAutoDestruct:(BOOL)autoDestruct andEngine:(GAnimation *)engine;

- (void) takeResponsibilityForReleasingTarget:(GBox *)box;

- (BOOL) releaseTargetIfThisGroupHasResponsibility;

- (void) addChildGroup:(GTweenGroup *)newGroup;

- (void) setStartAndDeltaValuesOnGroupFromModeTweens;

- (void) addParallelTween:(GTween *)twn;

- (void) setEndCallback:(NSString *)cllbkName withObserver:(id <GLayerMemoryObject>)obs;
- (void) setStartCallback:(NSString *)cllbkName withObserver:(id <GLayerMemoryObject>)obs;
- (void) setDestroyCallback:(NSString *)cllbkName withObserver:(id <GLayerMemoryObject>)obs;
//- (void) setEngineWideDestroyPolitely:(SEL)cllbk withObserver:(id <GLayerMemoryObject>)obs;
- (void) performStartCallback:(GTween *)tween;
- (void) destroyAllTweens;
//- (void) destroyThisPrevSequence;

/*
- (void) recalculateStructure:(GTween *)twnJustEnded
            updateLeftContour:(BOOL)updateLeft
           updateRightContour:(BOOL)updateRight
                 forDecrement:(BOOL)forDecrement
          fromAnimationEngine:(BOOL)directlyFromEngine
                         mode:(int)mode;
*/

- (void) setLastSequenceGroupToNil;

/*
- (void) chainHelper_updateTweenBoundary;

- (void) chainHelper_unhookFromNextAndPrevSequences;

- (void) chainHelper_maintainTweens:(GTween *)twnJustEnded withNewSequence:(GTweenGroup *)sequenceGroup;

- (void) chainHelper_maintainGroupSiblingsWithNewSequence:(GTweenGroup *)sequenceGroup;

- (void) chainHelper_maintainGroupSiblingsNoNextSequence;

- (void) chainHelper_maintainSiblings:(GTween *)twnJustEnded;

- (void) chainHelper_maintainTweens:(GTween *)twnJustEnded;
*/


/////////////
//         //
//  A P I  //
//         //
/////////////

- (void) pause;

- (void) unpause;

- (void) destroy;

@end
