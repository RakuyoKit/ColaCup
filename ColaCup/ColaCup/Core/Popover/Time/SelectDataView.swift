//
//  SelectDataView.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class SelectDataView: UIView {
    
    public init() {
        super.init(frame: .zero)
        config()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    /// Title view
    open lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .normalText
        
        return label
    }()
    
    /// Used to select a date to view the log of the selected date.
    @available(iOS 13.4, *)
    open lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        
        return datePicker
    }()
    
    /// A view showing the date. In iOS 13.4 and above, please use `datePicker`.
    @available(iOS, deprecated: 13.4)
    open lazy var showDateView: ShowDateView = {
        
        let view = ShowDateView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .theme
        
        return view
    }()
}

// MARK: - Config

private extension SelectDataView {

    /// Under the current system, the available dateView.
    var availableDateView: UIView {
        if #available(iOS 13.4, *) { return datePicker } else { return showDateView }
    }
}

private extension SelectDataView {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(titleLabel)
        addSubview(availableDateView)
    }
    
    func addInitialLayout() {
        
        let view = availableDateView
        
        NSLayoutConstraint.activate([
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        view.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
}
