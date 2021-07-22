## 导读

此文比较适合想要优化`React`项目，却不知道如何下手的人阅读。介绍了常见的调试工具和优化手段以及整个优化的思考过程。

## 背景

最近在工作中遇到了一些`React`的性能问题。

需求点击一个添加商品按钮，将商品添加商品到购物车，然后商品数量延迟了将近1s才变化。在经过一系列的优化之后，将渲染次数从20次优化到4次，渲染时间也降到了毫秒级。

在此期间，学习到一些`React`函数组件的调试和优化技巧（自从用了`hook`再没用过类组件，真香😄）。故想写篇水文记录并分享一下此次优化的心路历程。

## 正文

这里我们用`TodoList`的例子🌰作为基础，然后一步步通过调试工具，查找可以优化的点，再一步步优化。

**首先，使用[Create-React-App](https://create-react-app.dev/docs/getting-started/#selecting-a-template)创建一个简单的项目：**

```shell
npx create-react-app react-optimize-practice --template typescript
```

**然后，写个简单的`TodoList`，层级结构如下：**

![image-20210715173451106](https://i.loli.net/2021/07/15/d2sS6EHpaWh9wyo.png)

代码如下：

`TodoList.tsx`

```tsx
import { FC } from "react";
import { useState } from "react";
import TodoInput from "./TodoInput";
import TodoItem from "./TodoItem";

type TodoItemType = {
  id: number;
  text: string;
  isComplete: boolean;
};

const TodoList: FC = () => {
  const [todoList, setTodoList] = useState<TodoItemType[]>([]);

  const handleAddItem = (text: string) => {
    if (!text) return;
    setTodoList((preTodoList) => {
      return [
        ...preTodoList,
        { text, isComplete: false, id: +new Date() },
      ];
    });
  };

  return (
    <div>
      <TodoInput onAddItem={handleAddItem} />
      <ul>
        {todoList.map((item) => {
          return (
            <TodoItem
              key={item.id}
              text={item.text}
              isComplete={item.isComplete}
            />
          );
        })}
      </ul>
    </div>
  );
};

export default TodoList;
```

`TodoInput.tsx`

```tsx
import { FC, useState } from "react";

type Props = {
  onAddItem: (text: string) => void;
};

const TodoInput: FC<Props> = ({ onAddItem }) => {
  const [text, setText] = useState('');

  const handleAdd = () => {
    onAddItem(text);
  };

  return (
    <div>
      <input value={text} onChange={(e) => setText(e.target.value)} />
      <button onClick={handleAdd}>add</button>
    </div>
  );
};

export default TodoInput;
```

`TodoItem.tsx`

```tsx
import { FC } from "react";

type Props = {
  text: string;
  isComplete: boolean;
};

const TodoItem: FC<Props> = ({ text, isComplete }) => {
  return (
    <li>
      <button>x</button>
      <input type="checkbox" checked={isComplete} />
      <span>{text}</span>
    </li>
  );
};

export default TodoItem;
```

**页面效果**

![image-20210716171348531](https://i.loli.net/2021/07/16/zeDAfEVc2J8FoHn.png)

[完整代码](https://gitee.com/wcly/react-optimize-practice/tree/base/)

### React Developer Tools

#### 安装

这里我们先来介绍一款用来调试`React`项目的Chrome插件，下载地址：[React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi)

需要翻墙，如果翻不了墙的话，用新版的Edge也行：[Microsoft Edge 加载项 - react developer tools](https://microsoftedge.microsoft.com/addons/search/react developer tools?hl=zh-CN)

#### 使用

现在我们使用`React Developer Tools`查看渲染时间和次数。

进行如下操作：

1. 点击`React Developer Tools`插件中的`Profiler`功能的录制按钮，开始记录，按钮会变成红色的

   ![image-20210716171538311](https://i.loli.net/2021/07/16/7HOfhcyQe5bztvu.png)

2. 在输入框输入一个字符

   ![image-20210716171843127](https://i.loli.net/2021/07/16/ELyr8ZgGTR5Qbwl.png)

3. 点击`add`按钮，将输入内容添加到`TodoList`中

![image-20210716171806350](https://i.loli.net/2021/07/16/QHVLgR5xS2OczkD.png)

4. 再点击一下录制按钮，结束录制

开始查看数据

![image-20210716172426334](https://i.loli.net/2021/07/19/4CPtqYb16yEmRTX.png)

每个部分的含义：

1. 当前选择的tab是火焰图模式；
2. `1/2`代表，录制期间总共触发了2次渲染，当前看的是第一次渲染的数据；柱子也是两条，和渲染次数一样，蓝色是当前选中的渲染，柱子高低代表渲染时间；
3. 灰色的代表没有渲染的组件，如`App`、`TodoList`；有颜色代表有渲染的组件，绿色代表渲染时间很快，如果渲染很慢的话可能是黄色或红色的（此时就可以重点关注）；可以点击对应的组件查看详细渲染数据；
4. 当前选中组件的详细渲染数据，点击框框“3”内的组件可以切换组件。

再来看看另一个标签页的内容

![image-20210719095009176](https://i.loli.net/2021/07/19/LFNbVxPvUD6hlTs.png)

这里其它部分都一样，只是下面的组件渲染火焰图变成按组件渲染时间排序图（按渲染时长倒序排序），没有渲染的组件不显示，这个组件排行图比较适合直接找到渲染时长最长的组件。

#### 问题排查

点击查看第二次渲染的信息

![image-20210719094432365](https://i.loli.net/2021/07/19/w8a2JHCUpsu9oRD.png)

通过上面的第一次渲染的图和第二次渲染的图可以得出如下信息：

- 在第一次渲染中
  - `TodoInput`触发渲染
- 在第二次渲染中
  - `TodoList`触发渲染
  - `TodoInput`触发渲染
  - `TodoItem`触发渲染

#### 优化

优化可以从下列两个角度出发

- 一是减少渲染次数
- 二是减少每次渲染的渲染总时间（减少组件渲染时长）

这里进行了两次操作，所以渲染次数为两次，从渲染次数的角度出发已经没有优化空间了，所以这里主要考虑如何减少渲染总时长

分析：

1. 第一次渲染是因为在输入框输入一个字符`a`，`TodoInput`中的`state`发生变化，触发重新渲染，这里没什么问题。
2. 第二次渲染是因为点击了`add`按钮，将数据添加到`TodoList`中，由于新增一条数据，所以`TodoList`触发重新渲染，`TodoItem`也触发重新渲染，这里没什么问题，但是奇怪的是，为什么`TodoInput`也触发从新渲染呢？

这里引申出一个问题：什么会触发`React`组件重新渲染？

> 答：`state`变化或`props`变化

`TodoInput`触发重新渲染无非就是上述两种情况，在第二次渲染中，`state`明显是没有变化的，那么变化的就只能是`props`，从父组件`TodoList`传入的`props`只有一个：`onAddItem`

其实，在函数组件每次重新渲染的时候，相当于重新调用了一遍。所以当`TodoList`重新渲染的时候，`handleAddItem`是重新生成的，相当于给`TodoInput`组件传入一个新的`onAdd`方法。那么有没有办法将`handleAddItem`缓存起来，保证每次传给`TodoInput`的`props`都相同？这样就可以不用渲染`TodoInput`，从而减少第二次渲染的总时长。

> 答案是肯定的，React提供了一个叫`useCallback`的`hook`可以将函数缓存起来。

### useCallback

[想看useCallback官方文档解释戳我](https://zh-hans.reactjs.org/docs/hooks-reference.html#usecallback)

用法

- `useCallback`是一个函数，返回一个新的函数；
- 第一个参数传入你要缓存的函数；
- 第二个参数是个数组，表示依赖项数组，当依赖项数组变化后`useCallback`会返回新的函数，如果没有依赖项，写个空数组即可。

我们改造一下原来的代码

```js
// TodoList.tsx
import { useCallback } from "react";

const handleAddItem = useCallback((text: string) => {
  if (!text) return;
  setTodoList((preTodoList) => {
    return [...preTodoList, { text, isComplete: false, id: +new Date() }];
  });
}, []);
```

现在再重新测试一下，然后你会发现并没有什么变化，`TodoInput`还是渲染了

Why？？？

![黑人问号 - 一大波黑人问号即将来袭_黑人问号_群聊表情](http://wx3.sinaimg.cn/bmiddle/006Cmetyly1ff16b3zxvxj308408caa8.jpg)

> 原因就是，虽然这里确实通过`useCallback`保证`handleAddItem`的引用不变，但是`TodoInput`并没有根据这个比较需不需要重新渲染，这个时候就需要使用React提供的`memo`函数

[完整代码](https://gitee.com/wcly/react-optimize-practice/tree/useCallback/)

### React.memo

[想看React.memo官方文档解释戳我](https://zh-hans.reactjs.org/docs/react-api.html#reactmemo)

对函数组件的`props`进行比较，如果`props`不变，不进行渲染。

用法

- `memo`是一个高阶组件，返回一个新组件，是函数组件版的`PureComponent`；
- 第一个参数是要进行包装的组件；

- 第二个参数是一个比较函数，不传默认对`props`进行浅比较。

改造一下原来的代码

```tsx
import { FC, memo } from "react";

type Props = {
  onAddItem: (text: string) => void;
};

const TodoInput: FC<Props> = ({ onAddItem }) => {
  //...略
};

export default memo(TodoInput);
```

测试结果：

![image-20210719112556626](https://i.loli.net/2021/07/19/MYj26CWraoVBdHh.png)

 这个时候我们会发现，`TodoInput`是灰色的，并且多了个`Memo`的标记，代表`TodoInput`因为`Memo`的比较没有触发渲染。

以上就是对`TodoList`渲染时间的优化的全过程，有两个点需要注意一下

1. `memo`和`useCallback`需要同时使用，否则不会生效（我真的看到过只写`useCallback`的代码-_-||）；
2. `memo`用在子组件，`useCallbak`用在父组件，不要搞混了。

> React还提供了[useMemo](https://zh-hans.reactjs.org/docs/hooks-reference.html#usememo)对其它类型的数据进行缓存，用法和`useCallback`一致，但是可以返回任何值，`useCallback`只能返回函数，是`useMemo`的子集。

[完整代码](https://gitee.com/wcly/react-optimize-practice/tree/React.memo/)

### why-did-you-render

下面给大家介绍另一个很好用的调试工具：https://github.com/welldone-software/why-did-you-render

这个库可以打印出每一个操作组件重新渲染的原因，所以很适合在`hook`使用的很多的组件中，查找渲染原因的时候使用。

#### 安装

```shell
yarn add --dev @welldone-software/why-did-you-render
```

or

~~~shell
npm install @welldone-software/why-did-you-render --save-dev
~~~

创建一个新文件`/src/wdyr.ts`

```ts
/// <reference types="@welldone-software/why-did-you-render" />
import React from "react";

// 不要在生成环境打开，会影响性能
if (process.env.NODE_ENV === "development") {
  const whyDidYouRender = require("@welldone-software/why-did-you-render");
  whyDidYouRender(React, {
    trackAllPureComponents: true, // 跟踪所有纯组件(React.PureComponent or React.memo)
  });
}
```

然后在`index.tsx`导入

```tsx
import './wdyr'; // <--- 在第一行导入
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);
```

#### 调试

进行一样的步骤，输入一个字符然后点击添加按钮，打开控制台，发现了一个错误

![image-20210719145900730](https://i.loli.net/2021/07/19/snTNhLZSizvGokM.png)

这是一个`React`错误，之前写的代码有点，受控组件没有加`onChange`事件，这里先完善一下，`TodoItem`中`checkbox`的改变函数由`TodoList`传入。

```tsx
// TodoItem.tsx
import { ChangeEventHandler, FC } from "react";

type Props = {
  text: string;
  isComplete: boolean;
  onCheckboxChange: (checked: boolean) => void;
};

const TodoItem: FC<Props> = ({ text, isComplete, onCheckboxChange }) => {
  const handleCheckboxChange: ChangeEventHandler<HTMLInputElement> = (e) =>
    onCheckboxChange(e.target.checked);

  return (
    <li style={{ display: "flex", flexDirection: "row", alignItems: "center", paddingBottom: 5 }}>
      <input
        type="checkbox"
        checked={isComplete}
        onChange={handleCheckboxChange}
      />
      <span style={{marginLeft: 5}}>{text}</span>
      <button style={{marginLeft: 5}}>x</button>
    </li>
  );
};

export default TodoItem;
```

```tsx
// TodoList.tsx
import { FC, useCallback } from "react";
import { useState } from "react";
import TodoInput from "./TodoInput";
import TodoItem from "./TodoItem";

type TodoItemType = {
  id: number;
  text: string;
  isComplete: boolean;
};

const TodoList: FC = () => {
  const [todoList, setTodoList] = useState<TodoItemType[]>([]);

  const handleAddItem = useCallback((text: string) => {
    if (!text) return;
    setTodoList((preTodoList) => [
      ...preTodoList,
      { text, isComplete: false, id: +new Date() },
    ]);
  }, []);

  const handleChangeBox = (id: number) => (checked: boolean) => {
    setTodoList((preTodoList) =>
      preTodoList.map((item) =>
        item.id === id ? { ...item, isComplete: checked } : item
      )
    );
  };

  return (
    <div>
      <TodoInput onAddItem={handleAddItem} />
      <ul style={{ margin: 10, padding: 0 }}>
        {todoList.map((item) => {
          const { id, text, isComplete } = item;
          return (
            <TodoItem
              key={id}
              text={text}
              isComplete={isComplete}
              onCheckboxChange={handleChangeBox(id)}
            />
          );
        })}
      </ul>
    </div>
  );
};

export default TodoList;
```

改完发现并`wdyr`没有打印渲染原因，查文档发现用`Create React App (CRA) ^4` 创建的项目会有个[问题](https://github.com/welldone-software/why-did-you-render/issues/154)，尝试过按照官网的提示修改，无果。如有大佬知道什么问题，麻烦告知小弟一声。

好在，这只是全局设置的打印没有效果，组件内配置的还是可以的，现在给每个组件都添加上`wdyr`的配置，表示要监听渲染触发打印触发原因。

```tsx
// TodoInput.tsx
import { ChangeEventHandler, FC, memo, useState } from "react";

type Props = {
  onAddItem: (text: string) => void;
};

const TodoInput: FC<Props> = ({ onAddItem }) => {
  //...略
};

TodoInput.whyDidYouRender = {
  logOnDifferentValues: true,
}

export default memo(TodoInput);
```

其它组件配置也一样，这里就不贴代码了。

然后重新操作一遍，然后就可以看到控制台的输出了

![image-20210719183104177](https://i.loli.net/2021/07/19/glpQys6oWEwXPVO.png)

这里可以很清楚的看到什么组件因为什么原因触发了重新渲染。

[完整代码](https://gitee.com/wcly/react-optimize-practice/tree/why-did-you-render/)

### 函数组件使用React-Redux的坑

为了挖这个坑，啊，不对，为了复现这个问题，我们先把代码改造一下。

**引入[react-redux](https://react-redux.js.org/)等库**

```shell
yarn add react-redux
yarn add -D @types/react-redux
yarn add @reduxjs/toolkit
```

[@reduxjs/toolkit](https://redux-toolkit.js.org/)一个工具库，写起来有点像`dva`，但是对`Typescript`的支持比`dva`好，`dva`已经很久没有维护了，下面代码使用了`@reduxjs/toolkit`编写。

**使用`createSlice`创建一个`todoList.ts`**

```ts
// src/model/todoList.ts
import { createSlice, PayloadAction } from "@reduxjs/toolkit";

export type TodoItemType = {
  id: number;
  text: string;
  isComplete: boolean;
};

interface TodoListState {
  data: TodoItemType[];
}

const initialState: TodoListState = {
  data: [],
};

// createSlice相当于dva的创建一个model
export const todoListSlice = createSlice({
  name: "todoList", // 命名空间
  initialState, // 初始值
  reducers: {
    // 往todoList添加一项
    add: (state, action: PayloadAction<string>) => {
      // 可以直接改变state，因为@reduxjs/toolkit用了Immer库 
      state.data.push({
        id: +new Date(),
        isComplete: false,
        text: action.payload,
      });
    },
    // 删除todoList的一条内容
    remove: (state, action: PayloadAction<number>) => {
      state.data.filter((item) => item.id !== action.payload);
    },
    // 更新todoList的一条内容
    update: (state, action: PayloadAction<TodoItemType>) => {
      state.data = state.data.map((item) =>
        item.id === action.payload.id ? action.payload : item
      );
    },
  },
});

// 导出actions
export const { add, remove, update } = todoListSlice.actions;

export default todoListSlice.reducer;
```

**创建仓库**

```ts
// src/model/index.ts
import { configureStore } from "@reduxjs/toolkit";
import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";
import todoListReducer from "./todoList";

const store = configureStore({
  reducer: {
    todoList: todoListReducer,
  },
});

// 从store本身推断出RootState类型
type RootState = ReturnType<typeof store.getState>;
// 从store本身推断出AppDispatch类型: {todoList: TodoListState}
type AppDispatch = typeof store.dispatch;

// 在app中使用加入了类型的useDispatch和useSelector
export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;

export default store;
```

**连接仓库到React中**

```tsx
import "./wdyr";
import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import store from "./model";
import { Provider } from "react-redux";

ReactDOM.render(
  <React.StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </React.StrictMode>,
  document.getElementById("root")
);
```

**使用，修改`TodoList.tsx`**

```tsx
import { FC, useCallback } from "react";
import { useAppDispatch, useAppSelector } from "../model";
import { add, TodoItemType, update } from "../model/todoList";
import TodoInput from "./TodoInput";
import TodoItem from "./TodoItem";

const TodoList: FC = () => {
  const todoList = useAppSelector(({ todoList }) => todoList.data);
  const dispatch = useAppDispatch();

  const handleAddItem = useCallback(
    (text: string) => {
      if (!text) return;
      dispatch(add(text));
    },
    [dispatch]
  );

  const handleChangeBox = (item: TodoItemType) => (checked: boolean) => {
    dispatch(update({ ...item, isComplete: checked }));
  };

  return (
    <div>
      <TodoInput onAddItem={handleAddItem} />
      <ul style={{ margin: 10, padding: 0 }}>
        {todoList.map((item) => {
          const { id, text, isComplete } = item;
          return (
            <TodoItem
              key={id}
              text={text}
              isComplete={isComplete}
              onCheckboxChange={handleChangeBox(item)}
            />
          );
        })}
      </ul>
    </div>
  );
};

TodoList.whyDidYouRender = {
  logOnDifferentValues: true,
};

export default TodoList;
```

`dispatch`有两种用法

**第一种**

直接使用导出的`action`

```ts
dispatch(add(text)); 
```

**第二种**

和dva一样，使用字符串："命名空间/action名"，

```ts
dispatch({
  type: 'todoList/add',
  payload: text
}); 
```

我比较偏向于第一种，因为有代码提示比较香☺️

现在这种写法还没什么问题暴露出来，控制台啥也没打印。

![image-20210720140745456](https://i.loli.net/2021/07/20/q3dgronuCPMbA8T.png)

但是如果`useAppSelector`换一种写法，就不一样了

```diff
import { FC, useCallback } from "react";
import { useAppDispatch, useAppSelector } from "../model";
import { add, TodoItemType, update } from "../model/todoList";
import TodoInput from "./TodoInput";
import TodoItem from "./TodoItem";

const TodoList: FC = () => {
-  const todoList = useAppSelector(({ todoList }) => todoList.data);
+  const { todoList } = useAppSelector(({ todoList }) => ({
+    todoList: todoList.data,
+  }));
  //...略
};

TodoList.whyDidYouRender = {
  logOnDifferentValues: true,
};

export default TodoList;
```

这里我们用`useAppSelector` 返回了一个对象，实际上，这种写法在你想要从不同的`reducer`一次性获取多个值的时候很常用。

现在我们刷新页面，看看控制台。

![image-20210720141611834](https://i.loli.net/2021/07/20/Gn3NcM8xYlH49PR.png)



啥也没干，初始化就多了一次`useReducer`的刷新。

#### 问题排查

这里引出了两个问题：

1. 为什么多了一次渲染？
2. 为什么是`useReducer`改变触发的渲染，代码里并没有使用`useReducer`？

先解决第二个问题，其实`react-redux`在监听到`store`数据变化的时候是通过`useReducer`来进行强制刷新，从下图的`useSelector`的源码可以很清楚的看出来，这也是[官网](https://zh-hans.reactjs.org/docs/hooks-faq.html#is-there-something-like-forceupdate)推荐的写法。

![image-20210721191722166](https://i.loli.net/2021/07/21/lOYhBJQg5wnpyKs.png)

再来看看第一个问题，这里要先修改一下`wdyr.ts`的配置，才能看到`useSelector`触发更新的日志

```diff
// src/wdyr.ts
/// <reference types="@welldone-software/why-did-you-render" />
import React from "react";

// 不要在生成环境打开，会影响性能
if (process.env.NODE_ENV === "development") {
  const whyDidYouRender = require("@welldone-software/why-did-you-render");
+ const ReactRedux = require("react-redux");
  whyDidYouRender(React, {
    trackAllPureComponents: true, // 跟踪所有纯组件(React.PureComponent or React.memo)
+   trackExtraHooks: [[ReactRedux, "useSelector"]], // 跟踪useSelector
  });
}
```

现在再来看看控制台，看起来数据并没有变化，却触发了两次渲染

![image-20210721194855238](https://i.loli.net/2021/07/21/FVcMSB3nCZK7foz.png)

这是因为，`useSelector`返回数据的时候是使用`===`进行比较的，如果你返回的对象，则每次比较都是`false`，所以会触发多次渲染

#### 优化

针对第一个问题，这里有几种解决办法。

**第一种**

不要返回对象，就用一开始的写法，如果有多个值要返回，就使用多个`useSelector`。

```tsx
  const todoList = useAppSelector(({ todoList }) => todoList.data);
```

**第二种**

如果非要写对象，可以使用`useSelector`的第二个参数，传入一个比较函数。

在这里官网给我们导出了一个比较函数，可以直接使用。

```tsx
import { shallowEqual } from "react-redux";

const { todoList } = useAppSelector(
  ({ todoList }) => ({
    todoList: todoList.data,
  }),
  shallowEqual
);Ï
```

重新打开控制台，查看效果，没有任何多余的重新渲染。

![image-20210721195515987](https://i.loli.net/2021/07/21/DWG9HEZrR2wApTu.png)

你也可以使用第三方库的比较函数，如：[react-fast-compare](https://github.com/FormidableLabs/react-fast-compare)，[lodash/isEquald](https://lodash.com/docs/4.17.15#isEqual)等。

**第三种**

使用[reselect](https://github.com/reduxjs/reselect)缓存`useSelector`，这个没怎么用过，就不展开说了，感兴趣的自己看文档吧。

**第四种**

配合`useMemo`使用。

```tsx
import { useMemo } from 'react';
import { useSelector } from 'react-redux';

/** 原始写法 **/
const { todoList, usename } = useAppSelector(({ todoList, user }) => ({
  todoList: todoList.data,
  usename: user.username,
}));

/** 优化写法 **/
const state = useAppSelector((state) => state); // 保持useSelector返回的值不变

// 使用useMemo拆分数据
const { todoList, usename } = useMemo(() => {
  return {
    todoList: state.todoList.data,
  	usename: state.user.username
  };
}, [state])
```

[完整代码](https://gitee.com/wcly/react-optimize-practice/tree/react-redux/)

## 总结

1. React有两个常用的工具，分别是`React Developer Tools`和`why-did-you-render`，优化可以从减少渲染次数和渲染时间下手；
2. `React.memo`和`useCallback`或`useMemo`同时使用，可在父组件渲染的时候减少不必要的子组件渲染；
3. `react-redux`的`useSeletor`使用不当容易造成重复渲染，有四种方式可以解决。

其实这些性能优化的点，都是在一开始写代码的时候就可以避免的，写多两次就熟了。很多人觉得`React`的学习成本高，可能就是因为不熟悉`React`的渲染机制。在`vue`中，这些优化框架已经做好了，但是`React`中需要自己写。



>参考：
>
>- https://overreacted.io/zh-hans/a-complete-guide-to-useeffect/
>- https://react-redux.js.org/api/hooks#performance
>- https://zh-hans.reactjs.org/docs/hooks-faq.html
>- https://github.com/welldone-software/why-did-you-render