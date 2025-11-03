unit unTex;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, OpenGL,GLInst,mdlWork,mdlDraw,objedut, ExtCtrls,
  StdCtrls, Buttons,Math;

type
  TfrmTex = class(TForm)
    sb_instrum: TScrollBox;
    sb_info: TStatusBar;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    Panel1: TPanel;
    Label1: TLabel;
    cb_color: TComboBox;
    sb_cross: TSpeedButton;
    sb_zoom: TSpeedButton;
    pn_zoom: TPanel;
    Label5: TLabel;
    ed_zoom: TEdit;
    pn_stat: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ed_x: TEdit;
    ed_y: TEdit;
    pn_info: TPanel;
    l_vcount: TLabel;
    l_vselect: TLabel;
    sb_move: TSpeedButton;
    sb_undo: TSpeedButton;
    Label7: TLabel;
    Label8: TLabel;
    ed_ix: TEdit;
    Label9: TLabel;
    ed_iy: TEdit;
    Label6: TLabel;
    sb_select: TSpeedButton;
    sb_imove: TSpeedButton;
    sb_irot: TSpeedButton;
    sb_izoom: TSpeedButton;
    b_proec: TButton;
    TexWorkArea: TPanel;
    Label10: TLabel;
    cb_texname: TComboBox;
    PaintBox1: TPaintBox;
    b_collapse: TButton;
    N2: TMenuItem;
    N3: TMenuItem;
    b_uncouple: TButton;
    sb_mirrorx: TSpeedButton;
    sb_mirrory: TSpeedButton;
    N4: TMenuItem;
    pn_plane: TPanel;
    l_plane: TLabel;
    ed_plane: TEdit;
    ud_plane: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure _FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure cb_colorChange(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_zoomClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sb_crossClick(Sender: TObject);
    procedure ed_zoomExit(Sender: TObject);
    procedure ed_zoomKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sb_moveClick(Sender: TObject);
    procedure ed_xExit(Sender: TObject);
    procedure ed_xKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_yExit(Sender: TObject);
    procedure ed_yKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sb_undoClick(Sender: TObject);
    procedure sb_imoveClick(Sender: TObject);
    procedure sb_selectClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_ixExit(Sender: TObject);
    procedure ed_ixKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sb_irotClick(Sender: TObject);
    procedure sb_izoomClick(Sender: TObject);
    procedure b_proecClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure cb_texnameChange(Sender: TObject);
    procedure cb_texnameExit(Sender: TObject);
    procedure cb_texnameKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure b_collapseClick(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure N3Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure b_uncoupleClick(Sender: TObject);
    procedure sb_mirrorxClick(Sender: TObject);
    procedure sb_mirroryClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure ud_planeClick(Sender: TObject; Button: TUDBtnType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTex: TfrmTex;
  dc:HDC;hrc:HGLRC;
  CurMaterial,COStart:integer;
  Excentry,Zoom,ZoomX,ZoomY,TransX,TransY:GLfloat;
  dirName:string;
  IsExit,bExit,IsTexWrap:boolean;
implementation

uses frmmain;
var {IsIJLLoaded,}IsMouseDown,IsKeyDown,IsArea,IsWheel,
    IsRightMouseDown:boolean;
    r,g,b:GLfloat;              //цвет команды
    rAngle:GLfloat;             //угол поворота
    InstrumStatus,OldMouseX,OldMouseY,
    ClickX,ClickY:integer;
Const isSelect=1;isZoom=2;isMove=3;isRotate=4;

      crZoomCur=10;
    {dbg,tWidth,tHeight:integer;//!dbg}
{$R *.DFM}
//Создание формы
procedure TfrmTex.FormCreate(Sender: TObject);
//Var hIJL:hInst;
begin
 dc:=GetDC(TexWorkArea.handle);//получить контекст
 giSetPixFormat(dc,f_stand);//установить формат пикселя
 hrc:=wglCreateContext(dc); //получить контекст воспроизведения
 wglMakeCurrent(dc,hrc);    //сделать контекст текущим
 glMatrixMode(gl_projection);//матрица модели
  glLoadIdentity;           //загрузить единичную
 glMatrixMode(gl_modelview);//матрица вида
  glLoadIdentity;           //загрузить единичную
  glTranslatef(-1,-1,0);

 //Прежде всего, загрузим IJL
{ hIJL:=LoadLibrary('ijl15.dll');  //попытка загрузки
 @ijlInit:=GetProcAddress(hIJL,'ijlInit');
 @ijlRead:=GetProcAddress(hIJL,'ijlRead');
 @ijlFree:=GetProcAddress(hIJL,'ijlFree');
 @ijlWrite:=GetProcAddress(hIJL,'ijlWrite');
 IsIJLLoaded:=true;}
 if (@ijlInit=nil) or (@ijlRead=nil) or (@ijlFree=nil) then begin
{  MessageBox(0,'Библиотека ijl15.dll не найдена,'#13#10+
               'загрузка blp-текстур невозможна.',
               'ВНИМАНИЕ:',mb_iconstop or mb_applmodal);}
//  IsIJLLoaded:=false;
 end;//of if
end;

//при удалении формы
procedure TfrmTex.FormDestroy(Sender: TObject);
begin
 wglMakeCurrent(0,0);   //освободить контекст
 wglDeleteContext(hrc); //удалить его
 bExit:=true;
end;

procedure TfrmTex._FormPaint(Sender: TObject);
begin
 if IsExit then ModalResult:=mrCancel;
 glClearColor(0.8,0.8,0.8,1.0);//цвет фона
 glClear(GL_COLOR_BUFFER_BIT); //очистка буфера

 glEnable(GL_BLEND);              //режим смешения
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
 glEnable(GL_CULL_FACE);          //режим отсечения
 glCullFace(GL_FRONT);            //лицевая сторона
 glEnable(GL_TEXTURE_2D);
// glCallList(Materials[CurMaterial].ListNum);
 glColor3f(1,1,1);
 glBegin(GL_QUADS);
    glTexCoord2f(-10,-10);glVertex2f(-10,-10);
    glTexCoord2f(10,-10);glVertex2f(10,-10);
    glTexCoord2f(10,10);glVertex2f(10,10);
    glTexCoord2f(-10,10);glVertex2f(-10,10);
 glEnd;

 glDisable(GL_CULL_FACE);
 glDisable(GL_BLEND);

 //Изобразим разметку и точки с линиями:
 glDisable(GL_TEXTURE_2D);
 glCallList(TexListNum);
 SwapBuffers(dc);
end;

//попытка начать работу: старт редактора текстур
procedure TfrmTex.FormShow(Sender: TObject);
Var ps,i,j,MaxCoords:integer;
begin
 if EditorMode<>emVertex then b_uncouple.visible:=false
 else b_uncouple.visible:=true;
 CurrentCoordID:=0;
 MaxCoords:=100;                  //пока число к-т неограничено
  //Заполнение списка именами текстур
 TexWorkArea.Cursor:=crArrow;
 wglMakeCurrent(dc,hrc);
 cb_texname.tag:=-1;
 cb_texname.items.text:='';
 ed_ix.text:='';
 ed_iy.text:='';
 for i:=0 to CountOfTextures-1 do if length(Textures[i].FileName)>3 then begin
  cb_texname.Items.Text:=cb_texname.items.text+Textures[i].FileName+#13#10;
 end;//of if/for i
// cb_texname.tag:=0;
 cb_texname.ItemIndex:=0;
// application.processmessages;
 cb_texname.tag:=0;
 cb_texname.Text:=cb_texname.Items.Strings[0];
 //инициализация
 sb_cross.down:=true;sb_select.down:=true;
 InstrumStatus:=isSelect;
 sb_undo.enabled:=false;
 COStart:=CountOfUndo;
// CountOfUndo:=0;
 b_proec.enabled:=false;
 sb_imove.enabled:=false;
 b_collapse.enabled:=false;
 sb_irot.enabled:=false;
 sb_izoom.enabled:=false;
 sb_mirrorx.enabled:=false;
 sb_mirrory.enabled:=false;
 b_uncouple.enabled:=false;
 IsTexWrap:=false;
 cb_color.text:='Красный';
 cb_color.ItemIndex:=0;
 CurMaterial:=Geosets[GetIDOfSelGeoset].MaterialID;
 //находим имя каталога с моделью
 dirName:=frm1.od_file.FileName;
 ps:=length(dirName);
 while (dirName[ps]<>'\') and (ps>0) do dec(ps);
 Delete(dirName,ps,length(dirName)-ps+1);
 //Сформируем список и масштаб
  wglMakeCurrent(dc,hrc);
  glEnable(GL_TEXTURE_2D);
  if not CreateAllTextures(dirName,r,g,b) then IsExit:=true;
  if not MakeMaterialList(CurMaterial) then IsExit:=true;

  Excentry:=Materials[CurMaterial].Excentry;
//  if not MakeMaterialList(CurMaterial,dirName,Excentry,r,g,b) then IsExit:=true;
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
//  if Excentry=1 then
  if Excentry>1 then glScalef(2*Zoom,-2*Zoom/Excentry,1)
                else glScalef(2*Zoom*Excentry,-2*Zoom,1);
//                glScalef(2,-2,1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(TransX-0.5,TransY-0.5,0);
 //Переносим выделенные вершины в TexVertexList
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
  if not IsSelected then continue;
  SetLength(TexVertexList,VertexCount);
  TexVertexCount:=VertexCount;
  TexSelVertexCount:=0;
  for i:=0 to VertexCount-1 do TexVertexList[i]:=VertexList[i];
  //Подсчитываем кол-во текстурных плоскостей
  if Geosets[j].CountOfCoords<MaxCoords
  then MaxCoords:=Geosets[j].CountOfCoords;
 end;//of for j
 //Составим GL-список всей разметки и вершин
 MakeTVList(dc,hrc,CurrentCoordID);
 CalcTexVertex2D(TexWorkArea.Clientheight);//расчет 2D-вершин

 //Теперь - установка кнопок и др.
 l_vcount.caption:='Всего вершин: '+inttostr(GetSumCountOfTexVertices);
 l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelTexVertices);

 //Проверим, нужен ли переключатель плоскостей
 if MaxCoords>1 then begin
  ud_plane.tag:=-1;
  pn_plane.visible:=true;
  ud_plane.max:=MaxCoords-1;
  ed_plane.text:='0';
  ud_plane.position:=0;
  ud_plane.tag:=0;
 end else pn_plane.visible:=false;

 //И, наконец, масштабирование формы:
 //Разворот окна на весь экран
 if frmTex.tag=0 then begin
  frmTex.tag:=1;
  SendMessage(frmTex.handle,WM_SYSCOMMAND,SC_MAXIMIZE,0);
 end;//of if

 cb_colorChange(Sender);
 cb_texname.Text:=cb_texname.Items.Strings[0];
end;

//при выходе из редактора текстур
procedure TfrmTex.FormHide(Sender: TObject);
begin
 glDeleteLists(Materials[CurMaterial].ListNum,1);
 Materials[CurMaterial].ListNum:=-1;
 glDeleteLists(TexListNum,1);
end;

//Смена цвета команды
procedure TfrmTex.cb_colorChange(Sender: TObject);
Var index{,i}:integer;
const colors:array[1..13,1..3] of GLfloat=
      ((1,0,0),(0,0,1),(24/255,231/255,189/255),
       (82/255,0,132/255),(1,1,0),(1,138/255,8/255),
       (0,1,0),(231/255,89/255,173/255),(148/255,150/255,148/255),
       (123/255,190/255,247/255),
       (8/255,97/255,66/255),(74/255,40/2550,0),(0,0,0));
begin
 index:=cb_color.ItemIndex+1;
 cb_color.text:=cb_color.Items.Strings[index-1];
 if Index=0 then begin index:=1;cb_color.text:='Красный';end;
 r:=colors[index,1];g:=colors[index,2];b:=colors[index,3];

 //перерисовать
 TexWorkArea.SetFocus;
// glDeleteLists(Materials[CurMaterial].ListNum,1);
 if not CreateAllTextures(dirName,r,g,b) then exit;
 if not MakeMaterialList(CurMaterial) then exit;
 _FormPaint(Sender);
end;

//проверяет, выделена ли вершина, и:
//Ctrl/Shift не нажаты - инвертирует ее выделение
//Shift нажата - добавляет к выд.
//Ctrl нажата - убирает из выд.
procedure DoSelect(geoID,vnum:integer;act:TShiftState);
Var i:integer;
Begin with geoobjs[geoID] do begin
 //При определенном значении флага act очистить список выделенного
 if act=[] then begin
  TexSelVertexList:=nil;
  TexSelVertexCount:=0;
 end;//of if
 //ищем нужную вершину
 for i:=0 to TexSelVertexCount-1 do if TexSelVertexList[i]=vnum then begin
   //вершина выделена
   if ssShift in act then exit; //вершина уже в списке
   TexSelVertexList[i]:=TexSelVertexList[TexSelVertexCount-1];
   dec(TexSelVertexCount);
   SetLength(TexSelVertexList,TexSelVertexCount);//убрать из выделения
   //Теперь - приводим в соответствие к-ты и кнопки
   FindTexCoordCenter;              //найти центр
   frmTex.ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
   frmTex.ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
   exit;                             //готово
 end;//of if/for
 //не выделена!
 if ssCtrl in act then exit;//выйти, вершины уже нет
 inc(TexSelVertexCount);    //теперь вершин выделено на 1 больше
 SetLength(TexSelVertexList,TexSelVertexCount);//увеличить список
 TexSelVertexList[TexSelVertexCount-1]:=vNum;

 //Теперь - приводим в соответствие к-ты и кнопки
 FindTexCoordCenter;              //найти центр
 frmTex.ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
 frmTex.ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
end;End;

//Пытается выделить все треугольники текстуры,
//в который попадает вершина (x,y).
//Если это ей удаётся,
//выделяются треугольники и возвращается true.
function MakeTexTriangleSelection(x,y:integer;act:TShiftState):boolean;
Var i,ii,j,num1,num2,num3,numv1,numv2,numv3:integer;
    v,vt1,vt2,vt3:TVertex;
    IsNum1,IsNum2,IsNum3:boolean;
Begin
 Result:=false;v[1]:=x;v[2]:=y;

 for j:=0 to CountOfGeosets-1 do with Geosets[j],GeoObjs[j] do begin
  if not IsSelected then continue;
  //Цикл поиска верхнего теугольника
  i:=0;
  while i<High(Faces[0]) do begin
   //1. Считываем номера вершин треугольника
   num1:=Faces[0,i]+1;
   num2:=Faces[0,i+1]+1;
   num3:=Faces[0,i+2]+1;
   //2. Ищем эти номера в списке текстурных вершин
   IsNum1:=false;IsNum2:=false;IsNum3:=false;
   for ii:=0 to TexVertexCount-1 do begin
    if TexVertexList[ii]=num1 then begin IsNum1:=true;numv1:=ii;end;
    if TexVertexList[ii]=num2 then begin IsNum2:=true;numv2:=ii;end;
    if TexVertexList[ii]=num3 then begin IsNum3:=true;numv3:=ii;end;
   end;//of for ii
   if not (IsNum1 and IsNum2 and IsNum3) then begin
    i:=i+3;
    continue;
   end;//of if
   vt1[1]:=TexVertices2D[numv1].x;
   vt1[2]:=TexVertices2D[numv1].y;
   vt2[1]:=TexVertices2D[numv2].x;
   vt2[2]:=TexVertices2D[numv2].y;
   vt3[1]:=TexVertices2D[numv3].x;
   vt3[2]:=TexVertices2D[numv3].y;
   //Если вершина лежит в этом треугольнике, выделяем и его
   if IsVertexInTriangle(v,vt1,vt2,vt3) then begin
    if act=[] then begin
     TexSelVertexCount:=0;
     TexSelVertexList:=nil;
     act:=[ssShift];
    end;//of if
    DoSelect(j,num1,act);
    DoSelect(j,num2,act);
    DoSelect(j,num3,act);
    Result:=true;
   end;//of if
   i:=i+3;                        //к следующему треугольнику
  end;//of while
 end;//of for j
End;

//Отпускание клавиши мыши
procedure TfrmTex.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var i,j,NumFound,GeoFound,MinX,MinY,MaxX,MaxY:integer;
    fDelta,fDelta2:GLfloat;
begin
 IsMouseDown:=false;
 IsRightMouseDown:=false;
 if button=mbRight then exit;     //не та клавиша
 if (not IsArea) and sb_cross.down and
    (InstrumStatus=isSelect) then begin
  //Искать ближайшую вершину
  fDelta2:=100;{fDelta:=100;}NumFound:=0;GeoFound:=0;
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to Length(TexVertices2D)-1 do begin
   fDelta:=(abs(TexVertices2D[i].x-x)+abs(TexVertices2D[i].y-y));
    if (fDelta<5) and (fDelta<fDelta2) then begin
     //Подходящая вершина найдена
      NumFound:=TexVertexList[i];fDelta2:=fDelta;
      GeoFound:=j;
    end;//of if
   end;//of for
  end;//of for j
  if fDelta2=100 then begin
   //ничего не найдено
   TexSaveUndo(uTexSelect);        //запомним состояние выделения
   sb_undo.enabled:=true;
   if (not MakeTexTriangleSelection(x,y,Shift))
   and (not (([ssShift]=Shift) or ([ssCtrl]=Shift))) then
    for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do TexSelVertexCount:=0;
  end else begin
   //Вершина найдена. Выделим ее.
   TexSaveUndo(uTexSelect);        //запомним состояние выделения
   sb_undo.enabled:=true;
   DoSelect(GeoFound,NumFound,Shift);
  end;
  if GetSumCountOfSelTexVertices=0 then begin //инструменты
   b_proec.enabled:=false;
   sb_imove.enabled:=false;
   b_collapse.enabled:=false;
   sb_irot.enabled:=false;
   sb_izoom.enabled:=false;
   sb_mirrorx.enabled:=false;
   sb_mirrory.enabled:=false;
   b_uncouple.enabled:=false;
  end else begin
   b_proec.enabled:=true;
   sb_imove.enabled:=true;
   sb_irot.enabled:=true;
   sb_izoom.enabled:=true;
   sb_mirrorx.enabled:=true;
   sb_mirrory.enabled:=true;
   b_uncouple.enabled:=true;
   if GetSumCountOfSelTexVertices>1 then b_collapse.enabled:=true;
  end;//of if
  l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelTexVertices);
   glDeleteLists(TexListNum,1);
   MakeTVList(dc,hrc,CurrentCoordID);
//   CalcTexVertex2D(frmTex.ClientHeight);
//  wglMakeCurrent(0,0);
  _FormPaint(Sender);
  exit;
 end;//of if

 //Выделение области
 if sb_cross.down and IsArea and (InstrumStatus=isSelect) then begin
  IsArea:=false;                  //сбросить область
  //1. Найдем максимум/минимум координат
  MinX:=Min(x,ClickX);MinY:=Min(y,ClickY);
  MaxX:=Max(x,ClickX);MaxY:=Max(y,ClickY);
  sb_undo.enabled:=true;
  TexSaveUndo(uTexSelect);        //запомнить для отмены
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   //2. Очистка списка выделения
   if Shift=[] then begin
    TexSelVertexList:=nil;
    TexSelVertexCount:=0;
   end;//of if
   if not IsSelected then continue;
   //3. Поиск вершин, попавших в область
   for i:=0 to Length(TexVertices2D)-1 do
    if (round(TexVertices2D[i].x)>=MinX) and
       (round(TexVertices2D[i].x)<=MaxX) and
       (round(TexVertices2D[i].y)<=MaxY) and
       (round(TexVertices2D[i].y)>=MinY) then begin
    DoSelect(j,TexVertexList[i],Shift+[ssAlt]);//CtrlZ1.enabled:=true;sb_undo.enabled:=true;
   end;//of if/for
  end;//of for j
  if GetSumCountOfSelTexVertices=0 then begin //инструменты
   sb_imove.enabled:=false;
   b_proec.enabled:=false;
   b_collapse.enabled:=false;
   sb_irot.enabled:=false;
   sb_izoom.enabled:=false;
   sb_mirrorx.enabled:=false;
   sb_mirrory.enabled:=false;
   b_uncouple.enabled:=false;
  end else begin
   if GetSumCountOfSelTexVertices>1 then b_collapse.enabled:=true;
   sb_imove.enabled:=true;
   b_proec.enabled:=true; 
   sb_irot.enabled:=true;
   sb_izoom.enabled:=true;
   sb_mirrorx.enabled:=true;
   sb_mirrory.enabled:=true;
   b_uncouple.enabled:=true;
  end;//of if
  //Перерисовать
  l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelTexVertices);
//  wglMakeCurrent(dc,hrc);         //перерисовка
   glDeleteLists(TexListNum,1);
   MakeTVList(dc,hrc,CurrentCoordID);
//  wglMakeCurrent(0,0);
  _FormPaint(Sender);
  exit;
 end;//of if
end;

//Установить параметры вида
procedure SetTexView;
Begin
// wglMakeCurrent(dc,hrc);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  if Excentry>1 then glScalef(2*Zoom,-2*Zoom/Excentry,1)
                else glScalef(2*Zoom*Excentry,-2*Zoom,1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(TransX-0.5,TransY-0.5,0);
//  MakeTVList(dc,hrc);             //перестроить список
  CalcTexVertex2D(frmTex.TexWorkArea.ClientHeight);
// wglMakeCurrent(0,0);
End;

//Вспомогательная: прописывает в текстуры WrapWidth и WrapHeight
procedure MakeWrapTexs;
Var i:integer;
Begin with Materials[CurMaterial] do begin
 for i:=0 to CountOfLayers-1 do begin
  Textures[Layers[i].TextureID].IsWrapWidth:=true;
  Textures[Layers[i].TextureID].IsWrapHeight:=true;
 end;//of for i
 IsTexWrap:=true;
end;End;
//Движение курсора мыши
procedure TfrmTex.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var hBrush,i,j,jj:integer;
    DeltaX,DeltaY,OldTexX,OldTexY:GLfloat;
begin
 //Масштабирование
 if (sb_zoom.down and IsMouseDown) or IsWheel then begin
  Zoom:=Zoom+(OldMouseY-Y)/200;   //Новый масштаб
  if Zoom<0.01 then Zoom:=0.01;
  if Zoom>40 then Zoom:=40;
  ed_zoom.text:=inttostr(round(Zoom*100));
  SetTexView;                     //перерисовка
  _FormPaint(Sender);
  OldMouseY:=y;OldMouseX:=x;
  exit;
 end;//of if

 //Смещение
 if (sb_move.down and IsMouseDown) or IsRightMouseDown then begin
  TransX:=TransX+(x-OldMouseX)/(TexWorkArea.width*Zoom*Excentry);
  TransY:=TransY+(y-OldMouseY)/(TexWorkArea.Height*Zoom);
  if TransX<-10 then TransX:=-10;
  if TransX>10 then TransX:=10;
  if TransY<-10 then TransY:=-10;
  if TransY>10 then TransY:=10;
  ed_x.text:=floattostrf(TransX,ffFixed,10,5);
  ed_y.text:=floattostrf(TransY,ffFixed,10,5);
  SetTexView;                     //перерисовка
  _FormPaint(Sender);
 end;//of if

 //Выделение области
 if IsMouseDown and sb_cross.down and (InstrumStatus=isSelect) and
    (abs(ClickX-x)>5) and (abs(ClickY-y)>5) then begin
  IsArea:=true;               //обрабатываем площадь
  SwapBuffers(dc);            //обновить картинку
  hBrush:=CreatePen(PS_SOLID,1,$0888888);
  SelectObject(dc,hBrush);
  MoveToEx(dc,ClickX,ClickY,nil);      //рисуем рамку
  LineTo(dc,X,ClickY);LineTo(dc,x,y);
//  DeleteObject(hBrush);
//  hBrush:=CreateSolidBrush(0);
//  SelectObject(dc,hBrush);
  LineTo(dc,ClickX,y);LineTo(dc,ClickX,ClickY);
  DeleteObject(hBrush);
  exit;
{  LineTo(dc,X+1,ClickY-1);LineTo(dc,x+1,y+1);
  LineTo(dc,ClickX-1,y+1);LineTo(dc,ClickX-1,ClickY-1);}
//  OldMouseX:=x;OldMouseY:=y;
 end;//of if

 //Движение (Move)
 if IsMouseDown and sb_cross.down and (InstrumStatus=isMove) then begin
  if Zoom<0.0001 then Zoom:=0.0001;
  DeltaX:=(x-OldMouseX)/(TexWorkArea.width*Zoom*Excentry);
  DeltaY:=(y-OldMouseY)/(TexWorkArea.Height*Zoom);//смещение
//  DeltaX:=(x-OldMouseX)*Zoom/500;DeltaY:=(y-OldMouseY)*Zoom/500;//смещение
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
    for i:=0 to TexSelVertexCount-1
    do with Geosets[j].Crds[CurrentCoordID] do begin
     TVertices[TexSelVertexList[i]-1,1]:=TVertices[TexSelVertexList[i]-1,1]+
                  DeltaX;
     TVertices[TexSelVertexList[i]-1,2]:=TVertices[TexSelVertexList[i]-1,2]+
                  DeltaY;
     if not IsTexWrap then begin
      if (TVertices[TexSelVertexList[i]-1,1]<0) or
         (TVertices[TexSelVertexList[i]-1,1]>1) or
         (TVertices[TexSelVertexList[i]-1,2]<0) or
         (TVertices[TexSelVertexList[i]-1,2]>1) then MakeWrapTexs;
     end else begin                //переносимые текстуры
      if TVertices[TexSelVertexList[i]-1,1]<-10 then //проверка границ
          TVertices[TexSelVertexList[i]-1,1]:=-10;
      if TVertices[TexSelVertexList[i]-1,1]>10 then
          TVertices[TexSelVertexList[i]-1,1]:=10;
      if TVertices[TexSelVertexList[i]-1,2]<-10 then
          TVertices[TexSelVertexList[i]-1,2]:=-10;
      if TVertices[TexSelVertexList[i]-1,2]>10 then
          TVertices[TexSelVertexList[i]-1,2]:=10;
     end;//of if
    end;//of for i
  end;//of for j
  FindTexCoordCenter;              //найти центр
  frmTex.ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
  frmTex.ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
//  wglMakeCurrent(dc,hrc);
  MakeTVList(dc,hrc,CurrentCoordID);
  CalcTexVertex2D(TexWorkArea.ClientHeight);
//  wglMakeCurrent(0,0);
  _FormPaint(Sender);
 end;//of if

 //Поворот (Rotate)
 if IsMouseDown and sb_cross.down and (InstrumStatus=isRotate) then begin
  DeltaX:=(OldMouseX-x);rAngle:=rAngle+DeltaX;
  DeltaX:=DeltaX*0.01745;      //угол поворота (радианы)
  FindTexCoordCenter;          //найти центр координат
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to TexSelVertexCount-1
   do with Geosets[j].Crds[CurrentCoordID] do begin
    OldTexX:=TVertices[TexSelVertexList[i]-1,1]-tcX;
    OldTexY:=TVertices[TexSelVertexList[i]-1,2]-tcY;
    TVertices[TexSelVertexList[i]-1,1]:=
                OldTexX*cos(DeltaX)+OldTexY*sin(DeltaX)+tcX;
    TVertices[TexSelVertexList[i]-1,2]:=
                OldTexY*cos(DeltaX)-OldTexX*sin(DeltaX)+tcY;
   end;//of for
  end;//of for j
  //Теперь - перерисовка
  frmTex.ed_ix.text:=floattostrf(rAngle,ffFixed,10,5);
//  wglMakeCurrent(dc,hrc);
  MakeTVList(dc,hrc,CurrentCoordID);
  CalcTexVertex2D(TexWorkArea.ClientHeight);
//  wglMakeCurrent(0,0);
  _FormPaint(Sender);
 end;//of if

 //Масштабирование
 if IsMouseDown and sb_cross.down and (InstrumStatus=isZoom) then begin
  DeltaY:=1+(OldMouseY-y)/100;
  ZoomX:=ZoomX*DeltaY;ZoomY:=ZoomY*DeltaY;
  FindTexCoordCenter;
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to TexSelVertexCount-1
   do with Geosets[j].Crds[CurrentCoordId] do begin
    TVertices[TexSelVertexList[i]-1,1]:=(TVertices[TexSelVertexList[i]-1,1]-tcX)*
                 DeltaY+tcX;
    TVertices[TexSelVertexList[i]-1,2]:=(TVertices[TexSelVertexList[i]-1,2]-tcY)*
                 DeltaY+tcY;
    if not IsTexWrap then begin
     if (TVertices[TexSelVertexList[i]-1,1]<0) or
        (TVertices[TexSelVertexList[i]-1,1]>1) or
        (TVertices[TexSelVertexList[i]-1,2]<0) or
        (TVertices[TexSelVertexList[i]-1,2]>1) then MakeWrapTexs;
    end else begin                //переносимые текстуры
     if TVertices[TexSelVertexList[i]-1,1]<-10 then //проверка границ
         TVertices[TexSelVertexList[i]-1,1]:=-10;
     if TVertices[TexSelVertexList[i]-1,1]>10 then
         TVertices[TexSelVertexList[i]-1,1]:=10;
     if TVertices[TexSelVertexList[i]-1,2]<-10 then
         TVertices[TexSelVertexList[i]-1,2]:=-10;
     if TVertices[TexSelVertexList[i]-1,2]>10 then
         TVertices[TexSelVertexList[i]-1,2]:=10;
    end;//of if
   end;//of for
  end;//of for j
  //Теперь - перерисовка
  frmTex.ed_ix.text:=inttostr(round(ZoomX));
  frmTex.ed_iy.text:=inttostr(round(ZoomY));
//  wglMakeCurrent(dc,hrc);
  MakeTVList(dc,hrc,CurrentCoordID);
  CalcTexVertex2D(TexWorkArea.ClientHeight);
//  wglMakeCurrent(0,0);
  _FormPaint(Sender);
 end;//of isZoom
 OldMouseX:=x;OldMouseY:=y;
end;

//Включена кнопка "Масштаб"
procedure TfrmTex.sb_zoomClick(Sender: TObject);
begin
// InstrumStatus:=isZoom;           //масштабирование
 pn_stat.visible:=false;
 pn_info.visible:=false;          //смена активной панели
 pn_zoom.visible:=true;
 TexWorkArea.Cursor:=crZoomCur;
 ed_zoom.text:=inttostr(round(Zoom*100));
end;

procedure TfrmTex.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 OldMouseX:=x;OldMouseY:=y;
 if button=mbLeft then begin
  if not IsMouseDown then begin
   if (InstrumStatus=isMove) or (InstrumStatus=isRotate) or
      (InstrumStatus=isZoom) then begin
    TexSaveUndo(uTexVertexTrans);sb_undo.enabled:=true;
   end;//of if
   ClickX:=x;ClickY:=y;
  end;//of if
  IsMouseDown:=true;
 end else begin                   //нажата левая клавиша мыши
  IsRightMouseDown:=true;
  if not IsRightMouseDown then begin
   ClickX:=x;ClickY:=y;
  end;//of if
 end;//of if
end;

procedure TfrmTex.sb_crossClick(Sender: TObject);
begin
 TexWorkArea.Cursor:=crArrow;
 pn_info.visible:=true;
 pn_zoom.visible:=false;
 pn_stat.visible:=false;
end;

//Нужно сменить масштаб
procedure TfrmTex.ed_zoomExit(Sender: TObject);
begin
 if not IsCipher(ed_zoom.text) then begin
  ed_zoom.text:=inttostr(round(Zoom*100));
  exit;
 end;//of if
 //Все в порядке, считываем
 Zoom:=strtofloat(ed_zoom.text)/100;
 if Zoom<0.01 then Zoom:=0.01;
 if Zoom>40 then Zoom:=40;
 ed_zoom.text:=inttostr(round(Zoom*100));
 SetTexView;                     //перерисовка
 _FormPaint(Sender);
end;

procedure TfrmTex.ed_zoomKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=VK_RETURN then ed_ZoomExit(Sender);
end;

//Движение
procedure TfrmTex.sb_moveClick(Sender: TObject);
begin
 pn_info.visible:=false;
 pn_zoom.visible:=false;
 pn_stat.visible:=true;
 ed_x.text:=floattostrf(TransX,ffFixed,10,5);
 ed_y.text:=floattostrf(TransY,ffFixed,10,5);
 TexWorkArea.Cursor:=crHandPoint;
end;

procedure TfrmTex.ed_xExit(Sender: TObject);
begin
 if not IsCipher(ed_x.text) then begin
  ed_x.text:=floattostrf(TransX,ffFixed,10,5);
  exit;
 end;//of if
 TransX:=strtofloat(ed_x.text);
 if TransX<-1 then TransX:=-1;
 if TransX>1 then TransX:=1;
 ed_x.text:=floattostrf(TransX,ffFixed,10,5);
 SetTexView;                     //перерисовка
 _FormPaint(Sender);
end;

procedure TfrmTex.ed_xKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=VK_RETURN then ed_xExit(Sender);
end;

procedure TfrmTex.ed_yExit(Sender: TObject);
begin
 if not IsCipher(ed_y.text) then begin
  ed_y.text:=floattostrf(TransY,ffFixed,10,5);
  exit;
 end;//of if
 TransY:=strtofloat(ed_y.text);
 if TransY<-1 then TransY:=-1;
 if TransY>1 then TransY:=1;
 ed_y.text:=floattostrf(TransY,ffFixed,10,5);
 SetTexView;                     //перерисовка
 _FormPaint(Sender);
end;

procedure TfrmTex.ed_yKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=VK_RETURN then ed_yExit(Sender);
end;

//Отмена изменений
procedure TfrmTex.sb_undoClick(Sender: TObject);
Var j,i,ii,tmp:integer;
begin
if CountOfUndo<=COStart then exit;  //перестрахуемся
case Undo[CountOfUndo].Status1 of //проверим, что отменяется
 uTexSelect:begin
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin  //выделение
   TexSelVertexCount:=Undo[CountOfUndo].Status2;
   SetLength(TexSelVertexList,TexSelVertexCount);
   for i:=0 to TexSelVertexCount-1 do
                 TexSelVertexList[i]:=round(Undo[CountOfUndo].Data1[i]);
  end;//of with/for j
  l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelTexVertices);
  if GetSumCountOfSelTexVertices=0 then begin
   sb_imove.enabled:=false;
   b_proec.enabled:=false; 
   b_collapse.enabled:=false;
   sb_irot.enabled:=false;
   sb_izoom.enabled:=false;
   sb_mirrorx.enabled:=false;
   sb_mirrory.enabled:=false;
   b_uncouple.enabled:=false;
   sb_select.down:=true;    //нажать исходную
   InstrumStatus:=isSelect; //инструмент: выделение;
   sb_selectClick(Sender);
  end;//of if
  dec(CountOfUndo);
 end;//of uSelect

 uTexVertexTrans:begin
  for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
   tmp:=Undo[CountOfUndo].MatID;
   for i:=0 to Undo[CountOfUndo].Status2-1 do begin
    Geosets[j].Crds[tmp].TVertices[Undo[CountOfUndo].idata[i]-1,1]:=
         Undo[CountOfUndo].data1[i];
    Geosets[j].Crds[tmp].TVertices[Undo[CountOfUndo].idata[i]-1,2]:=
         Undo[CountOfUndo].data2[i];
   end;//of for
  end;//of with/for j
  dec(CountOfUndo);
  if sb_select.down or sb_imove.down then begin
   FindTexCoordCenter;
   ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
   ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
  end;
  if sb_irot.down then begin
   ed_ix.text:='0';
   ed_iy.text:='0';
  end;//of if
  if sb_izoom.down then begin
   ed_ix.text:='100';ed_iy.text:='100';
   ZoomX:=100;ZoomY:=100;
  end;//of if
 end;//of uVertexTrans

 uTexUncouple:begin
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do begin
  if Undo[CountOfUndo].Unselectable then continue;
  VertexCount:=Length(Undo[CountOfUndo].VertexList);
  TexVertexCount:=VertexCount;
  SetLength(VertexList,VertexCount);
  SetLength(TexVertexList,VertexCount);
  for i:=0 to VertexCount-1 do begin
   VertexList[i]:=Undo[CountOfUndo].VertexList[i]+1;
   TexVertexList[i]:=Undo[CountOfUndo].VertexList[i]+1;
  end;//of for i
  TexSelVertexCount:=Length(Undo[CountOfUndo].idata);
  SetLength(TexSelVertexList,TexSelVertexCount);
  for i:=0 to TexSelVertexCount-1 do
      TexSelVertexList[i]:=Undo[CountOfUndo].idata[i];
  CountOfVertices:=Undo[CountOfUndo].MatID;
  CountOfNormals:=CountOfVertices;
  //Копирование текстурных координат
  for i:=0 to CountOfCoords-1 do begin
   Crds[i].CountOfTVertices:=CountOfVertices;
   SetLength(Crds[i].TVertices,CountOfVertices);
   for ii:=0 to VertexCount-1
   do Crds[i].TVertices[Undo[CountOfUndo].VertexList[ii]]:=
      Undo[CountOfUndo].Crds[i].TVertices[ii];
  end;//of for i
  SetLength(Vertices,CountOfVertices);
  SetLength(Normals,CountOfVertices);
  SetLength(VertexGroup,CountOfVertices);
  SetLength(Geosets[j].Faces[0],length(Undo[CountOfUndo].Faces[0]));
  for i:=0 to length(Undo[CountOfUndo].Faces[0])-1 do
            Geosets[j].Faces[0,i]:=Undo[CountOfUndo].Faces[0,i];
 end;//of for j
 dec(CountOfUndo);
 //Теперь - установка кнопок и др.
 l_vcount.caption:='Всего вершин: '+inttostr(GetSumCountOfTexVertices);
 l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelTexVertices);
 sb_imove.enabled:=true;
 sb_irot.enabled:=true;
 sb_izoom.enabled:=true;
 sb_mirrorx.enabled:=true;
 sb_mirrory.enabled:=true;
 b_collapse.enabled:=true;
 b_uncouple.enabled:=true;
 b_proec.enabled:=true;
 end;  //of uTexUncouple

 uTexCoup:begin
  CoupTextureMap;
  dec(CountOfUndo);
 end;//of uTexCoup

 uTexPlaneChange:begin
  CurrentCoordID:=Undo[CountOfUndo].Status2;
  ud_plane.position:=CurrentCoordID;
  ed_plane.text:=inttostr(CurrentCoordID);
  dec(CountOfUndo);
 end;//of uTexPlaneChange
end;//of case
if CountOfUndo<=COStart then sb_undo.enabled:=false;
  if sb_select.down or sb_imove.down then begin
   FindTexCoordCenter;
   ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
   ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
  end;
  if sb_irot.down then begin
   ed_ix.text:='0';
   ed_iy.text:='0';
  end;//of if
  if sb_izoom.down then begin
   ed_ix.text:='100';ed_iy.text:='100';
   ZoomX:=100;ZoomY:=100;
  end;//of if
//Перерисовка картинки
 MakeTVList(dc,hrc,CurrentCoordID);
 CalcTexVertex2D(TexWorkArea.ClientHeight);
_FormPaint(Sender);
end;

//Инструмент: движение
procedure TfrmTex.sb_imoveClick(Sender: TObject);
begin
 InstrumStatus:=isMove;
 ed_ix.readOnly:=false;
 ed_iy.ReadOnly:=false;
 ed_iy.Visible:=true;
 label9.visible:=true;
 FindTexCoordCenter;
 ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
 ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
end;
//Инструмент: выделение
procedure TfrmTex.sb_selectClick(Sender: TObject);
begin
 InstrumStatus:=isSelect;
 ed_ix.readOnly:=true;
 ed_iy.ReadOnly:=true;
 ed_iy.Visible:=true;
 label9.visible:=true;
 FindTexCoordCenter;
 ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
 ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
end;

procedure TfrmTex.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 IsKeyDown:=false;
end;

procedure TfrmTex.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const VK_A=$41; VK_B=$42; VK_C=$43; VK_D=$44; VK_E=$45;
      VK_F=$46;           VK_H=$48;
                          VK_M=$4D; VK_N=$4E; VK_O=$4F;
                VK_Q=$51; VK_R=$52; VK_S=$53; VK_T=$54;
      VK_U=$55; VK_V=$56; VK_W=$57;
      VK_Z=$5A;
begin
// if IsKeyDown then exit; //во избежание повторов
 if (key=VK_PRIOR) or (key=VK_NEXT) or (key=VK_END) or
    (key=VK_HOME) or (key=VK_LEFT) or (key=VK_UP) or
    (key=VK_RIGHT) or (key=VK_DOWN) or
    (key=VK_INSERT) {or (key=VK_DELETE)} or
    (key in [VK_NUMPAD0..VK_NUMPAD9]) then exit;
 if key<>VK_CONTROL then IsKeyDown:=true;
 if Shift=[ssCtrl] then begin
  if sb_undo.enabled and (key=VK_Z) then sb_undoClick(Sender);
  if (key=VK_S) then begin
   frm1.StrlS1Click(Sender);
   frmTex.SetFocus;
  end;
  if (key=VK_A) then N3Click(Sender);
  exit;
 end;//of if (Ctrl)

 //Дополнительные "горячие клавиши"
 if (key=VK_A) then begin
  sb_select.down:=true;
  sb_selectClick(Sender);
 end;//of if
 if ((key=VK_M) or (key=VK_Q)) and sb_imove.enabled then begin
  sb_imove.down:=true;
  sb_imoveClick(Sender);
 end;//of if
 if (key=VK_R) and sb_irot.enabled then begin
  sb_irot.down:=true;
  sb_irotClick(Sender);
 end;//of if
 if (key=VK_Z) and sb_izoom.enabled then begin
  sb_izoom.down:=true;
  sb_izoomClick(Sender);
 end;//of if
 if (key=VK_C) and b_collapse.enabled then b_collapseClick(Sender);
 if (key=VK_U) and b_uncouple.enabled then b_uncoupleClick(Sender);
 if (key=VK_F1) then SendMessage(frmTex.handle,WM_CLOSE,0,0);
end;

procedure TfrmTex.ed_ixExit(Sender: TObject);
Var i,j:integer;DeltaX,DeltaY,OldTexX,OldTexY:GLfloat;
begin
 FindTexCoordCenter;              //найти реальный центр
 if not IsCipher(ed_ix.text) then begin
  ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
  if InstrumStatus=isRotate then ed_ix.text:=floattostrf(rAngle,ffFixed,10,5);
  exit;
 end;//of if
 if not IsCipher(ed_iy.text) then begin
  ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
  exit;
 end;//of if
if InstrumStatus=isMove then begin
 DeltaX:=strtofloat(ed_ix.text)-tcX;//считывание
 DeltaY:=strtofloat(ed_iy.text)-tcY;//считывание
 TexSaveUndo(uTexVertexTrans);       //сохранение
 //Собственно смещение
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to TexSelVertexCount-1
   do with Geosets[j].Crds[CurrentCoordID] do begin
    TVertices[TexSelVertexList[i]-1,1]:=TVertices[TexSelVertexList[i]-1,1]+
                 DeltaX;
    TVertices[TexSelVertexList[i]-1,2]:=TVertices[TexSelVertexList[i]-1,2]+
                 DeltaY;
    if not IsTexWrap then begin
     if (TVertices[TexSelVertexList[i]-1,1]<0) or
        (TVertices[TexSelVertexList[i]-1,1]>1) or
        (TVertices[TexSelVertexList[i]-1,2]<0) or
        (TVertices[TexSelVertexList[i]-1,2]>1) then MakeWrapTexs;
    end else begin                //переносимые текстуры
     if TVertices[TexSelVertexList[i]-1,1]<-10 then //проверка границ
         TVertices[TexSelVertexList[i]-1,1]:=-10;
     if TVertices[TexSelVertexList[i]-1,1]>10 then
         TVertices[TexSelVertexList[i]-1,1]:=10;
     if TVertices[TexSelVertexList[i]-1,2]<-10 then
         TVertices[TexSelVertexList[i]-1,2]:=-10;
     if TVertices[TexSelVertexList[i]-1,2]>10 then
         TVertices[TexSelVertexList[i]-1,2]:=10;
    end;//of if
   end;//of for
  end;//of for j
 FindTexCoordCenter;
 ed_ix.text:=floattostrf(tcX,ffFixed,10,5);
 ed_iy.text:=floattostrf(tcY,ffFixed,10,5);
end;//of if(isMove)

if InstrumStatus=isRotate then begin
  TexSaveUndo(uTexVertexTrans);       //сохранение
  DeltaX:=(strtofloat(ed_ix.text)-rAngle);
  rAngle:=rAngle+DeltaX;
  DeltaX:=DeltaX*0.01745;      //угол поворота (радианы)
  FindTexCoordCenter;          //найти центр координат
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to TexSelVertexCount-1
   do with Geosets[j].Crds[CurrentCoordID] do begin
    OldTexX:=TVertices[TexSelVertexList[i]-1,1]-tcX;
    OldTexY:=TVertices[TexSelVertexList[i]-1,2]-tcY;
    TVertices[TexSelVertexList[i]-1,1]:=
                 OldTexX*cos(DeltaX)+OldTexY*sin(DeltaX)+tcX;
    TVertices[TexSelVertexList[i]-1,2]:=
                 OldTexY*cos(DeltaX)-OldTexX*sin(DeltaX)+tcY;
   end;//of for
  end;//of for j
  ed_ix.text:=floattostrf(rAngle,ffFixed,10,5);
end;//of if

if InstrumStatus=isZoom then begin
 TexSaveUndo(uTexVertexTrans);       //сохранение
 DeltaX:=strtofloat(ed_ix.text); DeltaY:=strtofloat(ed_iy.text);
 //Проверка ошибок
 if (DeltaX<1) or (DeltaX>6000) then begin
  ed_ix.text:=inttostr(round(ZoomX));
  exit;
 end;//of if
 if (DeltaY<1) or (DeltaY>6000) then begin
  ed_iy.text:=inttostr(round(ZoomY));
  exit;
 end;//of if
 DeltaX:=DeltaX/ZoomX;DeltaY:=DeltaY/ZoomY;
  ZoomX:=ZoomX*DeltaX;ZoomY:=ZoomY*DeltaY;
  FindTexCoordCenter;
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to TexSelVertexCount-1
   do with Geosets[j].Crds[CurrentCoordID] do begin
    TVertices[TexSelVertexList[i]-1,1]:=(TVertices[TexSelVertexList[i]-1,1]-tcX)*
                 DeltaX+tcX;
    TVertices[TexSelVertexList[i]-1,2]:=(TVertices[TexSelVertexList[i]-1,2]-tcY)*
                 DeltaY+tcY;
    if not IsTexWrap then begin
     if (TVertices[TexSelVertexList[i]-1,1]<0) or
        (TVertices[TexSelVertexList[i]-1,1]>1) or
        (TVertices[TexSelVertexList[i]-1,2]<0) or
        (TVertices[TexSelVertexList[i]-1,2]>1) then MakeWrapTexs;
    end else begin                //переносимые текстуры
     if TVertices[TexSelVertexList[i]-1,1]<-10 then //проверка границ
         TVertices[TexSelVertexList[i]-1,1]:=-10;
     if TVertices[TexSelVertexList[i]-1,1]>10 then
         TVertices[TexSelVertexList[i]-1,1]:=10;
     if TVertices[TexSelVertexList[i]-1,2]<-10 then
         TVertices[TexSelVertexList[i]-1,2]:=-10;
     if TVertices[TexSelVertexList[i]-1,2]>10 then
         TVertices[TexSelVertexList[i]-1,2]:=10;
    end;//of if
   end;//of for
  end;//of for j
end;//of if
// SetTexView;                     //перерисовка
// wglMakeCurrent(dc,hrc);
  MakeTVList(dc,hrc,CurrentCoordID);
  CalcTexVertex2D(TexWorkArea.ClientHeight);
// wglMakeCurrent(0,0);
 _FormPaint(Sender);
end;

procedure TfrmTex.ed_ixKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=VK_RETURN then ed_ixExit(Sender);
end;

procedure TfrmTex.sb_irotClick(Sender: TObject);
begin
 InstrumStatus:=isRotate;
 ed_ix.ReadOnly:=false;
 ed_iy.visible:=false;
 label9.visible:=false;
 rAngle:=0;
 ed_ix.text:='0';
end;

procedure TfrmTex.sb_izoomClick(Sender: TObject);
begin
 InstrumStatus:=isZoom;
 ed_ix.ReadOnly:=false;
 ed_iy.ReadOnly:=false;
 ed_iy.visible:=true;
 label9.visible:=true;
 ed_ix.text:=inttostr(round(ZoomX));
 ed_iy.text:=inttostr(round(ZoomY));
end;

//Проецирование точек на текстуру
procedure TfrmTex.b_proecClick(Sender: TObject);
Var i,j:integer;
    xMin,yMin,xMax,yMax,yTst,xTst:GLfloat;
begin for j:=0 to CountOfGeosets-1 do with Geosets[j],geoobjs[j] do begin
 if not IsSelected then continue;
 xMax:=-1e5;yMax:=-1e5;xMin:=1e5;yMin:=1e5;
 TexSaveUndo(uTexVertexTrans);       //Сохранение
 //1. Находим нормировочные множители
 for i:=0 to TexSelVertexCount-1 do begin
  xTst:=Vertices2D[TexSelVertexList[i]-1].x;//чтение к-т
  yTst:=Vertices2D[TexSelVertexList[i]-1].y;
  if xTst<xMin then xMin:=xTst;
  if xTst>xMax then xMax:=xTst;
  if yTst<yMin then yMin:=yTst;
  if yTst>yMax then yMax:=yTst;
 end;//of for    
 //2. Осуществляем нормировку к 1
 for i:=0 to TexSelVertexCount-1 do begin
  if (xMax-xMin)=0 then begin
   xMax:=0.1;xMin:=0;
  end;
  if (yMax-yMin)=0 then begin
   yMax:=0.1;yMin:=0;
  end;//of if
  Crds[CurrentCoordID].TVertices[TexSelVertexList[i]-1,1]:=
        0.5*(Vertices2D[TexSelVertexList[i]-1].x-xMin)/(xMax-xMin);
  Crds[CurrentCoordID].TVertices[TexSelVertexList[i]-1,2]:=
        0.5*(Vertices2D[TexSelVertexList[i]-1].y-yMin)/(yMax-yMin);
 end;//of for
 //3. Перерисовать
// wglMakeCurrent(dc,hrc);
  MakeTVList(dc,hrc,CurrentCoordID);
  CalcTexVertex2D(TexWorkArea.ClientHeight);
// wglMakeCurrent(0,0);
 _FormPaint(Sender);
end;end;

//Сброс перспективы
procedure TfrmTex.N1Click(Sender: TObject);
begin
  Zoom:=1;TransX:=0;TransY:=0;
  sb_cross.down:=true;sb_crossClick(Sender);
//  wglMakeCurrent(dc,hrc);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  if Excentry>1 then glScalef(2*Zoom,-2*Zoom/Excentry,1)
                else glScalef(2*Zoom*Excentry,-2*Zoom,1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(TransX-0.5,TransY-0.5,0);
  CalcTexVertex2D(TexWorkArea.ClientHeight);  
//  wglMakeCurrent(0,0);
  _FormPaint(Sender);
end;

procedure TfrmTex.FormPaint(Sender: TObject);
begin
 _FormPaint(Sender);
// timer1.enabled:=true;
end;

procedure TfrmTex.cb_texnameChange(Sender: TObject);
Var i:integer;
begin
 i:=cb_texname.ItemIndex;
 if i<0 then exit;
 cb_texname.tag:=i;
end;

//возвращает ID текстуры по её тегу (пропуск пустых полей)
function GetTexIDFromTag(TexTag:integer):integer;
Var i,ID:integer;
Begin
 ID:=0;
 for i:=0 to CountOfTextures-1 do begin
  if length(Textures[i].FileName)=0 then continue;
  if TexTag<=0 then begin
   ID:=i;
   break;
  end;//of if
  dec(TexTag);
  ID:=i;
 end;//of for i
 Result:=ID;
End;
//Установить значение
procedure TfrmTex.cb_texnameExit(Sender: TObject);
Var s:string;
begin
 if cb_texname.tag<0 then exit;
 s:=cb_texname.text;
 cb_texname.Items.Strings[cb_texname.tag]:=s;
 Textures[GetTexIDFromTag(cb_texname.tag)].FileName:=s;
 cb_texname.text:=s;
end;

procedure TfrmTex.cb_texnameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=VK_RETURN then begin
  cb_texname.SelectAll;
  cb_texnameExit(Sender);
 end;//of if
end;

procedure TfrmTex.b_collapseClick(Sender: TObject);
Var i,j:integer;
begin
 //1. Сохранить для отмены изменений
 TexSaveUndo(uTexVertexTrans);       //сохранение
 FindTexCoordCenter;              //найти текстурный центр
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do begin
  if not IsSelected then continue;
  //2. Все вершины сместить в центр
  for i:=0 to TexSelVertexCount-1 do begin
   Crds[CurrentCoordID].TVertices[TexSelVertexList[i]-1,1]:=tcX;
   Crds[CurrentCoordID].TVertices[TexSelVertexList[i]-1,2]:=tcY;
  end;//of for
 end;//of for j
 //3. Перерисовать
 FindCoordCenter;
 MakeTVList(dc,hrc,CurrentCoordID);
 CalcTexVertex2D(TexWorkArea.ClientHeight);
 _FormPaint(Sender);
end;

//Поворот колесика вверх: масштаб
procedure TfrmTex.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
Var tmp:integer;
begin
 if cb_color.Focused then exit;
 IsWheel:=true;
 tmp:=OldMouseY;
 OldMouseY:=round(20*Zoom);
 if OldMouseY=0 then OldMouseY:=1;
 FormMouseMove(Sender,[],0,0);
 IsWheel:=false;
 OldMouseY:=tmp;
end;

procedure TfrmTex.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
Var tmp:integer;
begin
 if cb_color.Focused then exit;
 IsWheel:=true;
 tmp:=OldMouseY;
 OldMouseY:=0;
 FormMouseMove(Sender,[],0,round(20*Zoom));
 IsWheel:=false;
 OldMouseY:=tmp;
end;

//Выделить все вершины
procedure TfrmTex.N3Click(Sender: TObject);
Var i,j:integer;
begin
 TexSaveUndo(uTexSelect);           //запомним состояние выделения
 sb_undo.enabled:=true;
 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected then
     for i:=0 to geoobjs[j].TexVertexCount-1
     do DoSelect(j,Geoobjs[j].TexVertexList[i],[ssShift]);
 b_proec.enabled:=true;     
 sb_imove.enabled:=true;
 sb_irot.enabled:=true;
 sb_izoom.enabled:=true;
 sb_mirrorx.enabled:=true;
 sb_mirrory.enabled:=true;
 b_uncouple.enabled:=true;
 if GetSumCountOfSelTexVertices>1 then b_collapse.enabled:=true;
 l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelTexVertices);
 glDeleteLists(TexListNum,1);
 MakeTVList(dc,hrc,CurrentCoordID);
 _FormPaint(Sender);
end;

//Изменение размера формы
procedure TfrmTex.FormResize(Sender: TObject);
begin
 //Собственно правка размеров
 if bExit then exit;
 TexWorkArea.width:=sb_instrum.left-TexWorkArea.Left;
 TexWorkArea.height:=panel1.top-TexWorkArea.top;
 //переработка изображения
 wglMakeCurrent(0,0);
 wglDeleteContext(hrc);
 ReleaseDC(TexWorkArea.handle,dc);
 dc:=GetDC(TexWorkArea.handle);
 hrc:=wglCreateContext(dc);
 wglMakeCurrent(dc,hrc);         //начать вывод
 SetTexView;                     //перерисовка
 if length(Geosets)<>0 then begin
  MakeTVList(dc,hrc,CurrentCoordID);
  CalcTexVertex2D(TexWorkArea.ClientHeight);
  cb_colorChange(Sender);
 end;//of if
end;

procedure TransferTriangle(geoID,num:integer);
Var md,dv,num2,num3:integer;
    x1,y1,x2,y2:GLFloat;
Const pwr=0.8;
Begin with Geosets[geoID] do begin
 num2:=0;num3:=0;
 //1. Находим номера вершин, к которым
 //нужно приблизить текущую
 md:=num mod 3;
 dv:=(num div 3)*3;
 case md of
  0:begin
   num2:=Faces[0,dv+1];
   num3:=Faces[0,dv+2];
  end;
  1:begin
   num2:=Faces[0,dv];
   num3:=Faces[0,dv+2];
  end;
  2:begin
   num2:=Faces[0,dv];
   num3:=Faces[0,dv+1];
  end;
 end;//of case

 num:=Faces[0,num];
 //2. Собственно усреднение
 with Crds[CurrentCoordID] do begin
   x1:=(1-Pwr)*TVertices[num2,1]+Pwr*TVertices[num,1];
   y1:=(1-Pwr)*TVertices[num2,2]+Pwr*TVertices[num,2];
   x2:=(1-Pwr)*TVertices[num3,1]+Pwr*TVertices[num,1];
   y2:=(1-Pwr)*TVertices[num3,2]+Pwr*TVertices[num,2];
   TVertices[num,1]:=0.5*(x1+x2);
   TVertices[num,2]:=0.5*(y1+y2);
 end;//of with
end;End;

//Разъединить выделенные вершины
procedure TfrmTex.b_uncoupleClick(Sender: TObject);
Var j,i,ii,jj,k,num,len1:integer;
begin
 SaveUndo(uTexUncouple);
 for j:=0 to CountOfGeosets-1 do with Geosets[j],GeoObjs[j] do
 if IsSelected and (VertexCount>0) then begin
  OldCountOfVertices:=CountOfVertices;
  for i:=0 to TexSelVertexCount-1 do begin
   num:=TexSelVertexList[i]-1;    //считать номер очередной вершины
   //Ищем треугольник, содержащий эту вершину
   len1:=length(Faces[0])-1;
   for ii:=0 to len1 do if Faces[0,ii]=num then begin
    //Найдено! Движемся далее
    for jj:=ii+1 to len1 do if Faces[0,jj]=num then begin
     inc(CountOfVertices);
     inc(CountOfNormals);
     SetLength(Vertices,CountOfVertices);
     SetLength(Normals,CountOfVertices);
     SetLength(VertexGroup,CountOfVertices);
     Faces[0,jj]:=CountOfVertices-1;
     Vertices[CountOfVertices-1]:=Vertices[num];
     VertexGroup[CountOfVertices-1]:=VertexGroup[CountOfVertices-1];
     for k:=0 to CountOfCoords-1 do with Crds[k] do begin
      inc(CountOfTVertices);
      SetLength(TVertices,CountOfVertices);
      TVertices[CountOfVertices-1]:=TVertices[num];
     end;//of for k
     TransferTriangle(j,jj);
    end;//of for jj
    TransferTriangle(j,ii);
   end;//of for ii
  end;//of for i
  //Заполнить список выделения
  ii:=VertexCount;
  VertexCount:=VertexCount+CountOfVertices-OldCountOfVertices;
  SetLength(VertexList,VertexCount);
  for i:=CountOfVertices-1 downto OldCountOfVertices do begin
   VertexList[ii]:=i+1;
   inc(ii);
  end;//of for i

  //перенести в текстурную раскладку
  TexVertexCount:=VertexCount;
  SetLength(TexVertexList,TexVertexCount);
  for i:=0 to TexVertexCount-1 do TexVertexList[i]:=VertexList[i];
  TexSelVertexList:=nil;
  TexSelVertexCount:=0;
 end;//of if/with/for j

 //перерисовать:
 l_vcount.caption:='Всего вершин: '+inttostr(GetSumCountOfTexVertices);
 IsArea:=false;
 sb_select.down:=true;
 CalcTexVertex2D(TexWorkArea.Clientheight);//расчет 2D-вершин
 sb_selectClick(Sender);
 FormMouseUp(Sender,mbLeft,[],1000,1000);
 dec(CountOfUndo);
end;

//Отзеркалить вершины по X или по Y
procedure TfrmTex.sb_mirrorxClick(Sender: TObject);
Var j,i,num:integer;
begin
 TexSaveUndo(uTexVertexTrans);    //для отмены
 sb_undo.enabled:=true;
 FindTexCoordCenter;              //центр координат
 for j:=0 to CountOfGeosets-1 do with GeoObjs[j],Geosets[j] do
 if IsSelected then for i:=0 to TexSelVertexCount-1 do begin
  num:=TexSelVertexList[i]-1;
  Crds[CurrentCoordID].TVertices[num,1]:=
       2*tcX-Crds[CurrentCoordID].TVertices[num,1];
 end;//of [construction]

 //Перерисовать
 FindCoordCenter;
 MakeTVList(dc,hrc,CurrentCoordID);
 CalcTexVertex2D(TexWorkArea.ClientHeight);
 _FormPaint(Sender);
end;

procedure TfrmTex.sb_mirroryClick(Sender: TObject);
Var j,i,num:integer;
begin
 TexSaveUndo(uTexVertexTrans);    //для отмены
 sb_undo.enabled:=true;
 FindTexCoordCenter;              //центр координат
 for j:=0 to CountOfGeosets-1 do with GeoObjs[j],Geosets[j] do
 if IsSelected then for i:=0 to TexSelVertexCount-1 do begin
  num:=TexSelVertexList[i]-1;
  Crds[CurrentCoordID].TVertices[num,2]:=
        2*tcY-Crds[CurrentCoordID].TVertices[num,2];
 end;//of [construction]

 //Перерисовать
 FindCoordCenter;
 MakeTVList(dc,hrc,CurrentCoordID);
 CalcTexVertex2D(TexWorkArea.ClientHeight);
 _FormPaint(Sender);
end;

//переворачивание всей текстурной карты.
procedure TfrmTex.N4Click(Sender: TObject);
begin
 TexSaveUndo(uTexCoup);           //сохранить для отмены
 sb_undo.enabled:=true;
 CoupTextureMap;
 //Перерисовать
 FindCoordCenter;
 MakeTVList(dc,hrc,CurrentCoordID);
 CalcTexVertex2D(TexWorkArea.ClientHeight);
 _FormPaint(Sender);
end;

//Переключается текстурная плоскость
procedure TfrmTex.ud_planeClick(Sender: TObject; Button: TUDBtnType);
begin
 if ud_plane.tag<0 then exit;
 TexSaveUndo(uTexPlaneChange);
 sb_undo.enabled:=true;

 if Button=btNext then CurrentCoordID:=ud_plane.position+1
                  else CurrentCoordID:=ud_Plane.position-1;
 if CurrentCoordID<0 then CurrentCoordID:=0;
 if CurrentCoordID>ud_plane.Max then CurrentCoordID:=ud_plane.Max;
 //Перерисовать
 FindCoordCenter;
 MakeTVList(dc,hrc,CurrentCoordID);
 CalcTexVertex2D(TexWorkArea.ClientHeight);
 _FormPaint(Sender);

end;

initialization
 IsTexWrap:=false;
{ IsIJLLoaded:=false;}IsExit:=false;
 IsMouseDown:=false;IsArea:=false;
 IsKeyDown:=false;IsWheel:=false;
 IsRightMouseDown:=false;
 Zoom:=1;//100%
 ZoomX:=100;ZoomY:=100;
 TransX:=0;TransY:=0;             //переноса пока нет
 r:=1.0;g:=0;b:=0;
 rAngle:=0;
 InstrumStatus:=IsSelect;
 bExit:=false;
end.
