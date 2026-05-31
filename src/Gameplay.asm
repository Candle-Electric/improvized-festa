;=======================;
;       Gameplay        ;
;=======================;
Runner_Gameplay: ; Penguin Rename
	player_sprite_x					=		$6		; 1 Byte
	player_sprite_y					=		$7		; 1 Byte
	player_sprite_sprite_address	=		$8		; 2 Bytes
	player_grounded_bool			=		$a		; 1 byte
	player_acceleration				=		$11 	; 1 Byre 
	frame_counter 					=		$10 	; 1 Byte
	stun_timer						=		$12		; 1 Byte
	player_direction				=		$13		; 1 Byte
	player_position_lo				=		$14		; 1 Byte
	player_position_hi				=		$15		; 1 Byte
	; player_position_x_lo			=		$14		; 1 Byte
	; player_position_x_hi			=		$15		; 1 Byte
	ldc_read_byte					=		$16		; 1 Byte
	ldc_read_offset					=		$17		; 1 Byte
	player_screen_offset			=		$18		; 1 Byte
	boulder_screen_offset			=		$19		; 1 Byte
	boulder_chunk_offset			=		$1a		; 1 Byte
	boulder_chunk_0					=		$20		; 1 Byte
	boulder_chunk_1					=		$21		; 1 Byte
	boulder_chunk_2					=		$22		; 1 Byte
	boulder_chunk_3					=		$23		; 1 Byte
	boulder_chunk_4					=		$24		; 1 Byte
	boulder_chunk_5					=		$25		; 1 Byte
	boulder_chunk_6					=		$26		; 1 Byte
	boulder_sprite_address			=		$27		; 2 Bytes
	half_boulder_sprite_address		=		$29		; 2 Bytes
	player_standing_bool			=		$31		; 1 Byte
	;test_var = $29
	;boulder_x = $2a
	;boulder_y = $2b
    player_horizontal_acceleration  =       $32     ; 1 Byte
    collision_flags                 =       $33     ; 1 Byte
; Set Sprite Addresses
	mov	#8, player_sprite_x
	mov	#14, player_sprite_y
.Draw_Example_Character
	mov	#<Penguin_Trot_1_Mask, player_sprite_sprite_address
	mov	#>Penguin_Trot_1_Mask, player_sprite_sprite_address+1
	mov	#<Boulder_Sprite_Mask, boulder_sprite_address
	mov	#>Boulder_Sprite_Mask, boulder_sprite_address+1
; Set Values
	mov #0, player_acceleration
	mov #0, frame_counter
	mov #0, ldc_read_offset
	mov #1, player_grounded_bool
Gameplay_Loop:
	mov #1, player_standing_bool
.Check_Input
	ld stun_timer
	bnz .Calculate_Position ; Da Stun Flag Might Also Be Considered Here?
	callf Get_Input ; This Function Is Via LibKCommon.ASM
	ld p3
.Check_Up
	ld p3
	bp acc, T_BTN_UP1, .Check_Down
.Check_Down
	ld p3
	bp acc, T_BTN_DOWN1, .Check_Left
.Check_Left
	ld p3
	bp acc, T_BTN_LEFT1, .Check_Right
	ld player_position_hi
	bnz .Check_Left_Past_Origin
	ld player_position_lo
	sub #2
	bp acc, 7, .Check_Right	
.Check_Left_Past_Origin
	dec player_position_lo
	; Mov Walking Animation
	mov #0, player_direction
	mov #0, player_standing_bool
.Check_Right
	ld p3
	bp acc, T_BTN_RIGHT1, .Check_Buttons
	inc player_position_lo
	mov #1, player_direction
	mov #0, player_standing_bool
.Check_Buttons
	; mov #Button_A, acc
	; callf 	Check_Button_Pressed
	ld p3
	bp acc, T_BTN_A1, .B_Pressed
	; bn 	acc, 4, .A_Depressed
.A_Pressed
	ld player_grounded_bool
	bz .B_Pressed
	mov #6, player_acceleration
	mov #0, player_grounded_bool
    jmpf .Calculate_Position ; In Case A + B Are Pressed At The Same Time.
.A_Depressed
.B_Pressed
    ld player_grounded_bool
    bz .Calculate_Position
    mov #6, player_acceleration
    mov #0, Player_Grounded_Bool
.Calculate_Position
	bp player_grounded_bool, 0, .Skip_Grounding
	dec player_acceleration
	ld player_sprite_y
	sub player_acceleration
	st player_sprite_y
	sub #15
	bp acc, 7, .Skip_Grounding
	mov #1, player_grounded_bool
	mov #14, player_sprite_y
	jmpf .Skip_Ceiling
