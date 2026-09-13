using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EvanJoDesktopPet.Windows.Core.Characters;

namespace EvanJoDesktopPet.Windows.Core.Behavior;

/// <summary>
/// Owns display intent without depending on rendering, assets, or UI controls.
/// </summary>
public sealed class PetBehaviorController : IDisposable
{
    private readonly object syncRoot = new();
    private CancellationTokenSource? temporaryPoseCancellation;
    private PetBehaviorState state;
    private bool isDisposed;

    public PetBehaviorController(IPetCharacterDefinition character)
    {
        ArgumentNullException.ThrowIfNull(character);

        state = new PetBehaviorState(
            character,
            ResolvePose(character, character.DefaultPose),
            PetBehaviorMode.Automatic);
    }

    public event Action<PetBehaviorState>? StateChanged;

    public PetBehaviorState State
    {
        get
        {
            lock (syncRoot)
            {
                return state;
            }
        }
    }

    public void SetPose(PetPoseId pose)
    {
        Publish(UpdateState(
            mode: PetBehaviorMode.Fixed,
            pose: pose,
            cancelTemporaryPose: true));
    }

    public void SetFixed()
    {
        Publish(UpdateState(
            mode: PetBehaviorMode.Fixed,
            pose: State.CurrentPose,
            cancelTemporaryPose: true));
    }

    public void SetAutomatic()
    {
        var currentState = State;
        Publish(UpdateState(
            mode: PetBehaviorMode.Automatic,
            pose: currentState.Character.DefaultPose,
            cancelTemporaryPose: true));
    }

    /// <summary>
    /// Shows one caller-requested pose for the supplied duration, then restores
    /// the definition's default pose. This does not schedule future behavior.
    /// </summary>
    public async Task ShowTemporaryPose(
        PetPoseId pose,
        TimeSpan duration,
        CancellationToken cancellationToken = default)
    {
        if (duration < TimeSpan.Zero)
        {
            throw new ArgumentOutOfRangeException(nameof(duration));
        }

        var linkedCancellation = CancellationTokenSource.CreateLinkedTokenSource(
            cancellationToken);
        PetBehaviorState temporaryState;

        lock (syncRoot)
        {
            ThrowIfDisposed();
            CancelTemporaryPoseNoLock();
            temporaryPoseCancellation = linkedCancellation;
            state = state with
            {
                CurrentPose = ResolvePose(state.Character, pose)
            };
            temporaryState = state;
        }

        Publish(temporaryState);

        try
        {
            await Task.Delay(duration, linkedCancellation.Token);
        }
        catch (OperationCanceledException) when (linkedCancellation.IsCancellationRequested)
        {
            // Cancellation follows the same default-pose restoration path.
        }
        finally
        {
            PetBehaviorState? restoredState = null;

            lock (syncRoot)
            {
                if (ReferenceEquals(temporaryPoseCancellation, linkedCancellation))
                {
                    temporaryPoseCancellation = null;
                    state = state with
                    {
                        CurrentPose = ResolvePose(
                            state.Character,
                            state.Character.DefaultPose)
                    };
                    restoredState = state;
                }
            }

            linkedCancellation.Dispose();

            if (restoredState is not null)
            {
                Publish(restoredState);
            }
        }
    }

    public void Dispose()
    {
        lock (syncRoot)
        {
            if (isDisposed)
            {
                return;
            }

            isDisposed = true;
            CancelTemporaryPoseNoLock();
        }
    }

    private PetBehaviorState UpdateState(
        PetBehaviorMode mode,
        PetPoseId pose,
        bool cancelTemporaryPose)
    {
        lock (syncRoot)
        {
            ThrowIfDisposed();

            if (cancelTemporaryPose)
            {
                CancelTemporaryPoseNoLock();
            }

            state = state with
            {
                CurrentPose = ResolvePose(state.Character, pose),
                Mode = mode
            };
            return state;
        }
    }

    private void CancelTemporaryPoseNoLock()
    {
        temporaryPoseCancellation?.Cancel();
        temporaryPoseCancellation = null;
    }

    private static PetPoseId ResolvePose(
        IPetCharacterDefinition character,
        PetPoseId requestedPose) =>
        character.AvailablePoses.Contains(requestedPose)
            ? requestedPose
            : character.FallbackPose;

    private void Publish(PetBehaviorState updatedState) =>
        StateChanged?.Invoke(updatedState);

    private void ThrowIfDisposed()
    {
        if (isDisposed)
        {
            throw new ObjectDisposedException(nameof(PetBehaviorController));
        }
    }
}
