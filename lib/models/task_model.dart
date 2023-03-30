/*
* bu sınıf bir model sınıftır tasklar yani uygulamamızdaki görevler için oluşturulmuş bir model sınıftır
*
* */


import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
part 'task_model.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject{
  //Klasik öğrendiğimiz hive a çevirme işlemini yapıyoruz fakat burada ekstradan extends hiveobject dedik bunun da faydası şu
  //update ve delete işlemleri çok daha kolay oluyor extends HiveObject dersek.

  @HiveField(0)
  late final String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late final DateTime createdAt;

  @HiveField(3)
  late bool isCompleted;

  //sınıfımızın constructor'ını oluşturduk
  Task(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.isCompleted});


  /*
  factory kullanımını hatırlayalım.
  factory default constructor'dan farklı olarak bu sınıftan nesne üretmek için kullanılan bir fonksiyon gibidir.
  yani Task.create yaptığımızda şu şu parametreyi isteyip return diyerek bir nesne döndürüyoruz istediğimiz ayarda
   */
  factory Task.create({required String name, required DateTime createdAt}) {
    return Task(
        id: const Uuid().v1(),
        name: name,
        createdAt: createdAt,
        isCompleted: false);
  }
}
