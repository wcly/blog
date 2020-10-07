## 类

### 定义

使用`.h`文件

```objc
@interface MyObject : NSObject {
    int memberVar1; // 实体变量
    id  memberVar2;
}

+(return_type) class_method; // 类方法

-(return_type) instance_method1; // 实例方法
-(return_type) instance_method2: (int) p1;
-(return_type) instance_method3: (int) p1 andPar: (int) p2;
@end
```

### 实现

使用`.m`文件

```objc
@implementation MyObject {
  int memberVar3; //私有實體變數
}

+(return_type) class_method {
    .... //method implementation
}
-(return_type) instance_method1 {
     ....
}
-(return_type) instance_method2: (int) p1 {
    ....
}
-(return_type) instance_method3: (int) p1 andPar: (int) p2 {
    ....
}
@end
```

实体变量可以在Interface中定义，也可以在Implementation中定义，区别，Interface区块的实体变量默权限是protected，能被子类访问，Implementation中是private。



### 创建对象

```objc
MyObject * my = [[MyObject alloc] init];
```

2.0中可以使用

```objc
MyObject * my = [MyObject new];
```

打印对象地址，内部调用description

```objc
Person *p = [Person new];
NSLog(@"对象描述为：%@", p);
```

可以覆写description方法修改返回值

```objc
-(NSString *)description{
    NSString *description = [NSString stringWithFormat:@"%d %@ %d %@", _age, _sex, self.houseNumber, self.name];
    return description;
}
```



### 构造函数

创建一个实例

```objc
Person *p = [[Person alloc] init];
```

- alloc: 开辟内存空间
- init：初始化

简写

```objc
Person *p = [Person new];
```

**如果需要在初始化的时候加初始值，需要覆写init方法，不能使用new的写法创建实例**

构造函数声明

```objc
-(id)initWithName:(NSString *)name;
```

构造函数实现

```objc
-(id)initWithName:(NSString *)name{
  	// 对子类进行初始化操作,返回上一步alloc的结果，避免self指针指向无效内存
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}
```

使用

```objc
Person *p1 = [[Person alloc] initWithName:@"初始化的姓名"];
NSLog(@"%@", p1.name);
```





## 方法调用

```objc
[obj mthod: argument]
```

命名规范

```objc
- (void) setColorToRed: (float)red Green: (float)green Blue:(float)blue; /* 宣告方法*/

[myColor setColorToRed: 1.0 Green: 0.8 Blue: 0.2]; /* 呼叫方法*/
```



## 属性

```objc
@interface Person : NSObject {
    @public
        NSString *name; // 成员变量
    @private
        int age;
}

@property(copy) NSString *name; // 属性
@property(readonly) int age;

-(id)initWithAge:(int)age;
@end
```

- 成员变量是内容使用的，属性是暴露给外部使用的
- `@property`定义的属性相当于定义了成员变量加它的`geterr`和`setter`
- 有`getter`和`setter`方法的成员变量可以使用点表达式和箭头表达式访问

```objc
Person *aPerson = [[Person alloc] initWithAge: 53];
aPerson.name = @"Steve"; // 注意：点表达式，等于[aPerson setName: @"Steve"];
NSLog(@"Access by message (%@), dot notation(%@), property name(%@) and direct instance variable access (%@)",
      [aPerson name], aPerson.name, [aPerson valueForKey:@"name"], aPerson->name);
```



## 成员变量修饰符

- `public`：整个程序

- `protected`：本类和子类中（默认模式）

- `private`：本类中（用`property`自动生成的成员变量就是这种）

- `package`：在包内部

  

## 协议

协议是一组没有实现的方法列表，任何的类均可采纳协议并具体实现这组方法。

定义：

```objc
@protocol Locking <NSObject>
- (void)lock;
- (void)unlock;
@end
```

申明：

```objc
@interface SomeClass : SomeSuperClass <Locking>
@end
```

实现：

```objc
@implementation SomeClass
- (void)lock {
  // 实现lock方法...
}
- (void)unlock {
  // 实现unlock方法...
}
@end
```

协议可以遵守一个或多个协议；

类可以遵守一个或多个协议；



协议可以被一个或多个协议遵循；

协议可以被一个或多个类遵循；



### 代理

也叫委托，是一种设计模式

