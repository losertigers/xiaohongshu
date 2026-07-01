export class FollowerItem {
  id: string = ''; uid: string = ''; username: string = '';
  avatar: string = ''; description: string = ''; createTime: string = '';
  isfollow: boolean = false; isFollow: boolean = false; time: string = '';
  fanCount: number = 0; followerCount: number = 0; likeCount: number = 0; hsId: number = 0;
}
export class FollowerPage {
  records: FollowerItem[] = [];
  total: number = 0;
}
