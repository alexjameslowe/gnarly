//
//  GSimpleButton.h
//  RidiculousMissile2
//
//  Created by Alexander  Lowe on 4/26/11.
//  Copyright 2011 Codequark. See Licence.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "GSprite.h"
#import "GLayerMemoryObject.h"



@interface GSimpleButtonSkin : NSObject {

//int upLeftCapPosition;
//int downLeftCapPosition;

//int upRightCapPosition;
//int downRightCapPosition;

//int upMiddlePosition;
//int downMiddlePosition;

int upPosition;
int downPosition;

//if YES, then we're just going to use a single background for the buttons.
//and the text is going to be a dynamic text field.
//BOOL dynamicText;

//if dynamicText is yes, then this variable is important. If YES, then the 
//middle piece is going to scale automatically to accomadate whatever text
//is in the middle.
//BOOL hasMiddle;

}




@end




@interface GSimpleButton : GSprite {
    
//the up position for the button on the map.
int downPosition;

//the down position for the button on the map.
int upPosition;

//the skin of the button.
//GSimpleButtonSkin *buttonSkin;


GTexture *buttonTex;
GSpriteMap *buttonMap;

int stackCount;
int countLimit;
BOOL btnDown;
BOOL btnReleased;

//the event to dispatch when the button is selected.
NSString *eventOnSelect;

//the callback.
SEL callback;

//if YES, dispatch an event. if NO, then fire a callback.
BOOL eventOrCallback;

//the observer for the callback, or the target to dispatch the event.
id <GLayerMemoryObject> callbackObserver;

//the button id.
int buttonId;
    
}


- (id) init:(NSString *)key up:(int)u down:(int)d event:(NSString *)evt;

- (id) init:(NSString *)key up:(int)u down:(int)d callback:(NSString *)cllbck observer:(id <GLayerMemoryObject>)obs;

@property (nonatomic, assign) int buttonId;

@end
