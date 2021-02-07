//
//  GRenderable.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 10/17/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.

/////////////////////////////////////////////////////////////////////
//                                                                 //
//  The core renderable base class. contains the prevSib, nextSib  //
//  variables which chains all of renderable objects together in   //
//  a big renderable chain which is read out in the GSurface's     //
//  render loop.                                                   //
//                                                                 //
/////////////////////////////////////////////////////////////////////


#import <Foundation/Foundation.h>

@interface GRenderable : NSObject {

GRenderable *prev;

GRenderable *next;

BOOL isPop;

BOOL visible;
    
    NSString *name2;

}

@property (nonatomic, assign) BOOL isPop;
@property (nonatomic, assign) BOOL visible;

@property (nonatomic, assign) NSString *name2;

- (GRenderable *) render;

- (void) testTouchDown;

- (void) calcAffine;

- (void) destroy;

- (void) releaseResources;

- (void) setPrev:(GRenderable *)prv;
- (void) setNext:(GRenderable *)nxt;

- (GRenderable *) prev;
- (GRenderable *) next;


@end
