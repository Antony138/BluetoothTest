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
@property (copy, nonatomic) NSMutableArray *peripherals;
@property (copy, nonatomic) NSMutableArray *characteristics;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _peripherals = [[NSMutableArray alloc] init];
    _characteristics = [[NSMutableArray alloc] init];
    
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
    // 读取「Descriptor」值:readValueForDescriptors()// 「Descriptor」感觉没有用到，所以没有调用
//    _baby.scanForPeripherals().connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
    
    // 因为要手动实现链接，所以一开始只做扫描动作
    _baby.scanForPeripherals().begin();
}

- (void)babyDelegate {
    // 用于在block内进行一些操作
    __weak typeof(self) weakSelf = self;
    
    // 过滤:只显示扫描到设备名为WLT2541的设备
    [_baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName) {
        if ([peripheralName isEqualToString:@"WLT2541"]) {
            return YES;
        }
        return NO;
    }];
    
    // 过滤:只连接设备名为WLT2541的设备(其实这个不需要，因为扫描的时候已经做了过滤)
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
        NSLog(@"搜索到设备: %@", peripheral.name);
        [weakSelf insertPeripheral:peripheral];
    }];
    
    // 硬件链接成功的回调
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        // 读取RSSI
//        [peripheral readRSSI];
    }];
    
    // 硬件断开链接的回调
    [_baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接断开",peripheral.name);
    }];
    
    // 读取RSSI的回调(peripheral要先调用readRSSI方法)
    [_baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
//        NSLog(@"RSSI:%@",RSSI);
    }];
    
# pragma mark 读取硬件数据(「服务」「特征」「Descriptor」)的回调
    // 发现硬件「服务」后的回调
    [_baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
//        NSLog(@"发现设备%@有%lu个服务",peripheral.name ,peripheral.services.count);
        [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"设备%@的第%lu个服务是:%@", peripheral.name, (unsigned long)idx, service);
            // 在DiscoverServices:这个block中是不返回「特征」的
        }];
    }];
    
    // 发现硬件「特征」后的回调
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull service, NSUInteger idx, BOOL * _Nonnull stop) {
            // 服务里的「特征」？
//            NSLog(@"设备%@的第%lu个服务有%lu个“特征”", peripheral.name, (unsigned long)idx, service.characteristics.count);
            // 枚举service对象的characteristics属性，也可以得到各个characteristic的值
//            [service.characteristics enumerateObjectsUsingBlock:^(CBCharacteristic * _Nonnull characteristic, NSUInteger idx, BOOL * _Nonnull stop) {
//                 NSLog(@"这个服务的 characteristic name:%@ value is:%@", characteristic.UUID, characteristic.value);
//            }];
        }];
    }];
    
    // 读取「特征」值的回调(也可以在setBlockOnDiscoverCharacteristics:这个block里面枚举service对象的characteristics属性，得到值)
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        // 打印characteristic的值
//        NSLog(@"characteristic name:%@ value is:%@",characteristic.UUID, characteristic.value);
        
        // 为当前读取的设备(peripheral)中，UUID名称为FFF1的characteristic写入值(就是负责开灯与关灯的characteristic)
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {
            [weakSelf insertCharacteristic:characteristic];
        }
    }];
    
    // ---------感觉没有用到CBDescriptor，所以没有读取相关值，下面两个回调不会调用--------------
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
//        NSLog(@"Descriptor name:%@ value is:%@", descriptor.characteristic.UUID, descriptor.value);
    }];

# pragma mark 写入数据的回调
  [_baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
      NSLog(@"UUID:%@ 已经写入数据", characteristic.UUID);
  }];
}

- (void)insertPeripheral:(CBPeripheral *)peripheral {
    [_peripherals addObject:peripheral];
    NSLog(@"_peripherals的数量是:%lu", (unsigned long)_peripherals.count);
    if (_peripherals.count == 4) {
        // 扫描足4个设备后进行链接
        [_peripherals enumerateObjectsUsingBlock:^(CBPeripheral  *_Nonnull peripheral, NSUInteger idx, BOOL * _Nonnull stop) {
            _baby.having(peripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().begin();
        }];
    }
}

- (void)insertCharacteristic:(CBCharacteristic *)characteristic {
    [_characteristics addObject:characteristic];
}

- (IBAction)switchAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_peripherals enumerateObjectsUsingBlock:^(CBPeripheral  *_Nonnull peripheral, NSUInteger idx, BOOL * _Nonnull stop) {
            [_characteristics enumerateObjectsUsingBlock:^(CBCharacteristic  *_Nonnull characteristic, NSUInteger idx, BOOL * _Nonnull stop) {
                // 开灯
                Byte b = 0x01;
                NSData *testData = [NSData dataWithBytes:&b length:sizeof(b)];
                [peripheral writeValue:testData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }];
            
        }];
    } else {
        [_peripherals enumerateObjectsUsingBlock:^(CBPeripheral  *_Nonnull peripheral, NSUInteger idx, BOOL * _Nonnull stop) {
            [_characteristics enumerateObjectsUsingBlock:^(CBCharacteristic  *_Nonnull characteristic, NSUInteger idx, BOOL * _Nonnull stop) {
                // 关灯
                Byte b = 0x00;
                NSData *testData = [NSData dataWithBytes:&b length:sizeof(b)];
                [peripheral writeValue:testData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }];
        }];
    }
}
@end
