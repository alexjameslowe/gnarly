//
//  GnarlySettings.h
//  LM8_2
//
//  Created by Alexander  Lowe on 3/30/11.
//  Copyright 2011 Codequark. See Licence.
//

/////////////////////////////////// 
//  Some constants- meta macros  //
///////////////////////////////////

#define  gPORTRAIT_MODE  0
#define  gLANDSCAPE_MODE  1
#define  gIPHONE 6
#define  gIPHONE4 7 
#define  gIPAD12 8
#define  gIPAD3 9
#define  gYES 1
#define  gNO 0


#define gBTConnect 0
#define gBTReceive 1
#define gBTDisconnect 2
#define gBTAvailable 3
#define gBTUnavailable 4
#define gBTConnecting 5


///////////////////////////////////
//  Accelerometer and rendering  //
///////////////////////////////////

//EDITABLE  For filtering out gravitational affects
#define gFilteringFactor			0.1

//EDITABLE  the accelerometer frequency.
#define gAccelerometerFrequency		30

///EDITABLE  will this be enabled with the accelerometer? 1 = YES, 0 = NO
#define gAccelerometerEnabled       gNO

//EDITABLE the rendering frequency.
#define gRenderingFrequency         30



/////////////////
//  Bluetooth  //
/////////////////

//EDITABLE  is the bluetooth enabled? 1 = YES, 0 = NO
#define gBluetoothEnabled  gNO

//EDITABLE  the number of render frames between each heartbeat.
#define gBTMirrorPeriod  10



/////////////////////////////////////
// debugging and performance tests //
/////////////////////////////////////

//do you want all rendering surfaces to log their FPS estimates to the console?
#define gDebug_LogFPSInfo gNO

//do you want all objects to note their deallocs in the console?
#define gDebug_LogDealloc gNO





////////////////////////////////////////////////////////////////////////
//                                                                    //
//  EDITABLE  GPreloaderSpriteData is the blob of data that the       //
//  GnarlySaysConfigureLoadingSprite will pass as an argument. you    //
//  can edit it to be whatever you want from project to project.      //
//                                                                    //
////////////////////////////////////////////////////////////////////////
typedef struct {
    int int1;
    int int2;
    float float1;
    float float2;
} GSurfaceData;



////////////////////////////////////////////////////////////////////////
//                                                                    //
//  EDITABLE  GMirrorPacket is the unit of bt mirror data exchange    //
//  between two iPads. you can customize it from project to project.  //
//                                                                    //
////////////////////////////////////////////////////////////////////////
typedef struct {
    int int1;
    int int2;
    float float1;
    float float2;
    float float3;
    float float4;
    float float5;
    float float6;
} GMirrorPacket; 



/////////////////////////////////////////////////////////////////////////////////////
//
//  EDITABLE  GMessagePacket is the unit of data exchange between two iPads with actions 
//  that need to be taken on objects on the other game table this can be customized, 
//  but the obsCode integer must remain.
//
//  
typedef struct {
    int obsCode;
} GMessagePacket;  


//The coin-toss packet.
typedef struct {
    int rand;
    int result;
} GCoinTossPacket;





////////////////////////////////////////////////////////////////////////
//  EDITABLE Audio.Channel group ids, the channel groups define how   //
//  voiced will be shared.  If you wish you can simply have a single  //
//  channel group and all sounds will share all the voices            //
////////////////////////////////////////////////////////////////////////

#define GGROUP_DRUMLOOP 0
#define GGROUP_TONELOOP 1
#define GGROUP_DRUM_VOICES 2
#define GGROUP_FX_VOICES 3
#define GGROUP_NON_INTERRUPTIBLE 4




///////////////////////////////////////
// NOT EDITABLE basic math constants //
///////////////////////////////////////

#define gDegToRad  0.01745
#define gRadToDeg  57.2960
#define g2PI       6.28318



///EDITABLE  the orientation macro. use one of the appropriate macros.
#define gOrientation  gLANDSCAPE_MODE     

/// EDITABLE  he device macro. use one of the appropriate macros.
#define gDevice                    0

