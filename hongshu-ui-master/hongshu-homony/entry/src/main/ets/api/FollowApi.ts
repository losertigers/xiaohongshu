import { HttpUtil } from '../common/HttpUtil';
export class FollowApi {
  static getFollowTrend(page: number, size: number) {
    return HttpUtil.get<Object>('/web/follower/getFollowTrend/' + page + '/' + size);
  }
  static followUser(data: Object) {
    return HttpUtil.post<Object>('/web/app/follow/followUser', data);
  }
  static clearFollow(data: Object) {
    return HttpUtil.post<Object>('/web/follow/clearFollow', data);
  }
  static isFollow(params: Object) {
    return HttpUtil.get<Object>('/web/follower/isFollow');
  }
  static getFriend(page: number, size: number) {
    return HttpUtil.get<Object>('/web/follower/getFriend/' + page + '/' + size);
  }
}