.Skip_Grounding
	bn player_sprite_y, 7, .Skip_Ceiling
	mov #0, player_sprite_y
.Skip_Ceiling

.Assign_Offset
	ld player_position_lo
	clr1 acc, 7
	clr1 acc, 6
	clr1 acc, 5
	clr1 acc, 4
	st player_screen_offset
	ld player_screen_offset
	clr1 acc, 3
	st boulder_screen_offset

	ld player_position_lo
	st c
	mov #0, acc
	mov #8, b ;mob #8
	div
	ld c
	st boulder_chunk_offset

.Assign_Obstalces
	ld boulder_chunk_offset ; player_position_lo
	add #80
	st trl
	mov #0, trh
	ld ldc_read_offset ; mov #0, acc
	ldc
	st boulder_chunk_0 ; st ldc_read_byte
	ld ldc_read_offset
	add #1
	ldc
	st boulder_chunk_1
	ld ldc_read_offset
	add #2
	ldc
	st boulder_chunk_2
	ld ldc_read_offset
	add #3
	ldc
	st boulder_chunk_3
	ld ldc_read_offset
	add #4
	ldc
	st boulder_chunk_4
	ld ldc_read_offset
	add #5
	ldc
	st boulder_chunk_5
	ld ldc_read_offset
	add #6
	ldc
	st boulder_chunk_6

.Calculate_Collision
    ld boulder_chunk_0
    add boulder_chunk_1
    bz .Collision_Done ; Remember: Note To Change these To 30 and #31, Or Whatever The Chunks Were Assigned As. If The 2 Leftmost Chunk Stations (Where The Player Is.) Don't Have Obstacles, Skip Collision And Save The Cycles.
    ld player_sprite_x
    add #7
    ; sub chunk_displacement_Offset ; Generate Detail On Intermediate Zone Here For Collision
	bz .Keep_Colliding
	jmpf .Collision_Done
.Keep_Colliding
    LD Player_Sprite_Y
    ld boulder_chunk_offset
	bnz .Collision_Chunk_1
.Collision_Chunk_1
	sub #1
	bnz .Collision_Chunk_2
	ld player_y
	; Sub Distance Over The Obstacle, Depending On Type.
    sub # 18 
    bp acc, 7, .Collision_Chunk_2
    mov #1, collision_active
    jmpf .Collision_Done
.Collision_Chunk_2
	sub #1
	bnz. Collision_Chunk_3
    ld player_sprite_y
    mov %11111111, Collision_Flags
    ; Optionally, Maybe Try Assigning Based On Obstacle Type.
	jmpf .Collision_Done
.Collision_Chunk_3
    sub #1 ; 8
    bnz .Collision_Chunk_4
	ld player_sprite_y
     mov #1, Flags_2
    jmpf . Collision_Done
.Collision_Chunk_4
	sub #1
    bnz .Collision_Chunk_5 ; Move this Up
    ld player_sprite_y
    sub #18 ; Is Player Above Stone Rock?
	bp acc, 7, .Collision_Chunk_5 ; If So, Player's Cleared It + The Collision Check.
    mov #1, collision_flags
.Alternate_Collision
    bn boulder_chunk_offset, 1, .Collision_Done ; Skip Check For Collision When Not In Boulder Range.
    ; L.D. Obstacle Type Here And Determine Jump Path .Handle_Collision_Result
	ld Collision_Flags
.Collision_RegularBoulder
    ld player_sprite_y
    sub #17
    bn acc, 7, Collision_Done
    mov #255, Collision_Flags
    mov #11, stun_timer
    ; mov #0, Stun_Direction ; Meaning Left. Consider A 1 Variable Of 8 Flags.
    ; Once Grounded, Switch Directions And Keep Bouncing And Setting Bits Until Flag_Var = 255
    ; bp Flag_Bit (Direction) {When Landed, Move this Line Near .Stun_Drop + Do A "Grounded" Check.}/.
	; Alternatively, Do Stun_Bounce Same As Jump's Gravity, Capped At 2. 
	; ld Player_Sprite_Y, Add/Sub Stun_Bounce, Is Stun_Bounce <*> +/-2? Dec Stun_Bounce.
	; Once Done Bouncing And Changing Directions, Restore Control.
	; Flag Set. Skip All Other Collision In The Meantime?
    ; 7 6 5 4 3 2 1 0 ; Set, Direction., {.Up Timer.?} , [ . . Timer . . ]
