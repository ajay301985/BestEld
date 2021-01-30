//
//  EldFuelRecord.h
//  LGBluetoothExample
//
//  Created by Jay Shroff on 6/29/18.
//  Copyright © 2018 David Sahakyan. All rights reserved.
//

#ifndef EldFuelRecord_h
#define EldFuelRecord_h
#import <Foundation/Foundation.h>
#import "EldBroadcast.h"

@class EldBroadcast;


@interface EldFuelRecord : EldBroadcast;

@property (atomic) double  fuelLevelPercent;   //0
@property (atomic) double  fuelIntegratedLiters; //1
@property (atomic) double  totalFuelConsumedLiters; //2
@property (atomic) double  fuelRateLitersPerHours;  //3
@property (atomic) double  idleFuelConsumedLiters;  //4
@property (atomic) double  idleTimeHours;           //5
@property (atomic) NSInteger stateHighRPM;               //6
@property (atomic) NSInteger stateUnsteady;              //7
@property (atomic) NSInteger stateEnginePower;           //8
@property (atomic) NSInteger stateAccel;                 //9
@property (atomic) NSInteger stateEco;                   //10
@property (atomic) NSInteger stateAnticipate;            //11


-(id) initWithBroadcastString: (NSString * )broadcastString_;

@end

#endif /* EldFuelRecord_h */
