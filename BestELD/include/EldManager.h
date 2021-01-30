
#import <Foundation/Foundation.h>
#import "EldDataRecord.h"
#import "EldBroadcast.h"
#import "EldParameter.h"
#import "EldBleConnectionStates.h"
#import "EldCallbacks.h"


/*!
 * @brief Main class for the ELD device
 * Exposes all the ELD device functionality
 */
@interface EldManager : NSObject


/*!
 * @brief Error code  - No Error
 */
#define kEldNoError 0


/*!
 * @brief Error code No device found on scanning for eld
 */
#define kEldNoDeviceFoundError 1001


/*!
 * @brief If a list of all scanned devices is desired by the client this callback will be used to return the found devices list.
 * Device list is sorted by RSSI of each device (descending order), see scanForElds method
 */
typedef void (^EldBleScanListCallback) (NSArray * eldList, NSError *error);


/*!
 * @brief ScanCallback is called when scanning for BLE device
 */
typedef void (^EldBleScanCallback) (NSString *device, NSError *error);


/*!
 * @brief callback method to be invoked when notification data is available.
 * This is the standard data message broadcast by the Eld every second. The format for the data is
 * Data:engine_state,VIN,rpm,speed,odometer,trip_distance,hours,trip_hours,voltage,gps_date,gps_time,latitude,longitude,gps_speed,course,numsats,mslalt,dop,sequence,firmware_version
 */
typedef void (^EldBleDataCallback) (EldBroadcast *dataRec, EldBroadcastTypes broadcastTypes, NSError *error);


/*!
 * @brief callback method to allow notification of dis-connection event
 * states defined in EldBleConnectionStates.h
 */
typedef void (^EldBleStateCallback) (EldBleConnectionStates bleStates,NSError * error);


/*!
 * @brief callback method to notify client of firmwareudate status. 
 * multiple strings are returned at specific conditions within the firmwareupdate process
 * @param status The status notifications during fimrware update values are:
 * initiating file download: "Status: Downloading firmware update file from server"
 *
 * on successful download (file size in bytes) : "Status: Downloaded file size: %llu"   
 *
 * on error downloading file: "Status: Error downloading firmware update"
 *
 * on initiating firmware update: "Status: Initiating firmware update"
 *
 * on error initiating update: "Status: Error - timedout waiting for init update"
 *
 * on bad status while initiating update: "Status: Error - invalid response from device waiting for start"
 *
 * while downloading to device (in 1K chunks): "Status: Bytes Uploaded: %d"
 *
 * on completion: "Status: Update completed"
 */
typedef void (^EldFirmwareUpdateCallback) (NSString * status);

/*!
 *  @brief Callback method to notify client of DTC codes
 *  @param status the status of dtc check at the ioSiX server
 *  Following status strings will be provided <br>
 *  1. Status: Http Error<br>
 *
 *  2. "Status: Ok"<br>
 *  @param jsonString the dtc data
 *  Json string will contain the decoded DTC data
 *  At the top level is a variable mil, which is 1 if the 'check engine' light is on on the
 *  dashboard. Then there is an array of diagnostic trouble codes, with the array index for each
 *  DTC being the code itself (ex "SPN 1208" or "P0001") with elements of ecu (ex "Engine" or
 *  "Transmission") and desc (ex "Right Front Seat Belt Sensor Circuit, open circuit").<br>
 *
 * Examples:<br>
 *
 * No codes:<br>
 * {"mil":"0","dtcs":[]}<br>
 *
 * One J1939 code:<br>
 * {"mil":"1","dtcs":{"SPN 1208":{"ecu":"J1939 Engine","desc":"FMI 3, Count 10 (CM1)"}}}
 */
typedef void (^EldDtcCallback) (NSString * status, NSString * jsonString);


- (void) registerBleStateCallback:(LGCentralManagerBleStateCallback)aCallback;

