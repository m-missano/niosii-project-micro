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
* r19 : 
* r20 : 
* r21 : 
* r22 : 
*/


.global ACENDER_LED
.global ACENDER_LED
.global ACENDER_LED
.global ACENDER_LED
.global ACENDER_LED
.global ACENDER_LED

/*ACENDER_LED:
    movia r16, r4

    # Carrega o byte de dezena do MEMBUFF
    ldb r17, 0(r16)
    # Carrega o byte de unidade do MEMBUFF
    ldb r18, 1(r16)

    beq r17, r0, IGNORA_DEZENA
    addi r18, r18, 10

IGNORA_DEZENA:

    /*
    ACENDER LED
    */

ACENDER_LED:
    movia r4, 0x0000

APAGAR_LED:
    movia r4, 0x0001

START_ANIMA_LED:
    movia r4, 0x0100

STOP_ANIMA_LED:
    movia r4, 0x0101

START_CHRONOS:
    movia r4, 0x0200

STOP_CHRONOS:
    movia r4, 0x0201



