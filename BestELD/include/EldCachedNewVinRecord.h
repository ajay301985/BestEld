/**
 * Newvin Record
 */
#import "EldCachedDataRecord.h"

@interface EldCachedNewVinRecord : EldCachedDataRecord

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
 @brief time of new vin record
 
 */
@property (atomic)  int64_t  unixTime;



-(id) init;
-(id) initWithBroadcastString:(NSString *)broadcastString_;

@end
