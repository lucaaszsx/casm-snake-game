.org 0x200

.equ DIR_RIGHT 0
.equ DIR_LEFT 1
.equ DIR_TOP 2
.equ DIR_BOTTOM 3
.equ DIR_LEN 3

.equ S_ROWS_MASK 31
.equ S_COLS_MASK 63

; REGISTERS:
; v0..v1: used to load/store bytes from memory;
;         v0 can be used to return data from subroutines
; v2..v3: used for X and Y positions
; v8..v9: temp registers
; va: used to define delay for "wait"

; entrypoint
start:
    ; create snake head
    jsr random_pos
    mvi snake_head
    str v1
    jsr draw_pixel

    ; create snake tail
    jsr snake_get_head_pos
    mvi snake_tail
    

    ; spawn first fruit
    jsr spawn_fruit
    jsr draw_pixel

    ; sets the initial direction
    rand v0, DIR_LEN
    jsr snake_set_dir

    jsr loop

end:
    jmp end

; main loop
loop:
    cls

    jsr get_fruit_pos
    jsr draw_pixel

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

    ; stores snake head position (x = v2, y = v3)
    mov v2, v0
    mov v3, v1

    jsr get_fruit_pos ; (x = v0, y = v1)

    skne v2, v0
    jsr ret_no
    skne v3, v1
    jsr ret_no

    mov v0, 1
    rts

snake_move_head:
    jsr snake_get_head_pos
    mov v2, v0
    mov v3, v1

    ; moves the snake head
    mov v8, 1 ; used for sub instructions in dir_right, dir_bottom
    jsr snake_get_dir

    skeq v0, DIR_RIGHT
    jsr dir_right
    skeq v0, DIR_LEFT
    jsr dir_left
    skeq v0, DIR_TOP
    jsr dir_top
    skeq v0, DIR_BOTTOM
    jsr dir_bottom

    mvi snake_head
    mov v0, v2
    mov v1, v3
    str v1

    rts

snake_shrink_tail:
    
    rts

dir_right:
    sub v2, v8
    rts

dir_left:
    add v2, 1
    rts

dir_top:
    add v3, 1
    rts

dir_bottom:
    sub v3, v8
    rts

snake_get_head_pos:
    mvi snake_head
    ldr v1
    rts

snake_get_tail_pos:
    mvi snake_tail
    ldr v1
    rts

;; sets snake direction to v0
snake_set_dir:
    mvi snake_dir
    str v0
    rts

;; gets snake direction and stores into v0
snake_get_dir:
    mvi snake_dir
    ldr v0
    rts

; fruits
spawn_fruit:
    jsr random_pos
    mvi fruit_pos
    str v1
    rts

get_fruit_pos:
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

random_pos:
    rand v0, S_COLS_MASK
    rand v1, S_ROWS_MASK
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

snake_tail:
    .db 0, 0

snake_size:
    .db 0

snake_dir:
    .db 0

sprite_pixel:
    .db 0x80 ; 0b10000000

.end
