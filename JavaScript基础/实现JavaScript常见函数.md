# 实现JavaScript常见函数

> talk is cheap, show me the code



### 防抖

触发事件后在**规定时间内**回调函数**只能执行一次**，如果在规定时间内**又**触发了该事件，则会重新开始计算。

~~~js
function debounce(func, delay) {
  var timer;
  return function () {
    var _this = this;
    var _args = [].slice.call(arguments);
    clearTimeout(timer);  // 每次运行都清理掉上一个函数，重新计时
    timer = setTimeout(function () {
      func.apply(_this, _args);  // 在指定延迟时间后触发执行
    }, delay);
  };
}
~~~



### 节流

当持续触发事件时，在规定时间段内只能调用一次回调函数。如果在规定时间内**又**触发了该事件，**则什么也不做,也不会重置定时器**。

```js
function throttle(func, threshold) {
  var flag = true;
  return function () {
    if (!flag) return; // 没到时间不做操作
    flag = false;
    var _this = this;
    var _args = [].slice.call(arguments);
    setTimeout(function () {
      // 到时间了执行函数
      func.apply(_this, _args);
      flag = true;
    }, threshold);
  };
}
```



### [call](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/call)

call方法使用一个指定的 `this` 值和单独给出的一个或多个参数来调用一个函数

- call第一个参数为作为函数运行时使用的`this`
- call后续参数为参数列表
- 返回值为函数执行结果

```js
Function.prototype.myCall = function (context) {
  context = context || window; // 如果context为null或者undefined，则赋值为window
  context.fn = this; // 获取调用call的函数
  
  var args = [];
  // 收集剩余参数
  for(var i = 1, len = arguments.length; i < len; i++){
    args.push('arguments[' + i + ']');
  }
  
  var result = eval('context.fn(' + args + ')'); // 执行函数
  
  delete context.fn; // 删除临时属性
  return result; // 返回结果
}
```



### [apply](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/apply)

apply和call差不多，参数列表是作为apply第二个参数传入

- apply第一个参数为作为函数运行时使用的`this`
- apply第二参数是参数列表，是个数组
- 返回值为函数执行结果

```js
Function.prototype.myApply = function (context, args) {
  context = context || window; // 如果context为null或者undefined，则赋值为window
  context.fn = this; // 获取调用call的函数
  var result;
  
  // 如果参数列表不存在，直接运行
  if( !args) {
    result = context.fn(); // 执行函数
  } else {
    // 参数列表存在
    var _args = [];
    // 收集剩余参数
    for(var i = 0, len = args.length; i < len; i++){
      _args.push('args[' + i + ']');
    }
    result = eval('context.fn(' + _args + ')'); // 执行函数
  }
  
 
  delete context.fn; // 删除临时属性
  return result; // 返回结果
}
```



### [bind](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/bind)

bind 方法创建一个新的函数，在bind被调用时，这个新函数的 `this` 被指定为bind的第一个参数，而其余参数将作为新函数的参数，供调用时使用。

- bind的第一个参数作为新函数调用时的`this`，若使用`new`调用新函数会无视传入给bind的第一参数
- bind的剩余参数作为新函数的参数
- 返回一个新函数

```js
Function.prototype.myBind = function (context) {
  // 如果调用者不是函数，抛出错误
  if (typeof this !== "function") {
		throw new Error("Function.prototype.bind - what is trying to be bound is not callable");
  }
  
  var self = this; // 获取调用的函数
  var args = Array.prototype.slice.call(arguments, 1); // 将bind剩余参数转为数组
  
  // 用于生成原函数的原型对象 
  var Func = function() {};
  Func.prototype = this.prototype;
  
  var newFunc = function () {
    var selfArgs = [].slice.call(arguments); // 将新函数的参数转为数组
    // 如果使用new调用则使用原来函数的this，不然就是传入的上下文
    return self.apply(Func.prototype.isPrototypeOf(this) ? this : context, args.concat(selfArgs));
  }

  newFunc.prototype = new Func(); // 继承原函数的原型
  return newFunc;
}
```



### [new](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/new)

**`new`** 关键字会进行如下的操作：

1. 创建一个空的简单JavaScript对象（即**`{}`**）；
2. 链接该对象（设置该对象的**constructor**）到另一个对象 ；
3. 将步骤1新创建的对象作为**`this`**的上下文 ；
4. 如果该函数没有返回对象，则返回**`this`**。

```js
function objectFactory(){
  var obj = new Object(); // 步骤1
  var Constructor = [].shift.call(arguments); // 取第一个参数为构造函数
  
  obj.__proto__ = Constructor.prototype; // 步骤2
  
  var ret = Constructor.apply(obj, arguments); // 步骤3
  
  return typeof ret === 'object' ? ret : obj; // 步骤4
}
```



### [instanceof](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/instanceof)

**`instanceof`** **运算符**用于检测构造函数的 `prototype` 属性是否出现在某个实例对象的原型链上。

```js
function myInstanceOf (object, constructor) {
  var O = constructor.prototype; // 获取构造函数的显示原型
  object = object.__proto__; // 取实例对象的隐式原型
  while (1) {
    if (object === null) return false; // 是空则返回false
    if (object === O) return true; // 找到了，返回true
    object = object.__proto__; // 继续沿着原型链往上找
  }
}
```



### [Object.create](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object/create)

- 创建一个新对象
- 使用第一个参数作为改对象的原型对象

```js
function createObj(proto){
  function F(){};
  F.prototype = proto;
  
  return new F();
}
```



### 实现继承

