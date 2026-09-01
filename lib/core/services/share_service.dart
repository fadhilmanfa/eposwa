import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data' show BytesBuilder;

/// Laptop lain yang terdeteksi di jaringan/hotspot yang sama.
class SharePeer {
  final String id;
  final String name;
  final InternetAddress address;
  final int tcpPort;
  DateTime lastSeen;

  SharePeer({
    required this.id,
    required this.name,
    required this.address,
    required this.tcpPort,
    required this.lastSeen,
  });

  String get ip => address.address;

  @override
  bool operator ==(Object other) =>
      other is SharePeer && other.address == address;

  @override
  int get hashCode => address.hashCode;
}

/// Informasi Mobile Hotspot Windows (SSID + password).
class HotspotInfo {
  final bool enabled;
  final String ssid;
  final String? passphrase;
  final String? error;

  const HotspotInfo({
    required this.enabled,
    required this.ssid,
    this.passphrase,
    this.error,
  });
}

/// Layanan berbagi data antar laptop (ala ShareIt):
/// - Menyalakan Mobile Hotspot Windows secara otomatis (via PowerShell/WinRT)
/// - Auto-discovery via UDP beacon (broadcast + probing gateway 192.168.137.1)
/// - Transfer SQL dump via TCP (kirim & terima, dua arah)
class ShareService {
  ShareService._();

  static final ShareService instance = ShareService._();

  static const int udpPort = 42421;
  static const int tcpPort = 42420;

  static const Duration _peerTimeout = Duration(seconds: 8);

  RawDatagramSocket? _udp;
  ServerSocket? _server;
  Timer? _announceTimer;
  Timer? _sweepTimer;

  final Map<String, SharePeer> _peers = {};
  final _peersController = StreamController<SharePeer>.broadcast();
  final _receiveController = StreamController<String>.broadcast();

  String _deviceId = '';

  bool _running = false;
  bool get isRunning => _running;

  String _lastSenderName = 'Laptop lain';

  /// Nama pengirim terakhir (untuk push data dari laptop lain).
  String get lastSenderName => _lastSenderName;

  /// Menyediakan SQL dump untuk dikirim saat laptop lain meminta (terima).
  Future<String> Function()? dataProvider;

  /// Nama perangkat (hostname) yang tampil di laptop lain.
  String get deviceName =>
      Platform.localHostname.isEmpty ? 'Laptop' : Platform.localHostname;

  Stream<SharePeer> get peers => _peersController.stream;
  Stream<String> get onReceiveSql => _receiveController.stream;
  List<SharePeer> get peerList => _peers.values.toList(growable: false);

  // ---------------------------------------------------------------
  // Mobile Hotspot Windows
  // ---------------------------------------------------------------

