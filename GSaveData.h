//
//  GSaveData.h
//  CosmicDolphin_7_5
//
//  Created by Alexander  Lowe on 3/24/13.
//  Copyright (c) 2013 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>

@interface GSaveData : NSMutableDictionary

- (int) getI:(NSString *)key;

- (float) getF:(NSString *)key;

- (NSString *) getS:(NSString *)key;

- (void) saveI:(int)value withKey:(NSString *)key;

- (void) saveF:(float)value withKey:(NSString *)key;

- (void) saveS:(NSString *)value withKey:(NSString *)keys;

@end
