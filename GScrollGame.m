//
//  CosmicDolphin_6
//
//  Created by Alexander  Lowe on 3/28/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GScrollGame.h"
#import "GScrollGameScroller.h"
#import "GScrollBackgroundTile.h"
#import "GScrollGameObjects.h"
#import "GAnimation.h"
#import "GSprite.h"

//#import "NewGameTable.h"


///////////////////////////////////////////////////
//                                               //
//  camera tweens for the scrolling game system  //
//                                               //
///////////////////////////////////////////////////


@implementation GTween_cameraX
- (void) run:(float)val {
[cameraTarget setCameraX:val];
}
- (float) getStartPoint {
return [cameraTarget cameraX];
}
- (void) setTarget:(GNode *)targ {
cameraTarget = (GScrollCamera *)targ;
}
@end


@implementation GTween_cameraY
- (void) run:(float)val {
[cameraTarget setCameraY:val];
}
- (float) getStartPoint {
return [cameraTarget cameraY];
}
- (void) setTarget:(GNode *)targ {
cameraTarget = (GScrollCamera *)targ;
}
@end


@implementation GTween_cameraZ
- (void) run:(float)val {
[cameraTarget setCameraZ:val];
}
- (float) getStartPoint {
return [cameraTarget cameraZ];
}
- (void) setTarget:(GNode *)targ {
cameraTarget = (GScrollCamera *)targ;
}
@end


@implementation GTween_gameSize
- (void) run:(float)val {
    [gameTarget setGameSize:val];
}
- (float) getStartPoint {
    return [gameTarget gameSize];
}
- (void) setTarget:(GNode *)targ {
    gameTarget = (GScrollGame *)targ;
}
@end




////////////////////////////////////////////
//                                        //
//  camera for the scrolling game system  //
//                                        //
////////////////////////////////////////////



@implementation GScrollCamera


- (id) init {

self = [super init];

_cameraXPointer = &_cameraX;
_cameraYPointer = &_cameraY;
_cameraZPointer = &_cameraZ;

_cameraX = 0;
_cameraY = 0;
_cameraZ = 0;


return self;
}


- (void) setCameraX:(float)val {
_cameraX = val;
}
- (float) cameraX {
return _cameraX;
}
- (void) setCameraY:(float)val {
_cameraY = val;
}
- (float) cameraY {
return _cameraY;
}
- (void) setCameraZ:(float)val {
_cameraZ = val;
}
- (float) cameraZ {
return _cameraZ;
}


- (float *) getCameraXPointer {
return _cameraXPointer;
}
- (float *) getCameraYPointer {
return _cameraYPointer;
}
- (float *) getCameraZPointer {
return _cameraZPointer;
}

@end





///////////////////////////////////////////////////////////////////////////////////////
//                                                                                   //
//   This is a game table object for the kinds of games that require scrolling.      //
//   This class permits unlimited 2D scrolling/translating and scaling.              // 
//                                                                                   //                   
///////////////////////////////////////////////////////////////////////////////////////

/**

 from 2014-04-05
 
I've just spent two days miserably tinkering with the GScrollGame code/GSurfaceResourceManager code, and for a little while I was afraid that it was hoplessly f_cked up. Here's what the problem was: The scroll limit was set to 1000. See, the GScrollGameSprite will not delete an out-of-bounds sprite unless the _hasBeenOn is set to YES. **BUT** the _hasBeenOn only gets set to YES during the scroll-limit resets. So here's the hard lesson: ###If you set the scroll limit to greater than the screen's width, then a sprite will be scrolled off the screen before it EVER GETS A CHANCE TO EVALUATE FOR THE _hasBeenOn VARIABLE. You'll have a memory leak. Worse, it was causing a real problem with the GSurfaceResource manager, because these never-releasing sprites were darkspace-extending-sprites, and so the GSurfaceResourceManager was caught perpetually in lightening-space. Holy shit, that was a tough thing to figure out. So therefore, the maximum scroll-limit is the width of the screen. ##WARNING## this is something that has to get changed when I migrate the code back to MahinaDolphin. I've saved a version with all of the logs in there called "BraveRocket 2 Bug 2014-04-05". Just fire it up and let'r rip. keep the rocket on the screen. Collision detection is turned off, so it's going to just keep creating and deleting resources and you can see the sprites incrementing and decremeneting.
 
 **/


