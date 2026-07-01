import http from '@ohos.net.http';
import { Constants } from '../common/Constants';
import { HttpUtil } from '../common/HttpUtil';
import { NoteItem, NotePage } from '../model/Note';
import { ApiResponse } from '../common/HttpUtil';

export class NoteApi {
  static getNoteById(noteId: string) {
    return HttpUtil.get<NoteItem>('/web/note/getNoteById?noteId=' + noteId);
  }

  static saveNote(noteData: string, filePaths: string[]): Promise<ApiResponse<void>> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      const fullUrl = Constants.BASE_URL + '/web/note/saveNoteByDTO';
      const header: Record<string, string> = {};
      if (HttpUtil.getToken()) {
        header[Constants.TOKEN_KEY] = HttpUtil.getToken();
        if (HttpUtil.getUserId()) {
          header[Constants.USER_ID_KEY] = HttpUtil.getUserId();
        }
      }
      const multiFormDataList: http.MultiFormData[] = [
        { name: 'noteData', data: noteData, contentType: 'text/plain' }
      ];
      for (let i = 0; i < filePaths.length; i++) {
        multiFormDataList.push({
          name: 'uploadFiles',
          contentType: 'image/jpeg',
          filePath: filePaths[i],
          remoteFileName: 'image_' + i + '.jpg'
        });
      }
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: header,
        connectTimeout: 30000,
        readTimeout: 30000,
        multiFormDataList: multiFormDataList
      };
      httpRequest.request(fullUrl, options).then((response) => {
        if (response.responseCode === 200) {
          const result = JSON.parse(response.result as string) as ApiResponse<void>;
          resolve(result);
        } else {
          reject(new Error('HTTP ' + response.responseCode));
        }
        httpRequest.destroy();
      }).catch((err) => { reject(err); httpRequest.destroy(); });
    });
  }
  static getHotPage(page: number, size: number) {
    return HttpUtil.get<NotePage>('/web/es/note/getHotNote/' + page + '/' + size);
  }
  static deleteNoteByIds(ids: string[]) {
    return HttpUtil.post('/web/note/deleteNoteByIds', ids);
  }
  static pinnedNote(noteId: string) {
    return HttpUtil.get('/web/note/pinnedNote?noteId=' + noteId);
  }
  static getRecommendNote(page: number, size: number) {
    return HttpUtil.get<NotePage>('/web/es/note/getRecommendNote/' + page + '/' + size);
  }
  static searchNote(page: number, size: number, keyword: string) {
    return HttpUtil.post<NotePage>('/web/es/note/getNoteByDTO/' + page + '/' + size, { keyword });
  }
}
