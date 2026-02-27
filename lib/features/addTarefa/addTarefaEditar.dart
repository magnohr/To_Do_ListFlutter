import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:to_do_list/core/app_colors.dart';
import 'package:provider/provider.dart';


import '../../auth/models/modelAddTarefa.dart';
import '../../core/text_styles.dart';
import 'controllerAddTarefa.dart';
import 'date/date.dart';

class AddtarefaEditar extends StatefulWidget {
  const AddtarefaEditar({super.key});

  @override
  State<AddtarefaEditar> createState() => _AddtarefaEditarState();
}

class _AddtarefaEditarState extends State<AddtarefaEditar> {
  // controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // image
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  final controllerTodo = TodoController();

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    dateController.text =
    '${_twoDigits(now.day)}/${_twoDigits(now.month)}/${now.year}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final XFile? image =
      await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissão de acesso às fotos negada'),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }



  // 🔥 COLOQUE AQUI
  void _saveTodo() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título é obrigatório')),
      );
      return;
    }

    final todo = TodoModel(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      date: DateTime.tryParse(
        dateController.text.split('/').reversed.join('-'),
      ),
      imagePath: selectedImage?.path, // 👈 FOTO (se existir)
    );

    // ✅ USA O CONTROLLER GLOBAL
    context.read<TodoController>().addTodo(todo);

    Navigator.pop(context);
  }
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueFigma,

      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // 👈 garante topo
              children: [
                const SizedBox(height: 12), // espaço do topo
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    // TITLE
                    SizedBox(
                      width: 327,
                      height: 48,
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Title',
            
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            
                    const SizedBox(height: 16),
            
                    // DESCRIPTION
                    SizedBox(
                      width: 327,
                      height: 300,
                      child: TextField(
                        controller: descriptionController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Description',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:AppColors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            
                    const SizedBox(height: 16),

                    // DATE
                    Container(
                      width: 327,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: dateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          DateInputFormatter(),
                        ],
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'DD/MM/YYYY',
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              'assets/images/calendar.svg',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

// IMAGE
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: 327,
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedImage == null ? 'Add image' : 'Image selected',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: selectedImage == null
                                  ? SvgPicture.asset(
                                'assets/images/image.svg',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              )
                                  : const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                    const SizedBox(height: 24),
            
                    // BUTTON
                    SizedBox(
                      width: 327,
                      height: 48,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _saveTodo,
                          child: const Center(
                            child: Text(
                              'ADD TODO',
                              style: AppTextStyles.ButtonSing,
                            ),
                          ),
                        ),
                      ),
                    ),
            
                  ],
                )
            
              ],
            ),
          ),
        ),
      ),

    );
  }
  }
