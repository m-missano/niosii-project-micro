/* PSEUDOCODIGO 

int parsing(addr_membuff, length_membuff:r4){
    
    // 10 10 21 20

    content_membuff = load(addr_membuff)

    for(i=0; i<length_membuff; i++){
        content_membuff[i] = content_membuff[i] - "0x30";
        // Ideia de leitura de caracter de content
        // add r10, r0, content_membuff[i]
    }

    r1 = ler_membuff(0:2);

    if(r1 == "0x00"){
        acender_led(r2); 
    }
    else if(r1 == "0x01"){
        r2 = ler_membuff(2:4);
        r2 = to_dec(r2); //r2[0]*8 + r2[0]*2 + r2[1] = r2[0] << 3 + r2[0] << 1 + r2[1]
        // Verificar se o valor de r2 está dentro do numero dos leds \ 
        //  se não, retornar mensagem de led_overflow, ou led_underflows
        apagar_led(r2);
    }
    else if(r1 == "0x10"){
        start_anime_leds();
    }
    else if(r1 == "0x11"){
        stop_anime_leds();
    }
    else if(r1 == "0x20"){
        start_chronos();
    }
    else if(r1 == "0x21"){
        stop_chronos();
    }
    else{
        printf("Invalid command")
    }
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
* r16 : addr de MEMBUFF
* r17 : content de MEMBUFF
* r18 : content de MEMBUFF_LENGTH
* r19 : ADDR_MEMBUFF + iterador (contador) de MEMBUFF
* r20 : low byte operation code (opcode)
* r21 : resultado da comparacao do opcode (registrador temp)
* r22 : high byte operation code | complete operation code
*/

/*
   hex     |                  bin                           dec
0xFFFF0000 | 0b.1111.1111.1111.1111.0000.0000.0000.0000 | undefined
0x00008000 | 0b.0000.0000.0000.0000.1000.0000.0000.0000 | undefined
0x0000000A | 0b.0000.0000.0000.0000.0000.0000.0000.1010 |    10
*/

.global PARSING

PARSING:

    # PROLOGO : Stack
    addi sp, sp, -36
    stw ra, 32(sp)
    stw fp, 28(sp)
    stw r16, 24(sp)
    stw r17, 20(sp) 
    stw r18, 16(sp) 
    stw r19, 12(sp) 
    stw r20, 8(sp)
    stw r21, 4(sp)
    stw r22, 0(sp)
    addi fp, sp, 28

    # Carrega o addr de MEMBUFF
    movia r16, MEMBUFF
    # Carrega o content de MEMBUFF_LENGTH
    movia r18, r4
    # Carrega o ADDR_MEMBUFF + iterador (contador) de MEMBUFF
    movia r19, MEMBUFF

# Atualiza o valor no MEMBUFF
LOOP:
    # Carrega o conteudo de MEMBUFF
    ldb r18, 0(r19)
    # Subtrai 0x30 de MEMBUFF
    /*
    ! Pular espacos (ASCII 0x20)
    */
    subi r18, r18, 0x30
    # Armazena novamente no MEMBUFF
    stb r18, 0(r19)
    # Incrementa o iterador
    addi r19, r19, 1
    # Verifica se percorreu todo o MEMBUFF
    bne r19, r18, LOOP

movia r19, MEMBUFF

LOAD_CODE:
    /*
    ? Verificar little endian ou big endian para  ldh r20, 0(r19) ?
    */
    # Carrega o opcode para r22
    ldb r22, 0(r19)
    ldb r20, 1(r19)
    slli r22, r22, 2
    or r22, r22, r20
    
    movia r4, r19

    # Verifica para qual funcao saltar
    cmpeqi r21, r22, 0x0000
        bne r21, r0, ACENDER_LED
    cmpeqi r21, r22, 0x0001
        bne r21, r0, APAGAR_LED
    cmpeqi r21, r22, 0x0100
        bne r21, r0, START_ANIMA_LED
    cmpeqi r21, r22, 0x0101
        bne r21, r0, STOP_ANIMA_LED
    cmpeqi r21, r22, 0x0200
        bne r21, r0, START_CHRONOS
    cmpeqi r21, r22, 0x0201
        bne r21, r0, STOP_CHRONOS
    
    addi r19, r19, 2
    add r19, r19, r2
    subi r18, r18, 2
    /*
    TODO: condicao para sair do loop
    */
    bne r18, r0, LOAD_CODE

    # EPILOGO : Stack
    ldw ra, 32(sp)
    ldw fp, 28(sp)
    ldw r16, 24(sp)
    ldw r17, 20(sp)
    ldw r18, 16(sp)
    stw r19, 12(sp) 
    stw r20, 8(sp)
    stw r21, 4(sp)
    stw r22, 0(sp)
    addi sp, sp, 32

    ret

.end
    