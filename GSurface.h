/*

File: OpenGLCoreView.h
Abstract: A UIView subclass that allows for the rendering of OpenGL ES content
by a delegate that implements the OpenGLCoreViewDelegate protocol.

*/

//#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "GnarlySettings.h"
#import "GLayerMemoryObject.h"

@class GSurface;
@protocol GSurfaceTransactor


- (GSurface *) gnarly_SurfaceTransactor_getMainView;
- (void) gnarlySaysConfigureForEnd;
@property (nonatomic, readonly) int gnarly_SurfaceTransactor_transactorType;
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_forReplacement;
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_readyToContinueTransaction;
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_isWoundDown;
@property (nonatomic, assign) GSurface *gnarly_SurfaceTransactor_oldSurface,*gnarly_SurfaceTransactor_newSurface;

@end


@class GLoadView;
@class GOverlayView;
@class GSprite;
@class GLoadSprite;
@class GAtlas;
@class GOptionAndResourceList;
@class GAnimation;
@class GChain;
@class GNode;
@class GEvent;
@class GRenderable;
@class CXMLDocument;
@class GSurfaceResourceManager;
@class GEventTouchChain;


@interface GSurface : UIView <GSurfaceTransactor, GLayerMemoryObject>  {


    ////////////////////////////////////////////////////////////////////////
    // variables for Gnarly are prefaced with "gnarly" they dea in memory //
    // management, inter-surface transactions and preloading options. Do  //
    // not attempt to directly set or mutate any variable prefixed by     //
    // "gnarly_". You will very likely cause a crash or a memory leak.    //                                      
    ////////////////////////////////////////////////////////////////////////
    
    //cached atlases for easy access.
    NSMutableDictionary *gnarly_cachedAtlases;
    
    //the dictionary of xml documents available to this surface.
    NSMutableDictionary *gnarly_cachedXML;
    
    //the list of resources available to this surface.
    NSMutableArray *gnarly_resourceList;
    
    //soundkeys for sounds that are bound to this surface.
    NSMutableArray *gnarly_soundKeysToManage;
    
    //music keys for music that is bound to this surface.
    NSMutableArray *gnarly_musicKeysToManage;
    
    //resources that are currently being processed for this surface.
    NSMutableDictionary *gnarly_resourceRequests;
    
    //resource managers that have been created for this surface.
    NSMutableArray *resourceManagers;
    
    //the asynchronouns progress
    float gnarly_asynchProgress;
    
    //the preload view. may or may not exist.
    GLoadView *gnarly_preloadView;
    
    //the preload sprite. may or may not exist.
    GLoadSprite *gnarly_preloadSprite;
    
    //are the resources for this surface loaded?
    BOOL gnarly_resourcesLoaded;
    
    //has this guy been added to the window?
    BOOL gnarly_addedToWindow;
    
    //do we have a preloader
    BOOL gnarly_hasPreloader;
    
    //the keys of the resource lists that are bound to this surface.
    NSMutableArray *gnarly_keysOfResourceLists;
    
    //the class name of the preloader surface that this surface will use as a preloader
    NSString *gnarly_preloadClassName;
    
    //the key to the resource list used by the preloader
    NSString *gnarly_preloadResourceKey;

    //the resource key and the class name to create the pause view.
    NSString *gnarly_pauseResourceKey;
    NSString *gnarly_pauseClassName;
    
    //does this surface show a pause screen when it returns from background execution due to an interruption? the default is   yes.
    BOOL gnarly_pauseOnReturnFromBackground;
    
    //does an overlay pause screen exist?
    BOOL gnarly_doesOverlayScreenExist;
    
    //the key to the original resource list that this
    //surface is loaded with from the start.
    NSString * gnarly_originalResources;
    
    //the transactor variables
    int gnarly_SurfaceTransactor_transactorType; //transactor type
    GSurface *gnarly_SurfaceTransactor_newSurface; //the old surface
    GSurface *gnarly_SurfaceTransactor_oldSurface; //the new surface
    BOOL gnarly_SurfaceTransactor_forReplacement;  //part of a replacement transaction
    BOOL gnarly_SurfaceTransactor_readyToContinueTransaction; //ready to continue
    BOOL gnarly_SurfaceTransactor_isWoundDown; //is the surface wound-down yet?
    
