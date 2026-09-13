using System;
using System.Collections.Generic;

namespace EvanJoDesktopPet.Windows.Core.Characters;

/// <summary>
/// Declares the static rendering contract supplied by a bundled character pack.
/// </summary>
public interface IPetCharacterDefinition
{
    string Id { get; }

    string DisplayName { get; }

    IReadOnlyList<PetPoseId> AvailablePoses { get; }

    PetPoseId DefaultPose { get; }

    PetPoseId FallbackPose { get; }

    IReadOnlyDictionary<PetPoseId, Uri> PoseAssets { get; }

    string GetPoseDisplayName(PetPoseId pose);
}
