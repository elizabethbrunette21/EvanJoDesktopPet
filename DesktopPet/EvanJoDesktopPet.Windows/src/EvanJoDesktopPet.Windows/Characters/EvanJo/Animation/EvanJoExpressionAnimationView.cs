using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Animation;

/// <summary>Local layered timelines for Loading, Thinking and Sleepy.</summary>
internal sealed class EvanJoExpressionAnimationView : UserControl
{
    private readonly Storyboard storyboard = new();
    private readonly List<(Animatable Target, DependencyProperty Property, AnimationTimeline Timeline)> transformAnimations = new();
    private readonly bool reduceMotion = !SystemParameters.ClientAreaAnimation;
    private TranslateTransform? loadingTextMove;
    private TranslateTransform? loadingBodyMove;
    private RotateTransform? loadingSpinnerRotation;
    private bool isStarted;

    internal EvanJoExpressionAnimationView(PetPoseId pose)
    {
        Width = 240;
        Height = 184;
        ClipToBounds = true;
        Focusable = false;
        RenderOptions.SetBitmapScalingMode(this, BitmapScalingMode.HighQuality);

        try
        {
            if (pose == PetPoseId.Loading) Content = BuildLoading();
            else if (pose == PetPoseId.Thinking) Content = BuildThinking();
            else if (pose == PetPoseId.Sleepy) Content = BuildSleepy();
            IsLayerSetAvailable = Content is not null;
        }
        catch (Exception exception) when (exception is IOException
            or NotSupportedException or ArgumentException or InvalidOperationException)
        {
            Debug.WriteLine($"Evan Jo {pose} layers unavailable: {exception.Message}");
            Content = null;
        }

        Loaded += (_, _) => Start();
        Unloaded += (_, _) => Stop();
        IsVisibleChanged += (_, _) => { if (IsVisible) Start(); else Stop(); };
    }

    internal bool IsLayerSetAvailable { get; }

    internal void Start()
    {
        if (isStarted || !IsLoaded || !IsVisible || !IsLayerSetAvailable) return;
        isStarted = true;
        storyboard.Begin(this, HandoffBehavior.SnapshotAndReplace, true);
        foreach (var (target, property, timeline) in transformAnimations)
            target.BeginAnimation(property, timeline);
        if (loadingTextMove is not null && loadingBodyMove is not null && loadingSpinnerRotation is not null && !reduceMotion)
        {
            var pass = Frames((0, 159.14), (0.15, 159.14), (2.95, -180), (3.35, -180));
            pass.RepeatBehavior = RepeatBehavior.Forever;
            loadingTextMove.BeginAnimation(TranslateTransform.XProperty, pass);
            loadingSpinnerRotation.BeginAnimation(RotateTransform.AngleProperty,
                new DoubleAnimation(0, 360, TimeSpan.FromSeconds(2.8)) { RepeatBehavior = RepeatBehavior.Forever });
            loadingBodyMove.BeginAnimation(TranslateTransform.YProperty,
                new DoubleAnimation(0, -1, TimeSpan.FromSeconds(0.55))
                {
                    AutoReverse = true,
                    RepeatBehavior = RepeatBehavior.Forever,
                    EasingFunction = new SineEase { EasingMode = EasingMode.EaseInOut }
                });
        }
    }

    internal void Stop()
    {
        if (!isStarted) return;
        storyboard.Remove(this);
        foreach (var (target, property, _) in transformAnimations)
            target.BeginAnimation(property, null);
        loadingTextMove?.BeginAnimation(TranslateTransform.XProperty, null);
        loadingBodyMove?.BeginAnimation(TranslateTransform.YProperty, null);
        loadingSpinnerRotation?.BeginAnimation(RotateTransform.AngleProperty, null);
        isStarted = false;
    }

    private Canvas BuildLoading()
    {
        var scene = new Canvas { Width = 176, Height = 132 };
        var textClip = new Canvas { Width = 176, Height = 132, ClipToBounds = true };
        scene.Children.Add(textClip);
        var text = Layer(textClip, "Loading", "Text", 180, 180, 88, 83);
        loadingTextMove = new TranslateTransform(159.14, 0);
        text.RenderTransform = loadingTextMove;
        var body = Layer(scene, "Loading", "Body", 139, 139, 88, 73);
        loadingBodyMove = new TranslateTransform();
        body.RenderTransform = loadingBodyMove;
        var spinner = Layer(scene, "Loading", "Spinner", 74, 74, 88, 38);
        loadingSpinnerRotation = new RotateTransform(0, 37, 37);
        spinner.RenderTransform = loadingSpinnerRotation;

        Normalize(scene, new Rect(18.5 + 136.0 / 1254 * 139,
            3.5 + 24.0 / 1254 * 139, 969.0 / 1254 * 139, 1102.0 / 1254 * 139));
        return scene;
    }

