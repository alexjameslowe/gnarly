#import "GSurface.h"
#import "GLoadView.h"
#import "GOverlayView.h"
#import "GLoadSprite.h"
#import "GDefaultPauseView.h"
#import "GSprite.h"
#import "GLoadView.h"
#import "GOverlayView.h"
#import "GSprite.h"
#import "GLoadSprite.h"
#import "GAtlas.h"
#import "GOptionAndResourceList.h"
#import "animation/GAnimation.h"
#import "GChain.h"
#import "GNode.h"
#import "GEvent.h"
#import "GTexture.h"
#import "GSpriteMap.h"
#import "GListener.h"
#import "GnarlySettings.h"
#import "GAudio.h"
#import "GAsynchronousLoadingData.h"
#import "TouchXML.h"
#import "GEventTouchObject.h"



@implementation GSurface

static GSurface *currentView;

//static BOOL fff = NO;


//screen dimensions.
static int SCREEN_WIDTH;
static int SCREEN_HEIGHT;
static float CENTER_X;
static float CENTER_Y;
static BOOL ISRETINA;
static float SCREEN_HIRES;


///// NEW
@synthesize gnarly_musicKeysToManage, gnarly_soundKeysToManage,gnarly_resourceList;
@synthesize gnarly_asynchProgress;
@synthesize gnarly_preloadView;
@synthesize gnarly_preloadSprite;
@synthesize gnarly_resourcesLoaded;
@synthesize gnarly_hasPreloader, gnarly_addedToWindow;
@synthesize gnarly_keysOfResourceLists;
@synthesize gnarly_cachedAtlases;
@synthesize gnarly_resourceRequests;
@synthesize gnarly_originalResources;

@synthesize animator;
@synthesize temporalScale;
/////

@synthesize isObjectDestroyed;

@synthesize isUnglued;

@synthesize backingWidth,backingHeight;

@synthesize xAccel,yAccel,zAccel;

@synthesize eventsInPlay;

@synthesize numChildren, numTStarted, numTEnded;

@synthesize name;

@synthesize touchesStarted;

@synthesize tEnded;

@synthesize defaultParent;

@synthesize touchChain;

@synthesize surfaceKey;

@synthesize touchesStartedChain;


@synthesize gnarly_pauseOnReturnFromBackground;
@synthesize gnarly_doesOverlayScreenExist;
@synthesize gnarly_preloadClassName, gnarly_preloadResourceKey;

///surface transactor properties.
@synthesize gnarly_SurfaceTransactor_newSurface;
@synthesize gnarly_SurfaceTransactor_oldSurface;
@synthesize gnarly_SurfaceTransactor_isWoundDown;
@synthesize gnarly_SurfaceTransactor_transactorType;
@synthesize gnarly_SurfaceTransactor_forReplacement;
@synthesize gnarly_SurfaceTransactor_readyToContinueTransaction;


//////////
// Init //
//////////


// Implement this to override the default layer class (which is [CALayer class]).
// We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
+ (Class) layerClass {
return [CAEAGLLayer class];
}

- (void) loadView {
    
    
}



/***
 * inits this object with a comma-separated list of textures and maps to use. Their positions in the list
 * (from 0) is how you access them when creating a sprite.
 *
 */

- (id) initWithResources:(GOptionAndResourceList *)recList andResourceKey:(NSString *)resKey {
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    
	if(self != nil) {
        
        //gnarly variables, for transaction narratives and memory management.
        //do not screw with this variables by yourself at run-time.
        gnarly_cachedAtlases  = [[NSMutableDictionary alloc] init];
        gnarly_cachedXML = [[NSMutableDictionary alloc] init];
        gnarly_resourceRequests = [[NSMutableDictionary alloc] init];
        gnarly_soundKeysToManage = [[NSMutableArray alloc] init];
        gnarly_musicKeysToManage  = [[NSMutableArray alloc] init];
        gnarly_resourcesLoaded = NO;
        gnarly_addedToWindow = NO;
        gnarly_hasPreloader = NO;
        gnarly_originalResources = resKey;
        gnarly_resourceList = recList.resources;
        gnarly_keysOfResourceLists = [[NSMutableArray alloc] init]; 
        [gnarly_keysOfResourceLists addObject:resKey];
        gnarly_SurfaceTransactor_transactorType = 3;
        gnarly_pauseOnReturnFromBackground = YES;
        gnarly_doesOverlayScreenExist = NO;
        gnarly_pauseResourceKey = @"_DfltPauseScrn";
        gnarly_pauseClassName = @"GDefaultPauseView";
        gnarly_SurfaceTransactor_isWoundDown = NO;
        
            //if the surface is supposed to have a preloader, then make sure it's configured to have one.
            if(recList.hasPreloader == YES) {
            gnarly_hasPreloader = YES;
            gnarly_preloadResourceKey = recList.preloaderResourceKey;
            gnarly_preloadClassName = recList.preloaderClassName;
            }
            //if the surface has a different pause screen than the default one, then configure it.
            if(recList.hasPause == YES) {
            gnarly_pauseResourceKey = recList.pauseResourceKey;
            gnarly_pauseClassName = recList.pauseClassName;
            } 
            
        //set the pauseOnReturnFromBackground.
        gnarly_pauseOnReturnFromBackground = recList.willSurfacePauseOnReturnFromBackground;
        
        //set these guys so that we can get touches.
		self.multipleTouchEnabled = YES;
        self.userInteractionEnabled = YES;
        
        //set this. it gets set to YES when this thing is deleted,
        //and this prevents any calls to deleted objects.
        isUnglued = NO;
        isThreadsCompleteUnglued = NO;
        
        //a first-fire variable so that the first atlas
        //variable only gets assigned once.
		_firstAtlasLoaded = NO;
        
        //create an instance of the animation engine.
        animator = [[GAnimation alloc] init];
        
		is2D = YES;
	    eventsInPlay = NO;
		numChildren = 0;
        numCache = 0;
        
        
        //set the private properties
        _screenWidth = SCREEN_WIDTH;
        _screenHeight = SCREEN_HEIGHT;
        _screenCenterX = CENTER_X;
        _screenCenterY = CENTER_Y;
        _screenIsRetina = ISRETINA;
        _screenHiResScale = SCREEN_HIRES;
    
        //create the meta-container for all of the end-of-frame touch
        //events that need to be dispatched.
        touchChain = [[GChain alloc] init];
        
        //create the container for all of the touch objects for this surface.
        //each of the touch objects will be kept in correlation to the touches
        //that the OS hands us, but we don't rely on the objects that the OS gives
        //us. we don't store references to them in any way.
        touchesStartedChain = [[GEventTouchChain alloc] init];
        
        
        //the array to house all of the resource managers.
        resourceManagers = [[NSMutableArray alloc] init];
        	
	    //listeners
	    listeners = [[NSMutableDictionary alloc] init];
	    numLstnrs = 0;
        
        //TODO see if these things need to be created at all here
        //because they get created at run time.
        //lists of touches in play in the surface.
        //MEMORY TESTS. I THINK THESE ARE LEAKING.
		//touchesStarted = [[NSMutableArray alloc] init];
		//tEnded   = [[NSMutableArray alloc] init];

		defaultParent = [[GNode alloc] startAsMainDefault:self];
		defaultParent.name = @"defaultPrnt";
		
		//#if gAccelerometerEnabled == gYES
		//[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0/gAccelerometerFrequency)];
	    //[[UIAccelerometer sharedAccelerometer] setDelegate:self];
        //#endif
	
        //set the current view.
		//currentView = self;
        
        
        //CODE MOVED DOWN TO THE initGLES FUNCTION
        //create the context on this thread, OpenGL is picky about which thread this happens on.
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup: [[Gnar ly] getShareGroup]];
        [self makeContextCurrent];
        [GSurface setCurrentView:self];
        /////////////////////////////////////////
        
        //}
            
        //the safety retention. will not get released
        //until all elements are done deallocing.
        [self retain];
        
	}
	return self;
}



/**
 * A couple of surface transaction functions.
 * There's another one further down in the API section
 * that you can extend to perfrom actions on the loading sprite.
 *
 */
- (GSurface *) gnarly_SurfaceTransactor_getMainView {
return nil;
}


+ (void) setScreenW:(int)w H:(int)h cX:(float)x cY:(float)y hiResScale:(float)screenHiResScale isRetina:(BOOL)isRetina {
SCREEN_WIDTH = w;
SCREEN_HEIGHT = h;
CENTER_X = x;
CENTER_Y = y;
ISRETINA = isRetina;
SCREEN_HIRES = screenHiResScale;
}


- (void) removeUnderneathViewIfOverlay {
//take no action.
}


/**
 * call immediately after init to configure the surface to have a preloaded. Must be called before this
 * thing gets added to any super view. 
 *
 */
