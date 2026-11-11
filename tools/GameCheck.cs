// Development-only managed harness (executed under .NET 6); never shipped.
using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Xml.Linq;

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
        try { return Run(args[1], args.Length > 2 ? args[2] : null); }
        catch (Exception e) { Console.Error.WriteLine(e); return 1; }
    }
    private static int Run(string folder, string reportedGameVersion)
    {
        var target = typeof(MachineStorageCoordinator).GetMethod("HandleHotkeys", BindingFlags.Static | BindingFlags.NonPublic, null, Type.EmptyTypes, null);
        if (target == null || target.ReturnType != typeof(void)) throw new Exception("Storage hotkey target changed.");
        var current = typeof(ItemMouseDragHandler).GetField("current", BindingFlags.Public | BindingFlags.Static);
        var state = typeof(ItemMouseDragHandler).GetProperty("IsDraggingItem", BindingFlags.Public | BindingFlags.Instance);
        if (current == null || current.FieldType != typeof(ItemMouseDragHandler) || state == null || state.PropertyType != typeof(bool))
            throw new Exception("Drag API changed.");
        Console.WriteLine("PASS: real game target signature and public drag API.");
        if (reportedGameVersion != null)
        {
            // Run the installed game's actual pure normalization method, without
            // invoking Application.version outside Unity or patching any game code.
            var normalize = typeof(ModUIManager).GetMethod("NormalizeVersion", BindingFlags.Static | BindingFlags.NonPublic);
            if (normalize == null) throw new Exception("Game UI version normalization API changed.");
            var running = (string)normalize.Invoke(null, new object[] { reportedGameVersion });
            var versions = XDocument.Load(Path.Combine(folder, "manifest.xml")).Root.Element("GameVersions").Elements("Version").Select(v => v.Value).ToArray();
            // An exact normalized match guarantees the equality branch of the
            // inspected VersionMatchesGame method, avoiding broad prefix claims.
            bool exactMatch = versions.Any(v => (string)normalize.Invoke(null, new object[] { v }) == running);
            if (string.IsNullOrEmpty(running) || !exactMatch)
                throw new Exception("No declared game version exactly matches the game's normalized reported version: " + reportedGameVersion);
            Console.WriteLine("PASS: installed-game UI normalizer matches manifest for " + reportedGameVersion + " (" + running + ").");
        }
        var result = ModScanner.Scan(System.IO.Directory.GetFiles(folder, "*.dll"), System.IO.Directory.GetFiles(managed, "*.dll").Select(Path.GetFileNameWithoutExtension), folder, true);
        Console.WriteLine("Scanner: methods=" + result.MethodsScanned + ", refused=" + result.Refused + ", capabilities=" + result.Capabilities.Count + ", hardFlags=" + result.HardFlags.Count + ", error=" + (result.Error ?? "none"));
        foreach (var flag in result.HardFlags) Console.WriteLine("HARD: " + flag);
        foreach (var finding in result.Findings) Console.WriteLine("FIND: " + finding);
        return result.Refused || result.Capabilities.Count != 0 || result.HardFlags.Count != 0 || result.Error != null ? 1 : 0;
    }
}
