//
//  GAudio.h
//  BraveRocket
//
//  Created by Alexander Lowe circa 2011
//  Copyright © 2016 Alexander Lowe. See Licence.
//
// This sound engine class has been created based on the OpenAL tutorial at
// http://benbritten.com/blog/2008/11/06/openal-sound-on-the-iphone/
//
// http://stackoverflow.com/questions/2124622/trying-to-fix-memory-leak-using-avaudioplayer
// http://stackoverflow.com/questions/1352588/avaudioplayer-memory-leak
//
//
// http://www.paradeofrain.com/2010/02/iphone-dev-tip-2-openal-performance/
//
//
// THANK YOU - migrating to non-deprecated AVAudioSession functions.
// https://github.com/software-mariodiana/AudioBufferPlayer/wiki/Replacing-C-functions-deprecated-in-iOS-7
// http://stackoverflow.com/questions/13078901/cocos2d-2-1-delegate-deprecated-in-ios-6-how-do-i-set-the-delegate-for-this
//
// THANK YOU - handling interruption notifications.
// https://stackoverflow.com/questions/31806155/ios-avaudiosession-interruption-notification-not-working-as-expected

#import "GAudio.h"



@interface GAudio (Private)
- (BOOL)initOpenAL;
- (GAudioOpenALSource *) nextAvailableSource;
- (AudioFileID) openAudioFile:(NSString*)theFilePath;
- (UInt32) audioFileSize:(AudioFileID)fileDescriptor;
@end

@implementation GAudioOpenALSource
@synthesize source;
@synthesize currentSoundKey;
@synthesize isPaused;

- (id) init {
    
self = [super init];
isPaused = NO;
currentSoundKey = @"";
return self;
    
}

- (ALuint) sourceAsALuint {
return (ALuint)[source unsignedIntegerValue];
}

@end


@implementation GAudio

@synthesize asynchProgress;

// This var will hold our Singleton class instance that will be handed to anyone who asks for it
static GAudio *sharedSoundManager = nil;

// Class method which provides access to the sharedSoundManager var.
+ (GAudio *)sharedSoundManager {
    
    // synchronized is used to lock the object and handle multiple threads accessing this method at
    // the same time
    @synchronized(self) {
        
        // If the sharedSoundManager var is nil then we need to allocate it.
        if(sharedSoundManager == nil) {
            // Allocate and initialize an instance of this class
            [[self alloc] init];
        }
    }
    
    // Return the sharedSoundManager
    return sharedSoundManager;
}


/* This is called when you alloc an object.  To protect against instances of this class being
 allocated outside of the sharedSoundManager method, this method checks to make sure
 that the sharedSoundManager is nil before allocating and initializing it.  If it is not
 nil then nil is returned and the instance would need to be obtained through the sharedSoundManager method
 */
+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedSoundManager == nil) {
            sharedSoundManager = [super allocWithZone:zone];
            return sharedSoundManager;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


/*
 When the init is called from the sharedSoundManager class method, this method will get called.
 This is where we then initialize the arrays and dictionaries which will store the OpenAL buffers
 create as well as the soundLibrary dictionary
 */
- (id)init {
    
    self = [super init];
    
    soundSources        = [[NSMutableArray      alloc] init];
    
    commonMusic         = [[NSMutableArray      alloc] init];
    commonSounds        = [[NSMutableArray      alloc] init];
    
    soundLibrary        = [[NSMutableDictionary alloc] init];
    //soundSrcLibrary     = [[NSMutableDictionary alloc] init];
    
    musicLibrary        = [[NSMutableDictionary alloc] init];
    musicPlayerLibrary  = [[NSMutableDictionary alloc] init];
    
    pausedSounds        = [[NSMutableDictionary alloc] init];
    
    // Set the default volume for music
    backgroundMusicVolume = 1.0f;
    
    pausePlayToggle = NO;
    
    // Set up the OpenAL
    BOOL result = [self initOpenAL];
    if(!result)	return nil;
    return self;
    
    
    //}
    //[self release];
    //return nil;
}


///// deleted
//void interruptionListenerCallback (void   *inUserData, UInt32    interruptionState ) {
//    
//    // you could do this with a cast below, but I will keep it here to make it clearer
//    GAudio *controller = (GAudio *) inUserData;
//    
//    if (interruptionState == kAudioSessionBeginInterruption) {
//        [controller sessionAVInterruption_haltOpenALSession];
//    } else if (interruptionState == kAudioSessionEndInterruption) {
//        [controller sessionAVInterruption_resumeOpenALSession];
//    }
//}


/*
- (void) sessionAVInterruption_haltOpenALSession {
    NSLog(@"sessionAVInterruption_haltOpenALSession is firing");
    
    // Deactivate the current audio session
    AudioSessionSetActive(NO);
    //Next, shut down openAL in a nice way so you can keep your context intact:
    ALenum err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (0): %d",err);
    
    // set the current context to NULL will 'shutdown' openAL
    alcMakeContextCurrent(NULL);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (1): %d",err);
    
    // now suspend your context to 'pause' your sound world
    alcSuspendContext(context);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (2): %d",err);
    
}

- (void) sessionAVInterruption_resumeOpenALSession {
    NSLog(@"sessionAVInterruption_resumeOpenALSession is firing");
    
    // Reset audio session
    //UInt32 category = kAudioSessionCategory_PlayAndRecord;
    //kAudioSessionCategory_AmbientSound;
    UInt32 category = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty ( kAudioSessionProperty_AudioCategory, sizeof (category), &category );
    
    ALenum err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (0): %d",err);
    
    // Restore open al context
    alcMakeContextCurrent(context);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (2): %d",err);
    
    // 'unpause' my context
    alcProcessContext(context);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (3): %d",err);
    
    // Reactivate the current audio session as the last step.
    AudioSessionSetActive(YES);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (1): %d",err);
    
}
*/
//////////// NEW ///////

- (BOOL) stopAudioSession {
    NSError *deactivationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive:NO error:&deactivationError];
    if (!success) {
    avAudioSessionError =  [deactivationError localizedDescription];
    }
    return success;
}
- (BOOL) startAudioSession {
    BOOL success = NO;
    
    NSError *error = nil;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    success = [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!success) {
        avAudioSessionError = [NSString stringWithFormat:@"%@ Error setting category: %@",
                               NSStringFromSelector(_cmd), [error localizedDescription]];
        //NSLog(@"%@ Error setting category: %@",
        //NSStringFromSelector(_cmd), [error localizedDescription]);
        
        // Exit early
        return success;
    }
    
    success = [session setActive:YES error:&error];
    if (!success) {
        //NSLog(@"%@", [error localizedDescription]);
    avAudioSessionError = [error localizedDescription];
    }
    
    return success;
}

