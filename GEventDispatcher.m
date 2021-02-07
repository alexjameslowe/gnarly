///
//  GEventDispatcher.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 10/18/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import "GEventDispatcher.h"
#import "GEvent.h"
#import "GListener.h"
#import "GSurface.h"
#import "GTouchLink.h"
#import "GChain.h"
#import "GEventTouchObject.h"
#import "GGestureRecognizer.h"

#import "GLayerMemoryObject.h"



@implementation GTouchObject
@synthesize x,y;
@end



@implementation GEventDispatcher

@synthesize flat;




- (id) init {

//event listeners, touch detection //////////
listeners = [[NSMutableDictionary alloc] init];
numListeners = 0;
watchTouchHistory = 0;
watchTouchStart = NO;
watchTouchEnd = NO;
watchDoubleTouch = NO;
watchTouchMove = NO;
    
currentTouches = [[NSMutableArray alloc] init];
gestureRecognizersExist = [[NSMutableDictionary alloc] init];

return [super init];
}




/**
 * check for a touches down. forward any touches on this object to the GGestureRecognizers
 *
 */
//Touches_ReEngineering_2d75a480-87bf-11e5-af63-feff819cdc9f
- (void) testTouchDown {
    
    if(parent.totalWatchTouches == NO) {
        if(watchTouches == YES) {
            totalWatchTouches = YES;
        } else {
            totalWatchTouches = NO;
        }
    } else {
        if(_touchShield == YES) {
            totalWatchTouches = YES;
        }
    }
    
    //So, if we're watching for touches started,
    if(totalWatchTouches == YES) {
        
        //grab the touches array from the root and perform a custom loop
        GEventTouchChain *touches = root.touchesStartedChain;
        GEventTouchObject *link = (GEventTouchObject *)[touches getFirstLink];
        
        while(link) {
        GEventTouchObject *n = (GEventTouchObject *)link.next;
            
            //at the end of the frame, the chain of links on the root-level are looped through and
            //at that point are marked as availableForTouchStartTest = NO. That way, a touch on that chain
            //can't get fed through this conditional again and installed a second or third time on the
            //currentTouches array. that was a bug in times past.
            //
            //Now, you might naively think well gee alex why not just set availableForTouchStartTest=YES right here
            //as soon as we pass through? Well see, here's the thing. Z-Order. Objects are rendered in the opposite
            //z-order that we want the touches to behave. In other words, the object way in the back gets rendererd first
            //by the render-loop. If we captured this link right here and flagged it to availebleForTouchTest=YES,
            //we'd be removing the possibility that a higher-z-order object nearer to the front would capture this
            //link. and those higher-z-order objects are the ones that we really *want* to capture the links.
            if(link.availableForTouchStartTest) {
                
                //perform the test to see if it's a hit on this object
                if([self touchPointTest:link.gamePoint] == YES) {
                //NSLog(@"GEventDispatcher: testTouchDown: adding this to the currentTouches. %p",link);
                    
                //if so than store this GEventTouchObject in an array right here on this
                //object. so it's stored in two places. it's stored on the touchesStartedChain
                //and it's also stored on this object
                [currentTouches addObject:link];
                    
                //Now, we got a touch-start on this object. What do we do with it? Well, this is
                //where the gesture-recognizers take over. GGestureRecognizers are added to this
                //object from the addEL function. They are the classes which decide what to DO about
                //a touch. Some of them are simple, like GEventSingleTouch. Just dispatch an event
                //for touch-start, touch-end and touch-move. Others are more complicated. The point is
                //that none of the logic happens here. It's all handled by polymorphism in the
                //GGestureRecognizer classes.
                //The GGestureRecognizer classes each receieve three messages. touchStarted, touchMoved and touchEnded.
                //It's up to them to decide what to do with that information. Here we're going to loop through and hit
                //each GGestureRecognizer with the touchStart function.
                int len = (int)[gestureRecognizersTouchStart count];
                //NSLog(@"testTouchDown: numTouchStart: %i",len);
                GGestureRecognizer *recog;
                    for(int i=0; i<len; i++) {
                    recog = (GGestureRecognizer *)[gestureRecognizersTouchStart objectAtIndex:i];
                    [recog setEventObjectLink:link];
                    [recog touchStarted:link.gamePoint];
                    }
                //NSLog(@"got past touch-start.");
                    
                    
                //single-frame-edge-case: if the delegates touchesStarted and touchesEnded on the GSurface get triggered in the exact
                //same frame. In that case, it's conceivable that the touchEnded=YES will get set on a GEventTouchObject before the
                //link ever makes it to this touches-started conditional. In that case, the link will never be called on the
                //GGestureRecongizer instances, and that would bollix things up. The touch-end would fire but the touch-start would be lost.
                //
                //Well we have the medicine for that. which the "singleFrameEdgeCase_" variables. This will gurarntee that a GEventTouchObject
                //must pass through this conditional and be recognized as a touch-start before it can become a touch-end.
                //These particular variables basically defer setting the touch-end until after it's had a chance to run through the
                //the touch-started GGestureRecognizers.
                //NSLog(@"link.singleFrameEdgeCase_wasTouchStartRecognized = YES %p",link);
                link.singleFrameEdgeCase_wasTouchStartRecognized = YES;
                    if(link.singleFrameEdgeCase_extremelyRapidTouchesEndHappened == YES) {
                    [link singleFrameEdgeCase_deferredSetTouchEndedToYES];
                    }
                    
                }
                
            }
            
        link = n;
        }
        
    } 
    
}