.Cillision_HighBoulder ; Let's Pretend For Now. ; This time, it'll be Y < 8.
    ld Player_Sprite_Y ; Done with the L.D.C.?
    sub #8
	bp acc, 7, .Collision_HighB_Yes
	jmpf Collision_Done
.Collision_HighB_Yes
	mov
.Collision_Done

.Handle_Collision_Result
	ld Collision_Flags
	; bnz .Player_State_Collision_Done_Set
	; Instaniate A Player_Stunned Variable, And Have The Penguin Hop In Place When Stunned?
	mov #1, Player_Stunned
	; *Then, Possibly Moveing this to the Player Control Section, If Player_Stunned = 1/"Y," they'll bounce left/right on an Oscillator and up+down on the Frame Counter.
	mov #128, StunFlags ; Leftmost Flag = Direction
    mov #3, stun_rise_timer ; Actually, we'll Want To Dec this Timer Outside Of Here; Only _Set_ it Here. ; dec stun_rise_timer ; Initial Hop. -1 Y, Then 0 &And +1 Y Once it's Done.
    ; ld stun_rise_timer
    ; bz .Stun_Hop ; Move Up.!
	; jmpf .Stun_Drop
	inc Player_Sprite_Y
    ; Set1 The Flag When Timer's Up.
    ; Now, Y-Velocity = 1,
	; Then, when you come back to here, it's 1 but the Timer is 0, so now make it 2.
.Handle_Stun_Timer
	; bp player_stunned_bool, 0, .Draw_Screen
	ld stun_timer
	bz .Reset_Stun ; bp player_stunned_bool, 0, .Draw_Screen
	dec stun_timer
	; bn stun_timer, 0, .Draw_Screen
	ld stun_timer
	bp acc, 7, .Reset_Stun
	jmpf .Draw_Screen
.Reset_Stun
	; mov #1, player_stunned_bool
	mov #0, stun_timer ; Mov #Grounded, Player Y ?
    ; Now, can keep the Timer as 0 while still Locking Control Until Grounded. Might Lead To Softlocks; Need To Test.

.Draw_Screen
	; P_Draw_Background_Constant AllWhite
.BG_Offset_0
	bp player_screen_offset, 1, .BG_Offset_2
	bp player_screen_offset, 0, .BG_Offset_1
	P_Draw_Background_Constant BG_Frame_0
	jmpf .Draw_Player
.BG_Offset_1
	P_Draw_Background_Constant BG_Frame_1
	jmpf .Draw_Player
.BG_Offset_2
	bp player_screen_offset, 0, .BG_Offset_3
	P_Draw_Background_Constant BG_Frame_2
	jmpf .Draw_Player
.BG_Offset_3
	P_Draw_Background_Constant BG_Frame_3

.Draw_Player
.Standing
	bn player_standing_bool, 0, .Jumping
	mov #13, player_sprite_y
	mov #<Penguin_Standing_Mask, player_sprite_sprite_address
	mov #>Penguin_Standing_Mask, player_sprite_sprite_address+1
	P_Draw_Sprite_Mask player_sprite_sprite_address, player_sprite_x, player_sprite_y
	mov #14, player_sprite_y
	jmpf .Draw_Obstacles
.Stunned
.Jumping
	bp player_grounded_bool, 0, .Draw_Trot_L
	mov #<Penguin_Jump_Up_Mask, player_sprite_sprite_address
	mov #>Penguin_Jump_Up_Mask, player_sprite_sprite_address+1
	jmpf .Draw_Trot_Done
.Draw_Trot_L
	bp frame_counter, 3, .Draw_Trot_R
	mov	#<Penguin_Trot_1_Mask, player_sprite_sprite_address
	mov	#>Penguin_Trot_1_Mask, player_sprite_sprite_address+1
	jmpf .Draw_Trot_Done
.Draw_Trot_R
	bn frame_counter, 3, .Draw_Trot_Done
	mov	#<Penguin_Trot_2_Mask, player_sprite_sprite_address
	mov	#>Penguin_Trot_2_Mask, player_sprite_sprite_address+1
.Draw_Trot_Done
	P_Draw_Sprite_Mask player_sprite_sprite_address, player_sprite_x, player_sprite_y

.Draw_Obstacles
; jmpf .OkScrewTheBoulders ; Debugging Functions
.Draw_Obstacle_6
	ld boulder_screen_offset
	bz .Draw_Obstacle_5
	ld boulder_chunk_6
	sub #30
	bn boulder_chunk_6, 0, .Draw_Obstacle_5 ; bz .Draw_Obstacle_5
	mov #48, acc
	sub boulder_screen_offset
	st b
	mov #20, c
	P_Draw_Sprite_Mask Boulder_Sprite_Address, b, c
