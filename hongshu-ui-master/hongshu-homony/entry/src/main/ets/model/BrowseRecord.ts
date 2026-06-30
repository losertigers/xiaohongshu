export class BrowseRecordItem {
  id: string = ''; nid: string = ''; title: string = '';
  noteCover: string = ''; username: string = ''; createTime: string = '';
}
export class BrowseRecordPage {
  records: BrowseRecordItem[] = [];
  total: number = 0;
}
