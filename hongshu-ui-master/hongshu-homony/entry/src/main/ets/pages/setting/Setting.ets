import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { AuthApi } from '../../api/AuthApi';
import { TokenManager } from '../../common/TokenManager';
import { HttpUtil } from '../../common/HttpUtil';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct SettingPage {
  private context = getContext(this) as common.UIAbilityContext;

  build() {
    Column() {
      Row() {
        Text('<').fontSize(20).onClick(() => { router.back(); })
        Text('设置').fontSize(16).fontWeight(FontWeight.Bold).margin({ left: 16 })
      }.width('100%').height(48).padding({ left: 16 }).backgroundColor('#fff').alignItems(VerticalAlign.Center)
      List({ space: 0 }) {
        ListItem() { this.settingItem('修改密码', () => {}) }
        ListItem() { this.settingItem('编辑资料', () => { router.pushUrl({ url: 'pages/userinfo/UserInfo' }); }) }
        ListItem() { this.settingItem('清除缓存', () => { promptAction.showToast({ message: '缓存已清除' }); }) }
        ListItem() { this.settingItem('关于', () => {}) }
      }.width('100%').margin({ top: 12 })
      Button('退出登录').width('90%').height(48).borderRadius(24)
        .backgroundColor('#fff').fontColor('#FF2442').fontSize(16).margin({ top: 40 })
        .onClick(() => { this.logout(); })
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }

  @Builder settingItem(title: string, onClick: () => void) {
    Row() {
      Text(title).fontSize(15).layoutWeight(1)
      Text('>').fontSize(14).fontColor('#ccc')
    }.width('100%').height(52).padding({ left: 20, right: 20 }).backgroundColor('#fff').onClick(onClick)
  }

  async logout() {
    try {
      const userId = await TokenManager.getUserId(this.context);
      if (userId) { await AuthApi.loginOut({ userId: userId }); }
    } catch (e) {}
    HttpUtil.setToken('');
    HttpUtil.setUserId('');
    await TokenManager.clearAll(this.context);
    promptAction.showToast({ message: '已退出登录' });
    router.replaceUrl({ url: 'pages/login/Login' });
  }
}
