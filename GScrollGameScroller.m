//
//  CosmicDolphin_6
//
//  Created by Alexander  Lowe on 3/28/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GScrollGameScroller.h"
#import "GScrollGame.h"
#import "GRenderable.h"
#import "GScrollGame.h"



			
//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                  //
//   This is the container which does scrolling. There is only one tile, and everything             //
//   gets loaded onto it. The idea is that this guy scrolls however much, then it resets            //
//   and all of its contained object reset with it, so that it appears that they are                //
//   scrolling infinitely, but they're not.                                                         //
//                                                                                                  //
//   this came in handy at one point                                                                //
//   http://stackoverflow.com/questions/66882/simplest-way-to-check-if-two-integers-have-same-sign  //
//                                                                                                  //                   
//////////////////////////////////////////////////////////////////////////////////////////////////////


@implementation GScrollGameScroller


- (id) init {

self = [super init];

x = 0;
y = 0;

scroll_scrollX = 0;
scroll_scrollY = 0;

id_code = 0;

scroll_scrollState = NO;

//this is how far scrolling goes until 
//the layer resets itself. you can leave the
//thing scrolling all day and it won't ever 
//breach this number. That way, you don't have
//to worry about x/y values of 100,000,000,000
//or anything crazy.
scroll_scrollLimit = [[Gnar ly] screenWidth]-40;//1000;//500;//1000;
    
//See dev notes for an explanation of the upper limit of this value: IT CANNOT BE GREATER THAN THE SCREEN WIDTH (if horizontal scrolling)
//Why? because _hasBeenOn only gets calculated at the scroll-limit-resets. If it's greater than the screen width, then an object may get created,
//appear on screen and scroll off *but never get the _hasBeenOn set to YES and therefore is never available for deletion. This causes havok with
//the GSurfaceResourceManager code, which depends on sprites deleting.
    
    if(gOrientation == gPORTRAIT_MODE) {
        [NSException raise:@"Error" format:@"IS THIS MAHINA DOLPHIN? IF so, you have to set the _scrollLimit to screen-height. Actually you have to do a lot. Like re-write this scroll-game code. it's a mess."];
    }
    
_specialMode = 0;
_specialXAccelDone = NO;
_specialYAccelDone = NO;
_specialScroll = NO;

    #if gShowBoundaryBlocks == gYES
    topBx = [[GBox alloc] init];
    leftBx = [[GBox alloc] init];
    rightBx = [[GBox alloc] init];
    bottomBx = [[GBox alloc] init];
        
    [topBx rectWidth:_screenWidth andHeight:40 color:0xFF0000];
    [bottomBx rectWidth:_screenWidth andHeight:40 color:0xFF0000];

    [leftBx rectWidth:40 andHeight:_screenHeight color:0xFF9933];
    [rightBx rectWidth:40 andHeight:_screenHeight color:0xFF9933];

    [self addChild:topBx];
    [self addChild:bottomBx];

    [self addChild:rightBx];
    [self addChild:leftBx];
    #endif

return self;

}


/**
 * this is one of the initial-state functions.
 *
 */
