/* PSEUDOCODIGO 

int parsing(addr_membuff, length_membuff:r4){
    
    // 10 10 21 20

    content_membuff = load(addr_membuff)

    for(i=0; i<length_membuff; i++){
        content_membuff[i] = content_membuff[i] - "0x30";
        // Ideia de leitura de caracter de content
        // add r10, r0, content_membuff[i]
    }



    while (contador < length_membuff){

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

        contador += 1

    }
}
*/

/*
* r8  : valor de retorno da subrotina
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
* r23 : addr do ultimo elemento de MEMBUFF
*/

/*
   hex     |                  bin                           dec
0xFFFF0000 | 0b.1111.1111.1111.1111.0000.0000.0000.0000 | undefined
0x00008000 | 0b.0000.0000.0000.0000.1000.0000.0000.0000 | undefined
0x0000000A | 0b.0000.0000.0000.0000.0000.0000.0000.1010 |    10
*/

.global PARSING
.global END_SWITCH

PARSING:

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

    # Carrega o addr de MEMBUFF
    movia r16, MEMBUFF
    # Carrega o content de MEMBUFF_LENGTH
    mov r18, r4
    # Carrega o ADDR_MEMBUFF + iterador (contador) de MEMBUFF
    movia r19, MEMBUFF
    # Carrega o addr do ultimo elemento de MEMBUFF
    addi r23, r18, MEMBUFF

# Atualiza o valor no MEMBUFF
LOOP:
    # Carrega o conteudo de MEMBUFF
    ldb r17, 0(r19)
    # Subtrai 0x30 de MEMBUFF
    /*
    ! Pular espacos (ASCII 0x20)
    */
    subi r17, r17, 0x30
    # Armazena novamente no MEMBUFF
    stb r17, 0(r19)
    # Incrementa o iterador
    addi r19, r19, 1
    # Verifica se percorreu todo o MEMBUFF
    bne r19, r23, LOOP

movia r19, MEMBUFF

LOAD_CODE:
    /*
    ? Verificar little endian ou big endian para  ldh r20, 0(r19) ?
    */
    # Carrega o opcode para r22
    ldb r22, 0(r19)
    ldb r20, 1(r19)
    slli r22, r22, 8
    or r22, r22, r20

    # Verifica para qual funcao saltar
    cmpeqi r21, r22, 0x0000
        bne r21, r0, CHAMA_ACENDER_LED
    cmpeqi r21, r22, 0x0001
        bne r21, r0, CHAMA_APAGAR_LED
    cmpeqi r21, r22, 0x0100
        bne r21, r0, CHAMA_START_ANIMA_LED
    cmpeqi r21, r22, 0x0101
        bne r21, r0, CHAMA_STOP_ANIMA_LED
    cmpeqi r21, r22, 0x0200
        bne r21, r0, CHAMA_START_CHRONOS
    cmpeqi r21, r22, 0x0201
        bne r21, r0, CHAMA_STOP_CHRONOS
    br END_SWITCH2

CHAMA_ACENDER_LED:
    # Passa para ACENDER_LED o endereço atualizado da próxima instrução no MEMBUFF
    mov r4, r19
    call ACENDER_LED
    # Retorna a quantidade de bytes avançados de MEMBUFF dentro da subrotina chamada
    mov r8, r2
    br END_SWITCH

CHAMA_APAGAR_LED:
    # Passa a posicao atual do ponteiro de MEMBUFF (proximos bytes para ler)
    mov r4, r19
    call APAGAR_LED
    # Retorna a quantidade de bytes avançados de MEMBUFF dentro da subrotina chamada
    mov r8, r2
    br END_SWITCH
    
CHAMA_START_ANIMA_LED:
    call START_ANIMA_LED
    # Retorna a quantidade de bytes avançados de MEMBUFF dentro da subrotina chamada
    mov r8, r2
    br END_SWITCH

CHAMA_STOP_ANIMA_LED:
    call STOP_ANIMA_LED
    # Retorna a quantidade de bytes avançados de MEMBUFF dentro da subrotina chamada
    mov r8, r2
    br END_SWITCH

CHAMA_START_CHRONOS:
    call START_CHRONOS
    # Retorna a quantidade de bytes avançados de MEMBUFF dentro da subrotina chamada
    mov r8, r2
    br END_SWITCH

CHAMA_STOP_CHRONOS:
    call STOP_CHRONOS
    # Retorna a quantidade de bytes avançados de MEMBUFF dentro da subrotina chamada
    mov r8, r2
    br END_SWITCH        
        

END_SWITCH:
    addi r19, r19, 2
    add r19, r19, r8
    /*
    TODO: condicao para sair do loop
    */
    bne r19, r23, LOAD_CODE
END_SWITCH2:

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

.end