有两个累，A类和B类，A类想做一件事，自己不想去做，让B类去做（实现），就叫代理

B类是不固定的，只要符合一个条件就可以称之为B类，条件：能帮A类去做这件事

代理

```objc
#import <Foundation/Foundation.h>

// 代理
@interface Broker : NSObject
-(void)findHouse;
@end
```

```objc
#import "Broker.h"
// 代理
@implementation Broker
-(void)findHouse{
    NSLog(@"经纪人帮学生找房子");
}
@end
```

学生使用代理

```objc
#import "Person.h"
#import "Broker.h"

@interface Student : NSObject
// 将代理作为自己的成员变量
@property(nonatomic,assign) Broker *broker;

-(void) findBoker;

@end
```

```objc
#import "Student.h"

@implementation Student
// 实现招代理方法
-(void)findBoker{
    [_broker findHouse];
}
@end
```

使用

```objc
#import <Foundation/Foundation.h>
#import "Student.h"

int main(int argc, const char * argv[]) {
    // 自动释放池
    @autoreleasepool {
        Student *stu = [Student new];
				Broker *bro = [Broker new];
				stu.broker = bro;
				[bro findHouse];
    }
    return 0;
}
```

**一般和协议和代理模式一起使用**

协议代理，命名规则：当前类名+Delegate

```objc
#import "Person.h"

// 协议代理
@protocol StudentDelegate<NSObject>
-(void)findHouse;
@end

@interface Student : NSObject

@property(nonatomic, assign) id<StudentDelegate>delegate;

-(void) findHelp;
@end
```

```objc
#import "Student.h"

@implementation Student
// 容错处理
-(void)findHelp{
    SEL sel = @selector(findHouse);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel];
    }
}
@end
```

代理

```objc
#import <Foundation/Foundation.h>
#import "Student.h"

// 代理
@interface Broker : NSObject<StudentDelegate>
-(void)brokerWork;
@end
```

```objc
#import "Broker.h"
// 代理
@implementation Broker
-(void)findHouse{
    NSLog(@"经纪人帮学生找房子");
}

-(void)brokerWork{
    Student *stu = [Student new];
    stu.delegate = self; // 设置这个学生的代理是自己
    [stu findHelp]; // 学生寻求帮助找房子
}
@end
```

使用

```objc
#import <Foundation/Foundation.h>
#import "Broker.h"

int main(int argc, const char * argv[]) {
    // 自动释放池
    @autoreleasepool {
        // 代理
        Broker *bro = [Broker new];
        [bro brokerWork];
    }
    return 0;
}
```



## 动态类型

消息可以发送给任何对象实体，无论改对象实体的公开接口中有没有对应的方法。

对象收到消息，有三种可能的处理手段：

1. 回应消息并运行方法
2. 若无法回应，则可以转发消息给其它对象
3. 若以上两者均无，就要处理无法回应而抛出的异常

```objc
- setMyValue:(id) foo; // 表示参数"foo"可以是任务类的实例
- setMyValue:(id <aProtocal>) foo; // 表示"foo"可以是任何类的实例，但必须采纳"aProtocal"协议
- setMyValue:(id NSNumber*) foo; // 表示"foo"必须是"NSNumber"的实例
```



## 类别(Category)

主要用于分解代码

**Integer.h 文件代码：**

```objc
#import <objc/Object.h>

@interface Integer : Object
{
@private
    int integer;
}

@property (assign, nonatomic) integer;

@end
```

**Integer.m 文件代码：**

```objc
#import "Integer.h"

@implementation Integer

@synthesize integer;

@end
```

**Arithmetic.h 文件代码：**

```objc
#import "Integer.h"

@interface Integer(Arithmetic)
- (id) add: (Integer *) addend;
- (id) sub: (Integer *) subtrahend;
@end
```

**Arithmetic.m 文件代码：**

```objc
#import "Arithmetic.h"

@implementation Integer(Arithmetic)
- (id) add: (Integer *) addend
{
    self.integer = self.integer + addend.integer;
    return self;
}

- (id) sub: (Integer *) subtrahend
{
    self.integer = self.integer - subtrahend.integer;
    return self;
}
@end
```

**Display.h 文件代码：**

```objc
#import "Integer.h"

@interface Integer(Display)
- (id) showstars;
- (id) showint;
@end
```

**Display.m 文件代码：**