- (void) sessionAVInterruption_haltOpenALSession {
//NSLog(@"sessionAVInterruption_haltOpenALSession is firing");
    
    // Deactivate the current audio session
    //AudioSessionSetActive(NO);
    if(![self stopAudioSession]) {
    NSLog(@"Error: Error sessionAVInterruption_haltOpenALSession (-1): %@",avAudioSessionError);
    }

    //Next, shut down openAL in a nice way so you can keep your context intact:
    ALenum err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (0): %d",err);
    
    // set the current context to NULL will 'shutdown' openAL
    alcMakeContextCurrent(NULL);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (1): %d",err);
    
    // now suspend your context to 'pause' your sound world
    alcSuspendContext(context);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (2): %d",err);
    
}

- (void) sessionAVInterruption_resumeOpenALSession {
//NSLog(@"sessionAVInterruption_resumeOpenALSession is firing");
    
    // Reset audio session
    //UInt32 category = kAudioSessionCategory_PlayAndRecord;
    //kAudioSessionCategory_AmbientSound;
    //UInt32 category = kAudioSessionCategory_MediaPlayback;
    //AudioSessionSetProperty ( kAudioSessionProperty_AudioCategory, sizeof (category), &category );
    
    ALenum err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (0): %d",err);
    
    // Restore open al context
    alcMakeContextCurrent(context);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (2): %d",err);
    
    // 'unpause' my context
    alcProcessContext(context);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (3): %d",err);
    
    // Reactivate the current audio session as the last step.
    //AudioSessionSetActive(YES);
    err = alGetError();
    if (err != 0) NSLog(@"Error sessionAVInterruption_haltOpenALSession (1): %d",err);
    
    if(![self startAudioSession]) {
    NSLog(@"Error sessionAVInterruption_haltOpenALSession (4): %d",err);
    }
    
}

////////////////////////



/*
 This method is used to initialize OpenAL.  It gets the default device, creates a new context
 to be used and then preloads the define # sources.  This preloading means we wil be able to play up to
 (max 32) different sounds at the same time
 */
//[[AVAudioSession sharedInstance] setDelegate:_player];
/*
- (BOOL) initOpenAL {
    // Get the device we are going to use for sound.  Using NULL gets the default device
    device = alcOpenDevice(NULL);
    
    // If a device has been found we then need to create a context, make it current and then
    // preload the OpenAL Sources
    if(device) {
        // Use the device we have now got to create a context "air"
        context = alcCreateContext(device, NULL);
        // Make the context we have just created into the active context
        alcMakeContextCurrent(context);
        // Pre-create 32 sound sources which can be dynamically allocated to buffers (sounds)
        //NSUInteger sourceID;
        
        
        //#########New for phone interruption bug#####
        OSStatus result = AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, self);
        
        UInt32 category = kAudioSessionCategory_AmbientSound;
        result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        //////////////
        
        
        for(int index = 0; index < kMaxSources; index++) {
            ALuint sourceID;
            // Generate an OpenAL source
            alGenSources(1, &sourceID);
            // Add the generated sourceID to our array of sound sources
            //[soundSources addObject:[NSNumber numberWithUnsignedInt:sourceID]];
            GAudioOpenALSource *source = [[GAudioOpenALSource alloc] init];
            source.source = [NSNumber numberWithUnsignedInt:sourceID];
            [soundSources addObject:source];
            //this will make it wholly owned by the array. when the object is
            //removed from the array it will dealloc automatically.
            [source release];
        }
        
        // Return YES as we have successfully initialized OpenAL
        return YES;
    }
    // Something went wrong so return NO
    return NO;
}
*/


/*
- (BOOL) initOpenAL {
    
    BOOL success = NO;
    NSError *error = nil;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
    

    
    success = [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!success) {
        NSLog(@"%@ Error setting category: %@",
              NSStringFromSelector(_cmd), [error localizedDescription]);
        
        // Exit early
        return success;
    }
    
    success = [session setActive:YES error:&error];
    if (!success) {
    NSLog(@"%@", [error localizedDescription]);
    }
    
    return success;
    
}
 */


