import 'dart:io';

import 'package:dart_openai/dart_openai.dart';

import '../../../ai/models/find_helpers_models.dart';
import '../../../ai/models/mocking_analyse_model.dart';
import '../../../ai/models/model_creation_models.dart';
import '../../../core/utils/di_utils.dart';
import '../../core/current_project/current_project_controller.dart';
import '../models/determine_models_models.dart';
import '../models/generate_tests_models.dart';

TestsAIController get testsAIController =>
    handleDependency(() => TestsAIController());

class TestsAIController {
  Future<GenerateTestsResponse> generateTests(
      GenerateTestsRequest request) async {
    String finalContent = '';
    int usedTokens = 0;
    int numberOfLines = 100;
    Future<void> write() async {
      final response = await OpenAI.instance.chat.create(
          model: 'gpt-4-1106-preview',
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Wciel się w rolę programu, który generuje testy automatyczne w projekcie Flutter. Jesteś teraz na generowania testów dla przekazanego pliku.'),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content: 'Stosuj się do zasad stosowanych w projekcie '),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Plik do przetestowania: ${request.testedFileContent}'),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Niech odpowiedź będzie tak dokładna i szczególowa jak to możliwe, bez zbędnego skracania'),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Zwrócony plik powinien się poprawnie kompilować, sprawdzaj to'),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Cały plik zostanie zwrócony w kilku odpowiedziach, więc na razy wysyłaj maksymalnie $numberOfLines linijek kodu. Nie skracaj go w żaden sposób.'),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Instrukcja mockowania w projekcie: ${request.mockingSteps}'),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Pamiętaj, że nie wsztstji trzeba mockować na siłe, paczki takie jak Dio, czy SharedPreferences nie wymagają mockowania klasycznym sposobem, tylko mają swoje mechanizmy, korzystaj z nich'),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Modele jakie są wykorzystywane w tym pliku, opieraj się na nich tworząc nowe obiekty modeli danych: ${request.models.fold('', (previousValue, element) => '$previousValue\n$element')}'),
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Różne utilsy pomagające w testach:: ${request.utilsStructure}'),
            if (finalContent.isEmpty)
              OpenAIChatCompletionChoiceMessageModel(
                  role: OpenAIChatMessageRole.system,
                  content:
                      'Jeszcze nie wygenerowałeś żadnego kodu, wygeneruj teraz pierwsze $numberOfLines linijek kodu'),
            if (finalContent.isNotEmpty)
              OpenAIChatCompletionChoiceMessageModel(
                  role: OpenAIChatMessageRole.system,
                  content:
                      'Ten kod już wygenerowałeś, w odpowiedzi zwróć jedynie następne linijki kodu. To co już wygenerowałeś:\n$finalContent'),
          ],
          functions: [
            OpenAIFunctionModel.withParameters(
              name: 'generateTests',
              description:
                  'Generate tests for the provided file sticking to the project rules',
              parameters: [
                OpenAIFunctionProperty.string(
                  name: 'content',
                  description:
                      'Content of the new test file. Next $numberOfLines lines of file content, it should continue the content of previous response and not include code from previous message',
                  isRequired: true,
                ),
                OpenAIFunctionProperty.boolean(
                  name: 'isWholeFileReturned',
                  description:
                      "Indicates if content returned in current function call returns the rest of the file. False when still not whole file was returned, true if whole file is returned",
                  isRequired: true,
                ),
              ],
            )
          ],
          functionCall: FunctionCall.forFunction('generateTests'));
      // messages.add(response.choices.first.message);
      usedTokens += response.usage.totalTokens;

      final newContent = response
          .choices.first.message.functionCall!.arguments!['content']
          .toString()
          .trim();
      if (finalContent.split('\n').last.isNotEmpty &&
          !newContent.startsWith('\n')) {
        finalContent += '\n';
      }
      finalContent += newContent;

      final isWholeFileReturned = response.choices.first.message.functionCall!
          .arguments!['isWholeFileReturned'];
      if (!isWholeFileReturned) {
        await write();
      }
    }

    await write();

    return GenerateTestsResponse(
      newTestFileContent: finalContent,
      usedTokens: usedTokens,
    );
  }

  //todo: find helpers
  //todo: mocking steps
  //todo: model creation steps
  //todo: write tests
  //todo:
  Future<MockingAnalyseResponse> _getMockingSteps(
      MockingAnalyseRequest request) async {
    final response = await OpenAI.instance.chat.create(
        model: 'gpt-4-1106-preview',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wciel się w rolę programu, który generuje testy automatyczne w projekcie Flutter. Jesteś teraz na etapie analizy projektu - uczysz się jak wygląda mockowanie w testach jednostkowych, aby stworzyć z tego instrukcję, na której można się opierać pisząc później testy.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wskaż plik, do którego warto zajrzeć, aby się tego dowiedzieć. Nie wskazuj pliku, jeśli jest przekazany plik i jesteś w stanie napisać instrukcję mockowania na jego podstawie.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: 'Struktura projektu: ${request.projectStructure}'),
          if (request.fileContent != null)
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Przeanalizuj ten plik i oceń czy jest tutaj zastosowane mockowanie. Jeśli tak, to zwróć opis tego w jaki sposób mockować wraz przykładem, na którym będzie się można opierać pisząc nowe testy: ${request.fileContent}'),
          if (request.alreadyAnalyzedFiles.isNotEmpty)
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Nie wskazuj tych plików: : ${request.alreadyAnalyzedFiles}'),
        ],
        functions: [
          OpenAIFunctionModel.withParameters(
            name: 'getMockingSteps',
            description:
                'Find how mocking in tests is done in the provided project.',
            parameters: [
              OpenAIFunctionProperty.string(
                name: 'path',
                description:
                    'Next file to be analyzed, null if mocking instruction was found',
                isRequired: false,
              ),
              if (request.fileContent != null) ...[
                OpenAIFunctionProperty.boolean(
                  name: 'isMockingFound',
                  description: 'Indicates if mocking way was found in analy',
                  isRequired: true,
                ),
                OpenAIFunctionProperty.string(
                  name: 'mockingSteps',
                  description:
                      'Description with example how mocking is done in this project',
                  isRequired: false,
                ),
              ]
            ],
          )
        ],
        functionCall: FunctionCall.forFunction('getMockingSteps'));

    final result = response.choices.first.message.functionCall?.arguments;
    return MockingAnalyseResponse.fromJson(
      result!,
      usedTokens: response.usage.totalTokens,
    );
  }

  Future<ModelCreationResponse> getModelCreationSteps(
      ModelCreationRequest request) async {
    final response = await OpenAI.instance.chat.create(
        model: 'gpt-4-1106-preview',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wciel się w rolę programu, który generuje testy automatyczne w projekcie Flutter. Jesteś teraz na etapie analizy projektu - uczysz się jak wygląda tworzenie obiektów modeli na potrzeby testów, aby stworzyć z tego instrukcję, na której można się opierać pisząc później testy.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wskaż plik, do którego warto zajrzeć, aby się tego dowiedzieć. Nie wskazuj pliku, jeśli jest przekazany plik i jesteś w stanie napisać instrukcję tworzenia modeli na jego podstawie.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: 'Struktura projektu: ${request.projectStructure}'),
          if (request.fileContent != null)
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Przeanalizuj ten plik i oceń czy jest tutaj zastosowane tworzenie obiektów modeli. Jeśli tak, to zwróć opis tego w jaki sposób tworzyć modele wraz przykładem, na którym będzie się można opierać pisząc nowe testy: ${request.fileContent}'),
          if (request.alreadyAnalyzedFiles.isNotEmpty)
            OpenAIChatCompletionChoiceMessageModel(
                role: OpenAIChatMessageRole.system,
                content:
                    'Nie wskazuj tych plików: : ${request.alreadyAnalyzedFiles}'),
        ],
        functions: [
          OpenAIFunctionModel.withParameters(
            name: 'getModelCreationSteps',
            description:
                'Find how models are created in tests in the provided project.',
            parameters: [
              OpenAIFunctionProperty.string(
                name: 'path',
                description:
                    'Next file to be analyzed, null if model creation instruction was found',
                isRequired: false,
              ),
              if (request.fileContent != null) ...[
                OpenAIFunctionProperty.boolean(
                  name: 'isModelCreationFound',
                  description:
                      'Indicates if model creation way was found in analy',
                  isRequired: true,
                ),
                OpenAIFunctionProperty.string(
                  name: 'modelCreationSteps',
                  description:
                      'Description with example how models are created for tests in this project',
                  isRequired: false,
                ),
              ]
            ],
          )
        ],
        functionCall: FunctionCall.forFunction('getModelCreationSteps'));

    final result = response.choices.first.message.functionCall?.arguments;
    return ModelCreationResponse.fromJson(
      result!,
      usedTokens: response.usage.totalTokens,
    );
  }

  Future<FindHelpersResponse> findHelpers(FindHelpersRequest request) async {
    final response = await OpenAI.instance.chat.create(
        model: 'gpt-4-1106-preview',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wciel się w rolę programu, który generuje testy automatyczne w projekcie Flutter. Jesteś teraz na etapie analizy projektu - sprawdzasz czy projekt posiada jakieś pomocnicze utilsy dla testów.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Przeanalizuj strukturę i wskaż pliki, które mogą być takimi plikami'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: 'Struktura projektu: ${request.projectStructure}'),
        ],
        functions: [
          OpenAIFunctionModel.withParameters(
            name: 'findHelperFiles',
            description:
                'fnind files that can be helpers for tests in the provided project.',
            parameters: [
              OpenAIFunctionProperty.array(
                name: 'paths',
                description:
                    'path of test utils files, null if no files were found',
                isRequired: false,
                items: OpenAIFunctionProperty.string(
                    name: 'path',
                    isRequired: true,
                    description: 'path of test utils file'),
              ),
            ],
          )
        ],
        functionCall: FunctionCall.forFunction('findHelperFiles'));

    final result = response.choices.first.message.functionCall?.arguments;
    return FindHelpersResponse.fromJson(
      result!,
      usedTokens: response.usage.totalTokens,
    );
  }

  Future<MockingAnalyseResponse> findMocking(
      MockingAnalyseRequest request) async {
    List<String> analyzed = [];

    while (true) {
      final response = await _getMockingSteps(request);
      if (!response.isMockingFound) {
        analyzed.add(response.path!);
        final file =
            File(currentProjectController.currentProjectPath! + response.path!);
        final content = await file.readAsString();
        request = MockingAnalyseRequest(
          fileContent: content,
          alreadyAnalyzedFiles: analyzed,
          projectStructure: request.projectStructure,
        );
      } else {
        return response;
      }
    }
  }

  Future<DetermineModelsResponse> determineModels(
      DetermineModelsRequest model) async {
    final response = await OpenAI.instance.chat.create(
        model: 'gpt-4-1106-preview',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wciel się w rolę programu, który rozwiązuje zadania programistyczne w projektach flutter. Twoim aktualnym zadaniem jest wskazanie ścieżek do plików, które opisują modele danych wykorzystywane w przekazanym pliku. Wskazane pliki z modelami danych posłużą później do tworzenia modeli przy pisaniu testów jednostkowych przekazanego pliku'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Zwracaj zawsze cały path pliku, oto lista plików w projekcie: ${model.filesInProject}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: 'Oto plik:\n${model.fileContent}'),
        ],
        functions: [
          OpenAIFunctionModel.withParameters(
            name: 'determineModels',
            description:
                'Determine models used in file that will be required to unit test provided file',
            parameters: [
              OpenAIFunctionProperty.array(
                name: 'paths',
                description: 'Paths to files that describe models used in file',
                isRequired: true,
                items: OpenAIFunctionProperty.string(
                  name: 'path',
                  description: 'Path to file that describes model',
                  isRequired: true,
                ),
              )
            ],
          )
        ],
        functionCall: FunctionCall.forFunction('determineModels'));

    final result = response.choices.first.message.functionCall?.arguments;
    return DetermineModelsResponse.fromJson(
      result!,
      usedTokens: response.usage.totalTokens,
    );
  }
}
