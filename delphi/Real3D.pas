//Содержит процедуры для полного вывода модели
//с учетом буфера глубины
unit Real3D;

interface
uses windows,messages,OpenGL,mdlWork,mdlDraw,objedut,math,crash;
type TSortPrimitive=record        //тип: примитив
 GeoNum:integer;                   //номер поверхности
 Z:GLfloat;                        //глубина примитива
 num:array [1..3] of integer;      //номера вершин
end;//of type
TSPArray=array of TSortPrimitive; //тип: массив для сортировки
//Инициализирует поля цвета/прозрачности/видимости
//в материалах и поверхностях.
//Используется для рендеринга в редакторе вершин
procedure InitMatTransp;
//Создает список всей модели, включая источник света.
//procedure Make3DListFill(dc:hdc;hrc:hglrc;flags:integer);
//Формирует массив примитивов для последующей сортировки
//procedure FormPrimitives({dc:hdc;hrc:hglrc;}ClientHeight:integer);
//Перезаполняет Z-координаты примитивов новыми значениями
//procedure ReFormPrimitives({dc:hdc;hrc:hglrc;}ClientHeight:integer);
//Сортирует указанный массив примитивов по Z-координате
procedure SortPrimitives(var PrSorted:TSPArray;PrLength:integer);
//Формирует список примитивов для анимации - т.е. по слоям,
//а не по материалам.
procedure AFormPrimitives(ClientHeight:integer);
//То же самое, только перезаполнение
procedure AReFormPrimitives(ClientHeight:integer);
//Рисование модели 3D по слоям.
//Рисуется только общий вид, черчение в режиме поверхности
//нужно выполнять "обычной" Make3DListFill
procedure AMake3DListFill;

Var PrSorted1,PrSorted2:TSPArray;//сортированные примитивы
    //1 - для блендинга (Blend), 2-для добавки(Additive)
    PrLength1,PrLength2:integer;  //длина массивов с ними
    pts1,pts2:cardinal;           //профилировочные
implementation
//Инициализирует поля цвета/прозрачности/видимости
//в материалах и поверхностях.
//Используется для рендеринга в редакторе вершин
procedure InitMatTransp;
Var i,ii:integer;
Begin
 for i:=0 to CountOfGeosets-1 do begin
  Geosets[i].Color4f[1]:=1;
  Geosets[i].Color4f[2]:=1;
  Geosets[i].Color4f[3]:=1;
  Geosets[i].Color4f[4]:=1;
 end;//of for i

 for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1
 do with Materials[i].Layers[ii] do begin
  AAlpha:=1;
  ATextureID:=TextureID;
 end;//of with/for ii/i
End;
//----------------------------------------------------------

//Var i:integer;
//Вспомогательная: вычерчивание фрагментов модели из массива
procedure Draw3DPartFromArray(var PrSorted:TSPArray;PrLength:integer);
Var StIndex,gn,PrN:integer;//ts1,ts2:cardinal;
Begin
  if PrLength=0 then exit;        //нечего рисовать
  PushFunction(360);
  //Начали!!!
  StIndex:=0;                     //начальный индект куска
  repeat                          //основной цикл (PrSorted)
   PrN:=StIndex;                  //ту же группу
   Gn:=PrSorted[PrN].GeoNum;      //поверхность примитива
   //Установить текстуру материала
   glBindTexture(GL_TEXTURE_2D,Materials[Geosets[Gn].MaterialID].ListNum);
   //Вывод текстурированного
   glColor4f(Geosets[gn].Color4f[1],Geosets[gn].Color4f[2],
             Geosets[gn].Color4f[3],Geosets[gn].Color4f[4]);
   if Geosets[gn].Color4f[4]<0.01 then glColor4f(0,0,0,0);

   //Установка массивов вершин
   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn].Normals[0]);
   glTexCoordPointer(2,GL_FLOAT,0,@Geosets[Gn].Crds[0].TVertices[0]);

   glBegin(GL_TRIANGLES);           //рисование
   repeat                           //цикл вывода треугольников
    with PrSorted[PrN] do begin//треугольник
     glArrayElement(num[1]);
     glArrayElement(num[2]);
     glArrayElement(num[3]);
    end;//of with
    inc(PrN);
   until (PrSorted[PrN].GeoNum<>gn) or (PrN>PrLength-1);//до конца куска
   glEnd;
   StIndex:=PrN;                  //следующий кусок
  until PrN>PrLength-1;             //основной цикл
  PopFunction;
End;

//Вспомогательная: вычерчивание фрагментов модели из массива
//Используется при анимации
procedure ADraw3DPartFromArray(var PrSorted:TSPArray;PrLength:integer;
                               IsMultAlpha:boolean);
