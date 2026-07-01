import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { picker } from '@kit.CoreFileKit';
import fs from '@ohos.file.fs';
import { common } from '@kit.AbilityKit';
import { NoteApi } from '../../api/NoteApi';

@Entry
@Component
struct PublishPage {
  @State title: string = '';
  @State content: string = '';
  @State publishMode: string = 'image';
  @State selectedImages: string[] = [];
  @State imagePreviewUris: string[] = [];
  @State selectedVideo: string = '';
  @State videoPreviewUri: string = '';
  @State publishing: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;

  async pickVideo() {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        maxSelectNumber: 1,
        MIMEType: picker.PhotoViewMIMETypes.VIDEO_TYPE
      });
      if (result && result.photoUris && result.photoUris.length > 0) {
        const uri = result.photoUris[0];
        const cachePath = await this.copyToCache(uri);
        if (cachePath) {
          this.selectedVideo = cachePath;
          this.videoPreviewUri = uri;
          promptAction.showToast({ message: '已选择 1 个视频' });
        } else {
          promptAction.showToast({ message: '选择视频失败' });
        }
      }
    } catch (e) {
      const errMsg = (e instanceof Error) ? e.message : '未知错误';
      promptAction.showToast({ message: '选择视频失败：' + errMsg });
    }
  }

  async pickImages() {
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        maxSelectNumber: 9,
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE
      });
      if (result && result.photoUris && result.photoUris.length > 0) {
        this.selectedImages = [];
        this.imagePreviewUris = [];
        for (const uri of result.photoUris) {
          this.imagePreviewUris.push(uri);
          const cachePath = await this.copyToCache(uri);
          if (cachePath) {
            this.selectedImages.push(cachePath);
          }
        }
        promptAction.showToast({ message: '已选择 ' + this.selectedImages.length + ' 张图片' });
      }
    } catch (e) {
      const errMsg = (e instanceof Error) ? e.message : '未知错误';
      promptAction.showToast({ message: '选择图片失败：' + errMsg });
    }
  }

  async copyToCache(uri: string): Promise<string | null> {
    try {
      const fileName = 'upload_' + Date.now() + '.jpg';
      const cacheDir = this.context.cacheDir;
      const destPath = cacheDir + '/' + fileName;
      fs.copyFileSync(uri, destPath);
      return destPath;
    } catch (e) {
      console.error('copyToCache error:', e);
      return null;
    }
  }

  async doPublish() {
    if (!this.title.trim()) {
      promptAction.showToast({ message: '请输入标题' });
      return;
    }
    if (!this.content.trim()) {
      promptAction.showToast({ message: '请输入描述内容' });
      return;
    }
    if (this.publishMode === 'video' && !this.selectedVideo) {
      promptAction.showToast({ message: '请选择一个视频' });
      return;
    }
    if (this.publishMode === 'image' && this.selectedImages.length === 0) {
      promptAction.showToast({ message: '请至少选择一张图片' });
      return;
    }
    this.publishing = true;
    try {
      const noteData = JSON.stringify({
        title: this.title,
        content: this.content,
        noteType: this.publishMode === 'video' ? '1' : '0',
        cid: '1',
        cpid: '1',
        tagList: []
      });
      const filePaths = this.publishMode === 'video' ? [this.selectedVideo] : this.selectedImages;
      const res = await NoteApi.saveNote(noteData, filePaths);
      if (res && res.code === 200) {
        promptAction.showToast({ message: '发布成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res?.message || '发布失败' });
      }
    } catch (e) {
      const errMsg = (e instanceof Error) ? e.message : '未知错误';
      promptAction.showToast({ message: '发布失败：' + errMsg });
    }
    this.publishing = false;
  }

  build() {
    Column() {
      Row() {
        Text('取消').fontSize(14).fontColor('#999').onClick(() => { router.back(); })
        Text(this.publishMode === 'image' ? '发布图文' : '发布视频')
          .fontSize(16).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
        Text(this.publishing ? '发布中...' : '发布').fontSize(14).fontColor(this.publishing ? '#ccc' : '#FF2442')
          .fontWeight(FontWeight.Bold)
          .onClick(() => { if (!this.publishing) { this.doPublish(); } })
      }.width('100%').height(48).padding({ left: 16, right: 16 }).backgroundColor('#fff')
      Row() {
        Button('图片').fontSize(13).height(30).borderRadius(15)
          .backgroundColor(this.publishMode === 'image' ? '#FF2442' : '#f5f5f5')
          .fontColor(this.publishMode === 'image' ? Color.White : '#666')
          .onClick(() => { this.publishMode = 'image'; this.selectedVideo = ''; this.videoPreviewUri = ''; })
        Button('视频').fontSize(13).height(30).borderRadius(15)
          .backgroundColor(this.publishMode === 'video' ? '#FF2442' : '#f5f5f5')
          .fontColor(this.publishMode === 'video' ? Color.White : '#666')
          .margin({ left: 8 }).onClick(() => { this.publishMode = 'video'; this.selectedImages = []; this.imagePreviewUris = []; })
      }.width('100%').padding({ left: 16, right: 16, top: 12, bottom: 12 })
      Divider()
      Scroll() {
        Column() {
          if (this.publishMode === 'image') {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.imagePreviewUris, (uri: string, index: number) => {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Image(uri).width(100).height(100).borderRadius(4).objectFit(ImageFit.Cover)
                  Text('X').fontSize(12).fontColor(Color.White).width(20).height(20)
                    .backgroundColor('#999').borderRadius(10).textAlign(TextAlign.Center)
                    .margin({ top: 2, right: 2 })
                    .onClick(() => {
                      this.imagePreviewUris.splice(index, 1);
                      this.selectedImages.splice(index, 1);
                      this.imagePreviewUris = [...this.imagePreviewUris];
                      this.selectedImages = [...this.selectedImages];
                    })
                }.margin({ right: 8, bottom: 8 })
              }, (uri: string, index: number) => index.toString())
              if (this.imagePreviewUris.length < 9) {
                Column() {
                  Text('+').fontSize(28).fontColor('#ccc')
                  Text('添加图片').fontSize(12).fontColor('#999').margin({ top: 4 })
                }.width(100).height(100).borderRadius(4)
                 .border({ width: 1, color: '#ddd', style: BorderStyle.Dashed })
                 .justifyContent(FlexAlign.Center).margin({ right: 8, bottom: 8 })
                 .onClick(() => { this.pickImages(); })
              }
            }.padding({ left: 16, right: 16 })
          } else {
            if (this.videoPreviewUri) {
              Stack({ alignContent: Alignment.TopEnd }) {
                Image(this.videoPreviewUri).width(160).height(160).borderRadius(8).objectFit(ImageFit.Cover)
                Text('X').fontSize(12).fontColor(Color.White).width(20).height(20)
                  .backgroundColor('#999').borderRadius(10).textAlign(TextAlign.Center)
                  .margin({ top: 2, right: 2 })
                  .onClick(() => {
                    this.videoPreviewUri = '';
                    this.selectedVideo = '';
                  })
              }.margin({ left: 16 })
            } else {
              Column() {
                Text('+').fontSize(28).fontColor('#ccc')
                Text('添加视频').fontSize(12).fontColor('#999').margin({ top: 4 })
              }.width(160).height(160).borderRadius(8)
               .border({ width: 1, color: '#ddd', style: BorderStyle.Dashed })
               .justifyContent(FlexAlign.Center).margin({ left: 16 })
               .onClick(() => { this.pickVideo(); })
            }
          }
          TextInput({ placeholder: '请输入标题', text: this.title })
            .width('100%').height(48).margin({ top: 16 }).maxLength(20)
            .onChange((v: string) => { this.title = v; })
          TextInput({ placeholder: '填写描述...', text: this.content })
            .width('100%').height(120).margin({ top: 8 }).maxLength(250)
            .onChange((v: string) => { this.content = v; })
          if (this.selectedImages.length > 0) {
            Text('已选择 ' + this.selectedImages.length + ' 张图片')
              .fontSize(12).fontColor('#999').margin({ top: 8 })
          }
        }.padding({ left: 16, right: 16 })
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor('#fff')
  }
}
