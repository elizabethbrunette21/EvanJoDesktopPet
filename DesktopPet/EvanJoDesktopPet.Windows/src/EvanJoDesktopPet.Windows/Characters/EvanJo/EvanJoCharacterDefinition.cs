using System;
using System.Collections.Generic;
using System.Globalization;
using EvanJoDesktopPet.Windows.Core.Behavior;
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
            [PetPoseId.Thinking] = "Speechless",
            [PetPoseId.Sleepy] = "Brainwave"
        };

    private static readonly IReadOnlyDictionary<PetPoseId, string> chinesePoseDisplayNames =
        new Dictionary<PetPoseId, string>
        {
            [PetPoseId.Idle] = "待机",
            [PetPoseId.Happy] = "开心",
            [PetPoseId.Loading] = "加载中",
            [PetPoseId.Thinking] = "无语",
            [PetPoseId.Sleepy] = "灵光一现"
        };

    private static readonly IReadOnlyDictionary<PetPoseId, PetPosePresentation> posePresentations =
        new Dictionary<PetPoseId, PetPosePresentation>
        {
            [PetPoseId.Idle] = PetPosePresentation.Default,
            [PetPoseId.Happy] = new(156, 140, 1.18, 0, PetPoseAlignment.Bottom),
            [PetPoseId.Loading] = PetPosePresentation.Default,
            [PetPoseId.Thinking] = PetPosePresentation.Default,
            [PetPoseId.Sleepy] = new(125, 132, 1.16, 7)
        };

    private static readonly PetTemporaryPose happyClickReaction =
        new(PetPoseId.Happy, TimeSpan.FromSeconds(5.45));

    private static readonly PetTemporaryPose brainwaveReaction =
        new(PetPoseId.Sleepy, TimeSpan.FromSeconds(16.42));

    private static readonly PetAutomaticPoseConfiguration automaticPoseConfiguration = new(
        TimeSpan.FromSeconds(8), TimeSpan.FromSeconds(12),
        TimeSpan.FromSeconds(25), TimeSpan.FromSeconds(35),
        [
            new(new(PetPoseId.Thinking, TimeSpan.FromSeconds(19.35)), 32),
            new(new(PetPoseId.Happy, TimeSpan.FromSeconds(15.95)), 28),
            new(brainwaveReaction, 20),
            new(new(PetPoseId.Loading, TimeSpan.FromSeconds(18)), 20)
        ],
        new Dictionary<PetPoseId, int> { [PetPoseId.Sleepy] = 2 });

    public string Id => "evan_jo";

    public string DisplayName => "Evan Jo";

    public IReadOnlyList<PetPoseId> AvailablePoses => availablePoses;

    public PetPoseId DefaultPose => PetPoseId.Idle;

    public PetPoseId FallbackPose => PetPoseId.Idle;

    public IReadOnlyDictionary<PetPoseId, Uri> PoseAssets => EvanJoPoseAssets.ByPose;

    public IReadOnlyDictionary<PetPoseId, PetPosePresentation> PosePresentations =>
        posePresentations;

    public PetAutomaticPoseConfiguration AutomaticPoseConfiguration =>
        automaticPoseConfiguration;

    public PetTemporaryPose ClickReactionFor(PetPoseId pose) =>
        pose == PetPoseId.Loading ? brainwaveReaction : happyClickReaction;

    public string GetPoseDisplayName(PetPoseId pose) =>
        (CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "zh"
            ? chinesePoseDisplayNames
            : poseDisplayNames).TryGetValue(pose, out var displayName)
            ? displayName
            : pose.Value;
}
