//
//  BackSlice.m
//  CosmicDolphin_4_2
//
//  Created by Alexander  Lowe on 7/6/11.
//  
//


#import "GScrollBackgroundTile.h"
#import "GScrollGameScroller.h"
#import "GRenderable.h"

#define gLogAllocDealloc gNO


@implementation GScrollBackgroundTile


//static BOOL useScaled = YES;



    #if gLogAllocDealloc == gYES
    static int numCreated = 0;
    #endif

@synthesize cellX,cellY;

@synthesize firstInTopRow,isTile0;

@synthesize ignoreScrollShift;

@synthesize assBalls;


@synthesize isTop,isBottom,isLeft,isRight;

@synthesize hasTop,hasBottom,hasLeft,hasRight;

@synthesize tileTop,tileLeft,tileRight,tileBottom;



- (id) init:(NSString *)key
withUnitWidth:(float)uW andUnitHeight:(float)uH
unitScaleX:(float)uScX unitScaleY:(float)uScY
patternFunction:(SEL)func andObserver:(id <GLayerMemoryObject>)obs {

self = [super init:key];
    
_allSides = 0;
_atlasKey = key;

_hasMarker = NO;

_hasAllSides = NO;
isTop = NO;
isBottom = NO;
isRight = NO;
isLeft = NO;

ignoreScrollShift = NO;


unitWidth = uW;
unitHeight = uH;

_unitScaleX = uScX;
_unitScaleY = uScY;

_scaledUnitWidth = uW*uScX;
_scaledUnitHeight = uH*uScY;

_patternFunction = func;
_patternObserver = obs;

cellX = 0;
cellY = 0;

return self;
}


- (void) setGame:(GScrollGame *)gm andScroller:(GScrollGameScroller *)scroller {
    _scrollGame = gm;
    _scroller = scroller;
}


- (void) objectAppearedOnGame {
//nothing.
}
- (float) gameZ {
    if(_scrollGame) {
    return _scrollGame.z;
    } else {
    return 0;
    }
}


- (float) tableX {
return 0;
}
- (float) tableY {
return 0;
}


- (void) initialState_callPatternFunction {
[_patternObserver performSelector:_patternFunction withObject:self];
}



- (void)resetScrollingShit {
    
_scrollX = _scrollGame.scrollX;
_scrollY = _scrollGame.scrollY;
_scrollState = [_scroller scroll_state];

x += [_scroller scroll_scrollDX];
tileLeft = x;

tileRight = x+_scaledUnitWidth;

}






//Original

