//
//  Gnarly.m
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 8/7/11.
//  
//

#import "Gnarly.h"
#import "GSpriteMap.h"
#import "GLoadSprite.h"
#import "GOverlayView.h"
#import "GOptionAndResourceList.h"
#import "GLoadView.h"
#import "GAsynchronousLoadingData.h"
#import "GRootViewController.h"
#import "GNode.h"
#import "GResource.h"
#import "GAudio.h"
#import "TouchXML.h"
#import <sys/utsname.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                      //
//     ______ ______        ______  _     _     _                                                                       //
//    / _____)  ___ \   /\ (_____ \| |   | |   | |                                                                      //
//   | /  ___| |   | | /  \ _____) ) |   | |___| |                                                                      //
//   | | (___) |   | |/ /\ (_____ (| |    \_____/                                                                       //
//   | \____/| |   | | |__| |    | | |_____ ___                                                                         //
//    \_____/|_|   |_|______|    |_|_______|___)                                                                        //
//                                                                                                                      //
//                                                                                                                      //
//  The main manager for the Gnarly game engine. Owns and manages all of the GSurface objects, and contains all         //
//  of the application delegate functions.                                                                              //
//                                                                                                                      //
//  The game programmer does not have to worry about instantiating game surfaces or keeping track of their references.  //
//  This class does all that. You just tell Gnarly what kind of class you want to create, specify a list of resources,  //
//  and Gnarly will return a key you can use to access the surface. You can send message to whatever surface you like.  //
//                                                                                                                      //
//  link credits for this project:                                                                                      //
//                                                                                                                      //
//  http://getsetgames.com/2009/10/07/saving-and-loading-user-data-and-preferences/                                     //
//  asci generated at http://patorjk.com/software/taag/                                                                 //
//                                                                                                                      //
//  this was helpful in solving problems with including dependiencies like the libxml2 library.                         //
//  http://stackoverflow.com/questions/1428847/libxml-tree-h-no-such-file-or-directory                                  //
//                                                                                                                      //
//  this was helpful with some OpenAL questions:                                                                        //
//  http://developer.apple.com/library/ios/#technotes/tn2199/_index.html                                                //
//                                                                                                                      //
//  helpful with OpenAL questions:                                                                                      //
//  http://www.cocos2d-iphone.org/forum/topic/10408                                                                     //
//  "I doubt you'll gain any noticeable performance by shunning AVAudioPlayer. In fact, if you've got it set to use     //
//  hardware decoding you'll get WORSE performance using OpenAL.                                                        //
//  At worst you'll use up so much memory playing long files with OpenAL that your app's performance will fall through  //
//  the floor (especially on a 3G), not to mention the load time to get the file into memory."                          //
//                                                                                                                      //
// http://www.paradeofrain.com/2010/02/iphone-dev-tip-2-openal-performance                                              // 
//                                                                                                                      //
//                                                                                                                      //
//                                                                                                                      //
//  this came in handy with TouchXML                                                                                    //
//  http://dblog.com.au/general/iphone-sdk-tutorial-building-an-advanced-rss-reader-using-touchxml-part-1/              //
//                                                                                                                      //
//  also came in handy with TouchXML                                                                                    //
//  http://caydenliew.com/2011/12/parsing-xml-in-objective-c-with-touchxml/                                             //
//                                                                                                                      //
//  XPath                                                                                                               //
//  http://www.w3schools.com/xpath/xpath_syntax.asp                                                                     //
//                                                                                                                      //
//  NSZombiesEnabled                                                                                                    //
//  http://stackoverflow.com/questions/2190227/how-do-i-set-up-nszombieenabled-in-xcode-4                               //
//                                                                                                                      //
//  I think I was releasing the color space ref before I needed thanks to, and I found                                  //
//  out because of this link.                                                                                           //
//  http://stackoverflow.com/questions/5269815/does-the-result-of-cgimagegetcolorspaceimage-have-to-be-released         ///////////////////
//                                                                                                                                       //
//                                                                                                                                       //
//  if the spawned threads are interrupted by the application going into the background, no worries, because the threads                 //
//  are automagically paused by the OS right where they are, and then resumed when the application returns to the foreground.            //
//  therefore, we don't have to worry about background GPU access by a sub-thread churning away on loading texture data or anything.     //
//  awesome. Thank you http://stackoverflow.com/questions/7187967/problem-in-background-thread-in-iphone.                                //
//                                                                                                                                       //
//  Also read that timers get stopped and started automagically on enter-into/return-from background                                     //
//  http://stackoverflow.com/questions/3587524/nstimer-applicationdidenterbackground-countdown-how-to-keep-state                         //
//  So basically this code is allright.                                                                                 ///////////////////
//                                                                                                                      //
//                                                                                                                      //
//  These guys helped out a lot with sharegroup OpenGL context problems.                                                //
//  http://stackoverflow.com/questions/7547603/multiple-eaglviews-but-only-one-copy-of-each-texture-how                 ///////////////////////////////////////////////////
//  http://stackoverflow.com/questions/1253145/how-to-use-opengl-es-on-a-separate-thread-on-iphone                                                                       //
//  http://developer.apple.com/library/ios/#documentation/OpenGLES/Reference/EAGLSharegroup_ClassRef/Reference/EAGLSharegroup.html#//apple_ref/doc/c_ref/EAGLSharegroup  //
//  http://developer.apple.com/library/ios/#documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithOpenGLESContexts/WorkingwithOpenGLESContexts.html    //
//                                                                                                                                                                       //
//   exporting importing codesign identity.
//   http://stackoverflow.com/questions/12442837/valid-signing-identity-not-found-provisioning-profile
//
//   http://stackoverflow.com/questions/10574070/xcode-4-3-fonts-and-colors-export
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



static Gnar *_sharedManager;
static UIWindow *_sharedWindow;
static BOOL inited = NO;
static BOOL singletonInit = NO;
static BOOL hasWindow = NO;

@implementation Gnar

@synthesize screenWidth,screenHeight;
@synthesize screenCenterX,screenCenterY,screenHiResScale;

@synthesize globalFloat0,globalFloat1,globalFloat2,globalFloat3,globalFloat4,globalFloat5,
globalFloat6,globalFloat7,globalFloat8,globalFloat9,globalFloat10;

//static int wellWhatTheHell = 0;

/**
 * the init method. you don't call this method, because Gnarly is a singleton class.
 *
 */
- (id)init {

    if(singletonInit == YES) {
    self = [super init];
    numSurfaces = 0;
    allSurfaces = [[NSMutableDictionary alloc] init];
    allResOpLists = [[NSMutableDictionary alloc] init];
    userSettings = [[NSMutableDictionary alloc] init];
    dataStack = [[NSMutableArray alloc] init];
        
    _defaultBool = NO;
    _defaultInt = 0;
    _defaultFloat = 0;
    _defaultString = @"";

        
    gnarlyVersion = @"Gy0.5.2";
    settingsLoaded = NO;
    _appFiredForFirstTime = NO;
    appResignedActive = NO;
    manageDeviceAtlasInflectionManually = NO;
    deviceTokensWillPrependOrAppend = YES;
    _isClock = NO;
    
    //loadingContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup: shareGroup];
    loadingContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    //record the share group.
    shareGroup = loadingContext.sharegroup;
    
    [self calculatePlatformInfo];
    
    //set all of the screen properties that other objects will want to know about.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
        
        //NSLog(@"ScreenHiResScale: %f",screenHiResScale);
        //screenHiResScale = 1.0f;
    
    //NSLog(@"screenBounds: width: %f%@%f",
    //      CGRectGetWidth(screenBounds),@" height: ",CGRectGetHeight(screenBounds));
        //Sean's iPad says: screenBounds: width: 320.000000 height: 480.000000
        //Alex's iPhone says:  320.000000 height: 568.000000
        //NSLog(@"screenHiResScale: %f",screenHiResScale);
    
        //this is all for landscape mode, although I think it would be the same for portrait.
        //See: Notes iOS getting the frame right for OpenGL ES 1.1.txt

        screenWidth = screenHiResScale*CGRectGetWidth(screenBounds);
        screenHeight = screenHiResScale*CGRectGetHeight(screenBounds);
        
        screenCenterX = screenWidth/2;
        screenCenterY = screenHeight/2;
    
        //you'll notice the extra factor /2 in here. This is because while the hi-definition
        //iPhone screen is actually 640x960 pixels, the as far as the UIView API is concerned,
        //it's 320 x 480, i.e. "legacy" coordinates.
        _centerXForViews = screenCenterX/screenHiResScale;
        _centerYForViews = screenCenterY/screenHiResScale;
        
            //Ok so this IS necessary, for iPad situations. I didn't seem to need it
            //for iPhones, but I do need it for iPads. iPads will report orientation-dependent
            //coordinates no matter WHAT the orientation settings are for the app. 
            if(screenHeight > screenWidth) {
            //NSLog(@"BOUNDS Problem: GOTCHA center-x %f%@%f",
            //_centerXForViews,@" center-y ",_centerYForViews);
            float cX = _centerXForViews;
            float cY = _centerYForViews;
            _centerXForViews = cY;
            _centerYForViews = cX;
            
            float sW = screenWidth;
            float sH = screenHeight;
            
            screenWidth = sH;
            screenHeight = sW;
            
            screenCenterX = screenWidth/2;
            screenCenterY = screenHeight/2;
                
            //NSLog(@"AFTER screenWidth %i%@%i",screenWidth,@" screenHeight: ",screenHeight);
            //NSLog(@"AFTER screenCenterX %f%@%f",screenCenterX,@" screenCenterY: ",screenCenterY);
            //NSLog(@"AFTER _centerXForViews %f%@%f",_centerXForViews,@" _centerYForViews: ",_centerYForViews);
                
            }
        
        
        //See this for why we have a scaling factor. This leaves open the possibility
        //of having uniform sizes of things between different screens.
        //http://stackoverflow.com/questions/9881373/how-do-i-preserve-physical-sizes-between-different-ithings-in-open-gl/9894567#9894567
        //if(screenWidth == 320) {
        //screenK = 1.221;
        //} else {
        screenK = 1;
        //}
    
    
    //[GSurface setScreenW:screenWidth H:screenHeight cX:screenCenterX cY:screenCenterY K:screenK];
    //[GNode     setScreenW:screenWidth H:screenHeight cX:screenCenterX cY:screenCenterY K:screenK];
    //[GSpriteMap setScreenK:screenK];

    
    [GSurface  setScreenW:screenWidth H:screenHeight cX:screenCenterX cY:screenCenterY hiResScale:screenHiResScale isRetina:isRetina];
    [GNode     setScreenW:screenWidth H:screenHeight cX:screenCenterX cY:screenCenterY hiResScale:screenHiResScale isRetina:isRetina];

        
    return self;
    } else {
    NSLog(@"Error: Gnarly --> Gnarly cannot be instantiated. It is a singleton class.");
    return nil;
    }

}


/**
 * Calculate the platform information. Sort of a pain. These links came in handy:
 *  http://stackoverflow.com/questions/2884391/api-to-determine-whether-running-on-iphone-or-ipad
 *  http://stackoverflow.com/questions/14372906/to-detect-ios-device-type
 *  http://theiphonewiki.com/wiki/Models
 *
 */
