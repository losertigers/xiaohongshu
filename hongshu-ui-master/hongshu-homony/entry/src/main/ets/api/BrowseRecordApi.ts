import { HttpUtil } from '../common/HttpUtil';
import { BrowseRecordPage } from '../model/BrowseRecord';

export class BrowseRecordApi {
  static addBrowseRecord(data: Object) {
    return HttpUtil.post<Object>('/web/browseRecord/addBrowseRecord', data);
  }
  static getAllBrowseRecordByUser(page: number, size: number): Promise<ApiResponse<BrowseRecordPage>> {
    return HttpUtil.get<BrowseRecordPage>('/web/browseRecord/getAllBrowseRecordByUser/' + page + '/' + size);
  }
  static delRecord(uid: string, data: Object) {
    return HttpUtil.post<Object>('/web/browseRecord/delRecord/' + uid, data);
  }
}

interface ApiResponse<T> { code: number; message: string; data: T; }