Var StIndex,{j,}gn,PrN,lrNum,CurCrdID,MatrixID:integer;
    a:GLFloat;
    IsAddAlpha:boolean;           //true, если установлен режим AddAlpha
Begin
  IsAddAlpha:=false;              //пока такой режим не уст.
  if PrLength=0 then exit;        //нечего рисовать
  PushFunction(361);
  //Начали!!!
  StIndex:=0;                     //начальный индект куска
  MatrixID:=-1;                   //пока нет текстурной матрицы
  repeat                          //основной цикл (PrSorted)
   PrN:=StIndex;                  //ту же группу
   Gn:=PrSorted[PrN].GeoNum and $FFFF;//поверхность примитива
   lrNum:=PrSorted[PrN].GeoNum shr 16;//номер слоя
   with Materials[Geosets[Gn].MaterialID].Layers[lrNum] do begin
    //Установить текстуру слоя материала
    glBindTexture(GL_TEXTURE_2D,Textures[ATextureID].ListNum);
    //Вывод текстурированного
    if IsMultAlpha then begin
     a:={0.5*}AAlpha;
     //!dbg: "шкуринг" глюка
     if Materials[Geosets[Gn].MaterialID].CountOfLayers>1 then a:=0.1*a;
    end else a:={0.5}1;//of if
    glColor4f(Geosets[gn].Color4f[1]*a,Geosets[gn].Color4f[2]*a,
              Geosets[gn].Color4f[3]*a,
              AAlpha*Geosets[gn].Color4f[4]);
    //Проверить на затенение:
    if IsLight then
    if IsUnshaded then glDisable(GL_LIGHTING)
                  else begin glEnable(GL_LIGHTING);glEnable(GL_LIGHT0);end;
    //Установка отсечения сторон треугольников
    if IsTwoSided then glDisable(GL_CULL_FACE)
                  else glEnable(GL_CULL_FACE);
    //Установка режима смешения
    if (IsAddAlpha xor (FilterMode=AddAlpha)) then begin
     IsAddAlpha:=not IsAddAlpha;
     if IsAddAlpha then glBlendFunc(GL_SRC_ALPHA,GL_ONE)
                   else glBlendFunc(GL_ONE,GL_ONE);
    end;//of if
    //Установка номера CoordID
    if CoordID>=0 then CurCrdID:=CoordID else CurCrdID:=0;
    //Установка текстурной матрицы (если нужно)
    if (TVertexAnimID>=0) and (TVertexAnimID<>MatrixID) then begin
     glLoadMatrixd(@TexMatrix);
     MatrixID:=TVertexAnimID;
    end;//of if
    if (TVertexAnimID<0) and (MatrixID<>-1) then begin
     glLoadIdentity;
     MatrixID:=-1;
    end;//of if
   end;//of with

   //Установка массивов вершин
   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn].Normals[0]);
   glTexCoordPointer(2,GL_FLOAT,0,@Geosets[Gn].Crds[CurCrdID].TVertices[0]);

   glBegin(GL_TRIANGLES);           //рисование
   repeat                           //цикл вывода треугольников
    //треугольник
    with PrSorted[PrN] do begin
     glArrayElement(num[1]);
     glArrayElement(num[2]);
     glArrayElement(num[3]);
    end;//of with
    inc(PrN);
   until (PrSorted[PrN].GeoNum<>gn) or (PrN>PrLength-1);//до конца куска
   glEnd;
   StIndex:=PrN;                  //следующий кусок
  until PrN>PrLength-1;             //основной цикл
  PopFunction;
End;

//Вспомогательная: чертит сетку для 3D-вида
//Здесь же создаётся список и выполняется иная рутина
procedure Draw3DGrid;
Var i:integer;ccX,ccY,ccZ:GLFloat;
Begin
 PushFunction(362);
 glEnable(GL_LIGHTING);           //освещенность
 glEnable(GL_LIGHT0);
 glEnable(GL_LIGHT1);

 //0. Пересоздать список
 if CurrentListNum<>-1 then glDeleteLists(CurrentListNum,1);
 CurrentListNum:=glGenLists(1);
 //Начало списка
 glNewList(CurrentListNum,gl_compile);
