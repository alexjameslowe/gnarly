//
//  GTweenColorStrategy.h
//  BraveRocket
//
//  Created by Alexander Lowe on 3/13/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import "GTweenStrategy.h"

@interface GTweenColorStrategy : GTweenStrategy {

int _endColorHex;
    
}

- (id) initWithDuration:(int)dur delay:(int)del easing:(NSString *)ease andEndColorHex:(int)endColorHex;

@end
