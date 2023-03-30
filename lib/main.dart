import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:to_do_project/data/local_storage.dart';
import 'package:to_do_project/models/task_model.dart';
import 'package:to_do_project/pages/home_page.dart';

final locator = GetIt.instance; //global bir locator nesnesi tanımladık get_it package kullanarak

void setup(){
  locator.registerSingleton<LocalStorage>(HiveLocalStorage());
  //yarın öbür gün hive yerine başka bir sey kullanırsak hivelocalstorage kısmını degistirecegiz mantık bu
}

Future<void> setupHive() async{ //Hive ayarlarımızı şöyle bir topladık
  await Hive.initFlutter(); //runAppden önce Hive ı başlatıyoruz
  Hive.registerAdapter(TaskAdapter()); //adapterımızı da register etmiş olduk
  var taskBox = await Hive.openBox<Task>('tasks'); //icinde taskların bulundugu kutu açılmış oluyor artık
  for (var task in taskBox.values) {
    if(task.createdAt.day != DateTime.now().day){
     taskBox.delete(task.id);
    }
  }
}

void main() async{
  //mainde uzun süren runappden önce çalışmasını istediğimiz şeyler için
  WidgetsFlutterBinding.ensureInitialized();


  //status barı kaldırmak
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle( //durum cubugu ile ilgili stil bilgileri icin
      statusBarColor: Colors.transparent, //durum cubugu rengini beyaz yaptık
    ),
  );

  await setupHive();
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( //themedata ile uygulamanın temasını renkler vb şeylerini themedata diyerek merkezi yonetim yapılabiliyor
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme( //appbartemasını buradan ayarlayabiliyoruz
          elevation: 0,
          backgroundColor: Colors.white, //arkaplan beyaz olsun dedik
          iconTheme: IconThemeData(  //iconların temasını ayarlayabiliriz bu şekilde
            color: Colors.black, //iconların rengi siyah olsun dedik
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}