  /// Cek apakah kita sedang berada di jaringan hotspot
  /// (gateway default hotspot Windows = 192.168.137.1).
  static Future<bool> isOnHotspotNetwork() async {
    try {
      final socket = await Socket.connect(
        InternetAddress('192.168.137.1'),
        tcpPort,
        timeout: const Duration(seconds: 2),
      );
      await socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Menyalakan Mobile Hotspot Windows otomatis dan membaca SSID + password.
  static Future<HotspotInfo> enableHotspot() async {
    if (!Platform.isWindows) {
      return const HotspotInfo(
        enabled: false,
        ssid: '',
        error: 'Fitur hotspot otomatis hanya tersedia di Windows',
      );
    }
    final script = r'''
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}
[Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager, Windows.Networking.NetworkOperators, ContentType=WindowsRuntime] | Out-Null
[Windows.Networking.Connectivity.NetworkInformation, Windows.Networking.Connectivity, ContentType=WindowsRuntime] | Out-Null
$out = @{}
$profile = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile()
if ($null -eq $profile) {
    Write-Output '{"ok":false,"error":"Tidak ada koneksi internet aktif"}'
    exit 1
}
try {
    $manager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager]::CreateFromConnectionProfile($profile)
    if ($manager.TetheringOperationalState -eq 'On') {
        $out.ok = $true
        $out.status = 'AlreadyOn'
    } else {
        try {
            $op = $manager.StartTetheringAsync()
            $result = Await $op ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
            $out.ok = ($result.Status -eq 'Success')
            $out.status = $result.Status.ToString()
        } catch {
            $out.ok = $false
            $out.error = $_.Exception.Message
        }
    }
} catch {
    $out.ok = $false
    $out.error = $_.Exception.Message
}
try {
    $config = $manager.GetCurrentAccessPointConfiguration()
    $out.ssid = $config.Ssid
    $out.pass = $config.Passphrase
} catch {}
$out | ConvertTo-Json -Compress
''';
    try {
      final res = await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          script,
        ],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      final lines =
          (res.stdout as String)
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList();
      if (lines.isEmpty) {
        return const HotspotInfo(
          enabled: false,
          ssid: '',
          error: 'Hotspot tidak memberikan respons',
        );
      }
      Map<String, dynamic> json;
      try {
        json = jsonDecode(lines.last) as Map<String, dynamic>;
      } catch (_) {
        return HotspotInfo(
          enabled: false,
          ssid: '',
          error: 'Respons PowerShell tidak valid: ${lines.last}',
        );
      }
      final ok = json['ok'] == true;
      return HotspotInfo(
        enabled: ok,
        ssid: (json['ssid'] as String?) ?? '',
        passphrase: json['pass'] as String?,
        error: ok
            ? null
            : (json['error'] as String?) ?? 'Status: ${json['status']}',
      );
    } catch (e) {
      return HotspotInfo(
        enabled: false,
        ssid: '',
        error: 'Gagal menjalankan PowerShell: $e',
      );
    }
  }

  /// Mematikan Mobile Hotspot Windows (dipanggil hanya jika kita yang menyalakan).
  static Future<void> disableHotspot() async {
    if (!Platform.isWindows) return;
    final script = r'''
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}
[Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager, Windows.Networking.NetworkOperators, ContentType=WindowsRuntime] | Out-Null
[Windows.Networking.Connectivity.NetworkInformation, Windows.Networking.Connectivity, ContentType=WindowsRuntime] | Out-Null
$profile = [Windows.Networking.Connectivity.NetworkInformation]::GetInternetConnectionProfile()
if ($null -eq $profile) { exit 0 }
$manager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager]::CreateFromConnectionProfile($profile)
if ($manager.TetheringOperationalState -eq 'On') {
    $op = $manager.StopTetheringAsync()
    $result = Await $op ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
}
''';
    try {
      await Process.run(
        'powershell.exe',
        [
          '-NoProfile',
          '-NonInteractive',
          '-ExecutionPolicy',
          'Bypass',
          '-Command',
          script,
        ],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
    } catch (_) {}
  }

  // ---------------------------------------------------------------
  // Discovery & Transfer
  // ---------------------------------------------------------------

  /// Mulai discovery (UDP) + listening (TCP). Memanggil [dataProvider]
  /// saat ada laptop lain yang meminta data kita.
  Future<void> start() async {
    if (_running) return;
    await stop();
    _running = true;
    _deviceId =
        'eposwa-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(99999)}';

    _udp = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      udpPort,
      reuseAddress: true,
    );
    try {
      _udp!.broadcastEnabled = true;
    } catch (_) {}
    _udp!.listen(_onUdpEvent);

    _server = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      tcpPort,
      shared: true,
    );
    _server!.listen(_handleClient);

    _announceTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _announce(),
    );
    _sweepTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _sweepPeers(),
    );
    _announce();
  }

  Future<void> stop() async {
    _running = false;
    _announceTimer?.cancel();
    _sweepTimer?.cancel();
    _announceTimer = null;
    _sweepTimer = null;
    try {
      _udp?.close();
    } catch (_) {}
    try {
      _server?.close();
    } catch (_) {}
    _udp = null;
    _server = null;
    _peers.clear();
  }

  void _onUdpEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _udp?.receive();
    if (datagram == null) return;
    try {
      final map =
          jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
      if (map['app'] != 'eposwa') return;
      final peerId = map['id'] as String?;
      if (peerId == null || peerId == _deviceId) return;
      final peer = SharePeer(
        id: peerId,
        name: (map['name'] as String?) ?? 'Laptop',
        address: datagram.address,
        tcpPort: (map['tcp'] as num?)?.toInt() ?? tcpPort,
        lastSeen: DateTime.now(),
      );
      final key = datagram.address.address;
      final existing = _peers[key];
      if (existing == null) {
        _peers[key] = peer;
        _peersController.add(peer);
      } else {
        existing.lastSeen = peer.lastSeen;
      }
    } catch (_) {}
  }

  void _announce() {
    final udp = _udp;
    if (udp == null) return;
    final payload = utf8.encode(
      jsonEncode({
        'app': 'eposwa',
        'id': _deviceId,
        'name': deviceName,
        'tcp': tcpPort,
      }),
    );
    for (final target in const [
      '255.255.255.255',
      '192.168.137.255',
      '192.168.137.1',
    ]) {
      try {
        udp.send(payload, InternetAddress(target), udpPort);
      } catch (_) {}
    }
  }

  void _sweepPeers() {
    final now = DateTime.now();
    final stale = <String>[];
    _peers.forEach((key, peer) {
      if (now.difference(peer.lastSeen) > _peerTimeout) stale.add(key);
    });
    for (final key in stale) {
      _peers.remove(key);
    }
  }

  // ---------------------------------------------------------------
  // TCP protocol: [opcode(1) | len(4, big-endian) | payload]
  // opcode 0x01 = push data SQL, 0x02 = minta data SQL
  // ---------------------------------------------------------------

  Future<void> _handleClient(Socket socket) async {
    final reader = _MessageReader();
    final sub = socket.listen(
      reader.add,
      onDone: reader.close,
      onError: (_) => reader.close(),
      cancelOnError: true,
    );
    try {
      while (!reader.isClosed) {
        final msg = await reader
            .next()
            .timeout(const Duration(minutes: 2), onTimeout: () {
          throw const SocketException('Waktu koneksi habis');
        });
        final opcode = msg[0];
        final payload = msg.sublist(1);
        if (opcode == 0x01) {
          _lastSenderName =
              _peers[socket.remoteAddress.address]?.name ?? 'Laptop lain';
          _receiveController.add(utf8.decode(payload));
        } else if (opcode == 0x02) {
          final provider = dataProvider;
          if (provider != null) {
            final sql = await provider();
            final data = utf8.encode(sql);
            socket.add(_frame(0x01, data));
            await socket.flush();
          }
          break;
        }
      }
    } catch (_) {} finally {
      await sub.cancel();
      try {
        await socket.close();
      } catch (_) {}
    }
  }

  /// Kirim SQL dump ke laptop lain (tombol "Kirim").
  Future<void> sendSqlTo(SharePeer peer, String sql) async {
    final socket = await Socket.connect(
      peer.address,
      peer.tcpPort,
      timeout: const Duration(seconds: 15),
    );
    try {
      socket.add(_frame(0x01, utf8.encode(sql)));
      await socket.flush();
    } finally {
      try {
        await socket.close();
      } catch (_) {}
    }
  }

  /// Minta SQL dump dari laptop lain (tombol "Terima").
  /// Mengembalikan SQL yang diterima.
  Future<String> requestSqlFrom(SharePeer peer) async {
    final socket = await Socket.connect(
      peer.address,
      peer.tcpPort,
      timeout: const Duration(seconds: 15),
    );
    final reader = _MessageReader();
    final sub = socket.listen(
      reader.add,
      onDone: reader.close,
      onError: (_) => reader.close(),
      cancelOnError: true,
    );
    try {
      socket.add(_frame(0x02, const []));
      await socket.flush();
      final msg = await reader.next().timeout(
        const Duration(minutes: 2),
        onTimeout: () => throw const SocketException('Waktu permintaan habis'),
      );
      if (msg[0] != 0x01) {
        throw const SocketException('Respons tidak valid dari laptop lain');
      }
      return utf8.decode(msg.sublist(1));
    } finally {
      await sub.cancel();
      try {
        await socket.close();
      } catch (_) {}
    }
  }

  static List<int> _frame(int opcode, List<int> payload) {
    final len = payload.length;
    return [
      opcode,
      (len >> 24) & 0xff,
      (len >> 16) & 0xff,
      (len >> 8) & 0xff,
      len & 0xff,
      ...payload,
    ];
  }
}

