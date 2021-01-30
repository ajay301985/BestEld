//
//  EldTransmissionParametersRecord.h
//  LGBluetoothExample
//
//  Created by Jay Shroff on 10/3/19.
//  Copyright © 2019 David Sahakyan. All rights reserved.
//

#import "EldBroadcast.h"

typedef NS_ENUM(NSUInteger, EldTransmissionTorqueConverterLockupStates)  {
    // (Disengaged/Engaged/Error/NA
    TORQUECNV_LOCKUP_DISENGAGED,
    TORQUECNV_LOCKUP_ENGAGED,
    TORQUECNV_LOCKUP_ERROR,
    TORQUECNV_LOCKUP_NA,
    TORQUECNV_LOCKUP_INVALID
    
    
};

	

@interface EldTransmissionParametersRecord : EldBroadcast

@property (atomic) double outputShaftRpm;
@property (atomic) NSInteger gearStatus;
@property (atomic) NSInteger requestGearStatus;
@property (atomic) double transmissionOilTemp_c;
@property (atomic) EldTransmissionTorqueConverterLockupStates torqueConverterLockupStatus;
@property (atomic) double torqueConverterOilOutletTemp_c;

-(id) initWithBroadcastString: (NSString * )broadcastString_;

@end