- (void) scanForEldsByUUID: (EldBleScanListCallback)aCallback;


/*!
 * @brief scans for Elds and returns list of all detected Elds
 * If a list of detected ELDs is desired use this method. the other nethod scanForEld - returns only the first eld found
 *
 * @param aCallback - The EldBleScanListCallabck to return the list to  caller
 */
- (void) scanForElds: (EldBleScanListCallback)aCallback;


/*!
 * @brief scans for Elds and returns the first device found
 *
 * @param aCallback - The EldBleScanCallback to return the first found eld device to caller
 */
- (void) scanForEld: (EldBleScanCallback)aCallback;


/*!
 * @brief terminates the BLE connection to the ELD
 */
- (BOOL) disconnectEld;


/*!
 * @brief connects to the first eld found when invoking scanForEld
 *
 * @param aCallback - the data callback to send eld data to caller
 * @param subscriptionMask - the bitmask to inidcate records caller would like to recieve
 * refer to definitions in EldBroadcast.h
 *
 * @return YES - successfully processed connection request
 *         NO - Failed to process connection request
 */
- (BOOL) connectToEld: (EldBleDataCallback)aCallback : (EldBroadcastTypes)subscriptionMask;


/*!
 * @brief connects to the first eld found when invoking scanForEld
 *
 * @param aCallback - the data callback to send eld data to caller
 * @param subscriptionMask - the bitmask to inidcate records caller would like to recieve, refer to definitions in EldBroadcast.h
 * @param stateCallback - callback to notify caller of disconnection events
 *
 * @return YES - successfully processed connection request
 *         NO - Failed to process connection request
 */
- (BOOL) connectToEld: (EldBleDataCallback)aCallback : (EldBroadcastTypes)subscriptionMask : (EldBleStateCallback) stateCallback;


/*!
 * @brief connects to the  eld specified in the call - (obtained in the scanForElds callback)
 *
 * @param aCallback - the data callback to send eld data to caller
 * @param subscriptionMask - the bitmask to inidcate records caller would like to recieve refer to definitions in EldBroadcast.h
 * @param stateCallback - callback to notify caller of disconnection events
 * @param deviceId - the device that the caller would like to connect to - obtained via scanForElds callback
 *
 * @return YES - successfully processed connection request
 *         NO - Failed to process connection request
 */
- (BOOL) connectToEld: (EldBleDataCallback)aCallback : (EldBroadcastTypes)subscriptionMask : (EldBleStateCallback) stateCallback : (NSString *) deviceId;


/*!
 * @brief Update the broadcast type subscriptionMask after connection
 *
 * @param subscriptionMask - the bitmask to inidcate records caller would like to recieve refer to definitions in EldBroadcast.h
 */
- (void) updateSubscriptionMask: (EldBroadcastTypes)subscriptionMask;


/*!
 * @brief REQUEST a cached record by sequence number
 *
 * @param recNo - Sequence number fo the record to request
 * @param deleteRec - Dete record after requesting
 *
 * @return Status of the request
 */
- (NSError *) requestRecord: (NSInteger) recNo : (BOOL) deleteRec;


/*!
 * @brief REQUEST a cached record by sequence number
 *
 * @param recNo - Sequence number fo the record to request
 *
 * @return Status of the request
 */
-(NSError *) requestRecord: (NSInteger) recNo;


/*!
 * @brief REQUEST the first cached record
 *
 * @return Status of the request
 */
- (NSError *) requestRecord;


/*!
 * @brief Request deletion of a specific record or a range of records startSeq cannot be greater than initialSeq no on flash
 *
 * @param startSeqNo  - Starting record on flash
 * @param endSeqNo    - End seqNo for range or  startingSeqNo if only one record to be deleted
 *
 * @return Status of the request
 */
-(NSError *) deleteRecord : (NSInteger) startSeqNo  toSeq: (NSInteger) endSeqNo;


