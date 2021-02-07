//
//  GLoadView.h
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 8/5/11.
//  
//

#import "GSurface.h"

@class GOptionAndResourceList;

@interface GLoadView : GSurface {
GSurface *mainView;
}

- (id) initWithResources:(GOptionAndResourceList *)recList withResourceKey:(NSString *)key andMainView:(GSurface *)view;

- (void) gnarlySaysWindDownSurface;

- (GSurface *) gnarly_SurfaceTransactor_getMainView;

- (void) mainViewIsDestroyed;

@property (nonatomic, readonly) GSurface *mainView;

@end
