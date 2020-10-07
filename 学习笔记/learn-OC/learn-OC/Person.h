//
//  Person.h
//  learn-OC
//
//  Created by weixiaolin on 2020/9/17.
//  Copyright © 2020 weixiaolin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
{
    // 成员变量
    int _age;
    NSString *_sex;
}

/**
 setter
 */
-(void) setAge:(int)age;
/**
 getter
 */
-(int) age;

-(void) eat;
-(void) hello;

/**
 @property会自动生成get和set方法定义
 */
@property NSString * sex;


/**
 不需要定义成员变量
 */
@property(nonatomic, assign)int houseNumber;

/**
 对象用copy类型修饰
 */
@property(nonatomic, copy)NSString *name;

// 构造函数
-(id)initWithName:(NSString *)name;

/**
 语义化命名
 实例方法，可以使用成员变量
*/
-(void) eatApple:(int)num andOrange:(int)num2;

/**
 类方法
 不能使用成员变量
 */
+(int) addNum1:(int)num1 andNum2:(int)num2;

@end

NS_ASSUME_NONNULL_END
