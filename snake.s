.org 0x200

.equ DIR_RIGHT 0
.equ DIR_LEFT 1
.equ DIR_TOP 2
.equ DIR_BOTTOM 3

.equ SC_ROWS 32
.equ SC_COLS 64

; REGISTERS:
; v0 and v1: X and Y positions
; va: used to store delay in "wait"

; entrypoint
start:
    ; create snake head
    jsr random_pos
    mvi snake_head
    str v1
    jsr draw_pixel

    ; spawn first fruit
    jsr fruit_spawn
    jsr draw_pixel

    ; sets the initial direction
    rand v2, DIR_BOTTOM
    jsr snake_set_dir

    jsr loop

end:
    jmp end

; main loop
loop:
    cls

    jsr snake_move_head

    jsr draw_pixel

    mov va, 60
    sdelay va
    jsr wait

    jmp loop

; snake
snake_push:

    rts

snake_pop:

    rts

;; checks if the snake head collides with the fruit
;; returns v2 (1 = yes, 0 = no)
snake_check_collision:
    jsr snake_get_head_pos

    ; stores snake head position (x = v8, y = v9)
    mov v8, v0
    mov v9, v1

    jsr fruit_get_pos

    skne v8, v0
    jsr ret_no
    skne v9, v1
    jsr ret_no

    mov v0, 1
    rts

snake_move_head:
    jsr snake_get_head_pos
    jsr snake_get_dir

    skeq v2, DIR_RIGHT
    jsr dir_right
    skeq v2, DIR_LEFT
    jsr dir_left
    skeq v2, DIR_TOP
    jsr dir_top
    skeq v2, DIR_BOTTOM
    jsr dir_bottom

    mvi snake_head
    str v1

    rts

dir_right:
    sub v0, 1
    rts

dir_left:
    add v0, 1
    rts

dir_top:
    sub v1, 1
    rts

dir_bottom:
    add v1, 1
    rts

snake_get_head_pos:
    mvi snake_head
    ldr v1
    rts

;; sets snake direction from v2
snake_set_dir:
    mov v8, v0 ; stores v0 into v8
    mov v0, v2

    mvi snake_dir
    str v0

    mov v0, v8 ; restores v0 from v8

    rts

;; gets snake direction and stores into v2
snake_get_dir:
    mov v8, v0

    mvi snake_dir
    ldr v0
    mov v2, v0

    mov v0, v8

    rts

; fruits
fruit_spawn:
    jsr random_pos
    mvi fruit_pos
    str v1
    rts

fruit_get_pos:
    mvi fruit_pos
    ldr v1
    rts

; drawing
draw_pixel:
    mvi sprite_pixel
    draw v0, v1, 1
    rts

; misc
wait:
    gdelay va
    skeq va, 0
    jmp wait
    rts

;; return (x, y) -> (v0, v1)
random_pos:
    rand v0, SC_COLS
    rand v1, SC_ROWS
    rts

ret_no:
    mov v0, 0
    rts

; data section
game_over:
    .db 0

fruit_pos:
    .db 0, 0 ; (x, y)

snake_head:
    .db 0, 0 ; (x, y)

snake_body:
    .db 0,0,0,0,0,0,0,0
    .db 0,0,0,0,0,0,0,0
    .db 0,0,0,0,0,0,0,0
    .db 0,0,0,0,0,0,0,0
    .db 0,0,0,0,0,0,0,0
    .db 0,0,0,0,0,0,0,0
    .db 0,0,0,0,0,0,0,0
    .db 0,0,0,0,0,0,0,0

snake_size:
    .db 0

snake_dir:
    .db 0

sprite_pixel:
    .db 0x80 ; 0b10000000

.end