    //the surface key.
    NSString *surfaceKey;
      
    //are we in 2D?      	
	BOOL is2D;

    //the some cached atlases, because we're going to be
    //using the same one over and over again, usually.
    BOOL _firstAtlasLoaded;
    GAtlas *_firstAtlas;
    GAtlas *_cachedAtlas;
    
    //arrays of touches started, and touches ended.
	NSMutableArray *touchesStarted;
	NSMutableArray *tEnded;
	int numTStarted;
    int numTEnded;
    
    //this is the persistent list of touches that exist on the surface at any
    //given time, all in their different life-cycles of touch-start, touch-move, touch-enc
    GEventTouchChain *touchesStartedChain;
    
	//the number of event listeners
	int numLstnrs;
	
	//dictionary of listener objects.
	NSMutableDictionary *listeners;

	// The pixel dimensions of the backbuffer
	GLint backingWidth;
	GLint backingHeight;
	
    // the rendering context.
	EAGLContext *context;
    
	// OpenGL names for the renderbuffer and framebuffers used to render to this view
	GLuint viewRenderbuffer, viewFramebuffer;
	
	// OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
	GLuint depthRenderbuffer;
	
    //the stencil buffer.
	GLuint stencilRenderbuffer;
	
	// An animation timer that, when animation is started, will periodically call -drawView at the given rate.
	NSTimer *animationTimer;
	NSTimeInterval animInterval;
	
	// Delegate to do our drawing, called by -drawView, which can be called manually or via the animation timer.
	//id<OpenGLCoreViewDelegate> delegate;
	id delegate;
    
    //the name
	NSString *name;

    //the chain variables for the render loop, first child and last child
    GNode *firstChild;
    GNode *lastChild;
    int numChildren;
    
    //the chain variables for caching.
    GNode *firstCache;
    GNode *lastCache;
    int numCache;
    
    //chain variables for the safely deleting a GNode object.
    GNode *firstKill;
    GNode *lastKill;
    GNode *nextKill;
    GRenderable *killBound;
    GRenderable *firstInnerKill;
    GRenderable *nextInnerKill;
    BOOL incrementKillElement;
    
    //the default parent node, which is the parent of all objects that are
    //not on the render list.
    GNode *defaultParent;
    
    //the meta-chain of touch chains, for dispatching touch events to the world.
    GChain *touchChain;
    
    //the animation manager.
    GAnimation *animator;
    
    NSDate *_smoothnessDate;
    CADisplayLink *_displayLink;
    float temporalScale;
    double frameTimestamp;
    
    //acceleration, x,y and z.
	float xAccel;
	float yAccel;
	float zAccel;
	
    //did a touch happen?
	BOOL eventsInPlay;
    
    //if the render loop is in a state where it is processing events, then
    //it's possible that it should be culling touch-ended links out of the
    //touches chain. this state will control whether or not that culling loop fires.
    BOOL cullEndedTouchesFromChain;
    
    //the screen dimensions, plus the constant to multiply through to guarantee
    //uniform sizes across all iOS screens.
    int _screenWidth;
    int _screenHeight;
    float _screenCenterX;
    float _screenCenterY;
    BOOL _screenIsRetina;
    float _screenHiResScale;
    
    //has the surface been destroyed?
    //once destroy is called, this is set to YES and
    //then never again to NO. The surface self-destructs
    //and is unavailable for any other transactions.
    BOOL isUnglued;
    
    //has the surface been destroyed after the threads
    //have finished cranking in the background?
    BOOL isThreadsCompleteUnglued;
    
    //the number of background loading processes currenly alive.
    int numberOfBackgroundProcesses;
    
}


- (void) updateWithDisplayLink:(CADisplayLink *)sender;


/////////////////////////////////////
//                                 //
//  private properies and methods  //
//                                 //
/////////////////////////////////////


@property (readonly) GLint backingWidth;
@property (readonly) GLint backingHeight;
@property (readonly) GAnimation *animator;
@property (nonatomic, assign) NSString *surfaceKey;
@property (nonatomic,retain) NSMutableArray *touchesStarted;
@property (nonatomic,retain) NSMutableArray *tEnded;
@property (nonatomic, assign) int numTStarted;
@property (nonatomic, assign) int numTEnded;
@property (nonatomic, assign) GNode *defaultParent;
@property (nonatomic, assign) BOOL eventsInPlay;
@property (nonatomic, assign) GChain* touchChain;
@property (nonatomic, assign) GEventTouchChain *touchesStartedChain;