```objc
#import "Display.h"

@implementation Integer(Display)
- (id) showstars
{
    int i, x = self.integer;
    for(i=0; i < x; i++)
       printf("*");
    printf("\n");

    return self;
}

- (id) showint
{
    printf("%d\n", self.integer);

    return self;
}
@end
```

**main.m 文件代码：**

```objc
#import "Integer.h"
#import "Arithmetic.h"
#import "Display.h"

int
main(void)
{
    Integer *num1 = [Integer new], *num2 = [Integer new];
    int x;

    printf("Enter an integer: ");
    scanf("%d", &x);

    num1.integer = x;
    [num1 showstars];

    printf("Enter an integer: ");
    scanf("%d", &x);

    num2.integer = x;
    [num2 showstars];

    [num1 add:num2];
    [num1 showint];

    return 0;
}
```



## 垃圾回收机制

```objc
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
  	// 自动管理内存释放
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
```



## 常见修饰符

```objc
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
/**
 不需要定义成员变量，但是如果需要被继承还是要写
 */
@property(nonatomic, assign)int houseNumber;
@property(nonatomic, copy)NSString *name;
@end

NS_ASSUME_NONNULL_END

```

- nonatomic: 非线程安全，`@porperty`默认是atomic，即提供线程安全
- assign: 修饰int、float、double、char等简单数据类型
- weak、strong：用来修饰对象类型

加入 assign、weak、strong等修饰，不需要定义成员变量



## 字符串

`%@`表示打印的是对象的占位符

### 不可变字符串

#### 创建

##### 通过对象方法创建

简单方式创建字符串

```objc
NSString *string = @"hello OC"; // 不可变字符串
NSLog(@"%@", string);
```

格式化字符串

```objc
NSString *strInitWithFormat = @"hello OC";
NSString *strInitWithFormat1 = [[NSString alloc] initWithFormat:@"%@!!!", strInitWithFormat];
NSLog(@"%@", strInitWithFormat1);
```

通过已存在的字符串创建新的字符串

```objc
NSString *string = @"hello OC";
NSString *strWithString = [[NSString alloc] initWithString:string];
NSLog(@"%@", strWithString);
```

通过c语言字符串创建OC中的字符串对象

```objc
char *cstr = "hello OC"; //用c语言方式创建字符串
NSString *ocstr = [[NSString alloc] initWithUTF8String:cstr]; //转化为OC的字符串
NSLog(@"%@", ocstr);
```



##### 通过类方法创建

通过已存在的字符串创建

```objc
NSString *strClass = @"hello OC";
NSString *strClass1 = [NSString stringWithString:strClass];
NSLog(@"%@", strClass1);
```

通过c语言字符串创建OC中的字符串对象

```objc
NSString *string = @"hello OC";
NSString *ocstr1 = [NSString stringWithUTF8String:cstr];
NSLog(@"%@", ocstr1);
```

格式化字符串

```objc
NSString *string = @"hello OC";
NSString *string1 = [NSString stringWithFormat:@"%@!!!", string];
NSLog(@"%@", string1);
```

 通过拼接方式创建字符串

```
NSString *strAppend = @"hello OC";
NSString *strAppend1 = [strAppend stringByAppendingString: strAppend];
NSLog(@"%@", strAppend1);
```

通过格式化拼接创建字符串

```objc
NSString *strAppendFormat = @"hello OC";
NSString *strAppendFormat1 = [strAppendFormat stringByAppendingFormat:@" + 拼接格式化字符串 + %@", strAppendFormat];
NSLog(@"%@", strAppendFormat1);
```



#### 其它方法

```objc
NSString *strOtherMethod = @"test other method str";
```

求字符串长度

```objc
NSUInteger len = [strOtherMethod length];
NSLog(@"字符串长度为：%lu", len);
```

取字符串中指定下标的字符

```
char a = [strOtherMethod characterAtIndex:0];
NSLog(@"%c", a);
```

比较字符串是否相等

```objc
NSString *strEqual = @"字符串";
BOOL isEqual = [strOtherMethod isEqualToString:strEqual];
NSLog(@"%d", isEqual);
```

比较字符串大小，区分大小写

