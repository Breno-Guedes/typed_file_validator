# typed_file_validator

`typed_file_validator` é uma biblioteca Dart 3 sem dependências externas para validar uploads pela assinatura binária do conteúdo. O pacote detecta arquivos JPEG, PNG e PDF por magic bytes, sem confiar no nome fornecido pelo usuário ou no cabeçalho MIME da requisição.

## Por que usar

Extensões e cabeçalhos de requisição podem ser falsificados. A biblioteca inspeciona o início do conteúdo e compara os bytes com assinaturas conhecidas. A inspeção usa um buffer limitado, portanto não carrega o arquivo inteiro na memória.

O pacote pode ser usado com Dart Frog, Shelf, Serverpod, Flutter e aplicações de linha de comando. Não há dependências de runtime além do SDK do Dart.

## Instalação

Adicione o pacote ao `pubspec.yaml`:

```yaml
dependencies:
  typed_file_validator: ^0.1.0-beta.1
```

Depois execute `dart pub get`.

## Uso rápido

```dart
import 'dart:typed_data';
import 'package:typed_file_validator/typed_file_validator.dart';

Future<void> main() async {
  final validator = FileValidator()
      .allow([FileType.jpeg, FileType.png])
      .maxSizeInMB(10)
      .checkExtensionSpoofing(true);

  final result = await validator.validateBytes(
    Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
    fileName: 'avatar.png',
  );

  switch (result) {
    case ValidFile(:final fileType, :final size):
      print('Aceito ${fileType.mimeType}; $size bytes.');
    case InvalidFile(:final error):
      print('Rejeitado: ${error.message}');
  }
}
```

## Fontes

`MemoryBinarySource` valida uma `Uint8List`, `FileBinarySource` lê o cabeçalho de um arquivo `dart:io`, e `StreamBinarySource` lê somente o cabeçalho limitado de um stream. Todas as fontes implementam `BinarySource`, permitindo que a aplicação forneça sua própria abstração.

```dart
final result = await FileValidator().validate(
  FileBinarySource(File('/tmp/upload.pdf')),
  fileName: 'upload.pdf',
);

final streamResult = await FileValidator().validateStream(
  request,
  fileName: 'upload.pdf',
);
```

Para streams, o tamanho não é conhecido quando a aplicação não o fornece por uma fonte customizada. Nesse caso, o resultado do stream informa o tamanho do cabeçalho inspecionado. Quando o tamanho não está disponível, aplique os limites de requisição ou `Content-Length` na borda HTTP.

## Tipos suportados

| Tipo | Extensões | Tipo MIME | Assinatura |
|---|---|---|---|
| JPEG | `.jpg`, `.jpeg` | `image/jpeg` | `FF D8 FF` |
| PNG | `.png` | `image/png` | `89 50 4E 47 0D 0A 1A 0A` |
| PDF | `.pdf` | `application/pdf` | `%PDF-` |

## Resultados e erros

Uma validação bem-sucedida retorna `ValidFile`, com o `FileType` detectado e o tamanho conhecido. Uma falha retorna `InvalidFile` contendo `FileTooLargeError`, `ExtensionSpoofingError`, `UnrecognizedFileType`, `DisallowedFileType` ou `FileReadError`.

## Observações de segurança

A validação por magic bytes identifica o formato indicado pelo início do arquivo; ela não substitui um parser completo nem um scanner de malware. Continue aplicando autenticação, autorização, isolamento de armazenamento, quotas, antivírus e políticas seguras de `Content-Disposition` conforme necessário.

## Desenvolvimento

Execute os comandos a seguir na raiz do pacote:

```text
dart pub get
dart format .
dart analyze
dart test
```

## Licença

Este pacote é distribuído sob a licença MIT. Consulte [LICENSE](LICENSE).
