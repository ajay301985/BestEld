//
//  EldScanObject.h
//  LGBluetoothExample
//
//  Created by Jay Shroff on 11/9/17.
//  Copyright © 2017 David Sahakyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EldScanObject : NSObject

/*! 
 * @brief the device id of the ELD (macaddress)
 *
 */
@property (atomic,readonly,copy) NSString *deviceId;

/*!
 * @brief - signal strength (rssi) of the device
 *
 *
 */
@property (atomic,readonly) NSInteger rssi;

@end
