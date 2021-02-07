//
//  GSaveData.m
//  CosmicDolphin_7_5
//
//  Created by Alexander  Lowe on 3/24/13.
//  Copyright (c) 2013 Alex Lowe. See Licence.
//

#import "GSaveData.h"

@implementation GSaveData

- (int) getI:(NSString *)key {
NSString *s = [self objectForKey:key];
    if(s) {
    return [s intValue];
    }
return 0;
}

- (float) getF:(NSString *)key {
NSString *s = [self objectForKey:key];
    if(s) {
    return [s floatValue];
    }
return 0;
}

- (NSString *) getS:(NSString *)key {
NSString *s = [self objectForKey:key];
    if(s) {
    return s;
    }
return nil;
}

- (void) saveI:(int)value withKey:(NSString *)key {
NSString *s = [NSString stringWithFormat:@"%i",value];
[self setObject:s forKey:key];
}

- (void) saveF:(float)value withKey:(NSString *)key {
NSString *s = [NSString stringWithFormat:@"%f",value];
[self setObject:s forKey:key];
}

- (void) saveS:(NSString *)value withKey:(NSString *)key {
[self setObject:value forKey:key];
}

@end
