import Foundation

public struct PipelineStepResult {
    public let context: AIContext
    public let log: StepExecutionLog
}

@available(iOS 13.0, macOS 10.15, *)
public protocol PipelineStep {
    var id: String { get }
    func apply(to context: AIContext) async -> PipelineStepResult
}

@available(iOS 13.0, macOS 10.15, *)
public protocol LocalStep: PipelineStep {}

@available(iOS 13.0, macOS 10.15, *)
public protocol RemoteStep: PipelineStep {}
