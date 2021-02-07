//
//  GGroup.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 10/18/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GRenderable.h"
//#import "GBlueKite.h"
#import "GLayerMemoryObject.h"


@class GSurface;
@class GPop;
@class GTweenSet;
@class GDop;
@class GExistence;


@interface GExistenceCounter : NSObject {
    BOOL doesGNodeExist;
    int countOfExistenceWatchers;
}
@property (nonatomic, assign) BOOL doesGNodeExist;
@property (nonatomic, assign) int countOfExistenceWatchers;

@end


@interface GNode : GRenderable <GLayerMemoryObject> {
    
BOOL animationLayer_passiveAnimationChange;
BOOL animationLayer_nodeWasDestroyed;
int animationLayer_numberOfTweens;
int animationLayer_animationCurrentCode;
int animationLayer_numberOfTweensInPassiveAlteration;
    

    
    
BOOL _releasedResoucesWasCalled;

//////////////////////////////
//private/internal variables.
BOOL usePopper;
BOOL isLast;
BOOL isFirst;

GPop *popper;
GDop *dopper;
GRenderable *popOrDop;
BOOL usePopOrDop;

float *affineInverse;
BOOL *affineInverseSafetyPointer;
BOOL affineInverseSafety;
float **affineInversePointer;

//the rendering surface where this
//guy is rendered.
GSurface *root;

//coords
float _uniX;
float _uniY;


//the screen dimensions, plus the constant to multiply through to guarantee
//uniform sizes across all iOS screens.
int _screenWidth;
int _screenHeight;
float _screenCenterX;
float _screenCenterY;
BOOL _screenIsRetina;
float _screenHiResScale;

//blue tooth variables.
int btMrrId;
int btMsgId;
BOOL serveMirror;


BOOL isMainDefault;
BOOL isRootChild;
BOOL isCached;
BOOL isUnglued;
    

//caching chain references.
GNode *prevCache;
GNode *nextCache;

//killing chain references.
GNode *nextKill;
GNode *prevKill;

//here's the tween chain for all of the
//tween sets that are associated with this.
//GTweenSet *firstTweenSet;
//GTweenSet *lastTweenSet;


/////////////////
//API properties
GNode *nextSibling;
GNode *prevSibling;
GNode *parent;
GNode *lastChild;
GNode *firstChild;

int numChildren;
    
//Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
//int gnode_id;
//////////////////////////
    
float x;
float y;
float scaleX;
float scaleY;
float rotation;
float opacity;

//LOWE 2014-05-11 RETINA
float percentX;
float percentY;
    
BOOL isDelegateARenderableObject;

BOOL totalWatchTouches;
    
BOOL prevNextAreUpToDate;

NSString *name; 

GNode **boundPointer;
BOOL hasBoundPointer;
    
//BOOL nodeIsStillAlive;
//BOOL *pointerNodeIsStillAlive;
    
BOOL *lockedNodeIsStillAlive;
int *lockedCountOfExistenceWatchers;
BOOL existenceWatchersWereIssued;
    GExistenceCounter *existenceCounter;

}

//GLayerMemoryObject
@property (nonatomic, assign) BOOL isObjectDestroyed;

//private/only to be used internally.
@property (nonatomic, assign) BOOL isLast,isFirst,prevNextAreUpToDate;
@property (nonatomic, assign) float *affineInverse;
@property (nonatomic, assign) BOOL isMainDefault, isRootChild, isCached, isUnglued;
@property (nonatomic, readonly) GNode *nextCache,*prevCache;
@property (nonatomic, assign) BOOL totalWatchTouches;

@property (nonatomic, assign) BOOL animationLayer_passiveAnimationChange, animationLayer_nodeWasDestroyed;
@property (nonatomic, assign) int animationLayer_numberOfTweens, animationLayer_animationCurrentCode, animationLayer_numberOfTweensInPassiveAlteration;



