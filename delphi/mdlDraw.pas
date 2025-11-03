unit mdlDraw;

interface  
uses Windows,Messages,OpenGL,mdlwork,math,classes,cabstract,crash;
type
TVertex2D=record //тип: 2D-вершина
 x,y,z:GLDouble;      //координаты объекта
 id:integer;          //id объекта
end;

//Тип: запись об отменах
TUndo=record         //данные для отмены последнего действия
 //Обычные
 data1:array of GLfloat;
 data2:array of GLfloat;
 data3:array of GLfloat;
 idata:array of integer;
 Status1:cardinal;
 Status2:integer;
 //Полные
 GeosetAnim:TGeosetAnim;        //хранилище для анимации видимости
 Anims:array of TAnim;          //список анимаций поверхности
 Ext:TAnim;                     //хранилище границ поверхности
 Unselectable:boolean;
 MatID,SelGroup,HierID:integer; //параметры поверхности
 Vertices:array of TVertex;
 Normals:array of TNormal;      //нормали
 Crds:array of TCrds;           //текстурные координаты
 VertexGroup:array of integer;  //группы вершин
 Faces:array of TFace;          //развороты
 Groups:array of TFace;         //соединения с костями
 VertexList:array of integer;   //список выделенных вершин
 Controllers:array of TController;
 Sequence:TSequence;            //последовательность
end;//of type

//Тип: запись о состоянии поверхности
TGeoObj=record               //Объект, связанный с поверхностью
 IsSelected:boolean;         //true, если поверхность выбрана
 IsDelete:boolean;           //true, если объект подлежит удалению
 Undo:array [1..10] of TUndo;//массив для записи действий
// TexUndo:array[1..10] of TUndo;//то же, но для текстуры
 SelFaces:TFace;             //список выделенных треугольников
 NewVertices,NewFaces:array of integer;//для экструзии
 OldCountOfVertices:integer; //для экструзии
 IsBufferActive:boolean;     //true, если буфер не пуст
 InternalBuffer:TGeoset;     //внутренний буфер (Copy/Paste)
 InternalNums:array of integer;//номера вершин в буфере
 Vertices2D:array of TVertex2D;//массив 2D-вершин
 TexVertices2D:array of TVertex2D;
 VertexList:array of integer;  //массив выделенных вершин
 VertexCount:integer;//кол-во вершин в этом списке
 TexVertexList:array of integer;//массив вершин ред. текстур
 TexVertexCount:integer;       //кол-во вершин в этом списке
 TexSelVertexList:array of integer;
 TexSelVertexCount:integer;    
 HideVertices:array of integer;//скрытые вершины
 HideVertexCount:integer;      //кол-во скрытых вершин
end;//of TGeoObj

//Тип: выделенный объект
TSelectedObject=record            //выделенный объект и всё, что с ним связано
 IsSelected:boolean;              //true, если хоть что-то выделено
 b:TBone;                         //копия скелетной части объекта
 ObjType:integer;                 //тип объекта
 ChildObjects:array of integer;   //массив ID дочерних объектов
 CountOfChilds:integer;           //кол-во таких объектов
 CompetitorObjs:TFace;            //ID объектов, лежащих рядом (для выб. кликом)
 CountOfCompObjs:integer;         //кол-во таких объектов
 IDInComps:integer;               //ID данного объекта в массиве CompetitorObjs
 //---------------------
 IsMultiSelect:boolean;           //true, если допустимо выделение группы
 CountOfSelObjs:integer;          //кол-во выделенных объектов
 SelObjs:TFace;                   //массив ID выделенных объектов
end;//of TSelectedObject

TBuffer=record                  //тип: "внешний" буфер
 IsActive:boolean;              //true, если буфер не пуст
 Materials:array of TMaterial;  //материалы поверхностей
 Textures:array of TTexture;    //текстуры
 COTextures,COMaterials:integer;
 InternalBuffers:array of TGeoset;//массив буферов
 InternalNums:array of array of integer;
 COGeosets:integer;             //кол-во поверхностей в буфере
end;//of TBuffer

TVisibleObjects=record            //видимые объекты
 //Установка в true какого-либо поля приводит к тому,
 //что объекты этого типа будут отображаться.
 VisBones:boolean;                //true, если кости видны
 VisAttachments:boolean;          //true, если они видны
 VisParticles:boolean;            //true, если видны ИЧ-2
 VisSkel:boolean;                 //true, если видны связки объектов
 VisOrient:boolean;               //true, если видна система к-т объекта
end;//of TVisibleObjects


TNullBone=record                  //объект-пустышка (кость)
 IsExists:boolean;                //true, если есть такой объект
 id,                              //id объекта
 IdInBones:integer;               //id элемента массива Bones
end;//of TNullBone

//Классы:
TNewUndo=class                    //глобальный класс отмены
 public
  TypeOfUndo:integer;             //тип отмены
  Prev:integer;                   //указатель на предыдущий объект или (-1)
  //Запись текущего состояния
  procedure Save;virtual;
  //Его восстановление
  procedure Restore;virtual;
end;//of TNewUndo

TUndoContainer=class(TNewUndo)    //контейнер для TUndo
 public
  Undo:TUndo;                     //основной Undo
  GeoU:array of TUndo;            //массив Undo из GeoObj
end;//of TUndoContainer

TObjUndo=class(TNewUndo)          //класс для хранения данных объекта
 public
  typ:integer;                    //тип объекта
  IdInArray:integer;              //ID элемента в массиве
end;//of TObjUndo

TBoneUndo=class(TObjUndo)         //класс для хранения данных кости
 public
  b:TBone;
end;

TAtchUndo=class(TObjUndo)         //класс для хранения данных кости
 public
  atch:TAttachment;               //аттач
end;//of TBoneUndo

TPre2Undo=class(TObjUndo)         //класс для хранения данных Источника
 public
  pre2:TParticleEmitter2;         //источник
end;//of TPre2Undo

TPivUndo=class(TNewUndo)          //для отмены создания/удаления новой точки
 public
  SelID,                          //ID выделенного объекта
  id:integer;                     //id позиции
  IsDel:boolean;                  //true, если удалён. false - создан
  pt:TVertex;                     //при IsDel=true - координаты точки
  procedure Save;override;        //сохранить единственную точку (позиция id)
  procedure Restore;override;     //восстановить ед. точку (в позицию id)
end;//of TPivUndo

TStampObjUndo=class(TNewUndo)     //для хранения слепка объектов
 public
  CountOfBones,CountOfLights,
  CountOfHelpers,CountOfAttachments,
  CountOfParticleEmitters1,
  CountOfParticleEmitters,
  CountOfRibbonEmitters,CountOfEvents,
  CountOfCollisionShapes:integer;
  Bones:ATBone;
  Lights:ATLight;
  Helpers:ATBone;
  Attachments:ATAttachment;
  ParticleEmitters1:ATParticleEmitter;
  pre2:ATParticleEmitter2;
  Ribs:ATRibbonEmitter;
  Events:ATEventObject;
  Collisions:ATCollisionShape;
end;//of TStampObjUndo

TRedGeo=record                    //для хранения фрагментов
 CountOfVertices,                 //матрицы
 CountOfMatrices:integer;         //вершины
 VertexGroup:array of integer;
 Groups:array of TFace;
end;
TStampGeoUndo=class(TNewUndo)     //для хранения слепка поверхностей/Pivot'ов
 public
  Geo:array of TRedGeo;           //хранилище поверхностей
  CountOfPivotPoints:integer;
  PivotPoints:array of TVertex;   //геом. центры
  SelID:integer;                  //id выделенного объекта
  lst:TFace;                      //список выделенных объектов
  len:integer;                    //длина этого списка
end;//of TStampGeoUndo

TNewControllerUndo=class(TNewUndo)//отмена создания контроллера
 private
  ContID:integer;                 //ID текущего объекта
  b:TBone;                        //текущий объект скелета
 public
  procedure Save;override;                 //запись текущего состояния
  procedure Restore;override;              //его восстановление
end;//of TNewControllerUndo

TDelControllerUndo=class(TNewUndo)         //только для удаления контроллера!
 private
  Cont:TController;                        //содержит сохранённый контроллер
 public
  ContID:integer;                          //id исходного контроллера
  procedure Save;override;
  procedure Restore;override;
end;//of TDelControllerUndo

TDelEvStamps=class(TNewUndo)               //для удаления меток событий
 private
  COEvents:integer;                        //кол-во событийных объектов
  stamps:array of array of integer;        //само кранилище меток
 public
  procedure Save;override;
  procedure Restore;override;
end;//of TDelEvStamps


Var VisObjs:TVisibleObjects; //список видимости объектов
    DelGeoObjs:array of TGeoObj;
    CountOfDelObjs:integer;
    CurView:TSceneView;      //текущий вид
    InstrumStatus:integer;//статус инструмента
//    vCurrent:TView;          //текущий вид
    Excentry_:GLFloat;        //эксцентриситет рабочей области
