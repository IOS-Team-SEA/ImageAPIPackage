import Foundation

@available(iOS 13.0, macOS 10.15, *)
public final class PipelineEngine {
    public init() {}

    public func run(steps: [PipelineStep], initial context: AIContext) async -> AIContext {
        var ctx = context
        var history = ctx.history

        for step in steps {
            let result = await step.apply(to: ctx)
            history.append(result.log)
            ctx = result.context
            ctx.history = history
        }

        return ctx
    }
}
