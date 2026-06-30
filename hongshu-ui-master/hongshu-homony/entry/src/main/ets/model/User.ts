export class UserInfo {
  id: string = ''; username: string = ''; phone: string = ''; avatar: string = '';
  gender: string = ''; birthday: string = ''; description: string = '';
  trendCount: number = 0; fansCount: number = 0; followCount: number = 0;
  likeCount: number = 0; createTime: string = '';
}
export class LoginResult {
  accessToken: string = ''; refreshToken: string = ''; userInfo: UserInfo = new UserInfo();
}
