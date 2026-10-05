import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // Mock settings state
    @AppStorage("heifFormat") var heifFormat = true
    @AppStorage("rawCapture") var rawCapture = false
    @AppStorage("gridType") var gridType = "None"
    @AppStorage("levelIndicator") var levelIndicator = true
    @AppStorage("mirrorFront") var mirrorFront = false
    @AppStorage("preserveSettings") var preserveSettings = true
    @AppStorage("lensCorrection") var lensCorrection = true
    
    @AppStorage("videoRes") var videoRes = "1080p"
    @AppStorage("videoFps") var videoFps = "30"
    @AppStorage("hdrVideo") var hdrVideo = true
    @AppStorage("stabilization") var stabilization = "Standard"
    @AppStorage("videoFormat") var videoFormat = "HEVC"
    
    @AppStorage("haptic") var haptic = true
    @AppStorage("shutterSound") var shutterSound = true
    @AppStorage("appearance") var appearance = "Auto"
    @AppStorage("animation") var animation = "Normal"
    
    @AppStorage("smartCapture") var smartCapture = true
    @AppStorage("hdrStrength") var hdrStrength = "Smart HDR"
    @AppStorage("nightMode") var nightMode = "Auto"
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Photo")) {
                    Toggle("HEIF Format", isOn: $heifFormat)
                    Toggle("RAW Capture", isOn: $rawCapture)
                    Picker("Grid Type", selection: $gridType) {
                        Text("None").tag("None")
                        Text("Rule of Thirds").tag("Rule of Thirds")
                        Text("Square").tag("Square")
                        Text("Golden Ratio").tag("Golden Ratio")
                    }
                    Toggle("Level Indicator", isOn: $levelIndicator)
                    Toggle("Mirror Front Camera", isOn: $mirrorFront)
                    Toggle("Preserve Settings", isOn: $preserveSettings)
                    Toggle("Lens Correction", isOn: $lensCorrection)
                }
                
                Section(header: Text("Video")) {
                    Picker("Resolution", selection: $videoRes) {
                        Text("1080p").tag("1080p")
                        Text("4K").tag("4K")
                    }
                    Picker("Frame Rate", selection: $videoFps) {
                        Text("24 fps").tag("24")
                        Text("30 fps").tag("30")
                        Text("60 fps").tag("60")
                    }
                    Toggle("HDR Video", isOn: $hdrVideo)
                    Picker("Stabilization", selection: $stabilization) {
                        Text("Off").tag("Off")
                        Text("Standard").tag("Standard")
                        Text("Cinematic").tag("Cinematic")
                    }
                    Picker("Format", selection: $videoFormat) {
                        Text("H.264").tag("H.264")
                        Text("HEVC").tag("HEVC")
                    }
                }
                
                Section(header: Text("Interface")) {
                    Toggle("Haptic Feedback", isOn: $haptic)
                    Toggle("Shutter Sound", isOn: $shutterSound)
                    Picker("Appearance", selection: $appearance) {
                        Text("Auto").tag("Auto")
                        Text("Dark").tag("Dark")
                        Text("Light").tag("Light")
                    }
                    Picker("Animation", selection: $animation) {
                        Text("Reduced").tag("Reduced")
                        Text("Normal").tag("Normal")
                        Text("Expressive").tag("Expressive")
                    }
                }
                
                Section(header: Text("Smart Capture")) {
                    Toggle("Smart Capture", isOn: $smartCapture)
                    Picker("HDR Strength", selection: $hdrStrength) {
                        Text("Auto").tag("Auto")
                        Text("Natural").tag("Natural")
                        Text("Smart HDR").tag("Smart HDR")
                        Text("HDR Max").tag("HDR Max")
                    }
                    Picker("Night Mode", selection: $nightMode) {
                        Text("Auto").tag("Auto")
                        Text("Manual").tag("Manual")
                        Text("Off").tag("Off")
                    }
                }
                
                Section(header: Text("Privacy")) {
                    HStack {
                        Text("Camera")
                        Spacer()
                        Text("Granted").foregroundColor(.green)
                    }
                    HStack {
                        Text("Microphone")
                        Spacer()
                        Text("Granted").foregroundColor(.green)
                    }
                    HStack {
                        Text("Photo Library")
                        Spacer()
                        Text("Granted").foregroundColor(.green)
                    }
                    Text("All processing is performed securely on-device.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                    }
                    Text("Lumina Camera by AntiGravity")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Button("Reset All Settings", role: .destructive) {
                        // Reset defaults logic
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
