import { router } from '@kit.ArkUI';
import { CommentApi } from '../../api/CommentApi';
import { CommentItem } from '../../model/Comment';
import { TokenManager } from '../../common/TokenManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct CommentListPage {
  @State commentList: CommentItem[] = [];
  @State currentUid: string = '';
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.loadCurrentUser();
    this.loadComments();
  }

  async loadCurrentUser() {
    this.currentUid = await TokenManager.getUserId(this.context);
  }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  async loadComments() {
    try {
      const res = await CommentApi.getNoticeComment(1, 50);
      if (res.code === 200 && res.data && res.data.records) {
        this.commentList = res.data.records;
      }
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('评论和@').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      if (this.commentList.length === 0) {
        Text('暂无评论通知').fontSize(14).fontColor('#999').margin({ top: 40 }).width('100%').textAlign(TextAlign.Center)
      }
      List({ space: 0 }) {
        ForEach(this.commentList, (comment: CommentItem, index: number) => {
          ListItem() {
            Row() {
              Image(this.getSafeImage(comment.avatar)).width(40).height(40).borderRadius(20).objectFit(ImageFit.Cover)
              Column() {
                Row() {
                  Text(comment.username).fontSize(14).fontWeight(FontWeight.Medium).layoutWeight(1)
                  Text(comment.createTime || '').fontSize(11).fontColor('#ccc')
                }.width('100%')
                Text(comment.content).fontSize(13).fontColor('#333').margin({ top: 4 }).maxLines(2)
              }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
            }.padding(12).backgroundColor('#fff')
             .onClick(() => {
               if (comment.nid) {
                 router.pushUrl({ url: 'pages/note/NoteDetail', params: { noteId: comment.nid } });
               }
             })
          }
        }, (comment: CommentItem, index: number) => index.toString())
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
