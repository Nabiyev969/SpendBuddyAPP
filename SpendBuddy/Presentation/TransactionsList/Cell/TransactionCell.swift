//
//  TransactionCell.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 12.10.25.
//

import UIKit
import SnapKit

final class TransactionCell: UITableViewCell {
    
    private let title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let subtitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.7)
        label.numberOfLines = 1
        return label
    }()
    
    private let amount: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemIndigo
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white.withAlphaComponent(0.06)
        selectionStyle = .none
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(hStack)
        [stack, amount].forEach(hStack.addArrangedSubview)
        [title, subtitle].forEach(stack.addArrangedSubview)
        
        hStack.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(12)
        }
    }
}

extension TransactionCell {
    
    func configure(category: String, amountText: String, dateText: String, note: String?) {
            title.text = category
            subtitle.text = [dateText, note].compactMap { $0 }.joined(separator: "   ")
            amount.text = amountText
        }
}