//  glClearColor(0.5,0.5,0.5,1);
  glClearColor(0.8,0.8,0.8,1.0);//цвет фона
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);//очистка
  glDisable(GL_LIGHTING);
 //0.1. Чертить оси координат
 glLineWidth(2.5);           //толщина линий
 if IsAxes then begin
  glBegin(GL_LINES);          //линии
   glColor3f(1.0,0,0);        //красный цвет
   glVertex3f(-200,0,0);
   glVertex3f(200,0,0);
   glColor3f(0,1,0);          //ось y
   glVertex3f(0,-200,0);
   glVertex3f(0,200,0);
   glColor3f(0,0,1);
   glVertex3f(0,0,-200);
   glVertex3f(0,0,200);
  glEnd;
  glLineWidth(5);
  glBegin(GL_LINES);
   glVertex3f(0,0,200);
   glVertex3f(0,0,210);
   glColor3f(1,0,0);
   glVertex3f(200,0,0);
   glVertex3f(210,0,0);
   glColor3f(0,1,0);
   glVertex3f(0,200,0);
   glVertex3f(0,210,0);
  glEnd;
 end;//of if (оси координат)
 //Мелкая сетка
 glLineWidth(1);
 if IsLowGrid then begin
  glColor3f(0.5,0.5,0.5);//glLineWidth(1);
  glBegin(GL_LINES);
   if IsXYGrid then for i:=-32 to 32 do begin
    glVertex3f(i*8,-256,0);
    glVertex3f(i*8,256,0);
    glVertex3f(-256,i*8,0);
    glVertex3f(256,i*8,0);
   end;//of for
   if IsXZGrid then for i:=-32 to 32 do begin //еще одна сетка
    glVertex3f(i*8,0,-256);
    glVertex3f(i*8,0,256);
    glVertex3f(-256,0,i*8);
    glVertex3f(256,0,i*8);
   end;//of for/if
  if IsYZGrid then for i:=-32 to 32 do begin //еще одна сетка
   glVertex3f(0,i*8,-256);
   glVertex3f(0,i*8,256);
   glVertex3f(0,-256,i*8);
   glVertex3f(0,256,i*8);
  end;//of for/if
  glEnd;
 end;//of if
 //0.2. Чертить сетку XY
 glColor3f(0,0,0);glLineWidth(1);
 glBegin(GL_LINES);
  if IsXYGrid then for i:=-4 to 4 do begin
   glVertex3f(i*64,-256,0);
   glVertex3f(i*64,256,0);
   glVertex3f(-256,i*64,0);
   glVertex3f(256,i*64,0);
  end;//of for/if
  if IsXZGrid then for i:=-4 to 4 do begin //еще одна сетка
   glVertex3f(i*64,0,-256);
   glVertex3f(i*64,0,256);
   glVertex3f(-256,0,i*64);
   glVertex3f(256,0,i*64);
  end;//of for/if
  if IsYZGrid then for i:=-4 to 4 do begin //еще одна сетка
   glVertex3f(0,i*64,-256);
   glVertex3f(0,i*64,256);
   glVertex3f(0,-256,i*64);
   glVertex3f(0,256,i*64);
  end;//of for/if
 glEnd;
 //вывод подсветки осей к-т
 if IsXYZ then DrawXYZ;
 if IsNormals then begin
  glScalef(1.0,-1.0,1.0);
  DrawNormals;
  glScalef(1.0,-1.0,1.0);
 end;//of if
 PopFunction;
End;

//Создает список всей модели, включая источник света.
(*procedure Make3DListFill(dc:hdc;hrc:hglrc;flags:integer);
Var i,ii{,j},gn,len:integer;
Begin
 PushFunction(363);
 Draw3DGrid;
 glScalef(1.0,-1.0,1.0);          //отражение системы координат
 glEnableClientState(GL_VERTEX_ARRAY);
 glEnableClientState(GL_NORMAL_ARRAY);
 //1. Чертить развороты/треугольники
 if IsLight then glEnable(GL_LIGHTING);//освещенность
 glEnable(GL_LIGHT0);
 glEnable(GL_COLOR_MATERIAL);
// glEnable(GL_POLYGON_SMOOTH);//сглаживание треугольников
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);//с заливкой
 if (flags and 1)<>0 then begin   //если это - полный вид
  glDepthFunc(GL_LEQUAL);
  glEnable(GL_TEXTURE_2D);        //текстура
 end;//of if

 if (flags and 1)<>0 then begin  //если это - полный вид
  //1. Вывод сплошных поверхностей
  glAlphaFunc(GL_GEQUAL,0.75);
  glEnable(GL_DEPTH_TEST);        //используем буфер глубины
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);//текстурный массив
  //собственно цикл вывода
  for gn:=0 to CountOfGeosets-1 do begin
   //Пропускаем невидимое, рисуем лишь сплошные
   if VisGeosets[gn]=false then continue;
   if (Materials[Geosets[Gn].MaterialID].TypeOfDraw<>Opaque) and
      (Materials[Geosets[Gn].MaterialID].TypeOfDraw<>ColorAlpha) then continue;
