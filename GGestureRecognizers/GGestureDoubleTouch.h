//
//  GGestureDoubleTouch.h
//  BraveRocket
//
//  Created by Alexander Lowe on 11/24/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//

#import "GGestureRecognizer.h"

@class GEventTouchObject;

@interface GGestureDoubleTouch : GGestureRecognizer {

    GEventTouchObject *gEventTouchObject0;
    GEventTouchObject *gEventTouchObject1;
    
    NSDate *date0;
    NSDate *date1;
    
    int touchEndCount;
    int touchStartCount;
    
    BOOL doubleTouchDownWasDetected;
    
}


@end
