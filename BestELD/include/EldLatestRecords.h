/**
 * @brief The last record retrieved fron the device for buffer record, data record or cached data
 
 */
#import "EldCachedDataRecord.h"
@class EldCachedDataRecord;
@class EldBufferRecord;
@class EldCachedDataRecord;
@class EldDataRecord;
@class EldFuelRecord;
@class EldRawDiagnosticRecord;
@class EldDriverBehaviorRecord;
@class EldEngineParametersRecord;
@class EldTransmissionParametersRecord;
@class EldEmissionsParametersRecord;


@interface EldLatestRecords : EldCachedDataRecord


@property (atomic,retain)  EldBufferRecord* latestBufferRec;
@property (atomic,retain)   EldDataRecord* latestDataRec;
@property (atomic,retain)   EldCachedDataRecord* latestCachedDataRec;
@property (atomic,retain) EldFuelRecord* latestFuelRec;
@property (atomic,retain) EldRawDiagnosticRecord* latestRawDiagnosticRec;

@property (atomic,retain) EldDriverBehaviorRecord* latestDriverBehaviorRec;
@property (atomic,retain) EldEngineParametersRecord* latestEngineParametersRec;
@property (atomic,retain) EldTransmissionParametersRecord* latestTransmissionParametersRec;
@property (atomic,retain) EldEmissionsParametersRecord* latestEmissionsParametersRec;


+(id) instance;

@end
