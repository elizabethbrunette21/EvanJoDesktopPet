using System;
using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Features.DesktopPet;

/// <summary>
/// Displays a selected static pose through a character definition's asset map.
/// </summary>
public partial class PetRenderer : UserControl
{
    public static readonly DependencyProperty CharacterDefinitionProperty =
        DependencyProperty.Register(
            nameof(CharacterDefinition),
            typeof(IPetCharacterDefinition),
            typeof(PetRenderer),
            new PropertyMetadata(null, OnRenderInputChanged));

    public static readonly DependencyProperty PoseProperty =
        DependencyProperty.Register(
            nameof(Pose),
            typeof(PetPoseId),
            typeof(PetRenderer),
            new PropertyMetadata(PetPoseId.Idle, OnRenderInputChanged));

    public PetRenderer()
    {
        InitializeComponent();
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
        ((PetRenderer)dependencyObject).RenderPose();
    }

    private void RenderPose()
    {
        if (CharacterDefinition is null)
        {
            PoseImage.Source = null;
            return;
        }

        PoseImage.Source = LoadPose(CharacterDefinition, Pose)
            ?? LoadPose(CharacterDefinition, CharacterDefinition.FallbackPose);
    }

    private static ImageSource? LoadPose(
        IPetCharacterDefinition character,
        PetPoseId pose)
    {
        if (!character.PoseAssets.TryGetValue(pose, out var assetUri))
        {
            return null;
        }

        try
        {
            var image = new BitmapImage();
            image.BeginInit();
            image.CacheOption = BitmapCacheOption.OnLoad;
            image.UriSource = assetUri;
            image.EndInit();
            image.Freeze();
            return image;
        }
        catch (Exception exception) when (
            exception is IOException
            or NotSupportedException
            or ArgumentException
            or InvalidOperationException)
        {
            return null;
        }
    }
}
