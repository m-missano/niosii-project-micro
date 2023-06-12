/*
PSEUDOCODIGO:

int convert(){
    r2 = ler_membuff(2:4);
    r2 = to_dec(r2); //r2[0]*10 + r2[1] = r2[0] << 3 + r2[0] << 1 + r2[1]
    // Verificar se o valor de r2 está dentro do numero dos leds \ 
    //  se não, retornar mensagem de led_overflow, ou led_underflows
}
*/

/*
* r8  : 
* r9  :
* r10 :
* r11 : 
* r12 : 
* r13 : 
* r14 : 
* r15 : 
* r16 : ADDR_MEMBUFF + iterador (contador) de MEMBUFF
* r17 : decimal byte
* r18 : unit byte | final value
* r19 : addr do led vermelho
* r20 : led a ser aceso (lower)
* r21 : estado atual dos leds vermelhos
* r22 : led a ser aceso (upper)
* r23 : addr de FLAG_ANIMA                               | r23 : content de FLAG_ANIMA
*/


.global ACENDER_LED
.global APAGAR_LED
.global START_CHRONOS
.global STOP_CHRONOS


ACENDER_LED:

   # PROLOGO : Stack
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
    
    movia r23, FLAG_ANIMA
    ldw r23, 0(r23)
    bne r23, r0, ANIMACAO_ATIVA 
    # Carrega o ponteiro atual do MEMBUFF
    mov r16, r4
    # Carrega o byte de dezena do MEMBUFF
    ldb r17, 0(r16)
    # Carrega o byte de unidade do MEMBUFF
    ldb r18, 1(r16)
    
    # Verifica eh necessario adicionar dezena ou nao
    beq r17, r0, IGNORA_DEZENA_ACENDER
    addi r18, r18, 10

IGNORA_DEZENA_ACENDER:

    # Carrega a mascara inicial do led a ser aceso
    movia r20, 0x1
    # Desloca o valor 1 para a esquerda r18 vezes, definindo o led a ser aceso     
    sll r20, r20, r18  

    movia r19, LED_VERM
    
  
    # Carrega o estado atual dos leds
    ldwio r21, 0(r19)
    
    # Aplica a máscara ao registrador de controle dos LEDs
    or r21, r21, r20   

    stwio r21, 0(r19)

ANIMACAO_ATIVA:    

    # Carrega variavel de retorno
    movia r2, 0x2

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
    ret  




APAGAR_LED:
    # PROLOGO : Stack
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

    # Carrega o ponteiro atual do MEMBUFF
    mov r16, r4
    # Carrega o byte de dezena do MEMBUFF
    ldb r17, 0(r16)
    # Carrega o byte de unidade do MEMBUFF
    ldb r18, 1(r16)
    
    # Verifica eh necessario adicionar dezena ou nao
    beq r17, r0, IGNORA_DEZENA_APAGAR
    addi r18, r18, 10

IGNORA_DEZENA_APAGAR:

    # movia r20, 0b11111111111111111111111111111110
    # Carrega a mascara inicial do led a ser aceso
    # movui r20, 0xFFFE
    # Carrega a mascara inicial do led a ser aceso
    # movhi r22, 0xFFFF
    orhi r20, r0, 0xFFFF
    ori r20, r20, 0xFFFE
    # Rotaciona o valor 0 para a esquerda r18 vezes, definindo o led a ser apagado     
    rol r20, r20, r18    

    movia r19, LED_VERM

    # Carrega o estado atual dos leds
    ldwio r21, 0(r19)

    # Aplica a máscara ao registrador de controle dos LEDs
    and r21, r21, r20   
    
    
    stwio r21, 0(r19)

    # Carrega variavel de retorno
    movia r2, 0x2

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
    ret

/* 
ACENDER_LED:
    movia r4, 0x0000
    ret

APAGAR_LED:
    movia r4, 0x0001
    ret*/

START_CHRONOS:
    movia r4, 0x0200
    ret

STOP_CHRONOS:
    movia r4, 0x0201
    ret

.end