//   RecalcNormals(gn+1);           //расчет нормалей
   glColor4f(Geosets[gn].Color4f[1],Geosets[gn].Color4f[2],
             Geosets[gn].Color4f[3],Geosets[gn].Color4f[4]);
   if Geosets[gn].Color4f[4]<0.01 then continue;
   //Установить текстуру материала
   glBindTexture(GL_TEXTURE_2D,Materials[Geosets[Gn].MaterialID].ListNum);
   //Установить способ рисования - с проверкой Альфа или без
   if Materials[Geosets[Gn].MaterialID].TypeOfDraw=ColorAlpha then
    glEnable(GL_ALPHA_TEST)
   else glDisable(GL_ALPHA_TEST);

   //Установить указатели на массив вершин
   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn].Normals[0]);
   glTexCoordPointer(2,GL_FLOAT,0,@Geosets[gn].Crds[0].TVertices[0]);
   glBegin(GL_TRIANGLES);         //рисование
    for i:=0 to Geosets[Gn].CountOfFaces-1 do begin
     len:=length(Geosets[Gn].Faces[i])-1;
     for ii:=0 to len do glArrayElement(Geosets[Gn].Faces[i,ii]);
    end;//of for i
   glEnd;
  end;//of for (gn)

  //2. Вывод смешиваемых поверхностей
  glDisable(GL_ALPHA_TEST);
  glEnable(GL_BLEND);             //включить блендинг
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);//смешение
  glDepthMask(false);
  Draw3DPartFromArray(PrSorted1,PrLength1);//вывод участка

  //3. Вывод аддитивных участков
  glBlendFunc(GL_ONE,GL_ONE);
  Draw3DPartFromArray(PrSorted2,PrLength2);//вывод участка
  glDepthMask(true);

  //4. Вывод вершин (если нужно):
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  if (flags and 4)<>0 then InternalDrawVertices;
  glScalef(1.0,-1.0,1.0);
  glDisableClientState(GL_NORMAL_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//--------------------------------
 end else begin//of if
  glCullFace(GL_BACK);
  if (flags and 2)=0 then for gn:=0 to CountOfGeosets-1 do begin
   RecalcNormals(gn+1);           //расчет нормалей
   SmoothWithNormals(gn);
   ApplySmoothGroups;
  end;//of if
  for gn:=CountOfGeosets downto 1 do begin
   if VisGeosets[gn-1]=false then continue;
{   if (flags and 2)=0 then begin
    RecalcNormals(gn);              //расчет нормалей
    SmoothWithNormals(gn-1);
    ApplySmoothGroups;
   end;}
   if Materials[Geosets[gn-1].MaterialID].Layers[0].IsTwoSided
   then glDisable(GL_CULL_FACE)
   else glEnable(GL_CULL_FACE);
   glColor3f(1.0,0.6,0.6);          //цвет

   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn-1].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn-1].Normals[0]);
   glBegin(GL_TRIANGLES);           //рисование
   for i:=0 to Geosets[Gn-1].CountOfFaces-1 do
   for ii:=0 to length(Geosets[Gn-1].Faces[i])-1 do begin
    glArrayElement(Geosets[Gn-1].Faces[i,ii]); //номер вершины
   end;//of for ii/i
   glEnd;
  end;//of for gn
  glDisable(GL_CULL_FACE);
  //Вывод вершин (если нужно):
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  if (flags and 4)<>0 then InternalDrawVertices;
  glScalef(1.0,-1.0,1.0);
  glDisableClientState(GL_NORMAL_ARRAY);
  if AnimEdMode<>1 then begin
   glDisable(GL_LIGHTING);        //снять освещённость
   glDisable(GL_DEPTH_TEST);      //отключить тест глубины
   glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
   glLineStipple(1,$1C47);
   DrawObjects(false);            //вывод объектов (контурно)
   glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
   glEnable(GL_DEPTH_TEST);
   DrawObjects(true);             //вывод объектов (сплошным)
  end;//of if
 end;//of if

 if (flags and 1)<>0 then begin   //если это - полный вид
  glDisable(GL_BLEND);             //режим смешения
  glDisable(GL_TEXTURE_2D);        //текстура
 end;//of if
 glEndList;                       //конец списка
// pts2:=GetTSC-pts1;
  PopFunction;
