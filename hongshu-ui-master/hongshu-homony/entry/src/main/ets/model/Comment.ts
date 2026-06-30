export class CommentItem {
  id: string = ''; content: string = ''; nid: string = ''; uid: string = '';
  username: string = ''; avatar: string = ''; parentId: string = '';
  toUid: string = ''; toUsername: string = ''; likeCount: number = 0;
  children: CommentItem[] = []; createTime: string = '';
}
export class CommentPage {
  records: CommentItem[] = [];
  total: number = 0;
}
