using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Threading;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Animation;

/// <summary>
/// Runs Evan Jo Idle's one-shot visual sequences without owning input or pet behavior.
/// </summary>
public sealed class EvanJoIdleAnimationController
{
    private static readonly Vector[] SparkleOutwardOffsets =
    {
        new(-22, 18),
        new(53, -29),
        new(16, -31),
        new(-13, -74),
        new(36, -94),
        new(80, -41)
    };

    private readonly ScaleTransform headScaleTransform;
    private readonly TranslateTransform headTranslateTransform;
    private readonly IReadOnlyList<FrameworkElement> sparkleElements;
    private readonly IReadOnlyList<ScaleTransform> sparkleScaleTransforms;
    private readonly IReadOnlyList<TranslateTransform> sparkleTranslateTransforms;
    private readonly DispatcherTimer automaticNodTimer = new();
    private readonly DispatcherTimer pettingNodTimer = new();
    private readonly DispatcherTimer sparkleEndTimer = new();
    private bool isStarted;

    public EvanJoIdleAnimationController(
        ScaleTransform headScaleTransform,
        TranslateTransform headTranslateTransform,
        IReadOnlyList<FrameworkElement> sparkleElements,
        IReadOnlyList<ScaleTransform> sparkleScaleTransforms,
        IReadOnlyList<TranslateTransform> sparkleTranslateTransforms)
    {
        if (sparkleElements.Count != SparkleOutwardOffsets.Length
            || sparkleScaleTransforms.Count != SparkleOutwardOffsets.Length
            || sparkleTranslateTransforms.Count != SparkleOutwardOffsets.Length)
        {
            throw new ArgumentException("Every Evan Jo sparkle layer requires a transform.");
        }

        this.headScaleTransform = headScaleTransform;
        this.headTranslateTransform = headTranslateTransform;
        this.sparkleElements = sparkleElements;
        this.sparkleScaleTransforms = sparkleScaleTransforms;
        this.sparkleTranslateTransforms = sparkleTranslateTransforms;
        automaticNodTimer.Tick += (_, _) =>
        {
            automaticNodTimer.Interval = TimeSpan.FromSeconds(8);
            PlayNod();
        };
        pettingNodTimer.Tick += (_, _) =>
        {
            pettingNodTimer.Stop();
            ResetHead();
            PlaySparkles();
            ScheduleAutomaticNod(TimeSpan.FromSeconds(7.26));
        };
        sparkleEndTimer.Tick += (_, _) =>
        {
            sparkleEndTimer.Stop();
            ResetSparkles();
        };
    }

    public void Start()
    {
        if (isStarted)
        {
            return;
        }

        isStarted = true;
        ResetVisualState();
        ScheduleAutomaticNod(TimeSpan.FromSeconds(2));
    }

    public void Stop()
    {
        isStarted = false;
        automaticNodTimer.Stop();
        pettingNodTimer.Stop();
        sparkleEndTimer.Stop();
        ResetVisualState();
    }

    public void PlayNod()
    {
        if (!isStarted)
        {
            return;
        }

        ResetHead();
        var nods = new[]
        {
            (TimeSpan.FromSeconds(0.16), TimeSpan.FromSeconds(0.36)),
            (TimeSpan.FromSeconds(0.60), TimeSpan.FromSeconds(0.80))
        };
        headTranslateTransform.BeginAnimation(TranslateTransform.YProperty, CreateNodFrames(0, 1.5, nods));
        headScaleTransform.BeginAnimation(ScaleTransform.ScaleYProperty, CreateNodFrames(1, 0.985, nods));
    }

    public void PlayPettingFeedback()
    {
        if (!isStarted)
        {
            return;
        }

        pettingNodTimer.Stop();
        sparkleEndTimer.Stop();
        automaticNodTimer.Stop();
        ResetVisualState();
        PlayNod();
        pettingNodTimer.Interval = TimeSpan.FromSeconds(0.8);
        pettingNodTimer.Start();
    }

