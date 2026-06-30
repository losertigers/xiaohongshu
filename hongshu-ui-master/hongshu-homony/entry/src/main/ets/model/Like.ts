export class LikeItem {
  id: string = ''; uid: string = ''; username: string = ''; avatar: string = '';
  likeOrCollectionId: string = ''; publishUid: string = ''; type: number = 0;
  createTime: string = ''; cover: string = ''; content: string = '';
}
export class LikePage {
  records: LikeItem[] = [];
  total: number = 0;
}
