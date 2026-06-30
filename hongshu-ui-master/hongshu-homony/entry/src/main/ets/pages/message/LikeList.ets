import { router } from '@kit.ArkUI';
import { LikeApi } from '../../api/LikeApi';
import { LikeItem } from '../../model/Like';
import { TokenManager } from '../../common/TokenManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct LikeListPage {
  @State likeList: LikeItem[] = [];
  @State currentUid: string = '';
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.loadCurrentUser();
    this.loadLikes();
  }

  async loadCurrentUser() {
    this.currentUid = await TokenManager.getUserId(this.context);
  }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  async loadLikes() {
    try {
      const res = await LikeApi.getNoticeLikeOrCollection(1, 50);
      if (res.code === 200 && res.data && res.data.records) {
        this.likeList = res.data.records;
      }
    } catch (e) {}
  }

  getTypeText(type: number): string {
    switch (type) {
      case 0: return '点赞您的评论';
      case 1: return '点赞您的笔记';
      case 2: return '收藏您的笔记';
      case 3: return '收藏您的专辑';
      default: return '互动';
    }
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('赞和收藏').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      if (this.likeList.length === 0) {
        Text('暂无点赞收藏通知').fontSize(14).fontColor('#999').margin({ top: 40 }).width('100%').textAlign(TextAlign.Center)
      }
      List({ space: 0 }) {
        ForEach(this.likeList, (item: LikeItem, index: number) => {
          ListItem() {
            Row() {
              Image(this.getSafeImage(item.avatar)).width(40).height(40).borderRadius(20).objectFit(ImageFit.Cover)
              Column() {
                Row() {
                  Text(item.username).fontSize(14).fontWeight(FontWeight.Medium).layoutWeight(1)
                  Text(item.createTime || '').fontSize(11).fontColor('#ccc')
                }.width('100%')
                Text(this.getTypeText(item.type)).fontSize(12).fontColor('#666').margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
            }.padding(12).backgroundColor('#fff')
             .onClick(() => {
               if (item.likeOrCollectionId) {
                 router.pushUrl({ url: 'pages/note/NoteDetail', params: { noteId: item.likeOrCollectionId } });
               }
             })
          }
        }, (item: LikeItem, index: number) => index.toString())
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