- (void) calculatePlatformInfo {
struct utsname systemInfo;
uname(&systemInfo);
NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
int which = 0;
screenHiResScale = 1.0f;
isRetina = NO;
    
    //NSLog(@"Launching on iPhone 6! Platform! %@",platform);
    
    //iPhone 2
    if ([platform isEqualToString:@"iPhone1,1"]) {
    platformString = @"iPhone_2G";
    which = 0;
    generationNumber = 2;
    screenHiResScale = 1.0f;
    }
    
    //iPhone 3
    else if ([platform isEqualToString:@"iPhone1,2"]){
    platformString = @"iPhone_3G";
    which = 0;
    generationNumber = 3;
    screenHiResScale = 1.0f;
    }
    
    //iPhone 3GS
    else if ([platform isEqualToString:@"iPhone2,1"]){
    platformString = @"iPhone_3GS";
    which = 0;
    generationNumber = 3.5;
    screenHiResScale = 1.0f;
    }
    
    //iPhone 4
    else if ([platform isEqualToString:@"iPhone3,1"] || [platform isEqualToString:@"iPhone3,2"] || [platform isEqualToString:@"iPhone3,3"]){
    platformString = @"iPhone_4";
    which = 0;
    isRetina = YES;
    generationNumber = 4;
    screenHiResScale = 2.0f;
    }

    
    //iPhone 4S
    else if ([platform isEqualToString:@"iPhone4,1"]){
    platformString = @"iPhone_4S";
    which = 0;
    isRetina = YES;
    generationNumber = 4.5;
    screenHiResScale = 2.0f;
    }
    
    //iPhone 5
    else if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"]){
    platformString = @"iPhone_5";
    which = 0;
    isRetina = YES;
    generationNumber = 5;
    screenHiResScale = 2.0f;
    }


    //iPhone 5C
    else if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"]){
    platformString = @"iPhone_5C";
    which = 0;
    isRetina = YES;
    generationNumber = 5.2;
    screenHiResScale = 2.0f;
    }

    //iPhone 5S
    else if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"]){
    platformString = @"iPhone_5S";
    which = 0;
    isRetina = YES;
    generationNumber = 5.5;
    screenHiResScale = 2.0f;
    }
    
    //iPhone 6
    else if ([platform isEqualToString:@"iPhone7,2"]){
    platformString = @"iPhone_6";
    which = 0;
    isRetina = YES;
    generationNumber = 6;
    screenHiResScale = 2.0f;
    }
    
    //iPhone 6 plus
    else if ([platform isEqualToString:@"iPhone7,1"]){
    platformString = @"iPhone_6_plus";
    which = 0;
    isRetina = YES;
    generationNumber = 6;
    screenHiResScale = 2.0f;
    }

    //iPhone 6S
    else if ([platform isEqualToString:@"iPhone8,1"]){
    platformString = @"iPhone_6s";
    which = 0;
    isRetina = YES;
    generationNumber = 6.5;
    screenHiResScale = 2.0f;
    }
    
    
    //iPhone 6S plus
    else if ([platform isEqualToString:@"iPhone8,2"]){
    platformString = @"iPhone_6s_plus";
    which = 0;
    isRetina = YES;
    generationNumber = 6.5;
    screenHiResScale = 2.0f;
    }
    
    //iPhone SE
    else if ([platform isEqualToString:@"iPhone8,4"]){
    platformString = @"iPhone_SE";
    which = 0;
    isRetina = YES;
    generationNumber = 7;
    screenHiResScale = 2.0f;
    }
    
    //iPhone 7
    else if ([platform isEqualToString:@"iPhone9,1"] || [platform isEqualToString:@"iPhone9,3"]){
    platformString = @"iPhone_7";
    which = 0;
    isRetina = YES;
    generationNumber = 7;
    screenHiResScale = 2.0f;
    }

    //iPhone 7 plus
    else if ([platform isEqualToString:@"iPhone9,2"] || [platform isEqualToString:@"iPhone9,4"]){
    platformString = @"iPhone_7_plus";
    which = 0;
    isRetina = YES;
    generationNumber = 7;
    screenHiResScale = 2.0f;
    }
    
    //@"iPhone 8";
    else if ([platform isEqualToString:@"iPhone10,1"] || [platform isEqualToString:@"iPhone10,4"]) {
    platformString = @"iPhone_8";
    which = 0;
    isRetina = YES;
    generationNumber = 8;
    screenHiResScale = 2.0f;
    }
    
    //iPhone 8 Plus
    else if ([platform isEqualToString:@"iPhone10,2"] || [platform isEqualToString:@"iPhone10,5"]) {
    platformString = @"iPhone_8_plus";
    which = 0;
    isRetina = YES;
    generationNumber = 8;
    screenHiResScale = 2.0f;
    }

    //iPhone X
    else if ([platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"]) {
    platformString = @"iPhone_X";
    which = 0;
    isRetina = YES;
    generationNumber = 8;
    screenHiResScale = 2.0f;
    }

    
    
    //iPod Touch 1-6
    else if ([platform isEqualToString:@"iPod1,1"]){
    platformString = @"iPod_Touch 1G";
    which = 1;
    generationNumber = 1;
    screenHiResScale = 1.0f;
    }
    else if ([platform isEqualToString:@"iPod2,1"]){
    platformString = @"iPod_Touch 2G";
    which = 1;
    generationNumber = 2;
    screenHiResScale = 1.0f;
    }
    else if ([platform isEqualToString:@"iPod3,1"]){
    platformString = @"iPod_Touch 3G";
    which = 1;
    generationNumber = 3;
    screenHiResScale = 1.0f;
    }
    else if ([platform isEqualToString:@"iPod4,1"]){
    platformString = @"iPod_Touch 4G";
    which = 1;
    isRetina = YES;
    generationNumber = 4;
    screenHiResScale = 2.0f;
    }
    else if ([platform isEqualToString:@"iPod5,1"]){
    platformString = @"iPod_Touch 5G";
    which = 1;
    isRetina = YES;
    generationNumber = 5;
    screenHiResScale = 2.0f;
    }
    else if ([platform isEqualToString:@"iPod7,1"]){
    platformString = @"iPod_Touch 6G";
    which = 1;
    isRetina = YES;
    generationNumber = 6;
    screenHiResScale = 2.0f;
    }
    
    //iPad 1
    else if ([platform isEqualToString:@"iPad1,1"]){
    platformString = @"iPad_1G";
    generationNumber = 1;
    which = 2;
    screenHiResScale = 1.0f;
    }
    
    //iPad 2
    else if ([platform isEqualToString:@"iPad2,1"]){
    platformString = @"iPad_2(WiFi)";
    generationNumber = 2;
    which = 2;
    screenHiResScale = 1.0f;
    }
    else if ([platform isEqualToString:@"iPad2,2"]){
    platformString = @"iPad_2(GSM)";
    generationNumber = 2;
    which = 2;
    screenHiResScale = 1.0f;
    }
    else if ([platform isEqualToString:@"iPad2,3"]){
    platformString = @"iPad_2(CDMA)";
    generationNumber = 2;
    screenHiResScale = 1.0f;
    which = 2;
    }
    else if ([platform isEqualToString:@"iPad2,4"]){
    platformString = @"iPad_2";
    generationNumber = 2;
    screenHiResScale = 1.0f;
    which = 2;
    }
    
    //iPad 3
    else if ([platform isEqualToString:@"iPad3,1"]){
    platformString = @"iPad_3";
    generationNumber = 3;
    isRetina = YES;
    screenHiResScale = 2.0f;
    which = 2;
    }
    else if ([platform isEqualToString:@"iPad3,2"]){
    platformString = @"iPad_3(GSM/CDMA)";
    generationNumber = 3;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    else if ([platform isEqualToString:@"iPad3,3"]){
    platformString = @"iPad_3(GSM)";
    generationNumber = 3;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    
    //iPad 4
    else if ([platform isEqualToString:@"iPad3,4"]){
    platformString = @"iPad_4(WiFI)";
    generationNumber = 4;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    else if ([platform isEqualToString:@"iPad3,5"]){
    platformString = @"iPad_4(GSM)";
    generationNumber = 4;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    } else if ([platform isEqualToString:@"iPad3,6"]){
    platformString = @"iPad_4(GSM/CDMA)";
    generationNumber = 4;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    
    //iPad Air
    else if ([platform isEqualToString:@"iPad4,1"]){
    platformString = @"iPad_5(WiFi)";
    generationNumber = 5;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    else if ([platform isEqualToString:@"iPad4,2"] || [platform isEqualToString:@"iPad4,3"]){
    platformString = @"iPad_5(Cellular)";
    generationNumber = 5;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    
    //iPad Air 2
    else if ([platformString isEqualToString:@"iPad5,3"]) {
    platformString = @"iPad_Air2(WiFi)";
    generationNumber = 6;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    else if ([platformString isEqualToString:@"iPad5,4"]) {
    platformString = @"iPad_Air2(Cellular)";
    generationNumber = 6;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    
    //iPad Pro 9.7 inch
    else if([platformString isEqualToString:@"iPad6,3"] || [platformString isEqualToString:@"iPad6,4"]) {
    platformString = @"iPad_Pro_12.9_inch";
    generationNumber = 7;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    
    //iPad Pro 12.9 inch
    else if([platformString isEqualToString:@"iPad6,7"] || [platformString isEqualToString:@"iPad6,8"]) {
    platformString = @"iPad_Pro_1_12.9_inch";
    generationNumber = 7;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    
    //iPad Pro 12.9 inch gen 2
    else if([platformString isEqualToString:@"iPad7,1"] || [platformString isEqualToString:@"iPad7,2"]) {
    platformString = @"iPad_Pro_2_12.9_inch";
    generationNumber = 8;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    
    //iPad Pro 10.5 inch
    else if([platformString isEqualToString:@"iPad7,3"] || [platformString isEqualToString:@"iPad7,4"]) {
    platformString = @"iPad_Pro_10.5_inch";
    generationNumber = 8;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 2;
    }
    
    
    
    //iPad Mini 1
    else if ([platform isEqualToString:@"iPad2,5"]){
    platformString = @"iPad_mini_1(WiFi)";
    generationNumber = 1;
    screenHiResScale = 1.0f;
    which = 3;
    }
    else if ([platform isEqualToString:@"iPad2,6"]){
    platformString = @"iPad_mini_1(GSM)";
    generationNumber = 1;
    screenHiResScale = 1.0f;
    which = 3;
    }
    else if ([platform isEqualToString:@"iPad2,7"]){
    platformString = @"iPad_mini_1(GSM/CDMA)";
    generationNumber = 1;
    screenHiResScale = 1.0f;
    which = 3;
    }
    
    //iPad Mini 2
    else if ([platform isEqualToString:@"iPad4,4"]){
    platformString = @"iPad_mini_2(WiFi)";
    generationNumber = 2;
    screenHiResScale = 1.0f;
    which = 3;
    }
    else if ([platform isEqualToString:@"iPad4,5"]){
    platformString = @"iPad_mini_2(GSM)";
    generationNumber = 2;
    screenHiResScale = 1.0f;
    which = 3;
    }
    else if ([platform isEqualToString:@"iPad4,6"]){
    platformString = @"iPad_mini_2(?)";
    generationNumber = 2;
    screenHiResScale = 1.0f;
    which = 3;
    }
    
    //iPad Mini 3
    else if([platform isEqualToString:@"iPad4,7"]) {
    platformString = @"iPad_mini_3(Wifi)";
    generationNumber = 3;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 3;
    }
    else if([platform isEqualToString:@"iPad4,8"]) {
    platformString = @"iPad_mini_3(Cellular)";
    generationNumber = 3;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 3;
    }
    else if([platform isEqualToString:@"iPad4,9"]) {
    platformString = @"iPad_mini_3(Cellular2)";
    generationNumber = 3;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 3;
    }
    
    //iPad Mini 4
    else if([platform isEqualToString:@"iPad5,1"]) {
    platformString = @"iPad_mini_4(Wifi)";
    generationNumber = 4;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 3;
    }
    else if([platform isEqualToString:@"iPad5,2"]) {
    platformString = @"iPad_mini_4(Cellular)";
    generationNumber = 4;
    screenHiResScale = 2.0f;
    isRetina = YES;
    which = 3;
    }
    
    
    
    //Simulators
    else if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"]){
    generationNumber = 0;

        //if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        if([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
        platformString = @"iPad Simulator";
        which = 2;
        screenHiResScale = 1.0f;
        } else {
        platformString = @"iPhone Simulator";
        which = 0;
        screenHiResScale = 1.0f;
            
        //goddamn this shit is annoying.
//            switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
//
//                case 1136:
//                    //printf("iPhone 5 or 5S or 5C");
//                    platformString = @"iPhone_SE";
//                    which = 0;
//                    //generationNumber = 7;
//                    break;
//                case 1334:
//                    printf("iPhone 6/6S/7/8");
//                    break;
//                case 2208:
//                    printf("iPhone 6+/6S+/7+/8+");
//                    break;
//                case 2436:
//                    printf("iPhone X");
//                    break;
//                default:
//                    printf("unknown");
//            }
//
            
            
        }        
    }
   
is_iPad = NO;
is_iPadMini = NO;
is_iPhone = NO;
is_iPodTouch = NO;
    
    //NSLog(@"platformString: %@",platformString);
    
    if(which == 0) {
    is_iPhone = YES;
    } else
    if(which == 1) {
    is_iPodTouch = YES;
    } else
    if(which == 2) {
    is_iPad = YES;
    } else
    if(which == 3) {
    is_iPadMini = YES;
    }

}

- (EAGLSharegroup *) getShareGroup {
    if(!shareGroup) {
    [NSException raise:@"Error: Gnarly => getShareGroup. The shareGroup is null." format:@"Here's the shareGroup: %@",shareGroup];
    }
return shareGroup;
}


/**
 * is this the first time the app has fired?
 *
 */
- (BOOL) appFiredForFirstTime {
return _appFiredForFirstTime;
}




/**
 * singleton access for Gnarly.
 *
 */
+ (Gnar *) ly {

    if(inited == NO) {
    inited = YES;
    singletonInit = YES;
    _sharedManager = [[Gnar alloc] init];
    singletonInit = NO;
    
        if(hasWindow == NO) {
        hasWindow = YES;
        CGRect rect = [[UIScreen mainScreen] bounds];
        _sharedWindow = [[UIWindow alloc] initWithFrame:rect];
        [_sharedWindow makeKeyAndVisible];
        //For iOS rootViewController
        //_sharedWindow.rootViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
        
        _sharedWindow.rootViewController = [[GRootViewController alloc] initWithNibName:nil bundle:nil];
        }
        
    //generate some default resource lists that we may or may not need.
    //[_sharedManager newResourceListForKey:@"_DfltPauseScrn"];
    //[_sharedManager newAtlas:@"DEFAULT_PAUSE" withFile:@"GnarlyCommonGfx" extension:@"png" andMap:@"GnarlyMap"];
    
    }
    
return _sharedManager;

}



/**
 * Gnarly was instructed during a surface transaction to add its preloader sprite to the 
 * surface. so do it. make sure that one is there first.
 *
 */
- (void) addPreloader:(GLoadSprite *)loader toSurface:(GSurface *)sfc {
    if(loader) {
    [sfc addChild:loader];
    } else {
    NSLog(@"ERROR: Gnarly: addPreloaderToSurface: something went wrong because theres no preloader sprite to complete the transaction.");
    }
}



/**
 * insert a new preloader into the mix above the main surface. not an API function.
 *
 */
- (GLoadView *)addNewPreLoader:(NSString *)sfcClass withResourceKey:(NSString *)key aboveMainSurface:(GSurface *)otherSfc {
//get the coupled pair of resources and options for the surface.
GOptionAndResourceList *pair = [allResOpLists objectForKey:key];

    if(pair) {
    //generate the unique key for the surface
    NSString *surfaceKey = @"g";
    surfaceKey = [surfaceKey stringByAppendingFormat:@"%d",numSurfaces];
    
    //get the class of the surface.
    Class cls = NSClassFromString(sfcClass);

        if(cls) {
        numSurfaces++;
        //create the surface
        pair.hasPreloader = NO;
        pair.hasPreloaderSprite = NO;
        GLoadView *sfc = [[cls alloc] initWithResources:pair withResourceKey:key andMainView:otherSfc];
        
        //log the surface into the dictionary so that it's globally available
        [allSurfaces setObject:sfc forKey:surfaceKey]; 
        
        //position it, start the animation and insert into the display list.
            sfc.animationInterval = 1.0 / gRenderingFrequency;
        sfc.center = CGPointMake(_centerXForViews,_centerYForViews);
        //[_sharedWindow insertSubview:sfc aboveSubview:otherSfc];
        [_sharedWindow.rootViewController.view insertSubview:sfc aboveSubview:otherSfc];
        
        //assign the key.
        sfc.surfaceKey = surfaceKey;
        return sfc;
        } else {
        NSLog(@"Error: Gnarly: --> - (NSString *)addNewSurface:(NSString *)sfcClass withResourceList:(NSMutableArray *)list: no class %@%@",sfcClass,@" exists.");
        return nil;
        }   

    } else {
    NSLog(@"Error: Gnarly -->  addNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key resource list for key %@%@",key,@" does not exist.");
    return nil;
    }
    
}




/**
 * load all the resources that this surface will use. this function cranks on a thread separate
 * from the main program. this function updates the asynchProgress variable which gets polled 
 * by the main thread so that it will know when this process is finished.
 *
 */
- (void) loadResourcesAndBuildOrCall:(GAsynchronousLoadingData *)gData forSurface:(GSurface *)surf {
    
    if(!gData) {
    NSLog(@"Error: GSurface: loadResourcesAndBuildOrCall: data parameter cannot be null. An error is about to be thrown.");
    }

BOOL isSurfacePreloading = gData.forPreload;
    
     //NEED THE CURRENT AND CONTEXT SET HERE.
    if(isSurfacePreloading == YES && gData.forMultiThread == NO) {
    [GSurface setCurrentView:surf];
    [surf makeContextCurrent];
    }
    
    if(gData.forMultiThread == YES) {
    [EAGLContext setCurrentContext:loadingContext];
    [GSurface setCurrentView:surf];
    
    //You can test to see that a surface can be safely destroyed while it's loading resources, and nothing
    //terrible will happen.
    //[surf destroy];
    }
    
    //NSLog(@"loading resources: key: %@",gData.key);
    
//get the rec list. if the surface is in the process of loading itself up, then this
//rec list is going to be simply the one the surface was initialized with.
//The other situation is that the suface already exists, and it's greedily asking for
//"moar" resources. in this case, the resource grab the resource list from gnarly's
//central dictionary.
NSMutableArray *recList;
    if(isSurfacePreloading == YES) {
    recList = surf.gnarly_resourceList;
    } else {
    recList = [[Gnar ly] getResourceListForKey:gData.key];
    }
    
int len = (int)[recList count];


//the asynch progress starts off at 0.
gData.asynchProgress = 0;

    if(isSurfacePreloading == YES) {
    surf.gnarly_asynchProgress = 0;
    }

float increment = 1.0;

	if(len > 0) {
    increment = 1.0f / (len+1);
    
        // loop through the resource list and load them all
        for (int h=0; h<len; h++) {
        GResource *res = [recList objectAtIndex:h];
            
            //if the resourceType is 0, then we're loading texture data.
            if(res.resourceType == 0) {
                
            [surf addTexture:res.fileName andMap:res.nameOfClass withKey:res.key];
                
            } else
           
            //else, if the resourceType is 1, then we're creating xml data.
            if(res.resourceType == 1) {
                
            NSError *err = nil;
            //http://stackoverflow.com/questions/1915478/cocoa-error-256-core-data

            // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
            // object that actually grabs and processes the RSS data
            //CXMLDocument *xDoc = [[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:&err];
            //NSLog(@"res.fileName: %@",res.fileName);
            
            NSString *XMLPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:res.fileName];
            NSData *XMLData   = [NSData dataWithContentsOfFile:XMLPath];
            CXMLDocument *xDoc = [[CXMLDocument alloc] initWithData:XMLData options:0 error:&err];
            
                if(xDoc == nil) {
                NSLog(@"Gnarly: Error: can't create xml data for file: %@",res.fileName);
                NSLog(@"Error: %@",[err localizedDescription]);
                } else {
                [surf addXML:xDoc withKey:res.key];
                }

           } else 
           
           //if resourceType is 2, then we're loading a sound resource.
           if(res.resourceType == 2) {                        //22050  44100  WAS 22050
           [[GAudio sharedSoundManager] loadSoundWithKey:res.key fileName:res.fileName fileExt:res.fileExtension frequency:22050];
               
               //take responsibility for deleting this sound if the sound
               //is only meant to survive for the lifetime of this view.
               if(res.ownedBySurface == YES) {
               [surf.gnarly_soundKeysToManage addObject:res.key];
               } else {
               [[GAudio sharedSoundManager] logKeyAsCommonSound:res.key];
               }
               
           } else
           
           //if resource type is 3, then  we're loading background music.
           if(res.resourceType == 3) {
           //http://www.cocos2d-iphone.org/forum/topic/10408
           //"I doubt you'll gain any noticeable performance by shunning AVAudioPlayer. In fact, if you've got it set to use hardware decoding you'll get WORSE performance using OpenAL.
           // At worst you'll use up so much memory playing long files with OpenAL that your app's performance will fall through the floor (especially on a 3G), 
           // not to mention the load time to get the file into memory."
           [[GAudio sharedSoundManager] loadBackgroundMusicWithKey:res.key fileName:res.fileName fileExt:res.fileExtension];
           
               //take responsibility for deleting this sound if the sound
               //is only meant to survive for the lifetime of this view.
               if(res.ownedBySurface == YES) {
               [surf.gnarly_musicKeysToManage addObject:res.key];
               } else {
               [[GAudio sharedSoundManager] logKeyAsCommonMusic:res.key];
               }
             
           } else
           if(res.resourceType == 5) {
                    
           //just execute an arbitrary function in the background.
           [res.owner performSelector:res.worker withObject:nil];
                   
           }
           
        //other resources will be vertex data and shader programs, but that won't come until I start doing 3d, which
        //won't be for a while yet.
           
        //tick up the asynchProgress.
        gData.asynchProgress += increment;
        
            if(isSurfacePreloading == YES) {
            surf.gnarly_asynchProgress += increment;
            }
        
		}
        
	}	
    
    if(gData.forMultiThread == YES) {
    glFlush();
    [surf makeContextCurrent];
    [GSurface setCurrentView:surf];
    }

    //NEEDS THE CONTEXT AND CURRENT SURFACE SET HERE.
    if(isSurfacePreloading == YES) {
    [surf makeContextCurrent];
    [GSurface setCurrentView:surf];
        
        //call some delegates depending on what environment this thing is in.
        if(is_iPad) {
        [surf gnarlySays_iPad];
        } else
        if(is_iPhone) {
        [surf gnarlySays_iPhone];
        } else
        if(is_iPadMini) {
        [surf gnarlySays_iPadMini];
        } else
        if(is_iPodTouch) {
        [surf gnarlySays_iPodTouch];
        }
        
    [surf gnarlySaysBuildSurface];
    } 
    
    
//completed.
gData.asynchProgress = 1.0f;	

    if(isSurfacePreloading == YES) {
    surf.gnarly_asynchProgress = 1.0f;
    }


}



/**
 * check the progress on the asynchronous loading of the resources.
 *
 */
- (void) checkLoadProgress:(NSTimer *)tmr {
    
GAsynchronousLoadingData *gData = tmr.userInfo;
GSurface *surf = gData.relatedSurface;

	//Check if sound buffers have completed loading, asynchLoadProgress represents fraction of completion and 1.0 is complete.
    if(gData.asynchProgress >= 1.0f) {
    
    //invalidate the timer.
    [gData.loadingTimer invalidate];
    gData.loadingTimer = nil;
    
        //if were using this to start up the surface, then start it up.
        if(gData.forPreload == YES) {
        //set this to yes.
        surf.gnarly_resourcesLoaded = YES;
        
            //if there's a preload view, then that view needs to get the heads-up that
            //its GSurface object got done pre-loading all its resources, and so the 
            //preload view needs to wind down its pretty animation.
            if(surf.gnarly_preloadView) {
            [surf.gnarly_preloadView gnarlySaysWindDownSurface];
            } else
            if(surf.gnarly_preloadSprite) {
            [surf.gnarly_preloadSprite gnarlySaysWindDownSprite];
            }

            
            //else, if there is no preload view, then just build the game and get on with the show.
            else {
                //NSLog(@"Gnarly: setting animation-interval: checkLoadProgress.");
                surf.animationInterval = 1.0/gRenderingFrequency;///
            [surf gnarlySaysStartSounds];
            }
            
        } 
        //else, just fire the callback to let the world know that the requested resources are done loading.
        else {
        SEL call = NSSelectorFromString([gData.callback stringByAppendingString:@":"]);
            if([gData.observer respondsToSelector:call] == YES) {
            //objc_msgSend(gData.observer, call, gData.key);
            [gData.observer performSelector:call withObject:gData.key];
            } else {
            [NSException raise:@"Error: Gnarly => checkLoadProgress" format:@"observer does not respond to callback %@",[gData.callback stringByAppendingString:@":"]];
            }
    
        }
        
    
        //New 2014-02-03 If the resources were destroyed while they were loading,
        //then the destruction was called off temporarily so that they could be
        //destroyed as soon as they were loaded.
        if([surf resourceRequests_checkResourceRequestCancelationForKeyForGnarly:gData.key]) {
        [self destroyResourcesForKey:gData.key forSurface:surf];
        }
        
    //decrement the number of loading operations for the surface. if there aren't any more, then
    //this function will handle the contingency that the surface's destroy function was called
    //in the meantime and the surface and all of its resources, including the ones that just
    //loaded, all need to die.
    [surf decrementNumberBackgroundProcesses];
        
    //release the gData here. should get rid of the reference to the timer.
    [gData release];
    } 

}



/**
 * generic loading function for the multithreading. used for both preloading assets before a surface arrives, 
 * as well as loading new resources at runtime to a surface when it is living.
 * 
 *  FROM GSURFACE.
 */
- (void) loadResoucesInTheBackground:(GAsynchronousLoadingData *)gData {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// wait for 3 seconds before starting the thread, you don't have to do that. This is just an example how to stop the NSThread for some time
	//[NSThread sleepForTimeInterval:3];
    [[Gnar ly] loadResourcesAndBuildOrCall:gData forSurface:gData.relatedSurface];
    
    [pool release];
	
}

/**
 * THIS STARTS A SURFACE ALL LOADING. IT'S LOADED WHEN IT GET'S ADDED TO THE SUPERVIEW.
 *
 *
 */
- (void) beginLoadingResourcesForSurface:(GSurface *)surf {

    //only do this once./
    if(surf.gnarly_addedToWindow == NO) {
    surf.gnarly_addedToWindow = YES;
    
    //increment the number of background processes.
    [surf incrementNumberBackgroundProcesses];
        
        //if this view is configures to have a preloader (which happens at the top level of Gnarly), then add the 
        //preloader here. notice that we do not ever directly create GSurface instances ourselves. Gnarly does that.
        if(surf.gnarly_hasPreloader) {
        surf.gnarly_preloadView = [[Gnar ly] addNewPreLoader:surf.gnarly_preloadClassName withResourceKey:surf.gnarly_preloadResourceKey aboveMainSurface:surf];
        }
      
    //log the options into a asynchronous data packet. The only thing we need to do here is log the preloadTimer and set the preload flag to YES.
    GAsynchronousLoadingData *gData = [[GAsynchronousLoadingData alloc] initWithKey:@"MainPreloader" callback:nil observer:nil andPreloadFlag:YES];
    
    //record the surface.
    gData.relatedSurface = surf;
    
    //record the key for the original resources.
    gData.originalResourcesKey = surf.gnarly_originalResources;
       
    //start the timer to monitor the progress of the resource-loading routine.
    NSTimer* loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkLoadProgress:) userInfo:gData repeats:YES];
    
    //set the loading tomer on the gData object.
    gData.loadingTimer = loadTimer;
    
    
    ////////// do not do this in a separate thread. do it here.
    [GSurface setCurrentView:surf];
    [surf makeContextCurrent];
    [surf initGLES];
    [surf setupScene];
    /////////
    
    
    //CHANGED THIS.
    gData.forMultiThread = YES;

    //load the resources in a separate thread.
    [NSThread detachNewThreadSelector:@selector(loadResoucesInTheBackground:) toTarget:self withObject:gData];
        
    }

}



/**
 * this surface received a command to create a preloaderSprite, because a new surface is loading in the background.
 *
 */
- (void) surface:(GSurface *)surf mustCreateLoadingSprite:(NSString *)clss forOldSurface:(GSurface *)oldSfc forReplacement:(BOOL)truth withData:(GSurfaceData)data {
Class cls = NSClassFromString(clss);
    
    //NSLog(@"Gnarly: surface:(GSurface *)surf mustCreateLoadingSprite:(NSString *)clss forOldSurface:(GSurface *)oldSfc");
    //NSLog(@"old surface: %@%@%@",oldSfc,@"  new surface: ",surf);

    if(cls) {
    [GSurface setCurrentView:oldSfc];
    surf.gnarly_preloadSprite = [[cls alloc] initWithNewSurface:surf andOldSurface:oldSfc];
    
    //here, we're going to give both the old surface and the new surface an opportunity
    //to perform special configurations on the loading sprite. they might have relevant
    //information and preferences that they want to impose on that object.
    //tell the surface to do whatever configuration is necessary.
    [surf gnarlySaysStartLoadingSprite:surf.gnarly_preloadSprite withData:data];
    
    //tell the old surface to do whatever configuration is necessary.
    [oldSfc gnarlySaysStartLoadingSprite:surf.gnarly_preloadSprite withData:data];

    //tell Gnary to add the preloader sprite to the surface.
    //old and pointless. [[Gnar ly] addPreloader:surf.gnarly_preloadSprite toSurface:oldSfc];
    [oldSfc addChild:surf.gnarly_preloadSprite];
    
    //update the current view.
    [GSurface setCurrentView:surf];
    }

}




/**
 * A surface is in it's death throes, so it's asking Gnarly to destroy all of the sounds
 * and music that is exclusively associated with it.
 *
 */
- (void) destroySoundsAndMusicForSurface:(GSurface *)surf {
NSMutableArray *a0 = surf.gnarly_soundKeysToManage;
NSMutableArray *a1 = surf.gnarly_musicKeysToManage;
int l0 = (int)a0.count;
int l1 = (int)a1.count;

    for(int k=0; k<l0; k++) {
    [[GAudio sharedSoundManager] deleteSoundWithKey:[a0 objectAtIndex:k]];
    }
    for(int l=0; l<l1; l++) {
    [[GAudio sharedSoundManager] deleteSoundWithKey:[a1 objectAtIndex:l]];
    }

}


/**
 * once the preloader has completed it's animation after receiving the all-clear signal from this object,
 * the preloader needs to sends a message to this object, which in turn triggers this function. This function will destroy the
 * preloader if it has to, and call the gnarlySaysBuildSurface function which will populate the surface with game objects.
 *
 */
- (void) okToBeginGameForSurface:(GSurface *)surf {

    if(surf) {

        if(surf.gnarly_preloadView) {
        [surf.gnarly_preloadView destroy];
        }
        
    [surf preloaderIsDestroyed];

        surf.animationInterval = 1.0 / gRenderingFrequency;
    [surf renderScene];
    [surf gnarlySaysStartSounds];

    }
  
}



/**
 * remove and immediately destroy surface with a specific key.
 *
 */
- (void) removeSurfaceWithKey:(NSString *)key {
GSurface *sfc = [allSurfaces objectForKey:key];

    if(sfc) {
    [sfc destroy];
    } else {
    NSLog(@"Error: Gnarly: -->  removeSurfaceWithKey:(NSString *)key: surface for key %@%@",key,@" does not exist.");
    }

}


/**
 * you can either call removeSurfaceWithKey, or you can call destroy on a surface directly.
 * in either case, the surface will call this function and make sure that its reference
 * is removed from the internal Gnarly dictionary.
 *
 */
- (void) removeSurfaceFromGnarlyDictionary:(GSurface *)sfc {
[allSurfaces removeObjectForKey:sfc.surfaceKey];
}


/**
 * during surface transactions, a view, preloading view or preloading sprite will
 * receive a gnarlySaysWindDown message. In response, those classes send Gnarly
 * this message, and Gnarly sorts out what to do based on who the caller is.
 *
 */
- (void) windDownFinishedContinueTransaction:(id <GSurfaceTransactor>)actor {
int type = actor.gnarly_SurfaceTransactor_transactorType;

    //if it's 1, then it's a preloader sprite.
    if(type == 1) {
    //NSLog(@"Gnarly: windDownFinishedContinueTransaction: type=1");

        if(actor.gnarly_SurfaceTransactor_forReplacement == YES) {
        [actor.gnarly_SurfaceTransactor_oldSurface gnarlySaysWindDownSurface];
        [actor.gnarly_SurfaceTransactor_oldSurface gnarlySaysEndLoadingSprite:(GLoadSprite *)actor];
        [actor gnarlySaysConfigureForEnd];
        } else {
        actor.gnarly_SurfaceTransactor_readyToContinueTransaction = YES;
        }
        
    } else
    //if it's 2 then its a preloader view.
    if(type == 2) {
    //NSLog(@"Gnarly: windDownFinishedContinueTransaction: type=2");

    //if the main view exists, the continue the process. if the main view
    //does not exist, then just destroy the preloader.
    GSurface *mainView = [actor gnarly_SurfaceTransactor_getMainView];
        if(mainView) {
        [[Gnar ly] okToBeginGameForSurface:mainView];
        } else {
        [(GLoadView *)actor destroy];
        }
    
    //[[Gnar ly] okToBeginGameForSurface:[actor gnarly_SurfaceTransactor_getMainView]];
    
    } else 
    //else, if it's 3, then it's a regular surface.
    if(type == 3) {
    //NSLog(@"Gnarly: windDownFinishedContinueTransaction: type=3");
    actor.gnarly_SurfaceTransactor_isWoundDown = YES;
    }

}



/////////////////////////   
//  for app delegates  //
/////////////////////////

/**
 * this is called from the applicationWillResignActive delegate. you don't need to pause the animation timer here. Do something extra
 * if you need to, but DO NOT CREATE any new textures or anything that would require the attention of the GPU- that will guarantee 
 * a crash for the app.
 *
 */
- (void) applicationWillResignActiveForSurface:(GSurface *)surf {
[surf stopAnimation];

    
    if(surf.gnarly_pauseOnReturnFromBackground == YES) {
    //you have to stop all the music playing here because otherwise it will start playing automatically when the
    //app returns from the background and you don't want that if you have a pause screen up.
    [[GAudio sharedSoundManager] stopCommonMusic];
    [[GAudio sharedSoundManager] pauseCommonSounds];
    }
    
[surf pauseAllSounds];
     

}



/**
 * called on applicationDidBecomeActive delegate. If the surface is configured for a pause screen to
 * appear vis-a-vis the pauseOnReturnFromBackground property, then this function will make sure that
 * the pause screen appears. Else, just start the animation.
 *
 * If you override this function for some reason, make sure you call the super method.
 *
 */
- (void) applicationDidBecomeActiveForSurface:(GSurface *)surf {
    
    if(surf.gnarly_pauseOnReturnFromBackground == YES) {
    [surf pauseGameAndZapToOverlay];
    } else {
    [surf startAnimation];
    }
    
}


/** 
 * fire these methods in the application delegates, and Gnarly will behave properly
 * throughout the lifetime of the app. In theory.
 *
 */
- (void) applicationDidReceiveMemoryWarning {}

- (void) applicationWillResignActive {
appResignedActive = YES;

    //for(NSString *key in allSurfaces) {
    //[[Gnar ly] applicationWillResignActiveForSurface:[allSurfaces valueForKey:key]];
    //}
    for(int i=0; i<[allSurfaces.allKeys count]; i++) {
    [[Gnar ly] applicationWillResignActiveForSurface:[allSurfaces valueForKey:[allSurfaces.allKeys objectAtIndex:i]]];
    }

}
- (void) applicationDidBecomeActive {
    //this thing will fire when the app first fires up. we only want it to fire
    //after the app has been sent to the backgrouna dnd brought back out. the 
    //toggling appResignedActive variable assures that this is the case.
    if(appResignedActive == YES) {
    appResignedActive = NO;

        //for(NSString *key in allSurfaces) {
        for(int i=0; i<[allSurfaces.allKeys count]; i++) {
        //[[Gnar ly] applicationDidBecomeActiveForSurface:[allSurfaces valueForKey:key]];
        [[Gnar ly] applicationDidBecomeActiveForSurface:[allSurfaces valueForKey:[allSurfaces.allKeys objectAtIndex:i]]];
        }
        
    } 

}


/**
 * called on applicationDidEnterBackground. If you need to save game states to the disk, this is the place to do it.
 *
 */
- (void) applicationDidEnterBackgroundForSurface:(GSurface *)surf {
[surf gnarlySaysSaveUserData];
}



/**
 
 You should use this method to release shared resources, save user data, invalidate timers, and store enough application state information 
 to restore your application to its current state in case it is terminated later. You should also disable updates to your application’s user 
 interface and avoid using some types of shared system resources (such as the user’s contacts database). It is also imperative that you 
 avoid using OpenGL ES in the background.
 
 **/
- (void) applicationDidEnterBackground {
   
    for(int i=0; i<[allSurfaces.allKeys count]; i++) {
    [[Gnar ly] applicationDidEnterBackgroundForSurface:[allSurfaces valueForKey:[allSurfaces.allKeys objectAtIndex:i]]];
    }
    
    //dont change this
    [self dataSave];

}


/**
 * destroy Gnarly and every surface, resource and renderable object contained therein.
 * call dealloc manually.
 *
 */
- (void) applicationWillTerminate {
    
    //loop through and destroy all living surfaces.
    int count = (int)[allSurfaces.allKeys count];
    for(int i=0; i<count; i++) {
    [[allSurfaces valueForKey:[allSurfaces.allKeys objectAtIndex:0]] destroy];
    }

//dont change this
[[GAudio sharedSoundManager] shutdownSoundManager];
    
    if(hasWindow == YES) {
    [_sharedWindow release];
    }
    
    if(singletonInit == YES) {
    [_sharedManager dealloc];
    }
    
[self dealloc];
}



 /////////////
 //         //
 //  A P I  //
 //         //
 /////////////


//////////////////////////
// platform information //
//////////////////////////
- (BOOL) is_iPad {
return is_iPad;
}
- (BOOL) is_iPadMini {
return is_iPadMini;
}
- (BOOL) is_iPhone {
return is_iPhone;
}
- (BOOL) is_iPodTouch {
return is_iPodTouch;
}
- (int) generationNumber {
return generationNumber;
}
- (BOOL) isRetina {
return isRetina;
}
- (NSString *) platformString {
return platformString;
}

//here's some function to help you control the inflection of the
//atlas class urls and class names.
- (void) UA_setHighResolutionAtlasToken:(NSString *)token {
highResolutionAtlasToken = token;
}
- (void) UA_setIPadAtlasToken:(NSString *)token {
iPadAtlasToken = token;
}
- (void) UA_setIPhoneAtlasToken:(NSString *)token {
iPhoneAtlasToken = token;
}
- (void) UA_setIPadMiniAtlasToken:(NSString *)token {
iPadMiniAtlasToken = token;
}
- (void) UA_setIPodAtlasToken:(NSString *)token {
iPodAtlasToken = token;
}
- (void) UA_setAtlasTokenDelimiter:(NSString *)delimiter {
atlasTokenDelimiter = delimiter;
}
- (void) UA_setManageDeviceAtlasInflectionManually:(BOOL)yesOrNo {
manageDeviceAtlasInflectionManually = yesOrNo;
}
- (void) UA_setIPadMiniWillTokenizeResourcesAsIPad:(BOOL)yesOrNo {
iPadMiniWillTokenizeResourcesAsIPad = yesOrNo;
}
- (void) UA_setIPodTouchWillTokenizeResourcesAsIPhone:(BOOL)yesOrNo {
iPodTouchWillTokenizeResourcesAsIPhone = yesOrNo;
}


/**
 * if the tokens are appended, then
 *
 * MyTexture.png will become MyTexture_iPad_HiRes.png
 * 
 * if the tokens are prepended, then
 * 
 * MyTexture.png will become iPad_HiRes_MyTexture.png
 *
 */
- (void) UA_setDeviceTokensWillAppend {
deviceTokensWillPrependOrAppend = NO;
}
- (void) UA_setDeviceTokensWillPrepend {
deviceTokensWillPrependOrAppend = YES;    
}
 
 ////////////////////////////////////////////
 // create/destroy resouces at render-time //
 ////////////////////////////////////////////

/**
 * The surface is running, but there's some more resources you want to load. So load them in the background with this function. When
 * it's finished, it will send a message to the observer to let it know that the new resources are ready for use.
 *
 */
- (void) createNewResourcesForKey:(NSString *)key withCallback:(NSString *)cllbck andObserver:(id)obs forSurface:(GSurface *)surf {
    
    if(surf.isUnglued == NO) {

    GAsynchronousLoadingData *gData = [[GAsynchronousLoadingData alloc] initWithKey:key callback:cllbck observer:obs andPreloadFlag:NO];
        
        //New 2014-02-03. Each surface keeps track of which resources are loading.
        //this will log a new resource request in the surface, and if the request has
        //already been made, it will return false and this function will bail out.
        if(![surf resourceRequests_logNewResourceRequestForKeyForGnarly:key] ) {
        return;
        }

    //record the related surface.
    gData.relatedSurface = surf;

    //start the timer to monitor the progress of the resource-loading routine.
    NSTimer* loadTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkLoadProgress:) userInfo:gData repeats:YES];
    
    //set the loading tomer on the gData object.
    gData.loadingTimer = loadTimer;
    
    //this is for in-surface-loading, not preloading, so flag it.
    //CHANGED THIS.
    gData.forMultiThread = YES;
    
    //increment the number of background processes going on.
    [surf incrementNumberBackgroundProcesses];
    
    //2012-05-16: log key of the new resource list in the array so that we can get at it later.
    [surf.gnarly_keysOfResourceLists addObject:key];

    //load the resources in a separate thread. put in the gData so that the function knows that we're not in a preloading situation.
    [NSThread detachNewThreadSelector:@selector(loadResoucesInTheBackground:) toTarget:self withObject:gData];
    
    
    //You can test to see that a surface can be safely destroyed while it's loading resources, and nothing
    //terrible will happen.
    //[surf destroy];
    
    }
 
}


/**
 * the surface is running, but you don't need some of the resources anymore. So blow them up.
 * unlike the above loading function, this guy just cranks in the main thread. I don't see a need to
 * blow stuff up in the background, although maybe that will change if I notice that it's causing a
 * tick in the animation this way.
 * 
 */
- (void) destroyResourcesForKey:(NSString *)key forSurface:(GSurface *)surf {
    
    //NSLog(@"destroyResourcesForKey:%@",key);

    if(surf.isUnglued == NO) {
        
        if(!key) {
        NSLog(@"Error: GSurface: destroyResourcesForKey: key parameter doesn't exist. This function will not execute.");
        return;
        }
        
        //New 2014-02-03 if the resources are still loading, then bail out.
        //A flag will be set in the surface so that when the resources finish
        //loading, they will be immediately destroyed.
        if(![surf resourceRequests_checkResourcesAreStillLoadingForKeyForGnarly:key]) {
        return;
        }
        
        NSMutableArray *keys = surf.gnarly_keysOfResourceLists;

        //make sure that the resource list we're getting rid of
        //was loaded into this surface.
        if(![keys containsObject:key]) {
        NSLog(@"Error: the key was not found in here! %@",key);
        int yy = (int)keys.count;
        
            for(int rr=0; rr<yy; rr++) {
            NSLog(@"key of the resource lists: %@",[keys objectAtIndex:rr]);
            }
        
        return;
        } 

    NSMutableArray *resList = [[Gnar ly] getResourceListForKey:key];
    int len=(int)resList.count;
    int k=0;
    GResource *res;
    
    //set this so that the opengl resources are deleted properly
    [surf makeContextCurrent];

        //loop through and destroy.
        for(k=0; k<len; k++) {
        res = [resList objectAtIndex:k]; 
            
            //if the resourceType is 0, then we're deleting texture data.
            if(res.resourceType == 0) {
            [surf.gnarly_cachedAtlases removeObjectForKey:res.key];
            } else

            //else, if the resourceType is 1, then we're deleting a sprite map. These should go lickity-split
            if(res.resourceType == 1) {
            } else

            //if resourceType is 2, then we're deleting a sound resource.
            if(res.resourceType == 2) { //22050  44100  WAS 22050

               //take responsibility for deleting this sound if the sound
               //is only meant to survive for the lifetime of this view.
               if(res.ownedBySurface == YES) {
               [[GAudio sharedSoundManager] deleteSoundWithKey:res.key];
               }
               
            } else

            //if resource type is 3, then  we're deleting background music.
            if(res.resourceType == 3) {

                //take responsibility for deleting this sound if the sound
                //is only meant to survive for the lifetime of this view.
                if(res.ownedBySurface == YES) {
                [[GAudio sharedSoundManager] deleteSoundWithKey:res.key];
                }
               
            }
            
        }
    
    //remove the key from the list of keys associated with this surface.
    [keys removeObject:key];
    }
 
}



/**
 * maybe we don't need one of the resources in a resource list any more. 
 * so get rid of it. you just need the key and the list name.
 *
 */
- (void) destroyResourceFromList:(NSString *)listKey withKey:(NSString *)recKey forSurface:(GSurface *)surf {

    if(surf.isUnglued == NO) {

        if(!listKey || !recKey) {
        NSLog(@"Error: GSurface: destroyResourceFromList:withKey one of the parameters doesn't exist. This function will not execute.");
        return;
        }

        //make sure that the resource list we're getting rid of
        //was loaded into this surface.
        if(![surf.gnarly_keysOfResourceLists containsObject:listKey]) {
        NSLog(@"Error: the key was not found in here! %@",listKey);
        return;
        }

    NSMutableArray *resList = [[Gnar ly] getResourceListForKey:listKey];
    int len=(int)resList.count;
    int k=0;
    GResource *res;
    NSString *ky;
    int resType;
    
    //set this so that the opengl resources are deleted properly
    [surf makeContextCurrent];

        //loop through and destroy.
        for(k=0; k<len; k++) {
        res = [resList objectAtIndex:k]; 
        ky = res.key;
        resType = res.resourceType;
            
            //if the resourceType is 0, then we're deleting texture data.
            if(resType == 0 && [ky isEqualToString:recKey] == YES) {
            [surf.gnarly_cachedAtlases removeObjectForKey:ky];
            } else

            //else, if the resourceType is 1, then we're deleting a sprite map. These should go lickity-split
            if(resType == 1 && [ky isEqualToString:recKey] == YES) {
            } else

            //if resourceType is 2, then we're deleting a sound resource.
            if(resType == 2 && [ky isEqualToString:recKey] == YES) { //22050  44100  WAS 22050

               //take responsibility for deleting this sound if the sound
               //is only meant to survive for the lifetime of this view.
               if(res.ownedBySurface == YES) {
               [[GAudio sharedSoundManager] deleteSoundWithKey:ky];
               }
               
            } else

            //if resource type is 3, then  we're loading background music.
            if(res.resourceType == 3 && [ky isEqualToString:recKey] == YES) {

                //take responsibility for deleting this sound if the sound
                //is only meant to survive for the lifetime of this view.
                if(res.ownedBySurface == YES) {
                [[GAudio sharedSoundManager] deleteSoundWithKey:res.key];
                }
               
            }
            
        }
    
    }
    
}


//////////////////////////
// surface transactions //
//////////////////////////


/**
 * add a surface with a key to a specific list of resources  triggers the add-transaction.
 *
 */
- (GSurface *)addNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key {
//get the coupled pair of resources and options for the surface.
GOptionAndResourceList *pair = [allResOpLists objectForKey:key];

    if(pair) {
    
    //generate the unique key for the surface
    NSString *surfaceKey = @"g";
    surfaceKey = [surfaceKey stringByAppendingFormat:@"%d",numSurfaces];
    
    //get the class of the surface.
    Class cls = NSClassFromString(sfcClass);

        if(cls) {
        numSurfaces++;
        //create the surface
        GSurface *sfc = [[cls alloc] initWithResources:pair andResourceKey:key];
        
        //log the surface into the dictionary so that it's globally available
        [allSurfaces setObject:sfc forKey:surfaceKey]; 
                
        //position it, start the animation and insert into the display list.
            sfc.animationInterval = 1.0 / gRenderingFrequency;
        sfc.center = CGPointMake(_centerXForViews,_centerYForViews);
        //[_sharedWindow addSubview:sfc];
        [_sharedWindow.rootViewController.view addSubview:sfc];
        sfc.userInteractionEnabled = YES;
        
        //assign the key.
        sfc.surfaceKey = surfaceKey;
        return sfc;
        } else {
        NSLog(@"Error: Gnarly: --> - (NSString *)addNewSurface:(NSString *)sfcClass withResourceList:(NSMutableArray *)list: no class %@%@",sfcClass,@" exists.");
        return nil;
        }   
    
    } else {
    NSLog(@"Error: Gnarly -->  addNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key resource list for key %@%@",key,@" does not exist.");
    return nil;
    }
    
}



/**
 * insert a new surface above an existing surface. triggers the add-above-transaction.
 *
 */
- (GSurface *)addNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key aboveSurface:(GSurface *)otherSfc {

    if(otherSfc.isUnglued == NO) {

    //get the coupled pair of resources and options for the surface.
    GOptionAndResourceList *pair = [allResOpLists objectForKey:key];

        if(pair) {
        
        //generate the unique key for the surface
        NSString *surfaceKey = @"g";
        surfaceKey = [surfaceKey stringByAppendingFormat:@"%d",numSurfaces];
        
        //get the class of the surface.
        Class cls = NSClassFromString(sfcClass);

            if(cls) {
            numSurfaces++;
            //create the surface
            GSurface *sfc = [[cls alloc] initWithResources:pair andResourceKey:key];
             
            //log the surface into the dictionary so that it's globally available
            [allSurfaces setObject:sfc forKey:surfaceKey]; 
            
            //position it, start the animation and insert into the display list.
                sfc.animationInterval = 1.0 / gRenderingFrequency;
            sfc.center = CGPointMake(_centerXForViews,_centerYForViews);
            //[_sharedWindow insertSubview:sfc aboveSubview:otherSfc];
            [_sharedWindow.rootViewController.view insertSubview:sfc aboveSubview:otherSfc];
                
            //assign the key.
            sfc.surfaceKey = surfaceKey;
            
            //return focus to the original surface.
            [otherSfc makeContextCurrent];
            [GSurface setCurrentView:otherSfc];
            
            
            return sfc;
            } else {
            NSLog(@"Error: Gnarly: --> - (NSString *)addNewSurface:(NSString *)sfcClass withResourceList:(NSMutableArray *)list: no class %@%@",sfcClass,@" exists.");
            return nil;
            }   
        } 
        
        //if no pair exists for the key, then do nothing.
        else {
        NSLog(@"Error: Gnarly: addNewSurface:withResourceList:aboveMainSurface. No resources list exists for key: %@",key);
        return nil; 
        }
    
    
    } else {
    return nil;
    }
    
}




/**
 * this will trigger an overlay-transaction between two surfaces. At the end of the transaction, the old
 * surface won't exist anymore, and the new surface will be chugging along.
 *
 * The overlay-transaction is very similar to the replacement-transaction. The only difference is that the old
 * surface continues to exist after the overlay-transaction is completed, and the preload sprite has to self-destruct.
 *
 *  --When this function is called, the new surface is created and configured according to the options specified in its
 *  resouce list.
 *
 *  --The new surface is added to the display list. it will load all of its resources in the background.
 *
 *     --If the surface is configured to have a preload sprite, then the new surface will be instructed to create 
 *     a preload sprite and add it to the old surface. The class of the preload sprite gets determined in the 
 *     resource list for the new surface, but the sprite has all of the resources of the *old* surface available to it.
 *    
 *          --An indeterminate amount of time passes while the new surface loads all of it resources on a separate thread.
 *
 *          --The new surface's resources are done loading, so it sends the wind-down message to its preloading sprite, which 
 *          is ensconced on the old surface.
 *     
 *          --The sprite may or may not execute its own wind down animation. but whatever the case, it has to call the
 *          wind-down function on the old surface. during this time, the sprite is passively monitoring the state 
 *          of the old surface's gnarly_SurfaceTransactor_isWoundDown property.
 *
 *          --Upon receiving the gnarlySaysWindDown command, the old surface may choose to execute an animation on its graphical elements,
 *          or it may not. Whatever the case, when the old surface is content with the balance of its earthly existence, it
 *          calls a function which will set its gnarly_SurfaceTransactor_isWoundDown flag to YES.
 *
 *          --The preloading sprite notices on its next frame of render that the old surface has changed its gnarly_SurfaceTransactor_isWoundDown flag
 *          from NO to YES, indicating that the preload sprite is free to end the transaction.
 *
 *          --The preload sprite ends the transaction by sending the okToBeginGame message to the new surface, which triggers the
 *          rendering loop of the new surface. the old continues to exist. the preloading sprite self-destructs.
 *
 *     --Else, if the new surface is not configured for a preload sprite, The new surface will load its resources on a separate thread 
 *     as usual. It may or may not have a preload view, which is determined in the resource list for the new surface and is a wholly 
 *     separate process from the replacement transaction.
 *
 *
 */
- (GOverlayView *)addNewOverlayView:(NSString *)sfcClass withResourceKey:(NSString *)key aboveMainSurface:(GSurface *)otherSfc {
    
    if(otherSfc.isUnglued == NO) {

    //get the coupled pair of resources and options for the surface.
    GOptionAndResourceList *pair = [allResOpLists objectForKey:key];

        if(pair) {
        //generate the unique key for the surface
        NSString *surfaceKey = @"g";
        surfaceKey = [surfaceKey stringByAppendingFormat:@"%d",numSurfaces];
        
        //get the class of the surface.
        Class cls = NSClassFromString(sfcClass);

            if(cls) {
            numSurfaces++;
            //create the surface
            GOverlayView *sfc = [[cls alloc] initWithResources:pair withResourceKey:key andMainView:otherSfc];
            
            //log the surface into the dictionary so that it's globally available
            [allSurfaces setObject:sfc forKey:surfaceKey]; 
            
            //position it.
            sfc.center = CGPointMake(_centerXForViews,_centerYForViews);
            
            //assign the key.
            sfc.surfaceKey = surfaceKey;
            
                //if the new surface is supposed to trigger a preloader sprite, then tell
                //the old surface to create them.
                
                
                if(pair.hasPreloaderSprite == YES) {
                [self surface:sfc mustCreateLoadingSprite:pair.preloaderClassName forOldSurface:otherSfc forReplacement:NO withData:_transData];
                
                
                //add the surface to the display list after the preload sprite is done getting created, because
                //adding the new surface will trigger a multi-threaded process which will need to access the current
                //view of GSurface. We can't guarantee that it won't be asking for that resource at the same time
                //that the surfaceMustCreateLoadingSprite is changing it. 
                //[_sharedWindow insertSubview:sfc aboveSubview:otherSfc];
                [_sharedWindow.rootViewController.view insertSubview:sfc aboveSubview:otherSfc];
                    
                } 
                //else, just insert it.
                else {
                
                //no multithreading is occuring, so just add it in before the old surface gets destroyed.
                //[_sharedWindow insertSubview:sfc aboveSubview:otherSfc];
                [_sharedWindow.rootViewController.view insertSubview:sfc aboveSubview:otherSfc];
                    
                }
                
            //return focus to the original surface.
            [otherSfc makeContextCurrent];
            [GSurface setCurrentView:otherSfc];
            
            
            return sfc;
            } else {
            NSLog(@"Error: Gnarly: --> - (NSString *)addNewSurface:(NSString *)sfcClass withResourceList:(NSMutableArray *)list: no class %@%@",sfcClass,@" exists.");
            return nil;
            }   

        } else {
        NSLog(@"Error: Gnarly -->  addNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key resource list for key %@%@",key,@" does not exist.");
        return nil;
        }
    
    } else {
    return nil;
    }
    
}




/**
 * this will trigger a replace-transaction between two surfaces. At the end of the transaction, the old
 * surface won't exist anymore, and the new surface will be chugging along.
 *
 * The replacement transaction is complicated. The basic idea is that there are three actors- the old surface, the new
 * surface, and the preloading sprite. There's a number of steps to this dance- a preloading sprite of a certain type
 * must be created and placed on the old surface. The new surface must load its resource on a separate thread. The old 
 * surface must take its final bow when the new surface is ready to assume the limelite. There's a lot that can go wrong,
 * so the general idea is that the old surface does not know about the new surface or the preloading sprite. The new surface
 * knows about the preloading sprite, but not the old surface. The preloading sprite knows about the old surface and the 
 * new surface. In this way, the preloading sprite brokers the replacement transaction between the old and new surfaces,
 * and neither of those views have the ability to pollute each other during the course of the transaction. (The preloading
 * sprite is a base-class and easily extensible.) Here's the play-by-play of the events this function sets in motion.
 *
 *  --When this function is called, the new surface is created and configured according to the options specified in its
 *  resouce list.
 *
 *  --The new surface is added to the display list. it will load all of its resources in the background.
 *
 *     --If the surface is configured to have a preload sprite, then the new surface will be instructed to create 
 *     a preload sprite and add it to the old surface. The class of the preload sprite gets determined in the 
 *     resource list for the new surface, but the sprite has all of the resources of the *old* surface available to it.
 *    
 *          --An indeterminate amount of time passes while the new surface loads all of it resources on a separate thread.
 *
 *          --The new surface's resources are done loading, so it sends the wind-down message to its preloading sprite, which 
 *          is ensconced on the old surface.
 *     
 *          --The sprite may or may not execute its own wind down animation. but whatever the case, it has to call the
 *          wind-down function on the old surface. during this time, the sprite is passively monitoring the state 
 *          of the old surface's gnarly_SurfaceTransactor_isWoundDown property.
 *
 *          --Upon receiving the gnarlySaysWindDown command, the old surface may choose to execute an animation on its graphical elements,
 *          or it may not. Whatever the case, when the old surface is content with the balance of its earthly existence, it
 *          calls a function which will set its gnarly_SurfaceTransactor_isWoundDown flag to YES.
 *
 *          --The preloading sprite notices on its next frame of render that the old surface has changed its gnarly_SurfaceTransactor_isWoundDown flag
 *          from NO to YES, indicating that the preload sprite is free to end the transaction.
 *
 *          --The preload sprite ends the transaction by sending the okToBeginGame message to the new surface, which triggers the
 *          rendering loop of the new surface. the old surface is then sent a destroy message.
 *
 *     --Else, if the new surface is not configured for a preload sprite, then the old surface will be destroyed immediately. The
 *     new surface will load its resources on a separate thread as usual. It may or may not have a preload view, which is
 *     determined in the resource list for the new surface and is a wholly separate process from the replacement transaction.
 *
 *
 */
- (GSurface *) replace:(GSurface *)oldSurf withNewSurface:(NSString *)sfcClass withResourceKey:(NSString *)key {

    if(oldSurf.isUnglued == NO) {

    //get the coupled pair of resources and options for the surface.
    GOptionAndResourceList *pair = [allResOpLists objectForKey:key];

        if(pair) {

        //generate the unique key for the surface
        NSString *surfaceKey = @"g";
        surfaceKey = [surfaceKey stringByAppendingFormat:@"%d",numSurfaces];
        
        //get the class of the surface.
        Class cls = NSClassFromString(sfcClass);

            if(cls) {
            numSurfaces++;
            
            //destroy the underneath view if this thing is an overlay,
            //just like the function says.
            [oldSurf removeUnderneathViewIfOverlay];
            
            //create the surface
            GSurface *sfc = [[cls alloc] initWithResources:pair andResourceKey:key];
            
            //log the surface into the dictionary so that it's globally available
            [allSurfaces setObject:sfc forKey:surfaceKey];
            
            //position it.
            sfc.center = CGPointMake(_centerXForViews,_centerYForViews);
        
            //assign the key.
            sfc.surfaceKey = surfaceKey;
            
                //if the new surface is supposed to trigger a preloader sprite, then tell
                //the old surface to create them.
                if(pair.hasPreloaderSprite == YES) {
                [self surface:sfc mustCreateLoadingSprite:pair.preloaderSpriteClassName forOldSurface:oldSurf forReplacement:YES withData:_transData];
                
                //add the surface to the display list after the preload sprite is done getting created, because
                //adding the new surface will trigger a multi-threaded process which will need to access the current
                //view of GSurface. We can't guarantee that it won't be asking for that resource at the same time
                //that the surfaceMustCreateLoadingSprite is changing it. 
                //[_sharedWindow insertSubview:sfc aboveSubview:oldSurf];
                [_sharedWindow.rootViewController.view insertSubview:sfc aboveSubview:oldSurf];
                    
                } 
                //else, just destroy the old one.
                else {
                
                //no multithreading is occuring, so just add it in before the old surface gets destroyed.
                //[_sharedWindow insertSubview:sfc aboveSubview:oldSurf];
                [_sharedWindow.rootViewController.view insertSubview:sfc aboveSubview:oldSurf];
                    
                [oldSurf destroy];
                }
                
            //HEY BUTTFACE: I just commented these two lines out. It fixed the
            //flicker issue. I need to figure out exactly why it fixed it.
            //switch focus to the new surface.
            //[sfc makeContextCurrent];
            //[GSurface setCurrentView:sfc];
            
            return sfc;
            //return nil;
            } else {
            NSLog(@"Error: Gnarly: --> - (NSString *)addNewSurface:(NSString *)sfcClass withResourceList:(NSMutableArray *)list: no class %@%@",sfcClass,@" exists.");
            return nil;
            }   

        }
        
        //if no pair exists for the key, then do nothing.
        else {
        return nil; 
        }
    
    } else {
    return nil;
    }
    
}


/**
 * set this anytime, and the next part of the current surface transaction will have access to it.
 *
 */
- (void) useDataForNextLoadSprite:(GSurfaceData)d {
_transData = d;
}


//////////
// misc //
//////////


/**
 * describe gnarly to the curious developer.
 *
 */
- (void) describeGnarly {

NSLog(@"///////////////////////////////////////////////////////////////////////////");
NSLog(@"//");
NSLog(@"//  Gnarly:  %@",gnarlyVersion);
NSLog(@"//");
NSLog(@"//  2D game engine for iOS, author Alex Lowe.");
NSLog(@"//");
NSLog(@"//  Copyright 2011 Alex Lowe. See Licence. Not open-source yet.");
NSLog(@"//");
NSLog(@"///////////////////////////////////////////////////////////////////////////");

}



/**
 * return a surface for a specific key.
 *
 */
- (GSurface *) getSurfaceForKey:(NSString *)sfcCode {
return [allSurfaces objectForKey:sfcCode];
} 



/**
 * return the shared window object.
 *
 */
- (UIWindow *) sharedWindow {

    if(hasWindow == NO) {
    hasWindow = YES;
	CGRect rect = [[UIScreen mainScreen] bounds];
	_sharedWindow = [[UIWindow alloc] initWithFrame:rect];
	[_sharedWindow makeKeyAndVisible];
    }

return _sharedWindow;
}




/**
 * send a message to a surface with a specific key.
 *
 */
- (void) pingSurface:(NSString *)key withMsg:(SEL)message anObject:(id)info {

GSurface *sfc = [allSurfaces objectForKey:key];

    if(sfc) {
    [sfc performSelector:message withObject:info];
    } else {
    NSLog(@"Error: Gnarly: -->  pingSurface:(NSString *)key withMsg:(SEL)message anObject:(id)info: surface for key %@%@",key,@" does not exist.");
    }

}



////////////////////////////////////////////////////////////////
//  add information about what resources and options we need  //
//  for all the surfaces we'll create                         //
////////////////////////////////////////////////////////////////


/**
 * start a new resource list with a specific key. This is the only procedural-style thing in Gnarly. You begin a new list with
 * this function, and then use the newSound/Music/Texture/Map functions below to specify what should go into it.
 *
 */
- (void) newResourceListForKey:(NSString *)key {
 //   if([allResOpLists objectForKey:key] != nil) {
cyclingResOpList = [[GOptionAndResourceList alloc] init];
[allResOpLists setObject:cyclingResOpList forKey:key];
//tick down the retain count so that the only surviving reference is in the dictionary.
[cyclingResOpList release];
  //  } else {
  //  }
}


/**
 * return a pointer to the resource list for a key. This is to be used to load resources at run time in a surface.
 *
 */
- (NSMutableArray *) getResourceListForKey:(NSString *)key {

GOptionAndResourceList *lst = [allResOpLists objectForKey:key];

    if(lst) {
    return lst.resources;
    } else {
    NSLog(@"Error: Gnarly getCopyOfResourceListForKey: There is no option/resource list for key %@",key);
    return nil;
    }

}


/**
 * add sound, music, textures and sprite maps to the resource list. pretty self-explanatory.
 *
 */
- (void) newSound:(NSString *)ky fileName:(NSString *)file extension:(NSString *)ext ownedBySurface:(BOOL)del {

    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
    [cyclingResOpList addResource:[[GResource alloc] initSound:ky fileName:file extension:ext ownedBySurface:del]];
    }

}
- (void) newMusic:(NSString *)ky fileName:(NSString *)file extension:(NSString *)ext ownedBySurface:(BOOL)del {

    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
    [cyclingResOpList addResource:[[GResource alloc] initMusic:ky fileName:file extension:ext ownedBySurface:del]];
    }

}
- (void) newAtlas:(NSString *)ky withFile:(NSString *)file extension:(NSString *)ext andMap:(NSString *)clss {

    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
        if(manageDeviceAtlasInflectionManually == YES) {
        [cyclingResOpList addResource:[[GResource alloc] initTexture:ky withFile:file extension:ext andMap:clss]];
        } else {
            
        NSString *retinaString;
        NSString *deviceToken;
        NSString *tokenedFile;
        NSString *tokenedClassName;
            
            if(isRetina) {
                if([highResolutionAtlasToken isEqualToString:@""]) {
                retinaString = @"";
                } else {
                    if(deviceTokensWillPrependOrAppend == NO) {
                    retinaString = [atlasTokenDelimiter stringByAppendingString:highResolutionAtlasToken];
                    } else {
                    retinaString = [highResolutionAtlasToken stringByAppendingString:atlasTokenDelimiter];    
                    }
                }
            } else {
            retinaString = @"";
            }
            
            //NSLog(@"retina string: %@",retinaString);
            
            //get the device token. we may have told the api that iPad Mini
            //should have the same resources as the iPad, or that the iPod Touch
            //should have the same resources as the iPhone.
            if(is_iPhone) {
            deviceToken = iPhoneAtlasToken;
            } else
            if(is_iPad) {
            deviceToken = iPadAtlasToken;
            } else
            if(is_iPadMini) {
                if(iPadMiniWillTokenizeResourcesAsIPad == YES) {
                deviceToken = iPadAtlasToken;        
                } else {
                deviceToken = iPadMiniAtlasToken;
                }
            } else
            if(is_iPodTouch) {
                if(iPodTouchWillTokenizeResourcesAsIPhone == YES) {
                deviceToken = iPhoneAtlasToken;
                } else {
                deviceToken = iPodAtlasToken;
                }
            }
            
            //2017-07-07 launch- jury rigging this
            deviceToken = iPhoneAtlasToken;
            //because we need all devices to read as iPhone for the device-token
            //apparently this is supposed to run on iPads as well.
            //////////////////////////////////
            
            //if we're supposed to append the tokens to the end of the class name and texture resource
            if(deviceTokensWillPrependOrAppend == NO) {
            tokenedFile = [file stringByAppendingFormat:@"%@%@%@",atlasTokenDelimiter,deviceToken,retinaString];
            tokenedClassName = [clss stringByAppendingFormat:@"%@%@",atlasTokenDelimiter,deviceToken];
            }
            
            //else if we're supposed to prepend the tokens to the front of the class name and texture resource
            else {
            tokenedFile = [deviceToken stringByAppendingFormat:@"%@%@%@",atlasTokenDelimiter,retinaString,file];
            //NSLog(@"Gnarly: tokenedFile: %@%@%@",tokenedFile,@"  retinaString: ",retinaString);
            tokenedClassName = [deviceToken stringByAppendingFormat:@"%@%@",atlasTokenDelimiter,clss];
            }
        
        [cyclingResOpList addResource:[[GResource alloc] initTexture:ky withFile:tokenedFile extension:ext andMap:tokenedClassName]];
        }
    }

}
- (void) newAtlas:(NSString *)ky extension:(NSString *)ext {
    
    if(!cyclingResOpList) {
        NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
        if(manageDeviceAtlasInflectionManually == YES) {
        [cyclingResOpList addResource:[[GResource alloc] initTexture:ky withFile:ky extension:ext andMap:ky]];
        } else {
            
            NSString *retinaString;
            NSString *deviceToken;
            NSString *tokenedFile;
            NSString *tokenedClassName;
            
            if(isRetina) {
                if(deviceTokensWillPrependOrAppend == NO) {
                retinaString = [atlasTokenDelimiter stringByAppendingString:highResolutionAtlasToken];
                } else {
                retinaString = [highResolutionAtlasToken stringByAppendingString:atlasTokenDelimiter];
                }
            } else {
            retinaString = @"";
            }
            
            //get the device token. we may have told the api that iPad Mini
            //should have the same resources as the iPad, or that the iPod Touch
            //should have the same resources as the iPhone.
            if(is_iPhone) {
            deviceToken = iPhoneAtlasToken;
            } else
            if(is_iPad) {
                deviceToken = iPadAtlasToken;
            } else
            if(is_iPadMini) {
                if(iPadMiniWillTokenizeResourcesAsIPad == YES) {
                deviceToken = iPadAtlasToken;
                } else {
                deviceToken = iPadMiniAtlasToken;
                }
            } else
            if(is_iPodTouch) {
                if(iPodTouchWillTokenizeResourcesAsIPhone == YES) {
                deviceToken = iPhoneAtlasToken;
                } else {
                deviceToken = iPodAtlasToken;
                }
            }
            
            //if we're supposed to append the tokens to the end of the class name and texture resource
            if(deviceTokensWillPrependOrAppend == NO) {
            tokenedFile = [ky stringByAppendingFormat:@"%@%@%@",atlasTokenDelimiter,deviceToken,retinaString];
            tokenedClassName = [ky stringByAppendingFormat:@"%@%@",atlasTokenDelimiter,deviceToken];
            }
            
            //else if we're supposed to prepend the tokens to the front of the class name and texture resource
            else {
            tokenedFile = [deviceToken stringByAppendingFormat:@"%@%@%@",atlasTokenDelimiter,retinaString,ky];
            tokenedClassName = [deviceToken stringByAppendingFormat:@"%@%@",atlasTokenDelimiter,ky];
            }
            
        [cyclingResOpList addResource:[[GResource alloc] initTexture:ky withFile:tokenedFile extension:ext andMap:tokenedClassName]];
        }
        
    }
    
}


- (void) newXML:(NSString *)ky withFile:(NSString *)file {

    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
    [cyclingResOpList addResource:[[GResource alloc] initXML:ky withFile:file]];
    }
    
}

