using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Animation;

/// <summary>
/// Hosts Evan Jo's layered Happy visuals and exposes animation lifecycle APIs.
/// </summary>
public partial class EvanJoHappyAnimationView : UserControl
{
    private readonly EvanJoHappyAnimationController animationController;
    private bool isAnimationRequested;

    public EvanJoHappyAnimationView()
    {
        InitializeComponent();
        IsLayerSetAvailable = TryLoadLayerImages();
        animationController = new EvanJoHappyAnimationController(
            this,
            CharacterTranslateTransform,
            JumpLinesImage,
            [
                Flower01Image,
                Flower02Image,
                Flower03Image,
                Flower04Image,
                Flower05Image,
                Flower06Image,
                Flower07Image
            ],
            [
                Flower01ScaleTransform,
                Flower02ScaleTransform,
                Flower03ScaleTransform,
                Flower04ScaleTransform,
                Flower05ScaleTransform,
                Flower06ScaleTransform,
                Flower07ScaleTransform
            ],
            [
                Flower01TranslateTransform,
                Flower02TranslateTransform,
                Flower03TranslateTransform,
                Flower04TranslateTransform,
                Flower05TranslateTransform,
                Flower06TranslateTransform,
                Flower07TranslateTransform
            ]);

        Loaded += OnLoaded;
        Unloaded += (_, _) => animationController.Stop();
        IsVisibleChanged += (_, _) =>
        {
            if (IsVisible && isAnimationRequested && IsLoaded && IsLayerSetAvailable)
                animationController.Start();
            else if (!IsVisible)
                animationController.Stop();
        };
    }

    public bool IsLayerSetAvailable { get; }

    public void Start()
    {
        isAnimationRequested = true;

        if (IsLoaded && IsVisible && IsLayerSetAvailable)
        {
            animationController.Start();
        }
    }

    public void Stop()
    {
        isAnimationRequested = false;
        animationController.Stop();
    }

    private void OnLoaded(object sender, RoutedEventArgs e)
    {
        if (isAnimationRequested && IsVisible && IsLayerSetAvailable)
        {
            animationController.Start();
        }
    }

    private bool TryLoadLayerImages()
    {
        try
        {
            BodyImage.Source = LoadImage("Body/evan_jo_happy_body.png");
            HeadImage.Source = LoadImage("Head/evan_jo_happy_head.png");
            JumpLinesImage.Source = LoadImage("JumpLines/evan_jo_happy_jump_lines.png");

            var flowers = LoadImage("Flowers/evan_jo_happy_flowers.png");
            Flower01Image.Source = flowers;
            Flower02Image.Source = flowers;
            Flower03Image.Source = flowers;
            Flower04Image.Source = flowers;
            Flower05Image.Source = flowers;
            Flower06Image.Source = flowers;
            Flower07Image.Source = flowers;
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
            $"pack://application:,,,/EvanJoDesktopPet.Windows;component/Resources/Characters/EvanJo/Happy/Animation/{assetPath}",
            UriKind.Absolute);
        image.EndInit();
        image.Freeze();
        return image;
    }
}
