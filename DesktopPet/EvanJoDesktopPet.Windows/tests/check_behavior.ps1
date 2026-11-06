$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot '..\src\EvanJoDesktopPet.Windows'
$files = @(
    'Core\Characters\PetPoseId.cs',
    'Core\Characters\PetPosePresentation.cs',
    'Core\Characters\IPetCharacterDefinition.cs',
    'Core\Behavior\PetBehaviorMode.cs',
    'Core\Behavior\PetBehaviorState.cs',
    'Core\Behavior\PetAutomaticPoseConfiguration.cs',
    'Core\Behavior\PetBehaviorController.cs',
    'Characters\EvanJo\EvanJoPoseAssets.cs',
    'Characters\EvanJo\EvanJoCharacterDefinition.cs'
) | ForEach-Object { Join-Path $root $_ }
$probeSource = @'
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using EvanJoDesktopPet.Windows.Core.Behavior;
using EvanJoDesktopPet.Windows.Core.Characters;

public sealed class BehaviorProbeCharacter : IPetCharacterDefinition
{
    public string Id => "probe";
    public string DisplayName => "Probe";
    public IReadOnlyList<PetPoseId> AvailablePoses { get; } = new[] { PetPoseId.Idle, PetPoseId.Happy, PetPoseId.Thinking, PetPoseId.Loading };
    public PetPoseId DefaultPose => PetPoseId.Idle;
    public PetPoseId FallbackPose => PetPoseId.Idle;
    public IReadOnlyDictionary<PetPoseId, Uri> PoseAssets { get; } = new Dictionary<PetPoseId, Uri>();
    public IReadOnlyDictionary<PetPoseId, PetPosePresentation> PosePresentations { get; } = new Dictionary<PetPoseId, PetPosePresentation>();
    public string GetPoseDisplayName(PetPoseId pose) => pose.Value;
    public PetAutomaticPoseConfiguration AutomaticPoseConfiguration { get; } = new(
        TimeSpan.FromMilliseconds(10), TimeSpan.FromMilliseconds(10),
        TimeSpan.FromMilliseconds(10), TimeSpan.FromMilliseconds(10),
        new[] { new PetWeightedTemporaryPose(new(PetPoseId.Thinking, TimeSpan.FromMilliseconds(100)), 1) },
        new Dictionary<PetPoseId, int>());
    public PetTemporaryPose ClickReactionFor(PetPoseId pose) => new(PetPoseId.Happy, TimeSpan.FromMilliseconds(20));

    public static async Task Run()
    {
        using var controller = new PetBehaviorController(new BehaviorProbeCharacter());
        controller.SetAutomatic();
        if (controller.State.CurrentPose != PetPoseId.Idle) throw new Exception("Auto must start in Idle.");
        await Task.Delay(40);
        if (controller.State.CurrentPose != PetPoseId.Thinking) throw new Exception("Auto did not select its configured expression.");

        controller.ReactToClick();
        if (controller.State.CurrentPose != PetPoseId.Happy) throw new Exception("Click did not start Happy.");
        controller.SetPose(PetPoseId.Thinking);
        await Task.Delay(160);
        if (controller.State.Mode != PetBehaviorMode.Fixed || controller.State.CurrentPose != PetPoseId.Thinking)
            throw new Exception("A cancelled Auto timer replaced the fixed pose.");
        controller.ReactToClick();
        if (controller.State.CurrentPose != PetPoseId.Happy) throw new Exception("Fixed mode did not enter Happy on click.");
        await Task.Delay(40);
        if (controller.State.CurrentPose != PetPoseId.Thinking) throw new Exception("Fixed pose was not restored after Happy.");

        controller.SetLoadingOverrideActive(true);
        controller.SetPose(PetPoseId.Happy);
        if (controller.State.CurrentPose != PetPoseId.Loading) throw new Exception("Loading override was lost.");
        controller.SetLoadingOverrideActive(false);
        if (controller.State.CurrentPose != PetPoseId.Happy) throw new Exception("Fixed pose was not restored.");
    }
}
'@
$probePath = Join-Path ([IO.Path]::GetTempPath()) ("pet-behavior-probe-" + [Guid]::NewGuid() + '.cs')
try {
    [IO.File]::WriteAllText($probePath, $probeSource)
    Add-Type -Path ($files + $probePath) -IgnoreWarnings -WarningAction SilentlyContinue
}
finally {
    Remove-Item -LiteralPath $probePath -ErrorAction SilentlyContinue
}
[void][BehaviorProbeCharacter]::Run().GetAwaiter().GetResult()
$character = [EvanJoDesktopPet.Windows.Characters.EvanJo.EvanJoCharacterDefinition]::new()
foreach ($pose in $character.AvailablePoses) {
    $expected = if ($pose -eq [EvanJoDesktopPet.Windows.Core.Characters.PetPoseId]::Loading) {
        [EvanJoDesktopPet.Windows.Core.Characters.PetPoseId]::Sleepy
    } else {
        [EvanJoDesktopPet.Windows.Core.Characters.PetPoseId]::Happy
    }
    if ($character.ClickReactionFor($pose).Pose -ne $expected) {
        throw "Click on $pose did not enter $expected."
    }
}
$controller = [EvanJoDesktopPet.Windows.Core.Behavior.PetBehaviorController]::new($character)
try {
    $controller.SetPose([EvanJoDesktopPet.Windows.Core.Characters.PetPoseId]::Loading)
    $controller.ReactToClick()
    if ($controller.State.CurrentPose -ne [EvanJoDesktopPet.Windows.Core.Characters.PetPoseId]::Sleepy) {
        throw 'Clicking Loading did not enter Brainwave.'
    }
} finally {
    $controller.Dispose()
}
'PASS: Auto selection, Loading-to-Brainwave and other-to-Happy clicks, cancellation, fixed pose restoration, and loading override.'
