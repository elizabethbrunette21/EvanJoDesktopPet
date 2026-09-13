using System.Windows;
using System.Windows.Media;

namespace EvanJoDesktopPet.Windows.Platform.Windowing;

/// <summary>
/// Defines the Windows-specific shell for a desktop-pet surface.
/// Interaction and behavior remain outside this window-policy boundary.
/// </summary>
public class TransparentPetWindow : Window
{
    protected TransparentPetWindow()
    {
        WindowStyle = WindowStyle.None;
        AllowsTransparency = true;
        Background = Brushes.Transparent;
        ResizeMode = ResizeMode.NoResize;
        ShowInTaskbar = false;
        ShowActivated = false;
        Focusable = false;
        Topmost = true;
    }
}