- (void) initialState_setInitialXPosition:(float)xPos
                             andYPosition:(float)yPos
                             scrollXLimit:(float)xScrollLimit
                                 scrollDX:(float)scrollDX
                               scrollDirX:(float)dirX {
    
    x = xPos;
    y = yPos;
    
    //count.
    scroll_countX = xPos;
    scroll_countY = yPos;
    
    scroll_scrollX = 0;//_scrollX;
    scroll_scrollY = 0;//_scrollY;
    
    scroll_resetScrollX = NO;
    scroll_resetScrollY = NO;
    
    float dScrollCountX = scroll_countX - scroll_xLimit;
    float dScrollCountY = scroll_countY - scroll_yLimit;
    
    //if the count is past the limit, then reset the position, and tell all of the children (by way of the pseudo-global variable)
    //that it's time to reset their positions.
    if((dScrollCountX < 0) == (scroll_scrollDirX < 0)) {
        x = 0;
        scroll_scrollDX = scroll_countX;
        scroll_countX = 0;
        scroll_resetScrollX = YES;
        
    }
    
    //do the same thing down here that we did above.
    if((dScrollCountY < 0) == (scroll_scrollDirY < 0)) {
        y = 0;
        scroll_scrollDY = scroll_countY;
        scroll_countY = 0;
        scroll_resetScrollY = YES;
    }
    
    //update the edges according to scales and coordinates. we do not perform
    //the final scaling division here because the scale of this object never changes.
    geometry_topEdge = ( [_scrollGame geometry_topEdge] - y);
    geometry_bottomEdge = ([_scrollGame geometry_bottomEdge] - y);
    geometry_leftEdge = ([_scrollGame geometry_leftEdge] - x);
    geometry_rightEdge = ([_scrollGame geometry_rightEdge] - x);
    
    //_GSCROLLGAME_centerX = (_GSCROLLGAME_centerX - x);
    //_GSCROLLGAME_centerY = (_GSCROLLGAME_centerY - y);
    
}

/*
 
 
 [[_back getScroller] setScrollXLimit:xScrollLimit];
 [[_back getScroller] setScrollCountX:xScrollCount];
 [[_back getScroller] setScrollDX:scrollDX];
 [[_back getScroller] setScrollDirX:dirX];
 [[_back getScroller] initialState_setInitialXPosition:initialXPosition andYPosition:0];
 
 */


/**
 * this function will hijack the scrolling. It will remember what the current scrolling was,
 * and then it will set the program to a state where the specialized scrolling will take place.
 * 
 * makes use of the GEaseEquation classes, so any of the regular animation modes are available here.
 *
 * This function is interruptible with itself or the 
 * accelToXSpeed:(float)xAccel ySpeed:(float)yAccel withXDist:(float)xD yDist:(float)yD function.
 * it is safe to use at any time.
 *
 */
- (void) scrollXDist:(float)xD YDist:(float)yD withEase:(NSString *)ease andDuration:(int)dur resumeScroll:(BOOL)res {

///if we're in the acceleration mode, then switch 
//us back to the animation mode.
_specialMode = 1;
    
    //blows up.
    //get rid of the special equation if it exists.
    //if(_specialEquation) {
    //[_specialEquation release];
    //}


//generate a new animation equation from the ease string.
NSString *clss = @"GEase_";
clss = [clss stringByAppendingString:ease];
_specialEquation = [[NSClassFromString(clss) alloc] init];


    //if the equation exists, then finish the process. else,
    //let the world know that something went wrong.
    if(_specialEquation) {
    scroll_scrollState = YES;
    _specialDuration = dur;
    _specialXDist = xD;
    _specialYDist = yD;
    _specialTime = 0;
    _specialX = 0;
    _specialY = 0;
    _specialSavedScrollX = scroll_scrollX;
    _specialSavedScrollY = scroll_scrollY;
    _specialFF = YES;
    _specialScroll = YES;
    _specialUseSavedScrollValues = res;
    } else {
    NSLog(@"Error: no such animation class %@",clss);
    }
        
} 



/**
 * get the game bounds, which are the bounds of the screen as reported by an object on the 
 * GScrollGameScroller object.
 *
 */
- (CGRect) gameBounds {
return CGRectMake(
geometry_leftEdge,
geometry_topEdge,
geometry_rightEdge  - geometry_leftEdge,
geometry_bottomEdge - geometry_topEdge
);
}
- (void) setGameBounds:(CGRect)rect {
//take no action.
}


/**
 * this function wil hijack the scrolling with one of the special modes. This mode is the 'morph' mode, which will morph the 
 * scrolling from one speed to another. It's NOT a simple acceleration, because there's an acceleration of an acceleration. Unlike
 * the accleration function, this function will change the speed from sI to sF over a specified distance, *and a specified 
 * number of steps*
 *
 *
 */