/**
 * check for touches-ended or touches moved. forward any of them to the GGestureRecognizers.
 *
 */
- (void) testTouchMovedEnded {
    
int numTouches = (int)[currentTouches count];
    
BOOL atLeastOneTouchRemains = NO;
    
    for(int i=0; i<numTouches; i++) {
    GEventTouchObject *n = (GEventTouchObject *)[currentTouches objectAtIndex:i];
        
        //if any of the touches are touchEnded, then flag so them so that they
        //don't run through this conditional again (touchEnd=YES also means they'll be
        //deleted by GSurface at the end of the frame).
        if(n.touchEnded == YES) {
            
        [currentTouches removeObjectAtIndex:i];
        //we have to remove this particular object from the array if the touch ended.
        i--;
        numTouches--;
        
        //loop through the touch-end list of gesture-recognizers and send the touchEnded
        //message to each with the coordinates of the touch that ended.
        int numTouchEnded = (int)[gestureRecognizersTouchEnd count];
        GGestureRecognizer *recog;
        
            for(int j=0; j<numTouchEnded; j++) {
            recog = (GGestureRecognizer *)[gestureRecognizersTouchEnd objectAtIndex:j];
            [recog setEventObjectLink:n];
            [recog touchEnded:n.gamePoint];
            }
            
        } else {
            
        //set this so that we know in the nex block down that at least *one* touch still remains active.
        atLeastOneTouchRemains = YES;
            
            //With touch-moved we have to keep in mind that this loop will hand the gesture-recognizer
            //touchMoved calls regardless of whether or not the touches are actually moving. we could
            //test the coordinates of each point to make the determination of whether or not the touch
            //is moving, but we don't even need to do that, because the touchesMoved delegate on the
            //surface already gets called by the OS when it detects touches-moving. So the only thng
            //we need to do is just ask the surface if it's in the events-in-play state. If so,
            //then call the touches-moved on the gesture-recognizers.
            if([root areEventsInPlay]) {
            
            int numTouchMoved = (int)[gestureRecognizersTouchMove count];
            GGestureRecognizer *recog;
                
                //loop through the touch-move list of gesture-recognizers and send the touchMoved
                //message to each with the coordinates of the touch moved.
                for(int k=0; k<numTouchMoved; k++) {
                recog = (GGestureRecognizer *)[gestureRecognizersTouchMove objectAtIndex:k];
                [recog setEventObjectLink:n];
                [recog touchMoved:n.gamePoint];
                }
                
            }
            
        }
        
    }
    
    
    //if all of the touches have ended, then we're going to
    //just remove all of these guys.
    if(!atLeastOneTouchRemains) {
    [currentTouches removeAllObjects];
    }
    
}


