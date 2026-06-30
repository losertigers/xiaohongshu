import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { AuthApi } from '../../api/AuthApi';

@Entry
@Component
struct RegisterPage {
  @State phone: string = '';
  @State code: string = '';
  @State loading: boolean = false;
  @State countdown: number = 0;
  @State canSendCode: boolean = true;

  build() {
    Column() {
      Text('注册').fontSize(28).fontWeight(FontWeight.Bold).margin({ top: 80, bottom: 40 })
      TextInput({ placeholder: '请输入手机号', text: this.phone })
        .type(InputType.PhoneNumber).maxLength(11).height(48).width('90%').margin({ bottom: 16 })
        .onChange((v: string) => { this.phone = v; })
      Row() {
        TextInput({ placeholder: '请输入验证码', text: this.code })
          .type(InputType.Number).height(48).layoutWeight(1)
          .onChange((v: string) => { this.code = v; })
        Button(this.canSendCode ? '获取验证码' : this.countdown + 's')
          .height(48).fontSize(13).borderRadius(8)
          .backgroundColor('#f5f5f5').fontColor('#FF2442')
          .enabled(this.canSendCode)
          .onClick(() => { this.getCode(); })
      }.width('90%').margin({ bottom: 24 })
      Button(this.loading ? '注册中...' : '注册')
        .width('90%').height(48).borderRadius(24).backgroundColor('#FF2442')
        .fontColor(Color.White).fontSize(16).enabled(!this.loading)
        .onClick(() => { this.doRegister(); })
      Row() {
        Text('已有账号？').fontSize(14).fontColor('#999')
        Text('去登录').fontSize(14).fontColor('#FF2442').onClick(() => { router.back(); })
      }.margin({ top: 20 })
    }.width('100%').height('100%').backgroundColor('#fff')
  }

  async getCode() {
    if (!this.phone) {
      promptAction.showToast({ message: '请输入手机号' }); return;
    }
    if (this.phone.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号' }); return;
    }
    // Check if phone is already registered
    try {
      const checkRes = await AuthApi.isRegist({ phone: this.phone });
      if (checkRes.code === 200 && checkRes.data) {
        promptAction.showToast({ message: '手机号已被注册' }); return;
      }
    } catch (e) {}
    // Send verification code
    try {
      await AuthApi.sendMsm({ phone: this.phone });
      promptAction.showToast({ message: '发送成功' });
      this.canSendCode = false;
      this.countdown = 60;
      const timer = setInterval(() => {
        this.countdown--;
        if (this.countdown <= 0) {
          this.canSendCode = true;
          clearInterval(timer);
        }
      }, 1000);
    } catch (e) {
      promptAction.showToast({ message: '发送失败，请重试' });
    }
  }

  async doRegister() {
    if (!this.phone || !this.code) {
      promptAction.showToast({ message: '请填写完整' }); return;
    }
    this.loading = true;
    try {
      const res = await AuthApi.register({ phone: this.phone, code: this.code });
      this.loading = false;
      if (res.code === 200 && res.data) {
        promptAction.showToast({ message: '注册成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res.message || '注册失败' });
      }
    } catch (e) { this.loading = false; promptAction.showToast({ message: '网络异常' }); }
  }
}
