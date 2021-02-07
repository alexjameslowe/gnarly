//
//  GResourceCycler.m
//  CosmicDolphin_7_5
//
//  Created by Alexander Lowe on 4/20/13.
//  Copyright (c) 2013 Alex Lowe. See Licence.
//

#import "GResourceCycler.h"

@implementation GResourceCycler




/*
- (void) incrementShowStopperAgeWithPlanet:(Planet *)plnt {
    
    if(_newShowStopperIsReady == YES) {
        _newShowStopperIsReady = NO;
    //    plnt.isLastPlanetInTheCurrentShowStopper = YES;
    }
    
    //tick up the stack variable.
    _currentShowStopperStack++;
    //NSLog(@"Regime is incremented.  _currentGraphicsStack: %d%@%i",_currentGraphicsStack,@"   _currentGraphicsRegime: ",_currentGraphicsRegime);
    
    //we only want to load a new regime under a specific set of conditions: 1.) The current regime is sufficiently
    //old. 2.) There is not a regime currently loading. 3.) The ancestor of the current regime has been destroyed,
    //guaranteeing that there will not be any more than two regimes on the screen at any time.
    if(_currentShowStopperStack >= _showStopperLimit && _newRegimeIsLoading == NO && _newShowStopperIsLoading == NO && _oldShowStopperIsDestroyed == YES) {
        
        //the new regime. if it's out-of-bounds, then reset it to 0.
        int newRegime = _currentShowStopper+1;
        
        if(newRegime >= _numberOfShowStoppers) {
            newRegime = 0;
        }
        
        _newShowStopperAtlasKey = [[(CXMLElement *)[showStopperMetaNodes objectAtIndex:newRegime] attributeForName:@"class_name"] stringValue];
        
        //so new there is a new regime loading.
        _newShowStopperIsLoading = YES;
        
        //reset this flag.
        _oldShowStopperIsDestroyed = NO;
        
        //reset this counter.
        _currentShowStopperStack = 0;
        
        //textureHistory++;
        //NSLog(@"textureHistory: %i",textureHistory);
        
        //the keys for the resource lists match the keys for the atlases themselves. load the new regime,
        //and use the callback newRegimeIsLoaded. when that callback fires, it will update all of the
        //regime information so that this function will start issuing planets under the new graphics regime.
        //[self createNewResourcesForKey:_newShowStopperAtlasKey withCallback:@"newShowStopperIsLoaded" andObserver:self];
        [[Gnar ly] createNewResourcesForKey:_newShowStopperAtlasKey withCallback:@"newShowStopperIsLoaded" andObserver:self forSurface:self];
        
    } 
    
}
*/


@end
