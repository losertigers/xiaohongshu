import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { AuthApi } from '../../api/AuthApi';
import { HttpUtil } from '../../common/HttpUtil';
import { TokenManager } from '../../common/TokenManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct LoginPage {
  @State phone: string = '';
  @State password: string = '';
  @State loading: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;

  build() {
    Column() {
      Text('登录').fontSize(28).fontWeight(FontWeight.Bold).margin({ top: 80, bottom: 12 })
      Text('小红薯').fontSize(16).fontColor('#FF2442').margin({ bottom: 40 })
      TextInput({ placeholder: '请输入手机号', text: this.phone })
        .type(InputType.PhoneNumber).maxLength(11).height(48).width('90%').margin({ bottom: 16 })
        .onChange((value: string) => { this.phone = value; })
      TextInput({ placeholder: '请输入密码', text: this.password })
        .type(InputType.Password).height(48).width('90%').margin({ bottom: 24 })
        .onChange((value: string) => { this.password = value; })
      Button(this.loading ? '登录中...' : '登录')
        .width('90%').height(48).borderRadius(24).backgroundColor('#FF2442')
        .fontColor(Color.White).fontSize(16).enabled(!this.loading)
        .onClick(() => { this.doLogin(); })
      Row() {
        Text('还没有账号？').fontSize(14).fontColor('#999')
        Text('立即注册').fontSize(14).fontColor('#FF2442')
          .onClick(() => { router.pushUrl({ url: 'pages/register/Register' }); })
      }.margin({ top: 20 })
    }.width('100%').height('100%').backgroundColor('#fff')
  }

  async doLogin() {
    if (!this.phone) { promptAction.showToast({ message: '请输入手机号' }); return; }
    if (!this.password) { promptAction.showToast({ message: '请输入密码' }); return; }
    this.loading = true;
    try {
      const res = await AuthApi.login(this.phone, this.password);
      this.loading = false;
      if (res.code === 200 && res.data) {
        HttpUtil.setToken(res.data.accessToken);
        HttpUtil.setUserId(res.data.userInfo.id);
        await TokenManager.setToken(this.context, res.data.accessToken);
        await TokenManager.setUserId(this.context, res.data.userInfo.id);
        await TokenManager.setUserInfo(this.context, JSON.stringify(res.data.userInfo));
        promptAction.showToast({ message: '登录成功' });
        router.replaceUrl({ url: 'pages/Index' });
      } else { promptAction.showToast({ message: res.message || '登录失败' }); }
    } catch (e) { this.loading = false; promptAction.showToast({ message: '网络异常' }); }
  }
}