    private Canvas BuildThinking()
    {
        var scene = new Canvas { Width = 176, Height = 154 };
        Layer(scene, "Thinking", "Body", 177, 177, 88, 94);
        var glasses = Layer(scene, "Thinking", "Glasses", 101, 26, 101, 72);
        var push = new TranslateTransform();
        glasses.RenderTransform = push;
        if (!reduceMotion)
            Animate(push, TranslateTransform.YProperty,
                Frames((0, 0), (0.14, -3.5), (0.20, -3.5), (0.36, 0)));

        var bubble = Layer(scene, "Thinking", "Bubble", 92, 92, 43, 32, 0);
        FadeIn(bubble, 0.34, 0.22);
        Pop(bubble, 0.86, 0.34, 0.22);
        var sizes = new[] { 177.0, 149, 168 };
        for (var index = 0; index < 3; index++)
        {
            var dot = Layer(scene, "Thinking", $"Dot{index + 1}", sizes[index], sizes[index],
                35 + index * 11, index == 2 ? 25 : 26, 0);
            FadeIn(dot, 0.62 + index * 0.20, 0.14);
            Pop(dot, 0.7, 0.62 + index * 0.20, 0.14);
        }

        // Use the reference path in source-pixel coordinates; no replacement artwork.
        var path = new[]
        {
            new Point(361, 808), new Point(345.3, 806.7), new Point(329.8, 818.4),
            new Point(324, 845.5), new Point(328.4, 873), new Point(346.2, 903.8),
            new Point(376.6, 922.4), new Point(400, 923.3), new Point(417.8, 940.8),
            new Point(459, 972.2), new Point(488.1, 983.9), new Point(525.7, 997.5),
            new Point(568.2, 1007.4), new Point(586, 1012), new Point(665.5, 1048)
        };
        var leafWidth = 772.0 / 1254 * 177 * 0.115;
        var leaf = Layer(scene, "Thinking", "Leaf", leafWidth, leafWidth * 527 / 575,
            88 + (665.5 - 612) * 154 / 1163, 77 + (1048 - 612.5) * 154 / 1163, 0);
        leaf.Source = new CroppedBitmap((BitmapSource)leaf.Source, new Int32Rect(341, 337, 575, 527));
        var leafMove = new TranslateTransform();
        leaf.RenderTransform = leafMove;
        if (!reduceMotion)
        {
            var distances = new double[path.Length];
            for (var index = 1; index < path.Length; index++)
                distances[index] = distances[index - 1] + (path[index] - path[index - 1]).Length;
            var xs = new DoubleAnimationUsingKeyFrames();
            var ys = new DoubleAnimationUsingKeyFrames();
            for (var index = 0; index < path.Length; index++)
            {
                var time = TimeSpan.FromSeconds(1 + 1.62 * distances[index] / distances[^1]);
                var offset = (path[index] - path[^1]) * (177.0 / 1254);
                xs.KeyFrames.Add(new LinearDoubleKeyFrame(offset.X, KeyTime.FromTimeSpan(time)));
                ys.KeyFrames.Add(new LinearDoubleKeyFrame(offset.Y, KeyTime.FromTimeSpan(time)));
            }
            Animate(leafMove, TranslateTransform.XProperty, xs);
            Animate(leafMove, TranslateTransform.YProperty, ys);
        }
        Animate(leaf, OpacityProperty, Frames((0, 0), (1, 0), (1.12, 1), (2.78, 1), (3.06, 0)));
        Normalize(scene, new Rect(-0.5 + 282.0 / 1254 * 177,
            5.5 + 126.0 / 1254 * 177, 772.0 / 1254 * 177, 914.0 / 1254 * 177));
        return scene;
    }