/// Pembaca pesan ber-frame: [opcode(1) | len(4) | payload].
/// Mengakumulasi chunk dari socket dan mengeluarkan pesan utuh.
class _MessageReader {
  final BytesBuilder _buf = BytesBuilder();
  final List<Completer<List<int>>> _waiters = [];
  bool _closed = false;

  bool get isClosed => _closed;

  Future<List<int>> next() {
    final completer = Completer<List<int>>();
    if (_closed) {
      completer.completeError(const SocketException('Koneksi ditutup'));
      return completer.future;
    }
    _waiters.add(completer);
    _drain();
    return completer.future;
  }

  void add(List<int> chunk) {
    if (_closed) return;
    _buf.add(chunk);
    _drain();
  }

  void close() {
    _closed = true;
    for (final w in _waiters) {
      if (!w.isCompleted) {
        w.completeError(const SocketException('Koneksi ditutup'));
      }
    }
    _waiters.clear();
  }

  void _drain() {
    while (_waiters.isNotEmpty) {
      final data = _buf.toBytes();
      if (data.length < 5) return;
      final len = (data[1] << 24) | (data[2] << 16) | (data[3] << 8) | data[4];
      if (data.length < 5 + len) return;
      final payload = data.sublist(5, 5 + len);
      _buf.clear();
      _buf.add(data.sublist(5 + len));
      final w = _waiters.removeAt(0);
      w.complete([data[0], ...payload]);
    }
  }
}