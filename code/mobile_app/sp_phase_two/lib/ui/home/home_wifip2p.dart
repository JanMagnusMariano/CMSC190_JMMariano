import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wifi_p2p/routing.dart';
import 'package:wifi_p2p/wifi_p2p.dart';

import '../../blocs/offline_transfer/bloc.dart';
import '../../utils/offline_services.dart';

import 'package:permission/permission.dart';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';

// Logging
//import 'package:f_logs/f_logs.dart';

// https://flare.rive.app/a/indramahathanaya/files/flare/scan-animation-v1

class HomeWifiP2p extends StatefulWidget {
  @override
  State<HomeWifiP2p> createState() => _HomeWifiP2pState();
}

class _HomeWifiP2pState extends State<HomeWifiP2p> {

  List<String> _logs = [];
  OfflineTransferBloc _transferBloc;
  String animationToPlay = 'Animations';

  final FlareControls controls = FlareControls();

  void _playSuccessAnimation() {
    // Use the controls to trigger an animation.
    setState(() {
      controls.play("Animations");
    });

  }

  @override
  void initState() {
    _transferBloc = BlocProvider.of<OfflineTransferBloc>(context);
    initPlatformState();
    super.initState();
  }

  void  initPlatformState() async {
    await requestWritePermission();
    _transferBloc.initStreams();
    await WifiP2p.register();

    OfflineServices.routingTable = (OfflineServices.routingTable == null)
        ? new RoutingTable(await WifiP2p.getLocalMacAddress(), true) : OfflineServices.routingTable;
  }

  requestWritePermission() async {
    var permissions = await Permission.requestPermissions([PermissionName.Storage, PermissionName.Location]);
    return permissions;
  }

  // void _setAnimationToPlay(String animation) {
  //   if (animation == animationToPlay) {
  //     animationToPlay = '';
  //     Timer(const Duration(milliseconds: 4000), () {
  //       print('Loop');
  //       setState(() {
  //         animationToPlay = animation;
  //       });
  //     });
  //   } else {
  //     animationToPlay = animation;
  //   }
  // }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                _playSuccessAnimation();
              },
              child: Container(
                height: 300,
                child: FlareActor('lib/assets/images/scan_animation_v1.flr', animation: 'Animations', fit: BoxFit.fill, color: Colors.black, controller: controls, callback: (res) => _playSuccessAnimation()),
              ),
            ),
            ElevatedButton(
              onPressed: () async =>
                  BlocProvider.of<OfflineTransferBloc>(context).add(ListenToBroadcast()),
              child: Text("Listen"),
            ),
            ElevatedButton(
              onPressed: () async =>
                  BlocProvider.of<OfflineTransferBloc>(context).add(BroadcastAsSource()),
              child: Text("Broadcast"),
            ),
            ElevatedButton(
              onPressed: () => OfflineServices().hasConn = true,
              child: Text("Simulate Internet on"),
            ),
            ElevatedButton(
                onPressed: () async =>
                    BlocProvider.of<OfflineTransferBloc>(context).add(StopService()),
                child: Text("Stop Service")
            ),

            //Text("Logs : "),
            BlocBuilder<OfflineTransferBloc, OfflineTransferState>(builder: (context, state) {
              bool _conn = BlocProvider.of<OfflineTransferBloc>(context).isConnected;

              return Column(
                children: [
                  (_conn) ?
                    ElevatedButton(
                        onPressed: () async => await BlocProvider.of<OfflineTransferBloc>(context).openPortAndAccept(8888),
                        child: Text("Open Host Socket")
                    ) : Container(),
                  (_conn) ?
                  ElevatedButton(
                      onPressed: () async => await BlocProvider.of<OfflineTransferBloc>(context).connectToPort(8888),
                      child: Text("Connect To Host and Ping")
                  ) : Container(),
                ],
              );
            }),

            // BlocBuilder<OfflineTransferBloc, OfflineTransferState>(builder: (context, state) {
            //   return Column(
            //     children: BlocProvider.of<OfflineTransferBloc>(context).logs.map((e) {
            //       return Text(e, textAlign: TextAlign.center, style: TextStyle(fontSize: 16));
            //     }).toList(),
            //   );
            // }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _transferBloc.add(StopService());
    _transferBloc.close();
    print('Left screen successfully');
    super.dispose();
  }
}
