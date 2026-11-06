using System;
using System.Collections.Generic;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Input;
using EvanJoDesktopPet.Windows.Characters.EvanJo;
using EvanJoDesktopPet.Windows.Core.Behavior;
using EvanJoDesktopPet.Windows.Core.Characters;
using EvanJoDesktopPet.Windows.Platform.Windowing;

namespace EvanJoDesktopPet.Windows.Features.DesktopPet;

public partial class DesktopPetWindow : TransparentPetWindow
{
    private const double DesktopMargin = 24;
    private const double ClickMovementThreshold = 6;
    protected override double LeftEdgeAllowance => 40;
    protected override double TopEdgeAllowance => 24;
    protected override double RightEdgeAllowance => 48;
    private readonly PetBehaviorController behaviorController;
    private readonly ContextMenu contextMenu;
    private readonly Dictionary<PetPoseId, MenuItem> poseMenuItems = new();
    private MenuItem? automaticModeMenuItem;
    private MenuItem? fixedModeMenuItem;
    private bool hasPlacedInitialWindow;
    private Point? mouseDownPosition;
    private bool isDragging;

    public DesktopPetWindow()
    {
        InitializeComponent();

        behaviorController = new PetBehaviorController(
            new EvanJoCharacterDefinition());
        behaviorController.StateChanged += ApplyBehaviorState;
        ApplyBehaviorState(behaviorController.State);
        contextMenu = CreateContextMenu();
    }

    protected override void OnContentRendered(EventArgs e)
    {
        base.OnContentRendered(e);

        if (hasPlacedInitialWindow)
        {
            return;
        }

        hasPlacedInitialWindow = true;
        MoveToInitialPosition();
        behaviorController.SetAutomatic();
    }

    private void PetSurface_OnMouseLeftButtonDown(
        object sender,
        MouseButtonEventArgs e)
    {
        if (e.LeftButton != MouseButtonState.Pressed)
        {
            return;
        }

        mouseDownPosition = PointToScreen(e.GetPosition(this));
        PetSurface.CaptureMouse();
        e.Handled = true;
    }

    private void PetSurface_OnMouseMove(object sender, MouseEventArgs e)
    {
        if (mouseDownPosition is not { } start || isDragging
            || e.LeftButton != MouseButtonState.Pressed
            || IsClick(start, PointToScreen(e.GetPosition(this)))) return;

        isDragging = true;
        PetSurface.ReleaseMouseCapture();
        behaviorController.SuspendAutomatic();
        try
        {
            DragMove();
        }
        catch (InvalidOperationException)
        {
            // The button may be released between the move event and DragMove.
        }
        finally
        {
            mouseDownPosition = null;
            isDragging = false;
            behaviorController.ResumeAutomatic();
        }

        e.Handled = true;
    }

    private void PetSurface_OnMouseLeftButtonUp(object sender, MouseButtonEventArgs e)
    {
        if (mouseDownPosition is null || isDragging) return;
        mouseDownPosition = null;
        PetSurface.ReleaseMouseCapture();
        behaviorController.ReactToClick();
        e.Handled = true;
    }

    private void PetSurface_OnMouseRightButtonUp(
        object sender,
        MouseButtonEventArgs e)
    {
        contextMenu.PlacementTarget = PetSurface;
        contextMenu.Placement = PlacementMode.MousePoint;
        contextMenu.IsOpen = true;
        e.Handled = true;
    }

