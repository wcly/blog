# react-native实现国际化

其实国际化就是，根据当前选择的语言，将应用中的静态文本切换成对应的语言。

这里主要需要两个信息

- 选择的语言：可以是跟随系统的，也可以是自己定义的
- 语言包：k-v存储的内容，k是这个内容的键，v是显示的内容

在开发中，大部分情况都是一开始没有做国际化，后来业务扩展业务到国外，需要英文版的应用，这个时候如果要手工一个个文本替换，工作量未免太大。

不会偷懒的程序员不是好程序员😏，现在肯定有工具可以解决的，然后还真发现了一个，[di18n](https://github.com/didi/di18n)。

大概的原理就是转AST，替换文本，再转回来，有兴趣的可以自行查阅。

![img](https://github.com/didi/di18n/raw/master/di18n_work_flow.jpg)

总结一下，需要用到的库

- 获取系统的语言：[react-native-localize](https://github.com/zoontek/react-native-localize)
- js多语言配置：[i18n-js](https://github.com/fnando/i18n-js)
- 文本自动转换工具：[di18n](https://github.com/didi/di18n)

## 实战部分

### 新建项目

新建一个rn项目

```bash
npx react-native init i18n_practice
```

### 安装第三方库

把上文提到的第三方库都安装一下

```bash
yarn add react-native-localize i18n-js
```

```
yarn add -D di18n-cli
```

### 生成国际化语言包和配置

初始化

```bash
npx di18n init
```

初始化完成后会生成一些东西

一个是语言包

![image-20210511160226202](https://i.loli.net/2021/05/11/EzJ5qVMK8LYXsbT.png)

一个是配置文件

![image-20210511160317263](https://i.loli.net/2021/05/11/T3Mp2hU9xK6V5SG.png)

这里默认的入口是`src`，rn官方默认的模板没有，所以创建一个`src`目录把`App.js`挪进去

![image-20210511160647003](https://i.loli.net/2021/05/11/IReMJOrbTKdiYmF.png)

另外，配置文件还要做一些修改

```diff
module.exports = {
  entry: ['src'],
  exclude: [],
  output: ['src'],
  disableAutoTranslate: true,
  extractOnly: false,
  translator: null,
  ignoreComponents: [],
  ignoreMethods: [],
  primaryLocale: 'zh-CN',
  supportedLocales: ['zh-CN', 'en-US'],
-  importCode: "import { intl } from 'di18n-react';",
-  i18nObject: 'intl',
+  importCode: "import I18n from 'i18n-js';", // 使用i18n-js库
+  i18nObject: 'I18n', // 和上面import的变量保持一致
  i18nMethod: 't',
  prettier: {singleQuote: true, trailingComma: 'es5', endOfLine: 'lf'},
  localeConf: {type: 'file', folder: 'locales'},
};
```

> 测试了一下，现在不支持主语言是英语的转换❗️

所以我们要先修改一下`APP.js`，加入一些中文

![image-20210511163138024](https://i.loli.net/2021/05/11/9AqudzBeahKyMGJ.png)

### 转换源代码

现在，运行转换命令

```bash
npx di18n sync
```

然后会发现`App.js`的内容改变了

- 在上面导入了`importCode`属性对应的变量

![image-20210511163330314](https://i.loli.net/2021/05/11/timPVakMdXe26ZC.png)

- 将中文使用`I18n.t`包裹起来

![image-20210511163500999](https://i.loli.net/2021/05/11/cdiwPVnxQfyFYl3.png)

语言包也更新了，中文英文是一样的，需要自己修改

![image-20210511163843426](https://i.loli.net/2021/05/11/cDXQ5MZryJhUzV1.png)

修改一下英文语言包

![image-20210511164632417](https://i.loli.net/2021/05/11/iWDCrcN4EsjLFhg.png)

然后发现内容变成了这样

![simulator_screenshot_C4EEE3B2-855C-43F0-A344-B2213A01D12C](https://i.loli.net/2021/05/11/vIJC4NO9uMBwrLD.png)

原因是没有修改I18n的配置，默认的配置无法找到语言包

### 加入配置文件

新建`config/i18n.js`

```js
/**
 * 多语言配置文件
 */
import I18n from 'i18n-js';
import * as RNLocalize from 'react-native-localize';
import en from '../locales/en-US';
import zh from '../locales/zh-CN';

// 获取手机本地国际化信息
const locales = RNLocalize.getLocales();
const systemLanguage = locales[0]?.languageCode; // 用户系统偏好语言

I18n.fallbacks = true;

// 加载语言包
I18n.translations = {
  zh,
  en,
};

if (systemLanguage) {
  I18n.locale = systemLanguage;
} else {
  I18n.locale = 'en';
}

export default I18n;

```

然后就没问题了

![simulator_screenshot_7D5559DD-A5D4-4077-8480-10652CCFA288](/Users/weixiaolin/Library/Application Support/typora-user-images/simulator_screenshot_7D5559DD-A5D4-4077-8480-10652CCFA288.png)

### App内切换语言

如果在app内切换语言，需要以app内的语言为准，切换完成要重新刷新js内容才会生效，然后要将用户选择的语言进行持久化存储。

加入两个第三方库

- [react-native-restart](https://github.com/avishayil/react-native-restart)：刷新app bundle
- [async-storage](https://github.com/react-native-async-storage/async-storage)：持久化存储

```bash
yarn add react-native-restart @react-native-community/async-storage
```

修改配置文件`config/i18n.js`，加入修改语言和重置方法

```js
/**
 * 多语言配置文件
 */
import I18n from 'i18n-js';
import * as RNLocalize from 'react-native-localize';
import en from '../locales/en-US';
import zh from '../locales/zh-CN';
import AsyncStorage from '@react-native-community/async-storage';
import RNRestart from 'react-native-restart';

// 获取手机本地国际化信息
const locales = RNLocalize.getLocales();
const systemLanguage = locales[0]?.languageCode; // 用户系统偏好语言
export const languageKey = 'language';

I18n.fallbacks = true;

// 加载语言包
I18n.translations = {
  zh,
  en,
};

/**
 * 初始化
 */
AsyncStorage.getItem(languageKey).then(value => {
  if (value) {
    I18n.locale = value;
  } else if (systemLanguage) {
    I18n.locale = systemLanguage;
  } else {
    I18n.locale = 'en';
  }
});

/**
 * 修改语言
 * @param {*} language 语言
 */
export async function changeLanguage(language) {
  await AsyncStorage.setItem(languageKey, language);
  // Immediately reload the React Native Bundle
  RNRestart?.Restart();
}

/**
 * 重置
 */
export async function resetLanguage() {
  await AsyncStorage.removeItem(languageKey);
  // Immediately reload the React Native Bundle
  RNRestart?.Restart();
}

export default I18n;

```

在`app.js`中加入测试代码

![image-20210512100857221](https://i.loli.net/2021/05/12/e6AWqjworCDmfR1.png)

### 测试

ok，多语言切换功能完成👏

![Kapture 2021-05-12 at 10.39.18](https://i.loli.net/2021/05/12/bAYxGBn6PaWSCHL.gif)

完整代码地址：https://gitee.com/wcly/i18n_practice