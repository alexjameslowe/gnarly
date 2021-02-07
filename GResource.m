//
//  GResource.m
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 8/4/11.
//  
//

#import "GResource.h"


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                                                                        //
    //  These classes are simple data containers used during the initialization of GSurface rendering surfaces.  //
    //  They are used to tell the GSurface object to initialize textures, sprite maps and sounds. These classes  //
    //  all inherit from a very basic class, GResource.                                                       //
    //                                                                                                        //
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GResource

@synthesize resourceType;
@synthesize fileName,fileExtension,key;
@synthesize nameOfClass;
@synthesize ownedBySurface;
@synthesize worker;
@synthesize owner;

/*
- (id) initTexture:(NSString *)file extension:(NSString *)ext withKey:(NSString *)ky {

self = [super init];
fileName = file;
fileExtension = ext;
resourceType = 0;
key = ky;

return self;

}

- (id) initMap:(NSString *)clss withKey:(NSString *)ky {

self = [super init];
nameOfClass = clss;
resourceType = 1;
key = ky;

return self;
/Users/alexanderlowe/Documents/iPhone/CosmicDolphin/CosmicDolphin_6/CosmicDolphin/Gnarly/GResource.h
}*/

- (id) initTexture:(NSString *)ky withFile:(NSString *)file extension:(NSString *)ext andMap:(NSString *)clss {

self = [super init];
self.fileName = file;
self.fileExtension = ext;
resourceType = 0;
self.nameOfClass = clss;
self.key = ky;

return self;

}

- (id) initXML:(NSString *)ky withFile:(NSString *)file {

self = [super init];
self.fileName = file;
self.fileExtension = @"xml";
resourceType = 1;
self.key = ky;

return self;

}


- (id) initSound:(NSString *)ky fileName:(NSString *)file extension:(NSString *)ext ownedBySurface:(BOOL)del {

self = [super init];
self.key = ky;
self.fileName = file;
self.fileExtension = ext;
resourceType = 2;
ownedBySurface = del;

return self;
}


- (id) initMusic:(NSString *)ky fileName:(NSString *)file extension:(NSString *)ext ownedBySurface:(BOOL)del {

self = [super init];
self.key = ky;
self.fileName = file;
self.fileExtension = ext;
resourceType = 3;
ownedBySurface = del;

return self;
}


- (id) initPreloader:(NSString *)clss withKey:(NSString *)ky {

self = [super init];
self.key = ky;
self.nameOfClass = clss;
resourceType = 4;

return self;
}


- (id) initWorker:(NSString *)wrkr andOwner:(id <GLayerMemoryObject>)ownr {
self = [super init];
worker = NSSelectorFromString(wrkr);
owner = ownr;
resourceType = 5;

return self;
}


- (void) dealloc {

    if(key) {
    [self.key release];
    key = nil;
    }
    if(nameOfClass) {
    [self.nameOfClass release];
    nameOfClass = nil;
    }
    if(fileExtension) {
    [self.fileExtension release];
    fileExtension = nil;
    }
    if(fileName) {
    [self.fileName release];
    fileName = nil;
    }

[super dealloc];
}


@end


