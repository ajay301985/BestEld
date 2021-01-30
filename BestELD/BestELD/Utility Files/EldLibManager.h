//
//  EldLibManager.h
//  BestELD
//
//  Created by Ajay Rawat on 2021-01-26.
//

#import <Foundation/Foundation.h>
#import "EldManager.h"
#import "EldFuelRecord.h"
#import "EldDataRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface EldLibManager : NSObject

+ (id)shared;

@property (nonatomic, retain) EldDataRecord *currentEldDataRecord;
@property (nonatomic, retain) EldFuelRecord *currentEldFuelRecord;

- (void)getEldList:(void (^)(NSArray *, NSError *))completionBlock;

- (void)connectToEld: (NSString *) deviceId;

@end

NS_ASSUME_NONNULL_END
