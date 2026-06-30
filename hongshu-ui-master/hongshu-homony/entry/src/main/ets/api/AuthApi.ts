import { HttpUtil } from '../common/HttpUtil';
import { LoginResult } from '../model/User';
export class AuthApi {
  static login(phone: string, password: string) {
    return HttpUtil.post<LoginResult>('/web/auth/login', { phone, password });
  }
  static register(data: Object) {
    return HttpUtil.post<Object>('/auth/register', data);
  }
  static isRegist(data: Object) {
    return HttpUtil.post<Object>('/auth/isRegist', data);
  }
  static sendMsm(data: Object) {
    return HttpUtil.post<Object>('/util/msm/sendMsm', data);
  }
  static sendDm(data: Object) {
    return HttpUtil.post<Object>('/util/dm/sendDm', data);
  }
  static refreshToken(refreshToken: string) {
    return HttpUtil.get<LoginResult>('/web/auth/refreshToken?refreshToken=' + refreshToken);
  }
  static getUserInfoByToken(accessToken: string) {
    return HttpUtil.get('/web/auth/getUserInfoByToken?accessToken=' + accessToken);
  }
  static loginOut(data: Object) {
    return HttpUtil.post<Object>('/web/auth/loginOut', data);
  }
  static updatePassword(data: Object) {
    return HttpUtil.post<Object>('/auth/updatePassword', data);
  }
}
