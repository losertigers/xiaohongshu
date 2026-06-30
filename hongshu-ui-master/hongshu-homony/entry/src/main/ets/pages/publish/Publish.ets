import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct PublishPage {
  @State title: string = '';
  @State content: string = '';
  @State publishMode: string = 'image';

  build() {
    Column() {
      Row() {
        Text('取消').fontSize(14).fontColor('#999').onClick(() => { router.back(); })
        Text(this.publishMode === 'image' ? '发布图文' : '发布视频')
          .fontSize(16).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
        Text('发布').fontSize(14).fontColor('#FF2442').fontWeight(FontWeight.Bold)
      }.width('100%').height(48).padding({ left: 16, right: 16 }).backgroundColor('#fff')
      Row() {
        Button('图片').fontSize(13).height(30).borderRadius(15)
          .backgroundColor(this.publishMode === 'image' ? '#FF2442' : '#f5f5f5')
          .fontColor(this.publishMode === 'image' ? Color.White : '#666')
          .onClick(() => { this.publishMode = 'image'; })
        Button('视频').fontSize(13).height(30).borderRadius(15)
          .backgroundColor(this.publishMode === 'video' ? '#FF2442' : '#f5f5f5')
          .fontColor(this.publishMode === 'video' ? Color.White : '#666')
          .margin({ left: 8 }).onClick(() => { this.publishMode = 'video'; })
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
      Divider()
      Scroll() {
        Column() {
          if (this.publishMode === 'image') {
            Column() {
              Text('+').fontSize(28).fontColor('#ccc')
              Text('添加图片').fontSize(12).fontColor('#999').margin({ top: 4 })
            }.width(100).height(100).borderRadius(4)
             .border({ width: 1, color: '#ddd', style: BorderStyle.Dashed })
             .justifyContent(FlexAlign.Center).margin({ left: 16 })
             .onClick(() => { promptAction.showToast({ message: '请在手机端选择图片' }); })
          } else {
            Column() {
              Text('+').fontSize(28).fontColor('#ccc')
              Text('添加视频').fontSize(12).fontColor('#999').margin({ top: 4 })
            }.width(160).height(160).borderRadius(8)
             .border({ width: 1, color: '#ddd', style: BorderStyle.Dashed })
             .justifyContent(FlexAlign.Center).margin({ left: 16 })
             .onClick(() => { promptAction.showToast({ message: '请在手机端选择视频' }); })
          }
          TextInput({ placeholder: '请输入标题', text: this.title })
            .width('100%').height(48).margin({ top: 16 }).maxLength(20)
            .onChange((v: string) => { this.title = v; })
          TextInput({ placeholder: '填写描述...', text: this.content })
            .width('100%').height(120).margin({ top: 8 }).maxLength(250)
            .onChange((v: string) => { this.content = v; })
        }.padding({ left: 16, right: 16 })
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#fff')
  }
}