//_    Vertices2D:array of TVertex2D;//массив 2D-вершин
//_    TexVertices2D:array of TVertex2D;
    Objs2D:array of TVertex2D;    //массив к-т объектов
    CountOfObjs:integer;          //длина этого массива
{    Bones2D:array of TVertex2D;  //массив к-т костей
    Helpers2D:array of TVertex2D;           //помощников}
//_    VertexList:array of integer;  //массив выделенных вершин
//_    VertexCount:integer;//кол-во вершин в этом списке
//_    TexVertexList:array of integer;//массив вершин ред. текстур
//_    TexVertexCount:integer;       //кол-во вершин в этом списке
//_    TexSelVertexList:array of integer;
//_    TexSelVertexCount:integer;
//Следующие 5 строк нужно будет удалить, ибо мусор
//    SelectedBone:TBone;            //выделенная кость
    NumOfSelBone:integer;          //номер выд. кости (>65535 - помощник)
    ParentBone:TBone;              //родительская по отношению к ней
    NumOfParentBone:integer;       //номер род. кости
    ChildBones,ChildHelpers:array of integer;//список потомков
//    ChildVertices:array of TVertex;//вершины, связ. с дочерними объектами
//    CountOfChildVertices:integer; //кол-во этих вершин
    MinFrame,MaxFrame:integer;    //кадры последовательности
    SumFrame:cardinal;            //суммарное кол-во проигранных кадров
    SelMinFrame,SelMaxFrame:integer;//выделенные кадры
    UsingGlobalSeq:integer;       //текущая глоб. последовательность.
    IsContrFilter:boolean;        //присутствие фильтра контроллеров
    ContrFilter:TList;            //фильтр: список ID выделенных контроллеров
{    CountOfSelControllers:integer; //кол-во выделенных фильтром контроллеров
    FilterContrIDs:array of integer;//массив ID выделенных контроллеров}
//_    HideVertices:array of integer;//скрытые вершины
//_    HideVertexCount:integer;      //кол-во скрытых вершин
//_    CurrentGeosetNum:integer;     //номер текущей поверхности
    TexListNum:integer;           //номер списка вершин
    IsNoEndList:boolean;//true, если нужно пропустить glEndList в DrawVerices
    //Переменные, связанные с рисованием:
//    IsDepth,             //глубина
    IsLowGrid,           //мелкая сетка (8x8)
    IsXZGrid,            //сетка XZ
    IsYZGrid,            //сетка YZ
    IsXYGrid,            //сетка XY
    IsShowAll,           //отображать ли все поверхности
    IsXYZ,               //выводить ли мини-оси
    IsNormals,           //выводить ли нормали
    IsAxes,              //выводить ли оси
    IsVertices,          //чертить ли вершины в 3D-режимах
    IsDisp              //смещать ли вставляемое (Ctrl+V) по Z
//    IsBoneActive         //показ костей
    :boolean;
    ViewType:integer;    //обычный вид(0), поверхность(1), общий вид(2)
    BilbMatrix:TRotMatrix;//матрица поворота Billboard-объектов
    IsLight:boolean;              //если true, использовать свет
    NullBone:TNullBone;           //объект-"заглушка"
    GeoObjs:array of TGeoObj;//массив связанных объектов
    ChObj,              //дочерний объект (для связывания)
    SelObj:TSelectedObject;       //данные о выделенном объекте
    EditorMode:integer;   //РЕЖИМ РЕДАКТОРА    
    AnimEdMode:integer; //режим работы редактора анимаций
                        //(соответствует ID выбранной закладки)
    ccX,ccY,ccZ,        //координатный центр (центр выделения)
    ccVX,ccVY,ccVZ:GLFloat; //координатный центр выделенных вершин
    
Const ctAlpha=1;ctRotation=2;ctTranslation=3;
      ctScaling=4;
      BoneSize=4;   //Размер костей
      AtchSize=3;   //Размер точек прикрепления

      //типы отмены:
      nuUndoContainer=1;//контейнер Undo
      nuDeleteSeqs=2;    //удаление последовательностей

      //инструменты:
      isSelect=1;     //статус инструмента
      isSelectedArea=2;//область выделения
      isMove=3;       //перемещение выделенного
      isRotate=4;     //вращение выделенного
      isZoom=5;       //масштабирование
      isBoneRot=6;    //вращение кости
      isBoneMove=7;   //движение кости
      isBoneScaling=8;//масштабирование кости
      isNormalRot=9;  //вращение нормалей

//Вспомогательная: добавляет массив lst2 к массиву lst1 так,
//что
//Возвращает тип объекта по его ID
//(typHELP,typBONE,typLITE,typEVTS,typATCH,typCLID,typPRE2)
function GetTypeObjByID(id:integer):integer;
//Возвращает копию скелетной части объекта с указанным ID:
function GetSkelObjectByID(ID:integer):TBone;
//Вспомогательная: установка значения скелетной части
//объекта из SelBone.b. ID объекта определяется из SelBone.b
procedure SetSkelPart;
//Установка скелетной части для объекта из B
procedure SetObjSkelPart(b:TBone);
//Вспомогательная: перемещает содержимое из
//одного TUndo в другой
procedure ReplaceTUndo(var src,dest:TUndo);
//Вспомогательная: копировать объект TGeoObj
//Точнее, скорее заполнить нулями, чем копировать
procedure fillGeoObj(var src,dst:TGeoObj);
//Вспомогательная: чертит куб размера BoneSize(const) с центром (x,y,z)
procedure DrawCube(x,y,z:GLFloat;color:TVertex);
//Вспомогательная: чертит точки прикрепления (треуг.)
procedure DrawTetrahedron(x,y,z:GLFloat;color:TVertex);
//Чертит нормали (вызывается при построении списков):
procedure DrawNormals;
//Вспомогательная: чертит подсветку осей (XYZ)
procedure DrawXYZ;
//Вспомогательная (вывод вершин):
procedure InternalDrawVertices;
//Вспомогательная: вывод объектов
procedure DrawObjects(UseDepth:boolean);
//чертит точки поверхности.
//(Точнее, строит список GLU и помещает его ID в
//CurrentListNum) hrc - рабочая область
//Используется переменная Geosets.
procedure DrawVertices(dc:hdc;hrc:HGLRC);
//Чертит поверхность (треугольники синего цвета) всех Geosets
//procedure DrawFictiveVetices(dc:hdc;hrc:HGLRC);
//Создает список, содержащий изображение текстурных вершин
//из слоя CoordID
//Записывает его ID в TexListNum
procedure MakeTVList(dc:hdc;hrc:HGLRC;CoordID:integer);
//Возвращает true, если матрицы сходные (т.е. близки др. к другу)
function IsMatrixEqual(m1,m2:TRotMatrix):boolean;
//Перемножает два кватерниона
procedure MulQuaternions(q1,q2:TQuaternion;var qdest:TQuaternion);
//вычисляет обратный кватернион (qdest=qsrc^-1).
procedure GetInverseQuaternion(var qsrc,qdest:TQuaternion);
//вычисляет логарифм кватерниона
procedure CalcLogQ(var q:TQuaternion);
//вычисляет экспоненту кватерниона
procedure CalcExpQ(var q:TQuaternion);
//Преобразует матрицу поворота в нормированный кватернион.
procedure MatrixToQuaternion(m:TRotMatrix;var q:TQuaternion);
//Преобразует кватернион в 3D-матрицу поворота
procedure QuaternionToMatrix(q:TQuaternion;var m:TRotMatrix);
//Перемножает две текстурные матрицы 4x4
procedure MulTexMatrices(var C,D:TTexMatrix);
//Интерполяция сплайнами Кочанека-Бартельса.
procedure Spline(Frame:integer;var its,itd:TContItem);
//Интерполяция сплайнами Безье
procedure BezInterp(Frame:integer;var its,itd:TContItem);
//сферическая линейная интерполяция
procedure Slerp(Frame:integer;var its,itd:TContItem);
//Ищет кадр с заданным значением Frame;
//Возвращает его номер в контроллере ContNum
//или же len+1;len - длина контроллера
function GetFramePos(var Cont:TController;Frame,Len:integer):integer;
//Поиск КК в контроллере "вперёд". Процедура ищет КК от
//Frame и дальше. Дойдя до конца анимации, она ищет их
//сначала анимки. Если полный круг завершился,
//а ничего всё ещё не найдено, функция возвр. Frame=-10000.
//len - длина контроллера
//Frame - номер кадра, от которого начинается поиск.
//OMinF,OMaxF - кадры, ограничивающие анимку
//cont - контроллер для поиска.
function LookForward(var cont:TController;
                     Frame,OMinF,OMaxF,len:integer):TContItem;
//Поиск КК в контроллере "назад". Процедура ищет КК от
//Frame и ниже. Дойдя до начала анимации, она ищет их
//с конца анимки. Если полный круг завершился,
//а ничего всё ещё не найдено, функция возвр. Frame=-10000.
//len - длина контроллера
//Frame - номер кадра, от которого начинается поиск.
//OMinF,OMaxF - кадры, ограничивающие анимку
//cont - контроллер для поиска.
function LookBack(var cont:TController;
                     Frame,OMinF,OMaxF,len:integer):TContItem;
//Извлекает из контроллера ContNum данные,
//соответствующие кадру FrameNum.
//При необходимости осуществляется интерполяция
function GetFrameData(ContNum,FrameNum:integer;CngType:integer):TContItem;
//проводит интерполяцию параметров указанного объекта
procedure InterpTBone(FrameNum:integer;var b:TBone);
//Рассчитывает абсолютные значения для кости/помощника
procedure CalcTBone(FrameNum:integer;var b:TBone);
//Рассчитывает координаты объектов для указанного кадра
procedure CalcAnimCoords(FrameNum:integer);
//Рассчитать центр координат объектов из SelObj.SelObjs
//и занести его в ccX, ccY, ccZ
procedure FindObjCoordCenter;
//Рассчитать центр к-т и занести его в ccX,ccY,ccZ
procedure FindCoordCenter;
//рассчитать центр к-т вершин и занести в ccVX,ccVY,ccVZ
procedure FindVertCoordCenter;

//Фильтр: возвращает ID контроллера.
//hi - длина массива контроллеров;
//StartID - начальный номер контроллера.
//Если он равен (-1), то функция вернёт здесь ID
//Первого подходящего контроллера.
//Если нет следующего контроллера, возвр. false
//Учитываются UsingGlobalSeq и IsContrFilter
function GetNextController(var StartID:integer;hi:integer):boolean;
implementation
//=========================================================
//Возвращает тип объекта по его ID
//(typHELP,typBONE,typLITE,typEVTS,typATCH,typCLID,typPRE2)
function GetTypeObjByID(id:integer):integer;
Begin
 PushFunction(235);
 //1. Проверим на кость
 if (CountOfBones>0) and (id>=Bones[0].ObjectID) and
    (id<=Bones[CountOfBones-1].ObjectID) then begin
  Result:=typBONE;
  PopFunction;
  exit;
 end;//of if

 //2. Проверим на помощник:
 if (CountOfHelpers>0) and (id>=Helpers[0].ObjectID) and
    (id<=Helpers[CountOfHelpers-1].ObjectID) then begin
  Result:=typHELP;
  PopFunction;
  exit;
 end;//of if

 //3. Проверим на точки прикрепления
 if (CountOfAttachments>0) and (id>=Attachments[0].Skel.ObjectID) and
    (id<=Attachments[CountOfAttachments-1].Skel.ObjectID) then begin
  Result:=typATCH;
  PopFunction;
  exit;
 end;//of if

 //4. Проверим на источник частиц-2
 if (CountOfParticleEmitters>0) and (id>=pre2[0].Skel.ObjectID) and
    (id<=pre2[CountOfParticleEmitters-1].Skel.ObjectID) then begin
  Result:=typPRE2;
  PopFunction;
  exit;
 end;//of if

 Result:=-1;
 PopFunction;
End;
//-----------------------------------------------------
//Вспомогательная: копировать объект TUndo
//Копирование НЕПОЛНОЕ!
procedure cpyUndo(var src,dst:TUndo);
Var i,ii,len,len2:integer;
Begin
 PushFunction(236);
 len:=length(src.data1);
 SetLength(dst.data1,len);
 for i:=0 to len-1 do dst.data1[i]:=src.data1[i];

 len:=length(src.data2);
 SetLength(dst.data2,len);
 for i:=0 to len-1 do dst.data2[i]:=src.data2[i];

 len:=length(src.data3);
 SetLength(dst.data3,len);
 for i:=0 to len-1 do dst.data3[i]:=src.data3[i];

 len:=length(src.idata);
 SetLength(dst.idata,len);
 for i:=0 to len-1 do dst.idata[i]:=src.idata[i];

 dst.Status1:=src.Status1;
 dst.Status2:=src.Status2;
 dst.GeosetAnim:=src.GeosetAnim;

 len:=length(src.Anims);
 SetLength(dst.Anims,len);
 for i:=0 to len-1 do dst.Anims[i]:=src.Anims[i];

 dst.Ext:=src.Ext;
 dst.Unselectable:=src.Unselectable;
 dst.MatID:=src.MatID;
 dst.SelGroup:=src.SelGroup;
 dst.HierID:=src.HierID;

 len:=length(src.Vertices);
 SetLength(dst.Vertices,len);
 for i:=0 to len-1 do dst.Vertices[i]:=src.Vertices[i];

 len:=length(src.Normals);
 SetLength(dst.Normals,len);
 for i:=0 to len-1 do dst.Normals[i]:=src.Normals[i];

 len:=length(src.Crds);
 SetLength(dst.Crds,len);
 for ii:=0 to len-1 do begin
  len2:=length(src.Crds[ii].TVertices);
  SetLength(dst.Crds[ii].TVertices,len2);
  for i:=0 to len2-1 do dst.Crds[ii].TVertices[i]:=src.Crds[ii].TVertices[i];
  dst.Crds[ii].CountOfTVertices:=src.Crds[ii].CountOfTVertices;
 end;//of for ii

 len:=length(src.VertexGroup);
 SetLength(dst.VertexGroup,len);
 for i:=0 to len-1 do dst.VertexGroup[i]:=src.VertexGroup[i];

 len:=length(src.Faces);
 SetLength(dst.Faces,len);
 for i:=0 to len-1 do begin
  len2:=length(src.Faces[i]);
  SetLength(dst.Faces[i],len2);
  for ii:=0 to len2-1 do dst.Faces[i,ii]:=src.Faces[i,ii];
 end;//of for i

 len:=length(src.Groups);
 SetLength(dst.Groups,len);
 for i:=0 to len-1 do begin
  len2:=length(src.Groups[i]);
  SetLength(dst.Groups[i],len2);
  for ii:=0 to len2-1 do dst.Groups[i,ii]:=src.Groups[i,ii];
 end;//of for i

 len:=length(src.VertexList);
 SetLength(dst.VertexList,len);
 for i:=0 to len-1 do dst.VertexList[i]:=src.VertexList[i];

//контроллеры пока не копируем, как и последовательности
// dst.Controllers[0]
 PopFunction;
End;

//Вспомогательная: перемещает содержимое из
//одного TUndo в другой
procedure ReplaceTUndo(var src,dest:TUndo);
Begin
 PushFunction(237);
 dest:=src;
 FillChar(src,SizeOf(src),0);
 PopFunction;
End;

//Вспомогательная: копировать объект TGeoObj
//Точнее, скорее заполнить нулями, чем копировать
procedure fillGeoObj(var src,dst:TGeoObj);
Var i:integer;
Begin
 PushFunction(238);
 FillChar(dst,SizeOf(dst),0);
 for i:=1 to 10 do cpyUndo(src.Undo[i],dst.Undo[i]);
 FillChar(src,SizeOf(src),0);
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательная: чертит куб размера BoneSize(const) с центром (x,y,z)
procedure DrawCube(x,y,z:GLFloat;color:TVertex);
Var sz:GLFloat;
Begin
 PushFunction(239);
 sz:=Bonesize/CurView.Zoom;
 glColor3f(color[1]+0.1,color[2]+0.1,color[3]+0.1);
 glVertex3f(x-sz,-(y+sz),z+sz);   //1
 glVertex3f(x-sz,-(y-sz),z+sz);
 glVertex3f(x-sz,-(y-sz),z-sz);
 glVertex3f(x-sz,-(y+sz),z-sz);

 glColor3f(color[1]+0.2,color[2]+0.2,color[3]+0.2);
 glVertex3f(x+sz,-(y+sz),z+sz);   //2
 glVertex3f(x+sz,-(y-sz),z+sz);
 glVertex3f(x+sz,-(y-sz),z-sz);
 glVertex3f(x+sz,-(y+sz),z-sz);

 glColor3f(color[1]+0.15,color[2]+0.15,color[3]+0.15);
 glVertex3f(x-sz,-(y+sz),z+sz);   //3
 glVertex3f(x+sz,-(y+sz),z+sz);
 glVertex3f(x+sz,-(y+sz),z-sz);
 glVertex3f(x-sz,-(y+sz),z-sz);

 glColor3f(color[1]+0.05,color[2]+0.05,color[3]+0.05);
 glVertex3f(x-sz,-(y-sz),z+sz);   //4
 glVertex3f(x+sz,-(y-sz),z+sz);
 glVertex3f(x+sz,-(y-sz),z-sz);
 glVertex3f(x-sz,-(y-sz),z-sz);

 glColor3f(color[1]+0.12,color[2]+0.12,color[3]+0.12);
 glVertex3f(x-sz,-(y+sz),z+sz);   //5
 glVertex3f(x+sz,-(y+sz),z+sz);
 glVertex3f(x+sz,-(y-sz),z+sz);
 glVertex3f(x-sz,-(y-sz),z+sz);

 glColor3f(color[1]+0.18,color[2]+0.18,color[3]+0.18);
 glVertex3f(x-sz,-(y+sz),z+sz);   //6
 glVertex3f(x+sz,-(y+sz),z+sz);
 glVertex3f(x+sz,-(y-sz),z+sz);
 glVertex3f(x-sz,-(y-sz),z+sz);
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательная: чертит точки прикрепления (треуг.)
procedure DrawTetrahedron(x,y,z:GLFloat;color:TVertex);
Var _AtchSize:single;
Begin
 PushFunction(240);
 _AtchSize:=AtchSize/CurView.Zoom;
 glColor3f(color[1]+0.2,color[2]+0.2,color[3]+0.2);
 glVertex3f(x+1.732*_AtchSize,-(y+1.732*_AtchSize),z+1.732*_AtchSize);
 glVertex3f(x+1.732*_AtchSize,-(y-1.732*_AtchSize),z-1.732*_AtchSize);
 glVertex3f(x-1.732*_AtchSize,-(y-1.732*_AtchSize),z+1.732*_AtchSize);

 glColor3f(color[1]+0.1,color[2]+0.1,color[3]+0.1);
 glVertex3f(x-1.732*_AtchSize,-(y+1.732*_AtchSize),z-1.732*_AtchSize);
 glVertex3f(x+1.732*_AtchSize,-(y-1.732*_AtchSize),z-1.732*_AtchSize);
 glVertex3f(x+1.732*_AtchSize,-(y+1.732*_AtchSize),z+1.732*_AtchSize);

 glColor3f(color[1]+0.15,color[2]+0.15,color[3]+0.15);
 glVertex3f(x-1.732*_AtchSize,-(y-1.732*_AtchSize),z+1.732*_AtchSize);
 glVertex3f(x-1.732*_AtchSize,-(y+1.732*_AtchSize),z-1.732*_AtchSize);
 glVertex3f(x+1.732*_AtchSize,-(y+1.732*_AtchSize),z+1.732*_AtchSize);

 glColor3f(color[1]+0.05,color[2]+0.05,color[3]+0.05);
 glVertex3f(x+1.732*_AtchSize,-(y-1.732*_AtchSize),z-1.732*_AtchSize);
 glVertex3f(x-1.732*_AtchSize,-(y+1.732*_AtchSize),z-1.732*_AtchSize);
 glVertex3f(x-1.732*_AtchSize,-(y-1.732*_AtchSize),z+1.732*_AtchSize);
 PopFunction;
End;
//---------------------------------------------------------
//Рассчитать центр к-т и занести его в ccX,ccY,ccZ
procedure FindCoordCenter;
Var i,j,SumVertexCount:integer;MidX,MidY,MidZ:GLfloat;
Begin
 PushFunction(241);
 if AnimEdMode<>1 then begin       //центр=Pivot кости
  if (not SelObj.IsSelected) or (SelObj.b.ObjectID<0) then begin
   PopFunction;
   exit;
  end;
  if SelObj.IsMultiSelect then begin
   FindObjCoordCenter;
   PopFunction;
   exit;
  end;//of if
  if AnimEdMode=2 then begin
   ccX:=SelObj.b.AbsVector[1];
   ccY:=SelObj.b.AbsVector[2];
   ccZ:=SelObj.b.AbsVector[3];
  end else begin
   ccX:=PivotPoints[SelObj.b.ObjectID,1];
   ccY:=PivotPoints[SelObj.b.ObjectID,2];
   ccZ:=PivotPoints[SelObj.b.ObjectID,3];
  end;
  PopFunction;
  exit;
 end;//of if
 MidX:=0;MidY:=0;MidZ:=0;
 SumVertexCount:=0;
 for j:=0 to CountOfGeosets-1 do with geosets[j],geoobjs[j] do
     if IsSelected then begin
  SumVertexCount:=SumVertexCount+VertexCount;
  for i:=0 to VertexCount-1 do begin
   MidX:=MidX+Vertices[VertexList[i]-1,1];//!dbg
   MidY:=MidY+Vertices[VertexList[i]-1,2];//!dbg
   MidZ:=MidZ+Vertices[VertexList[i]-1,3];//!dbg
  end;//of for
 end;//of with(2)/for j
 if SumVertexCount=0 then begin
  ccX:=0;ccY:=0;ccZ:=0;
  PopFunction;
  exit;
 end;//of if
 MidX:=MidX/SumVertexCount;
 MidY:=MidY/SumVertexCount;
 MidZ:=MidZ/SumVertexCount;
 ccX:=MidX;ccY:=MidY;ccZ:=MidZ;
 PopFunction;
End;
//----------------------------------------------------------
//рассчитать центр к-т вершин и занести в ccVX,ccVY,ccVZ
procedure FindVertCoordCenter;
Var i,j,SumVertexCount:integer;
Begin
 PushFunction(242);
 SumVertexCount:=0;
 ccVX:=0; ccVY:=0; ccVZ:=0;
 for j:=0 to CountOfGeosets-1 do with geosets[j],geoobjs[j] do
     if IsSelected then begin
  SumVertexCount:=SumVertexCount+VertexCount;
  for i:=0 to VertexCount-1 do begin
   ccVX:=ccVX+Vertices[VertexList[i]-1,1];
   ccVY:=ccVY+Vertices[VertexList[i]-1,2];
   ccVZ:=ccVZ+Vertices[VertexList[i]-1,3];
  end;//of for
 end;//of with(2)/for j
 if SumVertexCount=0 then begin
  ccVX:=0;ccVY:=0;ccVZ:=0;
  PopFunction;
  exit;
 end;//of if
 ccVX:=ccVX/SumVertexCount;
 ccVY:=ccVY/SumVertexCount;
 ccVZ:=ccVZ/SumVertexCount;
 PopFunction;
End;
//----------------------------------------------------------
//Рассчитать центр координат объектов из SelObj.SelObjs
//и занести его в ccX, ccY, ccZ
procedure FindObjCoordCenter;
Var i:integer;b:TBone;
Begin
 if (not (SelObj.IsSelected and SelObj.IsMultiSelect)) or
    (SelObj.CountOfSelObjs=0) then exit;
 PushFunction(243);
 ccX:=0; ccY:=0; ccZ:=0;
 for i:=0 to SelObj.CountOfSelObjs-1 do begin
  if AnimEdMode=2 then begin
   b:=GetSkelObjectByID(SelObj.SelObjs[i]);
   ccX:=ccX+b.AbsVector[1];
   ccY:=ccY+b.AbsVector[2];
   ccZ:=ccZ+b.AbsVector[3];
  end else begin
   ccX:=ccX+PivotPoints[SelObj.SelObjs[i],1];
   ccY:=ccY+PivotPoints[SelObj.SelObjs[i],2];
   ccZ:=ccZ+PivotPoints[SelObj.SelObjs[i],3];
  end;//of if
 end;//of for i
 ccX:=ccX/SelObj.CountOfSelObjs;
 ccY:=ccY/SelObj.CountOfSelObjs;
 ccZ:=ccZ/SelObj.CountOfSelObjs;
 PopFunction;
End;
//----------------------------------------------------------

//Вспомогательная:
//Определяет, скрыта ли данная вершина:
function IsVertexHide(geoID,num:integer):boolean;
Var i:integer;
Begin with GeoObjs[geoID] do begin
 IsVertexHide:=false;             //пока считаем, что не скрыта
 if HideVertexCount=0 then exit;  //нет скрытых вершин
 PushFunction(244);
 for i:=0 to HideVertexCount-1 do if HideVertices[i]=num then begin
  IsVertexHide:=true;
  PopFunction;
  exit;
 end;//of for/if
 PopFunction;
end;End;

//Чертит нормали (вызывается при построении списков):
procedure DrawNormals;
Var j,i:integer;
Begin
 PushFunction(245);
 for j:=0 to CountOfGeosets-1 do with Geoobjs[j] do if IsSelected then begin
  glColor3f(0,0,1);
  glLineWidth(1);  
  glBegin(GL_LINES);
   for i:=0 to Geosets[j].CountOfVertices-1 do with Geosets[j] do begin
    if IsVertexHide(j,i+1) then continue;
    glVertex3fv(@Vertices[i]);
    glVertex3f(Vertices[i,1]+2*Normals[i,1],
               Vertices[i,2]+2*Normals[i,2],
               Vertices[i,3]+2*Normals[i,3]);
   end;//of for i
  glEnd;
 end;//of if/with/for j
 PopFunction;
End;

//---------------------------------------------------------
//Возвращает копию скелетной части объекта с указанным ID:
function GetSkelObjectByID(ID:integer):TBone;
Begin
 PushFunction(246);
 case GetTypeObjByID(id) of
  typHELP:Result:=Helpers[ID-Helpers[0].ObjectID];
  typBONE:Result:=Bones[ID-Bones[0].ObjectID];
  typLITE:Result:=Lights[ID-Lights[0].Skel.ObjectID].Skel;
  typEVTS:Result:=Events[ID-Events[0].Skel.ObjectID].Skel;
  typATCH:Result:=Attachments[ID-Attachments[0].Skel.ObjectID].Skel;
  typPRE2:Result:=pre2[id-pre2[0].Skel.ObjectID].Skel;
 end;//of case
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательная: вывод связки родитель->потомок
procedure iDrawSkelLine(ParentID,ChildID:integer);
Var bp,bch:TBone;t1,t2:integer;
Begin
 //Проверим корректность ID:
 if (ParentID<0) or (ChildID<0) then exit;
 PushFunction(247);

 //Проверим, видимы ли родитель и потомок
 t1:=GetTypeObjById(ParentID);
 t2:=GetTypeObjById(ChildID);
 if ((t1=typHELP) or (t1=typBONE) or (t2=typHELP) or (t2=typBONE)) and
    (not VisObjs.VisBones) then begin PopFunction;exit;end;
 if ((t1=typATCH) or (t2=typATCH)) and (not VisObjs.VisAttachments) then begin
  PopFunction;
  exit;
 end;
 if ((t1=typPRE2) or (t2=typPRE2)) and (not VisObjs.VisParticles) then begin
  PopFunction;
  exit;
 end;

 //Приступаем к выводу: читаем сами объекты
 bp:=GetSkelObjectByID(ParentID);
 bch:=GetSkelObjectByID(ChildID);

 //Чертим линию
 glColor3f(0,0,0);
 glVertex3f(bp.AbsVector[1],-bp.AbsVector[2],bp.AbsVector[3]);
 glColor3f(1,1,1);
 glVertex3f(bch.AbsVector[1],-bch.AbsVector[2],bch.AbsVector[3]);
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательная: вывод объектов
procedure DrawObjects(UseDepth:boolean);
Var i:integer;HasParent:boolean;tb:TBone;//tst:ByteBool;
    zm:GLFloat;clr:TVertex;
Begin
 PushFunction(248);
 //Рисуем кости/помощники (если видимы)
 if VisObjs.VisBones then begin
//  glColor3f(0.1,0.8,0.15);
  clr[1]:=0.1;
  clr[2]:=0.8;
  clr[3]:=0.15;
  HasParent:=true;
  //Кости
  glBegin(GL_QUADS);
  for i:=0 to CountOfBones-1 do begin
   //Кость-заглушку пропустим
   if NullBone.IsExists and (NullBone.IdInBones=i) then continue;
   //Объекты без родителя выделим более тёмным цветов
   if (Bones[i].Parent<0) and HasParent then begin
    clr[1]:=0.1;
    clr[2]:=0.5;
    clr[3]:=0.15;
//    glColor3f(0.1,0.5,0.15);
    HasParent:=false
   end else if (Bones[i].Parent>=0) and (not HasParent) then begin
    clr[1]:=0.1;
    clr[2]:=0.8;
    clr[3]:=0.15;
//    glColor3f(0.1,0.8,0.15);
    HasParent:=true;
   end;//of if
   DrawCube(Bones[i].AbsVector[1],Bones[i].AbsVector[2],Bones[i].AbsVector[3],
            clr);
  end;//of for i

  //Помощники:
  for i:=0 to CountOfHelpers-1 do begin
   //Объекты без родителя выделим более тёмным цветов
   if (Helpers[i].Parent<0) and HasParent then begin
    clr[1]:=0.1;
    clr[2]:=0.5;
    clr[3]:=0.15;
//    glColor3f(0.1,0.5,0.15);
    HasParent:=false
   end else if (Helpers[i].Parent>=0) and (not HasParent) then begin
    clr[1]:=0.1;
    clr[2]:=0.8;
    clr[3]:=0.15;
//    glColor3f(0.1,0.8,0.15);
    HasParent:=true;
   end;//of if
   DrawCube(Helpers[i].AbsVector[1],Helpers[i].AbsVector[2],
            Helpers[i].AbsVector[3],clr);
  end;//of for i

  glEnd;
 end;//of if

 //Точки прикрепления
 if VisObjs.VisAttachments then begin
  HasParent:=true;
//  glColor3f(0.5,0.5,1);
  clr[1]:=0.5;
  clr[2]:=0.5;
  clr[3]:=1;
  glBegin(GL_TRIANGLES);
  for i:=0 to CountOfAttachments-1 do begin
    //Объекты без родитея выделим более тёмным цветов
    if (Attachments[i].Skel.Parent<0) and HasParent then begin
     clr[1]:=0.2;
     clr[2]:=0.2;
     clr[3]:=0.7;
//     glColor3f(0.2,0.2,0.7);
     HasParent:=false
    end else if (Attachments[i].Skel.Parent>=0) and (not HasParent) then begin
     clr[1]:=0.5;
     clr[2]:=0.5;
     clr[3]:=1;
//     glColor3f(0.5,0.5,1);
     HasParent:=true;
    end;//of if
    DrawTetrahedron(Attachments[i].Skel.AbsVector[1],Attachments[i].Skel.AbsVector[2],
             Attachments[i].Skel.AbsVector[3],clr);
  end;//of for i
  glEnd;
 end;//of if(Atch)

 //Источники частиц
 if VisObjs.VisParticles then begin
  HasParent:=true;
  glBegin(GL_TRIANGLES);
  for i:=0 to CountOfParticleEmitters-1 do begin
    //Объекты без родитея выделим более тёмным цветов
    if (pre2[i].Skel.Parent<0) {and HasParent} then begin
     clr[1]:=0.1;
     clr[2]:=0.5;
     clr[3]:=0.15;
//     glColor3f(0.1,0.5,0.15);
     HasParent:=false
    end else {if (pre2[i].Skel.Parent>=0) and (not HasParent) then} begin
     clr[1]:=0.1;
     clr[2]:=0.8;
     clr[3]:=0.15;
//     glColor3f(0.1,0.8,0.15);
     HasParent:=true;
    end;//of if
    DrawTetrahedron(pre2[i].Skel.AbsVector[1],pre2[i].Skel.AbsVector[2],
             pre2[i].Skel.AbsVector[3],clr);
  end;//of for i
  glEnd;
 end;//of if(PRE2)

 //Рисуем выделенный объект, родительский объект и
 //(если есть) объект связывания
 if SelObj.IsSelected then with SelObj do begin
  if not SelObj.IsMultiSelect then begin
   //в случае активного поворота - рис. малые оси к-т
   if InstrumStatus=isBoneRot then with SelObj.b do begin
    zm:=1/CurView.Zoom;
    glLineWidth(2);
    glBegin(GL_LINES);
     glColor3f(1,0,0);
     glVertex3f(ccX,-ccY,ccZ);
     glVertex3f(ccX+AbsMatrix[0,0]*(20*zm),
              -(ccY+AbsMatrix[0,1]*(20*zm)),
                ccZ+AbsMatrix[0,2]*(20*zm));
     glColor3f(0,1,0);
     glVertex3f(ccX,-ccY,ccZ);
     glVertex3f(ccX+AbsMatrix[1,0]*(20*zm),
              -(ccY+AbsMatrix[1,1]*(20*zm)),
                ccZ+AbsMatrix[1,2]*(20*zm));
     glColor3f(0,0,1);
     glVertex3f(ccX,-ccY,ccZ);
     glVertex3f(ccX+AbsMatrix[2,0]*(20*zm),
              -(ccY+AbsMatrix[2,1]*(20*zm)),
                ccZ+AbsMatrix[2,2]*(20*zm));
    glEnd;
   end;//of with/if
   //рисуем сам объект
   case GetTypeObjByID(SelObj.b.ObjectID) of
    typHELP,typBONE:begin
//     glColor3f(1.0,0,0);
     clr[1]:=1;
     clr[2]:=0;
     clr[3]:=0;
     glBegin(GL_QUADS);
      DrawCube(b.AbsVector[1],b.AbsVector[2],b.AbsVector[3],clr);
     glEnd;
    end;//of (кость)
    typAtch:begin
     clr[1]:=1;
     clr[2]:=0;
     clr[3]:=0;
//     glColor3f(1.0,0,0);
     glBegin(GL_TRIANGLES);
      DrawTetrahedron(b.AbsVector[1],b.AbsVector[2],b.AbsVector[3],clr);
     glEnd;
    end;//of (точка прикрепления)
    typPRE2:begin
     clr[1]:=1;
     clr[2]:=0;
     clr[3]:=0;
//     glColor3f(1.0,0,0);
     glBegin(GL_TRIANGLES);
      DrawTetrahedron(b.AbsVector[1],b.AbsVector[2],b.AbsVector[3],clr);
     glEnd;
     //чертим рамочку вокруг Источника
     if AnimEdMode=0 then begin
      glLineWidth(1);
      glBegin(GL_LINE_LOOP);
       with pre2[b.ObjectID-pre2[0].Skel.ObjectID] do begin
        glVertex3f(b.AbsVector[1]-0.5*width,-(b.AbsVector[2]+0.5*length),
                   b.AbsVector[3]);
        glVertex3f(b.AbsVector[1]+0.5*width,-(b.AbsVector[2]+0.5*length),
                   b.AbsVector[3]);
        glVertex3f(b.AbsVector[1]+0.5*width,-(b.AbsVector[2]-0.5*length),
                   b.AbsVector[3]);
        glVertex3f(b.AbsVector[1]-0.5*width,-(b.AbsVector[2]-0.5*length),
                   b.AbsVector[3]);
       end;//of with
      glEnd;
     end else begin
      glLineWidth(1);
      glBegin(GL_LINE_LOOP);
       with pre2[b.ObjectID-pre2[0].Skel.ObjectID] do begin
        glVertex3f(ccX+b.AbsMatrix[0,0]*(-0.5*width)+b.AbsMatrix[1,0]*0.5*length,
                   -(ccY+b.AbsMatrix[0,1]*(-0.5*width)+0.5*length*b.AbsMatrix[1,1]),
                   ccZ+b.AbsMatrix[0,2]*(-0.5*width)+0.5*length*b.AbsMatrix[1,2]);

        glVertex3f(ccX+b.AbsMatrix[0,0]*(0.5*width)+b.AbsMatrix[1,0]*0.5*length,
                   -(ccY+b.AbsMatrix[0,1]*(0.5*width)+0.5*length*b.AbsMatrix[1,1]),
                   ccZ+b.AbsMatrix[0,2]*(0.5*width)+0.5*length*b.AbsMatrix[1,2]);

        glVertex3f(ccX+b.AbsMatrix[0,0]*(0.5*width)-b.AbsMatrix[1,0]*0.5*length,
                   -(ccY+b.AbsMatrix[0,1]*(0.5*width)-0.5*length*b.AbsMatrix[1,1]),
                   ccZ+b.AbsMatrix[0,2]*(0.5*width)-0.5*length*b.AbsMatrix[1,2]);

        glVertex3f(ccX+b.AbsMatrix[0,0]*(-0.5*width)-b.AbsMatrix[1,0]*0.5*length,
                   -(ccY+b.AbsMatrix[0,1]*(-0.5*width)-0.5*length*b.AbsMatrix[1,1]),
                   ccZ+b.AbsMatrix[0,2]*(-0.5*width)-0.5*length*b.AbsMatrix[1,2]);
       end;//of with
      glEnd;
     end;//of if
    end;//of typPRE2
   end;//of case
   //чертим родительский объект (если таковой есть)
   if b.Parent>=0 then case GetTypeObjByID(b.Parent) of
    typHELP,typBONE:if VisObjs.VisBones then begin
//     glColor3f(0.0,0,0);
     clr[1]:=0;
     clr[2]:=0;
     clr[3]:=0;
     tb:=GetSkelObjectByID(b.Parent);
     glBegin(GL_QUADS);
      DrawCube(tb.AbsVector[1],tb.AbsVector[2],tb.AbsVector[3],clr);
     glEnd;
    end;//of (кость)
    typAtch:if VisObjs.VisAttachments then begin
//     glColor3f(0.0,0,0);
     clr[1]:=0;
     clr[2]:=0;
     clr[3]:=0;
     tb:=GetSkelObjectByID(b.Parent);
     glBegin(GL_TRIANGLES);
      DrawTetrahedron(tb.AbsVector[1],tb.AbsVector[2],tb.AbsVector[3],clr);
     glEnd;
    end;//of (точка прикрепления)
    typPRE2:if VisObjs.VisParticles then begin
     clr[1]:=0;
     clr[2]:=0;
     clr[3]:=0;
//     glColor3f(0.0,0,0);
     tb:=GetSkelObjectByID(b.Parent);
     glBegin(GL_TRIANGLES);
      DrawTetrahedron(tb.AbsVector[1],tb.AbsVector[2],tb.AbsVector[3],clr);
     glEnd;
    end;//of typPRE2
   end;//of case
  end;//of if (not MultiSelect)

  //Рисуем дочерние объекты (если имеются):
  clr[1]:=1;
  clr[2]:=1;
  clr[3]:=0;
//  glColor3f(1,1,0);
  for i:=0 to CountOfChilds-1 do begin
   tb:=GetSkelObjectById(ChildObjects[i]);
   case GetTypeObjByID(tb.ObjectID) of
   typHELP,typBONE:if VisObjs.VisBones then begin
    glBegin(GL_QUADS);
     DrawCube(tb.AbsVector[1],tb.AbsVector[2],tb.AbsVector[3],clr);
    glEnd;
   end;//of (кость)
   typAtch:if VisObjs.VisAttachments then begin
    glBegin(GL_TRIANGLES);
     DrawTetrahedron(tb.AbsVector[1],tb.AbsVector[2],tb.AbsVector[3],clr);
    glEnd;
   end;//of (точка прикрепления)
   typPRE2:if VisObjs.VisParticles then begin
    glBegin(GL_TRIANGLES);
     DrawTetrahedron(tb.AbsVector[1],tb.AbsVector[2],tb.AbsVector[3],clr);
    glEnd;
   end;//of if(pre2)
   end;//of case
  end;//of for i

  //Рисуем остальные выделенные объекты
  //Если множественный выбор - рисовать ВСЕ выделенные объекты
  if SelObj.IsMultiSelect then for i:=0 to CountOfSelObjs-1 do begin
   SelObj.b:=GetSkelObjectByID(SelObjs[i]);
   case GetTypeObjByID(SelObj.b.ObjectID) of
    typHELP,typBONE:begin
     clr[1]:=1;
     clr[2]:=0;
     clr[3]:=0;
//     glColor3f(1.0,0,0);
     glBegin(GL_QUADS);
      DrawCube(b.AbsVector[1],b.AbsVector[2],b.AbsVector[3],clr);
     glEnd;
    end;//of (кость)
    typAtch,typPRE2:begin
//     glColor3f(1.0,0,0);
     clr[1]:=1;
     clr[2]:=0;
     clr[3]:=0;
     glBegin(GL_TRIANGLES);
      DrawTetrahedron(b.AbsVector[1],b.AbsVector[2],b.AbsVector[3],clr);
     glEnd;
    end;//of (точка прикрепления)
   end;//of case
  end;//of if
 end;//of if

 //Чертим связи между объектами (если они видны):
 if VisObjs.VisSkel then begin
  if UseDepth then glLineWidth(3) else begin
   glLineWidth(1);
   glEnable(GL_LINE_STIPPLE);
  end;//of if
  glBegin(GL_LINES);
  //Если кости видны, строим для них связки
  if VisObjs.VisBones then begin
   for i:=0 to CountOfBones-1
   do iDrawSkelLine(Bones[i].Parent,Bones[i].ObjectID);
   for i:=0 to CountOfHelpers-1
   do iDrawSkelLine(Helpers[i].Parent,Helpers[i].ObjectID);
  end;//of if

  if VisObjs.VisAttachments then begin
   for i:=0 to CountOfAttachments-1
   do iDrawSkelLine(Attachments[i].Skel.Parent,Attachments[i].Skel.ObjectID);
  end;//of if

  if VisObjs.VisParticles then begin
   for i:=0 to CountOfParticleEmitters-1
   do iDrawSkelLine(pre2[i].Skel.Parent,pre2[i].Skel.ObjectID);
  end;//of if

  glEnd;
  glLineWidth(1);
  glDisable(GL_LINE_STIPPLE);
 end;//of if (скелет)

 //Чертим объект связывания (если таковой есть)
 if ChObj.IsSelected then with ChObj do begin
  case GetTypeObjByID(ChObj.b.ObjectID) of
   typHELP,typBONE:begin
    clr[1]:=0.5;
    clr[2]:=0;
    clr[3]:=0;
//    glColor3f(0.5,0,0);
    glBegin(GL_QUADS);
     DrawCube(b.AbsVector[1],b.AbsVector[2],b.AbsVector[3],clr);
    glEnd;
   end;//of (кость)
   typAtch,typPRE2:begin
    clr[1]:=0.5;
    clr[2]:=0;
    clr[3]:=0;
//    glColor3f(0.5,0,0);
    glBegin(GL_TRIANGLES);
     DrawTetrahedron(b.AbsVector[1],b.AbsVector[2],b.AbsVector[3],clr);
    glEnd;
   end;//of (точка прикрепления)
  end;//of case

  //Если есть ещё и выделенный объект, чертим линию связи
  if SelObj.IsSelected then begin
   glLineWidth(2);
   glColor3f(1.0,0,0);
   glBegin(GL_LINES);
    glVertex3f(b.AbsVector[1],-b.AbsVector[2],b.AbsVector[3]);
    glVertex3f(SelObj.b.AbsVector[1],-SelObj.b.AbsVector[2],
               SelObj.b.AbsVector[3]);
   glEnd;
  end;//of if
 end;//of if
 PopFunction;
End;
//---------------------------------------------------------
procedure InternalDrawVertices;
Var i,j:integer;
Begin
 PushFunction(249);
 glColor3f(0,0,1.0);         //цвет точек
//  if AnimEdMode<>2 then
  for j:=0 to CountOfGeosets-1 do begin
   //Чертим вершины только выделенных поверхностей
   if geoobjs[j].IsSelected and (AnimEdMode<>2) then begin
    glColor3f(0,0,1.0);        //цвет точек
    glVertexPointer(3,GL_FLOAT,0,@Geosets[j].Vertices[0]);
    if GeoObjs[j].HideVertexCount=0
    then glDrawArrays(GL_POINTS,0,Geosets[j].CountOfVertices)
    else begin
     glBegin(GL_POINTS);
      for i:=0 to Geosets[j].CountOfVertices-1 do
      if not IsVertexHide(j,i+1) then glArrayElement(i);
     glEnd;
    end;//of else
   end;//of if (IsSelectd)

   //Дочерние вершины (дочерних объектов)
   glBegin(GL_POINTS);
   if GeoObjs[j].IsSelected {or IsShowAll} then begin
    //чертим дочерние вершины
    if AnimEdMode<>1 then begin
     glColor3f(0.5,0.5,0.5);
     for i:=0 to Geosets[j].CountOfChildVertices-1 do
     with Geosets[j] do glVertex3fv(@Vertices[ChildVertices[i]]);
     //чертим вершины, связанные непоср. с данной костью
     glColor3f(0,0,0);
     for i:=0 to Geosets[j].CountOfDirectCV-1 do
     with Geosets[j] do glVertex3fv(@Vertices[DirectCV[i]]);
    end;//of if(AnimEdMode)
   end;//of if
   glEnd;
  end;//of for j

  glColor3f(1.0,0,0); //Красный цвет
  for j:=0 to CountOfGeosets-1 do begin
   if not geoobjs[j].IsSelected then continue;
   glVertexPointer(3,GL_FLOAT,0,@Geosets[j].Vertices[0]);
   //Чертить выделенные вершины
   glBegin(GL_POINTS);
    for i:=0 to GeoObjs[j].VertexCount-1
    do glArrayElement(GeoObjs[j].VertexList[i]-1);
   glEnd;
  end;//of for j
  PopFunction;
// end;//of if(not IsBone)
End;

//Вспомогательная: чертит подсветку осей (XYZ)
procedure DrawXYZ;
Var zm:GLFloat; v1,v2,v3,v4,v5,c:TVertex;
const sz=2.5;
      lsz=14;
procedure DrawPyramid(v1,v2,v3,v4,v,c:TVertex);
Begin
 PushFunction(250);
 //рисуем основание пирамиды [квадрат]
{ glColor3fv(@c);
 glBegin(GL_TRIANGLE_STRIP);
  glVertex3fv(@v1);
  glVertex3fv(@v2);
  glVertex3fv(@v3);
  glVertex3fv(@v4);
 glEnd;}

 //рисуем 4 треугольника пирамиды
 c[1]:=c[1]*0.8; c[2]:=c[2]*0.5; c[3]:=c[3]*0.8;
 glColor3fv(@c);
 glBegin(GL_TRIANGLE_FAN);
  glVertex3fv(@v);
  glVertex3fv(@v1);
  glVertex3fv(@v2);
  glVertex3fv(@v4);
  glVertex3fv(@v3);
  glVertex3fv(@v1);
 glEnd;
 PopFunction;
End;
Begin
 if not IsXYZ then exit;
 if (InstrumStatus=isRotate) or (InstrumStatus=isBoneRot) then exit;
 PushFunction(251);
 zm:=1/CurView.Zoom;
 glBegin(GL_LINES);
  glColor3f(1,0,0);
  glVertex3f(ccX,-ccY,ccZ);
  glVertex3f(ccX+50*zm,-ccY,ccZ);
  glColor3f(0,1,0);
  glVertex3f(ccX,-ccY,ccZ);
  glVertex3f(ccX,-(ccY+50*zm),ccZ);
  glColor3f(0,0,1);
  glVertex3f(ccX,-ccY,ccZ);
  glVertex3f(ccX,-ccY,ccZ+50*zm);
 glEnd;

 //Теперь треугольники:
// glPushAttrib(GL_POLYGON_BIT); //Что-то проделывает с текс. матрицей!
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
 //X
 v1[1]:=ccX+50*zm; v1[2]:=-(ccY-sz*zm); v1[3]:=ccZ+sz*zm;
 v2[1]:=ccX+50*zm; v2[2]:=-(ccY+sz*zm); v2[3]:=ccZ+sz*zm;
 v3[1]:=ccX+50*zm; v3[2]:=-(ccY-sz*zm); v3[3]:=ccZ-sz*zm;
 v4[1]:=ccX+50*zm; v4[2]:=-(ccY+sz*zm); v4[3]:=ccZ-sz*zm;
 v5[1]:=ccX+(50+lsz)*zm; v5[2]:=-ccY; v5[3]:=ccZ;
 c[1]:=1; c[2]:=0; c[3]:=0;
 DrawPyramid(v1,v2,v3,v4,v5,c);

 //Y
 v1[2]:=-(ccY+50*zm); v1[1]:=ccX-sz*zm; v1[3]:=ccZ+sz*zm;
 v2[2]:=-(ccY+50*zm); v2[1]:=ccX+sz*zm; v2[3]:=ccZ+sz*zm;
 v3[2]:=-(ccY+50*zm); v3[1]:=ccX-sz*zm; v3[3]:=ccZ-sz*zm;
 v4[2]:=-(ccY+50*zm); v4[1]:=ccX+sz*zm; v4[3]:=ccZ-sz*zm;
 v5[1]:=ccX; v5[2]:=-(ccY+(50+lsz)*zm); v5[3]:=ccZ;
 c[1]:=0; c[2]:=1; c[3]:=0;
 DrawPyramid(v1,v2,v3,v4,v5,c);

 //Z
 v1[3]:=ccZ+50*zm; v1[1]:=ccX-sz*zm; v1[2]:=-(ccY+sz*zm);
 v2[3]:=ccZ+50*zm; v2[1]:=ccX+sz*zm; v2[2]:=-(ccY+sz*zm);
 v3[3]:=ccZ+50*zm; v3[1]:=ccX-sz*zm; v3[2]:=-(ccY-sz*zm);
 v4[3]:=ccZ+50*zm; v4[1]:=ccX+sz*zm; v4[2]:=-(ccY-sz*zm);
 v5[1]:=ccX; v5[2]:=-ccY; v5[3]:=ccZ+(50+lsz)*zm;
 c[1]:=0; c[2]:=0; c[3]:=1;
 DrawPyramid(v1,v2,v3,v4,v5,c);
// glPopAttrib;
 PopFunction;
End;

//чертит точки активных поверхностей. hrc - рабочая область
//Используется переменная Geosets.
procedure DrawVertices(dc:hdc;hrc:HGLRC);
Var i,ii,j,gn,num:integer;IsEdgeFlag:boolean;
Begin
 PushFunction(252);
 ViewType:=0;                //сброс видов(поверхность, общий вид)
 //Сброс ряда установок
 glDisable(GL_DEPTH_TEST);
 glDisable(GL_LIGHTING);
 if AnimEdMode<>1 then glEnable(GL_DEPTH_TEST);
 glDepthFunc(GL_LEQUAL);
 if CurrentListNum<>-1 then glDeleteLists(CurrentListNum,1);
 CurrentListNum:=glGenLists(1);
 glNewList(CurrentListNum,gl_compile);
 glClearColor(0.8,0.8,0.8,1.0);//цвет фона
 if AnimEdMode<>1 then glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
                  else glClear(GL_COLOR_BUFFER_BIT); //очистка буфера
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
 glColor3f(0,0,0);//glLineWidth(1);
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

 //1. Чертить развороты/треугольники
 glEnable(GL_POLYGON_SMOOTH);//сглаживание треугольников
 glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);//контурно
 glLineWidth(1);             //толщина линии
 glScalef(1.0,-1.0,1.0);    //для корректного вывода точек
 glEnableClientState(GL_VERTEX_ARRAY);//учёт только вершин 

if IsShowAll then begin
 glEdgeFlag(true);
 glColor3f(0.9,1,0.9);         //цвет
 for gn:=1 to CountOfGeosets do begin
  if Geosets[gn-1].Color4f[4]<0.5 then continue;
  glVertexPointer(3,GL_FLOAT,0,@Geosets[gn-1].Vertices[0]);
  glBegin(GL_TRIANGLES);
   for i:=0 to Geosets[Gn-1].CountOfFaces-1 do
   for ii:=0 to length(Geosets[Gn-1].Faces[i])-1 do
    glArrayElement(Geosets[Gn-1].Faces[i,ii]);
  glEnd;
 end;//of for gn 
end;//of if (ShowAll)


 glColor3f(1,1,1);           //цвет
 IsEdgeFlag:=true;glEdgeFlag(true);
  for j:=0 to CountOfGeosets-1 do begin
   if not Geoobjs[j].IsSelected then continue;
   glVertexPointer(3,GL_FLOAT,0,@Geosets[j].Vertices[0]);
   glBegin(GL_TRIANGLES);
    for i:=0 to Geosets[j].CountOfFaces-1 do
    for ii:=0 to length(Geosets[j].Faces[i])-1 do begin
     num:=Geosets[j].Faces[i,ii]; //номер вершины
     if IsVertexHide(j,num+1) and IsEdgeFlag then begin
      glEdgeFlag(false);IsEdgeFlag:=false;
     end;
     if (not IsVertexHide(j,num+1)) and (not IsEdgeFlag) then begin
      glEdgeFlag(true);IsEdgeFlag:=true;
     end;
     glArrayElement(num);
    end;//of for
   glEnd;
  end;//of for j
 glDisable(GL_POLYGON_SMOOTH);//отключить режим
 glPointSize(5);             //размер точек

 //Чертить нормали
 if IsNormals then DrawNormals;
 //2. Чертить вершины (обычные+дочерние)
 InternalDrawVertices;
 glScalef(1.0,-1.0,1.0);
 //вывод подсветки осей к-т
 DrawXYZ;
 
 //Теперь - вывод объектов (если нужно)
 if AnimEdMode<>1 then begin
  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
  DrawObjects(true);
 end;//of if

 if not IsNoEndList then begin
  glEndList;
 end;//of if
 PopFunction;
End;
//==========================================================
//Вспомогательная: ищет в списке TexVertexList нужную вершину
function FindInTexList(geoID,num:integer):boolean;
Var i:integer;
Begin with GeoObjs[geoID] do begin
 PushFunction(253);
 FindInTexList:=false;
 for i:=0 to TexVertexCount-1 do if (TexVertexList[i]-1)=num then begin
  FindInTexList:=true;
  PopFunction;
  exit;
 end;//of if/for
 PopFunction;
end;End;

//Создает список, содержащий изображение текстурных вершин
//из слоя CoordID
//Записывает его ID в TexListNum
procedure MakeTVList(dc:hdc;hrc:HGLRC;CoordID:integer);
Var j,i,ii:integer;
Begin
PushFunction(254);
TexListNum:=glGenLists(1);       //выделить номер списка
glNewList(TexListNum,GL_COMPILE);//начало списка
glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);//контурно
glLineWidth(1.0);               //минимальная ширина
for j:=0 to CountOfGeosets-1 do with Geosets[j] do begin
  if not GeoObjs[j].IsSelected then continue;//пропуск невыделенного
  glColor3f(1,1,1);               //белый цвет
  glBegin(GL_TRIANGLES);          //вначале - чертим линии
   //отбор треугольников
   for i:=0 to length(Faces)-1 do begin
    ii:=0;
    repeat
     if FindInTexList(j,Faces[i,ii]) and
        FindInTexList(j,Faces[i,ii+1]) and
        FindInTexList(j,Faces[i,ii+2]) then begin //треугольник есть!
      glVertex2f(Crds[CoordID].TVertices[Faces[i,ii],1],
                 Crds[CoordID].TVertices[Faces[i,ii],2]);
      glVertex2f(Crds[CoordID].TVertices[Faces[i,ii+1],1],
                 Crds[CoordID].TVertices[Faces[i,ii+1],2]);
      glVertex2f(Crds[CoordID].TVertices[Faces[i,ii+2],1],
                 Crds[CoordID].TVertices[Faces[i,ii+2],2]);
     end;//of if
     ii:=ii+3;                    //движение по треугольникам
    until ii>=length(Faces[i])-1;
   end;//of for
  glEnd;                          //конец рисования

  //Так. Теперь - вершины:
  glPointSize(5);                 //размер точек
  glColor3f(0,0,1);               //синий цвет
  glBegin(GL_POINTS);             //вот они - точки!
   for i:=0 to GeoObjs[j].TexVertexCount-1 do
    glVertex2f(Crds[CoordID].TVertices[GeoObjs[j].TexVertexList[i]-1,1],
               Crds[CoordID].TVertices[GeoObjs[j].TexVertexList[i]-1,2]);
  glEnd;                          //конец рисования
  //Второй ряд - для надежности распознавания:
  glPointSize(2);
  glColor3f(0.5,0.5,1);
  glBegin(GL_POINTS);             //вот они - точки!
   for i:=0 to GeoObjs[j].TexVertexCount-1 do
    glVertex2f(Crds[CoordID].TVertices[GeoObjs[j].TexVertexList[i]-1,1],
               Crds[CoordID].TVertices[GeoObjs[j].TexVertexList[i]-1,2]);
  glEnd;                          //конец рисования

  //Теперь - выделенные вершины:
  glPointSize(5);
  glColor3f(1,0,0);               //красный цвет
  glBegin(GL_POINTS);             //вот они - точки!
   for i:=0 to GeoObjs[j].TexSelVertexCount-1 do
    glVertex2f(Crds[CoordID].TVertices[GeoObjs[j].TexSelVertexList[i]-1,1],
               Crds[CoordID].TVertices[GeoObjs[j].TexSelVertexList[i]-1,2]);
  glEnd;                          //конец рисования
  glPointSize(2);
  glColor3f(1,0.5,0.5);
  glBegin(GL_POINTS);             //вот они - точки!
   for i:=0 to GeoObjs[j].TexSelVertexCount-1 do
    glVertex2f(Crds[CoordID].TVertices[GeoObjs[j].TexSelVertexList[i]-1,1],
               Crds[CoordID].TVertices[GeoObjs[j].TexSelVertexList[i]-1,2]);
  glEnd;                          //конец рисования
