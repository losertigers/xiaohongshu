<template>
  <div class="container" id="container">
    <div v-if="isLogin" class="push-container">
            <div class="header">
        <span class="header-icon"></span>
        <span class="header-title">{{ publishMode === 'image' ? '发布图文' : '发布视频' }}</span>
        <div class="mode-switch">
          <button class="mode-btn" :class="{ active: publishMode === 'image' }" @click="switchMode('image')">图片</button>
          <button class="mode-btn" :class="{ active: publishMode === 'video' }" @click="switchMode('video')">视频</button>
        </div>
      </div>
      <div class="img-list" v-if="publishMode === 'image'">
        <el-upload
          v-model:file-list="fileList"
          action="http://localhost:88/api/util/oss/saveBatch/0"
          list-type="picture-card"
          multiple
          :limit="9"
          :headers="uploadHeader"
          :auto-upload="false"
          accept="image/*"
        >
          <el-icon>
            <Plus />
          </el-icon>
        </el-upload>

        <el-dialog v-model="dialogVisible">
          <img w-full :src="dialogImageUrl" alt="Preview Image" />
        </el-dialog>
      </div>
      <div class="video-list" v-if="publishMode === 'video'">
        <el-upload
          v-model:file-list="videoFileList"
          action="http://localhost:88/api/util/oss/saveBatch/0"
          list-type="picture-card"
          :limit="1"
          :headers="uploadHeader"
          :auto-upload="false"
          accept="video/*"
          :on-exceed="handleVideoExceed"
          :before-upload="beforeVideoUpload"
        >
          <el-icon>
            <Plus />
          </el-icon>
          <template #file="{ file }">
            <div class="video-preview-item">
              <video class="video-preview" :src="file.url" muted></video>
              <span class="el-upload-list__item-actions">
                <span class="el-upload-list__item-preview" @click="handleVideoPreview(file)">
                  <el-icon><ZoomIn /></el-icon>
                </span>
                <span class="el-upload-list__item-delete" @click="handleVideoRemove(file)">
                  <el-icon><Delete /></el-icon>
                </span>
              </span>
              <div class="video-badge">视频</div>
            </div>
          </template>
        </el-upload>
        <el-dialog v-model="videoPreviewVisible" title="视频预览" width="60%" destroy-on-close>
          <video v-if="videoPreviewUrl" :src="videoPreviewUrl" controls autoplay style="width: 100%"></video>
        </el-dialog>
      </div>
      <el-divider style="margin: 0.75rem; width: 96%" />
      <div class="push-content">
        <el-input
          v-model="note.title"
          maxlength="20"
          show-word-limit
          type="text"
          placeholder="请输入标题"
          class="input-title"
        />
        <el-input
          v-model="note.content"
          maxlength="250"
          show-word-limit
          :autosize="{ minRows: 4, maxRows: 5 }"
          type="textarea"
          placeholder="填写更全面的描述信息，让更多的人看到你吧❤️"
        />
        <div class="btns">
          <button class="css-fm44j css-osq2ks dyn">
            <span class="btn-content" @click="addTag"># 话题</span></button
          ><button class="css-fm44j css-osq2ks dyn">
            <span class="btn-content"><span>@</span> 用户</span></button
          ><button class="css-fm44j css-osq2ks dyn">
            <span class="btn-content">
              <div class="smile"></div>
              表情
            </span>
          </button>
        </div>
        <div class="tag-list">
          <el-tag
            v-for="tag in dynamicTags"
            :key="tag"
            closable
            :disable-transitions="false"
            @close="handleClose(tag)"
            class="tag-item"
            type="danger"
          >
            {{ tag }}
          </el-tag>
          <el-input
            v-if="inputVisible"
            ref="InputRef"
            v-model="inputValue"
            style="width: 3.125rem"
            size="small"
            @keyup.enter="handleInputConfirm"
            @blur="handleInputBlur"
          />
          <el-button
            v-else
            type="warning"
            size="small"
            @click="showInput"
            plain
            id="tagContainer"
            :disabled="dynamicTags.length >= 5"
          >
            + 标签
          </el-button>
        </div>
        <div class="hot-tag">
          <span class="tag-title-text">推荐标签：</span>
          <el-tag
            v-for="tag in hotTags"
            :key="tag"
            class="hot-tag-item"
            type="warning"
            @click="selectHotTag(tag)"
            :disabled="dynamicTags.length >= 5"
          >
            {{ tag }}
          </el-tag>
        </div>
      </div>
      <el-divider style="margin: 0.75rem; width: 96%" />
      <div class="categorys">
        <el-cascader
          ref="CascaderRef"
          v-model="categoryList"
          :options="options"
          @change="handleChange"
          :props="props"
          placeholder="请选择分类"
        />
      </div>
      <div class="submit">
        <el-button type="danger" loading :disabled="true" v-if="pushLoading">发布</el-button>
        <button class="publishBtn" @click="pubslish()" v-else>
          <span class="btn-content">发布</span>
        </button>
        <button class="clearBtn">
          <span class="btn-content" @click="resetData">取消</span>
        </button>
      </div>
    </div>
    <div v-else>
      <el-empty description="用户未登录" />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, watch, nextTick, onMounted } from "vue";
