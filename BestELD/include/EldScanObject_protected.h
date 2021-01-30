//
//  EldScanObject.h
//  LGBluetoothExample
//
//  Created by Jay Shroff on 11/9/17.
//  Copyright © 2017 David Sahakyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EldScanObject.h"
#import "LGPeripheral.h"

@interface EldScanObject(Protected)



-(id)Init : (NSString*) deviceId : (NSInteger) rssi : (LGPeripheral *) periph;
-(LGPeripheral *)getPeripheral;

@end