@implementation GScrollGame


/**
 * init. easy breezy.
 *
 */
- (id) init {

    self = [super init];
    
    _focalLength = 250;
    
    _defaultCamX = 0;
    _defaultCamY = 0;
    _defaultCamZ = 0;
    
    _pFactor = 1;
    _size = 1;
    
    _cameraXPointer = &_defaultCamX;
    _cameraYPointer = &_defaultCamY;
    _cameraZPointer = &_defaultCamZ;
    
    self.x = _screenCenterX;
    self.y = _screenCenterY;
    self.z = 0;
    

    self.name = @"gscrollgame";

    _tileAdded = NO;
    _tile = [[GScrollGameScroller alloc] init];
    [_tile setScrollGame:self];
    [self addChild:_tile];
    
    _tileAdded = YES;
    
    _motherFucker = NO;
    
    showBoundaryBoxes = NO;//YES;
    
        if(showBoundaryBoxes == YES) {
        
        leftBx = [[GBox alloc] init];
        [leftBx rectWidth:10*_screenHiResScale andHeight:_screenHeight color:0xFF0000];
        [self addChild:leftBx];
        
        rightBx = [[GBox alloc] init];
        [rightBx rectWidth:10*_screenHiResScale andHeight:_screenHeight color:0xFF00FF];
        [self addChild:rightBx];
            
        topBx = [[GBox alloc] init];
        [topBx rectWidth:_screenWidth andHeight:10*_screenHiResScale color:0xFFFF00];
        [self addChild:topBx];
            
        bottomBx = [[GBox alloc] init];
        [bottomBx rectWidth:_screenWidth andHeight:10*_screenHiResScale color:0x00FFFF];
        [self addChild:bottomBx];
            
        }

    return self;

}


//Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
+ (void) decrementObjectsInPlayAndReport {
}


- (void) setLastTileCreated:(GScrollBackgroundTile *)lastTileCreated {
    if(_lastTileCreated) {
    [_lastTileCreated release];
    }
    
_lastTileCreated = lastTileCreated;
[_lastTileCreated retain];
}
- (GScrollBackgroundTile *)lastTileCreated {
    return _lastTileCreated;
}



/**
 * these functions will recursively assign the pointers for the camera to all of the 
 * perspective layers on the stack.
 *
 */
- (void) setCameraOnBackground:(GScrollCamera *)cam {
_camera = cam;
_cameraXPointer = [_camera getCameraXPointer];
_cameraYPointer = [_camera getCameraYPointer];
_cameraZPointer = [_camera getCameraZPointer];

    if(_back) {
    [_back bubbleCameraBack:cam pointerX:_cameraXPointer pointerY:_cameraYPointer pointerZ:_cameraZPointer];
    }

}
- (void) bubbleCameraFront:(GScrollCamera *)cam pointerX:(float *)xP pointerY:(float *)yP pointerZ:(float *)zP {
_camera = cam;
_cameraXPointer = xP;
_cameraYPointer = yP;
_cameraZPointer = zP;

    if(_front) {
    [_front bubbleCameraFront:cam pointerX:_cameraXPointer pointerY:_cameraYPointer pointerZ:_cameraZPointer];
    }

}
- (void) bubbleCameraBack:(GScrollCamera *)cam pointerX:(float *)xP pointerY:(float *)yP pointerZ:(float *)zP{
_camera = cam;
_cameraXPointer = xP;
_cameraYPointer = yP;
_cameraZPointer = zP;

    if(_back) {
    [_back bubbleCameraBack:cam pointerX:_cameraXPointer pointerY:_cameraYPointer pointerZ:_cameraZPointer];
    }
}


- (void) setFront:(GScrollGame *)f {
_front = f;
}
- (GScrollGame *) front {
return nil;
}








/**
 * render. set the boundaries to account for postion and scale. The tile will perform further 
 * operations.
 *
 */
