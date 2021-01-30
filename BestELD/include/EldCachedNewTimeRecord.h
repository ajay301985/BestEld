/**
 * Newtime Record
 */
#import "EldCachedDataRecord.h"

@interface EldCachedNewTimeRecord : EldCachedDataRecord


/***
 @brief old time prior to gps synch
 
 */
@property (atomic)  int64_t  oldUnixTime;

/***
 @brief new time at gps synch
 
 */
@property (atomic)  int64_t  newUnixTime;


-(id) init;
-(id) initWithBroadcastString:(NSString *)broadcastString_;

@end
