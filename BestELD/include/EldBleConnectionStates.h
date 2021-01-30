//
//  EldBleConnectionStates.h
//  LGBluetoothExample
//
//  Created by Jay Shroff on 10/26/17.
//  Copyright © 2017 David Sahakyan. All rights reserved.
//

#ifndef EldBleConnectionStates_h
#define EldBleConnectionStates_h

#import <Foundation/Foundation.h>

/**
 * The string types sent by the ELD
 */
typedef NS_ENUM(NSUInteger, EldBleConnectionStates) {
    /***
     * Disconnected
     */
    BLE_DISCONNECTED=0,
    BLE_CONNECTED=1

};



#endif /* EldBleConnectionStates_h */
