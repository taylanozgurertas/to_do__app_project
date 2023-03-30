//öyle bir kod yazmalıyız ki lokal veritabanı değiştiğinde kodlarımız bundan etkilenmesin.

//soyut sınıf içindeki kodları yazmadıgımız yapılarla yapıyorduk bunu

import 'package:hive/hive.dart';
import 'package:to_do_project/models/task_model.dart';

abstract class LocalStorage{
  Future<void> addTask({required Task task}); //parametre olarak task sınıfından nesne alabilen metodumuz addTask metodu
  Future<Task?> getTask({required String id}); //string türünde bir id alan ve geriye Task sınıfından nesne döndüren metodumuz
  Future<List<Task>> getAllTask();  //Task sınıfından nesneleri tutabilen bir list döndüren getAllTask metodumuz
  Future<bool> deleteTask({required Task task}); //bool bir deger donduren parametre olarak Task sınıfından bir nesne isteyen metodumuz
  Future<Task> updateTask({required Task task}); //ve yine Task sınıfından nesne isteyen parametre olarak ve geriye bir Task sınıfından nesne döndüren metodumuz
}

class MockData extends LocalStorage{
  @override
  Future<void> addTask({required Task task}) {
    // TODO: implement addTask
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteTask({required Task task}) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getAllTask() {
    // TODO: implement getAllTask
    throw UnimplementedError();
  }

  @override
  Future<Task> getTask({required String id}) {
    // TODO: implement getTask
    throw UnimplementedError();
  }

  @override
  Future<Task> updateTask({required Task task}) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
  //falanfilan flana filan mesela
} //mesela yani

class HiveLocalStorage extends LocalStorage{
  late Box<Task> _taskBox; //Task nesneleri tutabilen bir hive kutusu tanımladık

  HiveLocalStorage(){
    _taskBox = Hive.box<Task>('tasks'); //constructor da _taskBox a bu kutuyu koyduk mainde açtığımız şey bu aynı olmalı
  }

  @override
  Future<void> addTask({required Task task}) async{
   await _taskBox.put(task.id, task);
  }

  @override
  Future<bool> deleteTask({required Task task}) async{
    await task.delete(); //hiveobject sayesinde böyle kolayca yapıyoruz öbür türlü _taskBox.delete(task.id); şeklinde yazardık
    return true;
  }

  @override
  Future<List<Task>> getAllTask() async{
    List<Task> _allTask = <Task>[]; //Task nesneleri tutabilen boş bir list oluşturduk
    _allTask = _taskBox.values.toList(); //toList diyerek butun degerleri allTask listesine koyduk
    if(_allTask.isNotEmpty){ //eger allTask listesinin eleman sayisi 0 dan buyukse
      _allTask.sort((Task a, Task b)=> b.createdAt.compareTo(a.createdAt)); //kendi içinde siralama yap tarihlerine gore dedik
    }
    return _allTask;
  }

  @override
  Future<Task?> getTask({required String id}) async{
    if(_taskBox.containsKey(id)){
      return _taskBox.get(id);
    }else{
      return null;
    }
  }

  @override
  Future<Task> updateTask({required Task task}) async{
    await task.save();
    return task;
  }
  
} //bizim olayımız bu tabiki hive ı kullanacagız cok sistematik yaptık