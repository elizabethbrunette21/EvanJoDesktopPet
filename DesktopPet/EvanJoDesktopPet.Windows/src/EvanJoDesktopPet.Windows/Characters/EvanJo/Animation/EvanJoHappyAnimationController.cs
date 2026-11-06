using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Animation;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Animation;

/// <summary>
/// Runs Evan Jo Happy's one-shot jump and flower sequence without owning pose state.
/// </summary>
public sealed class EvanJoHappyAnimationController
{
    private const double FlowerSizeScale = 1.8;
    private const double FlowerInitialScale = 0.4 * FlowerSizeScale;
    private static readonly Vector[] FlowerMidpointOffsets =
    {
        new(-10, -15),
        new(9, -17),
        new(9, -7),
        new(16, -8),
        new(13, 5),
        new(-16, -7),
        new(-12, 4)
    };

    private static readonly Vector[] FlowerFinalOffsets =
    {
        new(-21, -24),
        new(20, -27),
        new(18, -15),
        new(27, -4),
        new(24, 15),
        new(-27, -10),
        new(-22, 14)
    };

    private readonly FrameworkElement animationHost;
    private readonly TranslateTransform characterTranslateTransform;
    private readonly FrameworkElement jumpLinesElement;
    private readonly IReadOnlyList<FrameworkElement> flowerElements;
    private readonly IReadOnlyList<ScaleTransform> flowerScaleTransforms;
    private readonly IReadOnlyList<TranslateTransform> flowerTranslateTransforms;
    private Storyboard? animationStoryboard;
    private bool isStarted;

    public EvanJoHappyAnimationController(
        FrameworkElement animationHost,
        TranslateTransform characterTranslateTransform,
        FrameworkElement jumpLinesElement,
        IReadOnlyList<FrameworkElement> flowerElements,
        IReadOnlyList<ScaleTransform> flowerScaleTransforms,
        IReadOnlyList<TranslateTransform> flowerTranslateTransforms)
    {
        if (flowerElements.Count != FlowerFinalOffsets.Length
            || flowerScaleTransforms.Count != FlowerFinalOffsets.Length
            || flowerTranslateTransforms.Count != FlowerFinalOffsets.Length)
        {
            throw new ArgumentException("Every Evan Jo flower layer requires a transform.");
        }

        this.animationHost = animationHost;
        this.characterTranslateTransform = characterTranslateTransform;
        this.jumpLinesElement = jumpLinesElement;
        this.flowerElements = flowerElements;
        this.flowerScaleTransforms = flowerScaleTransforms;
        this.flowerTranslateTransforms = flowerTranslateTransforms;
    }

    public void Start()
    {
        if (isStarted)
        {
            return;
        }

        isStarted = true;
        ResetVisualState();
        PlayAnimation();
    }

    public void Stop()
    {
        isStarted = false;
        StopStoryboard();
        ResetVisualState();
    }

    private void PlayAnimation()
    {
        if (!isStarted)
        {
            return;
        }

        StopStoryboard();
        ResetVisualState();

        var storyboard = new Storyboard { FillBehavior = FillBehavior.Stop };
        characterTranslateTransform.BeginAnimation(TranslateTransform.YProperty, CreateJumpFrames());
        AddTimeline(
            storyboard,
            jumpLinesElement,
            UIElement.OpacityProperty,
            CreateJumpLineFrames());

        for (var index = 0; index < flowerElements.Count; index++)
        {
            var appearanceStart = TimeSpan.FromSeconds(index * 0.04);
            var appearanceEnd = appearanceStart + TimeSpan.FromSeconds(0.12);
            var finalEnd = appearanceEnd + TimeSpan.FromSeconds(0.38);
            var fadeStart = TimeSpan.FromSeconds(1.15 + (index * 0.04));
            var fadeEnd = fadeStart + TimeSpan.FromSeconds(0.35);

            AddTimeline(
                storyboard,
                flowerElements[index],
                UIElement.OpacityProperty,
                CreateFlowerOpacityFrames(appearanceStart, appearanceEnd, fadeStart, fadeEnd));
            flowerScaleTransforms[index].BeginAnimation(ScaleTransform.ScaleXProperty,
                CreateFlowerScaleFrames(appearanceStart, appearanceEnd, fadeEnd));
            flowerScaleTransforms[index].BeginAnimation(ScaleTransform.ScaleYProperty,
                CreateFlowerScaleFrames(appearanceStart, appearanceEnd, fadeEnd));
            flowerTranslateTransforms[index].BeginAnimation(TranslateTransform.XProperty,
                CreateFlowerMovementFrames(
                    FlowerMidpointOffsets[index].X,
                    FlowerFinalOffsets[index].X,
                    appearanceStart,
                    appearanceEnd,
                    finalEnd,
                    fadeEnd));
            flowerTranslateTransforms[index].BeginAnimation(TranslateTransform.YProperty,
                CreateFlowerMovementFrames(
                    FlowerMidpointOffsets[index].Y,
                    FlowerFinalOffsets[index].Y,
                    appearanceStart,
                    appearanceEnd,
                    finalEnd,
                    fadeEnd));
        }

        storyboard.Completed += (_, _) =>
        {
            if (ReferenceEquals(animationStoryboard, storyboard))
            {
                storyboard.Remove(animationHost);
                animationStoryboard = null;
                ResetVisualState();
            }
        };

        animationStoryboard = storyboard;
        storyboard.Begin(animationHost, HandoffBehavior.SnapshotAndReplace, true);
    }

