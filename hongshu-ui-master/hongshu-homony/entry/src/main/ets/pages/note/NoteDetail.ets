import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { NoteApi } from '../../api/NoteApi';
import { CommentApi } from '../../api/CommentApi';
import { LikeApi } from '../../api/LikeApi';
import { NoteItem } from '../../model/Note';
import { CommentItem, CommentPage } from '../../model/Comment';

@Entry
@Component
struct NoteDetailPage {
  @State note: NoteItem = new NoteItem();
  @State commentList: CommentItem[] = [];
  @State commentText: string = '';
  @State images: string[] = [];
  @State currentIdx: number = 0;
  private noteId: string = '';

  aboutToAppear() {
    const params: Record<string, string> = router.getParams() as object as Record<string, string>;
    this.noteId = params?.['noteId'] ?? '';
    if (this.noteId) { this.loadNote(); this.loadComments(); }
  }

  async loadNote() {
    try {
      const res = await NoteApi.getNoteById(this.noteId);
      if (res.code === 200 && res.data) {
        this.note = res.data;
        if (this.note.urls) {
          const parsed: string[] = JSON.parse(this.note.urls) as string[];
          this.images = parsed;
        }
      }
    } catch (e) {}
  }

  async loadComments() {
    try {
      const res = await CommentApi.getCommentWithCommentByNoteId(1, 50, this.noteId);
      if (res.code === 200 && res.data) {
        const d: CommentPage = res.data as CommentPage;
        this.commentList = d.records ?? [];
      }
    } catch (e) {}
  }

  async doComment() {
    if (!this.commentText.trim()) { promptAction.showToast({ message: '请输入评论' }); return; }
    try {
      await CommentApi.saveComment({ nid: this.noteId, content: this.commentText });
      this.commentText = '';
      promptAction.showToast({ message: '评论成功' });
      this.loadComments();
    } catch (e) { promptAction.showToast({ message: '评论失败' }); }
  }

  async doLike() {
    try {
      await LikeApi.likeOrCollectionByDTO({ likeOrCollectionId: this.noteId, type: 1 });
      this.note.isLike = !this.note.isLike;
      this.note.likeCount += this.note.isLike ? 1 : -1;
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text(this.note.username).fontSize(16).fontWeight(FontWeight.Medium).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).alignItems(VerticalAlign.Center)
      Scroll() {
        Column() {
          if (this.images.length > 0) {
            Swiper() {
              ForEach(this.images, (url: string) => {
                Image(url).width('100%').aspectRatio(1).objectFit(ImageFit.Cover)
              })
            }.width('100%').aspectRatio(1).index(this.currentIdx)
             .onChange((index: number) => { this.currentIdx = index; })
          } else if (this.note.noteCover) {
            Image(this.note.noteCover).width('100%').aspectRatio(1).objectFit(ImageFit.Cover)
          }
          Text(this.note.title).fontSize(20).fontWeight(FontWeight.Bold)
            .margin({ top: 12, left: 16, right: 16 }).width('100%')
          Text(this.note.content).fontSize(14).fontColor('#333')
            .margin({ top: 8, left: 16, right: 16 }).width('100%')
          Row() {
            Image(this.note.avatar).width(36).height(36).borderRadius(18)
            Text(this.note.username).fontSize(14).fontWeight(FontWeight.Medium).margin({ left: 8 })
          }.padding(16).width('100%')
          Divider()
          Text('评论 (' + this.commentList.length + ')').fontSize(16).fontWeight(FontWeight.Bold)
            .margin({ top: 12, left: 16, bottom: 8 })
          ForEach(this.commentList, (comment: CommentItem) => {
            Row() {
              Image(comment.avatar).width(32).height(32).borderRadius(16)
              Column() {
                Text(comment.username).fontSize(13).fontColor('#999')
                Text(comment.content).fontSize(14).margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start).margin({ left: 8 }).layoutWeight(1)
            }.padding({ left: 16, right: 16, top: 8, bottom: 8 }).width('100%')
          })
        }
      }.layoutWeight(1).width('100%')
      Row() {
        TextInput({ placeholder: '说点什么...', text: this.commentText })
          .layoutWeight(1).height(36).borderRadius(18).onChange((v: string) => { this.commentText = v; })
        Text(this.note.isLike ? '❤' + this.note.likeCount : '♡' + this.note.likeCount)
          .fontSize(14).margin({ left: 12 }).onClick(() => { this.doLike(); })
        Button('发送').height(36).fontSize(13).borderRadius(18)
          .backgroundColor('#FF2442').fontColor(Color.White).margin({ left: 8 })
          .onClick(() => { this.doComment(); })
      }.width('100%').height(56).padding({ left: 12, right: 12 }).backgroundColor('#fff')
       .border({ width: { top: 0.5 }, color: '#eee' })
    }.width('100%').height('100%').backgroundColor('#fff')
  }
}
