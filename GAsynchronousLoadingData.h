/*

File: OpenGLCoreView.h
Abstract: A UIView subclass that allows for the rendering of OpenGL ES content
by a delegate that implements the OpenGLCoreViewDelegate protocol.

*/

//#include <stdlib.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "GLayerMemoryObject.h"

@class GSurface;

@interface GAsynchronousLoadingData : NSObject {

NSString * callback;

id <GLayerMemoryObject> observer;

NSString * key;

NSString *originalResourcesKey;

NSTimer * loadingTimer;

GSurface *relatedSurface;

BOOL forPreload;

BOOL forMultiThread;
    
BOOL hasResourceManager;

float asynchProgress;

}

- (id) initWithKey:(NSString *)ky callback:(NSString *)cllbck observer:(id <GLayerMemoryObject>)obs andPreloadFlag:(BOOL)forPreload;

//+ (void) surfaceIsDestroyed:(GSurface *)surf;

@property (nonatomic, readonly) NSString *callback;
@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) id <GLayerMemoryObject> observer;
@property (nonatomic, retain)   NSTimer *loadingTimer;
@property (nonatomic, readonly) BOOL forPreload;
@property (nonatomic, assign) BOOL forMultiThread;
@property (nonatomic, assign) float asynchProgress;
@property (nonatomic, assign) GSurface *relatedSurface;
@property (nonatomic, assign) NSString *originalResourcesKey;

@end

