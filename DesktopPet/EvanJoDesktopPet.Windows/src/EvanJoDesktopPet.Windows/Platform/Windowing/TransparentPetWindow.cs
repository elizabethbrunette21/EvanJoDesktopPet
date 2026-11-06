using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;
using System.Windows.Media;

namespace EvanJoDesktopPet.Windows.Platform.Windowing;

/// <summary>
/// Defines the Windows-specific shell for a desktop-pet surface.
/// Interaction and behavior remain outside this window-policy boundary.
/// </summary>
public class TransparentPetWindow : Window
{
    private const int WmMoving = 0x0216;

    protected virtual double LeftEdgeAllowance => 0;
    protected virtual double TopEdgeAllowance => 0;
    protected virtual double RightEdgeAllowance => 0;

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

    protected override void OnSourceInitialized(EventArgs e)
    {
        base.OnSourceInitialized(e);
        (PresentationSource.FromVisual(this) as HwndSource)?.AddHook(KeepVisibleWhileMoving);
    }

    private IntPtr KeepVisibleWhileMoving(IntPtr hwnd, int message, IntPtr wParam,
        IntPtr lParam, ref bool handled)
    {
        if (message != WmMoving) return IntPtr.Zero;

        var rectangle = Marshal.PtrToStructure<NativeRect>(lParam);
        var monitor = MonitorFromRect(lParam, 2);
        var info = new MonitorInfo { Size = Marshal.SizeOf<MonitorInfo>() };
        if (monitor == IntPtr.Zero || !GetMonitorInfo(monitor, ref info)) return IntPtr.Zero;

        var width = rectangle.Right - rectangle.Left;
        var height = rectangle.Bottom - rectangle.Top;
        var dpi = VisualTreeHelper.GetDpi(this);
        var minLeft = info.WorkArea.Left - (int)Math.Round(LeftEdgeAllowance * dpi.DpiScaleX);
        var minTop = info.WorkArea.Top - (int)Math.Round(TopEdgeAllowance * dpi.DpiScaleY);
        var rightAllowance = (int)Math.Round(RightEdgeAllowance * dpi.DpiScaleX);
        rectangle.Left = Math.Clamp(rectangle.Left, minLeft,
            Math.Max(minLeft, info.WorkArea.Right - width + rightAllowance));
        rectangle.Top = Math.Clamp(rectangle.Top, minTop,
            Math.Max(minTop, info.WorkArea.Bottom - height));
        rectangle.Right = rectangle.Left + width;
        rectangle.Bottom = rectangle.Top + height;
        Marshal.StructureToPtr(rectangle, lParam, false);
        handled = true;
        return new IntPtr(1);
    }

    [DllImport("user32.dll")]
    private static extern IntPtr MonitorFromRect(IntPtr rectangle, uint flags);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool GetMonitorInfo(IntPtr monitor, ref MonitorInfo info);

    [StructLayout(LayoutKind.Sequential)]
    private struct NativeRect
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MonitorInfo
    {
        public int Size;
        public NativeRect MonitorArea;
        public NativeRect WorkArea;
        public uint Flags;
    }
}
