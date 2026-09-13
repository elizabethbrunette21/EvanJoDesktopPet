using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Core.Behavior;

/// <summary>
/// The rendering intent currently selected by the behavior layer.
/// </summary>
public sealed record PetBehaviorState(
    IPetCharacterDefinition Character,
    PetPoseId CurrentPose,
    PetBehaviorMode Mode);
