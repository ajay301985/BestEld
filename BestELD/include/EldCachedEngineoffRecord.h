/**
 * Exposes the engine off event record
 */
#import "EldCachedDataRecord.h"
#include "stdint.h"

@interface EldCachedEngineoffRecord : EldCachedDataRecord

/***
 @brief Vin of the vehicle
 */
@property (atomic,copy) NSString * Vin;

/**
 @brief Accumulated odometer
 */
@property (atomic) double  odometer;


/**
 @brief Accumulated engine hours
 */
@property (atomic) double  engineHours;


/***
 @brief time of engine off RPM==0
 
 */
@property (atomic)  int64_t  unixTime;


-(id) init;
-(id) initWithBroadcastString:(NSString *)broadcastString_ :(int)version_;


@end
