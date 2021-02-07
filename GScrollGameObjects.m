//
//  GLoadSprite.m
//  CosmicDolphin_5_6
//
//  Created by Alexander  Lowe on 10/20/11.
//  
//

#import "GScrollGameObjects.h"
#import "GScrollGame.h"
#import "GScrollGameScroller.h"
#import "GRenderable.h"


@implementation GScrollGameBox

@synthesize willEncore,encoreTopEdge;

@synthesize ignoreScrollShift;

@synthesize id_code;

@synthesize assballs;


- (id) init {

self = [super init];

_beenOnYet = NO;

_addedToTable = NO;

return self;

}


/**
 * fires when the object is added to the game table. at this point, the _game reference exists, so any
 * additional building/confiuguration you need to do, do it here.
 *
 */
- (void) objectAppearedOnGame {

}

- (float) gameZ {
    if(_scrollGame) {
    return _scrollGame.z;
    } else {
    return 0;
    }
}

- (void) setGame:(GScrollGame *)gm andScroller:(GScrollGameScroller *)scroller {
    _scrollGame = gm;
    _scroller = scroller;
    _addedToTable = YES;
}



- (void)resetScrollingShit {
    
    ////BEEN_ON_YET_FIX////
    x += [_scroller scroll_scrollDX];
    ///////////////////////
    
    //if the coordinates have been reset, then we should ckeck to
    //see if this object is out of bounds. but only do it if
    //this object is not going to encore. 'encore' means that the
    //object will go off stage at some point, but then it may come back
    //on, like a player's spaceship slinging around a planet.
    if(willEncore == NO) {
        
        _scrollX = [_scroller scrollX];
        _scrollY = [_scroller scrollY];
        
        if(_scrollY != 0) {
            _tY = y + _minY;
            _bY = _tY + _height;
            
            _leftEdge = [_scroller geometry_topEdge];
            _rightEdge = [_scroller geometry_bottomEdge];
            
            if((_tY > _bottomEdge || _bY < _topEdge) && _beenOnYet == YES) {
                if(encoreTopEdge == YES) {
                    if(_tY > _bottomEdge) {
                        [self destroy];
                    }
                } else {
                    [self destroy];
                }
            } else
                if(_tY < _bottomEdge && _bY > _topEdge) {
                    _beenOnYet = YES;
                }
            
        }
        
        if(_scrollX != 0) {
            //_lX = x + _minX;
            //_rX = _lX + _width;
            _lX = x + _minX*scaleX;
            _rX = _lX + _width*scaleX;
            
            _leftEdge = [_scroller geometry_leftEdge];
            _rightEdge = [_scroller geometry_rightEdge];
            
            if((_lX > _rightEdge || _rX < _leftEdge) && _beenOnYet == YES) {
                
                //Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
                //[GScrollGame decrementObjectsInPlayAndReport];
                /////////////////
                [self destroy];
                
            } else
            if(_lX < _rightEdge && _rX > _leftEdge){
                _beenOnYet = YES;
            }
            
        }
        
    }
    
}




- (GRenderable *) render {
    
    //set local variables to the psuedo-globals.
    _topEdge = [_scroller geometry_topEdge];
    _leftEdge = [_scroller geometry_leftEdge];
    _rightEdge = [_scroller geometry_rightEdge];
    _bottomEdge = [_scroller geometry_bottomEdge];
    
    if(!_beenOnYet) {
        /*_tY = y + _minY;
        _bY = _tY + _height;
        _lX = x + _minX;
        _rX = _lX + _width;*/
        
        _tY = y + _minY*scaleY;
        _bY = _tY + _height*scaleY;
        _lX = x + _minX*scaleX;
        _rX = _lX + _width*scaleX;
        
        if( [_scroller isGameObjectWithinHorizontalWithRightBound:_rX andLeftBound:_lX]){
        _beenOnYet = YES;
        }
    }
    
return [super render];
}



/////////////
//         //
//  A P I  //
//         //
/////////////


/**
 * Important functions. Within this scroll-game code, if you ever want to set coordinates like this:
 *
 * self.y = someGameObject.y
 *
 * Don't, because you don't know if someGameObject comes before or after the rendering of 'self', and if
 * the object is rendered before self, then it may already have the scrolling-dX/dY built into it and
 * we'll have a skip.
 *
 */
- (float) matchXCoordWith:(GBox *)b {
float xCoord = b.x;
return xCoord;
}
- (float) matchYCoordWith:(GBox *)b {
float yCoord = b.y;
return yCoord;
}


