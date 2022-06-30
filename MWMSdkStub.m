//
//  MWMSdkStub.m
//  eeg_meditation
//
//  Created by Alex Lokk on 28.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

// A stub to build the app for simulator

// - FIXME the switch does not work??
#if TARGET_IPHONE_SIMULATOR

#import <Foundation/Foundation.h>

#import "MWMSdk/MWMEnum.h"
#import "MWMSdk/MWMDelegate.h"
#import "MWMSdk/MWMDevice.h"

@implementation MWMDevice
+ (MWMDevice *)sharedInstance {
    return [[MWMDevice alloc] init];
}
- (void)deviceFound:(NSString *)devName MfgID:(NSString *)mfgID DeviceID:(NSString *)deviceID {}
- (void)didConnect {}
- (void)didDisconnect {}
- (void)connectDevice:(NSString *)deviceID {}
- (void)disconnectDevice {}
- (void)enableConsoleLog:(BOOL)enabled {}
- (NSString *)enableLoggingWithOptions:(unsigned int)option {
    return @"---";
}
- (NSString *)getVersion {
    return @"STUB";
}
- (void)readConfig {}
- (void)scanDevice {}
- (void)stopLogging {}
- (void)stopScanDevice {}
- (void)writeConfig:(TGMWMConfigCMD)cmd {}
@end

#endif