- (GRenderable *) render {

_topEdge = [_scroller geometry_topEdge];
_leftEdge = [_scroller geometry_leftEdge];
_rightEdge = [_scroller geometry_rightEdge];
_bottomEdge = [_scroller geometry_bottomEdge];

tileTop = y;
tileBottom = y+_scaledUnitHeight;
tileLeft = x;
tileRight = x+_scaledUnitWidth;
    
opacity = parent.opacity;
    


    //if(isTop == NO) {
    
        if(y < _topEdge) {
        isTop = YES;
        }
        
    //} else {
    if(isTop) {
    
        if(y >= _topEdge) {
        
        GScrollBackgroundTile *tl = 
        [[GScrollBackgroundTile alloc] init:_atlasKey 
                                       withUnitWidth:unitWidth andUnitHeight:unitHeight 
                                       unitScaleX:_unitScaleX unitScaleY:_unitScaleY
                                       patternFunction:_patternFunction andObserver:_patternObserver];

        tl.scaleX = _unitScaleX;
        tl.scaleY = _unitScaleY;
        tl.y = y-_scaledUnitHeight;
        tl.x = x;
        
        
        tl.tileTop = tl.y;
        tl.tileBottom = y;
        tl.tileLeft = x;
        tl.tileRight = x+_scaledUnitWidth;
        
        tl.isTop = isTop;
        tl.isLeft = isLeft;
        tl.isRight = isRight;
        tl.isBottom = NO;
        
        tl.cellX = cellX;
        tl.cellY = cellY-1;
        
        [_patternObserver performSelector:_patternFunction withObject:tl];
        
        isTop = NO;
        [_scrollGame addElement:tl];
            
        _scrollGame.lastTileCreated = tl;
            
        } else {
                
            if(tileBottom < _topEdge) {
            [self destroy];
            }
            
        }
                 
    }
    

    
    

    

    //if(isBottom == NO) {
    
        if(tileBottom > _bottomEdge) {
        isBottom = YES;
        }

    //} else {
    if(isBottom) {
    
        if(tileBottom <= _bottomEdge) {
        

        GScrollBackgroundTile *tl = 
        [[GScrollBackgroundTile alloc] init:_atlasKey 
                                       withUnitWidth:unitWidth andUnitHeight:unitHeight 
                                       unitScaleX:_unitScaleX unitScaleY:_unitScaleY
                                       patternFunction:_patternFunction andObserver:_patternObserver];
        
        tl.scaleX = _unitScaleX;
        tl.scaleY = _unitScaleY;
        tl.y = y+_scaledUnitHeight;
        tl.x = x;
        
        tl.tileTop = tl.y;
        tl.tileBottom = tl.y+_scaledUnitHeight;
        tl.tileLeft = x;
        tl.tileRight = x+_scaledUnitWidth;
            
        
        //safety
        tl.ignoreScrollShift = YES;
        
        tl.isTop = NO;
        tl.isLeft = isLeft;
        tl.isRight = isRight;
        tl.isBottom = isBottom;
        
        tl.cellX = cellX;
        tl.cellY = cellY+1;

        [_patternObserver performSelector:_patternFunction withObject:tl];
        
        isBottom = NO;
        [_scrollGame addElement:tl];
            
        _scrollGame.lastTileCreated = tl;
        
    
        } else {
        
            if(y > _bottomEdge) {
            [self destroy];
            } 
        
        }
    
    }
    
    
    
    
    //if(isRight == NO) {
    
        if(tileRight > _rightEdge) {
        isRight = YES;
        }
    
    //} else {
    if(isRight) {
        
        if(tileRight <= _rightEdge) {
        
        GScrollBackgroundTile *tl = 
        [[GScrollBackgroundTile alloc] init:_atlasKey 
                                       withUnitWidth:unitWidth andUnitHeight:unitHeight 
                                       unitScaleX:_unitScaleX unitScaleY:_unitScaleY
                                       patternFunction:_patternFunction andObserver:_patternObserver];
            
            
        tl.scaleX = _unitScaleX;
        tl.scaleY = _unitScaleY;
        tl.x = x+_scaledUnitWidth;
        tl.y = y;
        
        tl.tileTop = y;
        tl.tileBottom = y+_scaledUnitHeight;
        tl.tileLeft = x;
        tl.tileRight = tl.x+_scaledUnitWidth;
     
    
        tl.isTop = isTop;
        tl.isLeft = NO;
        tl.isRight = isRight;
        tl.isBottom = isBottom;
            
        tl.cellX = cellX+1;
        tl.cellY = cellY;
 
        [_patternObserver performSelector:_patternFunction withObject:tl];
        
        isRight = NO;
        
        [_scrollGame addElement:tl];
            
        _scrollGame.lastTileCreated = tl;
            
        } else {
        
            if(x > _rightEdge) {
            [self destroy];
            }
        
        }
            
    }
    
    
    //this conditional is designed to create a new background tile the moment this tile moves from being off the left-edge
    //to within the left-edge.
    
    //if(isLeft == NO) {
    
        if(x < _leftEdge) {
        isLeft = YES;
        }

    //} else {
    if(isLeft) {
    
        if(x >= _leftEdge) {
        
        GScrollBackgroundTile *tl = 
        [[GScrollBackgroundTile alloc] init:_atlasKey 
                                       withUnitWidth:unitWidth andUnitHeight:unitHeight
                                       unitScaleX:_unitScaleX unitScaleY:_unitScaleY
                                       patternFunction:_patternFunction andObserver:_patternObserver];
        
        
        tl.scaleX = _unitScaleX;
        tl.scaleY = _unitScaleY;
        tl.x = x-_scaledUnitWidth;
        tl.y = y;
        
        tl.tileTop = y;
        tl.tileBottom = y+_scaledUnitHeight;
        tl.tileLeft = tl.x;
        tl.tileRight = x;
    
        
        tl.isTop = isTop;
        tl.isLeft = isLeft;
        tl.isRight = NO;
        tl.isBottom = isBottom;
        
        tl.cellX = cellX-1;
        tl.cellY = cellY;
        [_patternObserver performSelector:_patternFunction withObject:tl];
        
        isLeft = NO;
        [_scrollGame addElement:tl];
        
        _scrollGame.lastTileCreated = tl;
            
            
        } else {
        
            if(tileRight < _leftEdge) {
            [self destroy];
            } 
        
        }

    }
    
return [super render];
    
}


@end
