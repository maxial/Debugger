//
//  SystemMetricService.swift
//
//
//  Created by Maxim Aliev on 25.04.2024.
//

import SwiftUI
import QuartzCore

protocol SystemMetricServiceDelegate: AnyObject {
    func metricsReceived(_ metrics: [SystemMetric])
}

final class SystemMetricService {
    private let fpsCounterService: FPSCounterService
    private let memoryLeakSnifferService: MemoryLeakSnifferService
    private var startFpsTimestamp: TimeInterval?
    private var displayLink: CADisplayLink?
    private var leaksCount: Int = .zero
    
    weak var delegate: SystemMetricServiceDelegate?
    
    @AppStorage var isDetectLeaks: Bool { didSet { toggleLeakDetection() } }
    
    init(
        fpsCounterService: FPSCounterService = FPSCounterService(),
        memoryLeakSnifferService: MemoryLeakSnifferService = MemoryLeakSnifferService()
    ) {
        self._isDetectLeaks = AppStorage(wrappedValue: false, "Debugger_System_IsDetectLeaks")
        
        self.fpsCounterService = fpsCounterService
        self.memoryLeakSnifferService = memoryLeakSnifferService
        memoryLeakSnifferService.delegate = self
        memoryLeakSnifferService.isActive = isDetectLeaks
        
        startFpsTimestamp = Date().timeIntervalSince1970
        
        displayLink = CADisplayLink(target: self, selector: #selector(newFrame))
        displayLink?.add(to: .current, forMode: .common)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pause),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(start),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc func start() {
        self.startFpsTimestamp = Date().timeIntervalSince1970
        self.displayLink?.isPaused = false
    }
    
    @objc func pause() {
        self.startFpsTimestamp = nil
        self.displayLink?.isPaused = true
    }
    
    private func toggleLeakDetection() {
        leaksCount = .zero
        memoryLeakSnifferService.isActive = isDetectLeaks
    }
    
    @objc private func newFrame(_ displayLink: CADisplayLink) {
        fpsCounterService.newFrame(timestamp: displayLink.timestamp)
        
        var metrics: [SystemMetric] = []
        
        for type in SystemMetricType.allCases {
            var value: String = ""
            
            switch type {
            case .fps:
                value = fpsCounterService.fps.description
            case .cpuUsage:
                value = cpuUsage()
            case .memoryUsage:
                value = memoryUsage()
            case .leaksCount:
                value = isDetectLeaks ? leaksCount.description : "Off"
            }
            
            metrics.append(SystemMetric(type: type, value: value))
        }
        
        delegate?.metricsReceived(metrics)
    }
    
    private func memoryUsage() -> String {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        var used: Double = 0
        if result == KERN_SUCCESS {
            used = Double(taskInfo.phys_footprint) / (1024 * 1024)
        }
        
        let total = Double(ProcessInfo.processInfo.physicalMemory) / (1024 * 1024)
        
        return String(format: "%.0f MB / %.0f MB", used, total)
    }
    
    private func cpuUsage() -> String {
        var totalUsageOfCPU: Double = 0.0
        var threadsList = UnsafeMutablePointer(mutating: [thread_act_t]())
        var threadsCount = mach_msg_type_number_t(0)
        let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
            return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadsCount)
            }
        }
        
        if threadsResult == KERN_SUCCESS {
            for index in 0..<threadsCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(
                            threadsList[Int(index)],
                            thread_flavor_t(THREAD_BASIC_INFO),
                            $0,
                            &threadInfoCount
                        )
                    }
                }
                
                guard infoResult == KERN_SUCCESS else {
                    break
                }
                
                let threadBasicInfo = threadInfo as thread_basic_info
                if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                    let threadUsageOfCPU = Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                    totalUsageOfCPU = totalUsageOfCPU + threadUsageOfCPU
                }
            }
        }
        
        vm_deallocate(
            mach_task_self_,
            vm_address_t(UInt(bitPattern: threadsList)),
            vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride)
        )
        
        return String(format: "%.1f%%", totalUsageOfCPU)
    }
}

extension SystemMetricService: MemoryLeakSnifferServiceDelegate {
    func didDetectMemoryLeak(with leakedObject: NSObject, leaksCount: Int) {
        self.leaksCount = leaksCount
    }
}
