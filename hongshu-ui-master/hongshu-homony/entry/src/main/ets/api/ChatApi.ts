import { HttpUtil } from '../common/HttpUtil';
import { ChatUser, ChatRecordPage } from '../model/Chat';

export class ChatApi {
  static sendMsg(data: Object) { return HttpUtil.post<Object>('/web/im/chat/sendMsg', data); }
  static getAllChatRecord(page: number, size: number, acceptUid: string): Promise<ApiResponse<ChatRecordPage>> {
    return HttpUtil.get<ChatRecordPage>('/web/im/chat/getAllChatRecord/' + page + '/' + size + '?acceptUid=' + acceptUid);
  }
  static getChatUserList(): Promise<ApiResponse<ChatUser[]>> {
    return HttpUtil.get<ChatUser[]>('/web/im/chat/getChatUserList');
  }
  static getCountMessage() { return HttpUtil.get('/web/im/chat/getCountMessage'); }
  static clearMessageCount(sendUid: string, type: number) {
    return HttpUtil.get('/web/im/chat/clearMessageCount?sendUid=' + sendUid + '&type=' + type);
  }
}

interface ApiResponse<T> { code: number; message: string; data: T; }
