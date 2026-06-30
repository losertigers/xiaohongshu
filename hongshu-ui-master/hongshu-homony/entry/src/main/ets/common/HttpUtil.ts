import http from '@ohos.net.http';
import { Constants } from './Constants';
export interface ApiResponse<T> { code: number; message: string; data: T; }
export class HttpUtil {
  private static token: string = '';
  private static userId: string = '';
  static setToken(t: string): void { HttpUtil.token = t; }
  static getToken(): string { return HttpUtil.token; }
  static setUserId(uid: string): void { HttpUtil.userId = uid; }
  static getUserId(): string { return HttpUtil.userId; }
  static request<T>(url: string, method: string, data?: Object): Promise<ApiResponse<T>> {
    return new Promise((resolve, reject) => {
      const httpRequest = http.createHttp();
      const fullUrl = Constants.BASE_URL + url;
      const header: Record<string, string> = { 'Content-Type': 'application/json' };
      if (HttpUtil.token) {
        header[Constants.TOKEN_KEY] = HttpUtil.token;
        if (HttpUtil.userId) {
          header[Constants.USER_ID_KEY] = HttpUtil.userId;
        }
      }
      const options: http.HttpRequestOptions = {
        method: method === 'GET' ? http.RequestMethod.GET : http.RequestMethod.POST,
        header: header, connectTimeout: 15000, readTimeout: 15000,
        extraData: data ? JSON.stringify(data) : undefined
      };
      httpRequest.request(fullUrl, options).then((response) => {
        if (response.responseCode === 200) {
          const result: ApiResponse<T> = JSON.parse(response.result as string) as ApiResponse<T>;
          if (result.code === 401) {
            HttpUtil.token = '';
            HttpUtil.userId = '';
            reject(new Error('登录已过期，请重新登录'));
          } else {
            resolve(result);
          }
        } else { reject(new Error('HTTP ' + response.responseCode)); }
        httpRequest.destroy();
      }).catch((err) => { reject(err); httpRequest.destroy(); });
    });
  }
  static get<T>(url: string): Promise<ApiResponse<T>> { return HttpUtil.request<T>(url, 'GET'); }
  static post<T>(url: string, data?: Object): Promise<ApiResponse<T>> { return HttpUtil.request<T>(url, 'POST', data); }
}