- (GRenderable *) render {

_pFactor = (_focalLength/(_focalLength+(_z-(*_cameraZPointer))));

x = _screenCenterX - (*_cameraXPointer)*_pFactor;
y = _screenCenterY - (*_cameraYPointer)*_pFactor;

scaleX = _pFactor;
scaleY = _pFactor;

//Here's the question. What do these correspond to? they correspond to the edges
//of the screen as reported by an observer in this system.
geometry_topEdge = -y/scaleY;
geometry_bottomEdge = (_screenHeight - y)/scaleY;
geometry_leftEdge = -x/scaleX;
geometry_rightEdge = (_screenWidth - x)/scaleX;

geometry_centerX = (_screenCenterX - x)/scaleX;
geometry_centerY = (_screenCenterY - y)/scaleY;
    
    if(showBoundaryBoxes == YES) {
    leftBx.x = geometry_leftEdge;
    leftBx.y = geometry_topEdge;
    rightBx.x = geometry_rightEdge - (10*_screenHiResScale);
    rightBx.y = geometry_topEdge;
        
    topBx.x = geometry_leftEdge;
    topBx.y = geometry_topEdge;
    bottomBx.x = geometry_leftEdge;
    bottomBx.y = geometry_bottomEdge - (10*_screenHiResScale);
    }
    
return [super render];

}



/////////////
//         //
//  A P I  //
//         //
/////////////



/**
 * not all of this stuff is calculated right when you instantiate it in the gnarlySaysBuild delegate.
 * It requires at least one frame of rendering before all of the necessary arithmetic is done.
 * so, call this function if you need the arithmetic to exist immediately.
 *
 */
- (void) setUpFrame {
    
    _pFactor = (_focalLength/(_focalLength+(_z-(*_cameraZPointer))));
    
    x = _screenCenterX - (*_cameraXPointer)*_pFactor;
    y = _screenCenterY - (*_cameraYPointer)*_pFactor;
    
    scaleX = _pFactor;
    scaleY = _pFactor;
    
    geometry_topEdge = -y/scaleY;
    geometry_bottomEdge = (_screenHeight - y)/scaleY;
    geometry_leftEdge = -x/scaleX;
    geometry_rightEdge = (_screenWidth - x)/scaleX;
    
    geometry_centerX = (_screenCenterX - x)/scaleX;
    geometry_centerY = (_screenCenterY - y)/scaleY;
    
    if(_back) {
        [_back setUpFrame];
    }
    
}


/**
 * this will immediately kill whatever scrolling/animations are going on and it will also 
 * reset the thing back to the center coordinates.
 *
 */
- (void) reset {

    if(_camera) {
    [GAnimation destroyTweensForTarget:_camera];
    //cameraTween = nil;
    //_camera.cameraX = 0;
    //_camera.cameraY = 0;
    //_camera.cameraZ = 0;
    }
    
_pFactor = (_focalLength/(_focalLength+(_z-(*_cameraZPointer))));

x = _screenCenterX - (*_cameraXPointer)*_pFactor;
y = _screenCenterY - (*_cameraYPointer)*_pFactor;

scaleX = _pFactor;
scaleY = _pFactor;

geometry_topEdge = -y/scaleY;
geometry_bottomEdge = (_screenHeight - y)/scaleY;
geometry_leftEdge = -x/scaleX;
geometry_rightEdge = (_screenWidth - x)/scaleX;

geometry_centerX = (_screenCenterX - x)/scaleX;
geometry_centerY = (_screenCenterY - y)/scaleY;
    
[_tile stopAllScrollingAndReset];

    if(_back) {
    [_back reset];
    }

}

- (void) addElement:(GBox *)newBox {
    if(_tileAdded == YES) {
        
    [(id <GScrollGameObject>) newBox setGame:self andScroller:_tile];

    [(id<GScrollGameObject>) newBox objectAppearedOnGame];
    [_tile addChild:newBox];
    }
}


- (void) addElement:(GBox *)newBox before:(GBox *)ref {
    if(_tileAdded == YES) {
        
    [(id <GScrollGameObject>) newBox setGame:self andScroller:_tile];

    [(id<GScrollGameObject>) newBox objectAppearedOnGame];
    [_tile addChild:newBox before:ref];
    }
}

