//
//  MissionView.swift
//  Moonshot
//
//  Created by Vitali Tatarintev on 25.11.19.
//  Copyright © 2019 Vitali Tatarintev. All rights reserved.
//

import SwiftUI

struct MissionView: View {
  let mission: Mission

  var body: some View {
    GeometryReader { geometry in
      ScrollView(.vertical) {
        VStack {
          Image(self.mission.image)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: geometry.size.width * 0.7)
            .padding(.top)

          Text(self.mission.description)
            .padding()

          Spacer(minLength: 25)
        }
      }
    }
  }
}

struct MissionView_Previews: PreviewProvider {
  static let missions: [Mission] = Bundle.main.decode("missions.json")

  static var previews: some View {
    MissionView(mission: missions[0])
  }
}