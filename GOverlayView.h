//
//  GPauseView.h
//  CosmicDolphin_5_3
//
//  Created by Alexander  Lowe on 8/16/11.
//  
//

#import "GSurface.h"


@interface GOverlayView : GSurface {
    
GSurface *mainView;

BOOL zapToMainState;
    
}

- (id) initWithResources:(GOptionAndResourceList *)recList withResourceKey:(NSString *)key andMainView:(GSurface *)view;

- (void) returnToMain;

+ (void) shouldOverlayZapToMainState:(BOOL)bl;

@property (nonatomic, readonly) BOOL zapToMainState;

@end