- (void) configurePreloaderWithClassName:(NSString *)class andResourceKey:(NSString *)key {
gnarly_hasPreloader = YES;
gnarly_preloadResourceKey = key;
gnarly_preloadClassName = class;
}



/**
 * call immediately after init to configure the surface to have a preloaded. Must be called before this
 * thing gets added to any super view. 
 *
 */
- (void) configurePauseWithClassName:(NSString *)class andResourceKey:(NSString *)key {
gnarly_pauseResourceKey = key;
gnarly_pauseClassName = class;
}



/**
 * get and set the class's currentView, which is the view object which will implcitly own
 * all GBox objects.
 *
 */
+ (GSurface *)getCurrentView {
return currentView;
}
+ (void)setCurrentView:(GSurface *)rt {

   if([rt didFirstAtlasLoad] == YES) {
   //[rt installCachedAtlasOnGSprite];
   }
    
currentView = rt;
}

- (void) installCachedAtlasOnGSprite {
[GSprite setFirstAtlas:_firstAtlas andCachedAtlas:_cachedAtlas];
}



/**
 * init all the OpenGL stuff. I don't really know too much
 * about what's going on here.
 *
 */
-(void)initGLES {
    
    ///CODE MOVED FROM THE INIT FUNCTION.
    //context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup: [[Gnar ly] getShareGroup]];
    //[self makeContextCurrent];
    //[GSurface setCurrentView:self];
    /////////////////

    
CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;

//http://www.david-amador.com/2010/09/setting-opengl-view-for-iphone-4-retina-hi-resolution/
//LOWE 2014-05-11 RETINA
eaglLayer.contentsScale = [[Gnar ly] screenHiResScale];//2.0f;
    
// Configure it so that it is opaque, does not retain the contents of the backbuffer when displayed, and uses RGBA8888 color.
eaglLayer.opaque = YES;
eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    nil];

// ordinarily you would create an EAGL context right here, but we're doing multithreader, so it's a bit different.
   
    if(!context || ![EAGLContext setCurrentContext:context] || ![self createFramebuffer]) {
    [self release];
    }

glEnableClientState(GL_VERTEX_ARRAY);
}

/***
 *  If our view is resized, we'll be asked to layout subviews.
 *  This is the perfect opportunity to also update the framebuffer so that it is
 *  the same size as our display area.
 * 
 */
-(void)layoutSubviews {
//[EAGLContext setCurrentContext:context];
}


/**
 * return the animation engine.
 *
 */
- (GAnimation *) getAnimationLayer {
    return animator;
}





///////////////
//           //
//  Open GL  //
//           //
///////////////

//http://www.lastrayofhope.com/2011/07/07/iphone-multithreading-opengl/
//http://stackoverflow.com/questions/8990770/failed-to-make-complete-framebuffer-object-8cd6-ios-programmatically-created-o?rq=1
//http://stackoverflow.com/questions/10721496/opengles-issues-with-framebuffer



/**
 * create the frame buffer, which is something I don't really understand.
 *
 */
- (BOOL)createFramebuffer {
	
// Generate IDs for a framebuffer object and a color renderbuffer
glGenFramebuffersOES(1, &viewFramebuffer);
glGenRenderbuffersOES(1, &viewRenderbuffer);

GLenum err = glGetError();
        if (err != GL_NO_ERROR) {
        printf("Error 0. glError: 0x%04X\n", err);
        }

glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);

GLenum err2 = glGetError();
        if (err2!= GL_NO_ERROR) {
        printf("Error 1. glError: 0x%04X\n", err2);
        }

// This call associates the storage for the current render buffer with the EAGLDrawable (our CAEAGLLayer)
// allowing us to draw into a buffer that will later be rendered to screen whereever the layer is (which corresponds with our view).
[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);

glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

GLenum err3 = glGetError();
        if (err3!= GL_NO_ERROR) {
        printf("Error 2. glError: 0x%04X\n", err3);
        }

//we're using the depth buffer....
glGenRenderbuffersOES(1, &depthRenderbuffer);
glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);

GLenum err4 = glGetError();
        if (err4!= GL_NO_ERROR) {
        printf("Error 3. glError: 0x%04X\n", err4);
        }

   // if we're using the stencil buffer, which we probably never will....
  //  glGenRenderbuffersOES(1, &stencilRenderbuffer);
  //  glBindRenderbufferOES(GL_RENDERBUFFER_OES, stencilRenderbuffer);
  //  glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_STENCIL_INDEX8_OES, backingWidth, backingHeight);
  //  glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_STENCIL_ATTACHMENT_OES, GL_RENDERBUFFER_OES, stencilRenderbuffer);


    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
    NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    return NO;
    }

return YES;
}



/***
 * Clean up any buffers we have allocated.
 *
 */
- (void)destroyFramebuffer {
glDeleteFramebuffersOES(1, &viewFramebuffer);
viewFramebuffer = 0;
glDeleteRenderbuffersOES(1, &viewRenderbuffer);
viewRenderbuffer = 0;
	
    if(depthRenderbuffer) {
    glDeleteRenderbuffersOES(1, &depthRenderbuffer);
    depthRenderbuffer = 0;
    }
	
    //if(stencilRenderbuffer) {
    //glDeleteRenderbuffersOES(1, &stencilRenderbuffer);
    //stencilRenderbuffer = 0;
    //}
}



/***
 * configure the OpenGL rendering surface.
 *
 */
-(void)setupScene {
    
    /*
     
     Should my images be saved at a specific PPI?
     
     No. iOS ignores PPI (pixels per inch) stored inside images. However, the pixel dimensions of your images do matter, so make sure you get those right. It’s also important to ensure your 2× images are exactly double
     the dimensions of your 1× images and that elements within the image are in the same positions—your Retina images should be identical content to their smaller counterparts, but with more detail.
     
     (via http://bjango.com/articles/designingforretina2/)
     
     Read the above article it's invaluable, if you're designing for iOS. Dimensions matter, the PPI is irrelevant.
     
     */
 
        if(is2D == YES) {
		glDisable(GL_DEPTH_TEST);
        } else {
		glEnable(GL_DEPTH_TEST);	
        }
    
    //See Notes iOS getting the frame right for OpenGL ES 1.1.txt for a debugging effort
    //that I had to do during the RobRocket launch. There were iPad compatibility problems
    //and a crash from a quick bug fix. Always it's the quick bug fixes. Anyway, see that
    //set of notes for glViewport, glOrthof.

	
   //LOWE 2014-05-11 RETINA
   //###################################################
    //CGRect rect = [[UIScreen mainScreen] bounds];
    //float w = CGRectGetWidth(rect) * [[Gnar ly] screenHiResScale];
    //float h = CGRectGetHeight(rect) * [[Gnar ly] screenHiResScale];
    float w = [[Gnar ly] screenWidth];
    float h = [[Gnar ly] screenHeight];
    
    //NSLog(@"GSurface: w: %f",w);
    //NSLog(@"GSurface: h: %f",h);


	if(is2D == NO) {
    const GLfloat zNear = 0.1,
    zFar = 1000.0,
    fieldOfView = 60.0;
    GLfloat size;
    size = zNear * tanf((gDegToRad*fieldOfView)/2.0);
    glFrustumf(-size, size, -size/(w/h), size/(w/h), zNear, zFar);
	}
    

    glViewport(0, 0, w, h);
    
    
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

    
    //for portrait mode, possibly.
    //glOrthof(0.0f, w, h, 0.0f, 600.0f, -600.0f);
    
    //for landscape-left
    glOrthof(w, 0.0f, 0.0f, h, 600.0f, -600.0f);
    
	glMatrixMode(GL_MODELVIEW);
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
}


/////////////////////////
//                     //
//  loading resources  //
//                     //
/////////////////////////



/**
 * when this thing is added to the display list, it's going to create a pre-loading screen, and add it above this
 * view. the preloading screen will only have a few resources available to it. the pre-loading screen is a self-contained
 * GSurface which will do animations and shit while this object cranks on loading and caching its resources. when it's done, 
 * it will send a message to the preloading screen to wrap it up. then the preloading screen will wrap it up, and when it's
 * done wrapping it up, it will send a message back to this view that it's time to roll. gnarlySaysBuildSurface will get called, and the 
 * preloader screen will self-destruct. 
 *
 * For the moment, we will assume that each view has its own texture resources, and these texture resources will be destroyed when
 * the view is destroyed. Sound resources however will carry over. They can be marked at creation to either be live on past the view or
 * to be destroyed along with the view. If they carry over, then they will still be destroyed when the application terminates. The whole point
 * of this is that sometimes you're going to want background music to carry over between different views. So it shouldn't always need to get destroyed.
 *
 *
 */
- (void)willMoveToSuperview:(UIView *)newWindow {
    
    //Heh! this seems to have no effect on the flicker. What could be causing this?
    //if(!fff) {
    //fff = YES;
    //NSLog(@"########################### beginLoadingResourcesForSurface");

        //tell Gnarly to start loading the resources.
        [[Gnar ly] beginLoadingResourcesForSurface:self];
        
    //}

}


