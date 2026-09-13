using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Interaction;

/// <summary>
/// Bridges head-only pointer movement to the character-local pet detector.
/// </summary>
public sealed class EvanJoHeadPetInteractionView : Border
{
    private readonly EvanJoHeadPetDetector detector = new();
    private bool isActive;

    public EvanJoHeadPetInteractionView()
    {
        Background = Brushes.Transparent;
        IsHitTestVisible = false;

        detector.PettingDetected += () => PettingDetected?.Invoke();
        MouseEnter += (_, _) => detector.Reset();
        MouseLeave += (_, _) => detector.Reset();
        MouseLeftButtonDown += (_, _) => detector.Reset();
        MouseLeftButtonUp += (_, _) => detector.Reset();
        MouseMove += OnMouseMove;
        SizeChanged += (_, _) => detector.SetHeadBounds(ActualWidth, ActualHeight);
    }

    public event Action? PettingDetected;

    public void StartInteraction()
    {
        isActive = true;
        IsHitTestVisible = true;
        detector.SetHeadBounds(ActualWidth, ActualHeight);
    }

    public void StopInteraction()
    {
        isActive = false;
        IsHitTestVisible = false;
        detector.Reset();
    }

    private void OnMouseMove(object sender, MouseEventArgs e)
    {
        if (!isActive || HasPressedMouseButton(e))
        {
            detector.Reset();
            return;
        }

        var point = e.GetPosition(this);
        detector.RegisterPointerMove(point.X, point.Y, DateTimeOffset.UtcNow);
    }

    private static bool HasPressedMouseButton(MouseEventArgs e) =>
        e.LeftButton == MouseButtonState.Pressed
        || e.RightButton == MouseButtonState.Pressed
        || e.MiddleButton == MouseButtonState.Pressed
        || e.XButton1 == MouseButtonState.Pressed
        || e.XButton2 == MouseButtonState.Pressed;
}
