//
//  GPauseView.m
//  CosmicDolphin_5_3
//
//  Created by Alexander  Lowe on 8/16/11.
//  
//

#import "GOverlayView.h"
#import "GAudio.h"


@implementation GOverlayView

//this variable controls if the overlay view will perform an animation in or if it will simply
//just zap to its post-intro state. you would want it to zap if the app was reacting to coming out
//of the background because of an interruption like a call coming in or the home button getting pressed.
static BOOL zapTo = NO;

@synthesize zapToMainState;



// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass {
return [CAEAGLLayer class];
}


/**
 * should all following instances of GOverlayView skip their intro animations and just show their post-intro configurations.
 *
 */
+ (void) shouldOverlayZapToMainState:(BOOL)bl {
zapTo = bl;
}


/**
 * this is an overlay, so this function will destroy the main view. this is used in cases
 * where the overlay view is going to need to replace itself with a new view, like an overlay
 * menu with a button which goes back to the main menu.
 *
 */
- (void) removeUnderneathViewIfOverlay {
    if(mainView) {
    [mainView destroy];
    mainView = nil;
    //NSLog(@"GAME TABLE DESTROYING");
    }
}



- (id) initWithResources:(GOptionAndResourceList *)recList withResourceKey:(NSString *)key andMainView:(GSurface *)view {

//this is the view that is loading its resources to play a game while this view
//entertains the user with a preloading animation.
mainView = view;

//call super method
self = [super initWithResources:recList andResourceKey:key];

//set the resourcesLoaded to YES, because the preload views are not themselves
//preloaded on a separate thread.
gnarly_resourcesLoaded = YES;

//set the zap variable.
zapToMainState = zapTo;

//// this is set in the options, so it's redundant here.
//this has no pause screen.
//self.pauseOnReturnFromBackground = NO;
      
//// overlay views should generally load in the background.
//load the resources- same as in GLRoot, only here we do it on the main thread
//instead of shunting it off on the operation queue.
//[self loadResourcesAndBuild:nil];


		
return self;

}


/////////////
//         //
//  A P I  //
//         //
/////////////


/**
 * call this function when you're ready for this surface to die and the main surface to start cranking again.
 * you'll probably want to do something like make the pause view perform some kind of fading animation or something,
 * after which, you call this function and this surface will get destroyed and the main view will begin again.
 *
 */
- (void) returnToMain {
[self destroy];
[GSurface setCurrentView:mainView];
[mainView startAnimation];

[[GAudio sharedSoundManager] resumeCommonMusic];
[[GAudio sharedSoundManager] resumeCommonSounds];
[mainView resumeAllMusic];
[mainView resumeAllSounds];

mainView.gnarly_doesOverlayScreenExist = NO;
}





@end