end;
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);//контурно
 glColor3f(1,1,1);
 glEndList;                       //конец списка
 PopFunction;
End;
//==========================================================
//ИНТЕРПОЛЯЦИОННЫЕ И КАДРОВЫЕ ФУНКЦИИ
//осуществляет сферическую линейную интерполяцию
//кватерниона, результат возвращает в itd
procedure Slerp(Frame:integer;var its,itd:TContItem);
Var qa:TQuaternion;
    cosom,sinom,omega,scale0,scale1,t,qn:GLFloat;
Const DELTA=0.001;
Begin
 //косинус сферического угла
 cosom:=its.Data[1]*itd.Data[1]+its.Data[2]*itd.Data[2]+
        its.Data[3]*itd.Data[3]+its.Data[4]*itd.Data[4];

 if cosom<0 then begin
  cosom:=-cosom;
  qa.x:=-itd.Data[1];qa.y:=-itd.Data[2];
  qa.z:=-itd.Data[3];qa.w:=-itd.Data[4];
 end else begin
  qa.x:=itd.Data[1];qa.y:=itd.Data[2];
  qa.z:=itd.Data[3];qa.w:=itd.Data[4];
 end;

 t:=(Frame-its.Frame)/(itd.Frame-its.Frame);
 //выбор варианта интерполяции
 if (1-cosom)>DELTA then begin    //сферическая интерполяция
  omega:=arccos(cosom);
  sinom:=sin(omega);
  scale0:=sin((1.0 - t)*omega)/sinom;
  scale1:=sin(t*omega)/sinom;
 end else begin                   //линейная интерполяция
  scale0:=1.0-t;
  scale1:=t;
 end;

 //Собственно интерполяция
 itd.Data[1]:=scale0*its.Data[1]+scale1*qa.x;
 itd.Data[2]:=scale0*its.Data[2]+scale1*qa.y;
 itd.Data[3]:=scale0*its.Data[3]+scale1*qa.z;
 itd.Data[4]:=scale0*its.Data[4]+scale1*qa.w;
 qn:=1/sqrt(itd.Data[1]*itd.Data[1]+itd.Data[2]*itd.Data[2]+
            itd.Data[3]*itd.Data[3]+itd.Data[4]*itd.Data[4]);
 itd.Data[1]:=itd.Data[1]*qn;
 itd.Data[2]:=itd.Data[2]*qn;
 itd.Data[3]:=itd.Data[3]*qn;
 itd.Data[4]:=itd.Data[4]*qn;
