import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { NoteApi } from '../../api/NoteApi';
import { CommentApi } from '../../api/CommentApi';
import { LikeApi } from '../../api/LikeApi';
import { FollowApi } from '../../api/FollowApi';
import { NoteItem } from '../../model/Note';
import { CommentItem, CommentPage } from '../../model/Comment';
import { TokenManager } from '../../common/TokenManager';
import { Constants } from '../../common/Constants';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct NoteDetailPage {
  @State note: NoteItem = new NoteItem();
  @State commentList: CommentItem[] = [];
  @State commentText: string = '';
  @State images: string[] = [];
  @State videoSrc: string = '';
  @State currentIdx: number = 0;
  @State isFollowed: boolean = false;
  @State currentUid: string = '';
  private noteId: string = '';
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    const params: Record<string, string> = router.getParams() as object as Record<string, string>;
    this.noteId = params?.['noteId'] ?? '';
    if (this.noteId) {
      this.loadCurrentUser();
      this.loadNote();
      this.loadComments();
    }
  }

  async loadCurrentUser() {
    this.currentUid = await TokenManager.getUserId(this.context);
  }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) {
      if (url.startsWith('http')) { return url; }
      return Constants.BASE_URL + url;
    }
    return $r('app.media.startIcon');
  }

  async loadNote() {
    try {
      const res = await NoteApi.getNoteById(this.noteId);
      if (res.code === 200 && res.data) {
        this.note = res.data;
        try {
          if (this.note.urls) {
            const parsed: string[] = JSON.parse(this.note.urls) as string[];
            const firstUrl = parsed.length > 0 ? parsed[0] : '';
            if (this.note.noteType === '1' && this.isVideoUrl(firstUrl)) {
              this.videoSrc = firstUrl;
              this.images = [];
            } else {
              this.videoSrc = '';
              this.images = parsed;
            }
          } else {
            this.videoSrc = '';
            this.images = [];
          }
        } catch (parseErr) {
          this.videoSrc = '';
          this.images = [];
        }
        // Check follow status
        if (this.note.uid && this.note.uid !== this.currentUid) {
          this.checkFollow();
        }
      }
    } catch (e) {
      promptAction.showToast({ message: '加载笔记失败' });
    }
  }

  async checkFollow() {
    try {
      const res = await FollowApi.isFollow(this.note.uid);
      if (res.code === 200) {
        this.isFollowed = res.data === true;
      }
    } catch (e) {
      promptAction.showToast({ message: '查询关注状态失败' });
    }
  }

  private isVideoUrl(url: string): boolean {
    if (!url) {
      return false;
    }
    const lower = url.toLowerCase();
    return lower.indexOf('.mp4') !== -1 || lower.indexOf('.webm') !== -1 || lower.indexOf('.ogg') !== -1 || lower.indexOf('.mov') !== -1 || lower.indexOf('.m4v') !== -1 || lower.indexOf('.avi') !== -1 || lower.indexOf('.flv') !== -1 || lower.indexOf('.wmv') !== -1;
  }

  async toggleFollow() {
    if (!this.note.uid) return;
    try {
      if (this.isFollowed) {
        const res = await FollowApi.clearFollow(this.note.uid);
        if (res && res.code === 200) {
          this.isFollowed = false;
          promptAction.showToast({ message: '已取消关注' });
        } else {
          promptAction.showToast({ message: res?.message || '取消关注失败' });
        }
      } else {
        const res = await FollowApi.followUser(this.note.uid);
        if (res && res.code === 200) {
          this.isFollowed = true;
          promptAction.showToast({ message: '已关注' });
        } else {
          promptAction.showToast({ message: res?.message || '关注失败' });
        }
      }
    } catch (e) {
      const errMsg = (e instanceof Error) ? e.message : '未知错误';
      promptAction.showToast({ message: '操作失败：' + errMsg });
    }
  }

  async loadComments() {
    try {
      const res = await CommentApi.getCommentWithCommentByNoteId(1, 50, this.noteId);
      if (res.code === 200 && res.data) {
        const d: CommentPage = res.data as CommentPage;
        this.commentList = d.records ?? [];
      }
    } catch (e) {
      promptAction.showToast({ message: '加载评论失败' });
    }
  }

  async doComment() {
    if (!this.commentText.trim()) { promptAction.showToast({ message: '请输入评论' }); return; }
    if (!this.currentUid) { promptAction.showToast({ message: '请先登录' }); return; }
    try {
      const res = await CommentApi.saveComment({
        nid: this.noteId,
        noteUid: this.note.uid,
        content: this.commentText,
        pid: '0',
        replyId: '0',
        replyUid: '0',
        level: 1
      });
      if (res && res.code === 200) {
        const commentData: CommentItem = res.data;
        if (commentData && commentData.id) {
          await CommentApi.syncCommentByIds([commentData.id]);
        }
        this.commentText = '';
        promptAction.showToast({ message: '评论成功' });
        this.loadComments();
      } else {
        promptAction.showToast({ message: res?.message || '评论失败' });
      }
    } catch (e) {
      const errMsg = (e instanceof Error) ? e.message : '未知错误';
      promptAction.showToast({ message: '评论失败：' + errMsg });
    }
  }

  async doLike() {
    if (!this.currentUid) { promptAction.showToast({ message: '请先登录' }); return; }
    try {
      // 对齐安卓端字段
      await LikeApi.likeOrCollectionByDTO({
        uid: this.currentUid,
        type: 1,
        likeOrCollectionId: this.noteId,
        publishUid: this.note.uid
      });
      this.note.isLike = !this.note.isLike;
      this.note.likeCount += this.note.isLike ? 1 : -1;
    } catch (e) {
      promptAction.showToast({ message: '点赞失败' });
    }
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text(this.note.username || '笔记详情').fontSize(16).fontWeight(FontWeight.Medium).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).alignItems(VerticalAlign.Center)
      Scroll() {
        Column() {
          if (this.videoSrc) {
            Video({ src: this.videoSrc }).width('100%').aspectRatio(1).backgroundColor(Color.Black).controls(true)
          } else if (this.images.length > 0) {
            Swiper() {
              ForEach(this.images, (url: string, index: number) => {
                Image(this.getSafeImage(url)).width('100%').aspectRatio(1).objectFit(ImageFit.Cover)
              }, (url: string, index: number) => index.toString())
            }.width('100%').aspectRatio(1).index(this.currentIdx)
             .onChange((index: number) => { this.currentIdx = index; })
          } else if (this.note.noteCover && this.note.noteCover.length > 0) {
            Image(this.note.noteCover).width('100%').aspectRatio(1).objectFit(ImageFit.Cover)
          }
          Text(this.note.title).fontSize(20).fontWeight(FontWeight.Bold)
            .margin({ top: 12, left: 16, right: 16 }).width('100%')
          Text(this.note.content).fontSize(14).fontColor('#333')
            .margin({ top: 8, left: 16, right: 16 }).width('100%')
          // Author info + follow button
          Row() {
            Image(this.getSafeImage(this.note.avatar)).width(36).height(36).borderRadius(18).objectFit(ImageFit.Cover)
            Text(this.note.username).fontSize(14).fontWeight(FontWeight.Medium).margin({ left: 8 }).layoutWeight(1)
            if (this.note.uid && this.note.uid !== this.currentUid) {
              Button(this.isFollowed ? '已关注' : '关注')
                .height(30).fontSize(13).borderRadius(15)
                .backgroundColor(this.isFollowed ? '#f0f0f0' : '#FF2442')
                .fontColor(this.isFollowed ? '#666' : Color.White)
                .onClick(() => { this.toggleFollow(); })
            }
          }.padding(16).width('100%').alignItems(VerticalAlign.Center)
          Divider()
          Text('评论 (' + this.commentList.length + ')').fontSize(16).fontWeight(FontWeight.Bold)
            .margin({ top: 12, left: 16, bottom: 8 })
          ForEach(this.commentList, (comment: CommentItem, index: number) => {
            Row() {
              Image(this.getSafeImage(comment.avatar)).width(32).height(32).borderRadius(16).objectFit(ImageFit.Cover)
              Column() {
                Text(comment.username).fontSize(13).fontColor('#999')
                Text(comment.content).fontSize(14).margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start).margin({ left: 8 }).layoutWeight(1)
            }.padding({ left: 16, right: 16, top: 8, bottom: 8 }).width('100%')
          }, (comment: CommentItem, index: number) => index.toString())
        }
      }.layoutWeight(1).width('100%')
      Row() {
        TextInput({ placeholder: '说点什么...', text: this.commentText })
          .layoutWeight(1).height(36).borderRadius(18).onChange((v: string) => { this.commentText = v; })
        Text(this.note.isLike ? '❤ ' + this.note.likeCount : '♡ ' + this.note.likeCount)
          .fontSize(14).margin({ left: 12 }).onClick(() => { this.doLike(); })
        Button('发送').height(36).fontSize(13).borderRadius(18)
          .backgroundColor('#FF2442').fontColor(Color.White).margin({ left: 8 })
          .onClick(() => { this.doComment(); })
      }.width('100%').height(56).padding({ left: 12, right: 12 }).backgroundColor('#fff')
       .border({ width: { top: 0.5 }, color: '#eee' })
    }.width('100%').height('100%').backgroundColor('#fff')
  }
}
