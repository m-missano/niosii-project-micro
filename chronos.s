.global START_CHRONOS
.global STOP_CHRONOS
.global UPDATE_DISPLAY


/*
* r16 : addr de FLAG_CHRONUS
* r17 : content de FLAG_CHRONUS
* r18 : addr de ACCUMULATOR
* r19 : addr de INTERRUPT_COUNTER
* r20 : addr de TIMER
* r21 : mascara de interrupcao de TIMER
* r22 : 
* r23 : 
*/
START_CHRONOS:
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

    # Carregamento de FLAG_CHRONUS
    movia r16, FLAG_CHRONUS
    ldw r17, 0(r16)

    # Carregamento de addr de ACCUMULATOR
    movia r18, ACCUMULATOR
    
    bne r17, r0, CRONOMETRO_ATIVO /*Se cronometo ja ativo, significa que ja esta sendo tratada interrupcao*/
        
        # Seta a FLAG_CHRONUS como 1
        addi r17, r0, 1
        # Salva a flag de volta p/ memoria
        stw r17, 0(r16) 

        # Seta content de ACCUMULATOR como 0
        stw r0, 0(r18)
        # Inicializa cronometro
        call UPDATE_DISPLAY
        
        # Carrega addr de INTERRUPT_COUNTER
        movia r19, INTERRUPT_COUNTER
        # Reinicia INTERRUPT_COUNTER
        stw r0, 0(r19)

        # Carrega o TIMER
        movia r20, TIMER
        # Habilita interrupcao do dispositivo, cont e start 
        addi r21,r0,0b111 
        stwio r21,4(r20)

CRONOMETRO_ATIVO:

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
* r16 : addr de FLAG_CHRONUS
* r17 : content de FLAG_CHRONUS
* r18 : addr de ACCUMULATOR
* r19 : addr de SEG7DISPLAY
* r20 : addr de TIMER
* r21 : mascara de interrupcao de TIMER
* r22 : 
* r23 : 
*/

STOP_CHRONOS:
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

    # Carregamento de FLAG_CHRONUS
    movia r16, FLAG_CHRONUS
    ldw r17, 0(r16)

    # Carregamento de addr de ACCUMULATOR
    movia r18, ACCUMULATOR
    # Carrega addr de SEG7DISPLAY
    movia r19, SEG7DISPLAY

    # Verifica se cronometo ja esta desativado, se ja, nao faz nada
    beq r17, r0, CRONOMETRO_DESATIVADO
        
        # Seta a FLAG_CHRONUS como 0
        mov r17, r0
        # Salva a flag de volta p/ memoria
        stw r17, 0(r16) 

        # Desliga SEG7DISPLAY
        stwio r0, 0(r19)

        # Carregamento de FLAG_ANIMA
        movia r16, FLAG_ANIMA
        ldw r17, 0(r16)

        # Verifica se animacao dos LEDs está ativada, nesse caso não desabilita interrupção
        bne r17, r0, ANIMACAO_ATIVA
            # Carrega o timer
            movia r20, TIMER
            # Desabilita interrupcao do dispositivo, cont e start 
            mov r21, r0
            stwio r21,4(r20)

ANIMACAO_ATIVA:
CRONOMETRO_DESATIVADO: 

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
* r16 : addr de LOOKUPTABLE
* r17 : content de SEG7DISPLAY
* r18 : indice de LOOKUPTABLE
* r19 : addr de ACCUMULATOR
* r20 : content de ACCUMULATOR
* r21 : addr de SEG7DISPLAY 
* r22 : content de um elemento de LOOKUPTABLE
* r23 : 
*/

/*
   hex     |                  bin                           dec
0xFFFF0000 | 0b.1111.1111.1111.1111.0000.0000.0000.0000 | undefined
0x00008000 | 0b.0000.0000.0000.0000.1000.0000.0000.0000 | undefined
0x0000000A | 0b.0000.0000.0000.0000.0000.0000.0000.1010 |    10
*/

