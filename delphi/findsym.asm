format MS COFF		     ;формат - линкуемый файл
section '.text' code readable executable ;секция кода
public	    FindSym

;функция для поиска символа:
;FindSym(StartAddr,sym_code)
;Возвращает смещение этого символа относительно нач. адреса
FindSym:			  ;eax=StartAddr, edx=sym_code
 push	edi
 mov	edi,eax 		  ;StartAddr
 mov	eax,edx 		  ;sym_code в eax
 mov	edx,edi 		  ;ещё раз скопируем
 mov	ecx,-1			  ;огромное кол-во итераций для поиска
 repne	scasb			  ;ищем
 sub	edi,edx 		  ;находим смещение
 mov	eax,edi 		  ;вернём его
 dec	eax			  ;коррекция лишнего прибавления
 pop	edi
ret
