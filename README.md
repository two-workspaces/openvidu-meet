# Deploy and Host OpenVidu Meet on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/openvidu-meet?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=openvidu-meet)

[OpenVidu Meet](https://openvidu.io/) is a self-hosted video calling app, an open source alternative to Zoom and Google Meet. Create a room, share the link, and people join from a browser with no account or install. It has screen sharing, chat, recording and a REST API for adding calls to your own product.

## About Hosting OpenVidu Meet

Five services and a bucket. **Meet** is the app and API. **LiveKit** carries the audio and video. **Egress** makes recordings. **MongoDB** and **Redis** hold rooms and state. Recordings go to the bucket.

- **Calls run over TCP, through one port.** Railway has no inbound UDP, which is what video calls normally use, and it's why video servers rarely work here. This template sends all media through a TCP proxy and sets up the address for you. Upstream's server doesn't work this way, so the template uses stock LiveKit.
- **Recording works on first deploy.** Storage is already connected to the bucket, and files can be played or downloaded from the Meet console.
- **Nothing is open to strangers.** The admin password and API key are generated for your deploy, and creating rooms requires one of them.
- **Sized for a small team.** All five services together use about 410 MB at idle.

**What to expect from TCP.** It's fine for small meetings on normal connections. On a poor connection a lost packet holds up everything behind it, so video stutters more than it would over UDP. A two-person test call ran at 720p with no lost packets, but larger meetings haven't been tested. Networks that only allow ports 80 and 443 can't connect, because the media port is a high-numbered one chosen by Railway. Some corporate and guest networks are like this.

## Common Use Cases

- A private meeting room for a team or a family, with no per-seat fees
- Video calls inside your own app, using the REST API and embeddable links
- Recording interviews, classes and consultations to storage you control
- Client calls that shouldn't run through a third-party meeting service

## Dependencies for OpenVidu Meet Hosting

- Nothing external. MongoDB, Redis and the bucket are part of the template.

### Deployment Dependencies

- [OpenVidu Meet documentation](https://openvidu.io/latest/meet/)
- [OpenVidu Meet on GitHub](https://github.com/OpenVidu/openvidu-meet)
- [LiveKit on GitHub](https://github.com/livekit/livekit)

### Implementation Details

**First steps**

1. Wait for all five services to finish. Egress takes the longest to build.
2. Open the **Meet** service's domain and sign in as `admin`. The password is `MEET_INITIAL_ADMIN_PASSWORD` in the Meet service's Variables. Your REST API key is `MEET_INITIAL_API_KEY`, sent as the `X-API-KEY` header.
3. Create a room and share its link. Moderator and speaker links are separate.

The admin password and API key are only read on the first start. Changing them later in Variables has no effect, so change the password in the Meet console.

**Recording.** Egress runs a headless browser to compose the video and uses roughly one or two CPU cores per recording, which your Railway plan bills as usage. It handles one recording at a time comfortably on small plans. If you don't need recording, you can remove the Egress service.

**Bandwidth.** Every participant sends and receives through Railway, and video adds up fast. Railway bills outbound traffic, so check your usage after your first real meetings.

**Custom domains.** After adding one to Meet, update `MEET_BASE_URL`. After adding one to LiveKit, update `LIVEKIT_URL` on Meet and `LIVEKIT_WS_URL` on Egress. Media keeps using the TCP proxy either way.

**Not included.** Phone dial-in (SIP) and streaming in from OBS (RTMP ingest), since both need ports Railway can't offer. LiveKit's built-in TURN is also off, because it would have to run on the same TCP route anyway.

**Keep the TCP proxy.** Removing LiveKit's TCP proxy stops all calls. LiveKit reads the proxy's address and port each time it starts, so restart LiveKit if Railway ever changes them.

**Licence.** OpenVidu Meet Community Edition and LiveKit are Apache-2.0.

## Why Deploy OpenVidu Meet on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying OpenVidu Meet on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
