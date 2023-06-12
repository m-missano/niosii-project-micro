/* PSEUDOCODIGO 

void rti(){

} 
*/

/*                                            
 * r16 : addr de FLAG_ANIMA                     
 * r17 :           r17 : content de FLAG_ANIMA                                     
 * r18 :           r18 : addr de LED_VERM
 * r19 :           r19 : mascara do LED_VERM
 * r20 :           r20 : mascara de valor final ROL       
 * r21 :           r21 : addr de TIMER               | r21 : addr do switch
 * r22 :           r22 : mascara para TIMER          | r22 : content do switch
 * r23 :           r23 : mascara de valor final ROR
 */

/*

   hex     |                    bin                           dec
0xFFFF0000 | 0b.1111.1111.1111.1111.0000.0000.0000.0000 | undefined
0x00008000 | 0b.0000.0000.0000.0000.1000.0000.0000.0000 | undefined
0x0000000A | 0b.0000.0000.0000.0000.0000.0000.0000.1010 |    10
*/

.org 0x20
RTI:
    # PROLOGO SF
    addi sp, sp, -40
    stw ra, 36(sp)
    stw fp, 32(sp)
    stw r16, 28(sp)
    stw r17, 24(sp) 
    stw r18, 20(sp) 
    stw r19, 16(sp) 
    stw r20, 12(sp)
    stw r21, 8(sp)
    stw r22, 4(sp)
    stw r23, 0(sp)
    addi fp, sp, 32

    # ALTERAR ISSO
    rdctl et, ipending
    beq et, r0, OTHER_EXCEPTIONS
    subi ea, ea, 4
    andi r17, et, 1
    beq r17, r0, OTHER_INTERRUPTS
    call EXT_IRQ0
OTHER_INTERRUPTS:
  br END_HANDLER:
OTHER_EXCEPTIONS:

END_HANDLER:

   # EPILOGO : Stack
    ldw ra, 36(sp)
    ldw fp, 32(sp)
    ldw r16, 28(sp)
    ldw r17, 24(sp)
    ldw r18, 20(sp)
    ldw r19, 16(sp) 
    ldw r20, 12(sp)
    ldw r21, 8(sp)
    ldw r22, 4(sp)
    ldw r23, 0(sp)
    addi sp, sp, 40

    eret


EXT_IRQ0:
    
    # PROLOGO SF
    addi sp, sp, -40
    stw ra, 36(sp)
    stw fp, 32(sp)
    stw r16, 28(sp)
    stw r17, 24(sp) 
    stw r18, 20(sp) 
    stw r19, 16(sp) 
    stw r20, 12(sp)
    stw r21, 8(sp)
    stw r22, 4(sp)
    stw r23, 0(sp)
    addi fp, sp, 32

    # Aplica mascara do ultimo LED ROL: 0x00020000
    orhi r20, r0, 0x0002
    ori r20, r20, 0x0000

    # Aplica mascara do ultimo LED ROR
    orhi r23, r0, 0x0000
    ori r23, r23, 0x0001

    # Carrega FLAG_ANIMA
    movia r16, FLAG_ANIMA
    ldw r17, 0(r16) 
    # Verificar flag do LED
    beq r17, r0, LED_DESATIVADO

    # Polling do switch para verificar sentido da animacao
    # Animacao
    # Carrega endereço do led vermelho
    movia r18, LED_VERM

    # Carrega mascara atual do LED
    ldwio r19, 0(r18)

    # Carregar switch
    movia r21, SWITCH_BUTTON
    ldwio r22, 0(r21)
    # Verificar bit 0 - Aplica mascara
    andi r22, r22, 0x1
    
    # Verifica se SWITCH_BUTTON esta acionado
    bne r22, r0, ROTACAO_ANTIH 
    ############ ROR ############
    # Se SW0 = 0
    # Verifica se chegou ao final dos LEDs ROL
    beq r19, r23, REINICIA_ROR
    # Realiza rotacao H - ROR
    roli r19, r19, 31
    br ARMAZENA_LED
REINICIA_ROR:  
    # Seta mascara inicial ROR
    mov r19, r20
    br ARMAZENA_LED


ROTACAO_ANTIH:
    ############ ROL ############
    # Se SW0 = 1
    # Verifica se chegou ao final dos LEDs ROL
    beq r19, r20, REINICIA_ROL
    # Realiza rotacao AH - ROL
    roli r19, r19, 1
    br ARMAZENA_LED
REINICIA_ROL:  
    # Seta mascara inicial ROL
    mov r19, r23


ARMAZENA_LED:
        # Armazena nova mascara no LED
        stwio r19, 0(r18)
        # mascara para o bit do LED que sera aceso
        # ror / rol dependendo do sentido
        
LED_DESATIVADO:

    movia r22, 0x0003
    movia r21, TIMER
    stwio r22, (r21)

    # EPILOGO : Stack
    ldw ra, 36(sp)
    ldw fp, 32(sp)
    ldw r16, 28(sp)
    ldw r17, 24(sp)
    ldw r18, 20(sp)
    ldw r19, 16(sp) 
    ldw r20, 12(sp)
    ldw r21, 8(sp)
    ldw r22, 4(sp)
    ldw r23, 0(sp)
    addi sp, sp, 40
    # Stack Frame

    ret



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
.equ SWITCH_BUTTON, 0x10000040

.global _start
.global MEMBUFF

.global TIMER

.global LED_VERM
.global LED_VERM_STATE
.global FLAG_ANIMA

.global SWITCH_BUTTON

.global FLAG_CHRONOS
# TODO: Verificar necessidade de switch .global


.text

_start:
    movia sp, STACK   /* armazena em sp o endereço da STACK */
    mov fp, sp        /* seta o frame pointer */
    
    # FLAG_ANIMACAO inicialmente eh zero
    movia r8,FLAG_ANIMA
    ldw r13, 0(r8)
    mov r13, r0
    stw r13, 0(r8) 
    
    # TIMER = 10000000
    movia r9, 10000000 
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
# Armazena o estado de LED_VERM antes do inicio da animacao
LED_VERM_STATE:
.skip 32

.end