- (BOOL) initOpenAL {
    // Get the device we are going to use for sound.  Using NULL gets the default device
    device = alcOpenDevice(NULL);
    
    // If a device has been found we then need to create a context, make it current and then
    // preload the OpenAL Sources
    if(device) {
        // Use the device we have now got to create a context "air"
        context = alcCreateContext(device, NULL);
        // Make the context we have just created into the active context
        alcMakeContextCurrent(context);
        // Pre-create 32 sound sources which can be dynamically allocated to buffers (sounds)
        //NSUInteger sourceID;
        
        
        //#########New for phone interruption bug#####
        //OSStatus result = AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, self);
        //UInt32 category = kAudioSessionCategory_AmbientSound;
        //result = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        //////////////
        
        [self startAudioSession];
        
        //??
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:nil];
        
        
        for(int index = 0; index < kMaxSources; index++) {
            ALuint sourceID;
            // Generate an OpenAL source
            alGenSources(1, &sourceID);
            // Add the generated sourceID to our array of sound sources
            //[soundSources addObject:[NSNumber numberWithUnsignedInt:sourceID]];
            GAudioOpenALSource *source = [[GAudioOpenALSource alloc] init];
            source.source = [NSNumber numberWithUnsignedInt:sourceID];
            [soundSources addObject:source];
            //this will make it wholly owned by the array. when the object is
            //removed from the array it will dealloc automatically.
            [source release];
        }
        
        // Return YES as we have successfully initialized OpenAL
        return YES;
    }
    // Something went wrong so return NO
    return NO;
}



////// NEW

- (void) interruption:(NSNotification*)notification {
    //NSDictionary *interuptionDict = notification.userInfo;
    //NSLog(@"interruption:(NSNotification*)notification !!! %@",notification);
    //NSUInteger interuptionType = (NSUInteger)[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    ///NSLog(@"interuptionType! %int",(int)interuptionType);
    
    //if (interuptionType == AVAudioSessionInterruptionTypeBegan) {
    //    [self beginInterruption];
    //} else if (interuptionType == AVAudioSessionInterruptionTypeEnded) {
    //    [self endInterruption];
    //}
    
    //https://stackoverflow.com/questions/31806155/ios-avaudiosession-interruption-notification-not-working-as-expected
    //thank you!
    if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey]
         isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
        
    //NSLog(@"InterruptionTypeBegan");
    [self beginInterruption];
    } else {
    //NSLog(@"InterruptionTypeEnded");
    [self endInterruption];
    }
    
}


- (void)beginInterruption
{
    
    //NSLog(@"beginInterruption is firing!!!!");
    //[self tearDownAudio];
    [self sessionAVInterruption_haltOpenALSession];
}

- (void)endInterruption
{
    
    //NSLog(@"HEY! endInterruption is firing!!");
    
    [self sessionAVInterruption_resumeOpenALSession];
    
    //[self setUpAudio];
    //[self start];
}



///////////




void* MyGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei*	outSampleRate) {
    OSStatus						err = noErr;
    SInt64							theFileLengthInFrames = 0;
    //UInt32                          theFileLengthInFrames = 0;
    AudioStreamBasicDescription		theFileFormat;
    UInt32							thePropertySize = sizeof(theFileFormat);
    ExtAudioFileRef					extRef = NULL;
    void*							theData = NULL;
    AudioStreamBasicDescription		theOutputFormat;
    
    // Open a file with ExtAudioFileOpen()
    err = ExtAudioFileOpenURL(inFileURL, &extRef);
    if(err) { NSLog(@"MyGetOpenALAudioData: ExtAudioFileOpenURL FAILED, Error = %i", err); goto Exit; }
    
    // Get the audio data format
    err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat);
    if(err) { NSLog(@"MyGetOpenALAudioData: ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = %i", err); goto Exit; }
    if (theFileFormat.mChannelsPerFrame > 2)  { printf("MyGetOpenALAudioData - Unsupported Format, channel count is greater than stereo\n"); goto Exit;}
    
    // Set the client format to 16 bit signed integer (native-endian) data
    // Maintain the channel count and sample rate of the original source format
    theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
    theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;
    
    theOutputFormat.mFormatID = kAudioFormatLinearPCM;
    theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
    theOutputFormat.mFramesPerPacket = 1;
    theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
    theOutputFormat.mBitsPerChannel = 16;
    theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    
    // Set the desired client (output) data format
    err = ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(theOutputFormat), &theOutputFormat);
    if(err) { NSLog(@"MyGetOpenALAudioData: ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = %i", err); goto Exit; }
    
    // Get the total frame count
    thePropertySize = sizeof(theFileLengthInFrames);
    err = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames);
    if(err) { NSLog(@"MyGetOpenALAudioData: ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = %i", err); goto Exit; }
    
    // Read all the data into memory
    UInt32		dataSize = (UInt32)theFileLengthInFrames * theOutputFormat.mBytesPerFrame;
    theData = malloc(dataSize);
    if (theData)
    {
        AudioBufferList		theDataBuffer;
        theDataBuffer.mNumberBuffers = 1;
        theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
        theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
        theDataBuffer.mBuffers[0].mData = theData;
        
        // Read the data into an AudioBufferList
        err = ExtAudioFileRead(extRef, (UInt32*)&theFileLengthInFrames, &theDataBuffer);
        if(err == noErr)
        {
            // success
            *outDataSize = (ALsizei)dataSize;
            *outDataFormat = (theOutputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
            *outSampleRate = (ALsizei)theOutputFormat.mSampleRate;
        }
        else
        {
            // failure
            free (theData);
            theData = NULL; // make sure to return NULL
            NSLog(@"MyGetOpenALAudioData: ExtAudioFileRead FAILED, Error = %i", err); goto Exit;
        }
    }
    
Exit:
    // Dispose the ExtAudioFileRef, it is no longer needed
    if (extRef) ExtAudioFileDispose(extRef);
    return theData;
}



