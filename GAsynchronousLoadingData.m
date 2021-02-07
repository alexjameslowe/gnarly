#import "GAsynchronousLoadingData.h"
#import "GSurface.h"


@implementation GAsynchronousLoadingData

//static NSMutableArray *allInstances;

@synthesize callback,key;
@synthesize observer;
@synthesize forPreload;
@synthesize loadingTimer;
@synthesize asynchProgress;
@synthesize relatedSurface;
@synthesize forMultiThread;
@synthesize originalResourcesKey;

- (id) initWithKey:(NSString *)ky callback:(NSString *)cllbck observer:(id <GLayerMemoryObject>)obs andPreloadFlag:(BOOL)preLd {

self = [super init];

//    if(allInstances) {
//    allInstances = [[NSMutableArray alloc] init];
//    }

callback = cllbck;

observer = obs;

key = ky;

forMultiThread = NO;

forPreload = preLd;

asynchProgress = 0;
    
//[allInstances addObject:self];

return self;

}


/**
 *
 *
 */
/*
+ (void) surfaceIsDestroyed:(GSurface *)surf {

int cnt = [allInstances count];
GAsynchronousLoadingData *gData;

    for(int k=0; k<cnt; k++) {
    gData = [allInstances objectAtIndex:k];
        if(gData.relatedSurface == surf) {
        gData.relatedSurface = nil;
        }
        
    }

}*/



/**
 *
 *
 */
- (void) dealloc {

    if(self.loadingTimer) {
    [self.loadingTimer release];
    }
    
//[allInstances removeObject:self];

//    if([allInstances count] == 0) {
//    [allInstances release];
//    allInstances = nil;
//    }


[super dealloc];

}

@end
