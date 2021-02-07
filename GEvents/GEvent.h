//
//  GEvent.h
//  gravity_pong_10
//
//  Created by Alexander  Lowe on 5/17/10.
//  Copyright 2010 Alex Lowe.
//

#import <Foundation/Foundation.h>

@interface GGestureRecognizerInjectionMetaObject : NSObject {
    
    BOOL touchStart;
    BOOL touchMove;
    BOOL touchEnd;
    Class gestureRecognizerClass;
    NSString *gestureRecognizerClassName;
    
}

@property (nonatomic, assign) BOOL touchStart, touchMove, touchEnd;
@property (nonatomic, assign) Class gestureRecognizerClass;
@property (nonatomic, assign) NSString *gestureRecognizerClassName;

- (id) initWithClass:(Class)clss touchStart:(BOOL)tS touchMove:(BOOL)tM touchEnd:(BOOL)tE;

@end





@class GGestureRecognizer;

@interface GEvent : NSObject {

BOOL keepBubbling;

BOOL bubbles;

GEvent *prev;
GEvent *next;
    
float touchX;
float touchY;

    int whichTouch;
    int howManyTouches;

id currentTarget;
id target;

NSString *evtCode;

}


- (id)init:(NSString *)cd bubbles:(BOOL)bbls;

+ (void) injectGestureRecognizer:(GGestureRecognizerInjectionMetaObject *)gestureRecognizerMetaObject;

//+ (Class) getGestureRecognizerInjectionClass;
+ (GGestureRecognizerInjectionMetaObject *) getInjectionGestureReconizerMetaObject;

+ (void) clearGestureRecognizerInjection;

//+ (GGestureRecognizer *) getTouchStartGestureRecognizerInjection;
//+ (GGestureRecognizer *) getTouchEndGestureRecognizerInjection;
//+ (GGestureRecognizer *) getTouchMoveGestureRecognizerInjection;
//+ (void) clearGestureRecognizerInjections;

@property(nonatomic, assign) BOOL keepBubbling;
@property(nonatomic, assign) BOOL bubbles;

@property(nonatomic, assign) id currentTarget;
@property(nonatomic, assign) id target;

@property (nonatomic, assign) int whichTouch, howManyTouches;

@property(nonatomic, assign) GEvent *prev;
@property(nonatomic, assign) GEvent *next;

@property (nonatomic, assign) float touchX,touchY;

@property (nonatomic, readonly) NSString * evtCode;

@end
