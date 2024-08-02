import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: HomePage(),
));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Task {
  late String taskName; 
  late int goalDuration;
  late int currentDuration;

  Task(this.taskName, this.goalDuration, this.currentDuration);

  updateTaskDuration(int duration){
    currentDuration += duration;
  }

  int getTaskDuration(){
    return currentDuration;
  }

  int getGoalDuration(){
    return goalDuration;
  }

  String getTaskName(){
    return taskName;
  }

}

class _HomePageState extends State<HomePage> {
  List<Task> task = [];
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDurationController = TextEditingController();
  final TextEditingController _taskCurrentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Tracker'),
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('New Task'),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _taskNameController,
                        decoration: InputDecoration(hintText: 'Enter Task Name')
                      ),
                      TextField(
                        controller: _taskDurationController,
                        decoration: InputDecoration(hintText: 'Enter Goal Length (sec)')
                      ),
                      TextField(
                        controller: _taskCurrentController,
                        decoration: InputDecoration(hintText: 'Enter Current Lenght (sec)')
                      ),
                    ]
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () {
                      setState(() {
                        Task newTask = Task(
                          _taskNameController.text, 
                          int.parse(_taskDurationController.text), 
                          int.parse(_taskCurrentController.text)
                        );
                        task.add(newTask);
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          );
        },
        backgroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text('add task')
      ),
      backgroundColor: Color.fromRGBO(219, 219, 219, 1),
      body: AnimatedContainer(
        padding: EdgeInsets.symmetric(vertical: 5),
        duration: Duration(seconds: 2),
        child: ListView.builder(
          itemCount: task.length,
          itemBuilder: (BuildContext context, int index) {
              return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: const [ BoxShadow(
                        color: Color.fromRGBO(132, 132, 132, 0.498),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: Offset(0, 2)
                      )
                    ]
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: (){
                        
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(9),
                            child: Text(
                                    task[index].taskName,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                  )
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 70),
                            child: LinearProgressIndicator(
                                value: (task[index].currentDuration / task[index].goalDuration),
                                backgroundColor: const Color.fromARGB(255, 218, 218, 218),
                                valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 116, 10, 134)),
                                borderRadius: BorderRadius.circular(30),
                            )
                          ),
                          OverflowBar(
                            alignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextButton( child: const Text('Start Time'), onPressed: () {}),
                              TextButton( child: const Text('Stop Time'), onPressed: () {}),
                              TextButton( 
                                child: const Text('Delete Task', selectionColor: Colors.red), 
                                onPressed:() {
                                  showDialog(
                                    context: context, 
                                    builder: (BuildContext context){
                                      return AlertDialog(
                                        title: const Text('Are you sure you want to delete this task?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: (){
                                              setState((){
                                                task.removeAt(index);
                                              });
                                              Navigator.of(context).pop();
                                            }, 
                                            child: Text('Delete Task')),
                                          TextButton(
                                            onPressed: (){
                                              Navigator.of(context).pop();
                                            }, 
                                            child: Text('Cancel')),   
                                        ]
                                      );
                                    }
                                  );
                                }),
                            ],
                          )
                        ]
                      )
                    )
                  )
                );
          }
        )
      )
    );
  }
}




