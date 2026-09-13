using System.Windows;
using System.Windows.Controls;
using EvanJoDesktopPet.Windows.Characters.EvanJo.Animation;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Views;

/// <summary>
/// Hosts Evan Jo's selected static pose without owning desktop-window behavior.
/// </summary>
public partial class EvanJoPoseView : UserControl
{
    public static readonly DependencyProperty CharacterDefinitionProperty =
        DependencyProperty.Register(
            nameof(CharacterDefinition),
            typeof(IPetCharacterDefinition),
            typeof(EvanJoPoseView),
            new PropertyMetadata(null, OnRenderInputChanged));

    public static readonly DependencyProperty PoseProperty =
        DependencyProperty.Register(
            nameof(Pose),
            typeof(PetPoseId),
            typeof(EvanJoPoseView),
            new PropertyMetadata(PetPoseId.Idle, OnRenderInputChanged));

    public EvanJoPoseView()
    {
        InitializeComponent();
        UpdateRenderedPose();
    }

    public IPetCharacterDefinition? CharacterDefinition
    {
        get => (IPetCharacterDefinition?)GetValue(CharacterDefinitionProperty);
        set => SetValue(CharacterDefinitionProperty, value);
    }

    public PetPoseId Pose
    {
        get => (PetPoseId)GetValue(PoseProperty);
        set => SetValue(PoseProperty, value);
    }

    private static void OnRenderInputChanged(
        DependencyObject dependencyObject,
        DependencyPropertyChangedEventArgs e)
    {
        ((EvanJoPoseView)dependencyObject).UpdateRenderedPose();
    }

    private void UpdateRenderedPose()
    {
        var shouldUseLayeredIdle = CharacterDefinition is EvanJoCharacterDefinition
            && Pose == PetPoseId.Idle
            && IdleAnimationView.IsLayerSetAvailable;
        var shouldUseLayeredHappy = CharacterDefinition is EvanJoCharacterDefinition
            && Pose == PetPoseId.Happy
            && HappyAnimationView.IsLayerSetAvailable;

        StaticRenderer.Visibility = shouldUseLayeredIdle || shouldUseLayeredHappy
            ? Visibility.Collapsed
            : Visibility.Visible;
        IdleAnimationView.Visibility = shouldUseLayeredIdle
            ? Visibility.Visible
            : Visibility.Collapsed;
        HappyAnimationView.Visibility = shouldUseLayeredHappy
            ? Visibility.Visible
            : Visibility.Collapsed;

        if (shouldUseLayeredIdle)
        {
            IdleAnimationView.Start();
        }
        else
        {
            IdleAnimationView.Stop();
        }

        if (shouldUseLayeredHappy)
        {
            HappyAnimationView.Start();
        }
        else
        {
            HappyAnimationView.Stop();
        }
    }
}