- (void) addElementInBack:(GBox *)newBox {
    if(_tileAdded == YES) {
        
    [(id <GScrollGameObject>) newBox setGame:self andScroller:_tile];

    [(id<GScrollGameObject>) newBox objectAppearedOnGame];
    [_tile addInBack:newBox];
    }
}


- (void) removeElement:(GBox *)box {
    if(_tileAdded == YES) {
    [_tile removeChild:box];
    }
}




- (void) empty {
    if(_tileAdded == YES) {
    [_tile empty];
    } //else {
    //[super empty];
    //}
}


- (void) setTheIDCode:(int)code {

id_code = code;
[_tile setTheIDCode:code];

}


/**
 * set the background. whenever a scroll or animation is set here,
 * the background will reciprocate. Once you set this you can't unset it.
 *
 */
- (void) setBackground:(GScrollGame *)back withAtlasKey:(NSString *)key
             unitWidth:(float)uW unitHeight:(float)uH
            unitScaleX:(float)uScX unitScaleY:(float)uScY
           patternFunc:(NSString *)func
           andObserver:(id)obs
         /* initialTileX:(float)tileX
          initialTileY:(float)tileY
       initialTileLeft:(float)tileLeft
        initialTileTop:(float)tileTop
          initialCellX:(int)tileCellX
          initialCellY:(int)tileCellY
      initialCellIsTop:(BOOL)initialCellIsTop
   initialCellIsBottom:(BOOL)initialCellIsBottom
     initialCellIsLeft:(BOOL)initialCellIsLeft
    initialCellIsRight:(BOOL)initialCellIsRight*/
{
    
    _back = back;
    
    _back.front = self;
    
    _back.scrollX = _scrollX;
    _back.scrollY = _scrollY;
    
    if(_camera) {
        [_back setCameraOnBackground:_camera];
    }
    
    SEL f = NSSelectorFromString([func stringByAppendingString:@":"]);
    
    //saved_observer = obs;
    //saved_unitWidth = uW;
    //saved_unitHeight = uH;
    //saved_unitScaleX = uScX;
    //saved_unitScaleY = uScY;
    //saved_patternCallback = NSSelectorFromString([func stringByAppendingString:@":"]);
    
    _savedAtlasKey = key;
    
    _savedFirstTile = [[GScrollBackgroundTile alloc] init:key
                                            withUnitWidth:uW
                                            andUnitHeight:uH
                                              unitScaleX:uScX
                                              unitScaleY:uScY
                                         patternFunction:f
                                             andObserver:obs];
    
    _savedFirstTile.scaleX = uScX;
    _savedFirstTile.scaleY = uScY;
    _savedFirstTile.isTile0 = YES;
    _savedUnitWidth = uW;
    _savedUnitHeight = uH;
    _savedUnitScaleX = uScX;
    _savedUnitScaleY = uScY;
    
}




/**
 * override the x/y accessors and add a z accessor- apply the 
 * perspective arithmetic to all three.
 *
 */
- (void) setX:(float)xVal {
_x2 = xVal;
x = xVal*_pFactor - (*_cameraXPointer);
}
-(float) x {
return _x2;
}

- (void) setY:(float)yVal {
_y2 = yVal;
y = yVal*_pFactor - (*_cameraYPointer);
}
-(float) y {
return _y2;
}

- (void) setZ:(float)zVal {
_z = zVal;
}
- (float) z {
return _z;
}

- (float) realX {
return x;
}
- (void) setRealX:(float)rX {
//take no action. readonly.
}

- (float) realY {
return y;
}
- (void) setRealY:(float)rY {
//take no action. readonly.
}

- (void) setGameSize:(float)sz {
    _size = sz;
    _camera.cameraZ = (_focalLength*(1-_size));
}
- (float) gameSize {
    return _size;
}

- (float) geometry_gameWidth {
    return (geometry_rightEdge-geometry_leftEdge);
}
- (float) geometry_gameHeight {
    return (geometry_bottomEdge-geometry_topEdge);
}
- (float) geometry_topEdge {
    return geometry_topEdge;
}
- (float) geometry_bottomEdge {
    return geometry_bottomEdge;
}
- (float) geometry_rightEdge {
    return geometry_rightEdge;
}
- (float) geometry_leftEdge {
    return geometry_leftEdge;
}


