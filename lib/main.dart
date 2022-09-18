import 'dart:io';

import 'package:easy_onvif/onvif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:loggy/loggy.dart';
import 'package:yaml/yaml.dart';

Future<Map> getFileDataMap(String path) async {
  final String resp = await rootBundle.loadString(path);

  return loadYaml(resp);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final multicastProbe = MulticastProbe();

  await multicastProbe.probe();

  for (var device in multicastProbe.onvifDevices) {
    print(
        '${device.name} ${device.location} ${device.hardware} ${device.xaddr}');
  }

  final config = await getFileDataMap('lib/example/config.yaml');
  print(config);

  // configure device connection
  final onvif = await Onvif.connect(
      host: config['host'],
      username: config['username'],
      password: config['password'],
      logOptions: const LogOptions(
        LogLevel.info,
        stackTraceLevel: LogLevel.error,
      ),
      printer: const PrettyPrinter(
        showColors: true,
      )).catchError(
    (e) {
      print(e);
      exit(1);
    },
  );

  var deviceInfo = await onvif.deviceManagement.getDeviceInformation();

  print('Manufacturer: ${deviceInfo.manufacturer}');
  print('Model: ${deviceInfo.model}');

  var profs = await onvif.media.getProfiles();

  for (var profile in profs) {
    print('name: ${profile.name}, token: ${profile.token}');
  }

  final uri = await onvif.media.getStreamUri(profs[0].token);

  final rtsp = OnvifUtil.authenticatingUri(
      uri.uri, config['username'], config['password']);

  print('stream uri: $rtsp');

  var ntpInformation = await onvif.deviceManagement.getNtp();

  print(ntpInformation);

  // var configurations = await onvif.media.getMetadataConfigurations();

  // for (var configuration in configurations) {
  //   print('${configuration.name} ${configuration.token}');
  // }

  var capabilities = await onvif.deviceManagement.getCapabilities();

  print(capabilities);

  //get hostname
  var hostname = await onvif.deviceManagement.getHostname();

  print(hostname);

  //get Network Protocols
  var networkProtocols = await onvif.deviceManagement.getNetworkProtocols();

  for (var networkProtocol in networkProtocols) {
    print('${networkProtocol.name} ${networkProtocol.port}');
  }

  //get system uris
  // var systemUris = await onvif.deviceManagement.getSystemUris();

  // print(systemUris);

  //create users
  // var newUsers = <User>[
  //   User(username: 'test_1', password: 'onvif.device', userLevel: 'User'),
  //   User(username: 'test_2', password: 'onvif.device', userLevel: 'User')
  // ];

  // await onvif.deviceManagement.createUsers(newUsers);

  //get users
  var users = await onvif.deviceManagement.getUsers();

  for (var user in users) {
    print('${user.username} ${user.userLevel}');
  }

  // //delete users
  // var deleteUsers = ['test_1', 'test_2'];

  // await onvif.deviceManagement.deleteUsers(deleteUsers);

  //get users
  users = await onvif.deviceManagement.getUsers();

  for (var user in users) {
    print('${user.username} ${user.userLevel}');
  }

  // //get audio sources
  // var audioSources = await onvif.media.getAudioSources();

  // for (var audioSource in audioSources) {
  //   print('${audioSource.token} ${audioSource.channels}');
  // }

  //get video sources
  var videoSources = await onvif.media.getVideoSources();

  for (var videoSource in videoSources) {
    print('${videoSource.token} ${videoSource.resolution}');
  }

  // //get snapshot Uri
  // var snapshotUri = await onvif.media.getSnapshotUri(profs[0].token);

  // print(snapshotUri.uri);

  //get stream Uri
  var streamUri = await onvif.media.getStreamUri(profs[0].token);

  print(streamUri.uri);

  // //get get presets
  // var presets = await onvif.ptz.getPresets(profs[0].token, limit: 5);

  // for (var preset in presets) {
  //   print('${preset.token} ${preset.name}');
  // }

  //get ptz status
  // var status = await onvif.ptz.getStatus(profs[0].token);

  // print(status);

  //set preset
  //var res = await onvif.ptz.setPreset(profs[0].token, 'new test', '20');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
