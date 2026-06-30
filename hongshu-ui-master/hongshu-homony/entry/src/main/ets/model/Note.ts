export class NoteItem {
  id: string = ''; title: string = ''; content: string = ''; noteCover: string = '';
  noteCoverHeight: number = 200; uid: string = ''; username: string = ''; avatar: string = '';
  urls: string = ''; noteType: string = '0'; likeCount: number = 0; collectionCount: number = 0;
  commentCount: number = 0; viewCount: number = 0; pinned: string = '0';
  isLike: boolean = false; isCollection: boolean = false; isFollow: boolean = false;
  tagList: TagItem[] = []; time: number = 0;
}
export class TagItem { id: string = ''; title: string = ''; }
export class NotePage { records: NoteItem[] = []; total: number = 0; }
