using System.Windows;
using System.Windows.Controls;
using EvanJoDesktopPet.Windows.Characters.EvanJo.Animation;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Views;

/// <summary>
/// Hosts Evan Jo's layered poses and static fallback without owning window behavior.
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
        if (StaticRenderer is null) return;
        IdleAnimationView.Stop();
        HappyAnimationView.Stop();
        (ExpressionHost.Content as EvanJoExpressionAnimationView)?.Stop();
        ExpressionHost.Content = null;

        var shouldUseLayeredIdle = CharacterDefinition is EvanJoCharacterDefinition
            && Pose == PetPoseId.Idle
            && IdleAnimationView.IsLayerSetAvailable;
        var shouldUseLayeredHappy = CharacterDefinition is EvanJoCharacterDefinition
            && Pose == PetPoseId.Happy
            && HappyAnimationView.IsLayerSetAvailable;

        var expression = CharacterDefinition is EvanJoCharacterDefinition
            && (Pose == PetPoseId.Loading || Pose == PetPoseId.Thinking || Pose == PetPoseId.Sleepy)
            ? new EvanJoExpressionAnimationView(Pose)
            : null;
        var shouldUseExpression = expression?.IsLayerSetAvailable == true;
        if (shouldUseExpression) ExpressionHost.Content = expression;
        ExpressionHost.Visibility = shouldUseExpression ? Visibility.Visible : Visibility.Collapsed;

        StaticRenderer.Visibility = shouldUseLayeredIdle || shouldUseLayeredHappy || shouldUseExpression
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

    public void RestartAnimation() => UpdateRenderedPose();
}
