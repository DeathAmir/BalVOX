using System.Runtime.InteropServices;
using System.Text.Json;

namespace BalVOX.Configurator;

internal static class Program
{
    [DllImport("balvox_native.dll", CallingConvention = CallingConvention.Cdecl)]
    private static extern double balvox_drag_factor(double speed, double density, double area, double coefficient, double mass);

    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new ConfigForm());
    }

    private sealed class ConfigForm : Form
    {
        private readonly ComboBox quality = new() { DropDownStyle = ComboBoxStyle.DropDownList, Width = 220 };
        private readonly NumericUpDown speed = new() { Minimum = 5, Maximum = 34, Value = 16, Width = 220 };
        private readonly NumericUpDown power = new() { Minimum = 20, Maximum = 100, Value = 72, Width = 220 };
        private readonly Label result = new() { AutoSize = true };
        public ConfigForm()
        {
            Text = "BalVOX Simulator Configurator";
            Width = 430; Height = 330; StartPosition = FormStartPosition.CenterScreen;
            var layout = new FlowLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(18), FlowDirection = FlowDirection.TopDown, WrapContents = false };
            quality.Items.AddRange(["Low", "Medium", "High", "Ultra"]); quality.SelectedIndex = 1;
            layout.Controls.Add(new Label { Text = "Graphics preset" }); layout.Controls.Add(quality);
            layout.Controls.Add(new Label { Text = "Camera movement speed" }); layout.Controls.Add(speed);
            layout.Controls.Add(new Label { Text = "Test simulation power (%)" }); layout.Controls.Add(power);
            var save = new Button { Text = "Save settings", Width = 220, Height = 36 };
            save.Click += (_, _) => SaveSettings();
            layout.Controls.Add(save); layout.Controls.Add(result); Controls.Add(layout);
        }
        private void SaveSettings()
        {
            var data = new { quality = quality.SelectedIndex, speed = (double)speed.Value, power = (double)power.Value / 100.0 };
            var path = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Godot", "app_userdata", "BalVOX Realistic Simulator", "balvox_settings.json");
            Directory.CreateDirectory(Path.GetDirectoryName(path)!);
            File.WriteAllText(path, JsonSerializer.Serialize(data, new JsonSerializerOptions { WriteIndented = true }));
            double drag;
            try { drag = balvox_drag_factor(45, 1.225, 0.08, 0.35, 4.0); }
            catch (DllNotFoundException) { drag = 0; }
            result.Text = $"Saved: {path}\nNative C++ drag preview: {drag:F3} m/s²";
        }
    }
}