/*
 Used to load an audiofile from the file path which is provided.
 */
- (AudioFileID) openAudioFile:(NSString*)theFilePath {
    
    AudioFileID outAFID;
    // Create an NSURL which will be used to load the file.  This is slightly easier
    // than using a CFURLRef
    NSURL *afUrl = [NSURL fileURLWithPath:theFilePath];
    
    // Open the audio file provided
    //OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
    OSStatus result = AudioFileOpenURL((CFURLRef)afUrl, kAudioFileReadPermission, 0, &outAFID);
    //void* MyGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei*	outSampleRate);
    
    // If we get a result that is not 0 then something has gone wrong.  We report it and
    // return the out audio file id
    if(result != 0)	{
        NSLog(@"ERROR SoundEngine: Cannot open file: %@", theFilePath);
        return nil;
    }
    
    return outAFID;
}


/*
 This helper method returns the file size in bytes for a given AudioFileID
 */
- (UInt32) audioFileSize:(AudioFileID)fileDescriptor {
    UInt64 outDataSize = 0;
    UInt32 thePropSize = sizeof(UInt64);
    OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
    if(result != 0)	NSLog(@"ERROR: cannot file file size");
    return (UInt32)outDataSize;
}



/**
 * Search through the max number of sources to find one which is not playing.  If one cannot
 * be found that is not playing then the first one which is looping is stopped and used instead.
 * If a source still cannot be found then the first source is stopped and used. One way or another,
 * the sound will play.
 *
 */
- (GAudioOpenALSource *) nextAvailableSource {
    
 
    // Holder for the current state of the current source
    ALint sourceState;
    
    // Find a source which is not being used at the moment
    for(GAudioOpenALSource *source in soundSources) {
        alGetSourcei([source sourceAsALuint], AL_SOURCE_STATE, &sourceState);
        // If this source is not playing then return it
        if(sourceState != AL_PLAYING) return source;//[sourceNumber unsignedIntValue];
    }
    
    // If all the sources are being used we look for the first non looping source
    // and use the source associated with that
    ALint looping;
    for(GAudioOpenALSource *source in soundSources) {
        alGetSourcei([source sourceAsALuint], AL_LOOPING, &looping);
        if(!looping) {
            // We have found a none looping source so return this source and stop checking
            alSourceStop([source sourceAsALuint]);
            return source;
        }
    }
    
    // If there are no looping sources to be found then just use the first sounrce and use that
    if(soundSources.count == 0) {
    [NSException raise:@"Error" format:@"Somehow the soundSources got to be empty."];
    }
    
    GAudioOpenALSource *source = [soundSources objectAtIndex:0];
    alSourceStop([source sourceAsALuint]);
    return source;
}



/////////////
//         //
//  A P I  //
//         //
/////////////




- (void) logKeyAsCommonSound:(NSString *)key {
    [commonSounds addObject:key];
}

- (void) logKeyAsCommonMusic:(NSString *) key {
    [commonMusic addObject:key];
}


- (void) loadSoundWithKey:(NSString*)theSoundKey
                 fileName:(NSString*)theFileName
                  fileExt:(NSString*)theFileExt
                frequency:(NSUInteger)theFrequency {
    
    if([soundLibrary objectForKey:theSoundKey] == nil) {
        
        //some of the sound sources may have been destroyed previously,
        //so we have to create any that are missing
        while(soundSources.count < kMaxSources) {
            ALuint sourceID;
            // Generate an OpenAL source
            alGenSources(1, &sourceID);
            // Add the generated sourceID to our array of sound sources
            GAudioOpenALSource *source = [[GAudioOpenALSource alloc] init];
            source.source = [NSNumber numberWithUnsignedInt:sourceID];
            [soundSources addObject:source];
            //this will make it wholly owned by the array. when the object is
            //removed from the array it will dealloc automatically.
            [source release];
        }
    
        //ALenum  error = AL_NO_ERROR;
        ALenum  format;
        ALsizei size;
        ALsizei freq;
        
        void* data;
        
        // Get the full path of the audio file
        NSBundle*				bundle = [NSBundle mainBundle];
        
        // get some audio data from a wave file
        CFURLRef fileURL = (CFURLRef)[[NSURL fileURLWithPath:[bundle pathForResource:theFileName ofType:theFileExt]] retain];
        
        data = MyGetOpenALAudioData(fileURL, &size, &format, &freq);
        
        ALuint bufferID;
        
        // Generate a buffer within OpenAL for this sound
        alGenBuffers(1, &bufferID);
        
        // Place the audio data into the new buffer
        //alBufferData(bufferID, AL_FORMAT_STEREO16, outData, fileSize, theFrequency);
        alBufferData(bufferID, format, data, size, freq);
        
        // Save the buffer to be used later
        //[soundLibrary setObject:[NSNumber numberWithUnsignedInt:bufferID] forKey:theSoundKey];
        [soundLibrary setObject:[NSNumber numberWithInt:bufferID] forKey:theSoundKey];
        
        // Clean the buffer
        if(data) {
            free(data);
            data = NULL;
        }
    }
}