End;
//-------------------------------------------------
//Интерполяция кватернионов поворота
//сплайнами Кочанека-Бартельса.
procedure SlerpQ(Frame:integer;var its,itd:TContItem);
Var t:GLFloat;
    v1,c1,v2,c2,tmp1,tmp2,{tmp3,tmp4,tmp5,}dst:TQuaternion;
//Const d3=1/3;
//интерполяция кватернионов, t - время
procedure GetSlerp(var q1,q2,qs:TQuaternion;t:GLFloat);
Var cosom,omega,sinom,scale0,scale1,qn:double;qa:TQuaternion;
Const DELTA=0.00001;
Begin
 //косинус сферического угла
 cosom:=q1.x*q2.x+q1.y*q2.y+q1.z*q2.z+q1.w*q2.w;
 if cosom<0 then begin
  cosom:=-cosom;
  qa.x:=-q2.x;qa.y:=-q2.y;
  qa.z:=-q2.z;qa.w:=-q2.w;
 end else qa:=q2;
 if (1-cosom)>Delta then begin
  omega:=arccos(cosom);
  sinom:=sin(omega);
  scale0:=sin((1.0 - t)*omega)/sinom;
  scale1:=sin(t*omega)/sinom;
 end else begin
  scale0:=1.0-t;
  scale1:=t;
 end;
 //Собственно интерполяция
 qs.x:=scale0*q1.x+scale1*qa.x;
 qs.y:=scale0*q1.y+scale1*qa.y;
 qs.z:=scale0*q1.z+scale1*qa.z;
 qs.w:=scale0*q1.w+scale1*qa.w;
 qn:=1/sqrt(qs.x*qs.x+qs.y*qs.y+qs.z*qs.z+qs.w*qs.w);
 qs.x:=qs.x*qn;
 qs.y:=qs.y*qn;
 qs.z:=qs.z*qn;
 qs.w:=qs.w*qn;
