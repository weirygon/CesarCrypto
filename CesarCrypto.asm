
	# IDE: MARS 4.5
	# JAVA JDK: 18
	# MIPS 32
	
.data

	#Posts
	
	logo: .asciiz "\N###############################################\n#   _____ ______  _____         _____         #\n#  / ____|  ____|/ ____|  /\\   |  __ \\        #\n# | |    | |__  | (___   /  \\  | |__) |       #\n# | |    |  __|  \\___ \\ / /\\ \\ |  _  /        #\n# | |____| |____ ____) / ____ \\| | \\ \\        #\n#  \\_____|______|_____/_/____\\_\\_|__\\_\\____   #\n#   / ____|  __ \\\ \\\   / /  __ \\\__   __/ __ \\\  #\n#  | |    | |__) \\\ \\\_/ /| |__) | | | | |  | | #\n#  | |    |  _  / \\\   / |  ___/  | | | |  | | #\n#  | |____| | \\\ \\\  | |  | |      | | | |__| | #\n#   \\\_____|_|  \\\_\\\ |_|  |_|      |_|  \\\____/  #\n#\t\t\t\t\t      #\n###############################################\nBy: Weiry\n\n"
	msg_empty: .asciiz "\n"
	msg_op: .asciiz "Options: \n1 - Encrypt\n2 - Decrypt\n=> "
	msg_load_op: .asciiz "\nLoad string of:\n1 - Terminal\n2 - File\n=>"
	msg_file_input: .asciiz "Inform the file with the directory: "
	msg_factor: .asciiz "\nInform the value of factor: "
	msg_terminal_in: .asciiz "\nType the text:\n"
	msg_ln: .asciiz "\n===============================================\n"
	msg_ln_original: .asciiz, "\n=====ORIGINAL==================================\n"
	msg_ln_encrypt: .asciiz "\n=====ENCRYPT===================================\n" 
	msg_ln_decrypt: .asciiz "\n=====DECRYPT===================================\n" 
	msg_open: .asciiz "\n[*] Opening... "
	msg_create: .asciiz "\n[*] Creating... "
	msg_success: .asciiz "\n[+] Success!"
	
	msg_erro_option: .asciiz "\n[!] Error: Unknown option! \n"
	msg_erro_open: .asciiz "\n[!] Error: File not found! Check the directory.\n"
	msg_erro_create: .asciiz "\n[!] Error: File cant be create!\n"
	msg_erro_factor: .asciiz "\n[!] Error: The factor dont be negative!\n"
	
	#Varibles
	
	#$s0 = descriptor of file load
	#$s1 = descriptor of file create
	#$s2 = option : 1 - Encrypt
	#		2 - Decrypt
	#$s3 = encryption factor
	#$s4 = size of string
	#$s5 = optin :  1 - Terminal
	#		2 - File
	
	
	local_File_In:	.align 1	#Address input file
			.space 180	#"C:/Users/User/Documents/Org/T1/teste.txt"
			
	buffer_File_In: .space 1024	#Maximum size of input file: 1MB
	
	local_File_Out:	.align 1
			.space 200
	
	buffer_File_Out:.space 1024

