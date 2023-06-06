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
 * r7  : caracter espaco em ASCI 0x20 ! ALTERAR ISSO DPOIS
 * r8  : addr de Data register                                                         | r8  : addr FLAG_ANIMACAO (temp)
 * r9  : content de Data register                                                      | r9  : valor numerico timer (temp) 
 * r10 : rvalid (bit de validacao de leitura)                                          | r10 : addr TIMER (temp)
 * r11 : content de Control register                                                   | r11 : counter start value (high) (temp)    | r11 : mascara para habilitar interrupcao no processador
 * r12 : wspace (espaco livre na FIFO de escrita)                                      | r12 : counter start value (low) (temp)
 * r13 : mascara para obter o wspace (16 bits superiores de Control register)          | r13 : content de FLAG_ANIMACAO (temp)
 * r14 : addr de TERMINAL_MESSAGE                                                 
 * r15 : content de TERMINAL_MESSAGE                                              
 * r16 : contador para o TERMINAL_MESSAGE_POLL                                    
 * r17 : armazena o codigo ASCII de \n                                             
 * r18 : addr de MEMBUFF
 * r19 : content de MEMBUFF
 * r20 : addr de MEMBUFF_LENGTH
 * r21 : content de MEMBUFF_LENGTH (qtd de bytes escritos e ainda nao lidos em MEMBUFF) 
 * r22 : ADDR_MEMBUFF + iterador (contador) de MEMBUFF
 * r23 : ja usado pelo cezar
 */

/*

   hex     |                    bin                           dec
0xFFFF0000 | 0b.1111.1111.1111.1111.0000.0000.0000.0000 | undefined
0x00008000 | 0b.0000.0000.0000.0000.1000.0000.0000.0000 | undefined
0x0000000A | 0b.0000.0000.0000.0000.0000.0000.0000.1010 |    10
*/

.equ ADDR_DATAREG, 0x10001000
.equ STACK, 0x01000000
.equ LED_VERM, 0x10000000 
.equ TIMER, 0x10002000
.equ FLAG_ANIMA, 0x00010000
.equ FLAG_CHRONOS, 0x00010004

.global _start
.global MEMBUFF
.global LED_VERM
.global TIMER
.global FLAG_ANIMA
.global FLAG_CHRONOS

.text

_start:
    movia sp, STACK   /* armazena em sp o endereço da STACK */
    mov fp, sp        /* seta o frame pointer */
    
    # FLAG_ANIMACAO inicialmente eh zero
    movia r8,FLAG_ANIMA
    ldw r13, 0(r8)
    mov r13, r0
    stw r13, 0(r8) 
    
    # TIMER
    movia r9, 1000000
    movia r10, TIMER
    andi r12, r9, 0xFFFF # baixo
    srli r11, r9, 16 # alto
    # Inserindo 200ms no TIMER
    stwio r12, 8(r10)
    stwio r11, 12(r10)
    
    # SETA INTERRUPCAO NO PROCESSADOR
    # Habilitar o TIMER (IRQ0) no ienable
    addi r11, r0, 1 # 0b0001
    wrctl ienable, r11 # 0b0010 -> ienable
    # Habilitar o bit PIE do status (processador)
    wrctl status, r11  # interrupcao PIE

    # TODO: Essa parte vai pro ANIMA_LED
    # Habilita interrupcao do dispositivo, cont e start 
    # addi r13,r0,0b111 
    # stwio r13,4(r11)


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
    addi r22, r18, 0

    # Armazena o codigo ASCII de Space
    movia r7, 0x20 



# Polling
POLLING:

    add r16, r14, r0 # TESTE
    /*
    TODO: Alterar MEMBUFF para possibilitar escrita posterior
    */
    addi r22, r18, 0

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
        andi r9, r9, 0b11111111
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
            andi r9, r9,0b11111111
            beq r7, r9, READ_POLL
            # Escreve no MEMBUFF
            stb r9, 0(r22)

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
            ldb r9, 0(r22)
            # Escreve no buffer de escrita
            stwio r9, 0(r8)
            # Verifica se o caracter atual é \n
            beq r9, r17, PARSER
            # Incrementa o contador do MEMBUFF
            addi r22, r22, 1
            # Verifica o length de MEMBUFF
            sub r21, r22, r18
            # Armazena o length em MEMBUFF_LENGTH
            stw r21, 0(r20)
            # Retorna para aguardar nova entrada
            br READ_POLL

PARSER:
    mov r4, r21

    addi sp, sp, -4
    stw r8, 0(sp)

    call PARSING

    ldw r8, 0(sp)
    addi sp, sp, 4

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