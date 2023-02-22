import SwiftUI

struct StartView: View {
    var lockText: Text {
        Text(Image(systemName: "lock.fill")).foregroundColor(Color.init(hex: "346c3b")) + Text(" Alle informatie is versleuteld").foregroundColor(Color.init(hex: "346c3b"))
    }

    var body: some View {
        ZStack {
            Color.init(hex: "fff5ec")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 8) {
                Text("")
                lockText
                    .padding(8)
                    .background(Color.init(hex: "daf3dc"))
                    .cornerRadius(10)
                Image("Scan")
                    .frame(maxWidth: .infinity)
                    .scaledToFit()
                    .padding()
                Spacer()

                VStack(spacing: 24) {
                    Text("Simpel App")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .padding(.top, 16)
                    
                    Text("Maak een foto van een brief dan versimpelen wij hem voor je.")
                        .font(.title2)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    NavigationLink {
                        #if targetEnvironment(simulator)
                            ProcessingView(image:nil)
                        #else
                            DataScanner()
                        #endif
                    } label: {
                        Text("Maak een scan ")
                    }
                    .buttonStyle(LargeButton(color: .blue, textColor: .white))
                }
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(10)
                .background(Color.white)
            }
        }
        .modifier(HiddenNavBarModifier())
    }
}



struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
