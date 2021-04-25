import 'package:ftiotsystem/pages/device/entity/item_entity.dart';
import 'package:ftiotsystem/pages/device/model/item.dart';
import 'package:meta/meta.dart';

@immutable
class Device extends Item{
  final String id;
  final String uid;
  final int index;
  final String name;
  final String mode;
  final String localip;
  final int readingInterval;
  // List<Header> headers;
  // List<ItemData> itemDatas;
  // Topic topic;

  Device({
    String id,
    String uid,
    int index = 0,
    String name = '',
    String mode = '',
    String localip = '',
    int readingInterval = 0,
    // List<Header> headers,
    // List<ItemData> itemDatas,
    // Topic topic,
  })
    : this.index = index ?? 0,
      this.name = name ?? '',
      this.mode = mode ?? '',
      this.localip = localip ?? '',
      this.readingInterval = readingInterval ?? 0,
      this.id = id ?? '',
      this.uid = uid ?? ''
      // this.headers = headers,
      // this.itemDatas = itemDatas,
      // this.topic = topic
    ;

  Device copyWith({
    String id,
    String uid,
    int index,
    String name,
    String mode,
    String localip,
    int readingInterval,
    // List<Header> headers,
    // List<ItemData> itemDatas,
    // Topic topic,
  }) {
    return Device(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      index: index ?? this.index,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      localip: localip ?? this.localip,
      readingInterval: readingInterval ?? this.readingInterval,
      // headers: headers ?? this.headers,
      // itemDatas: itemDatas ?? this.itemDatas,
      // topic: topic ?? this.topic,
    );
  }

  @override
  int get hashCode =>
      id.hashCode ^ uid.hashCode ^ index.hashCode ^ name.hashCode ^ mode.hashCode ^ localip.hashCode ^ readingInterval.hashCode; // ^ topic.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        uid == other.uid &&
        index == other.index &&
        mode == other.mode &&
        localip == other.localip &&
        readingInterval == other.readingInterval &&
        name == other.name; // &&
        // headers == other.headers &&
        // itemDatas == other.itemDatas &&
        // topic == other.topic;

  @override
  String toString() {
    return 'Device { id: $id, uid: $uid, index: $index, name: $name, mode: $mode, localip: $localip, readingInterval: $readingInterval }'; //, headers: $headers, itemDatas: ${itemDatas}, topic: ${topic} }';
  }

  ItemEntity toEntity() {
    return ItemEntity(id, uid, index, name);
  }

  static Device fromEntity(ItemEntity entity) {
    return Device(
      id: entity.id,
      uid: entity.uid,
      index: entity.index,
      name: entity.name,
    );
  }
}