- (void) loadBackgroundMusicWithKey:(NSString*)theMusicKey fileName:(NSString*)theFileName fileExt:(NSString*)theFileExt {
    
    if([musicLibrary objectForKey:theMusicKey] == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:theFileName ofType:theFileExt];
        [musicLibrary setObject:path forKey:theMusicKey];
    }
}



/////////////////////////////////////
//                                 //
//  manipulate a sound with a key  //
//                                 //
/////////////////////////////////////

//So here's the deal, you pause a sound, but the f_cking thing is playing on multiple channels.
//so basically you're going to the last one that was playing and pausing it. well, what about those other damned channels?


/*
 Plays the sound which matches the key provided.  The Gain, pitch and if the sound should loop can
 also be set from the method signature
 */
//gain: 0-1.
//pitch: 0-infinity. default is 1.
- (NSUInteger) playSoundWithKey:(NSString*)theSoundKey gain:(ALfloat)theGain pitch:(ALfloat)thePitch location:(Vector2f)theLocation shouldLoop:(BOOL)theShouldLoop {
    
    NSNumber *paused = [pausedSounds objectForKey:theSoundKey];
        if(paused != nil) {
        return 0;
        }
    
    ALenum err = alGetError(); // clear the error code
    
    // Find the buffer linked to the key which has been passed in
    NSNumber *numVal = [soundLibrary objectForKey:theSoundKey];
    if(numVal == nil) return 0;
    ALint bufferID = (ALint)[numVal intValue];
    
    // Find an available source i.e. it is currently not playing anything
    //ALuint sourceID = (ALuint)[self nextAvailableSource];
    GAudioOpenALSource *source = [self nextAvailableSource];
    ALuint sourceID = [source sourceAsALuint];
    source.currentSoundKey = theSoundKey;
    
    ALint state;
    alGetSourcei(sourceID, AL_SOURCE_STATE, &state);
        if (state == AL_PAUSED) {
            //NSLog(@"Found a paused source, dammit");
            return 0;
        }
    
    //  fartBrains = sourceID;
    
    // Make sure that the source is clean by resetting the buffer assigned to the source
    // to 0
    alSourcei(sourceID, AL_BUFFER, 0);
    //Attach the buffer we have looked up to the source we have just found
    alSourcei(sourceID, AL_BUFFER, bufferID);
    
    // Set the pitch and gain of the source
    alSourcef(sourceID, AL_PITCH, thePitch);
    alSourcef(sourceID, AL_GAIN, theGain);
    
    // Set the looping value
    if(theShouldLoop) {
        alSourcei(sourceID, AL_LOOPING, AL_TRUE);
    } else {
        alSourcei(sourceID, AL_LOOPING, AL_FALSE);
    }
    
    // Check to see if there were any errors
     err = alGetError();
     if(err != 0) {
     NSLog(@"ERROR SoundManager playSound: %d", err);
     return 0;
     }
    
    // Now play the sound
    alSourcePlay(sourceID);
    
    //NSUInteger sourceID = [[soundSources objectAtIndex:0] unsignedIntegerValue];
    //[soundSrcLibrary setObject:[NSNumber numberWithUnsignedInt:sourceID] forKey:theSoundKey];
    
    // Return the source ID so that loops can be stopped etc
    return sourceID;
}


/*
 Plays the sound which matches the key provided.  The Gain, pitch and if the sound should loop can
 also be set from the method signature
 */
- (NSUInteger) playSoundWithKey:(NSString*)theSoundKey {
    return [self playSoundWithKey:theSoundKey gain:1 pitch:1 location:Vector2fZero shouldLoop:NO];
}

- (NSUInteger) playSoundWithKeyAndLoop:(NSString*)theSoundKey {
    return [self playSoundWithKey:theSoundKey gain:1 pitch:1 location:Vector2fZero shouldLoop:YES];
}



/**
 * stop a sound from playing.
 *
 */
- (void) stopSoundWithKey:(NSString*)theSoundKey {
 //   ALuint srcId = (ALuint)[[soundSrcLibrary objectForKey:theSoundKey] unsignedIntegerValue];
 //   alSourceStop(srcId);
 //   alGetError();
    
    //NSNumber *paused = [pausedSounds objectForKey:theSoundKey];
    //if(paused != nil) {
    //    return;
    //} else {
    //    [pausedSounds setObject:[NSNumber numberWithInt:1] forKey:theSoundKey];
    //}
    
    for(GAudioOpenALSource *source in soundSources) {
        if([source.currentSoundKey isEqualToString:theSoundKey] && source.isPaused == NO) {
            alSourceStop([source sourceAsALuint]);
            alGetError();
        }
    }
}

- (GAudioOpenALSource *) uglyHack_getSoundSourceWithKey:(NSString *)soundKey {
 
    for(GAudioOpenALSource *source in soundSources) {
        if([source.currentSoundKey isEqualToString:soundKey]) {
        return source;
        }
    }
    
return nil;
}