- (void) newWorker:(NSString *)wrkr withOwner:(id)ownr {
    
    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
    [cyclingResOpList addResource:[[GResource alloc] initWorker:wrkr andOwner:ownr]];
    }
    
}



/**
 * specify that any surface which uses this resource list should load a preloader view. 
 * ##Note## this will have no effect if the resource list has been previously configures to 
 * load a preloader sprite. 
 *
 */
- (void) setPreloader:(NSString *)clss withResourceKey:(NSString *)key {

    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
        if(cyclingResOpList.hasPreloaderSprite == NO) {
        cyclingResOpList.hasPreloader = YES;
        cyclingResOpList.preloaderClassName = clss;
        cyclingResOpList.preloaderResourceKey = key;
        }
        
    }

}

/**
 * set a pause view for the surface. It already has a default one, but you can specify a different one here.
 *
 */
- (void) setPauseView:(NSString *)clss withResourceKey:(NSString *)key {

    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
    cyclingResOpList.hasPause = YES;
    cyclingResOpList.pauseClassName = clss;
    cyclingResOpList.pauseResourceKey = key;
    }

}

/**
 * specify a preloader sprite which will be used in replacment/overlay transactions. 
 * ##Note## setting a preloader sprite will negate the setting for the preloader view
 * if one is set for the resource list.
 *
 */