```objc
NSString *compareStr = @"test other method str compare";
NSComparisonResult compareResult = [strOtherMethod compare:compareStr];
if (compareResult == NSOrderedAscending){
  NSLog(@"strOtherMethod < compareStr");
} else if (compareResult == NSOrderedDescending){
  NSLog(@"strOtherMethod > compareStr");
} else if (compareResult == NSOrderedSame){
  NSLog(@"strOtherMethod = compareStr");
}
```

区分大小写

```objc
NSComparisonResult compareResult = [strOtherMethod compare:compareStr options: NSCaseInsensitiveSearch];
```

大小写转换

```objc
NSLog(@"转为小写字符串 %@", [strOtherMethod lowercaseString]);
NSLog(@"转为大写字符串 %@", [strOtherMethod uppercaseString]);
```

每个单词的首字母大写

```objc
NSLog(@"首字母大写字符串 %@", [strOtherMethod capitalizedString]);
```

查找字符串

```objc
// NSRange 是结构体，表示位置（location：起始点下标，length：长度）
NSRange range = [strOtherMethod rangeOfString:@"other"];
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
```

从后往前找第一个出现的

```objc
NSRange range = [strOtherMethod rangeOfString:@"other" options: NSBackwardsSearch];
```

字符串转数字，找到非数字位位置，第一个就为非数字字符串返回0

```objc
NSLog(@"%d", [@"3333ergerg" intValue]);
```

字符串提取，注意：可能会越界

```objc
// 确定开始位置
NSLog(@"%@", [strOtherMethod substringFromIndex:8]);
// 确定结束位置
NSLog(@"%@", [strOtherMethod substringToIndex:10]);
// 确定开始和结束位置
NSLog(@"%@", [strOtherMethod substringWithRange:NSMakeRange(0, 4)]);
```



### 可变字符串

可变字符串是不可变字符串的子类，不可变字符串的方法可变字符串一般可以使用，只是换个类名

可变字符串的任何操作都不能越界

#### 创建

创建空的字符串

```objc
NSMutableString *mutableStr = [[NSMutableString alloc] init];
```

创建一个大致范围的字符串，大于小于这个范围都可以

```objc
NSMutableString *mutableStr = [NSMutableString stringWithCapacity:20];
```

#### 增

在可变字符串后面增加

```objc
// 方法1，返回新字符串
NSLog(@"%@", [mutableStr stringByAppendingString:@"hello OC"]);
// 方法2，修改原字符串
[mutableStr appendString:@"!"];
NSLog(@"%@", mutableStr);
```

在中间增加，不会覆盖原数据，原数据会向后顺延

```objc
[mutableStr insertString:@"hello OC" atIndex:0];
NSLog(@"%@", mutableStr);
```

#### 删

```objc
[mutableStr deleteCharactersInRange:NSMakeRange(8, 1)];
NSLog(@"%@", mutableStr);
```

#### 改

替换当前字符串

```objc
[mutableStr setString:@"hello world"];
NSLog(@"%@", mutableStr);
```

修改制定范围的字符串

```objc
[mutableStr replaceCharactersInRange:NSMakeRange(6, 5) withString:@"OC"];
NSLog(@"%@", mutableStr);
```

#### 查

遍历

```objc
for (int i = 0; i < [mutableStr length]; i++) {
  NSLog(@"%c", [mutableStr characterAtIndex:i]);
}
```



## 数组

数组也是对象，是不同类型对象的集合

### 不可变数组

#### 创建

```objc
// 创建空数组
NSArray *arr = [[NSArray alloc] init];
NSArray *arr1 = [NSArray array];

// 简单方式创建，结尾有个nil，被隐藏了
NSArray *arr2 = @[@"hello", @"world"];
NSLog(@"arr2 = %@", arr2);

// 通过对象方法创建
// 1.通过已有数组创建新数组
NSArray *arr3 = [[NSArray alloc] initWithArray:arr2];
NSLog(@"arr3 = %@", arr3);
// 2.通过单个对象创建数组
NSArray *arr4 = [[NSArray alloc] initWithObjects:@"hello", @"world", nil];
NSLog(@"arr4 = %@", arr4);

// 通过类方法调用
NSArray *arr5 = [NSArray arrayWithArray:arr4];
NSLog(@"arr5 = %@", arr5);
NSArray *arr6 = [NSArray arrayWithObjects:@"hello", @"world", nil];
NSLog(@"arr6 = %@", arr6);
```

####  其它方法

求数组元素个数

