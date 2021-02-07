//
//  BackSlice.h
//  CosmicDolphin_4_2
//
//  Created by Alexander  Lowe on 7/6/11.
//  
//

#import "GSprite.h"
#import "GMath.h"
#import "GScrollGame.h"
#import "GLayerMemoryObject.h"


@class GScrollGameScroller;

@interface  GScrollBackgroundTile : GSprite <GScrollGameObject> {

float _topEdge, _leftEdge, _rightEdge, _bottomEdge;
float _scrollX,_scrollY;
BOOL  _scrollState;
BOOL hasTop,hasRight,hasLeft,hasBottom;

BOOL ignoreScrollShift;

NSString *_atlasKey;
    
GScrollGame *_scrollGame;
GScrollGameScroller *_scroller;

BOOL isTop,isBottom,isLeft,isRight;

BOOL _hasMarker;
GBox *_marker;

/*
GBox *left;
GBox *right;
GBox *top;
GBox *bottom;
*/

float tileTop;
float tileLeft;
float tileRight;
float tileBottom;

float _rightMost;

int unitWidth;
int unitHeight;

float _unitScaleX;
float _unitScaleY;

float _scaledUnitWidth;
float _scaledUnitHeight;

int _allSides;
BOOL _hasAllSides;

int cellX;
int cellY;

BOOL firstInTopRow;

BOOL isTile0;

id <GLayerMemoryObject> _patternObserver;
SEL _patternFunction;

//int shiftCode;
    
    BOOL assBalls;

}


- (void) objectAppearedOnGame;

- (float) gameZ;

- (float) tableX;
- (float) tableY;


- (id) init:(NSString *)key withUnitWidth:(float)uW andUnitHeight:(float)uH unitScaleX:(float)uScX unitScaleY:(float)uScY patternFunction:(SEL)func andObserver:(id <GLayerMemoryObject>)obs;

- (void) initialState_callPatternFunction;

@property (nonatomic, assign) BOOL assBalls;

@property (nonatomic, assign) BOOL hasTop,hasBottom,hasLeft,hasRight;

@property (nonatomic, assign) BOOL isTop,isBottom,isLeft,isRight;
@property (nonatomic, assign) float tileTop,tileLeft,tileRight,tileBottom;

@property (nonatomic, assign) int cellX;
@property (nonatomic, assign) int cellY; 

@property (nonatomic, assign) BOOL firstInTopRow;
@property (nonatomic, assign) BOOL isTile0;

@property (nonatomic, assign) BOOL ignoreScrollShift;






@end