```js
 // 父类构造函数
function Parent(father) {
  this.father = father;
}
// 父类原型方法
Parent.prototype.say = function () {
  console.log("hi," + this.father);
};

// 子类构造函数
function Child(name, father) {
  Parent.call(this, father); // 调用父类构造函数
  this.name = name;
}

Child.prototype = Object.create(Parent.prototype); // 继承父类的原型

// 子类原型方法
Child.prototype.say = function () {
  console.log("hi," + this.father + ";I'm " + this.name);
};

Child.prototype.constructor = Child; // 修复子类的构造函数指向

// 测试
var parent = new Parent("father");
parent.say(); // hi, father
const child = new Child("child", "father");
child.say(); // hi,father;I'm child
```



### EventBus

使用发布订阅模式，是前端常见的通信手段之一。

~~~js
class EventEmitter {
  constructor() {
    this._event = this._event || new Map(); // 使用map存储事件处理函数
  }

  emit(type, ...args) {
    const handler = this._event.get(type);

    if (Array.isArray(handler)) {
      // 如果处理函数是数组，需要循环触发
      for (let i = 0; i < handler.length; i++) {
        if (args.length > 0) {
          handler[i].apply(this, args); // 参数不为0，使用apply
        } else {
          handler[i].call(this); // 参数为空，直接触发
        }
      }
    } else if (handler && typeof handler === "function") {
      // 如果处理函数是单个函数，直接运行
      if (args.length > 0) {
        handler.apply(this, args);
      } else {
        handler.call(this);
      }
    }
  }

  addEventListener(type, fn) {
    const handler = this._event.get(type);

    if (Array.isArray(handler)) {
      handler.push(fn); // 如果原来的处理函数是数组，直接加一个
    } else if (handler && typeof handler === "function") {
      this._event.set(type, [handler, fn]); // 如果原来的处理函数是函数，变成数组
    } else if (!handler) {
      this._event.set(type, fn); // 如果原来的处理函数不存在，直接设置为目标函数
    }
  }

  removeEventListener(type, fn) {
    const handler = this._event.get(type);

    if (Array.isArray(handler)) {
      const res = handler.filter((i) => i !== fn); // 如果是数组，过滤掉目标函数
      if (res.length === 0) {
        this._event.delete(type); // 过滤完之后为空数组，删除该监听事件
      } else {
        this._event.set(type, res); // 过滤完之后不是数组，设置为过滤完之后的数组
      }
    } else if (
      handler &&
      typeof handler === "function" &&
      handler === fn
    ) {
      this._event.delete(type); // 如果是函数，直接删除
    }
  }
}

// 测试
const eventEmitter = new EventEmitter();
const handler = function (name) {
  console.log(name);
};
eventEmitter.addEventListener("say", handler);
eventEmitter.addEventListener("say", handler);
eventEmitter.emit("say", "hello world");
eventEmitter.removeEventListener("say", handler);
eventEmitter.emit("say", "hello world");
~~~



### 深克隆

这里只考虑数组和普通对象的形式，其它对象（RegExp，Date等）没有考虑到。

```js
function deepClone(origin) {
  if (!origin || typeof origin !== "object") return; // 如果为空值或原始值，直接返回

  const type = Object.prototype.toString.call(origin); // 判断是什么对象

  let newObj = type === "[object Object]" ? {} : []; // 如果是对象则新建一个对象，否则新建一个数组

  if (type === "[object Array]") {
    for (let i = 0; i < origin.length; i++) {
      newObj[i] = deepClone(origin[i]); // 克隆数组的每一个值
    }
  } else if (type === "[object Object]") {
    for (let key in origin) {
      if (origin.hasOwnProperty(key)) {
        newObj[key] = deepClone(origin[key]); // 克隆对象的每一个值
      }
    }
  }
  return newObj;
}

// 测试
const obj = {
  foo: 1,
  bar: {
    baz: 2,
    c: 3,
  },
  d: [4, 5],
};

const obj1 = deepClone(obj);
obj.bar.baz = 1;
console.log(obj, obj1);
```



### 函数柯里化

在数学和计算机科学中，柯里化是一种将使用多个参数的一个函数转换成一系列使用一个参数的函数的技术。

例子：

~~~js
function add(a, b){
  return a + b;
}

add(1, 2); // 普通调用

// 将函数柯里化
var curryAdd = curry(add);
curryAdd(1)(2); // 3
~~~

作用：

1. 参数复用
2. 延迟执行

代码：

- 传入一个函数，返回柯里化之后的函数
- 拼接参数，直到参数长度与原函数参数长度一致才执行，否则继续返回一个函数

```js
 function curry(fn, args) {
   var length = fn.length; // 获取原函数的参数列表长度
   args = args || []; // 获取当前传入的参数

   return function () {
     var _args = args.slice(0); // 复制一份当前传入的参数
     // 拼接传入参数
     for (var i = 0; i < arguments.length; i++) {
       _args.push(arguments[i]);
     }
     
     if (_args.length < length) { // 如果参数小于定义函数参数的长度，继续调用
       return curry.call(this, fn, _args);
     } else {
       return fn.apply(this, _args); // 如果参数等于定义函数参数的长度，执行
     }
   };
 }
```



### 函数组合

接收若干个函数作为参数，返回一个新函数。新函数执行时，按照`由右向左`的顺序依次执行传入`compose`中的函数，每个函数的执行结果作为为下一个函数的输入，直至最后一个函数的输出作为最终的输出结果。

例子：

```js
const n = '3.14';

const func = compose(Math.round, parseFloat);
func(n); // 4，先执行parseFloat再执行round
```

代码：

```js
const compose = (...funcs) => (...args) => funcs.reduceRight((a, b) => a(b(args)));
```



**从左至右处理数据流的过程称之为管道(pipeline)**

代码：

```js
const pipe = (...funcs) => (...args) => funcs.reduce((a, b) => a(b(args)));
```

