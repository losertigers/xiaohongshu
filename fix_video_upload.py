# -*- coding: utf-8 -*-
# Fix WebOssServiceImpl.save() to allow video uploads
filepath = r"I:\red-book-ma\hongshu-master\hongshu-web\src\main\java\com\hongshu\web\service\impl\WebOssServiceImpl.java"
with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

old = '                return FileUploadUtils.upload(HongshuConfig.getAvatarPath(), file, MimeTypeUtils.IMAGE_EXTENSION);'
new = '''                // 鏀寔鍥剧墖鍜岃棰戞牸寮忎笂浼?                String[] allAllowed = {
                    "bmp", "gif", "jpg", "jpeg", "png",
                    "mp4", "avi", "rmvb", "mov", "flv", "wmv"
                };
                return FileUploadUtils.upload(HongshuConfig.getAvatarPath(), file, allAllowed);'''

content = content.replace(old, new, 1)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)

print("OK: WebOssServiceImpl.save() now supports video uploads")