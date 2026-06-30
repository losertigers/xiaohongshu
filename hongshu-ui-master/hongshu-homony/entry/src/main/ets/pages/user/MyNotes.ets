import { router } from '@kit.ArkUI';
import { UserApi } from '../../api/UserApi';
import { NoteItem } from '../../model/Note';
import { TokenManager } from '../../common/TokenManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct MyNotesPage {
  @State noteList: NoteItem[] = [];
  @State currentUid: string = '';
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.loadCurrentUser();
  }

  async loadCurrentUser() {
    this.currentUid = await TokenManager.getUserId(this.context);
    if (this.currentUid) {
      this.loadMyNotes();
    }
  }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  async loadMyNotes() {
    try {
      const res = await UserApi.getTrendByUser(1, 50, this.currentUid, 1);
      if (res.code === 200 && res.data && res.data.records) {
        this.noteList = res.data.records;
      }
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('我的作品').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      if (this.noteList.length === 0) {
        Text('暂无作品').fontSize(14).fontColor('#999').margin({ top: 40 }).width('100%').textAlign(TextAlign.Center)
      }
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.noteList, (note: NoteItem, index: number) => {
            Column() {
              Image(this.getSafeImage(note.noteCover))
                .width('100%').height(note.noteCoverHeight > 0 ? note.noteCoverHeight : 200)
                .objectFit(ImageFit.Cover).borderRadius(8)
              Text(note.title).fontSize(14).fontWeight(FontWeight.Medium).maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 6 }).width('100%')
              Row() {
                Text(note.isLike ? '❤' : '♡').fontSize(14).fontColor(note.isLike ? 'red' : '#999')
                Text(note.likeCount.toString()).fontSize(12).fontColor('#999').margin({ left: 2 })
              }.width('100%').margin({ top: 6 }).alignItems(VerticalAlign.Center)
            }.width('48%').padding(8).backgroundColor('#fff').borderRadius(12).margin({ bottom: 8 })
             .onClick(() => {
               router.pushUrl({ url: 'pages/note/NoteDetail', params: { noteId: note.id } });
             })
          }, (note: NoteItem, index: number) => index.toString())
        }.width('100%').padding(8)
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
