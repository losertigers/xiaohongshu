import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { TokenManager } from '../common/TokenManager';
import { HttpUtil } from '../common/HttpUtil';
import { NoteApi } from '../api/NoteApi';
import { UserApi } from '../api/UserApi';
import { NoteItem } from '../model/Note';
import { UserInfo } from '../model/User';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @State noteList: NoteItem[] = [];
  @State currentPage: number = 1;
  @State loading: boolean = false;
  @State userInfo: UserInfo = new UserInfo();
  @State isLoggedIn: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() { this.initLogin(); }

  async initLogin() {
    const token = await TokenManager.getToken(this.context);
    if (token) {
      HttpUtil.setToken(token);
      const userId = await TokenManager.getUserId(this.context);
      if (userId) {
        HttpUtil.setUserId(userId);
        this.isLoggedIn = true;
        this.loadUserInfo();
      }
      this.loadNotes();
    }
  }

  async loadUserInfo() {
    try {
      const infoStr = await TokenManager.getUserInfo(this.context);
      if (infoStr) { this.userInfo = JSON.parse(infoStr) as UserInfo; }
    } catch (e) {}
  }

  async loadNotes() {
    if (this.loading) return;
    this.loading = true;
    try {
      const res = await NoteApi.getRecommendNote(this.currentPage, 10);
      if (res.code === 200 && res.data && res.data.records) {
        this.noteList = this.noteList.concat(res.data.records);
        this.currentPage++;
      }
    } catch (e) { console.error('loadNotes error:', e); }
    this.loading = false;
  }

  @Builder
  tabBuilder(label: string, index: number) {
    Column() {
      Text(label).fontSize(12)
        .fontColor(this.currentIndex === index ? '#FF2442' : '#999')
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
    }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
     .onClick(() => { this.currentIndex = index; })
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() { this.homeContent() }.tabBar(this.tabBuilder('首页', 0))
        TabContent() { this.discoverContent() }.tabBar(this.tabBuilder('动态', 1))
        TabContent() { this.publishContent() }.tabBar(this.tabBuilder('发布', 2))
        TabContent() { this.messageContent() }.tabBar(this.tabBuilder('消息', 3))
        TabContent() { this.mineContent() }.tabBar(this.tabBuilder('我', 4))
      }.onChange((index: number) => { this.currentIndex = index; })
       .barHeight(56).scrollable(false).barMode(BarMode.Fixed)
       .width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }

  @Builder homeContent() {
    Column() {
      Row() {
        Text('搜索').fontSize(14).fontColor('#bfbfbf').layoutWeight(1)
      }.width('95%').height(36).borderRadius(18).backgroundColor('#f5f5f5').padding({ left: 16 })
       .margin({ top: 8, bottom: 8 }).justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
       .onClick(() => { router.pushUrl({ url: 'pages/search/Search' }); })
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.noteList, (note: NoteItem) => {
            this.noteCard(note)
          })
        }.width('100%').padding(8)
      }.width('100%').layoutWeight(1).onReachEnd(() => { this.loadNotes(); })
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }

  @Builder noteCard(note: NoteItem) {
    Column() {
      Image(this.getImageSrc(note.noteCover))
        .width('100%').height(note.noteCoverHeight > 0 ? note.noteCoverHeight : 200)
        .objectFit(ImageFit.Cover).borderRadius(8)
        .onClick(() => { router.pushUrl({ url: 'pages/note/NoteDetail?noteId=' + note.id }); })
      Text(note.title).fontSize(14).fontWeight(FontWeight.Medium).maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 6 }).width('100%')
      Row() {
        Image(this.getImageSrc(note.avatar)).width(20).height(20).borderRadius(10).objectFit(ImageFit.Cover)
        Text(note.username).fontSize(12).fontColor('#666').margin({ left: 4 }).layoutWeight(1)
        Text(note.isLike ? '❤' : '♡').fontSize(14).fontColor(note.isLike ? 'red' : '#999')
        Text(note.likeCount.toString()).fontSize(12).fontColor('#999').margin({ left: 2 })
      }.width('100%').margin({ top: 6 }).alignItems(VerticalAlign.Center)
    }.width('48%').padding(8).backgroundColor('#fff').borderRadius(12).margin({ bottom: 8 })
  }

  @Builder discoverContent() {
    Column() {
      Text('关注动态').fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 16, left: 16 })
      Text('关注的人发布的内容将在此展示')
        .fontSize(14).fontColor('#999').margin({ top: 20 }).width('100%').textAlign(TextAlign.Center)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }

  @Builder publishContent() {
    Column() {
      Text('发布内容').fontSize(18).margin({ top: 40 })
      Row() {
        Button('发布图文').width(120).height(80).borderRadius(12)
          .backgroundColor('#FF2442').fontColor(Color.White).fontSize(14).margin({ right: 16 })
          .onClick(() => { router.pushUrl({ url: 'pages/publish/Publish' }); })
        Button('发布视频').width(120).height(80).borderRadius(12)
          .backgroundColor('#3a64ff').fontColor(Color.White).fontSize(14)
          .onClick(() => { router.pushUrl({ url: 'pages/publish/Publish' }); })
      }.margin({ top: 24 })
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
     .justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Center)
  }

  @Builder messageContent() {
    Column() {
      Text('消息').fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 16, left: 16 })
      List({ space: 8 }) {
        ListItem() { this.msgItem('私信', () => { router.pushUrl({ url: 'pages/chat/Chat' }); }) }
        ListItem() { this.msgItem('评论', () => {}) }
        ListItem() { this.msgItem('点赞收藏', () => {}) }
        ListItem() { this.msgItem('新关注', () => {}) }
      }.width('100%').padding(12)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }

  @Builder msgItem(title: string, onClick: () => void) {
    Row() {
      Text(title).fontSize(15).layoutWeight(1)
      Text('>').fontSize(14).fontColor('#ccc')
    }.width('100%').height(56).padding({ left: 16, right: 16 }).backgroundColor('#fff')
     .borderRadius(8).onClick(onClick)
  }

  getImageSrc(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  @Builder mineContent() {
    Column() {
      if (this.isLoggedIn) {
        Row() {
          Image(this.getImageSrc(this.userInfo.avatar)).width(60).height(60).borderRadius(30).objectFit(ImageFit.Cover)
          Column() {
            Text(this.userInfo.username || '用户').fontSize(18).fontWeight(FontWeight.Bold)
            Text(this.userInfo.description || '这个人很懒，什么都没写').fontSize(13).fontColor('#999').margin({ top: 4 })
          }.margin({ left: 16 }).layoutWeight(1).alignItems(HorizontalAlign.Start)
        }.width('100%').height(100).padding({ left: 20, right: 20 }).backgroundColor('#fff')
         .alignItems(VerticalAlign.Center)
        Row() {
          Column() {
            Text(this.userInfo.trendCount.toString()).fontSize(16).fontWeight(FontWeight.Bold)
            Text('作品').fontSize(12).fontColor('#999').margin({ top: 4 })
          }.layoutWeight(1)
          Column() {
            Text(this.userInfo.fansCount.toString()).fontSize(16).fontWeight(FontWeight.Bold)
            Text('粉丝').fontSize(12).fontColor('#999').margin({ top: 4 })
          }.layoutWeight(1)
          Column() {
            Text(this.userInfo.followCount.toString()).fontSize(16).fontWeight(FontWeight.Bold)
            Text('关注').fontSize(12).fontColor('#999').margin({ top: 4 })
          }.layoutWeight(1)
          Column() {
            Text(this.userInfo.likeCount.toString()).fontSize(16).fontWeight(FontWeight.Bold)
            Text('获赞').fontSize(12).fontColor('#999').margin({ top: 4 })
          }.layoutWeight(1)
        }.width('100%').height(70).backgroundColor('#fff').margin({ top: 1 })
      } else {
        Row() {
          Column() {
            Text('登录/注册').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#FF2442')
              .onClick(() => { router.pushUrl({ url: 'pages/login/Login' }); })
          }.margin({ left: 20 })
        }.width('100%').height(120).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      }
      List({ space: 0 }) {
        ListItem() { this.menuItem('我的专辑', () => {}) }
        ListItem() { this.menuItem('浏览记录', () => {}) }
        ListItem() { this.menuItem('编辑资料', () => { router.pushUrl({ url: 'pages/userinfo/UserInfo' }); }) }
        ListItem() { this.menuItem('设置', () => { router.pushUrl({ url: 'pages/setting/Setting' }); }) }
      }.width('100%').margin({ top: 12 })
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }

  @Builder menuItem(title: string, onClick: () => void) {
    Row() {
      Text(title).fontSize(15).layoutWeight(1)
      Text('>').fontSize(14).fontColor('#ccc')
    }.width('100%').height(52).padding({ left: 20, right: 20 }).backgroundColor('#fff').onClick(onClick)
  }
}
