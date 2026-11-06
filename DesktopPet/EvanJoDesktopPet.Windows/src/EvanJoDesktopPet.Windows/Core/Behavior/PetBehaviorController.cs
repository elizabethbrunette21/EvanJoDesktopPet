using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Core.Behavior;

/// <summary>
/// Owns the selected pose and its cancellable automatic cycle.
/// Called on the window's UI thread so delayed continuations publish in order.
/// </summary>
public sealed class PetBehaviorController : IDisposable
{
    private CancellationTokenSource? cycleCancellation;
    private readonly Dictionary<PetPoseId, int> remainingCooldowns = new();
    private PetPoseId? lastExpressivePose;
    private PetPoseId fixedPose;
    private bool isLoadingOverrideActive;
    private bool isDisposed;

    public PetBehaviorController(IPetCharacterDefinition character)
    {
        ArgumentNullException.ThrowIfNull(character);
        fixedPose = ResolvePose(character, character.DefaultPose);
        State = new PetBehaviorState(character, fixedPose, PetBehaviorMode.Automatic);
    }

    public event Action<PetBehaviorState>? StateChanged;

    public PetBehaviorState State { get; private set; }

    public PetPoseId FixedPose => fixedPose;

    public void SetPose(PetPoseId pose)
    {
        ThrowIfDisposed();
        CancelCycle();
        fixedPose = ResolvePose(State.Character, pose);
        SetState(isLoadingOverrideActive ? PetPoseId.Loading : fixedPose, PetBehaviorMode.Fixed);
    }

    public void SetFixed()
    {
        ThrowIfDisposed();
        CancelCycle();
        if (!isLoadingOverrideActive) fixedPose = State.CurrentPose;
        SetState(isLoadingOverrideActive ? PetPoseId.Loading : fixedPose, PetBehaviorMode.Fixed);
    }

    public void SetAutomatic()
    {
        ThrowIfDisposed();
        CancelCycle();
        lastExpressivePose = null;
        remainingCooldowns.Clear();
        if (isLoadingOverrideActive)
        {
            SetState(PetPoseId.Loading, PetBehaviorMode.Automatic);
            return;
        }

        SetState(State.Character.DefaultPose, PetBehaviorMode.Automatic);
        StartCycle(State.Character.AutomaticPoseConfiguration, initial: true);
    }

    public void ReactToClick()
    {
        ThrowIfDisposed();
        if (isLoadingOverrideActive) return;
        var reaction = State.Character.ClickReactionFor(State.CurrentPose);
        if (reaction is null) return;

        CancelCycle();
        SetState(reaction.Pose, State.Mode);
        if (State.Mode == PetBehaviorMode.Automatic)
            StartCycle(State.Character.AutomaticPoseConfiguration, initial: false, interactionDuration: reaction.Duration);
        else
        {
            var cancellation = new CancellationTokenSource();
            cycleCancellation = cancellation;
            _ = RestoreFixedPoseAsync(reaction.Duration, cancellation);
        }
    }

    public void SuspendAutomatic()
    {
        ThrowIfDisposed();
        if (State.Mode == PetBehaviorMode.Automatic) CancelCycle();
    }

    public void ResumeAutomatic()
    {
        ThrowIfDisposed();
        if (State.Mode == PetBehaviorMode.Automatic && !isLoadingOverrideActive)
            StartAutomaticCycle(resetHistory: false);
    }

    public void SetLoadingOverrideActive(bool active)
    {
        ThrowIfDisposed();
        if (active == isLoadingOverrideActive) return;
        isLoadingOverrideActive = active;
        CancelCycle();
        if (active)
            SetState(PetPoseId.Loading, State.Mode);
        else if (State.Mode == PetBehaviorMode.Automatic)
            StartAutomaticCycle(resetHistory: false);
        else
            SetState(fixedPose, PetBehaviorMode.Fixed);
    }

    public void Dispose()
    {
        if (isDisposed) return;
        isDisposed = true;
        CancelCycle();
    }

    private void StartAutomaticCycle(bool resetHistory)
    {
        CancelCycle();
        if (resetHistory)
        {
            lastExpressivePose = null;
            remainingCooldowns.Clear();
        }
        if (State.Mode != PetBehaviorMode.Automatic || isLoadingOverrideActive) return;
        SetState(State.Character.DefaultPose, PetBehaviorMode.Automatic);
        StartCycle(State.Character.AutomaticPoseConfiguration, initial: true);
    }

    private void StartCycle(
        PetAutomaticPoseConfiguration? configuration,
        bool initial,
        TimeSpan? interactionDuration = null)
    {
        if (configuration is null) return;
        var cancellation = new CancellationTokenSource();
        cycleCancellation = cancellation;
        _ = RunCycleAsync(configuration, initial, interactionDuration, cancellation);
    }

