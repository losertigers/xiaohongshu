import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { SearchApi } from '../../api/SearchApi';
import { NoteApi } from '../../api/NoteApi';
import { NoteItem } from '../../model/Note';
import { HotSearchItem } from '../../model/Search';

@Entry
@Component
struct SearchPage {
  @State keyword: string = '';
  @State hotTags: string[] = [];
  @State resultNotes: NoteItem[] = [];
  @State showResult: boolean = false;

  aboutToAppear() { this.loadHotTags(); }

  async loadHotTags() {
    try {
      const res = await SearchApi.getHotRecord();
      if (res.code === 200 && res.data) {
        const list: HotSearchItem[] = res.data as HotSearchItem[];
        this.hotTags = list.map((item: HotSearchItem) => item.keyword);
      }
    } catch (e) {
      promptAction.showToast({ message: '加载热搜失败' });
    }
  }

  async doSearch() {
    if (!this.keyword.trim()) return;
    try {
      SearchApi.addRecord(this.keyword);
      const res = await NoteApi.searchNote(1, 20, this.keyword);
      if (res.code === 200 && res.data && res.data.records) {
        this.resultNotes = res.data.records;
        this.showResult = true;
        if (this.resultNotes.length === 0) {
          promptAction.showToast({ message: '未找到相关笔记' });
        }
      }
    } catch (e) {
      promptAction.showToast({ message: '搜索失败' });
    }
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        TextInput({ placeholder: '搜索笔记、用户、标签', text: this.keyword })
          .layoutWeight(1).height(36).borderRadius(18).backgroundColor('#f5f5f5').margin({ left: 8 })
          .onChange((v: string) => { this.keyword = v; })
          .onSubmit(() => { this.doSearch(); })
        Text('搜索').fontSize(14).fontColor('#FF2442').margin({ left: 8 })
          .onClick(() => { this.doSearch(); })
      }.width('100%').height(48).padding({ left: 12, right: 12 }).backgroundColor('#fff')
      if (!this.showResult) {
        Text('热门搜索').fontSize(16).fontWeight(FontWeight.Bold).margin({ top: 16, left: 16 })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.hotTags, (tag: string) => {
            Text(tag).fontSize(13).padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#f5f5f5').borderRadius(16).margin({ right: 8, bottom: 8 })
              .onClick(() => { this.keyword = tag; this.doSearch(); })
          })
        }.padding(16)
      } else {
        Text('搜索结果 (' + this.resultNotes.length + ')')
          .fontSize(14).fontColor('#999').margin({ top: 12, left: 16 })
        List({ space: 8 }) {
          ForEach(this.resultNotes, (note: NoteItem) => {
            ListItem() {
              Row() {
                Image(note.noteCover).width(80).height(80).objectFit(ImageFit.Cover).borderRadius(8)
                Column() {
                  Text(note.title).fontSize(14).fontWeight(FontWeight.Medium).maxLines(2)
                  Text(note.username).fontSize(12).fontColor('#999').margin({ top: 4 })
                }.layoutWeight(1).margin({ left: 12 }).alignItems(HorizontalAlign.Start)
              }.padding(12).backgroundColor('#fff').borderRadius(8)
               .onClick(() => { router.pushUrl({ url: 'pages/note/NoteDetail', params: { noteId: note.id } }); })
            }
          })
        }.width('100%').layoutWeight(1).padding(8)
      }
    }.width('100%').height('100%').backgroundColor('#fff')
  }
}
