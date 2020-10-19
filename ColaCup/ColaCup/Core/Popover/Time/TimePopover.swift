//
//  TimePopover.swift
//  ColaCup
//
//  Created by MBCore on 2020/10/19.
//

import UIKit

/// A pop-up window for displaying time options.
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
    
    public override var height: CGFloat { 200 }
}
