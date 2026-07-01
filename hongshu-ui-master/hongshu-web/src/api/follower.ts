import request from "@/utils/request";

/**
 * 得到关注用户的所有动态
 * @param currentPage 当前页
 * @param pageSize 分页数
 * @returns 
 */
export const getFollowTrend = (currentPage: number, pageSize: number) => {
  return request<any>({
    url: `/web/follower/getFollowTrend/${currentPage}/${pageSize}`, // mock接口
    method: "get",
  });
};

/**
 * 关注用户
 * @param followerId 关注用户id
 * @returns 
 */
export const followById = (followerId: string) => {
  return request<any>({
    url: `/web/follower/followById`, // mock接口
    method: "get",
    params: {
      followerId,
    },
  });
};

/**
 * 当前用户是否关注
 * @param followerId 关注的用户id
 * @returns 
 */
export const isFollow = (followerId: string) => {
  return request<any>({
    url: `/web/follower/isFollow`, // mock接口
    method: "get",
    params: {
      followerId,
    },
  });
};

/**
 * 得到当前用户的最新关注信息
 * @param currentPage 当前页
 * @param pageSize 分页数
 * @returns FollowerVo
 */
export const getNoticeFollower = (currentPage: number, pageSize: number) => {
  return request<any>({
    url: `/web/follower/getNoticeFollower/${currentPage}/${pageSize}`, // mock接口
    method: "get",
  });
};

/**
 * 获取关注/粉丝列表
 * @param currentPage 当前页
 * @param pageSize 分页数
 * @param type 类型 0：粉丝 1：关注
 * @param uid 目标用户id
 * @returns
 */
export const getFriend = (currentPage: number, pageSize: number, type: number, uid?: string) => {
  return request<any>({
    url: `/web/follower/getFriend/${currentPage}/${pageSize}`,
    method: "get",
    params: {
      type,
      uid,
    },
  });
};