- (float) tY {
    return _tY;
}
- (float)bY {
    return _bY;
}
-(float)lX {
    return _lX;
}
- (float)rX {
    return _rX;
}

- (GNode *) clone {
    GScrollGameBox *bx = [[GScrollGameBox alloc] init];
    [bx rectWidth:_width andHeight:_height color:self.color];
    bx.scaleX = scaleX;
    bx.scaleY = scaleY;
    bx.x = x;
    bx.y = y;
    bx.rotation = rotation;
    [bx regX:-_minX andY:-_minY];
    bx.color = self.color;
    bx.opacity = self.opacity;
    return bx;
}



- (float) tableX {
    if(_addedToTable == YES) {
    return _scrollGame.x + _scrollGame.scaleX*(x + _scroller.x);
    } else {
    return _tableX;
    }
}
- (void) setTableX:(float)tX {
_tableX = tX;

    if(_addedToTable == YES) {
    x = (tX - _scrollGame.x)/_scrollGame.scaleX - _scroller.x;
    }
}

- (float) tableY {
    if(_addedToTable == YES) {
    return _scrollGame.y + _scrollGame.scaleY*(y + _scroller.y);
    } else {
    return _tableY;
    }
}
- (void) setTableY:(float)tY {
_tableY = tY;

    if(_addedToTable == YES) {
    y = (tY - _scrollGame.y)/_scrollGame.scaleY - _scroller.y;
    }
}

@end






@implementation GScrollGameSprite

@synthesize willEncore,encoreTopEdge;

@synthesize ignoreScrollShift;

@synthesize id_code;

@synthesize amountOfClearanceForOutroAnimation;

@synthesize assballs;


- (id) init:(NSString *)key {
    
self = [super init:key];
    
_beenOnYet = NO;

_addedToTable = NO;
    
amountOfClearanceForOutroAnimation = 100;

return self;

}



/**
 * protocol methods.
 *
 */
- (void) objectAppearedOnGame {}


- (void) setGame:(GScrollGame *)gm andScroller:(GScrollGameScroller *)scroller {
    _scrollGame = gm;
    _scroller = scroller;
    _addedToTable = YES;
}


- (float) gameZ {
    if(_scrollGame) {
    return _scrollGame.z;
    } else {
    return 0;
    }
}


- (void)resetScrollingShit {
    
    ////BEEN_ON_YET_FIX////
    x += [_scroller scroll_scrollDX];
    //NSLog(@"    resetScrollingShit: %f",[_scroller scroll_scrollDX]);
    ///////////////////////
    
    //if the coordinates have been reset, then we should ckeck to
    //see if this object is out of bounds. but only do it if
    //this object is not going to encore. 'encore' means that the
    //object will go off stage at some point, but then it may come back
    //on, like a player's spaceship slinging around a planet.
    if(willEncore == NO) {
        
        _scrollX = [_scroller scrollX];
        _scrollY = [_scroller scrollY];
        
        if(_scrollY != 0) {
            _tY = y + _minY;
            _bY = _tY + _height;
            
            _topEdge = [_scroller geometry_topEdge];
            _bottomEdge = [_scroller geometry_bottomEdge];
            
            if((_tY > _bottomEdge || _bY < _topEdge) && _beenOnYet == YES) {
                if(encoreTopEdge == YES) {
                    if(_tY > _bottomEdge) {
                        [self destroy];
                    }
                } else {
                    [self destroy];
                }
            } else
                if(_tY < _bottomEdge && _bY > _topEdge) {
                    _beenOnYet = YES;
                }
            
        }
        
        if(_scrollX != 0) {
            //_lX = x + _minX;
            //_rX = _lX + _width;
            _lX = x + _minX*scaleX;
            _rX = _lX + _width*scaleX;
            
            _leftEdge = [_scroller geometry_leftEdge];
            _rightEdge = [_scroller geometry_rightEdge];
            
            //if(assballs) {
            //    NSLog(@"_width: %f",_width);
            //}
            
            if((_lX > _rightEdge || _rX < _leftEdge) && _beenOnYet == YES) {
                
                //if(assballs) {
                //    NSLog(@"_lX:%f%@%f%@%f%@%f",_lX,@" _rX:",_rX,@" _rightEdge:",_rightEdge,@" _leftEdge:",_leftEdge);
                //}
                
                //Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
                //[GScrollGame decrementObjectsInPlayAndReport];
                /////////////////
                //if([self.name isEqualToString:@"wtf!"]) {
                //    NSLog(@"????");
                //}
                [self destroy];
                
            } else
            if(_lX < _rightEdge && _rX > _leftEdge){
                _beenOnYet = YES;
                
                //if([self.name isEqualToString:@"wtf!"]) {
                //    NSLog(@"_beenOnYet = YES");
                //}
                
            }
            
        }
        
    }
    
}