//the unique id for this object if it is supposed to be passively synched with its mate on another iOS device
@property (nonatomic, assign) int btMrrId;

//the unique id for object if it is supposed to be able to send/receive active messages to/from its mate on another iOS device
@property (nonatomic, assign) int btMsgId;

//if this box is passively synched, then this determines whether or not this object serves or receives passive synch data.
@property (nonatomic, assign) BOOL serveMirror;


- (void) setParentRef:(GNode *)par;
- (void) setPrevRef:(GNode *)prv;
- (void) setNextRef:(GNode *)nxt;
- (void) setNextCacheRef:(GNode *)nxt;
- (void) setPrevCacheRef:(GNode *)prv;

- (BOOL *) getAffineInverseSafetyPointer;
- (float **) getAffineInversePointer;

- (void) resetExistence;

- (GNode *) prevKill;
- (void) setPrevKill:(GNode *)pk;
- (GNode *) nextKill;
- (void) setNextKill:(GNode *)nk;

- (void) assignFirstChild:(GNode *)first;
- (void) assignLastChild:(GNode *)last;

- (id) startAsMainDefault:(GSurface *)view;

+ (void) setScreenW:(int)w H:(int)h cX:(float)x cY:(float)y hiResScale:(float)screenHiResScale isRetina:(BOOL)isRetina;

- (void) contract;
- (void) convertToDop;
- (void) convertToPop;

- (GRenderable *) getLast;
- (GRenderable *) getNext;

- (void) deepDestroy;

//- (void) cacheTweenSet:(GTweenSet *)tweenSet;
//- (void) uncacheTweenSet:(GTweenSet *)tweenSet;
//- (void) destroyTweens;

+ (void) decrementAndLogNumberOfInstances;


/////////////
//         //
//  A P I  //
//         //
/////////////


//public. a full complement of display-list functions.
@property (nonatomic, readonly) GNode *nextSibling,*prevSibling;
@property (nonatomic, readonly) GNode *parent;
@property (nonatomic, assign) int numChildren;
@property (nonatomic, assign) float x,y,scaleX,scaleY,rotation,opacity;
@property (nonatomic, assign) NSString *name;


//these are the functions required by the GTouchBehavior protocol.
- (GRenderable *) touchTarget;
- (void) setTouchTarget:(GRenderable *)tTarg;
- (void) touchStart:(CGPoint)gamePoint;
- (void) touchMove:(CGPoint)gamePoint;
- (void) touchEnd:(CGPoint)gamePoint;
- (void) touchDouble:(CGPoint)gamePoint;
@property (nonatomic, assign) BOOL isDelegateARenderableObject;


//the percent setters and getters for position.
- (float) percentX;
- (float) percentY;
- (void) setPercentX:(float)pX;
- (void) setPercentY:(float)pY;

//the legacy setters and getters for position. 
- (float) legacyX;
- (float) legacyY;
- (void) setLegacyX:(float)lgcyX;
- (void) setLegacyY:(float)lgcyY;


//- (void) bindPointer:(GNode *)pointer;
//- (void) clearBoundPointer;

- (GExistence *) getExistence;


- (GNode *)clone;


//bluetooth synchronization.
//- (GMirrorPacket)mirrorOut;
//- (void)mirrorIn:(GMirrorPacket)data;

- (GSurface *) root;

- (void) setRoot:(GSurface *)rt;

- (CGPoint) globalToLocal:(CGPoint)global;

- (CGPoint) localToGlobal:(CGPoint)local;

- (void) addChild:(GNode *)child;

- (void) addChild:(GNode *)child at:(int)ind;

- (void) addChild:(GNode *)child after:(GNode *)ref;

- (void) addChild:(GNode *)child before:(GNode *)ref;

- (void) addInBack:(GNode *)child;

- (void) removeChild:(GNode *)child;

- (void) removeFromParent;

- (void) empty;

- (GNode *) getChildAt:(int)index;

- (GNode *) getFirstChild;





@end
