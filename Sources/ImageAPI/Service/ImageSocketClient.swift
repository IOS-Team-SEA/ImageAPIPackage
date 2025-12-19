import Foundation
import SocketConnection
import LoggerKit

public protocol ImageSocketClientDelegate: AnyObject {
    func imageSocketDidAssign(_ client: ImageSocketClient, payload: ImageAPIEnvelope?)
    func imageSocket(_ client: ImageSocketClient, didReceiveProgress payload: ImageAPIEnvelope)
    func imageSocket(_ client: ImageSocketClient, didReceiveCompletion payload: ImageAPIEnvelope)
    func imageSocket(_ client: ImageSocketClient, didChange state: SocketConnectionState)
    func imageSocket(_ client: ImageSocketClient, didError message: String?)
}

public final class ImageSocketClient: SocketClientDelegate {
    private let client: SocketClient
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    public weak var delegate: ImageSocketClientDelegate?

    public init(baseURL: URL, query: [String: String] = [:], headers: [String: String] = [:]) {
        let config = SocketConfig(
            baseURL: baseURL,
            path: "/cvision/image/api/socket.io",
            transports: [.websocket, .polling],
            reconnectPolicy: SocketReconnectPolicy(),
            query: query,
            extraHeaders: headers
        )
        self.client = SocketClient(config: config) { message in
            Task { @MainActor in
                Logger.info(message)
            }
        }
        self.client.delegate = self
    }

    public func connect() {
        client.connect()
    }

    public func disconnect() {
        client.disconnect()
    }

    public func emitInit(payload: ImageSocketInitPayload) {
        do {
            let data = try encoder.encode(payload)
            client.emit(event: "init", items: [data])
        } catch {
            Task { @MainActor in
                Logger.error("Failed to encode init payload", metadata: ["error": error.localizedDescription])
            }
        }
    }

    // MARK: - SocketClientDelegate

    public func socketClient(_ client: SocketClient, didReceive event: SocketEvent) {
        switch event.name {
        case "socket-assigned":
            let payload = decodeEnvelope(from: event.items)
            delegate?.imageSocketDidAssign(self, payload: payload)
        case "job-progress":
            if let payload = decodeEnvelope(from: event.items) {
                delegate?.imageSocket(self, didReceiveProgress: payload)
            }
        case "job-completed":
            if let payload = decodeEnvelope(from: event.items) {
                delegate?.imageSocket(self, didReceiveCompletion: payload)
            }
        default:
            break
        }
    }

    public func socketClient(_ client: SocketClient, didChangeConnectionState state: SocketConnectionState) {
        delegate?.imageSocket(self, didChange: state)
    }

    public func socketClient(_ client: SocketClient, didEncounter error: SocketClientError) {
        let message: String?
        switch error {
        case .failedToConnect(let reason):
            message = reason
        case .underlying(let err):
            message = err.localizedDescription
        }
        delegate?.imageSocket(self, didError: message)
    }

    // MARK: - Helpers

    private func decodeEnvelope(from items: [Any]) -> ImageAPIEnvelope? {
        guard let first = items.first else { return nil }
        if let dict = first as? [String: Any] {
            return decodeJSONDictionary(dict, as: ImageAPIEnvelope.self, using: decoder)
        }
        if let data = first as? Data {
            return try? decoder.decode(ImageAPIEnvelope.self, from: data)
        }
        return nil
    }
}
