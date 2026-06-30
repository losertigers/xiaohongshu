export class FollowerItem {
  id: string = ''; uid: string = ''; username: string = '';
  avatar: string = ''; description: string = ''; createTime: string = '';
  isfollow: boolean = false; time: string = '';
}
export class FollowerPage {
  records: FollowerItem[] = [];
  total: number = 0;
}