- (void) morphFromXSpeed:(float)xSI ySpeed:(float)ySI toXSpeed:(float)xSF andYSpeed:(float)ySF withXDist:(float)xD yDist:(float)yD numXSteps:(int)numX numYSteps:(int)numY {

_specialMode = 3;
scroll_scrollState = YES;
_specialScroll = YES;

_specialMorphXDist = xD;
_specialMorphYDist = yD;

_specialMorphStackXSteps = 0;
_specialMorphStackYSteps = 0;

_specialMorphXDone = NO;
_specialMorphYDone = NO;

_specialMorphXSpeedI = xSI;
_specialMorphXSpeedF = xSF;

_specialMorphYSpeedI = ySI;
_specialMorphYSpeedF = ySF;

_specialMorphXSteps = numX;
_specialMorphYSteps = numY;

_specialMorphAccelX0 = 6*(numX*xSI - (((numX+2.0)/3.0)*(xSI - xSF)) - xD)/(numX*(numX-1));  
_specialMorphAccelX1 = (xSI -  xSF - (numX*_specialMorphAccelX0))/((numX/2.0)*(numX+1));

_specialMorphAccelY0 = 6*(numY*ySI - (((numY+2.0)/3.0)*(ySI - ySF)) - yD)/(numY*(numY-1));  
_specialMorphAccelY1 = (ySI -  ySF - (numY*_specialMorphAccelY0))/((numY/2.0)*(numY+1));
}



/**
 * perform a scroll acceleration. This solution came from book 2, pg 119,120 - and it also 
 * appears in book 1, pg 112,113.
 *
 * This function is interruptible with itself or with the 
 * scrollXDist:(float)xD YDist:(float)yD withEase:(NSString *)ease andDuration:(int)dur
 * function. It is safe to use at any time.
 *
 */
- (void) accelToXSpeed:(float)xAccel ySpeed:(float)yAccel withXDist:(float)xD yDist:(float)yD {

//switch us to the acceleration special state.
_specialMode = 2;
_specialXDist = xD;
_specialYDist = yD;

    //filter out crazy distances.
    if(_specialXDist <= 0) {
    _specialXDist = 10;
    }
    if(_specialYDist <= 0) {
    _specialYDist = 10;
    }
    
scroll_scrollState = YES;
_specialScroll = YES;
_specialXAccelDone = NO;
_specialYAccelDone = NO;

int xAUnit = round(xAccel/fabs(xAccel));
int yAUnit = round(yAccel/fabs(yAccel));
int sXUnit = round(scroll_scrollX/fabs(scroll_scrollX));
int sYUnit = round(scroll_scrollY/fabs(scroll_scrollY));

//use the calculus solution- book 2, pg 219,200 and book 1, pg 112,113.
_specialXAccel = (xAUnit*xAccel*xAccel - sXUnit*scroll_scrollX*scroll_scrollX)/(2*_specialXDist);
_specialYAccel = (yAUnit*yAccel*yAccel - sYUnit*scroll_scrollY*scroll_scrollY)/(2*_specialYDist);

_specialXDistStart = x;
_specialYDistStart = y;

_specialXEndSpeed = xAccel;
_specialYEndSpeed = yAccel;

}


/**
 * interrupt the special scrolling.
 *
 */
- (void) interruptSpecialScroll {
_specialScroll = NO;
}



- (void) setTheIDCode:(int)code {

id_code = code;

}


/**
 * should be sufficient to stop all scrolling action.
 *
 */
