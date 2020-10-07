//
//  Student.m
//  learn-OC
//
//  Created by weixiaolin on 2020/9/27.
//  Copyright © 2020 weixiaolin. All rights reserved.
//

#import "Student.h"

@implementation Student
-(void)eat{
    _age = 18;
    [super eat];
    NSLog(@"学生在吃");
}

// 容错处理
-(void)findHelp{
    SEL sel = @selector(findHouse);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel];
    }
}

@end
