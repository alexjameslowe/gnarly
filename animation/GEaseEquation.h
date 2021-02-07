//
//  GEaseEquation.h
//  CosmicDolphin_7
//
//  Created by Alexander  Lowe on 11/13/12.
//  Copyright (c) 2012 Alex Lowe. See Licence.
//

#import <Foundation/Foundation.h>

@interface GEaseEquation : NSObject {}
- (float) runStart:(float)b delta:(float)c time:(float)t duration:(float)d;
@end


@interface GEase_easeNone : GEaseEquation
@end

@interface GEase_easeInCubic : GEaseEquation
@end

@interface GEase_easeOutCubic : GEaseEquation
@end

@interface GEase_easeInOutCubic : GEaseEquation
@end

@interface GEase_easeInQuad : GEaseEquation
@end

@interface GEase_easeOutQuad : GEaseEquation
@end

@interface GEase_easeInOutQuad : GEaseEquation
@end

@interface GEase_easeInBounce : GEaseEquation
- (float) runBounce:(float)b delta:(float)c time:(float)t duration:(float)d;
@end

@interface GEase_easeOutBounce : GEaseEquation
@end

@interface GEase_easeInBack : GEaseEquation
@end

@interface GEase_easeOutBack : GEaseEquation
@end
