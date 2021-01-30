//
//  EldEmissionsParametersRecord.h

//  Created by Jay Shroff on 9/30/19.

//

#import "EldBroadcast.h"

typedef NS_ENUM(NSUInteger, EldEmissionsDpfRegenStates) {
    //(Active/Passive/Not active/NA)
    DPFREGEN_ACTIVE,
    DPFREGEN_PASSIVE,
    DPFREGEN_NOT_ACTIVE,
    DPFREGEN_NA,
    DPFREGEN_INVALID
};


typedef NS_ENUM(NSUInteger, EldEmissionsScrInducmentFaultStates) {
    
    // (Inactive/Level 1/Level 2/Level 3/Level 4/Level 5/Temporary override/NA)
    
    SCRINDUCEMENT_INACTIVE,
    SCRINDUCEMENT_LEVEL1,
    SCRINDUCEMENT_LEVEL2,
    SCRINDUCEMENT_LEVEL3,
    SCRINDUCEMENT_LEVEL4,
    SCRINDUCEMENT_LEVEL5,
    SCRINDUCEMENT_TEMPORARY_OVERRIDE,
    SCRINDUCEMENT_NA,
    SCRINDUCEMENT_INVALID
};

@interface EldEmissionsParametersRecord : EldBroadcast

//Emissions: <NOx inlet>,<NOx outlet>,<Ash load>,<Dpf soot load>,<DPF regen status*>,<Dpf differential pressure>,
// <Egr valve position>,<Aftertreatment fuel pressure>,<Engine exhaust temperature>,<Exhaust temperature 1>,
// <Exhaust temperature 2>,<Exhaust temperature 3>,<Def fluid level>,<Def tank temp>,<Scr Inducement fault status*>


@property (atomic) double NOxInlet;   //0
@property (atomic) double NOxOutlet;  //1
@property (atomic) double ashLoad;    //2
@property (atomic) double DpfSootLoad; //3
@property (atomic)   EldEmissionsDpfRegenStates DpfRegenStatus; //4
@property (atomic) double DpfDifferentialPressure; //5
@property (atomic) double EgrValvePosition; //6
@property (atomic) double afterTreatmentFuelPressure;  //7
@property (atomic) double engineExhaustTemperature;   //8
@property (atomic) double exhaustTemperature1;       //9
@property (atomic) double exhaustTemperature2;      //10
@property (atomic) double exhaustTemperature3;      //11
@property (atomic) double defFluidLevel;              //12
@property (atomic) double defTankTemperature;         //13
@property (atomic)   EldEmissionsScrInducmentFaultStates scrInducementFaultStatus; //14

-(id) initWithBroadcastString: (NSString * )broadcastString_;


@end
