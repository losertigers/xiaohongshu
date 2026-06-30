<template>
  <div class="app-container home">
    <el-row :gutter="20">
      <!-- 项目介绍 -->
      <el-col :sm="24" :lg="12" style="padding-left: 20px">
        <h2><b>红薯后台管理系统</b></h2>
        <p>
          仿小红书设计的一个基于Springboot架构的前后端分离项目。
          <br />
          此项目基于Springboot+vue架构的前后端分离系统。
          <br />
          Web 端使用Vue3+ts+ElementUi，后端使用 SpringBoot +
          Mybatis-plus进行开发。
          <br />
          使用ElasticSearch作为全文检索服务。
          <br />
          使用webSocket做聊天和消息推送。
        </p>
        <p>
          <b>当前版本:</b> <span>v{{ version }}</span>
        </p>
      </el-col>

      <!-- 技术介绍 -->
      <el-col :sm="24" :lg="12" style="padding-left: 100px">
        <el-row>
          <el-col :span="12">
            <h2><b>技术选型</b></h2>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="6">
            <h4>后端技术</h4>
            <ul>
              <li>SpringBoot</li>
              <li>Spring Security</li>
              <li>JWT</li>
              <li>MyBatis</li>
              <li>Druid</li>
              <li>Fastjson</li>
              <li>...</li>
            </ul>
          </el-col>
          <el-col :span="6">
            <h4>前端技术</h4>
            <ul>
              <li>Vue</li>
              <li>Vuex</li>
              <li>Element-ui</li>
              <li>Axios</li>
              <li>Sass</li>
              <li>Quill</li>
              <li>...</li>
            </ul>
          </el-col>
        </el-row>
      </el-col>
    </el-row>
    <el-divider />


    <el-row :gutter="20">
      <!-- 联系信息 -->
      <!-- <el-col :xs="24" :sm="24" :md="12" :lg="8">
        <el-card class="update-log">
          <template v-slot:header>
            <div class="clearfix">
              <span>联系信息</span>
            </div>
          </template>
          <div class="body">
            <img
              src="@/assets/images/wx.png"
              alt="donate"
              class="center-img"
              style="width: 52%"
            />
            <span class="donate-text">备注：源码</span>
          </div>
        </el-card>
      </el-col> -->
    </el-row>
  </div>
</template>

<script setup name="Index">
const version = ref("1.0.0");

function goTarget(url) {
  window.open(url, "__blank");
}
</script>

<style scoped lang="scss">
.donate-text {
  display: inline-block;
  height: 28px;
  line-height: 30px;
  text-align: center;
  width: 100%;
  margin-top: 10px; /* 调整与图片的间距 */
}
.center-img {
  width: 50%;
  display: block;
  margin: 0 auto;
}
.home {
  blockquote {
    padding: 10px 20px;
    margin: 0 0 20px;
    font-size: 17.5px;
    border-left: 5px solid #eee;
  }
  hr {
    margin-top: 20px;
    margin-bottom: 20px;
    border: 0;
    border-top: 1px solid #eee;
  }
  .col-item {
    margin-bottom: 20px;
  }

  ul {
    padding: 0;
    margin: 0;
  }

  font-family: "open sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
  font-size: 15px;
  color: #555;
  overflow-x: hidden;

  ul {
    list-style-type: none;
  }

  h4 {
    margin-top: 0;
    margin-bottom: 12px;
    font-size: 16px;
    font-weight: 600;
    color: #333;
  }

  h2 {
    margin-top: 10px;
    font-size: 28px;
    font-weight: 600;
    color: #303133;
  }

  p {
    margin-top: 12px;
    line-height: 1.8;

    b {
      font-weight: 700;
    }
  }

  .update-log {
    ol {
      display: block;
      list-style-type: decimal;
      margin-block-start: 1em;
      margin-block-end: 1em;
      margin-inline-start: 0;
      margin-inline-end: 0;
      padding-inline-start: 40px;
    }
  }
}
</style>
