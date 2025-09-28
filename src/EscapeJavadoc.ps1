
<#
.SYNOPSIS
    EscapeJavadoc: Converte caracteres especiais em comentários de arquivos .java para/de sequências de escape Unicode.
.DESCRIPTION
    Este script processa arquivos .java para encontrar todos os tipos de comentários (Javadoc, bloco, linha)
    e converte caracteres acentuados/especiais para suas representações de escape Unicode ou faz o processo inverso.

.EXAMPLE
    # Escapa caracteres Unicode em um único arquivo .java e aplica as mudanças
    .\EscapeJavadoc.ps1 -Path "C:\caminho\para\MeuArquivo.java" -Mode Escape -Force

    # Reverte caracteres Unicode escapados em um único arquivo .java e aplica as mudanças
    .\EscapeJavadoc.ps1 -Path "C:\caminho\para\MeuArquivo.java" -Mode Unescape -Force

    # Escapa caracteres Unicode em todos os arquivos .java em um diretório (não recursivo)
    .\EscapeJavadoc.ps1 -Path "C:\caminho\para\meu\diretorio" -Mode Escape -Force

    # Escapa caracteres Unicode em todos os arquivos .java em um diretório e seus subdiretórios (recursivo)
    .\EscapeJavadoc.ps1 -Path "C:\caminho\para\meu\diretorio" -Recurse -Mode Escape -Force

    # Executa uma simulação de escape em um arquivo .java (não aplica as mudanças)
    .\EscapeJavadoc.ps1 -Path "C:\caminho\para\MeuArquivo.java" -Mode Escape

    # Escapa caracteres Unicode em um arquivo .java com uma codificação específica
    .\EscapeJavadoc.ps1 -Path "C:\caminho\para\MeuArquivo.java" -Mode Escape -Encoding UTF8 -Force

.NOTES
    Este script é projetado para auxiliar desenvolvedores Java que trabalham com sistemas legados ou que precisam garantir a compatibilidade de caracteres em ambientes com diferentes codificações. Ele foca especificamente em comentários Javadoc, de bloco e de linha, ignorando strings de código para evitar a introdução de erros de compilação ou de lógica.

    É altamente recomendável fazer backup dos arquivos antes de aplicar as mudanças com o parâmetro -Force.

.LINK
    https://github.com/jonna-dev/escape-unicode-javadoc
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Caminho para o arquivo .java ou diretório a ser processado.")]
    [string]$Path,
    [Parameter(HelpMessage = "Processa o diretório de forma recursiva.")]
    [switch]$Recurse,
    [Parameter(Mandatory = $true, HelpMessage = "Define o modo de operação: 'Escape' ou 'Unescape'.")]
    [ValidateSet('Escape', 'Unescape')]
    [string]$Mode,
    [Parameter(HelpMessage = "Codificação dos arquivos. Padrão: UTF8.")]
    [string]$Encoding = 'UTF8',
    [Parameter(HelpMessage = "Aplica as mudanças nos arquivos. Sem este parâmetro, executa em modo simulação.")]
    [switch]$Force
)

begin {
    Write-Verbose "Iniciando a execução do script no modo '$Mode'."
    $filesProcessed = 0
    $filesModified = 0

    # Mapeamento de caracteres para sequências de escape Unicode
    $escapeMap = @{}
    $escapeMap[[char]0x00e1] = '\u00e1'  # á
    $escapeMap[[char]0x00c1] = '\u00c1'  # Á
    $escapeMap[[char]0x00e9] = '\u00e9'  # é
    $escapeMap[[char]0x00c9] = '\u00c9'  # É
    $escapeMap[[char]0x00ed] = '\u00ed'  # í
    $escapeMap[[char]0x00cd] = '\u00cd'  # Í
    $escapeMap[[char]0x00f3] = '\u00f3'  # ó
    $escapeMap[[char]0x00d3] = '\u00d3'  # Ó
    $escapeMap[[char]0x00fa] = '\u00fa'  # ú
    $escapeMap[[char]0x00da] = '\u00da'  # Ú
    $escapeMap[[char]0x00e3] = '\u00e3'  # ã
    $escapeMap[[char]0x00c3] = '\u00c3'  # Ã
    $escapeMap[[char]0x00f5] = '\u00f5'  # õ
    $escapeMap[[char]0x00d5] = '\u00d5'  # Õ
    $escapeMap[[char]0x00e2] = '\u00e2'  # â
    $escapeMap[[char]0x00c2] = '\u00c2'  # Â
    $escapeMap[[char]0x00ea] = '\u00ea'  # ê
    $escapeMap[[char]0x00ca] = '\u00ca'  # Ê
    $escapeMap[[char]0x00f4] = '\u00f4'  # ô
    $escapeMap[[char]0x00d4] = '\u00d4'  # Ô
    $escapeMap[[char]0x00e7] = '\u00e7'  # ç
    $escapeMap[[char]0x00c7] = '\u00c7'  # Ç
    $escapeMap[[char]0x00e0] = '\u00e0'  # à
    $escapeMap[[char]0x00c0] = '\u00c0'  # À
    $escapeMap[[char]0x00f2] = '\u00f2'  # ò
    $escapeMap[[char]0x00d2] = '\u00d2'  # Ò
    $escapeMap[[char]0x00fc] = '\u00fc'  # ü
    $escapeMap[[char]0x00dc] = '\u00dc'  # Ü
    $escapeMap[[char]0x00ef] = '\u00ef'  # ï
    $escapeMap[[char]0x00cf] = '\u00cf'  # Ï

    # Regex para capturar comentários Javadoc, de bloco e de linha
    $commentRegex = '(?<JavadocComment>/\*\*[\s\S]*?\*/)|(?<BlockComment>/\*[\s\S]*?\*/)|(?<LineComment>//.*)'
}

