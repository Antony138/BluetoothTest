//
//  ViewController.m
//  BabyBluetoothTest
//
//  Created by YuHeng_Antony on 12/4/15.
//  Copyright © 2015 Homni Electron Inc. All rights reserved.
//

#import "ViewController.h"
#import "BabyBluetooth.h"

@interface ViewController ()
@property (strong, nonatomic) BabyBluetooth *baby;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _baby = [BabyBluetooth shareBabyBluetooth];
    [self babyDelegate];
    [_baby cancelAllPeripheralsConnection];
    // 扫描、连接，同时完成
    _baby.scanForPeripherals().connectToPeripherals().begin();
}

- (void)babyDelegate {
    // 过滤:只连接设备名为WLT2541的设备
    [_baby setFilterOnConnetToPeripherals:^BOOL(NSString *peripheralName) {
        if ([peripheralName isEqualToString:@"WLT2541"]) {
            return YES;
        }
        return NO;
    }];
    
    // 返回CBCentralManager实例的状态(手机蓝牙的状态，开、关等)
    [_baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        switch (central.state) {
            case CBCentralManagerStatePoweredOn:
                NSLog(@"手机蓝牙状态: 打开");
                break;
            case CBCentralManagerStatePoweredOff:
                NSLog(@"手机蓝牙状态: 关闭");
                break;
            default:
                break;
        }
    }];
    
    // 返回搜索到的设备
    [_baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到设备: %@", peripheral.name);
    }];
    
    // 硬件链接成功的回调
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
    }];
    
    // 硬件断开链接的回调
    [_baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接断开",peripheral.name);
    }];
}

@end
