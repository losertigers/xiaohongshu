import { HttpUtil } from '../common/HttpUtil';

export class AlbumApi {
  static saveAlbum(data: Object) {
    return HttpUtil.post<Object>('/web/album/saveAlbum', data);
  }
  static updateAlbum(data: Object) {
    return HttpUtil.post<Object>('/web/album/updateAlbum', data);
  }
  static getAllAlbum(page: number, size: number) {
    return HttpUtil.get<Object>('/web/album/getAlbumByUserId/' + page + '/' + size);
  }
  static getAlbum(albumId: string) {
    return HttpUtil.get<Object>('/web/album/getAlbum?albumId=' + albumId);
  }
  static deleteAlbum(albumId: string) {
    return HttpUtil.get<Object>('/web/album/deleteAlbum?albumId=' + albumId);
  }
  static addAlbumImgRelation(data: Object) {
    return HttpUtil.post<Object>('/web/albumImgRelation/addAlbumImgRelation', data);
  }
  static isCollectImgToAlbum(mid: string) {
    return HttpUtil.get<Object>('/web/albumImgRelation/isCollectImgToAlbum?mid=' + mid);
  }
  static deleteAlbumImgRelation(data: Object) {
    return HttpUtil.post<Object>('/web/albumImgRelation/deleteAlbumImgRelation', data);
  }
}