.text

	.main:
		
		#Print Menu
		la $a0, logo
		jal printString
		la $a0, msg_op
		jal printString
		
		#Option
		li $v0, 5
		syscall
		move $s2, $v0	#s2 = v0
		
		li $t0, 2
		la $a0, msg_erro_option
		blez $s2, exit
		bgt $s2, $t0, exit 
		
		#Factor
		la $a0, msg_factor
		jal printString
		li $v0, 5
		syscall
	
		la $a0, msg_erro_factor	#Loading message error of factor
		bltz $v0, exit
		
		move $s3, $v0	#s3 = v0
	
		
		#OptionLoad
		li $t2, 2	# 2 - file
		
		la $a0, msg_load_op
		li $v0, 4
		syscall	#Printing Options
		
		li $v0, 5	#Read keyboard
		syscall
		
		move $s5, $v0
		
		#errorOptionLoad
		la $a0, msg_erro_option
		blez $s5, exit
		bgt $s5, $t2, exit
		
		beq $s5, $t2, addressFile	#File
		
		#terminal
		la $a0, msg_terminal_in
		jal printString
		
		li $v0, 8	#Read String
		la $a0, buffer_File_In	#scanf("%s", buffer_File_In)
		la $a1, 1024	#Maximun Size 1MB
		syscall
		
		j crypting
		
		addressFile:
		
			la $a0, msg_file_input
			jal printString
		
			li $v0, 8
			la $a0, local_File_In
			li $a1, 180
			syscall 
		
			jal removeEnter	#Removing Enter of end string
			
			la $a0, msg_open
			jal printString
			la $a0, local_File_In
			jal printString
		
		
			#Opening file read mode
			li $v0, 13	#fopen($a0, $a1)
			la $a0, local_File_In	#$a0 = &local_File_In
			li $a1, 0 	#$a1 = 0 : Read Mode
			syscall		#Descriptor of file going to $v0
		
			la $a0, msg_erro_open	#Loading Message Error
			bltz $v0, exit	#Error in open file
	
			move $s0, $v0	#Copying Descriptor for $s0
		
		
		
			#Put buffer in buffer_File_in
			move $a0, $s0	#a0 = s0
			li $v0, 14	#Read file references for a0
			la $a1, buffer_File_In	#Parameter 1: &buffer_File_In
			li $a2, 1024	#Parameter 2: size of file
			syscall
		
			la $a0, ($s2)
			jal rename
		
			la $a0, msg_create
			jal printString
			la $a0, local_File_Out
			jal printString
		
			#Opening file read mode
			li $v0, 13	#fopen($a0, $a1)
			la $a0, local_File_Out	#$a0 = &local_File_In
			li $a1, 1 	#$a1 = 0 : Write Mode
			syscall		#Descriptor of file going to $v0
		
			la $a0, msg_erro_create	#Loading Message Error
			bltz $v0, exit	#Error in open file
	
			move $s1, $v0	#Copying Descriptor for $s1
		
		crypting:
		
			li $t0, 1	#Encrypt
			li $t1, 2	#Decrypt
			beq $s2, $t0, encrypt
			beq $s2, $t1, decrypt
		
		success:
		
			li $t0, 1	#Terminal
			li $t1, 2	#File
			
			beq $s5, $t1, successFile
		
		successTerminal:
			
			beq $s2, $t1, msgDecrypt
			
			la $a0, msg_ln_original
			jal printString
			
			la $a0, buffer_File_In
			jal printString
			
			la $a0, msg_ln_encrypt
			jal printString
			
			la $a0, buffer_File_Out
			jal printString
			
			la $a0, msg_ln
			jal printString
			
			la $a0, msg_success
			j exit
			
			msgDecrypt:
			
			la $a0, msg_ln_encrypt
			jal printString
			
			la $a0, buffer_File_In
			jal printString
			
			la $a0, msg_ln_decrypt
			jal printString
			
			la $a0, buffer_File_Out
			jal printString
			
			la $a0, msg_ln
			jal printString
			
			la $a0, msg_success
			j exit
		
		successFile:
			
			#Writing in new file
			li $v0, 15
			move $a0, $s1
			la $a1, buffer_File_Out
			move $a2, $s4
			syscall
			
			#Closing Files
			li $v0, 16
			move $a0, $s0
			syscall
		
			li $v0, 16
			move $a0, $s1
			syscall

			la $a0, msg_success
		exit:
			jal printString
			
			li $v0, 10	#exit()
			syscall
	#End Main
	
	printString:
	
		li $v0, 4
		syscall
		
		jr $ra
	#End PrintString
	
	removeEnter:
	
		li $t1, 10	#t1 = \n
		li $t0, 0	#t0 = Position where is \n
		
		runStr:
			lb $t2, local_File_In($t0)
			beq $t2, $t1, remove
			addi $t0, $t0, 1
			j runStr
		remove:
			sb $zero, local_File_In($t0)	#Replacing \n with \00
		jr $ra
	#End RemoveEnter
	
	rename:
		li $t0, 0	#t0 = position
		li $t2, 46	#t2 = .
		
		whileRename:
		
			beq $t1, $t2, outRename
		
			lb $t1, local_File_In($t0)
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			j whileRename
			
		outRename:
			sub $t0, $t0, 1
			li $t2, 2
			beq $a0, $t2, decryptRename 
			
			#Insert E
			li $t1, 69
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert n
			li $t1, 110
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert c
			li $t1, 99
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
		
			#Insert r
			li $t1, 114
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
		
			#Insert y
			li $t1, 121
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert p
			li $t1, 112
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert t
			li $t1, 116
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert .
			li $t1, 46
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert t
			li $t1, 116
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert x
			li $t1, 120
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert t
			li $t1, 116
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
		
			jr $ra
		decryptRename:
	
			#Insert D
			li $t1, 68
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert e
			li $t1, 101
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert c
			li $t1, 99
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
		
			#Insert r
			li $t1, 114
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
		
			#Insert y
			li $t1, 121
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert p
			li $t1, 112
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert t
			li $t1, 116
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert .
			li $t1, 46
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert t
			li $t1, 116
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert x
			li $t1, 120
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
			
			#Insert t
			li $t1, 116
			sb $t1, local_File_Out($t0)
			add $t0, $t0, 1
	
			jr $ra
	#EndRename
	
	encrypt:
	
		la $a0, msg_empty 	#Clear Buffer 
		li $t0, 0
		li $t3, 33	#t3 = minimun ascii
		li $t4, 126	#t4 = maximum ascii		
		
		whileEncrypt:
			
			lb $t1, buffer_File_In($t0)	#Caracter
			move $t2, $t1	#t2 = t1
			
			blt $t1, $t3, ignore	#Skip add
			bgt $t1, $t4, ignore	#Skip add
								
			add $t2, $t2, $s3 #Adding factor
			
			subCaracter:
				
				ble $t2, $t4, ignore	#Skip
				sub $t5, $t2, $t4
				sub $t5, $t5, 1	#t5--;
				add $t2, $t3, $t5
				j subCaracter
			
			ignore:
			
				sb $t2, buffer_File_Out($t0)
			
				beq $t1, $zero, outEncrypt	#End of String
				addi $t0, $t0, 1
				j whileEncrypt
			
		outEncrypt:
			move $s4, $t0	#S6 = t0 Size of content
			j success
	#End Encrypt
	
	decrypt:
		la $a0, msg_empty 	#Clear Buffer 
		li $t0, 0	#t0 = position
		li $t3, 33	#t3 = minimun ascii
		li $t4, 126	#t4 = maximum ascii		
		
		whileDecrypt:
			
			lb $t1, buffer_File_In($t0)	#Caracter
			move $t2, $t1	#t2 = t1
			blt $t2, $t3, skip
			
			sub $t2, $t2, $s3 #Subing factor
			
			subChar:
				
				bge $t2, $t3, skip
				sub $t5, $t3, $t2
				bltzal $t5, modulo
				sub $t5, $t5, 1	#t5--;
				sub $t2, $t4, $t5
				
				j subChar
			
			skip:
			
				sb $t2, buffer_File_Out($t0)
			
				beq $t1, $zero, outDecrypt	#End of String
				addi $t0, $t0, 1
				j whileDecrypt
			
		outDecrypt:
			move $s4, $t0	#S6 = t0 Size of content
			j success
	#End Encrypt
	
	modulo:
		mulo $t5, $t5, -1	# t5 = t5 * -1
		add $t5, $t5, $t3
		
		jr $ra
	#End Modulo
