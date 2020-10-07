//
//  main.m
//  learn-OC
//
//  Created by weixiaolin on 2020/9/17.
//  Copyright © 2020 weixiaolin. All rights reserved.
//
// cmd + R 运行
// cmd + B 编译，只编译.m文件

// <>: 引用的是系统库
#import <Foundation/Foundation.h>
// "": 引用的是自己定义的类
#import "Person.h"
#import "Student.h"
#import "Broker.h"

int main(int argc, const char * argv[]) {
    // 自动释放池
    @autoreleasepool {
        // NSLog自动换行
        NSLog(@"Hello, World!");
        Person *p = [Person new];
        [p eat];
        [p eatApple:1 andOrange:2];
        [p setAge:18];
        NSLog(@"获取年龄:%d", [p age]);
        // 有setter,getter的成员可以使用.语法访问
        p.age = 30;
        NSLog(@"获取年龄:%d", p.age);
        int sum = [Person addNum1:1 andNum2:2];
        NSLog(@"和为：%d", sum);
        p.sex = @"男";
        NSLog(@"性别为：%@", p.sex);
        
        p.houseNumber = 3;
        NSLog(@"房子数量为：%d", p.houseNumber);
        
        Student *s = [Student new];
        [s eat];
        NSLog(@"学生的年龄：%d", s.age);
        
        NSString *string = @"笔者很帅";
        NSString *string1 = [NSString stringWithFormat:@"%@!!!", string];
        NSLog(@"%@", string1);
        
        p.name = @"帅哥";
        NSLog(@"姓名：%@", p.name);
        NSLog(@"对象描述:%@", p);
        
        Person *p1 = [[Person alloc] initWithName:@"初始化的姓名"];
        NSLog(@"%@", p1.name);
        
        char *cstr = "hello OC"; //用c语言方式创建字符串
        NSString *ocstr = [[NSString alloc] initWithUTF8String:cstr]; //转化为OC的字符串
        NSLog(@"%@", ocstr);
        
        // 通过已有字符串创建字符串
        NSString *strWithString = [[NSString alloc] initWithString:string];
        NSLog(@"%@", strWithString);
        
        NSString *strInitWithFormat = @"hello OC";
        NSString *strInitWithFormat1 = [[NSString alloc] initWithFormat:@"%@!!!", strInitWithFormat];
        NSLog(@"%@", strInitWithFormat1);
        
        NSString *strClass = @"hello OC";
        NSString *strClass1 = [NSString stringWithString:strClass];
        NSLog(@"%@", strClass1);
        
        NSString *ocstr1 = [NSString stringWithUTF8String:cstr];
        NSLog(@"%@", ocstr1);
        
        NSString *strAppend = @"hello OC";
        NSString *strAppend1 = [strAppend stringByAppendingString: strAppend];
        NSLog(@"%@", strAppend1);
        
        NSString *strAppendFormat = @"hello OC";
        NSString *strAppendFormat1 = [strAppendFormat stringByAppendingFormat:@" + 拼接格式化字符串 + %@", strAppendFormat];
        NSLog(@"%@", strAppendFormat1);
        
        NSString *strOtherMethod = @"test other method str";
        NSUInteger len = [strOtherMethod length];
        NSLog(@"字符串长度为：%lu", len);
        
        char a = [strOtherMethod characterAtIndex:0];
        NSLog(@"%c", a);
        
        NSString *strEqual = @"字符串";
        BOOL isEqual = [strOtherMethod isEqualToString:strEqual];
        NSLog(@"%d", isEqual);
        
        NSString *compareStr = @"test other method str compare";
        NSComparisonResult compareResult = [strOtherMethod compare:compareStr];
        if (compareResult == NSOrderedAscending){
          NSLog(@"strOtherMethod < compareStr");
        } else if (compareResult == NSOrderedDescending){
          NSLog(@"strOtherMethod > compareStr");
        } else if (compareResult == NSOrderedSame){
          NSLog(@"strOtherMethod = compareStr");
        }
        
        NSLog(@"转为小写字符串 %@", [strOtherMethod lowercaseString]);
        NSLog(@"转为大写字符串 %@", [strOtherMethod uppercaseString]);
        NSLog(@"首字母大写字符串 %@", [strOtherMethod capitalizedString]);
        
        // NSRange 是结构体，表示位置（location：起始点下标，length：长度）
        NSRange range = [strOtherMethod rangeOfString:@"other" options: NSBackwardsSearch];
        // 根据location判断
        if (range.location == NSNotFound){
            NSLog(@"没找到");
        }else {
            NSLog(@"找到了");
        }
        // 根据length判断
        if (range.length == 0){
            NSLog(@"没找到");
        }else {
            NSLog(@"找到了");
        }
        NSLog(@"locatoin = %lu", range.location);
        NSLog(@"length = %lu", range.length);
        
        NSLog(@"%d", [@"3333ergerg" intValue]);
        
        // 确定开始位置
        NSLog(@"%@", [strOtherMethod substringFromIndex:8]);
        // 确定结束位置
        NSLog(@"%@", [strOtherMethod substringToIndex:10]);
        // 确定开始和结束位置
        NSLog(@"%@", [strOtherMethod substringWithRange:NSMakeRange(0, 4)]);
        
        NSMutableString *mutableStr = [NSMutableString stringWithCapacity:20];
        NSLog(@"%@", mutableStr);
        
        NSLog(@"%@", [mutableStr stringByAppendingString:@"hello OC"]);
        [mutableStr appendString:@"!"];
        NSLog(@"%@", mutableStr);
        
        [mutableStr insertString:@"hello OC" atIndex:0];
        NSLog(@"%@", mutableStr);
        
        [mutableStr deleteCharactersInRange:NSMakeRange(8, 1)];
        NSLog(@"%@", mutableStr);
        
        [mutableStr setString:@"hello world"];
        NSLog(@"%@", mutableStr);
        
        [mutableStr replaceCharactersInRange:NSMakeRange(6, 5) withString:@"OC"];
        NSLog(@"%@", mutableStr);
        
        for (int i = 0; i < [mutableStr length]; i++) {
            NSLog(@"%c", [mutableStr characterAtIndex:i]);
        }
        
        //创建空数组
        NSArray *arr = [[NSArray alloc] init];
        NSArray *arr1 = [NSArray array];
        //简单方式创建
        NSArray *arr2 = @[@"hello", @"world"];
        NSLog(@"arr2 = %@", arr2);
        
        //通过对象方法创建
        //1.通过已有数组创建新数组
        NSArray *arr3 = [[NSArray alloc] initWithArray:arr2];
        NSLog(@"arr3 = %@", arr3);
        //2.通过单个对象创建数组
        NSArray *arr4 = [[NSArray alloc] initWithObjects:@"hello", @"world", nil];
        NSLog(@"arr4 = %@", arr4);
        
        //使用类方法调用
        NSArray *arr5 = [NSArray arrayWithArray:arr4];
        NSLog(@"arr5 = %@", arr5);
        NSArray *arr6 = [NSArray arrayWithObjects:@"hello", @"world", nil];
        NSLog(@"arr6 = %@", arr6);
        
        NSUInteger arr6Count = [arr6 count];
        NSLog(@"arr6 lenght = %lu", arr6Count);
        
        // 按下标取元素
        NSLog(@"%@", [arr6 objectAtIndex:0]);
        // 简单方式获取元素
        NSLog(@"%@", arr6[1]);
        // 取最后一个元素
        NSLog(@"%@", [arr6 lastObject]);
        // 取第一个元素
        NSLog(@"%@", [arr6 firstObject]);
        // 取多个元素
        NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 2)];
        NSLog(@"%@", [arr6 objectsAtIndexes:set]);
        // 简单方式取多个元素
        NSLog(@"%@", [arr6 subarrayWithRange:NSMakeRange(0, 2)]);
        
        for (int i = 0; i < [arr6 count]; i++) {
            NSLog(@"%@", arr6[i]);
        }
        
        for (NSString *str in arr6) {
            NSLog(@"%@", str);
        }
        
        NSString *joinArrStr = [arr6 componentsJoinedByString:@"#"];
        NSLog(@"%@", joinArrStr);
        NSLog(@"%@", [joinArrStr componentsSeparatedByString:@"#"]);
        
        NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
        NSMutableArray *mutableArr1 = [NSMutableArray array];
        NSMutableArray *mutableArr2 = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *mutableArr3 = [NSMutableArray arrayWithCapacity:10];
        
        // 添加单个元素
        [mutableArr3 addObject:@"hello"];
        NSLog(@"%@", mutableArr3);
        // 添加多个元素
        [mutableArr3 addObjectsFromArray:@[@"world", @"!"]];
        NSLog(@"%@", mutableArr3);
        // 在中间插入一个元素
        [mutableArr3 insertObject:@"#" atIndex:1];
        NSLog(@"%@", mutableArr3);
        // 在数组中间加入多个元素
        NSIndexSet *set1 = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(2, 2)]; // 在索引为2的地方插入两个元素
        [mutableArr3 insertObjects:@[@"very", @"good"] atIndexes:set1];
        NSLog(@"%@", mutableArr3);
        
        // 按元素内容删除，如果有多个相同的元素会全部删除
        [mutableArr3 removeObject:@"very"];
        NSLog(@"%@", mutableArr3);
        // 按下标删除元素
        [mutableArr3 removeObjectAtIndex:2];
        NSLog(@"%@", mutableArr3);
        // 按位置删除多个元素
        [mutableArr3 removeObjectsInRange:NSMakeRange(1, 2)];
        NSLog(@"%@", mutableArr3);
        // 删除全部元素
        [mutableArr3 removeAllObjects];
        NSLog(@"%@", mutableArr3);
        
        // 替换数组
        [mutableArr3 setArray:@[@"hello", @"world"]];
        NSLog(@"%@", mutableArr3);
        // 替换指定坐标后的多个元素
        NSIndexSet *set2 = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 2)];
        [mutableArr3 replaceObjectsAtIndexes:set2 withObjects:@[@"very", @"good"]];
        NSLog(@"%@", mutableArr3);
        // 在指定位置插入字符串指定范围的数据
        [mutableArr3 replaceObjectsInRange:NSMakeRange(0, 2) withObjectsFromArray:@[@"hello", @"world", @"very", @"good"] range:NSMakeRange(0, 4)];
        NSLog(@"%@", mutableArr3);
        
        for (int i = 0; i < [mutableArr3 count]; i ++) {
            for (int j = 0; j < [mutableArr3 count] - i - 1; j++) {
                if ([mutableArr3[j] compare:mutableArr3[j+1]] == NSOrderedDescending) {
                    [mutableArr3 exchangeObjectAtIndex:j withObjectAtIndex:j+1];
                }
            }
        }
        NSLog(@"冒泡排序 %@", mutableArr3);
        
        // 封装
        int int1 = 1;
        float float1 = 1.02;
        NSNumber *num1 = [[NSNumber alloc] initWithInt:int1];
        NSNumber *num2 = [[NSNumber alloc] initWithFloat:float1];
        NSLog(@"%@ %@", num1, num2);
        
        // 还原
        int int2 = [num1 intValue];
        float float2 = [num2 floatValue];
        NSLog(@"%d %.2f", int2, float2);
        
        Person *per1 = [Person new];
        SEL sel1 = @selector(eat);
        [per1 performSelector:sel1]; // 调用sel封装的方法
        // 容错处理
        SEL sel2 = @selector(run1);
        // 调用方法没有被响应，不会执行后续代码，不会报错
        if ([per1 respondsToSelector:sel2]) {
            [per1 performSelector:sel1];
        }
        [per1 performSelector:sel1 withObject:[[NSNumber alloc] initWithInt:10]]; // 可以加参数，最多两个，多于两个要自己封装
        
        NSDictionary *dic1 = [[NSDictionary alloc] init];
        NSDictionary *dic2 = [NSDictionary dictionary];
        
        NSDictionary *dic3 = @{@"1": @"Beijing", @"2": @"Shanghai"};
        // 通过对象方法创建
        // nil在这里不能省略
        NSDictionary  *dic4 = [[NSDictionary alloc] initWithObjectsAndKeys:@"Beijing", @"1", @"Shanghai", @"2", nil];
        NSDictionary * dic5 = [[NSDictionary alloc] initWithObjects:@[@"Beijing", @"Shanghai"] forKeys:@[@"1", @"2"]];
        NSLog(@"dic5 = %@", dic5);
        // 通过已存在的字典创建新字典
        NSDictionary *dic6 = [[NSDictionary alloc] initWithDictionary:dic3];
        // 通过类方法创建
        NSDictionary *dic7 = [NSDictionary dictionaryWithObjectsAndKeys:@"Beijing", @"1", @"Shanghai", @"2", nil];
        NSDictionary *dic8 = [NSDictionary dictionaryWithObjects:@[@"Beijing", @"Shanghai"] forKeys:@[@"1", @"2"]];
        NSDictionary *dic9 = [NSDictionary dictionaryWithDictionary:dic3];
        
        NSString *dicValue = [dic3 objectForKey:@"1"];
        NSLog(@"dicValue = %@", dicValue);
        // 简单方式取一个值
        NSString *dicValue1 = dic3[@"2"];
        NSLog(@"dicValue1 = %@", dicValue1);
        // 取多个值
        NSArray *dicValues = [dic3 objectsForKeys:@[@"1", @"2", @"3"] notFoundMarker: @"NOT FOUND"];
        NSLog(@"dicValues = %@", dicValues);
        // 取全部的key，无序的
        NSArray *dicAllKeys = [dic3 allKeys];
        NSLog(@"@dicAllKeys = %@", dicAllKeys);
        // 取全部的value, 无序的
        NSArray *dicAllValues = [dic3 allValues];
        NSLog(@"@dicAllValues = %@", dicAllValues);
        // 取已知value对应的key
        NSArray *dicKeys = [dic3 allKeysForObject:@"Beijing"];
        NSLog(@"@dicKeys = %@", dicKeys);
        
        for (int i = 1; i <= [dic3 count]; i++) {
            NSString *keyString1 = [NSString stringWithFormat:@"%d", i];
            NSLog(@"%@ = %@", keyString1, dic3[keyString1]);
        }
        // 快速遍历 无序的
        for (NSString *keyString2 in dic3) {
            NSLog(@"%@ = %@", keyString2, dic3[keyString2]);
        }
        // 枚举
        // NSEnumerator 枚举管理器
        NSEnumerator *merator = [dic3 keyEnumerator];
        NSLog(@"merator = %@", merator);
        // 枚举管理器中存放着字典的key
        id keyString3 = nil;
        while (keyString3 = [merator nextObject]) {
            NSLog(@"keyString3 = %@", keyString3);
            NSLog(@"%@ = %@", keyString3, dic3[keyString3]);
        }
        
        // 创建空字典
        NSMutableDictionary *mDic1 = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *mDic2 = [[NSMutableDictionary alloc] initWithCapacity:100];
        NSMutableDictionary *mDic3 = [NSMutableDictionary dictionaryWithCapacity:100];
        NSMutableDictionary *mDic4 = [NSMutableDictionary dictionary];
        
        // 增
        // 增加一个键值对
        [mDic1 setObject:@"Beijing" forKey:@"1"];
        NSLog(@"mDic1 = %@", mDic1);
        // 增加多个键值对
        [mDic1 addEntriesFromDictionary:@{@"2": @"Shanghai", @"3": @"Tianjing"}];
        NSLog(@"mDic1 = %@", mDic1);
        
        // 改
        // 找到相同key就替换，没有就增加
        [mDic1 setValue:@"Nanjing" forKey:@"2"];
        NSLog(@"mDic1 = %@", mDic1);
        // 用后面的字典替换前面的
        [mDic1 setDictionary:@{@"1": @"b", @"2": @"t", @"3": @"n"}];
        NSLog(@"mDic1 = %@", mDic1);
        
        // 删
        // 删除一个键值对
        [mDic1 removeObjectForKey:@"3"];
        NSLog(@"mDic1 = %@", mDic1);
        // 删除多个键值对
        [mDic1 removeObjectsForKeys:@[@"1"]];
        NSLog(@"mDic1 = %@", mDic1);
        // 删除全部
        [mDic1 removeAllObjects];
        NSLog(@"mDic1 = %@", mDic1);
        
        // 获取格林尼治时间
        NSDate *date = [NSDate date];
        NSLog(@"date = %@", date);
        
        NSDate *newDate = [date dateByAddingTimeInterval:1*60*60];
        NSLog(@"newDate = %@", newDate);
        // 将来的时间，返回一个很远的时间
        NSDate *futureDate = [NSDate distantFuture];
        NSLog(@"futureDate = %@", futureDate);
        // 过去的时间，返回一个很久以前的时间
        NSDate *pastDate = [NSDate distantPast];
        NSLog(@"pastDate = %@", pastDate);
        
        // 将Date转换为字符串
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        // HH是24小时制，hh是12小时制
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *dateStr = [dateFormatter stringFromDate:date];
        NSLog(@"dateStr = %@", dateStr);
        
        // 将字符串转为Date
        NSDate *date1 = [dateFormatter dateFromString:dateStr];
        NSLog(@"date1 = %@", date1);
        