- (void) stopAllScrollingAndReset {
self.scrollX = 0;
self.scrollY = 0;

_specialScroll = NO;

_specialMode = 0;
scroll_scrollDX = 0;
scroll_scrollDY = 0;
_specialXAccel = 0;
_specialYAccel = 0;
    
scroll_resetScrollX = NO;
scroll_resetScrollY = NO;

x = 0;
y = 0;

scroll_countX = 0;
scroll_countY = 0;

//update the edges according to scales and coordinates. we do not perform
//the final scaling division here because the scale of this object never changes.
geometry_topEdge = ([_scrollGame geometry_topEdge] - y);
geometry_bottomEdge = ([_scrollGame geometry_bottomEdge] - y);
geometry_leftEdge = ([_scrollGame geometry_leftEdge] - x);
geometry_rightEdge = ([_scrollGame geometry_rightEdge] - x);

    
//2015-10-25 ????
//These lines should have no effect or I'm nuts.
//_GSCROLLGAME_centerX = (_GSCROLLGAME_centerX - x);
//_GSCROLLGAME_centerY = (_GSCROLLGAME_centerY - y);

}


- (void) shiftScrollerAndGameObjects {
    
    x = 0;
    scroll_scrollDX = scroll_countX;
    scroll_countX = 0;
    
    GBox *firstSib = (GBox *)firstChild;
    GBox *nextSib;
    

    //update the edges according to scales and coordinates. we do not perform
    //the final scaling division here because the scale of this object never changes.
    geometry_topEdge = ([_scrollGame geometry_topEdge] - y);
    geometry_bottomEdge = ([_scrollGame geometry_bottomEdge] - y);
    geometry_leftEdge = ([_scrollGame geometry_leftEdge] - x);
    geometry_rightEdge = ([_scrollGame geometry_rightEdge] - x);
    

    
    int j=0;
    
    while(firstSib) {
        j++;
        nextSib = (GBox *)firstSib.nextSibling;
        [firstSib resetScrollingShit];
        firstSib = nextSib;
    }
    
}


- (BOOL) isGameObjectWithinHorizontalWithRightBound:(float)r andLeftBound:(float)l {
return (l < geometry_rightEdge && r > geometry_leftEdge);
}


/**
 * render. lock out or enable separate scrolling modes depending on what state this
 * thing is in.
 *
 */
