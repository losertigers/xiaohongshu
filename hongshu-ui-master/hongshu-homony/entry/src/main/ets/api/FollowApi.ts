import { HttpUtil } from '../common/HttpUtil';
import { FollowerPage } from '../model/Follower';

export class FollowApi {
  static getFollowTrend(page: number, size: number) {
    return HttpUtil.get<Object>('/web/follower/getFollowTrend/' + page + '/' + size);
  }
  // 关注/取消关注用户（toggle方式）
  static followUser(followerId: string) {
    return HttpUtil.get<Object>('/web/follower/followById?followerId=' + followerId);
  }
  // 取消关注（调用同一个接口，toggle方式）
  static clearFollow(followerId: string) {
    return HttpUtil.get<Object>('/web/follower/followById?followerId=' + followerId);
  }
  static isFollow(followerId: string) {
    return HttpUtil.get<Object>('/web/follower/isFollow?followerId=' + followerId);
  }
  // type=0: 粉丝（关注我的人）, type=1: 关注（我关注的人）
  static getFriend(page: number, size: number, type: number, uid?: string): Promise<ApiResponse<FollowerPage>> {
    let url = '/web/follower/getFriend/' + page + '/' + size + '?type=' + type;
    if (uid) {
      url += '&uid=' + uid;
    }
    return HttpUtil.get<FollowerPage>(url);
  }
}

interface ApiResponse<T> { code: number; message: string; data: T; }
