//
//  GSimpleButton.h
//  RidiculousMissile2
//
//  Created by Alexander  Lowe on 4/26/11.
//  Copyright 2011 Codequark. See Licence.
//

#import <Foundation/Foundation.h>
#import "GBox.h"
#import "Gnarly.h"

@class GSurface;
@interface GLoadSprite : GBox <GSurfaceTransactor> {


//// GSurfaceTransactor variables.
GSurface *gnarly_SurfaceTransactor_newSurface;
GSurface *gnarly_SurfaceTransactor_oldSurface;
int gnarly_SurfaceTransactor_transactorType;
BOOL gnarly_SurfaceTransactor_forReplacement;
BOOL gnarly_SurfaceTransactor_readyToContinueTransaction;
BOOL gnarly_SurfaceTransactor_isWoundDown;
/////////////////////////////////////////

BOOL transactionFinished;


}



//init.
- (id) initWithNewSurface:(GSurface *)newSfc andOldSurface:(GSurface *)oldSfc;


/// GSurfaceTransactor methods and properties.
- (GSurface *) gnarly_SurfaceTransactor_getMainView;
- (void) gnarlySaysConfigureForEnd;
@property (nonatomic, readonly) int gnarly_SurfaceTransactor_transactorType;
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_forReplacement;
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_readyToContinueTransaction;
@property (nonatomic, assign) BOOL gnarly_SurfaceTransactor_isWoundDown;;
@property (nonatomic, assign) GSurface *gnarly_SurfaceTransactor_oldSurface,*gnarly_SurfaceTransactor_newSurface;
//////////////////////////////////////////////////////////////////////////////


//gnarly delegate.
- (void) gnarlySaysWindDownSprite;






@end
