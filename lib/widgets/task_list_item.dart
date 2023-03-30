import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_project/data/local_storage.dart';
import 'package:to_do_project/main.dart';
import 'package:to_do_project/models/task_model.dart';

class TaskItem extends StatefulWidget {
  Task task;

  TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  final TextEditingController _taskNameController =
      TextEditingController(); //bir kontroller tanımladık textfield için

  late LocalStorage _localStorage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _localStorage = locator<LocalStorage>();

  }

  @override
  Widget build(BuildContext context) {
    _taskNameController.text =
        widget.task.name; //sayfa açıldığında bu atama gerçekleşsin
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10),
          ]),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            widget.task.isCompleted = !widget.task.isCompleted;
            _localStorage.updateTask(task: widget.task);
            setState(() {});
          },
          child: Container(
            //bir container içine bir icon koyduk ve box decoration falan verdik
            decoration: BoxDecoration(
              color: widget.task.isCompleted ? Colors.green : Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 0.8,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ),
        title: widget.task.isCompleted
            ? Text(
                widget.task.name,
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough, color: Colors.grey),
              )
            : TextField(
                controller: _taskNameController,
                minLines: 1,
                maxLines: null, //sığmama sorunu çözülüyor maksimum satırı null veriyoruz genisletiyoruz yani esneklik
                textInputAction: TextInputAction.done, //klavyede yeni alt satıra geç değil de tik işaretinin çıkması için
                decoration: const InputDecoration(border: InputBorder.none),
                onSubmitted: (yeniDeger){
                  if(yeniDeger.length>3){
                    //eger textfielda yazılan yazı 3 ten buyukse artık gelen nesnenin ismine bu yeni degeri ata klavyeden ok basılınca
                    widget.task.name = yeniDeger;
                    _localStorage.updateTask(task: widget.task);
                  }
                },
              ),
        trailing: Text(
          //intl package ile tarih formatlandırma yapabiliyoruz dokümantasyonda var bir seyler
          DateFormat('hh:mm a').format(widget.task.createdAt),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