- (GRenderable *) render {
    
    opacity = parent.opacity;


    if(scroll_scrollState == YES) {
    
        //we're going to recalculate the scrollX/Y here for the
        //specialized animated scrolling.
        if(_specialScroll == YES) {
        
            if(_specialMode == 1) {
        
            //get the correct value.
            _specialX = [_specialEquation runStart:0 delta:_specialXDist time:_specialTime duration:_specialDuration];
            _specialY = [_specialEquation runStart:0 delta:_specialYDist time:_specialTime duration:_specialDuration];
            
                //if there's a previous value, then get the
                //difference. that will be the scrolling value.
                if(_specialFF == NO) {
                self.scrollX = _specialX - _specialPrevX;
                self.scrollY = _specialY - _specialPrevY;
                } 
            
            //set to NO.
            _specialFF = NO;
            
            //set the previous values so the the deltas
            //can be calculated the next time around.
            _specialPrevX = _specialX;
            _specialPrevY = _specialY;
            
            //increment.
            _specialTime++;
            
                //if we're at the end, then get rid of the
                //equation, end the special period and
                //reset the scrolling to the saved variables.
                if(_specialTime > _specialDuration) {
                [_specialEquation release];
                _specialScroll = NO;
                _specialTime = 0;
                
                    //set the scrolling back to the original values,
                    //if that's what we're supposed to do.
                    if(_specialUseSavedScrollValues == YES) {
                    self.scrollX = _specialSavedScrollX;
                    self.scrollY = _specialSavedScrollY;
                    } 
                    
                    //otherwise, the scrolling is zero, so just zero
                    //out the scrolling behavior.
                    else {
                    scroll_scrollState = NO;
                    }

                }
            
            } else 
            
            //if we're in an acceleration mode, then accelerate the scroll, and
            //see if we're done scrolling. reset the state back to ordinary mode
            //if we are done scrolling.
            if(_specialMode == 2) {
            
            self.scrollX += _specialXAccel;
            self.scrollY += _specialYAccel;
            
            float dScrollX = scroll_scrollX - _specialXEndSpeed;
            float dScrollY = scroll_scrollY - _specialYEndSpeed;
            
                //if the increment is pointing in the same direction as the acceleration vector, then the goal has been reached,
                //so flip the switch.
                //if(  (dScrollX <= 0 && _specialXAccel <= 0) || (dScrollX > 0 && _specialXAccel > 0) ) {
                if((dScrollX < 0) == (_specialXAccel < 0)) {
                self.scrollX = _specialXEndSpeed;
                _specialXAccelDone = YES;
                }
                
                //if(  (dScrollY <= 0 && _specialYAccel <= 0) || (dScrollY > 0 && _specialYAccel > 0) ) {
                if((dScrollY < 0) == (_specialYAccel < 0)) {
                self.scrollY = _specialYEndSpeed;
                _specialYAccelDone = YES;
                }
                
                //if both switches are flipped, then reset to the ordinary scrolling mode.
                if(_specialXAccelDone == YES && _specialYAccelDone == YES) {
                _specialScroll = NO;
                }
                
            } else
            
            //else, we are in a morph mode, where we are supposed to reach a certain point with a certain speed at a certain
            //time. this calculation is pretty sophisticated- the whole thing amounts to a discrete solution of a second-order
            //acceleration boundary value problem. It's documented pretty well in book 2, pg 126-131.
            if(_specialMode == 3) {
            
            _specialMorphAccelX0+=_specialMorphAccelX1;
            scroll_scrollX-=_specialMorphAccelX0;
            _specialMorphStackXSteps++;
            
            _specialMorphAccelY0+=_specialMorphAccelY1;
            scroll_scrollY-=_specialMorphAccelY0;
            _specialMorphStackYSteps++;
            
                if(_specialMorphStackXSteps >= _specialMorphXSteps) {
                scroll_scrollX = _specialMorphXSpeedF;
                _specialMorphXDone = YES;
                } 
                
                if(_specialMorphStackYSteps >= _specialMorphYSteps) {
                scroll_scrollY = _specialMorphYSpeedF;
                _specialMorphYDone = YES;
                } 
            
                //if the morphin both x and y is done, then zero out 
                //the special scrolling, and if the final speeds are both
                //zero, cancel all scrolling behavior.
                if(_specialMorphXDone == YES && _specialMorphYDone == YES) {
                _specialScroll = NO;
                
                    if(_specialMorphXSpeedF == 0 && _specialMorphYSpeedF == 0) {
                    scroll_scrollState = NO;
                    }
                
                }
            
            }
        
        }
     
    x += scroll_scrollX;
    y += scroll_scrollY;
        
    
    //count.
    scroll_countX += scroll_scrollX;
    scroll_countY += scroll_scrollY;
        
    scroll_resetScrollX = NO;
    scroll_resetScrollY = NO;
    
    float dScrollCountX = scroll_countX - scroll_xLimit;
    //float dScrollCountY = _scrollCountY - _scrollYLimit;
    
        //if the count is past the limit, then reset the position. this will affect all the children
        if((dScrollCountX < 0) == (scroll_scrollDirX < 0)) {
        [self shiftScrollerAndGameObjects];
        }
        
    }
    

//update the edges according to scales and coordinates. we do not perform
//the final scaling division here because the scale of this object never changes.
geometry_topEdge = ([_scrollGame geometry_topEdge] - y);
geometry_bottomEdge = ([_scrollGame geometry_bottomEdge] - y);
geometry_leftEdge = ([_scrollGame geometry_leftEdge] - x);
geometry_rightEdge = ([_scrollGame geometry_rightEdge] - x);


    //2015-10-25 ????
    //why are we setting these values here? shouldn't the scrollgame know about this?
    //_GSCROLLGAME_centerX = (_GSCROLLGAME_centerX - x);
    //_GSCROLLGAME_centerY = (_GSCROLLGAME_centerY - y);
    
    #if gShowBoundaryBlocks == gYES
    
    topBx.y = geometry_topEdge;
    topBx.x = geometry_leftEdge;

    bottomBx.y = geometry_bottomEdge - 40;
    bottomBx.x = geometry_leftEdge;

    leftBx.x = geometry_leftEdge;
    leftBx.y = geometry_topEdge;

    rightBx.x = geometry_rightEdge - 40;
    rightBx.y = geometry_topEdge;
    
    #endif



/////////
//This is the transformation of x',y' point [0,0] to local coordinates.
//The notes are in the note book
/*

GScrollGame *sc = (GScrollGame *) parent;

float topLeftX = (0 - x - sc.realX)/parent.scaleX;
float topLeftY = (0 - y - sc.realY)/parent.scaleY;

float topRightX = (_screenWidth - x - sc.realX)/parent.scaleX;
float topRightY = (0 - y - sc.realY)/parent.scaleY;

float bottomLeftX = (0 - x - sc.realX)/parent.scaleX;
float bottomLeftY = (_screenHeight - y - sc.realY)/parent.scaleY;

//float bottomRightX = (_screenWidth  - x - parent.x)/parent.scaleX;
//float bottomRightY = (_screenHeight - y - parent.y)/parent.scaleY;

topBx.y = topLeftY;
topBx.x = topLeftX;

bottomBx.y = bottomLeftY - 10;
bottomBx.x = bottomLeftX;

leftBx.x = topLeftX;
leftBx.y = topLeftY; 

rightBx.x = topRightX - 10;
rightBx.y = topRightY; 
*/ 

return [super render];

}


