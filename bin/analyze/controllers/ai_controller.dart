import 'package:dart_openai/dart_openai.dart';

import '../../ai/models/determine_models_models.dart';
import '../../ai/models/generate_tests_models.dart';
import '../../core/conrtollers_interfaces.dart';
import '../../server_core/base_models.dart';
import '../models/add_file.dart';
import '../models/modify_file.dart';
import '../models/split_task.dart';

AIController get aiController => handleDependency(() => AIController());

class AIController {
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

  Future<SplitTaskResult> splitTask(SplitTaskRequest splitTaskRequest) async {
    final response = await OpenAI.instance.chat.create(
        model: 'gpt-4-1106-preview',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wciel się w rolę programu, który rozwiązuje zadania programistyczne w projektach flutter. Pierwszym krokiem jest podzielenie przekazanego zadania na instrukcje, które dotyczą konkretnych plików. Podziel przekazane zadanie na mniejsze kroki, które dotyczą wyłącznie pojedynczych plików. W odpowiedzi podaj te pliki i opisz co powinno zostać tam zrobione. Jeśli trzeba będzie stworzyć plik to to zrób.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Zadbaj o to, aby odpowiedź brała pod uwagę zależności między plikami, tzn na przykład jeśli w jednym pliku tworzymy metodę, to inna klasa może ją wykorzystać aby wykonać zadanie. Zawsze umieszczaj informację o korzystaniu z kodu z innych plików w opisie zmiany.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Opis zmian konstruuj w taki sposób, aby każdy plik mógł zostać zmodyfikowany przez AI w oddzielnym kontekście bez dostępu do innych zmian.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Oto struktura projektu: ${splitTaskRequest.projectStructure}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Zależności z pubspec.yaml: ${splitTaskRequest.pubspecDependencies}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Architektura projektu: ${splitTaskRequest.architecture}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: 'Zadanie: ${splitTaskRequest.task}'),
        ],
        functions: [
          OpenAIFunctionModel.withParameters(
            name: 'getSmallerTasks',
            description:
                'Split task into smaller tasks that are related to single file',
            parameters: [
              OpenAIFunctionProperty.array(
                  name: 'flutterAddDependenciesCommands',
                  description:
                      'Commands that should be executed to add dependencies to pubspec.yaml',
                  isRequired: true,
                  items: OpenAIFunctionProperty.string(
                      name: 'flutterAddDependenciesCommand',
                      description:
                          'Command that should be executed to add dependency to pubspec.yaml',
                      isRequired: true)),
              OpenAIFunctionProperty.array(
                name: 'fileChangeDescriptions',
                description:
                    'Detailed descriptions of changes that should be made to files',
                isRequired: true,
                items: OpenAIFunctionProperty.object(
                    name: 'fileChangeDescription',
                    description:
                        'Detailed description of changes that should be made to file',
                    isRequired: true,
                    properties: [
                      OpenAIFunctionProperty.string(
                          name: 'path',
                          description: 'Path to file that should be changed',
                          isRequired: true),
                      OpenAIFunctionProperty.string(
                          name: 'changeDescriptions',
                          description:
                              'Description of changes that should be made to file',
                          isRequired: true),
                      OpenAIFunctionProperty.boolean(
                          name: 'isFileCreated',
                          description:
                              'Indicates if file should be created or modified',
                          isRequired: true),
                      OpenAIFunctionProperty.string(
                          name: 'similarFilePath',
                          description:
                              'Path to file that is similar to file that should be created. If file is modified then null',
                          isRequired: false),
                    ]),
              ),
            ],
          )
        ],
        functionCall: FunctionCall.forFunction('getSmallerTasks'));

    if (response.choices.first.message.functionCall?.arguments != null) {
      return SplitTaskResult.fromJson(
        response.choices.first.message.functionCall!.arguments!,
        usedTokens: response.usage.totalTokens,
      );
    } else {
      return SplitTaskResult.empty(usedTokens: response.usage.totalTokens);
    }
  }

  Future<SimpleResponse> modifyFile(ModifyFileRequest modifyFileRequest) async {
    String finalContent = '';
    int usedTokens = 0;
    int numberOfLines = 100;

    final messages = [
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content:
              'Wciel się w rolę senior flutter developera. Twoim zadaniem jest zmiana przekazanego pliku w taki sposób, aby zrealizować opis zmian i zapisywać plik po $numberOfLines linijek na jedno wywonie funkcji'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content:
              'Opis zmian to część czynności jakie trzeba wykonać w przekazanym pliku. Skup się wylącznie na tych zmianach'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content:
              'Dla lepszego kontekstu dostaniesz też ogólne zadanie, które ma zostać osiągnięte modyfikacjami w calym projekcie.'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content:
              'Opis wszystkich zmian w projekcie ma nadać Ci kontekst dlaczego modyfikujesz dany plik i z jakich innych zależności możesz korzystać.'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content:
              'Niech odpowiedź będzie tak dokładna i szczególowa jak to możliwe, bez zbędnego skracania'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content:
              'Cały plik zostanie zwrócony w kilku odpowiedziach, więc na razy wysyłaj maksymalnie $numberOfLines linijek kodu. Nie skracaj go w żaden sposób.'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: 'Ogólne zadanie: ${modifyFileRequest.task}'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: 'Opis zmian: ${modifyFileRequest.changeDescription}'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content:
              'Wszystkie zmiany jakie będą robione w projekcie: ${modifyFileRequest.allChangesDescriptions}'),
      OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content:
              'Spróbuj zmodyfikować ten plik: ${modifyFileRequest.content}'),
    ];

    Future<void> modify() async {
      final response = await OpenAI.instance.chat.create(
          model: 'gpt-4-1106-preview',
          messages: messages,
          functions: [
            OpenAIFunctionModel.withParameters(
              name: 'saveNewContent',
              description:
                  'Modified content of the file, max $numberOfLines lines',
              parameters: [
                OpenAIFunctionProperty.string(
                  name: 'content',
                  description:
                      'Next $numberOfLines lines of file content, it should continue the content of previous response',
                  isRequired: true,
                ),
                OpenAIFunctionProperty.boolean(
                    name: 'isWholeFileReturned',
                    description:
                        'Indicates if whole file was already returned in the conversation',
                    isRequired: true),
              ],
            ),
          ],
          functionCall: FunctionCall.forFunction('saveNewContent'));
      messages.add(response.choices.first.message);
      usedTokens = response.usage.totalTokens;

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
        await modify();
      }
    }

    await modify();

    return SimpleResponse(
      message: finalContent,
      usedTokens: usedTokens,
    );
  }

  Future<SimpleResponse> addFile(AddFileRequest addFileRequest) async {
    final response = await OpenAI.instance.chat.create(
        model: 'gpt-4-1106-preview',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wciel się w rolę programu, który rozwiązuje zadania programistyczne w projektach flutter.  Twoją odpowiedzialnością na tym etapie jest stworzenie nowego pliku w taki sposób, aby zrealizować przekazany opis.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Dostaniesz też pierwotne zadanie, które ma zostać osiągnięte. Opis określa jak powinien wyglądać nowo stworzony plik, aby zadanie mogło zostać wykonane. '),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Opis wszystkich zmian w projekcie ma nadać Ci kontekst dlaczego tworzysz dany plik.'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: 'Pierwotne zadanie: ${addFileRequest.task}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Opis nowego pliku: ${addFileRequest.newFileDescription}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Wszystkie opisy zmian w projekcie: ${addFileRequest.allChangesDescriptions}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Zależności z pubspec.yaml: ${addFileRequest.pubspecDependencies}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content:
                  'Ten plik powinien wyglądać podobnie do tego co tworzysz, możesz się na nim wzorować: ${addFileRequest.similarFile}'),
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user, content: 'Stwórz nowy plik'),
        ],
        functions: [
          OpenAIFunctionModel.withParameters(
            name: 'getNewFile',
            description:
                'Create new file in such a way that it will satisfy change description',
            parameters: [
              OpenAIFunctionProperty.string(
                name: 'newContent',
                description:
                    'Content of new file, not changed if no changes are needed. Always complete file content',
                isRequired: true,
              )
            ],
          )
        ],
        functionCall: FunctionCall.forFunction('getNewFile'));

    return SimpleResponse(
      message:
          response.choices.first.message.functionCall!.arguments!['newContent'],
      usedTokens: response.usage.totalTokens,
    );
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
