//
//  ResultView.swift
//  IkEetKip
//
//  Created by Erwin Russel on 11/02/2023.
//

import SwiftUI

enum ContentItem: Int, CaseIterable {
    case header
    case first
    case second
    case third
}

struct ResultView: View {
    let queryResponse: QueryResponse
    @State var contentItems: [ContentItem] = []
    @State var isAnimating: Bool = true
    @Namespace private var animation

    @State var showFirstItem: Bool = false
    @State var showSecondItem: Bool = false
    @State var showThirdItem: Bool = false

    let animationTime: CGFloat = 0.8
    
    var lockText: Text {
        Text(Image(systemName: "lock.fill")) + Text("Alle data is versleuteld")
    }

    var header: some View {
        VStack{
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.init(hex: "#C8E6C9"))
                .scaledToFit()
                .background(Circle().fill(Color.init(hex: "#4CAF50")))
            Text("Hier is je\nversimpelde brief")
                .bold()
                .font(.title)
                .multilineTextAlignment(.center)
        }
    }

    var whoSentIt: some View {
        VStack(alignment: .leading, spacing: 10){
            Text("1")
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
            Text("Van wie is de brief?")
                .font(.title2)
                .fontWeight(.bold)
            Text(queryResponse.sender)
                .modifier(HighlightModifier())
        }.modifier(SectionViewModifier())
    }

    @Environment(\.openURL) var openURL

    var phoneText: some View {

        Label("Bel \(queryResponse.sender)", systemImage: "phone.and.waveform.fill")
            .foregroundColor(.white)
    }

    var whatToDo: some View {
        VStack(alignment: .leading, spacing: 10){
            Text("3")
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
            Text("Wat moet je doen?")
                .font(.title2)
                .fontWeight(.bold)
            Text(queryResponse.call_to_action)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(HighlightModifier())
            
            if queryResponse.call_to_action_is_call {
                queryResponse.phone_number.map { num in
                    Button(action: {
                        openURL(URL(string: "tel://"+num)!)
                    }, label: {
                        phoneText
                    }).buttonStyle(LargeButton(color: .green, textColor: .white))

                }
            }

            NavigationLink {
                StartView()
            } label: {
                Text("Maak nog een scan")
            }
            .buttonStyle(OutLineButton(textColor: .blue))


        }.modifier(SectionViewModifier())
    }

    var whatsInIt: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("2")
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
            Text("Wat staat er in?")
                .font(.title2)
                .fontWeight(.bold)
            ForEach(queryResponse.summary_sentences) { response in
                HStack {
                    Text(response.emoji)
                    Text(response.text)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .modifier(HighlightModifier())
                
        }.modifier(SectionViewModifier())
    }

    var body: some View {
        ZStack {
            if contentItems.isEmpty {
                VStack {
                    Spacer()
                    header
                        .transition(.move(edge: .bottom))
                        .matchedGeometryEffect(id: "header", in: animation)

                    Spacer()
                }
            } else {
                ScrollView {
                    Text("").frame(maxWidth: .infinity)
                    header
                        .transition(.move(edge: .bottom))
                        .matchedGeometryEffect(id: "header", in: animation)

                    if showFirstItem {
                        whoSentIt
                    }
                    if showSecondItem {
                        whatsInIt
                    }
                    if showThirdItem {
                        whatToDo
                    }
                }
            }
        }
        .padding(.top, 16)
        .animation(.easeOut(duration: animationTime), value: contentItems)
        .modifier(HiddenNavBarModifier())
        .task {
                repeat {
                    if #available(iOS 16.0, *) {
                        try? await Task.sleep(for: .seconds(animationTime))
                    } else {
                        try? await Task.sleep(nanoseconds: (UInt64(animationTime) * 1_000_000_000))
                        // Fallback on earlier versions
                    }
                    withAnimation {
                        DispatchQueue.main.async {
                            let nextIndex = contentItems.count
                            guard
                                ContentItem.allCases.indices.contains(nextIndex),
                                let nextItem = ContentItem(rawValue: nextIndex)
                            else {
                                isAnimating = false
                                return
                            }
                            contentItems.append(nextItem)
                            switch nextItem {
                            case .header: return
                            case .first: showFirstItem = true
                            case .second: showSecondItem = true
                            case .third: showThirdItem = true
                            }
                        }
                    }
                } while isAnimating
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static let queryResopnse = QueryResponse.init(sender: "Stichting Pensioenfonds ABP", call_to_action: "Lees de toelichting", call_to_action_is_call: false, phone_number: nil, summary_sentences: [
        .init(text: "Je hebt minimal 3 maanden niet bij ABP gewerkt, dus je bouwt geen pensioen meer op bij ABP.", emoji: "🤔"),
        .init(text: "Je hebt belangrijke keuzes te maken omtrent je opgebouwde pensioen.", emoji: "🤔"),
        .init(text: "Je partner krijgt geen nabestaandenpensioen als je deelname aan ABP stopt.", emoji: "🤔"),
        .init(text: "Je kunt je opgebouwde pension maximaal 3 jaar vrijwillig voortzetten na einde deelneming.", emoji: "🤔"),

    ])

    static var previews: some View {
        ResultView(queryResponse: queryResopnse)
    }
}
