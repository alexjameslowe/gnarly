//
//  Texture.m
//  LM2
//
//  Created by Alexander  Lowe on 1/29/11.
//  Copyright 2011 Codequark. See Licence.
//

#import "GTexture.h"
#import "GSprite.h"

#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

@implementation GTexture

@synthesize textureWidth,textureHeight;
@synthesize texture;
@synthesize address;
@synthesize uID;

- (id) init {

self.address = &texture;

return self;
}

//the only thing to dealloc is the texture.
- (void) dealloc {

    //if(glIsTexture(*self.address) != GL_TRUE) {
    //NSLog(@"OPEN GL IS BACK TO IT'S OLD TRICKS!!");
    //}

glDeleteTextures(1, self.address);

[super dealloc];
}

@end







static NSInteger _texWidth  = 0;
static NSInteger _texHeight = 0;
static int numberOfTextures = 0;


@implementation GPNGTexture

/*
+ (void)makeTexture:(NSString *)imageName withTextureObject:(GTexture *)textureObj {
	
	//NSString *im = [imageName stringByAppendingString:@".png"];
	//CGImageRef textureImage = [UIImage imageNamed:im].CGImage;
    //might avoid a caching problem by using this code:
    //http://www.idevgames.com/forums/thread-1194-post-59137.html#pid59137
    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    CGImageRef textureImage = image.CGImage; 
    
    
        if (textureImage == nil) {
		NSLog(@"Failed to load texture image");
        }
	
	NSInteger texWidth = CGImageGetWidth(textureImage);
    NSInteger texHeight = CGImageGetHeight(textureImage);
	
	_texWidth = texWidth;
	_texHeight = texHeight;

	
	//The correct amount of data to allocate is the width multiplied by the height, **multiplied by 4**. 
	// Remember from the last tutorial that OpenGL only accepts RGBA values? Each pixel is 4 bytes in size, 
	// one byte for each of the RGBA values.
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	//GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 8);
	
	CGContextRef textureContext = CGBitmapContextCreate(textureData,
														texWidth,
														texHeight,
														8, texWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	
	CGContextDrawImage(textureContext,
					   CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight),
					   textureImage);
	
	CGContextRelease(textureContext);
	
	
	//generate one texture and assign it to a value in the textures variable.
    glGenTextures(1, textureObj.address);
    

	//Next we need to activate the texture which we just generated:
	//////////////////////////
    GLuint *pt = textureObj.address;
    GLuint d = *pt;
    glBindTexture(GL_TEXTURE_2D, d);
    
	//Next, we send our texture data (pointed to by textureData) into OpenGL. 
	// OpenGL manages the texture data over on 'it’s' side (the server side) so 
	// the data is converted in the required format for the hardware implementation, 
	// and copied into OpenGL’s space.  It’s a bit of a mouthful but most parameters 
	// will always be the same due to the limitations of OpenGL ES.
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	//glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, textureData);
	

	//free the texture data.
	free(textureData);
	
    [texData release];
    [image release];
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
}*/

+ (CGPoint) makeTexture:(NSString *)imageName withTextureObject:(GTexture *)textureObj {
    
	//NSString *im = [imageName stringByAppendingString:@".png"];
	//CGImageRef textureImage = [UIImage imageNamed:im].CGImage;
    //might avoid a caching problem by using this code:
    //http://www.idevgames.com/forums/thread-1194-post-59137.html#pid59137
    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    
    //CGImageRef textureImage = image.CGImage;
    //NSLog(@"makeTexture:%@",imageName);
    
     //Image size
    //NSInteger width = CGImageGetWidth(image.CGImage);
    //NSInteger height = CGImageGetHeight(image.CGImage);
    
    int width = (int)CGImageGetWidth(image.CGImage);
    int height = (int)CGImageGetHeight(image.CGImage);
    
    //_texWidth = width;
	//_texHeight = height;
    
        if(width == 0 || height == 0) {
        [NSException raise:@"Error" format:@" GTexture: makeTexture:withTextureObject: There is no texture file %@%@",imageName,@".png"];
        }
    
    glGenTextures(1, textureObj.address);
    
    //Create context
    void *imageData = malloc(height * width * 4);
    
    //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(image.CGImage);
    CGColorSpaceRef colorSpace =CGImageGetColorSpace(image.CGImage);
    
    
       //NSLog(@"image data 1 %s",imageData);
    
    //CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
       //NSLog(@"image data 2 %s",imageData);
    
    //CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    
    //CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGBitmapByteOrder32Big);
    
    
        /*
    	CGContextRef context = CGBitmapContextCreate(imageData,
														width,
														height,
														8, width * 4,
														CGImageGetColorSpace(image.CGImage),
														kCGImageAlphaPremultipliedLast);
                                                        */
    
    //we were leaking memory with this. 
    //CGColorSpaceRelease(colorSpace);
    

    //Prepare image
    CGContextClearRect(context, CGRectMake(0, 0, width, height));
    
       //NSLog(@"image data 4 %s",imageData);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    
       //NSLog(@"image data 5 %s",imageData);

    //Bind texture
    glBindTexture(GL_TEXTURE_2D, *(textureObj.address));
    
       //NSLog(@"image data 6 %s",imageData);

    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //glTexParameterf(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //NSLog(@"image data 7 %s",imageData);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    //glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
   


    //Release
    CGContextRelease(context);
    free(imageData);
     [texData release];
    
    
    [image release];
    
    
    CGPoint pt = CGPointMake((CGFloat)width, (CGFloat)height);
    
    return pt;
}



/**
 * use the makeTexture function to create a texture object and give it the 
 * correct width and height properties. This saves us from writing a whole log
 * of tedious production code.
 *
 */
+ (GTexture *) getTexture:(NSString *)imageName {

GTexture *txt = [[GTexture alloc] init];

/////////////
CGPoint pt = [GPNGTexture makeTexture:imageName withTextureObject:txt];
    
txt.textureWidth = (NSInteger)pt.x;
txt.textureHeight = (NSInteger)pt.y;
    
//txt.textureWidth  = [GPNGTexture textureWidth];
//txt.textureHeight = [GPNGTexture textureHeight];

txt.uID = numberOfTextures;

numberOfTextures++;

//we have a new unique id, so we need to force
//a texture rebinding for background loading.
[GSprite newTextureRequiresBoundIndexUpdate:-1];

return txt;
}




+ (NSInteger) textureHeight {
return _texHeight;	
}


+ (NSInteger) textureWidth {
return _texWidth;	
}


- (void) dealloc {
    NSLog(@"    GTexture deallocing!");
    [super dealloc];
}


@end
