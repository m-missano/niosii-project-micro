/* PSEUDOCODIGO 

int main(){
    char addr_keyboard = "0x0000";
    char content_keyboard;
    char addr_membuff = "0x500";
    char content_membuff[1024];
    char input;

    content_keyboard = found_by_addr(addr_keyboard);
    content_membuff = found_by_addr(addr_membuff);

    // POLLING
    while(1){
        // Ignorar espaços
        char input = read_character();
        content_membuff.push(input)

        if(input == '\n'){
            parsing(content_membuff);
        }
    }
} 
*/

/*
 * r7 : caracter espaco em ASCI 0x20
 * r8  : addr de Data register
 * r9  : content de Data register
 * r10 : rvalid (bit de validacao de leitura)
 * r11 : content de Control register
 * r12 : wspace (espaco livre na FIFO de escrita)
 * r13 : mascara para obter o wspace (16 bits superiores de Control register)
 * r14 : addr de TERMINAL_MESSAGE
 * r15 : content de TERMINAL_MESSAGE
 * r16 : contador para o TERMINAL_MESSAGE_POLL
 * r17 : armazena o codigo ASCII de \n
 * r18 : addr de MEMBUFF
 * r19 : content de MEMBUFF
 * r20 : addr de MEMBUFF_LENGTH
 * r21 : content de MEMBUFF_LENGTH (qtd de bytes escritos e ainda nao lidos em MEMBUFF)
 * r22 : contador de MEMBUFF
 */

/*

   hex     |                    bin                           dec
0xFFFF0000 | 0b.1111.1111.1111.1111.0000.0000.0000.0000 | undefined
0x00008000 | 0b.0000.0000.0000.0000.1000.0000.0000.0000 | undefined
0x0000000A | 0b.0000.0000.0000.0000.0000.0000.0000.1010 |    10
*/

.equ ADDR_DATAREG, 0x10001000
.equ STACK, 0x1000000

.global _start
.global MEMBUFF

.text

_start:
    movia sp, STACK   /* armazena em sp o endereço da STACK */
    mov fp, sp        /* seta o frame pointer */
    # Armazena o endereco de Data register
    movia r8, ADDR_DATAREG
    # Armazena a mascara para a operacao de 32 bits
    movia r13, 0xFFFF0000
    # Armazena o endereco da mensagem a aparecer no terminal
    movia r14, TERMINAL_MESSAGE # TESTE
    # Armazena o codigo ASCII de \n
    movia r17, 0xA
    # Armazena o endereco de MEMBUFF
    movia r18, MEMBUFF
    # Armazena o endereco de MEMBUFF_LENGTH
    movia r20, MEMBUFF_LENGTH
    # Carrega conteudo de MEMBUFF
    addi r22,r18,0

    # Armazena o codigo ASCII de Space
    movia r7, 0x20 

# Polling
POLLING:

    add r16, r14, r0 # TESTE

    /*
    ! Vericar como melhor essa parte (outras abordagens melhores)
    ? Ler 4 bytes da mem e escrever 1 por 1 no terminal ?
    ? Possibilidade de criar subrotina para escrita (evitar repeticao) ?
    ! Verificar logica de fim de escrita (beq r15, r0, READ_POLL)
    */
    # Escreve a mensagem no terminal
    TERMINAL_MESSAGE_POLL:
        # Carrega o content de Control register
        ldwio r11, 4(r8)
        # Aplica mascara para obter o wspace
        and r12, r11, r13
        # Verifica se ha espaco para escrita
        beq r12, r0, TERMINAL_MESSAGE_POLL
        # Obtem dados a serem escritos
        andi r9,r9,0b11111111
        # Carrega o caracter da mensagem no endereco r16 para r15
        ldb r15, 0(r16) # TESTE
        # Verifica se atingiu o final da mensagem
        beq r15, r0, READ_POLL # TESTE
        # Escreve no buffer de escrita
        stwio r15, 0(r8)
        # Move o indice do vetor para pegar o proximo caracter
        addi r16, r16, 1
        br TERMINAL_MESSAGE_POLL

    /* 
    TODO: Implementar o MEMBUFF
    TODO: Escrever em MEMBUFF
    TODO: Implementar backspace
    */
    # Le a entrada do usuario
    READ_POLL:
        # Carrega content de Data register
        ldwio r9, 0(r8)
        # Aplica mascara para obter o rvalid
        andi r10, r9, 0x8000
        # Verifica se esta valido para leitura
        beq r10, r0, READ_POLL
        MEMBUFF_POLL:
            # Obtem dados a serem escritos
            andi r9,r9,0b11111111
            beq r7, r9, READ_POLL
            # Escreve no MEMBUFF
            stb r9,0(r22)

        /*  
        ? Conteudo da escrita vir de MEMBUFF ao inves do registrador ?
        ? Auxiliaria na implementacao do backspace ?
        */
        # Escreve a entrada no terminal
        WRITE_POLL:
            # Carrega o content de Control register
            ldwio r11, 4(r8)
            # Aplica mascara para obter o wspace
            and r12, r11, r13
            # Verifica se ha espaco para escrita
            beq r12, r0, WRITE_POLL
            # Carrega o byte salvo no MEMBUFF
            ldb r9,0(r22)
            # Escreve no buffer de escrita
            stwio r9, 0(r8)
            # Verifica se o caracter atual é \n
            beq r9, r17, PARSER
            # Incrementa o contador do MEMBUFF
            addi r22,r22,1
            # Verifica o length de MEMBUFF
            sub r21,r22,r18
            # Armazena o length em MEMBUFF_LENGTH
            stw r21,0(r20)
            # Retorna para aguardar nova entrada
            br READ_POLL

PARSER:
    mov r4, r21
    call PARSING
    
    br POLLING

END:
    br END

.org 0x500
.data

# Mensagem inicial a ser apresentada no terminal
TERMINAL_MESSAGE:
.asciz "Entre com a mensagem aqui: "

/*
TODO: Implementar o MEMBUFF
*/
# Buffer para armazenar as entradas do usuario
MEMBUFF:
.skip 1024
# Quantidade de bytes escrito e ainda nao lidos em MEMBUFF
MEMBUFF_LENGTH:
.word 0

.end