//
//  GSimpleButton.h
//  RidiculousMissile2
//
//  Created by Alexander  Lowe on 4/26/11.
//  Copyright 2011 Codequark. See Licence.
//



#import "Gnarly.h"
#import "GBox.h"
#import "GSprite.h"
#import "GScrollGame.h"


@class GScrollGameScroller;

@interface GScrollGameBox : GBox <GScrollGameObject> {

float _topEdge, _leftEdge, _rightEdge, _bottomEdge, _centerX, _centerY;
float _scrollX,_scrollY;
float _rX,_lX,_tY,_bY;
BOOL  _scrollState;
BOOL  _beenOnYet;
BOOL  _checkBounds;
BOOL  _addedToTable;

BOOL ignoreScrollShift;
    
float _tableX,_tableY;
    
BOOL  willEncore;
BOOL encoreTopEdge;
    
int id_code;
    
GScrollGame *_scrollGame;
GScrollGameScroller *_scroller;
    
BOOL assballs;
    
}

@property (nonatomic, assign) BOOL assballs;


- (float) matchXCoordWith:(GBox *)b;
- (float) matchYCoordWith:(GBox *)b;


//most of the objects are going to appear offscreen, scroll onscreen, scroll off-screen and
//then destroy themselves. some objects however, will move in and off the screen following 
//their own animations. we don't want these object to be destroyed. so we have the idea of
//an 'encore'- if an object is likely to make an appearance on the stage *again*, then
//set this to YES and that object will be immune from the off-screen culling logic.
@property (nonatomic, assign) BOOL willEncore,encoreTopEdge;

@property (nonatomic, assign) BOOL ignoreScrollShift;

@property (nonatomic, assign) int id_code;

- (void) setGame:(GScrollGame *)gm andScroller:(GScrollGameScroller *)scroller;

- (void) objectAppearedOnGame;

- (float) gameZ;

- (float) tableX;
- (void) setTableX:(float)tX;

- (float) tableY;
- (void) setTableY:(float)tY;

- (float)tY;
- (float)bY;
- (float)lX;
- (float)rX;

- (void)resetScrollingShit;


@end


@class GScrollGame;

@interface GScrollGameSprite : GSprite <GScrollGameObject> {

float _topEdge, _leftEdge, _rightEdge, _bottomEdge, _centerX, _centerY;
float _scrollX,_scrollY;
float _rX,_lX,_tY,_bY;
BOOL  _scrollState;
BOOL  _beenOnYet;
BOOL  _checkBounds;
BOOL  _addedToTable;
    
float amountOfClearanceForOutroAnimation;

BOOL ignoreScrollShift;

float _tableX,_tableY;
    
BOOL  willEncore;
BOOL encoreTopEdge;

int id_code;
    
GScrollGame *_scrollGame;
GScrollGameScroller *_scroller;
    
BOOL assballs;
    
}


@property (nonatomic, assign) BOOL assballs;

@property (nonatomic, assign) float amountOfClearanceForOutroAnimation;

@property (nonatomic, assign) int id_code;

@property (nonatomic, assign) BOOL willEncore,encoreTopEdge;

@property (nonatomic, assign) BOOL ignoreScrollShift;

- (id) init:(NSString *)key;

- (void) setGame:(GScrollGame *)gm andScroller:(GScrollGameScroller *)scroller;

- (float) matchXCoordWith:(GBox *)b;
- (float) matchYCoordWith:(GBox *)b;

- (void) objectAppearedOnGame;

- (float) gameZ;

- (float) tableX;
- (void) setTableX:(float)tX;

- (float) tableY;
- (void) setTableY:(float)tY;

- (GScrollGameSprite *) offerProxy;

- (float)tY;
- (float)bY;
- (float)lX;
- (float)rX;

- (void)resetScrollingShit;

- (GRenderable *) render_fromSpriteClass;

@end
