//
//  GEventDoubleTouch.h
//  BraveRocket
//
//  Created by Alexander Lowe on 11/24/15.
//  Copyright © 2015 Alexander Lowe. See Licence.
//


#import "GEvent.h"

@interface GEventDoubleTouch : GEvent {
    CGPoint gamePoint;
    int lifeCycle;
}

@property (nonatomic, readonly) CGPoint gamePoint;
@property (nonatomic, readonly) int lifeCycle;

+ (NSString *) START;
+ (NSString *) END;
+ (NSString *) MOVE;

- (id)init:(NSString *)cd bubbles:(BOOL)bbls gamePoint:(CGPoint)pt andLifeCycle:(int)lCycle;


@end