- (void) setScrollGame:(GScrollGame *)game {
_scrollGame = game;
}

- (BOOL) scroll_state {
    return scroll_state;
}

- (float) scroll_countX {
    return scroll_countX;
}
- (float) scroll_xLimit {
    return scroll_xLimit;
}
- (float) scroll_scrollDX {
    return scroll_scrollDX;
}
- (int) scroll_scrollDirX {
    return scroll_scrollDirX;
}
- (float) geometry_topEdge {
    return geometry_topEdge;
}
- (float) geometry_bottomEdge {
    return geometry_bottomEdge;
}
- (float) geometry_leftEdge {
    return geometry_leftEdge;
}
- (float) geometry_rightEdge {
    return geometry_rightEdge;
}


/**
 * the scroll accessors. cache some important information
 * whenever the scroll changes. It is never safe to write
 * directly to the _scrollX/Y variables. Always use the
 * accessors to write.
 *
 */
- (void) setScrollX:(float)scX {
    scroll_scrollX = scX;
    
    if(scX < 0) {
        scroll_scrollIncX = scX;
        scroll_scrollDirX = -1;
        scroll_xLimit = - scroll_scrollLimit;
    } else {
        scroll_scrollIncX = scX;
        scroll_scrollDirX = 1;
        scroll_xLimit = scroll_scrollLimit;
    }
    
    if(scX == 0 && scroll_scrollY == 0) {
        scroll_scrollState = NO;
        scroll_scrollState = NO;
    } else {
        scroll_scrollState = YES;
        scroll_scrollState = YES;
    }
}
- (void) setScrollY:(float)scY {
    scroll_scrollY = scY;
    
    if(scY < 0) {
        scroll_scrollIncY = scY;
        scroll_scrollDirY = -1;
        scroll_yLimit = - scroll_scrollLimit;
    } else {
        scroll_scrollIncY = scY;
        scroll_scrollDirY = 1;
        scroll_yLimit = scroll_scrollLimit;
    }
    
    if(scY == 0 && scroll_scrollX == 0) {
        scroll_scrollState = NO;
        scroll_scrollState = NO;
    } else {
        scroll_scrollState = YES;
        scroll_scrollState = YES;
    }
}

- (float) scrollX {
    return scroll_scrollX;
}
- (float) scrollY {
    return scroll_scrollY;
}




@end
