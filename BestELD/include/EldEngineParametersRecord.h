//
//  EldEngineParametersRecord.h
//  LGBluetoothExample
//
//  Created by Jay Shroff on 10/3/19.
//  Copyright © 2019 David Sahakyan. All rights reserved.
//

#import "EldBroadcast.h"


@interface EldEngineParametersRecord : EldBroadcast

@property (atomic) double oilPressure_kpa;
@property (atomic) double turboBoost_kpa;
@property (atomic) double intakePressure_kpa;
@property (atomic) double fuelPressure_kpa;
@property (atomic) double crankCasePressure_kpa;
@property (atomic) double load_pct;
@property (atomic) double massAirFlow_galPerSec;
@property (atomic) double turboRpm;
@property (atomic) double intakeTemp_c;
@property (atomic) double engineCoolantTemp_c;
@property (atomic) double engineOilTemp_c;
@property (atomic) double fuelTemp_c;
@property (atomic) double chargeCoolerTemp_c;
@property (atomic) double torgue_Nm;
@property (atomic) double engineOilLevel_pct;
@property (atomic) double engineCoolandLevel_pct;
@property (atomic) double tripFuel_L;
@property (atomic) double drivingFuelEconomy_LPerKm;

-(id) initWithBroadcastString: (NSString * )broadcastString_;
@end
