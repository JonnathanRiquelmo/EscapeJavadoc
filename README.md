# EscapeJavadoc.ps1

[Jump to English version](#english-version)

## 🚀 Visão Geral

Este script PowerShell (`EscapeJavadoc.ps1`) foi desenvolvido para automatizar a conversão de caracteres acentuados e especiais em comentários (Javadoc, de bloco e de linha) dentro de arquivos `.java` para suas respectivas sequências de escape Unicode (`\uXXXX`) e vice-versa. Isso é particularmente útil em ambientes de desenvolvimento onde a codificação de caracteres pode causar problemas de compatibilidade ou exibição incorreta em ferramentas que não suportam UTF-8 nativamente para Javadoc, como algumas versões antigas do Javadoc ou sistemas de CI/CD.

## ✨ Funcionalidades

- **Escape de Caracteres**: Converte caracteres acentuados (ex: `á`, `é`, `ç`) para suas sequências de escape Unicode (ex: `\u00e1`, `\u00e9`, `\u00e7`).
- **Unescape de Caracteres**: Reverte as sequências de escape Unicode de volta para os caracteres acentuados originais.
- **Processamento Seletivo**: Atua apenas em comentários Javadoc (`/** ... */`), comentários de bloco (`/* ... */`) e comentários de linha (`// ...`), ignorando strings de código e outras partes do arquivo.
- **Modo de Simulação**: Permite executar o script sem aplicar as mudanças, mostrando quais arquivos seriam modificados e quais alterações seriam feitas.
- **Processamento Recursivo**: Suporta o processamento de arquivos em diretórios e subdiretórios.

## ⚙️ Parâmetros

- **`-Path <string>`**: (Obrigatório) O caminho para o arquivo `.java` ou diretório a ser processado. Se for um diretório, todos os arquivos `.java` dentro dele (e subdiretórios, se `-Recurse` for usado) serão processados.
- **`-Mode <string>`**: (Obrigatório) Define o modo de operação do script. Os valores aceitos são:
    - `'Escape'`: Converte caracteres acentuados para sequências de escape Unicode.
    - `'Unescape'`: Converte sequências de escape Unicode de volta para caracteres acentuados.
- **`-Recurse`**: (Switch) Se presente, o script processará arquivos `.java` em todos os subdiretórios do caminho especificado.
- **`-Force`**: (Switch) Se presente, o script aplicará as mudanças diretamente nos arquivos. Sem este parâmetro, o script executará em modo de simulação, exibindo as modificações que seriam feitas sem salvar os arquivos.
- **`-Encoding <string>`**: (Opcional) A codificação dos arquivos. O padrão é `'UTF8'`. Pode ser útil especificar outras codificações se seus arquivos `.java` não estiverem em UTF-8. Exemplos de uso: `-Encoding UTF8`, `-Encoding Default`, `-Encoding ASCII`.

## 💡 Obtendo Ajuda

Para visualizar a documentação completa do script e seus parâmetros diretamente no terminal, você pode usar o comando `Get-Help` do PowerShell:

```powershell
Get-Help .\src\EscapeJavadoc.ps1 -Full
```

Ou, para uma ajuda rápida:

```powershell
.\src\EscapeJavadoc.ps1 -?
```

## 🧪 Exemplos de Uso

### 1. Escapar caracteres em um único arquivo (modo de simulação)

Este comando irá analisar o arquivo `MeuArquivo.java` e mostrar quais caracteres acentuados seriam convertidos para Unicode, mas não salvará as alterações.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste\Calculadora copy 1.java" -Mode Escape
```

### 2. Escapar caracteres em um único arquivo (aplicando as mudanças)

Este comando irá converter os caracteres acentuados no arquivo `MeuArquivo.java` para Unicode e salvar as alterações.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste\Calculadora copy 1.java" -Mode Escape -Force
```

### 3. Escapar caracteres em um diretório (não recursivo, modo de simulação)

Este comando irá analisar todos os arquivos `.java` no diretório `meu-projeto/src` e mostrar as conversões, mas não salvará as alterações.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste" -Mode Escape
```

### 4. Escapar caracteres em um diretório (recursivo, aplicando as mudanças)

Este comando irá converter os caracteres acentuados em todos os arquivos `.java` dentro do diretório `meu-projeto/src` e seus subdiretórios, salvando as alterações.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste" -Mode Escape -Recurse -Force
```

### 5. Reverter caracteres escapados em um único arquivo (aplicando as mudanças)

Este comando irá converter as sequências de escape Unicode de volta para caracteres acentuados no arquivo `MeuArquivo.java` e salvar as alterações.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste\Calculadora copy 1.java" -Mode Unescape -Force
```

### 6. Reverter caracteres escapados em um diretório (recursivo, modo de simulação)

Este comando irá analisar todos os arquivos `.java` no diretório `meu-projeto/src` e seus subdiretórios, mostrando as reversões de escape, mas não salvará as alterações.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste" -Mode Unescape -Recurse
```

## Execução dos Testes

Para executar os testes Pester que validam o funcionamento do script `EscapeJavadoc.ps1`, siga os passos abaixo:

1.  **Navegue até o diretório raiz do projeto:**
    ```powershell
    cd C:\Users\jonna\Documents\escape-unicode-javadoc
    ```

2.  **Execute os testes Pester:**
    ```powershell
    Invoke-Pester -Path ".\tests\EscapeJavadoc.Tests.ps1"
    ```

    Este comando irá executar todos os testes definidos no arquivo `Manage-JavadocUnicode.Tests.ps1`. Os resultados indicarão se o script está funcionando conforme o esperado, convertendo corretamente os caracteres Unicode em comentários Javadoc e lidando com os diferentes modos de operação (`Escape` e `Unescape`), recursividade e o parâmetro `-Force`.

### Testes Detalhados

Os seguintes testes são executados para garantir a funcionalidade e a robustez do script:

*   **Contexto: Modo Escape**
    *   **Deve converter caracteres acentuados em um único arquivo**: Verifica se o script consegue converter corretamente caracteres acentuados para suas representações Unicode em um único arquivo Java.
    *   **Deve converter arquivos em um diretório (não recursivo)**: Garante que o script processa todos os arquivos Java em um diretório especificado, sem entrar em subdiretórios.
    *   **Deve converter arquivos recursivamente**: Assegura que o script processa arquivos Java em um diretório e em todos os seus subdiretórios quando o parâmetro `-Recurse` é utilizado.

*   **Contexto: Modo Unescape**
    *   **Deve reverter um arquivo para caracteres acentuados**: Testa a capacidade do script de converter sequências Unicode de volta para caracteres acentuados originais em um arquivo Java.

*   **Contexto: Segurança e Casos de Borda**
    *   **NÃO deve modificar arquivos no modo de simulação (sem -Force)**: Confirma que o script não faz alterações permanentes nos arquivos quando o parâmetro `-Force` não é fornecido, operando em modo de simulação.
    *   **NÃO deve modificar strings de código fora dos comentários**: Verifica se o script modifica *apenas* os comentários Javadoc, de bloco e de linha, e não altera strings de código ou outras partes do código-fonte Java.

## Notas Importantes

- **Backup**: Sempre faça backup de seus arquivos antes de executar o script com o parâmetro `-Force`, especialmente em projetos grandes.
- **Codificação**: Certifique-se de que a codificação especificada (`-Encoding`) corresponda à codificação real dos seus arquivos `.java` para evitar problemas de leitura/escrita.
- **Comentários Apenas**: O script é projetado para modificar *apenas* o conteúdo de comentários. Ele não deve alterar strings de código ou outras partes do seu código-fonte.

## Requisitos

- PowerShell 5.1 ou superior (testado com PowerShell 7+).

<a name="english-version"></a>
# EscapeJavadoc.ps1

## 🚀 Overview

This PowerShell script (`EscapeJavadoc.ps1`) was developed to automate the conversion of accented and special characters in comments (Javadoc, block, and line comments) within `.java` files to their respective Unicode escape sequences (`\uXXXX`) and vice-versa. This is particularly useful in development environments where character encoding can cause compatibility issues or incorrect display in tools that do not natively support UTF-8 for Javadoc, such as some older versions of Javadoc or CI/CD systems.

## ✨ Features

- **Character Escaping**: Converts accented characters (e.g., `á`, `é`, `ç`) to their Unicode escape sequences (e.g., `\u00e1`, `\u00e9`, `\u00e7`).
- **Character Unescaping**: Reverts Unicode escape sequences back to the original accented characters.
- **Selective Processing**: Acts only on Javadoc comments (`/** ... */`), block comments (`/* ... */`), and line comments (`// ...`), ignoring code strings and other parts of the file.
- **Simulation Mode**: Allows running the script without applying changes, showing which files would be modified and what changes would be made.
- **Recursive Processing**: Supports processing files in directories and subdirectories.

## ⚙️ Parameters

- **`-Path <string>`**: (Mandatory) The path to the `.java` file or directory to be processed. If it's a directory, all `.java` files within it (and subdirectories, if `-Recurse` is used) will be processed.
- **`-Mode <string>`**: (Mandatory) Defines the script's operation mode. Accepted values are:
    - `'Escape'`: Converts accented characters to Unicode escape sequences.
    - `'Unescape'`: Converts Unicode escape sequences back to accented characters.
- **`-Recurse`**: (Switch) If present, the script will process `.java` files in all subdirectories of the specified path.
- **`-Force`**: (Switch) If present, the script will apply changes directly to the files. Without this parameter, the script will run in simulation mode, displaying the modifications that would be made without saving the files.
- **`-Encoding <string>`**: (Optional) The file encoding. The default is `'UTF8'`. It may be useful to specify other encodings if your `.java` files are not in UTF-8. Usage examples: `-Encoding UTF8`, `-Encoding Default`, `-Encoding ASCII`.

## 💡 Getting Help

To view the full documentation of the script and its parameters directly in the terminal, you can use the PowerShell `Get-Help` command:

```powershell
Get-Help .\src\EscapeJavadoc.ps1 -Full
```

Or, for quick help:

```powershell
.\src\EscapeJavadoc.ps1 -?
```

## 🧪 Usage Examples

### 1. Escape characters in a single file (simulation mode)

This command will analyze the `MyFile.java` file and show which accented characters would be converted to Unicode, but will not save the changes.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste\Calculadora copy 1.java" -Mode Escape
```

### 2. Escape characters in a single file (applying changes)

This command will convert the accented characters in the `MyFile.java` file to Unicode and save the changes.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste\Calculadora copy 1.java" -Mode Escape -Force
```

### 3. Escape characters in a directory (non-recursive, simulation mode)

This command will analyze all `.java` files in the `my-project/src` directory and show the conversions, but will not save the changes.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste" -Mode Escape
```

### 4. Escape characters in a directory (recursive, applying changes)

This command will convert the accented characters in all `.java` files within the `my-project/src` directory and its subdirectories, saving the changes.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste" -Mode Escape -Recurse -Force
```

### 5. Revert escaped characters in a single file (applying changes)

This command will convert Unicode escape sequences back to accented characters in the `MyFile.java` file and save the changes.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste\Calculadora copy 1.java" -Mode Unescape -Force
```

### 6. Revert escaped characters in a directory (recursive, simulation mode)

This command will analyze all `.java` files in the `my-project/src` directory and its subdirectories, showing the escape reversals, but will not save the changes.

```powershell
.\src\EscapeJavadoc.ps1 -Path ".\tests\arquivos-para-teste" -Mode Unescape -Recurse
```

## Running Tests

To run the Pester tests that validate the functionality of the `EscapeJavadoc.ps1` script, follow the steps below:

1.  **Navigate to the project root directory:**
    ```powershell
    cd C:\Users\jonna\Documents\escape-unicode-javadoc
    ```

2.  **Execute Pester tests:**
    ```powershell
    Invoke-Pester -Path ".\tests\EscapeJavadoc.Tests.ps1"
    ```

    This command will execute all tests defined in the `EscapeJavadoc.Tests.ps1` file. The results will indicate whether the script is working as expected, correctly converting Unicode characters in Javadoc comments and handling different operation modes (`Escape` and `Unescape`), recursion, and the `-Force` parameter.

### Detailed Tests

The following tests are executed to ensure the functionality and robustness of the script:

*   **Context: Escape Mode**
    *   **Should convert accented characters in a single file**: Verifies that the script can correctly convert accented characters to their Unicode representations in a single Java file.
    *   **Should convert files in a directory (non-recursive)**: Ensures that the script processes all Java files in a specified directory, without entering subdirectories.
    *   **Should convert files recursively**: Ensures that the script processes Java files in a directory and all its subdirectories when the `-Recurse` parameter is used.

*   **Context: Unescape Mode**
    *   **Should revert a file to accented characters**: Tests the script's ability to convert Unicode sequences back to original accented characters in a Java file.

*   **Context: Security and Edge Cases**
    *   **Should NOT modify files in simulation mode (without -Force)**: Confirms that the script does not make permanent changes to files when the `-Force` parameter is not provided, operating in simulation mode.
    *   **Should NOT modify code strings outside comments**: Verifies that the script modifies *only* Javadoc, block, and line comments, and does not alter code strings or other parts of the Java source code.

## Important Notes

- **Backup**: Always back up your files before running the script with the `-Force` parameter, especially in large projects.
- **Encoding**: Ensure that the specified encoding (`-Encoding`) matches the actual encoding of your `.java` files to avoid read/write issues.
- **Comments Only**: The script is designed to modify *only* the content of comments. It should not alter code strings or other parts of your source code.

## Requirements

- PowerShell 5.1 or higher (tested with PowerShell 7+).