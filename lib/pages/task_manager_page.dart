import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:testproject/components/app_button.dart';
import 'package:testproject/components/app_input.dart';
import 'package:testproject/components/app_text.dart';
import 'package:testproject/models/task.dart';
import 'package:testproject/pages/gallery.dart';
import 'package:testproject/utils/app_func.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../utils/providers.dart';

class TaskManagerPage extends ConsumerStatefulWidget {
  const TaskManagerPage({super.key});

  @override
  ConsumerState createState() => _TaskManagerPageState();
}

class _TaskManagerPageState extends ConsumerState<TaskManagerPage> {
  var formatter = DateFormat("dd MMM yyyy");
  var currentDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          "Mes tâches",
          color: Colors.white,
          size: 22,
        ),
        actions: [
          IconButton(onPressed: (){
            navigateToWidget(context, GalleryPage());
          }, icon: Icon(Icons.photo, color: Colors.white,))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  showDatePicker(
                          context: context,
                          initialDate: currentDate,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)))
                      .then((value) {
                    currentDate = DateTime(value!.year, value.month, value.day);
                    log(currentDate.millisecondsSinceEpoch);
                    setState(() {});
                  });
                },
                child: AppText(
                  "Date du ${formatter.format(currentDate)}",
                  size: 20,
                  align: TextAlign.center,
                )),
            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Divider(
                thickness: 2,
                color: Colors.black,
              ),
            ),
            const SpacerHeight(),
            // Affichage des tâches

            ref.watch(getTasksStream).when(
                data: (data) {
                  data = data
                      .where((element) =>
                          element.time == currentDate.millisecondsSinceEpoch)
                      .toList();
                  return RefreshIndicator(
                    onRefresh: () async {
                      return ref.refresh(getTasks);
                    },
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        Task task = data[index];
                        return CheckboxListTile(
                          value: task.status,
                          onChanged: (e) {
                            changeStatus(task, e);
                          },
                          title: AppText(
                            task.task,
                            size: 18,
                            decoration: task.status?TextDecoration.lineThrough:null,
                            weight: FontWeight.bold,
                          ),
                        );
                      },
                      itemCount: data.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  );
                },
                error: errorLoading,
                loading: loadingError)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTask();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void addTask() {
    var now = DateTime.now();
    var selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );
    var _taskController = TextEditingController();
    var isLoading = false;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const AppText(
              "Ajouter une tâche",
              size: 22,
              weight: FontWeight.bold,
            ),
            content: StatefulBuilder(builder: (context, setLocalState) {
              return Container(
                height: 300,
                child: Column(
                  children: [
                    TextButton(
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)))
                              .then((value) {
                            selectedDate =
                                DateTime(value!.year, value.month, value.day);
                            log(selectedDate.millisecondsSinceEpoch);
                            setLocalState(() {});
                          });
                        },
                        child: AppText(
                          "Date ${formatter.format(selectedDate)}",
                          size: 20,
                          align: TextAlign.center,
                        )),
                    const SpacerHeight(),
                    SimpleFormField(
                      controller: _taskController,
                      labelText: "Nom de la tâche",
                    ),
                    const SpacerHeight(),
                    AppButtonRound(
                      text: "Sauvegarder",
                      onTap: () async {
                        if (_taskController.text.trim().isNotEmpty) {
                          setLocalState(() {
                            isLoading = true;
                          });
                          //Sauvegarder
                          Task t = Task(
                              userId: ref.read(getUserId),
                              time: selectedDate.millisecondsSinceEpoch,
                              task: _taskController.text.trim(),
                              key: "",
                              status: false);
                          String err =
                              await ref.read(taskController).addTask(t);

                          setLocalState(() {
                            isLoading = false;
                          });
                          if (err.isEmpty) {
                            Navigator.pop(context);
                            showSnackbar(context, "Tâche ajoutée avec succès");
                            // ref.refresh(getTasks);
                          } else {
                            showSnackbar(context, err);
                          }
                        } else {
                          showSnackbar(context, "Renseignez la tâche");
                        }
                      },
                      isLoading: isLoading,
                    )
                  ],
                ),
              );
            }),
          );
        });
  }

  void changeStatus(Task task, bool? e) {
    showConfirm(context,
        "Voulez-vous vraiment changer le status de la tâche ${task.task}", () {
      task = task.copyWith(status: e!);
      ref.read(taskController).updateTask(task);
      Navigator.pop(context);
    });
  }
}
