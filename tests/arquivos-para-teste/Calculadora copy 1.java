/**
 * Esta classe representa uma calculadora simples que realiza operações aritméticas básicas.
 * Ela é utilizada para demonstrar a funcionalidade de escape e unescape de caracteres Unicode
 * em comentários Javadoc, contendo caracteres acentuados como 'á', 'é', 'í', 'ó', 'ú', 'ã', 'õ',
 * 'â', 'ê', 'ô', 'à', 'ç' e 'ü'.
 */
public class Calculadora {

    /**
     * Realiza a soma de dois números inteiros.
     * @param a O primeiro número inteiro.
     * @param b O segundo número inteiro.
     * @return A soma dos dois números.
     */
    public int soma(int a, int b) {
        return a + b;
    }

    /**
     * Realiza a subtração de dois números inteiros.
     * @param a O primeiro número inteiro (minuendo).
     * @param b O segundo número inteiro (subtraendo).
     * @return A diferença entre os dois números.
     */
    public int subtrai(int a, int b) {
        return a - b;
    }

    /**
     * Realiza a multiplicação de dois números inteiros.
     * @param a O primeiro número inteiro.
     * @param b O segundo número inteiro.
     * @return O produto dos dois números.
     */
    public int multiplica(int a, int b) {
        return a * b;
    }

    /**
     * Realiza a divisão de dois números inteiros.
     * @param a O primeiro número inteiro (dividendo).
     * @param b O segundo número inteiro (divisor). Não pode ser zero.
     * @return O quociente da divisão.
     * @throws IllegalArgumentException Se o divisor for zero.
     */
    public double divide(int a, int b) {
        if (b == 0) {
            throw new IllegalArgumentException("Divisor não pode ser zero.");
        }
        return (double) a / b;
    }
}
