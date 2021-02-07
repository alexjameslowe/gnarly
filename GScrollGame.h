//
//  CosmicDolphin_6
//
//  Created by Alexander  Lowe on 3/28/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

//#import "GScrollGameScroller.h"
#import "GAnimation.h"
#import "GTween.h"
#import "GBox.h"



@class GScrollCamera;
@class GScrollGame;

//specialized tweens.
@interface GTween_cameraX : GTween {
GScrollCamera *cameraTarget;
}
@end

@interface GTween_cameraY : GTween {
GScrollCamera *cameraTarget;
}
@end

@interface GTween_cameraZ : GTween {
GScrollCamera *cameraTarget;
}
@end

@interface GTween_gameSize : GTween {
GScrollGame *gameTarget;
}

@end


@interface GScrollCamera : GBox {

float _cameraX;
float _cameraY;
float _cameraZ;

float *_cameraXPointer;
float *_cameraYPointer;
float *_cameraZPointer;

}

- (void) setCameraX:(float)val;
- (float) cameraX;

- (void) setCameraY:(float)val;
- (float) cameraY;

- (void) setCameraZ:(float)val;
- (float) cameraZ;

- (float *) getCameraXPointer;
- (float *) getCameraYPointer;
- (float *) getCameraZPointer;

@end




//a simple protocol so that any object that gets added to the game has a reference to the game.
@class GScrollGame;
@class GScrollGameScroller;
@protocol GScrollGameObject

- (void) setGame:(GScrollGame *)gm andScroller:(GScrollGameScroller *)scroller;

- (void) objectAppearedOnGame;

- (float) gameZ;

- (float) x;
- (float) y;
- (float) tableX;
- (float) tableY;

@end







@class GScrollGameScroller;
@class GScrollGameSprite;
@class GScrollBackgroundTile;

@interface GScrollGame : GBox {


    
GScrollGameScroller *_tile;

GScrollGame *_back;

GScrollGame *_front;

GScrollCamera *_camera;
    
GScrollBackgroundTile *_lastTileCreated;

GTweenSet *cameraTween;

float *_cameraXPointer;
float *_cameraYPointer;
float *_cameraZPointer;
    
float geometry_rightEdge;
float geometry_leftEdge;
float geometry_topEdge;
float geometry_bottomEdge;
float geometry_centerX;
float geometry_centerY;
    
GScrollBackgroundTile *_savedFirstTile;
float _savedUnitWidth;
float _savedUnitHeight;
float _savedUnitScaleX;
float _savedUnitScaleY;
NSString *_savedAtlasKey;

float _pFactor;

BOOL showBoundaryBoxes;
GBox *topBx;
GBox *leftBx;
GBox *rightBx;
GBox *bottomBx;

float _defaultCamX,_defaultCamY,_defaultCamZ;

float _x2;
float _y2;
float _z;
float _scaleX2;
float _scaleY2;

float _scrollX,_scrollY;

BOOL _tileAdded;

float _focalLength;
    
float _size;

BOOL *_scrollState;


BOOL _motherFucker;

int id_code;

}

@property (nonatomic, assign) GScrollBackgroundTile *lastTileCreated;

- (void) setTheIDCode:(int)code;

//Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
+ (void) decrementObjectsInPlayAndReport;


- (void) setCameraOnBackground:(GScrollCamera *)cam;
- (void) bubbleCameraFront:(GScrollCamera *)cam pointerX:(float *)xP pointerY:(float *)yP pointerZ:(float *)pZ;
- (void) bubbleCameraBack:(GScrollCamera *)cam pointerX:(float *)xP pointerY:(float *)yP pointerZ:(float *)pZ;


- (void) setCamera:(GScrollCamera *)cam;
- (GScrollCamera *) camera;

- (void) setFront:(GScrollGame *)f;
- (GScrollGame *) front;

- (void) setScrollX:(float)scX;
- (void) setScrollY:(float)scY;
- (float) scrollX;
- (float) scrollY;

- (void) setZ:(float)zVal;
- (float) z;

- (float) realX;
- (void) setRealX:(float)rX;

- (float) realY;
- (void) setRealY:(float)rY;

- (void) setGameSize:(float)sz;
- (float) gameSize;

- (float) geometry_gameWidth;

- (float) geometry_gameHeight;

- (float) geometry_topEdge;

- (float) geometry_bottomEdge;

- (float) geometry_rightEdge;

- (float) geometry_leftEdge;


- (void) addElement:(GBox *)newBox;
- (void) addElement:(GBox *)newBox before:(GBox *)ref;
- (void) removeElement:(GBox *)box;
- (void) addElementInBack:(GBox *)newBox;


- (void) reset;

- (void) interruptSpecialScroll;

- (void) scrollXDist:(float)xD YDist:(float)yD withEase:(NSString *)ease andDuration:(int)dur resumeScroll:(BOOL)res;

- (void) accelToXSpeed:(float)xAccel ySpeed:(float)yAccel withXDist:(float)xD yDist:(float)yD;

- (void) setBackground:(GScrollGame *)back withAtlasKey:(NSString *)key
             unitWidth:(float)uW unitHeight:(float)uH
            unitScaleX:(float)uScX unitScaleY:(float)uScY
           patternFunc:(NSString *)func
           andObserver:(id)obs;
          /*initialTileX:(float)tileX
          initialTileY:(float)tileY
       initialTileLeft:(float)tileLeft
        initialTileTop:(float)tileTop
          initialCellX:(int)tileCellX
          initialCellY:(int)tileCellY
      initialCellIsTop:(BOOL)initialCellIsTop
   initialCellIsBottom:(BOOL)initialCellIsBottom
     initialCellIsLeft:(BOOL)initialCellIsLeft
    initialCellIsRight:(BOOL)initialCellIsRight;*/

- (void) applyStateForKey:(NSString *)key;
- (void) saveStateForKey:(NSString *)key;

- (void) setUpFrame;
         
- (void) focusOn:(id <GScrollGameObject>)box anX:(BOOL)aX anY:(BOOL)aY anZ:(BOOL)aZ X:(float)xCoord Y:(float)yCoord Z:(float)camZ withEase:(NSString *)ease andDuration:(int)dur withCallback:(NSString *)callback andObserver:(id)obs;
        
- (void) morphFromXSpeed:(float)xSI ySpeed:(float)ySI toXSpeed:(float)xSF andYSpeed:(float)ySF withXDist:(float)xD yDist:(float)yD numXSteps:(int)numX numYSteps:(int)numY;
        
//- (BOOL) scrollState;
//- (void) setScrollState:(BOOL)state;



- (void) setLastTileCreated:(GScrollBackgroundTile *)lastTileCreated;
- (GScrollBackgroundTile *)lastTileCreated;

- (GScrollGameScroller *)getScroller;
           
@end






