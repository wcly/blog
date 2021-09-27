# Promises/A+规范

**一个健全的、可互操作的 JavaScript  promise的开放标准——由实施者提供，为实施者服务。**

*Promise* 代表的是异步操作的最终结果，和 promise 交互的主要途径是通过它的`then`方法，它通过回调函数接受 promise 的最终值（value）或是造成 promise 无法实现的原因（reason）。

该规范详细说明了 `then `方法的行为，提供一个可交互操作的基础，所有符合 Promises/A+ 规范的 promise 都可以依赖这个基础来实现。因此，规范可以被当做是非常稳定的。尽管 Promises/A+ 组织偶尔在发现新问题的极端情况下，可能会通过向后兼容的微小改动来修改此规范，并且只有在经过仔细考虑、讨论和测试后，我们才会集成大的不向后兼容的修改。

从历史上看，Promises/A+ 是基于 [Promises/A](http://wiki.commonjs.org/wiki/Promises/A) 规范的，扩展其中明确规定的条款，并且摒弃其中不确定的或者有问题的部分。

最终，Promises/A+ 规范目前并没有涉及如何创建（create）、履行（fulfill）或者拒绝（reject）promises，而是选择专注于提供可交互操作的 `then` 方法。以后可以能会涉及这些操作。

## 1. 术语

1.1. “promise” 是一个具有 `then` 方法的对象或者函数，它的行为符合本规范。

1.2. “thenable” 是定义 `then` 方法的对象或函数。

1.3. “value” 是任何合法的 JavaScript 值（包括 undefined、thenable 或 promise）。

1.4. “exception” 是使用 `throw` 语句抛出的值。

1.5. “reason” 是一个值，表示 promise 被拒绝的原因。

## 2. 规则

### 2.1 Promise 的状态

promise 必须处于以下三种状态之一：pending，fulfilled 或 rejected。

2.1.1. 当 promise 处于 pending 状态时：

​	2.1.1.1. 可以转换到 fulfilled 或者 rejected 状态

2.1.2  当 promise 处于 fulfilled 状态时：

​	2.1.2.1. 不能转到任何状态。

​	2.1.2.2. 必须有一个不能改变的 value。

2.1.3  当 promise 处于 rejected 状态时：

​	2.1.3.1 不能转到任何状态。

​	2.1.3.2. 必须有一个不能改变的 reason。

这里的不能改变指的是全等（即`===`），不是深度全等（如果是对象只要引用全等即可）。

### 2.2. `then` 方法

一个 promise 对象一定要提供一个 `then` 方法来获取它当前的最终 value 或者 reason。

一个 promise 的 `then` 方法接受两个参数：

```js
promise.then(onFulfilled, onRejected)
```

2.2.1. `onFulfilled` 和 `onRejected`都是可选参数：

​	2.2.1.1. 如果 `onFulfilled` 不是一个函数，就必须忽略它。

​	2.2.1.2. 如果`onRejected`不是一个函数，就必须忽略它。

2.2.2. 如果 `onFulfilled` 是一个函数：

​	2.2.2.1. 它必须在 `promise` 状态变成 fulfilled 的时候调用它，`promise` 的 value 作为它的第一个参数。

​	2.2.2.2. 它在 `promise` 状态变成 fulfilled 之前一定不能调用。

​	2.2.2.3. 它不能被调用多次。

2.2.3. 如果 `onRejected` 是一个函数：

​	2.2.3.1. 它必须在 `promise` 状态变成 rejected 的时候调用它，`promise` 的 reason 作为它的第一个参数。

​	2.2.3.2. 它在 `promise` 状态变成 rejected 之前一定不能调用。

​	2.2.3.3. 它不能被调用多次。

2.2.4. 在[执行上下文堆栈](https://es5.github.io/#x10.3)仅包含平台代码之前，不能调用 `onFulfilled` 和 `onRejected`。[详见3.1]

2.2.5.  `onFulfilled` 和 `onRejected`必须作为函数调用（i.e 不能包含 `this` 变量）。[详见3.2]

2.2.6. `then` 方法可以在同一个 promise 中被调用多次

​	2.2.6.1. 如果/当 `promise` 状态为 fulfilled，所有相应的 `onFulfilled` 回调必须按照他们对 `then` 的原始调用的顺序执行。

​	2.2.6.2. 如果/当 `promise` 状态为 rejected，所有相应的 `onRejected` 回调必须按照他们对 `then` 的原始调用的顺序执行。

2.2.7. `then` 必须返回一个 promise。[详见3.3]

```js
promise2 = promise1.then(onFulfilled, onRejected);
```

​	2.2.7.1. 如果 `onFulfilled` 或 `onRejected` 返回一个值 `x`，则运行 promise 解决程序 `[[Resolve]](promise2, x)`

​	2.2.7.2. 如果 `onFulfilled` 或 `onRejected` 抛出一个异常 `e`，`promise2` 必须以 `e` 作为 reason 被 rejected。

​	2.2.7.3. 如果 `onFulfilled` 不是一个函数并且 `promise1` 的状态是 fulfilled，`promise2` 必须使用与 `promise1` 相同的 value 来进行fulfilled 操作。

​	2.2.7.4. 如果 `onRejected` 不是一个函数并且 `pormise1` 的状态是 rejected，`promise2` 必须使用与 `promise1` 相同的 reason 来进行rejected 操作。

### 2.3. promise 解决程序

promise 解决程序是一个抽象的操作，将 promise 和 value 作为输入，我们将其表示为 `[[Resolve]](promise2, x)`。如果 `x` 是 一个 thenable，它会尝试假设 `x` 的行为至少有一点像 promise，然后让 `promise` 采用 `x` 的状态，否则， `promise` 执行完成曹组并使用 `x` 作为它的值。

对 thenables 的这种处理允许 promise 实现相互用作，只要他们暴露一个符合 Promises/A+ 的 `then` 方法。它还允许 Pormises/A+ 实现使用合理的 `then` 方法“同化”不一致的实现

要运行 `[[Resolve]](promise2, x)`，请执行以下步骤：

2.3.1. 如果 `promise` 和 `x` 引用了同一个对象，则以 `TypeError` 作为 reason 拒绝。

2.3.2. 如果 `x` 是一个 promise，采用它的状态，[详见3.4]：

​	2.3.2.1. 如果 `x` 是 pending 状态，`promise` 必须保持 pending 状态直到 `x` fulfilled 或 rejected。

​	2.3.2.2. 如果/当 `x` 是 fulfilled 状态，使用同样的 value 履行 promise。

​	2.3.2.3. 如果/当 `x` 是 rejected 状态，使用同样的 reason 拒绝 promise。

2.3.3. 除此之外，如果 `x` 是一个对象或者函数，

​	2.3.3.1. 将 `then` 变成 `x.then`。[详见3.5]

​	2.3.3.2. 如果在检索 `x.then` 属性时候抛出异常 `e`，贼以 `e` 作为 reason 拒绝 `promise`。

​	2.3.3.3. 如果 `then` 是一个函数，则使用 `x` 作为 `this` 调用它，第一个参数是 `resolvePromise`，第二个参数是 `rejectPromise`，其中：

​		2.3.3.3.1. 如果/当使用 `y` 作为 value 调用  `resolvePromise` 时，则运行 `[[Resolve]](promise, y)`。

​		2.3.3.3.2. 如果/当使用 `r` 作为 reason 调用  `rejectPromise `时，则使用 `r` 拒绝 `promise`。

​		2.3.3.3.3. 如果同时调用 `resolvePromise` 和 `rejectPromise`，或者对同一个参数进行了很多次调用，则第一个调用优先，任何进一步的调用都将被忽略。

​		2.3.3.3.4. 如果调用 `then` 的时候抛出异常 `e`，

​			2.3.3.3.4.1. 如果 `resolvePromise` 和 `rejectPromise` 已经被调用了，忽略它。

​			2.3.3.3.4.2. 否则，使用 `e` 作为 reason 拒绝 `promise`。

​	2.3.3.4. 如果 `then` 不是一个函数，使用`x` 作为值解决 `promise`。

2.3.4. 如果 `x` 不是一个对象或者函数， 使用 `x` 作为值解决 `promise`。

如果一个 promise 是用参与循环 thenable 链的 thenable 解析的，这样 `[[Resolve]](promise, thenable)` 的递归性质最终会导致 `[[Resolve]](promise, thenable)` 再次被调用，上述算法会导致无限递归。鼓励但并不要求必须实现，在检测到这种递归的时候，使用丰富的 `TypeError` 作为 reason 拒绝 `promise`。[详见3.6]

## 3. 注释

3.1. 这里的”平台代码“指的是引擎，环境和 `promise` 实现代码。在实践中，这个规则确保 `onFulfilled` 和 `onRejected` 是在事件循环中`then` 被调用的之后，有一个新的调用栈的时候异步执行。这可以通过”宏任务“机制（例如 `setTimeout` 和 `setImmediate` ）或”微任务“机制（例如 `MutationObserver` 或 `process.nextTick`） 来实现。由于 promise 实现被认为是平台代码，它本身可能包含一个任务调度队列或 “trampoline” ，在其中调用处理程序。

3.2. 也就是说，在严格模式下，`this` 在它们内部是未定义的；在非严格模式下，`this` 是全局对象。

3.3. 实现可能允许 `promise2 === promise1`，前提是实现满足所有要求。 每个实现都应该记录它是否可以产生 `promise2 === promise1` 以及在什么条件下。

3.4. 一般来说，只有当 `x` 来自当前的实现时，才会知道 x 是一个真正的 promise。 该条款允许使用特定于实现的手段来采用已知符合 promise 的状态。

3.5. 这个首先存储对 `x.then` 的引用，然后测试该引用，然后调用该引用的过程避免了对 `x.then` 属性的多次访问。 这些预防措施对于确保访问器属性的一致性很重要，访问器属性的值可能会在检索之间发生变化。

3.6. 实现不应对 thenable 链的深度进行任何限制，并假设超出该限制递归将是无限的。 只有真正的循环才会导致 `TypeError`； 如果遇到无限的不同 thenable 链，则永远递归是正确的行为。

# 实现一个 Promise.all()

这个静态方法接受一个可迭代对象，返回一个新 promise。

- 只有在全部 promise 解决的时候才标记为解决
- 在一个 promise 拒绝的时候，就会拒绝
- 如果所有 promise 都解决，贼返回一个包含所有 promise 解决值的数组，按照迭代器的顺序
- 如果有一个 promise 拒绝，则会作为最终的拒绝理由，后续拒绝的 promise 不会再影响最终拒绝的理由。不过，在一个 promise 拒绝之后，不影响其它 promise 会正常执行。

```js
// 判断是否是可迭代对象
const isIterable = (obj) =>
  obj !== null && typeof obj[Symbol.iterator] === "function";

function promiseAll(promises) {
  // 返回一个新的promise
  return new Promise((resolve, reject) => {
    if (!isIterable(promises)) {
      // 抛出错误
      return reject(new Error("传入的对象必须是可迭代对象"));
    }

    let count = 0; // fulfilled的成功次数
    const res = []; // 结果数组
    const len = promises.length;
    if (len === 0) resolve(res); // 如果是空数组直接resolve出去

    for (let i = 0; i < len; i++) {
      const promise = promises[i];
      Promise.resolve(promise)
        .then((value) => {
          count++; // 成功次数加2
          res[i] = value; // 按索引存储结果

          // 全部promise fulfilled后调用resolve
          if (count === len) {
            resolve(res);
          }
        })
        .catch((e) => reject(e)); // 铺抓异常
    }
  });
}
```

测试：

```js
let p = promiseAll([Promise.resolve(3), Promise.resolve(), Promise.resolve(4)]);
p.then((values) => setTimeout(console.log, 0, values)); // [ 3, undefined, 4 ]

let p1 = promiseAll([
  Promise.resolve(3),
  Promise.reject(new Error("抛出错误")),
  Promise.resolve(4)
]);
p1.catch((e) => setTimeout(console.log, 0, e)); // Error: 抛出错误
```

# 实现promise结果的缓存

需求：当你要请求一个接口，接口返回数据是不变的，又不想将数据存在状态管理等中，可以在请求数据的时候缓存请求结果，下次再调用的时候就可以直接获取缓存数据而不需要再次发送请求。

```js
// 缓存
const cache = new Map();

// 定义一个装饰器函数，实现数据缓存
function enableCache(target, name, descriptor) {
  const oldFunc = descriptor.value; // 原函数

  // 修改新函数
  descriptor.value = async (...args) => {
    // 将函数名称和参数设置为缓存的key
    const cacheKey = name + JSON.stringify(args);

    // 如果缓存不存在
    if (!cache.get(cacheKey)) {
      // 执行原函数获取值
      const cacheValue = Promise.resolve(oldFunc(...args)).catch((_) => {
        cache.set(cacheKey, null); // 报错将值设置为null
      });
      cache.set(cacheKey, cacheValue); // 设置值
    }

    // 返回缓存的值
    return cache.get(cacheKey);
  };

  return descriptor;
}
```

使用方式：

```js
class User {
  // 在要缓存数据的地方加入@enableCache
  @enableCache
  static async getUserInfo() {
    // 模拟从服务器获取数据
    const res = await new Promise((resolve) => {
      console.log("获取数据中");
      setTimeout(() => {
        resolve({ name: "雮尘" });
      }, 500);
    });
    return res;
  }
}
```

测试代码：

```js
let res;

// 第一次调用
User.getUserInfo().then((value) => {
  res = value;
  console.log(value);
});

// 1s后再次调用
setTimeout(() => {
  User.getUserInfo().then((value) => {
    console.log(value);
    console.log(value === res);
  });
}, 1000);
```

不开启缓存的结果：

```js
获取数据中

// ...约500ms后
{ name: '雮尘' }

// ...约1500ms后
获取数据中
{ name: '雮尘' }
false
```

可以看到，没开启缓存，发起了两次请求

开启缓存结果：

```js
获取数据中

// ...约500ms后
{ name: '雮尘' }

// ...约1000ms后
{ name: '雮尘' }
true
```

开启缓存后，只发起了一次请求，后续请求直接从缓存获取数据

# 如何使用promise进行并发数量控制

使用`Promise.race`，传入一个 promise 数组，只要有一个 promise 返回结果，就作为最终结果返回。假设限制并发数量为`limit`条，每次并发`limit`条数据，在`Promise.race`返回结果的时候再推一条进去，继续`Promise.race`直到所有请求发送完。

```js
function limitFetch(urls, handler, limit) {
  const sequece = [].concat(urls); // 复制一下原数组
  let promises = []; // 请求队列

  // 切个limit个出来，封装一下
  promises = sequece.splice(0, limit).map((url, index) => {
    return handler(url).then(() => {
      // 执行完处理函数返回当前索引
      return index;
    });
  });

  // 使用race并发limit个请求
  let p = Promise.race(promises);

  // 剩余的请求
  for (let i = 0; i < sequece.length; i++) {
    p = p.then((index) => {
      // race出结果之后，promises队列推入一个新的处理函数
      promises[index] = handler(sequece[i]).then(() => {
        return index;
      });
      return Promise.race(promises);
    });
  }
}
```

测试数据：

```js
const urls = [
  {
    url: "url1",
    used: 1000
  },
  {
    url: "url2",
    used: 500
  },
  {
    url: "url3",
    used: 800
  },
  {
    url: "url4",
    used: 2000
  },
  {
    url: "url5",
    used: 2200
  }
];

function handler(url) {
  return new Promise((resolve) => {
    console.log(`发送请求 ${url.url} 开始`);
    setTimeout(() => {
      console.log(`发送请求 ${url.url} 完成`);
      resolve(url.url);
    }, url.used);
  });
}

limitFetch(urls, handler, 2);
```

测试结果：

```js
发送请求 url1 开始
发送请求 url2 开始
发送请求 url2 完成
发送请求 url3 开始
发送请求 url1 完成
发送请求 url4 开始
发送请求 url3 完成
发送请求 url5 开始
发送请求 url4 完成
发送请求 url5 完成
```

每次最多同时有两个开始，等待完成之后，才会有新的开始。