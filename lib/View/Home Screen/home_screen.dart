import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> students = [];
  final Stream<QuerySnapshot> _studentsStream =
      FirebaseFirestore.instance.collection('students').snapshots();

  void _addOrEditStudent({Map<String, String>? student, int? index}) {
    final nameController = TextEditingController(text: student?['name'] ?? '');
    final phoneController =
        TextEditingController(text: student?['phone'] ?? '');
    final courseController =
        TextEditingController(text: student?['course'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: courseController,
                decoration: InputDecoration(labelText: 'Course'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final newStudent = {
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'course': courseController.text,
                  };
                  if (index != null) {
                    setState(() {
                      students[index] = newStudent;
                    });
                  } else {
                    setState(() {
                      students.add(newStudent);
                    });
                  }
                  Navigator.of(ctx).pop();
                },
                child: Text(index == null ? 'Add Student' : 'Update Student'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteStudent(int index) {
    setState(() {
      students.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Manager'),actions: [IconButton(onPressed: () async {
        await FirebaseAuth.instance.signOut();
      }, icon: Icon(Icons.ac_unit))],),
      body: StreamBuilder(
        stream: _studentsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: const Text('Something went wrong'));
            
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) {
                final studentlist = snapshot.data!.docs;

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(studentlist[index]["name"]),
                    subtitle: Text(
                        'Phone: ${studentlist[index]["ph"] ?? ''}\nCourse: ${studentlist[index]["sub"] ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _addOrEditStudent(student: {}, index: index);
                            }),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteStudent(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditStudent(),
        child: Icon(Icons.add),
      ),
    );
  }
}