End;             *)
//---------------------------------------------------------
//Вывод поверхности
procedure RenderSurface;
Var gn,i,ii:integer;
Begin
  glCullFace(GL_BACK);
  {if (flags and 2)=0 then} for gn:=0 to CountOfGeosets-1 do begin
   RecalcNormals(gn+1);           //расчет нормалей
   SmoothWithNormals(gn);
   ApplySmoothGroups;
  end;//of for gn/if
  for gn:=CountOfGeosets downto 1 do begin
   if VisGeosets[gn-1]=false then continue;
   if Materials[Geosets[gn-1].MaterialID].Layers[0].IsTwoSided
   then glDisable(GL_CULL_FACE)
   else glEnable(GL_CULL_FACE);
   glColor3f(1.0,0.6,0.6);          //цвет

   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn-1].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn-1].Normals[0]);
   glBegin(GL_TRIANGLES);           //рисование
   for i:=0 to Geosets[Gn-1].CountOfFaces-1 do
   for ii:=0 to length(Geosets[Gn-1].Faces[i])-1 do begin
    glArrayElement(Geosets[Gn-1].Faces[i,ii]); //номер вершины
   end;//of for ii/i
   glEnd;
  end;//of for gn
  glDisable(GL_CULL_FACE);
  //Вывод вершин (если нужно):
  glDisable(GL_LIGHTING);
  glDisable(GL_BLEND);
  glDisable(GL_TEXTURE_2D);
  glDisableClientState(GL_NORMAL_ARRAY);
  if IsVertices then InternalDrawVertices;
  glScalef(1.0,-1.0,1.0);
  glDisableClientState(GL_NORMAL_ARRAY);
End;

//Вывод "объектной" части
procedure DrawObjPart;
Begin
 glDisable(GL_DEPTH_TEST);
 glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
 glLineStipple(1,$1C47);
 DrawObjects(false);             //вывод объектов (контурно)
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
 glEnable(GL_DEPTH_TEST);
 DrawObjects(true);              //вывод объектов (сплошным)
End;

//Рисование модели 3D по слоям.
//Рисуется только общий вид, черчение в режиме поверхности
//нужно выполнять "обычной" Make3DListFill
procedure AMake3DListFill;
Var i,ii{,j},gn,len,lrNum,CurCrdID:integer;
    IsMatChange:boolean;
Begin
 PushFunction(364);
 Draw3DGrid;
 glScalef(1.0,-1.0,1.0);          //отражение системы координат
 glEnableClientState(GL_VERTEX_ARRAY);//массивы вершин
 glEnableClientState(GL_NORMAL_ARRAY);
 glEnableClientState(GL_TEXTURE_COORD_ARRAY);
 //1. Чертить развороты/треугольники
 if IsLight then glEnable(GL_LIGHTING);//освещенность
 glEnable(GL_LIGHT0);
 glEnable(GL_COLOR_MATERIAL);
// glEnable(GL_POLYGON_SMOOTH);//сглаживание треугольников
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);//с заливкой
 if ViewType=1 then begin
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  RenderSurface;
  if AnimEdMode<>1 then DrawObjPart;
  glEndList;                      //конец списка
  PopFunction;
  exit;
 end;//of if

 glDepthFunc(GL_LEQUAL);
 glEnable(GL_TEXTURE_2D);        //текстура
 glCullFace(GL_BACK);
 glMatrixMode(GL_TEXTURE);      //режим текстурной матрицы
 IsMatChange:=false;

 //1. Вывод сплошных поверхностей
 glAlphaFunc(GL_GEQUAL,0.75);
 glEnable(GL_DEPTH_TEST);        //используем буфер глубины
 //собственно цикл вывода
 for gn:=0 to CountOfGeosets-1 do begin
  //Пропускаем невидимое, рисуем лишь сплошные поверхности
  if (VisGeosets[gn]=false) or (Geosets[gn].Color4f[4]<=0.01) then continue;
  for lrNum:=0 to Materials[Geosets[Gn].MaterialID].CountOfLayers-1 do
  with Materials[Geosets[Gn].MaterialID].Layers[lrNum] do begin
   if ((FilterMode<>Opaque) and (FilterMode<>ColorAlpha)) then continue;
   if (FilterMode=ColorAlpha) and (AAlpha<0.75) then continue;
   if (FilterMode=Opaque) and (AAlpha<0.01) then continue;
   //Установить текущую плоскость CoordID
   if CoordID>=0 then CurCrdID:=CoordID else CurCrdID:=0;
   //Установить указатели на массивы вершин
   glVertexPointer(3,GL_FLOAT,0,@Geosets[Gn].Vertices[0]);
   glNormalPointer(GL_FLOAT,0,@Geosets[Gn].Normals[0]);
   glTexCoordPointer(2,GL_FLOAT,0,@Geosets[Gn].Crds[CurCrdID].TVertices[0]);
   glColor4f(Geosets[gn].Color4f[1],Geosets[gn].Color4f[2],
             Geosets[gn].Color4f[3],AAlpha*Geosets[gn].Color4f[4]);
   //Установить текстуру слоя
   glBindTexture(GL_TEXTURE_2D,Textures[ATextureID].ListNum);
   //Установить освещение
   if IsLight then
   if IsUnshaded then glDisable(GL_LIGHTING)
                 else begin glEnable(GL_LIGHTING);glEnable(GL_LIGHT0);end;
   //Установка отсечения сторон треугольников
   if IsTwoSided then glDisable(GL_CULL_FACE)
                 else glEnable(GL_CULL_FACE);
   //Установить способ рисования - с проверкой Альфа или без
   if FilterMode=ColorAlpha then
    glEnable(GL_ALPHA_TEST)
   else glDisable(GL_ALPHA_TEST);
   //Установить текстурную матрицу (если нужно)
   if TVertexAnimID>=0 then begin
    glLoadMatrixd(@TexMatrix);
    IsMatChange:=true;
   end else if IsMatChange then begin
    IsMatChange:=false;
    glLoadIdentity;
   end;//of if

   glBegin(GL_TRIANGLES);         //рисование
   for i:=0 to Geosets[Gn].CountOfFaces-1 do begin
    len:=length(Geosets[Gn].Faces[i])-1;
    for ii:=0 to len do glArrayElement(Geosets[Gn].Faces[i,ii]);
   end;//of for i
   glEnd;
  end;//of for lrNum
 end;//of for (gn)

 //2. Вывод смешиваемых поверхностей
 glLoadIdentity;                 //сброс текстурной матрицы
 glDisable(GL_ALPHA_TEST);
 glEnable(GL_BLEND);             //включить блендинг
 glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);//смешение
 glDepthMask(false);
 glDepthFunc(GL_LEQUAL);
 ADraw3DPartFromArray(PrSorted1,PrLength1,false);//вывод участка

 //3. Вывод аддитивных участков
 glBlendFunc(GL_ONE,GL_ONE);