- (void) setPreloaderSprite:(NSString *)clss {

    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
    cyclingResOpList.hasPreloader = NO;
    cyclingResOpList.hasPreloaderSprite = YES;
    cyclingResOpList.preloaderSpriteClassName = clss;
    }

}

/**
 * determine whether the pause view will appear immediately for the surface when the 
 * application returns from the background.
 *
 */
- (void) setWillSurfacePauseOnReturnFromBackground:(BOOL)truth {

    if(!cyclingResOpList) {
    NSLog(@"Error: Gnarly: addResource:(GResource *)rec --> You have to call newResourceListForKey:(NSString *)key before you try to add a resource.");
    } else {
    cyclingResOpList.willSurfacePauseOnReturnFromBackground = truth;
    }

}





/////////////////////////////////////
// clocking for performance tests  //
/////////////////////////////////////

- (void) startClock {
_clockDate = [NSDate date];
[_clockDate retain];
_isClock = YES;
}
- (float) endClock {
    if(_isClock == YES) {
    NSTimeInterval diff = [_clockDate timeIntervalSinceNow];
    [_clockDate release];
    _isClock = NO;
    return (float) -diff;
    }
    
return 0;
}
- (void) logClock {
NSLog(@"End clock: %f",[self endClock]);
}
- (float) endClockAndGetFPS {

    if(_isClock == YES) {
    NSTimeInterval diff = [_clockDate timeIntervalSinceNow];
    [_clockDate release];
    
    _isClock = NO;
        if(diff == 0)
        return 0;

    return (-1/diff);
    } 

return 0;
}
- (void) logClockFPS {
NSLog(@"FPS Estimate: %f",[self endClockAndGetFPS]);
}


