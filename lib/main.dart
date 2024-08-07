// ignore_for_file: prefer_const_constructors

// TODO: allow Current Duration to be specific to Minute, Hour, Second.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(MaterialApp(
  home: HomePage(),
));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Task {
  String taskName;
  int goalDuration;
  int goalDurationBar = 0;
  int currentDuration;
  Timer? timer;
  int secondVal = 0;
  int minuteVal = 0;
  bool isRunning = false;
  String timeUnit = 'seconds';
  final StreamController<int> _durationController = StreamController<int>.broadcast();
  final StreamController<bool> _runningController = StreamController<bool>.broadcast();
  final StreamController<bool> _completedController = StreamController<bool>.broadcast();

  Stream<int> get durationStream => _durationController.stream;
  Stream<bool> get runnningStream => _runningController.stream;
  Stream<bool> get completedStream => _completedController.stream;


  Task(this.taskName, this.goalDuration, this.currentDuration, this.timeUnit){
    if(timeUnit == 'Minutes'){
      goalDurationBar = goalDuration * 60;
      currentDuration *= 60;
    } else if (timeUnit == 'Hours'){
      goalDurationBar = goalDuration * 3600;
      currentDuration *= 3600;
    } else {
      goalDurationBar = goalDuration;
    }
  }

  void startTimer() {
    if (!isRunning) {
      isRunning = true;
      _runningController.add(true);
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          if(currentDuration < goalDurationBar){
            currentDuration++;
            _durationController.add(currentDuration);
          } else {
            timer.cancel();
            _completedController.add(true);
          }
        });
    }
  }

  void stopTimer() {
    isRunning = false;
    _runningController.add(false);
    timer?.cancel();
  }

  void updateTaskDuration(int duration) {
    if(timeUnit == 'Minutes'){
      duration *= 60;
    } else if (timeUnit == 'Hours'){
      duration *= duration * 3600;
    }

    if((currentDuration + duration) >= goalDurationBar){
      currentDuration = goalDurationBar;
      _durationController.add(((goalDurationBar - currentDuration) + currentDuration));
      _completedController.add(true);
    } else {
      currentDuration += duration;
      _durationController.add(currentDuration);
    }
  }

  int getTaskDuration() {
    return currentDuration;
  }

  int getGoalDuration() {
    return goalDuration;
  }

  String getTaskName() {
    return taskName;
  }
}

class _HomePageState extends State<HomePage> {
  List<Task> task = [];
  List<bool> expandedStates = [];
  List<DropdownMenuEntry<String>> timeUnits =[DropdownMenuEntry(value: 'seconds', label: 'Seconds'), DropdownMenuEntry(value: 'minutes', label: 'Minutes'), DropdownMenuEntry(value: 'hours', label: 'Hours')];
  String dropdownSelection = 'seconds'; 

  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDurationController = TextEditingController();
  final TextEditingController _taskCurrentController = TextEditingController();
  final TextEditingController _taskTimeUnitsController = TextEditingController();
  final TextEditingController _taskAddDurationController = TextEditingController();

