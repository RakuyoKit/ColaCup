//
//  Throttler.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/27.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

public struct DispatchSemaphoreWrapper {
    public init(withValue value: Int) {
        self.semaphore = DispatchSemaphore(value: value)
    }
    
    private let semaphore: DispatchSemaphore
    
    public func sync<R>(execute: () throws -> R) rethrows -> R {
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        defer { semaphore.signal() }
        return try execute()
    }
}

public class Throttler {
    public init(seconds: Double) {
        self.maxInterval = seconds
        self.semaphore = DispatchSemaphoreWrapper(withValue: 1)
    }
    
    private var maxInterval: Double
    fileprivate let semaphore: DispatchSemaphoreWrapper
    
    private lazy var queue = DispatchQueue(label: "com.ColaCup.throttler", qos: .background)
    
    private lazy var job = DispatchWorkItem(block: {})
    private lazy var previousRun = Date.distantPast
    
    public func execute(_ block: @escaping () -> ()) {
        semaphore.sync  {
            job.cancel()
            job = DispatchWorkItem() { [weak self] in
                self?.previousRun = Date()
                block()
            }
            let delay = Date.second(from: previousRun) > maxInterval ? 0 : maxInterval
            queue.asyncAfter(deadline: .now() + delay, execute: job)
        }
    }
}

private extension Date {
    static func second(from referenceDate: Date) -> TimeInterval {
        return Date().timeIntervalSince(referenceDate).rounded()
    }
}