End;
Begin
 //1. Находим локальное время сплайна
 t:=(Frame-its.Frame)/(itd.Frame-its.Frame);
 //2. Инициализация кватернионов
 v1.x:=its.Data[1]; v2.x:=itd.Data[1];
 v1.y:=its.Data[2]; v2.y:=itd.Data[2];
 v1.z:=its.Data[3]; v2.z:=itd.Data[3];
 v1.w:=its.Data[4]; v2.w:=itd.Data[4];

{ c1.x:=its.Data[1]+its.OutTan[1]/3;
 c1.y:=its.Data[2]+its.OutTan[2]/3;
 c1.z:=its.Data[3]+its.OutTan[3]/3;
 c1.w:=its.Data[4]+its.OutTan[4]/3;

 c2.x:=itd.Data[1]-itd.InTan[1]/3;
 c2.y:=itd.Data[2]-itd.InTan[2]/3;
 c2.z:=itd.Data[3]-itd.InTan[3]/3;
 c2.w:=itd.Data[4]-itd.InTan[4]/3;

 //3. Собственно интерполирование
 GetSlerp(v1,c1,tmp1,t);
 GetSlerp(c1,c2,tmp2,t);
 GetSlerp(c2,v2,tmp3,t);
 GetSlerp(tmp1,tmp2,tmp4,t);
 GetSlerp(tmp2,tmp3,tmp5,t);
 GetSlerp(tmp4,tmp5,dst,t);}
 c1.x:=its.OutTan[1];
 c1.y:=its.OutTan[2];
 c1.z:=its.OutTan[3];
 c1.w:=its.OutTan[4];

 c2.x:=itd.InTan[1];
 c2.y:=itd.InTan[2];
 c2.z:=itd.InTan[3];
 c2.w:=itd.InTan[4];
 GetSlerp(v1,v2,tmp1,t);
 GetSlerp(c1,c2,tmp2,t);
 GetSlerp(tmp1,tmp2,dst,2*t*(1-t));
 //4. Возврат значений
 itd.Data[1]:=dst.x;
 itd.Data[2]:=dst.y;
 itd.Data[3]:=dst.z;
 itd.Data[4]:=dst.w;
End;
//----------------------------------------------------------
//Интерполяция сплайнами Кочанека-Бартельса.
procedure Spline(Frame:integer;var its,itd:TContItem);
Var f1,f2,f3,f4,t:GLFloat;
Begin
 //1. Находим локальное время сплайна
 t:=(Frame-its.Frame)/(itd.Frame-its.Frame);
// if itd.Frame-its.Frame<1e-6 then MessageBox(0,'asd','sdg',0);
 f1:=2*t*t*t-3*t*t+1;
 f2:=t*t*t-2*t*t+t;
 f3:=-2*t*t*t+3*t*t;
 f4:=t*t*t-t*t;
 itd.Data[1]:=its.Data[1]*f1+its.OutTan[1]*f2+
              itd.Data[1]*f3+itd.InTan[1]*f4;
 itd.Data[2]:=its.Data[2]*f1+its.OutTan[2]*f2+
              itd.Data[2]*f3+itd.InTan[2]*f4;
 itd.Data[3]:=its.Data[3]*f1+its.OutTan[3]*f2+
              itd.Data[3]*f3+itd.InTan[3]*f4;
 itd.Data[4]:=its.Data[4]*f1+its.OutTan[4]*f2+
              itd.Data[4]*f3+itd.InTan[4]*f4;
