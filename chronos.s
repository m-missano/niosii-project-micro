.global START_CHRONOS
.global CANCEL_CHRONOS
.global UPDATE_DISPLAY


/*
* r16 : addr de FLAG_CHRONUS
* r17 : content de FLAG_CHRONUS
* r18 : addr de ACCUMULATOR        | r18: addr de FLAG_CHRONUS_STOPPED
* r19 : addr de INTERRUPT_COUNTER
* r20 : addr de TIMER
* r21 : mascara de interrupcao de TIMER
* r22 : addr de PUSH_BUTTON
* r23 : mascara de habilitacao de interrupcao de PUSH_BUTTON
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

    # Carregamento de FLAG_CHRONUS_STOPPED
    movia r18, FLAG_CHRONUS_STOPPED
    # Seta FLAG_CHRONUS_STOPPED para False 
    stw r0, 0(r18)

    # Carregamento de addr de ACCUMULATOR
    movia r18, ACCUMULATOR
        
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

    # Carrega addr de PUSH_BUTTON
    movia r22, PUSH_BUTTON
    # Habilita interrupcao do KEY1 de PUSH_BUTTON
    movi r23, 0x02 # mascara KEY1 -> 0b0010
    stwio r23, (r22)

    # Carrega o TIMER
    movia r20, TIMER
    # Habilita interrupcao do dispositivo, cont e start 
    addi r21,r0,0b111 
    stwio r21,4(r20)

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
* r18 : addr de ACCUMULATOR      | 18 : addr de FLAG_CHRONUS_STOPPED
* r19 : addr de SEG7DISPLAY
* r20 : addr de TIMER
* r21 : mascara de interrupcao de TIMER
* r22 : 
* r23 : 
*/

CANCEL_CHRONOS:
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

    # Carregamento de FLAG_CHRONUS_STOPPED
    movia r18, FLAG_CHRONUS_STOPPED
    # Seta FLAG_CHRONUS_STOPPED para False
    stw r0, 0(r18)
    
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

        # Carrega addr de PUSH_BUTTON
        movia r22, PUSH_BUTTON
        # Desabilita interrupcao do KEY1 de PUSH_BUTTON
        movi r23, 0x0 # mascara KEY1 -> 0b0000
        stwio r23, (r22)

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

    movia r23, 0x6000
    beq r20, r23, MAX_LIMITE_ON
    movia r23, 0xFFFF
    beq r20, r23, MAX_LIMIT_OFF

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
    movia r23, 0x000A
    bne r18, r23, NAO_LIMITE_UNI_SEG
    # aumenta 1 na dezena 
    # reseta unidade de segundos para 0 
    # 13:0A -> 13:00 -> 13:10
    andi r20, r20, 0xFFF0
    addi r20, r20, 0x0010
    # Atualiza o elemento a ser adicionado ao SEG7DISPLAY
    movia r22, 0x3F
    br ROTACAO_UNI_SEG 

NAO_LIMITE_UNI_SEG:
    # Multiplica r18 por 4 para encontrar o indice que aponta (endereço relativo) o elemento em LOOKUPTABLE
    add r18, r18, r18
    add r18, r18, r18
    # Encontra o endereço na memória do elemento em LOOKUPTABLE 
    add r18, r18, r16
    # Carrega o content do elemento de LOOKUPTABLE
    ldw r22, 0(r18)

ROTACAO_UNI_SEG:
    # Adiciona elemento de LOOKUPTABLE ou advindo ao atingir o limite ao content de SEG7DISPLAY
    add r17, r17, r22
    # Realiza rotação para calcular o proximo valor de SEG7DISPLAY
    roli r17, r17, 24


    ### DEZENAS DE SEGUNDOS ###
    # Aplica mascara para obter a dezena de segundos
    andi r18, r20, 0x00F0
    /* 
    ? r18 -> 0x0060 -> Update da unidade de minutos | dezena de segundos = 0
    */
    movia r23, 0x0060
    bne r18, r23, NAO_LIMITE_DEZ_SEG
    # aumenta 1 na dezena 
    # reseta unidade de segundos para 0 
    # 13:70 -> 13:00 -> 14:00
    andi r20, r20, 0xFF0F
    addi r20, r20, 0x0100
    # Atualiza o elemento a ser adicionado ao SEG7DISPLAY
    movia r22, 0x3F
    br ROTACAO_DEZ_SEG 

NAO_LIMITE_DEZ_SEG:
    # Desloca content de r18 para os 4 bits menos significativos para obter o indice relativo do elemento em LOOKUPTABLE
    srli r18, r18, 4
    # Multiplica r18 por 4 para encontrar o indice que aponta (endereço relativo) o elemento em LOOKUPTABLE
    add r18, r18, r18
    add r18, r18, r18 
    # Encontra o endereço na memória do elemento em LOOKUPTABLE 
    add r18, r18, r16
    # Carrega o content do elemento de LOOKUPTABLE
    ldw r22, 0(r18)

ROTACAO_DEZ_SEG:
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
    movia r23, 0x0A00
    bne r18, r23, NAO_LIMITE_UNI_MIN
    # aumenta 1 na dezena 
    # reseta unidade de segundos para 0 
    # 13:0A -> 13:00 -> 13:10
    andi r20, r20, 0xF0FF
    addi r20, r20, 0x1000
    # Atualiza o elemento a ser adicionado ao SEG7DISPLAY
    movia r22, 0x3F
    br ROTACAO_UNI_MIN 

NAO_LIMITE_UNI_MIN:
    # Desloca content de r18 para os 4 bits menos significativos para obter o indice relativo do elemento em LOOKUPTABLE
    srli r18, r18, 8
    # Multiplica r18 por 4 para encontrar o indice que aponta (endereço relativo) o elemento em LOOKUPTABLE
    add r18, r18, r18
    add r18, r18, r18 
    # Encontra o endereço na memória do elemento em LOOKUPTABLE 
    add r18, r18, r16
    # Carrega o content do elemento de LOOKUPTABLE
    ldw r22, 0(r18)

ROTACAO_UNI_MIN:
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
    movia r23, 0x6000
    bne r18, r23, NAO_LIMITE_DEZ_MIN
    br MAX_LIMIT_OFF 

NAO_LIMITE_DEZ_MIN:
    # Desloca content de r18 para os 4 bits menos significativos para obter o indice relativo do elemento em LOOKUPTABLE
    srli r18, r18, 12
    # Multiplica r18 por 4 para encontrar o indice que aponta (endereço relativo) o elemento em LOOKUPTABLE 
    add r18, r18, r18
    add r18, r18, r18
    # Encontra o endereço na memória do elemento em LOOKUPTABLE 
    add r18, r18, r16
    # Carrega o content do elemento de LOOKUPTABLE
    ldw r22, 0(r18)

ROTACAO_DEZ_MIN:
    # Adiciona elemento de LOOKUPTABLE ao content de SEG7DISPLAY
    add r17, r17, r22
    # Realiza rotação para calcular o proximo valor de SEG7DISPLAY
    roli r17, r17, 24
    
    /*
    ! UPDATE: atualiza o acumulador 
    */
    addi r20, r20, 1
    br MOSTRA_NO_DISPLAY    

MAX_LIMITE_ON:
    mov r17, r0
    movia r20, 0xFFFF
    br MOSTRA_NO_DISPLAY

MAX_LIMIT_OFF:
    mov r17, r0
    orhi r17, r17, 0x7D3F
    ori r17, r17, 0x3F3F
    movia r20, 0x6000

MOSTRA_NO_DISPLAY:
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