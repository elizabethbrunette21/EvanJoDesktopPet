using System;
using System.Collections.Generic;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Core.Behavior;

public sealed record PetTemporaryPose(PetPoseId Pose, TimeSpan Duration);

public sealed record PetWeightedTemporaryPose(PetTemporaryPose TemporaryPose, int Weight);

public sealed record PetAutomaticPoseConfiguration(
    TimeSpan InitialIdleMinimum,
    TimeSpan InitialIdleMaximum,
    TimeSpan RecoveryIdleMinimum,
    TimeSpan RecoveryIdleMaximum,
    IReadOnlyList<PetWeightedTemporaryPose> WeightedPoses,
    IReadOnlyDictionary<PetPoseId, int> CooldownSelections);