    private ContextMenu CreateContextMenu()
    {
        var isChinese = CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "zh";
        var menu = new ContextMenu { Style = (Style)FindResource("PetContextMenuStyle") };
        menu.Resources.Add(typeof(MenuItem), FindResource("PetMenuItemStyle"));
        menu.Resources.Add(typeof(Separator), FindResource("PetMenuSeparatorStyle"));
        var sectionStyle = (Style)FindResource("PetMenuSectionStyle");
        menu.Items.Add(new Separator { Tag = isChinese ? "状态" : "POSE", Style = sectionStyle });
        var character = behaviorController.State.Character;

        foreach (var pose in character.AvailablePoses)
        {
            var poseMenuItem = new MenuItem
            {
                Header = character.GetPoseDisplayName(pose),
                IsCheckable = true
            };
            poseMenuItem.Click += (_, _) => SelectPose(pose);
            menu.Items.Add(poseMenuItem);
            poseMenuItems.Add(pose, poseMenuItem);
        }

        menu.Items.Add(new Separator());
        menu.Items.Add(new Separator { Tag = isChinese ? "模式" : "MODE", Style = sectionStyle });
        automaticModeMenuItem = new MenuItem
        {
            Header = isChinese ? "自动切换" : "Automatic",
            IsCheckable = true
        };
        automaticModeMenuItem.Click += (_, _) => behaviorController.SetAutomatic();
        menu.Items.Add(automaticModeMenuItem);

        fixedModeMenuItem = new MenuItem
        {
            Header = isChinese ? "固定状态" : "Fixed",
            IsCheckable = true
        };
        fixedModeMenuItem.Click += (_, _) => behaviorController.SetFixed();
        menu.Items.Add(fixedModeMenuItem);
        menu.Items.Add(new Separator());

        var resetPositionItem = new MenuItem { Header = isChinese ? "重置位置" : "Reset Position" };
        resetPositionItem.Click += (_, _) => MoveToInitialPosition();
        menu.Items.Add(resetPositionItem);
        menu.Items.Add(new Separator());

        var quitItem = new MenuItem { Header = isChinese ? "退出" : "Quit" };
        quitItem.Click += (_, _) => Application.Current.Shutdown();
        menu.Items.Add(quitItem);

        UpdateMenuState(behaviorController.State);
        return menu;
    }

    private void SelectPose(PetPoseId pose)
    {
        behaviorController.SetPose(pose);
    }

    private static bool IsClick(Point mouseDownPosition, Point mouseUpPosition) =>
        (mouseUpPosition - mouseDownPosition).Length <= ClickMovementThreshold;

    private void ApplyBehaviorState(PetBehaviorState behaviorState)
    {
        if (!Dispatcher.CheckAccess())
        {
            Dispatcher.Invoke(() => ApplyBehaviorState(behaviorState));
            return;
        }

        var samePose = ReferenceEquals(PoseView.CharacterDefinition, behaviorState.Character)
            && PoseView.Pose == behaviorState.CurrentPose;
        PoseView.CharacterDefinition = behaviorState.Character;
        PoseView.Pose = behaviorState.CurrentPose;
        if (samePose) PoseView.RestartAnimation();
        UpdateMenuState(behaviorState);
    }

    private void UpdateMenuState(PetBehaviorState behaviorState)
    {
        foreach (var (pose, menuItem) in poseMenuItems)
        {
            menuItem.IsChecked = behaviorState.Mode == PetBehaviorMode.Fixed
                && pose == behaviorController.FixedPose;
        }

        if (automaticModeMenuItem is not null)
        {
            automaticModeMenuItem.IsChecked =
                behaviorState.Mode == PetBehaviorMode.Automatic;
        }

        if (fixedModeMenuItem is not null)
        {
            fixedModeMenuItem.IsChecked =
                behaviorState.Mode == PetBehaviorMode.Fixed;
        }
    }

    protected override void OnClosed(EventArgs e)
    {
        behaviorController.StateChanged -= ApplyBehaviorState;
        behaviorController.Dispose();
        base.OnClosed(e);
    }

    private void MoveToInitialPosition()
    {
        var workingArea = SystemParameters.WorkArea;
        var windowWidth = ActualWidth > 0 ? ActualWidth : Width;
        var windowHeight = ActualHeight > 0 ? ActualHeight : Height;

        Left = Math.Max(
            workingArea.Left,
            workingArea.Right - windowWidth + RightEdgeAllowance);
        Top = Math.Max(
            workingArea.Top,
            workingArea.Bottom - windowHeight - DesktopMargin);
    }

}
