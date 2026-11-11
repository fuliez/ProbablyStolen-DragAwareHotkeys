# 游戏版本核查 / Game-version verification

核查日期：2026-11-11，Asia/Singapore。以下是该时点的版本记录，不应当作永久有效的“最新版”声明。

| 名称 | 核实结果 | 适配声明 |
| --- | --- | --- |
| Steam 正式分支 `public` | build **26525552**；正式更新名 **100-Rev13**，按开发者版本规则换算为 **1.0.0.13** | 本项目实际编译与用户功能验收所用构建 |
| 本机安装 | appmanifest 的 build **26525552**；程序集常量 **VERSION 100-Rev13** | 与当前正式分支一致 |
| 游戏内部 `Application.version` | **0.46D**；本机 Mod 菜单也据此匹配 | 当前 manifest 的 `GameVersions` 仅声明此标识 |
| Steam `open_beta` | build **26556045**；开发者文档将 **100-Rev14 / 1.0.0.14** 标为 beta | 未安装、未验证，不声明兼容 |
| 图一 Battery Manager 的 `1.1.0` | 位于“模组版本”栏，属于该 Mod | 不是 Probably Stolen 的游戏版本，撤回此前推断 |
| 本 Mod 版本 | **0.1.5** | 独立于游戏版本的项目版本号 |

## 一手依据

1. [Steam 官方新闻 API](https://api.steampowered.com/ISteamNews/GetNewsForApp/v2/?appid=4348910&count=20&maxlength=0) 的最新正式补丁公告为 **100-Rev13 Hotfix**。也可在[官方 Steam 社区](https://steamcommunity.com/app/4348910/workshop/)查看近期更新。该公告时间为 2026-11-08 UTC / 2026-11-09 Singapore；不是其他 Mod 的版本号。
2. [开发者 APIChanges.md](https://github.com/dragonpan2/probably-stolen-modding/blob/main/APIChanges.md) 明确将 **100-Rev14 (1.0.0.14)** 标为 **beta branch**，并说明此前 `0.46D` 长期未更新。正式版仍报告旧值，不等于玩家正在运行旧 demo。
3. [开发者 Game Versions 文档](https://github.com/dragonpan2/probably-stolen-modding/blob/main/ModdingGuide.md#game-versions) 说明 `major.minor.patch.revision` 与 `100-RevN` 的对应规则。**1.0.0.13 是按该规则对 Rev13 的换算**。
4. 直接以 SteamCMD 匿名查询 Steam 的 app info：`+login anonymous +app_info_update 1 +app_info_print 4348910 +quit`。正式分支 build 为 **26525552**，open_beta 为 **26556045**。查询输出留在被忽略的 `.local/steam-branch-check.txt`，不含用户密码或验证码。
5. 本机 Steam app manifest 和游戏程序集交叉印证正式分支 build / Rev13；程序集 SHA-256 仍为 `725CB999D019DFF1FF31BED353C7F9BB8D81A7605A15DE1F80F5A3A6CF7B1D05`。本机 ModUIManager 对 `Application.version` 做归一化并匹配 GameVersions，故当前必须使用 **0.46D**。

## 声明策略

当前只声明实际验证过的 **100-Rev13 / build 26525552**。在旧菜单可识别的 `GameVersions` 中仅放 **0.46D**，README 和工坊另行说明真实发行版本；不再添加无依据的 **1.1.0**，也不为消除红字而宣称覆盖所有版本。

未来正式版采用点分版本后，应重新检查真实接口、运行时版本与输入行为，再更新清单。开发指南建议新体系可使用 `1.0.0` 覆盖多个修订，但本项目尚未验证 beta，因此本次不据此扩展承诺。

## English summary

As checked on 2026-11-11, the public branch is **100-Rev13 / 1.0.0.13, build 26525552**, matching the installed and tested game. That build's Mod menu still uses the legacy **0.46D** runtime identifier, so the manifest declares only 0.46D. The **1.1.0** in the supplied Battery Manager screenshot is that mod's own version, not the game version. The developer's **100-Rev14 / 1.0.0.14** is on beta (build 26556045) and is not claimed as tested. Our mod's own version is **0.1.5**. Sources and the normalization-based mapping are recorded above.
