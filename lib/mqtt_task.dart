import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_task/bloc/mqtt_bloc/mqtt_bloc.dart';
import 'package:mqtt_task/bloc/mqtt_bloc/mqtt_event.dart';
import 'package:mqtt_task/bloc/mqtt_bloc/mqtt_state.dart';

class MqttTask extends StatelessWidget {
   MqttTask({Key? key}) : super(key: key);

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MqttBloc(
        MqttServerClient('test.mosquitto.org', 'mqtt_client_1'),
        'sensors/temperature',
      )..add(InitializeMqttClient()),
      child: _MqttTaskView(messageController: _messageController),
    );
  }
}

class _MqttTaskView extends StatelessWidget {
  final TextEditingController messageController;

  const _MqttTaskView({Key? key, required this.messageController}) : super(key: key);

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
              onPressed: () =>
                  context.read<MqttBloc>().add(ConnectToBroker()),
              child: const Text('Connect'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  context.read<MqttBloc>().add(SubscribeToTopic()),
              child: const Text('Subscribe'),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Message'),
              controller: messageController,
              onChanged: (value) {
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.read<MqttBloc>().add(PublishMessage(messageController.text.toString())),
              child: const Text('Publish'),
            ),
            const SizedBox(height: 20),
            BlocBuilder<MqttBloc, MqttState>(
              builder: (context, state) {
                if (state is MqttSubscribedState) {
                  return Text(
                    'Published Message: ${state.publishedMessage}',
                    style: const TextStyle(fontSize: 16),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
