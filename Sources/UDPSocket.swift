// UDPSocket.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import CLibvenice
import C7
import POSIX
@_exported import IP

public enum UDPError: Error {
    case didSendDataWithError(error: SystemError, remaining: Data)
    case didReceiveDataWithError(error: SystemError, received: Data)
}

extension UDPError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .didSendDataWithError(let error, _): return "\(error)"
        case .didReceiveDataWithError(let error, _): return "\(error)"
        }
    }
}

public final class UDPSocket {
    private var socket: udpsock?
    public private(set) var closed = false

    public var port: Int {
        return Int(udpport(socket))
    }

    internal init(socket: udpsock) {
        self.socket = socket
    }

    public convenience init(ip: IP) throws {
        guard let socket = udplisten(ip.address) else {
            throw SystemError.socketTypeNotSupported
        }
        try ensureLastOperationSucceeded()
        self.init(socket: socket)
    }

    deinit {
        if let socket = socket, !closed {
            udpclose(socket)
        }
    }

    public func send(_ data: Data, ip: IP, timingOut deadline: Double = .never) throws {
        try ensureStreamIsOpen()

        data.withUnsafeBufferPointer {
            udpsend(socket, ip.address, $0.baseAddress, $0.count)
        }

        try ensureLastOperationSucceeded()
    }

    public func receive(upTo byteCount: Int, timingOut deadline: Double = .never) throws -> (Data, IP) {
        try ensureStreamIsOpen()

        var address = ipaddr()
        var data = Data.buffer(with: byteCount)

        let received = data.withUnsafeMutableBufferPointer {
            udprecv(socket, &address, $0.baseAddress, $0.count, deadline.int64milliseconds)
        }

        let receivedData = Data(data.prefix(received))

        do {
            try ensureLastOperationSucceeded()
        } catch let error as SystemError where received > 0 {
            throw UDPError.didReceiveDataWithError(error: error, received: receivedData)
        }

        let ip = IP(address: address)
        return (receivedData, ip)
    }

    public func close() throws {
        try ensureStreamIsOpen()
        udpclose(socket)
        try ensureLastOperationSucceeded()
        closed = true
    }

    private func ensureStreamIsOpen() throws {
        if closed {
            throw StreamError.closedStream(data: [])
        }
    }
}
