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
  // List<Header> headers;
  // List<ItemData> itemDatas;
  // Topic topic;

  Device({
    String id,
    String uid,
    int index = 0,
    String name = '',
    String mode = '',
    // List<Header> headers,
    // List<ItemData> itemDatas,
    // Topic topic,
  })
    : this.index = index ?? 0,
      this.name = name ?? '',
      this.mode = mode ?? '',
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
      // headers: headers ?? this.headers,
      // itemDatas: itemDatas ?? this.itemDatas,
      // topic: topic ?? this.topic,
    );
  }

  @override
  int get hashCode =>
      id.hashCode ^ uid.hashCode ^ index.hashCode ^ name.hashCode ^ mode.hashCode; // ^ topic.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        uid == other.uid &&
        index == other.index &&
        mode == other.mode &&
        name == other.name; // &&
        // headers == other.headers &&
        // itemDatas == other.itemDatas &&
        // topic == other.topic;

  @override
  String toString() {
    return 'Device { id: $id, uid: $uid, index: $index, name: $name, mode: $mode}'; //, headers: $headers, itemDatas: ${itemDatas}, topic: ${topic} }';
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