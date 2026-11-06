using System;

namespace EvanJoDesktopPet.Windows.Characters.EvanJo.Interaction;

/// <summary>
/// Detects gentle horizontal back-and-forth movement inside Evan Jo's head region.
/// </summary>
public sealed class EvanJoHeadPetDetector
{
    private const double MinimumMovement = 2;
    private const double MinimumLegDistance = 7;
    private const double MinimumTotalDistance = 20;
    private static readonly TimeSpan MaximumDuration = TimeSpan.FromSeconds(1.35);
    private static readonly TimeSpan CooldownDuration = TimeSpan.FromSeconds(1.2);

    private double headWidth;
    private double headHeight;
    private DateTimeOffset? startedAt;
    private DateTimeOffset cooldownUntil;
    private double? previousX;
    private double? legStartX;
    private int direction;
    private int reversals;
    private double totalDistance;

    public event Action? PettingDetected;

    public void SetHeadBounds(double width, double height)
    {
        headWidth = Math.Max(0, width);
        headHeight = Math.Max(0, height);
        Reset();
    }

    public void RegisterPointerMove(
        double x,
        double y,
        DateTimeOffset timestamp)
    {
        if (timestamp < cooldownUntil || !IsInsideHead(x, y))
        {
            Reset();
            return;
        }

        if (startedAt is null || previousX is null || legStartX is null)
        {
            Begin(x, timestamp);
            return;
        }

        var elapsed = timestamp - startedAt.Value;
        if (elapsed > MaximumDuration)
        {
            Begin(x, timestamp);
            return;
        }

        var deltaX = x - previousX.Value;
        if (Math.Abs(deltaX) < MinimumMovement)
        {
            return;
        }

        var newDirection = deltaX > 0 ? 1 : -1;
        totalDistance += Math.Abs(deltaX);

        if (direction == 0)
        {
            direction = newDirection;
        }
        else if (newDirection != direction
                 && Math.Abs(previousX.Value - legStartX.Value) >= MinimumLegDistance)
        {
            reversals++;
            direction = newDirection;
            legStartX = previousX.Value;
        }

        previousX = x;

        if (reversals < 2
            || totalDistance < MinimumTotalDistance)
        {
            return;
        }

        cooldownUntil = timestamp + CooldownDuration;
        Reset();
        PettingDetected?.Invoke();
    }

    public void Reset()
    {
        startedAt = null;
        previousX = null;
        legStartX = null;
        direction = 0;
        reversals = 0;
        totalDistance = 0;
    }

    private bool IsInsideHead(double x, double y) =>
        x >= 0 && x <= headWidth && y >= 0 && y <= headHeight;

    private void Begin(double x, DateTimeOffset timestamp)
    {
        startedAt = timestamp;
        previousX = x;
        legStartX = x;
        direction = 0;
        reversals = 0;
        totalDistance = 0;
    }
}
