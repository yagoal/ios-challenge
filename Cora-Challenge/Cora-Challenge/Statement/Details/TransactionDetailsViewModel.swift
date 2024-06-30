//
//  TransactionDetailsViewModel.swift
//  Cora-Challenge
//
//  Created by Yago Augusto Guedes Pereira on 27/06/24.
//

import Foundation
import Combine
import PDFKit

enum DetailViewState: Equatable {
    case initial
    case loading
    case success(TransactionDetailsResponse)
    case error(String)
}

final class TransactionDetailsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var state: DetailViewState = .initial

    private let transactionService: TransactionServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(transactionService: TransactionServiceProtocol = TransactionService()) {
        self.transactionService = transactionService
    }

    // MARK: - Fetch Details Methods
    func fetchTransactionDetails(id: String) {
        state = .loading
        transactionService.fetchTransactionDetails(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] details in
                self?.state = .success(details)
            })
            .store(in: &cancellables)
    }

    // MARK: - Date Formatting Methods
    func formatDate(_ date: String) -> String {
        let isoDateFormatter = DateFormatter()
        isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        isoDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let dateObj = isoDateFormatter.date(from: date) else { return date }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "pt_BR")

        let calendar = Calendar.current
        if calendar.isDateInToday(dateObj) {
            displayFormatter.dateFormat = "'Hoje - 'dd/MM/yyyy"
            return displayFormatter.string(from: dateObj)
        } else if calendar.isDateInYesterday(dateObj) {
            displayFormatter.dateFormat = "'Ontem - 'dd/MM/yyyy"
            return displayFormatter.string(from: dateObj)
        } else {
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: dateObj)
        }
    }

    // MARK: - Document Formatting Methods
    func formattedDocumentNumber(_ documentNumber: String) -> String {
        if documentNumber.isCPF {
            return formatCPF(documentNumber)
        } else {
            return formatCNPJ(documentNumber)
        }
    }

    private func formatCPF(_ number: String) -> String {
        guard number.count == 11 else { return number }
        let first = number.index(number.startIndex, offsetBy: 3)
        let second = number.index(first, offsetBy: 3)
        let third = number.index(second, offsetBy: 3)
        return "\(number[..<first]).\(number[first..<second]).\(number[second..<third])-\(number[third...])"
    }

    private func formatCNPJ(_ number: String) -> String {
        guard number.count == 14 else { return number }
        let first = number.index(number.startIndex, offsetBy: 2)
        let second = number.index(first, offsetBy: 3)
        let third = number.index(second, offsetBy: 3)
        let fourth = number.index(third, offsetBy: 4)
        return "\(number[..<first]).\(number[first..<second]).\(number[second..<third])/\(number[third..<fourth])-\(number[fourth...])"
    }

    func generatePDF(details: TransactionDetailsResponse) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Cora Bank",
            kCGPDFContextAuthor: "corabank.com.br",
            kCGPDFContextTitle: "Comprovante de Transferência"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 300
        let pageHeight: CGFloat = 400
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.avenir(size: 16, weight: .bold)
            ]

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.avenir(size: 12)
            ]

            // Centralizar o logo
            if let logo = UIImage(named: "cora-logo-black") {
                let logoWidth: CGFloat = 100
                let logoHeight: CGFloat = 30
                let logoRect = CGRect(x: (pageRect.width - logoWidth) / 2, y: 20, width: logoWidth, height: logoHeight)
                logo.draw(in: logoRect)
            }
            
            // Centralizar o título
            let title = "Detalhes da Transferência"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageRect.width - titleSize.width) / 2, y: 80), withAttributes: titleAttributes)
            
            let cardRect = CGRect(x: 20, y: 120, width: pageRect.width - 40, height: pageRect.height - 140)
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.addRect(cardRect)
            context.cgContext.drawPath(using: .fillStroke)
            
            context.cgContext.setShadow(offset: CGSize(width: 2, height: 2), blur: 4, color: UIColor.black.cgColor)
            
            let items = [
                "Valor: \(details.amount.formattedCurrencyAmount)",
                "Data: \(formatDate(details.dateEvent))",
                "De: \(details.sender.name)",
                "CNPJ: \(formattedDocumentNumber(details.sender.documentNumber))",
                "Para: \(details.recipient.name)",
                "CNPJ: \(formattedDocumentNumber(details.recipient.documentNumber))",
                "Descrição: \(details.description)"
            ]
            
            var yPosition = cardRect.origin.y + 20
            for item in items {
                let itemRect = CGRect(x: cardRect.origin.x + 20, y: yPosition, width: cardRect.width - 40, height: 20)
                item.draw(in: itemRect, withAttributes: bodyAttributes)
                yPosition += 30
            }
        }
        
        return data
    }
}