    private static DoubleAnimationUsingKeyFrames CreateJumpFrames()
    {
        var frames = new DoubleAnimationUsingKeyFrames();
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            0,
            KeyTime.FromTimeSpan(TimeSpan.Zero)));
        frames.KeyFrames.Add(CreateEasedFrame(
            -8,
            TimeSpan.FromSeconds(0.16),
            EasingMode.EaseOut));
        frames.KeyFrames.Add(CreateEasedFrame(
            0,
            TimeSpan.FromSeconds(0.34),
            EasingMode.EaseIn));
        frames.KeyFrames.Add(CreateEasedFrame(
            -2,
            TimeSpan.FromSeconds(0.44),
            EasingMode.EaseOut));
        frames.KeyFrames.Add(CreateEasedFrame(
            0,
            TimeSpan.FromSeconds(0.54),
            EasingMode.EaseIn));
        return frames;
    }

    private static DoubleAnimationUsingKeyFrames CreateJumpLineFrames()
    {
        var frames = new DoubleAnimationUsingKeyFrames();
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            0,
            KeyTime.FromTimeSpan(TimeSpan.Zero)));
        frames.KeyFrames.Add(CreateEasedFrame(
            1,
            TimeSpan.FromSeconds(0.08),
            EasingMode.EaseOut));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            1,
            KeyTime.FromTimeSpan(TimeSpan.FromSeconds(0.16))));
        frames.KeyFrames.Add(CreateEasedFrame(
            0,
            TimeSpan.FromSeconds(0.34),
            EasingMode.EaseIn));
        return frames;
    }

    private static DoubleAnimationUsingKeyFrames CreateFlowerOpacityFrames(
        TimeSpan appearanceStart,
        TimeSpan appearanceEnd,
        TimeSpan fadeStart,
        TimeSpan fadeEnd)
    {
        var frames = new DoubleAnimationUsingKeyFrames();
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            0,
            KeyTime.FromTimeSpan(TimeSpan.Zero)));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            0,
            KeyTime.FromTimeSpan(appearanceStart)));
        frames.KeyFrames.Add(CreateEasedFrame(1, appearanceEnd, EasingMode.EaseOut));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            1,
            KeyTime.FromTimeSpan(fadeStart)));
        frames.KeyFrames.Add(CreateEasedFrame(0, fadeEnd, EasingMode.EaseOut));
        return frames;
    }

    private static DoubleAnimationUsingKeyFrames CreateFlowerScaleFrames(
        TimeSpan appearanceStart,
        TimeSpan appearanceEnd,
        TimeSpan finish)
    {
        var frames = new DoubleAnimationUsingKeyFrames();
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            FlowerInitialScale,
            KeyTime.FromTimeSpan(TimeSpan.Zero)));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            FlowerInitialScale,
            KeyTime.FromTimeSpan(appearanceStart)));
        frames.KeyFrames.Add(CreateEasedFrame(FlowerSizeScale, appearanceEnd, EasingMode.EaseOut));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            FlowerSizeScale,
            KeyTime.FromTimeSpan(finish)));
        return frames;
    }

    private static DoubleAnimationUsingKeyFrames CreateFlowerMovementFrames(
        double midpoint,
        double final,
        TimeSpan appearanceStart,
        TimeSpan appearanceEnd,
        TimeSpan finalEnd,
        TimeSpan finish)
    {
        var frames = new DoubleAnimationUsingKeyFrames();
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            0,
            KeyTime.FromTimeSpan(TimeSpan.Zero)));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            0,
            KeyTime.FromTimeSpan(appearanceStart)));
        frames.KeyFrames.Add(CreateEasedFrame(midpoint, appearanceEnd, EasingMode.EaseOut));
        frames.KeyFrames.Add(CreateEasedFrame(final, finalEnd, EasingMode.EaseOut));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            final,
            KeyTime.FromTimeSpan(finish)));
        return frames;
    }

    private static EasingDoubleKeyFrame CreateEasedFrame(
        double value,
        TimeSpan keyTime,
        EasingMode easingMode) => new(
        value,
        KeyTime.FromTimeSpan(keyTime))
    {
        EasingFunction = new CubicEase { EasingMode = easingMode }
    };

    private static void AddTimeline(
        Storyboard storyboard,
        DependencyObject target,
        DependencyProperty property,
        Timeline timeline)
    {
        Storyboard.SetTarget(timeline, target);
        Storyboard.SetTargetProperty(timeline, new PropertyPath(property));
        storyboard.Children.Add(timeline);
    }

    private void StopStoryboard()
    {
        if (animationStoryboard is null)
        {
            return;
        }

        animationStoryboard.Remove(animationHost);
        animationStoryboard = null;
    }

    private void ResetVisualState()
    {
        characterTranslateTransform.BeginAnimation(TranslateTransform.YProperty, null);
        characterTranslateTransform.Y = 0;
        jumpLinesElement.Opacity = 0;

        for (var index = 0; index < flowerElements.Count; index++)
        {
            flowerScaleTransforms[index].BeginAnimation(ScaleTransform.ScaleXProperty, null);
            flowerScaleTransforms[index].BeginAnimation(ScaleTransform.ScaleYProperty, null);
            flowerTranslateTransforms[index].BeginAnimation(TranslateTransform.XProperty, null);
            flowerTranslateTransforms[index].BeginAnimation(TranslateTransform.YProperty, null);
            flowerElements[index].Opacity = 0;
            flowerScaleTransforms[index].ScaleX = FlowerInitialScale;
            flowerScaleTransforms[index].ScaleY = FlowerInitialScale;
            flowerTranslateTransforms[index].X = 0;
            flowerTranslateTransforms[index].Y = 0;
        }
    }
}