@property (nonatomic, readonly) BOOL isUnglued;
@property (nonatomic, readonly) float temporalScale;

@property (nonatomic, assign) BOOL isObjectDestroyed;


// gnarly accessors.
@property (nonatomic, assign) NSMutableArray *gnarly_musicKeysToManage, *gnarly_soundKeysToManage, *gnarly_resourceList;
@property (nonatomic, assign) float gnarly_asynchProgress;
@property (nonatomic, assign) GLoadView *gnarly_preloadView;
@property (nonatomic, assign) GLoadSprite *gnarly_preloadSprite;
@property (nonatomic, assign) BOOL gnarly_resourcesLoaded, gnarly_addedToWindow, gnarly_hasPreloader;
@property (nonatomic, assign) NSMutableArray *gnarly_keysOfResourceLists;
@property (nonatomic, assign) NSMutableDictionary *gnarly_cachedAtlases, *gnarly_resourceRequests;
@property (nonatomic, assign) BOOL gnarly_pauseOnReturnFromBackground;
@property (nonatomic, assign) BOOL gnarly_doesOverlayScreenExist;
@property (nonatomic, readonly) NSString *gnarly_preloadClassName;
@property (nonatomic, readonly) NSString *gnarly_preloadResourceKey;
@property (nonatomic, readonly) NSString *gnarly_originalResources;

// GSurfaceTransactor methods and properties.
- (GSurface *) gnarly_SurfaceTransactor_getMainView;
- (void) gnarlySaysConfigureForEnd;
@property (nonatomic, readonly) int gnarly_SurfaceTransactor_transactorType; 
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_forReplacement;
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_readyToContinueTransaction;
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_isWoundDown;
@property (nonatomic, assign) GSurface *gnarly_SurfaceTransactor_oldSurface;
@property (nonatomic, assign) GSurface *gnarly_SurfaceTransactor_newSurface;

//helpers for the display list logic.
- (void) addToSiblingChain:(GNode *)child withPrev:(GNode *)prv andNext:(GNode *)nxt;
- (void) assignFirstChild:(GNode *)first;
- (void) removeFromSiblingChain:(GNode *)child;
- (void) addToCacheChain:(GNode *)node;
- (void) addToKillChain:(GNode *)node;
- (void) removeFromCacheChain:(GNode *)node;

//if this is an overlay view, this thing will
//remove the view which this is an overlay of.
- (void) removeUnderneathViewIfOverlay;

//the preloader is destroyed, so this will set the
//internal reference to nil for safety's sake.
- (void) preloaderIsDestroyed;


- (float) getTimeIntervalScale;

//set the screen dimensions so that the appropriate classes will contain
//them as private variables.
+ (void) setScreenW:(int)w H:(int)h cX:(float)x cY:(float)y hiResScale:(float)screenHiResScale isRetina:(BOOL)isRetina;

//render function
- (void) renderScene;

//the destroy method, which is wired to fire after the last full turn
//of the render loop has happened.
- (void) safeDestroy;

//initialization
- (void) setupScene;
- (void) initGLES;
- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

//access to the animation layer.
- (GAnimation *) getAnimationLayer;

// coordinate transformations/
CGPoint gameToView(float xCoord, float yCoord, float w, float h);
CGPoint viewToGame(float xCoord, float yCoord, float w, float h);

//configure the options.
- (void) configurePreloaderWithClassName:(NSString *)class andResourceKey:(NSString *)key;
- (void) configurePauseWithClassName:(NSString *)class andResourceKey:(NSString *)key;

//deletage methods to get touches and accelerations.
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;


//helpers for textures.
- (void) addTexture:(NSString *)texture andMap:(NSString *)map withKey:(NSString *)key;
- (BOOL) didFirstAtlasLoad;

- (void) addXML:(CXMLDocument *)doc withKey:(NSString *)key;

//the init method
- (id) initWithResources:(GOptionAndResourceList *)recList andResourceKey:(NSString *)resKey;