// glBlendFunc(GL_ONE,GL_DST_ALPHA);
 ADraw3DPartFromArray(PrSorted2,PrLength2,true);//вывод участка
 glDepthMask(true);
 glDisable(GL_BLEND);             //режим смешения
 glDisable(GL_TEXTURE_2D);        //текстура
 glDisable(GL_CULL_FACE);
 glLoadIdentity;                  //сброс текстурной матрицы
 glMatrixMode(GL_MODELVIEW);      //переход на матрицу модели
 glScalef(1.0,-1.0,1.0);          //отражение системы координат
 glDisableClientState(GL_NORMAL_ARRAY);
 glDisableClientState(GL_TEXTURE_COORD_ARRAY);

 glDisable(GL_LIGHTING);         //снять освещённость
 glDisable(GL_DEPTH_TEST);       //отключить тест глубины
 if IsVertices and ((AnimEdMode<>1) or (EditorMode=1)) then begin
  glScalef(1.0,-1.0,1.0);         //отражение системы координат
  if IsVertices then InternalDrawVertices;
  glScalef(1.0,-1.0,1.0);         //отражение системы координат
 end;//of if

 if AnimEdMode<>1 then DrawObjPart;
 glEndList;                       //конец списка
 PopFunction;
End;
//=========================================================
//Формирует массивы примитивов для последующей сортировки
(*procedure FormPrimitives(ClientHeight:integer);
Var i,ii,j,len,slen:integer;Triangle:TSortPrimitive;
Begin
 PushFunction(365);
 PrLength1:=0;PrSorted1:=nil;       //инициализация
 PrLength2:=0;PrSorted2:=nil;       //еще инициализация
 //Расчет всех нормалей
 for i:=0 to CountOfGeosets-1 do begin
  RecalcNormals(i+1);
  SmoothWithNormals(i);
 end;//of for i
 ApplySmoothGroups;

 CalcVertex2D(ClientHeight);   //рассчитать глубины вершин
 //цикл по всем поверхностям
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  //Пропустить невидимые и непрозрачные поверхности
  //(невидимые не рисуются, непрозрачные рисуются без сортировки)
  if VisGeosets[i]=false then continue;
  if (Materials[Geosets[i].MaterialID].TypeOfDraw=Opaque) or
     (Materials[Geosets[i].MaterialID].TypeOfDraw=ColorAlpha) then continue;

  Triangle.GeoNum:=i;               //номер поверхности
  //цикл по всем треугольникам
  slen:=length(Geosets[i].Faces)-1;
  for ii:=0 to slen do begin
   j:=0;len:=length(Geosets[i].Faces[ii]);//инициализация
   repeat
    Triangle.num[1]:=Geosets[i].Faces[ii,j];//читаем номера вершин
    Triangle.num[2]:=Geosets[i].Faces[ii,j+1];
    Triangle.num[3]:=Geosets[i].Faces[ii,j+2];
    j:=j+3;
    //расчет глубины
    Triangle.Z:=(Vertices2D[Triangle.num[1]].z+
                Vertices2D[Triangle.num[2]].z+
                Vertices2D[Triangle.num[3]].z)*0.3333333{-j*1e-6-0.005*Triangle.GeoNum};
    //Проверка: в какой массив засунуть
    if Materials[Geosets[i].MaterialID].TypeOfDraw=FullAlpha then begin
     inc(PrLength1);SetLength(PrSorted1,PrLength1);
     PrSorted1[PrLength1-1]:=Triangle;//добавить в список
    end else begin                //Additive, другой массив
     inc(PrLength2);SetLength(PrSorted2,PrLength2);
     PrSorted2[PrLength2-1]:=Triangle;//добавить в список
    end;//of if (TypeOfDraw)
   until j>=len;
  end;//of for ii
 end;//of for i
// CurrentGeosetNum:=CurNum;
 PopFunction;
End;     *)
//---------------------------------------------------------
//Сортирует указанный массив примитивов по Z-координате
procedure SortPrimitives(var PrSorted:TSPArray;PrLength:integer);
Var d,i,j:integer;Tr:TSortPrimitive;
Begin
 if PrLength=0 then exit;
 PushFunction(366);
 d:=round(log2(PrLength));
 asm
  fninit
 end;
{ fl:=Power(2,d);
 d:=round(fl)-1;}
 d:=trunc(Power(2,d))-1;
 repeat                           //цикл сортировки
 for i:=1 to PrLength-d do begin
  j:=i;                           //цикл с шагом
  repeat
   if PrSorted[j-1].z>=PrSorted[j+d-1].z then break;
   Tr:=PrSorted[j-1];
   PrSorted[j-1]:=PrSorted[j+d-1];
   PrSorted[j+d-1]:=Tr;
   j:=j-d;
  until j<1;
 end;//of for i
 d:=d shr 1;
 until d<=0;
 PopFunction;