/**
 * these functions are meant to keep track of how many background processes are currently
 * active for this surface. These threads will be involved in loading resources. If
 * the surface has been destroyed and some processes are still alive,
 *
 */
- (void) incrementNumberBackgroundProcesses {
numberOfBackgroundProcesses++;
}
- (void) decrementNumberBackgroundProcesses {
numberOfBackgroundProcesses--;
    if(numberOfBackgroundProcesses == 0 && isUnglued == YES) {
    [self backgroundThreadsAreDoneSoCompleteDestruction];
    }
}



/**
 * these functions manage elements of gnarly_resourceRequests, and return a boolan
 * variable which tells Gnarly's resource loading/destruction/creation functions whether or
 * not to bail out.
 *
 */
- (BOOL) resourceRequests_logNewResourceRequestForKeyForGnarly:(NSString *)key {
    
NSString *rCode = (NSString *)[gnarly_resourceRequests objectForKey:key];
    
    //if the request is currently in motion, then return NO, because the
    //request was somehow made twice.
    if(rCode) {
    return NO;
    }
   
//0 means that the resources are loading.
[gnarly_resourceRequests setObject:@"0" forKey:key];
return YES;
}
- (BOOL) resourceRequests_checkResourcesAreStillLoadingForKeyForGnarly:(NSString *)key {
    
    NSString *rCode = (NSString *)[gnarly_resourceRequests objectForKey:key];
    
    //if the request is absent, that means that the request was previously completed
    //and the destruction of resources can continue like usual.
    if(!rCode) {
    return YES;
    }
    
    //if the resources are still loading, then we're going to change this to 1,
    //which is a signal that when they are finished loading, they will immediately be destroyed.
    if([rCode isEqualToString:@"0"]) {
    [gnarly_resourceRequests removeObjectForKey:key];
    [gnarly_resourceRequests setObject:@"1" forKey:key];
    }
    
return NO;
}
- (BOOL) resourceRequests_checkResourceRequestCancelationForKeyForGnarly:(NSString *)key {

    NSString *rCode = (NSString *)[gnarly_resourceRequests objectForKey:key];
    
    //if the request is absent, that means that the request was previously completed
    //and the destruction of resources can continue like usual.
    if(!rCode) {
    return NO;
    }
    
    //if the rCode is 1, that means that the resource request was cancelled by
    //a call to destroy the resources, and so return YES if that's the case.
    if([rCode isEqualToString:@"0"]) {
    [gnarly_resourceRequests removeObjectForKey:key];
    return NO;
    } else {
    [gnarly_resourceRequests removeObjectForKey:key];
    return YES;
    }
    
}
- (BOOL) resourceRequests_checkResourceRequestCancelationOrLoadingForKeyForGSurfaceResourceManager:(NSString *)key {
    
    NSString *rCode = (NSString *)[gnarly_resourceRequests objectForKey:key];
    
    //if the request is absent, that means that the request was previously completed
    //and the destruction of resources can continue like usual.
    if(!rCode) {
    return NO;
    }
    
//else, the resources are either still loading, or they are still loading and have since been canceled.
//the GSurfaceResourceManager will want to know.
return YES;
}


//////////////////////
//                  //
//  sound/textures  //
//                  //
//////////////////////





/**
 * get the textures and sprite maps with convenient keys.
 * also returns the cached texture and sprite maps.
 *
 */
- (GAtlas *) getAtlas:(NSString *)key {

_cachedAtlas = [gnarly_cachedAtlases objectForKey:key];

    if(_cachedAtlas) {
    return _cachedAtlas;
    } else {
    NSAssert(YES,@"Error: GSurface: getAtlas: there is no atals for key: %@",key);
    return nil;
    }

}
- (BOOL) didFirstAtlasLoad {
return _firstAtlasLoaded;
}


/**
 * add a new xml document to the surface.
 *
 */
- (void) addXML:(CXMLDocument *)doc withKey:(NSString *)key {

    if(![gnarly_cachedXML objectForKey:key]) {
    //log the document in the dictionary.
    [gnarly_cachedXML setObject:doc forKey:key];
    //release it, because we only want a single reference retained in the dictionary.
    //when the dictionary releases, the data will release automatically.
    [doc release];
    } else {
    NSLog(@"Error: GSurface: addXML: there is already data for key '%@%@",key,@"'. Use a different key");
    }

}



/**
 * add a texture and a sprite map to the mix. Make sure you have to know what the indexes are.
 * returns the index of the objects.
 *
 */
- (void) addTexture:(NSString *)texture andMap:(NSString *)map withKey:(NSString *)key {
    
//create the texture and map.
GTexture *tex = [GPNGTexture getTexture:texture];
    
//set the class properties so that the inited sprite map will have
//the texture width and height available to it from birth. this way,
//it can cache arithmetic calculations in the frame array.
[GSpriteMap setTexWidth:(int)tex.textureWidth andHeight:(int)tex.textureHeight];
    
    
//Class spmapClass = NSClassFromString(map);
//create the sprite map.
GSpriteMap *mp = [[NSClassFromString(map) alloc] init];
//GSpriteMap *mp = [[spmapClass alloc] init];
    
    //NSLog(@"    GSurface: addTexture: mp: %p",mp);
    
    if (!mp) {
    [NSException raise:@"Error" format:@"GSurface: addTexture:andMap:withKey: -> no class exists by name ###%@%@",map,@"###"];
    } else {
        
    //create an atlas object.
    GAtlas *atlas = [[GAtlas alloc] initTexture:tex andMap:mp];
        
    //NSLog(@"    GSurface: addTexture: atlas: %p",atlas);
    
        if(!_firstAtlasLoaded) {
        _firstAtlasLoaded = YES;
        _firstAtlas = atlas;
        }
        
    //set the cached texture regardless.
    _cachedAtlas = atlas;
        
    //    NSLog(@"    GSurface: _cachedAtlas: %p",_cachedAtlas);
    //    NSLog(@"    GSurface: _firstAtlas: %p",_firstAtlas);
        
    //install the atlas in the dictionary.
    [gnarly_cachedAtlases setObject:atlas forKey:key];
        
    //    NSLog(@"    GSurface: addTexture: gnarly_cachedAtlases: %p",gnarly_cachedAtlases);
    //    NSLog(@"    GSurface: addTexture: atlas: %p",atlas);
    //    NSLog(@"    GSurface: addTexture: tex: %p",tex);
    //    NSLog(@"    GSurface: addTexture: [gnarly_cachedAtlases objectForKey:key]: %p",[gnarly_cachedAtlases objectForKey:key]);
    
    //we only want a single surviving reference to the atlas, and that's in
    //the dictionary. when that dies, all the texture and map data goes 'down with the ship'.
    [atlas release];
    
    //we only want a single surviving reference to the texture, which is in the atlas.
    //so when it dies, the texture dies.
    [tex release];
    
    //same for the sprite map.
    [mp release];
    
    }
}


/////////////
//         //
//  Events //
//         //
/////////////

- (BOOL) areEventsInPlay {
    return eventsInPlay;
}



/////////////////
//             //
//  Rendering  //
//             //
/////////////////


/**
 * here is the main game-loop. open and close a session of OpenGL rendering,
 * render the objects, process the touches, and perform destruction of ejected objects.
 *
 *
 */
