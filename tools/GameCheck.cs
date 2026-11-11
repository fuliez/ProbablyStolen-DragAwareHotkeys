// Development-only .NET Framework harness; never included in the runtime package.
using System;
using System.IO;
using System.Linq;
using System.Reflection;

internal static class GameCheck
{
    private static string managed;
    private static int Main(string[] args)
    {
        managed = args[0];
        AppDomain.CurrentDomain.AssemblyResolve += (sender, e) =>
        {
            string path = Path.Combine(managed, new AssemblyName(e.Name).Name + ".dll");
            return File.Exists(path) ? Assembly.LoadFrom(path) : null;
        };
        try { return Run(args[1]); }
        catch (Exception e) { Console.Error.WriteLine(e); return 1; }
    }
    private static int Run(string folder)
    {
        var target = typeof(MachineStorageCoordinator).GetMethod("HandleHotkeys", BindingFlags.Static | BindingFlags.NonPublic, null, Type.EmptyTypes, null);
        if (target == null || target.ReturnType != typeof(void)) throw new Exception("Storage hotkey target changed.");
        var current = typeof(ItemMouseDragHandler).GetField("current", BindingFlags.Public | BindingFlags.Static);
        var state = typeof(ItemMouseDragHandler).GetProperty("IsDraggingItem", BindingFlags.Public | BindingFlags.Instance);
        if (current == null || current.FieldType != typeof(ItemMouseDragHandler) || state == null || state.PropertyType != typeof(bool))
            throw new Exception("Drag API changed.");
        Console.WriteLine("PASS: real game target signature and public drag API.");
        var result = ModScanner.Scan(System.IO.Directory.GetFiles(folder, "*.dll"), System.IO.Directory.GetFiles(managed, "*.dll").Select(Path.GetFileNameWithoutExtension), folder, true);
        Console.WriteLine("Scanner: methods=" + result.MethodsScanned + ", refused=" + result.Refused + ", capabilities=" + result.Capabilities.Count + ", hardFlags=" + result.HardFlags.Count + ", error=" + (result.Error ?? "none"));
        foreach (var flag in result.HardFlags) Console.WriteLine("HARD: " + flag);
        foreach (var finding in result.Findings) Console.WriteLine("FIND: " + finding);
        return result.Refused || result.Capabilities.Count != 0 || result.HardFlags.Count != 0 || result.Error != null ? 1 : 0;
    }
}
