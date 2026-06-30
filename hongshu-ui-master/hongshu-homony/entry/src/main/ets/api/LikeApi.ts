import { HttpUtil } from '../common/HttpUtil';
import { LikePage } from '../model/Like';

export class LikeApi {
  static likeOrCollectionByDTO(data: Object) { return HttpUtil.post('/web/likeOrCollection/likeOrCollectionByDTO', data); }
  static isLikeOrCollection(data: Object) { return HttpUtil.post('/web/likeOrCollection/isLikeOrCollection', data); }
  static getNoticeLikeOrCollection(page: number, size: number): Promise<ApiResponse<LikePage>> {
    return HttpUtil.get<LikePage>('/web/likeOrCollection/getNoticeLikeOrCollection/' + page + '/' + size);
  }
}

interface ApiResponse<T> { code: number; message: string; data: T; }
