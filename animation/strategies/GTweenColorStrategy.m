//
//  GTweenColorStrategy.m
//  BraveRocket
//
//  Created by Alexander Lowe on 3/13/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import "GTweenColorStrategy.h"
#import "GTween.h"

@implementation GTweenColorStrategy


- (id) initWithDuration:(int)dur delay:(int)del easing:(NSString *)ease andEndColorHex:(int)endColorHex {
    
    self = [super initWithDuration:dur delay:del easing:ease];
    
    _endColorHex = endColorHex;
    
    return self;

}

- (void) performStrategy {
    
float endR = ((float)((_endColorHex & 0xFF0000) >> 16))/255.0;
float endG = ((float)((_endColorHex & 0xFF00) >> 8))/255.0;
float endB = ((float)(_endColorHex & 0xFF))/255.0;

GTween_red   *rTween   = [[GTween_red   alloc]  initWithTarget:_target easing:_easing delay:_delay duration:_duration goal:endR];
GTween_green *gTween   = [[GTween_green alloc]  initWithTarget:_target easing:_easing delay:_delay duration:_duration goal:endG];
GTween_blue  *bTween   = [[GTween_blue  alloc]  initWithTarget:_target easing:_easing delay:_delay duration:_duration goal:endB];

[self addTweenToStrategy:rTween];
[self addTweenToStrategy:gTween];
[self addTweenToStrategy:bTween];
}

@end
