//
//  GDefaultPauseView.h
//  CosmicDolphin_5_3
//
//  Created by Alexander  Lowe on 8/16/11.
//  
//

#import "GOverlayView.h"

@class GBox;
@class GSprite;
@class GSimpleButton;

@interface GDefaultPauseView : GOverlayView {

GBox *background;

GSprite *pauseMsg;

GSimpleButton *returnButton;
    
}

@end