UPDATE_DISPLAY:
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

    # Carrega addr de LOOKUPTABLE
    movia r16, LOOKUPTABLE
    # Inicia content de SEG7DISPLAY como 0
    mov r17, r0
    # Carrega addr de ACCUMULATOR
    movia r19, ACCUMULATOR
    # Carrega content de ACCUMULATOR
    ldw r20, 0(r19)

    /*
    TODO : colocar trecho abaixo em um loop
    ! Ainda em hexadecimal -> modificar para funcionar em 60 segundos e 60 minutos
    */
    ### UNIDADES DE SEGUNDOS ###
    # Aplica mascara para obter a unidade de segundos
    andi r18, r20, 0x000F
    /*
    ? r18 -> 0x000A -> Update da dezena de segundos | unidade de segundos = 0
    */
    # Multiplica r18 por 4 para encontrar o indice que aponta (endereço relativo) o elemento em LOOKUPTABLE
    add r18, r18, r18
    add r18, r18, r18
    # Encontra o endereço na memória do elemento em LOOKUPTABLE 
    add r18, r18, r16
    # Carrega o content do elemento de LOOKUPTABLE
    ldw r22, 0(r18)
    # Adiciona elemento de LOOKUPTABLE ao content de SEG7DISPLAY
    add r17, r17, r22
    # Realiza rotação para calcular o proximo valor de SEG7DISPLAY
    roli r17, r17, 24


    ### DEZENAS DE SEGUNDOS ###
    # Aplica mascara para obter a dezena de segundos
    andi r18, r20, 0x00F0
    /* 
    ? r18 -> 0x0070 -> Update da unidade de minutos | dezena de segundos = 0
    */
    # Desloca content de r18 para os 4 bits menos significativos para obter o indice relativo do elemento em LOOKUPTABLE
    srli r18, r18, 4
    /* 
    ? r18 -> 0x0007 -> Update da unidade de minutos | dezena de segundos = 0
    */
    # Multiplica r18 por 4 para encontrar o indice que aponta (endereço relativo) o elemento em LOOKUPTABLE
    add r18, r18, r18
    add r18, r18, r18 
    # Encontra o endereço na memória do elemento em LOOKUPTABLE 
    add r18, r18, r16
    # Carrega o content do elemento de LOOKUPTABLE
    ldw r22, 0(r18)
    # Adiciona elemento de LOOKUPTABLE ao content de SEG7DISPLAY
    add r17, r17, r22
    # Realiza rotação para calcular o proximo valor de SEG7DISPLAY
    roli r17, r17, 24


    ### UNIDADES DE MINUTOS ###
    # Aplica mascara para obter a unidade de minutos
    andi r18, r20, 0x0F00
    /* 
    ? r18 -> 0x0A00 -> Update da dezena de minutos | unidade de minutos = 0
    */
    # Desloca content de r18 para os 4 bits menos significativos para obter o indice relativo do elemento em LOOKUPTABLE
    srli r18, r18, 8
    /* 
    ? r18 -> 0x000A -> Update da dezena de minutos | unidade de minutos = 0
    */
    # Multiplica r18 por 4 para encontrar o indice que aponta (endereço relativo) o elemento em LOOKUPTABLE
    add r18, r18, r18
    add r18, r18, r18 
    # Encontra o endereço na memória do elemento em LOOKUPTABLE 
    add r18, r18, r16
    # Carrega o content do elemento de LOOKUPTABLE
    ldw r22, 0(r18)
    # Adiciona elemento de LOOKUPTABLE ao content de SEG7DISPLAY
    add r17, r17, r22
    # Realiza rotação para calcular o proximo valor de SEG7DISPLAY
    roli r17, r17, 24

    ### DEZENAS DE MINUTOS ###
    # Aplica mascara para obter a unidade de minutos
    andi r18, r20, 0xF000
    /* 
    ? r18 -> 0x7000 -> Reinicia
    */
    # Desloca content de r18 para os 4 bits menos significativos para obter o indice relativo do elemento em LOOKUPTABLE
    srli r18, r18, 12
    /* 
    ? r18 -> 0x7000 -> Reinicia
    */
    # Multiplica r18 por 4 para encontrar o indice que aponta (endereço relativo) o elemento em LOOKUPTABLE 
    add r18, r18, r18
    add r18, r18, r18
    # Encontra o endereço na memória do elemento em LOOKUPTABLE 
    add r18, r18, r16
    # Carrega o content do elemento de LOOKUPTABLE
    ldw r22, 0(r18)
    # Adiciona elemento de LOOKUPTABLE ao content de SEG7DISPLAY
    add r17, r17, r22
    # Realiza rotação para calcular o proximo valor de SEG7DISPLAY
    roli r17, r17, 24
    
    /*
    ! UPDATE: atualiza o acumulador 
    */
    addi r20, r20, 1
    stw r20, 0(r19)
    
    # Carrega addr de SEG7DISPLAY
    movia r21, SEG7DISPLAY
    # Envia valores do contador para SEG7DISPLAY
    stwio r17, 0(r21)

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