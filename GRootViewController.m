//
//  GRootViewController.m
//  BraveRocket
//
//  Created by Alexander Lowe on 7/9/16.
//  Copyright © 2016 Alexander Lowe. See Licence.
//

#import "GRootViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                       //
//    Here's the view-controller that we use for the window's shared root-view-controller.               //
//    Right now we're just using it to lock the rotations so that the darned screen doesn't              //
//    try to rotate.                                                                                     //
//                                                                                                       //
//    I know perfectly well that in the future we're going to have to have some kind of system for       //
//    crystallizing the options for each rendering surface inside it's own UIViewController subclass.    //
//    Right now this class holds sway for ALL of the rendering surfaces. So right now this is ad-hoc     //
//    but I'm pretty sure that more use-cases will rear their heads which will force me to think about   //
//    how to make this all systematic and formal. It never ends.                                         //
//                                                                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GRootViewController

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    //return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    //return UIInterfaceOrientationPortrait;
    return UIInterfaceOrientationLandscapeLeft;
}


//- (BOOL) shouldAutorotate {
//    return NO;
//}


@end