- (void) renderScene {
    
   // NSLog(@"renderScene!");
    
    //if(_smoothnessDate) {
    //NSTimeInterval diff = -[_smoothnessDate timeIntervalSinceNow];
    //temporalScale = diff/0.033;
    //NSLog(@"temporal-scale: %f%@%f",temporalScale,@" time diff: ",diff);
    //[_smoothnessDate release];
    //}
    
    //if(_smoothnessDate) {
    //NSTimeInterval diff = -[_smoothnessDate timeIntervalSinceNow];
    //temporalScale = diff/0.033;
    //NSLog(@"temporal-scale: %f%@%f",temporalScale,@" time diff: ",diff);
    //[_smoothnessDate release];
    //}
    
    
    
    /*
    if(_smoothnessDate != nil) {
        NSTimeInterval diff = [_smoothnessDate timeIntervalSinceNow];
        temporalScale = diff/0.033;
        [_smoothnessDate release];
        _smoothnessDate = nil;
        NSLog(@"temporal-scale: %f%@%f",temporalScale,@" time diff: ",diff);
    } else {
    temporalScale = 1;
    }*/
    
    //log the frames-per-second rendered if we need to.
    //#if gDebug_LogFPSInfo == gYES
    //NSLog(@"FPS estimate: %f",[[Gnar ly] endClockAndGetFPS]);
    //#endif

    //start the OpenGL calls.
    [EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClear(GL_COLOR_BUFFER_BIT);
    
    //thank you http://gamedev.stackexchange.com/questions/21199/why-do-my-sprites-have-a-dark-shadow-line-frame-surrounding-the-texture
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);     
    glEnable(GL_BLEND);
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY); 
    glEnable(GL_TEXTURE_2D);
    

    //start off the render chain.
    GRenderable *tmp = (GRenderable *)firstChild;
    GRenderable *nxt;
	   
		 //if there events which need handling, then handle them.
        if(eventsInPlay == YES) {
        //eventsInPlay = NO;
            
            //calculate the affine values and perform
            //the touch test on each object.
            while(tmp) {
            [tmp calcAffine];
            [tmp testTouchDown];
            nxt = [tmp render];
            tmp = nxt;
            }
            
        //run the touch chain backward so that touches get dispatched in the correct z-order.
        //What this chain does is loop *backward* through the links and dispatch the event for
        //each one. The *backwards-ness* is to preserve the expected behavior for z-ordering. If an display-object covers another
        //display object on the screen the expected behavior is that it will shield objects underneath it from touches.
        [touchChain loopBackward];
        
        //at this point there's going to be touches in the touch-chain
        //that have ended. all of the machinery has cranked on these touches
        //so we're going to remove any that have ended.
        [touchesStartedChain setToCullTouchEnded];
        [touchesStartedChain loopForward];

        eventsInPlay = NO;
		} 
        
		//if the program is just chugging away and there are no touches, then just crank on the
        //rendering of the box objects.
		else {
            
		    //no events, so just blast through the render chain like a bat out of hell.	
			while(tmp) {
            tmp = [tmp render];
			}
				
		}
        
    //run the tweens here.
    [animator runTweens];
    
    
    //this is a complicated conditional, and it's a pretty critical one, so here's how this thing works:
    //whenever a GNode object/hierarchy is destroyed, it gets placed on the kill-chain defined by GNode's
    //prevKill,nextKill properties. This conditional grabs the first element from the kill chain, destroys each
    //one of its descendants, and then moves onto the next element in the kill-chain. The firstKill exists
    //if there are any objects that need deletion. there is coordination with the addToKillChain function
    //so that if there is no firstKill assignment, the assignment is made.
    
    //in the context of this conditional, we call the descendants of a kill-chain element 'inner-kill' elements,
    //as opposed to the kill-chain elements, which are implicitly 'outer-kill' elements. You'll notice that
    //we do not call flat-destroy on any of the kill-chain (outer-kill) elements directly. We call 
    //flat-destroy them on the 'inner-kill' chained elements, and because each firstKill is also a 
    //firstInnerKill, they are destroyed anyway.
    //
    //The whole point of this exercise is so that no matter how many objects suddenly get flagged for destruction,
    //**only one GRenderable object is ever destroyed during any iteration of the render function.** Oh, and,
    //'Why not just delete the object immediately?' We want to avoid this terrible dilemma of having to worry about
    //destuction calls inside an object's overriden render function. we don't want it to break halfway through.
    //we want the darn thing to start spewing horrible 'bad access' errors halfway through its render task.
    
    //////////////////////////////////////////////
    //Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
    //commenting this out
    /*
    if(firstKill) {
    nextKill = firstKill.nextKill;
        if(nextKill != firstKill) {
        [firstKill deepDestroy];
        firstKill = nextKill;
        } else {
        [firstKill deepDestroy];
        firstKill = nil;
        }
    }*/
    //In favor of this:
    int numDestroyed = 0;
    if(firstKill) {
        GNode *nextK = firstKill;
        while (nextK) {
        numDestroyed++;
        GNode *n = nextK.nextKill;
        [nextK deepDestroy];
        nextK = n;
        }
    firstKill = nil;
    }
    //////////////////////////////////////////////
    
//end the OpenGL calls. 
glDisable(GL_TEXTURE_2D);
glEnableClientState(GL_TEXTURE_COORD_ARRAY);

glDisable(GL_BLEND);
glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    
//    // check OpenGL error
//    GLenum err;
//    while ((err = glGetError()) != GL_NO_ERROR) {
//        NSLog(@"Err! %d",err);
//    }

//frame is ready to render.
[context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
//#if gDebug_LogFPSInfo == gYES
//    NSLog(@"FPS estimate: %f",[[Gnar ly] endClockAndGetFPS]);
//#endif
    
    //log the frames-per-second rendered if we need to.
    //#if gDebug_LogFPSInfo == gYES
    //[[Gnar ly ] startClock];
    //#endif
    
    
    /*
    if(_smoothnessDate != nil) {
    NSTimeInterval diff = -[_smoothnessDate timeIntervalSinceNow];
    temporalScale = diff/0.033;
    [_smoothnessDate release];
    _smoothnessDate = nil;
    } else {
    temporalScale = 1;
    }*/
    
    //start the smoothness.
    //_smoothnessDate = [NSDate date];
    //[_smoothnessDate retain];
         
}

//////////////
//          //
//  Chains  //
//          //
//////////////

- (float) getTimeIntervalScale {
    
    //if(_smoothnessDate != nil) {
    //NSTimeInterval diff = fabsf([_smoothnessDate timeIntervalSinceNow]);
    //temporalScale = 1.2*(diff/0.033);
    //[_smoothnessDate release];
    //NSLog(@"temporal-scale: %f%@%f",temporalScale,@" time diff: ",diff);
    //_smoothnessDate = nil;
    //return temporalScale;
    //}
    
return 1;
}


/**
 * Manage the first and last children. They are handy references to have around.
 *
 */
- (void) assignFirstChild:(GNode *)first {

    if(firstChild) {
    firstChild.isFirst = NO;
    }
    
firstChild = first;
first.isFirst = YES;

}
- (void) assignLastChild:(GNode *)last {
	
    if(lastChild) {
    lastChild.isLast = NO;
    }
    
lastChild = last;
last.isLast = YES;

}


/**
 * manage the kill chain. This is for the chain of objects on GSurface which
 * get killed at the end of each render loop instead of immediately.
 *
 */
- (void) addToKillChain:(GNode *)node {
    
    if(!firstKill) {
    firstKill = node;
    lastKill = node;
        
    /////////////////////////////////////////////
    //Memory_Managment_Problem_a82ffd38-6000-11e5-9d70-feff819cdc9f
    //Commenting these out. Appears to be dead code.
    //firstInnerKill = node;
    //killBound = [node getLast];
    /////////////////////////////////////////////
        
    } else {
    lastKill.nextKill = node;
    node.prevKill = lastKill;
    lastKill = node;
    }
    
}

- (void) removeFromKillChain:(GNode *)node {
    if(node.prevKill) {
    node.prevKill.nextKill = node.nextKill;
    } else {
    firstKill = node.nextKill;
    }
    if(node.nextKill) {
    node.nextKill.prevKill = node.prevKill;
    } else {
    lastKill = node.prevKill;
    }
    
node.prevKill = nil;
node.nextKill = nil;
}



/**
 * manage the cache chain. this is the chain of objects on GSurface
 * which have been created, but are not currently on the render list.
 *
 */
- (void) addToCacheChain:(GNode *)node {
node.isCached = YES;

    if(!firstCache) {
    firstCache = node;
    lastCache = node;
    } else {
    [lastCache setNextCacheRef:node];
    [node setPrevCacheRef:lastCache];
    lastCache = node;
    }

}


- (void) removeFromCacheChain:(GNode *)node {
    
    //NSLog(@"GSurface: removeFromCacheChain: %@",node);
    
node.isCached = NO;
GNode *nextCache = node.nextCache;
GNode *prevCache = node.prevCache;
    
    if(prevCache) {
    [prevCache setNextCacheRef:nextCache];
    } else {
    firstCache = nextCache;
    }
    if(nextCache) {
    [nextCache setPrevCacheRef:prevCache];
    } else {
    lastCache = prevCache;
    }

[node setPrevCacheRef:nil];
[node setNextCacheRef:nil];
}



/**
 * add or remove a child from the chain of prevSibling, nextSibling references.
 * 
 * #NOTE# This is different from the prev/next reference chain. The latter is designed
 * so that the entire tree structure can be read out in a single, non-recursive loop
 * the the GSurface level. the former is designed to give you easy access to sets 
 * of ancestors for batch processes.
 *
 */
- (void) addToSiblingChain:(GNode *)child withPrev:(GNode *)prv andNext:(GNode *)nxt {

    //do not presume that the prevSibling/nextSiblings exist.
    if(prv) {
    [prv setNextRef:child];
    }
    
    if(nxt) {
    [nxt setPrevRef:child];
    }

[child setPrevRef:prv];
[child setNextRef:nxt];

}

//Armstrong --
//713 745 6605

/**
 * remove the child from the 
 *
 *
 */
- (void) removeFromSiblingChain:(GNode *)child {

    if(child.prevSibling) {
    [child.prevSibling setNextRef:child.nextSibling];
    }
    if(child.nextSibling) {
    [child.nextSibling setPrevRef:child.prevSibling];
    }
    
[child setPrevRef:nil];
[child setNextRef:nil];
}



