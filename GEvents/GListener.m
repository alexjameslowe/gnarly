//
//  GListener.m
//  gravity_pong_10
//
//  Created by Alexander  Lowe on 5/17/10.
//  Copyright 2010 Codequark. See Licence.
//

#import "GListener.h"


@implementation GListener

@synthesize observer;

@synthesize callback;


- (id) initWithCallback:(SEL)cllbck andObserver:(id <GLayerMemoryObject>)obs {
    
    self = [super init];

    callback = cllbck;

    observer = obs;

    return self;

}

@end
