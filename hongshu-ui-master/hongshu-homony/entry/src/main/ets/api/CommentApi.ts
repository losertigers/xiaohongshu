import { HttpUtil } from '../common/HttpUtil';
import { CommentItem, CommentPage } from '../model/Comment';

export class CommentApi {
  static getOneCommentByNoteId(page: number, size: number, noteId: string) {
    return HttpUtil.get('/web/comment/getOneCommentByNoteId/' + page + '/' + size + '?noteId=' + noteId);
  }
  static getCommentWithCommentByNoteId(page: number, size: number, noteId: string): Promise<ApiResponse<CommentPage>> {
    return HttpUtil.get<CommentPage>('/web/comment/getCommentWithCommentByNoteId/' + page + '/' + size + '?noteId=' + noteId);
  }
  static saveComment(data: Object): Promise<ApiResponse<CommentItem>> {
    return HttpUtil.post<CommentItem>('/web/comment/saveCommentByDTO', data);
  }
  static deleteComment(commentId: string) {
    return HttpUtil.get('/web/comment/deleteCommentById?commentId=' + commentId);
  }
  static syncCommentByIds(commentIds: string[]) {
    return HttpUtil.post('/web/comment/syncCommentByIds', commentIds);
  }
  static getNoticeComment(page: number, size: number): Promise<ApiResponse<CommentPage>> {
    return HttpUtil.get<CommentPage>('/web/comment/getNoticeComment/' + page + '/' + size);
  }
}

interface ApiResponse<T> { code: number; message: string; data: T; }