/**
 * pause a sound
 *
 */

- (void) pauseSoundWithKey:(NSString*)theSoundKey {
NSNumber *paused = [pausedSounds objectForKey:theSoundKey];
    
    //NSLog(@"pauseSoundWithKey: %@",theSoundKey);
    
    if(paused != nil) {
    //NSLog(@"pauseSoundWithKey taking eary exit: %i",[paused intValue]);
    return;
    } else {
    [pausedSounds setObject:[NSNumber numberWithInt:1] forKey:theSoundKey];
    }
    
    //NSLog(@"pauseSoundWithKey is this firing??: %@",theSoundKey);
    
    
    for(GAudioOpenALSource *source in soundSources) {
        if([source.currentSoundKey isEqualToString:theSoundKey] && source.isPaused == NO) {
            source.isPaused = YES;
            alSourcePause([source sourceAsALuint]);
            alGetError();
        }
    }
    
}
- (void) resumeSoundWithKey:(NSString *)theSoundKey {
ALenum err = alGetError(); // clear the error code
    
    //NSLog(@"resumeSoundWithKey: %@",theSoundKey);
    
    NSNumber *paused = [pausedSounds objectForKey:theSoundKey];
    
    if(paused == nil) {
    //NSLog(@"resumeSoundWithKey: taking early exit here");
    return;
    } else {
    [pausedSounds removeObjectForKey:theSoundKey];
    //NSLog(@"resuming sound for key: %@%@%@",theSoundKey,@"  %@",[pausedSounds objectForKey:theSoundKey]);
    }
    
    //NSLog(@"resumeSoundWithKey: is this firing??: %@",theSoundKey);
    
    for(GAudioOpenALSource *source in soundSources) {
    
        //NSLog(@"TRYING to UNpause STEP1: this source %d%@%@%@%@%@%@",[source sourceAsALuint],
        //      @"  for the sound: ",theSoundKey,@" source.currentSoundKey: ",
        //      source.currentSoundKey,
        //      @" is the source paused, goddammit? ", (source.isPaused)? @"YES" : @"NO");
        
        
        if([source.currentSoundKey isEqualToString:theSoundKey] && source.isPaused == YES) {
        source.isPaused = NO;
            
            // Find the buffer linked to the key which has been passed in
            NSNumber *numVal = [soundLibrary objectForKey:theSoundKey];
            if(numVal == nil) {
                continue;
            }
            
            //if the sound wasn't paused, then the function can exit right here.
            ALint state;
            alGetSourcei([source sourceAsALuint], AL_SOURCE_STATE, &state);
            if (state != AL_PAUSED) {
                continue;
            }
            
            ALint bufferID = (ALint)[numVal intValue];
            
            // Find an available source i.e. it is currently not playing anything
            ALuint sourceID = [source sourceAsALuint]; //(ALuint)[self nextAvailableSource];
            
            //alSetSourcei(sourceID, AL_SOURCE_STATE, AL_PENDING);
            //alSourcei(sourceID, AL_SOURCE_STATE, AL_PENDING);
            alSourceStop(sourceID);
            
            // Make sure that the source is clean by resetting the buffer assigned to the source
            // to 0
            alSourcei(sourceID, AL_BUFFER, 0);
            
            //Attach the buffer we have looked up to the source we have just found
            alSourcei(sourceID, AL_BUFFER, bufferID);
            
            // Set the pitch and gain of the source
            alSourcef(sourceID, AL_PITCH, 1);
            alSourcef(sourceID, AL_GAIN, 1);
            
            // Set the looping value
            alSourcei(sourceID, AL_LOOPING, AL_FALSE);
            
            // Check to see if there were any errors
            err = alGetError();
            if(err != 0) {
                NSLog(@"ERROR SoundManager!!!: %d", err);
                continue;
            }
            
            //NSLog(@"UNpausing %d",sourceID);
            
            // Now play the sound
            alSourcePlay(sourceID);
            
        }
    }
}



///////////////////////////////////////////
//                                       //
//  manipulate a music track with a key  //
//                                       //
///////////////////////////////////////////



/**
 * Play the background track which matches the key
 * times to repleat = -1 means it wont' ever stop until it's asked to.
 * volume is between 0 and 1.
 *
 */
- (void) playMusicWithKey:(NSString*)theMusicKey timesToRepeat:(NSUInteger)theTimesToRepeat withVolume:(ALfloat)volume {
    
    NSError *error;
    
    NSString *path = [musicLibrary objectForKey:theMusicKey];
    
    if(!path) {
        NSLog(@"ERROR SoundEngine: The music key '%@' could not be found", theMusicKey);
        return;
    }
    
    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:theMusicKey];
    
    //if the player does not exist for this key, then create it and install it in the dictionary of AVAudioPlayer objects.
    //give the player a release message so that removing it from the dictionary will cause it to immediately dealloc.
    if(player == nil) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
        
        if(player) {
            [musicPlayerLibrary setObject:player forKey:theMusicKey];
            [player release];
        }
    }
    
    
    // If the player object is nil then there was an error
    if(!player) {
        NSLog(@"ERROR SoundManager: Could not play music for key %@", error);
        return;
    }
    
    // Set the number of times this music should repeat.  -1 means never stop until its asked to stop
    [player setNumberOfLoops:theTimesToRepeat];
    
    // Set the volume of the music
    [player setVolume:volume];
    
    // Play the music
    [player play];
    
}