/*!
 * @brief Manually set a VIN on vehicles that do not provide a VIN
 * @param vin - max vin length is 17 characters. VIN will have a '-' prefix to indicate manual vin oer FMCSA rule
 */
-(NSError *) setVIN: (NSString *) vin;


/*!
 * @brief Resets ELD. This will result in disconnecting from the ELD
 */
-(NSError *) resetEld;


/*!
 * @brief Adjust the Cached data interval.
 * @param interval - Cached data interval in miliseconds.
 *              Range: 15000 to 3,600,000
 */
-(NSError *) setCachedDataInterval: (unsigned int) interval;


/*!
 * @brief enable DTC data broadcasts
 *
 * @return status of ENABLE dtc data
 */
-(NSError *) enableDTCData: (EldDtcCallback)dtcCallback;


/*!
 * @brief disables WiFi on the ELD
 *
 * @return status of disable WiFi
 */
-(NSError *) disableWiFi;


/*!
 * @brief enable fuel data broadcast
 *
 * @return status of ENABLE fuel data
 */
-(NSError *) enableFuelData;


/*!
 * @brief enable extra parameter data broadcast
 *
 * @return status of ENABLE parameter
 */
-(NSError *) enableParameter: (EldParameterTypes) parameter;


/*!
 * @brief enable extra parameter data broadcast
 *
 * @return status of DISABLE parameter
 */
-(NSError *) disableParameter: (EldParameterTypes) parameter;


/*!
 * @brief Reset the Bluetooth watchdog timer on the connected ELD.
 * In firmware 304 an optional 25 second Bluetooth watchdog was added to the ELD firmware for active confirmation of the connection status. If you wish to use this feature, this function must be called to reset that timer, otherwise the ELD will initiate a bluetooth disconnection. If you do not call this function, the Bluetooth watchdog will not start and never needs to be reset.
 *
 * @return status of watchdog reset
 */
-(NSError *) resetBleWatchdog;


/*!
 * @brief sets the starting odometer value for vehicles that don't support true odometer
 *
 * @return status of SETODO
 */
-(NSError *) setOdometer: (NSInteger) odometer;


/*!
 * @brief sets the time in Unix Time to be used before GPS time can be acquired
 *
 * @return status of SETTIME
 */
-(NSError *) setTime: (NSInteger) time;

/*!
 * @return firmware version string
 */
-(NSString *)getFirmwareVersion;


/*!
 * @brief use to check if a new firmware is available for the device
 * @return empty string if no new firmware version is available for this device
 *         New version string if new version is available
 * @warning - a valid connection should exist prior to invoking this method
 */
-(NSString *)  checkFirmwareUpdate;


/*!
 * @brief initiates firmware update process
 * @param updateCallback - Call back function that will be invoked to notify progress of firmware update
 * @param fver - The version number to update to
 * @return          YES - firmware update was initiated
 *                  NO - unable to initiate firmware update
 * @warning - Valid connection needs to be present prior to invoking this method
 *
 * caller should invoke checkFirmwareUpdate first and ensure a new version is available
 *
 * All existing cached data will be erased - client should ensure all data has been digested prior to initiatibg an update
 * Default device functionality will be halted while fimrware update is in process
 */
- (BOOL) startUpdate: (EldFirmwareUpdateCallback)updateCallback tover:(NSString *)fver;


/*!
 * @brief initiates debug log to post to the IOSiX webserver for anaysis
 * @return      YES - Debug record transfer was initiated
 *              NO - unable to initiate DEBUG record
 * @warning - Valid connection to ELD and internet needs to be present prior to invoking
 * this method
 */
- (BOOL) requestDebugData;


-(NSString *)getApiVersion;


/*!
 * @brief retrieve the MAC Address of the device - unique id of the device
 */
@property (atomic,copy)  NSString * eldMacAddress;


/*!
 * @return Singleton instance of EldManager
 */
+ (EldManager *)sharedInstance;

@end
