import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MqttTask extends StatefulWidget {
  const MqttTask({Key? key}) : super(key: key);

  @override
  _MqttTaskState createState() => _MqttTaskState();
}

class _MqttTaskState extends State<MqttTask> {
  late MqttServerClient client;

  String clientId = 'mqtt_client_1';
  int port = 1883;
  String topic = 'sensors/temperature';
  late String message;
  String publishedMessage = "";

  @override
  void initState() {
    super.initState();
    client = MqttServerClient('test.mosquitto.org', clientId);
    client.port = port;
    client.logging(on: true);
    client.keepAlivePeriod = 30;
    client.onDisconnected = onDisconnected;
  }

  void onDisconnected() {
    Fluttertoast.showToast(msg: 'Disconnected');
    print('Disconnected');
  }

  void connectToBroker() async {
    try {
      await client.connect();
      Fluttertoast.showToast(msg: 'Connected');
      print('Connected');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Connection failed: $e');
      print('Connection failed: $e');
    }
  }

  void subscribeToTopic() {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.atLeastOnce);
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        setState(() {
          publishedMessage = pt;
        });
      });
      Fluttertoast.showToast(msg: 'Subscribed to topic');
    } else {
      if (kDebugMode) {
        Fluttertoast.showToast(msg: 'Client is not connected.');
        print('Client is not connected.');
      }
    }
  }

  void publishMessage() {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: connectToBroker,
              child: const Text('Connect'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: subscribeToTopic,
              child: const Text('Subscribe'),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Message'),
              onChanged: (value) {
                message = value;
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: publishMessage,
              child: const Text('Publish'),
            ),
            const SizedBox(height: 20),
            Text(
              'Published Message: $publishedMessage',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
