import { preferences } from '@kit.ArkData';
import { Constants } from './Constants';
import { common } from '@kit.AbilityKit';
const STORE_NAME = 'hongshu_prefs';
export class TokenManager {
  static async setToken(context: common.UIAbilityContext, token: string): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(Constants.TOKEN_KEY, token);
    await store.flush();
  }
  static async getToken(context: common.UIAbilityContext): Promise<string> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    return (await store.get(Constants.TOKEN_KEY, '')) as string;
  }
  static async setUserId(context: common.UIAbilityContext, userId: string): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(Constants.USER_ID_KEY, userId);
    await store.flush();
  }
  static async getUserId(context: common.UIAbilityContext): Promise<string> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    return (await store.get(Constants.USER_ID_KEY, '')) as string;
  }
  static async setUserInfo(context: common.UIAbilityContext, info: string): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.put(Constants.USER_INFO_KEY, info);
    await store.flush();
  }
  static async getUserInfo(context: common.UIAbilityContext): Promise<string> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    return (await store.get(Constants.USER_INFO_KEY, '')) as string;
  }
  static async clearAll(context: common.UIAbilityContext): Promise<void> {
    const store = await preferences.getPreferences(context, STORE_NAME);
    await store.clear();
    await store.flush();
  }
}
