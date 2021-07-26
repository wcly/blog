### 迭代器（iterator）
简单来说，迭代器（iterator）就是一个满足一定规则的对象。

规则：如果一个对象中含有一个`next`方法，`next`方法中返回一个对象，其中中包含两个属性`value`、`done`，那么这个对象就是一个迭代器。

如下代码就是一个迭代器：

```js
//生成随机数的迭代器
let iterator = {
    total: 2,
    i: 1,
    next(){
        let obj = {
            value: this.i > this.total ? undefined : Math.random(), //下一个数据的值
            done: this.i > this.total, //是否还有下一个数据
        }
        this.i++;
        return obj;
    }
}
```

执行方式，调用`next`函数

```js
console.log(iterator.next()) //{value: 1, done: false}
console.log(iterator.next()) //{value: 2, done: false}
console.log(iterator.next()) //{value: undefined, done: true}
```

遍历迭代器数据

```js
let next = iterator.next();

while(!next.done){
    console.log(next.value);
    next = iterator.next();
}
```

### 迭代器创建函数（iterator creator）
一个返回迭代器对象的函数。

```js
function createIterator(total = 2){
    let i = 1;
    return {
        next(){
            let obj = {
                value: i > total ? undefined : Math.random(), //下一个数据的值
                done: i > total, //是否还有下一个数据
            }
            i++;
            return obj;
        }
    }
}

const iterator = createIterator(5)
```

将一个数组改成迭代模式：

```js
function createArrIterator(arr){
    let i = 0;
    return {
        next(){
            let obj = {
                value: arr[i++],
                done: i > arr.length
            }
            return obj;
        }
    }
}

const iterator = createArrIterator([3, 4,5, 23, 4, 6, 34]);
```

### 迭代协议
只有满足迭代协议的对象才能使用`for of`遍历，否则就会报错。

```js
const obj = {}

for(const i of obj){
    console.log(i) // "Uncaught TypeError: obj is not iterable"
}
```

如果想使用`for of`遍历`obj`，只要将`obj`改造成满足可迭代协议的对象即可。

**迭代协议**：满足可迭代协议的对象要有一个符号属性`(Symbol.iterator)`，属性的值是一个无参的**迭代器创建函数**。如下所示：

```js
//obj加入[Symbol.iterator]属性后可被迭代
const obj = {
    [Symbol.iterator]: (total = 2) => { //迭代器创建函数
        let i = 1;
        return {
            next() {
                let obj = {
                    value: i > total ? undefined : Math.random(), //下一个数据的值
                    done: i > total, //是否还有下一个数据
                }
                i++;
                return obj;
            }
        }
    }
}

for(const i of obj){
    console.log(i); // 不报错
}
```

> `Array`、`Map`、`Set`可以使用`for of`遍历，是因为他们的原型上都有符号属性`(Symbol.iterator)`

#### for of执行原理
实际上`for of`遍历可迭代对象时，就是运行该对象上的`Symbol.iterator`属性，然后调用迭代器的`next`方法直到`done`属性是`true`位置。

```js
const obj = {
    [Symbol.iterator]: (total = 2) => {
        let i = 1;
        return {
            next() {
                let obj = {
                    value: i > total ? undefined : Math.random(), //下一个数据的值
                    done: i > total, //是否还有下一个数据
                }
                i++;
                return obj;
            }
        }
    }
}


for(const i of obj){
    console.log(i); // 不报错, i实际上就是迭代器next方法返回对象里面的value属性
}

//for of 代码相当于如下代码：
const iterator = obj[Symbol.iterator]();
let item = iterator.next();
while(!item.done){
    const i = item.value;
    console.log(i) //执行for of中的代码
    item = iterator.next()
}
```

### 生成器 generator
由构造函数`Generator`创建的对象，创建的对象是一个迭代器，也满足可迭代协议。

> Generator构造函数是浏览器内置的，开发者无法使用。

```js
//伪代码
const generator = new Generator();

//generator的内部大概是这样的：
generator = {
    next(){...}, //具有next函数
    [Symbol.iterator](){...}, //具有(Symbol.iterator)属性
}
```

### 生成器创建函数（generator function）
开发者无法直接调用`Generator`创建生成器，只能使用生成器创建函数创建一个生成器。

生成器函数定义：只要`function`关键字和函数名之间加入一个`*`，该函数就是生成器函数，会返回一个生成器。


```js
function *createGenerator(){}

const generator = createGenerator(); //得到一个生成器

console.log("next" in generator); //true
console.log(Symbol.iterator in generator); //true
console.log(generator.next === generator[Symbol.iterator]().next); //true
```

#### `yield`关键字
写在生成器内部，相当于暂停，配合`next`方法可以在生成器外部控制生成器函数内部代码的执行。
1. `yield`关键字只能在生成器内部使用；
2. 每次调用生成器的`next`方法后，代码会从上一个`yield`执行到下一个`yield`；
3. 如果没有生成器函数内部没有`yield`关键字，则里面的代码一行都不会执行；
4. `return`返回的值作为`next`方法的`done`**第一次为**`true`时的`value`值；
5. `yield`关键字后面的值会当做执行`next`方法时返回的`value`值；
5. `yield`关键字表达式返回的值等于执行`next`方法时传入的参数。

举个例子：大家最好使用浏览器，手动调用`generator.next()`，一步一步看比较容易理解。
```js
function* createGenerator() {
    let res;
    console.log("开始", res);
    
    res = yield 1; //将第2个next传入的参数作为返回值赋值给res

    console.log("打印1", res);
    
    res = yield 2; //将第3个next传入的参数作为返回值赋值给res
    
    console.log("打印2", res);
    
    return "结束"
}

const generator = createGenerator();
let result = generator.next();
console.log("调用第1次next的返回值：", result);

result = generator.next(result.value);
console.log("调用第2次next的返回值：", result);

result = generator.next(result.value);
console.log("调用第3次next的返回值：", result);

result = generator.next(result.value);
console.log("调用第4次next的返回值：", result);

//输出：
开始 undefined
调用第1次next： { value: 1, done: false }
打印1 1
调用第2次next： { value: 2, done: false }
打印2 2
调用第3次next： { value: '结束', done: true }
调用第4次next： { value: undefined, done: true }
```

##### 利用生成器函数将异步代码转化为同步代码：

```js
/**
 * 模拟一个请求
 */
function getData() {
    return new Promise(resolve => {
        setTimeout(() => {
            resolve('数据');
        }, 2000)
    })
}

/**
 * 生成器函数，在这里写业务逻辑，可以将异步代码的写法转化为同步代码写法
 */
function* task() {
    console.log('获取数据中...');
    let result = yield getData(); //将异步代码转化为同步的写法
    console.log('得到数据：', result);
    //对数据进行后续处理...
}

/**
 * 运行生成器的通用函数
 */
function run(generatorFunc) {
    const generator = generatorFunc();
    next();

    function next(nextValue) {
        let result = generator.next(nextValue)
        if (result.done) { //迭代结束
            return;
        } else {
            const value = result.value;
            if (value instanceof Promise) {
                value.then(data => next(data));
            } else {
                next(value);
            }
        }
    }
}

run(task); //执行生成器函数代码
// 获取数据中...
// 得到数据： 数据
```
