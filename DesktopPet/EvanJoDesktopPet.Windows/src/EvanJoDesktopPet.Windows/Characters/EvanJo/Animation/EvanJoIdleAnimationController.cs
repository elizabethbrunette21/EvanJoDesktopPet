using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Animation;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Animation;

/// <summary>
/// Runs Evan Jo Idle's one-shot visual sequences without owning input or pet behavior.
/// </summary>
public sealed class EvanJoIdleAnimationController
{
    private static readonly Vector[] SparkleOutwardOffsets =
    {
        new(11, -4),
        new(-6, -8),
        new(-11, -4),
        new(10, 9),
        new(-10, 9),
        new(-8, 3)
    };

    private readonly FrameworkElement animationHost;
    private readonly ScaleTransform headScaleTransform;
    private readonly TranslateTransform headTranslateTransform;
    private readonly IReadOnlyList<FrameworkElement> sparkleElements;
    private readonly IReadOnlyList<ScaleTransform> sparkleScaleTransforms;
    private readonly IReadOnlyList<TranslateTransform> sparkleTranslateTransforms;
    private Storyboard? nodStoryboard;
    private Storyboard? sparkleStoryboard;
    private bool isStarted;

    public EvanJoIdleAnimationController(
        FrameworkElement animationHost,
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

        this.animationHost = animationHost;
        this.headScaleTransform = headScaleTransform;
        this.headTranslateTransform = headTranslateTransform;
        this.sparkleElements = sparkleElements;
        this.sparkleScaleTransforms = sparkleScaleTransforms;
        this.sparkleTranslateTransforms = sparkleTranslateTransforms;
    }

    public void Start()
    {
        if (isStarted)
        {
            return;
        }

        isStarted = true;
        ResetVisualState();
        PlayNod();
    }

    public void Stop()
    {
        isStarted = false;
        StopStoryboard(ref nodStoryboard);
        StopStoryboard(ref sparkleStoryboard);
        ResetVisualState();
    }

    public void PlayNod()
    {
        if (!isStarted)
        {
            return;
        }

        StopStoryboard(ref nodStoryboard);
        ResetHead();

        var storyboard = CreateNodStoryboard(
            [(TimeSpan.FromSeconds(0.16), TimeSpan.FromSeconds(0.36))]);

        storyboard.Completed += (_, _) =>
        {
            if (ReferenceEquals(nodStoryboard, storyboard))
            {
                nodStoryboard = null;
                ResetHead();
            }
        };

        nodStoryboard = storyboard;
        storyboard.Begin(animationHost, HandoffBehavior.SnapshotAndReplace, true);
    }

    public void PlayPettingFeedback()
    {
        if (!isStarted)
        {
            return;
        }

        StopStoryboard(ref nodStoryboard);
        StopStoryboard(ref sparkleStoryboard);
        ResetVisualState();

        var storyboard = CreateNodStoryboard(
        [
            (TimeSpan.FromSeconds(0.16), TimeSpan.FromSeconds(0.36)),
            (TimeSpan.FromSeconds(0.60), TimeSpan.FromSeconds(0.80))
        ]);
        storyboard.Completed += (_, _) =>
        {
            if (ReferenceEquals(nodStoryboard, storyboard))
            {
                nodStoryboard = null;
                ResetHead();
                PlaySparkles();
            }
        };

        nodStoryboard = storyboard;
        storyboard.Begin(animationHost, HandoffBehavior.SnapshotAndReplace, true);
    }

