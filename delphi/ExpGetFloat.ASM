format MS COFF		     ;формат - линкуемый файл
section '.text' code readable executable ;секция кода
public	    ExpGetFloat

;функция для конверсии символов во float-число:
;ExpGetFloat(StartAddr,var Data)
;Возвращает непосредственно integer-число (delta-смещение),
;в DATA заносятся требуемые данные
;АЛГ.:
;eax - StartAddr
;esi - текущий адрес
;edi - хранит степень (exp-часть)
;edx - @data
;ecx - хранилище символа
;ebp - хранилище минуса (<>0 - есть минус)
;[esp] - резерв для обмена данными
;[esp+4] - 10 (константа)
ExpGetFloat:			    ;eax=StartAddr, edx=@data
 push	esi edi ebp
 push	dword 10		    ;константа
 push	eax			    ;резерв
 xor	ebp,ebp
 mov	esi,eax 		    ;esi=адрес
 fldz				    ;0 - в стек сопр.
 ;0. Чтение минуса (если нужно)
  movzx ecx,byte [esi]
  cmp	ecx,'-'
  jne	@f

  dec	ebp			    ;ebp=-1
  inc	esi
 ;1. Чтение целой части
 @@:
  movzx ecx,byte [esi]		    ;читать очередной символ
  cmp	ecx,'0'
  jb	EGF_Fract
  cmp	ecx,'9'
  ja	EGF_Fract

  sub	ecx,30h 		    ;конверсия в цифру
  fimul dword [esp+4]		    ;*10
  mov	[esp],ecx		    ;в стек
  fiadd dword [esp]		    ;+цифра
  inc	esi			    ;к след. символу
 jmp	@b			    ;конец цикла

 EGF_Fract:

 ;2. Чтение дробной части
 movzx	ecx,byte [esi]
 cmp	ecx,'.' 		    ;перед дробной частью должна идти точка (.)
 jne	EGF_Exp

 inc	esi			    ;к первому символу дроби
 mov	dword [esp+4],0.1	    ;множитель для дробной части
 fldz				    ;загрузка нуля в дробную часть
 fld	dword [esp+4]		    ;в стек (прибавка)
 fld	st0			    ;0.1
 @@:
  movzx ecx,byte [esi]		    ;читать очередной символ
  cmp	ecx,'0'
  jb	EGF_Compose
  cmp	ecx,'9'
  ja	EGF_Compose

  sub	ecx,30h
  mov	[esp],ecx
  fild	dword [esp]		    ;загрузка числа
  fmul	st0,st2
  faddp st3,st0 		    ;кусок добавлен
  fmul	st1,st0 		    ;домножить прибавку на 0.1
  inc	esi			    ;к след. символу
 jmp	@b			    ;конец цикла

 ;3. Их совмещение
 EGF_Compose:
 ffree	st0			    ;избавимся от 0.1 и прибавки
 fincstp
 ffree	st0
 fincstp

 faddp	st1,st0 		    ;складываем число с дробной частью. Стек чист.

 ;4. Чтение степени (читается как целое. Знак будет ebp)
 EGF_Exp:
 ;Учёт минуса (имеется в виду - минуса числа, а не экспоненты)
 test	ebp,ebp
 jz	@f
  fchs				    ;смена знака
 @@:

 movzx	ecx,byte [esi]		    ;загрузить символ (для степени - 'e')
 cmp	ecx,'e'
 jne	EGF_Ret 		    ;нет экспоненциальной части

 inc	esi			    ;к 1 символу (это м.б. знак степени - +/-)
 xor	ebp,ebp
 movzx	ecx,byte [esi]		    ;читать символ (возможно, знак)
 cmp	ecx,'+' 		    ;плюс. Пропускаем
 jne	@f
  inc	esi
 @@:
 cmp	ecx,'-'
 jne	@f
  dec	ebp
  inc	esi
 @@:

 xor	edi,edi 		    ;edi=0 (пока нет степени)
 @@:
  movzx ecx,byte [esi]
  cmp	ecx,'0'
  jb	EGF_ApplyExp
  cmp	ecx,'9'
  ja	EGF_ApplyExp
				    ;цифра найдена
  lea	edi,[edi*4+edi]
  sub	ecx,30h
  lea	edi,[edi*2+ecx] 	    ;edi=edi*10+ecx
  inc	esi
 jmp	@b			    ;конец цикла

 ;5. Возврат
 EGF_ApplyExp:
 cmp	edi,38			    ;проверка на выход за предел табл.
 jna	@f
  mov	edi,38
 @@:

 mov	edi,[Fr_Tbl+edi*4]	    ;загрузка к-ты степени
 mov	[esp],edi

 test	ebp,ebp 		    ;в случае отриц. знака - перевернём
 fld   dword [esp]
 jz	@f
  fdivp st1,st0
;  fidiv dword [esp]
;  fmulp st1,st0                    ;*1/exp
  jmp	EGF_Ret
 @@:
 fmul  st1,st0			    ;*exp

 EGF_Ret:
 fstp	dword [edx]		    ;извлечь число
 add	esp,8			    ;очистка стека
 sub	esi,eax
 mov	eax,esi
 pop	ebp edi esi
ret
;======================================================
section '.data' data readable writeable  ;секция данных
 ;Набор экспоненциальных множителей
 Fr_Tbl dd 1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9,\
	   1e10,1e11,1e12,1e13,1e14,1e15,1e16,1e17,1e18,1e19,\
	   1e20,1e21,1e22,1e23,1e24,1e25,1e26,1e27,1e28,1e29,\
	   1e30,1e31,1e32,1e33,1e34,1e35,1e36,1e37,1e38