- (void) saveStateForKey:(NSString *)key {
    
    float initialXPosition = _tile.x;
    float xScrollCount = [[self getScroller] scroll_countX];  //getScrollCountX];
    float xScrollLimit = [[self getScroller] scroll_xLimit];  //getScrollXLimit];
    float scrollDX = [[self getScroller] scroll_scrollDX];    //getScrollDX];
    float dirX = [[self getScroller] scroll_scrollDirX];      //getScrollDirX];
    
    float initialTileX = _back.lastTileCreated.x;
    float initialTileY = _back.lastTileCreated.y;
    float initialTileLeft = _back.lastTileCreated.tileLeft;
    float initialTileTop = _back.lastTileCreated.tileTop;
    int initialCellX = _back.lastTileCreated.cellX;
    int initialCellY = _back.lastTileCreated.cellY;
    
    BOOL initialCellIsTop = _back.lastTileCreated.isTop;
    BOOL initialCellIsBottom = _back.lastTileCreated.isBottom;
    BOOL initialCellIsLeft = _back.lastTileCreated.isLeft;
    BOOL initialCellIsRight = _back.lastTileCreated.isRight;
    
    [[Gnar ly] dataOpen:key];
    [[Gnar ly] dataSetF:initialXPosition      withKey:@"initialXPosition"];
    [[Gnar ly] dataSetF:xScrollCount          withKey:@"xScrollCount"];
    [[Gnar ly] dataSetF:xScrollLimit          withKey:@"xScrollLimit"];
    [[Gnar ly] dataSetF:scrollDX              withKey:@"scrollDX"];
    [[Gnar ly] dataSetF:initialTileX          withKey:@"initialTileX"];
    [[Gnar ly] dataSetF:initialTileY          withKey:@"initialTileY"];
    [[Gnar ly] dataSetF:initialTileLeft       withKey:@"initialTileLeft"];
    [[Gnar ly] dataSetF:initialTileTop        withKey:@"initialTileTop"];
    [[Gnar ly] dataSetI:initialCellX          withKey:@"initialCellX"];
    [[Gnar ly] dataSetI:initialCellY          withKey:@"initialCellY"];
    [[Gnar ly] dataSetI:dirX                  withKey:@"scrollDirX"];
    [[Gnar ly] dataSetB:initialCellIsTop      withKey:@"initialCellIsTop"];
    [[Gnar ly] dataSetB:initialCellIsBottom   withKey:@"initialCellIsBottom"];
    [[Gnar ly] dataSetB:initialCellIsLeft     withKey:@"initialCellIsLeft"];
    [[Gnar ly] dataSetB:initialCellIsRight    withKey:@"initialCellIsRight"];
    [[Gnar ly] dataClose];
    
    
}

