//
//  EldErrors.h
//  LGBluetoothExample
//
//  Created by Jay Shroff on 8/15/17.
//  Copyright © 2017 David Sahakyan. All rights reserved.
//

#ifndef EldErrors_h
#define EldErrors_h

#import <Foundation/Foundation.h>

const NSInteger kEldErrorBase = 1000;
NSString *const  kEldFrameworkErrorDomain = @"com.IOSiXELD.BLEErrorDomain";
const NSInteger kNoError = 0;
const NSInteger kNoDeviceFoundError = kEldErrorBase+1;
const NSInteger kRecNoOutOfBounds   = kEldErrorBase+2;
const NSInteger kEldNotConnected    = kEldErrorBase+3;
const NSInteger kSetVinInvalidLength = kEldErrorBase+4;
const NSInteger kbleStateNotSupported = kEldErrorBase+5;
const NSInteger kbleStateUnauthorized = kEldErrorBase+6;
const NSInteger kbleStateUnknown = kEldErrorBase+7;
const NSInteger kbleStatePoweredOff = kEldErrorBase+8;
const NSInteger kbleStatePoweredOn = kEldErrorBase+9;
const NSInteger kEldInputOutOfRange = kEldErrorBase+10;



#endif /* EldErrors_h */
