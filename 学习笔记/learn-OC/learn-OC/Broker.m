//
//  Broker.m
//  learn-OC
//
//  Created by wcly on 2020/10/7.
//  Copyright © 2020 weixiaolin. All rights reserved.
//

#import "Broker.h"
// 代理
@implementation Broker
-(void)findHouse{
    NSLog(@"经纪人帮学生找房子");
}

-(void)brokerWork{
    Student *stu = [Student new];
    stu.delegate = self; // 设置这个学生的代理是自己
    [stu findHelp];
}
@end
