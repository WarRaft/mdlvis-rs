unit glinst;
// In this unit there are the constants and the procedure,
// which installing the videodriver in  GL mode
interface
uses Windows,OpenGL;
Var
    fNeedPal:boolean;// to use for 256 colours
    Palette:integer;// the logical palette of the application
                   // the format of a pixel
// At a palette of 256 colours the true value is installed in fNeedPal
const
    f_stand=pfd_draw_to_window or pfd_support_opengl or
            pfd_doublebuffer;
procedure giSetPixFormat(dc:hdc;flg:integer);
//===========================================
implementation
Var
   pfd:TPixelFormatDescriptor;
//============================================
// the format of a pixel
procedure giSetPixFormat(dc:hdc;flg:integer);
Var npf,nColors,i:integer;
    hHeap:THandle;        //the handle of memory block
    lpPalette:PLogPalette;
    r,g,b:byte;
Begin
 FillChar(pfd,SizeOf(pfd),0);//the initialization of structure
 pfd.dwFlags:=flg;           //the installation of flags
 npf:=ChoosePixelFormat(dc,@pfd);//the choice of format
 SetPixelFormat(dc,npf,@pfd);

 //the check of installation of palette
 if ((pfd.dwFlags and pfd_need_palette)<>0) then begin
  fNeedPal:=true;
  nColors:=1 shl pfd.cColorBits;
  hHeap:=GetProcessHeap;
  lpPalette:=HeapAlloc(hHeap,0,sizeof(TLogPalette)+
                       (nColors*sizeof(TPaletteEntry)));
  //the installation of version and elements of palette
  lpPalette^.palVersion:=$300;
  lpPalette^.palNumEntries:=nColors;
  //the rgb model
  r:=(1 shl pfd.cRedBits)-1;
  g:=(1 shl pfd.cGreenBits)-1;
  b:=(1 shl pfd.cBlueBits)-1;
  //the filling of palette by colors
  for i:=0 to nColors-1 do begin
   lpPalette^.palPalEntry[i].peRed:=(((i shr pfd.cRedShift)
                             and r)*255) div r;
   lpPalette^.palPalEntry[i].peGreen:=(((i shr pfd.cGreenShift)
                             and g)*255) div g;
   lpPalette^.palPalEntry[i].peBlue:=(((i shr pfd.cBlueShift)
                             and b)*255) div b;
  end;//of for
  //the creation of palette
  Palette:=CreatePalette(lpPalette^);
  HeapFree(hHeap,0,lpPalette);//to clear the memory
  if (Palette<>0) then begin
   SelectPalette(dc,palette,false);
   RealizePalette(dc);
  end;//of if
 end;//of if
End;//pf procedure
//----------------------------
initialization
 fNeedPal:=false;
end.
