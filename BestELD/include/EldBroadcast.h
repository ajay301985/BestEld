//
//  EldBroadcast.h
//  
//
//  Created by Jay Shroff on 9/20/17.
//
//

#import <Foundation/Foundation.h>

/*!
 * The string types sent by the ELD
 */
typedef NS_ENUM(NSUInteger, EldBroadcastTypes) {
    /*!
     * Realtime data record
     */
    ELD_DATA_RECORD=1<<0,
    /*!
     * Status string showing cached data availability on the device
     */
    ELD_BUFFER_RECORD=1<<1,
    /*!
     * Response strng for a REQUEST command send to the ELD
     */
    ELD_CACHED_RECORD=1<<2,
    ELD_FUEL_RECORD=1<<3,
    ELD_DIAGNOSTIC_RECORD=1<<4,
    ELD_RAW_DIAGNOSTIC_RECORD=1<<5,
    ELD_DRIVER_BEHAVIOR_RECORD=1<<6,
    ELD_ENGINE_PARAMETERS_RECORD=1<<7,
    ELD_TRANSMISSION_PARAMETERS_RECORD=1<<8,
    ELD_EMISSIONS_PARAMETERS_RECORD=1<<9,
    ELD_UNKNOWN=1<<10
};



@interface EldBroadcast : NSObject

@property (atomic,copy)  NSString * broadcastString;
@property (atomic) EldBroadcastTypes recType;


-(id) init;
-(id) initWithBroadcastString: (NSString * )broadcastString_;




@end
