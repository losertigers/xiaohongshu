import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { UserApi } from '../../api/UserApi';
import { TokenManager } from '../../common/TokenManager';
import { UserInfo } from '../../model/User';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct UserInfoPage {
  @State userInfo: UserInfo = new UserInfo();
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    this.loadUser();
  }

  async loadUser() {
    const infoStr = await TokenManager.getUserInfo(this.context);
    if (infoStr) { this.userInfo = JSON.parse(infoStr) as UserInfo; }
  }

  async saveUser() {
    try {
      const res = await UserApi.updateUser(this.userInfo);
      if (res.code === 200) {
        await TokenManager.setUserInfo(this.context, JSON.stringify(this.userInfo));
        promptAction.showToast({ message: '保存成功' });
        router.back();
      }
    } catch (e) { promptAction.showToast({ message: '保存失败' }); }
  }

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('编辑资料').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
        Blank()
        Text('保存').fontSize(14).fontColor('#FF2442').onClick(() => { this.saveUser(); })
      }.width('100%').height(48).padding({ left: 16, right: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      List({ space: 0 }) {
        ListItem() {
          Row() {
            Text('头像').fontSize(15)
            Blank()
            Image(this.userInfo.avatar).width(40).height(40).borderRadius(20)
            Text('>').fontSize(14).fontColor('#ccc').margin({ left: 8 })
          }.width('100%').height(60).padding({ left: 20, right: 20 }).backgroundColor('#fff')
        }
        ListItem() {
          Row() {
            Text('昵称').fontSize(15)
            Blank()
            TextInput({ text: this.userInfo.username }).textAlign(TextAlign.End).width(200).height(36)
              .backgroundColor(Color.Transparent).onChange((v: string) => { this.userInfo.username = v; })
          }.width('100%').height(52).padding({ left: 20, right: 20 }).backgroundColor('#fff')
        }
        ListItem() {
          Row() {
            Text('个性签名').fontSize(15)
            Blank()
            TextInput({ text: this.userInfo.description }).textAlign(TextAlign.End).width(200).height(36)
              .backgroundColor(Color.Transparent).onChange((v: string) => { this.userInfo.description = v; })
          }.width('100%').height(52).padding({ left: 20, right: 20 }).backgroundColor('#fff')
        }
      }.width('100%').margin({ top: 12 })
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}
