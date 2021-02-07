//
//  GLoadSprite.m
//  CosmicDolphin_5_6
//
//  Created by Alexander  Lowe on 10/20/11.
//  
//

#import "GLoadSprite.h"

/*
#import "GSurface.h"
*/

///////////////////////////////////////////////////////////////////////
//                                                                   //
//  GLoadSprite. A very small base-class for loading animations.     //
//  You got yer full-on pre-loading screens, and then you got these  //
//  guys, which can be just a rotating wheel which can live on one   //
//  surface while another surface is loading.                        //
//                                                                   //
///////////////////////////////////////////////////////////////////////

@implementation GLoadSprite


//GSurfaceTransactor properties
@synthesize gnarly_SurfaceTransactor_forReplacement;
@synthesize gnarly_SurfaceTransactor_readyToContinueTransaction;
@synthesize gnarly_SurfaceTransactor_isWoundDown;
@synthesize gnarly_SurfaceTransactor_transactorType;
@synthesize gnarly_SurfaceTransactor_oldSurface;
@synthesize gnarly_SurfaceTransactor_newSurface;
////////////////////////////////////////





- (id) initWithNewSurface:(GSurface *)newSfc andOldSurface:(GSurface *)oldSfc {

self = [super init];

//[self rectWidth:300 andHeight:600 color:0xFF00FF];

gnarly_SurfaceTransactor_newSurface = newSfc;

gnarly_SurfaceTransactor_oldSurface = oldSfc;

transactionFinished = NO;

gnarly_SurfaceTransactor_transactorType = 1;

gnarly_SurfaceTransactor_forReplacement = YES;

gnarly_SurfaceTransactor_readyToContinueTransaction = NO;

  
return self;

}



/**
 * render. this object passively watches the winding down state of the old surface. when it is done winding down,
 * it destroyes the old surface and begins the new surface.
 *
 * check to see if the transaction is ready to be completed. This will depend on either the old surface being 
 * wound down completely, or on the internal gnarly_SurfaceTransactor_readyToContinueTransaction being set to YES. The latter case is
 * for instances when this object is facilitating the addition of an overlay, rather than a wholesale replacement
 * of the original surface. We need to distinguish the two, because in a replacement, the old surface will be destroyed,
 * and in an overlay, only this object needs to get destroyed.
 *
 */
- (GRenderable *) render {
GRenderable *n = [super render];

   if(transactionFinished == NO) {

        if(gnarly_SurfaceTransactor_forReplacement == YES) {
            
            if(gnarly_SurfaceTransactor_oldSurface.gnarly_SurfaceTransactor_isWoundDown == YES) {
            //NSLog(@"GLoadSprite: render: gnarly_SurfaceTransactor_isWoundDown == YES... %@",gnarly_SurfaceTransactor_oldSurface);
            [gnarly_SurfaceTransactor_oldSurface destroy]; //OLD
            [[Gnar ly] okToBeginGameForSurface:gnarly_SurfaceTransactor_newSurface]; //OLD
            }
            
        } else {
            
            if(gnarly_SurfaceTransactor_readyToContinueTransaction == YES) {
            transactionFinished = YES;
            [self destroy]; //OLD
            }
            
        }
    
    }
    
return n;
}


//GSurfaceTransactor methods /////
- (GSurface *) gnarly_SurfaceTransactor_getMainView {
return nil;
}
//////////////////////////////////


 
/////////////
//         //
//  A P I  //
//         //
/////////////



/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 *
 * called by the loading view when the loading view is finished loading. When you subclass GLoadSprite, you have
 * to override this function unless you want to the sprite to be eliminated immediately to continue the transaction.
 * But maybe you don't want that. Maybe you want to trigger some new animation before the new surface appears, and you
 * want the preload sprite to do something new before it goes away. Maybe the preload sprite is a dolphin swimming
 * and right before the new surface appears you want the dolphin to do a back-flip.
 * Will clients ask for things like that? Oh god.
 *
 * 
 */
- (void) gnarlySaysWindDownSprite {
[[Gnar ly] windDownFinishedContinueTransaction:self];
}


/**
 * Delegate function. Called by the Gnarly system. You don't ever call this function.
 *
 * When the sprite has signaled that it is ready to continue the transaction after its wind-down, the surface
 * may or may not begin some kind of a wind down process. At this time, the sprite will be considered
 * in its end-of-life. If you have any extra confinguration to do on the sprite here, like perhaps another 
 * animation, then you can trigger that here.
 *
 */
- (void) gnarlySaysConfigureForEnd {}




@end
