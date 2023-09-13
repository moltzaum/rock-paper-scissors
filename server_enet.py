#!/usr/bin/env python
import struct
from threading import Thread
from typing import NewType, Dict
from queue import Queue
import enet
import uuid

# Type Aliases
Channel = Queue
Host = NewType('Host', str)
Port = NewType('Port', int)

# SERVER CONFIGURATION

# The enet channel count will likely equal the peer count. enet should be able to handle 4K peers at
# once, but I'm not sure what happens when more than 10 try to connect with the configuration below.
# I'm not sure how to handle zombie peers or bandwidth issues. It's not clear if setting bandwidth
# is preferable.
SERVER_IP: bytes = b"127.0.0.1"
SERVER_PORT: int = 12345
PEER_COUNT: int = 10
ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT: int = 255
INCOMING_BANDWIDTH = 0  # unlimited bandwidth
OUTGOING_BANDWIDTH = 0  # unlimited bandwidth

# COMMUNICATION PROTOCOL

# Matchmaking Sequence Diagram:
# Client 1 -> REQ
#             ACK   <- Server
# ...
# Client 2 -> REQ
#             ACK   <- Server
# Client 1, 2
#             COMP  <- Server
MATCHMAKING_REQ = 0b0001
MATCHMAKING_ACK = 0b0010
MATCHMAKING_COMP = 0b0011

# Game Logic Sequence Diagram
# Client 1 -> ROCK [match_id]
# ...
# Client 2 -> PAPER [match_id]
# Client 1
#             PAPER <- Server
# Client 2
#             ROCK <- Server
ROCK, PAPER, SCISSORS = 0b0100, 0b0101, 0b0110


# Matches are stored in-memory. A server crashing would be fatal.
# This data structure grows continuously. TODO: remove stale entries or when client disconnects
matches = dict()


def rock_paper_scissors(event: enet.Event, choice: int, data: bytes):
    if not data:
        print(f"unexpected error: no data to unpack")
        return  # throwing an exception would crash the server, so just log the error

    # Lua appears to send a null terminated string. We'll just specify the exact size.
    _, match_id = struct.unpack('!B 16s', data[:17])
    match = matches.get(match_id, None)

    if match is None:
        print(f"unexpected error: match not found: {choice} {data}")
        return

    peer1, choice1, peer2, choice2 = match[0][0], match[0][1], match[1][0], match[1][1]
    if choice1 and choice2:
        print("unexpected error: both game choices are already populated")
        return
    elif choice1:
        match[1][1] = choice
    elif choice2:
        match[0][1] = choice
    elif peer1.address == event.peer.address:
        match[0][1] = choice
    elif peer2.address == event.peer.address:
        match[1][1] = choice
    else:
        print("unexpected error: event peer address does not match either peer")
        return

    choice1, choice2 = match[0][1], match[1][1]
    if choice1 and choice2:
        peer1.send(0, enet.Packet(struct.pack('!B', choice2), enet.PACKET_FLAG_RELIABLE))
        peer2.send(0, enet.Packet(struct.pack('!B', choice1), enet.PACKET_FLAG_RELIABLE))
        match[0][1], match[1][1] = None, None


def pair_match(matchmaking: Channel):
    while True:
        client1, client2 = matchmaking.get(), matchmaking.get()

        # This tries to ensure the client is still connected before matching. It somewhat works,
        # but the client disconnecting might be delayed.
        # How to prevent race conditions and manage connections? Two General's Problem
        if client1.peer.state is not enet.PEER_STATE_CONNECTED:
            matchmaking.put(client2)
            continue

        if client2.peer.state is not enet.PEER_STATE_CONNECTED:
            matchmaking.put(client1)
            continue

        # Uniqueness is determined by the client address port combination. These are not good
        # identifiers because they can be spoofed, but it works for the sake of this prototype.
        if client1.peer.address == client2.peer.address:
            matchmaking.put(client1)
            continue

        match_id = uuid.uuid1()
        matches[match_id.bytes] = [[client1.peer, None], [client2.peer, None]]

        print(f"Created match: {match_id.hex}")
        data = struct.pack('!B 16s', MATCHMAKING_COMP, match_id.bytes)
        client1.peer.send(0, enet.Packet(data, enet.PACKET_FLAG_RELIABLE))
        client2.peer.send(0, enet.Packet(data, enet.PACKET_FLAG_RELIABLE))


def handle_request(ch: Dict[str, Channel], event: enet.Event):
    # A tuple is technically returned but there is only one value
    protocol, = struct.unpack('!B', event.packet.data[:1])

    if protocol == MATCHMAKING_REQ:
        data = struct.pack('!B', MATCHMAKING_ACK)
        event.peer.send(0, enet.Packet(data, enet.PACKET_FLAG_RELIABLE))
        ch['matchmaking'].put(event)
    elif protocol in [ROCK, PAPER, SCISSORS]:
        rock_paper_scissors(event, protocol, event.packet.data)
    else:
        print(f"{event.peer.address}: invalid protocol data: {event.packet.data}")


def listen(ch: Dict[str, Channel], host):
    event = host.service(100)
    if event.type == enet.EVENT_TYPE_CONNECT:
        print(f"{event.peer.address}: Client connected")
    elif event.type == enet.EVENT_TYPE_DISCONNECT:
        print(f"{event.peer.address}: Client disconnected")
    elif event.type == enet.EVENT_TYPE_RECEIVE:
        print(f"Receive from {event.peer.address}::{event.channelID}")
        handle_request(ch, event)


def main():
    server = enet.Host(
        enet.Address(SERVER_IP, SERVER_PORT),
        PEER_COUNT,
        ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT,
        INCOMING_BANDWIDTH,
        OUTGOING_BANDWIDTH)

    data_channels = {
        'matchmaking': Channel(),
    }
    matchmaking = Thread(target=pair_match, args=(data_channels['matchmaking'],))
    matchmaking.daemon = True
    matchmaking.start()

    print(f"ENet Server listening on {SERVER_IP}:{SERVER_PORT}")
    try:
        while True:
            listen(data_channels, server)
    except KeyboardInterrupt:
        print()


if __name__ == "__main__":
    main()