/**
 * set the volume and also fade down the music if needs be.
 *
 */
- (void) setVolumeOfMusicWithKey:(NSString*)musicKey volume:(ALfloat)volume {
    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:musicKey];
    if(player) {
    [player setVolume:volume];
    }
}
- (void) setVolumeOfMusicWithKey:(NSString*)musicKey volume:(ALfloat)volume withFadeDuration:(int)timeSeconds {

    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:musicKey];
    if(player) {
        [player setVolume:volume fadeDuration:(NSTimeInterval)timeSeconds];
    }
}

- (void) setMusicTimeForKey:(NSString *)musicKey time:(int)seconds {
    
    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:musicKey];
    if(player) {
    player.currentTime = seconds;
    }
    
}


/**
 * Stop playing the currently playing music
 *
 */
- (void) stopMusicWithKey:(NSString *)key {
    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:key];
    if(player) {
        [player stop];
    }
}


/**
 * pause the music.
 *
 */
- (void) pauseMusicWithKey:(NSString *)key {
    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:key];
    if(player) {
        [player pause];
    }
}


/**
 * resume the background music.
 *
 */
- (void) resumeMusicWithKey:(NSString *)key {
    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:key];
    if(player) {
        [player play];
    }
}


/**
 * toggle the pause/play. first call will pause the music, next will play etc. etc.
 *
 */
- (void) togglePausePlayWithKey:(NSString *)key {
    
    if(pausePlayToggle == NO) {
        pausePlayToggle = YES;
        [self pauseMusicWithKey:key];
    } else {
        pausePlayToggle = NO;
        [self resumeMusicWithKey:key];
    }
    
}




////////////////////////////////////////////
//                                        //
//  manipulate a bunch of sounds at once  //
//                                        //
////////////////////////////////////////////



/**
 * stop all the sounds/common sounds.
 *
 */
- (void) stopAllSounds {
    
    NSArray *arr = [soundLibrary allKeys];
    int len = (int)arr.count;
    
    for(int j=0; j<len; j++) {
        [self stopSoundWithKey:[arr objectAtIndex:j]];
    }
    
    
}
- (void) stopCommonSounds {
    
    int len = (int)commonSounds.count;
    
    for(int g=0; g<len; g++) {
        [self stopSoundWithKey:[commonSounds objectAtIndex:g]];
    }
}



/**
 * pause all the sounds/common sounds.
 *
 */
- (void) pauseAllSounds {
    
    NSArray *arr = [soundLibrary allKeys];
    int len = (int)arr.count;
    
    for(int g=0; g<len; g++) {
        [self pauseSoundWithKey:[arr objectAtIndex:g]];
    }
    
}
- (void) pauseCommonSounds {

    int len = (int)commonSounds.count;
    
    for(int g=0; g<len; g++) {
        [self pauseSoundWithKey:[commonSounds objectAtIndex:g]];
    }
}


/**
 * resume all sounds/common sounds.
 *
 */
- (void) resumeAllSounds {
    
    NSArray *arr0 = [soundLibrary allKeys];
    int len0 = (int)arr0.count;
    
    for(int k=0; k<len0; k++) {
        [self resumeSoundWithKey:[arr0 objectAtIndex:k]];
    }
    
}
- (void) resumeCommonSounds {
    int len = (int)commonSounds.count;
    
    for(int g=0; g<len; g++) {
        [self resumeSoundWithKey:[commonSounds objectAtIndex:g]];
    }
    
}





//////////////////////////////////////////////////
//                                              //
//  manipulate a bunch of music tracks at once  //
//                                              //
//////////////////////////////////////////////////



/**
 * pause all of the music/common music.
 *
 */
- (void) pauseAllMusic {
    
    NSArray *arr0 = [musicPlayerLibrary allKeys];
    int len0 = (int)arr0.count;
    
    for(int k=0; k<len0; k++) {
        [self pauseMusicWithKey:[arr0 objectAtIndex:k]];
    }
    
}
- (void) pauseCommonMusic {
    
    int len = (int)commonMusic.count;
    
    for(int g=0; g<len; g++) {
        [self pauseMusicWithKey:[commonMusic objectAtIndex:g]];
    }
}


/**
 * stop all music/common music.
 *
 */
- (void) stopAllMusic {
    
    NSArray *arr0 = [musicPlayerLibrary allKeys];
    int len0 = (int)arr0.count;
    
    for(int k=0; k<len0; k++) {
        [self stopMusicWithKey:[arr0 objectAtIndex:k]];
    }
    
}
- (void) stopCommonMusic {
    
    int len = (int)commonMusic.count;
    
    for(int g=0; g<len; g++) {
        [self stopMusicWithKey:[commonMusic objectAtIndex:g]];
    }
}


/**
 * resume all of the music/common music.
 *
 */
- (void) resumeAllMusic {
    
    //loop through the music player library and
    //resume all music.
    NSArray *arr0 = [musicPlayerLibrary allKeys];
    int len0 = (int)arr0.count;
    
    for(int k=0; k<len0; k++) {
        [self resumeMusicWithKey:[arr0 objectAtIndex:k]];
    }
    
}
- (void) resumeCommonMusic {
    int len = (int)commonMusic.count;
    
    for(int g=0; g<len; g++) {
        [self resumeMusicWithKey:[commonMusic objectAtIndex:g]];
    }
    
}


