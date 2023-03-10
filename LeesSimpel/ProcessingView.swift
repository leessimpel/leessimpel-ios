import SwiftUI
import Vision

struct ImageProcessInput {
    let index: Int
    let image: UIImage

    init(_ data: (Int, UIImage)) {
        self.index = data.0
        self.image = data.1
    }
}

struct ImageProcessOutput: Comparable {
    static func < (lhs: ImageProcessOutput, rhs: ImageProcessOutput) -> Bool {
        lhs.index < rhs.index
    }

    let index: Int
    let transcript: String
}

extension Array where Element == ImageProcessOutput {
    var collected: String {
        self.sorted().map(\.transcript).joined(separator: "\n")
    }

}

struct ProcessingView: View {
    @State var response: QueryResponse?
    @State var error: Error?
    let backendService = BackendService()
    let images: [UIImage]
    #if DEBUG
    @State var errorViewButtonIsPresented: Bool = false
    #endif


    var body: some View {
        Group {
            if let response {
                ResultView(queryResponse: response)
            } else {
                VStack {
                    HStack {
                        Spacer()
                        LottieRepresentable()
                            .frame(width: 100, height: 80)
                        Spacer()
                    }
                    Text("Goede foto!")
                        .font(.title)
                    Text("We versimpelen nu je brief")
                        .font(.title2)
                    if let error {
                        Text(error.localizedDescription)
                            .font(.body)
                            .foregroundColor(.red)

                        #if DEBUG
                        Button {
                            self.errorViewButtonIsPresented = true
                        } label: {
                            Text("Show decoded error")
                        }
                        .sheet(isPresented: $errorViewButtonIsPresented) {
                            ErrorView()
                        }
                        #endif
                    }
                }
                .task { @MainActor in
                    do {
                        
#if !targetEnvironment(simulator)
                        let transcript = await withTaskGroup(of: ImageProcessOutput.self) { taskGroup in

                            let enumaratedImages: [(Int, UIImage)] = Array(images.enumerated())
                            let data = enumaratedImages.map(ImageProcessInput.init(_:))
                            for item in data {
                                taskGroup.addTask {
                                    await analyze(data: item)
                                }
                            }

                            var outputCollection = [ImageProcessOutput]()
                            for await result in taskGroup {
                                outputCollection.append(result)
                            }
                            return outputCollection.collected
                        }
                        
#else
                        let transcript = "this is a fake transcript from a fake letter that we use when running in the simulator"
#endif
                        
                        let response = try await backendService.summarizeTranscript(transcript: transcript)
                        self.response = response
                    } catch {
                        #if DEBUG
                        if let decodeError = error as? DecodeError,
                            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

                            // create the destination url for the text file to be saved
                            let fileURL = documentDirectory.appendingPathComponent("decode_error.txt")
                            // define the string/text to be saved
                            let text = decodeError.result
                            // writing to disk
                            // Note: if you set atomically to true it will overwrite the file if it exists without a warning
                            do {
                                try text.write(to: fileURL, atomically: true, encoding: .utf8)
                            } catch {}
                        }
                        #endif
                        self.error = error
                    }
                }
            }
        }
        .modifier(HiddenNavBarModifier())
    }

    func analyze(data: ImageProcessInput) async -> ImageProcessOutput {
        await withCheckedContinuation { continuation in
            let textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { [continuation] (request, error) in
                var transcript:String = ""
                guard
                    let results = request.results,
                        !results.isEmpty,
                    let requestresult = results as? [VNRecognizedTextObservation]
                else { return }

                for observation in requestresult {
                    guard let candidate = observation.topCandidates(1).first else { continue }
                    transcript += candidate.string
                    transcript += "\n"
                }
                print(transcript)
                continuation.resume(returning: .init(index: data.index, transcript: transcript))
            })

            textRecognitionRequest.recognitionLevel = .accurate
            textRecognitionRequest.usesLanguageCorrection = true

            guard let cgImage = data.image.cgImage else {

                print("Failed to get cgimage from input image")
                continuation.resume(returning: .init(index: -1, transcript: ""))
                return
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([textRecognitionRequest])
            } catch {
                print(error)
            }
        }

    }
}

struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessingView(images: [])
    }
}

struct ErrorView: View {
    @State var text: String = ""

    var body: some View {
        Text(text)
            .onAppear {
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentDirectory.appendingPathComponent("decode_error.txt")
                    do {
                        let savedText = try String(contentsOf: fileURL)
                        self.text  = savedText
                    } catch {
                        //
                    }
                }
            }
    }
}
