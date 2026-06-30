import { HttpUtil } from '../common/HttpUtil';
import { NoteItem, NotePage } from '../model/Note';
export class NoteApi {
  static getNoteById(noteId: string) {
    return HttpUtil.get<NoteItem>('/web/note/getNoteById?noteId=' + noteId);
  }
  static getHotPage(page: number, size: number) {
    return HttpUtil.get<NotePage>('/web/es/note/getHotNote/' + page + '/' + size);
  }
  static deleteNoteByIds(ids: string[]) {
    return HttpUtil.post('/web/note/deleteNoteByIds', ids);
  }
  static pinnedNote(noteId: string) {
    return HttpUtil.get('/web/note/pinnedNote?noteId=' + noteId);
  }
  static getRecommendNote(page: number, size: number) {
    return HttpUtil.get<NotePage>('/web/es/note/getRecommendNote/' + page + '/' + size);
  }
  static searchNote(page: number, size: number, keyword: string) {
    return HttpUtil.post<NotePage>('/web/es/note/getNoteByDTO/' + page + '/' + size, { keyword });
  }
}