  void _moveTaskToEnd(int index) {
    setState(() {
      Task completedTask = task.removeAt(index);
      bool expandedState = expandedStates.removeAt(index);
      task.add(completedTask);
      expandedStates.add(expandedState);
    });
  }

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
                shadowColor: Colors.deepPurple.withOpacity(1),
                insetPadding: EdgeInsets.symmetric(vertical: 120),
                title: Text('New Task'),
                content: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        maxLength: 30,
                        controller: _taskNameController,
                        decoration: InputDecoration(hintText: 'Enter Task Name')
                      ),
                      TextField(
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        controller: _taskDurationController,
                        decoration: InputDecoration(hintText: 'Enter Goal Length')
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        controller: _taskCurrentController,
                        decoration: InputDecoration(hintText: 'Enter Current Length')
                      ),
                      SizedBox(height: 20),
                      DropdownMenu(
                        menuHeight: 100,
                        dropdownMenuEntries: timeUnits,
                        controller: _taskTimeUnitsController,
                        hintText: 'Time Units',
                        enableSearch: false,
                        initialSelection: 'Seconds',
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
                          int.parse(_taskCurrentController.text),
                          _taskTimeUnitsController.text
                        );
                        newTask.completedStream.listen((completed) {
                          if (completed) {
                            int index = task.indexOf(newTask);
                            _moveTaskToEnd(index);
                          }
                        });
                        expandedStates.add(false);
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
        child: ReorderableListView.builder(
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final Task movedTask = task.removeAt(oldIndex);
              task.insert(newIndex, movedTask);

              final bool movedExpandState = expandedStates.removeAt(oldIndex);
              expandedStates.insert(newIndex, movedExpandState);
            });
          },
          proxyDecorator: (child, index, animation) {return child;},
          itemCount: task.length,
          itemBuilder: (BuildContext context, int index) {
              return AnimatedContainer(
                  key: ValueKey(task[index]),
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  duration: Duration(milliseconds: 400), // 400 is smoothest 
                  curve: Curves.ease,
                  height: expandedStates[index] ? 220 : 120,
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
                        setState(() {
                          expandedStates[index] = !expandedStates[index];
                        });
                      },
                      borderRadius: expandedStates[index] ? BorderRadius.circular(0) : BorderRadius.circular(20),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(9),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    StreamBuilder<bool>(
                                      stream: task[index].runnningStream,
                                      initialData: task[index].isRunning,
                                      builder: (context, snapshot) {
                                        bool isRunning = snapshot.data ?? false;
                                        return Icon(isRunning == true ? Icons.timer_outlined : Icons.timer_off_outlined, size: 20, color: Colors.deepPurpleAccent,);
                                      }
                                    ),
                                  ],
                                ),
                                Text(
                                        task[index].taskName,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                      ),
                              ],
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 70),
                            child: StreamBuilder<int>(
                              stream: task[index].durationStream,
                              initialData: task[index].currentDuration,
                              builder: (context, snapshot){
                                return TweenAnimationBuilder<double>(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.linear,
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: snapshot.hasData ? (snapshot.data! / task[index].goalDurationBar) : 0.0,
                                  ),
                                  builder: (context, value, child) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: const Color.fromARGB(255, 218, 218, 218),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 116, 10, 134)),
                                      borderRadius: BorderRadius.circular(30),
                                    );
                                  },
                                );
                              }
                            )
                          ),
                          OverflowBar(
                            alignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TextButton( 
                                child: const Text('Start Time'), 
                                onPressed: () {
                                  task[index].startTimer();
                                }
                              ),
                              TextButton(
                                child: const Text('Stop Time'), 
                                onPressed: () {
                                  task[index].stopTimer();
                                }
                              ),
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
                                                expandedStates.removeAt(index);
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
                          ),
                          if (expandedStates[index])
                            Expanded(
                              child: UnconstrainedBox(
                                alignment: Alignment.topCenter,
                                clipBehavior: Clip.hardEdge,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('Current Duration: ', 
                                            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold,fontSize: 20),
                                          ),
                                          StreamBuilder<int>(
                                            stream: task[index].durationStream,
                                            initialData: task[index].currentDuration,
                                            builder: (context, snapshot) {
                                              String unit = task[index].timeUnit;
                                              int value = snapshot.data ?? 0;
                                              
                                              if (unit == 'Minutes') {
                                                value = (value / 60).floor();
                                              } else if (unit == 'Hours') {
                                                value = (value / 3600).floor();
                                              }
                                              
                                              return Text(
                                                '$value ${task[index].timeUnit}',
                                                style: TextStyle(color: Colors.deepPurple, fontSize: 20),
                                              );
                                            },
                                          ),
                                        ]
                                      ),
                                    ),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text('Goal Duration: ', 
                                            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold,fontSize: 15),
                                          ),
                                          Text('${task[index].goalDuration} ${task[index].timeUnit}', style: TextStyle(color: Colors.deepPurple,fontSize: 15))
                                        ]
                                      ),
                                    ),
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: (){
                                              showDialog(
                                                context: context, 
                                                builder: (BuildContext context){
                                                  return AlertDialog(
                                                    shadowColor: Colors.deepPurple.withOpacity(1),
                                                    insetPadding: EdgeInsets.symmetric(vertical: 255),
                                                    title: Text('Add Time in ${task[index].timeUnit}'),
                                                    content: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: <Widget>[
                                                          TextField(
                                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                            maxLength: 30,
                                                            controller: _taskAddDurationController,
                                                            decoration: InputDecoration(hintText: 'Enter Amount (${task[index].timeUnit})')
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
                                                            int amountDuration = int.parse(_taskAddDurationController.text);
                                                            expandedStates.add(false);
                                                            task[index].updateTaskDuration(amountDuration);
                                                          });
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                }
                                              );
                                            }, 
                                            child: Text('Add Time', selectionColor: Colors.deepPurpleAccent,)
                                          ),
                                        ],
                                      ),
                                    )
                                  ]
                                ),
                              )
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
  @override
  void initState() {
    super.initState();
    for (var onetask in task) {
      onetask.completedStream.listen((completed) {
        if (completed) {
          int index = task.indexOf(onetask);
          _moveTaskToEnd(index);
        }
      });
    }
  }
}