import { Plus, ZoomIn, Delete } from "@element-plus/icons-vue";
import { useRoute } from "vue-router";
import type { UploadUserFile, CascaderProps, ElInput } from "element-plus";
import { ElMessage } from "element-plus";
import { useUserStore } from "@/store/userStore";
import { getCategoryTreeData } from "@/api/category";
import { saveNoteByDTO, getNoteById, updateNoteByDTO } from "@/api/note";
import { getTagByKeyword } from "@/api/tag";
import { getFileFromUrl } from "@/utils/util";
// import Schema from "async-validator";
// import Crop from "@/components/Crop.vue";
const props: CascaderProps = {
  label: "title",
  value: "id",
  checkStrictly: true, // 允许选择父级节点
};
const CascaderRef = ref<any>(null);

// const rules = {
//   title: { required: true, message: "标题不能为空" },
//   content: { required: true, message: "内容不能为空" },
//   category: { required: true, message: "分类不能为空" },
// };
// const validator = new Schema(rules);

const userStore = useUserStore();
const route = useRoute();

const fileList = ref<UploadUserFile[]>([]);
const publishMode = ref<'image' | 'video'>('image');
const videoFileList = ref<UploadUserFile[]>([]);
const videoPreviewVisible = ref(false);
const videoPreviewUrl = ref("");

const dialogImageUrl = ref("");
const dialogVisible = ref(false);
const uploadHeader = ref({
  accessToken: userStore.getToken(),
});
const categoryList = ref<Array<any>>([]);
const options = ref([]);
const note = ref<any>({});
const showTagState = ref(false);
const selectTagList = ref<Array<any>>([]);
const currentPage = ref(1);
const pageSize = 10;
const tagTotal = ref(0);
const pushLoading = ref(false);
const isLogin = ref(false);
const inputValue = ref("");
const dynamicTags = ref<Array<string>>([]);
const inputVisible = ref(false);
const InputRef = ref<InstanceType<typeof ElInput>>();
const hotTags = ref<Array<string>>([]);

const handleClose = (tag: string) => {
  dynamicTags.value.splice(dynamicTags.value.indexOf(tag), 1);
};

const handleInputBlur = () => {
  inputVisible.value = false;
  // showTagState.value = false;
};

const showInput = () => {
  inputVisible.value = true;
  nextTick(() => {
    InputRef.value!.input!.focus();
    addTag();
  });
};

const handleInputConfirm = () => {
  if (inputValue.value) {
    dynamicTags.value.push(inputValue.value);
  }
  inputVisible.value = false;
  inputValue.value = "";
  showTagState.value = false;
};

watch(
  () => inputValue.value,
  () => {
    addTag();
  }
);

// 监听外部点击
onMounted(() => {
  if (!isLogin.value) {
    return;
  }
  document.getElementById("container")!.addEventListener("click", function (e) {
    var event = e || window.event;
    var target = event.target || (event.srcElement as any);
    // if(target.id == "name") {
    const tagContainer = document.getElementById("tagContainer");
    if (tagContainer == null) return;

    if (tagContainer.contains(target)) {
      console.log("in");
    } else {
      showTagState.value = false;
    }
  });
});

