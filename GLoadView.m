//
//  GLoadView.m
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 8/5/11.
//  
//

#import "GLoadView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "GOptionAndResouceList.h"
#import "GAsynchronousLoadingData.h"
#import "Gnarly.h"


@implementation GLoadView

@synthesize mainView;

// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass {
return [CAEAGLLayer class];
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

//this has no pause screen.
gnarly_pauseOnReturnFromBackground = NO;

//set the transactor type here. for Gnarly.
gnarly_SurfaceTransactor_transactorType = 2;

//load the resources- same as in GLRoot, only here we do it on the main thread
//instead of shunting it off on the operation queue.
GAsynchronousLoadingData *gData = [[GAsynchronousLoadingData alloc] initWithKey:nil callback:nil observer:nil andPreloadFlag:YES];

[GSurface setCurrentView:self];
[self makeContextCurrent];
[self initGLES];
[self setupScene];

[[Gnar ly] loadResourcesAndBuildOrCall:gData forSurface:self];

//have to manually release the data packet here.
[gData release];
		
return self;

}


/**
 * reset this to nil so that it won't blow up 
 * otherwise good code.
 *
 */
- (void) mainViewIsDestroyed {
mainView = nil;
}


/**
 * we override this to take away the stuff that GSurface would do right here.
 *
 */
- (void) willMoveToSuperview:(UIView *)newWindow {}


/**
 * GSurfaceTransactor functions. used by Gnarly. do not mess with them.
 *
 */
- (GSurface *) gnarly_SurfaceTransactor_getMainView {
return mainView;
}


///////////////
//           //
//  A  P  I  //
//           //
///////////////



/**
 * override this method to populate the preloader view with some shiny objects for the user
 * to watch while all of the resources are aynchronously loaded on the main view.
 *
 */
- (void) gnarlySaysBuildSurface {}


/**
 * called by the loading view when the loading view is finished loading. In some cases maybe you would want
 * fade out the animation or something here. up to you. But whatever you set into motion here, the message
 * [[Gnar ly] windDownFinishedContinueTransaction:self] must be called at the end. 
 * if you don't need to do any fancy wind-down animation, then just override this method to call 
 * [[Gnar ly] windDownFinishedContinueTransaction:self]; 
 * immediately and be done with it. 
 *
 */
- (void) gnarlySaysWindDownSurface {
[[Gnar ly] windDownFinishedContinueTransaction:self];
}



@end