/**
 * used in the dealloc methods. helps debugging to see what objects have dealloced.
 *
 */
- (void) logDealloc:(NSObject *)ob {
//NSLog(@"Object %@%@",class_getName([ob class]),@" dealloced.");
}



/////////////////////////////
//  Data saving/retrieval  //
/////////////////////////////

/**
 * set the name of the app. it will be appended with the version number. you need to call this function before you
 * start doing things with any saved user settings or anything.
 *
 */
- (void) setNameOfAppAndLoadSettings:(NSString *)name {
    
    if(settingsLoaded == NO) {
        settingsLoaded = YES;
        uniqueNameOfApp = name;
        [self dataLoad];
    }
}


/**
 * open up or retrieve a data row from the current data row in focus.
 * upon return of this function, that new data row is in focus for
 * all of the other procedural functions to use.
 *
 */
- (void) dataOpen:(NSString *)key {
[self dataLoad];
    
NSMutableDictionary *mainData = proceduralSaveDictionary;
    
    if(!mainData) {
    mainData = _MAIN_APPLICATION_DATA_;
    }
    
    if([[mainData allKeys] containsObject:key] == NO) {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [mainData setObject:dict forKey:key];
    [dict release];
    proceduralSaveDictionary = dict;
    [dataStack addObject:proceduralSaveDictionary];
    } else {
    NSMutableDictionary *d = [mainData objectForKey:key];
        if([d isKindOfClass:[NSMutableDictionary class]]) {
        proceduralSaveDictionary = d;
        [dataStack addObject:proceduralSaveDictionary];
        } else {
        [NSException raise:@"Error" format:@"Gnarly: openData: The key %@%@",key,@" does not belong to a saved data row"];
        }
        
    }
    
}

