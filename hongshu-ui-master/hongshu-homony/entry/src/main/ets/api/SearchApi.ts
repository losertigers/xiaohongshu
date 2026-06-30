import { HttpUtil } from '../common/HttpUtil';
import { HotSearchItem } from '../model/Search';
export class SearchApi {
  static getHotRecord() { return HttpUtil.get<HotSearchItem[]>('/web/es/record/getHotRecord'); }
  static getRecordByKeyWord() { return HttpUtil.get('/web/es/record/getRecordByKeyWord'); }
  static addRecord(keyword: string) { return HttpUtil.post('/web/es/record/addRecord', { keyword }); }
  static getCategoryTreeData() { return HttpUtil.get('/web/category/getCategoryTreeData'); }
  static getHotTagList() { return HttpUtil.get('/web/tag/getHotTagList'); }
}
