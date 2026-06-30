import { HttpUtil } from '../common/HttpUtil';
import { UserInfo } from '../model/User';
import { NotePage } from '../model/Note';
export class UserApi {
  static getUserById(userId: string) {
    return HttpUtil.get<UserInfo>('/web/user/getUserById?userId=' + userId);
  }
  static updateUser(data: UserInfo) {
    return HttpUtil.post<UserInfo>('/web/user/updateUser', data);
  }
  static getTrendByUser(page: number, size: number, userId: string, type: number) {
    return HttpUtil.get<NotePage>('/web/user/getTrendByUser/' + page + '/' + size + '?userId=' + userId + '&type=' + type);
  }
  static getUserByKeyword(page: number, size: number, keyword: string) {
    return HttpUtil.get('/web/user/getUserByKeyword/' + page + '/' + size + '?keyword=' + keyword);
  }
}