process {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "O caminho especificado não foi encontrado: '$Path'"
    }

    $filesToProcess = @()
    if (Test-Path -LiteralPath $Path -PathType Container) {
        $getFilesParams = @{
            Path = $Path
            Filter = '*.java'
            File = $true
        }
        if ($Recurse) {
            $getFilesParams.Recurse = $true
        }
        $filesToProcess = Get-ChildItem @getFilesParams
    }
    else {
        if ($Path -like '*.java') {
            $filesToProcess += Get-Item -LiteralPath $Path
        }
    }

    if ($filesToProcess.Count -eq 0) {
        Write-Warning "Nenhum arquivo .java encontrado no caminho especificado."
        return
    }

    foreach ($file in $filesToProcess) {
        $filesProcessed++
        Write-Verbose "Analisando arquivo: $($file.FullName)" 
        
        try {
            $originalContent = Get-Content -Raw -LiteralPath $file.FullName -Encoding $Encoding
        }
        catch {
            Write-Error "Falha ao ler o arquivo $($file.FullName) com a codificação '$Encoding'. Erro: $_"
            continue
        }

        $matches = [regex]::Matches($originalContent, $commentRegex)
        $newContent = $originalContent
        $hasChanges = $false

        for ($i = $matches.Count - 1; $i -ge 0; $i--) {
            $match = $matches[$i]
            $originalComment = $match.Value
            $modifiedComment = ""

            if ($Mode -eq 'Escape') {
                $modifiedComment = $originalComment
                $escapeMap.GetEnumerator() | ForEach-Object {
                    $modifiedComment = $modifiedComment.Replace([string]$_.Key, $_.Value)
                }
            }
            else { 
                $modifiedComment = [regex]::Unescape($originalComment)
            }

            if ($originalComment -ne $modifiedComment) {
                $hasChanges = $true
                Write-Host "--- Modificação encontrada no arquivo $($file.FullName) ---" -ForegroundColor Yellow
                Write-Host "Original  : $originalComment"
                Write-Host "Modificado: $modifiedComment"
                Write-Host "--------------------------------------------------"

                $newContent = $newContent.Remove($match.Index, $match.Length).Insert($match.Index, $modifiedComment)
            }
        }

        if ($hasChanges) {
            if ($Force) {
                Write-Verbose "Modificações detectadas. Salvando arquivo: $($file.FullName)"
                try {
                    Set-Content -LiteralPath $file.FullName -Value $newContent -Encoding $Encoding -Force
                    $filesModified++
                }
                catch {
                    Write-Error "Falha ao salvar o arquivo $($file.FullName). Erro: $_"
                }
            }
            else {
                Write-Host "SIMULAÇÃO: Arquivo seria modificado: $($file.FullName)" -ForegroundColor Yellow
            }
        }
        else {
            Write-Verbose "Nenhuma alteração necessária para $($file.FullName)."
        }
    }
}

end {
    Write-Host "--------------------------------------------------"
    Write-Host "Processamento concluído."
    Write-Host "Arquivos processados: $filesProcessed"
    Write-Host "Arquivos modificados: $filesModified"
    if (-not $Force) {
        Write-Host "Use o parâmetro -Force para aplicar as mudanças."
    }
    Write-Host "--------------------------------------------------"
}
