//
//  StartNewGameView.swift
//  ScopaRoyale
//
//  Created on 24/06/24.
//

import SwiftUI

struct StartNewGameView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Waiting for opponents...")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
    }
}

struct StartNewGameView_Previews: PreviewProvider {
    static var previews: some View {
        StartNewGameView()
    }
}


#Preview {
    StartNewGameView()
}
