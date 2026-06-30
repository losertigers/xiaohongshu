export class ChatMessage {
  id: string = ''; content: string = ''; sendUid: string = ''; acceptUid: string = '';
  sendUsername: string = ''; sendAvatar: string = ''; acceptUsername: string = '';
  acceptAvatar: string = ''; createTime: string = ''; isRead: number = 0;
}
export class ChatUser {
  uid: string = ''; username: string = ''; avatar: string = '';
  lastMessage: string = ''; unreadCount: number = 0; lastTime: string = '';
}
export class ChatRecordPage {
  records: ChatMessage[] = [];
  total: number = 0;
}
