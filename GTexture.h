//
//  Texture.h
//  LM2
//
//  Created by Alexander  Lowe on 1/29/11.
//  Copyright 2011 Codequark. See Licence.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


/**
 * the texture wrapper. an object that is convenient to trade around so that we don't have to worry about
 * keeping track of the widths and heights all the time.
 *
 */
@interface GTexture : NSObject {

NSInteger textureHeight;

NSInteger textureWidth;

GLuint texture;

GLuint *address;

int uID;
	
}

@property (nonatomic, assign) NSInteger textureHeight;

@property (nonatomic, assign) NSInteger textureWidth;

@property (nonatomic, assign) GLuint texture;

@property (nonatomic, assign) GLuint *address;

@property (nonatomic, assign) int uID; 

@end




@interface GPNGTexture : NSObject {}

+ (CGPoint)makeTexture:(NSString *)imageName withTextureObject:(GTexture *)textureObj;

+ (GTexture *) getTexture:(NSString *)imageName;

+ (NSInteger) textureHeight;

+ (NSInteger) textureWidth;

@end
