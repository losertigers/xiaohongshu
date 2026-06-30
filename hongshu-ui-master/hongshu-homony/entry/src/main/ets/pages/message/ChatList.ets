import { router } from '@kit.ArkUI';
import { ChatApi } from '../../api/ChatApi';
import { ChatUser } from '../../model/Chat';

@Entry
@Component
struct ChatListPage {
  @State chatUsers: ChatUser[] = [];

  aboutToAppear() { this.loadChatUsers(); }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  async loadChatUsers() {
    try {
      const res = await ChatApi.getChatUserList();
      if (res.code === 200 && res.data) {
        this.chatUsers = res.data as ChatUser[];
      }
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('私信').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      if (this.chatUsers.length === 0) {
        Text('暂无私信').fontSize(14).fontColor('#999').margin({ top: 40 }).width('100%').textAlign(TextAlign.Center)
      }
      List({ space: 0 }) {
        ForEach(this.chatUsers, (user: ChatUser, index: number) => {
          ListItem() {
            Row() {
              Image(this.getSafeImage(user.avatar)).width(44).height(44).borderRadius(22).objectFit(ImageFit.Cover)
              Column() {
                Row() {
                  Text(user.username).fontSize(15).fontWeight(FontWeight.Medium).layoutWeight(1)
                  Text(user.lastTime || '').fontSize(11).fontColor('#ccc')
                }.width('100%')
                Text(user.lastMessage || '').fontSize(13).fontColor('#999').margin({ top: 4 }).maxLines(1)
                  .width('100%')
              }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
              if (user.unreadCount > 0) {
                Text(user.unreadCount.toString()).fontSize(11).fontColor(Color.White)
                  .backgroundColor('#FF2442').borderRadius(10).width(20).height(20)
                  .textAlign(TextAlign.Center)
              }
            }.width('100%').height(64).padding({ left: 16, right: 16 }).backgroundColor('#fff')
             .onClick(() => {
               router.pushUrl({ url: 'pages/chat/Chat', params: { uid: user.uid, username: user.username } });
             })
          }
        }, (user: ChatUser, index: number) => index.toString())
      }.width('100%').layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
