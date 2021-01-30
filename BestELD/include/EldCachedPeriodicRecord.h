//
//  EldCachedPeriodicRecord.h
//  EldBleSdk
//
//  Created by Jay Shroff on 9/22/17.
//  Copyright © 2017 IOSiX. All rights reserved.
//

#import "EldCachedDataRecord.h"

@interface EldCachedPeriodicRecord : EldCachedDataRecord

/**
 *
 * @brief Instantaneous engine RPM
 */
@property (atomic) double rpm;

/**
 *
 * @brief Instantaneous engine speed
 */
@property (atomic) double speed;

/**
 *
 * @brief Vehicle odometer reading in kilometers
 */
@property (atomic) double odometer;

/**
 *
 * @brief Accumuated engine hours
 */
@property (atomic) double engineHours;

/**
 *
 * @brief Gps reported Lattitude
 */
@property (atomic) double lattitude;

/**
 *
 * @brief Gps reported Longitude
 */
@property (atomic) double longitude;

/**
 *
 * @brief Gps reported speed
 */
@property (atomic) NSInteger gpsSpeed;

/**
 *
 * @brief Gps reported heading
 */
@property (atomic) NSInteger course;

/**
 *
 * @brief Number of satellites in view
 */
@property (atomic) NSInteger numSats;

/**
 *
 * @brief Gps reported altitude
 */
@property (atomic) NSInteger mslAlt;

/**
 *
 * @brief DOP
 */
@property (atomic) double dop;

@property (atomic)  int64_t  unixTime;

-(id) init;

-(id) initWithBroadcastString:(NSString *)broadcastString_;

@end
