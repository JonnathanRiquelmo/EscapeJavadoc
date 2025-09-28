# Importa o módulo Pester, se ainda não estiver carregado
if (-not (Get-Module -Name Pester -ErrorAction SilentlyContinue)) {
    try {
        Import-Module Pester -PassThru
    }
    catch {
        Write-Error "Pester não está instalado ou não pôde ser importado. Por favor, instale com: Install-Module -Name Pester -Force"
        return
    }
}

# Define os caminhos principais
$scriptFile = Resolve-Path (Join-Path $PSScriptRoot "..\src\EscapeJavadoc.ps1")
$sourceTestFilesDir = Join-Path $PSScriptRoot "arquivos-para-teste"
$tempTestDir = Join-Path $PSScriptRoot "temp-test-area"

# LÊ O SCRIPT UMA VEZ, ESPECIFICANDO A CODIFICAÇÃO, E O REUTILIZA
$scriptContent = Get-Content $scriptFile -Raw -Encoding UTF8
$scriptBlock = [scriptblock]::Create($scriptContent)

Describe "Testes do Script EscapeJavadoc.ps1" -Tags 'UnicodeConversion' {

    BeforeAll {
        if (Test-Path $tempTestDir) {
            Remove-Item -Recurse -Force $tempTestDir
        }
        Copy-Item -Path $sourceTestFilesDir -Destination $tempTestDir -Recurse
    }

    AfterAll {
        if (Test-Path $tempTestDir) {
            Remove-Item -Recurse -Force $tempTestDir
        }
    }

    Context "Modo Escape" {
        It "Deve converter caracteres acentuados em um único arquivo" {
            $testFile = Join-Path $tempTestDir "Calculadora copy 1.java"
            
            & $scriptBlock -Path $testFile -Mode Escape -Force

            $content = Get-Content $testFile -Raw
        $content | Should Match 'opera\\u00e7\\u00f5es aritm\\u00e9ticas b\\u00e1sicas'
        $content | Should Not Match 'operações aritméticas básicas'
        }

        It "Deve converter arquivos em um diretório (não recursivo)" {
            $testDir = Join-Path $tempTestDir "diretorio"
            $testFileDir = Join-Path $testDir "Calculadora copy 4.java"
            $testFileSubDir = Join-Path $testDir "subdiretorio\Calculadora copy 8.java"

            & $scriptBlock -Path $testDir -Mode Escape -Force

            $contentDir = Get-Content $testFileDir -Raw
            $contentDir | Should Match 'opera\\u00e7\\u00f5es aritm\\u00e9ticas b\\u00e1sicas'

            $contentSubDir = Get-Content $testFileSubDir -Raw
            $contentSubDir | Should Not Match 'opera\\u00e7\\u00f5es aritm\\u00e9ticas b\\u00e1sicas'
            $contentSubDir | Should Match 'operações aritméticas básicas'
        }

        It "Deve converter arquivos recursivamente" {
            $testDir = Join-Path $tempTestDir "diretorio"
            $testFile = Join-Path $testDir "subdiretorio\Calculadora copy 9.java"

            & $scriptBlock -Path $testDir -Mode Escape -Force -Recurse

            $content = Get-Content $testFile -Raw
            $content | Should Match 'n\\u00fameros inteiros'
            $content | Should Not Match 'números inteiros'
         }
    }

    Context "Modo Unescape" {
        It "Deve reverter um arquivo para caracteres acentuados" {
            $testFile = Join-Path $tempTestDir "Calculadora copy 2.java"

            # Primeiro converte para escape
            & $scriptBlock -Path $testFile -Mode Escape -Force
            $escapedContent = Get-Content $testFile -Raw
            $escapedContent | Should Match 'soma de dois n\\u00fameros'

            # Depois reverte para unescape
            & $scriptBlock -Path $testFile -Mode Unescape -Force

            $unescapedContent = Get-Content $testFile -Raw
            $unescapedContent | Should Match 'soma de dois números'
            $unescapedContent | Should Not Match '\\u00fameros'
        }
    }

    Context "Segurança e Casos de Borda" {
        It "NÃO deve modificar arquivos no modo de simulação (sem -Force)" {
            $testFile = Join-Path $tempTestDir "Calculadora copy 3.java"
            $originalContent = Get-Content $testFile -Raw

            & $scriptBlock -Path $testFile -Mode Escape

            $contentAfterRun = Get-Content $testFile -Raw
            $contentAfterRun | Should Be $originalContent
        }

        It "NÃO deve modificar strings de código fora dos comentários" {
            $testFile = Join-Path $tempTestDir "diretorio\subdiretorio\Calculadora copy 10.java"
            $codeWithAccent = @"
public class Test { 
    String s = "olá mundo"; 
    // Este é um comentário com acentuação
}
"@
            Set-Content -Path $testFile -Value $codeWithAccent

            & $scriptBlock -Path $testFile -Mode Escape -Force

            $content = Get-Content $testFile -Raw
            $content | Should Match '"olá mundo"'
            $content | Should Match 'acentua\\u00e7\\u00e3o'
        }
    }
}