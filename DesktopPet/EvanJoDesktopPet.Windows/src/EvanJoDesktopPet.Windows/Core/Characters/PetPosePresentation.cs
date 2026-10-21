namespace EvanJoDesktopPet.Windows.Core.Characters;

/// <summary>
/// Describes how a pose is placed by the shared rendering layer.
/// </summary>
public readonly record struct PetPosePresentation(
    double Width,
    double Height,
    double Scale = 1,
    double HorizontalInset = 0,
    PetPoseAlignment Alignment = PetPoseAlignment.Center)
{
    public static PetPosePresentation Default { get; } = new(125, 132);
}

public enum PetPoseAlignment
{
    Center,
    Bottom
}
