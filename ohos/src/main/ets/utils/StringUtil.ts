/**
 * MIT License
 *
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import util from '@ohos.util'

/**
 * 字符串工具类
 */
namespace StringUtil {

/**
 * 字符串是否为空
 * @param str 字符串
 * @return 是否为空
 */
    export function isEmpty(str: string): boolean {
        return!str || str.length === 0
    }

    /**
     * 将字符串转换成Uint8Array类型
     * @param str 字符串
     * @return 无符号整型数组
     */
    export function convert2Uint8Array(str: string): Uint8Array {
        if (isEmpty(str)) {
            return new Uint8Array()
        }
        return new util.TextEncoder().encode(str)
    }

    /**
     * 将字符串做base64编码
     * @param str 字符串
     * @return Base64字符串
     */
    export function convert2Base64(str: string): string {
        if (isEmpty(str)) {
            return ''
        }
        const array = convert2Uint8Array(str)
        return new util.Base64().encodeToStringSync(array)
    }

    /**
     * 字符串头部补全
     * @param num 待补全字符串
     * @param maxLen 补全后字符串的最大长度
     * @param placeholder 占位符
     * @return 不全后的字符串，如：1=>01
     */
    export function padStart(num: number | string, maxLen = 2, placeholder = '0') {
        return num.toString().padStart(maxLen, placeholder)
    }

    /**
     * 获得字符串字节长度
     * @param str 字符串
     * @return 字节长度
     */
    export function getBytesCount(str: string): number {
        let bytesCount = 0
        if (str) {
            for (let i = 0; i < str.length; i++) {
                const char = str.charAt(i)
                if (char.match(/[^\x00-\xff]/ig) != null) {
                    // 汉字占用字节数和编码有关，utf-8编码：占3个字节，GB2312编码：占2个字节
                    bytesCount += 3
                } else {
                    bytesCount += 1
                }
            }
        }
        return bytesCount
    }
}

export default StringUtil