/**
 * reset the preloader to nil.
 *
 */
- (void) preloaderIsDestroyed {
gnarly_preloadView = nil;
}


////////////////
//            //
//  Clean up  //
//            //
////////////////


/**
 * delegate function. give the surface a chance to clean up arrays and whatnot. This is so that you don't
 * have to override the destroy function. This is the very last thing that gets called before the surface
 * absorbs the final release message and deallocates.
 *
 */
- (void) releaseResources {
//take no action.
}


/**
 * if the surface gets destroyed while there are background processes running, then
 * we have to wait until each of those threads have completed, and then continue
 * on with the destruction. this function is called when the threads are finished
 * and we are free to destroy.
 *
 */
- (void) backgroundThreadsAreDoneSoCompleteDestruction {

    if(isThreadsCompleteUnglued == NO) {
    
    //guarantees that this function will never be called again.
    isThreadsCompleteUnglued = YES;

    //set the context so that deleting the textures will not 
    //interfere with any other rendering surfaces.
    [EAGLContext setCurrentContext:context];

    //get rid of the framebuffer. it will cause these weird
    //8cd6 errors later on when you try to create a new surface.
    //and remember- you have to do these things inside a context
    //or it won't 'count'.
    [self destroyFramebuffer];

    //release all of the resource keys that are
    //associated with this surface.
    [gnarly_keysOfResourceLists release];

    //clear the rendering buffer.
    //glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    glClear(GL_COLOR_BUFFER_BIT);
        
    //2014-02-06 moving this in here because it needs there
    //to be a valid context when the texture data gets released
    //or it causes memory leaks. Strange- I could have sworn this
    //thing was doing that already.
    //destroy the texture data and map data.
    [gnarly_cachedAtlases release];

        //get rid of the context.
        if([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
        }
        
    //get rid of this.
    [context release];
    context = nil;

    //tell Gnarly to destroy the sounds and music that
    //are explicitly associated with thie surface.
    [[Gnar ly] destroySoundsAndMusicForSurface:self];

    //destroy the cached xml data.
    [gnarly_cachedXML release];
    
    //run the timer one more frame, at the end of which it's going to loop
    //through and destroy all of our GRenderable objects wherever they are.
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:animInterval target:self selector:@selector(safeDestroy) userInfo:nil repeats:NO];
    }

}




- (void) safeDestroy {

//get rid of the destroy timer. the animation should already be stopped at this point.
[animationTimer invalidate];
animationTimer = nil;
//[self stopAnimation];

//Every GRenderable object belongs to one of three chains, and these
//chains are mutually exclusive.
//1. The render chain of objects that are currently getting rendered.
//2. The cache chain of objects that are not getting rendered, but are on the sidelines.
//3. The kill chain of objects that have been marked for deletion.
//At the time this function fires, any of these chains may be populated, so
//each chain must be destroyed in turn.

//Destroy every object on the render chain.
GNode *child0 = firstChild;
GNode *child1;
    while(child0) {
    child1 = child0.nextSibling;
    [child0 deepDestroy];
    child0 = child1;
    }
    
 
//Destroy every object on the cache chain.
GNode *childCache0 = firstCache;
GNode *childCache1;
    while(childCache0) {
    childCache1 = childCache0.nextCache;
    [childCache0 deepDestroy];
    childCache0 = childCache1;
    }


//Destroy every object on the kill chain.
GNode *childKill0 = firstKill;
GNode *childKill1;
    while(childKill0) {
    childKill1 = childKill0.nextKill;
        if(childKill0 != childKill1) {
        [childKill0 deepDestroy];
        childKill0 = childKill1;
        } else {
        [childKill0 deepDestroy];
        childKill0 = nil;
        }
    }
    
    
//make sure that the dictionary in Gnarly is not holding onto any references to this thing.
[[Gnar ly] removeSurfaceFromGnarlyDictionary:self];
	
//release the safety retention from the initiailization.
[self release];

//get rid of the listeners.
[listeners release];

//TODO- this might be a pressure point.
//destroy and release the default parent.
[defaultParent releaseResources];

//destroy the animation engine.
[animator destroyAllTweens];
[animator release];
    
//get rid of the chain container for the end-of-frame z-order events.
[touchChain destroy];

//get rid of the chain container for the touches
[touchesStartedChain destroy];
    
    
    //destroy resource managers here. they don't need to destroy their own textures, because the textures
    //were all destroyed previously, and this function can only fire after all background threads for this
    //rendering surface have resolved. So it should be just fine do destroy this right here.
    [resourceManagers removeAllObjects];
    [resourceManagers release];

//set the accelerometer delegate to nil.
//#if gAccelerometerEnabled == gYES
//[UIAccelerometer sharedAccelerometer].delegate = nil;
//#endif
    
//get rid of the resource requests. this safeDestroy fires only
//after all background threads have finished, so no-one is going
//to try to access this dictionary at this point.
[gnarly_resourceRequests release];
    
//let the surface release it's resources.
[self releaseResources];

//do the release of the initial creation retain count. that way, the only method you need to
//call to destroy a GSurface object is destroy.
[self release];

}





///////////////
//           //
//  A  P  I  //
//           //
///////////////


/**
 * if you're curious about the asynchronous progress, here is
 * a read-only accessor.
 *
 */
- (void) setAsynchProgress:(float)prog {
//take no action
}
- (float) asynchProgress {
return gnarly_asynchProgress;
}


/**
 * update the rendering context to this object's context.
 *
 */
- (void) makeContextCurrent {
    if(context) {
    [EAGLContext setCurrentContext:context];
    }
}



/**
 * set the backing color and opacity. rejiggers the opaque property within it.
 *
 */
- (void) backingColor:(int)hex andOpacity:(float)op {
if(op != 1) {
self.opaque = NO;
} else {
self.opaque = YES;
}
    
	float r = ((float)((hex & 0xFF0000) >> 16))/255.0;
	float g = ((float)((hex & 0xFF00) >> 8))/255.0;
	float b = ((float)(hex & 0xFF))/255.0;
    
glClearColor(r, g, b, op);    
}



/**
 * set the backing to visible/invisible.
 *
 */
- (BOOL) opaque {
    return self.layer.opaque;
}
- (void) setOpaque:(BOOL)truth {
    self.layer.opaque = truth;
}




/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 *
 * override this method to draw Box objects and Sprites to the view. The render loop is
 * cranking by the time this method is called. Boxes and Sprites will render immediately.
 * 
 * You don't call this method ever- Gnarly will call it for you when the time comes. you are free
 * to use whatever resources inside that you specified in the resource list which you 
 * used to init this surface.
 *
 */
- (void) gnarlySaysBuildSurface {}


/**
 * this is the function that fires when the application enters the background. the purpose
 * is to give the surface a change to save the user data.
 *
 */
- (void) gnarlySaysSaveUserData {}


/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 * This function will fire immediately before gnarlySaysBuildSurface, in the event that
 * we're in an iPhone environment, and give us a chance to do some configuration.
 *
 */
- (void) gnarlySays_iPhone {}

/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 * This function will fire immediately before gnarlySaysBuildSurface, in the event that
 * we're in an iPad environment, and give us a chance to do some configuration.
 *
 */
- (void) gnarlySays_iPad {}

/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 * This function will fire immediately before gnarlySaysBuildSurface, in the event that
 * we're in an iPod Touch environment, and give us a chance to do some configuration.
 *
 */
- (void) gnarlySays_iPodTouch {}

/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 * This function will fire immediately before gnarlySaysBuildSurface, in the event that
 * we're in an iPad Mini environment, and give us a chance to do some configuration.
 *
 */
- (void) gnarlySays_iPadMini {}

/**
 * If this thing has a preloading sprite, then you can make some additional
 * configurations for it here. This function fires after the sprite
 * is wound down and it will dies some time after this fuction fires.
 *
 */
- (void) gnarlySaysConfigureForEnd {}

/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 *
 * override this method to start any sounds that need to immediately play in this view,
 * such as background music. function is fired when the preload view is ready to go away,
 * which can happen after the gnarlySaysBuildSurface function is called, depending on when the preloadView
 * fires the okTognarlySaysBuildSurface to this object.
 *
 * You don't call this method ever- Gnarly will call it for you when the time comes. you are free
 * to use whatever resources inside that you specified in the resource list which you 
 * used to init this surface.
 */
- (void) gnarlySaysStartSounds {}



/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 *
 * if the replacement surface is ready for action and all of its resources are done loading, then 
 * this function will get called. the purpose of this function is to trigger whatever kind of 
 * outro animations need to happen in the flow of the game. you can do whatever you like, but at the
 * end you have to call callGnarlyToContinueTransaction on the surface.
 *
 * If you don't have a fancy outro animation, just call [self callGnarlyToContinueTransaction]
 * and it will replace this surface with the new surface.
 *
 */
