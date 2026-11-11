# Drag-Aware Hotkeys_解决拖拽时按键冲突

[![简体中文](docs/assets/language-zh.svg)](README.md) [![English](docs/assets/language-en.svg)](README.en.md)

《Probably Stolen》的轻量 Mod：拖动物品时屏蔽储物协调器的容器快捷键，避免旋转物品时误触开箱。此仓库公开源码，供玩家审阅、了解实现并自行构建。

| 项目 | 状态 |
| --- | --- |
| Mod 版本 | **0.1.3** |
| 适配游戏 | 官方 **1.1.0**；同时声明此构建内部标识 **0.46D** |
| 验收状态 | 项目所有者已完成官方版本游戏内验收，未发现明显问题 |
| 支持范围 | 官方游戏；不承诺与第三方 Mod 兼容 |

## 功能

- 拖动物品期间，屏蔽储物协调器的全部容器快捷键。
- 保留原有 Q/E 旋转、翻转、重置朝向和放置操作；未拖动时储物快捷键正常工作。
- 不修改存档，不覆盖原始游戏程序集，无需前置 Mod 或额外能力权限。使用游戏原生加载器和游戏自带的 Harmony。

## 安装与卸载

推荐通过 [Steam 创意工坊](https://steamcommunity.com/sharedfiles/filedetails/?id=3837800051)订阅、获取更新和反馈问题。订阅后，在游戏 Mods 菜单启用本 Mod、检查权限并重启游戏。

手动安装也可使用 [GitHub Releases](https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys/releases) 中的独立安装包：先关闭游戏，再将压缩包内的 `drag_aware_hotkeys/` 文件夹放入游戏的 `Mods/` 目录。安装包仅含 Mod DLL 和 `manifest.xml`，请勿将整个源码仓库复制到 Mods。

停用并重启可恢复原版行为。卸载时取消工坊订阅，或关闭游戏后移除本地 `Mods/drag_aware_hotkeys` 文件夹。相同 Mod ID 的本地副本优先于工坊副本；重新构建或更新后需重启，开发期间可用 Mods 菜单的本地 Developer mode 减少重复授权提示。

## 从源码构建

需要 Windows PowerShell 5.1+ 或 PowerShell 7+、Git、支持 C# 10 / netstandard2.1 的 .NET SDK，以及合法安装的完整版游戏。CI 固定使用 SDK 6.0.410；.NET 6 已停止支持，后续维护应考虑升级开发 SDK。Mod 运行目标仍为游戏使用的 netstandard2.1。

在项目根目录设置游戏路径（以下示例适用于仓库位于游戏的 `my_mod` 子目录），然后执行：

```powershell
$env:PROBABLY_STOLEN_GAME_DIR = (Resolve-Path '..').Path
./build.ps1
./install-local.ps1
./package.ps1
```

也可传入 `-GameDir`，或将 `config.example.json` 复制为被 Git 忽略的 `config.local.json` 并填写 `GameDir`。构建不会自动安装；安装前请退出游戏。本机绝对路径配置、游戏 DLL、存档、日志和登录状态不进入 Git。

## 检查与调试

```powershell
dotnet run --project tests/Contracts/Contracts.csproj -c Release
./scripts/check.ps1
./tests/Workshop.ps1
./scripts/check-game.ps1 -ReportedGameVersion '0.46D'
./install-local.ps1 -Configuration Debug
```

契约检查使用手写替身验证启停、拖拽状态及异常回退，不代表真实 Unity 输入时序或 Harmony 加载验证。`check-game.ps1` 在 .NET 6 下验证已安装游戏的真实接口，并调用其 Mod 扫描器。工坊检查完全离线，使用模拟 SteamCMD，覆盖物品 ID、显式上传确认、可见性、UTF-8 和换行保护。

Debug 构建记录拖拽状态切换；Release 记录启停和每次启用后的首次状态读取异常。日志位于 `%USERPROFILE%/AppData/LocalLow/Questing Goose Studio/Probably Stolen/Player.log`。可选的游戏根目录 `dev.txt` 启用 F8/F9；项目不会创建或分发它。

公开 CI 执行契约、脚本和离线发布检查；真实游戏构建只在手动启动的可信自托管任务中进行，并比较干净重建后的 DLL 哈希。公共运行器不下载游戏程序集，也无法在缺少这些引用时构建真实 Mod；不向 GitHub 上传游戏引用。

## 项目结构

| 路径 | 用途 |
| --- | --- |
| `src/`、`mod/` | C# 源码与原生加载器清单 |
| `tests/`、`scripts/` | 行为检查、离线发布检查及开发工具 |
| `docs/` | [API 调查](docs/API-INVESTIGATION.md)、[验收清单](docs/TESTING.md)、[发布流程](docs/RELEASING.md) |
| `workshop/` | 对应的中英文简介、封面和非敏感物品标识 |
| `AGENTS.md`、`agent.md` | AI 开发规范和接续记录 |

## 版本与发布

采用 Semantic Versioning、Conventional Commits 和 `main` 分支；已发布标签及安装包保留历史。变更见 [CHANGELOG.md](CHANGELOG.md)。补丁仅作用于储物协调器的私有快捷键处理函数，游戏更新后需重新验证其接口和行为。

`publish-workshop.ps1` 默认只准备 SteamCMD 配置，不上传。上传必须提供与目标可见性对应的 `UPLOAD HIDDEN` 或 `UPLOAD PUBLIC` 确认；首次创建强制隐藏。现有物品 ID 保存在 `workshop/item.json`，新克隆也更新同一物品，冲突 ID 会被拒绝。Steam 密码与 Guard 验证码只在本机交互输入，不写入项目。完整流程见[发布说明](docs/RELEASING.md)。

## 参考资料

- [游戏 Modding Guide](https://github.com/dragonpan2/probably-stolen-modding/blob/main/ModdingGuide.md)
- [参考 Mod 合集](https://github.com/KCN-judu/ProbablyStolen-Mods)
- [Better Key Bindings 源码参考](https://github.com/KCN-judu/ProbablyStolen-BetterKeyBindings)；仅用于技术调查，不属于兼容性承诺

## 许可证

项目代码采用 [MIT 许可证](LICENSE)。Probably Stolen、Unity、Harmony 及第三方素材的权利归各自所有者；仓库不分发游戏代码或程序集。原创生成封面的来源及使用说明见 [ARTWORK.md](workshop/ARTWORK.md)。
