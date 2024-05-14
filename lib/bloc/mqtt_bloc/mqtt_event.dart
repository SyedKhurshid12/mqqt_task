// mqtt_event.dart

import 'package:equatable/equatable.dart';

abstract class MqttEvent extends Equatable {
  const MqttEvent();

  @override
  List<Object> get props => [];
}

class InitializeMqttClient extends MqttEvent {}

class ConnectToBroker extends MqttEvent {}

class SubscribeToTopic extends MqttEvent {}

class PublishMessage extends MqttEvent {
  final String message;

  const PublishMessage(this.message);

  @override
  List<Object> get props => [message];
}
