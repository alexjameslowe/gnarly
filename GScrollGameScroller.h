//
//  CosmicDolphin_6
//
//  Created by Alexander  Lowe on 3/28/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GScrollGameObjects.h"
#import "GAnimation.h"
#import "GEaseEquation.h"
#import "GBox.h"
#define gShowBoundaryBlocks gNO


//pseudo-global variables, to avoid calls in the
//performance-sensitive render code of GScrollGameBox/Sprite.
//BOOL  _GSCROLLGAMESCROLLER_scrollState;
//BOOL  _GSCROLLGAMESCROLLER_resetScrollX;
//BOOL  _GSCROLLGAMESCROLLER_resetScrollY;
//float _GSCROLLGAMESCROLLER_rightEdge;
//float _GSCROLLGAMESCROLLER_leftEdge;
//float _GSCROLLGAMESCROLLER_topEdge;
//float _GSCROLLGAMESCROLLER_bottomEdge;
//float _GSCROLLGAMESCROLLER_scrollDX;
//float _GSCROLLGAMESCROLLER_scrollDY;
//float _GSCROLLGAMESCROLLER_scrollX;
//float _GSCROLLGAMESCROLLER_scrollY;



@class GScrollGame;

@interface GScrollGameScroller : GBox {


#if gShowBoundaryBlocks == gYES
//for testing. 
GBox *topBx,*leftBx,*rightBx,*bottomBx;
#endif

//dont think we even need these.
float _leftEdge,_rightEdge,_topEdge,_bottomEdge;

//are in a special scroll?
BOOL _specialScroll;

//which special mode are you in? 1 for animation, 2 for acceleration.
int _specialMode;
    
//the edges of the game in this coordinate system.
float geometry_rightEdge;
float geometry_leftEdge;
float geometry_topEdge;
float geometry_bottomEdge;
    
//the unsigned scroll increments
float scroll_scrollIncX;
float scroll_scrollIncY;
    
//the directions of the current scroll
int scroll_scrollDirX;
int scroll_scrollDirY;

//the state of the scroll. animation?
BOOL  scroll_scrollState;
    
//are we at a point that the scroller will be reset?
BOOL  scroll_resetScrollX;
BOOL  scroll_resetScrollY;

//the delta-x/y by which the scroller is going to be shifted
float scroll_scrollDX;
float scroll_scrollDY;
    
//the current scrolling x and y speeds
float scroll_scrollX;
float scroll_scrollY;
    
//the limit at which a shift will be performed
int scroll_xLimit;
int scroll_yLimit;

//the raw limit value.
int scroll_scrollLimit;

//are we scrolling at all?
BOOL scroll_state;

//the counts to keep track of where we are relative to the limits
float scroll_countX, scroll_countY;
    
GScrollGame *_scrollGame;
    

GEaseEquation *_specialEquation;
float _specialSavedScrollX,_specialSavedScrollY;
float _specialXDist,_specialYDist,_specialX,_specialY,_specialPrevX,_specialPrevY;
int _specialDuration,_specialTime;
BOOL _specialFF;
BOOL _specialUseSavedScrollValues;

float _specialXAccel,_specialYAccel;
float _specialXAccelDist,_specialYAccelDist;
float _specialXDistStart,_specialYDistStart;
float _specialXEndSpeed,_specialYEndSpeed;
BOOL  _specialXAccelDone,_specialYAccelDone;

float _specialMorphAccelX0,_specialMorphAccelY0,_specialMorphAccelX1,_specialMorphAccelY1;
int _specialMorphXSteps,_specialMorphYSteps,_specialMorphStackXSteps,_specialMorphStackYSteps;
float _specialMorphXDist,_specialMorphYDist;
float _specialMorphXSpeedI,_specialMorphYSpeedI,_specialMorphXSpeedF,_specialMorphYSpeedF;
BOOL _specialMorphXDone,_specialMorphYDone;

int id_code;

}

- (void) setTheIDCode:(int)code;

- (void) stopAllScrollingAndReset;

- (void) shiftScrollerAndGameObjects;

- (void) initialState_setInitialXPosition:(float)xPos
                             andYPosition:(float)yPos
                             scrollXLimit:(float)xScrollLimit
                                 scrollDX:(float)scrollDX
                               scrollDirX:(float)dirX;




/////////////
//         //
//  A P I  //
//         //
/////////////

//set/get the scrolling.
- (void) setScrollX:(float)scX;
- (void) setScrollY:(float)scY;
- (float) scrollX;
- (float) scrollY;

- (BOOL) scroll_state;

- (float) scroll_countX;
- (float) scroll_xLimit;
- (float) scroll_scrollDX;
- (int) scroll_scrollDirX;

- (float) geometry_topEdge;
- (float) geometry_bottomEdge;
- (float) geometry_leftEdge;
- (float) geometry_rightEdge;

- (void) setScrollGame:(GScrollGame *)game;

- (BOOL) isGameObjectWithinHorizontalWithRightBound:(float)r andLeftBound:(float)l;



- (CGRect) gameBounds;
- (void) setGameBounds:(CGRect)rect;

- (void) interruptSpecialScroll;

- (void) scrollXDist:(float)xD YDist:(float)yD withEase:(NSString *)ease andDuration:(int)dur resumeScroll:(BOOL)res;

- (void) accelToXSpeed:(float)xAccel ySpeed:(float)yAccel withXDist:(float)xD yDist:(float)yD;

- (void) morphFromXSpeed:(float)xSI ySpeed:(float)ySI toXSpeed:(float)xSF andYSpeed:(float)ySF withXDist:(float)xD yDist:(float)yD numXSteps:(int)numX numYSteps:(int)numY;



@end