/**
 * render. if we're supposed to watch for touches that move or end,
 * then do that here. return the next GRenderable object in this chain.
 *
 */

- (GRenderable *) render {
GRenderable *n = next;
		
    if(totalWatchTouches == YES) {
    [self testTouchMovedEnded];
    }

//return next;
return n;
}



/**
 * When you add an event-listener you do it by specififing a string-code in the addEL function.
 * You get this string code by using one of the class-level functions on the GEvent class itself
 * like [GEventSingleTouch START] for the touch-start event, [GEventSingleTouch END] for the
 * touch-end event etc. etc. And these functions act as implicit dependency injectors. then this
 * function catches those dependencies from the GEvent class and applies them to the case at hand,
 * which is the addEL function.
 *
 *
 */
- (void) addEL_addGestureReconizerInjections {
    GGestureRecognizerInjectionMetaObject *injectionMetaObject = [GEvent getInjectionGestureReconizerMetaObject];
    
    if(injectionMetaObject) {
        NSString *injectionClassName = injectionMetaObject.gestureRecognizerClassName;
        
        if(![gestureRecognizersExist objectForKey:injectionClassName]) {
            
        GGestureRecognizer *injection = [[injectionMetaObject.gestureRecognizerClass alloc] init];
            
        //NSLog(@"addEL_addGestureReconizerInjections: adding injection: %@",injection);
        [injection setSurface:root andEventDispatcher:self];
            
            if(injectionMetaObject.touchStart) {
                if(!gestureRecognizersTouchStart) {
                gestureRecognizersTouchStart = [[NSMutableArray alloc] init];
                }
            [gestureRecognizersTouchStart addObject:injection];
            }
            if(injectionMetaObject.touchMove) {
                if(!gestureRecognizersTouchMove) {
                gestureRecognizersTouchMove = [[NSMutableArray alloc] init];
                }
            [gestureRecognizersTouchMove addObject:injection];
            }
            if(injectionMetaObject.touchEnd) {
                if(!gestureRecognizersTouchEnd) {
                gestureRecognizersTouchEnd = [[NSMutableArray alloc] init];
                }
            [gestureRecognizersTouchEnd addObject:injection];
            }
            
        //[gestureRecognizers addObject:injection];
        [injection release];
        
        [gestureRecognizersExist setObject:@"_" forKey:injectionClassName];
        }
        
        watchTouchHistory++;
        watchTouches = YES;
        
        [GEvent clearGestureRecognizerInjection];
    }
}


/**
 * injections for the removeEL function. same principle as the addEL_addGestureReconizerInjections
 * function, except here we're just going to delete the injections. we have to do this because the
 * dependencies are injected with functions like [GEventSingleTouch START], [GEventSingleTouch END],
 * and we use those same functions in the calls to removeEL.
 *
 */
- (void) removeEL_addGestureReconizerInjections {
    
    GGestureRecognizerInjectionMetaObject *injectionMetaObject = [GEvent getInjectionGestureReconizerMetaObject];
    
    if(injectionMetaObject) {
        
        watchTouchHistory--;
        
        if(watchTouchHistory <= 0) {
            watchTouchHistory = 0;
            watchTouches = NO;
        }
        
        
    [GEvent clearGestureRecognizerInjection];
    }
    
}



/////////////
//         //
//  A P I  //
//         //
/////////////


/**
 * this is overridden in extended classes depending on their geometry.
 * they need to make use of the inverse affine matrix.
 *
 */
- (BOOL) touchPointTest:(CGPoint)collPt {
return NO;
}



/**
 * set the touch opacity of this object If this thing is supposed to shield objects beneath it from 
 * any touches, then set the touchShield to YES. the default is NO.
 *
 * we're incrementing/decrementing the watchTouchHistory so as not to effect whatever event listeners
 * are added to this thing.
 * 
 */
