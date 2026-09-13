using System;

namespace EvanJoDesktopPet.Windows.Core.Characters;

/// <summary>
/// A stable, string-backed pose identifier. Character packs may create
/// additional identifiers without changing a closed shared enum.
/// </summary>
public readonly record struct PetPoseId
{
    public static PetPoseId Idle { get; } = new("idle");
    public static PetPoseId Happy { get; } = new("happy");
    public static PetPoseId Loading { get; } = new("loading");
    public static PetPoseId Thinking { get; } = new("thinking");
    public static PetPoseId Sleepy { get; } = new("sleepy");

    public PetPoseId(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException(
                "A pose identifier must not be empty.",
                nameof(value));
        }

        Value = value;
    }

    public string Value { get; }

    public override string ToString() => Value;
}
