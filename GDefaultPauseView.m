//
//  GDefaultPauseView.m
//  CosmicDolphin_5_3
//
//  Created by Alexander  Lowe on 8/16/11.
//  
//

#import "GDefaultPauseView.h"
#import "GSimpleButton.h"
#import "GBox.h"
#import "GSprite.h"
#import "GAnimation.h"
#import "GTweenInfo.h"


@implementation GDefaultPauseView


- (void) gnarlySaysBuildSurface {
    
    //NSLog(@"!!");

[self backingColor:0x000000 andOpacity:0];

background = [[GBox alloc] init];
[background rectWidth:_screenWidth andHeight:_screenHeight];
background.color = 0x000000;
[self addChild:background];

pauseMsg = [[GSprite alloc] init:@"DEFAULT_PAUSE"];
[pauseMsg goTo:0];
[self addChild:pauseMsg];

returnButton = [[GSimpleButton alloc] init:@"DEFAULT_PAUSE" up:1 down:2 callback:@"returnBtnPressed" observer:self];
[self addChild:returnButton];


    if(zapToMainState == NO) {
    
    background.opacity = 0;
   // [background animate:@"opacity,0.9,easeInOutQuad,30,0" onStart:nil startObs:nil onEnd:nil endObs:nil];
   //[GAnimation tweenSet:@"opacity,0.9,easeNone,15,0" box:background];
    [GAnimation beginSet:background];
    [GAnimation animate:@"opacity" duration:15 delay:0 end:0.9 easing:@"easeNone"];
    [GAnimation endSet];
        
    pauseMsg.x = _screenWidth;
    pauseMsg.y = 100;
    //[pauseMsg animate:@"x,100,easeInOutQuad,10,30" onStart:nil startObs:nil onEnd:nil endObs:nil];
    //[GAnimation tweenSet:@"x,100,easeNone,10,15" box:pauseMsg];
    [GAnimation beginSet:pauseMsg];
    [GAnimation animate:@"x" duration:15 delay:0 end:50*_screenHiResScale easing:@"easeOutQuad"];
    [GAnimation endSet];

    returnButton.y = 150;
    returnButton.x = _screenWidth;
    //[returnButton animate:@"x,100,easeInOutQuad,10,35" onStart:nil startObs:nil onEnd:nil endObs:nil];
    //[GAnimation tweenSet:@"x,100,easeNone,10,20" box:returnButton];
    [GAnimation beginSet:returnButton];
    [GAnimation animate:@"x" duration:15 delay:0 end:50*_screenHiResScale easing:@"easeOutQuad"];
    [GAnimation endSet];
    
    } else {
    
    background.opacity = 0.9;

    pauseMsg.x = 100;
    pauseMsg.y = 100;

    returnButton.y = 150;
    returnButton.x = 100;  
    
    }

}


- (void) returnBtnPressed:(GSimpleButton *)btn {
//have a look at this thing. we need to have a destroyTweenForTarget function after all.
[GAnimation destroyTweensForTarget:background];
[GAnimation destroyTweensForTarget:pauseMsg];
[GAnimation destroyTweensForTarget:returnButton];

    
    [GAnimation beginSet:background];
    [GAnimation animate:@"opacity" duration:15 delay:0 end:0 easing:@"easeNone"];
    [GAnimation onEnd:@"outroIsDone" endObs:self];
    [GAnimation endSet];
    
    [GAnimation beginSet:pauseMsg];
    [GAnimation animate:@"x" duration:15 delay:0 end:_screenWidth easing:@"easeInBack"];
    [GAnimation endSet];
    
    [GAnimation beginSet:returnButton];
    [GAnimation animate:@"x" duration:15 delay:0 end:_screenWidth easing:@"easeInBack"];
    [GAnimation endSet];
    
    
    
}


- (void) outroIsDone:(GTweenInfo *)info {
[self returnToMain];
}


@end
