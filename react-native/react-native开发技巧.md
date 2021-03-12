## 调试工具

### react-native-debugger

老牌[react-native](https://github.com/jhen0409/react-native-debugger)调试工具，直接[下载](https://github.com/jhen0409/react-native-debugger/releases/tag/v0.10.13)安装即可，使用的时候要开启debug模式

内置redux-devtools，谷歌调试工具，react-devtools。

![](https://i.loli.net/2021/03/11/94KjmxbHSTiyVeF.png)

如果network看不到请求，在顶层页面加入如下代码：

```js
global.XMLHttpRequest = global.originalXMLHttpRequest || global.XMLHttpRequest;
```



### flipper

0.62以上版本的react-native内置调试工具，内置很多插件，功能比react-natev-debugger，使用的时候无需开启debug模式

在官网[下载](https://fbflipper.com/)安装即可



## 如果遇到第三方库有bug该怎么办

在日常开发中，我们尝尝会用到各种各样的第三方库。就算使用的是大厂或者start很多库，也避免不了遇到bug。下面说一下面对这些bug，我们要如何处理。

### 查找是否有新版本

遇到问题，首先查看这个bug是否已经在新版本中解决了。

这里分为3步：

1. 查看bug是否已解决
2. 查看解决bug的commit被合并到了哪个分支
3. 下载对应的分支代码

一般我们直接下载的npm包都不会是最新的代码，而是默认下载的发布到npm的**稳定版本**。

运行`npm info <repo-name>`可以查看第三方库的版本信息。

例如运行：

```bash
npm info react-native
```

![image-20210311100823472](https://i.loli.net/2021/03/11/bJM6LItR8mwfU2O.png)

当我们运行`npm install react-native`，默认会下载标记为`lastest`的版本。

#### 如何查看bug是否已解决

可以在github上找对应的仓库，然后在Issues中搜索，这里以[react-native](https://github.com/facebook/react-native/issues)为例

![image-20210311102450414](https://i.loli.net/2021/03/11/sMvIzZKHGBnqUTL.png)

你遇到的问题不一定是bug，也有可能是使用的姿势不对，在Issues中如果找到了和你一样的问题，可以查看其它人给出的解决方案，如果能解决就不用进行后续步骤了。

#### 查看解决bug的commit被合并到了哪个分支

可以在点击`Closed`按钮筛选已被关闭的issue

![image-20210311103544799](https://i.loli.net/2021/03/11/iwHmgdWQsBzZkF3.png)

被关闭的bug有两个含义：

1. 这个issue被放弃了
2. 这个issue被解决了

我们再点其中一个[issue](https://github.com/facebook/react-native/issues/30949)去看具体的内容

![image-20210311103832561](https://i.loli.net/2021/03/11/NtqCQauE1I5VgKH.png)

拉下去看评论，这里显示已经被解决了

![image-20210311103931437](https://i.loli.net/2021/03/11/8U2AGqW4vMfSLdn.png)

点击[this commit](https://github.com/facebook/react-native/commit/1c7d9c8046099eab8db4a460bedc0b2c07ed06df)，我们可以看到这个bug修复后被提交到了master分支

![image-20210311104046822](https://i.loli.net/2021/03/11/re9fM8TRZWG1mPI.png)

有时候也会在close时候关联commit连接

![image-20210311110547234](https://i.loli.net/2021/03/11/klq6EKUZQHvFbzG.png)

也有很多时候，开发者不一定会加上解决bug的commit连接，这就看运气了

#### 下载对应的分支代码

在npm仓库查看[react-native](https://www.npmjs.com/package/react-native)版本信息

![image-20210311112801494](https://i.loli.net/2021/03/11/PMQ1mJNRp32CrUe.png)



![image-20210311112531124](https://i.loli.net/2021/03/11/ctrMIUfNvsax4RD.png)

- 代码没有合并到对应的npm版本中

对于只提交到了master分支上的代码，并没有发布一个新的npm版本，如果要下载最新的代码，可以尝试如下命令：

```bash
npm install https://github.com/facebook/react-native
```

如果该第三方库有将npm包托管到github上，就可以通过`npm install ` + `github地址`来下载最新代码。

或者你也可以将代码fork到自己的仓库，然后发布一个新的npm包。

- 代码已合并到对应的npm版本中

![image-20210311111055502](https://i.loli.net/2021/03/11/1hJEOmFwjV4QIvs.png)

如这个bug，直接运行如下命令即可

```
npm install react-native@0.64-rc.3
```

这里是根据tag进行下载的，也可以下载更新的对应的commit版本，点击查看最新的commit

![image-20210311113233198](https://i.loli.net/2021/03/11/8P6pyzGAroaitY5.png)

点击commits查看commit历史记录

![image-20210311113325106](https://i.loli.net/2021/03/11/sD4vLUPy9oJFpja.png)

![image-20210311113532685](https://i.loli.net/2021/03/11/gBZCOYWbzNUyVs1.png)

这里我们可以看到npm中对应的最新版本号和第4条commit的哈希值一致。

我们运行命令`npm install react-native@nightly`下载到的包就能包括该commit之前的所有代码了。



### 使用`patch-package`打补丁

下面我们来使用[pathc-package](https://www.npmjs.com/package/patch-package)给第三方库打补丁。

#### 安装

```bash
npm i patch-package -D
```

在`package.json`加入脚本命令

```diff
 "scripts": {
+  "postinstall": "patch-package"
 }
```

#### 使用

举个例子，这里来修改一下react-native button的默认字体颜色

**找到文件**

```bash
cd node_modules/react-native/Libraries/Components/Button.js
```

修改代码，将color改为`#008c8c`

```diff
text: {
    textAlign: 'center',
    margin: 8,
    ...Platform.select({
      ios: {
        // iOS blue from https://developer.apple.com/ios/human-interface-guidelines/visual-design/color/
-        color: '#007AFF',
+        color: '#008c8c',
        fontSize: 18,
      },
      android: {
-        color: 'white',
+        color: '#008c8c',
        fontWeight: '500',
      },
    }),
  },
```

**生成补丁文件**

yarn

```bash
yarn patch-package react-native
```

npm

```bash
npx patch-package react-native
```

然后patch-package就会自动查找`node_modules/react-native`中修改的文件，并生成补丁文件

![image-20210311140603484](https://i.loli.net/2021/03/11/NvMts93cy5Dxj8u.png)

补丁内容：

~~~bash
cd patches/react-native+0.63.3.patch
~~~

![image-20210311140641649](https://i.loli.net/2021/03/11/eh6S4ctq8E5xiAU.png)

**应用patch**

将patch代码提交到仓库，你的同事在每次安装依赖的时候就会自动打补丁，也可以直接运行命令

yarn

```bash
yarn postinstall
```

npm

```bash
npm run postinstall
```

> 注意：这里只有修改引用的代码才有效，如果第三方库需要打包，则修改它的原码是不生效的。



### 修复第三方库的间接依赖

每个第三方库都会或多或少的依赖其它的库，在遇到间接依赖出现bug的时候，我们只能通过升级这些间接依赖来解决。

如何强制使用某个版本的间接依赖，可以通过修改`package.json`来达到目的：

举个例子：

**yarn**

以修改metro为例，现在在`yarn.lock`文件看到的metro库的版本是`0.58.0`

![image-20210312090310556](https://i.loli.net/2021/03/12/9e2xnbBUCmlDqN6.png)

修改`package.json`，添加`resoultions`字段，你可以指定某个库的简介依赖，如：`d2/left-pad`

如果你不知道那个库依赖了metro可以使用`**/metro`，替换所有库的metro依赖

```diff
+"resolutions": {
+  "**/metro": "0.65.2"
+}
```

然后重新安装依赖，再查看`yarn.lock`，我们会发现已经生效

![image-20210312091205054](https://i.loli.net/2021/03/12/LxBmAyWlkZeFG32.png)

**npm**

npm默认不支持该功能，需要借助一个第三方库：[npm-force-resolutions](https://www.npmjs.com/package/npm-force-resolutions)，配置方式也差不多，这里就不做过多说明了。



## webview调试技巧

在react-native中使用使用[react-native-webview](https://github.com/react-native-webview/react-native-webview)库进行webview的编写。

### 如何调试

webview中打印的信息在react-native运行终端是看不到的，需要进行额外设置

#### ios

Safari浏览器>偏好设置>高级

![image-20210311155500533](https://i.loli.net/2021/03/11/W9eJ5orG2jXiYNL.png)

在开发选项中就可以看到模拟器的运行，如果有网页，会显示网页的地址，点击即可查看

![image-20210311155520018](https://i.loli.net/2021/03/11/QwHD3JmrWKO2aeN.png)

#### android

在`MainApplication.java`中加入如下代码：

```java
import android.webkit.WebView;

@Override
public void onCreate(){
  super.onCreate();
  ...
  WebView.setWebContentsDebuggingEnabled(true);
}
```
修改完成需要重新运行`npx react-native run-android`
在谷歌浏览器地址栏输入

```plain
chrome://inspect
```
![image-20210311155532748](https://i.loli.net/2021/03/11/hdTsZI7QOVLvcjn.png)

如果有webview接入会显示在Remote Target中，点击inspect就可以打开调试工具



## 其它需要注意的点
### ios

* 只能在Mac中开发，编译，需要使用xcode
* 需要有苹果开发者账号才能调试

| 账号类型 | 可上架APP Store | 可调试 |               可以不上架进行分发（通过浏览器）               |
| :------: | :-------------: | :----: | :----------------------------------------------------------: |
|   免费   |                 |   ✅   |                                                              |
| 个人付费 |       ✅        |   ✅   |                                                              |
| 公司付费 |       ✅        |   ✅   | 可以通过蒲公英进行内测分发，但是要在苹果开发者中心添加信任的设备才可以 |
| 企业付费 |       ✅        |   ✅   |                              ✅                              |

### android

#### adb常用命令

* 查看连接中的设备
```plain
adb devices
```
* 静默安装apk
```plain
adb install <apk地址>
```
* 映射端口

Metro 运行在电脑的`localhost:8081`，ios模拟器请求指向电脑的`localhost:8081`，android模拟器不是，所以需要做个映射

连接android机时，打包过后再次连接运行该命令即可连接到电脑，无需重复运行打包命令

```plain
adb reverse tcp:8081 tcp:8081
```
* 打印日志

生成环境也可以看

```plain
adb logcat
```
logcat会把手机所有日志打印出来，难以查看，可以使用[pidcat](https://github.com/JakeWharton/pidcat)，会做一些过滤
#### 减少打包体积

![image-20210311155551820](https://i.loli.net/2021/03/11/cbrHJFUX82EZC6e.png)

android为了做兼容，会把所有cpu架构的包都下载下来，会使打包体积增大

|   cpu类型   |          备注           | 打包是否可以去掉 |
| :---------: | :---------------------: | :--------------: |
| armeabi-v7a |    老的32位的手机cpu    |        ✅        |
|     x86     | pc的32位cpu，用于模拟器 |        ✅        |
|  arm64-v84  | 比较新的手机64位手机cpu |                  |
|   x86_64    | 64位pc的cup，用于模拟器 |                  |

[查看打包后的体积](https://github.com/IjzerenHein/react-native-bundle-visualizer)