End;
//----------------------------------------------------------
//Интерполяция сплайнами Безье
procedure BezInterp(Frame:integer;var its,itd:TContItem);
Var t,f1,f2,f3,f4:GLFloat;
Begin
 //1. Найдём локальное время сплайна
 t:=(Frame-its.Frame)/(itd.Frame-its.Frame);

 //2. Вспомогательные значения (для большей скорости расч.):
 f1:=(1-t)*(1-t)*(1-t);       //(1-t)^3
 f2:=3*t*(1-t)*(1-t);
 f3:=3*t*t*(1-t);
 f4:=t*t*t;                   //t^3

 //3. Расчёт
 itd.Data[1]:=f1*its.Data[1]+f2*its.OutTan[1]+
              f3*itd.InTan[1]+f4*itd.Data[1];
 itd.Data[2]:=f1*its.Data[2]+f2*its.OutTan[2]+
              f3*itd.InTan[2]+f4*itd.Data[2];
 itd.Data[3]:=f1*its.Data[3]+f2*its.OutTan[3]+
              f3*itd.InTan[3]+f4*itd.Data[3];
End;
//----------------------------------------------------------
//Ищет кадр с заданным значением Frame;
//Возвращает его номер в контроллере Cont
//или же len+1;len - длина контроллера
function GetFramePos(var Cont:TController;Frame,Len:integer):integer;
Var i,{fs,fe,}nfs,nfe,Delta,tmp,ntmp:integer;
Begin
 PushFunction(255);
 nfs:=0;nfe:=len-1;
 if len=0 then begin
  Result:=0;
  exit;
 end;//of if
{ fs:=Cont.Items[nfs].Frame;
 fe:=Cont.Items[nfe].Frame;}
 Delta:=nfe-nfs;
 while Delta>5 do begin
  ntmp:=nfs+(Delta shr 1);
  tmp:=Cont.Items[ntmp].Frame;
  if tmp<Frame then nfs:=ntmp else nfe:=ntmp;
  Delta:=nfe-nfs;
 end;//of while

 i:=nfs;
 while (i<=len) and (Cont.Items[i].Frame<Frame) do inc(i);
 Result:=i;
 PopFunction;
End;
//----------------------------------------------------------
//Вспомогательная:
//Поиск КК в контроллере "вперёд". Процедура ищет КК от
//Frame и дальше. Дойдя до конца анимации, она ищет их
//сначала анимки. Если полный круг завершился,
//а ничего всё ещё не найдено, функция возвр. Frame=-10000.
//len - длина контроллера
//Frame - номер кадра, от которого начинается поиск.
//OMinF,OMaxF - кадры, ограничивающие анимку
//cont - контроллер для поиска.
function LookForward(var cont:TController;
                     Frame,OMinF,OMaxF,len:integer):TContItem;
Var iMin,i:integer;
Begin
 Result.Frame:=-10000;
 PushFunction(256);
 //0. Вычисляем начальную позицию для поиска
 i:=GetFramePos(cont,Frame,len);  //поиск
 //Если сразу же попали в кадр - выйти
 if (i<len) and (cont.Items[i].Frame=Frame) then begin
  Result:=cont.Items[i];
  PopFunction;
  exit;
 end;//of if

 //1. Вычисляем индекс начального КК
 iMin:=GetFramePos(cont,OMinF,len);
 if (iMin>=len) or (cont.Items[iMin].Frame>OMaxF) then begin
  PopFunction;
  exit; //нет КК в анимке
 end;

 //выход за пределы контроллера/анимки - возвр. начальный кадр.
 if (i>=len) or (cont.Items[i].Frame>OMaxF) then begin
  Result:=cont.Items[iMin];
  PopFunction;
  exit;
 end;//of if

 Result:=cont.Items[i];
 PopFunction;
End;

//Вспомогательная:
//Поиск КК в контроллере "назад". Процедура ищет КК от
//Frame и ниже. Дойдя до начала анимации, она ищет их
//с конца анимки. Если полный круг завершился,
//а ничего всё ещё не найдено, функция возвр. Frame=-10000.
//len - длина контроллера
//Frame - номер кадра, от которого начинается поиск.
//OMinF,OMaxF - кадры, ограничивающие анимку
//cont - контроллер для поиска.
function LookBack(var cont:TController;
                     Frame,OMinF,OMaxF,len:integer):TContItem;
Var iMin,iMax,i:integer;
Begin
 PushFunction(257);
 Result.Frame:=-10000;

 //0. Вычисляем начальную позицию для поиска
 i:=GetFramePos(cont,Frame,len);  //поиск
 //Если сразу же попали в кадр - выйти
 if (i<len) and (cont.Items[i].Frame=Frame) then begin
  Result:=cont.Items[i];
  PopFunction;
  exit;
 end;//of if

 //1. Вычисляем индекс начального и конечного КК
 iMin:=GetFramePos(cont,OMinF,len);
 if (iMin>=len) or (cont.Items[iMin].Frame>OMaxF) then begin
  PopFunction;
  exit; //нет КК в анимке
 end;//of if

 iMax:=GetFramePos(cont,OMaxF,len);
 if iMax>=len then iMax:=len-1;
 if i>len then i:=len;

 //2. Собственно цикл поиска
  dec(i);
  if (i<0) or (i<iMin) then i:=iMax; //цикл замкнулся
  while (i>0) and (cont.Items[i].Frame>OMaxF) do dec(i);

  Result:=cont.Items[i];
  PopFunction;
End;


//Извлекает из контроллера ContNum данные,
//соответствующие кадру FrameNum.
//При необходимости осуществляется интерполяция
function GetFrameData(ContNum,FrameNum:integer;CngType:integer):TContItem;
Var its,itd:TContItem;len,i{,ii}:integer;
    a,b,DeltaFrame:GLFloat;
    OwnMinFrame,OwnMaxFrame:cardinal;
Begin
 PushFunction(258);
 OwnMinFrame:=MinFrame;OwnMaxFrame:=MaxFrame;
 if (UsingGlobalSeq>=0) and (AnimEdMode>0) then begin
  if Controllers[ContNum].GlobalSeqId<>UsingGlobalSeq then FrameNum:=0;
 end else begin//of if
  //Учет глобальной анимации
  if (Controllers[ContNum].GlobalSeqId>=0) and (AnimEdMode>0) then begin
   OwnMinFrame:=0;
   OwnMaxFrame:=GlobalSequences[Controllers[ContNum].GlobalSeqId];
   if GlobalSequences[Controllers[ContNum].GlobalSeqId]=0 then
    FrameNum:=Controllers[ContNum].Items[0].Frame
   else FrameNum:=SumFrame mod GlobalSequences[Controllers[ContNum].GlobalSeqId];
  end;//of if (GlobalAnim)
 end;//of if

 {i:=0;}len:=length(Controllers[ContNum].Items);
 case CngType of
  ctAlpha:its.Data[1]:=1;
  ctRotation:begin
   its.Data[1]:=0;its.Data[2]:=0;its.Data[3]:=0;its.Data[4]:=1;
  end;//of ctRotation
  ctScaling:begin its.Data[1]:=1;its.Data[2]:=1;its.Data[3]:=1;end;
  ctTranslation:begin its.Data[1]:=0;its.Data[2]:=0;its.Data[3]:=0;end;
 end;//of case


 itd:=LookForward(Controllers[ContNum],FrameNum,OwnMinFrame,OwnMaxFrame,len);
 if itd.Frame=CurFrame then begin //попали точно в кадр
  Result:=itd;
  PopFunction;
  exit;
 end;//of if
 if itd.Frame<0 then begin        //в линейке нет КК
  Result:=its;                    //именно так, пустышку!
  PopFunction;
  exit;
 end;//of if
 its:=LookBack(Controllers[ContNum],FrameNum,OwnMinFrame,OwnMaxFrame,len);
 if its.Frame=itd.Frame then begin
  Result:=itd;
  PopFunction;
  exit;
 end;//of if

 //Теперь интерполяция - разная, в зависимости
 //от типа контроллера и типа данных
 if Controllers[ContNum].ContType=DontInterp then begin
  Result:=its;
  PopFunction;
  exit;
 end;//of if

 //Учтём также, что может быть itd.Frame<its.Frame
 if itd.Frame<its.Frame then begin //нужно скорректировать
  if FrameNum>its.Frame then FrameNum:=FrameNum-its.Frame
  else FrameNum:=OwnMaxFrame-its.Frame+FrameNum-OwnMinFrame;
  itd.Frame:=OwnMaxFrame-its.Frame+itd.Frame-OwnMinFrame;
  its.Frame:=0;
 end;//of if

 if cngType=ctRotation then begin //вращение, интерп. кватернионом
  if (Controllers[ContNum].ContType=Linear) then Slerp(FrameNum,its,itd)
  else SlerpQ(FrameNum,its,itd);
 end else begin                   //перенос, масштаб и пр.
  case Controllers[ContNum].ContType of
   Linear:begin
    DeltaFrame:=1/(itd.Frame-its.Frame);
    for i:=1 to Controllers[ContNum].SizeOfElement do begin//интерполируем по к-там
     a:=(itd.Data[i]-its.Data[i])*DeltaFrame;
     b:=its.Data[i]-a*its.Frame;
     itd.Data[i]:=a*FrameNum+b;      //получим значение
    end;//of for
   end;//of Linear
   Bezier:BezInterp(FrameNum,its,itd); //Безье-интерполяция
   Hermite:Spline(FrameNum,its,itd);   //сплайновая инт.
  end;//of case
 end;//of if(else)
 GetFrameData:=itd;
 PopFunction;
End;
//==========================================================
//НАБОР ВСПОМОГАТЕЛЬНЫХ ФУНКЦИЙ ДЛЯ РАБОТЫ С МАТРИЦАМИ/КВАТЕРНИОНАМИ

//Возвращает true, если матрицы сходные (т.е. близки др. к другу)
function IsMatrixEqual(m1,m2:TRotMatrix):boolean;
Var i,ii:integer; Delta:GLFloat;
Begin
 Delta:=0;
 for i:=0 to 2 do for ii:=0 to 2 do Delta:=Delta+abs(m1[i,ii]-m2[i,ii]);
 Result:=Delta<1e-5;
End;
//----------------------------------------------------------
//Преобразует кватернион в 3D-матрицу поворота
procedure QuaternionToMatrix(q:TQuaternion;var m:TRotMatrix);
Var wx,wy,wz,xx,yy,yz,xy,xz,zz,x2,y2,z2:GLfloat;
Begin
 x2:=q.x+q.x;
 y2:=q.y+q.y;
 z2:=q.z+q.z;
 xx:=q.x*x2; xy:=q.x*y2; xz:=q.x*z2;
 yy:=q.y*y2; yz:=q.y*z2; zz:=q.z*z2;
 wx:=q.w*x2; wy:=q.w*y2; wz:=q.w*z2;

 m[0,0]:=1.0-(yy+zz); m[1,0]:=xy-wz;       m[2,0]:=xz+wy;
 m[0,1]:=xy+wz;       m[1,1]:=1.0-(xx+zz); m[2,1]:=yz-wx;
 m[0,2]:=xz-wy;       m[1,2]:=yz+wx;       m[2,2]:=1.0-(xx+yy);
End;
//----------------------------------------------------------
//Перемножает две текстурные матрицы 4x4
procedure MulTexMatrices(var C,D:TTexMatrix);
Var i,j,ii:integer;Sum:GLDouble;Dst:TTexMatrix;
Begin
 for i:=0 to 3 do for j:=0 to 3 do begin
  Sum:=0;
  for ii:=0 to 3 do Sum:=Sum+C[i,ii]*D[ii,j];
  Dst[i,j]:=Sum;
 end;//of for j/i
 C:=Dst;
End;
//----------------------------------------------------------
//Преобразует матрицу поворота в нормированный кватернион.
procedure MatrixToQuaternion(m:TRotMatrix;var q:TQuaternion);
Var tr,qn,s:GLFloat;
    qa:array[0..3] of GLFloat;
    i,j,k:integer;
