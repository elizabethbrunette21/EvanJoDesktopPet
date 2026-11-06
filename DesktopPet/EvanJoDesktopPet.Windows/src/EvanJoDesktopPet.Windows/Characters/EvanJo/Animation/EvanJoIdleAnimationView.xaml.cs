using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Animation;

/// <summary>
/// Hosts Evan Jo's layered Idle visuals and exposes animation lifecycle APIs.
/// </summary>
public partial class EvanJoIdleAnimationView : UserControl
{
    private readonly EvanJoIdleAnimationController animationController;
    private bool isAnimationRequested;

    public EvanJoIdleAnimationView()
    {
        InitializeComponent();
        IsLayerSetAvailable = TryLoadLayerImages();
        animationController = new EvanJoIdleAnimationController(
            HeadScaleTransform,
            HeadTranslateTransform,
            [
                Sparkle01Image,
                Sparkle02Image,
                Sparkle03Image,
                Sparkle04Image,
                Sparkle05Image,
                SparkleDotImage
            ],
            [
                Sparkle01ScaleTransform,
                Sparkle02ScaleTransform,
                Sparkle03ScaleTransform,
                Sparkle04ScaleTransform,
                Sparkle05ScaleTransform,
                SparkleDotScaleTransform
            ],
            [
                Sparkle01TranslateTransform,
                Sparkle02TranslateTransform,
                Sparkle03TranslateTransform,
                Sparkle04TranslateTransform,
                Sparkle05TranslateTransform,
                SparkleDotTranslateTransform
            ]);

        Loaded += (_, _) => StartIfVisible();
        Unloaded += (_, _) => SuspendAnimation();
        IsVisibleChanged += (_, _) => { if (IsVisible) StartIfVisible(); else SuspendAnimation(); };
        HeadPetInteraction.PettingDetected += OnHeadPettingDetected;
    }

    public bool IsLayerSetAvailable { get; }

    public void Start()
    {
        isAnimationRequested = true;
        StartIfVisible();
    }

    private void StartIfVisible()
    {
        if (!isAnimationRequested || !IsLoaded || !IsVisible || !IsLayerSetAvailable)
        {
            return;
        }

        HeadPetInteraction.StartInteraction();
        animationController.Start();
    }

    public void Stop()
    {
        isAnimationRequested = false;
        SuspendAnimation();
    }

    private void SuspendAnimation()
    {
        HeadPetInteraction.StopInteraction();
        animationController.Stop();
    }

    public void PlayNod() => animationController.PlayNod();

    public void PlaySparkles() => animationController.PlaySparkles();

    private void OnHeadPettingDetected() => animationController.PlayPettingFeedback();

    private bool TryLoadLayerImages()
    {
        try
        {
            BodyImage.Source = LoadImage("Body/evan_jo_idle_body.png");
            HeadImage.Source = LoadImage("Head/evan_jo_idle_head.png");
            Sparkle01Image.Source = LoadImage("Sparkles/evan_jo_idle_sparkle_01.png");
            Sparkle02Image.Source = LoadImage("Sparkles/evan_jo_idle_sparkle_02.png");
            Sparkle03Image.Source = LoadImage("Sparkles/evan_jo_idle_sparkle_03.png");
            Sparkle04Image.Source = LoadImage("Sparkles/evan_jo_idle_sparkle_04.png");
            Sparkle05Image.Source = LoadImage("Sparkles/evan_jo_idle_sparkle_05.png");
            SparkleDotImage.Source = LoadImage("Sparkles/evan_jo_idle_sparkle_dot.png");
            return true;
        }
        catch (Exception exception) when (
            exception is IOException
            or NotSupportedException
            or ArgumentException
            or InvalidOperationException)
        {
            return false;
        }
    }

    private static ImageSource LoadImage(string assetPath)
    {
        var image = new BitmapImage();
        image.BeginInit();
        image.CacheOption = BitmapCacheOption.OnLoad;
        image.UriSource = new Uri(
            $"pack://application:,,,/EvanJoDesktopPet.Windows;component/Resources/Characters/EvanJo/Idle/Animation/{assetPath}",
            UriKind.Absolute);
        image.EndInit();
        image.Freeze();
        return image;
    }
}