/**
 * add a new data dictionary onto the current procedural data target.
 * Note- you must call the dataOpen function first to set the initial data.
 * This one will add children to the current procedural data, where as the one above
 * will only add a new level into the hierarchy.
 *
 */
- (void) dataChild:(NSString *)key {
    
	if([dataStack count] == 0) {
        [NSException raise:@"Error" format:@"Gnarly: dataChild: You must call dataOpen first to set the initial data node on which to place children"];
        return;
    }
    
    NSMutableDictionary *last = [dataStack lastObject];
    NSMutableDictionary *newD = [[NSMutableDictionary alloc] init];
    
    proceduralSaveDictionary = newD;
    [last setObject:newD forKey:key];
    
    //the only retention should be the one that accrued with the setObject call.
    [newD release];
    
}

/**
 * move the focus of the data up one level. This will throw noisy helpful errors if you have an underflow situation
 * or if somehow a non-dictionary object is in the stack.
 *
 */
- (void) dataClose {
    
    if([dataStack count] == 0) {
    [NSException raise:@"Error" format:@"Gnarly: closeData: underflow."];
    } else {
    [dataStack removeLastObject];
        if([dataStack count] == 0) {
        proceduralSaveDictionary = _MAIN_APPLICATION_DATA_;
        } else {
        proceduralSaveDictionary = [dataStack lastObject];
            if(!proceduralSaveDictionary
            || [proceduralSaveDictionary isKindOfClass:[NSMutableDictionary class]] == NO) {
            [NSException raise:@"Error" format:@"Gnarly: closeData: a non-dictionary object found its way to the data stack and now everything's bollixed up."];
            }
            
        }
        
    }
    
}

