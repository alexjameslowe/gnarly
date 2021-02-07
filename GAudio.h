//
//  GAudio.h
//  BraveRocket
//
//  Created by Alexander Lowe circa 2011
//  Copyright © 2016 Alexander Lowe. See Licence.
//
//
// This sound engine class has been created based on the OpenAL tutorial at
// http://benbritten.com/blog/2008/11/06/openal-sound-on-the-iphone/

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/ExtendedAudioFile.h>


//#import "MyOpenALSupport.h"

//#import "Common.h"
#import "GMath.h"
#import "GResource.h"

// Define the maximum number of sources we can use
#define kMaxSources 32



@interface GAudioOpenALSource : NSObject {
    
    NSNumber *source;
    NSString *currentSoundKey;
    BOOL isPaused;
    
    
}
- (ALuint) sourceAsALuint;

@property (nonatomic, assign) NSNumber *source;
@property (nonatomic, assign) NSString *currentSoundKey;
@property (nonatomic, assign) BOOL isPaused;

@end




@interface GAudio : NSObject <AVAudioSessionDelegate> {
    
    // OpenAL context for playing sounds
    ALCcontext *context;
    
    // The device we are going to use to play sounds
    ALCdevice *device;
    
    // Array to store the OpenAL buffers we create to store sounds we want to play
    NSMutableArray *soundSources;
    NSMutableDictionary *soundLibrary;
    NSMutableDictionary *soundSrcLibrary;
    
    NSMutableDictionary *pausedSounds;
    
    NSMutableDictionary *musicLibrary;
    NSMutableDictionary *musicPlayerLibrary;
    
    NSMutableArray *commonSounds;
    NSMutableArray *commonMusic;
    
    // AVAudioPlayer responsible for playing background music
    AVAudioPlayer *backgroundMusicPlayer;
    
    // Background music volume which is remembered between tracks
    ALfloat backgroundMusicVolume;
    
    
    
    NSTimer *timer;
    id observer;
    SEL endCallback;
    SEL progressCallback;
    
    NSMutableArray *soundFiles;
    float asynchProgress;
    BOOL pausePlayToggle;
    
    NSUInteger fartBrains;
    
    NSString *avAudioSessionError;
    
}

////// NEW

//////


//- (AVAudioPlayer *)audioPlayerWithContentsOfFile:(NSString *)path;



/////////////
//         //
//  A P I  //
//         //
/////////////

- (id)init;
+ (GAudio *)sharedSoundManager;


- (void) logKeyAsCommonSound:(NSString *)key;
- (void) logKeyAsCommonMusic:(NSString *) key;

@property (nonatomic, readonly) float asynchProgress;
//- (void) loadSoundBuffers:(NSObject *) allSounds;
//- (void) checkProgress;
//- (void) preloadEffects:(NSMutableArray *)list onEnd:(NSString *)end onProgress:(NSString *)progress andObserver:(id)obs;
- (void) loadSoundWithKey:(NSString*)theSoundKey fileName:(NSString*)theFileName fileExt:(NSString*)theFileExt frequency:(NSUInteger)theFrequency;
- (void) loadBackgroundMusicWithKey:(NSString*)theMusicKey fileName:(NSString*)theFileName fileExt:(NSString*)theFileExt;
- (void) shutdownSoundManager;
- (void) deleteSoundWithKey:(NSString *)key;


//functions to handle interruptions like phone-calls and alarms and shit.
//void interruptionListenerCallback (void   *inUserData, UInt32    interruptionState );
- (void) sessionAVInterruption_haltOpenALSession;
- (void) sessionAVInterruption_resumeOpenALSession;
- (BOOL) startAudioSession;
- (BOOL) stopAudioSession;

- (void) interruption:(NSNotification*)notification;
- (void) beginInterruption;
- (void) endInterruption;


void* MyGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei*	outSampleRate);


- (NSUInteger) playSoundWithKey:(NSString*)theSoundKey gain:(ALfloat)theGain pitch:(ALfloat)thePitch location:(Vector2f)theLocation shouldLoop:(BOOL)theShouldLoop;


- (NSUInteger) playSoundWithKey:(NSString*)theSoundKey;
- (void) stopSoundWithKey:(NSString*)theSoundKey;
- (void) pauseSoundWithKey:(NSString*)theSoundKey;
- (void) resumeSoundWithKey:(NSString *)theSoundKey;

- (void) pauseAllSounds;
- (void) stopAllSounds;
- (void) resumeAllSounds;
- (void) pauseCommonSounds;
- (void) stopCommonSounds;
- (void) resumeCommonSounds;

- (GAudioOpenALSource *) uglyHack_getSoundSourceWithKey:(NSString *)soundKey;

- (void) setMusicTimeForKey:(NSString *)musicKey time:(int)seconds;
- (void) playMusicWithKey:(NSString*)theMusicKey timesToRepeat:(NSUInteger)theTimesToRepeat withVolume:(ALfloat)volume;
- (void) stopMusicWithKey:(NSString *)key;
- (void) pauseMusicWithKey:(NSString *)key;
- (void) resumeMusicWithKey:(NSString *)key;

- (void) setVolumeOfMusicWithKey:(NSString*)musicKey volume:(ALfloat)volume;
- (void) setVolumeOfMusicWithKey:(NSString*)musicKey volume:(ALfloat)volume withFadeDuration:(int)timeSeconds;

- (NSUInteger) playSoundWithKeyAndLoop:(NSString*)theSoundKey;


- (void) pauseAllMusic;
- (void) stopAllMusic;
- (void) resumeAllMusic;
- (void) pauseCommonMusic;
- (void) stopCommonMusic;
- (void) resumeCommonMusic;


- (void) setBackgroundMusicVolume:(ALfloat)theVolume withKey:(NSString *)key;
- (ALfloat) getBackgroundMusicVolume:(ALfloat)theVolume withKey:(NSString *)key;
- (void) togglePausePlayWithKey:(NSString *)key;

- (void) release;


/*
 - (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
 - (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
 - (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
 - (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags;
 - (void)audioPlayerEndInterruption:(AVAudioPlayer *)player;
 */


@end
