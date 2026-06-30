import { router } from '@kit.ArkUI';
import { ChatApi } from '../../api/ChatApi';
import { ChatMessage } from '../../model/Chat';
import { TokenManager } from '../../common/TokenManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct ChatPage {
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State currentUid: string = '';
  @State chatUserUid: string = '';
  @State chatUsername: string = '';
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    const params: Record<string, string> = router.getParams() as object as Record<string, string>;
    this.chatUserUid = params?.['uid'] ?? '';
    this.chatUsername = params?.['username'] ?? '';
    this.loadCurrentUser();
    this.loadMessages();
  }

  async loadCurrentUser() {
    this.currentUid = await TokenManager.getUserId(this.context);
  }

  async loadMessages() {
    if (!this.chatUserUid) return;
    try {
      const res = await ChatApi.getAllChatRecord(1, 100, this.chatUserUid);
      if (res.code === 200 && res.data && res.data.records) {
        this.messages = res.data.records.reverse();
      }
    } catch (e) {}
  }

  async sendMessage() {
    if (!this.inputText.trim()) return;
    try {
      await ChatApi.sendMsg({ content: this.inputText, acceptUid: this.chatUserUid });
      const msg: ChatMessage = new ChatMessage();
      msg.content = this.inputText;
      msg.sendUid = this.currentUid;
      msg.acceptUid = this.chatUserUid;
      this.messages.push(msg);
      this.inputText = '';
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text(this.chatUsername || '私信').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      List({ space: 8 }) {
        ForEach(this.messages, (msg: ChatMessage) => {
          ListItem() {
            Row() {
              if (msg.sendUid === this.currentUid) {
                Blank()
                Text(msg.content).fontSize(14).padding(10).backgroundColor('#FF2442')
                  .fontColor(Color.White).borderRadius(12).constraintSize({ maxWidth: '70%' })
              } else {
                Text(msg.content).fontSize(14).padding(10).backgroundColor('#f0f0f0')
                  .borderRadius(12).constraintSize({ maxWidth: '70%' })
              }
            }.width('100%').padding({ left: 12, right: 12 })
          }
        })
      }.width('100%').layoutWeight(1).backgroundColor('#f5f5f5')
      Row() {
        TextInput({ placeholder: '输入消息...', text: this.inputText })
          .layoutWeight(1).height(40).borderRadius(20).backgroundColor('#f5f5f5')
          .onChange((v: string) => { this.inputText = v; })
        Button('发送').height(40).fontSize(14).borderRadius(20)
          .backgroundColor('#FF2442').fontColor(Color.White).margin({ left: 8 })
          .onClick(() => { this.sendMessage(); })
      }.width('100%').height(56).padding({ left: 12, right: 12 }).backgroundColor('#fff')
    }.width('100%').height('100%').backgroundColor('#fff')
  }
}
