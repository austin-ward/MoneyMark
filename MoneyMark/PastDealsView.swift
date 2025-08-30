//
//  PastDealsView.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import SwiftUI

struct PastDealsView: View {
    var body: some View {
        ZStack {
            Color.AppBackground.ignoresSafeArea()
            Text("Past Deals")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
        }
    }
}

#Preview { PastDealsView() }


