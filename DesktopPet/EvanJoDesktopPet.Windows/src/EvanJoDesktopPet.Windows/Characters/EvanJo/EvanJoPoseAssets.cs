using System;
using System.Collections.Generic;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo;

/// <summary>
/// Contains Evan Jo's character-pack-local pose-to-resource mapping.
/// </summary>
internal static class EvanJoPoseAssets
{
    internal static IReadOnlyDictionary<PetPoseId, Uri> ByPose { get; } =
        new Dictionary<PetPoseId, Uri>
        {
            [PetPoseId.Idle] = CreatePackUri("Idle/evan_jo_idle.png"),
            [PetPoseId.Happy] = CreatePackUri("Happy/evan_jo_happy.png"),
            [PetPoseId.Loading] = CreatePackUri("Loading/evan_jo_loading.png"),
            [PetPoseId.Thinking] = CreatePackUri("Thinking/evan_jo_thinking.png"),
            [PetPoseId.Sleepy] = CreatePackUri("Sleepy/evan_jo_sleepy.png")
        };

    private static Uri CreatePackUri(string assetPath) => new(
        $"pack://application:,,,/EvanJoDesktopPet.Windows;component/Resources/Characters/EvanJo/{assetPath}",
        UriKind.Absolute);
}
