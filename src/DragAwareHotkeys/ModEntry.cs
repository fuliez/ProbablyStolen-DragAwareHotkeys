namespace ProbablyStolen.DragAwareHotkeys
{
    public sealed class ModEntry : IMod
    {
        internal static ModLog? Log { get; private set; }
        internal static bool Enabled { get; private set; }

        public void Init(ModManifest manifest)
        {
            Log = new ModLog(manifest);
        }

        public void OnEnable()
        {
            StorageHotkeysPatch.ResetDiagnostics();
            Enabled = true;
            Log?.Log("Enabled: Storage Coordinator hotkeys are suppressed while dragging an item.");
        }

        public void OnDisable()
        {
            Enabled = false;
            Log?.Log("Disabled: original Storage Coordinator hotkeys restored.");
        }
    }
}