/**
 * set the default boolean, int and float
 *
 */
- (void) dataSetDefaultB:(BOOL)bl {
_defaultBool = bl;
}
- (void) dataSetDefaultF:(float)fl {
_defaultFloat = fl;
}
- (void) dataSetDefaultI:(int)i {
_defaultInt = i;
}
- (void) dataSetDefaultS:(NSString *)str {
_defaultString = str;
}


/**
 * set a float on the current procedural data.
 * if no data is in focus, then create a new file in the documents folder and load it up.
 *
 *
 */
- (void) dataSetF:(float)f withKey:(NSString *)key {
[self dataLoad];

    if(proceduralSaveDictionary) {
    NSString *val0 = [NSString stringWithFormat:@"%f",f];
    [proceduralSaveDictionary setObject:val0 forKey:key];
    } else
    if(_MAIN_APPLICATION_DATA_) {
    NSString *val1 = [NSString stringWithFormat:@"%f",f];
    [_MAIN_APPLICATION_DATA_ setObject:val1 forKey:key];
    } else {
    NSLog(@"Error: Gnarly: setF: something has gone wrong because there is no data defined for this value to be saved to.");
    }
}

/**
 * set an integer on the current procedural data. 
 * if no data is in focus, then create a new file in the documents folder and load it up.
 *
 *
 */
