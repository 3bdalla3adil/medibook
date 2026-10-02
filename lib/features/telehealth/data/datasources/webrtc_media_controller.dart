import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRtcMediaController {
  RTCPeerConnection? _peer;
  MediaStream? _localStream;
  MediaStream? get localStream => _localStream;
  RTCPeerConnection? get peerConnection => _peer;

  Future<void> initialize() async {
    _peer = await createPeerConnection({'iceServers': <Map<String, dynamic>>[]});
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': true});
      for (final track in _localStream!.getTracks()) {
        await _peer!.addTrack(track, _localStream!);
      }
    } on DomException {
      await dispose();
      rethrow;
    }
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    for (final track in _localStream?.getAudioTracks() ?? const <MediaStreamTrack>[]) {
      track.enabled = enabled;
    }
  }

  Future<void> setCameraEnabled(bool enabled) async {
    for (final track in _localStream?.getVideoTracks() ?? const <MediaStreamTrack>[]) {
      track.enabled = enabled;
    }
  }

  Future<void> dispose() async {
    for (final track in _localStream?.getTracks() ?? const <MediaStreamTrack>[]) {
      await track.stop();
    }
    await _localStream?.dispose();
    await _peer?.close();
    _localStream = null;
    _peer = null;
  }
}
