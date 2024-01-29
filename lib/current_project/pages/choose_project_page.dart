import 'package:flukki/core/brain/flukki_brain_controller.dart';
import 'package:flukki/current_project/controllers/current_project_controller.dart';
import 'package:flutter/material.dart';

class ChooseProjectPage extends StatelessWidget {
  final descriptionTextController = TextEditingController();
  final nameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                child: Image.asset('assets/logo.webp'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Generate app',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                        controller: nameTextController,
                        decoration: InputDecoration(
                          hintText: 'Name',
                          hintStyle: Theme.of(context).textTheme.bodyText2,
                        )),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: descriptionTextController,
                      decoration: InputDecoration(
                        hintText: 'Describe your app',
                        hintStyle: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    height: 54,
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () => flukkiBrainController.generateProject(
                        nameTextController.text,
                        descriptionTextController.text,
                      ),
                      child: Text('Generate'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 32),
                child: Text(
                  'or choose an existing Flutter project',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 54,
                width: 200,
                child: ElevatedButton(
                  onPressed: () => currentProjectController.chooseProject(),
                  child: Text('Choose project'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
