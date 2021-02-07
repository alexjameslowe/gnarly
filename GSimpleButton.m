//
//  GSimpleButton.m
//  RidiculousMissile2
//
//  Created by Alexander  Lowe on 4/26/11.
//  Copyright 2011 Codequark. See Licence.
//

#import "GSimpleButton.h"
#import "GEvent.h"
#import "GRenderable.h"

@implementation GSimpleButtonSkin

@end


@implementation GSimpleButton

@synthesize buttonId;



/**
 * init with an event to fire when the button is pressed.
 *
 */
- (id) init:(NSString *)key up:(int)u down:(int)d event:(NSString *)evt {
    
upPosition = u;
downPosition = d;

//set up the event to fire when the button is selected.
eventOnSelect = evt;
eventOrCallback = YES;

countLimit = 5;
btnDown = NO;
btnReleased = NO;

return [super init:key];
    
}


/**
 * init with a callback to fire when the button is pressed.
 *
 */
- (id) init:(NSString *)key up:(int)u down:(int)d callback:(NSString *)cllbck observer:(id <GLayerMemoryObject>)obs {
    
self = [super init:key];

upPosition = u;
downPosition = d;

//set up the callback to fire when the button is selected.
callback = NSSelectorFromString([cllbck stringByAppendingString:@":"]);
callbackObserver = obs;
eventOrCallback = NO;
    
countLimit = 5;
btnDown = NO;
btnReleased = NO;

[self goTo:upPosition];

[self addEL:@"T_START" withCallback:@"buttonDown" andObserver:self];
[self addEL:@"T_END"   withCallback:@"buttonUp"   andObserver:self];
    
return self;  
    
}




/**
 * callbacks. the button will not react unless the user's finger is over the button when (s)he releases it.
 * that's expected behavior.
 *
 */
- (void) buttonDown:(GEvent *)evt {
evt.keepBubbling = NO;

//self.rotationOverride = YES;

    if(btnReleased == NO) {
    btnDown = YES;
    [self goTo:downPosition];
    }
    
[self dispatch:[[GEvent alloc] init:@"BTN_START" bubbles:YES]];
}
- (void) buttonUp:(GEvent *)evt {
evt.keepBubbling = NO;

    if(btnDown == YES) {
    btnDown = NO;
    
        if([self touchPointTest:gamePoint] == YES) {
        btnReleased = YES;
        }
        
    [self goTo:upPosition];
    }
    
    
[self dispatch:[[GEvent alloc] init:@"BTN_END" bubbles:YES]];
}



/**
 * this override of the render method will make sure that when the button is released,
 * the button waits for a few frames before it takes action.
 *
 */
- (GRenderable *) render {

    if(btnReleased == YES) {
    stackCount++;
    
        if(stackCount == countLimit) {
        stackCount = 0;
        btnReleased = NO;
        
            if(eventOrCallback == YES) {
            [self dispatch:[[GEvent alloc] init:eventOnSelect bubbles:YES]];
            } else {
            //objc_msgSend(callbackObserver, callback, self);
            [callbackObserver performSelector:callback withObject:self];
            }
        
        }
            
    }
    
return [super render];
    
}


@end
