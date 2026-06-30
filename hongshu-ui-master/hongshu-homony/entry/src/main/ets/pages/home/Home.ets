import { router } from '@kit.ArkUI';
import { NoteApi } from '../../api/NoteApi';
import { NoteItem } from '../../model/Note';

@Component
struct NoteCard {
  @Prop note: NoteItem = new NoteItem();
  build() {
    Column() {
      Image(this.note.noteCover)
        .width('100%').height(this.note.noteCoverHeight > 0 ? this.note.noteCoverHeight : 200)
        .objectFit(ImageFit.Cover).borderRadius(8)
        .onClick(() => { router.pushUrl({ url: 'pages/note/NoteDetail?noteId=' + this.note.id }); })
      Text(this.note.title).fontSize(14).fontWeight(FontWeight.Medium).maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 6 }).width('100%')
      Row() {
        Image(this.note.avatar).width(20).height(20).borderRadius(10)
        Text(this.note.username).fontSize(12).fontColor('#666').margin({ left: 4 }).layoutWeight(1)
        Text(this.note.isLike ? '❤' : '♡').fontSize(14).fontColor(this.note.isLike ? 'red' : '#999')
        Text(this.note.likeCount.toString()).fontSize(12).fontColor('#999').margin({ left: 2 })
      }.width('100%').margin({ top: 6 }).alignItems(VerticalAlign.Center)
    }.width('48%').padding(8).backgroundColor('#fff').borderRadius(12)
  }
}

@Entry
@Component
struct HomePage {
  @State noteList: NoteItem[] = [];
  @State currentPage: number = 1;
  @State loading: boolean = false;

  aboutToAppear() { this.loadData(); }

  async loadData() {
    if (this.loading) return;
    this.loading = true;
    try {
      const res = await NoteApi.getRecommendNote(this.currentPage, 10);
      if (res.code === 200 && res.data && res.data.records) {
        this.noteList = this.noteList.concat(res.data.records);
        this.currentPage++;
      }
    } catch (e) { console.error('loadData error:', e); }
    this.loading = false;
  }

  build() {
    Column() {
      Row() {
        Text('搜索').fontSize(14).fontColor('#bfbfbf').layoutWeight(1)
      }.width('95%').height(36).borderRadius(18).backgroundColor('#f5f5f5').padding({ left: 16 })
       .margin({ top: 8, bottom: 8 }).justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Center)
       .onClick(() => { router.pushUrl({ url: 'pages/search/Search' }); })
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.noteList, (note: NoteItem) => {
            NoteCard({ note: note }).margin({ bottom: 8 })
          })
        }.width('100%').padding(8)
      }.width('100%').layoutWeight(1).onReachEnd(() => { this.loadData(); })
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
