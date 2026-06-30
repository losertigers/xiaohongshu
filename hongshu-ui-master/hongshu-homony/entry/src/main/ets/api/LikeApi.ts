import { HttpUtil } from '../common/HttpUtil';
export class LikeApi {
  static likeOrCollectionByDTO(data: Object) { return HttpUtil.post('/web/likeOrCollection/likeOrCollectionByDTO', data); }
  static isLikeOrCollection(data: Object) { return HttpUtil.post('/web/likeOrCollection/isLikeOrCollection', data); }
  static getNoticeLikeOrCollection(page: number, size: number) {
    return HttpUtil.get('/web/likeOrCollection/getNoticeLikeOrCollection/' + page + '/' + size);
  }
}
