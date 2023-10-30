import 'package:dart_openai/dart_openai.dart';

import '../../../ai/models/find_helpers_models.dart';
import '../../../ai/models/mocking_analyse_model.dart';
import '../../../ai/models/model_creation_models.dart';
import '../../../core/conrtollers_interfaces.dart';

TestAnalyseController get testAnalyseController =>
    handleDependency(() => TestAnalyseController());

class TestAnalyseController {
  //todo: find helpers
  //todo: mocking steps
  //todo: model creation steps
  //todo: write tests
  //todo:
  Future<MockingAnalyseResponse> getMockingSteps(
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
}