const addTag = () => {
  selectTagList.value = [];
  currentPage.value = 1;
  setData();
  showTagState.value = true;
};

const setData = () => {
  getTagByKeyword(currentPage.value, pageSize, inputValue.value).then((res) => {
    const { records, total } = res.data;
    selectTagList.value.push(...records);
    tagTotal.value = total;
  });
};

const selectHotTag = (val: string) => {
  if (dynamicTags.value.length < 5) {
    dynamicTags.value.push(val);
  } else {
    // 如果已选择 5 个标签，弹出提示
    ElMessage.warning("最多只能选择 5 个标签");
  }
};

const handleChange = (ids: Array<any>) => {
  categoryList.value = ids;
  // 选中后关闭下拉框
  CascaderRef.value.togglePopperVisible();
};

const getHotTag = () => {
  getTagByKeyword(1, pageSize, "").then((res) => {
    const { records } = res.data;
    records.forEach((item: any) => {
      hotTags.value.push(item.title);
    });
  });
};

const getNoteByIdMethod = (noteId: string) => {
  getNoteById(noteId).then((res) => {
    const { data } = res;
    note.value = data;
    const urls = JSON.parse(data.urls);
    publishMode.value = data.noteType === "1" ? "video" : "image";
    if (publishMode.value === "video") {
      const videoUrl = urls[0];
      const fileName = videoUrl.substring(videoUrl.lastIndexOf("/") + 1);
      getFileFromUrl(videoUrl, fileName).then((res: any) => {
        videoFileList.value.push({ name: fileName, url: videoUrl, raw: res });
      });
    } else {
      urls.forEach((item: string) => {
        const fileName = item.substring(item.lastIndexOf("/") + 1);

        getFileFromUrl(item, fileName).then((res: any) => {
          fileList.value.push({ name: fileName, url: item, raw: res });
        });
      });
    }
    categoryList.value.push(data.cpid);
    categoryList.value.push(data.cid);

    data.tagList.forEach((item: any) => {
      dynamicTags.value.push(item.title);
    });
  });
};

const switchMode = (mode: 'image' | 'video') => {
  publishMode.value = mode;
  if (mode === "image") {
    videoFileList.value = [];
  } else {
    fileList.value = [];
  }
};

const handleVideoExceed = () => {
  ElMessage.warning("只能上传 1 个视频文件");
};

const beforeVideoUpload = (file: File) => {
  const isVideo = file.type.startsWith("video/");
  if (!isVideo) {
    ElMessage.error("请上传视频文件");
    return false;
  }
  const isLt500M = file.size / 1024 / 1024 < 500;
  if (!isLt500M) {
    ElMessage.error("视频文件大小不能超过 500MB");
    return false;
  }
  return true;
};

const handleVideoPreview = (file: any) => {
  videoPreviewUrl.value = file.url;
  videoPreviewVisible.value = true;
};

const handleVideoRemove = (file: any) => {
  const index = videoFileList.value.indexOf(file);
  if (index !== -1) {
    videoFileList.value.splice(index, 1);
  }
};

// upload
const pubslish = () => {
  if (publishMode.value === "image") {
    if (fileList.value.length <= 0 || note.value.title === null || categoryList.value.length <= 0) {
      ElMessage.error("请选择图片，标签，分类～");
      return;
    }
  } else {
    if (videoFileList.value.length <= 0 || note.value.title === null || categoryList.value.length <= 0) {
      ElMessage.error("请选择视频，标签，分类～");
      return;
    }
  }
  pushLoading.value = true;
  let params = new FormData();
  note.value.type = 1;
  note.value.cpid = categoryList.value[0];
  note.value.cid = categoryList.value[1];
  note.value.tagList = dynamicTags.value;

  if (publishMode.value === "video") {
    params.append("uploadFiles", videoFileList.value[0].raw as any);
    note.value.count = 1;
    note.value.noteType = "1";
    note.value.noteCoverHeight = 300;
    const noteData = JSON.stringify(note.value);
    params.append("noteData", noteData);
    if (note.value.id !== null && note.value.id !== undefined) {
      updateNote(params);
    } else {
      saveNote(params);
    }
    return;
  }

  fileList.value.forEach((file: any) => {
    params.append("uploadFiles", file.raw);
  });
  note.value.count = fileList.value.length;
  note.value.noteType = "0";
  // note.value.content = document.getElementById("post-textarea")!.innerHTML.replace(/<[^>]*>[^<]*(<[^>]*>)?/gi, "");
  const coverImage = new Image();
  coverImage.src = fileList.value[0].url!;
  coverImage.onload = () => {
    const size = coverImage.width / coverImage.height;
    note.value.noteCoverHeight = size >= 1.3 ? 200 : 300;
    const noteData = JSON.stringify(note.value);
    params.append("noteData", noteData);
    if (note.value.id !== null && note.value.id !== undefined) {
      updateNote(params);
    } else {
      saveNote(params);
    }
  };
};

