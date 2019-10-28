//
//  LandmarkRow.swift
//  Landmarks
//
//  Created by Vitaly Tatarintsev on 28/10/2019.
//  Copyright © 2019 Vitali Tatarintev. All rights reserved.
//

import SwiftUI

struct LandmarkRow: View {
  var landmark: Landmark

  var body: some View {
    HStack {
      landmark.image
        .resizable()
        .frame(width: 50, height: 50)
      Text(landmark.name)

      Spacer()
    }
  }
}

struct LandmarkRow_Previews: PreviewProvider {
  static var previews: some View {
    LandmarkRow(landmark: landmarkData[0])
  }
}
