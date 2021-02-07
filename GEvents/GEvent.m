
///////////////////////////////////////////////////
//  GEvent.m
//  gravity_pong_10
//
//  Created by Alexander  Lowe on 5/17/10.
//
//  an event base class. a *real* event, not the
//  fake events I've been making heretofore.
// 
///////////////////////////////////////////////////

#import "GEvent.h"
#import "GGestureRecognizer.h"


@implementation GGestureRecognizerInjectionMetaObject

@synthesize touchStart,touchMove,touchEnd;
@synthesize gestureRecognizerClass;
@synthesize gestureRecognizerClassName;

- (id) initWithClass:(Class)clss touchStart:(BOOL)tS touchMove:(BOOL)tM touchEnd:(BOOL)tE {
    
    self = [super init];
    gestureRecognizerClass = clss;
    gestureRecognizerClassName = NSStringFromClass(clss);
    touchStart = tS;
    touchMove = tM;
    touchEnd = tE;
    return self;
    
}

@end


@implementation GEvent

@synthesize keepBubbling, bubbles;

@synthesize currentTarget;

@synthesize target;

@synthesize evtCode;

@synthesize prev,next;

@synthesize touchX,touchY;

@synthesize whichTouch, howManyTouches;

static BOOL EVENT_STRINGS_WILL_INJECT = YES;

static GGestureRecognizerInjectionMetaObject *injection_gestureRecognizerMetaObject;


- (id)init:(NSString *)cd bubbles:(BOOL)bbls {
    
self = [super init];

evtCode = cd;
bubbles = bbls;
    
touchX = 0;
touchY = 0;

	if(bubbles == YES)
	self.keepBubbling = YES;
    
EVENT_STRINGS_WILL_INJECT = YES;

return self;

}


+ (id) alloc {
EVENT_STRINGS_WILL_INJECT = NO;
return [super alloc];
}



+ (void) injectGestureRecognizer:(GGestureRecognizerInjectionMetaObject *)gestureRecognizerMetaObject {

    if(EVENT_STRINGS_WILL_INJECT) {
    injection_gestureRecognizerMetaObject = gestureRecognizerMetaObject;
    } else {
    EVENT_STRINGS_WILL_INJECT = YES;
    }
    
}

+ (GGestureRecognizerInjectionMetaObject *) getInjectionGestureReconizerMetaObject {
return injection_gestureRecognizerMetaObject;
}

+ (void) clearGestureRecognizerInjection {
[injection_gestureRecognizerMetaObject release];
injection_gestureRecognizerMetaObject = nil;
}

@end
