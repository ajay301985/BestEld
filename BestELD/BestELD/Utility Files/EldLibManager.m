//
//  EldLibManager.m
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-26.
//

#import "EldLibManager.h"
#import "EldScanObject.h"

@implementation EldLibManager

+ (id)shared {
  static EldLibManager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}


- (void)getEldList:(void (^)(NSArray *, NSError *))completionBlock {
    [[EldManager sharedInstance] scanForElds:^(NSArray *deviceList, NSError *error) {
        //LGLog(@"Found device: %@",device);

        if (error.code == 0) {
            NSMutableArray *deviceArray = [[NSMutableArray alloc]init];
            if (deviceList.count) {
                for (EldScanObject *eld in deviceList) {
                    [deviceArray addObject:eld.deviceId];
                }
                completionBlock(deviceArray, nil);
            }
        } else {
            if (error != nil) {
                completionBlock(nil, error);
            }
        }
    }];
}

- (void)connectToEld: (NSString *) deviceId
{
    [[EldManager sharedInstance] connectToEld:^(EldBroadcast *dataRec, EldBroadcastTypes broadcastTypes, NSError *error) {
        if (broadcastTypes == ELD_DATA_RECORD) {
            self.currentEldDataRecord = (EldDataRecord *)dataRec;
        } else if (broadcastTypes == ELD_FUEL_RECORD) {
            self.currentEldFuelRecord = (EldFuelRecord *)dataRec;
        } else if (broadcastTypes == ELD_CACHED_RECORD) {
        }
    }:ELD_DATA_RECORD | ELD_BUFFER_RECORD | ELD_CACHED_RECORD

                                             : ^(EldBleConnectionStates connState, NSError *error) {
        NSLog(@"connection state change");
    }:deviceId
    ];
}

- (double) currentOdometerValue {
  return self.currentEldDataRecord.odometer;
}

- (void)disconnectDevice:(NSString *)deviceId {
  [[EldManager sharedInstance] disconnectEld];
}

/*
 - (void) showFuelDataRecord:(EldDataRecord*) dataRec {

 [self addTextDataOnTop:@"******* Data for ELD Data RECODE START *******"];

 [self addDataOnTop: @"******* Data for ELD Data RECODE START *******"];
 [self addDataOnTop: [NSString stringWithFormat:@"Engine State: %lu \n",(unsigned long)((EldDataRecord *)dataRec).engineState]];
 if (((EldDataRecord *)dataRec).engineState == ENGINE_ON) {
 [self addDataOnTop: [NSString stringWithFormat:@"Engine State: ON"]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine State: ON \n"]];
 }else {
 [self addDataOnTop:[NSString stringWithFormat:@"Engine State: OFF \n"]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine State: OFF \n"]];
 }

 [self addDataOnTop:[NSString stringWithFormat:@"Engine vin: %@",((EldDataRecord *)dataRec).vin]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine vin: %@",((EldDataRecord *)dataRec).vin]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine rpm: %f",((EldDataRecord *)dataRec).rpm]];
 [self addDataOnTop:[NSString stringWithFormat:@"Engine rpm: %f",((EldDataRecord *)dataRec).rpm]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine speed: %f",((EldDataRecord *)dataRec).speed]];
 [self addDataOnTop:[NSString stringWithFormat:@"Engine speed: %f",((EldDataRecord *)dataRec).speed]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine odometer: %f",((EldDataRecord *)dataRec).odometer]];

 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine tripDistance: %f",((EldDataRecord *)dataRec).tripDistance]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine engineHours: %f",((EldDataRecord *)dataRec).engineHours]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine tripHours: %f",((EldDataRecord *)dataRec).tripHours]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine voltage: %f",((EldDataRecord *)dataRec).voltage]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine gpsDateTime: %@",((EldDataRecord *)dataRec).gpsDateTime.description]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine lattitude: %f",((EldDataRecord *)dataRec).lattitude]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine longitude: %f",((EldDataRecord *)dataRec).longitude]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine gpsSpeed: %ld",(long)((EldDataRecord *)dataRec).gpsSpeed]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine course: %ld",(long)((EldDataRecord *)dataRec).course]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine numSats: %ld",(long)((EldDataRecord *)dataRec).numSats]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Engine firmwareVersion: %@",((EldDataRecord *)dataRec).firmwareVersion]];
 [self addTextDataOnTop:@"******* Data for ELD Data RECODE END *******"];
 if (_viewDetailController) {
 [_viewDetailController detailDataTextView].text = finalData;
 }
 }

 - (void) showFuelRecord: (EldFuelRecord*)dataRec {
 [self addTextDataOnTop:@"******* Data for ELD_FUEL_RECORD Start *******"];
 [self addDataOnTop:[NSString stringWithFormat:@"State Accel: %ld \n",(long)((EldFuelRecord *)dataRec).stateAccel]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"State Accel: %ld \n",(long)((EldFuelRecord *)dataRec).stateAccel]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"Fuel fuelLevelPercent: %f",((EldFuelRecord *)dataRec).fuelLevelPercent]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"fuelIntegratedLiters: %f",((EldFuelRecord *)dataRec).fuelIntegratedLiters]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"totalFuelConsumedLiters: %f",((EldFuelRecord *)dataRec).totalFuelConsumedLiters]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"fuelRateLitersPerHours: %f",((EldFuelRecord *)dataRec).fuelRateLitersPerHours]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"idleFuelConsumedLiters: %f",((EldFuelRecord *)dataRec).idleFuelConsumedLiters]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"idleTimeHours: %f",((EldFuelRecord *)dataRec).idleTimeHours]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"stateHighRPM: %ld",(long)((EldFuelRecord *)dataRec).stateHighRPM]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"stateUnsteady: %ld",(long)((EldFuelRecord *)dataRec).stateUnsteady]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"stateEnginePower: %ld",(long)((EldFuelRecord *)dataRec).stateEnginePower]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"stateAccel: %ld",(long)((EldFuelRecord *)dataRec).stateAccel]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"stateEco: %ld",(long)((EldFuelRecord *)dataRec).stateEco]];
 [self addTextDataOnTop:[NSString stringWithFormat:@"stateAnticipate: %ld",(long)((EldFuelRecord *)dataRec).stateAnticipate]];
 [self addTextDataOnTop:@"******* Data for ELD_FUEL_RECORD END *******"];
 if (_viewDetailController) {
 [_viewDetailController detailDataTextView].text = finalData;
 }

 */
@end
