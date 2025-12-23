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
        print("SOCKET STATUS: \(event.name)")
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
            // Nested payload dictionary
            if let payloadDict = dict["payload"] as? [String: Any],
               let decoded = decodeJSONDictionary(payloadDict, as: ImageAPIEnvelope.self, using: decoder) {
                return decoded
            }
            // Payload as JSON string
            if let payloadString = dict["payload"] as? String,
               let data = payloadString.data(using: .utf8) {
                do {
                    return try decoder.decode(ImageAPIEnvelope.self, from: data)
                } catch {
                    let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                    print("ImageSocketClient: failed to decode envelope from payload string", ["error": error.localizedDescription, "body": body])
                }
            }
            // Try the dictionary itself
            if let decoded = decodeJSONDictionary(dict, as: ImageAPIEnvelope.self, using: decoder) {
                return decoded
            } else {
                print("ImageSocketClient: Using ANother Decoder",["payload": "\(dict)"])
            }
        }
        if let data = first as? Data {
            do {
                let result = try decoder.decode(ImageAPIEnvelope.self, from: data)
                print("ImageSocketClient: Success \(result) ")

                return result
            } catch {
                let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                print("ImageSocketClient: failed to decode envelope from data", ["error": error.localizedDescription, "body": body])
            }
        }
        return nil
    }
}
