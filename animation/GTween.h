//
//  GTween.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/13/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GEaseEquation.h"
#import "GNode.h"
#import "GSprite.h"

@class GTweenGroup;
@class GTweenInfo;



@interface GTween : NSObject {

//the target. always a box.
//GBox *target;
    
NSString *name;
    
GTweenGroup *parentGroup;
    
int animationCurrentCode;

GEaseEquation *equation;

//start point/end point
float startPoint;
float endPoint;
    
//the multi-use goal
float goal;

//the difference end - start
float interval;

//the delay
int delay;

//the progressing delay count
int delayCnt;

//the duration
int dur;

//the current frame of the tween.
int pos;
    
//the goal mode which is set once on the tween when it's created.
//0=absolute, 1=relative, 2=ratio.
int goalMode;
    
//YES=animate to FROM this new thing to the current position.
//NO=animate from the current position TO this new thing.
BOOL goalModeFromOrTo;
    
//all GTween object are chained together in a loop which 
//runs on the surface.
GTween *prevTween;
GTween *nextTween;
    
GTween *prevSequence;
GTween *nextSequence;
    
GTween *prevSibling;
GTween *nextSibling;

BOOL targetWasDestroyed;

BOOL isFinished;
BOOL hasTweenAfter;
    
    int numTimesRelease;
    
}

+ (void) debugNameForTween:(NSString *)debugName;

+ (GTween *) tweenProp:(NSString *)prop 
            duration:(int)dur 
               delay:(int)del 
                 goal:(float)goal
              easing:(NSString *)ease
          withTarget:(GNode *)targ;
          
- (void) reset;
- (void) reverse;

- (void) run:(float)val;

- (float) getStartPoint;

- (GNode *) target;
- (void) setTarget:(GNode *)targ;

- (void) setStartAndDeltaValuesToModeTween;

- (void) setStartAndDeltaValuesFromModeTween;

- (void) setTargetWasDestroyed;

- (GTweenInfo *) getInfoObject;

//@property (nonatomic, assign) GBox *target;

- (id) initWithTarget:(GNode *)targ easing:(NSString *)ease delay:(int)del duration:(int)duration goal:(float)goal;

@property (nonatomic, assign) NSString *name;

@property (nonatomic, assign) GTweenGroup *parentGroup;

@property (nonatomic, assign) NSString *startEvt;
@property (nonatomic, assign) NSString *endEvt;

@property (nonatomic, assign) GEaseEquation *equation;

@property (nonatomic, assign) int animationCurrentCode;

@property (nonatomic, assign) id startTarg;
@property (nonatomic, assign) id endTarg;

@property (nonatomic, assign) int goalMode;

@property (nonatomic, assign) BOOL goalModeFromOrTo;

@property (nonatomic, assign) int delay;

@property (nonatomic, assign) int delayCnt;

@property (nonatomic, assign) float goal;

@property (nonatomic, assign) float startPoint;

@property (nonatomic, assign) float interval;

@property (nonatomic, assign) int dur;

@property (nonatomic, assign) int pos;

@property (nonatomic, assign) BOOL isFirst,isLast;

@property (nonatomic, assign) GTween *nextTween,*prevTween,*nextSequence,*prevSequence,*prevSibling,*nextSibling;
@property (nonatomic, assign) BOOL isFinished;

@end


//the available tweens

@interface GTween_x : GTween {
GNode *gNodeTarg;
}

@end

@interface GTween_y : GTween {
GNode *gNodeTarg;
}

@end

@interface GTween_opacity : GTween {
GNode *gNodeTarg;
}

@end

@interface GTween_rotation : GTween {
GNode *gNodeTarg;
}

@end

@interface GTween_scaleX : GTween {
GNode *gNodeTarg;
}

@end

@interface GTween_scaleY : GTween {
GNode *gNodeTarg;
}

@end

@interface GTween_scale : GTween {
GNode *gNodeTarg;
}

@end

@interface GTween_frame : GTween {
GSprite *gSpriteTarg;
}

@end

@interface GTween_red : GTween {
    GBox *gBoxTarg;
}

@end

@interface GTween_green : GTween {
    GBox *gBoxTarg;
}

@end

@interface GTween_blue : GTween {
    GBox *gBoxTarg;
}

@end

@interface GTween_time : GTween {
    GNode *gNodeTarg;
}

@end
