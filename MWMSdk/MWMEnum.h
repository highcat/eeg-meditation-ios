//
//  MWMEnum.h
//
//  Created by test on 09/06/16.
//  Copyright (c) 2016 neurosky. All rights reserved.
//

#pragma mark -- TGBleConfig --
typedef NS_ENUM(NSUInteger, TGMWMConfigCMD){
    TGMWMConfigCMD_ChangeNotchTo_50,
    TGMWMConfigCMD_ChangeNotchTo_60
};

#pragma mark -- LoggingOptions --
typedef NS_ENUM(NSUInteger, LoggingOptions){
    LoggingOptions_Raw  = 1,
    LoggingOptions_Processed = 1 << 1,
};

#pragma mark --  TGBleExceptionEvent  --
typedef NS_ENUM(NSUInteger, TGBleExceptionEvent){
    TGBleUnexpectedEvent = 0,
    TGBleConfigurationModeCanNotBeChanged = 1,
    TGBleFailedOtherOperationInProgress = 2,
    TGBleConnectFailedSuspectKeyMismatch = 3,
    TGBlePossibleResetDetect = 4,
    TGBleNewConnectionEstablished = 5,
    TGBleStoredConnectionInvalid = 6,
    TGBleConnectHeadSetDirectoryFailed = 7,
    TGBleBluetoothModuleError = 8,
    TGBleNoMfgDatainAdvertisement = 9,
};

