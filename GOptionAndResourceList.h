//
//  GOptionAndResourceList.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/16/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>

@class GResource;

@interface GOptionAndResourceList : NSObject {
NSMutableArray *resources;

BOOL hasPreloader;
BOOL hasPause;
BOOL willSurfacePauseOnReturnFromBackground;
BOOL hasPreloaderSprite;
NSString *preloaderClassName;
NSString *preloaderResourceKey;
NSString *pauseClassName;
NSString *pauseResourceKey;
NSString *preloaderSpriteClassName;

}
@property (nonatomic, readonly) NSMutableArray *resources;
@property (nonatomic, assign) NSString *preloaderClassName;
@property (nonatomic, assign) NSString *preloaderResourceKey;
@property (nonatomic, assign) NSString *pauseClassName;
@property (nonatomic, assign) NSString *pauseResourceKey;
@property (nonatomic, assign) NSString *preloaderSpriteClassName;
@property (nonatomic, assign) BOOL hasPreloader;
@property (nonatomic, assign) BOOL hasPause;
@property (nonatomic, assign) BOOL willSurfacePauseOnReturnFromBackground;
@property (nonatomic, assign) BOOL hasPreloaderSprite;

- (void) addResource:(GResource *)rec;

@end
