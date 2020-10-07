//
//  Person.m
//  learn-OC
//
//  Created by weixiaolin on 2020/9/17.
//  Copyright © 2020 weixiaolin. All rights reserved.
//

#import "Person.h"

@implementation Person

-(void)setAge:(int)age{
    _age = age;
}

-(int)age{
    return _age;
}

-(void) hello{
    NSLog(@"hello");
}

-(void) eat{
    NSLog(@"吃饭");
}

-(void) eatApple:(int)num andOrange:(int)num2{
    NSLog(@"吃苹果%d个和橘子%d个", num, num2);
}

-(NSString *)description{
    NSString *description = [NSString stringWithFormat:@"年龄：%d， 性别：%@， 房子数量：%d， 姓名：%@", _age, _sex, self.houseNumber, self.name];
    return description;
}

-(id)initWithName:(NSString *)name{
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}

/**
 自动生成get和set方法实现，可省略
 */
@synthesize sex = _sex;

+(int)addNum1:(int)num1 andNum2:(int)num2{
    int sum = num1 + num2;
    return sum;
}
@end
