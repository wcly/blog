//
//  Broker.h
//  learn-OC
//
//  Created by wcly on 2020/10/7.
//  Copyright © 2020 weixiaolin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Student.h"

NS_ASSUME_NONNULL_BEGIN
// 代理
@interface Broker : NSObject<StudentDelegate>
-(void)brokerWork;
@end

NS_ASSUME_NONNULL_END
