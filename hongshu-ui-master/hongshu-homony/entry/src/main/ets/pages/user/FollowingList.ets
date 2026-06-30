import { router, promptAction } from '@kit.ArkUI';
import { FollowApi } from '../../api/FollowApi';
import { FollowerItem } from '../../model/Follower';
import { TokenManager } from '../../common/TokenManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct FollowingListPage {
  @State followingList: FollowerItem[] = [];
  @State currentUid: string = '';
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.loadCurrentUser();
  }

  async loadCurrentUser() {
    this.currentUid = await TokenManager.getUserId(this.context);
    if (this.currentUid) {
      this.loadFollowing();
    }
  }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  async loadFollowing() {
    try {
      // type=1: 关注（我关注的人）
      const res = await FollowApi.getFriend(1, 50, 1);
      if (res.code === 200 && res.data && res.data.records) {
        this.followingList = res.data.records;
      }
    } catch (e) {
      const errMsg = (e instanceof Error) ? e.message : '未知错误';
      promptAction.showToast({ message: '加载失败：' + errMsg });
    }
  }

  async unfollow(index: number) {
    const item = this.followingList[index];
    try {
      const res = await FollowApi.clearFollow(item.uid);
      if (res && res.code === 200) {
        this.followingList[index].isfollow = false;
      }
    } catch (e) {
      const errMsg = (e instanceof Error) ? e.message : '未知错误';
      promptAction.showToast({ message: '操作失败：' + errMsg });
    }
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('关注').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      if (this.followingList.length === 0) {
        Text('暂无关注').fontSize(14).fontColor('#999').margin({ top: 40 }).width('100%').textAlign(TextAlign.Center)
      }
      List({ space: 0 }) {
        ForEach(this.followingList, (item: FollowerItem, index: number) => {
          ListItem() {
            Row() {
              Image(this.getSafeImage(item.avatar)).width(40).height(40).borderRadius(20).objectFit(ImageFit.Cover)
              Column() {
                Text(item.username).fontSize(14).fontWeight(FontWeight.Medium)
                Text(item.description || '').fontSize(12).fontColor('#999').margin({ top: 4 }).maxLines(1)
              }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
              Button(item.isfollow ? '已关注' : '关注')
                .height(30).fontSize(12).borderRadius(15)
                .backgroundColor(item.isfollow ? '#f0f0f0' : '#FF2442')
                .fontColor(item.isfollow ? '#666' : Color.White)
                .onClick(() => { this.unfollow(index); })
            }.padding(12).backgroundColor('#fff')
          }
        }, (item: FollowerItem, index: number) => index.toString())
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