End;
//--------------------------------------------------------
//Перезаполняет Z-координаты примитивов новыми значениями
(*procedure ReFormPrimitives({dc:hdc;hrc:hglrc;}ClientHeight:integer);
Var i,ii,j,len:integer;Triangle:TSortPrimitive;
//    PrLength:integer;
Begin
 PushFunction(367);
 PrLength1:=0;PrLength2:=0;
 CalcVertex2D(ClientHeight);   //рассчитать глубины вершин
 //цикл по всем поверхностям
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  //Пропустить невидимые и непрозрачные поверхности
  //(невидимые не рисуются, непрозрачные рисуются без сортировки)
  if VisGeosets[i]=false then continue;
  if (Materials[Geosets[i].MaterialID].TypeOfDraw=Opaque) or
     (Materials[Geosets[i].MaterialID].TypeOfDraw=ColorAlpha)then continue;

  Triangle.GeoNum:=i;               //номер поверхности
  //цикл по всем треугольникам
  for ii:=0 to length(Geosets[i].Faces)-1 do begin
   j:=0;len:=length(Geosets[i].Faces[ii]);//инициализация
   repeat
    Triangle.num[1]:=Geosets[i].Faces[ii,j];//читаем номера вершин
    Triangle.num[2]:=Geosets[i].Faces[ii,j+1];
    Triangle.num[3]:=Geosets[i].Faces[ii,j+2];
    j:=j+3;
    //расчет глубины
    Triangle.Z:=(Vertices2D[Triangle.num[1]].z+
                Vertices2D[Triangle.num[2]].z+
                Vertices2D[Triangle.num[3]].z)*0.3333333{-j*1e-6-
                0.005*(Triangle.GeoNum and $FFFF)};
    if Materials[Geosets[i].MaterialID].TypeOfDraw=FullAlpha then begin
     inc(PrLength1);
     PrSorted1[PrLength1-1]:=Triangle;        //добавить в список
    end else begin
     inc(PrLength2);
     PrSorted2[PrLength2-1]:=Triangle;        //добавить в список
    end;//of if (TypeOfDraw)
   until j>=len;
  end;//of for ii
 end;//of for i
 PopFunction;
End;        *)
//---------------------------------------------------------
//Формирует список примитивов для анимации - по слоям.
procedure AFormPrimitives(ClientHeight:integer);
Var i,ii,j,jj,len,slen:integer;Triangle:TSortPrimitive;
Const lrType=$10000;
Begin
 PushFunction(368);
 PrLength1:=0;PrSorted1:=nil;       //инициализация
 PrLength2:=0;PrSorted2:=nil;       //еще инициализация
 //Расчет всех нормалей
 for i:=0 to CountOfGeosets-1 do begin
  RecalcNormals(i+1);
  SmoothWithNormals(i);
 end;//of for i
 ApplySmoothGroups;

 CalcVertex2D(ClientHeight);   //рассчитать глубины вершин
 //цикл по всем поверхностям
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  //Пропустить невидимые и непрозрачные поверхности
  //(невидимые не рисуются, непрозрачные рисуются без сортировки)
  if (VisGeosets[i]=false) or (Geosets[i].Color4f[4]<1e-5) then continue;
  for jj:=0 to Materials[Geosets[i].MaterialID].CountOfLayers-1 do begin
  if (Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=Opaque) or
     (Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=ColorAlpha) or
     (Materials[Geosets[i].MaterialID].Layers[jj].AAlpha<1e-2)
      then continue;
   Triangle.GeoNum:=i+jj*lrType;  //номер поверхности+номер слоя
   //цикл по всем треугольникам
   slen:=length(Geosets[i].Faces)-1;
   for ii:=0 to slen do begin
    j:=0;len:=length(Geosets[i].Faces[ii]);//инициализация
    repeat
     Triangle.num[1]:=Geosets[i].Faces[ii,j];//читаем номера вершин
     Triangle.num[2]:=Geosets[i].Faces[ii,j+1];
     Triangle.num[3]:=Geosets[i].Faces[ii,j+2];
     j:=j+3;
     //расчет глубины
     Triangle.Z:=(Vertices2D[Triangle.num[1]].z+
                 Vertices2D[Triangle.num[2]].z+
                 Vertices2D[Triangle.num[3]].z)*0.3333333-j*1e-6-0.005*Triangle.GeoNum;
     //Проверка: в какой массив засунуть
     if Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=FullAlpha then begin
      inc(PrLength1);SetLength(PrSorted1,PrLength1);
      PrSorted1[PrLength1-1]:=Triangle;//добавить в список
     end else begin                //Additive, другой массив
      inc(PrLength2);SetLength(PrSorted2,PrLength2);
      PrSorted2[PrLength2-1]:=Triangle;//добавить в список
     end;//of if (TypeOfDraw)
    until j>=len;
   end;//of for ii
  end;//of for jj
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//То же самое, только перезаполнение
procedure AReFormPrimitives(ClientHeight:integer);
Var i,ii,j,jj,len:integer;Triangle:TSortPrimitive;
Const lrType=$10000;
Begin
 PushFunction(369);
 PrLength1:=0;PrSorted1:=nil;       //инициализация
 PrLength2:=0;PrSorted2:=nil;       //еще инициализация
 CalcVertex2D(ClientHeight);   //рассчитать глубины вершин
 //цикл по всем поверхностям
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  //Пропустить невидимые и непрозрачные поверхности
  //(невидимые не рисуются, непрозрачные рисуются без сортировки)
  if (VisGeosets[i]=false) or (Geosets[i].Color4f[4]<1e-5) then continue;
  for jj:=0 to Materials[Geosets[i].MaterialID].CountOfLayers-1 do begin
  if (Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=Opaque) or
     (Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=ColorAlpha) or
     (Materials[Geosets[i].MaterialID].Layers[jj].AAlpha<1e-2)
      then continue;
   Triangle.GeoNum:=i+jj*lrType;  //номер поверхности+номер слоя
   //цикл по всем треугольникам
   for ii:=0 to length(Geosets[i].Faces)-1 do begin
    j:=0;len:=length(Geosets[i].Faces[ii]);//инициализация
    repeat
     Triangle.num[1]:=Geosets[i].Faces[ii,j];//читаем номера вершин
     Triangle.num[2]:=Geosets[i].Faces[ii,j+1];
     Triangle.num[3]:=Geosets[i].Faces[ii,j+2];
     j:=j+3;
     //расчет глубины
     Triangle.Z:=(Vertices2D[Triangle.num[1]].z+
                 Vertices2D[Triangle.num[2]].z+
                 Vertices2D[Triangle.num[3]].z)*0.3333333-j*1e-6-
                 0.005*(Triangle.GeoNum and $FFFF);
     //Проверка: в какой массив засунуть
     if Materials[Geosets[i].MaterialID].Layers[jj].FilterMode=FullAlpha then begin
      inc(PrLength1);SetLength(PrSorted1,PrLength1);
      PrSorted1[PrLength1-1]:=Triangle;//добавить в список
     end else begin                //Additive, другой массив
      inc(PrLength2);SetLength(PrSorted2,PrLength2);
      PrSorted2[PrLength2-1]:=Triangle;//добавить в список
     end;//of if (TypeOfDraw)
    until j>=len;
   end;//of for ii
  end;//of for jj
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//initialization
end.
