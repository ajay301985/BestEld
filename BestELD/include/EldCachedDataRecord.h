/**
 * Base class for all saved(cached) data records
 */

#import "EldBroadcast.h"


/***
*
* @brief Cached data record types
*/

typedef NS_ENUM(NSUInteger, EldCachedDataRecordTypes) {
    ELD_CACHED_DATA_RECORD_NONE,
    ELD_CACHED_POWERON_RECORD,
    ELD_CACHED_ENGINEON_RECORD,
    ELD_CACHED_ENGINEOFF_RECORD,
    ELD_CACHED_PERIODIC_RECORD,
    ELD_CACHED_MOTIONSTART_RECORD,
    ELD_CACHED_MOTIONSTOP_RECORD,
    ELD_CACHED_NEWVIN_RECORD,
    ELD_CACHED_NEWTIME_RECORD,
    ELD_CACHED_UNKNOWN,
    ELD_CACHED_NOT_FOUND
};



@interface EldCachedDataRecord : EldBroadcast

/***
 *
 * @return sequence number of the record
 */
@property (atomic) NSInteger seqNum;

/***
 *
 @return The type of cached report 
 */
@property (atomic) EldCachedDataRecordTypes cachedRecType;

-(id) init;
-(id) initWithBroadcastString :(NSString *)broadcastString_;


@end
