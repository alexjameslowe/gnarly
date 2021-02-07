//
//  Gnarly.h
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 8/7/11.
//  
//


#import <Foundation/Foundation.h>
#import "GnarlySettings.h"
#import "GSurface.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>







//////////////////////////////////////////////////////////
//                                                      //
// Gnarly- game engine. We're using a  neat singleton   //
// trick- the "ly" function manages the shared instance //
// of the Gnar kernel, where a bunch of the important   //
// logic resides.                                       //
//                                                      //                                         
//////////////////////////////////////////////////////////



@class GSpriteMap;
@class GLoadSprite;
@class GOverlayView;
@class GOptionAndResourceList;
@class GLoadView;
@class GAsynchronousLoadingData;
@class GNode;

@interface Gnar : NSObject {

int numSurfaces;
UIWindow *_window;

NSMutableDictionary *allSurfaces;

NSMutableDictionary *allResOpLists;

GOptionAndResourceList *cyclingResOpList;

NSMutableDictionary* userSettings;

NSString *uniqueNameOfApp;

NSString *gnarlyVersion;

BOOL settingsLoaded;

BOOL _appFiredForFirstTime;

float _centerXForViews;

float _centerYForViews;

BOOL appResignedActive;

NSDate *_clockDate;
BOOL _isClock;
    
    float globalFloat0;
    float globalFloat1;
    float globalFloat2;
    float globalFloat3;
    float globalFloat4;
    float globalFloat5;
    float globalFloat6;
    float globalFloat7;
    float globalFloat8;
    float globalFloat9;
    float globalFloat10;
    
NSMutableDictionary *_MAIN_APPLICATION_DATA_;
NSString *mainApplicationDataURL;
NSMutableDictionary *proceduralSaveDictionary;
NSMutableArray *dataStack;
    
BOOL _defaultBool;
int _defaultInt;
float _defaultFloat;
NSString *_defaultString;


EAGLSharegroup *shareGroup;
EAGLContext *loadingContext;

GSurfaceData _transData;



//the variables for the.
//screen dimensions and resolution.
int screenWidth;
int screenHeight;
float screenCenterX;
float screenCenterY;
float screenHiResScale;
float screenK;

    
BOOL is_iPhone;
BOOL is_iPad;
BOOL is_iPadMini;
BOOL is_iPodTouch;
BOOL isRetina;
int  generationNumber;
NSString *platformString;
    

    
//variables for inflecting the class names and urls for the atlases.
NSString *highResolutionAtlasToken;
NSString *iPadAtlasToken;
NSString *iPhoneAtlasToken;
NSString *iPadMiniAtlasToken;
NSString *iPodAtlasToken;
NSString *atlasTokenDelimiter;
BOOL manageDeviceAtlasInflectionManually;
BOOL deviceTokensWillPrependOrAppend;
BOOL iPadMiniWillTokenizeResourcesAsIPad;
BOOL iPodTouchWillTokenizeResourcesAsIPhone;
    
}



//fire these methods in the application delegates, and Gnarly will behave properly
//throughout the lifetime of the app.
- (void) applicationDidReceiveMemoryWarning;
- (void) applicationWillResignActive;
- (void) applicationDidBecomeActive;
- (void) applicationDidEnterBackground;
- (void) applicationWillTerminate;

- (void) calculatePlatformInfo;

//Gnarly has been instructed to add its preloader sprite to the surface.
- (void) addPreloader:(GLoadSprite *)loader toSurface:(GSurface *)sfc;

- (void) beginLoadingResourcesForSurface:(GSurface *)surf;

//remove a surface from the dictionary.
- (void) removeSurfaceFromGnarlyDictionary:(GSurface *)sfc;

//// NEW ////
- (void) surface:(GSurface *)surf mustCreateLoadingSprite:(NSString *)clss
   forOldSurface:(GSurface *)oldSfc forReplacement:(BOOL)truth withData:(GSurfaceData)data;
- (void) destroySoundsAndMusicForSurface:(GSurface *)surf;
- (void) createNewResourcesForKey:(NSString *)key withCallback:(NSString *)cllbck andObserver:(id)obs forSurface:(GSurface *)surf;
- (void) loadResoucesInTheBackground:(GAsynchronousLoadingData *)gData;
- (void) destroyResourceFromList:(NSString *)listKey withKey:(NSString *)recKey forSurface:(GSurface *)surf;
- (void) destroyResourcesForKey:(NSString *)key forSurface:(GSurface *)surf;
- (void) okToBeginGameForSurface:(GSurface *)surf;
- (void) loadResourcesAndBuildOrCall:(GAsynchronousLoadingData *)gData forSurface:(GSurface *)surf;
- (void) checkLoadProgress:(NSTimer *)tmr;
////////////

- (EAGLSharegroup *) getShareGroup;



/////////////
//         //
//  A P I  //
//         //
/////////////

//screen and platform properties.
@property (nonatomic, readonly) int screenWidth;
@property (nonatomic, readonly) int screenHeight;
@property (nonatomic, readonly) float screenCenterX;
@property (nonatomic, readonly) float screenCenterY;
@property (nonatomic, readonly) float screenHiResScale;

@property (nonatomic, assign) float globalFloat0, globalFloat1,
globalFloat2, globalFloat3, globalFloat4, globalFloat5, globalFloat6, globalFloat7, globalFloat8, globalFloat9, globalFloat10;