- (void) dataSetI:(int)i withKey:(NSString *)key {
[self dataLoad];
    
    if(proceduralSaveDictionary) {
    NSString *val0 = [NSString stringWithFormat:@"%i",i];
    [proceduralSaveDictionary setObject:val0 forKey:key];
    } else
    if(_MAIN_APPLICATION_DATA_) {
    NSString *val1 = [NSString stringWithFormat:@"%i",i];
    [_MAIN_APPLICATION_DATA_ setObject:val1 forKey:key];
    } else {
    NSLog(@"Error: Gnarly: setI: something has gone wrong because there is no data defined for this value to be saved to.");
    }
}

/**
 * set a string on the current procedural data.
 * if no data is in focus, then create a new file in the documents folder and load it up.
 *
 *
 */
- (void) dataSetS:(NSString *)s withKey:(NSString *)key {
[self dataLoad];
    
    if(proceduralSaveDictionary) {
    [proceduralSaveDictionary setObject:s forKey:key];
    } else
    if(_MAIN_APPLICATION_DATA_) {
    [_MAIN_APPLICATION_DATA_ setObject:s forKey:key];
    } else {
    NSLog(@"Error: Gnarly: setS: something has gone wrong because there is no data defined for this value to be saved to.");
    }
}

/**
 * set a string on the current procedural data.
 * if no data is in focus, then create a new file in the documents folder and load it up.
 *
 *
 */
- (void) dataSetB:(BOOL)yesOrNo withKey:(NSString *)key {
    [self dataLoad];
    NSString *s = (yesOrNo)? @"Y" : @"N";
    
    if(proceduralSaveDictionary) {
    [proceduralSaveDictionary setObject:s forKey:key];
    } else
    if(_MAIN_APPLICATION_DATA_) {
    [_MAIN_APPLICATION_DATA_ setObject:s forKey:key];
    } else {
    NSLog(@"Error: Gnarly: setB: something has gone wrong because there is no data defined for this value to be saved to.");
    }
}


/**
 * get a float from the current procedural data.
 * if no data is in focus, then create a new file in the documents folder and load it up.
 *
 *
 */
- (float) dataGetF:(NSString *)key {
[self dataLoad];
    
    if(proceduralSaveDictionary) {
    NSString *val = (NSString *)[proceduralSaveDictionary objectForKey:key];
    return [val floatValue];
    } else
    if(_MAIN_APPLICATION_DATA_) {
    NSString *val = (NSString *)[_MAIN_APPLICATION_DATA_ objectForKey:key];
    return [val floatValue];
    } else {
    return _defaultFloat;
    }
}

/**
 * get an integer from the current procedural data.
 * if no data is in focus, then create a new file in the documents folder and load it up.
 *
 *
 */
- (int) dataGetI:(NSString *)key {
[self dataLoad];
    
    if(proceduralSaveDictionary) {
    NSString *savedInt = (NSString *)[proceduralSaveDictionary objectForKey:key];
        if(savedInt) {
        return [savedInt intValue];
        } else {
        return _defaultInt;
        }
    //return [(NSString *)[proceduralSaveDictionary objectForKey:key] intValue];
    } else
    if(_MAIN_APPLICATION_DATA_) {
    return [(NSString *)[_MAIN_APPLICATION_DATA_ objectForKey:key] intValue];
    } else {
    return _defaultInt;
    }
}


/**
 * get a string from the current procedural data.
 * if no data is in focus, then create a new file in the documents folder and load it up.
 *
 *
 */
- (NSString *) dataGetS:(NSString *)key {
[self dataLoad];
    
    if(proceduralSaveDictionary) {
    return (NSString *)[proceduralSaveDictionary objectForKey:key];
    } else
    if(_MAIN_APPLICATION_DATA_) {
    return (NSString *)[_MAIN_APPLICATION_DATA_ objectForKey:key];
    } else {
    return _defaultString;
    }
}

/**
 * get a boolean from the current procedural data.
 * if no data is in focus, then create a new file in the documents folder and load it up.
 *
 *
 */
- (BOOL) dataGetB:(NSString *)key {
    [self dataLoad];
    //BOOL defaultBool = YES;//NO. this should be configurable.
    
    if(proceduralSaveDictionary) {
    NSString *val = (NSString *)[proceduralSaveDictionary objectForKey:key];
        if(!val) {
        return _defaultBool;
        } else
        if([val isEqualToString:@"Y"]) {
        return YES;
        } else {
        return NO;
        }
        
    } else
    if(_MAIN_APPLICATION_DATA_) {
    NSString *val = (NSString *)[_MAIN_APPLICATION_DATA_ objectForKey:key];
        if(!val) {
        return _defaultBool;
        } else
        if([val isEqualToString:@"Y"]) {
        return YES;
        } else {
        return NO;
        }
        
    } else {
    return _defaultBool;
    }

return _defaultBool;
}



/**
 * clears out all of the data immediately. The next call to any of the other data API functions
 * will generate a new file and procedural data.
 * http://stackoverflow.com/questions/3404689/iphone-objective-c-cant-delete-a-file
 *
 */
-(void) dataClear {
[_MAIN_APPLICATION_DATA_ removeAllObjects];
[_MAIN_APPLICATION_DATA_ release];

_MAIN_APPLICATION_DATA_ = nil;
proceduralSaveDictionary = nil;
    
NSFileManager *fileManager = [NSFileManager defaultManager];
NSError *error;

NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
NSString *mainAppDataURL = [documentsDirectory stringByAppendingPathComponent:@"MAIN_APPLICATION_DATA.txt"];

BOOL fileExists = [fileManager fileExistsAtPath:mainAppDataURL];
    
    if (fileExists) {
    BOOL success = [fileManager removeItemAtPath:mainAppDataURL error:&error];
    if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
    
_appFiredForFirstTime = YES;

}

/**
 * log the data to the console.
 *
 *
 */
- (void) dataLog {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *mainAppDataURL = [documentsDirectory stringByAppendingPathComponent:@"MAIN_APPLICATION_DATA.txt"];

    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:mainAppDataURL encoding:NSUTF8StringEncoding error:&error];
    
    //if (error)
    //    NSLog(@"Error reading file: %@", error.localizedDescription);
    
    NSLog(@" ");
    NSLog(@" ");
    NSLog(@"###################################");
    NSLog(@"MAIN_APPLICATION_DATA: %@", fileContents);
    NSLog(@"###################################");
    NSLog(@" ");
    NSLog(@" ");
}


/**
 * save the data. You shouldn't ever need to call this function directly- it's called at the
 * applicationWillEnterBackground delegate function.
 *
 *
 */
- (void)dataSave {
    
    if(_MAIN_APPLICATION_DATA_) {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *mainAppDataURL = [documentsDirectory stringByAppendingPathComponent:@"MAIN_APPLICATION_DATA.txt"];
    
        if (![_MAIN_APPLICATION_DATA_ writeToFile:mainAppDataURL atomically:YES]) {
        NSLog(@"Gnarly: Error: dataSave. Something went wrong and the data was not saved.");
        }
    
    }
    
}

- (void) dataPurgeAndSave {
    
    if(_MAIN_APPLICATION_DATA_) {
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *mainAppDataURL = [documentsDirectory stringByAppendingPathComponent:@"MAIN_APPLICATION_DATA.txt"];
        
        [_MAIN_APPLICATION_DATA_ removeAllObjects];
        
        if (![_MAIN_APPLICATION_DATA_ writeToFile:mainAppDataURL atomically:YES]) {
            NSLog(@"Gnarly: Error: dataSave. Something went wrong and the data was not saved.");
        }
        
    }
    
    
}

/**
 * load up the data. create a new data file if one doesn't already exist in the documents folder. this
 * is where data will live so that new updates will not overwrite it. it will be persistent from
 * upgrade to upgrade.
 *
 *
 */
- (void)dataLoad {
    
    if(!_MAIN_APPLICATION_DATA_) {

        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        mainApplicationDataURL = [documentsDirectory stringByAppendingPathComponent:@"MAIN_APPLICATION_DATA.txt"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:mainApplicationDataURL]) {
        _MAIN_APPLICATION_DATA_ = [[NSMutableDictionary alloc] initWithContentsOfFile:mainApplicationDataURL];
        } else {
        _appFiredForFirstTime = YES;
        _MAIN_APPLICATION_DATA_ = [[NSMutableDictionary alloc] init];
        }
        
    }
    
}


-(void) logSettings {
	//for(NSString* item in [userSettings allKeys]) {
    //NSLog(@"[Gnarly user settings: KEY:%@ - VALUE:%@]", item, [userSettings valueForKey:item]);
	//}
}



///////////////////////
// memory management //
///////////////////////


/**
 * override the retain count stuff. we don't ever want Gnarly's retain count to change.
 * dealloc is called directly.
 *
 */
- (id)retain {
return self;
}
- (NSUInteger)retainCount {
return (NSUInteger)UINT_MAX;  //denotes an object that cannot be released
} 
- (void)release {
//take no action.
}
- (id)autorelease {
return self;
}




/**
 * free resources and call the super method.
 *
 */
- (void) dealloc {
    if(_MAIN_APPLICATION_DATA_) {
    [_MAIN_APPLICATION_DATA_ release];
    }
[allSurfaces release];
[allResOpLists release];
[userSettings release];
[super dealloc];
}



@end
