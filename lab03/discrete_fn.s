# Дирректива .globl определяет функции, которые мы хотим экспортировать
# похоже на размещение объявления функции в заголовке в Cи
.globl f

.data
# asciiz директива используется дял размещения строк
# asciiz автоматически добавит нулевой символ в конец строки
# FIXME исправьте строки, чтобы они выдавали корректные отладочные значения 
case1:   .asciiz "f(-11) should be 50, and it is: "
case2:   .asciiz "f(-10) should be 2, and it is: "
case3:   .asciiz "f(-9) should be 48, and it is: "
case4:   .asciiz "f(-8) should be 17, and it is: "
case5:   .asciiz "f(-7) should be 13, and it is: "
case6:   .asciiz "f(-6) should be 35, and it is: "
case7:   .asciiz "f(-5) should be -5, and it is: "

# FIXME Разместите значения из вашего варианта в этом массиве 
output: .word   50,2,48,17,13,35,-5

.text
main:
	######### перебор случаев, случай 1 (case1) #########
    # загружаем адрес строки case1 в a0
    # это послужит аргументом функции print_str
    la a0, case1 
    # Выводим строку по адресу case1
    jal print_str 
    # Загружаем первый аргумент функции f в a0
    # FIXME Подставьте первый аргумент case1
    li a0, -11 
    # загружаем второй аргумент функции f в a1
    # `output` -- это указатель на массив, который содержит возможные выходные значения f
    la a1, output
    # выполняем f(case1)
    jal f     
    # f вернет результат f(-3) в регистре a0
    # чтобы отобразить это значение мы вызовем print_int
    # print_int ожидает значение аргумента в регистре a0
    # значение уже находится в a0, не требуется перемещений
    jal print_int
    # print a new line
    jal print_newline

	######### перебор случаев, случай 2 (case2) #########
    la a0, case2
    jal print_str
    # FIXME Подставьте первый аргумент case1
    li a0, -10
    la a1, output
    jal f                
    jal print_int
    jal print_newline

	######### перебор случаев, случай 3 (case3) #########
    la a0, case3
    jal print_str
    # FIXME Подставьте первый аргумент case1
    li a0, -9
    la a1, output
    jal f               
    jal print_int
    jal print_newline

	######### перебор случаев, случай 4 (case4) #########
    la a0, case4
    jal print_str
    # FIXME Подставьте первый аргумент case1
    li a0, -8
    la a1, output
    jal f               
    jal print_int
    jal print_newline

	######### перебор случаев, случай 5 (case5) #########
    la a0, case5
    jal print_str
    # FIXME Подставьте первый аргумент case1
    li a0, -7
    la a1, output
    jal f                
    jal print_int
    jal print_newline

	######### перебор случаев, случай 6 (case6) #########
    la a0, case6
    jal print_str
    # FIXME Подставьте первый аргумент case1
    li a0, -6
    la a1, output
    jal f               
    jal print_int
    jal print_newline

	######### перебор случаев, случай 7 (case7) #########
    la a0, case7
    jal print_str
    # FIXME Подставьте первый аргумент case1
    li a0, -5
    la a1, output
    jal f                
    jal print_int
    jal print_newline

	# передаем 10 в ecall чтобы завершить программу
    li a0, 10
    ecall

# f принимает два аргумента:
# a0 значение для которого мы хотим вычислить функцию f
# a1 адрес выходного ("output") массива, содержащего все допустимые варианты.
f:
    # FIXME
    # YOUR CODE GOES HERE!
    # ||a0|*4-44|=смещение 
      mv s11,a0
      addi s10,zero,-1
      mul s11,s11,s10
      
      addi s9,zero,4
      mul s11,s11,s9
      
      addi s11,s11,-44
      mul s11,s11,s10
      
      add t0,a1,s11
      lw a0,0(t0)
    jr ra               

# печатает одно целое число
# вход: a0: число на печать
# ничего не возвращает
print_int:
	# to print an integer, we need to make an ecall with a0 set to 1
    # the thing that will be printed is stored in register a1
    # this line copies the integer to be printed into a1
    mv a1, a0
    # set register a0 to 1 so that the ecall will print
    li a0, 1
    # print the integer
    ecall
    # return to the calling function
    jr    ra

# печатает строку
print_str:
    mv a1, a0
    li a0, 4 # tells ecall to print the string that a1 points to
    ecall
    jr    ra

print_newline:
    li a1, '\n'
    li a0, 11 # tells ecall to print the character in a1
    ecall
    jr    ra