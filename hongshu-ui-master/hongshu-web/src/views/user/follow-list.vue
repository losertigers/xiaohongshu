<template>
  <el-dialog
    :model-value="visible"
    :title="listType === 1 ? '关注列表' : '粉丝列表'"
    width="32rem"
    @close="close"
    destroy-on-close
  >
    <div class="follow-list-container" v-infinite-scroll="loadMore">
      <div class="follow-item" v-for="(item, index) in dataList" :key="index">
        <a class="user-avatar" @click="toUser(item.uid)">
          <img class="avatar-item" :src="item.avatar" />
        </a>
        <div class="main">
          <div class="info">
            <div class="user-info">
              <a @click="toUser(item.uid)">{{ item.username }}</a>
            </div>
            <div class="user-desc" v-if="item.description">{{ item.description }}</div>
          </div>
          <div class="extra">
            <el-button
              class="follow-btn"
              type="danger"
              round
              size="small"
              v-if="item.isFollow"
              @click="follow(item.uid, index, 1)"
            >已关注</el-button>
            <el-button
              class="follow-btn"
              type="danger"
              round
              size="small"
              plain
              v-else
              @click="follow(item.uid, index, 0)"
            >关注</el-button>
          </div>
        </div>
      </div>
      <div class="empty-tip" v-if="dataList.length === 0 && loaded">
        {{ listType === 1 ? '还没有关注任何人' : '还没有粉丝' }}
      </div>
    </div>
  </el-dialog>
</template>

<script lang="ts" setup>
import { ref } from "vue";
import { getFriend, followById } from "@/api/follower";
import { useRouter } from "vue-router";

const router = useRouter();

const props = defineProps({
  visible: {
    type: Boolean,
    default: false,
  },
  uid: {
    type: String,
    default: "",
  },
  listType: {
    type: Number,
    default: 1, // 1: 关注列表, 0: 粉丝列表
  },
});

const emit = defineEmits(["update:visible"]);

const currentPage = ref(1);
const pageSize = 20;
const dataList = ref<Array<any>>([]);
const dataTotal = ref(0);
const loaded = ref(false);

const getPageData = () => {
  getFriend(currentPage.value, pageSize, props.listType, props.uid).then((res) => {
    const { records, total } = res.data;
    dataTotal.value = total;
    records.forEach((item: any) => {
      dataList.value.push(item);
    });
    loaded.value = true;
  });
};

const follow = (fid: string, index: number, type: number) => {
  followById(fid).then(() => {
    dataList.value[index].isFollow = type === 0;
  });
};

const loadMore = () => {
  if (dataList.value.length >= dataTotal.value) return;
  currentPage.value += 1;
  getPageData();
};

const toUser = (uid: string) => {
  close();
  router.push({ name: "user", query: { uid: uid } });
};

const close = () => {
  emit("update:visible", false);
};

// 重置并加载数据
const resetAndLoad = () => {
  currentPage.value = 1;
  dataList.value = [];
  loaded.value = false;
  getPageData();
};

// 监听 visible 变化来加载数据
import { watch } from "vue";
watch(
  () => props.visible,
  (val) => {
    if (val) {
      resetAndLoad();
    }
  }
);
</script>

<style lang="less" scoped>
.follow-list-container {
  max-height: 60vh;
  overflow-y: auto;

  .follow-item {
    display: flex;
    align-items: center;
    padding: 0.75rem 0;
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);

    .user-avatar {
      flex-shrink: 0;
      margin-right: 0.75rem;
      cursor: pointer;

      .avatar-item {
        width: 3rem;
        height: 3rem;
        border-radius: 50%;
        border: 1px solid rgba(0, 0, 0, 0.08);
        object-fit: cover;
      }
    }

    .main {
      flex-grow: 1;
      display: flex;
      align-items: center;
      justify-content: space-between;

      .info {
        flex-grow: 1;
        min-width: 0;

        .user-info {
          a {
            color: #333;
            font-size: 0.9375rem;
            font-weight: 600;
            cursor: pointer;
          }
          a:hover {
            color: #ff2e4d;
          }
        }

        .user-desc {
          font-size: 0.75rem;
          color: rgba(51, 51, 51, 0.6);
          margin-top: 0.25rem;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
      }

      .extra {
        flex-shrink: 0;
        margin-left: 1rem;

        .follow-btn {
          min-width: 5rem;
        }
      }
    }
  }

  .empty-tip {
    text-align: center;
    padding: 2rem 0;
    color: rgba(51, 51, 51, 0.4);
    font-size: 0.875rem;
  }
}
</style>