    private Canvas BuildSleepy()
    {
        // Reference composition is 419 x 418. Fit the body, not the surrounding mist.
        var scene = new Canvas { Width = 419, Height = 418 };
        var mist = Layer(scene, "Sleepy", "BlueMist", 421.632, 363.072, 207.816, 181.536);
        mist.Opacity = 0.8;
        var mistMove = new TranslateTransform();
        mist.RenderTransform = mistMove;
        if (!reduceMotion)
            Animate(mistMove, TranslateTransform.XProperty, Frames((0, -8), (1, 8)));

        var bodyBounds = new Rect(54.6118, 47.2, 319.5764, 369.2);
        AlignedLayer(scene, "BodyBack", new Rect(107, 10, 805, 930), bodyBounds);
        var contact = new Canvas { Width = 419, Height = 418 };
        scene.Children.Add(contact);
        var glasses = Layer(contact, "Sleepy", "Glasses", 196.522, 69.452, 238.261, 256.726);
        var reflection = Layer(contact, "Sleepy", "GlassesReflection", 196.522, 69.452, 238.261, 256.726, 0);
        AlignedLayer(contact, "HandFront", new Rect(472, 338, 331, 456),
            new Rect(206.9264, 238.8, 89.2192, 122.912));
        var push = new TranslateTransform();
        contact.RenderTransform = push;
        if (!reduceMotion)
        {
            Animate(push, TranslateTransform.XProperty, Frames((0, 0), (0.65, 0), (0.82, 2.12)));
            Animate(push, TranslateTransform.YProperty, Frames((0, 0), (0.65, 0), (0.82, -9.89)));
        }
        Animate(glasses, OpacityProperty, Frames((0, 1), (0.82, 1), (0.96, 0)));
        FadeIn(reflection, 0.82, 0.14);
        var sparkle = Layer(scene, "Sleepy", "YellowSparkle", 46.2, 52.2, 119.9, 198.9, 0);
        FadeIn(sparkle, 1, 0.16);
        Pop(sparkle, 0.72, 1, 0.16);
        Normalize(scene, bodyBounds);
        return scene;
    }

    private static void Normalize(Canvas scene, Rect visibleBody)
    {
        scene.HorizontalAlignment = HorizontalAlignment.Left;
        scene.VerticalAlignment = VerticalAlignment.Top;
        // Match Idle's visible height and keep feet fixed across every expression.
        var scale = 130.7 / visibleBody.Height;
        scene.RenderTransform = new MatrixTransform(scale, 0, 0, scale,
            120 - (visibleBody.Left + visibleBody.Width / 2) * scale,
            176 - visibleBody.Bottom * scale);
    }

    private static Image Layer(Canvas parent, string pose, string name,
        double width, double height, double centerX, double centerY, double opacity = 1)
    {
        var bitmap = new BitmapImage();
        bitmap.BeginInit();
        bitmap.CacheOption = BitmapCacheOption.OnLoad;
        bitmap.UriSource = new Uri($"pack://application:,,,/EvanJoDesktopPet.Windows;component/Resources/Characters/EvanJo/{pose}/Animation/{name}.png");
        bitmap.EndInit();
        bitmap.Freeze();
        var image = new Image
        {
            Source = bitmap, Width = width, Height = height,
            Stretch = Stretch.Uniform, Opacity = opacity
        };
        Canvas.SetLeft(image, centerX - width / 2);
        Canvas.SetTop(image, centerY - height / 2);
        parent.Children.Add(image);
        return image;
    }

    private static void AlignedLayer(Canvas parent, string name, Rect sourceBounds, Rect target)
    {
        var width = target.Width * 1024 / sourceBounds.Width;
        var height = target.Height * 1024 / sourceBounds.Height;
        var image = Layer(parent, "Sleepy", name, width, height,
            target.Left - sourceBounds.Left / 1024 * width + width / 2,
            target.Top - sourceBounds.Top / 1024 * height + height / 2);
        image.Stretch = Stretch.Fill;
    }

    private void FadeIn(Image image, double start, double duration) =>
        Animate(image, OpacityProperty, Frames((0, 0), (start, 0), (start + duration, 1)));

    private void Pop(Image image, double from, double start, double duration)
    {
        if (reduceMotion) return;
        var scale = new ScaleTransform(1, 1, image.Width / 2, image.Height / 2);
        image.RenderTransform = scale;
        Animate(scale, ScaleTransform.ScaleXProperty, Frames((0, from), (start, from), (start + duration, 1)));
        Animate(scale, ScaleTransform.ScaleYProperty, Frames((0, from), (start, from), (start + duration, 1)));
    }

    private void Animate(DependencyObject target, DependencyProperty property, AnimationTimeline timeline)
    {
        if (target is Animatable animatable)
        {
            transformAnimations.Add((animatable, property, timeline));
            return;
        }
        Storyboard.SetTarget(timeline, target);
        Storyboard.SetTargetProperty(timeline, new PropertyPath(property));
        storyboard.Children.Add(timeline);
    }

    private static DoubleAnimationUsingKeyFrames Frames(params (double Time, double Value)[] values)
    {
        var frames = new DoubleAnimationUsingKeyFrames();
        foreach (var (time, value) in values)
            frames.KeyFrames.Add(new LinearDoubleKeyFrame(value, KeyTime.FromTimeSpan(TimeSpan.FromSeconds(time))));
        return frames;
    }
}
