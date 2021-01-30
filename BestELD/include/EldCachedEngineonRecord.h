/**
 * Exposes the EngineOn event record
 */
#import "EldCachedDataRecord.h"

@interface EldCachedEngineonRecord : EldCachedDataRecord


/**
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
 
 @brief The unix time of engine on (RPM>0)
 */
@property (atomic)  int64_t  unixTime;



-(id) init;
-(id) initWithBroadcastString:(NSString *)broadcastString_:(int)version_;


@end
