import { router } from '@kit.ArkUI';
import { BrowseRecordApi } from '../../api/BrowseRecordApi';
import { BrowseRecordItem } from '../../model/BrowseRecord';

@Entry
@Component
struct BrowseRecordPage {
  @State recordList: BrowseRecordItem[] = [];

  aboutToAppear() { this.loadRecords(); }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  async loadRecords() {
    try {
      const res = await BrowseRecordApi.getAllBrowseRecordByUser(1, 50);
      if (res.code === 200 && res.data && res.data.records) {
        this.recordList = res.data.records;
      }
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('浏览记录').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      if (this.recordList.length === 0) {
        Text('暂无浏览记录').fontSize(14).fontColor('#999').margin({ top: 40 }).width('100%').textAlign(TextAlign.Center)
      }
      List({ space: 8 }) {
        ForEach(this.recordList, (record: BrowseRecordItem, index: number) => {
          ListItem() {
            Row() {
              Image(this.getSafeImage(record.noteCover)).width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
              Column() {
                Text(record.title || '').fontSize(14).fontWeight(FontWeight.Medium).maxLines(2)
                Text(record.username || '').fontSize(12).fontColor('#999').margin({ top: 4 })
              }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
            }.padding(12).backgroundColor('#fff').borderRadius(8)
             .onClick(() => {
               if (record.nid) {
                 router.pushUrl({ url: 'pages/note/NoteDetail', params: { noteId: record.nid } });
               }
             })
          }
        }, (record: BrowseRecordItem, index: number) => index.toString())
      }.width('100%').layoutWeight(1).padding(8)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