- (void) setTouchShield:(BOOL)shld {
_touchShield = shld;

    if(_touchShield == YES) {
    watchTouches = YES;
    watchTouchHistory++;    
    } else {
    
    //decrement the history variable. if it's zero, then there's no need to 
    //watch the touches anymore.
    watchTouchHistory--;
        if(watchTouchHistory == 0) {
        watchTouches = NO;
        }
        
    }

}
- (BOOL) touchShield {
return _touchShield;
}



/**
 * add/remove event listeners. if the event that you're listening to requires gesture-recognizers, then
 * the addEL_addGestureReconizerInjections function will inject them.
 *
 */
- (void) addEL:(NSString *)evt withCallback:(NSString *)cllbck andObserver:(id)obs {
    
 GListener *lst = [listeners objectForKey:evt];
    
	if(lst) {
	NSLog(@"Error: Box -> addEL: you can't double register %@%@",evt,@" for this object.");
	} else {
        
	numListeners++;
        
    //if the event that you're listening to requires gesture-recognizers, then
    //this function will inject them. the evt string is the "implicit" dependency
    //injector. Instead of asking the developer to create the gesture recognizers themselves,
    //the GEvent class will prep the injections itself, and this function will catch them and apply them.
    [self addEL_addGestureReconizerInjections];
    
    SEL sel = NSSelectorFromString([cllbck stringByAppendingString:@":"]);
        if(!sel) {
        NSAssert(YES, @"Error: Box --> addEL:withCallback:andObserver --> callback %@%@",cllbck,@" failed.");
        }
    
    GListener *tmp = [[GListener alloc] initWithCallback:sel andObserver:obs];
    [listeners setObject:tmp forKey:evt];
	//[listeners setObject:tmp forKey:[NSString stringWithFormat:@"%d",evt]];
	//send a release message here because we want the only extant reference 
	//to the listener to be on the dictionary.
	[tmp release];
	}

}


- (void) removeEL:(NSString *)evt {
 
GListener *lst = [listeners objectForKey:evt];
 
 	if(!lst) {
	NSLog(@"Error: Box -> removeEL: listener for event %@%@",evt,@" does not exist on this object.");
	} else {
        
    [self removeEL_addGestureReconizerInjections];

	numListeners--;
    
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
   
	if(self.flat != nil) {
	evt.target = self.flat;
	}

    if(numListeners != 0) {
	GListener *lst = [listeners valueForKey:evt.evtCode];
		if(lst) {
        [lst.observer performSelector:lst.callback withObject:evt];
		}
	}
    
    if(parent) {
	
        if(evt.keepBubbling == YES && parent.isMainDefault == NO) {
        [(GEventDispatcher *)parent dispatch:evt];
        } else {
        [evt release];
        }

    }

}



/**
 * flatten a box hierarchy so that the origin of events all point to one box,
 * regardless of which one dispatched it. 
 *
 */
- (void) flatten:(BOOL)yesOrNo withObj:(GEventDispatcher *)disp {
GEventDispatcher *first = (GEventDispatcher *)firstChild;

	if(yesOrNo == NO) {
	
	flat = nil;
        
        while(first) {
        [first flatten:NO withObj:nil];
        first = (GEventDispatcher *)first.nextSibling;  
        }
		
	} else {
	
	flat = disp;
    
        while(first) {
        [first flatten:YES withObj:disp];
        first = (GEventDispatcher *)first.nextSibling;  
        }
	
	}

}



- (void) releaseResources {
    
[currentTouches release];
    
    if(gestureRecognizersTouchStart) {
    [gestureRecognizersTouchStart release];
    }
    
    if(gestureRecognizersTouchMove) {
    [gestureRecognizersTouchMove release];
    }
    
    if(gestureRecognizersTouchEnd) {
    [gestureRecognizersTouchEnd release];
    }
    
[gestureRecognizersExist release];
    
[listeners release]; 
 
[super releaseResources];
}


@end