- (GRenderable *) render {
    
    _topEdge = [_scroller geometry_topEdge];
    _leftEdge = [_scroller geometry_leftEdge];
    _rightEdge = [_scroller geometry_rightEdge];
    _bottomEdge = [_scroller geometry_bottomEdge];
    
    if(!_beenOnYet) {
        //_tY = y + _minY;
        //_bY = _tY + _height;
        //_lX = x + _minX;
        //_rX = _lX + _width;
        
        _tY = y + _minY*scaleY;
        _bY = _tY + _height*scaleY;
        _lX = x + _minX*scaleX;
        _rX = _lX + _width*scaleX;
        
        if( [_scroller isGameObjectWithinHorizontalWithRightBound:_rX andLeftBound:_lX]){
            _beenOnYet = YES;
        }
    }
    
    return [super render];
}




/////////////
//         //
//  A P I  //
//         //
/////////////

- (GRenderable *) render_fromSpriteClass {
return [super render];
}

/**
 * this function will return a proxy object closely matching the original. same transformations. you can just
 * get rid of the original or do whatever with it.
 *
 */
- (GScrollGameSprite *) offerProxy {
    
    GScrollGameSprite *sp = [[GScrollGameSprite alloc] init:_key];
    
    sp.frame = self.frame;
    sp.x = self.x;
    sp.y = self.y;
    sp.scaleX = self.scaleX;
    sp.scaleY = self.scaleY;
    sp.rotation = self.rotation;
    sp.color = self.color;
    sp.opacity = self.opacity;
    
    return sp;
}

/////////////
//Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
//- (void) destroy {
//    [GScrollGame decrementObjectsInPlayAndReport];
//    [super destroy];
//}
/////////////


/**
 * Important functions. Within this scroll-game code, if you ever want to set coordinates like this:
 *
 * self.y = someGameObject.y
 *
 * Don't, because you don't know if someGameObject comes before or after the rendering of 'self', and if
 * the object is rendered before self, then it may already have the scrolling-dX/dY built into it and
 * we'll have a skip.
 *
 */
- (float) matchXCoordWith:(GBox *)b {
float xCoord = b.x;
return xCoord;
}
- (float) matchYCoordWith:(GBox *)b {
float yCoord = b.y;
return yCoord;
}


- (float) tY {
    return _tY;
}
- (float)bY {
    return _bY;
}
-(float)lX {
    return _lX;
}
- (float)rX {
    return _rX;
}




- (GNode *)clone {
    GScrollGameSprite *sp = [[GScrollGameSprite alloc] init:_key];
    sp.frame = self.frame;
    sp.scaleX = scaleX;
    sp.scaleY = scaleY;
    sp.x = x;
    sp.y = y;
    sp.rotation = rotation;
    [sp regX:-_minX andY:-_minY];
    sp.color = self.color;
    sp.opacity = self.opacity;
    return sp;
}



/*
 
 - (float) tableX {
 if(_addedToTable == YES) {
 return *pointer_GSCROLLGAMESCROLLER_scrollTableX + *pointer_GSCROLLGAMESCROLLER_scrollTableScX*(x + *pointer_GSCROLLGAMESCROLLER_scrollTileX);
 } else {
 return _tableX;
 }
 }
 - (void) setTableX:(float)tX {
 _tableX = tX;
 
 if(_addedToTable == YES) {
 x = (tX - *pointer_GSCROLLGAMESCROLLER_scrollTableX)/(*pointer_GSCROLLGAMESCROLLER_scrollTableScX) - *pointer_GSCROLLGAMESCROLLER_scrollTileX;
 }
 }
 
 */


- (float) tableX {
    if(_addedToTable == YES) {
        return _scrollGame.x + _scrollGame.scaleX*(x + _scroller.x);
    } else {
        return _tableX;
    }
}
- (void) setTableX:(float)tX {
    _tableX = tX;
    
    if(_addedToTable == YES) {
        x = (tX - _scrollGame.x)/_scrollGame.scaleX - _scroller.x;
    }
}

- (float) tableY {
    if(_addedToTable == YES) {
        return _scrollGame.y + _scrollGame.scaleY*(y + _scroller.y);
    } else {
        return _tableY;
    }
}
- (void) setTableY:(float)tY {
    _tableY = tY;
    
    if(_addedToTable == YES) {
        y = (tY - _scrollGame.y)/_scrollGame.scaleY - _scroller.y;
    }
}

@end
