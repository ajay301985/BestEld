/**
 * powerOn detection record
 */
#import "EldCachedDataRecord.h"

@interface EldCachedPoweronRecord : EldCachedDataRecord


/***
 *
 * @brief number of hardboots
 */
@property (atomic) NSInteger hardBoots;

/***
 *
 * @brief number of crashes
 */
@property (atomic) NSInteger crashes;


/***
 *
 * @brief event occurance time
 */
@property  int64_t unixTime;

-(id) init;
-(id) initWithBroadcastString:(NSString *)broadcastString_;

@end
