//
//  Student.h
//  learn-OC
//
//  Created by weixiaolin on 2020/9/27.
//  Copyright © 2020 weixiaolin. All rights reserved.
//

#import "Person.h"

NS_ASSUME_NONNULL_BEGIN

// 协议代理
@protocol StudentDelegate<NSObject>
-(void)findHouse;
@end

@interface Student : Person

@property(nonatomic, assign) id<StudentDelegate>delegate;

-(void) eat;
-(void) findHelp;
@end

NS_ASSUME_NONNULL_END
