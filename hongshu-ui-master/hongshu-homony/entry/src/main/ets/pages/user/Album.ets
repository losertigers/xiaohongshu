import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { AlbumApi } from '../../api/AlbumApi';

@Entry
@Component
struct AlbumPage {
  @State albumList: AlbumItem[] = [];

  aboutToAppear() { this.loadAlbums(); }

  getSafeImage(url: string): string | Resource {
    if (url && url.length > 0) { return url; }
    return $r('app.media.startIcon');
  }

  async loadAlbums() {
    try {
      const res = await AlbumApi.getAllAlbum(1, 50);
      if (res.code === 200 && res.data) {
        const d = res.data as Record<string, Object>;
        const records = d['records'] as AlbumItem[];
        if (records) { this.albumList = records; }
      }
    } catch (e) {}
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('我的专辑').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      if (this.albumList.length === 0) {
        Column() {
          Text('暂无专辑').fontSize(14).fontColor('#999')
          Text('去发布内容创建你的第一个专辑吧').fontSize(12).fontColor('#ccc').margin({ top: 8 })
        }.width('100%').margin({ top: 60 }).alignItems(HorizontalAlign.Center)
      }
      List({ space: 8 }) {
        ForEach(this.albumList, (album: AlbumItem) => {
          ListItem() {
            Row() {
              Image(this.getSafeImage(album.cover)).width(60).height(60).borderRadius(8).objectFit(ImageFit.Cover)
              Column() {
                Text(album.name).fontSize(15).fontWeight(FontWeight.Medium)
                Text(album.description || '').fontSize(12).fontColor('#999').margin({ top: 4 }).maxLines(1)
              }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)
            }.padding(12).backgroundColor('#fff').borderRadius(8)
          }
        }, (album: AlbumItem, index: number) => index.toString())
      }.width('100%').layoutWeight(1).padding(8)
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}

class AlbumItem {
  id: string = ''; name: string = ''; description: string = '';
  cover: string = ''; imgCount: number = 0; collectionCount: number = 0;
  createTime: string = '';
}
