// UDPError.swift
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

public enum UDPError: ErrorProtocol {
    case unknown(description: String)
    case connectionResetByPeer(description: String, data: Data)
    case noBufferSpaceAvailabe(description: String, data: Data)
    case operationTimedOut(description: String, data: Data)
    case closedSocket(description: String)

    static func lastReceiveErrorWithData(source: Data, bytesProcessed: Int) -> UDPError {
        let data = source.prefix(bytesProcessed)
        return lastErrorWithData(data)
    }

    static func lastErrorWithData(data: Data) -> UDPError {
        switch errno {
        case ECONNRESET:
            return .connectionResetByPeer(description: lastErrorDescription, data: data)
        case ENOBUFS:
            return .noBufferSpaceAvailabe(description: lastErrorDescription, data: data)
        case ETIMEDOUT:
            return .operationTimedOut(description: lastErrorDescription, data: data)
        default:
            return .unknown(description: lastErrorDescription)
        }
    }

    static var lastErrorDescription: String {
        return String(cString: strerror(errno))
    }

    static var lastError: UDPError {
        // TODO: Switch on errno
        return .unknown(description: lastErrorDescription)
    }

    static var closedSocketError: UDPError {
        return UDPError.closedSocket(description: "Closed socket")
    }

    static func assertNoError() throws {
        if errno != 0 {
            throw UDPError.lastError
        }
    }

    static func assertNoReceiveErrorWithData(data: Data, bytesProcessed: Int) throws {
        if errno != 0 {
            throw UDPError.lastReceiveErrorWithData(data, bytesProcessed: bytesProcessed)
        }
    }
}

extension UDPError: CustomStringConvertible {
    public var description: String {
        switch self {
        case unknown(let description):
            return description
        case connectionResetByPeer(let description, _):
            return description
        case noBufferSpaceAvailabe(let description, _):
            return description
        case operationTimedOut(let description, _):
            return description
        case closedSocket(let description):
            return description
        }
    }
}