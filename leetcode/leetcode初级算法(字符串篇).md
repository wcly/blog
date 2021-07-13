## [leetcode初级算法(字符串篇)](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/)

注：**点标题可以查看对应的题目**，本文代码均使用`Javascript`编写。代码不一定是最优解，仅供参考，如大佬们有更好的实现，欢迎交流。

### [反转字符串](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/32/)

解析：要**原地**改变数组，第一次循环交换第一个和数组最后一个值，第二次交换第二个和数组倒数第二个值，依次类推。每次交换两个值，循环数组长度的1/2次即可。其实用`javascript`内置方法`reverse`，一行代码就搞定了，但是这毕竟是算法题，不自己想出来也没啥必要练了。

代码：

```javascript
/**
 * @param {character[]} s
 * @return {void} Do not return anything, modify s in-place instead.
 */
var reverseString = function(s) {
    var len = s.length;
    for(var i = 0; i < len / 2; i++){
        var temp = s[i];
        s[i] = s[len - 1 - i];
        s[len - 1 - i] = temp;
    }
};
```

### [整数反转](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/33/)

解析：

1. 个位数，直接返回。
2. 十位数及以上，转换为字符串翻转后，判断是否溢出，不溢出加上符号位返回，溢出返回0。

代码：

```javascript
/**
 * @param {number} x
 * @return {number}
 */
var reverse = function(x) {
	var absX = Math.abs(x); // 取绝对值
    // 个位数直接返回
	if(absX >= 0 && absX <= 9){
        return x;
    }
    var reverse = absX.toString().split('').reverse().join(''); // 转换成字符串数组，反转数字，在变回字符串
    if(+reverse > 2 ** 31 - 1){ // 溢出返回0
        return 0;
    }else{
        // 加上原来的符号返回
        if(x > 0){
            return +reverse;
        }else{
            return -reverse;
        }
    }
};
```

### [字符串中的第一个唯一字符](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/34/)

解析：每次取一个字符和其他字符进行比较，比较完没有重复则返回索引，所有字符都比较完都没有出现不重复的，则返回-1。

代码：

```javascript
/**
 * @param {string} s
 * @return {number}
 */
var firstUniqChar = function(s) {
	var repeatItems= {};
    var len = s.length;
    for(var i = 0; i < len; i++){
        var cur = s[i]; // 当前值
        var hasRepeat = false;
        // 当前索引的值已比较过，是有重复的值，无需进行再次比较
        if(repeatItems[i]){
            continue;
        }
        // 依次和原字符串的每一个值做比较
        for(var j = 0; j < len; j++){
            // 跳过和自己比较
            if(i === j){
                continue;
            }
            // 发现有重复的值，标记当前值有重复，记录重复值索引，下次无需再次比较
            if(s[j] === cur){
                repeatItems[j] = true;
                hasRepeat = true;
            }
        }
        // 比较完成后没有重复的值，返回索引
        if(!hasRepeat){
            return i;
        }
    }
    return -1;
};
```

### [有效的字母异位词](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/35/)

解析：解释一下字母异位词，同样的几个字母，只是字母摆放顺序不同的词。

分析：

	1. 字母异位词数组长度一定是一样的；
 	2. 字母异位词包含的字母也是一样的，不会存在一个字母在第一个词中有，第二个词中没有的情况。

代码：

```javascript
/**
 * @param {string} s
 * @param {string} t
 * @return {boolean}
 */
var isAnagram = function(s, t) {
	if(s.length !== t.length){ // 长度不一样直接返回false
        return false;
    }else{
        var arrT = t.split(''); // 将字符串t转为数组
        for(var i = 0; i < s.length; i++){
            var index = arrT.indexOf(s[i]); // 查找t中和当前字母相同的索引
            if(index === -1){ // 找不到一样的值返回false
                return false;
            }else{
                arrT.splice(index, 1); // 删除t中找过的值，防止问题
            }
        }
        return true; // 比较完还没有发现找不到的值，返回true
    }
};
```

### [验证回文字符串](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/36/)

解析：回文就是正着写倒着写都一样的文字。

分析：

1. 先过滤掉**字母和数字字符**以外的符号；
2. 转为字符串数组，逆置字符串数组，和逆置前作比较看是否一样。

代码：

```javascript
/**
 * @param {string} s
 * @return {boolean}
 */
var isPalindrome = function(s) {
    if(s === null || s === undefined){
        return false;
    }
    // 空字符串和空串返回true
    if(s === ' ' || s === ''){
        return true;
    }
    // 只有一个字符返回true
    if(s.length === 1){
        return true
    }
    var strArr = s.toLowerCase().match(/[a-zA-Z0-9]/g); // 统一转换成小写，过滤符号
    // 过滤完之后数字字符之后是空返回true
	if(!strArr){
        return true;
    }
    var reverseStr = strArr.slice(0, strArr.length).reverse().join(''); // 逆置字符串
    if(strArr.join('') === reverseStr){ // 比较逆置前后是否相等
        return true;
    }else{
        return false;
    }
};
```

### [字符串转换整数 (atoi)](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/37/)

解析：这题就是按照规则进行一步步的过滤和处理。

分析：

1. 第一项只能为+-号或数字；
2. 后面的项在没有小数点时可以是小数点，已有小数点就只能是数字；
3. 判断是否能转换成数字，不能返回0；
4. 判断范围是否在32 位有符号整数范围内；
5. 返回结果。

