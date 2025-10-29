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

export class MimeType {
  /**
   * 文件大分类：图片
   */
  public static FILE_CATEGORY_IMAGE = 1

  /**
   * 文件大分类：视频
   */
  public static FILE_CATEGORY_VIDEO = 2

  /**
   * 文件大分类：音频
   */
  public static FILE_CATEGORY_AUDIO = 3

  /**
   * 文件大分类：文档
   */
  public static FILE_CATEGORY_TXT = 4

  /**
   * 文件大分类：压缩包
   */
  public static FILE_CATEGORY_ZIP = 5

  /**
   * 文件大分类：APK
   */
  public static FILE_CATEGORY_PKG = 6

  /**
   * 文件大分类：未知
   */
  public static FILE_CATEGORY_UNKNOW = 7

  /**
   * 文件后缀对应的整形定义，用于文件的大分类
   */
  private fileCategory: number

  /**
   * 文件后缀对应的整形定义，用于文件细分的类型
   */
  private fileTypeSort: number


  /**
   * 文件的mimetype
   */
  private mimeType: string

  /**
   * 文件后缀
   */
  private extension: string

  constructor(extension: string, fileCategory: number, fileTypeSort: number,  mimeType: string) {
    this.extension = extension
    this.fileCategory = fileCategory
    this.fileTypeSort = fileTypeSort
    this.mimeType = mimeType
  }

  getFileCategory(): number {
    return this.fileCategory
  }

  getMimeType(){
    return this.mimeType
  }

  getFileTypeSort(): number {
    return this.fileTypeSort
  }


  isMedia(): boolean {
    return this.fileCategory === MimeType.FILE_CATEGORY_IMAGE || this.fileCategory === MimeType.FILE_CATEGORY_VIDEO || this.fileCategory === MimeType.FILE_CATEGORY_AUDIO
  }

  isAudioOrVideo(): boolean {
    return this.fileCategory === MimeType.FILE_CATEGORY_VIDEO || this.fileCategory === MimeType.FILE_CATEGORY_AUDIO
  }

  isDoc(): boolean {
    return this.fileCategory === MimeType.FILE_CATEGORY_TXT
  }

  isAudio(): boolean {
    return this.fileCategory === MimeType.FILE_CATEGORY_AUDIO
  }

  isVideo(): boolean {
    return this.fileCategory === MimeType.FILE_CATEGORY_VIDEO
  }

  isImage(): boolean {
    return this.fileCategory === MimeType.FILE_CATEGORY_IMAGE
  }

  isZip(): boolean {
    return this.fileCategory === MimeType.FILE_CATEGORY_ZIP
  }

  isPKG(): boolean {
    return this.fileCategory === MimeType.FILE_CATEGORY_PKG
  }
}