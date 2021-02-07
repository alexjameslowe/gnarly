//
//  GRenderable.m
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 10/17/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//


#import "GRenderable.h"

@implementation GRenderable



@synthesize isPop,visible;
@synthesize name2;


- (GRenderable *) render {
return self;
}


//empty function.
- (void) calcAffine {};

- (void) testTouchDown {};



//  we're declaring accessors explicitly instead of using the synthesize directive, because
//  synthesized accessors will send release messages to objects that occupy these spaces
//  when they are replaced with nil.
// 
- (void) setPrev:(GRenderable *)prv {
prev = prv;
}
- (void) setNext:(GRenderable *)nxt {
next = nxt;
}


- (GRenderable *) prev {
return prev;
}
- (GRenderable *) next {
return next;
}



- (void) destroy {}


/**
 * release messages are tightly controlled by this library. unless you have cause to insert object into arrays
 * of your own, this should be the only place that the release message lives for all GRenderable classes.
 *
 */
- (void) releaseResources {
[self release];
}



@end
