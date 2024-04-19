import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:notes/services/firestore.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open dialog input note
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docID == null) {
                        firestoreService.addNote(textController.text);
                      } else {
                        firestoreService.updateNote(docID, textController.text);
                      }
                      textController.clear();

                      // close dialog
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[400],
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        backgroundColor: Colors.blue[400],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                    title: Text(noteText),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => openNoteBox(docID: docID),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => firestoreService.deleteNote(docID),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  );
                });
          } else {
            return const Text("No notes...");
          }
        },
      ),
    );
  }
}