/**
 * get/set the volume of a track of music.
 *
 */
- (void) setBackgroundMusicVolume:(ALfloat)theVolume withKey:(NSString *)key {
    
    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:key];
    if(player) {
        [player setVolume:backgroundMusicVolume];
    }
    
}
- (ALfloat) getBackgroundMusicVolume:(ALfloat)theVolume withKey:(NSString *)key {
    
    AVAudioPlayer *player = [musicPlayerLibrary objectForKey:key];
    if(player) {
        return [player volume];
    } else {
        return 0.0f;
    }
    
}


/**
 * stop all the sounds.
 *
 */
- (void) stopAllSoundsAndMusic {
    
    //loop through the music player library and
    //stop all music from playing.
    NSArray *arr0 = [musicPlayerLibrary allKeys];
    int len0 = (int)arr0.count;
    
    for(int k=0; k<len0; k++) {
        [self stopMusicWithKey:[arr0 objectAtIndex:k]];
    }
    
    //loop through the sound library stop all of the
    //sounds from playing.
    NSArray *arr = [soundLibrary allValues];
    int len = (int)arr.count;
    
    for(int g=0; g<len; g++) {
        ALuint bufferId = (ALuint)[[arr objectAtIndex:g] integerValue];
        alSourceStop(bufferId);
        alGetError();
    }
}


/**
 * delete a sound with a key. this is used to remove sounds that are specific to a single view.
 * this function is nil-safe in the sense that this function will not blow up the program
 * if you try to re-delete a resource. that's what the conditionals are for.
 *
 */
- (void) deleteSoundWithKey:(NSString *)key {
    
    if([musicLibrary objectForKey:key] != nil) {
        [self stopMusicWithKey:key];
        [musicLibrary removeObjectForKey:key];
        [musicPlayerLibrary removeObjectForKey:key];
    } else
    if([soundLibrary objectForKey:key] != nil) {
        [self stopSoundWithKey:key];
        NSNumber *bufferIDVal = [soundLibrary objectForKey:key];
        ALuint bufferID = (ALuint)[bufferIDVal unsignedIntValue];
        
        //NEW///////////
        //remove the object from the sound library.
        [soundLibrary removeObjectForKey:key];
        ////////////////
        
        //if it's one of the paused sounds, then get rid of it.
        NSNumber *n = (NSNumber *)[pausedSounds objectForKey:key];
            if(n) {
            [pausedSounds removeObjectForKey:key];
            }
        
        //loop through the sound sources and remove all of the sources which match the key.
        int numSrcs = (int)[soundSources count];
        for(int k=0; k<numSrcs; k++) {
        GAudioOpenALSource *source = (GAudioOpenALSource *)[soundSources objectAtIndex:k];
            if([source.currentSoundKey isEqualToString:key]) {
            [soundSources removeObjectAtIndex:k];
            numSrcs--;
            k--; //it's a tricky business mutating arrays while you're looping through them.
            }
        }
        
    
    alDeleteBuffers(1, &bufferID);
    }
    
}


/**
 * the destroy method. to be called on applicationWillTerminate.
 *
 */
- (void) shutdownSoundManager {
    @synchronized(self) {
        if(sharedSoundManager != nil) {
            [self dealloc];
        }
    }
}


/**
 * stop all sounds and destroy all resources.
 *
 */
- (void)dealloc {
    
    //stop all sounds.
    [self stopAllSoundsAndMusic];
    
    //loop through the music player library and
    //destroy the associate music player and path object.
    NSArray *arr = [musicPlayerLibrary allKeys];
    int len = (int)arr.count;
    
    for(int k=0; k<len; k++) {
        [self deleteSoundWithKey:[arr objectAtIndex:k]];
    }
    
    // Loop through the OpenAL sources and delete them
    for(GAudioOpenALSource *audioSrc in soundSources) {
    //ALuint sourceID = (ALuint)[numVal unsignedIntValue];
        //alDeleteSources(1, &sourceID);
    ALuint sourceID = [audioSrc sourceAsALuint];
    alDeleteSources(1, &sourceID);
    }
    
    // Loop through the OpenAL buffers and delete
    NSEnumerator *enumerator = [soundLibrary keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        NSNumber *bufferIDVal = [soundLibrary objectForKey:key];
        ALuint bufferID = (ALuint)[bufferIDVal unsignedIntValue];
        alDeleteBuffers(1, &bufferID);
    }
    
    // Release the arrays and dictionaries we have been using
    [soundLibrary release];
    //[soundSrcLibrary release];
    [soundSources release];
    [musicLibrary release];
    [musicPlayerLibrary release];
    [commonSounds release];
    [commonMusic release];
    [pausedSounds release];
    
    // Disable and then destroy the context
    alcMakeContextCurrent(NULL);
    alcDestroyContext(context);
    
    // Close the device
    alcCloseDevice(device);
    
    [super dealloc];
}




/**
 * override the retain count stuff. we don't ever want the sound manager's retain count to change.
 * dealloc is called directly.
 *
 */
- (id)retain {
    return self;
}
- (NSUInteger)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}
- (void)release {
    //do nothing
}
- (id)autorelease {
    return self;
}


@end
