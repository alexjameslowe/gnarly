//
//  GTweenStrategy.h
//  BraveRocket
//
//  Created by Alexander Lowe on 3/12/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//


#import <Foundation/Foundation.h>

@class GNode;
@class GTweenGroup;
@class GTween;

@interface GTweenStrategy : NSObject {

    int _duration;
    int _delay;
    NSString *_easing;
    NSMutableArray *_tweens;
    GNode *_target;
    
}

- (id) initWithDuration:(int)dur delay:(int)del easing:(NSString *)ease;

- (NSMutableArray *) exposeStrategyTweens;

/////////////
//         //
//  A P I  //
//         //
/////////////


- (void) addTweenToStrategy:(GTween *)twn;

- (void) setTarget:(GNode *)target;

- (void) performStrategy;


@end