- (void) applyStateForKey:(NSString *)key {

     [[Gnar ly] dataOpen:key];
     float initialXPosition = [[Gnar ly] dataGetF:@"initialXPosition"];
     //float xScrollCount = [[Gnar ly] dataGetF:@"xScrollCount"];
     float xScrollLimit = [[Gnar ly] dataGetF:@"xScrollLimit"];
     float scrollDX = [[Gnar ly] dataGetF:@"scrollDX"];
     
     float initialTileX = [[Gnar ly] dataGetF:@"initialTileX"];
     float initialTileY = [[Gnar ly] dataGetF:@"initialTileY"];
     float initialTileLeft = [[Gnar ly] dataGetF:@"initialTileLeft"];
     float initialTileTop = [[Gnar ly] dataGetF:@"initialTileTop"];
     int initialCellX = [[Gnar ly] dataGetF:@"initialCellX"];
     int initialCellY = [[Gnar ly] dataGetF:@"initialCellY"];
     int dirX = [[Gnar ly] dataGetF:@"scrollDirX"];
    
     [[Gnar ly] dataClose];
    
    _savedFirstTile.isTop = YES;
    _savedFirstTile.isBottom = YES;
    _savedFirstTile.isRight = YES;
    _savedFirstTile.isLeft = YES;
    _savedFirstTile.tileTop = initialTileTop;
    _savedFirstTile.tileBottom = _savedFirstTile.tileTop + _savedUnitHeight*_savedUnitScaleY;
    _savedFirstTile.tileLeft = initialTileLeft;
    _savedFirstTile.tileRight = _savedFirstTile.tileLeft + _savedUnitWidth*_savedUnitScaleX;
    
    _savedFirstTile.x = initialTileX;
    _savedFirstTile.y = initialTileY;
    
    _savedFirstTile.cellX = initialCellX;
    _savedFirstTile.cellY = initialCellY;
    
    //[obs performSelector:f withObject:first];
    [_savedFirstTile initialState_callPatternFunction];
    
    [_back addElement:_savedFirstTile];
    
    
    //if(xScrollLimit != 0) {
    //    [[_back getScroller] setScrollXLimit:xScrollLimit];
    //    [[_back getScroller] setScrollCountX:xScrollCount];
    //    [[_back getScroller] setScrollDX:scrollDX];
    //    [[_back getScroller] setScrollDirX:dirX];
    //    [_back setInitialXPosition:initialXPosition andYPosition:0];
    //}
    
     [[_back getScroller] initialState_setInitialXPosition:initialXPosition
                                              andYPosition:0
                                              scrollXLimit:xScrollLimit
                                                  scrollDX:scrollDX
                                                scrollDirX:dirX];
    
    
    [self setUpFrame];
    
}



/**
 * set the camera, and associate the pointers so that later on we can just dereferece
 * the pointers instead of making Objective-C calls.
 *
 */
- (void) setCamera:(GScrollCamera *)cam {
_camera = cam;
_cameraXPointer = [_camera getCameraXPointer];
_cameraYPointer = [_camera getCameraYPointer];
_cameraZPointer = [_camera getCameraZPointer];

    if(_back) {
    [_back bubbleCameraBack:cam pointerX:_cameraXPointer pointerY:_cameraYPointer pointerZ:_cameraZPointer];
    } 
    if(_front) {
    [_front bubbleCameraFront:cam pointerX:_cameraXPointer pointerY:_cameraYPointer pointerZ:_cameraZPointer];
    }

}
- (GScrollCamera *) camera {
return _camera;
}





/**
 * accessors for the scrolling
 *
 */
- (void) setScrollX:(float)scX {
_scrollX = scX;
_tile.scrollX = scX;
    if(_back) {
    _back.scrollX = scX;
    }
}
- (void) setScrollY:(float)scY {
_scrollY = scY;

_tile.scrollY = scY;
    if(_back) {
    _back.scrollY = scY;
    }
}
- (float) scrollX {

    if(_back) {
    return _back.scrollX;
    }

return _scrollX;
}
- (float) scrollY {

    if(_back) {
    return _back.scrollY;
    }

return _scrollY;
}


/**
 * stop the special scrolling modes dead in their tracks.
 *
 */
- (void) interruptSpecialScroll {
    if(_back) {
    [_back interruptSpecialScroll];
    }

[_tile interruptSpecialScroll];
}



/**
 * perform a scroll animation.
 *
 * makes use of the GEaseEquation classes, so any of the regular animation modes are available here.
 *
 * This function is interruptible with itself or the 
 * accelToXSpeed:(float)xAccel ySpeed:(float)yAccel withXDist:(float)xD yDist:(float)yD function.
 * it is safe to use at any time.
 *
 *
 */
- (void) scrollXDist:(float)xD YDist:(float)yD withEase:(NSString *)ease andDuration:(int)dur resumeScroll:(BOOL)res  {
    if(_back) {
    [_back scrollXDist:xD YDist:yD withEase:ease andDuration:dur resumeScroll:res];
    }
[_tile scrollXDist:xD YDist:yD withEase:ease andDuration:dur resumeScroll:res];
}


/**
 * perform a scroll acceleration. This solution came from book 2, pg 119,120 - and it also 
 * appears in book 1, pg 112,113.
 * 
 * This function is interruptible with itself or with the 
 * scrollXDist:(float)xD YDist:(float)yD withEase:(NSString *)ease andDuration:(int)dur
 * function. It is safe to use at any time.
 *
 *
 */
