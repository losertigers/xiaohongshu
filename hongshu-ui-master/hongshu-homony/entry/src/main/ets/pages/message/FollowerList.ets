import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { FollowApi } from '../../api/FollowApi';
import { FollowerItem } from '../../model/Follower';
import { TokenManager } from '../../common/TokenManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct FollowerListPage {
  @State followerList: FollowerItem[] = [];
  @State currentUid: string = '';
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.loadCurrentUser();
    this.loadFollowers();
  }

  async loadCurrentUser() {
    this.currentUid = await TokenManager.getUserId(this.context);
  }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  async loadFollowers() {
    try {
      const res = await FollowApi.getFriend(1, 50, 0); // type=0: 新增关注（粉丝）
      if (res.code === 200 && res.data && res.data.records) {
        const list: FollowerItem[] = [];
        const records = res.data.records;
        for (let i = 0; i < records.length; i++) {
          const item = records[i];
          const newItem = new FollowerItem();
          newItem.id = item.id;
          newItem.uid = item.uid;
          newItem.username = item.username;
          newItem.avatar = item.avatar;
          newItem.description = item.description;
          newItem.time = item.time;
          newItem.isfollow = item.isFollow !== undefined ? Boolean(item.isFollow) : Boolean(item.isfollow);
          list.push(newItem);
        }
        this.followerList = list;
      }
    } catch (e) {
      const errMsg = (e instanceof Error) ? e.message : '未知错误';
      promptAction.showToast({ message: '加载失败：' + errMsg });
    }
  }

  async toggleFollow(index: number) {
    const item = this.followerList[index];
    try {
      if (item.isfollow) {
        const res = await FollowApi.clearFollow(item.uid);
        if (res && res.code === 200) {
          this.followerList[index].isfollow = false;
        } else {
          promptAction.showToast({ message: res?.message || '取消关注失败' });
        }
      } else {
        const res = await FollowApi.followUser(item.uid);
        if (res && res.code === 200) {
          this.followerList[index].isfollow = true;
        } else {
          promptAction.showToast({ message: res?.message || '关注失败' });
        }
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
        Text('新增关注').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      if (this.followerList.length === 0) {
        Text('暂无新关注').fontSize(14).fontColor('#999').margin({ top: 40 }).width('100%').textAlign(TextAlign.Center)
      }
      List({ space: 0 }) {
        ForEach(this.followerList, (item: FollowerItem, index: number) => {
          ListItem() {
            Row() {
              Image(this.getSafeImage(item.avatar)).width(40).height(40).borderRadius(20).objectFit(ImageFit.Cover)
              Column() {
                Text(item.username).fontSize(14).fontWeight(FontWeight.Medium)
                Text('开始关注您了').fontSize(12).fontColor('#999').margin({ top: 4 })
                Text(item.time || '').fontSize(11).fontColor('#ccc').margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
              Button(item.isfollow ? '已关注' : '关注')
                .height(30).fontSize(12).borderRadius(15)
                .backgroundColor(item.isfollow ? '#f0f0f0' : '#FF2442')
                .fontColor(item.isfollow ? '#666' : Color.White)
                .onClick(() => { this.toggleFollow(index); })
            }.padding(12).backgroundColor('#fff')
          }
        }, (item: FollowerItem, index: number) => index.toString())
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
