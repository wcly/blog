深克隆作为前端面试炙手可热的面试题，难倒了不是英雄好汉。这是一道很好的，可以让面试官看出面试者对`JavaScript`基础的掌握程度的题。

在这内卷盛行的行业，你知道如何写出让面试官眼前一亮的深克隆代码吗？如果你不知道如何写出让面试官眼前一亮的深克隆代码，那就让我带你来一起研究研究。

![](http://wx4.sinaimg.cn/large/006APoFYly8gptwqt3k71g308c08cx3q.gif)

# 前置知识

## 浅克隆

在`JavaScript`中，对引用类型进行复制操作，就是单纯的复制引用地址，复制后的对象指向的还是同一个内存空间。

```js
const obj = { foo: 1 };
const shallowCloneObj = obj;
```

![image-20210914094256133](https://i.loli.net/2021/09/14/jGAYxJbUraidP7Q.png)

问题很明显，修改`shallowCloneObj`对象中的值会影响到原来的对象`obj`。

```javascript
console.log(obj); // { foo: 1 }

shallowCloneObj.foo = 2;
console.log(obj); // { foo: 2 }
```

![](http://wx4.sinaimg.cn/bmiddle/415f82b9ly1ff3sol8f13j20hq0gb3z5.jpg)

显然，使用浅复制，在对复制对象进行操作后，无法保证原对象的内容不变，这个时候就需要使用到深克隆。

## 深克隆

深克隆，就是指开辟一块新的内存空间，再将原来的属性值复制过来。

![image-20210914101630229](https://i.loli.net/2021/09/14/gtT5AqhFxRjI2Da.png)

```js
const obj = { foo: 1 };
const shallowCloneObj = { foo: 1 };
```

这样不管怎么操作复制后的对象，都不会影响到原来的对象。

![](http://wx4.sinaimg.cn/bmiddle/b3b42fe1gy1g9gkj2sp0kj20ic0icdhk.jpg)

# 开始手写

## 面试官OS：就这？

首先，我们想到，复制一个对象的属性，遍历一遍对象的key，挨个复制就行了。

```js
function cloneDeep(target) {
  const cloneTarget = {};

  for (const key in target) {
    cloneTarget[key] = target[key];
  }

  return cloneTarget;
}
```

这很简单，没什么问题，但是，大家不难想到，如果有嵌套对象怎么办。

### 解决嵌套对象

可以使用递归，当遇到原始值的时候直接返回，遇到对象继续递归遍历。

```js
function cloneDeep(target) {
  // 原始值直接返回
  if (typeof target !== "object") {
    return target;
  }

  const cloneTarget = {};

  for (const key in target) {
    cloneTarget[key] = cloneDeep(target[key]); // 继续递归克隆对象中的属性
  }

  return cloneTarget;
}
```

这样，最基本的深克隆就完成了。

但是这里我们并没有区分数组和对象，显然在克隆数组的时候初始化的值不能是`{}`。

这里我们只需要加个简单的判断就可以了。

```js
function cloneDeep(target) {
  if (typeof target !== "object") {
    return target;
  }

  const cloneTarget = Array.isArray(target) ? [] : {}; // 区分是数组还是对象，进行不同的初始化

  for (const key in target) {
    cloneTarget[key] = cloneDeep(target[key]);
  }

  return cloneTarget;
}
```

**测试代码：**

```js
const obj = { foo: 1, child: { bar: 2 }, arr: [1, 2, 3] };
console.log(cloneDeep(obj));
```

**测试结果：**

![image-20210914161032485](https://i.loli.net/2021/09/14/FMRqoKpCBvT1Ytd.png)

**代码地址：**https://codesandbox.io/s/deepclone-egjwg?file=/src/cloneDeep1.js

> 一个简易版的深克隆实现了，但估计面试官看到这里，内心应该毫无波澜，甚至有点想说：

![](http://wx4.sinaimg.cn/large/005XSXmNgy1gsug6b68tmj308c08c3yt.jpg)



写到这里，你掌握的知识点有：

- 对象遍历
- 递归
- 类型判断

## 面试官OS：展开说说？

### 解决循环引用

遇到对象不得不提，循环引用，当你使用循环引用的对象时，上面的递归代码就会招不到出口，从而造成死循环，如下面这种对象：

```js
const obj = { foo: 1, child: { bar: 2 }, arr: [1, 2, 3] };
obj.obj = obj;
```

![image-20210914161114171](https://i.loli.net/2021/09/14/HEOi3KhRB4eASjr.png)

这个时候其实我们只需要加个缓存就行了，当遇到已经克隆过的对象，直接返回，不再进行递归处理。

我们可以使用`Map`数据结构做缓存，`key`为对象的引用，`value`为对象克隆后的值。

```js
function cloneDeep(target, cache = new Map()) {
  if (typeof target !== "object") {
    return target;
  }

  if (cache.has(target)) {
    // 有缓存直接返回
    return cache.get(target);
  }

  const cloneTarget = Array.isArray(target) ? [] : {};

  cache.set(target, cloneTarget); // 设置缓存

  for (const key in target) {
    cloneTarget[key] = cloneDeep(target[key], cache); // 使用同一个缓存
  }

  return cloneTarget;
}
```

**测试代码：**

```js
const obj = { foo: 1, child: { bar: 2 }, arr: [1, 2, 3] };
obj.obj = obj;
```

**测试结果：**

![image-20210914161141660](https://i.loli.net/2021/09/14/DlCpf3sEzBMy8OW.png)

`<ref *1>`：代表这个对象被引用了，名称为`*1`

`[Circular *1]`：代表这个是循环引用，引用了名称为`*1`的对象

**代码地址：**https://codesandbox.io/s/deepclone-egjwg?file=/src/cloneDeep2.js

**掌握知识点：**

- 使用缓存解决循环引用

> 看到这里，面试官心理应该是这么想的：哦？心还挺细，想到了循环引用的问题，让我康康这小伙子后面还能写点什么出来。

![](http://wx3.sinaimg.cn/bmiddle/006m97Kgly1g4r4wa9tpyj30hs0hsdhm.jpg)

## 面试官OS：哎呦，不错哦

### 精准判断数据类型

上面的类型判断显然不够精确，只是粗略的判断区分了数组，对象还有基本类型，还有很多数据类型需要特殊处理。

这里使用`typeof`显然是不够用的，`typeof`只能区分基本类型和引用类型，并且特殊值`Null`会被识别为对象。所以，这里我们要的对象并不是我们真正想要的，还需要排除一些干扰项。这里我们编写一个`isObject`方法。

```js
/**
 * 是否是对象或者函数
 * @param {*} target 目标
 * @returns
 */
function isObject(target) {
  const type = typeof target;
  return target !== null && (type === "object" || type === "function");
}
```

我们这里把函数也筛选出来，因为后续还要对函数进行克隆，不能直接返回。

接着，我们编写一个获取目标数据准确类型的方法，并事先罗列出已有的类型

```js
const MAP_TAG = "[object Map]";
const SET_TAG = "[object Set]";
const OBJECT_TAG = "[object Object]";
const ARRAY_TAG = "[object Array]";

const NUMBER_TAG = "[object Number]";
const BOOLEAN_TAG = "[object Boolean]";
const STRING_TAG = "[object String]";
const SYMBOL_TAG = "[object Symbol]";
const FUNCTION_TAG = "[object Function]";
const BIGINT_TAG = "[object BigInt]";
const ERROR_TAG = "[object Error]";
const REG_EXP_TAG = "[object RegExp]";
const DATE_TAG = "[object Date]";
const NULL_TAG = "[object Null]";
const UNDEFINED_TAG = "[object Undefined]";

// 可以继续遍历克隆的类型
const deepCloneableTags = [MAP_TAG, SET_TAG, OBJECT_TAG, ARRAY_TAG];

/**
 * 获取目标类型
 * @param {*} target 目标
 * @returns
 */
function getType(target) {
  return Object.prototype.toString.call(target);
}
```

我们还将需要深克隆的数据类型进行了分组处理，后续便于筛选。

### 保留原数据的原型链

在之前的代码中，我们初始化对象和数组使用的字面量声明的形式，这里会有一个问题，这会导致原有的原型链丢失，所以，在我们初始化引用类型数据的时候需要使用它的构造函数创建一个新的实例。

```js
/**
 * 生成一个新的相同类型的对象
 * @param {*} target 目标对象
 * @returns
 */
function getInit(target) {
  const Ctor = target.constructor;
  return new Ctor();
}
```

我们创建一个`getInit`方法，并使用目标数据的构造函数创建一个新的实例，保持原有数据的原型。

> 做了严谨的类型判断和原型链细节的完善后，此时面试官应该已经看出了你的扎实的js基础，并且好奇的想要看下去，这些类型你要怎么实现克隆。

![](https://tva1.sinaimg.cn/large/9150e4e5gy1fxro0siwtyg207i07igmf.gif)

**掌握知识点：**

- 精准类型判断
- 原型链

## 面试官OS：可以，可以，你过关了

好了，接下来轮到要把我们装过的逼一个个兑现的时候了。

![](http://wx3.sinaimg.cn/bmiddle/0073Cjx6gy1gtta4m6mo4g30780784dr.gif)

### 克隆Map和Set

先来个简单的，对于Map和Set数据直接遍历，根据其自带api进行赋值即可。

```js
// 获取类型
const type = getType(target);

// 克隆Set
if (type === SET_TAG) {
  target.forEach((value) => {
    cloneTarget.add(cloneDeep(value));
  });
  return cloneTarget;
}

// 克隆Map
if (type === MAP_TAG) {
  target.forEach((value, key) => {
    cloneTarget.set(key, cloneDeep(value));
  });
  return cloneTarget;
}
```

### 克隆正则表达式

```js
/**
 * 克隆正则表达式
 * @param {*} target 正则对象
 * @returns
 */
function cloneRegExp(regexp) {
  const reFlags = /\w*$/;
  const Ctor = regexp.constructor;
  const result = new Ctor(regexp.source, reFlags.exec(regexp));
  result.lastIndex = regexp.lastIndex; // 游标归位
  return result;
}
```

这里使用正则表达式的构造函数创建一个新的正则表达式，构造函数的第一个参数是传入正则表达式的字符串，第二个参数是传入正则表达式的标志字符串。

我们使用`source`属性获取正则表达式的字符串形式。

```js
var regex = /fooBar/ig;

console.log(regex.source); // "fooBar"，不包含 /.../ 和 "ig"。
```

使用正则`/\w*$/`并调用`exec`方法获取正则表达式的标志。

![image-20210914152608406](https://i.loli.net/2021/09/14/elUOEfvwKukaxg1.png)

需要注意的是，`exec`方法返回的是一个数组，而正则表达式第二个参数需要传入的是一个字符串，这里证明构造函数内部会对数组进行隐式类型转换，变成字符串。

![image-20210914152631275](https://i.loli.net/2021/09/14/fFDazuUQegiG41V.png)

然后有些人可能会问：直接使用`regexp.flags`不是能直接获取到正则标志字符串吗，为什么要不厌其烦的使用正则去取出来。答案很简单，兼容性不好，这玩意好，但这玩意用不了：

![image-20210914171544571](https://i.loli.net/2021/09/14/QfcsAOEujPFowyn.png)

然后最后的最后别忘了要将游标归位，谁知道原来的正则调用了几次`exec()`呢。

### 克隆函数

虽然大多数情况下，克隆函数并没什么必要，使用同一个函数的引用反而是一种节省内存的表现，但是这里为了向面试官炫技嘛，还是得写一下。

首先，我们要知道函数分为两种：普通函数和箭头函数。箭头函数相较于普通函数：不能使用`arguments`、`super`和`new.target`，也不能用作构造函数。此外，箭头函数也没有`prototype`属性。

这里我们就以有没有`prototype`属性来区分普通函数和箭头函数：

```js
/**
 * 复制函数
 * @param {*} func 目标函数
 */
function cloneFunction(func) {
  const paramReg = /(?<=\().+(?=\)\s+{)/; // 参数正则
  const bodyReg = /(?<={)(.|\n)+(?=})/m; // 函数体正则
  const funcString = func.toString(); // 获取函数字符串

  // 有原型表示是普通函数，否则是箭头函数
  if (func.prototype) {
    const param = paramReg.exec(funcString);
    const body = bodyReg.exec(funcString);

    if (body) {
      if (param) {
        const args = param[0].split(",");
        return new Function(...args, body[0]); // 有参函数
      }
      return new Function(body[0]); // 无参函数
    } else {
      return null;
    }
  } else {
    return eval(funcString); // 箭头函数直接用eval转
  }
}
```

先使用`toString()`获取函数声明的字符串。

![image-20210914154150164](https://i.loli.net/2021/09/14/rq8On5uolbAUhZt.png)

这里拆解一下正则表达式：

- 参数正则：`/(?<=\().+(?=\)\s+{)/`，分几部分看：

  - `(?<=\()`：表示匹配内容在`(`后面

  - `.+`：匹配内容可以是任意字符
  - `(?=\)\s+{)`：表示匹配内容后面跟着`)`加任意数量的空格再加`{`

- 函数体正则：`/(?<={)(.|\n)+(?=})/m`
  - `(?<={)`：表示匹配内容在`{`后面
  - `(.|\n)+`：表示内容是任意字符串或者换行符
  - `(?=})`：表示后面跟着的是`}`
  - `m`：标志着可以多行匹配

最后使用`Function`构造函数生成普通函数，使用`eval()`生成箭头函数就可以了。

### 克隆其它类型

```js
/**
 * 克隆其它不需要深克隆的类型
 * @param {*} target 目标
 * @param {*} type 类型
 * @returns
 */
function cloneOtherType(target, type) {
  const Ctor = target.constructor;
  switch (type) {
    case BOOLEAN_TAG:
    case NUMBER_TAG:
    case STRING_TAG:
    case ERROR_TAG:
    case DATE_TAG:
      return new Ctor(target);
    case SYMBOL_TAG:
    case BIGINT_TAG:
      return Object(target.constructor.prototype.valueOf.call(target));
    case REG_EXP_TAG:
      return cloneRegExp(target);
    case FUNCTION_TAG:
      return cloneFunction(target);
    default:
      return null;
  }
}
```

这里`Object()`当成普通函数调用的时候相当于`new Object()`，并且会转换成传入数据对应的包装函数类型。

```js
// 等价于 o = new Boolean(true);
var o = Object(true);
```

下面完善一下主体代码：

```js
function cloneDeep(target, cache = new Map()) {
  // 原始类型直接返回
  if (!isObject(target)) {
    return target;
  }

  // 循环引用直接返回
  if (cache.has(target)) {
    return cache.get(target);
  }

  // 获取类型
  const type = getType(target);

  let cloneTarget;
  if (deepCloneableTags.includes(type)) {
    // 初始化
    cloneTarget = getInit(target);
  } else {
    return cloneOtherType(target, type);
  }

  // 设置缓存
  cache.set(target, cloneTarget);

  // 克隆Set
  if (type === SET_TAG) {
    target.forEach((value) => {
      cloneTarget.add(cloneDeep(value));
    });
    return cloneTarget;
  }

  // 克隆Map
  if (type === MAP_TAG) {
    target.forEach((value, key) => {
      cloneTarget.set(key, cloneDeep(value));
    });
    return cloneTarget;
  }

  // 克隆对象或数组
  for (const key in target) {
    cloneTarget[key] = cloneDeep(target[key], cache); // 使用同一个缓存
  }

  return cloneTarget;
}
```

**测试数据：**

```js
const obj = {
  ud: undefined,
  bool: new Boolean(true),
  num: new Number(2),
  str: new String(2),
  date: new Date(),
  sb: Symbol(1),
  bi: BigInt(1),
  err: new Error(),
  null: null,
  reg: /(?<=\().+(?=\)\s+{)/,
  map: new Map([[1, 1]]),
  set: new Set([1]),
  child: {
    child: "child"
  },
  arr: [1, 2, 3],
  func1: () => {
    console.log("雮尘");
  },
  func2: function (a, b) {
    return a + b;
  }
};
obj.obj = obj;
console.log(cloneDeep(obj));
```

**测试结果：**

![image-20210914162451144](https://i.loli.net/2021/09/14/eT6Vj5tHwvogc2u.png)

> 到这里，估计面试官已经认可你的能力了，这一关你算是过去了哈。

![](http://wx2.sinaimg.cn/large/006APoFYly1g7y1qb9o0hg308c08ct9g.gif)

**掌握知识点：**

- `Map`和`Set`
- 正则表达式
- 箭头函数和普通函数的区别
- 包装类
- `eval()`
- 各种类型的构造函数
- 隐式类型转换

## 面试官OS：漂亮！

你们以为到这里就完事了吗，对不起，让你们失望了，还有优化点呢。

### 优化效率

`JavaScript`中的遍历有好几种：`while`、`for`、`for of`，哪个效率高，写个测试代码一目了然：

```js
const arr = new Array(1000000).fill(1);

function testWhileConsumption() {
  console.time("while");
  let sum = 0;
  const { length } = arr;
  let i = -1;
  while (++i < length) {
    sum += arr[i];
  }
  console.timeEnd("while");
}

function testForConsumption() {
  console.time("for");
  let sum = 0;
  const { length } = arr;
  for (let i = 0; i < length; i++) {
    sum += arr[i];
  }
  console.timeEnd("for");
}

function testForInConsumption() {
  console.time("for in");
  let sum = 0;
  for (const key in arr) {
    sum += arr[key];
  }
  console.timeEnd("for in");
}

testWhileConsumption();
testForConsumption();
testForInConsumption();
```

![image-20210914170438841](https://i.loli.net/2021/09/14/WjnGUwgY95EMHzy.png)

这里很明显，`for in`的效率是很低的。所以我们要想办法使用`for`来代替`for in`，编写一个`forEach`函数

```js
/**
 * 迭代数组或者对象，优化效率
 * @param {*} collection 集合
 * @param {*} iteratee 迭代回调
 * @returns
 */
function forEach(collection, iteratee) {
  if (collection === null) {
    return collection;
  }
  const { length } = collection;
  for(let i = 0; i < length; i++) {
    iteratee(collection[i], i);
  }
  return collection;
}
```

调用：

```js
// 克隆对象或数组
const isArray = type === ARRAY_TAG;
let collection = isArray ? target : Object.keys(target);
forEach(collection, (value, key) => {
  if (!isArray) {
    key = value;
  }
  cloneTarget[key] = cloneDeep(target[key], cache);
});
```

### 优化内存

在使用缓存的时候也可以优化，使用`weakMap`来代替`Map`。使用`WeakMap`的好处使用的对象作为`key`的时候，这个对象的所有引用都不存在了，那么垃圾回收机制就会回收掉`WeakMap`中的这一项；

下面写个测试代码验证一下：

```js
global.gc(); // 0 每次查询内存都先执行gc()再memoryUsage()，是为了确保垃圾回收，保证获取的内存使用状态准确

function usedSize() {
  const used = process.memoryUsage().heapUsed;
  return Math.round((used / 1024 / 1024) * 100) / 100 + "M";
}

console.log(usedSize()); // 1 初始状态，执行gc()和memoryUsage()以后，heapUsed 值为 1.85M

var map = new Map();
var b = new Array(5 * 1024 * 1024);

map.set(b, 1);

global.gc();
console.log(usedSize()); // 2 在 Map 中加入元素b，为一个 5*1024*1024 的数组后，heapUsed为42.03M左右

b = null;
global.gc();

console.log(usedSize()); // 3 将b置为空以后，heapUsed 仍为442.03M，说明Map中的那个长度为5*1024*1024的数组依然存在
```

运行结果：

![image-20210915081656498](https://i.loli.net/2021/09/15/5YWZNgeEd2XCotP.png)

 注：运行的时候记得加上参数`--expose-gc`，否则无法使用`gc()`方法

上图很明显看到，使用`Map`的时候，即使原对象被设置为`null`，因为`Map`和就原对象的堆内存是强引用的关系，所以还是不会被gc回收内存。

现在将`Map`改成`WeakMap`，再运行一次：

![image-20210915082121705](https://i.loli.net/2021/09/15/H9QyIPU8lERFZCX.png)

知道以上结论后，只需要将我们原代码中的`Map`改成`WeakMap`就行了。

```js
function cloneDeep(target, cache = new Map()) {
	//...
}
```

### 解决`Symbol`作为key的问题

上面我们只考虑了如何克隆`Symbol`，但是`Symbol`类型不但可以作为对象的值存在，还可以作为对象的键存在。而通过`Object.keys`是没办法获取作为键的`Symbol`的。

![](http://wx4.sinaimg.cn/large/bf976b12gy1ghfo72u6qlg206m05ydg2.gif)

我们需要使用`Object.getOwnPropertySymbols()`方法获取。所以在处理对象的时候需要拼接上已`Symbol`类型作为键的数组。

```js
 let collection = isArray
    ? target
    : Object.keys(target).concat(Object.getOwnPropertySymbols(target));
```

最后再测试一下完整代码：

**测试代码：**

```js
const obj = {
  ud: undefined,
  bool: new Boolean(true),
  num: new Number(2),
  str: new String(2),
  date: new Date(),
  sb: Symbol(1),
  bi: BigInt(1),
  err: new Error(),
  null: null,
  reg: /(?<=\().+(?=\)\s+{)/,
  map: new Map([[1, 1]]),
  set: new Set([1]),
  child: {
    child: "child"
  },
  [Symbol("key")]: Symbol("value"),
  arr: [1, 2, 3],
  func1: () => {
    console.log("雮尘");
  },
  func2: function (a, b) {
    return a + b;
  }
};
obj.obj = obj;
console.log(cloneDeep(obj));
```

**测试结果：**

![image-20210915085624212](https://i.loli.net/2021/09/15/uUpODqzY4kATvfI.png)

**代码地址：**https://codesandbox.io/s/deepclone-egjwg?file=/src/cloneDeep4.js:3981-4478

> 面试官：漂亮！JavaScript功底扎实，注重细节处理，还考虑到了性能问题，看来平时没少积累，确认过眼神，是我要的人，明天过来上班吧！

![](https://i.loli.net/2021/09/15/THbYlXpJq65CrkI.jpg)

**掌握知识点：**

- 各种循环的效率比较
- `WeakMap`对比`Map`的优势
- 如何获取作为对象键的`Symbol`

# 后记

看看我们最后掌握了那些知识点：

- 对象遍历
- 递归
- 类型判断
- 使用缓存解决循环引用
- 精准类型判断
- 原型链
- `Map`和`Set`
- 正则表达式
- 箭头函数和普通函数的区别
- 包装类
- `eval()`
- 各种类型的构造函数
- 隐式类型转换
- 各种循环的效率比较
- `WeakMap`对比`Map`的优势
- 如何获取作为对象键的`Symbol`

一道题就可以看出面试者的城府有多深，啊，不对，是基础有多扎实。不管面试要不要考，还是很值得手写一遍的，卷起来。



希望本文对大家有所帮助，喜欢的记得点赞收藏❤️。



> 参考：
>
> - https://segmentfault.com/a/1190000039862872
> - https://github1s.com/lodash/lodash/blob/master/.internal/baseClone.js
> - https://cloud.tencent.com/developer/article/1497418