- (void) accelToXSpeed:(float)xAccel ySpeed:(float)yAccel withXDist:(float)xD yDist:(float)yD {
    if(_back) {
    [_back accelToXSpeed:xAccel ySpeed:yAccel withXDist:xD yDist:yD];    
    }
[_tile accelToXSpeed:xAccel ySpeed:yAccel withXDist:xD yDist:yD];
}


- (GScrollGameScroller *)getScroller {
return _tile;
}


/**
 * you want to perform an animation so that a certain scroll game object is right where you want it to be. so use this function.
 * the three boolean variables govern whether or not the thing will perform the animations, or simply 'snap to' the desired positions.
 *
 * NOTE: the coordinates passed in here are ordinary OpenGL coordinates, not the center-screen coordinates.
 *
 */
- (void) focusOn:(id <GScrollGameObject>)box anX:(BOOL)aX anY:(BOOL)aY anZ:(BOOL)aZ X:(float)xCoord Y:(float)yCoord Z:(float)camZ withEase:(NSString *)ease andDuration:(int)dur withCallback:(NSString *)callback andObserver:(id)obs {

float pFac =  _focalLength/(_focalLength+([box gameZ]-camZ));
    
    //NSLog(@"box gameZ:%f%@%f%@%f%@%f",[box gameZ],@"   camZ:",camZ,@"   _focalLength:%@",_focalLength,@"  denominator:",(_focalLength+([box gameZ]-camZ)));
   //pFac = 1/0;
    
    //this is the only thing which I can think of which would cause the strange run-time error.
    if(!pFac) {
    //NSLog(@"######## SOMETHING HAS GONE WRONG. ###########");
        
        //if(![box gameZ]) {
        //[[NewGameTable getSingleton] logPFactorForRunTimeError:424242];
        //} else
        //if(!camZ) {
        //[[NewGameTable getSingleton] logPFactorForRunTimeError:595959];
        //} else
        //if(([box gameZ]-camZ) == _focalLength) {
        //[[NewGameTable getSingleton] logPFactorForRunTimeError:616161];
        //} else
        //if([box gameZ] == INFINITY) {
        //[[NewGameTable getSingleton] logPFactorForRunTimeError:191919];
        //} else {
        //[[NewGameTable getSingleton] logPFactorForRunTimeError:[box gameZ]];
        //[[NewGameTable getSingleton] logPFactorForRunTimeError:2020202];
        //}
        
    } else {
    //[[NewGameTable getSingleton] logPFactorForRunTimeError:pFac];
    }

//why not save a little arithmetic.
//float camX = (xCoord - (x + pFac*(box.x + _tile.x)))/pFac; 
float camY = (yCoord - (y + pFac*(box.y + _tile.y)))/pFac;
    
[self scrollXDist:0 YDist:camY withEase:@"easeInOutCubic" andDuration:40 resumeScroll:NO];
   
    /*
    //destroy the old camera tween if it still exists.
    if(cameraTween) {
    //////////////////////////////////////////
    ///////// THIS THEW AN ERROR /////////////
    //////////////////////////////////////////
    [cameraTween destroy];  //right here exc_bad_access.
    cameraTween = nil;
    }
    */
   
    [GAnimation destroyTweensForTarget:_camera];

//will need a callback here.
//[_camera animate:@"cameraZ" duration:dur delay:0 end:camZ easing:ease onStart:nil startObs:nil onEnd:nil endObs:nil];
//get the animation going.
[GAnimation beginSet:_camera];
[GAnimation animate:@"cameraZ" duration:dur delay:0 end:camZ easing:ease];
    if(callback != nil) {
    [GAnimation onEnd:callback endObs:obs];
    }
//cameraTween = [GAnimation endSet];
      
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

    if(_back) {
    [_back morphFromXSpeed:xSI ySpeed:ySI toXSpeed:xSF andYSpeed:ySF withXDist:xD yDist:yD numXSteps:numX numYSteps:numY];
    }

[_tile morphFromXSpeed:xSI ySpeed:ySI toXSpeed:xSF andYSpeed:ySF withXDist:xD yDist:yD numXSteps:numX numYSteps:numY];
}


@end
