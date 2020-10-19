//
//  TimePopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// A pop-up window for displaying time options.
@available(iOS 14.0, *)
public class TimePopover: BasePopover {
    
    /// Initialization method.
    ///
    /// - Parameter dataSource: The data source model of the content of the pop-up.
    public init(position: CGPoint, dataSource: TimePopoverModel) {
//        viewModel = TimePopoverViewModel(dataSource: dataSource)
        
        super.init(position: position)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The view used to select the date of the log to be viewed.
    public lazy var dataView: SelectDataView = {
        
        let view = SelectDataView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    /// The view used to select the time period of the log to be viewed.
    public lazy var periodView: SelectPeriodView = {
        
        let view = SelectPeriodView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    /// Confirm button. Used to submit the date and time selected by the user.
    public lazy var doneButton: UIButton = {
        
        let button = UIButton(type: .custom)
        
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .theme
        
        button.layer.cornerRadius = 22
        
        return button
    }()
    
    public override var height: CGFloat {
        
        let con = BasePopover.Constant.self
        
        return con.topBottomSpacing * 2
             + con.spacing * 2
             + con.itemHeight * 3
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.alignment = .center
        
        addSubviews()
        addInitialLayout()
    }
}

// MARK: - Config

@available(iOS 14.0, *)
private extension TimePopover {
    
    func addSubviews() {
        
        stackView.addArrangedSubview(dataView)
        stackView.addArrangedSubview(periodView)
        stackView.addArrangedSubview(doneButton)
    }
    
    func addInitialLayout() {
        
        [dataView, periodView, doneButton].forEach {
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 44),
                $0.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9)
            ])
        }
    }
}
