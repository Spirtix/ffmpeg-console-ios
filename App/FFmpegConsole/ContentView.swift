import SwiftUI
import ffmpegkit

struct ContentView: View {
    @State private var command: String = ""
    @State private var log: String = ""

    var body: some View {
        VStack {
            TextField("ffmpeg args, e.g. -i in.mp4 -c:v libx264 -crf 23 out.mp4", text: $command)
                .textFieldStyle(.roundedBorder)
                .padding()

            Button("Run") {
                let documentsURL = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )[0]

                FileManager.default.changeCurrentDirectoryPath(documentsURL.path)

                FFmpegKit.executeAsync(
                    command,
                    withCompleteCallback: { session in
                        DispatchQueue.main.async {
                            log += "\nFinished.\n"
                            log += session?.getAllLogsAsString() ?? "no output"
                        }
                    },
                    withLogCallback: { logEntry in
                        DispatchQueue.main.async {
                            log += logEntry?.getMessage() ?? ""
                        }
                    },
                    withStatisticsCallback: nil
                )
            }

            ScrollView {
                Text(log)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .padding()
    }
}