//        // 创建文件管理类实例
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        // 查看目录下的文件
//        NSString *path = @"/Users/wcly/Documents/learn-OC";
//        // 浅遍历，只遍历一层
//        NSArray *dirArr = [fileManager contentsOfDirectoryAtPath:path error:nil];
//        NSLog(@"dirArr = %@", dirArr);
//        // 深遍历，遍历多层
//        NSArray *dirDeepArr = [fileManager subpathsAtPath:path];
//        NSLog(@"dirDeepArr = %@", dirDeepArr);
//        // 取出后缀为.m的文件
//        for (NSString *str in dirDeepArr) {
//            if ([str hasSuffix: @".m"]) {
//                NSLog(@"str = %@", str);
//            }
//        }
//        // 取文件的扩展名
//        for (NSString *str1 in dirDeepArr) {
//            NSLog(@"str1 = %@", str1);
//        }
//        // 取路径的各个部分
//        NSArray *pathComp = [path pathComponents];
//        NSLog(@"pathComp = %@", pathComp);
        
        // 字符串转NSData
        NSString *dataStr = @"hello world";
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"data = %@", data);
        // NSData转字符串
        NSString *dataStr1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"dataStr1 = %@", dataStr1);
        
        // 代理
        Broker *bro = [Broker new];
        [bro brokerWork];
    }
    return 0;
}
