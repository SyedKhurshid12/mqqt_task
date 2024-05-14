// mqtt_state.dart

import 'package:equatable/equatable.dart';

abstract class MqttState extends Equatable {
  const MqttState();

  @override
  List<Object> get props => [];
}

class MqttInitialState extends MqttState {}

class MqttConnectedState extends MqttState {}

class MqttDisconnectedState extends MqttState {}

class MqttSubscribedState extends MqttState {
  final String publishedMessage;

  const MqttSubscribedState(this.publishedMessage);

  @override
  List<Object> get props => [publishedMessage];
}