- (void) gnarlySaysWindDownSurface {
[[Gnar ly] windDownFinishedContinueTransaction:self];
}



/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 *
 * the loading sprite was created, so any extra configuring of the loading sprite,
 * like position or whatever, should be done here. the preloading sprite is accessible
 * with the private variable, 'preloadSprite'.
 *
 * do not attempt to add the preload sprite to any display list. Gnarly will handle that.
 *
 * the loading sprite is fire-and-forget, and once it is rendering it will
 * do everything it needs to.
 *
 */
- (void) gnarlySaysStartLoadingSprite:(GLoadSprite *)loader withData:(GSurfaceData)data {}


/**
 * delegate function. Called by the Gnarly system. You don't ever call this function.
 *
 * The loading sprite has done its job, and it has fired the windDownCompleteToContinueTransaction
 * message back to gnarly. Gnarly then calls this function, and the job of this function is to
 * either deestroy it or move it off screen or perform whatever operation you want on the loading
 * sprite. Perhaps another animation.
 * This fires right before the gnarlySaysWindDownSurface function fires.
 *
 */
- (void) gnarlySaysEndLoadingSprite:(GLoadSprite *)loader {}



/**
 * pause/unpause all the music associated with this surface.
 *
 */
- (void) pauseAllMusic {

    int len = (int) gnarly_musicKeysToManage.count;
    for(int h=0; h<len; h++) {
    [[GAudio sharedSoundManager] pauseMusicWithKey:[gnarly_musicKeysToManage objectAtIndex:h]];
    }

}
- (void) pauseAllSounds {
   // NSLog(@"pauseAllSounds");

    int len = (int) gnarly_soundKeysToManage.count;
    for(int h=0; h<len; h++) {
    [[GAudio sharedSoundManager] pauseSoundWithKey:[gnarly_soundKeysToManage objectAtIndex:h]];
    }

}
- (void) resumeAllMusic {
    
    int len = (int) gnarly_musicKeysToManage.count;
    for(int h=0; h<len; h++) {
    [[GAudio sharedSoundManager] resumeMusicWithKey:[gnarly_musicKeysToManage objectAtIndex:h]];
    }

}
- (void) resumeAllSounds {

    int len = (int) gnarly_soundKeysToManage.count;
    for(int h=0; h<len; h++) {
    [[GAudio sharedSoundManager] resumeSoundWithKey:[gnarly_soundKeysToManage objectAtIndex:h]];
    }

}




/**
 * pause the game, create the overlay and add the overlay above this game surface.
 *
 */
- (void) pauseGameAndShowOverlay {
    
    //NSLog(@"Gnarly: pauseGameAndShowOverlay.");
    
    //if(animationTimer != nil) {
        
        //NSLog(@"Gnarly: pauseGameAndShowOverlay. getting this far at least.");
        
    [self stopAnimation];
    
    gnarly_doesOverlayScreenExist = YES;
    
    [[GAudio sharedSoundManager] pauseCommonMusic];
    [[GAudio sharedSoundManager] pauseCommonSounds];
    [self pauseAllMusic];
    [self pauseAllSounds];

    [GOverlayView shouldOverlayZapToMainState:NO];
    
    [[Gnar ly] addNewOverlayView:gnarly_pauseClassName withResourceKey:gnarly_pauseResourceKey aboveMainSurface:self];
    //}
    
}



/**
 * pause the game, create the overlay above this surface, and set the zapToMainState of the
 * overlay so that it knows to skip the intro animation and just show its post intro configuration.
 * http://gmc.yoyogames.com/index.php?showtopic=462301
 */
- (void) pauseGameAndZapToOverlay {
    
    if(gnarly_doesOverlayScreenExist == NO) {
    
    gnarly_doesOverlayScreenExist = YES;
    [self stopAnimation];
    
    [[GAudio sharedSoundManager] pauseCommonMusic];
    [[GAudio sharedSoundManager] pauseCommonSounds];
    [self pauseAllMusic];
    [self pauseAllSounds];
        
    [GOverlayView shouldOverlayZapToMainState:YES];
    [[Gnar ly] addNewOverlayView:gnarly_pauseClassName withResourceKey:gnarly_pauseResourceKey aboveMainSurface:self];
    [GOverlayView shouldOverlayZapToMainState:NO];
    }

}


/***
 * start the animation.
 *
 */

- (void)startAnimation {
    if(gnarly_resourcesLoaded == YES) {
    
        /*
        if(animationTimer == nil) {
        animationTimer = [NSTimer
                          scheduledTimerWithTimeInterval:animInterval
                          target:self
                          selector:@selector(renderScene)
                          userInfo:nil
                          repeats:YES];
        }*/
        
        if(_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateWithDisplayLink:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [_displayLink retain];
        }
        
    }
}

//thank you- the following posts. I think CADisplay link is the way to go.
//http://www.bigspaceship.com/ios-animation-intervals/
//http://gamedev.stackexchange.com/questions/2381/how-can-i-improve-the-smoothness-of-a-2d-side-scrolling-iphone-game
- (void) updateWithDisplayLink:(CADisplayLink *)sender; {
	double currentTime = [_displayLink timestamp];
	double renderTime = currentTime - frameTimestamp;
    
        if(renderTime >= 0.033) {
        frameTimestamp = currentTime;
        [self renderScene];
        //NSLog(@"renderTime: %f",renderTime);
        }
    

}





/***
 * stop the animation.
 *
 *
 */
- (void)stopAnimation {
    
    if(gnarly_resourcesLoaded == YES) {
    /*    if(animationTimer != nil) {
        [animationTimer invalidate];
        animationTimer = nil;
        }
    */
        
        if(_displayLink != nil) {
        [_displayLink invalidate];
        _displayLink = nil;
        }
	}
}


/***
 * set the anomation interval. 
 *
 *
 */
- (void)setAnimationInterval:(NSTimeInterval)interval {
    animInterval = interval;
	[self stopAnimation];
	[self startAnimation];
}
- (NSTimeInterval) animationInterval {
    return animInterval;
}




/**
 * insert a child into a specific position of the display list. this is safe. index can be negative.
 * will fail over to addChild. 
 * 
 * this thing will put the child at the index. If you specify 0, it will be at the 0th position
 * when this function is through.
 *
 */
- (void) addChild:(GNode *)child at:(int)index {

    if(child.isUnglued == NO) {

    //grab the reference node.
    GNode *ref = [self getChildAt:index];

        //if the reference exists (it's not guaranteed), then 
        //use the addChild:before: function.
        if(ref) {
        [self addChild:child before:ref];
        } else {
        [self addChild:child];
        }
    
    }

}



/**
 * add a child after the reference node. if ref is nil, then this
 * function will fail over to addChild. if ref does not belong
 * to this object, then this function will take no action.
 *
 */
- (void) addChild:(GNode *)child after:(GNode *)ref {

    if(child.isUnglued == NO) {

        //if the ref exists (it's not guaranteed),
        if(ref) {
        
            //filter out nonsense.
            if(ref.isRootChild == YES) {
            child.isRootChild = YES;
            
                //if we're supposed to just add it to the back,
                //then we can use the addChild function.
                if(ref.isLast) {
                [self addChild:child];
                } else {
                
                    //if the object is on the display list,
                    //reparent it.
                    if(child.parent) {
                    [child removeFromParent];
                    }
                
                //uncache this
                [self removeFromCacheChain:child];
                
                //perform the handshake.
                GRenderable *childLast = [child getLast];
                GRenderable *refLast = [ref getLast];
                GRenderable *refNext = refLast.next;
                
                childLast.next = refNext;
                    if(refNext) {
                    refNext.prev = childLast;
                    }
                
                refLast.next = child;
                child.prev = refLast;
                
                //add this guy to the sibling chain.
                [self addToSiblingChain:child withPrev:ref andNext:ref.nextSibling];
                
                //increment.
                numChildren++;
            
                }
        
            } 
        
        } else {
        [self addChild:child];
        }
    
    }

}



/**
 * add a child before the reference node. if ref is nil, then this
 * function will fail over to addChild. if ref does not belong
 * to this object, then this function will take no action.
 *
 */
- (void) addChild:(GNode *)child before:(GNode *)ref {

     if(child.isUnglued == NO) {

        //the reference child is not guaranteed to exist.
        if(ref) {
        
            //filter out nonsense.
            if(ref.isRootChild == YES) {
            child.isRootChild = YES;
            
                //if the object is on the display list,
                //reparent it.
                if(child.parent) {
                [child removeFromParent];
                }
                
            //uncache this
            [self removeFromCacheChain:child];

                //manage the firstChild thing.
                if(ref.isFirst == YES) {
                ref.isFirst = NO;
                child.isFirst = YES;
                firstChild = child;
                }
            
            //perform the handshake.
            GRenderable *childLast = [child getLast];
            GRenderable *refPrev = ref.prev;
            
            childLast.next = ref;
            ref.prev = childLast;

            child.prev = refPrev;
                if(refPrev) {
                refPrev.next = child;
                }
            
            //add this guy to the sibling chain.
            [self addToSiblingChain:child withPrev:ref.prevSibling andNext:ref];
                
            //increment.
            numChildren++;
        
            }
        
        } else {
        [self addChild:child];
        }
    
    }

}




