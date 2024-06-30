//
//  TransactionCell.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 26/06/24.
//

import SwiftUI

struct TransactionCell: View {
    let viewData: TransactionCellViewData

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            viewData.icon

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewData.amount)
                        .font(.avenirBodyBold(size: 16))
                        .foregroundColor(viewData.color)
                    
                    
                    Text(viewData.label)
                        .font(.avenir())
                        .foregroundColor(viewData.color)
                    
                    Text(viewData.name)
                        .font(.avenirBodyRegular())
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Text(viewData.hour)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

#Preview {
    TransactionCell(viewData: TransactionCellViewData(
        item: TransactionItem(
            id: "1",
            description: "Compra de produtos eletrônicos",
            label: "Compra aprovada",
            entry: .credit,
            amount: 150000,
            name: "João da Silva",
            dateEvent: "23/04/2020",
            status: "COMPLETED"
        )
    ))
}