const updateNote = (params: FormData) => {
  updateNoteByDTO(params)
    .then(() => {
      resetData();
      ElMessage.success("修改成功");
    })
    .catch(() => {
      ElMessage.error("修改失败");
    })
    .finally(() => {
      pushLoading.value = false;
    });
};

const saveNote = (params: FormData) => {
  saveNoteByDTO(params)
    .then(() => {
      resetData();
      ElMessage.success("发布成功,请等待审核结果");
    })
    .catch(() => {
      ElMessage.error("发布失败");
    })
    .finally(() => {
      pushLoading.value = false;
    });
};

const resetData = () => {
  note.value = {};
  categoryList.value = [];
  fileList.value = [];
  videoFileList.value = [];
  publishMode.value = "image";
  pushLoading.value = false;
  dynamicTags.value = [];
};

const initData = () => {
  isLogin.value = userStore.isLogin();
  if (isLogin.value) {
    const noteId = route.query.noteId as string;
    if (noteId !== "" && noteId !== undefined) {
      getNoteByIdMethod(noteId);
    }
    getCategoryTreeData().then((res) => {
      options.value = res.data;
    });
    getHotTag();
  }
};

initData();
</script>

<style lang="less" scoped>
:deep(.el-upload-list--picture-card .el-upload-list__item) {
  width: 100px;
  height: 100px;
}

:deep(.el-upload-list__item.is-success .el-upload-list__item-status-label) {
  display: none;
}

:deep(.el-upload--picture-card) {
  width: 100px;
  height: 100px;
}

a {
  text-decoration: none;
}

