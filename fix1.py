# -*- coding: utf-8 -*-
# Fix FileUploadUtils default max size for video support
filepath = r"I:\red-book-ma\hongshu-master\hongshu-common\src\main\java\com\hongshu\common\utils\file\FileUploadUtils.java"
with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

old = '    public static final long DEFAULT_MAX_SIZE = 50 * 1024 * 1024;'
new = '    public static final long DEFAULT_MAX_SIZE = 500 * 1024 * 1024; // 500MB, support video uploads'
content = content.replace(old, new, 1)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)

print("OK: FileUploadUtils.DEFAULT_MAX_SIZE increased to 500MB")