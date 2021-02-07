//
//  GTweenStrategy.m
//  BraveRocket
//
//  Created by Alexander Lowe on 3/12/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                  //
//  This is the way to do composite tweens such as color, or tweens that take a different end-goal  //
//  parameter than a floating number, also like color, which takes a hexedecimal integer.           //
//  See the GTweenColorStrategy class for an example.                                               //
//                                                                                                  //
//  At some point I'm going to go through and make a strategy class for all of the tweens           //
//                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////

#import "GTweenStrategy.h"
#import "GAnimation.h"
#import "GTween.h"
#import "GTweenGroup.h"

@implementation GTweenStrategy


- (id) initWithDuration:(int)dur delay:(int)del easing:(NSString *)ease {

    self = [super init];
    
    _tweens = [[NSMutableArray alloc] init];
    _duration = dur;
    _easing = ease;
    _delay = del;

    return self;
}

- (NSMutableArray *) exposeStrategyTweens {
return _tweens;
}


- (void) setTarget:(GNode *)target {
    _target = target;
}

- (void) dealloc {
    [_tweens removeAllObjects];
    [_tweens release];
    [super dealloc];
}


/////////////
//         //
//  A P I  //
//         //
/////////////


/**
 * perform the animation strategy here. create all of your tween instances here and then
 * add them to the strategy with the addTweenToStrategy function.
 *
 */
- (void) performStrategy {}


/**
 * Call this function above with the perform strategy function. the contract here is that
 * you should only call this function here inside the auspices of the performStrategy function.
 *
 */
- (void) addTweenToStrategy:(GTween *)twn {
[_tweens addObject:twn];
}






@end
