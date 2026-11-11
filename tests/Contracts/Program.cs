// Hand-authored API doubles. They never build or package the production mod.
using System;
using ProbablyStolen.DragAwareHotkeys;

namespace HarmonyLib
{
    [AttributeUsage(AttributeTargets.Class)]
    public sealed class HarmonyPatch : Attribute { public HarmonyPatch(Type type, string method) { } }
    [AttributeUsage(AttributeTargets.Method)]
    public sealed class HarmonyPrefix : Attribute { }
}
public interface IMod { void Init(ModManifest manifest); void OnEnable(); void OnDisable(); }
public sealed class ModManifest { }
public sealed class ModLog
{
    public static int Warnings;
    public ModLog(ModManifest manifest) { }
    public void Log(object message) { }
    public void Warning(object message) { Warnings++; }
}
public sealed class MachineStorageCoordinator { }
public sealed class ItemMouseDragHandler
{
    public static ItemMouseDragHandler? current;
    public bool Dragging;
    public bool ThrowOnRead;
    public bool IsDraggingItem => ThrowOnRead ? throw new InvalidOperationException("Test state failure") : Dragging;
}
internal static class Program
{
    private static void Check(bool condition, string name)
    {
        if (!condition) throw new Exception("FAIL: " + name);
        Console.WriteLine("PASS: " + name);
    }
    private static void Main()
    {
        var entry = new ModEntry();
        entry.Init(new ModManifest());
        Check(StorageHotkeysPatch.Prefix(), "inactive allows vanilla");
        entry.OnEnable();
        Check(StorageHotkeysPatch.Prefix(), "no handler allows vanilla (menu/scene transition)");
        var handler = new ItemMouseDragHandler();
        ItemMouseDragHandler.current = handler;
        Check(StorageHotkeysPatch.Prefix(), "idle allows storage shortcuts");
        handler.Dragging = true;
        Check(!StorageHotkeysPatch.Prefix(), "drag blocks storage shortcut method");
        entry.OnDisable();
        Check(StorageHotkeysPatch.Prefix(), "disable during drag restores vanilla");
        entry.OnEnable();
        handler.ThrowOnRead = true;
        Check(StorageHotkeysPatch.Prefix(), "state failure allows vanilla");
        Check(StorageHotkeysPatch.Prefix() && ModLog.Warnings == 1, "failure warning is emitted once");
        handler.ThrowOnRead = false;
        handler.Dragging = false;
        Check(StorageHotkeysPatch.Prefix(), "drop/cancel restores storage shortcuts");
        handler.Dragging = true;
        Check(!StorageHotkeysPatch.Prefix(), "later drag is blocked again");
        entry.OnEnable();
        handler.ThrowOnRead = true;
        Check(StorageHotkeysPatch.Prefix() && ModLog.Warnings == 2, "reenable resets diagnostics");
    }
}
