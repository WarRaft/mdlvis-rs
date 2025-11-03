format MS COFF		     ;формат - линкуемый файл
section '.text' code readable executable ;секция кода
public	    ExpGoToCipher

;Экспериментальная функция для поиска ближайшей цифры.
;ExpGoToCipher(StartAddr)
;Возвращает смещение первого символа цифры
ExpGoToCipher:			  ;eax=StartAddr
 mov	ecx,eax 		  ;скопировать
 @@:
  movzx edx,byte [eax]		  ;читаем байт
  cmp	edx,'-' 		  ;сравниваем с минусом
  je	EGTC_End
  inc	eax			  ;двигаемся далее
  cmp	edx,'0'
 jb	@b
  cmp	edx,'9'
 ja	@b
  dec	eax
EGTC_End:
  sub	eax,ecx 		  ;находим смещение
ret
