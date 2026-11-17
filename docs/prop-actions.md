# 视频道具动作 · 2026-11-16

补齐两个此前漏掉的原版姿势，使用内置 imagegen 参考视频裁切与已认可的 `idle-v2.png` 绘制。角色继续使用红豆豆眼和无嘴脸，不采用敲锣参考图里的弯眼笑脸。

- 敲锣参考：`ScreenRecording_11-11-2026 09-17-36_1.MP4`，1.8 秒，裁切保存在 `references/evan-gong.png`。小金锣、中央凸起、粉色双瓣软头锣槌。四帧为举槌、挥入、接触、回弹，循环播放；没有新增声音。
- 骷髅头杆子参考：`ScreenRecording_11-14-2026 17-32-23_1.MP4`，12 秒，裁切保存在 `references/evan-skull-staff.png`。保留白骨色细长杆、乳白骷髅、深眼窝红点、红色额记与下方红饰、骨形底端。四帧表现持杆与轻晃。

新素材另存 `assets/characters/evan/motion-v2/gong.png` 和 `skull-staff.png`，均为 2×2 透明图集，未覆盖 v2 立绘和第一批动作。

[内置 imagegen 完整生成提示词](prop-action-prompts.txt)。

运行时现在共 17 种状态、37 个图集单元；两种新状态均进入自动洗牌轮换，也能在右键／托盘“做个动作”菜单中直接选取。

运行 `npm run smoke -- --record-props` 可以检查全部动作并导出这两个状态的连续预览帧。它们是依据视频的补绘动画，不是从游戏中提取的原始素材。Windows 本次未实测。
