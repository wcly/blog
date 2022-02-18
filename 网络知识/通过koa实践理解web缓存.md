# 为什么要进行web缓存？

很简单，就是提速，如果本地有文件能直接读，就不用走网络请求。

在实际开发中也有很多静态文件，如图片，css，js等不会经常变动，如果每次请求都要重新请求的话，无疑是一种网络资源的浪费，而且用户的等待时间也会变长。

所以**为了提高加载速度，减少流量消耗，减轻服务器压力，我们需要使用web缓存。**

# 缓存策略

web缓存策略主要分两种：

1. **强缓存**

2. **协商缓存**

浏览器会自行缓存文件，但是你需要告诉浏览器缓存的策略是什么，这两种方式都是通过设置请求头来告知浏览器什么时候需要向服务器请求新的资源，什么时候使用本地缓存。

## 强缓存

不去请求服务器，直接和本地的缓存做对比。

### 如何判断强缓存是否有效？

通过设置过期时间，过期了就去服务器请求新的资源，没有过期就直接用本地缓存。

### 强缓存时序图

![强缓存时序图.png](https://s2.loli.net/2022/02/18/7oVlK9vkBHszmIe.png)

### 如何设置强缓存？

过期时间有两种设置方式：

1. `Expires`

2. `Cache-Control`

#### Expires

`Expires`是`HTTP/1.0`中定义的缓存字段。表示一个资源的过期时间，它的值是一个**时间戳**（格林尼治时间）。

浏览器向服务器请求资源，服务器设置`Expires`后返回对应的资源，在浏览器再次请求该资源的时候会先对比客户端的时间和`Expires`中设置的值，如果`客户端时间 < Expires`表示缓存有效，直接使用缓存内容，否则，会重新向服务器发起请求获取最新的资源。

##### 缺点

依赖客户端时间，如果修改了客户端时间，资源有效性判断会不准确。

> 参考：[Expires | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Expires)

##### 代码验证

```js
const Koa = require("koa");
const route = require("koa-route");

const app = new Koa();

/**
 * 获取当前时间
 * @returns
 */
function getTime() {
  return new Date().toUTCString();
}

/**
 * 不使用缓存，返回一个html
 * @param {*} ctx
 */
const noCache = async (ctx) => {
  ctx.body = `
    <html>
        html文件的更新时间为: ${getTime()}
        <script src='./main.js'></script>
    </html>
    `;
};

/**
 * 设置了缓存的资源，返回一个js
 * @param {*} ctx 
 */
const hasCache = async (ctx) => {
  // 强缓存方式一：设置Expires
  ctx.set("expires", new Date(Date.now() + 10 * 1000).toUTCString()); // 过期时间设为当前时间 + 10s
  ctx.body = `document.writeln('<br>js文件的更新时间为: ${getTime()}')`;
};

app.use(route.get("/index.html", noCache));
app.use(route.get("/main.js", hasCache));

app.listen(8080, () => {
  console.log("服务器已启动：");
  console.log("http://localhost:8080/");
});
```

这里设置了两个路由，一个是`index.html`，一个是`main.js`，`index.html`内容包含一个`html`更新时间和`main.js`引用，`main.js`执行时会向文档插入一行显示`js`的更新时间。

刷新后，如果html更新时间变化了（html的时间一定会变，因为没有设置缓存，这里是用来做参照的），而js的更新时间没有变化，代表js是来自缓存的。

##### 结果

![2022-02-17-14-29-54-image.png](https://s2.loli.net/2022/02/18/Knm4ZTweJNYLiOc.png)

#### Cache-Control

为了解决`Expires`的漏洞，`HTTP/1.1`引入了一个新字段，用来设置过期时间，即：`Cache-Control`。`Cache-Control`的优先级比`Expires`高，如果同时设置了`Expires`和`Cache-Control`，`Expires`设置的内容无效。

用法：

`Cache-Control:public, max-age=5`，代表资源可以被任何对象缓存（客户端，代理服务器等等），并且缓存资源在5秒后过期。其它字段用法可以查看下面👇🏻的参考文档

> 参考：[Cache-Control | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Cache-Control)

##### 代码验证

```js
/**
 * 设置了缓存的资源，返回一个js
 * @param {*} ctx
 */
const hasCache = async (ctx) => {
  // 强缓存方式一：设置Expires
  ctx.set("expires", new Date(Date.now() + 10 * 1000).toUTCString()); // 过期时间设为当前时间 + 10s
  // 强缓存方式二：设置Cache-Control，优先级高
  ctx.set("cache-control", "public, max-age=5"); // 过期时间设置为5s后过期
  ctx.body = `document.writeln('<br>js文件的更新时间为: ${getTime()}')`;
};
```

##### 结果

![2022-02-17-15-51-33-image.png](https://s2.loli.net/2022/02/18/zNPimJTgs1Yocdr.png)

## 协商缓存

协商缓存是指浏览器在使用缓存的时候会去服务器问一下（协商），当前缓存资源是否有效，如果有效，服务器会返回304，不返回内容，表示资源没有更新，浏览器可以继续使用本地缓存，反之，浏览器会返回一个新的资源。

协商缓存将缓存有效的判断逻辑迁移到了服务器。

### 如何关闭强缓存？

设置`cache-control`为`no-store`或者`no-cache`即可。

### 协商缓存时序图

![2022-02-17-17-12-12-image.png](https://s2.loli.net/2022/02/18/FYxKrhwGiyk1g9j.png)

### 如何设置协商缓存？

设置协商缓存有两种方式，一个是对比过期时间，一个是对比文件内容是否有变化

1. 过期时间：使用`last-modified`和`if-modified-since`

2. 文件内容变化：使用`etag`和`if-none-match`

`last-modified`和`etag`是设置在响应头返回给浏览器的，`if-modified-since`和`if-none-match`是浏览器下次发起请求的时候将上次返回的响应头中的`last-modified`和`etag`设置到请求头中返回给服务器做校验的。

> 参考：
> 
> - [Last-Modified | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Last-Modified)
> 
> - [If-Modified-Since | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/If-Modified-Since)
> 
> - [ETag | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/ETag)
> 
> - [If-None-Match | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/If-None-Match)

### last-modified & if-modified-since

通过过期时间判断资源缓存有效性。

#### 代码验证

```js
/**
 * 设置了缓存的资源，返回一个js
 * @param {*} ctx
 */
const hasCache = async (ctx) => {
  // 关闭强缓存
  ctx.set("cache-control", "no-cache");
  // 记录最新一次的请求时间
  ctx.set("last-modified", new Date().toUTCString());
  // 过期时间设置为上次请求的3s后
  if (new Date(ctx.header["if-modified-since"]).getTime() + 3 * 1000 > Date.now()) {
    console.log("协商缓存命中");
    ctx.status = 304;
  } else {
    ctx.body = `document.writeln('<br>js文件的更新时间为: ${getTime()}')`;
  }
};
```

#### 结果

![2022-02-17-17-21-19-image.png](https://s2.loli.net/2022/02/18/gFUtQAycu39lZEa.png)

### etag & if-none-match

通过文件摘要判断缓存资源有效性。

不管是强缓存还是协商缓存的`last-modified`和`if-modified-since`都是使用过期时间判断缓存命中的，这无疑都出现一个问题，资源更新后无法及时刷新， 如设置过期时间为1天后过期，然后资源一秒后就变更了，这时浏览器也要等到1天后才能获取最新的资源。

为了避免这种延迟资源刷新的情况，可以使用文件摘要对比的方式来资源是否更新。

所以`etag`和`if-none-match`使最常用的缓存策略，既能保证更新的即时性，也节省带宽。

#### 代码验证

```js
/**
 * 设置了缓存的资源，返回一个js
 * @param {*} ctx
 */
const hasCache = async (ctx) => {
  // 关闭强缓存
  ctx.set("cache-control", "no-cache");
  const content = `document.writeln('<br>js文件的内容为: hello world')`
  const crypto = require("crypto");
  // 对返回的内容做摘要
  const hash = crypto.createHash('sha1').update(content).digest('hex')
  // 记录最新内容的摘要
  ctx.set("etag", hash);
  // 对比最新的摘要和上次的摘要
  if (hash === ctx.header['if-none-match']) {
    console.log("协商缓存命中");
    ctx.status = 304;
  } else {
    ctx.body = content;
  }
};
```

#### 结果

![2022-02-18-11-09-15-image.png](https://s2.loli.net/2022/02/18/rStLl8gOKG3Yj9x.png)

## 其它缓存策略

上面说的都是基于HTTP的缓存策略，下面是一些其它缓存策略，感兴趣的可以看看。

1. 直接在代码里进行缓存：主要思路就是接口返回的值，如果下次请求参数不变，直接用之前保存，参考基于[promise的缓存demo](https://codesandbox.io/s/promise-2b825?file=/src/cache.js:674-685)

2. [Service Workers | MDN](https://developer.mozilla.org/zh-CN/docs/Web/API/Service_Worker_API/Using_Service_Workers)
