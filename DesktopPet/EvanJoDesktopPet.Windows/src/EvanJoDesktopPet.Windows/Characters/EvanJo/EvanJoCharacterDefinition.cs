using System;
using System.Collections.Generic;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo;

/// <summary>
/// The bundled static-pose definition for Evan Jo.
/// </summary>
public sealed class EvanJoCharacterDefinition : IPetCharacterDefinition
{
    private static readonly IReadOnlyList<PetPoseId> availablePoses =
    [
        PetPoseId.Idle,
        PetPoseId.Happy,
        PetPoseId.Loading,
        PetPoseId.Thinking,
        PetPoseId.Sleepy
    ];

    private static readonly IReadOnlyDictionary<PetPoseId, string> poseDisplayNames =
        new Dictionary<PetPoseId, string>
        {
            [PetPoseId.Idle] = "Idle",
            [PetPoseId.Happy] = "Happy",
            [PetPoseId.Loading] = "Loading",
            [PetPoseId.Thinking] = "Thinking",
            [PetPoseId.Sleepy] = "Sleepy"
        };

    public string Id => "evan_jo";

    public string DisplayName => "Evan Jo";

    public IReadOnlyList<PetPoseId> AvailablePoses => availablePoses;

    public PetPoseId DefaultPose => PetPoseId.Idle;

    public PetPoseId FallbackPose => PetPoseId.Idle;

    public IReadOnlyDictionary<PetPoseId, Uri> PoseAssets => EvanJoPoseAssets.ByPose;

    public string GetPoseDisplayName(PetPoseId pose) =>
        poseDisplayNames.TryGetValue(pose, out var displayName)
            ? displayName
            : pose.Value;
}
