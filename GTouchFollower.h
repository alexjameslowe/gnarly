//
//  GTouchFollower.h
//  RidiculousMissile3
//
//  Created by Alexander  Lowe on 5/5/11.
//  Copyright 2011 Codequark. See Licence.
//

#import "GSprite.h"
#import "GTouchLine.h"
#import "GMath.h"


@interface GTouchFollower : GSprite {

GTouchLine *followLine;

float followSpeed;

BOOL following;

CGPoint targPt;
CGPoint currPt;
float stackFollow;

BOOL followFF;

float xDiff;
float yDiff;
float ratio;

float currRotation;
float rotationDiff;

BOOL addLineToRoot;
BOOL ownsEvents;

int addLineAt;
    
}



- (void) setTotalLength:(float)len;
- (float) totalLength;

- (id) init:(NSString *)key ownsEvents:(BOOL)owns addLineToRootOrParent:(BOOL)oneOrTheOther atIndex:(int)index;

- (void) startLine;
- (void) drawLineX:(float)xCoord andY:(float)yCoord;

- (void) setReachedEnd:(BOOL)bl;
- (BOOL) reachedEnd;

@property (nonatomic, assign) float followSpeed;

@end