/**
 * super simple. just add this guy before the first child.
 * "addInBack" refers to the z-order. if you use this, the child
 * will appear behind all the elements, at the bottom of the z-stack.
 *
 */
- (void) addInBack:(GNode *)child {
[self addChild:child before:firstChild];
}



//- (void) describe


/**
 * add a child to the display list. if it's already on the display list, then it
 * will get swapped to the front. if it's already on a different parent, then it
 * will get reparented to this object.
 *
 */
- (void) addChild:(GNode *)child {
    
    //NSLog(@"GSurface: addChild: %@%@%@",child.name,@"   to self: ",self);
    
    if(child) {
        child.isRootChild = YES;
        
	    //if the object is on the display list,
	    //reparent it.
		if(child.parent) {
        [child removeFromParent];
		}
        
        //uncache this
        [self removeFromCacheChain:child];
        
        //set the parent
        [child setParentRef:defaultParent];
        
        //increment.
        numChildren++;
        
	    //handshake. introduce the ends of the chain
        //so they are connected at the next iteration of the loop.
		if(numChildren != 1) {
            GRenderable *l = [lastChild getLast];
            child.prev = l;
            l.next = child;

            [self addToSiblingChain:child withPrev:lastChild andNext:nil];
		} else {
            [self assignFirstChild:child];
            [self addToSiblingChain:child withPrev:nil andNext:nil];
		}
		
    [self assignLastChild:child];
        
    //NEW this is the last child of the whole scene, so there is no next. enforce this.
    [child getLast].next = nil;
    }
    
}




/**
 * remove a child from the display list.
 *
 *
 */
- (void) removeChild:(GNode *)child {

	    //take no action if the object
	    //does not belong to us here.
		if(child.isRootChild == YES && child.isUnglued == NO) {
        
        child.isRootChild = NO;
        
        //cache this
        [self addToCacheChain:child];
    
		//set to null.
        [child setParentRef:nil];
		
		    //if this is the only child on the object.
			if(numChildren == 1) {
			
				//update this state.
				if(child.isLast == YES) {
				child.isLast = NO;		
				}
				
            //set these guys to nil, because this is the last child
            //to get removed, and so they need to reset.
            lastChild = nil;
            firstChild = nil;
			
		    } else {
		    
		    	//update the lastChild, firstChild references,
                //and manage the properties.
				if(child.isLast == YES) {
				child.isLast = NO;
                lastChild = child.prevSibling;
				lastChild.isLast = YES;
				}
                if(child.isFirst == YES) {
                child.isFirst = NO;
                firstChild = child.nextSibling;
                firstChild.isFirst = YES;
                }
		    
		    //we're going to take the neighbors and introduce
		    //them to each other. that cuts ob right out of the
		    //display list. it can get back on later, or it can die.
            GRenderable *l2 = [child getLast].next;
		    GRenderable *p2 = child.prev;
   
		    	if(l2) {
		    	l2.prev = p2;
		    	}
		    	
                if(p2) {
                p2.next = l2;
                }
		    }
            
        //remove from the prevSibling/nextSibling reference chain.
        [self removeFromSiblingChain:child];
        
        //DEBUG///////////////////////////////////////////////////////////
        //[child setPrevNextAreUpToDate:NO];
        //[child getLast].next = nil; //HERE IS THE THING THAT MADE ALL THE DIFFERENCE.
            /*
             //FROM GNODE. This should be implemented.
             //set this so that the child knows that the its prev/next
             //properties are NOT up-to-date with the display list.
             [child setPrevNextAreUpToDate:NO];
             */
        //GNode *wtf2 = (GNode *)[child getLast].next;  //DEBUG
        //NSLog(@"Hey whats this here? [child getLast].next: %@",wtf2.name);
        //////////////////////////////////////////////////////////////////
          
		//decrement.
		numChildren--;
		} 

}



/**
 * get the [index]th child of this object. You'll notice that there aren't any
 * arrays of children getting stored in this code. you have to use a loop
 * to access a child at a particular index.
 *
 * you can use negative indices in here- it will wrap around to the back
 * of the children chain. -1 will get the last child, -2 the second-to-last, etc etc.
 *
 */
- (GNode *) getChildAt:(int)index {

GNode *nd = nil;
   
    //filter out nonsense. 
    if(isnan(index) == NO) {
    int targ = index;

        //convert to a positive integer.
        if(index < 0) {
        targ = numChildren + index; 
        }
        
        //filter out nonsense.
        if(targ >= 0 && targ < numChildren) {
        
        int ind = 0;
        nd = firstChild;
        NSAssert((!nd),@"GNode -> getChildAt: Something has gone wrong. code 0.");
        
        
            //loop, and see throw an error if anything crazy happens.
            while(ind < targ) {
            nd = nd.nextSibling;
            NSAssert((!nd),@"GNode -> getChildAt: Something has gone wrong. code 1. index: %d",ind);
            ind++;
            }
        }
    
    }
    
return nd;
}


/**
 * a delegate method to get a single touch point which
 * was not captured by any game object.
 *
 */
- (void) freeTouchPoint:(CGPoint)gamePoint {}



/**
 * add/remove event listeners on the root object. You should not nest GLRoots inside other GLRoots. The events will
 * not bubble, and there is no flatEvents method for GSurface.
 *
 */
- (void) addEL:(NSString *)evt withCallback:(NSString *)cllbck andObserver:(id)obs {

 GListener *lst = [listeners objectForKey:evt];
 
	if(lst) {
	NSLog(@"Error: GSurface -> addEL: you can't double register %@%@",evt,@" for this sprite.");
	} else {
	
	numLstnrs++;
    
    SEL sel = NSSelectorFromString([cllbck stringByAppendingString:@":"]);
        if(!sel) {
        NSAssert(YES, @"Error: GSurface --> addEL:withCallback:andObserver --> callback %@%@",cllbck,@" failed.");
        }
	  
    GListener *tmp = [[GListener alloc] initWithCallback:sel andObserver:obs];
    [listeners setObject:tmp forKey:evt];
	//send a release message here because we want the only extant reference 
	//to the listener to be on the dictionary.
	[tmp release];
	
	}

}
- (void) removeEL:(NSString *)evt {
 
GListener *lst = [listeners objectForKey:evt];
 
 	if(!lst) {
	NSLog(@"Error: GSurface -> removeEL: listener for event %@%@",evt,@" does not exist on this sprite.");
	} else {
		
	numLstnrs--;
    
	[listeners removeObjectForKey:evt];
    //need no release message here because the only reference was in the dictionary.
	}

}


/**
 * dispatch an event.
 *
 */
- (void) dispatch:(GEvent *)evt {
evt.currentTarget = self;

    if(evt.target == nil) {
    evt.target = self;
    }
   
    if(numLstnrs != 0) {
	GListener *lst = [listeners valueForKey:evt.evtCode];
		if(lst) {
        //objc_msgSend(lst.observer, lst.callback, evt);
        [lst.observer performSelector:lst.callback withObject:evt];
		} else {
        NSLog(@"Error: GSurface-> dispatch: there is no iistener defined for the event string: %@",evt.evtCode);
        }
	}
	
[evt release];

}


/**
 * get the cached XML for a key.
 *
 */
- (CXMLDocument *) getXML:(NSString *)key {
return [gnarly_cachedXML objectForKey:key];
}





////////////////////////////////
// Coordinate transformations //
////////////////////////////////



/***
  this family of functions takes care of all the transformations
  between coordinate systems. The GL system should almost
  always be totally hidden from the production-level, unless
  a developer needs to write special rendering code for a
  sprite subclass.
*/



/***
  this family of functions takes care of all the transformations
  between coordinate systems. The GL system should almost
  always be totally hidden from the production-level, unless
  a developer needs to write special rendering code for a
  sprite subclass.
*/

    CGPoint gameToView(float xCoord, float yCoord, float w, float h) {
        //if we're in landscape mode...
        CGPoint p = CGPointMake(xCoord, yCoord);
        return p;
    }

    CGPoint viewToGame(float xCoord, float yCoord, float w, float h) {
        //if we're in landscape mode...
        //float x2 = w - xCoord;
        //float y2 = h - yCoord;
        //NSLog(@"view xCoord: %f%@%f",x2,@" yCoord: ",y2);
        //CGPoint p = CGPointMake(x2,y2);
        CGPoint p = CGPointMake(w - xCoord, h - yCoord);
        return p;
    }





///////////////
// delegates //
///////////////