    public void PlaySparkles()
    {
        if (!isStarted)
        {
            return;
        }

        StopStoryboard(ref sparkleStoryboard);
        ResetSparkles();

        var storyboard = new Storyboard { FillBehavior = FillBehavior.Stop };
        var fadeStart = TimeSpan.FromSeconds(1.0);
        var fadeEnd = TimeSpan.FromSeconds(1.22);

        for (var index = 0; index < sparkleElements.Count; index++)
        {
            var appearanceStart = TimeSpan.FromSeconds(index * 0.08);
            var appearanceEnd = appearanceStart + TimeSpan.FromSeconds(0.21);
            var offset = SparkleOutwardOffsets[index];

            AddSparkleTimeline(
                storyboard,
                sparkleElements[index],
                UIElement.OpacityProperty,
                CreateOpacityFrames(appearanceStart, appearanceEnd, fadeStart, fadeEnd));
            AddSparkleTimeline(
                storyboard,
                sparkleScaleTransforms[index],
                ScaleTransform.ScaleXProperty,
                CreateMovementFrames(0.42, 1.18, appearanceStart, appearanceEnd, fadeEnd));
            AddSparkleTimeline(
                storyboard,
                sparkleScaleTransforms[index],
                ScaleTransform.ScaleYProperty,
                CreateMovementFrames(0.42, 1.18, appearanceStart, appearanceEnd, fadeEnd));
            AddSparkleTimeline(
                storyboard,
                sparkleTranslateTransforms[index],
                TranslateTransform.XProperty,
                CreateMovementFrames(0, offset.X, appearanceStart, appearanceEnd, fadeEnd));
            AddSparkleTimeline(
                storyboard,
                sparkleTranslateTransforms[index],
                TranslateTransform.YProperty,
                CreateMovementFrames(0, offset.Y, appearanceStart, appearanceEnd, fadeEnd));
        }

        storyboard.Completed += (_, _) =>
        {
            if (ReferenceEquals(sparkleStoryboard, storyboard))
            {
                sparkleStoryboard = null;
                ResetSparkles();
            }
        };

        sparkleStoryboard = storyboard;
        storyboard.Begin(animationHost, HandoffBehavior.SnapshotAndReplace, true);
    }

    private Storyboard CreateNodStoryboard(
        IReadOnlyList<(TimeSpan Down, TimeSpan Recover)> nods)
    {
        var storyboard = new Storyboard { FillBehavior = FillBehavior.Stop };
        var translationFrames = CreateNodFrames(0, 1.5, nods);
        Storyboard.SetTarget(translationFrames, headTranslateTransform);
        Storyboard.SetTargetProperty(
            translationFrames,
            new PropertyPath(TranslateTransform.YProperty));
        storyboard.Children.Add(translationFrames);

        var scaleFrames = CreateNodFrames(1, 0.985, nods);
        Storyboard.SetTarget(scaleFrames, headScaleTransform);
        Storyboard.SetTargetProperty(
            scaleFrames,
            new PropertyPath(ScaleTransform.ScaleYProperty));
        storyboard.Children.Add(scaleFrames);

        return storyboard;
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

    private static void AddSparkleTimeline(
        Storyboard storyboard,
        DependencyObject target,
        DependencyProperty property,
        Timeline timeline)
    {
        Storyboard.SetTarget(timeline, target);
        Storyboard.SetTargetProperty(timeline, new PropertyPath(property));
        storyboard.Children.Add(timeline);
    }

    private void StopStoryboard(ref Storyboard? storyboard)
    {
        if (storyboard is null)
        {
            return;
        }

        storyboard.Remove(animationHost);
        storyboard = null;
    }

    private void ResetVisualState()
    {
        ResetHead();
        ResetSparkles();
    }

    private void ResetHead()
    {
        headScaleTransform.ScaleY = 1;
        headTranslateTransform.Y = 0;
    }

    private void ResetSparkles()
    {
        for (var index = 0; index < sparkleElements.Count; index++)
        {
            sparkleElements[index].Opacity = 0;
            sparkleScaleTransforms[index].ScaleX = 0.42;
            sparkleScaleTransforms[index].ScaleY = 0.42;
            sparkleTranslateTransforms[index].X = 0;
            sparkleTranslateTransforms[index].Y = 0;
        }
    }
}
