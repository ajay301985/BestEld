//
//  EldDriverBehaviorRecord.h

//
//  Created by Jay Shroff on 9/29/19.

//

#import "EldBroadcast.h"


@class EldBroadcast;

typedef NS_ENUM(NSUInteger, EldDriverCruiseStates)  {
    
    CRUISE_OFF,
    CRUISE_HOLD,
    CRUISE_ACCELERATE,
    CRUISE_DECELERATE,
    CRUISE_RESUME,
    CRUISE_SET,
    CRUISE_ACCELERATOR_OVERRIDE,
    CRUISE_NA,
    CRUISE_INVALID
};

typedef NS_ENUM(NSUInteger, EldDriverSeatBeltStates)  {
    
    BELT_UNLOCKED,
    BELT_LOCKED,
    BELT_UNKNOWN,
    BELT_NA,
    BELT_INVALID
    
};

typedef NS_ENUM(NSUInteger, EldDriverAbsStates)  {
    ABS_PASSIVE,
    ABS_ACTIVE,
    ABS_RESERVED,
    ABS_NA,
    ABS_INVALID
};

typedef NS_ENUM(NSUInteger,EldDriverTractionStates )   {
    TRACTION_OFF,
    TRACTION_ON,
    TRACTION_ERROR,
    TRACTION_NA,
    TRACTION_INVALID
};

typedef NS_ENUM(NSUInteger, EldDriverStabilityStates)  {
    STABILITY_PASSIVE,
    STABILITY_ACTIVE,
    STABILITY_RESERVED,
    STABILITY_NA,
    STABILITY_INVALID
};


@interface EldDriverBehaviorRecord : EldBroadcast


@property (atomic) double cruiseSetSpeed_kph;
@property (atomic) EldDriverCruiseStates cruiseStatus;
@property (atomic) double throttlePosition_pct;
@property (atomic) double acceleratorPosition_pct;
@property (atomic) double brakePosition_pct;
@property (atomic) EldDriverSeatBeltStates seatBeltStatus;
@property (atomic) double steeringWheelAngle_deg;
@property (atomic) EldDriverAbsStates absStatus;
@property (atomic) EldDriverTractionStates tractionStatus;
@property (atomic) EldDriverStabilityStates stabilityStaus;
@property (atomic) double brakeSystemPressure_kpa;

-(id) initWithBroadcastString: (NSString * )broadcastString_;

@end
