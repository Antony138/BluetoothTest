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
    // 扫描、链接、发现「服务」、发现「特征」、读取「特征」同时完成
    // 扫描:scanForPeripherals()
    // 连接:connectToPeripherals()
    // 发现「服務」:discoverServices()
    // 发现「特徵」:discoverCharacteristics()
    // 读取「特徵」值:readValueForCharacteristic()// 注意，一定要先执行scanForPeripherals()后才能执行后面的方法
    // 发现「Descriptor」:discoverDescriptorsForCharacteristic()
    // 读取「Descriptor」值:readValueForDescriptors()
    _baby.scanForPeripherals().connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

- (void)babyDelegate {
    // 过滤:只连接设备名为WLT2541的设备
    [_baby setFilterOnConnetToPeripherals:^BOOL(NSString *peripheralName) {
        if ([peripheralName isEqualToString:@"WLT2541"]) {
            return YES;
        }
        return NO;
    }];
    
# pragma mark 扫描/链接/硬件状态/手机状态的回调
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
    
    // 搜索到设备后的回调
    [_baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
//        NSLog(@"搜索到设备: %@", peripheral.name);
    }];
    
    // 硬件链接成功的回调
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        // 读取RSSI
        [peripheral readRSSI];
    }];
    
    // 硬件断开链接的回调
    [_baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接断开",peripheral.name);
    }];
    
    // 读取RSSI的回调(peripheral要先调用readRSSI方法)
    [_baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"RSSI:%@",RSSI);
    }];
    
# pragma mark 读取硬件数据(「服务」「特征」「Descriptor」)的回调
    // 发现硬件「服务」后的回调
    [_baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"发现设备%@有%lu个服务",peripheral.name ,peripheral.services.count);
        [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"设备%@的第%lu个服务是:%@", peripheral.name, (unsigned long)idx, service);
            // 在DiscoverServices:这个block中是不返回「特征」的
        }];
    }];
    
    // 发现硬件「特征」后的回调
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
            // 服务里的「特征」？
            NSLog(@"设备%@的第%lu个服务有%lu个“特征”", peripheral.name, (unsigned long)idx, service.characteristics.count);
        }];
    }];
    
    // 读取「特征」值的回调(其实也可以在setBlockOnDiscoverCharacteristics:这个block里面枚举service对象的characteristics属性，得到值)
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        NSLog(@"characteristic name:%@ value is:%@",characteristic.UUID, characteristic.value);
    }];
    
    // 发现characteristics的descriptors的回调
    [_baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
//        for (CBDescriptor *d in characteristic.descriptors) {
//            NSLog(@"CBDescriptor name is :%@",d.UUID);
//        }
    }];
    
    // 读取「Descriptor」值的回调
    // 读取不到？还是硬件没有「Descriptor」这方面的信息？
    [_baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@", descriptor.characteristic.UUID, descriptor.value);
    }];
    
}

@end