    private async Task RunCycleAsync(
        PetAutomaticPoseConfiguration configuration,
        bool initial,
        TimeSpan? interactionDuration,
        CancellationTokenSource cancellation)
    {
        try
        {
            if (interactionDuration is { } duration)
            {
                await Task.Delay(duration, cancellation.Token);
                if (!IsCycleActive(cancellation)) return;
                SetState(State.Character.DefaultPose, PetBehaviorMode.Automatic);
            }

            while (IsCycleActive(cancellation))
            {
                var minimum = initial ? configuration.InitialIdleMinimum : configuration.RecoveryIdleMinimum;
                var maximum = initial ? configuration.InitialIdleMaximum : configuration.RecoveryIdleMaximum;
                await Task.Delay(RandomDelay(minimum, maximum), cancellation.Token);
                if (!IsCycleActive(cancellation)) return;

                var selected = SelectAutomaticPose(configuration);
                if (selected is null) return;
                RecordSelection(selected.Pose, configuration);
                SetState(selected.Pose, PetBehaviorMode.Automatic);
                await Task.Delay(selected.Duration, cancellation.Token);
                if (!IsCycleActive(cancellation)) return;
                SetState(State.Character.DefaultPose, PetBehaviorMode.Automatic);
                initial = false;
            }
        }
        catch (OperationCanceledException) when (cancellation.IsCancellationRequested)
        {
        }
        finally
        {
            if (ReferenceEquals(cycleCancellation, cancellation)) cycleCancellation = null;
            cancellation.Dispose();
        }
    }

    private async Task RestoreFixedPoseAsync(TimeSpan duration, CancellationTokenSource cancellation)
    {
        try
        {
            await Task.Delay(duration, cancellation.Token);
            if (ReferenceEquals(cycleCancellation, cancellation) && !isDisposed
                && State.Mode == PetBehaviorMode.Fixed && !isLoadingOverrideActive)
                SetState(fixedPose, PetBehaviorMode.Fixed);
        }
        catch (OperationCanceledException) when (cancellation.IsCancellationRequested)
        {
        }
        finally
        {
            if (ReferenceEquals(cycleCancellation, cancellation)) cycleCancellation = null;
            cancellation.Dispose();
        }
    }

    private PetTemporaryPose? SelectAutomaticPose(PetAutomaticPoseConfiguration configuration)
    {
        var totalWeight = 0;
        foreach (var candidate in configuration.WeightedPoses)
            if (candidate.Weight > 0 && candidate.TemporaryPose.Pose != lastExpressivePose
                && !remainingCooldowns.ContainsKey(candidate.TemporaryPose.Pose))
                totalWeight += candidate.Weight;

        if (totalWeight == 0) return null;
        var target = Random.Shared.Next(totalWeight);
        foreach (var candidate in configuration.WeightedPoses)
        {
            if (candidate.Weight <= 0 || candidate.TemporaryPose.Pose == lastExpressivePose
                || remainingCooldowns.ContainsKey(candidate.TemporaryPose.Pose)) continue;
            target -= candidate.Weight;
            if (target < 0) return candidate.TemporaryPose;
        }
        return null;
    }

    private void RecordSelection(PetPoseId pose, PetAutomaticPoseConfiguration configuration)
    {
        foreach (var cooldownPose in new List<PetPoseId>(remainingCooldowns.Keys))
        {
            var remaining = remainingCooldowns[cooldownPose] - 1;
            if (remaining <= 0) remainingCooldowns.Remove(cooldownPose);
            else remainingCooldowns[cooldownPose] = remaining;
        }
        if (configuration.CooldownSelections.TryGetValue(pose, out var cooldown) && cooldown > 0)
            remainingCooldowns[pose] = cooldown;
        lastExpressivePose = pose;
    }

    private static TimeSpan RandomDelay(TimeSpan minimum, TimeSpan maximum) =>
        minimum + TimeSpan.FromTicks((long)((maximum - minimum).Ticks * Random.Shared.NextDouble()));

    private bool IsCycleActive(CancellationTokenSource cancellation) =>
        !isDisposed && ReferenceEquals(cycleCancellation, cancellation)
        && !cancellation.IsCancellationRequested && !isLoadingOverrideActive
        && State.Mode == PetBehaviorMode.Automatic;

    private void CancelCycle()
    {
        cycleCancellation?.Cancel();
        cycleCancellation = null;
    }

    private void SetState(PetPoseId pose, PetBehaviorMode mode)
    {
        State = State with { CurrentPose = ResolvePose(State.Character, pose), Mode = mode };
        StateChanged?.Invoke(State);
    }

    private static PetPoseId ResolvePose(IPetCharacterDefinition character, PetPoseId pose) =>
        character.AvailablePoses.Contains(pose) ? pose : character.FallbackPose;

    private void ThrowIfDisposed()
    {
        if (isDisposed) throw new ObjectDisposedException(nameof(PetBehaviorController));
    }
}
