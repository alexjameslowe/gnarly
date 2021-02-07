//
//  GListener.h
//  gravity_pong_10
//
//  Created by Alexander  Lowe on 5/17/10.
//  Copyright 2010 Codequark. See Licence.
//

#import <Foundation/Foundation.h>
#import "GLayerMemoryObject.h"


@interface GListener : NSObject {

id <GLayerMemoryObject> observer;

SEL callback;

}

- (id) initWithCallback:(SEL)cllbck andObserver:(id <GLayerMemoryObject>)obs;

@property(nonatomic, assign) id <GLayerMemoryObject> observer;

@property(assign) SEL callback;

@end