```javascript
/**
 * @param {string} str
 * @return {number}
 */
var myAtoi = function(str) {
    var res = '';
    var reg = /[0-9\+-]/; // 匹配数字和+-号
    var INT_MIN = 2147483648; // 32位有符号整数范围
    for(var i = 0; i < str.length; i++){
        var cur = str[i]; // 当前字符
        if(res.length === 0){ // 判断第一项
            if(reg.test(cur)){ // 可以为数字或+-号
                res += cur;
            }
            if(!reg.test(cur) && cur !== ' '){ // 遇到不是数字和+-号和空格的，跳出循环
                break;
            }
        }else{ // 判断后续项
            if((cur === '.' && !res.includes('.')) || /[0-9]/g.test(cur)){ // 没有小数点时可以为小数点或数字，有小数点只能是数字
                res += cur;
            }
            if(!/[0-9]/g.test(cur)){ // 不是数字的时候跳出循环
                break;
            }
        }
    }
    var res = +res; // 将字符串转为数字
    if(isNaN(res)){ // 转换不成功返回0
        return 0;
    }
    if(res < -INT_MIN){ // 溢出判断
        return -INT_MIN;
    }else if(res > INT_MIN - 1){
        return INT_MIN - 1;
    }
    return res;
};
```

### [实现 strStr()](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/38/)

解析：查找一个字符串haystack中是否包含另一个字符串needle，有则返回出现在haystack的位置，没有则返回-1，如果needle为空字符串，返回0；

分析：

1. 遍历字符串haystack；
2. 截取当前位置到needle字符串长度位置的字符串；
3. 比较，相等则返回当前位置；
4. 遍历完毕证明不存在，返回-1。

代码：

```javascript
/**
 * @param {string} haystack
 * @param {string} needle
 * @return {number}
 */
var strStr = function(haystack, needle) {
    if(needle === ''){ // 空字符串返回0
        return 0;
    }else{
        var index = 0; // 记录找到的位置
        var needleLen = needle.length;
        for(var i = 0; i < haystack.length; i++){
           // 在当前位置截取和needle字符串长度相同的子串和needle进行比较，相等则返回当前位置
           if(haystack.slice(i, i + needleLen) === needle){ 
               return i;
           }
        }
        return -1; // 遍历完成，找不到相同的字符串，返回-1
    }
};
```

### [外观数列](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/39/)

解析：可以分为两个子问题

1. 如何返回一个字符串的描述字符串？

2. 如何返回给定项的描述字符串？

分析：

1. 获取一个描述字符串，遍历这个字符串，把连续相同的字符的个数存起来，每次遇到不一样的值，更新描述字符串即可；
2. 返回给定项的描述字符串，每一个描述字符串都是描述上一个字符串的，从1开始，一直计算到第n个即可；
3. 可以加入缓存，提高性能，因为第n项的描述字符串依赖第n-1个字符串，如果缓存第n-1个字符串，则无需从头开始计算。

```javascript
// 给一个字符串，返回描述这个字符串的字符串
function getDescriptionString(str){
    var curStr = str[0]; // 取字符串第一字符为当前描述字符
    var curCount = 1; // 当前描述字符出现的次数，一开始肯定有一个
    var describeStr = ''; // 初始化描述字符串
    for(var i = 1; i < str.length; i++){ // 从字符串第二项开始比较
        if(curStr === str[i]){ // 如果和当前描述字符相同
            curCount++; // 当前描述字符的个数加1
        }else{ // 如果和当前描述字符不同
            describeStr += curCount + curStr; // 描述字符串加上累加后的当前描述字符
            curStr = str[i]; // 更新当前描述字符
            curCount = 1; // 充值当前描述字符个数
        }
    }
    describeStr += curCount + curStr; // 加上最后一次描述字符和他的个数
    return describeStr;
}

var descriptions = ['1']; // 缓存已描述的数据

/**
 * @param {number} n
 * @return {string}
 */
var countAndSay = function(n) {
    if(descriptions[n-1]){ // 如果缓存数组中存在当前项的描述字符串，直接返回
		return descriptions[n-1];
    }else {
       for(var i = descriptions.length; i < n; i++){ // 如果不存在，从缓存字符串的最后一项开始，获取到第n项描述字符串
           const desctiptionStr = getDescriptionString(descriptions[i-1]); // 根据上一项的描述字符，获取当前的描述字符串
           descriptions.push(desctiptionStr); // 缓存
           if(i === n - 1){ // 返回结果
               return desctiptionStr;
           }
    	} 
    }
};
```

### [最长公共前缀](https://leetcode-cn.com/explore/interview/card/top-interview-questions-easy/5/strings/40/)

解析：初始化公共前缀为空字符串，判断每一个字符长的第i位，如果相等，公共前缀加上第i位的字符，如果有一个不相等，返回公共前缀。

```javascript
/**
 * @param {string[]} strs
 * @return {string}
 */
var longestCommonPrefix = function (strs) {
    if(!strs || strs.length === 0){ // 严谨性判断，传入空或空字符串直接返回
        return "";
    }
  	var result = ""; // 最长公共前缀
  	var index = 0; // 最长公共前缀的索引
  	while (1) {
    	var char = strs[0][index]; // 以第一个字符为基准字符串
    	if (!char) { // 如果当前字符不存在
      		return result;
    	} else {
            for (var i = 1; i < strs.length; i++) {
                if (!strs[i][index] || strs[i][index] !== char) {
                    // 如果有一个字符中的第index个字符不存在或者不等于当前基准字符，跳出循环
                    return result;
                }
            }
            result += char; // 加入当前在所有字符串中都存在的字符
            index++; // 索引加1
    	}
  	}
};

```

