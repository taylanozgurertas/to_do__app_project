import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:to_do_project/data/local_storage.dart';
import 'package:to_do_project/main.dart';
import 'package:to_do_project/models/task_model.dart';
import 'package:to_do_project/widgets/custom_search_delegate.dart';
import 'package:to_do_project/widgets/task_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task>
      _allTasks; //Task sınıfından nesneler tutabilen bir List oluşturduk

  late LocalStorage _localStorage;

  /*initState
  * burada initState metodu sadece bir kez çalışır uygulama başlatıldığında
  * çalıştığında olacakları yazıyoruz bir kez çalışır sadece bu metod
  * */
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    _localStorage = locator<LocalStorage>(); //locatori kullanarak localstorage turunde bir veri bekledigimizi belirttik
    _allTasks = <Task>[]; //allTasks adlı List'e boş bir atama yaptık
    _getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _showAddTaskBottomSheet(context); //metodu kullanıyoruz
          },
          child: const Text(
            "Bugün Neler Yapacaksın",
            style: TextStyle(color: Colors.black),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {
            _showSearchPage();
          }, icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () {
                _showAddTaskBottomSheet(context);
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      /*
      * Tasarım olarak body kısmına bir ListView.builder tasarımı düşündük
      * ListView.builder bize context, index veriyor index 0 dan başlar öyle gider
      * bir değişken oluşturduk oankiTaskIndex diye onu da allTasks listesinin 0.indexi olsun dedik o öyle gider 0,1,2 diye
      * ListView.builder'ın uzunluğunu da belirleyecek olan şey zaten allTasks listesinin uzunluğu kadar olacak öyle ayarladık
      * sonra her seferinde ListTile döndürecek her bir index için çünkü ListView.builder'ın olayı bu
      *
      * başlangıçta isNotEmtpy falan yapmamızın sebebi eğer _allTasks listesi boş değilse yani bir şeyler varsa tasarımı göster
      * yook eğer bir şeyler yoksa yani boşsa : dan sonra yazdığımız Center içerisinde bir Text widget gösterecek hadi görev ekle diye
      * */
      body: _allTasks.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var _oankiTaskElemani = _allTasks[index];
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
                  onDismissed: (direction){
                    _allTasks.removeAt(index);
                    _localStorage.deleteTask(task: _oankiTaskElemani);
                    setState(() {});
                  },
                  child: TaskItem(task: _oankiTaskElemani,), //oankiTaskElemanini TaskItem sınıfından nesne oluşturuyoruz
                  /*
                  * TaskItem sınıfı bizden bir Task sınıfı türünde nesne bekliyor zaten
                  * biz de oankiTaskElemani ni yolladık
                  * TaskItem sınıfına gidip orada neler olduğuna bakabilirsin*/
                );
              },
              itemCount: _allTasks.length,
            )
          : const Center(
              child: Text("Hadi görev ekle"),
            ),
    );
  }

  //goreveklebottomı adını bu sekilde ing koydugumuz bir metod olusturduk
  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      //guzel bir widget biraz karartarak alltan bir pencere acıyor gibi
      context: context,
      builder: (context) {
        return Container(
          //bir tasarım döndürüyoruz
          /*
          * bu tasarımda bir container koyduk öncelikle containera padding verdik yani içindeki itemlerle arasında
          * kendi arasında boşluk bırakması için. burada şöyle bir ayar var
          * MediaQuery den yararlanıyoruz viewInsets diye bir ozelligi var viewInsets.bottom ifadesi bize
          * klavye açıldığında klavyenin kapladığı alanı veriyor bizde bu şekilde padding verdiğimizde
          * klavye açıldığında Containerımız ve içerisindeki her şey tabiki alttan o kadar yukarı çıkıyor baya güzel*/
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: TextField(
              autofocus: true, //direkt olarak imlecin yazilabilir halde olmasini sagliyor
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                hintText: "Görev Nedir ?",
                border: InputBorder
                    .none, //InputBorder.none dedik çünkü altta çizgi vardı o kalktı
              ),
              onSubmitted: (value) {
                //görev nedir text kutucuguna bir seyler yazildıktan klavyeden tamama basınca
                Navigator.of(context).pop(); //geri dön demek

                if (value.length > 3) {
                  /*
                * flutter date time picker adlı package ı yükledik zaman tarih vb. seçme penceresi açıyor bize*/
                  DatePicker.showTimePicker(
                    context,
                    showSecondsColumn: false,
                    onConfirm: (time) async{
                      //yeni görev ekliyoruz
                      /*
                      * burada yapılan şey şu Task diye bir sınıf var bu sınıfın factory metoduyla nesne üretiyoruz
                      * bu sınıf da zaten Görev sınıfı yani oluşturduğumuz model sınıftan nesne üretiyoruz mevzu bu
                      * sonra bu nesneyi ürettiğimiz bu nesneyi allTasks diye bir listin içine atıyoruz olay bu*/
                      var addNewTask =
                          Task.create(name: value, createdAt: time);
                      _allTasks.insert(0, addNewTask);
                      await _localStorage.addTask(task: addNewTask);
                      setState(() {});
                    },
                  ); //showSecondsColumn false yaptık ki saniye gözükmesin
                }
              },
            ),
          ),
        );
      },
    );
  }


  //bir tane fonksiyon olusturuyoruz allTasks e localStorage sınıfından getAllTask metodunu kullanacak sonra setstate çakacak
  void _getAllTaskFromDb() async{
    _allTasks = await _localStorage.getAllTask();
    setState(() {

    });
  }

  void _showSearchPage() async{ //arama ile ilgili işlemler icin
    await showSearch(context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    _getAllTaskFromDb();
  }
}
