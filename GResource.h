//
//  GResource.h
//  CosmicDolphin_5_2
//
//  Created by Alexander  Lowe on 8/4/11.
//  
//

#import <Foundation/Foundation.h>
#import "GLayerMemoryObject.h"


@interface GResource : NSObject {

//the type of resource this is. 0 if texture. 1 if sprite map. 2 if sound. 3 if background music.
int resourceType;
NSString *fileName;
NSString *fileExtension;
NSString *key;
NSString *nameOfClass;
SEL worker;
id <GLayerMemoryObject> owner;
BOOL ownedBySurface;
    
}

@property (nonatomic, readonly) int resourceType;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileExtension;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *nameOfClass;
@property (nonatomic, readonly) BOOL ownedBySurface;
@property (nonatomic, readonly) SEL worker;
@property (nonatomic, readonly) id <GLayerMemoryObject> owner;

//- (id) initMap:(NSString *)clss;

- (id) initSound:(NSString *)ky fileName:(NSString *)file extension:(NSString *)ext ownedBySurface:(BOOL)del;

- (id) initMusic:(NSString *)ky fileName:(NSString *)file extension:(NSString *)ext ownedBySurface:(BOOL)del;

- (id) initTexture:(NSString *)ky withFile:(NSString *)file extension:(NSString *)ext andMap:(NSString *)clss;

- (id) initXML:(NSString *)ky withFile:(NSString *)file;

- (id) initWorker:(NSString *)wrkr andOwner:(id <GLayerMemoryObject>)ownr;

- (id) initPreloader:(NSString *)clss withKey:(NSString *)ky;

@end