.container {
  flex: 1;
  padding-top: 72px;

  .push-container {
    margin-left: 11vw;
    margin-top: 1vw;
    width: 720px;
    border-radius: 8px;
    box-sizing: border-box;
    box-shadow: var(--el-box-shadow-lighter);

    .header {
      padding: 15px 20px;
      line-height: 16px;
      font-size: 16px;
      font-weight: 400;
      display: flex;
      align-items: center;

      .header-icon {
        position: relative;
        top: 2px;
        display: inline-block;
        width: 6px;
        height: 16px;
        background: #3a64ff;
        border-radius: 3px;
        margin-right: 3px;
      }

      .header-title {
        margin-right: 16px;
      }

      .mode-switch {
        display: flex;
        gap: 4px;
        margin-left: auto;

        .mode-btn {
          padding: 4px 12px;
          border: 1px solid #d9d9d9;
          border-radius: 4px;
          background: #fff;
          cursor: pointer;
          font-size: 12px;
          color: #666;
          transition: all 0.2s;

          &:hover {
            color: #ff2442;
            border-color: #ff2442;
          }

          &.active {
            background: #ff2442;
            color: #fff;
            border-color: #ff2442;
          }
        }
      }
    }

    .img-list {
      width: 650px;
      margin: auto;
      padding: 6px 6px 6px 6px;
    }

    .video-list {
      width: 650px;
      margin: auto;
      padding: 6px;

      .video-preview-item {
        position: relative;
        width: 100px;
        height: 100px;
        overflow: hidden;
        border-radius: 4px;

        .video-preview {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }

        .video-badge {
          position: absolute;
          bottom: 4px;
          left: 4px;
          background: rgba(0, 0, 0, 0.6);
          color: #fff;
          font-size: 10px;
          padding: 1px 4px;
          border-radius: 2px;
        }

        .el-upload-list__item-actions {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          opacity: 0;
          transition: opacity 0.2s;
          background: rgba(0, 0, 0, 0.4);

          &:hover {
            opacity: 1;
          }

          span {
            cursor: pointer;
            color: #fff;
            font-size: 18px;
          }
        }
      }
    }

        .push-content {
      padding: 6px 12px 6px 12px;
      position: relative;

      .hot-tag {
        .tag-title-text {
          font-size: 0.875rem;
          color: #484848;
          margin: 0.125rem 0;
        }
        .hot-tag-item {
          cursor: pointer;
          margin: 0.3125rem 0.3125rem 0 0.3125rem;
        }
        :hover {
          transform: scale(1.2); /* 鼠标移入时按钮稍微放大 */
        }
      }

      .tag-list {
        margin: 0.825rem 0;
        .tag-item {
          margin-right: 0.3125rem;
        }
      }

      .scroll-tag-container {
        position: absolute;
        width: 98%;
        background-color: #fff;
        z-index: 99999;
        border: 1px solid #f4f4f4;
        height: 300px;
        overflow: auto;

        .scrollbar-tag-item {
          display: flex;
          align-items: center;
          height: 30px;
          margin: 10px;
          text-align: center;
          border-radius: 4px;
          padding-left: 2px;
          color: #484848;
          font-size: 14px;
        }

        .scrollbar-tag-item:hover {
          background-color: #f8f8f8;
        }
      }

      .input-title {
        margin-bottom: 12px;
        font-size: 15px;
      }

      .input-content {
        font-size: 12px;
      }

      .post-content:empty::before {
        content: attr(placeholder);
        color: #ccc;
        font-size: 14px;
      }

      .post-content {
        cursor: text;
        margin-top: 10px;
        width: 100%;
        min-height: 90px;
        max-height: 300px;
        margin-bottom: 10px;
        background: #fff;
        border: 1px solid #d9d9d9;
        border-radius: 4px;
        padding: 6px 12px 22px;
        outline: none;
        overflow-y: auto;
        text-rendering: optimizeLegibility;
        font-size: 14px;
        line-height: 22px;
      }

      .post-content:focus,
      .post-content:hover {
        border: 1px solid #3a64ff;
      }
    }

    .btns {
      padding: 5px 12px 10px 2px;

      button {
        min-width: 62px;
        width: 62px;
        margin: 0 6px 0 0;
        height: 18px;
      }

      .css-fm44j {
        -webkit-font-smoothing: antialiased;
        appearance: none;
        font-family:
          RedNum,
          RedZh,
          RedEn,
          -apple-system;
        vertical-align: middle;
        text-decoration: none;
        border: 1px solid rgb(217, 217, 217);
        outline: none;
        user-select: none;
        cursor: pointer;
        display: inline-flex;
        -webkit-box-pack: center;
        justify-content: center;
        -webkit-box-align: center;
        align-items: center;
        margin-right: 16px;
        border-radius: 4px;
        background-color: white;
        color: rgb(38, 38, 38);
        height: 24px;
        font-size: 12px;
      }
    }

    .categorys {
      padding: 0 12px 10px 12px;
    }

    .submit {
      padding: 10px 12px 10px 12px;
      margin-top: 10px;

      button {
        width: 100px;
        height: 36px;
        font-size: 15px;
        display: inline-block;
        margin-left: 250px;
        margin-bottom: 2px;
        cursor: pointer; /* 显示小手指针 */
        transition:
          background-color 0.3s,
          color 0.3s; /* 添加过渡效果 */
      }
      button:hover {
        transform: scale(1.05); /* 鼠标移入时按钮稍微放大 */
      }

      .publishBtn {
        background-color: #ff2442;
        color: #fff;
        border-radius: 24px;
      }

      .clearBtn {
        border-radius: 24px;
        margin-left: 10px;
        border: 1px solid rgb(217, 217, 217);
      }
    }
  }
}
</style>
