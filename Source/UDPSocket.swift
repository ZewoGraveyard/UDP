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

public final class UDPSocket {
    private var socket: udpsock
    public private(set) var closed = false

    public var port: Int {
        return Int(udpport(socket))
    }

    public init(socket: udpsock) throws {
        self.socket = socket
        try UDPError.assertNoError()
    }

    public convenience init(ip: IP) throws {
        try self.init(socket: udplisten(ip.address))
    }

    public convenience init(fileDescriptor: Int32) throws {
        try self.init(socket: udpattach(fileDescriptor))
    }

    deinit {
        if !closed && socket != nil {
            udpclose(socket)
        }
    }

    public func send(ip ip: IP, data: Data, deadline: Deadline = never) throws {
        try assertNotClosed()

        data.withUnsafeBufferPointer {
            udpsend(socket, ip.address, $0.baseAddress, $0.count)
        }

        try UDPError.assertNoError()
    }

    public func receive(length length: Int, deadline: Deadline = never) throws -> (Data, IP) {
        try assertNotClosed()

        var address = ipaddr()
        var data = Data.bufferWithSize(length)

        let bytesProcessed = data.withUnsafeMutableBufferPointer {
            udprecv(socket, &address, $0.baseAddress, $0.count, deadline)
        }

        try UDPError.assertNoReceiveErrorWithData(data, bytesProcessed: bytesProcessed)

        let processedData = Data(data.prefix(bytesProcessed))
        let ip = try IP(address: address)
        return (processedData, ip)
    }

    public func attach(fileDescriptor: FileDescriptor) throws {
        if !closed {
            try close()
        }

        socket = udpattach(fileDescriptor)
        try UDPError.assertNoError()
        closed = false
    }

    public func detach() throws -> FileDescriptor {
        try assertNotClosed()
        closed = true
        return udpdetach(socket)
    }

    public func close() throws {
        try assertNotClosed()
        closed = true
        udpclose(socket)
    }

    func assertNotClosed() throws {
        if closed {
            throw UDPError.closedSocketError
        }
    }
}