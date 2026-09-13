using System;
using System.Collections.Generic;
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
    private static readonly TimeSpan HappyReactionDuration = TimeSpan.FromSeconds(1.8);
    private readonly PetBehaviorController behaviorController;
    private readonly ContextMenu contextMenu;
    private readonly Dictionary<PetPoseId, MenuItem> poseMenuItems = new();
    private MenuItem? automaticModeMenuItem;
    private MenuItem? fixedModeMenuItem;
    private bool hasPlacedInitialWindow;

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
    }

    private void PetSurface_OnMouseLeftButtonDown(
        object sender,
        MouseButtonEventArgs e)
    {
        if (e.LeftButton != MouseButtonState.Pressed)
        {
            return;
        }

        var mouseDownPosition = PointToScreen(e.GetPosition(this));
        DragMove();

        var mouseUpPosition = PointToScreen(Mouse.GetPosition(this));
        if (IsClick(mouseDownPosition, mouseUpPosition))
        {
            StartTemporaryHappyReaction();
        }

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
        var menu = new ContextMenu();
        var poseMenu = new MenuItem { Header = "Pose" };
        var character = behaviorController.State.Character;

        foreach (var pose in character.AvailablePoses)
        {
            var poseMenuItem = new MenuItem
            {
                Header = character.GetPoseDisplayName(pose),
                IsCheckable = true
            };
            poseMenuItem.Click += (_, _) => SelectPose(pose);
            poseMenu.Items.Add(poseMenuItem);
            poseMenuItems.Add(pose, poseMenuItem);
        }

        menu.Items.Add(poseMenu);
        menu.Items.Add(new Separator());

        var modeMenu = new MenuItem { Header = "Mode" };
        automaticModeMenuItem = new MenuItem
        {
            Header = "Automatic",
            IsCheckable = true
        };
        automaticModeMenuItem.Click += (_, _) => behaviorController.SetAutomatic();
        modeMenu.Items.Add(automaticModeMenuItem);

        fixedModeMenuItem = new MenuItem
        {
            Header = "Fixed",
            IsCheckable = true
        };
        fixedModeMenuItem.Click += (_, _) => behaviorController.SetFixed();
        modeMenu.Items.Add(fixedModeMenuItem);
        menu.Items.Add(modeMenu);
        menu.Items.Add(new Separator());

        var resetPositionItem = new MenuItem { Header = "Reset Position" };
        resetPositionItem.Click += (_, _) => MoveToInitialPosition();
        menu.Items.Add(resetPositionItem);
        menu.Items.Add(new Separator());

        var quitItem = new MenuItem { Header = "Quit EvanJoDesktopPet" };
        quitItem.Click += (_, _) => Application.Current.Shutdown();
        menu.Items.Add(quitItem);

        UpdateMenuState(behaviorController.State);
        return menu;
    }

    private void SelectPose(PetPoseId pose)
    {
        behaviorController.SetPose(pose);
    }

    private async void StartTemporaryHappyReaction()
    {
        try
        {
            await behaviorController.ShowTemporaryPose(
                PetPoseId.Happy,
                HappyReactionDuration);
        }
        catch (ObjectDisposedException)
        {
            // Window shutdown can dispose the behavior controller after a click.
        }
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

        PoseView.CharacterDefinition = behaviorState.Character;
        PoseView.Pose = behaviorState.CurrentPose;
        UpdateMenuState(behaviorState);
    }

    private void UpdateMenuState(PetBehaviorState behaviorState)
    {
        foreach (var (pose, menuItem) in poseMenuItems)
        {
            menuItem.IsChecked = pose == behaviorState.CurrentPose;
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
            workingArea.Right - windowWidth - DesktopMargin);
        Top = Math.Max(
            workingArea.Top,
            workingArea.Bottom - windowHeight - DesktopMargin);
    }
}