- (BOOL) is_iPad;
- (BOOL) is_iPadMini;
- (BOOL) is_iPhone;
- (BOOL) is_iPodTouch;
- (BOOL) isRetina;
- (int) generationNumber;
- (NSString *) platformString;


//access the central manager.
+ (Gnar *) ly;

//access the main window
- (UIWindow *) sharedWindow;

//describe.
- (void) describeGnarly;

//the app has fired for the first time.
- (BOOL) appFiredForFirstTime;

//add remove surfaces
- (GSurface *) addNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key;
- (GSurface *) addNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key aboveSurface:(GSurface *)otherSfc;
- (GLoadView *) addNewPreLoader:(NSString *)sfcClass withResourceKey:(NSString *)key aboveMainSurface:(GSurface *)otherSfc;
- (GOverlayView *) addNewOverlayView:(NSString *)sfcClass withResourceKey:(NSString *)key aboveMainSurface:(GSurface *)otherSfc;
- (GSurface *) replace:(GSurface *)oldSurf withNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key;


- (void) UA_setHighResolutionAtlasToken:(NSString *)token;
- (void) UA_setIPadAtlasToken:(NSString *)token;
- (void) UA_setIPhoneAtlasToken:(NSString *)token;
- (void) UA_setIPadMiniAtlasToken:(NSString *)token;
- (void) UA_setIPodAtlasToken:(NSString *)token;
- (void) UA_setAtlasTokenDelimiter:(NSString *)delimiter;
- (void) UA_setDeviceTokensWillAppend;
- (void) UA_setDeviceTokensWillPrepend;
- (void) UA_setManageDeviceAtlasInflectionManually:(BOOL)yesOrNo;
- (void) UA_setIPadMiniWillTokenizeResourcesAsIPad:(BOOL)yesOrNo;
- (void) UA_setIPodTouchWillTokenizeResourcesAsIPhone:(BOOL)yesOrNo;

- (void) useDataForNextLoadSprite:(GSurfaceData)d;
- (void) removeSurfaceWithKey:(NSString *)key;
- (void) windDownFinishedContinueTransaction:(id <GSurfaceTransactor>)actor;

//the clocking methods to see how fast stuff is going.
- (void) startClock;
- (float) endClock;
- (float) endClockAndGetFPS;
- (void) logClock;
- (void) logClockFPS;

//the persistent data api.
- (void) dataSetDefaultB:(BOOL)bl;
- (void) dataSetDefaultF:(float)fl;
- (void) dataSetDefaultI:(int)i;
- (void) dataSetDefaultS:(NSString *)str;
- (void) dataChild:(NSString *)key;
- (void) dataOpen:(NSString *)key;
- (void) dataClose;
- (void) dataSetF:(float)f withKey:(NSString *)key;
- (void) dataSetI:(int)i withKey:(NSString *)key;
- (void) dataSetS:(NSString *)s withKey:(NSString *)key;
- (void) dataSetB:(BOOL)yesOrNo withKey:(NSString *)key;
- (float) dataGetF:(NSString *)key;
- (int) dataGetI:(NSString *)key;
- (NSString *) dataGetS:(NSString *)key;
- (BOOL) dataGetB:(NSString *)key;
- (void) dataClear;
- (void) dataLog;
- (void) dataSave;
- (void) dataLoad;

//this is meant specifically for debugging
- (void) dataPurgeAndSave;

//log deallocing for debug purposes.
- (void) logDealloc:(NSObject *)ob;


//access/communicate with a surface
- (GSurface *) getSurfaceForKey:(NSString *)sfcCode;
- (void) pingSurface:(NSString *)key withMsg:(SEL)message anObject:(id)info;


//add resources
//- (void) addResourceList:(NSMutableArray *)list forKey:(NSString *)key;
- (void) newResourceListForKey:(NSString *)key;
- (void) newSound:(NSString *)ky fileName:(NSString *)file extension:(NSString *)ext ownedBySurface:(BOOL)del;
- (void) newMusic:(NSString *)ky fileName:(NSString *)file extension:(NSString *)ext ownedBySurface:(BOOL)del;
- (void) newAtlas:(NSString *)ky withFile:(NSString *)file extension:(NSString *)ext andMap:(NSString *)clss;
- (void) newAtlas:(NSString *)ky extension:(NSString *)ext;
- (void) newXML:(NSString *)ky withFile:(NSString *)file;
- (void) newWorker:(NSString *)wrkr withOwner:(id)ownr;

- (void) setPreloader:(NSString *)clss withResourceKey:(NSString *)key;
- (void) setPauseView:(NSString *)clss withResourceKey:(NSString *)key;
- (void) setWillSurfacePauseOnReturnFromBackground:(BOOL)truth;
- (void) setPreloaderSprite:(NSString *)clss;

//get a reference to a resource list.
- (NSMutableArray *) getResourceListForKey:(NSString *)key;

//data methods.
- (void) setNameOfAppAndLoadSettings:(NSString *)name;

-(void) logSettings;



////// new 
//- (void) destroySoundsAndMusicForSurface:(GSurface *)surf;
//- (void) loadResourcesAndBuildOrCall:(GAsynchronousLoadingData *)gData forSurface:(GSurface *)surf;
///////

- (void) release;

@end



