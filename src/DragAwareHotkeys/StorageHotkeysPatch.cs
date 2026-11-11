using System;
using HarmonyLib;

namespace ProbablyStolen.DragAwareHotkeys
{
    // Private game method: name and signature verified against Steam build 26525552.
    // Let the native loader apply this attribute; do not create a second Harmony instance.
    [HarmonyPatch(typeof(MachineStorageCoordinator), "HandleHotkeys")]
    internal static class StorageHotkeysPatch
    {
        private static bool reportedFailure;
#if DEBUG
        private static bool wasDragging;
#endif

        internal static void ResetDiagnostics()
        {
            reportedFailure = false;
#if DEBUG
            wasDragging = false;
#endif
        }

        [HarmonyPrefix]
        internal static bool Prefix()
        {
            if (!ModEntry.Enabled) return true;
            try
            {
                var drag = ItemMouseDragHandler.current;
                // Unity's null comparison also handles destroyed components.
                bool dragging = drag != null && drag.IsDraggingItem;
#if DEBUG
                if (dragging != wasDragging)
                {
                    wasDragging = dragging;
                    ModEntry.Log?.Log(dragging ? "Drag detected: storage hotkeys blocked." : "Drag ended: storage hotkeys allowed.");
                }
#endif
                return !dragging;
            }
            catch (Exception exception)
            {
                // Restore vanilla behavior if reading the game state fails. Log once per enable.
                if (!reportedFailure)
                {
                    reportedFailure = true;
                    ModEntry.Log?.Warning("Cannot read item drag state; allowing original hotkeys. " + exception);
                }
                return true;
            }
        }
    }
}
