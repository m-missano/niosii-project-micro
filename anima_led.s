
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
* r8  : 
* r9  :
* r10 :
* r11 : 
* r12 : 
* r13 : 
* r14 : 
* r15 : 
* r16 : addr de FLAG_ANIMACAO (temp)
* r17 : content de FLAG_ANIMACAO (temp)
* r18 : addr de LED_VERM
* r19 : mascara inicial de LED_VERM
* r20 : 
* r21 : 
* r22 : 
* r23 : 
*/

/*

   hex     |                    bin                           dec
0xFFFF0000 | 0b.1111.1111.1111.1111.0000.0000.0000.0000 | undefined
0x00008000 | 0b.0000.0000.0000.0000.1000.0000.0000.0000 | undefined
0x0000000A | 0b.0000.0000.0000.0000.0000.0000.0000.1010 |    10
*/

.global START_ANIMA_LED
.global STOP_ANIMA_LED


START_ANIMA_LED:
    
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

    # Carregamento da FLAG_ANIMACAO
    movia r16, FLAG_ANIMA
    ldw r17, 0(r16)
    
    
    bne r17, r0, ANIMACAO_ATIVA /*Se animacao ja ativa, significa que ja esta sendo tratada interrupcao*/
        
        # Seta a FLAG_ANIMA como 1
        addi r17, r0, 1
        # Salva a flag de volta p/ memoria
        stw r17, 0(r16) 

        # Carrega addr de LED_VERM
        movia r18, LED_VERM

        # Seta mascara inicial
        orhi r19, r0, 0x0000
        ori r19, r19, 0x0001

        # Seta a mascara inicial para LED_VERM
        stwio r19, 0(r18)

        # Habilita interrupcao do dispositivo, cont e start 
        addi r13,r0,0b111 
        stwio r13,4(r11)

ANIMACAO_ATIVA:

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

STOP_ANIMA_LED:
    movia r4, 0x0101
    ret