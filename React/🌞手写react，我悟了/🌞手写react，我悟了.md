# 🌞手写react，我悟了

文章内容

- 仿照源码实现react的初始化渲染和更新功能

步骤

- [step0: 准备工作](#step0：准备工作)

- step1：实现`createElement`函数

- step2：实现`render`函数

- step3：并发模式

- step4：加入Fibers

- step5：提交和渲染Fiber

- step6：加入协调算法

- step7：加入函数组件渲染支持

- step8：实现`useState`hook

源码地址：https://github.com/wcly/my-react2



## 初始化项目

使用[`create-react-native`](https://www.npmjs.com/package/create-react-app)脚手架创初始化一个项目

运行`npx create-react-native myReact`创建一个项目

在React中使用jsx语法

```js
const element = <h1 title="foo">Hello</h1>
```

babel在编译的时候会转换成

```js
const element = React.createElement("h1", { title: 'foo' }, 'hello world')
```

因此，这就是为什么平时开发的时候，明明没有使用`React`，却要引入，不然就会报错

```js
import React from 'react'
```

然而，在React17中优化这个问题，用户不需用手动导入`react`，它在内部babel编译jsx的时候自动引入，而且在babel转换jsx的时候不再使用`React.createElement`函数，使用的是[`jsx`](https://github.com/reactjs/rfcs/blob/createlement-rfc/text/0000-create-element-changes.md#detailed-design)函数

```js
import {jsx} from "react";

function Foo() {
  return jsx('div', ...);
}
```



**为了保持统一**

如果下载的是React17的版本:point_down:

```json
// package.json
"react": "^17.0.1",
"react-dom": "^17.0.1",
"react-scripts": "4.0.0",
```

需要先运行`yarn eject`命令弹出配置，这个时候babel还是会将jsx转换为`React.createElement`



## [step0：准备工作](https://github.com/wcly/my-react2/tree/main)

**现在，让我们开始开发一个`React`**

这是原来react的写法

```js
// src\index.js
import React from "react";
import ReactDOM from "react-dom";

const element = <h1 title="foo">Hello</h1>
const container = document.getElementById("root")
ReactDOM.render(element, container)
```

在经过babel转换jxs后

```js
// src\index.js
import React from "react";
import ReactDOM from "react-dom";

const element = React.createElement("h1", { title: 'foo' }, 'hello world')
const container = document.getElementById("root")
ReactDOM.render(element, container)
```

经babel转码jsx后，传递给createElement的第一个参数为type，第二参数为props，剩余参数作为children

打印一下element

```js
console.log(element);
```

![image-20201121092716377](./images/elemnt.png)

**简单的理解，createElement的作用根据用户编写的jsx生成一个虚拟dom树**

再来看看`ReactDOM.render`方法，这里的render方法，不难看出，这里就是将createElement返回的虚拟dom树渲染成真实的dom，并添加到容器root下

下面我们将``ReactDOM.render`方法`换成自己的代码

```js
// src\index.js
import React from 'react'

const element = React.createElement("h1", { title: 'foo' }, 'hello world')

const container = document.getElementById("root")

const node = document.createElement(element.type)
node['title'] = element.props.title
const text = document.createTextNode('')
text['nodeValue'] = element.props.children
node.appendChild(text)
container.appendChild(node)
```



## [step1: 实现`createElement`函数](https://github.com/wcly/my-react2/tree/step1)

实现`createElement的`代码

```js
// src\myReact\index.js
import { TEXT_ELEMENT } from './const'

/**
 * 创建react元素
 * @param {*} type 类型 
 * @param {*} props 属性
 * @param  {...any} children 子节点
 */
function createElement(type, props, ...children) {
    return {
        type,
        props: {
            ...props,
            children: children.map(child =>
                typeof child === 'object'
                    ? child
                    : createTextElement(child)
            ),
        }
    }
}

/**
 * 创建文本元素
 * @param {*} text 文本
 */
function createTextElement(text) {
    return {
        type: TEXT_ELEMENT,
        props: {
            nodeValue: text,
            children: []
        }
    }
}

const React = {
    createElement
}

export default React
```

修改一下我们的例子，使用自己写的`React.createElement`转换jsx

```js
// src\index.js
import React from './myReact'

const element = (
    <div id="foo">
        <a>bar</a>
        <b />
    </div>
)
console.log(element)

const container = document.getElementById("root")

const node = document.createElement(element.type)
node['title'] = element.props.title
const text = document.createTextNode('')
text['nodeValue'] = element.props.children
node.appendChild(text)
container.appendChild(node)
```

打印一下`element`

![image-20201121092716377](./images/my-elemnt.png)

返回的数据主要关注

```js
{
    type: "div", // 节点类型
    // 属性
    props:{
        id: 'foo', // attr
        children: [...], // 子节点，这里是a标签和b标签
    }
}
```



## [step2: 实现`render`函数](https://github.com/wcly/my-react2/tree/step2)

下面，我们将原来的渲染函数抽出来，加以改造

```js
// src\index.js
import React from './myReact'
import ReactDOM from './myReact/ReactDOM'


const element = (
    <div id="foo">
        <a>bar</a>
        <b />
    </div>
)
console.log(element)

const container = document.getElementById("root")

ReactDOM.render(element, container)
```

实现自己的render函数

```js
// src\myReact\ReactDOM.js
import { TEXT_ELEMENT } from "./const"

/**
 * 渲染函数，将vdom转为dom
 * @param {*} element react元素
 * @param {*} container dom容器
 */
function render(element, container) {
    // 创建dom结点
    const dom = element.type === TEXT_ELEMENT
        ? document.createTextNode('')
        : document.createElement(element.type)

    // 将props分配给结点
    const isProperty = key => key !== 'children'
    Object.keys(element.props)
        .filter(isProperty)
        .forEach(name => {
            dom[name] = element.props[name]
        })

    // 递归遍历子元素
    element.props.children.forEach(child => render(child, dom))

    // 添加子元素
    container.appendChild(dom)
}

const ReactDOM = {
    render
}

export default ReactDOM
```



## [step3：并发模式](https://github.com/wcly/my-react2/tree/step3)

按找上面的渲染方式，当需要渲染的元素多的时候，在一帧（16.6ms）内无法渲染完毕就会造成浏览器的卡顿。

要想个办法优化，在React中，选择的是把一个大的任务才分成很多小的任务，在浏览器空闲的时候执行每个小的任务。这就是React的**并发模式**。

上图，看图理解👇，占用浏览器的时间被分成了很多小的单元，这样就可以让浏览器优先执行优先级更高的任务（如：用户输入，点击等操作的响应）

![image-20201122163543380](./images/concurrent-mode.png)

:heavy_exclamation_mark:这里使用到一个API：[requestIdleCallback](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/requestIdleCallback#Browser_compatibility)

这个函数会在每次浏览器空闲的时候调用，这个函数接受一个回调函数，函数会接受一个`IdeDeadline`的参数，可以使用`IdeDeadline.timeRemaining()`获取预估的剩余空闲时间毫秒数。

```js
// 下一个浏览器空闲时间要执行的任务
let nextUnitOfWork = null

function workLoop(deadline) {
    let shouldYield = false // 是否阻塞执行任务
    while (nextUnitOfWork && !shouldYield) {
        // 执行任务
        nextUnitOfWork = performUnitOfWork(
            nextUnitOfWork
        )
        // 剩余空闲时间不足一毫秒的时候暂停执行
        shouldYield = deadline.timeRemaining() < 1
    }
    requestIdleCallback(workLoop)
}

// 浏览器处于空闲的时候会调用
requestIdleCallback(workLoop)

function performUnitOfWork(nextUnitOfWork){
    // TODO
}
```



## [step4：加入Fibers](https://github.com/wcly/my-react2/tree/step4)

为组织拆分成多个单元的任务，需要一种数据结构，React在这里使用一种叫**Fiber**的数据结构，React给每一个节点分配一个fiber节点，形成fiber树，可以理解为虚拟dom。

**每次执行一个单元的任务就是执行生成一个fiber节点**。

为后续更高效的找到下一个单元的任务，React将fiber的数据结构设计成如下的样子：

- 有一个`parent`，指向自己的父节点
- 有一个`child`，指向自己的第一个孩子节点
- 有一个`sibing`，指向下一个同级的兄弟节点

假设现在要渲染的jsx结构是这样的：

```jsx
React.render(
  <div>
    <h1>
      <p />
      <a />
    </h1>
    <h2 />
  </div>,
  container
)
```

按照我们的例子，生成的fiber树就是下面这个样子的👇

![image-20201122163543380](./images/fiber-tree.png)

在生成的Fiber树的时候，遵循如下规则：

1. 先找第一个孩子节点，找到则返回
2. 找不到孩子节点，找同级兄弟节点
3. 找不到同级兄弟节点，回父节点，找父节点的兄弟节点
4. 父节点的兄弟节点也没有，再往上找爷爷的兄弟节点
5. 直到找到根节点，就完成本次渲染的所有工作

下面来看看代码怎么写：

首先给`nextUnitOfWork`赋值为渲染的根节点，这样在浏览器空闲的时候就会执行`workLoop`方法👇

```js
// src\myReact\ReactDOM.js
/**
 * 渲染函数
 * @param {*} element react元素
 * @param {*} container dom容器
 */
function render(element, container) {
    // 设置nextUnitOfWork为根fiber结点
    nextUnitOfWork = {
        dom: container,
        props: {
            children: [element],
        }
    }
}

function workLoop(deadline) {
    let shouldYield = false // 是否阻塞执行任务
    while (nextUnitOfWork && !shouldYield) {
        // 执行任务
        nextUnitOfWork = performUnitOfWork(
            nextUnitOfWork
        )
        // 剩余空闲时间不足一毫秒的时候暂停执行
        shouldYield = deadline.timeRemaining() < 1
    }
    requestIdleCallback(workLoop)
}

// 浏览器处于空闲的时候会调用
requestIdleCallback(workLoop)
```

然后再完成`performUnitOfWork`函数👇，分为三步：

1. 根据DOM节点，添加到页面，并使用`fiber.dom`存起来
2. 取出children数组，将每个child转换为fiber结点
3. 返回下一个要渲染的fiber节点

```js
// src\myReact\ReactDOM.js
function performUnitOfWork(fiber) {
    console.log('current render fiber', fiber)
    // 1. 添加dom结点
    if (!fiber.dom) {
        fiber.dom = createDom(fiber)
    }
    if (fiber.parent) {
        fiber.parent.dom.appendChild(fiber.dom)
    }

    // 2. 将每个child转换为fiber结点
    const elements = fiber.props.children
    let index = 0
    let prevSibling = null
    while (index < elements.length) {
        const element = elements[index]
        const newFiber = {
            type: element.type,
            props: element.props,
            parent: fiber,
            dom: null
        }
        // 第一个child结点
        if (index === 0) {
            fiber.child = newFiber
        } else {
            prevSibling.sibling = newFiber
        }

        prevSibling = newFiber
        index++
    }

    // 3. 返回下一个要渲染的fiber结点
    // 找child结点
    if (fiber.child) {
        return fiber.child
    }
    let nextFiber = fiber
    while (nextFiber) {
        // 找兄弟结点
        if (nextFiber.sibling) {
            return nextFiber.sibling
        }
        // 往父节点找
        nextFiber = nextFiber.parent
    }
}
```

`console.log('current render fiber', fiber)`打印结果如下：

![image-20201122163543380](./images/current-render-fiber.png)

> 补充：`createDom`函数

```js
// src\myReact\ReactDOM.js
/**
 * 将fiber结点转换为真实DOM结点
 * @param {*} fiber fiber结点
 */
function createDom(fiber) {
    const dom =
        fiber.type === TEXT_ELEMENT
            ? document.createTextNode("")
            : document.createElement(fiber.type)

    const isProperty = key => key !== "children"
    Object.keys(fiber.props)
        .filter(isProperty)
        .forEach(name => {
            dom[name] = fiber.props[name]
        })

    return dom
}
```

最后再来回顾一下完整的**fiber**的结构

```js
{
	parent: null, //父节点
	sibling: null, // 下一个兄弟节点
	child: null, // 第一子节点
	dom： null, // 真实dom节点
	type: null, // 节点类型
	props: null, // 属性
}
```

