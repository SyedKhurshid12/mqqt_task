// mqtt_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_task/bloc/mqtt_bloc/mqtt_event.dart';
import 'package:mqtt_task/bloc/mqtt_bloc/mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final MqttServerClient client;
  final String topic;

  MqttBloc(this.client, this.topic) : super(MqttInitialState()) {
    on<InitializeMqttClient>((event, emit) async {
      try {
        // Initialize MQTT client
        client.port = 1883;
        client.logging(on: true);
        client.keepAlivePeriod = 30;
        client.onDisconnected = () => emit(MqttDisconnectedState());
        emit(MqttConnectedState());
      } catch (e) {
        // Handle initialization error
      }
    });

    on<ConnectToBroker>((event, emit) async {
      try {
        // Connect to MQTT broker
        await client.connect();
        emit(MqttConnectedState());
      } catch (e) {
        // Handle connection error
      }
    });

    on<SubscribeToTopic>((event, emit) async {
      try {
        // Subscribe to MQTT topic
        client.subscribe(topic, MqttQos.atLeastOnce);

        // Listen to updates and emit state when received
        await client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
          final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          emit(MqttSubscribedState(pt));
        }).asFuture();
      } catch (e) {
        // Handle subscription error
      }
    });


    on<PublishMessage>((event, emit) {
      try {
        // Publish MQTT message
        final builder = MqttClientPayloadBuilder();
        builder.addString(event.message);
        client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
      } catch (e) {// Handle publishing error
      }
    });
  }
}
