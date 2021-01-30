//
//  EldDataRecord.h
//  LGBluetoothExample
//
//  Created by Jay Shroff on 8/14/17.
//
//

#import <Foundation/Foundation.h>
#import "EldBroadcast.h"

@class EldBroadcast;

/**
 Engine state obtained in the realtime data record
 */
typedef NS_ENUM(NSUInteger, EldEngineStates)  {
    /***
     * Engine if off
     */
    ENGINE_OFF,
    /***
     * Engine is on
     */
    ENGINE_ON,
    ENGINE_INVALID
};

@interface EldDataRecord : EldBroadcast;

@property (atomic) EldEngineStates engineState;  //0
@property (atomic,copy) NSString *  vin;         //1
@property (atomic) double  rpm;                  //2
@property (atomic) double speed;                 //3
@property (atomic) double  odometer;             //4
@property (atomic) double  tripDistance;         //5
@property (atomic) double  engineHours;          //6
@property (atomic) double  tripHours;            //7
@property (atomic) double  voltage;              //8
@property (atomic,copy) NSDate *  gpsDateTime;   //9

@property (atomic) double  lattitude;            //10
@property (atomic) double  longitude;            //11
@property (atomic) NSInteger   gpsSpeed;         //12
@property (atomic) NSInteger   course;           //13
@property (atomic) NSInteger   numSats;          //14
@property (atomic) NSInteger   mslAlt;           //15
@property (atomic) double  dop;                  //16
@property (atomic) NSInteger   sequence;         //17
@property (atomic,copy) NSString *  firmwareVersion; //18


-(id) initWithBroadcastString: (NSString * )broadcastString_;

@end
