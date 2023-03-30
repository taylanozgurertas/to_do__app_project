import 'package:flutter/material.dart';
import 'package:to_do_project/data/local_storage.dart';
import 'package:to_do_project/main.dart';
import 'package:to_do_project/models/task_model.dart';

import 'task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {
  late final List<Task> allTasks;

  CustomSearchDelegate({required this.allTasks});

  @override
  List<Widget>? buildActions(BuildContext context) {
    //arama kısmının sağ tarafındaki ikonları
    return [
      IconButton(onPressed: () {
        query.isEmpty ? null : query =
        ''; // kullanıcının arama yapmak istedigi deger bossa sorguyu '' bosalt
      }, icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    //en bastaki ikonları
    return GestureDetector(
        onTap: () {
          close(context,
              null); //bunlar hep flutter sayesinde close metodu falan query mevzusu falan
        },
        child: const Icon(Icons.arrow_back_ios, color: Colors.red, size: 24,));
  }

  @override
  Widget buildResults(BuildContext context) {
    //cıkacak sonucların gosterilis sekli
    List<Task> filteredList = allTasks.where((gorev) =>
        gorev.name.toLowerCase().contains(query.toLowerCase())).toList();
    return filteredList.length > 0 ? ListView.builder(
      itemBuilder: (context, index) {
        var _oankiTaskElemani = filteredList[index];
        /*
          * Dismissible çok güzel bir widget sağa kaydırmaya yarıyor içerisindeki widgetı
          * sağa kaydırıldığında onDismissed özelliği var oraya direction yazmak yeterli
          * onDismissed edildiğinde olacakları yazdık _allTasks listemizin o anki elemanini sil demiş olduk listeden
          * Dismissible widgetı bizden bir key bekler her seferinde farklı olmalı bu key. Bu keye de oankielemanin id sini verdik
          * */
        return Dismissible(
          background: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              SizedBox(
                width: 8,
              ),
              Text("Bu görev silindi"),
            ],
          ),
          key: Key(_oankiTaskElemani.id),
          onDismissed: (direction) async{
            filteredList.removeAt(index);
            await locator<LocalStorage>().deleteTask(task: _oankiTaskElemani);

          },
          child: TaskItem(task: _oankiTaskElemani,), //oankiTaskElemanini TaskItem sınıfından nesne oluşturuyoruz
          /*
                  * TaskItem sınıfı bizden bir Task sınıfı türünde nesne bekliyor zaten
                  * biz de oankiTaskElemani ni yolladık
                  * TaskItem sınıfına gidip orada neler olduğuna bakabilirsin*/
        );
      },
      itemCount: filteredList.length,
    ) : const Center(child: Text("Aradığınızı bulamadık"),);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //kullanici bir harf falan yazarsa veya bir sey yazmazsa gosterilecekler
    return Container();
  }

}