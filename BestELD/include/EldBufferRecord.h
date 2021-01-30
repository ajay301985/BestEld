
/***
@brief The buffer broadcast record issued by the ELD every 10 SECONDS


*/
#import "EldBroadcast.h"

@interface EldBufferRecord : EldBroadcast


/***
 *
 * @brief  the starting seqNo of the records cached on the device
 */
@property (atomic,readonly) NSInteger startSeqNo;

/***
 *
 * @brief Ending sequence number of the records stored on the device
 */
@property (atomic,readonly) NSInteger endSeqNo;

/***
 *
 * @brief total number of records stored on the device
 */
@property (atomic,readonly) NSInteger totRecords;

/***
 *
 * @brief additional records that could be saved on the device (empty  flash space in number of records)
 */
@property (atomic,readonly) NSInteger storageRemaining;

-(id) init;
-(id) initWithBroadcastString:(NSString *)broadcastString_;

@end