const nxt:array [0..2] of integer=(1,2,0);
Begin
 //1. Ищем диагональ матрицы:
{ tr:=m[0,0]+m[1,1]+m[2,2];
 if (tr>0) then begin //диагональ положительна, w-наибольший компонент
  q.w:=tr+1;
  q.x:=(m[1,2]-m[2,1]);
  q.y:=(m[2,0]-m[0,2]);
  q.z:=(m[0,1]-m[1,0]);
 end else begin       //векторный компонент максимален
  if (m[0,0]>m[1,1]) and (m[0,0]>m[2,2]) then begin
   q.x:=1.0+m[0,0]-m[1,1]-m[2,2];
   q.y:=m[1,0]+m[0,1];
   q.z:=m[2,0]+m[0,2];
   q.w:=m[1,2]-m[2,1];
  end else begin
   if m[1,1]>m[2,2] then begin
    q.x:=m[1,0]+m[0,1];
    q.y:=1.0+m[1,1]-m[0,0]-m[2,2];
    q.z:=m[2,1]+m[1,2];
    q.w:=m[2,0]-m[0,2];
   end else begin
    q.x:=m[0,2]+m[2,0];
    q.y:=m[1,2]+m[2,1];
    q.z:=1.0+m[2,2]-m[0,0]-m[1,1];
    q.w:=m[0,1]-m[1,0];
   end;
  end;
 end;//of if (tr)}
 tr:=m[0,0]+m[1,1]+m[2,2];
  if (tr > 0.0) then begin
   s:=sqrt(tr+1.0);
   q.w:=s*0.5;
   s:=0.5/s;
   q.x:=(m[1,2]-m[2,1])*s;
   q.y:=(m[2,0]-m[0,2])*s;
   q.z:=(m[0,1]-m[1,0])*s;
  end else begin
   i:= 0;
   if (m[1,1]>m[0,0]) then i:=1;
   if (m[2,2]>m[i,i]) then i:=2;
   j:=nxt[i];
   k:=nxt[j];

   s:=sqrt((m[i,i]-(m[j,j]+m[k,k]))+1.0);

   qa[i]:=s*0.5;

   if (s<>0.0) then s:=0.5/s;

   qa[3]:=(m[j,k]-m[k,j])*s;
   qa[j]:=(m[i,j]+m[j,i])*s;
   qa[k]:=(m[i,k]+m[k,i])*s;

   q.x:=qa[0];
   q.y:=qa[1];
   q.z:=qa[2];
   q.w:=qa[3];
  end;//of if
 //Теперь - нормирование кватерниона
 qn:=1/sqrt(q.x*q.x+q.y*q.y+q.z*q.z+q.w*q.w);
 q.x:=q.x*qn; q.y:=q.y*qn; q.z:=q.z*qn; q.w:=q.w*qn;
End;
//----------------------------------------------------------
//Преобразует кватернион в ненормированную матрицу
{procedure QuaternionToMatrixNN(q:TQuaternion;var m:TRotMatrix);
Begin
 m[0,0]:= 1-2*(q.y*q.y+q.z*q.z);
 m[1,0]:= 2*(q.x*q.y-q.w*q.z);
 m[2,0]:= 2*(q.x*q.z+q.w*q.y);

 m[0,1]:= 2*(q.x*q.y+q.w*q.z);
 m[1,1]:= 1-2*(q.x*q.x+q.z*q.z);
 m[2,1]:= 2*(q.y*q.z-q.w*q.x);

 m[0,2]:= 2*(q.x*q.z-q.w*q.y);
 m[1,2]:= 2*(q.y*q.z+q.w*q.x);
 m[2,2]:= 1-2*(q.x*q.x+q.y*q.y);
End;}
//----------------------------------------------------------
//Перемножение двух матриц
procedure MulMatrices(mp,ms:TRotMatrix;var md:TRotMatrix);
Var i:integer;
Begin for i:=0 to 2 do begin
 md[0,i]:=mp[0,i]*ms[0,0]+mp[1,i]*ms[0,1]+mp[2,i]*ms[0,2];
 md[1,i]:=mp[0,i]*ms[1,0]+mp[1,i]*ms[1,1]+mp[2,i]*ms[1,2];
 md[2,i]:=mp[0,i]*ms[2,0]+mp[1,i]*ms[2,1]+mp[2,i]*ms[2,2];
end;End;
//----------------------------------------------------------
//Перемножает два кватерниона
procedure MulQuaternions(q1,q2:TQuaternion;var qdest:TQuaternion);
Var a,b,c,d,e,f,g,h:GLfloat;
Begin
  A:= (q1.w + q1.x) * (q2.w + q2.x);
  B:= (q1.z - q1.y) * (q2.y - q2.z);
  C:= (q1.x - q1.w) * (q2.y + q2.z);
  D:= (q1.y + q1.z) * (q2.x - q2.w);
  E:= (q1.x + q1.z) * (q2.x + q2.y);
  F:= (q1.x - q1.z) * (q2.x - q2.y);
  G:= (q1.w + q1.y) * (q2.w - q2.z);
  H:= (q1.w - q1.y) * (q2.w + q2.z);

  qdest.w:= B + (-E - F + G + H) * 0.5;
  qdest.x:= A - ( E + F + G + H) * 0.5;
  qdest.y:=-C + ( E - F + G - H) * 0.5;
  qdest.z:=-D + ( E - F - G + H) * 0.5;
End;
//----------------------------------------------------------
//вычисляет обратный кватернион (qdest=qsrc^-1).
procedure GetInverseQuaternion(var qsrc,qdest:TQuaternion);
Var N:GLFloat;
Begin
 N:=1/(qsrc.x*qsrc.x+qsrc.y*qsrc.y+qsrc.z*qsrc.z+qsrc.w*qsrc.w);
 qdest.x:=-qsrc.x*N;
 qdest.y:=-qsrc.y*N;
 qdest.z:=-qsrc.z*N;
 qdest.w:=qsrc.w*N;
End;
//----------------------------------------------------------
//вычисляет логарифм кватерниона
procedure CalcLogQ(var q:TQuaternion);
Var sint:GLFloat;
Begin
 if q.w>0.99999 then q.w:=0.99999;
 sint:=arccos(q.w)/sqrt(1-q.w*q.w);
 q.x:=q.x*sint;
 q.y:=q.y*sint;
 q.z:=q.z*sint;
 q.w:=0;
End;
//----------------------------------------------------------
//вычисляет экспоненту кватерниона
procedure CalcExpQ(var q:TQuaternion);
Var t,divt{,sint}:GlFloat;
Begin
 t:=sqrt(q.x*q.x+q.y*q.y+q.z*q.z);
 if t<1e-5 then begin
  q.w:=1;
  q.x:=0;
  q.y:=0;
  q.z:=0;
  exit;
 end;//of if
 divt:=sin(t)/t;
 q.w:=cos(t);
 q.x:=q.x*divt;
 q.y:=q.y*divt;
 q.z:=q.z*divt;
End;
//==========================================================
//Заполнение абсолютных параметров кости/помощника
procedure InterpTBone(FrameNum:integer;var b:TBone);
Var it:TContItem;j:integer;
Begin
  PushFunction(259);
  B.IsReady:=B.Parent<0;
  if B.Translation<0 then begin
   B.AbsVector[1]:=PivotPoints[b.ObjectID,1];
   B.AbsVector[2]:=PivotPoints[b.ObjectID,2];
   B.AbsVector[3]:=PivotPoints[b.ObjectID,3];
  end else begin
   it:=GetFrameData(B.translation,FrameNum,ctTranslation);//получить вектор
   B.AbsVector[1]:=it.Data[1]+PivotPoints[b.ObjectID,1];
   B.AbsVector[2]:=it.Data[2]+PivotPoints[b.ObjectID,2];
   B.AbsVector[3]:=it.Data[3]+PivotPoints[b.ObjectID,3];
  end;//of if (Yes/NoTrans)
  if B.Rotation<0 then begin
   B.AbsQuaternion.x:=0;
   B.AbsQuaternion.y:=0;
   B.AbsQuaternion.z:=0;
   B.AbsQuaternion.w:=1;
  end else begin
   it:=GetFrameData(B.Rotation,FrameNum,ctRotation);
   B.AbsQuaternion.x:=it.Data[1];
   B.AbsQuaternion.y:=it.Data[2];
   B.AbsQuaternion.z:=it.Data[3];
   B.AbsQuaternion.w:=it.Data[4];
  end;//of if (Yes/NoRot)
  if B.Scaling<0 then begin
   B.AbsScaling[1]:=1;
   B.AbsScaling[2]:=1;
   B.AbsScaling[3]:=1;
  end else begin
   it:=GetFrameData(B.Scaling,FrameNum,ctScaling);
   B.AbsScaling[1]:=it.Data[1];
   B.AbsScaling[2]:=it.Data[2];
   B.AbsScaling[3]:=it.Data[3];
  end;//of if (Yes/NoScal)
  if B.Visibility<0 then begin
   B.AbsVisibility:=true;
  end else begin
   it:=GetFrameData(B.Visibility,FrameNum,ctAlpha);
   if it.Data[1]>0.2 then B.AbsVisibility:=true
                   else B.AbsVisibility:=false;
  end;//of if (Yes/NoVis)
  //Вычисляем матрицу поворота
  QuaternionToMatrix(b.AbsQuaternion,b.AbsMatrix);
  for j:=0 to 2 do begin
   b.AbsMatrix[j,0]:=b.AbsMatrix[j,0]*b.AbsScaling[1];
   b.AbsMatrix[j,1]:=b.AbsMatrix[j,1]*b.AbsScaling[2];
   b.AbsMatrix[j,2]:=b.AbsMatrix[j,2]*b.AbsScaling[3];
  end;//of for j
  //Учесть возможность разворота
  if b.IsBillboarded then MulMatrices(BilbMatrix,b.AbsMatrix,b.AbsMatrix);
  PopFunction;
End;
//----------------------------------------------------------
//Рассчитывает параметры текущего объекта с использованием
//параметров родителя
procedure CalcAbsolute(FrameNum:integer;parent:TBone;var Child:TBone);
Var j:integer;
    x,y,z{,sx,sy,sz}:GLFloat;
    //q:TQuaternion;
    m:TRotMatrix;
const IdMatrix:TRotMatrix=((1,0,0),(0,1,0),(0,0,1));
Begin
 PushFunction(260);
 //2. Найти текущую матриу
 if not Child.IsBillboarded then
  MulMatrices(Parent.AbsMatrix,Child.AbsMatrix,Child.AbsMatrix)
 else begin
  m:=IdMatrix;
  for j:=0 to 2 do begin
   m[j,0]:=m[j,0]*Parent.AbsScaling[1];
   m[j,1]:=m[j,1]*Parent.AbsScaling[2];
   m[j,2]:=m[j,2]*Parent.AbsScaling[3];
  end;//of for j
  MulMatrices(m,Child.AbsMatrix,Child.AbsMatrix);
 end;
 //3. Вычислить дочерний вектор перемещения
 Child.AbsVector[1]:=Child.AbsVector[1]-PivotPoints[Parent.ObjectID,1];
 Child.AbsVector[2]:=Child.AbsVector[2]-PivotPoints[Parent.ObjectID,2];
 Child.AbsVector[3]:=Child.AbsVector[3]-PivotPoints[Parent.ObjectID,3];
 x:=Parent.AbsVector[1]+
    Parent.AbsMatrix[0,0]*Child.AbsVector[1]+
    Parent.AbsMatrix[1,0]*Child.AbsVector[2]+
    Parent.AbsMatrix[2,0]*Child.AbsVector[3];
 y:=Parent.AbsVector[2]+
    Parent.AbsMatrix[0,1]*Child.AbsVector[1]+
    Parent.AbsMatrix[1,1]*Child.AbsVector[2]+
    Parent.AbsMatrix[2,1]*Child.AbsVector[3];
 z:=Parent.AbsVector[3]+
    Parent.AbsMatrix[0,2]*Child.AbsVector[1]+
    Parent.AbsMatrix[1,2]*Child.AbsVector[2]+
    Parent.AbsMatrix[2,2]*Child.AbsVector[3];
 Child.AbsVector[1]:=x;
 Child.AbsVector[2]:=y;
 Child.AbsVector[3]:=z;
 //4. Вычислить видимость
 Child.AbsVisibility:=Child.AbsVisibility and Parent.AbsVisibility;
 PopFunction;
End;
//----------------------------------------------------------
//Рассчитывает абсолютные значения для кости/помощника
procedure CalcTBone(FrameNum:integer;var b:TBone);
Var objtype:integer;
Begin
 if b.IsReady then exit;         //тут уже нечего делать...
 PushFunction(261);
 objtype:=GetTypeObjByID(b.Parent);
 //Теперь действуем в зависимости от типа...
 case objtype of
  typHELP:begin                   //помощник
   if not Helpers[b.Parent-Helpers[0].ObjectID].IsReady then
    CalcTBone(FrameNum,Helpers[b.Parent-Helpers[0].ObjectID]);
   Helpers[b.Parent-Helpers[0].ObjectID].IsReady:=true;
   CalcAbsolute(FrameNum,Helpers[b.Parent-Helpers[0].ObjectID],b)
  end;//of typHELP

  typBONE:begin                   //кость
   if not Bones[b.Parent].IsReady then CalcTBone(FrameNum,Bones[b.Parent]);
   Bones[b.Parent].IsReady:=true;
   CalcAbsolute(FrameNum,Bones[b.Parent],b);
  end;//of typBONE

  typATCH:begin                   //точка прикрепления
   if not Attachments[b.Parent-Attachments[0].Skel.ObjectID].Skel.IsReady then
    CalcTBone(FrameNum,Attachments[b.Parent-Attachments[0].Skel.ObjectID].Skel);
   Attachments[b.Parent-Attachments[0].Skel.ObjectID].Skel.IsReady:=true;
   CalcAbsolute(FrameNum,
                Attachments[b.Parent-Attachments[0].Skel.ObjectID].Skel,b)
  end;//of typATCH

  typPRE2:begin
   if not pre2[b.Parent-pre2[0].Skel.ObjectID].Skel.IsReady
   then CalcTBone(FrameNum,pre2[b.Parent-pre2[0].Skel.ObjectID].Skel);
   pre2[b.Parent-pre2[0].Skel.ObjectID].Skel.IsReady:=true;
   CalcAbsolute(FrameNum,pre2[b.Parent-pre2[0].Skel.ObjectID].Skel,b)
  end;//of typPRE2
 end;//of case
 b.IsReady:=true;
 PopFunction;
End;
//----------------------------------------------------------
//Вспомогательная: установка значения скелетной части
//объекта из SelBone.b. ID объекта определяется из SelBone.b
procedure SetSkelPart;
Begin
 PushFunction(262);
 //В зависимости от типа объекта
 case GetTypeObjByID(SelObj.b.ObjectID) of
  typBONE:Bones[SelObj.b.ObjectID-Bones[0].ObjectID]:=SelObj.b;
  typHELP:Helpers[SelObj.b.ObjectID-Helpers[0].ObjectID]:=SelObj.b;
  typAtch:Attachments[SelObj.b.ObjectID-
          Attachments[0].Skel.ObjectID].Skel:=SelObj.b;
  typPRE2:pre2[SelObj.b.ObjectID-pre2[0].Skel.ObjectID].Skel:=SelObj.b;
 end;//of case
 PopFunction;
End;
//----------------------------------------------------------

//Установка скелетной части для объекта из B
procedure SetObjSkelPart(b:TBone);
Begin
 PushFunction(263);
 //В зависимости от типа объекта
 case GetTypeObjByID(b.ObjectID) of
  typBONE:Bones[b.ObjectID-Bones[0].ObjectID]:=b;
  typHELP:Helpers[b.ObjectID-Helpers[0].ObjectID]:=b;
  typAtch:Attachments[b.ObjectID-Attachments[0].Skel.ObjectID].Skel:=b;
  typPRE2:pre2[b.ObjectID-pre2[0].Skel.ObjectID].Skel:=b;
 end;//of case
 PopFunction;
End;
//----------------------------------------------------------
//Работа с анимацией
//Рассчитывает координаты объектов для указанного кадра
procedure CalcAnimCoords(FrameNum:integer);
Var i,ii,j,jj,bNum:integer;
    it:TContItem;
    b:TBone;
    qn:GLfloat;q:TQuaternion;
    Coords:array of TVertex;
    _CountOfCoords:integer;
    Viewport:array[0..3] of GLfloat;
    mvMatrix,ProjMatrix:array[0..15] of GLdouble;
    prjRot:TRotMatrix;
    x,y,z,vx,vy,vz:Double;
    TM:TTexMatrix;
const IdentTexMatrix:TTexMatrix=((1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1));
Begin
 PushFunction(264);
 //-1. Расчёт Billboarded-матрицы.
 glGetIntegerv(GL_VIEWPORT,@Viewport);
 glGetDoublev(GL_MODELVIEW_MATRIX,@mvMatrix);
 glGetDoublev(GL_PROJECTION_MATRIX,@ProjMatrix);
 gluUnProject(0,0,0,@mvMatrix,@ProjMatrix,@Viewport,x,y,z);
 //x->Z
 gluUnProject(0,0,-1,@mvMatrix,@ProjMatrix,@Viewport,vx,vy,vz);
 BilbMatrix[0,0]:=vx-x;BilbMatrix[0,1]:=-(vy-y);BilbMatrix[0,2]:=vz-z;
 //y->X
 gluUnProject(1,0,0,@mvMatrix,@ProjMatrix,@Viewport,vx,vy,vz);
 BilbMatrix[1,0]:=vx-x;BilbMatrix[1,1]:=-(vy-y);BilbMatrix[1,2]:=vz-z;
 //z->Y
 gluUnProject(0,1,0,@mvMatrix,@ProjMatrix,@Viewport,vx,vy,vz);
 BilbMatrix[2,0]:=vx-x;BilbMatrix[2,1]:=-(vy-y);BilbMatrix[2,2]:=vz-z;

 for i:=0 to 2 do begin
  qn:=1/sqrt(sqr(BilbMatrix[i,0])+sqr(BilbMatrix[i,1])+sqr(BilbMatrix[i,2]));
  BilbMatrix[i,0]:=BilbMatrix[i,0]*qn;
  BilbMatrix[i,1]:=BilbMatrix[i,1]*qn;
  BilbMatrix[i,2]:=BilbMatrix[i,2]*qn;
 end;//of for i

 //0. Восстановим значения координат вершин:
 for i:=0 to CountOfGeosets-1 do
 for ii:=0 to Geosets[i].CountOfVertices-1 do begin
  Geosets[i].Vertices[ii]:=SFAVertices[i,ii];
 end;//of for ii/i
 
 //1. Начинаем расчет параметров для всего скелета
 //а. Обработать все корневые объекты
 for i:=0 to CountOfHelpers-1 do InterpTBone(FrameNum,Helpers[i]);
 for i:=0 to CountOfBones-1 do InterpTBone(FrameNum,Bones[i]);
 for i:=0 to CountOfAttachments-1 do InterpTBone(FrameNum,Attachments[i].Skel);
 for i:=0 to CountOfParticleEmitters-1 do InterpTBone(FrameNum,pre2[i].Skel);
 //б. Обсчет остальных объектов
 for i:=0 to CountOfHelpers-1 do CalcTBone(FrameNum,Helpers[i]);
 for i:=0 to CountOfBones-1 do CalcTBone(FrameNum,Bones[i]);
 for i:=0 to CountOfAttachments-1 do CalcTBone(FrameNum,Attachments[i].Skel);
 for i:=0 to CountOfParticleEmitters-1 do CalcTBone(FrameNum,pre2[i].Skel);

 //2. Пересчитаем координаты вершин всех поверхностей
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  SetLength(Coords,40);  //этого хватит с избытком
  for ii:=0 to CountOfVertices-1 do begin
   if High(Groups)<VertexGroup[ii] then begin
    MessageBox(0,'Модель повреждена.'#13#10'Обратитесь к разработчику MdlVis',
                 'Ошибка',MB_ICONSTOP);
    PopFunction;
    exit;
   end;//of if
   _CountOfCoords:=length(Groups[VertexGroup[ii]]);
   //Для каждой кости...
   for j:=0 to _CountOfCoords-1 do begin
    bNum:=Groups[VertexGroup[ii],j];

    //Получить сам объект
    if (CountOfHelpers>0) and (bNum>=Helpers[0].ObjectID) then
       b:=Helpers[bNum-Helpers[0].ObjectID]
    else b:=Bones[bNum];
    Coords[j,1]:=Vertices[ii,1]-PivotPoints[b.ObjectID,1];
    Coords[j,2]:=Vertices[ii,2]-PivotPoints[b.ObjectID,2];
    Coords[j,3]:=Vertices[ii,3]-PivotPoints[b.ObjectID,3];
    //Поворот
    x:=Coords[j,1]*b.AbsMatrix[0,0]+
       Coords[j,2]*b.AbsMatrix[1,0]+
       Coords[j,3]*b.AbsMatrix[2,0];
    y:=Coords[j,1]*b.AbsMatrix[0,1]+
       Coords[j,2]*b.AbsMatrix[1,1]+
       Coords[j,3]*b.AbsMatrix[2,1];
    z:=Coords[j,1]*b.AbsMatrix[0,2]+
       Coords[j,2]*b.AbsMatrix[1,2]+
       Coords[j,3]*b.AbsMatrix[2,2];
    //Перенос с восстановлением
    Coords[j,1]:=x+b.AbsVector[1];
    Coords[j,2]:=y+b.AbsVector[2];
    Coords[j,3]:=z+b.AbsVector[3];
   end;//of for j
   //Теперь усредним...
   Vertices[ii,1]:=0;Vertices[ii,2]:=0;Vertices[ii,3]:=0;
   for j:=0 to _CountOfCoords-1 do begin
    Vertices[ii,1]:=Vertices[ii,1]+Coords[j,1];
    Vertices[ii,2]:=Vertices[ii,2]+Coords[j,2];
    Vertices[ii,3]:=Vertices[ii,3]+Coords[j,3];
   end;//of for j
   Vertices[ii,1]:=Vertices[ii,1]/_CountOfCoords;
   Vertices[ii,2]:=Vertices[ii,2]/_CountOfCoords;
   Vertices[ii,3]:=Vertices[ii,3]/_CountOfCoords;
  end;//of for ii

  //Расчет цвета поверхности [и прозрачности]
  for ii:=0 to CountOfGeosetAnims-1 do if GeosetAnims[ii].GeosetID=i then begin
   //Анимация найдена.
   if GeosetAnims[ii].IsAlphaStatic then begin
    Geosets[i].Color4f[4]:=GeosetAnims[ii].Alpha;
    if Geosets[i].Color4f[4]<0 then Geosets[i].Color4f[4]:=1;
   end else begin                     //надо интерполировать
    it:=GetFrameData(GeosetAnims[ii].AlphaGraphNum,FrameNum,ctAlpha);
    Geosets[i].Color4f[4]:=it.Data[1];
    //Учет "выключателя" - контроллера DontInterp
    if (Controllers[GeosetAnims[ii].AlphaGraphNum].ContType=DontInterp)
       and (Geosets[i].Color4f[4]<0.5) then Geosets[i].Color4f[4]:=-1;
   end;//of if
   if GeosetAnims[ii].IsColorStatic then begin
    Geosets[i].Color4f[1]:=GeosetAnims[ii].Color[3];
    Geosets[i].Color4f[2]:=GeosetAnims[ii].Color[2];
    Geosets[i].Color4f[3]:=GeosetAnims[ii].Color[1];
    if Geosets[i].Color4f[1]<0 then Geosets[i].Color4f[1]:=1;
    if Geosets[i].Color4f[2]<0 then Geosets[i].Color4f[2]:=1;
    if Geosets[i].Color4f[3]<0 then Geosets[i].Color4f[3]:=1;
   end else begin                     //надо интерполировать
    it:=GetFrameData(GeosetAnims[ii].ColorGraphNum,FrameNum,ctTranslation);
    Geosets[i].Color4f[1]:=it.Data[3];
    Geosets[i].Color4f[2]:=it.Data[2];
    Geosets[i].Color4f[3]:=it.Data[1];
   end;//of if
  end;//of if/for ii

 end;//of with/for i

 //Расчёт текстурных матриц для каждого слоя
 for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1 do
 with Materials[i].Layers[ii] do begin
  if TVertexAnimID<0 then continue;   //нет текс. анимации, продолжить
  //Создадим единичную матрицу
  TexMatrix:=IdentTexMatrix;
  
  //Получим данные масштабирования (если есть)
  if TextureAnims[TVertexAnimID].ScalingGraphNum>=0 then begin
   it:=GetFrameData(TextureAnims[TVertexAnimID].ScalingGraphNum,
                    FrameNum,ctScaling);
   TM:=IdentTexMatrix;
   TM[0,0]:=it.Data[1];
   TM[1,1]:=it.Data[2];
   TM[2,2]:=it.Data[3];
   MulTexMatrices(TexMatrix,TM);   //домножение
  end;//of if (IsScaling)

  //Теперь - данные вращения:
  if TextureAnims[TVertexAnimID].RotationGraphNum>=0 then begin
   it:=GetFrameData(TextureAnims[TVertexAnimID].RotationGraphNum,
                    FrameNum,ctRotation);
   q.x:=it.Data[1]; q.y:=it.Data[2]; q.z:=it.Data[3]; q.w:=it.Data[4];
   QuaternionToMatrix(q,prjRot);
   TM:=IdentTexMatrix;
   TM[0,0]:=prjRot[0,0]; TM[1,0]:=prjRot[1,0]; TM[2,0]:=prjRot[2,0];
   TM[0,1]:=prjRot[0,1]; TM[1,1]:=prjRot[1,1]; TM[2,1]:=prjRot[2,1];
   TM[0,2]:=prjRot[0,2]; TM[1,2]:=prjRot[1,2]; TM[2,2]:=prjRot[2,2];
   MulTexMatrices(TexMatrix,TM);
  end;//of if

  //и, наконец, данные переноса
  if TextureAnims[TVertexAnimID].TranslationGraphNum>=0 then begin
   it:=GetFrameData(TextureAnims[TVertexAnimID].TranslationGraphNum,
                    FrameNum,ctTranslation);
   TM:=IdentTexMatrix;
   TM[3,0]:=it.Data[1];
   TM[3,1]:=it.Data[2];
   TM[3,2]:=it.Data[3];
   MulTexMatrices(TexMatrix,TM);  
  end;//of if
 end;//of with/for ii/for i

 //3. Теперь рассчитываем ID текстуры в кадре и AAlpha слоя
 for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1 do
 with Materials[i].Layers[ii] do begin
  if IsAlphaStatic then AAlpha:=Alpha
  else begin
   it:=GetFrameData(NumOfGraph,FrameNum,ctAlpha);
   AAlpha:=it.Data[1];
  end;
  if AAlpha<0 then AAlpha:=1;
  if IsTextureStatic then ATextureID:=TextureID
  else begin
   it:=GetFrameData(NumOfTexGraph,FrameNum,ctTranslation);
   ATextureID:=round(it.Data[1]);
  end; //of if (TextureStatic)
 end;//of with/for ii/i

 if (AnimEdMode=2) and SelObj.IsSelected
 then SelObj.b:=GetSkelObjectById(SelObj.b.ObjectID);
 PopFunction;
End;
//----------------------------------------------------------
//Фильтр: возвращает ID контроллера.
//hi - длина массива контроллеров;
//StartID - начальный номер контроллера.
//Если он равен (-1), то функция вернёт здесь ID
//Первого подходящего контроллера.
//Если нет следующего контроллера, возвр. false
//Учитываются UsingGlobalSeq и IsContrFilter
function GetNextController(var StartID:integer;hi:integer):boolean;
//Var i:integer;
Begin
 PushFunction(265);
 Result:=false;
 //Цикл сканирования контроллеров
 while (StartID+1)<=hi do begin
  inc(StartID);                    //следующий контроллер
  //1. Проверим, установлен ли фильтр.
  if IsContrFilter then begin     //да, применим его
   if (ContrFilter.IndexOf(pointer(StartID))>=0)
   and (length(Controllers[StartID].Items)>0) then begin
    Result:=true;
    PopFunction;
    exit;
   end;//of if/for i
   //Фильтр не пропускает этот контроллер:
   continue;
  end;//of if

  //2. Проверим, используется ли выборка по глобальной
  //   последовательности
  if UsingGlobalSeq>=0 then begin
   if (Controllers[StartID].GlobalSeqId=UsingGlobalSeq) and
      (length(Controllers[StartID].Items)>0) then begin
    Result:=true;
    PopFunction;
    exit;
   end;//of if
   //выборка не пропускает этот контроллер
   continue;
  end;//of if

  //3. Никаких фильтров нет, сразу возвращаем true
  if (length(Controllers[StartID].Items)>0) then begin
   Result:=true;
   PopFunction;
   exit;
  end;//of if
 end;//of while
 PopFunction;
End;

//----------------------------------------------------------
//Запись текущего состояния
procedure TNewUndo.Save;
Begin
 //заглушка (всё равно переопределяется дочерними классами)
End;

//Его восстановление
procedure TNewUndo.Restore;
Begin
 //заглушка (всё равно переопределяется дочерними классами)
End;

//----------------------------------------------------------
//Запись [перед созданием нового контроллера]
procedure TNewControllerUndo.Save;
Begin
 ContID:=length(Controllers);     //т.к. следующий контроллер будет в конце
 b:=SelObj.b;
End;

//Восстановление [отмена создания нового контроллера]
procedure TNewControllerUndo.Restore;
Begin
 PushFunction(266);
 SelObj.b:=b;
 SetSkelPart;
 if ContID=High(Controllers) then SetLength(Controllers,High(Controllers))
 else Controllers[ContID].Items:=nil;
 PopFunction;
End;
//----------------------------------------------------------

procedure TDelControllerUndo.Save;
Begin
 if ContID>High(Controllers) then exit;
 Cont:=Controllers[Contid];
End;

procedure TDelControllerUndo.Restore;
Begin
 if ContID>High(Controllers) then exit;
 PushFunction(267);
 Controllers[ContID]:=Cont;
 Cont.Items:=nil;
 PopFunction;
End;
//----------------------------------------------------------

procedure TDelEvStamps.Save;
Var i,ii:integer;
Begin
 PushFunction(268);
 COEvents:=CountOfEvents;
 SetLength(Stamps,COEvents);
 for i:=0 to CountOfEvents-1 do begin
  SetLength(Stamps[i],Events[i].CountOfTracks);
  for ii:=0 to Events[i].CountOfTracks-1 do Stamps[i,ii]:=Events[i].Tracks[ii];
 end;//of for i
 PopFunction;
End;

//востановление
procedure TDelEvStamps.Restore;
Var i,ii:integer;
Begin
 PushFunction(269);
 for i:=0 to COEvents-1 do begin
  Events[i].CountOfTracks:=length(Stamps[i]);
  SetLength(Events[i].Tracks,Events[i].CountOfTracks);
  for ii:=0 to Events[i].CountOfTracks-1 do Events[i].Tracks[ii]:=Stamps[i,ii];
 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------

procedure TPivUndo.Save;          //сохранить единственную точку (позиция id)
Begin
 pt:=PivotPoints[id];
End;

procedure TPivUndo.Restore;       //восстановить ед. точку (в позицию id)
Var i:integer;
Begin
 PushFunction(270);
 inc(CountOfPivotPoints);
 SetLength(PivotPoints,CountOfPivotPoints);
 for i:=CountOfPivotPoints-2 downto id do PivotPoints[i+1]:=PivotPoints[i];
 PivotPoints[id]:=pt;
 PopFunction;
End;
//----------------------------------------------------------
//==========================================================
initialization
//создание объектов
ContrFilter:=TList.Create;
CurView:=TSceneView.Create;
//установка переменных
IsNoEndList:=false;

IsLowGrid:=false;IsXZGrid:=false;IsYZGrid:=false;
IsXYGrid:=true; //одну из сеток чертить
IsXYZ:=true;   //выводить ли мини-оси
IsShowAll:=false;//пока отображать лишь часть
IsNormals:=false;//не выводить нормали
IsDisp:=true;
ViewType:=0;
{IsFullView:=false;//пока нет общего вида
IsSurfaceView:=false;}
//SelectedBone.IsReady:=false;
NumOfSelBone:=-1;NumOfParentBone:=-1;
MinFrame:=0;SumFrame:=0;MaxFrame:=3333;
IsLight:=true;//использоватьсвет
end.