//these are called whenever a background process for loading
//resources on this surface is started or completed.
- (void) incrementNumberBackgroundProcesses;
- (void) decrementNumberBackgroundProcesses;
- (BOOL) resourceRequests_logNewResourceRequestForKeyForGnarly:(NSString *)key;
- (BOOL) resourceRequests_checkResourcesAreStillLoadingForKeyForGnarly:(NSString *)key;
- (BOOL) resourceRequests_checkResourceRequestCancelationForKeyForGnarly:(NSString *)key;
- (BOOL) resourceRequests_checkResourceRequestCancelationOrLoadingForKeyForGSurfaceResourceManager:(NSString *)key;


/////////////
//         //
//  A P I  //
//         //
/////////////


//music and sounds.
- (void) pauseAllMusic;
- (void) pauseAllSounds;
- (void) resumeAllMusic;
- (void) resumeAllSounds;

//accessors for the asynchronous progress.
- (void) setAsynchProgress:(float)prog;
- (float) asynchProgress;

//get the current view so that all of the rendering objects
//will automatically know who their root level is.
+ (GSurface *)getCurrentView;
+ (void)setCurrentView:(GSurface *)rt;

//update the rendering context.
- (void) makeContextCurrent;

//give the surface a chance to release its resources and any retentions that
//have cropped up.
- (void) releaseResources;

//display list functions.
- (void) addChild:(GNode *)child;
- (void) addChild:(GNode *)child at:(int)ind;
- (void) addChild:(GNode *)child after:(GNode *)ref;
- (void) addChild:(GNode *)child before:(GNode *)ref;
- (void) addInBack:(GNode *)child;
- (void) removeChild:(GNode *)child;
- (GNode *) getChildAt:(int)index;

//event listening.
- (void) addEL:(NSString *)evt withCallback:(NSString *)cllbck andObserver:(id)obs;
- (void) dispatch:(GEvent *)evt;
- (void) removeEL:(NSString *)evt;
- (BOOL) areEventsInPlay;

//start/stop the animation
- (void) startAnimation;
- (void) stopAnimation;

//opacity of the backing.
- (BOOL) opaque;
- (void) setOpaque:(BOOL)truth;

//set/get the animation interval
- (void)setAnimationInterval:(NSTimeInterval)interval;
- (NSTimeInterval)animationInterval;

//set the backing color and opacity. rejiggers the opaque property within it.
- (void) backingColor:(int)hex andOpacity:(float)op;

//get a texture and sprite map
- (GAtlas *) getAtlas:(NSString *)key;
- (void) installCachedAtlasOnGSprite;

//get the xml associated with a key.
- (CXMLDocument *) getXML:(NSString *)key;

//the loading sprite was created, so this function must do something
- (void) gnarlySaysStartLoadingSprite:(GLoadSprite *)loader withData:(GSurfaceData)data;
- (void) gnarlySaysEndLoadingSprite:(GLoadSprite *)loader;

//trigger the outro animation, and then tell the preloading sprite we're ready
//to proceed to the next scene.
- (void) gnarlySaysWindDownSurface;

//the jumping off point to build stuff on the surface and begin stuff happening.
- (void) gnarlySaysBuildSurface;

//this is when the application enters the background
- (void) gnarlySaysSaveUserData;


//these function fire immediately before gnarlySaysBuildSurface. Gives us a change to
//make some modification depending on our environment.
- (void) gnarlySays_iPhone;
- (void) gnarlySays_iPad;
- (void) gnarlySays_iPodTouch;
- (void) gnarlySays_iPadMini;


//the jumping off point to start sounds.
- (void) gnarlySaysStartSounds;

//pause the game and show the overlay.
- (void) pauseGameAndShowOverlay;
- (void) pauseGameAndZapToOverlay;

//a delegate method to get a single touch point which
//was not captured by any game object.
- (void) freeTouchPoint:(CGPoint)gamePoint;

//destroy method
- (void) destroy;

//get the number of children
@property (nonatomic, assign) int numChildren;

//get/set the name of this object.
@property (nonatomic, retain) NSString *name;

//accelerations
@property (nonatomic, assign) float xAccel;
@property (nonatomic, assign) float yAccel;
@property (nonatomic, assign) float zAccel;







@end