/**
 The life-cycle of a touch begins with this function. This is the most basic and primitive way to capture
 touches. There are analogues to this in javascript and android. 
 
 So the deal is this. In the past I've stored two touch objects from this NSSet directly on the GEventDispatcher objects.
 It was easy to tell if a touch ended because you could just compare the objects directly. I was always uncomfortable with that
 solution, but it worked well enough and I had other things to so. 
 
 Well, eventually it came out that this method was a bad idea. In particular with this rocket game where there are a whole bunch
 of touches I found that about 0.05% of the time the touch simply gets lost and the object comparison just fails. And of course that
 0.05% of the time seems to happen 60% of the time, sometimes. So basically I needed a new and totally bullet-proof way to do touch-detection.
 At this point you might ask youself, "Why all the rigamarole, Alex? Why not just use iOS' baked-in gestures?" Well, in case this detail 
 escaped your attention, this is an OpenGL game engine. When you're rendering OpenGL primitives, iOS has absolutely no idea if touches are 
 falling within those primitives or not. How could it? You're rendering those yourself. So if you want touches and gestures, you have to 
 roll that on your own.
 
 So I decided it was time to make a much better touch-detection system. It had to handle arbitrary numbers of touches, event dispatching, and
 it had to have a way to extend gestures into the mix (So Mahina Dolphin will work). A tall order. 
 
 The first layer of this is these three delegate functions: touchesBegan, touchesMoved and touchesEnded. These functions correlate the UITouch
 objects from the NSSets with a list of abstract touch object (GEventTouchObject) maintained by Gnarly. It does this by performing a double loop
 and just matching each GEventTouchObject with it's nearest UITouch and then just copying the touch coordinates from UITouch over to the 
 GEventTouchObject. When touchesMoved or touchesEnded fire, we perform the same loops, upate the touch coordinates and also update the life-cycle 
 of the GEventTouchObjects so that they'll know which events to dispatch.
 
 the whole idea of the touchesStartedChain container is that it contains abstract touch objects for all of the touches on this surface.
 each of the touch objects will be kept in correlation to the touches that the OS hands us, but we don't rely on the objects that the OS gives
 us. we don't store references to them in any way. why? because pain and suffering. first of all the references get lost from touch start to 
 touch-end. it happens often enough to be a bad thing to rely on. second, storing UITouch objects makes this code less portable.
 
 **/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
eventsInPlay = YES;

NSArray *tArr = [touches allObjects];
int len = (int)[tArr count];
int i=0;

    //for each UITouch object, create a GEventTouchObject and add it to the chain.
    for(i=0; i<len; i++) {
    UITouch *tch = [tArr objectAtIndex:i];
    CGPoint viewPoint1 = [tch locationInView:self];
    CGPoint gamePoint = viewToGame(viewPoint1.x*_screenHiResScale, viewPoint1.y*_screenHiResScale, _screenWidth, _screenHeight);
    GEventTouchObject *tObj = [[GEventTouchObject alloc] initWithGamePoint:gamePoint];
    [touchesStartedChain addLink:tObj];
    }

}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
eventsInPlay = YES;
    
    NSMutableArray *touchesArray = [[NSMutableArray alloc] init];
    [touchesArray addObjectsFromArray:[touches allObjects]];
    
    int count = (int)touchesArray.count;
    UITouch *touch;
    
    //set the chain to a state where it will evaluate the touches-moved test for each chain link.
    [touchesStartedChain setToTestTouchMoved];
    
    //loop through the UITouches and for each one we're going to peform a loop to see which of the
    //GEventTouchObjects are closest. The one that is closest we're going to update its lifecycle and touch coodinates.
    for(int i=0; i<count; i++) {
        touch = [touchesArray objectAtIndex:i];
        CGPoint viewPoint1 = [touch locationInView:self];
        CGPoint gamePoint = viewToGame(viewPoint1.x*_screenHiResScale, viewPoint1.y*_screenHiResScale, _screenWidth, _screenHeight);
        
        //tell the chain to evaluate with this particular point
        [touchesStartedChain resetWithTestPoint:gamePoint];
        
        //perform the loop to find the closest one.
        [touchesStartedChain loopForward];
        
        //The one that is closest we're going to update its lifecycle and touch coodinates.
        GEventTouchObject *closestMatch = touchesStartedChain.linkWithClosestDistance;
        [closestMatch declareClosestAndUpdateGamePoint:gamePoint promoteToLifeCycleStage:1];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
eventsInPlay = YES;
cullEndedTouchesFromChain = YES;
    
    NSArray *tArr = [touches allObjects];
    int len = (int)[tArr count];
    int i=0;
    
    UITouch *touch;
    
    //set the chain to a state where it will evaluate the touches-end test for each chain link.
    [touchesStartedChain setToTestTouchEnded];
    
    //perform the same loop as before, only this time we're going to use the touch-end test.
    for(i=0; i<len; i++) {
        touch = [tArr objectAtIndex:i];
        CGPoint viewPoint1 = [touch locationInView:self];
        CGPoint gamePoint = viewToGame(viewPoint1.x*_screenHiResScale, viewPoint1.y*_screenHiResScale, _screenWidth, _screenHeight);
        [touchesStartedChain resetWithTestPoint:gamePoint];
        [touchesStartedChain loopForward];
        
        GEventTouchObject *closestMatch = touchesStartedChain.linkWithClosestDistance;
        [closestMatch declareClosestAndUpdateGamePoint:gamePoint promoteToLifeCycleStage:2];
    }
    
}



//////////////
// Clean up //
//////////////


/**
 * Ok- so the deal is this: Generally, messages which result in the destruction of a surface are going to come from inside
 * a render loop, and possibly the render loop of the doomed surface itself. But there's a problem. If the surface gets
 * destroyed *immediately* and it's only half-way through the renderScene function, the program will crash instantly, because
 * you effectively pulled the carpet out underneath all of the objects and released their memory before the renderScene function
 * was done with them.
 * 
 * To avoid this dilemma, the solution is to *not* have the surfaces go away immediately. What will happen is that the most expensive
 * resources -the textures and sound- will all be immediately returned to the Force, but the renderable objects themselves will
 * live on *just one frame longer*. Because we're running this in a single thread, we can be guaranteed that the safeDestroy function
 * will fire *after* the current call to renderScene and not *during* it, for heaven's sake.
 *
 *
 */
- (void) destroy {

    if(isUnglued == NO) {

    //the surface is unglued, so it can't participate
    //in anymore transactions, and the world needs to know this.
    isUnglued = YES;
        
    self.isObjectDestroyed = YES;
    
        if(gnarly_preloadView) {
        [gnarly_preloadView mainViewIsDestroyed];
        }
    
    
        //if there are background threads which have yet to complete
        //their work, then we're going to have to wait for them to
        //do so. so kill the timer, remove from the superview and
        //return.
        if(numberOfBackgroundProcesses > 0) {
            if(animationTimer) {
            [animationTimer invalidate];
            animationTimer = nil;
            }
        [self removeFromSuperview];
        return;
        }
    

    //set the context so that deleting the textures will not 
    //interfere with any other rendering surfaces.
    [EAGLContext setCurrentContext:context];
        
    //get rid of the framebuffer. it will cause these weird
    //8cd6 errors later on when you try to create a new surface.
    //and remember- you have to do these things inside a context
    //or it won't 'count'.
    [self destroyFramebuffer];

    //release all of the resource keys that are
    //associated with this surface.
    [gnarly_keysOfResourceLists release];
        
    //I had to move this up here because the textures need
    //to be destroyed within a context.
    //destroy the texture data and map data.
    [gnarly_cachedAtlases release];
        
    //clear the rendering buffer.
    //glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    glClear(GL_COLOR_BUFFER_BIT);

        //get rid of the context.
        if([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
        }
        
    //get rid of this.
    [context release];
    context = nil;

    //remove from the window.
    [self removeFromSuperview];

    //tell Gnarly to destroy the sounds and music that
    //are explicitly associated with this surface.
    [[Gnar ly] destroySoundsAndMusicForSurface:self];
        
    //destroy the cached xml data.
    [gnarly_cachedXML release];
        
    //release these guys.
    [gnarly_soundKeysToManage release];
    [gnarly_musicKeysToManage release];


        //if(animationTimer) {
        //[animationTimer invalidate];
        //animationTimer = nil;
        //}
    //stop the animation.
    [self stopAnimation];

    //run the timer one more frame, at the end of which it's going to loop
    //through and destroy all of our GRenderable objects wherever they are.
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:animInterval target:self selector:@selector(safeDestroy) userInfo:nil repeats:NO];

    }

}


/**
 * Stop animating and release resources when they are no longer needed.
 *
 */
//
//- (void)dealloc {
//
//    //#if gDebug_LogDealloc == gYES
//    //NSLog(@"dealloc: GSurface");
//    //#endif
//
//[super dealloc];
//}

@end
