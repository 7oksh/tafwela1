import 'package:floor/floor.dart';

@Entity(tableName: 'pending_writes')
class PendingWriteEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String collection;
  final String docId;
  final String operation;
  final String dataJson;
  final String createdAt;

  PendingWriteEntity({
    this.id,
    required this.collection,
    required this.docId,
    required this.operation,
    required this.dataJson,
    required this.createdAt,
  });
}
