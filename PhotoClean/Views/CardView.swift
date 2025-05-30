//
//  CardView.swift
//  PhotoClean
//
//  Created by Vedant Bhatt on 5/30/25.
//

import SwiftUI

struct CardView: View {
    let card: Card
    @State private var offset: CGSize = .zero
    //@Binding var cards: [Card]
    
    var body: some View {
        ZStack {
            Rectangle()
                //.resizable()
                .scaledToFill()
                .frame(width: 300, height: 400)
                .cornerRadius(20)
                .shadow(radius: 5)
                .overlay(
                    Text(card.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(),
                    alignment: .bottom
                )
        }
        .offset(x: offset.width, y: 0)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 150 {
                        likeCard()
                    } else if offset.width < -150 {
                        dislikeCard()
                    } else {
                        offset = .zero
                    }
                }
        )
    }
    
    func likeCard() {
        withAnimation {
            offset.width = 500 // Move off-screen to the right
            removeCard()
        }
    }
    
    func dislikeCard() {
        withAnimation {
            offset.width = -500 // Move off-screen to the left
            removeCard()
        }
    }
    
    func removeCard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            //cards.removeAll { $0.id == card.id }
        }
    }
}

#Preview {
    @Previewable @State var array: [Card] = [Card(imageName: "gtlinkedn.jpg", title: "first"), Card(imageName: "second", title: "second"), Card(imageName: "third", title: "third")]
    ForEach(array) { card in
        CardView(card: card)
    }
}