.Draw_Obstacle_5
	ld boulder_chunk_5
	sub #30
	bn boulder_chunk_5, 0, .Draw_Obstacle_4 ; bz .Draw_Obstacle_4
	mov #40, acc
	sub boulder_screen_offset
	st b
	mov #20, c
	P_Draw_Sprite_Mask Boulder_Sprite_Address, b, c
.Draw_Obstacle_4
	ld boulder_chunk_4
	sub #30
	bn boulder_chunk_4, 0, .Draw_Obstacle_3 ; bz .Draw_Obstacle_3
	mov #32, acc
	sub boulder_screen_offset
	st b
	mov #20, c
	P_Draw_Sprite_Mask Boulder_Sprite_Address, b, c
.Draw_Obstacle_3
	ld boulder_chunk_3
	sub #30
	bn boulder_chunk_3, 0, .Draw_Obstacle_2 ; bz .Draw_Obstacle_2
	mov #24, b
	ld b
	sub boulder_screen_offset
	st b
	mov #20, c
	P_Draw_Sprite_Mask Boulder_Sprite_Address, b, c
.Draw_Obstacle_2
	ld boulder_chunk_2
	sub #30
	bn boulder_chunk_2, 0, .Draw_Obstacle_1 ; bz .Draw_Obstacle_1
	mov #16, acc
	sub boulder_screen_offset
	st b
	mov #20, c
	P_Draw_Sprite_Mask Boulder_Sprite_Address, b, c
.Draw_Obstacle_1
	ld boulder_chunk_1
	sub #30
	bn boulder_chunk_1, 0, .Draw_Obstacle_0 ; bz .Draw_Obstacle_0
	mov #8, acc
	sub boulder_screen_offset
	st b
	mov #20, c
	P_Draw_Sprite_Mask Boulder_Sprite_Address, b, c
.Draw_Obstacle_0
	bp boulder_chunk_0, 0, .Build_Error_1; .OkScrewTheBoulders
	jmpf .OkScrewTheBoulders
.Build_Error_1
.Obstacle_0_0
	ld boulder_screen_offset
	bnz .Obstacle_0_3
	mov	#<Boulder_Sprite_Offscreen_Mask_2, half_boulder_sprite_address
	mov	#>Boulder_Sprite_Offscreen_Mask_2, half_boulder_sprite_address+1
	mov #0, b
	mov #20, c
	P_Draw_Sprite_Mask Boulder_Sprite_Address, b, c
.Obstacle_0_3
	sub #1
	bnz .Obstacle_0_4
	mov	#<Boulder_Sprite_Offscreen_Mask_3, half_boulder_sprite_address
	mov	#>Boulder_Sprite_Offscreen_Mask_3, half_boulder_sprite_address+1
	mov #1, b
	mov #20, c
	P_Draw_Sprite_Mask Half_Boulder_Sprite_Address, b, c
.Obstacle_0_4
	sub #1
	bnz .Obstacle_0_5
	mov	#<Boulder_Sprite_Offscreen_Mask_4, half_boulder_sprite_address
	mov	#>Boulder_Sprite_Offscreen_Mask_4, half_boulder_sprite_address+1
	mov #1, b
	mov #20, c
	P_Draw_Sprite_Mask Half_Boulder_Sprite_Address, b, c
.Obstacle_0_5
	sub #1
	bnz .Obstacle_0_6
	mov	#<Boulder_Sprite_Offscreen_Mask_5, half_boulder_sprite_address
	mov	#>Boulder_Sprite_Offscreen_Mask_5, half_boulder_sprite_address+1
	mov #1, b
	mov #20, c
	P_Draw_Sprite_Mask Half_Boulder_Sprite_Address, b, c
.Obstacle_0_6
	sub #1
	bnz .Obstacle_0_7
	mov	#<Boulder_Sprite_Offscreen_Mask_6, half_boulder_sprite_address
	mov	#>Boulder_Sprite_Offscreen_Mask_6, half_boulder_sprite_address+1
	mov #1, b
	mov #20, c
	P_Draw_Sprite_Mask Half_Boulder_Sprite_Address, b, c
.Obstacle_0_7
.OkScrewTheBoulders
; P_Draw_Sprite_Mask Boulder_Sprite_Address, boulder_x, boulder_y


.Blit_And_Draw_Screen
	; callf Draw_Ground
	P_Blit_Screen
	inc frame_counter

	jmpf Gameplay_Loop


