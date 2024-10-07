import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http ;
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category.dart';
import 'package:shopping_app/models/grocery_item.dart';


class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final formKey = GlobalKey<FormState>();
  var enteredNmae = '';
  var enteredQuentity = 1;
  var selectedCategory = categories[Categories.vegetables]!;
  var isLoading = false;

  void saveItem() async{
    if (formKey.currentState!.validate()) { 
      formKey.currentState!.save();
      setState(() {
        isLoading =true;
      });
      final url = Uri.https('shopping-app-a8136-default-rtdb.firebaseio.com', 'shopping-list.json');
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode({
          'name': enteredNmae,
          'quantity': enteredQuentity,
          'category': selectedCategory.title
      },),);
     
     final Map<String, dynamic> resData = json.decode(response.body);

     if(!context.mounted){
      return;
     }
      Navigator.of(context).pop(GroceryItem(id: resData['name'], name: enteredNmae , quantity: enteredQuentity, category: selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni öğe ekleyin.'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('İsim')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'İsim 1 ile 50 karakter arasında olmalı.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    enteredNmae = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Adet'),
                        ),
                        initialValue: enteredQuentity.toString(),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Pozitif bir sayı olmalı';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          enteredQuentity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                          value: selectedCategory,
                          items: [
                            for (final category in categories.entries)
                              DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.title)
                                  ],
                                ),
                              )
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            }); 
                          }),
                    )
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: isLoading ? null : () {
                          formKey.currentState!.reset();
                        },
                        child: const Text('Sıfırla')),
                    ElevatedButton(
                        onPressed:isLoading ? null  : saveItem, child:isLoading ? const SizedBox(height: 16,width: 16, child: CircularProgressIndicator()) : const Text('Öğeyi ekle'))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