    public void PlaySparkles()
    {
        if (!isStarted)
        {
            return;
        }

        sparkleEndTimer.Stop();
        ResetSparkles();

        var fadeStart = TimeSpan.FromSeconds(1.15);
        var fadeEnd = TimeSpan.FromSeconds(1.45);

        for (var index = 0; index < sparkleElements.Count; index++)
        {
            var appearanceStart = TimeSpan.FromSeconds(index * 0.08);
            var appearanceEnd = appearanceStart + TimeSpan.FromSeconds(0.42);
            var offset = SparkleOutwardOffsets[index];

            sparkleElements[index].BeginAnimation(UIElement.OpacityProperty,
                CreateOpacityFrames(appearanceStart, appearanceStart + TimeSpan.FromSeconds(0.12), fadeStart, fadeEnd));
            sparkleScaleTransforms[index].BeginAnimation(ScaleTransform.ScaleXProperty,
                CreateMovementFrames(0.1, 1.6, appearanceStart, appearanceEnd, fadeEnd));
            sparkleScaleTransforms[index].BeginAnimation(ScaleTransform.ScaleYProperty,
                CreateMovementFrames(0.1, 1.6, appearanceStart, appearanceEnd, fadeEnd));
            sparkleTranslateTransforms[index].BeginAnimation(TranslateTransform.XProperty,
                CreateMovementFrames(0, offset.X, appearanceStart, appearanceEnd, fadeEnd));
            sparkleTranslateTransforms[index].BeginAnimation(TranslateTransform.YProperty,
                CreateMovementFrames(-43, offset.Y + 3, appearanceStart, appearanceEnd, fadeEnd));
        }

        sparkleEndTimer.Interval = fadeEnd;
        sparkleEndTimer.Start();
    }

    private static DoubleAnimationUsingKeyFrames CreateNodFrames(
        double restingValue,
        double nodValue,
        IReadOnlyList<(TimeSpan Down, TimeSpan Recover)> nods)
    {
        var frames = new DoubleAnimationUsingKeyFrames();
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            restingValue,
            KeyTime.FromTimeSpan(TimeSpan.Zero)));

        foreach (var nod in nods)
        {
            frames.KeyFrames.Add(CreateEasedFrame(nodValue, nod.Down));
            frames.KeyFrames.Add(CreateEasedFrame(restingValue, nod.Recover));
        }

        return frames;
    }

    private static DoubleAnimationUsingKeyFrames CreateMovementFrames(
        double initialValue,
        double outwardValue,
        TimeSpan appearanceStart,
        TimeSpan appearanceEnd,
        TimeSpan finish)
    {
        var frames = new DoubleAnimationUsingKeyFrames();
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            initialValue,
            KeyTime.FromTimeSpan(TimeSpan.Zero)));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            initialValue,
            KeyTime.FromTimeSpan(appearanceStart)));
        frames.KeyFrames.Add(CreateEasedFrame(outwardValue, appearanceEnd));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            outwardValue,
            KeyTime.FromTimeSpan(finish)));
        return frames;
    }

    private static DoubleAnimationUsingKeyFrames CreateOpacityFrames(
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
        frames.KeyFrames.Add(CreateEasedFrame(1, appearanceEnd));
        frames.KeyFrames.Add(new DiscreteDoubleKeyFrame(
            1,
            KeyTime.FromTimeSpan(fadeStart)));
        frames.KeyFrames.Add(CreateEasedFrame(0, fadeEnd));
        return frames;
    }

    private static EasingDoubleKeyFrame CreateEasedFrame(
        double value,
        TimeSpan keyTime) => new(
        value,
        KeyTime.FromTimeSpan(keyTime))
    {
        EasingFunction = new CubicEase { EasingMode = EasingMode.EaseOut }
    };

    private void ScheduleAutomaticNod(TimeSpan delay)
    {
        automaticNodTimer.Stop();
        automaticNodTimer.Interval = delay;
        automaticNodTimer.Start();
    }

    private void ResetVisualState()
    {
        ResetHead();
        ResetSparkles();
    }

    private void ResetHead()
    {
        headScaleTransform.BeginAnimation(ScaleTransform.ScaleYProperty, null);
        headTranslateTransform.BeginAnimation(TranslateTransform.YProperty, null);
        headScaleTransform.ScaleY = 1;
        headTranslateTransform.Y = 0;
    }

    private void ResetSparkles()
    {
        for (var index = 0; index < sparkleElements.Count; index++)
        {
            sparkleElements[index].BeginAnimation(UIElement.OpacityProperty, null);
            sparkleScaleTransforms[index].BeginAnimation(ScaleTransform.ScaleXProperty, null);
            sparkleScaleTransforms[index].BeginAnimation(ScaleTransform.ScaleYProperty, null);
            sparkleTranslateTransforms[index].BeginAnimation(TranslateTransform.XProperty, null);
            sparkleTranslateTransforms[index].BeginAnimation(TranslateTransform.YProperty, null);
            sparkleElements[index].Opacity = 0;
            sparkleScaleTransforms[index].ScaleX = 0.1;
            sparkleScaleTransforms[index].ScaleY = 0.1;
            sparkleTranslateTransforms[index].X = 0;
            sparkleTranslateTransforms[index].Y = -43;
        }
    }
}