```objc
NSUInteger arr6Count = [arr6 count];
NSLog(@"arr6 lenght = %lu", arr6Count);
```

取元素

```objc
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
```

> NSIndexSet: 是一个索引集合
>
> 集合：其它说法与数组相同，只不过集合没有顺序

遍历

```objc
for (int i = 0; i < [arr6 count]; i++) {
  NSLog(@"%@", arr6[i]);
}
```

快速遍历

```objc
for (NSString *str in arr6) {
	NSLog(@"%@", str);
}
```

数组的组合（拼接）

```objc
NSLog(@"%@", [arr6 componentsJoinedByString:@"#"]);
```

字符串分隔

```objc
NSLog(@"%@", [joinArrStr componentsSeparatedByString:@"#"]);
```

### 可变数组

可变数组是不可变数组的子类，类名：`NSMutableArray`，大部分方法和不可变数组一致

#### 创建

```objc
NSMutableArray *mutableArr = [[NSMutableArray alloc] init];
NSMutableArray *mutableArr1 = [NSMutableArray array];
NSMutableArray *mutableArr2 = [[NSMutableArray alloc] initWithCapacity:10];
NSMutableArray *mutableArr3 = [NSMutableArray arrayWithCapacity:10];
```

> 注意：可变数组不能用简单方式创建，用简单方法创建的数组是一个不可变数组

#### 其它方法

增

```objc
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
```

删

```objc
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
```

改

```objc
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
```

遍历

冒泡排序

```objc
for (int i = 0; i < [mutableArr3 count]; i ++) {
  for (int j = 0; j < [mutableArr3 count] - i - 1; j++) {
    if ([mutableArr3[j] compare:mutableArr3[j+1]] == NSOrderedDescending) {
      [mutableArr3 exchangeObjectAtIndex:j withObjectAtIndex:j+1];
    }
  }
}
NSLog(@"冒泡排序 %@", mutableArr3);
```



## 包装类

### NSNumber

用于封装简单数据类型的类，可以将简单数据类型封装成对象

```objc
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
```

### SEL

可以将对象方法封装成变量，它是一种数据类型

格式：`selector(方法名)`

```objc
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
```



### 字典

#### 不可变字典（NSDictionary）

创建字典

```objc
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
```

取值

```objc
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
```

遍历

```objc
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
```

#### 可变字典（NSMutableDictionary）

可变字典是不可变字典的子类

创建

```objc
// 创建空字典
NSMutableDictionary *mDic1 = [[NSMutableDictionary alloc] init];
NSMutableDictionary *mDic2 = [[NSMutableDictionary alloc] initWithCapacity:100];
NSMutableDictionary *mDic3 = [NSMutableDictionary dictionaryWithCapacity:100];
NSMutableDictionary *mDic4 = [NSMutableDictionary dictionary];
```

其他方法

```objc
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
```





### 日期类（NSDate）

```objc
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
```



### 文件管理类（NSFileManager）

专门用于管理文件的，使用的是单例模式

```objc
// 创建文件管理类实例
NSFileManager *fileManager = [NSFileManager defaultManager];
// 查看目录下的文件
NSString *path = @"/Users/wcly/Documents/learn-OC";
// 浅遍历，只遍历一层
NSArray *dirArr = [fileManager contentsOfDirectoryAtPath:path error:nil];
NSLog(@"dirArr = %@", dirArr);
// 深遍历，遍历多层
NSArray *dirDeepArr = [fileManager subpathsAtPath:path];
NSLog(@"dirDeepArr = %@", dirDeepArr);
// 取出后缀为.m的文件
for (NSString *str in dirDeepArr) {
if ([str hasSuffix: @".m"]) {
NSLog(@"str = %@", str);
}
}
// 取文件的扩展名
for (NSString *str1 in dirDeepArr) {
NSLog(@"str1 = %@", str1);
}
// 取路径的各个部分
NSArray *pathComp = [path pathComponents];
NSLog(@"pathComp = %@", pathComp);
}
```



### 数据类（NSData）

一种数据类型，在传输数据时，传输的是二进制文件

```objc
// 字符串转NSData
NSString *dataStr = @"hello world";
NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
NSLog(@"data = %@", data);
// NSData转字符串
NSString *dataStr1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
NSLog(@"dataStr1 = %@", dataStr1);
```

