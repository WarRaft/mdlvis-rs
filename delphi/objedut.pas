unit objedut;//Вот ведь!..

interface
uses Windows,Messages,OpenGL,mdlWork,mdlDraw,sysutils,classes,math,
     cabstract,crash;
Const uSelect=1;//выделение
//      uChangeGeoset=2;//смена текущей поверхности
      uVertexTrans=3;//изменение координат вершин
      uVertexDelete=4;//изменение количества вершин
      uCreateTriangle=5;//создание треугольника
      uCreateGeoset=6;  //создание новой поверхности
      uSelectVertex=7;//выбор вершин в редакторе костей
      uVertexGroupChange=8;//изменение групп вершин
      uTransBone=9;   //преобразования кости
      uGeosetDelete=10;//удаление поверхности
      uTexSelect=11;  //выделение текстурной карты
      uTexVertexTrans=12;//смещение вершин текстуры
      uUncouple=13;   //разделение вершин
      uTexUncouple=14;//разделение вершин текстурной карты
      uFrameAdd=$FF000000; //добавка пустых кадров
      uSeqPropChange=15;//изменение свойств последовательности
      uSeqDurationChange=16;//изменить длительность глоб. последовательности
      uCreateSeq=17;    //создать последовательность
      uCreateGlobalSeq=18;//создать глобальную последовательность
      uEmittersOff=19; //гашение источников частиц
      uDeleteGlobalSeq=20;//удаление глобальной последовательности
      uDeleteSeq=21;   //удаление последовательности
      uSwapNormals=22; //переворот нормалей
      uDeleteKeyFrames=23;//удаление части кадров.
      uDeleteTriangle=24;//удаление треугольника
      uPasteFrames=25;   //вставка кадров [из буфера]
      uCutKeyFrames=26;  //отрезание части шкалы
      uCreateGAController=27;//создать контроллер "видимость"
      uChangeFrame=28;   //смена содержимого текущего кадра
      uTexCoup=29;       //переворачивание текстуры
      uGeosetDetach=30;
      uNDeleteSeqs=31;   //удаление группы анимаций
      uTexPlaneChange=32;//смена активной текстурной плоскости
      uSelectObject=33;  //выделение объекта
      uChangeObjName=34; //смена имени объекта
      uChangeObjects=35; //изменение состояния объектов
      uChangeObject=36;  //изменение состояния единичного объекта
      uUseNewUndo=37;    //использовать отмену по NewUndo
      uCreateObject=38;  //создание нового объекта
      uDeleteObject=39;  //удаление объекта
      uSaveObjChange=40; //слепок состояния Pivots,Matrices,VertexGr и SelBone
      uPivotChange=41;   //изменение координат объекта
      uAttachObject=42;  //связывание объекта
      uDetachObject=43;  //отсоединение объекта
      uSelectObjects=44; //выделение нескольких объектов
      uDeleteObjects=45; //удаление нескольких объектов
      uCreateController=46;//создание нового контроллера
      uDeleteController=47;//удаление контроллера
      uSaveController=48;//полная запись состояния контроллера
      uSmoothGroups=49;  //запись групп сглаживания (нормалей)
      uCommonUndo=50;    //общий вариант отмены
//константы типов секций
      ut=$1000000;ut2=$2000000;ut3=$3000000;
      utMatTexture=$1000000;utMatAlpha=$2000000;
      utTATranslation=$3000000;utTARotation=$4000000;utTAScaling=$5000000;
      utGAAlpha=$6000000;utGAColor=$7000000;
      utBTranslation=$8000000;
      utHTranslation=$C000000;
      utLTranslation=$10000000;
      utLAS=$14000000;utLAE=$15000000;utLI=$16000000;utLC=$17000000;
      utLAI=$18000000;utLAC=$19000000;
      utATranslation=$1A000000;
      utPTranslation=$1E000000;
      utPER=$22000000;utPG=$23000000;utPLong=$24000000;utPLat=$25000000;
      utPLS=$26000000;utPIV=$27000000;
      utP2Translation=$28000000;
      utP2S=$2C000000;utP2V=$2D000000;utP2L=$2E000000;utP2G=$2F000000;
      utP2E=$30000000;utP2W=$31000000;utP2H=$32000000;
      utRTranslation=$33000000;
      utRHA=$37000000;utRHB=$38000000;utRA=$39000000;utRC=$3A000000;
      utRTS=$3B000000;
      utCTranslation=$3C000000;utCRotation=$3D000000;utCT=$3E000000;
      utETranslation=$3F000000;
      utCSTranslation=$43000000;
type
TChangeObjKFUndo=class(TNewUndo)           //изменение единичного КК контроллера
 private
  CountOfControllers:integer;
  SvCntrs:array of integer;
  SvItems:array of TContItem;
  CountOfSvCntrs:integer;
  procedure SaveContItem(ContID:integer); //запись тек. кадра контроллера
 public
  objs:array of TBone;        //эти поля заполняются ПЕРЕД выховом Save
  CountOfObjs:integer;
  procedure Save;override;
  procedure Restore;override;
end;
      
TSaveSmoothGroups=class(TNewUndo)  //хранит данные групп сглаживания
 private
  _COMidNormals,_COConstNormals:integer;
  _MidNormals:ATMidNormal;
  _ConstNormals:ATConstNormal;
 public
  procedure Save;override;
  procedure Restore;override;
end;//of TSaveSmoothGroups

TSaveSeq=class(TNewUndo)          //используется для сохр./восст. указанной анимации
 private
  Seq:TSequence;                  //собственно последовательность
  IsGlobal:boolean;               //true, если последовательность глобальна
  id:cardinal;                    //id в списке
 public
  procedure Save;override;
  procedure Restore;override;
end;//of TSeqChng

TSaveCreateSeq=class(TNewUndo)    //отмена вставки анимации (фактичски, просто удаление)
 private
  id:integer;
 public
  procedure Save;override;
  procedure Restore;override;
end;//of TSaveCreateSeq

TDelSeqUndo=class(TNewUndo)                //для отмены удаления анимации
 private
  Seq:TSequence;
  IsGlobal:boolean;
  idc,idg:array of integer;                //хранилище глобальных id контроллеров
 public
  id:integer;                              //id удаляемой аним.
  procedure Save;override;
  procedure Restore;override;
end;

Var Undo:array [1..10] of TUndo; //хранит данные для отмены посл. действия
//_    TexUndo:array[1..10] of TUndo;//то же, для ред. текстур
    CountOfUndo:integer;//кол-во занятых элементов
    NewUndo:array of TNewUndo;    //массив для отмены в редакторе анимок
    CountOfNewUndo:integer;//кол-во элементов этого массива
    tcX,tcY:GLfloat;    //к-ты центра текстурных вершин
    ExternalBuffer:TBuffer;//"внешний" буфер обмена
    FrameBuffer:array of TController;//буфер обмена для кадров
    IsModified:boolean; //true, если модель модифицирована
    AnimPanel:TAnimPanel;    
//Вспомогательная: применяется для сортировки списка
function cmpItems(Item1, Item2:pointer):integer;
//Вспомогательная: добавляет массив lstsrc к массиву lstdest,
//сортируя получившийся массив по возрастанию ID
//и удаляя все повторения
procedure AddTFace(var lstsrc,lstdest:TFace;lensrc,lendest:integer);
//Вспомогательная: удаляет из массива lstdest все элементы,
//встречающиеся в массиве lstsrc
//Полученный массив сортируется
procedure SubTFace(var lstsrc,lstdest:TFace;lensrc,lendest:integer);
//Возвращает кол-во поверхностей, в которых выделена
//хотя бы одна вершина
function GetCountOfSelGeosets:integer;
//Возвращает номер первой поверхности,
//содержащей хотя бы 1 выделенную вершину
function GetIDOfSelGeoset:integer;
//Возвращает кол-во вершин текстуры
function GetSumCountOfTexVertices:integer;
//Возвращает кол-во выделенных вершин текстуры
function GetSumCountOfSelTexVertices:integer;
//Возвращает кол-во вершин во всех выделенных поверхностях
function GetSumCountOfVertices:integer;
//Возвращает суммарное кол-во выделенных вершин
function GetSumCountOfSelVertices:integer;
//Возвращает суммарное кол-во скрытых вершин
function GetSumCountOfHideVertices:integer;
//Возвращает суммарное кол-во треугольников:
function GetSumCountOfTriangles:integer;
//Возвращает суммарное кол-во дочерних вершин кости
function GetSumCountOfChildVertices:integer;
//Возвращает true, если хоть одна из выделенных вершин
//присутствует в списке модификаторов нормалей
function IsSmoothVerticesInSelection:boolean;
//Ищет указанный набор костей (bns) в
//группе grp. Если находит, возвращает его ID.
//Если нет - добавляет набор в группу и
//всё равно возвращает ID.
function GetBoneGroupID(var bns:TFace;var grp:TGroup):integer;
//Возвращает длину (в кадрах) буфера, куда кадры попадают по Ctrl+C.
//Если буфер пуст, возвращается 0
function GetLenOfFrameBuffer:integer;
//Используя координаты вершин текущего Geoset'а
//рассчитывает их координаты на плоскости,
//заполняя массив Vertices2D;
//num - номер поверхности
//ClientHeight - размер (высота) области вывода
//! Перед ее вызовом нужно установить контекст wgl
procedure CalcVertex2D(ClientHeight:integer);
//То же, но для к-т текстуры: массив TexVertices2D
procedure CalcTexVertex2D(ClientHeight:integer);
//То же, но для различных скелетных объектов
procedure CalcObjs2D(ClientHeight:integer);
//Создаёт список объектов, достаточно близких к курсору,
//на основе Objs2D.
//Сам список заносится в SelObj.
//Объекты списка сортируются по убыванию Z.
//В IDInComps заносится 0.
//Если нет подходящих объектов, CountOfCompObjs=0.
procedure MakeCompetitorObjsList(x,y:integer);
//Возвращает true, если вершина v лежит внутри треугольника
//vt1-vt3
function IsVertexInTriangle(v,vt1,vt2,vt3:TVertex):boolean;
//Сдвигает массивы Undo, подготавливает их для записи.
//Возвращает текущую свободную позицию [вспомогатльная,
//для эмуляции SaveUndo некоторыми процедурами].
function ShearUndo:integer;
//Вспомогательная: работает с "новым" массивом отмен
function SaveNewUndo(uAction,param:integer):integer;
//Запомнить действие. Action - тип действия (константа)
procedure SaveUndo(action:integer);
//То же самое - для редактора текстур
procedure TexSaveUndo(action:integer);
//Осуществляет переворачивание текстурной карты
procedure CoupTextureMap;
//То же - для редактора анимаций
procedure AnimSaveUndo(action:cardinal;param:integer);
//Рассчитать центр текстурных к-т и занести его в tcX,tcY
//При этом используется CurrentCoordID
procedure FindTexCoordCenter;
//Удалить вершину. geonum - номер поверхности
procedure DeleteVertex(geonum,NumOfVertex:integer);
//Вызывается после удаления всей группы вершин,
//приводит массивы в порядок после удаления
procedure FinalizeDeleting(geonum:integer);
//Удаляет всю поверхность+ее анимацию видимости
procedure DeleteGeoset(geonum:integer);
//Удаляет текстуру с указанным ID.
//Все остальные текстуры, соотв., сдвигаются.
//Правятся id в Источниках и материалах.
procedure DeleteTexture(id:integer);
//Удаляет повторяющиеся текстуры, производя коррекцию
//TextureID в материалах и ИЧ
procedure DeleteDublicateTextures;
//Сравнение поверхностей. Возвращает true, если
//вершины поверхностей мало отличаются друг от друга.
function CompareGeosets(geoID1,geoID2:integer):boolean;
//Строит список полностью выделенных треугольников,
//заполняя массив SelFaces
procedure FindSelectedFaces(geonum:integer);
//Строит список полностью выделенных треугольников,
//заполняя массив SelFaces ИХ НОМЕРАМИ В Faces
procedure FindNumbersSelFaces(geonum:integer);
//Добавляет к поверхности новые точки, удваивая вершины
//из SelFaces. Номера новых вершин накапливаются в NewVertices
procedure AddVertices(geonum:integer);
//Осуществляет создание граней экструзии
//на основании SelFaces и NewVertices
procedure Extrude(geonum:integer);
//Возвращает true, если указанная вершина не используется
//ни в одном из треугольников поверхности
function IsVertexFree(GeoID,VertID:integer):boolean;
//Определяет, скрыта ли данная вершина:
function IsVertexHide(geoID,num:integer):boolean;
//Удаляет выделенные треугольники, сдвигая массив Faces.
//Одновременно заполняются массивы Undo для отмены
function DeleteTriangles:boolean;
//Копирует выделенный кусок поверхности
//в специальный буфер (ClpBrd).
procedure CopyToInternalBuffer;
//Вставляет в текущую поверхность кусок из внутреннего буфера
procedure PasteFromInternalBuffer;
//Частично очищает буфер, оставляя там только кусок поверхности
procedure ResetBuffer;
//Копирует выделенный кусок поверхности из
//InternalBuffer+CurrentGeoset в файл подкачки (проецирование)
//вместе с соответствующими текстурами/материалом
procedure CopyToExternalBuffer;
//Вставляет новую поверхность с использованием внешнего буфера
//и точки прикрепления
procedure PasteFromExternalBuffer;
//Вставляет новую поверхность из 3DS-файла
procedure Import3DS(fname:string);
//Обращает нормали. Масcивы SelFaces в поверхностях
//должны быть заполнены заранее вызовом FindSelectedFaces 
procedure SwapNormals;
//Выделяет объект с указанным ID:
//заполняет структуру SelObj за исключением CompetitorObjs
procedure SelectSkelObj(ID:integer);
//Рекурсивная процедура: находит всех потомков указанного
//объекта, помещая их ID в соотв. список
procedure FindChilds(id:integer);
//Заполняет список дочерних вершин выделенной кости
//и ЕЁ дочерних костей. 
//Вершины ищутся в каждой поверхности
//Используются данные SelObj.
//Массив ChildVertices заполняется номерами вершин.
//Масив DirectChildVertices заполняется номерами вершин,
//связанных непосредственно с выделенной костью.
procedure FindChildVertices;
//Создать новый ключевой кадр с указанным номером и значением
//procedure CreateKeyFrame(ContNum:integer;it:TContItem);
//Создает новый контроллер и возвращает его номер
function CreateController(ObjID:integer;it:TContItem;CngType:integer):integer;
//Преобразует контроллер к линейному типу
procedure TransformController(cnum:integer);
//Преобразует тип контроллера.
//Предварительно сохраняет данные контроллера для отмены
procedure TranslateControllerType(ContNum,NewType:integer;var SaveC:TController);
//Вставляет данные из буфера, начиная с текущего кадра и до конца
//true - если что-то вставлено.
//Если IsUseFilter=true, то при вставке применяется фильтр
//(выделение кадров только активного контроллера)
//Если IsBlend=true, то вместо вставки происходит смешивание
//(блендинг) с коэффициентом BlendF
function PasteFramesFromBuffer(CurFrame,MaxFrame:integer;
                               IsUseFilter:boolean;IsBlend:boolean;
                               BlendF:GlFloat):boolean;
//Делает полный слепок текущей позиции и копирует этот
//единственный кадр в буфер обмена
procedure CopyCurFrameToBuffer;
//Копирует набор кадров из контроллера cSrc (sStart,sEnd)
//в контроллер cDest (dStart,dEnd).
//То, что выходит за границы dEnd, не копируется.
//Если типы контроллеров не совпадают, происходит
//конвертирование кадров в тип (cDest.ContType).
//Возвр. false, если ни одного кадра не скопировано
//Если dStart=sStart, кадры копируются "как есть", без
//пересчёта номеров
function CopyFrames(var cSrc,cDest:TController;
                    sStart,sEnd,dStart,dEnd:integer):boolean;
//Производит смешение (блендинг) кадров из cSrc и cDest
//с коэффициентом cBlend
//Используется такая схема (A, B, C - временные переменные):
//1. Кусок sStart-sDest копируется в A
//2. Кусок dStart-dEnd копируется в B
//3. A и B смешиваются (с увеличением числа КК) в C.
//4. C копируется в sStart-sEnd.
function BlendFrames(var cSrc,cDest:TController;
                    sStart,sEnd,dStart,dEnd:integer;cBlend:GLFloat):boolean;
//Удаление всех КК из указанного диапазона.
//Массивы Undo модифицируются ей автоматически -
//нет надобности выполнять SaveUndo.
procedure DeleteKeyFrames(FrStart,FrEnd:integer);
//Удаление меток событий EventObjects из указанного диапазона
//Автоматически модифицируется NewUndo,
//куда и записываются удалённые фрагменты
procedure DeleteEventStamps(FrStart,FrEnd:integer);
//Дополняет анимационный набор недостающими анимациями
//procedure SupplySet(s:string);
//Сдвигает кадры (для добавления/удаления кадров)
procedure ShearFrames(CurFrame,UsingGlobalSeq,Count:integer);
//Добавляет в контроллер Cont элемент NewFrame,
//вставляя его в нужную позицию (по порядку номеров кадров)
//Если таковой кадр уже есть, его данные замещаются.
procedure InsertFrame(var Cont:TController;var NewFrame:TContItem);
//Обёртка для InsertFrame: добавляет в контроллер ContNum
//элемент NewFrame.
procedure AddKeyFrame(ContNum:integer;var NewFrame:TContItem);
//Удаляет фрагмент контроллера cont.
procedure DeleteFrames(var cont:TController;FrStart,FrEnd:integer);
//Удаляет весь контроллер с указанным ID.
//Суть удаления заключается в удалении всех КК (items:=nil)
//и установке IsStaticXX в true.
//Возвращает тип+номер объекта, контроллер которого удалён
function DeleteAllController(ID:integer):cardinal;
//Восстанавливает из TUndo секцию текстурных анимаций
//(если она удалялась) и TVertexAnimID в слоях.
//Используется для отмены удаления КК.
procedure RestoreTextureAnims(var u:TUndo);
//Восстанавливает КК контроллеров (и, возможно,
//целые контроллеры) из TUndo.
//Вторая стадия отмены удаления КК.
//Если QuickRestore=true, отмена осуществляется ускоренным способом,
//при котором контроллеры не копируются покадрово
procedure RestoreControllers(var u:TUndo;QuickRestore:boolean);
//Используется сразу после открытия WoW-модели.
//Изменяет анимации так, чтобы КК были в начале
//и в конце каждой анимации
procedure NormalizeWoWAnimations;
//Создаёт/удаляет анимацию видимости
//gan - ID анимации видимости для удаления или
//позиция для добавления новой
//geoID - используется в случае создания новой анимации:
//это - её поле GeosetID.
//ARFlag - если +1, анимация создаётся. Иначе - удаляется.
procedure ARGeosetAnim(gan,geoID,ARFlag:integer);
//Создаёт полный комплект анимаций видимости, если это
//нужно. Одновременно в Undo запоминается факт создания
//новых анимаций и их ID.
procedure CreateGeosetAnimsIfNeed;
//Проверяет указанный материал на ConstantColor.
//Предназначена для работы в цикле.
//Устанавливает ConstantColor, проверяет все анимации видимости
//Устанавливает там цвет в случае его отсутствия для всех
//поверхностей, использующих данный материал.
procedure TestMaterialColors(MatID:integer);
//Сохраняет данные указанного кадра контроллера.
//Может вызываться в цикле для нескольких контроллеров
//Перед первым вызовом нужно использовать AnimSaveUndo(uChangeFrame,0);
procedure SaveContFrame(ContID,Frame:integer);
//Изменяет имя объекта с указанным ID на NewName
//поля в cb_bonelist и lv_obj нужно изменить отдельно
procedure SetObjectName(id:integer;NewName:string);
//Осуществляет инкремент/декремент (в зависимости от флага IsInc)
//Всех ID объектов с ID>=указанного.
//Вставить новый объект нужно отдельно
procedure IncDecObjectIDs(id:integer;IsInc:boolean);
//Производит сдвиг компонент массива PivotPoints так,
//чтобы освободить место под объект ObjectID
//Даже если ID находится за пределами массива,
//процедура всё равно работает, просто увеличивая массив
procedure ReservePivotSpace(id:integer);
//Удаляет повторяющиеся матрицы костей в указанной поверхности.
//VertexGroups изменяются автоматически
procedure ReduceMatrices(GeoId:integer);
//Производит удаление скелетного объекта (полностью).
procedure DeleteSkelObj(id:integer);
//Производит удаление костей/помощников,
//к которым ничего не прикреплено
procedure DeleteFreeBones;
//Производит поиск "нулевой" кости
//В зависимости от результата устанавливает NullBone
procedure FindNullBone;
//Создаёт нулевую кость (сдвигая прочие объекты скелета)
procedure CreateNullBone;
//Удаляет "нулевую" кость, если она нигде не используется
procedure DeleteNullBone;
//Производит связывание объектов (изменяет при необходимости
//порядок их следования, ID, матрицы и VertexGroup)
procedure AttachObject;
//Присоединяет вершины к указанной кости.
//Если выделен помощник, он конвертируется в кость
procedure AttachVertices;
//Присоединяет вершины к указанной кости, отсоединя их
//от всех остальных. Тоже удаляет "нулевую" кость, если нужно
//Неиспользуемые кости конвертируются в помощники
procedure ReAttachVertices;
//Отсоединяет выделенные вершины от выделенной кости
procedure DetachVertices;
//Проводит (если нужно) сортировку анимаций - так,
//чтобы они расположились по возрастанию IntervalStart.
//Если сортировка не нужна - возвращает true
function SortSequences:boolean;
//=========================================================
implementation
//Вспомогательная: добавляет массив lstsrc к массиву lstdest,
//сортируя получившийся массив по возрастанию ID
//и удаляя все повторения
procedure AddTFace(var lstsrc,lstdest:TFace;lensrc,lendest:integer);
Var lst:TList;i:integer;
Begin
 PushFunction(274);
 lst:=TList.Create;
 for i:=0 to lendest-1 do lst.Add(pointer(lstdest[i]));
 for i:=0 to lensrc-1 do if lst.IndexOf(pointer(lstsrc[i]))<0
 then lst.Add(pointer(lstsrc[i]));
 lst.Sort(cmpItems);
 SetLength(lstdest,lst.Count);
 for i:=0 to lst.Count-1 do lstdest[i]:=integer(lst.Items[i]);
 lst.Free;
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательная: удаляет из массива lstdest все элементы,
//встречающиеся в массиве lstsrc
//Полученный массив сортируется
procedure SubTFace(var lstsrc,lstdest:TFace;lensrc,lendest:integer);
Var lst:TList;i:integer;
Begin
 PushFunction(275);
 lst:=TList.Create;
 for i:=0 to lendest-1 do lst.Add(pointer(lstdest[i]));
 for i:=0 to lensrc-1 do lst.Remove(pointer(lstsrc[i]));
 lst.Sort(cmpItems);
 SetLength(lstdest,lst.Count);
 for i:=0 to lst.Count-1 do lstdest[i]:=integer(lst.Items[i]);
 lst.Free;
 PopFunction;
End;
//---------------------------------------------------------
//Возвращает кол-во поверхностей, в которых выделена
//хотя бы одна вершина
function GetCountOfSelGeosets:integer;
Var i:integer;
Begin
 PushFunction(276);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do
  if (GeoObjs[i].IsSelected) and (GeoObjs[i].VertexCount>0) then inc(Result);
 PopFunction;
End;
//---------------------------------------------------------
//Возвращает ID первой поверхности,
//содержащей хотя бы 1 выделенную вершину
function GetIDOfSelGeoset:integer;
Var i:integer;
Begin
 PushFunction(277);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  Result:=0;
  if not IsSelected then continue;
  if VertexCount>0 then begin
   Result:=i;
   PopFunction;
   exit;
  end;//of if
 end;
 PopFunction;
End;

//Возвращает кол-во вершин текстуры
function GetSumCountOfTexVertices:integer;
Var i:integer;
Begin
 PushFunction(278);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  if not IsSelected then continue;
  Result:=Result+TexVertexCount;
 end;
 PopFunction;
End;
//Возвращает кол-во выделенных вершин текстуры
function GetSumCountOfSelTexVertices:integer;
Var i:integer;
Begin
 PushFunction(279);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do begin
  if not IsSelected then continue;
  Result:=Result+TexSelVertexCount;
 end;
 PopFunction;
End;

//Возвращает кол-во вершин во всех выделенных поверхностях
function GetSumCountOfVertices:integer;
Var i:integer;
Begin
 PushFunction(280);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do with geosets[i],geoobjs[i] do
  if IsSelected then Result:=Result+CountOfVertices;
 PopFunction;
End;

//Возвращает суммарное кол-во выделенных вершин
function GetSumCountOfSelVertices:integer;
Var i:integer;
Begin
 PushFunction(281);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do
  if IsSelected then Result:=Result+VertexCount;
 PopFunction;
End;

//Возвращает суммарное кол-во скрытых вершин
function GetSumCountOfHideVertices:integer;
Var i:integer;
Begin
 PushFunction(282);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do with geoobjs[i] do
  if IsSelected then Result:=Result+HideVertexCount;
 PopFunction;
End;

//Возвращает суммарное кол-во треугольников:
function GetSumCountOfTriangles:integer;
Var i,ii:integer;
Begin
 PushFunction(283);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do with GeoObjs[i] do
  if IsSelected then begin
   for ii:=0 to High(Geosets[i].Faces) do
    Result:=Result+length(Geosets[i].Faces[ii]);
 end;//of with/for i
 Result:=Result div 3;
 PopFunction;
End;
//----------------------------------------------------------
//Возвращает суммарное кол-во дочерних вершин кости
function GetSumCountOfChildVertices:integer;
Var i:integer;
Begin
 PushFunction(284);
 Result:=0;
 for i:=0 to CountOfGeosets-1 do if Geoobjs[i].IsSelected
 then Result:=Result+Geosets[i].CountOfDirectCV;
 PopFunction;
End;
//----------------------------------------------------------
//Возвращает true, если хоть одна из выделенных вершин
//присутствует в списке модификаторов нормалей
function IsSmoothVerticesInSelection:boolean;
Var i,ii,j,jj,id:integer;
Begin
 PushFunction(381);
 Result:=false;
 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected
 then for i:=0 to GeoObjs[j].VertexCount-1 do begin
  id:=GeoObjs[j].VertexList[i]-1;
  for ii:=0 to COMidNormals-1 do for jj:=0 to High(MidNormals[ii])
  do if (MidNormals[ii,jj].GeoID=j) and (MidNormals[ii,jj].VertID=id)
  then begin
   Result:=true;
   PopFunction;
   exit;
  end;//of if/for jj/ii

  for ii:=0 to COConstNormals-1
  do if (ConstNormals[ii].GeoID=j) and (ConstNormals[ii].VertID=id) then begin
   Result:=true;
   PopFunction;
   exit;
  end;//of if/for ii
 end;//of for j

 PopFunction;
End;
//----------------------------------------------------------
//Ищет указанный набор костей (bns) в
//группе grp. Если находит, возвращает его ID.
//Если нет - добавляет набор в группу и
//всё равно возвращает ID.
function GetBoneGroupID(var bns:TFace;var grp:TGroup):integer;
Var i,ii,j,len,len2,ID:integer;fnd:boolean;
Begin
 PushFunction(285);
 len:=High(grp);
 len2:=High(bns);
 ID:=-1;                          //пока не найдено
 //Большой цикл поиска
 for i:=0 to len do begin         //цикл по наборам
  //1. Сравниваем длины масивов
  if High(grp[i])<>len2 then continue;
  //2. Ищем каждую из костей в списке
  fnd:=false;
  for ii:=0 to len2 do begin      //цикл по костям bns
   fnd:=false;
   for j:=0 to High(grp[i]) do if grp[i,j]=bns[ii] then begin
    fnd:=true;
    break;
   end;//of if/for j
   if fnd=false then break;       //одна из костей не найдена
  end;//of for ii
  //Найдено!
  if fnd=true then begin
   ID:=i;
   break;
  end;//of if
 end;//of for i

 //Смотрим, что получилось в итоге
 if ID>=0 then begin              //такой набор уже есть
  Result:=ID;
  PopFunction;
  exit;
 end;//of if

 //Такого набора нет - добавляем
 SetLength(grp,length(grp)+1);
 SetLength(grp[High(grp)],length(bns));
 for i:=0 to High(bns) do grp[High(grp),i]:=bns[i];
 Result:=High(grp);
 PopFunction;
End;
//----------------------------------------------------------
//Возвращает длину (в кадрах) буфера, куда кадры попадают по Ctrl+C.
//Если буфер пуст, возвращается 0
function GetLenOfFrameBuffer:integer;
Var i:integer;
Begin
 PushFunction(286);
 Result:=0;
 for i:=0 to High(FrameBuffer)
 do if FrameBuffer[i].Items[High(FrameBuffer[i].Items)].Frame>Result then
       Result:=FrameBuffer[i].Items[High(FrameBuffer[i].Items)].Frame;
 PopFunction;
End;
//----------------------------------------------------------
//Используя координаты вершин текущего Geoset'а
//рассчитывает их координаты на плоскости,
//заполняя массив Vertices2D;
//num - номер поверхности
//ClientHeight - размер (высота) области вывода
//! Перед ее вызовом нужно установить контекст wgl
procedure CalcVertex2D(ClientHeight:integer);
Var Viewport:array[0..3] of GLfloat;
    mvMatrix,ProjMatrix:array[0..15] of GLdouble;
//    wx,wy,wz:GLDouble;
    j,i:integer;
Begin for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
 PushFunction(287);
 //1. Читаем матрицы
 glGetIntegerv(GL_VIEWPORT,@Viewport);
 glGetDoublev(GL_MODELVIEW_MATRIX,@mvMatrix);
 glGetDoublev(GL_PROJECTION_MATRIX,@ProjMatrix);
 //2. Задать размер массива
 SetLength(Vertices2D,Geosets[j].CountOfVertices);
 //3. Начать расчет для всех вершин
 for i:=0 to Geosets[j].CountOfVertices-1 do begin
  gluProject(Geosets[j].Vertices[i,1],
             -Geosets[j].Vertices[i,2],
             Geosets[j].Vertices[i,3],
             @mvMatrix,@ProjMatrix,@ViewPort,
             Vertices2D[i].x,Vertices2D[i].y,Vertices2D[i].z);
  Vertices2D[i].y:=ClientHeight-Vertices2D[i].y;//пересчет
 end;//of for
 //Расчет окончен :)
 PopFunction;
end;End;
//---------------------------------------------------------
//Сдвигает массивы Undo, подготавливает их для записи.
//Возвращает текущую свободную позицию [вспомогатльная,
//для эмуляции SaveUndo некоторыми процедурами].
function ShearUndo:integer;
Var i,j:integer;
procedure ShearNewUndo;
Var i:integer;
Begin
 PushFunction(288);
 if CountOfNewUndo>0 then NewUndo[0].Free;
 for i:=1 to CountOfNewUndo-1 do NewUndo[i-1]:=NewUndo[i];
 dec(CountOfNewUndo);
 SetLength(NewUndo,CountOfNewUndo);
 PopFunction;
End;
Begin
 PushFunction(289);
 //0. Ищем пустое место в списке отмен
 if CountOfUndo<10 then begin     //есть пустые места
  Result:=CountOfUndo+1;
  inc(CountOfUndo);               //теперь их станет меньше
 end else begin
  //Если нужно, сдвинуть NewUndo-массивы
  if Undo[1].Status1=uUseNewUndo then begin
   //сдвинуть один раз
   ShearNewUndo;
   //сдвигать до тех пор, пока не встретится (-1) или
   //не закончится массив
   while (CountOfNewUndo>0) and (NewUndo[0].Prev>=0) do ShearNewUndo;
  end;//of if
  //Сдвиг Undo-массивов
  for i:=2 to 10 do Undo[i-1]:=Undo[i];//сдвиг массивов
  for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
   for i:=2 to 10 do Undo[i-1]:=Undo[i];//сдвиг массивов
   FillChar(Undo[10],SizeOf(TUndo),0);   
  end;//of for j
  Result:=10;
 end;//of if
 //на всякий случай
 FillChar(Undo[Result],SizeOf(TUndo),0);
 PopFunction;
End;
//---------------------------------------------------------
//Запомнить действие. Action - тип действия (константа)
procedure SaveUndo(action:integer);
Var Cur,j,i,ii,cnt:integer;
Begin
 PushFunction(290);
 IsModified:=true;//модель модифицирована
 Cur:=ShearUndo;
case action of
 uSelect:begin                    //выделение точки
  Undo[Cur].Status1:=uSelect;     //сохранить тип действия
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   Undo[Cur].Status1:=uSelect;     //сохранить тип действия
   Undo[Cur].Status2:=VertexCount; //кол-во вершин
   SetLength(Undo[Cur].Data1,VertexCount);//размер данных
   for i:=0 to VertexCount-1 do Undo[Cur].Data1[i]:=VertexList[i];
  end;//of for j
 end;//of uSelect

 uVertexTrans:begin               //изменение к-т вершин
  Undo[Cur].Status1:=uVertexTrans;//сохранить тип действия
  for j:=0 to CountOfGeosets-1 do with geosets[j],geoobjs[j] do begin
   Undo[Cur].Status1:=uVertexTrans;//сохранить тип действия
   Undo[Cur].Status2:=VertexCount; //кол-во вершин
   SetLength(Undo[Cur].Data1,VertexCount);//размер массива
   SetLength(Undo[Cur].Data2,VertexCount);
   SetLength(Undo[Cur].Data3,VertexCount);
   SetLength(Undo[Cur].iData,VertexCount);
   for i:=0 to VertexCount-1 do begin
    Undo[Cur].data1[i]:=Vertices[VertexList[i]-1,1];
    Undo[Cur].data2[i]:=Vertices[VertexList[i]-1,2];
    Undo[Cur].data3[i]:=Vertices[VertexList[i]-1,3];
    Undo[Cur].idata[i]:=VertexList[i];
   end;
  end;//of for j
 end;//of uVertexTrans

 //удаление вершин
 uVertexDelete:begin
  Undo[Cur].Status1:=uVertexDelete;//общий статус
  SaveNewUndo(uSmoothGroups,0);   //сохранить группы сглаживания
  for j:=0 to CountOfGeosets-1 do with geosets[j],geoobjs[j] do begin
   Undo[Cur].Status1:=uVertexDelete;
   Undo[Cur].Status2:=CountOfVertices;
   SetLength(Undo[Cur].Vertices,CountOfVertices);
   SetLength(Undo[Cur].Normals,CountOfVertices);
   SetLength(Undo[Cur].Crds,CountOfCoords);
   for i:=0 to CountOfCoords-1 do begin
    SetLength(Undo[Cur].Crds[i].TVertices,CountOfVertices);
    Undo[Cur].Crds[i].CountOfTVertices:=CountOfVertices;
   end;//of for i
   SetLength(Undo[Cur].VertexGroup,CountOfVertices);
   SetLength(Undo[Cur].Faces,length(Faces));
   SetLength(Undo[Cur].Groups,length(Groups));
   SetLength(Undo[Cur].VertexList,length(VertexList));
   //копируем массивы поверхности
   for i:=0 to CountOfVertices-1 do for ii:=1 to 3 do begin
    Undo[Cur].Vertices[i,ii]:=Vertices[i,ii];
    Undo[Cur].Normals[i,ii]:=Normals[i,ii];
   end;//of for ii/i
   for i:=0 to CountOfCoords-1 do for ii:=0 to CountOfVertices-1 do begin
    Undo[Cur].Crds[i].TVertices[ii]:=Crds[i].TVertices[ii];
   end;//of for
   for i:=0 to CountOfVertices-1 do Undo[Cur].VertexGroup[i]:=VertexGroup[i];
   for i:=0 to Length(Faces)-1 do begin
    SetLength(Undo[Cur].Faces[i],length(Faces[i]));
    for ii:=0 to Length(Faces[i])-1 do Undo[Cur].Faces[i,ii]:=Faces[i,ii];
   end;//of for
   for i:=0 to Length(Groups)-1 do begin
    SetLength(Undo[Cur].Groups[i],length(Groups[i]));
    for ii:=0 to Length(Groups[i])-1 do Undo[Cur].Groups[i,ii]:=Groups[i,ii];
   end;//of for ii/i
   for i:=0 to length(VertexList)-1 do Undo[Cur].VertexList[i]:=VertexList[i];
  end;//of with(2)/for 
 end;

 uCreateTriangle:begin            //создан треугольник
  Undo[Cur].Status1:=uCreateTriangle;
  for j:=0 to CountOfGeosets-1 do with geosets[j],geoobjs[j] do begin
   Undo[Cur].Status1:=uCreateTriangle;
   i:=length(Faces);
   ii:=length(Faces[i-1]);
   Undo[Cur].Status2:=ii;
  end;//of for j
 end;//of uCreateTriangle

 uCreateGeoset:begin              //создание поверхности (вставка)
  Undo[Cur].Status1:=uCreateGeoset;   //тип действия
  Undo[Cur].Status2:=CountOfGeosets;  //номер текущей поверхности
  //Сохраняем список выделенного
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   SetLength(Undo[Cur].VertexList,VertexCount);
   for i:=0 to VertexCount-1 do Undo[Cur].VertexList[i]:=VertexList[i];
  end;//of for j 
  //Сохранение кол-ва текстур
  SetLength(Undo[Cur].idata,2);
  Undo[Cur].idata[0]:=CountOfTextures;
  Undo[Cur].idata[1]:=CountOfMaterials;
 end;//of uCreateGeoset

 uGeosetDelete:begin              //удаление поверхности
  Undo[Cur].Status1:=uGeosetDelete;//тип действия
  SaveNewUndo(uSmoothGroups,0);   //сохранить группы сглаживания
  SetLength(Undo[Cur].idata,1);
  Undo[Cur].idata[0]:=0;          //пока 0
  for j:=CountOfGeosets-1 downto 0 do if geoobjs[j].IsDelete then begin
   GeoObjs[j].IsDelete:=false;
   //Место для сохранения
   inc(CountOfDelObjs);
   inc(Undo[Cur].idata[0]);       //кол-во удалённых поверхностей
   SetLength(DelGeoObjs,CountOfDelObjs);
   with Geosets[j],DelGeoObjs[CountOfDelObjs-1] do begin
    FillGeoObj(GeoObjs[j],DelGeoObjs[CountOfDelObjs-1]);
    Undo[Cur].Status1:=uGeosetDelete;//тип действия
    Undo[Cur].Status2:=j;//номер текущей поверхности
    Undo[Cur].Sequence.IntervalStart:=CountOfCoords;//кол-во текстур. плоскостей
    SetLength(Undo[Cur].idata,1);
    Undo[Cur].idata[0]:=-1;
    //Поиск GeosetAnim с данной поверхностью
    for i:=0 to CountOfGeosetAnims-1 do
     if GeosetAnims[i].GeosetID=j then begin //найдено!
      Undo[Cur].idata[0]:=i;        //сохранить номер анимации
      Undo[Cur].GeosetAnim:=GeosetAnims[i];//сохранить саму анимацию
      break;
    end;//of if/for
    //Сохранение параметров поверхности
//   with Geosets[CurrentGeosetNum-1] do begin
    Undo[Cur].Ext.MinimumExtent:=MinimumExtent;
    Undo[Cur].Ext.MaximumExtent:=MaximumExtent;
    Undo[Cur].Ext.BoundsRadius:=BoundsRadius;
    //копируем границы анимаций
    SetLength(Undo[Cur].Anims,CountOfAnims);
    for i:=0 to CountOfAnims-1 do Undo[Cur].Anims[i]:=Anims[i];
    Undo[Cur].Unselectable:=Unselectable;
    Undo[Cur].MatID:=MaterialID;
    Undo[Cur].SelGroup:=SelectionGroup;
    Undo[Cur].HierID:=HierID;
//   end;//of with
    //Сохраняем номера костей и помощников, которые будут изменены
    cnt:=0;
    for i:=0 to CountOfBones-1 do
     if (Bones[i].GeosetID=j) or
        (Bones[i].GeosetAnimID=Undo[Cur].idata[0]) then begin
      inc(cnt);
      SetLength(Undo[Cur].Vertices,cnt);//выделить место
      Undo[Cur].Vertices[cnt-1,1]:=Bones[i].GeosetID;
      Undo[Cur].Vertices[cnt-1,2]:=Bones[i].GeosetAnimID;
      Undo[Cur].Vertices[cnt-1,3]:=i;
    end;//of if/for
    cnt:=0;Undo[Cur].Normals:=nil;
    for i:=0 to CountOfHelpers-1 do
     if (Helpers[i].GeosetID=j) or
        (Helpers[i].GeosetAnimID=Undo[Cur].idata[0]) then begin
      inc(cnt);
      SetLength(Undo[Cur].Normals,cnt);//выделить место
      Undo[Cur].Normals[cnt-1,1]:=Helpers[i].GeosetID;
      Undo[Cur].Normals[cnt-1,2]:=Helpers[i].GeosetAnimID;
      Undo[Cur].Normals[cnt-1,3]:=i;
    end;//of if/for
  end;end;//of with(2)/for j
 end;//of uGeosetDelete

 uUncouple,uTexUncouple:begin     //разъединение вершин
  Undo[Cur].Status1:=action;   //тип действия
  for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
   Undo[Cur].Status1:=action;
   if (not IsSelected) or (VertexCount=0) then begin
    Undo[Cur].Unselectable:=true;
    Continue;
   end else Undo[Cur].Unselectable:=false;//of if
   //Теперь сохраняем детали:
   //a. Координаты выделенных вершин
   SetLength(Undo[Cur].Vertices,VertexCount);
   SetLength(Undo[Cur].VertexList,VertexCount);
   SetLength(Undo[Cur].Crds,Geosets[j].CountOfCoords);
   for i:=0 to VertexCount-1 do begin
    Undo[Cur].VertexList[i]:=VertexList[i]-1;
    Undo[Cur].Vertices[i]:=Geosets[j].Vertices[VertexList[i]-1];
   end;//of for i
   for ii:=0 to Geosets[j].CountOfCoords-1 do begin
    SetLength(Undo[Cur].Crds[ii].TVertices,VertexCount);
    for i:=0 to VertexCount-1 do begin
     Undo[Cur].Crds[ii].TVertices[i]:=
         Geosets[j].Crds[ii].TVertices[VertexList[i]-1];
    end;//of for i
   end;//of for ii
   //b. Номера вершин в разворотах
   SetLength(Undo[Cur].Faces,1);
   SetLength(Undo[Cur].Faces[0],length(Geosets[j].Faces[0]));
   for i:=0 to length(Geosets[j].Faces[0])-1 do
            Undo[Cur].Faces[0,i]:=Geosets[j].Faces[0,i];
   //c. Кол-во вершин (общее)
   Undo[Cur].MatID:=Geosets[j].CountOfVertices;
   //d. Сохранить список TexSelVertices
   SetLength(Undo[Cur].idata,TexSelVertexCount);
   for i:=0 to TexSelVertexCount-1 do Undo[Cur].idata[i]:=TexSelVertexList[i];
  end;//of for j
 end;//of uUncouple

 uSwapNormals:begin               //обратить нормали
  Undo[Cur].Status1:=uSwapNormals;
  for j:=0 to CountOfGeosets-1 do begin
   FindNumbersSelFaces(j+1);
   SetLength(GeoObjs[j].Undo[Cur].Faces,1);
   GeoObjs[j].Undo[Cur].Faces[0]:=GeoObjs[j].SelFaces;
  end;//of for j
 end;//of uSwapNormals

 uSmoothGroups:begin              //сохранить группы сглаживания
  Undo[Cur].Status1:=uSmoothGroups;
  SaveNewUndo(uSmoothGroups,0);
 end;//of uSmoothGroups
end;//of case
PopFunction;
End;
//---------------------------------------------------------
//Рассчитать центр текстурных к-т и занести его в tcX,tcY
//При этом используется CurrentCoordID
procedure FindTexCoordCenter;
Var i,j,SumVertexCount:integer;MidX,MidY:GLfloat;
Begin
 PushFunction(291);
 MidX:=0;MidY:=0;SumVertexCount:=0;
 for j:=0 to CountOfGeosets-1 do with geosets[j],geoobjs[j] do begin
  SumVertexCount:=SumVertexCount+TexSelVertexCount;
  for i:=0 to TexSelVertexCount-1 do begin
   MidX:=MidX+Crds[CurrentCoordID].TVertices[TexSelVertexList[i]-1,1];
   MidY:=MidY+Crds[CurrentCoordID].TVertices[TexSelVertexList[i]-1,2];
  end;//of for
 end;//of for j
 if SumVertexCount=0 then begin      //нет вершин
  tcX:=0;tcY:=0;
  PopFunction;
  exit;
 end;//of if
 MidX:=MidX/SumVertexCount;
 MidY:=MidY/SumVertexCount;
 tcX:=MidX;tcY:=MidY;
 PopFunction;
End;
//---------------------------------------------------------
//Удалить вершину. geonum - номер поверхности
procedure DeleteVertex(geonum,NumOfVertex:integer);
Var i,ii,j,Sum,counter:integer; n:TMidNormal;
Begin with Geosets[geonum-1],geoobjs[geonum-1] do begin
 PushFunction(292);
 //проверка: остались ли еще вершины и не последняя ли это поверхность
 Sum:=0;
 for j:=0 to CountOfGeosets-1 do with geosets[j] do Sum:=Sum+CountOfVertices;
 if (Sum<=1) then begin
  MessageBox(0,'Осталась последняя поверхность.'#13#10+
               'Ее удаление невозможно.','ВНИМАНИЕ!',
               MB_ICONEXCLAMATION or MB_APPLMODAL);
  PopFunction;
  exit;
 end;//of if}
 //1. Удалить вершину из списков.
 for i:=NumOfVertex-1 to Geosets[geonum-1].CountOfVertices-2 do begin
  //Массив вершин
  Vertices[i,1]:=Vertices[i+1,1];
  Vertices[i,2]:=Vertices[i+1,2];
  Vertices[i,3]:=Vertices[i+1,3];
  //Массив нормалей
  Normals[i,1]:=Normals[i+1,1];
  Normals[i,2]:=Normals[i+1,2];
  Normals[i,3]:=Normals[i+1,3];
  //Массив текстурных координат
  for ii:=0 to CountOfCoords-1 do with Crds[ii] do begin
   TVertices[i,1]:=TVertices[i+1,1];
   TVertices[i,2]:=TVertices[i+1,2];
  end;//of with/for ii
  //Массив групп вершин
  VertexGroup[i]:=VertexGroup[i+1];
 end;//of for
 //Исправить массив выделенных вершин
 for i:=0 to VertexCount-1 do
          if VertexList[i]>NumOfVertex then dec(VertexList[i]);
 //Исправить массив скрытых вершин
 i:=0;
 repeat
  if HideVertexCount=NumOfVertex then begin
   HideVertices[i]:=HideVertices[HideVertexCount-1];
   dec(HideVertexCount);
   SetLength(HideVertices,HideVertexCount);
  end;//of if
  inc(i);
 until i>(HideVertexCount-1);
 for i:=0 to HideVertexCount-1 do
          if HideVertices[i]>NumOfVertex then dec(HideVertices[i]);
 dec(CountOfVertices);dec(CountOfNormals);
 for ii:=0 to CountOfCoords-1 do begin
  dec(Crds[ii].CountOfTVertices);
  SetLength(Crds[ii].TVertices,CountOfVertices);
 end;//of for ii
 SetLength(Vertices,CountOfVertices); //изменить размеры массивов
 SetLength(Normals,CountOfVertices);
 SetLength(VertexGroup,CountOfVertices);

 //2. Пометить все треугольники, содержащие эту вершину
 //Затем в др. процедуре (FinalizeDeleting) они удаляются
 //Кроме того, здесь же (см. ниже) осуществляется
 //"сдвиг" номеров Faces
 Counter:=0;                      //счетчик смещения
 for i:=0 to Length(Faces)-1 do for ii:=0 to Length(faces[i])-1 do begin
  if counter<=-3 then counter:=0; //подсчет вершин
  if Faces[i,ii]=NumOfVertex-1 then begin
   Faces[i,ii+counter]:=-1;
   Faces[i,ii+counter+1]:=-1;
   Faces[i,ii+counter+2]:=-1;
  end;//of if
  dec(counter);
  if Faces[i,ii]>NumOfVertex-1 then dec(Faces[i,ii]); //сдвиг
 end;//of for

 //3. Сдвиг номеров вершин в ConstNormals/MidNormals
 n.GeoID:=geonum-1;
 n.VertID:=NumOfVertex-1;
 DeleteRecFromSmoothGroups(n);
 for i:=0 to COMidNormals-1 do for ii:=0 to High(MidNormals[i])
 do if (MidNormals[i,ii].GeoID=geonum-1) and (MidNormals[i,ii].VertID>=n.VertID)
 then dec(MidNormals[i,ii].VertID);

 for i:=0 to COConstNormals-1
 do if (ConstNormals[i].GeoId=geonum-1) and (ConstNormals[i].VertID>=n.VertID)
 then dec(ConstNormals[i].VertID);

 PopFunction;
end;End;
//---------------------------------------------------------
//Вызывается после удаления всей группы вершин,
//приводит массивы в порядок после удаления
procedure FinalizeDeleting(geonum:integer);
Var delta,i,ii:integer;
    IsIncDelta:boolean;
    grnums:array of integer;
Begin with Geosets[geonum-1] do begin
 PushFunction(293);
 //1. Удалить из Faces треугольники, помеченные (-1)
 for i:=0 to Length(faces)-1 do begin
  Delta:=0;
  for ii:=0 to Length(faces[i])-1 do begin
   if Faces[i,ii]=-1 then begin inc(delta);continue;end;
   if Delta<>0 then faces[i,ii-Delta]:=faces[i,ii];
  end;//of for ii
  SetLength(faces[i],length(faces[i])-Delta);//изменить длину
 end;//of for i
 //1.2. Удалить пустые подмассивы Faces
 delta:=0;
 for i:=0 to length(faces)-1 do begin
  if length(faces[i])=0 then begin inc(delta);continue;end;
  if Delta<>0 then faces[i-Delta]:=faces[i];
 end;//of for
 SetLength(Faces,length(faces)-delta);
 CountOfFaces:=length(faces);

 //2. Определить, не отсеилась ли часть групп
 SetLength(grnums,length(Groups)); //длина массива
 for i:=0 to length(Groups)-1 do grnums[i]:=0; //инициализация
 for i:=0 to length(VertexGroup)-1 do begin
  inc(grnums[VertexGroup[i]]); //подсчитываем группы
//  if grnums[VertexGroup[i]]=0 then Assert(true);
//  grnums[VertexGroup[i]]:=grnums[VertexGroup[i]]+1;
 end;//of for
{ DONE 1 -oАлексей -cГлюк : Глюк (на Runner) }
 //2.2. Сдвигаем (dec) номера групп
 Delta:=0;
 for i:=0 to Length(Groups)-1 do begin
  IsIncDelta:=false;
  if grnums[i]=0 then begin
   for ii:=0 to length(VertexGroup)-1 do
     if VertexGroup[ii]>(i-Delta) then begin
      dec(VertexGroup[ii]);IsincDelta:=true;
     end;//of if(2)
  end;//of if
  if IsIncDelta then inc(Delta);
 end;//of for
 //2.3. Удаляем отсеившиеся группы
 Delta:=0;
 for i:=0 to Length(Groups)-1 do begin
  if grnums[i]=0 then begin inc(delta);continue;end;
  if Delta<>0 then Groups[i-Delta]:=Groups[i];
 end;//of for
 SetLength(Groups,Length(Groups)-Delta);
 CountOfMatrices:=Length(Groups);

 //проверка: остались ли еще треугольники
 if (length(faces)=0) and (CountOfVertices<>0) then begin
 //создать фиктивный треугольник
  SetLength(faces,1);
  SetLength(faces[0],3);
  Faces[0,0]:=0;Faces[0,1]:=0;Faces[0,2]:=0;
  CountOfFaces:=1;
 end;//of if
 PopFunction;
end;End;
//---------------------------------------------------------
//Создаёт/удаляет анимацию видимости
//gan - ID анимации видимости для удаления или
//позиция для добавления новой
//geoID - используется в случае создания новой анимации:
//это - её поле GeosetID.
//ARFlag - если +1, анимация создаётся. Иначе - удаляется.
procedure ARGeosetAnim(gan,geoID,ARFlag:integer);
Var i:integer;
Begin
 PushFunction(294);
 //a. Удаление сдвигом
 if ARFlag<0 then begin
  if CountOfGeosetAnims<2 then begin //полное удаление
   CountOfGeosetAnims:=0;
   SetLength(GeosetAnims,CountOfGeosetAnims);
  end else begin                  //удаления 1 анимации из списка
   for i:=gan+1 to CountOfGeosetAnims-1 do GeosetAnims[i-1]:=GeosetAnims[i];
   dec(CountOfGeosetAnims);
   SetLength(GeosetAnims,CountOfGeosetAnims);
  end;//of if (способ удаления)
 end else begin                   //если же надо добавить
  inc(CountOfGeosetAnims);
  SetLength(GeosetAnims,CountOfGeosetAnims);
  for i:=CountOfGeosetAnims-1 downto gan+1 do GeosetAnims[i]:=GeosetAnims[i-1];
 end;//of if

 //b. Обработка костей (в помощниках GeosetAnimID не бывает):
 for i:=0 to CountOfBones-1 do begin
  if Bones[i].GeosetAnimID>gan
  then Bones[i].GeosetAnimID:=Bones[i].GeosetAnimID+ARFlag;
  if (ARFlag<0) and (Bones[i].GeosetAnimID=gan)
  then Bones[i].GeosetAnimID:=None;
  if (ARFlag>0) and (Bones[i].GeosetAnimID=gan) then inc(Bones[i].GeosetAnimID);
 end;//of for (bones)
 PopFunction;
End;
//---------------------------------------------------------
//Удаляет всю поверхность+ее анимацию видимости
procedure DeleteGeoset(geonum:integer);
Var i,ii,gan:integer; 
    bFlg:boolean;
Begin
 PushFunction(295);
 //1. Сдвиг массива поверхностей (удаление поверхности)
 for i:=geonum to CountOfGeosets-1 do begin
  Geosets[i-1]:=Geosets[i];
  Geoobjs[i-1]:=GeoObjs[i];
 end;//of for i
 dec(CountOfGeosets);
 SetLength(Geosets,CountOfGeosets);
 SetLength(Geoobjs,CountOfGeosets);

 //2. Проверяем анимации видмости - не нужно ли удалить.
 bFlg:=false;
 for i:=0 to CountOfGeosetAnims-1 do
  if GeosetAnims[i].GeosetID=(geonum-1) then begin
   gan:=i;                        //узнать номер анимации
   bFlg:=true;
   break;
 end;//of if/for

 //3. Если нужно - удаляем:
 if bFlg then begin
  //a. Удаление сдвигом
  if CountOfGeosetAnims<2 then begin //полное удаление
   CountOfGeosetAnims:=0;
   SetLength(GeosetAnims,CountOfGeosetAnims);
  end else begin                  //удаления 1 анимации из списка
   for i:=gan+1 to CountOfGeosetAnims-1 do GeosetAnims[i-1]:=GeosetAnims[i];
   dec(CountOfGeosetAnims);
   SetLength(GeosetAnims,CountOfGeosetAnims);
  end;//of if (способ удаления)
  //b. Обработка костей/помощников:
  for i:=0 to CountOfBones-1 do begin
   if Bones[i].GeosetAnimID=gan then Bones[i].GeosetAnimID:=None;
   if Bones[i].GeosetAnimID>gan then dec(Bones[i].GeosetAnimID);
  end;//of for (bones)
  for i:=0 to CountOfHelpers-1 do begin
   if Helpers[i].GeosetAnimID=gan then Helpers[i].GeosetAnimID:=-1;
   if Helpers[i].GeosetAnimID>gan then dec(Helpers[i].GeosetAnimID);
  end;//of for (helpers)
 end;//of if (удалить GeosetAnim)

 //4. Обработка костей/помощников (сдвиг GeosetID)
 for i:=0 to CountOfBones-1 do begin
  if Bones[i].GeosetID=geonum-1 then Bones[i].GeosetID:=Multiple;
  if Bones[i].GeosetID>geonum-1 then dec(Bones[i].GeosetID);
 end;//of for (bones)
 for i:=0 to CountOfHelpers-1 do begin
  if Helpers[i].GeosetID=geonum-1 then Helpers[i].GeosetID:=-1;
  if Helpers[i].GeosetID>geonum-1 then dec(Helpers[i].GeosetID);
 end;//of for

 //5. Обработка GeosetAnims (сдвиг GeosetID):
 for i:=0 to CountOfGeosetAnims-1 do
  if GeosetAnims[i].GeosetID>geonum-1 then dec(GeosetAnims[i].GeosetID);

 //6. Обработка групп сглаживания
 for i:=0 to COMidNormals-1 do for ii:=0 to High(MidNormals[i])
 do if MidNormals[i,ii].GeoID>=geonum-1 then dec(MidNormals[i,ii].GeoID);

 for i:=0 to COConstNormals-1 do if ConstNormals[i].GeoId>=geonum-1
 then dec(ConstNormals[i].GeoID);

 PopFunction;
End;
//---------------------------------------------------------
//Удаляет текстуру с указанным ID.
//Все остальные текстуры, соотв., сдвигаются.
//Правятся id в Источниках и материалах.
procedure DeleteTexture(id:integer);
Var i,ii,j:integer;
Begin
 PushFunction(371);
 //1. Выполним сдвиг текстур
 for i:=id to CountOfTextures-2 do Textures[i]:=Textures[i+1];
 dec(CountOfTextures);
 SetLength(Textures,CountOfTextures);

 //2. Сдвинем ID в материалах
 for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1
 do if Materials[i].Layers[ii].TextureID>=id
 then dec(Materials[i].Layers[ii].TextureID);

 //3. Сдвинем id в контроллерах текстур
 for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1
 do if not Materials[i].Layers[ii].IsTextureStatic
 then with Controllers[Materials[i].Layers[ii].NumOfTexGraph]
 do for j:=0 to High(Items) do if round(Items[j].Data[1])>=id
 then Items[j].Data[1]:=Items[j].Data[1]-1;

 //4. Сдвинем ID в ИЧ
 for i:=0 to CountOfParticleEmitters-1 do if pre2[i].TextureID>=id
 then dec(pre2[i].TextureID);
 
 PopFunction;
End;

//Удаляет повторяющиеся текстуры, производя коррекцию
//TextureID в материалах и ИЧ
procedure DeleteDublicateTextures;
Var i,ii,j,iOne,iTwo:integer;
Begin
 PushFunction(370);
 iOne:=0;
 while iOne<CountOfTextures do begin
  iTwo:=iOne+1;
  while iTwo<CountOfTextures do begin
   if (lowercase(Textures[iOne].FileName)=lowercase(Textures[iTwo].FileName))
      and (Textures[iOne].ReplaceableID=Textures[iTwo].ReplaceableID)
   then begin                     //текстуры совпали
    //1. Изменим ID в материалах
    for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1
    do if Materials[i].Layers[ii].TextureID=iTwo
    then Materials[i].Layers[ii].TextureID:=iOne;
    //2. Изменим ID в контроллерах текстур (если таковые есть):
    for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1
    do if not Materials[i].Layers[ii].IsTextureStatic
    then with Controllers[Materials[i].Layers[ii].NumOfTexGraph]
    do for j:=0 to High(Items) do if round(Items[j].Data[1])=iTwo
    then Items[j].Data[1]:=iOne;
    //3. Изменим ID в источниках
    for i:=0 to CountOfParticleEmitters-1 do if pre2[i].TextureID=iTwo
    then pre2[i].TextureID:=iOne;
    //(в др. источниках, даже в Ribb'ах, нет TextureID)

    //4. Удалим лишнюю (повторяющуюся) текстуру
    DeleteTexture(iTwo);
    continue;                     //продолжить
   end;//of if
   inc(iTwo);
  end;//of while
  inc(iOne);
 end;//of while
 
 PopFunction;
End;
//---------------------------------------------------------
//Сравнение поверхностей. Возвращает true, если
//вершины поверхностей мало отличаются друг от друга.
function CompareGeosets(geoID1,geoID2:integer):boolean;
Var i,ii:integer;Sum1,Sum2:TVertex;Delta:GLFloat;
const SumLim=1;
Begin
 PushFunction(296);
 Result:=false;       
 //1. Сравним кол-во вершин
 if Geosets[geoID1].CountOfVertices<>Geosets[geoID2].CountOfVertices then begin
  PopFunction;
  exit;
 end;
 //2. Сравниваем матрицы костей
 if Geosets[geoID1].CountOfMatrices<>Geosets[geoID2].CountOfMatrices then begin
  PopFunction;
  exit;
 end;
{ for i:=0 to Geosets[geoID1].CountOfMatrices-1 do begin
  if length(Geosets[GeoID1].Groups)<>length(Geosets[GeoID2].Groups) then exit;
  for ii:=0 to High(Geosets[GeoID1].Groups[i])
  do if Geosets[GeoID1].Groups[i,ii]<>Geosets[GeoID2].Groups[i,ii] then exit;
 end;//of for i}

 //2. Сравниваем координаты (находим их сумму)
 Sum1[1]:=0;Sum1[2]:=0;Sum1[3]:=0;
 Sum2[1]:=0;Sum2[2]:=0;Sum2[3]:=0;
 for i:=0 to Geosets[geoID1].CountOfVertices-1 do for ii:=1 to 3 do begin
  Sum1[ii]:=Sum1[ii]+Geosets[GeoID1].Vertices[i,ii];
  Sum2[ii]:=Sum2[ii]+Geosets[GeoID2].Vertices[i,ii];
 end;//of for i
 Delta:=abs(Sum1[1]-Sum2[1])+abs(Sum1[2]-Sum2[2])+abs(Sum1[3]-Sum2[3]);
 if Delta<SumLim then Result:=true;
 PopFunction;
End;
//---------------------------------------------------------
//Строит список полностью выделенных треугольников,
//заполняя массив SelFaces
procedure FindSelectedFaces(geonum:integer);
Var i,ii,j,len,count,tmp:integer;
Begin with Geosets[geonum-1],geoobjs[geonum-1] do begin
 PushFunction(297);
 SelFaces:=nil;                   //пока ничего не найдено
 count:=0;
 //просмотр всех треугольников
 for i:=0 to length(Faces)-1 do begin
  ii:=0;len:=length(Faces[i])-1;
  repeat
   tmp:=0;         //подсчет для каждого треугольника
   for j:=0 to VertexCount-1 do
       if ((VertexList[j]-1)=Faces[i,ii]) or
          ((VertexList[j]-1)=Faces[i,ii+1]) or
          ((VertexList[j]-1)=Faces[i,ii+2]) then inc(tmp);
   //подсчет окончен. Если все три вершины выделены...
   //да, еще учтем, что две вершины в треуг. м. совпадать.
   if (tmp=3) or ((tmp=2) and (
      (Faces[i,ii]=Faces[i,ii+1]) or
      (Faces[i,ii]=Faces[i,ii+2]) or
      (Faces[i,ii+1]=Faces[i,ii+2]))) then begin
    count:=count+3;          //удлиним массив
    SetLength(SelFaces,count);
    SelFaces[count-1-2]:=Faces[i,ii];
    SelFaces[count-1-1]:=Faces[i,ii+1];
    SelFaces[count-1]:=Faces[i,ii+2];
   end;//of if
   ii:=ii+3;                      //движемся далее
  until ii>=len;
 end;//of for
 PopFunction;
end;End;
//---------------------------------------------------------
//Строит список полностью выделенных треугольников,
//заполняя массив SelFaces ИХ НОМЕРАМИ В Faces
procedure FindNumbersSelFaces(geonum:integer);
Var {i,}ii,j,len,count,tmp:integer;
Begin with Geosets[geonum-1],geoobjs[geonum-1] do begin
 PushFunction(298);
 SelFaces:=nil;                   //пока ничего не найдено
 count:=0;
 //просмотр всех треугольников
// for i:=0 to length(Faces)-1 do begin
  ii:=0;len:=High(Faces[0]);
  repeat
   tmp:=0;         //подсчет для каждого треугольника
   for j:=0 to VertexCount-1 do
       if ((VertexList[j]-1)=Faces[0,ii]) or
          ((VertexList[j]-1)=Faces[0,ii+1]) or
          ((VertexList[j]-1)=Faces[0,ii+2]) then inc(tmp);
   //подсчет окончен. Если все три вершины выделены...
   //да, еще учтем, что две вершины в треуг. м. совпадать.
   if (tmp=3) or ((tmp=2) and (
      (Faces[0,ii]=Faces[0,ii+1]) or
      (Faces[0,ii]=Faces[0,ii+2]) or
      (Faces[0,ii+1]=Faces[0,ii+2]))) then begin
    inc(count);                   //удлиним массив
    SetLength(SelFaces,count);
    SelFaces[count-1]:=ii;
   end;//of if
   ii:=ii+3;                      //движемся далее
  until ii>=len;
// end;//of for
 PopFunction;
end;End;
//---------------------------------------------------------
//Добавляет к поверхности новые точки, удваивая вершины
//из SelFaces. Номера новых вершин накапливаются в NewVertices
procedure AddVertices(geonum:integer);
Var i,ii,CountOfNew,num:integer;
    IsExist:boolean;
Begin with Geosets[geonum-1],geoobjs[geonum-1] do begin
 PushFunction(299);
 VertexCount:=0;VertexList:=nil;
 CountOfNew:=length(SelFaces);
 If CountOfNew=0 then begin PopFunction;exit;end;//ошибка, нет вершин
 NewVertices:=nil;                //пока нет новых вершин
 SetLength(NewVertices,CountOfNew);//размер массива
 //Теперь заполним массив NewVertices (соответствие вершин)
 for i:=0 to length(SelFaces)-1 do NewVertices[i]:=SelFaces[i];
 //начинаем добавление
 for i:=0 to CountOfNew-1 do begin
  //Учтем, что добавлять вершины нужно только однократно
  IsExist:=false;
  for ii:=0 to i-1 do if SelFaces[ii]=SelFaces[i] then begin
   IsExist:=true;  //Такая вершина уже есть
   break;
  end;//of for ii
  if IsExist then continue;
  inc(VertexCount);SetLength(VertexList,VertexCount);
  VertexList[VertexCount-1]:=CountOfVertices+1;
  inc(CountOfVertices);           //вначале установим размеры
  inc(CountOfNormals);
  num:=SelFaces[i];               //читаем номер исх. вершины
  //Дублируем координаты вершины
  SetLength(Vertices,CountOfVertices);
  Vertices[CountOfVertices-1,1]:=Vertices[num,1];
  Vertices[CountOfVertices-1,2]:=Vertices[num,2];
  Vertices[CountOfVertices-1,3]:=Vertices[num,3];
  //Устанавливаем к-ты нормалей
  SetLength(Normals,CountOfVertices);
  Normals[CountOfVertices-1,1]:=Normals[num,1];
  Normals[CountOfVertices-1,2]:=Normals[num,2];
  Normals[CountOfVertices-1,3]:=Normals[num,3];
  //Текстурные к-ты
  for ii:=0 to CountOfCoords-1 do with Crds[ii] do begin
   inc(CountOfTVertices);
   SetLength(TVertices,CountOfVertices);
   TVertices[CountOfVertices-1,1]:=TVertices[num,1];
   TVertices[CountOfVertices-1,2]:=TVertices[num,2];
  end;//of with/for ii
  //Группы вершин
  SetLength(VertexGroup,CountOfVertices);
  VertexGroup[CountOfVertices-1]:=VertexGroup[num];

  //Теперь заменяем номер очередной вершины в NewVertices
  for ii:=i to CountOfNew-1 do
   if NewVertices[ii]=num then NewVertices[ii]:=CountOfVertices-1;
 end;//of for
 PopFunction;
end;End;
//---------------------------------------------------------
//Осуществляет создание граней экструзии
//на основании SelFaces и NewVertices
procedure Extrude(geonum:integer);
Var i,ii,j,len,count,num,len2,num1,num2,num3:integer;
    IsExist:boolean;
Begin with Geosets[geonum-1],geoobjs[geonum-1] do begin
 PushFunction(300);
 {i:=0;}len:=Length(NewVertices);
 SetLength(NewFaces,length(NewVertices));
 count:=length(NewFaces);
 //цикл: создаем верхнюю грань
 for i:=0 to length(NewVertices)-1 do NewFaces[i]:=NewVertices[i];
 //Теперь создаем боковые грани
 i:=0;
 repeat
  SetLength(NewFaces,count+18);//место для новых треугольников
  NewFaces[count+1]:=SelFaces[i];
  NewFaces[count+2]:=SelFaces[i+1];
  NewFaces[count]:=NewVertices[i];
  NewFaces[count+4]:=NewVertices[i+1];
  NewFaces[count+5]:=NewVertices[i];
  NewFaces[count+3]:=SelFaces[i+1];

  NewFaces[count+7]:=SelFaces[i+1];
  NewFaces[count+8]:=SelFaces[i+2];
  NewFaces[count+6]:=NewVertices[i+1];
  NewFaces[count+10]:=NewVertices[i+2];
  NewFaces[count+11]:=NewVertices[i+1];
  NewFaces[count+9]:=SelFaces[i+2];

  NewFaces[count+13]:=SelFaces[i+2];
  NewFaces[count+14]:=SelFaces[i];
  NewFaces[count+12]:=NewVertices[i+2];
  NewFaces[count+16]:=NewVertices[i];
  NewFaces[count+17]:=NewVertices[i+2];
  NewFaces[count+15]:=SelFaces[i];

  count:=count+18;
  i:=i+3;
 until i>=len;

 //Проверяем боковые грани на дублирование, повторные удаляем
 i:=length(NewVertices);len:=length(NewFaces);
 repeat
  ii:=i;
  repeat
   num1:=-1;num2:=-1;num3:=-1;
   if (ii<>i) and ((NewFaces[i]=NewFaces[ii]) or
                   (NewFaces[i]=NewFaces[ii+1]) or
                   (NewFaces[i]=NewFaces[ii+2])) then num1:=NewFaces[i];
   if (ii<>i) and ((NewFaces[i+1]=NewFaces[ii]) or
                   (NewFaces[i+1]=NewFaces[ii+1]) or
                   (NewFaces[i+1]=NewFaces[ii+2])) then num2:=NewFaces[i+1];
   if (ii<>i) and ((NewFaces[i+2]=NewFaces[ii]) or
                   (NewFaces[i+2]=NewFaces[ii+1]) or
                   (NewFaces[i+2]=NewFaces[ii+2])) then num3:=NewFaces[i+2];
   if num1=-1 then begin num1:=num3;num3:=-1;end;
   if num2=-1 then begin num2:=num3;num3:=-1;end;
   if ((num1>=0) and (num2>=0) and (num3>=0)) or
      ((num1>=0) and (num2>=0) and
      (((num1>=OldCountOfVertices) and (num2>=OldCountOfVertices)) or
      ((num1<OldCountOfVertices)and(num2<OldCountOfVertices)))) then begin
    NewFaces[i]:=-1;NewFaces[ii]:=-1;    //удаляем совпадающие
    NewFaces[i+1]:=-1;NewFaces[ii+1]:=-1;
    NewFaces[i+2]:=-1;NewFaces[ii+2]:=-1;
   end;
   ii:=ii+3;
  until ii>=len-1;
  i:=i+3;
 until i>=len-1;

 //Теперь нужно удалить нижнюю грань.
 i:=0;len:=length(SelFaces);
 repeat                           //цикл по SelFaces
  for ii:=0 to length(Faces)-1 do begin //поиск в Faces
   j:=0;
   repeat
    if (Faces[ii,j]=SelFaces[i]) and
       (Faces[ii,j+1]=SelFaces[i+1]) and
       (Faces[ii,j+2]=SelFaces[i+2]) then begin
     Faces[ii,j]:=-1;Faces[ii,j+1]:=-1;Faces[ii,j+2]:=-1;
    end;//of if
    j:=j+3;
   until j>=length(Faces[ii])-1;
  end;//of for
  i:=i+3;
 until i>=len-1;

 //Добавить вновь созданные треугольники к поверхности
 len:=length(Faces);len2:=length(Faces[len-1]);
 SetLength(Faces[len-1],len2+length(NewFaces));
 for i:=0 to length(NewFaces)-1 do Faces[len-1,len2+i]:=NewFaces[i];

 //Теперь удаляем уже ненужные вершины
 for i:=0 to length(SelFaces)-1 do begin
  num:=SelFaces[i];               //считываем номер вершины
  if num<0 then continue;         //пропустить удаленное
  IsExist:=false;                 //ищем вершину
  for ii:=0 to length(NewFaces)-1 do if NewFaces[ii]=num then begin
   IsExist:=true;
   break;
  end;//of for ii
  if not IsExist then begin       //вершина не используется
   for j:=0 to length(SelFaces)-1 do begin
    if SelFaces[j]=num then SelFaces[j]:=-1;
    if SelFaces[j]>num then dec(SelFaces[j]);
   end;//of for j
   for j:=0 to High(NewFaces) do begin
    if NewFaces[j]>num then dec(NewFaces[j]);
   end;//of for j
   DeleteVertex(geonum,num+1);      //удаляем вершину
  end;//of if (IsExist)
 end;//of for

 //Завершаем обработку поверхности
 FinalizeDeleting(geonum);
 PopFunction;
end;End;
//---------------------------------------------------------
//Возвращает true, если указанная вершина не используется
//ни в одном из треугольников поверхности
function IsVertexFree(GeoID,VertID:integer):boolean;
Var i,ii:integer;
Begin
 PushFunction(382);
 Result:=true;
 for i:=0 to Geosets[GeoID].CountOfFaces-1
 do for ii:=0 to High(Geosets[GeoID].Faces[i])
 do if Geosets[GeoID].Faces[i,ii]=VertID then begin
  Result:=false;
  PopFunction;
  exit;
 end;//of if/for ii/i
 PopFunction;
End;
//---------------------------------------------------------
//То же, но для к-т текстуры: массив TexVertices2D
//Естественно, контекст должен быть установлен.
procedure CalcTexVertex2D(ClientHeight:integer);
Var Viewport:array[0..3] of GLfloat;
    mvMatrix,ProjMatrix:array[0..15] of GLdouble;
//    wx,wy,wz:GLDouble;
    i,j:integer;
Begin for j:=0 to CountOfGeosets-1 do with Geosets[j],geoobjs[j] do begin
 PushFunction(301);
 //1. Читаем матрицы
 glGetIntegerv(GL_VIEWPORT,@Viewport);
 glGetDoublev(GL_MODELVIEW_MATRIX,@mvMatrix);
 glGetDoublev(GL_PROJECTION_MATRIX,@ProjMatrix);
 //2. Задать размер массива
 SetLength(TexVertices2D,TexVertexCount);
 //3. Начать расчет для всех вершин
 for i:=0 to TexVertexCount-1 do begin
  gluProject(Crds[CurrentCoordID].TVertices[TexVertexList[i]-1,1],
             Crds[CurrentCoordID].TVertices[TexVertexList[i]-1,2],0,
             @mvMatrix,@ProjMatrix,@ViewPort,
             TexVertices2D[i].x,TexVertices2D[i].y,
             TexVertices2D[i].z);
  TexVertices2D[i].y:=ClientHeight-TexVertices2D[i].y;//пересчет
 end;//of for
 PopFunction;
end;End;
//---------------------------------------------------------
//То же, но для различных скелетных объектов
procedure CalcObjs2D(ClientHeight:integer);
Var Viewport:array[0..3] of GLfloat;
    mvMatrix,ProjMatrix:array[0..15] of GLdouble;
    i,ii:integer;
Begin
 PushFunction(302);
 //1. Читаем матрицы
 glGetIntegerv(GL_VIEWPORT,@Viewport);
 glGetDoublev(GL_MODELVIEW_MATRIX,@mvMatrix);
 glGetDoublev(GL_PROJECTION_MATRIX,@ProjMatrix);
 //2. Задать размеры массивов
 CountOfObjs:=0;
 if VisObjs.VisBones then CountOfObjs:=CountOfObjs+CountOfBones+CountOfHelpers;
 if VisObjs.VisAttachments then CountOfObjs:=CountOfObjs+CountOfAttachments;
 if VisObjs.VisParticles then CountOfObjs:=CountOfObjs+CountOfParticleEmitters;
 SetLength(Objs2D,CountOfObjs);

 //3. Начать расчет для всех видимых объектов скелета
 ii:=0;                           //счётчик объектов
 if VisObjs.VisBones then begin
  for i:=0 to CountOfBones-1 do begin
   gluProject(Bones[i].AbsVector[1],
              -Bones[i].AbsVector[2],Bones[i].AbsVector[3],
              @mvMatrix,@ProjMatrix,@ViewPort,
              Objs2D[ii].x,Objs2D[ii].y,Objs2D[ii].z);
   Objs2D[ii].y:=ClientHeight-Objs2D[ii].y;//пересчет
   //Если есть Null-объект - не включать его
   if NullBone.IsExists and (NullBone.IdInBones=i) then begin
    Objs2D[ii].x:=-1e6;
    Objs2D[ii].y:=-1e6;
   end;//of if
   Objs2D[ii].id:=Bones[i].ObjectID;
   inc(ii);                       //следующий объект
  end;//of for
  
  //Расчет для помощников
  for i:=0 to CountOfHelpers-1 do begin
   gluProject(Helpers[i].AbsVector[1],
              -Helpers[i].AbsVector[2],Helpers[i].AbsVector[3],
              @mvMatrix,@ProjMatrix,@ViewPort,
              Objs2D[ii].x,Objs2D[ii].y,Objs2D[ii].z);
   Objs2D[ii].y:=ClientHeight-Objs2D[ii].y;//пересчет
   Objs2D[ii].id:=Helpers[i].ObjectID;
   inc(ii);
  end;//of for i
 end;//of if(кости видимы)

 //Расчёт для аттачей (если видимы):
 if VisObjs.VisAttachments then begin
  for i:=0 to CountOfAttachments-1 do begin
   gluProject(Attachments[i].Skel.AbsVector[1],
              -Attachments[i].Skel.AbsVector[2],
              Attachments[i].Skel.AbsVector[3],
              @mvMatrix,@ProjMatrix,@ViewPort,
              Objs2D[ii].x,Objs2D[ii].y,Objs2D[ii].z);
   Objs2D[ii].y:=ClientHeight-Objs2D[ii].y;//пересчет
   Objs2D[ii].id:=Attachments[i].Skel.ObjectID;
   inc(ii);
  end;//of for i
 end;//of if (аттачи видимы)

 //Расчёт для ИЧ-2 (если видимы)
 if VisObjs.VisParticles then begin
  for i:=0 to CountOfParticleEmitters-1 do begin
   gluProject(pre2[i].Skel.AbsVector[1],
              -pre2[i].Skel.AbsVector[2],
              pre2[i].Skel.AbsVector[3],
              @mvMatrix,@ProjMatrix,@ViewPort,
              Objs2D[ii].x,Objs2D[ii].y,Objs2D[ii].z);
   Objs2D[ii].y:=ClientHeight-Objs2D[ii].y;//пересчет
   Objs2D[ii].id:=pre2[i].Skel.ObjectID;
   inc(ii);
  end;//of for i
 end;//of if (ИЧ-2 видимы)
 PopFunction;
End;
//---------------------------------------------------------
//Возвращает true, если вершина v лежит внутри треугольника
//vt1-vt3
function IsVertexInTriangle(v,vt1,vt2,vt3:TVertex):boolean;
Var mc1,mc2,mc3,mv1,mv2,mv3:GLFloat;cntr:TVertex;
function Orient(a,b,c:TVertex):GLFloat;
Begin
 Result:=(a[1]-c[1])*(b[2]-c[2])-(a[2]-c[2])*(b[1]-c[1]);
End;
Begin
 Result:=false;
 //0. Проверим, не совпадают ли вершины треугльника
 if abs(vt1[1]-vt2[1])+abs(vt1[2]-vt2[2])<1e-5 then exit;
 if abs(vt1[1]-vt3[1])+abs(vt1[2]-vt3[2])<1e-5 then exit;
 if abs(vt2[1]-vt3[1])+abs(vt2[2]-vt3[2])<1e-5 then exit;

 //1. Находим центр треугольника
 cntr[1]:=0.333333*(vt1[1]+vt2[1]+vt3[1]);
 cntr[2]:=0.333333*(vt1[2]+vt2[2]+vt3[2]);
 if abs((vt1[1]-vt2[1])+(vt1[2]-vt2[2])+(vt1[3]-vt2[3]))<1e-5 then begin
  Result:=false;
  exit;
 end;//of if
 //2. Начинаем проверку
 mc1:=Orient(vt1,vt2,cntr);
 mc2:=Orient(vt2,vt3,cntr);
 mc3:=Orient(vt3,vt1,cntr);
 mv1:=Orient(vt1,vt2,v);
 mv2:=Orient(vt2,vt3,v);
 mv3:=Orient(vt3,vt1,v);
 if (mc1*mv1>=0) and (mc2*mv2>=0) and (mc3*mv3>=0) then Result:=true
 else Result:=false;
End;
//---------------------------------------------------------
//То же самое - для редактора текстур
procedure TexSaveUndo(action:integer);
Var Cur,i,j:integer;
Begin
 PushFunction(303);
 IsModified:=true;//модель модифицирована
 //0. Ищем пустое место в списке отмен
 Cur:=ShearUndo;
 //1. Выделение
 case action of
  uTexSelect:begin
   Undo[Cur].Status1:=uTexSelect; //сохранить тип действия
   for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
    Undo[Cur].Status1:=uTexSelect;//сохранить тип действия
    Undo[Cur].Status2:=TexSelVertexCount; //кол-во вершин
    SetLength(Undo[Cur].Data1,TexSelVertexCount);//размер данных
    for i:=0 to TexSelVertexCount-1 do Undo[Cur].Data1[i]:=TexSelVertexList[i];
   end;//of for j
  end;//of uSelect;

 uTexVertexTrans:begin               //изменение к-т вершин
  Undo[Cur].Status1:=uTexVertexTrans;//сохранить тип действия
  for j:=0 to CountOfGeosets-1 do with geosets[j],geoobjs[j] do begin
   Undo[Cur].Status1:=uTexVertexTrans;//сохранить тип действия
   Undo[Cur].Status2:=TexSelVertexCount; //кол-во вершин
   Undo[Cur].MatID:=CurrentCoordID;   //текущую текстурную плоскость
   SetLength(Undo[Cur].Data1,TexSelVertexCount);//размер массива
   SetLength(Undo[Cur].Data2,TexSelVertexCount);
   SetLength(Undo[Cur].iData,TexSelVertexCount);
   for i:=0 to TexSelVertexCount-1 do begin
    Undo[Cur].data1[i]:=Crds[CurrentCoordID].TVertices[TexSelVertexList[i]-1,1];
    Undo[Cur].data2[i]:=Crds[CurrentCoordID].TVertices[TexSelVertexList[i]-1,2];
    Undo[Cur].idata[i]:=TexSelVertexList[i];
   end;//of for i
  end;//of for j
 end;//of uVertexTrans

 uTexCoup:begin                   //переворот текстурной карты
  Undo[Cur].status1:=uTexCoup;
 end;//of uTexCoup

 uTexPlaneChange:begin            //смена активной текст. плоскости
  Undo[Cur].Status1:=uTexPlaneChange;
  Undo[Cur].Status2:=CurrentCoordID;
 end;//of uTexPlaneChange
 end;//of case
 PopFunction;
End;
//---------------------------------------------------------
//Осуществляет переворачивание текстурной карты
procedure CoupTextureMap;
Var j,i:integer;
Begin
 PushFunction(304);
 for j:=0 to CountOfGeosets-1 do with Geosets[j] do if GeoObjs[j].IsSelected
 then begin
  for i:=0 to CountOfVertices-1
  do Crds[CurrentCoordID].TVertices[i,2]:=1-Crds[CurrentCoordID].TVertices[i,2];
 end;//of if
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательная: работает с "новым" массивом отмен
function SaveNewUndo(uAction,param:integer):integer;
Var bu:TBoneUndo;au:TAtchUndo;pu:TPivUndo;su:TStampObjUndo;pr:TPre2Undo;
    sg:TStampGeoUndo;cc:TNewControllerUndo;dc:TDelControllerUndo;
    skf:TChangeObjKFUndo; smg:TSaveSmoothGroups;
    ssq:TSaveSeq;tou:TObjUndo;
    i,ii,j:integer;
Begin
 PushFunction(305);
 inc(CountOfNewUndo);
 SetLength(NewUndo,CountOfNewUndo);
 Result:=0;
 case uAction of
  uDeleteSeq:begin
   i:=AnimPanel.ids;
   tou:=TObjUndo(TDelSeqUndo.Create);
   AnimPanel.ids:=param;
   tou.Save;
   AnimPanel.SelSeq(i);
   NewUndo[CountOfNewUndo-1]:=tou;
  end;
  uCreateSeq:begin
   i:=AnimPanel.ids;
   tou:=TObjUndo(TSaveCreateSeq.Create);
   AnimPanel.ids:=param;
   tou.Save;
   AnimPanel.SelSeq(i);
   NewUndo[CountOfNewUndo-1]:=tou;
  end;
  uSeqPropChange:begin            //смена свойств указанной анимации
   i:=AnimPanel.ids;
   AnimPanel.SelSeq(param);
   ssq:=TSaveSeq.Create;
   ssq.Save;
   AnimPanel.SelSeq(i);
   NewUndo[CountOfNewUndo-1]:=ssq;
  end;//of uSeqPropChange

  uChangeObject:begin             //изменение состояния объекта
   case GetTypeObjByID(SelObj.b.ObjectID) of
    typBONE:begin                 //кость
     bu:=TBoneUndo.Create;
     bu.TypeOfUndo:=uChangeObject;
     bu.Prev:=-1;
     bu.typ:=typBONE;
     bu.b:=SelObj.b;
     bu.IdInArray:=SelObj.b.ObjectID-Bones[0].ObjectID;
     NewUndo[CountOfNewUndo-1]:=bu;
    end;//of typBONE
    typHELP:begin                 //помощник
     bu:=TBoneUndo.Create;
     bu.TypeOfUndo:=uChangeObject;
     bu.Prev:=-1;
     bu.typ:=typHELP;
     bu.b:=SelObj.b;
     bu.IdInArray:=SelObj.b.ObjectID-Helpers[0].ObjectID;
     NewUndo[CountOfNewUndo-1]:=bu;
    end;//of typHELP
    typATCH:begin                 //аттач
     au:=TAtchUndo.Create;
     au.TypeOfUndo:=uChangeObject;
     au.Prev:=-1;
     au.typ:=typATCH;
     au.atch:=Attachments[SelObj.b.ObjectID-Attachments[0].Skel.ObjectID];
     au.IdInArray:=SelObj.b.ObjectID-Attachments[0].Skel.ObjectID;
     NewUndo[CountOfNewUndo-1]:=au;
    end;//of typHELP
    typPRE2:begin                 //ИЧ-2
     pr:=TPre2Undo.Create;
     pr.TypeOfUndo:=uChangeObject;
     pr.Prev:=-1;
     pr.typ:=typPRE2;
     pr.pre2:=pre2[SelObj.b.ObjectID-pre2[0].Skel.ObjectID];
     pr.IdInArray:=SelObj.b.ObjectID-pre2[0].Skel.ObjectID;
    end;//of typPRE2
   end;//of case
   Result:=1;
  end;//of uChangeObject

//----------------------------------------------------------
  uChangeObjects:begin            //создать полный слепок объектов
   su:=TStampObjUndo.Create;
   su.Prev:=-1;
   su.TypeOfUndo:=uChangeObjects;

   //копирование объектов
   //кости
   su.CountOfBones:=CountOfBones;
   SetLength(su.Bones,su.CountOfBones);
   for i:=0 to CountOfBones-1 do su.Bones[i]:=Bones[i];

   //Источники света
   su.CountOfLights:=CountOfLights;
   SetLength(su.Lights,CountOfLights);
   for i:=0 to CountOfLights-1 do su.Lights[i]:=Lights[i];

   //Помощники
   su.CountOfHelpers:=CountOfHelpers;
   SetLength(su.Helpers,CountOfHelpers);
   for i:=0 to CountOfHelpers-1 do su.Helpers[i]:=Helpers[i];

   //аттачи
   su.CountOfAttachments:=CountOfAttachments;
   SetLength(su.Attachments,CountOfAttachments);
   for i:=0 to CountOfAttachments-1 do su.Attachments[i]:=Attachments[i];

   //Источники частиц
   su.CountOfParticleEmitters1:=CountOfParticleEmitters1;
   SetLength(su.ParticleEmitters1,CountOfParticleEmitters1);
   for i:=0 to CountOfParticleEmitters1-1
   do su.ParticleEmitters1[i]:=ParticleEmitters1[i];

   //Источники частиц (вторая версия)
   su.CountOfParticleEmitters:=CountOfParticleEmitters;
   SetLength(su.pre2,CountOfParticleEmitters);
   for i:=0 to CountOfParticleEmitters-1 do su.pre2[i]:=pre2[i];

   //Источники следа
   su.CountOfRibbonEmitters:=CountOfRibbonEmitters;
   SetLength(su.Ribs,CountOfRibbonEmitters);
   for i:=0 to CountOfRibbonEmitters-1 do su.Ribs[i]:=Ribs[i];

   //События
   su.CountOfEvents:=CountOfEvents;
   SetLength(su.Events,CountOfEvents);
   for i:=0 to CountOfEvents-1 do su.Events[i]:=Events[i];

   //Объекты границ
   su.CountOfCollisionShapes:=CountOfCollisionShapes;
   SetLength(su.Collisions,CountOfCollisionShapes);
   for i:=0 to CountOfCollisionShapes-1 do su.Collisions[i]:=Collisions[i];

   NewUndo[CountOfNewUndo-1]:=su;
   Result:=1;
  end;//of uChangeObjects
//----------------------------------------------------------
  uCreateObject:begin             //создан объект
   pu:=TPivUndo.Create;           //создать новый объект
   pu.TypeOfUndo:=uCreateObject;
   pu.Prev:=-1;
   pu.id:=param;                  //id будущего объекта
   pu.IsDel:=false;
   if SelObj.IsSelected then pu.SelID:=SelObj.b.ObjectID
   else pu.SelID:=-1;
   NewUndo[CountOfNewUndo-1]:=pu; //точки сохранены
   SaveNewUndo(uChangeObjects,0); //запомнить состояние всех объектов
   TNewUndo(NewUndo[CountOfNewUndo-1]).Prev:=0; //есть предыдущий
   Result:=2;                     //кол-во ячеек массива
  end;//of uCreateObject

//---------------------------------------------------------  
  uSaveObjChange:begin            //слепок состояния vg/m/pp
   sg:=TStampGeoUndo.Create;
   sg.Prev:=-1;
   sg.TypeOfUndo:=uSaveObjChange;
   SetLength(sg.Geo,CountOfGeosets);

   //Копируем матрицы и группы
   for i:=0 to CountOfGeosets-1 do with sg do begin
    Geo[i].CountOfVertices:=Geosets[i].CountOfVertices;
    SetLength(Geo[i].VertexGroup,Geo[i].CountOfVertices);
    for ii:=0 to Geo[i].CountOfVertices-1
    do Geo[i].VertexGroup[ii]:=Geosets[i].VertexGroup[ii];
    Geo[i].CountOfMatrices:=Geosets[i].CountOfMatrices;
    SetLength(Geo[i].Groups,Geo[i].CountOfMatrices);
    for ii:=0 to Geosets[i].CountOfMatrices-1 do begin
     SetLength(Geo[i].Groups[ii],length(Geosets[i].Groups[ii]));
     for j:=0 to High(Geosets[i].Groups[ii])
     do Geo[i].Groups[ii,j]:=Geosets[i].Groups[ii,j];
    end;//of for ii
   end;//of for i

   //Копируем геометрические центры
   sg.CountOfPivotPoints:=CountOfPivotPoints;
   SetLength(sg.PivotPoints,CountOfPivotPoints);
   for i:=0 to CountOfPivotPoints-1 do sg.PivotPoints[i]:=PivotPoints[i];

   //Сохраним ID выделенного объекта
   if SelObj.IsMultiSelect and (SelObj.CountOfSelObjs>0) then begin
    sg.SelID:=SelObj.SelObjs[0];
   end else sg.SelID:=SelObj.b.ObjectID;

   //Сохраним список ID выделенных объектов (если есть)
   if not SelObj.IsMultiSelect then sg.len:=0 else begin
    sg.len:=SelObj.CountOfSelObjs;
    SetLength(sg.lst,sg.len);
    for i:=0 to sg.len-1 do sg.lst[i]:=SelObj.SelObjs[i];
   end;//of if

   //Остаточная работа ;)
   NewUndo[CountOfNewUndo-1]:=sg;
   Result:=1;
  end;//of uSaveObjChange
//----------------------------------------------------------
  uCreateController:begin
   cc:=TNewControllerUndo.Create;
   cc.Prev:=-1;
   cc.TypeOfUndo:=uCreateController;
   cc.Save;                       //запись состояния
   NewUndo[CountOfNewUndo-1]:=cc;
  end;//of uCreateController
//----------------------------------------------------------
  uDeleteController:begin
   dc:=TDelControllerUndo.Create;
   dc.Prev:=CountOfNewUndo-2;
   dc.TypeOfUndo:=uDeleteController;
   dc.ContID:=param;              //не забыть про параметр!
   dc.Save;
   NewUndo[CountOfNewUndo-1]:=dc;
  end;//of uDeleteController
//----------------------------------------------------------
  uTransBone:begin                //начальный фрагмент сохранения
   skf:=TChangeObjKFUndo.Create;
   skf.Prev:=-1;
   skf.TypeOfUndo:=uTransBone;
   NewUndo[CountOfNewUndo-1]:=skf;
  end;//of uTransBone
//----------------------------------------------------------
  uSmoothGroups:begin             //группы сглаживания
   smg:=TSaveSmoothGroups.Create;
   smg.Prev:=-1;
   smg.TypeOfUndo:=uSmoothGroups;
   smg.Save;
   NewUndo[CountOfNewUndo-1]:=smg;
  end;//of uSmoothGroups
 end;//of case

 PopFunction;
End;
//---------------------------------------------------------
//То же - для редактора анимаций
//!Нужно отлаживать
procedure AnimSaveUndo(action:cardinal;param:integer);
Var Cur,i,j,len{,ii},ID:integer;
    {b:TBone;}IsBone:boolean;
Begin
 PushFunction(306);
 IsModified:=true;//модель модифицирована
 //0. Ищем пустое место в списке отмен
 Cur:=ShearUndo;
 //Проверка на сдвиг
 if (action and uFrameAdd)=uFrameAdd then begin
  Undo[Cur].Status1:=uFrameAdd;
  Undo[Cur].Status2:=action and $FFFFFF;
  Undo[Cur].MatID:=CurFrame;
  Undo[Cur].SelGroup:=UsingGlobalSeq;
 end;//of if

 //Проверка на всё остальное
 case action of
  uSeqPropChange,uCreateSeq,uDeleteSeq:begin //Изменены параметры анимации
   Undo[Cur].Status1:=uUseNewUndo;
   Undo[Cur].status2:=SaveNewUndo(action,param);
{   Undo[Cur].Status1:=uSeqPropChange;
   Undo[Cur].Status2:=param;
   Undo[Cur].Sequence:=Sequences[param-1];}
  end;

{  uSeqDurationChange:begin//изменить длительность глоб. ан.
   Undo[Cur].Status1:=uSeqDurationChange;
   Undo[Cur].Status2:=param;
   Undo[Cur].MatID:=GlobalSequences[param];
  end;}

{  uCreateSeq:begin
   Undo[Cur].Status1:=uCreateSeq;
  end;//of uCreateSeq

  uCreateGlobalSeq:Undo[Cur].Status1:=uCreateGlobalSeq;}

  uEmittersOff:begin    //"гашение" источников частиц
   Undo[Cur].Status1:=uEmittersOff;
   len:=0;
   for i:=0 to CountOfParticleEmitters1-1 do with ParticleEmitters1[i] do begin
    if Skel.Visibility<0 then continue;
    if Controllers[Skel.Visibility].GlobalSeqId>=0 then continue;
    inc(len);
    SetLength(Undo[Cur].Controllers,len);
    SetLength(Undo[Cur].idata,len);
    cpyController(Controllers[Skel.Visibility],Undo[Cur].Controllers[len-1]);
    Undo[Cur].idata[len-1]:=Skel.Visibility;
   end;//of for i
   for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
    if Skel.Visibility<0 then continue;
    if Controllers[Skel.Visibility].GlobalSeqId>=0 then continue;
    inc(len);
    SetLength(Undo[Cur].Controllers,len);
    SetLength(Undo[Cur].idata,len);
    cpyController(Controllers[Skel.Visibility],Undo[Cur].Controllers[len-1]);
    Undo[Cur].idata[len-1]:=Skel.Visibility;
   end;//of for i
  end;//of uEmittersOff

{  uDeleteGlobalSeq:begin     //удаление глобальной последовательности
   Undo[Cur].Status1:=uDeleteGlobalSeq;
   len:=0;
   //Перестраховка
   SetLength(Undo[Cur].idata,1);
   Undo[Cur].idata[0]:=-1;
   //Начинаем поиск контроллеров с нужной GlobalSeqID
   for i:=0 to High(Controllers) do
   if Controllers[i].GlobalSeqId=UsingGlobalSeq then begin
    inc(len);
    SetLength(Undo[Cur].idata,len);
    Undo[Cur].idata[len-1]:=i;    //запоминаем ID контроллера
   end;//of for i
   //Запоминаем номер GlobalSeq и её длительность:
   Undo[Cur].Status2:=UsingGlobalSeq;
   Undo[Cur].MatID:=GlobalSequences[UsingGlobalSeq];
  end;//of uDeleteGlobalSeq

  uDeleteSeq:begin                //Удаление последовательности
   Undo[Cur].Status1:=uDeleteSeq;
   Undo[Cur].Status2:=param-1;
   Undo[Cur].Sequence:=Sequences[param-1];
   //Запоминаем Anim, которая потом удалится
   for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
    if (Geosets[j].CountOfAnims>=param-1) and (Geosets[j].CountOfAnims>0)
    then begin
     SetLength(Undo[Cur].Anims,1);
     Undo[Cur].Anims[0]:=Geosets[j].Anims[param-1];
    end else Undo[Cur].Anims:=nil;//of if
   end;//of with/for j
  end;//of uDeleteSeq }

  uPasteFrames:begin              //вставка кадров из буфера
   Undo[Cur].Status1:=uPasteFrames;
   len:=High(FrameBuffer);
   SetLength(Undo[Cur].Controllers,len+1);
   Undo[Cur].Status2:=len+1;
   SetLength(Undo[Cur].idata,2*(len+1));
   SetLength(Undo[Cur].VertexGroup,len+1);
   //Собственно цикл копирования
   for i:=0 to len do begin
    //1. Получаем ID контроллера, данные которого сохраняются
    ID:=FrameBuffer[i].SizeOfElement;

    //2. Сохраняем MaxFrame и MinFrame
    Undo[Cur].idata[i*2]:=FrameBuffer[i].Items[0].Frame+CurFrame;
    Undo[Cur].idata[i*2+1]:=
     FrameBuffer[i].Items[High(FrameBuffer[i].Items)].Frame+CurFrame;

    //3. Копируем фрагменты
    Undo[Cur].Controllers[i]:=Controllers[ID];
    Undo[Cur].Controllers[i].Items:=nil;
    Undo[Cur].VertexGroup[i]:=ID;
    if not CopyFrames(Controllers[ID],Undo[Cur].Controllers[i],
                      Undo[Cur].idata[i*2],Undo[Cur].idata[i*2+1],
                      Undo[Cur].idata[i*2],-1)
    then Undo[Cur].Controllers[i].SizeOfElement:=0;      
   end;//of for i
  end;//of uPasteFrames

  uChangeFrame:begin              //изменён текущий кадр
   Undo[Cur].Status1:=uChangeFrame;
   Undo[Cur].Status2:=0;
  end;//of uChangeFrame

  uSelectObject:begin             //изменено выделение объекта
   Undo[Cur].Status1:=uSelectObject;
   Undo[Cur].Status2:=SelObj.b.ObjectID;
   Undo[Cur].Unselectable:=SelObj.IsMultiSelect;
   if SelObj.IsMultiSelect then begin
    Undo[Cur].SelGroup:=SelObj.CountOfSelObjs;
    SetLength(Undo[Cur].idata,Undo[Cur].SelGroup);
    for i:=0 to Undo[Cur].SelGroup-1 do Undo[Cur].idata[i]:=SelObj.SelObjs[i];
   end;//of if
  end;//of uSelectObject

  uChangeObjName:begin            //меняется имя объекта
   Undo[Cur].Status1:=uChangeObjName;
   Undo[Cur].Status2:=SelObj.b.ObjectID;
   Undo[Cur].Sequence.Name:=SelObj.b.Name;
  end;//of uChangeObjName

  uChangeObject:begin             //изменено состояние объекта
   Undo[Cur].status1:=uUseNewUndo;
   Undo[Cur].status2:=SaveNewUndo(uChangeObject,0);
  end;//of uChangeObject

  uCreateObject:begin             //создан новый объект
   Undo[Cur].status1:=uUseNewUndo;
   Undo[Cur].status2:=SaveNewUndo(uCreateObject,param);
  end;//of uCreateObject

  uDeleteObject:begin             //объект удалён
   Undo[Cur].status1:=uUseNewUndo;
   Undo[Cur].status2:=2;
   SaveNewUndo(uSaveObjChange,0); //выделенный объект+Matrices+VertexGroup
   SaveNewUndo(uChangeObjects,0); //полный слепок объектов
   NewUndo[CountOfNewUndo-1].Prev:=0;
  end;//of uDeleteObject

  uDeleteObjects:begin
   Undo[Cur].status1:=uDeleteObjects;
   Undo[Cur].status2:=2;
   SaveNewUndo(uSaveObjChange,0); //выделенный объект+Matrices+VertexGroup
   SaveNewUndo(uChangeObjects,0); //полный слепок объектов
   NewUndo[CountOfNewUndo-1].Prev:=0;
    { TODO 1 -oАлексей -cОшибка : Возможно, ошибка. Почему Prev=0? }
  end;//of uDeleteObjects

  uPivotChange:begin              //изменение геом. центра
   Undo[Cur].status1:=uPivotChange;
   Undo[Cur].Unselectable:=false;
   if SelObj.IsMultiSelect then begin
    Undo[Cur].Unselectable:=true;
    Undo[Cur].status2:=SelObj.CountOfSelObjs;
    SetLength(Undo[Cur].Vertices,SelObj.CountOfSelObjs);
    SetLength(Undo[Cur].idata,SelObj.CountOfSelObjs);
    for i:=0 to Undo[Cur].status2-1 do begin
     Undo[Cur].idata[i]:=SelObj.SelObjs[i];
     Undo[Cur].Vertices[i]:=PivotPoints[SelObj.SelObjs[i]];
    end;//of for i
   end else begin
    Undo[Cur].status2:=SelObj.b.ObjectID;
    if SelObj.b.ObjectID>=0 then
     Undo[Cur].Sequence.Bounds.MinimumExtent:=PivotPoints[SelObj.b.ObjectID];
   end;
  end;//of uPivotChange

  uAttachObject:begin             //аттач объекта
   Undo[Cur].status1:=uAttachObject;
   Undo[Cur].status2:=ChObj.b.ObjectID;
   Undo[Cur].SelGroup:=ChObj.b.Parent;
  end;//of uAttachObject

  uDetachObject:begin             //отсоединение объекта
   Undo[Cur].status1:=uDetachObject;
   Undo[Cur].status2:=SelObj.b.Parent;
  end;//of uDetachObject

  uSelectObjects:begin            //выделение группы объектов
   Undo[Cur].status1:=uSelectObjects;
   Undo[Cur].status2:=SelObj.CountOfSelObjs;
   SetLength(Undo[Cur].Faces,1);
   SetLength(Undo[Cur].Faces[0],SelObj.CountOfSelObjs);
   for i:=0 to SelObj.CountOfSelObjs-1
   do Undo[Cur].Faces[0,i]:=SelObj.SelObjs[i];
  end;//of uSelectObjects

  uCreateController:begin
   Undo[Cur].status1:=uUseNewUndo;
   SaveNewUndo(uCreateController,0);
  end;//of uCreateController

  uDeleteController:begin
   Undo[Cur].status1:=uUseNewUndo;
   SaveNewUndo(uChangeObject,0);
   SaveNewUndo(uDeleteController,param);
   NewUndo[CountOfNewUndo-1].Prev:=0;
  end;

  uTransBone:begin                //любые преобразования тек. КК скел. объекта
   Undo[Cur].status1:=uUseNewUndo;
   SaveNewUndo(uTransBone,0);
  end;//of uTransBone
 end;//of case
 PopFunction;
End;
//---------------------------------------------------------
//Определяет, скрыта ли данная вершина:
function IsVertexHide(geoID,num:integer):boolean;
Var i:integer;
Begin with geoobjs[geoID] do begin
 IsVertexHide:=false;             //пока считаем, что не скрыта
 if HideVertexCount=0 then exit;  //нет скрытых вершин
 PushFunction(307);
 for i:=0 to HideVertexCount-1 do if HideVertices[i]=num then begin
  IsVertexHide:=true;
  PopFunction;
  exit;
 end;//of for/if
 PopFunction;
end;End;
//---------------------------------------------------------
//Удаляет выделенные треугольники, сдвигая массив Faces.
//Одновременно заполняются массивы Undo для отмены
//Возвращает true при успехе
function DeleteTriangles:boolean;
Var i,{ii,}j,Cur:integer;IsDo:boolean;
Begin
 PushFunction(308);
 DeleteTriangles:=false;
 //1. Проверим, нужно ли вообще что-то удалять.
 //Заодно составим массивы SelFaces
 IsDo:=false;
 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected then begin
  FindNumbersSelFaces(j+1);
  if length(GeoObjs[j].SelFaces)>0 then IsDo:=true;
 end;//of for j
 if not IsDo then begin PopFunction;exit;end;//ничего не выделено

 //2. Запомним массив Faces
 Result:=true;
 Cur:=ShearUndo;                  //выделить место
 Undo[Cur].Status1:=uDeleteTriangle;

 for j:=0 to CountOfGeosets-1 do with Geosets[j],GeoObjs[j] do begin
  Undo[Cur].Status1:=uDeleteTriangle;
  if (not IsSelected) or (length(GeoObjs[j].SelFaces)=0) then begin
   Undo[Cur].Status2:=0;
   continue;
  end;//of if
  //Вначале сохраним список треугольников
  Undo[Cur].Status2:=length(Faces[0]);
  SetLength(Undo[Cur].idata,Undo[Cur].Status2);
  for i:=0 to Undo[Cur].Status2-1 do Undo[Cur].idata[i]:=Faces[0,i];

  //Теперь удалим выделенные
  for i:=0 to High(SelFaces) do begin
   Faces[0,SelFaces[i]]:=-1;
   Faces[0,SelFaces[i]+1]:=-1;
   Faces[0,SelFaces[i]+2]:=-1;
  end;//of for i
  FinalizeDeleting(j+1);
 end;//of with/for j
 PopFunction;
End;
//---------------------------------------------------------
//Копирует выделенный кусок поверхности
//в специальный буфер (ClpBrd).
procedure CopyToInternalBuffer;
Var i,ii,j:integer;
Begin for j:=0 to CountOfGeosets-1 do with Geosets[j],geoobjs[j] do begin
 if not IsSelected then begin
  IsBufferActive:=false;
  continue;
 end;//of if
 PushFunction(309);
 IsBufferActive:=true;
 //1. Заполним "количественные" поля.
 InternalBuffer.CountOfVertices:=VertexCount;
 InternalBuffer.CountOfNormals:=VertexCount;
 InternalBuffer.CountOfCoords:=CountOfCoords;
 SetLength(InternalBuffer.Crds,CountOfCoords);
 SetLength(InternalBuffer.Vertices,VertexCount);
 SetLength(InternalBuffer.Normals,VertexCount);
 SetLength(InternalBuffer.VertexGroup,VertexCount);
 SetLength(InternalNums,VertexCount);
 //2. Копируем часть полей (наиболее простые)
 for i:=0 to VertexCount-1 do begin
  //Вершины
  InternalBuffer.Vertices[i,1]:=Vertices[VertexList[i]-1,1];
  InternalBuffer.Vertices[i,2]:=Vertices[VertexList[i]-1,2];
  InternalBuffer.Vertices[i,3]:=Vertices[VertexList[i]-1,3];
  //Нормали
  InternalBuffer.Normals[i,1]:=Normals[VertexList[i]-1,1];
  InternalBuffer.Normals[i,2]:=Normals[VertexList[i]-1,2];
  InternalBuffer.Normals[i,3]:=Normals[VertexList[i]-1,3];
  //Группы вершин
  InternalBuffer.VertexGroup[i]:=VertexGroup[VertexList[i]-1];
  //номера вершин
  InternalNums[i]:=VertexList[i]-1;
 end;//of for

 //Копируем текстурные вершины
 for i:=0 to CountOfCoords-1 do begin
  InternalBuffer.Crds[i].CountOfTVertices:=VertexCount;
  SetLength(InternalBuffer.Crds[i].TVertices,VertexCount);
  for ii:=0 to VertexCount-1 do begin
   InternalBuffer.Crds[i].TVertices[ii,1]:=
      Crds[i].TVertices[VertexList[ii]-1,1];
   InternalBuffer.Crds[i].TVertices[ii,2]:=
      Crds[i].TVertices[VertexList[ii]-1,2];
  end;//of for ii
 end;//of for i
 
 //Заполняем список треугольников
 FindSelectedFaces(j+1);
 //Копируем треугольники в буфер
 SetLength(InternalBuffer.Faces,1);
 SetLength(InternalBuffer.Faces[0],length(SelFaces));
 for i:=0 to length(SelFaces)-1 do InternalBuffer.Faces[0,i]:=SelFaces[i];
 PopFunction;
end;End;
//---------------------------------------------------------
//Вставляет в активные поверхности кусоки из внутренних буферов
procedure PasteFromInternalBuffer;
Var i,ii,j,jj,tmp,VCount,len,len2,ActCount,ActID:integer;
Begin
PushFunction(310);
//1. Подсчитаем кол-во активных поверхностей
ActCount:=0;ActID:=-1;
for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected then begin
 inc(ActCount);
 ActID:=j;
 GeoObjs[j].VertexCount:=0;       //сброс выделенных вершин
end;//of for j
for j:=0 to CountOfGeosets-1 do with Geosets[j],geoobjs[j] do begin
 if ((ActCount<>1) and (not IsSelected)) or (not IsBufferActive) then continue;
 if ActCount<>1 then ActID:=j;
 VCount:=Geosets[ActID].CountOfVertices;//запомнить текущее кол-во вершин
 //1. Добавим вершины (в т.ч. в VertexList)
 Geosets[ActID].CountOfVertices:=Geosets[ActID].CountOfVertices+
  InternalBuffer.CountOfVertices;
 SetLength(Geosets[ActID].Vertices,Geosets[ActID].CountOfVertices);
 GeoObjs[ActID].VertexCount:=GeoObjs[ActID].VertexCount+
  InternalBuffer.CountOfVertices;
 SetLength(GeoObjs[ActID].VertexList,GeoObjs[ActID].VertexCount);
 for i:=0 to InternalBuffer.CountOfVertices-1 do begin
  Geosets[ActID].Vertices[VCount+i,1]:=InternalBuffer.Vertices[i,1]{-5};
  Geosets[ActID].Vertices[VCount+i,2]:=InternalBuffer.Vertices[i,2]{-5};
  if IsDisp then Geosets[ActID].Vertices[VCount+i,3]:=InternalBuffer.Vertices[i,3]-5
  else Geosets[ActID].Vertices[VCount+i,3]:=InternalBuffer.Vertices[i,3];
  GeoObjs[ActID].VertexList[i]:=VCount+i+1;//добавка в список выделения
 end;//of for
 //2. Добавка нормалей
 Geosets[ActID].CountOfNormals:=Geosets[ActID].CountOfNormals+
  InternalBuffer.CountOfNormals;
 SetLength(Geosets[ActID].Normals,Geosets[ActID].CountOfNormals);
 for i:=0 to InternalBuffer.CountOfVertices-1 do begin
  Geosets[ActID].Normals[VCount+i,1]:=InternalBuffer.Normals[i,1];
  Geosets[ActID].Normals[VCount+i,2]:=InternalBuffer.Normals[i,2];
  Geosets[ActID].Normals[VCount+i,3]:=InternalBuffer.Normals[i,3];
 end;//of for
 
 //3. Добавка текстурных вершин
 Geosets[ActID].CountOfCoords:=InternalBuffer.CountOfCoords;
 SetLength(Geosets[ActID].Crds,Geosets[ActID].CountOfCoords);
 for jj:=0 to InternalBuffer.CountOfCoords-1 do begin
  //Установить длину (кол-во вершин)
  Geosets[ActID].Crds[jj].CountOfTVertices:=
    Geosets[ActID].Crds[jj].CountOfTVertices+
    InternalBuffer.Crds[jj].CountOfTVertices;
  SetLength(Geosets[ActID].Crds[jj].TVertices,
            Geosets[ActID].Crds[jj].CountOfTVertices);
  //копировать сами вершины
  for i:=0 to InternalBuffer.CountOfVertices-1 do begin
   Geosets[ActID].Crds[jj].TVertices[VCount+i,1]:=
        InternalBuffer.Crds[jj].TVertices[i,1];
   Geosets[ActID].Crds[jj].TVertices[VCount+i,2]:=
        InternalBuffer.Crds[jj].TVertices[i,2];
  end;//of for i
 end;//of for jj

 //4. Добавка групп вершин
 SetLength(Geosets[ActID].VertexGroup,Geosets[ActID].CountOfVertices);
 for i:=0 to InternalBuffer.CountOfVertices-1 do if ActCount=1 then
  Geosets[ActID].VertexGroup[VCount+i]:=InternalBuffer.VertexGroup[i]
 else Geosets[ActID].VertexGroup[VCount+i]:=0;//of for
 //5. Добавка разворотов (треугольников)
 len:=length(Geosets[ActID].Faces); //определить размер массива
 len2:=length(Geosets[ActID].Faces[len-1]);
 SetLength(Geosets[ActID].Faces[len-1],len2+length(InternalBuffer.Faces[0]));
 for i:=0 to length(InternalBuffer.Faces[0])-1 do begin
  tmp:=InternalBuffer.Faces[0,i];
  //поиск номера вершины в списке
  for ii:=0 to length(InternalNums)-1 do if InternalNums[ii]=tmp then break;
  //преобразование номеров
  Geosets[ActID].Faces[len-1,len2+i]:=ii+VCount;
 end;//of for
 PopFunction;
end;End;
//---------------------------------------------------------
//Копирует выделенный кусок поверхности из
//InternalBuffer+CurrentGeoset в файл подкачки (проецирование)
//вместе с соответствующими текстурами/материалом
procedure CopyToExternalBuffer;
Var j,i,ii,TexID:integer;
    MatIDList,TexIDList:array of integer;
    COMatIDs,COTexIDs:integer;
    IsFound:boolean;
Begin
 PushFunction(311);
 FillChar(ExternalBuffer,SizeOf(ExternalBuffer),#0);
 ExternalBuffer.IsActive:=true;   //буфер активен
 COMatIDs:=0;COTexIDs:=0;
 ExternalBuffer.COGeosets:=0;
 //Пробегаем по поверхностям, подлежащим копированию
 for j:=0 to CountOfGeosets-1 do with {geosets[j],}geoobjs[j] do
 if IsSelected and (VertexCount<>0) then begin
  //Выделить место под буфер куска
  inc(ExternalBuffer.COGeosets);
  SetLength(ExternalBuffer.InternalBuffers,ExternalBuffer.COGeosets);
  SetLength(ExternalBuffer.InternalNums,ExternalBuffer.COGeosets);  
  //Копируем содержимое соответствующего внутреннего буфера
  cpyGeoset(InternalBuffer,
            ExternalBuffer.InternalBuffers[ExternalBuffer.COGeosets-1]);
  SetLength(ExternalBuffer.InternalNums[ExternalBuffer.COGeosets-1],
            length(InternalNums));
  for i:=0 to High(InternalNums) do
      ExternalBuffer.InternalNums[ExternalBuffer.COGeosets-1,i]:=InternalNums[i];
  //Сохранение в буфере списка связанных текстур и материалов
  with ExternalBuffer.InternalBuffers[ExternalBuffer.COGeosets-1] do begin
   IsFound:=false;                //пока не найдено
   for i:=0 to COMatIDs-1 do if MatIDList[i]=Geosets[j].MaterialID then begin
    IsFound:=true;                //материал уже в списке
    MaterialID:=i;                //списочный ID
    break;                        //конец цикла
   end;//of if/for i

   //Если материала ещё нет в буфере, скопировать его
   if not IsFound then begin
    //Дополнить список ID
    inc(COMatIDs);
    SetLength(MatIDList,COMatIDs);
    MatIDList[COMatIDs-1]:=Geosets[j].MaterialID;
    MaterialID:=COMatIDs-1;
    //Скопировать материал
    inc(ExternalBuffer.COMaterials);
    SetLength(ExternalBuffer.Materials,ExternalBuffer.CoMaterials);
    cpyMaterial(Materials[Geosets[j].MaterialID],
                ExternalBuffer.Materials[ExternalBuffer.CoMaterials-1]);

    //Скопировать все текстуры, связанные с материалом
    for i:=0 to Materials[Geosets[j].MaterialID].CountOfLayers-1 do begin
     IsFound:=false;               //пока текстуры не найдены
     with Materials[Geosets[j].MaterialID].Layers[i] do
      if IsTextureStatic then TexID:=TextureID
                     else TexID:=round(Controllers[TextureID].Items[0].Data[1]);
     for ii:=0 to COTexIDs-1 do if TexIDList[ii]=TexID then begin
      IsFound:=true;
      ExternalBuffer.Materials[ExternalBuffer.CoMaterials-1].Layers[i].TextureID
      :=TexIDList[ii];
      break;
     end;//of for ii

     //Если не найдено, скопировать текстуру в буфер
     if not IsFound then begin
      inc(COTexIDs);SetLength(TexIDList,COTexIDs);
      TexIDList[COTexIDs-1]:=TexID;
      ExternalBuffer.Materials[ExternalBuffer.CoMaterials-1].Layers[i].TextureID
      :=CoTexIDs-1;
      inc(ExternalBuffer.CoTextures);
      SetLength(ExternalBuffer.Textures,ExternalBuffer.COTextures);
      ExternalBuffer.Textures[ExternalBuffer.COTextures-1]:=Textures[TexID];
     end;//of if
    end;//of for i (по слоям)
   end;//of if(not IsFound - Material)
  end;//of with
 end;//of for j
 PopFunction;
End;

//Вставляет новую поверхность с использованием внешнего буфера
//и точки прикрепления
procedure PasteFromExternalBuffer;
Var i,ii,j,jj,k,mi,len,tmp,num,CurrentGeosetNum,CurGeoNum,coDel,tid:integer;
    nm:string;
Begin
 PushFunction(312);
 CurGeoNum:=-1;
 //Ищем номер активной поверхности
 for i:=0 to CountOfGeosets-1 do
 if geoObjs[i].IsSelected and (geoobjs[i].VertexCount=1) then begin
  CurGeoNum:=i;
  break;
 end;//of for i
 if CurGeoNum<0 then begin PopFunction;exit;end; //перестраховка
 CurrentGeosetNum:=CurGeoNum;
 //Если нужно, добавим GeosetAnim
 if CountOfGeosets=CountOfGeosetAnims then with ExternalBuffer do begin
  CountOfGeosetAnims:=CountOfGeosetAnims+COGeosets;
  SetLength(GeosetAnims,CountOfGeosetAnims);
  ii:=0;
  for i:=CountOfGeosetAnims-COGeosets to CountOfGeosetAnims-1 do
  with GeosetAnims[i] do begin
   Alpha:=1;IsAlphaStatic:=true;
   Color[1]:=1;Color[2]:=1;Color[3]:=1;
   IsColorStatic:=true;
   GeosetID:=CountOfGeosets+ii;inc(ii);
  end;//of with/for i
 end;//of with/if (AddNewAnim)

 //Собственно работа с буферами
 with ExternalBuffer do begin
  //1. Увеличим список поверхностей
  CountOfGeosets:=CountOfGeosets+COGeosets;
  SetLength(Geosets,CountOfGeosets);
  SetLength(Geoobjs,CountOfGeosets);
  j:=0;
  for mi:=CountOfGeosets-COGeosets to CountOfGeosets-1 do
  with geoobjs[mi],geosets[mi] do begin
   num:=GeoObjs[CurrentGeosetNum].VertexList[0]-1;
   //2. Заполним (частично) новую поверхность
//   Geosets[mi]:=ExternalBuffer.InternalBuffers[j];
   CountOfVertices:=ExternalBuffer.InternalBuffers[j].CountOfVertices;
   SetLength(Vertices,CountOfVertices);
   SetLength(Normals,CountOfVertices);
   CountOfCoords:=ExternalBuffer.InternalBuffers[j].CountOfCoords;
   SetLength(Crds,CountOfCoords);
   for i:=0 to CountOfCoords-1 do begin
    Crds[i].CountOfTVertices:=CountOfVertices;
    SetLength(Crds[i].TVertices,CountOfVertices);
   end;//of for i
   SetLength(VertexGroup,CountOfVertices);
   CountOfNormals:=CountOfVertices;
   //5. Добавка разворотов (треугольников)
   SetLength(Faces,1);
   Faces[0]:=nil;
   SetLength(Faces[0],length(ExternalBuffer.InternalBuffers[j].Faces[0]));
   for i:=0 to High(ExternalBuffer.InternalBuffers[j].Faces[0]) do begin
    tmp:=ExternalBuffer.InternalBuffers[j].Faces[0,i];
    //поиск номера вершины в списке
    for ii:=0 to High(ExternalBuffer.InternalNums[j]) do
        if ExternalBuffer.InternalNums[j,ii]=tmp then break;
    //преобразование номеров
    Faces[0,i]:=ii;
   end;//of for
   
   for i:=0 to CountOfVertices-1 do begin
    Vertices[i]:=ExternalBuffer.InternalBuffers[j].Vertices[i];
   end;//of for i

   for i:=0 to CountOfCoords-1 do for ii:=0 to CountOfVertices-1 do begin
    Crds[i].TVertices[ii]:=
        ExternalBuffer.InternalBuffers[j].Crds[i].TVertices[ii];
   end;//of for i

   Geosets[mi].CountOfFaces:=1;
   Geosets[mi].CountOfMatrices:=1;
   MaterialID:=CountOfMaterials+ExternalBuffer.InternalBuffers[j].MaterialID;//Geosets[mi].MaterialID;
   VertexList:=nil;                 //очистка списка выделения
   VertexCount:=0;
   //3. Обнулим массив групп вершин
   for i:=0 to length(VertexGroup)-1 do VertexGroup[i]:=0;
   //4. Создать группу прикрепления
   SetLength(Groups,1);            //только 1 элемент
   num:=Geosets[CurGeoNum].VertexGroup[num];//считать номер группы
   len:=length(Geosets[CurGeoNum].Groups[num]);//узнать длину
   SetLength(Groups[0],len);       //установить размер группы
   for ii:=0 to len-1 do Groups[0,ii]:=Geosets[CurGeoNum].Groups[num,ii];
   //5. Скопировать границы анимаций
   CountOfAnims:=Geosets[0].CountOfAnims;
   if CountOfAnims=0 then SetLength(Anims,1) else SetLength(Anims,CountOfAnims);
   //6. Установить границы поверхности
   CalcBounds(mi,Anims[0]);
   MinimumExtent:=Anims[0].MinimumExtent;
   MaximumExtent:=Anims[0].MaximumExtent;
   BoundsRadius:=Anims[0].BoundsRadius;
   if CountOfAnims=0 then Anims:=nil;
   for i:=1 to CountOfAnims-1 do Anims[i]:=Anims[0];
   //7. Создать (если нужно) фиктивный треугольник
   if length(Faces[0])=0 then begin
    SetLength(Faces[0],3);
    Faces[0,0]:=0;Faces[0,1]:=0;Faces[0,2]:=0;
   end;//of if
   //8. Доустановка
   SelectionGroup:=0;Unselectable:=false;
   CurrentListNum:=0;
   inc(j);
  end;//of with/for mi
 end;//of with ExternalBuffer

 //9. Теперь скопируем добавочные текстуры
 CountOfTextures:=CountOfTextures+ExternalBuffer.CoTextures;
 coDel:=0;                        //пока нет пропусков
 SetLength(Textures,CountOfTextures);
 j:=0;
 for i:=CountOfTextures-ExternalBuffer.COTextures to CountOfTextures-1 do begin
  Textures[i]:=ExternalBuffer.Textures[j];
  Textures[i].pImg:=nil;
  Textures[i].ListNum:=0;
  inc(j);
 end;//of for i
 CountOfTextures:=CountOfTextures-ExternalBuffer.CoTextures;

 //10. Создаём добавочные материалы.
 CountOfMaterials:=CountOfMaterials+ExternalBuffer.COMaterials;
 SetLength(Materials,CountOfMaterials);
 j:=0;
 for i:=CountOfMaterials-ExternalBuffer.CoMaterials to CountOfMaterials-1
 do begin
  cpyMaterial(ExternalBuffer.Materials[j],Materials[i]);
  with Materials[i] do begin
   ListNum:=0;IsConstantColor:=false;
   for ii:=0 to CountOfLayers-1 do begin
    Layers[ii].TextureID:=Layers[ii].TextureID+CountOfTextures-coDel;
    Layers[ii].IsTextureStatic:=true;
    if not Layers[ii].IsAlphaStatic then begin
     Layers[ii].IsAlphaStatic:=true;
     Layers[ii].Alpha:=1;
    end;//of if(not IsAlphaStatic)
    Layers[ii].TVertexAnimID:=-1;
//(уже скопировано)    Layers[ii].CoordID:=-1;

   end;//of for ii
  end;//of with Materials[i]
  inc(j);
 end;//of for i
 CountOfTextures:=CountOfTextures+ExternalBuffer.CoTextures-CoDel;
 SetLength(Textures,CountOfTextures);

 //Проведём удаление дублирующихся текстур
 DeleteDublicateTextures;

 //Теперь заполним geoobjs новых поверхностей
 for j:=CountOfGeosets-ExternalBuffer.COGeosets to CountOfGeosets-1 do
 with geoobjs[j],geosets[j] do begin
  IsDelete:=false;
  IsBufferActive:=false;
  HideVertexCount:=0;
  VertexCount:=CountOfVertices;
  SetLength(VertexList,VertexCount);
  for i:=1 to CountOfVertices do VertexList[i-1]:=i;
 end;//of for j

 //Сбрасываем выделение вершины прикрепления
 GeoObjs[CurrentGeosetNum].VertexCount:=0;
 PopFunction;
End;
//---------------------------------------------------------
//Частично очищает буфер, оставляя там только кусок поверхности
//!Пока не работает
procedure ResetBuffer;
//Var i:integer;
Begin
{ for i:=0 to length(InternalBuffer.VertexGroup)-1 do
        InternalBuffer.VertexGroup[i]:=0;}
End;
//---------------------------------------------------------
//Обращает нормали. Масcивы SelFaces в поверхностях
//должны быть заполнены заранее вызовом FindSelectedFaces 
procedure SwapNormals;
Var j,i,len,tmp:integer;
Begin
 PushFunction(313);
 for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
  if SelFaces=nil then continue;  //нет выделенных треугольников
  i:=0;len:=High(SelFaces);
  repeat
   tmp:=Geosets[j].Faces[0,SelFaces[i]];
   Geosets[j].Faces[0,SelFaces[i]]:=Geosets[j].Faces[0,SelFaces[i]+2];
   Geosets[j].Faces[0,SelFaces[i]+2]:=tmp;
   inc(i);
  until i>len;
  ReCalcNormals(j+1);
  SmoothWithNormals(j);
 end;//of with/for j
 ApplySmoothGroups;
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательные: чтение числа
function Get3DSInt(var ps:integer):integer;
Var ans:integer;
Begin
 Move(pointer(ps)^,ans,4);
 ps:=ps+4;
 Get3DSInt:=ans;
End;
function Get3DSWord(var ps:integer):integer;
Var ans:integer;
Begin
 ans:=0;
 Move(pointer(ps)^,ans,2);
 ps:=ps+2;
 Get3DSWord:=ans;
End;
function Get3DSFloat(var ps:integer):single;
Var ans:single;
Begin
 ans:=0;
 Move(pointer(ps)^,ans,4);
 ps:=ps+4;
 Get3DSFloat:=ans;
End;
function Get3DSByte(var ps:integer):integer;
Var ans:integer;
Begin
 ans:=0;
 Move(pointer(ps)^,ans,1);
 ps:=ps+1;
 Get3DSByte:=ans;
End;


//осуществляет создание очередной поверхности для импорта 3DS
procedure CreateGeoset(var tvn:integer;var FirstFlag:boolean);
Begin
 PushFunction(314);
 //Если нужно, добавим GeosetAnim
 if CountOfGeosets=CountOfGeosetAnims then begin
  inc(CountOfGeosetAnims);
  SetLength(GeosetAnims,CountOfGeosetAnims);
  with GeosetAnims[CountOfGeosetAnims-1] do begin
   Alpha:=1;IsAlphaStatic:=true;
   Color[1]:=1;Color[2]:=1;Color[3]:=1;
   IsColorStatic:=true;
   GeosetID:=CountOfGeosets;
  end;//of width
 end;//of if (AddNewAnim)
 //Увеличим список поверхностей
 inc(CountOfGeosets);
 SetLength(Geosets,CountOfGeosets);
 SetLength(Geoobjs,CountOfGeosets);
 SetLength(Geosets[CountOfGeosets-1].Faces,1);
 Geosets[CountOfGeosets-1].CountOfFaces:=1;
 Geosets[CountOfGeosets-1].CountOfMatrices:=1;
 Geosets[CountOfGeosets-1].CountOfVertices:=0;
 Geosets[CountOfGeosets-1].CountOfCoords:=1;
 with Geosets[CountOfGeosets-1] do
      SetLength(Crds,CountOfCoords);   //текстурные плоскости
 tvn:=0;                          //стартовый номер вершины
 FirstFlag:=true;
 PopFunction;
End;

//Вставляет новую поверхность из 3DS-файла
procedure Import3DS(fname:string);
Var f:file;p:pointer;
    sz,CurGeoNum,tag,num,cp,cpEnd,cof,tvn,mn,i,
    len,ii,j,fdelta,vdelta,StartNewGeoset:integer;
    FirstFlag:boolean;
Begin
 PushFunction(315);
 //1. Откроем и прочитаем файл
 AssignFile(f,fname);
 {$I-}
 reset(f,1);
 {$I+}
 if IOResult<>0 then begin
  MessageBox(0,'Файл 3DS не найден','Ошибка:',mb_iconstop);
  PopFunction;
  exit;
 end;//of if
 sz:=FileSize(f);
 GetMem(p,sz);                    //выделим память под буфер
 BlockRead(f,p^,sz);              //чтение файла
 closeFile(f);                    //закрыть файл

 //Ищем поверхность с точкой прикрепления:
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
  if VertexCount>0 then begin
   num:=VertexList[0]-1;
   CurGeoNum:=j+1;
   break;
  end;//of if
 end;//of for j

 //3. Заполним (частично) новую поверхность, анализируем файл 3DS
 StartNewGeoset:=CountOfGeosets;
// with Geosets[CountOfGeosets-1],geoobjs[CountOfGeosets-1] do begin
// >>
 cp:=integer(p);                  //текущая позиция
 cpEnd:=cp+sz-4;                  //конечная позиция
 while cp<cpEnd do begin
  //анализ тегов 3DS-файла
  tag:=Get3DSWord(cp);             //читаем тег
  case tag of                      //анализ тега
   $4D4D,$3D3D:cp:=cp+4;           //пропуск длины
   $4100:begin                     //новый тримеш
    CreateGeoset(tvn,FirstFlag);   //создать поверхность
    cp:=cp+4;                      //пропустить длину
   end;//of 4100
   $4000:begin                     //пропуск имени объекта
    cp:=cp+4;                      //пропускаем длину
    while (cp<cpEnd) and (Get3DSByte(cp)<>0) do begin end;
   end;
   $4110:with Geosets[CountOfGeosets-1] do begin //список вершин
    if not FirstFlag then begin //доукомплектация текстурой
     vdelta:=Crds[0].CountOfTVertices;
     Crds[0].CountOfTVertices:=CountOfVertices;
     SetLength(Crds[0].TVertices,Crds[0].CountOfTVertices);
     for i:=vdelta to Crds[0].CountOfTVertices-1 do begin
      Crds[0].TVertices[i,1]:=0;
      Crds[0].TVertices[i,2]:=0;
     end;//of for i
    end;//of if
    FirstFlag:=false;              //все, уже не первый раз
    cp:=cp+4;                      //пропуск поля длины
    CountOfVertices:=Get3DSWord(cp);//кол-во вершин
    SetLength(Vertices,CountOfVertices+tvn);
    for i:=0 to CountOfVertices-1 do begin
     Vertices[i+tvn,1]:=Get3DSFloat(cp);
     Vertices[i+tvn,2]:=Get3DSFloat(cp);
     Vertices[i+tvn,3]:=Get3DSFloat(cp);
    end;//of for i
    CountOfVertices:=CountOfVertices+tvn;
   end;//of import(Vertices)
   $4120:with Geosets[CountOfGeosets-1] do begin //грани
    cp:=cp+4;                      //пропуск длины
    SetLength(Faces,1);
    cof:=Get3DSWord(cp);           //кол-во треугольников
    fdelta:=Length(Faces[0]);
    SetLength(Faces[0],cof*3+fdelta);//выделить память
    for i:=0 to cof-1 do begin
     Faces[0,fdelta+i*3]:=Get3DSWord(cp)+tvn;
     Faces[0,fdelta+i*3+1]:=Get3DSWord(cp)+tvn;
     Faces[0,fdelta+i*3+2]:=Get3DSWord(cp)+tvn;
     cp:=cp+2;                    //пропуск флагов
    end;//of for i
    tvn:=CountOfVertices;         //блок вершин окончен
   end;//of import(Faces)
   $4140:with Geosets[CountOfGeosets-1] do begin
    cp:=cp+4;                     //пропуск поля длины
    Crds[0].CountOfTVertices:=Get3DSWord(cp);
    vDelta:=length(Crds[0].TVertices);
    SetLength(Crds[0].TVertices,Crds[0].CountOfTVertices+vdelta);
    for i:=0 to Crds[0].CountOfTVertices-1 do begin
     Crds[0].TVertices[vdelta+i,1]:=Get3DSFloat(cp);
     Crds[0].TVertices[vdelta+i,2]:={1-}Get3DSFloat(cp);
    end;//of for i
    Crds[0].CountOfTVertices:=Crds[0].CountOfTVertices+vdelta;
   end;//of import (TVertices)
   else begin                     //пропуск побочных тегов
   cof:=Get3DSInt(cp);
   cp:=cp+cof-6;
  end;end;//of case
 end;//of while
// end;//of with

 //Копируем текстурные вершины

 //Обсчет нормалей
 SetLength(VisGeosets,CountOfGeosets);//видимость поверхностей
 for j:=StartNewGeoset to CountOfGeosets-1 do with Geosets[j],Geoobjs[j]
 do begin
  VisGeosets[j]:=true;
  color4f[1]:=1;
  color4f[2]:=1;
  color4f[3]:=1;
  color4f[4]:=1;
  SetLength(Normals,CountOfVertices);
  CountOfNormals:=CountOfVertices;
  ReCalcNormals(j+1);
  SetLength(VertexGroup,CountOfVertices);//создание массива групп
// >>
  VertexList:=nil;                 //очистка списка выделения
  VertexCount:=0;

  //3. Обнулим массив групп вершин
  for i:=0 to length(VertexGroup)-1 do VertexGroup[i]:=0;
  //4. Создать группу прикрепления
  SetLength(Groups,1);            //только 1 элемент
  num:=Geosets[CurGeoNum-1].VertexGroup[num];//считать номер группы
  len:=length(Geosets[CurGeoNum-1].Groups[num]);//узнать длину
  SetLength(Groups[0],len);       //установить размер группы
  for ii:=0 to len-1 do Groups[0,ii]:=Geosets[CurGeoNum-1].Groups[num,ii];
  //5. Скопировать границы анимаций
  CountOfAnims:=Geosets[0].CountOfAnims;
  SetLength(Anims,CountOfAnims);
  for i:=0 to CountOfAnims-1 do Anims[i]:=Geosets[0].Anims[i];
  //6. Установить границы поверхности
  MinimumExtent[1]:=-350;MinimumExtent[2]:=-350;MinimumExtent[3]:=-350;
  MaximumExtent[1]:=350;MaximumExtent[2]:=350;MaximumExtent[3]:=350;
  BoundsRadius:=400;
  //7. Создать (если нужно) фиктивный треугольник
  if length(Faces[0])=0 then begin
   SetLength(Faces[0],3);
   Faces[0,0]:=0;Faces[0,1]:=0;Faces[0,2]:=0;
  end;//of if
  //8. Доустановка
  SelectionGroup:=0;Unselectable:=false;
  CurrentListNum:=0;
 end;//of with/for i
 //9. Теперь создадим добавочные текстуру и материал
 cof:=0;
 for i:=0 to CountOfTextures-1 do if Textures[i].ReplaceableID=1 then begin
  cof:=i;
  break;
 end;//of for i
 if Textures[cof].ReplaceableID<>1 then begin //создать текстуру
  inc(CountOfTextures);
  cof:=CountOfTextures-1;
  SetLength(Textures,CountOfTextures);
  with Textures[cof] do begin
   pImg:=nil;
   FileName:='';
   ReplaceableID:=1;
   IsWrapWidth:=false;
   IsWrapHeight:=false;
  end;//of with
 end;//of if

// num:=CountOfTextures;
 mn:=0;
 //10. Добавим материал (или же найдем подходящий)
 for i:=0 to CountOfMaterials-1 do if Materials[i].CountOfLayers=1 then begin
  if Materials[i].Layers[0].TextureID=cof then begin
   mn:=i;
   break;
  end;//of if
 end;//of for/if
 if (Materials[mn].CountOfLayers<>1) or
    (Materials[mn].Layers[0].TextureID<>cof) then begin //создать материал
  inc(CountOfMaterials);
  mn:=CountOfMaterials-1;
  SetLength(Materials,CountOfMaterials);
  with Materials[mn] do begin
   ListNum:=-1;
   IsConstantColor:=false;
   IsSortPrimsFarZ:=false;
   IsFullResolution:=false;
   PriorityPlane:=-1;
   CountOfLayers:=1;
   SetLength(Layers,1);           //создать слой
   Layers[0].FilterMode:=Opaque;  //непрозрачный
   Layers[0].IsUnshaded:=false;
   Layers[0].IsUnfogged:=false;
   Layers[0].IsTwoSided:=true;
   Layers[0].IsSphereEnvMap:=false;
   Layers[0].IsNoDepthTest:=false;
   Layers[0].IsNoDepthSet:=false;
   Layers[0].TextureID:=cof;
   Layers[0].IsTextureStatic:=true;
   Layers[0].Alpha:=-1;
   Layers[0].IsAlphaStatic:=true;
   Layers[0].NumOfGraph:=-1;
   Layers[0].NumOfTexGraph:=-1;
   Layers[0].TVertexAnimID:=-1;
   Layers[0].CoordID:=-1;
  end;//of with
 end;//of if (Create_Material)
 for i:=StartNewGeoset to CountOfGeosets-1 do Geosets[i].MaterialID:=mn;

 FreeMem(p);
 PopFunction;
End;
//---------------------------------------------------------
//Рекурсивная процедура: находит всех потомков указанного
//объекта, помещая их ID в соотв. список
procedure FindChilds(id:integer);
Var i:integer;
 function IsInChilds(id:integer):boolean;
 Var ii:integer;
 Begin
  Result:=false;
  for ii:=0 to SelObj.CountOfChilds-1 do if id=SelObj.ChildObjects[ii] then begin
   Result:=true;
   exit;
  end;//of for ii
 End;
Begin
 PushFunction(316);
 //1. Перебор костей
 for i:=0 to CountOfBones-1
 do if (Bones[i].parent=ID) and (not IsInChilds(Bones[i].ObjectID)) then begin
  //найден потомок. Заносим в массив потомков 
  inc(SelObj.CountOfChilds);
  SetLength(SelObj.ChildObjects,SelObj.CountOfChilds);
  //сохранить номер  
  SelObj.ChildObjects[SelObj.CountOfChilds-1]:=Bones[i].ObjectID;
  FindChilds(Bones[i].ObjectID);
 end;//of for/if

 //2. Перебор помощников
 for i:=0 to CountOfHelpers-1
 do if (Helpers[i].parent=ID) and (not IsInChilds(Helpers[i].ObjectID)) then
 with SelObj do begin
  inc(CountOfChilds);
  SetLength(ChildObjects,CountOfChilds);
  ChildObjects[CountOfChilds-1]:=Helpers[i].ObjectID;//сохранить номер
  FindChilds(Helpers[i].ObjectID);
 end;//of for/if

 //3. Перебор аттачей
 for i:=0 to CountOfAttachments-1
 do if (Attachments[i].Skel.parent=ID) and
       (not IsInChilds(Attachments[i].Skel.ObjectID)) then
 with SelObj do begin
  inc(CountOfChilds);
  SetLength(ChildObjects,CountOfChilds);
  ChildObjects[CountOfChilds-1]:=Attachments[i].Skel.ObjectID;//сохранить номер
  FindChilds(Attachments[i].Skel.ObjectID);
 end;//of for/if

 //4. Перебор ИЧ-2
 for i:=0 to CountOfParticleEmitters-1
 do if (pre2[i].Skel.parent=ID) and
       (not IsInChilds(pre2[i].Skel.ObjectID)) then
 with SelObj do begin
  inc(CountOfChilds);
  SetLength(ChildObjects,CountOfChilds);
  ChildObjects[CountOfChilds-1]:=pre2[i].Skel.ObjectID;//сохранить номер
  FindChilds(pre2[i].Skel.ObjectID);
 end;//of for/if
 PopFunction;
End;
//---------------------------------------------------------
//Выделяет объект с указанным ID:
//заполняет структуру SelObj за исключением CompetitorObjs
procedure SelectSkelObj(ID:integer);
Begin with SelObj do begin
 PushFunction(317);
 b:=GetSkelObjectByID(id);        //собственно объект
 IsSelected:=true;                //объект выделен
 ObjType:=GetTypeObjByID(id);     //тип объекта
 CountOfChilds:=0;                //инициализация
 FindChilds(id);                  //найти дочерние объекты
 IDInComps:=-1;                   //пока массив не используется
 PopFunction;
end;End;
//---------------------------------------------------------
//Заполняет список дочерних вершин выделенной кости
//и ЕЁ дочерних костей. 
//Вершины ищутся в каждой поверхности
//Используются данные SelObj.
//Массив ChildVertices заполняется номерами вершин.
//Масив DirectChildVertices заполняется номерами вершин,
//связанных непосредственно с выделенной костью.
procedure FindChildVertices;
Var j,jj,i,ii,k,kk,cnt:integer;
    lst:TFace;
Begin
 PushFunction(318);
 //0. Подготовим список костей, дочерние вершины которых нужно найти
 if SelObj.IsMultiSelect then begin
  cnt:=SelObj.CountOfSelObjs;
  lst:=SelObj.SelObjs;
 end else begin
  cnt:=1;
  SetLength(lst,1);
  lst[0]:=SelObj.b.ObjectID;
 end;//of if

 for j:=0 to CountOfGeosets-1 do with Geosets[j] do begin
  CountOfChildVertices:=0;
  CountOfDirectCV:=0;

  //Ищем вхождения данного объекта в матрицы:
  for i:=0 to CountOfMatrices-1 do for ii:=0 to High(Groups[i])
  do for kk:=0 to cnt-1 do if Groups[i,ii]=lst[kk] then begin
   //Вхождение найдено. Определяем номера вершин с
   //соответствующим значением VertexGroup
   for jj:=0 to CountOfVertices-1 do begin
    if VertexGroup[jj]=i then begin //найдена вершина
     inc(CountOfDirectCV);
     SetLength(DirectCV,CountOfDirectCV);
     DirectCV[CountOfDirectCV-1]:=jj;     //записать номер вершины
    end;//of if
   end;//of for jj
  end;//of if/for kk/ii/i

  //Ищем вхождения остальных (дочерних) объектов в матрицы
  for k:=0 to SelObj.CountOfChilds-1
  do for i:=0 to CountOfMatrices-1
  do for ii:=0 to High(Groups[i])
  do if Groups[i,ii]=SelObj.ChildObjects[k] then begin
   //Вхождение найдено. Определяем номера вершин с
   //соответствующим значением VertexGroup
   for jj:=0 to CountOfVertices-1 do begin
    if VertexGroup[jj]=i then begin //найдена вершина
     inc(CountOfChildVertices);
     SetLength(ChildVertices,CountOfChildVertices);
     ChildVertices[CountOfChildVertices-1]:=jj;//записать номер вершины
    end;//of if
   end;//of for jj
  end;//of if/for ii/i/k
 end;//of for j
 PopFunction;
End;
//---------------------------------------------------------
//Создаёт список объектов, достаточно близких к курсору,
//на основе Objs2D.
//Сам список заносится в SelObj.
//Объекты списка сортируются по убыванию Z.
//В IDInComps заносится 0.
//Если нет подходящих объектов, CountOfCompObjs=0.
procedure MakeCompetitorObjsList(x,y:integer);
Var d,i,j:integer;
    Tr:TVertex2D;
Const BN_AREA=7;
Begin with SelObj do begin
 PushFunction(319);
 CountOfCompObjs:=0;

 //Сортируем список объектов Objs2D:
 d:=round(log2(CountOfObjs));
 asm
  fninit
 end;
 d:=trunc(Power(2,d))-1;
 repeat                           //цикл сортировки
 for i:=1 to CountOfObjs-d do begin
  j:=i;                           //цикл с шагом
  repeat
   if Objs2D[j-1].z<=Objs2D[j+d-1].z then break;
   Tr:=Objs2D[j-1];
   Objs2D[j-1]:=Objs2D[j+d-1];
   Objs2D[j+d-1]:=Tr;
   j:=j-d;
  until j<1;
 end;//of for i
 d:=d shr 1;
 until d<=0;

 //Ищем объекты, достаточно близкие к курсору
 for i:=0 to CountOfObjs-1 
 do if (abs(Objs2D[i].x-x)+abs(Objs2D[i].y-y))<BN_AREA then begin
  inc(CountOfCompObjs);
  SetLength(CompetitorObjs,CountOfCompObjs);
  CompetitorObjs[CountOfCompObjs-1]:=Objs2D[i].id;
 end;

 IDInComps:=0;
 PopFunction;
end;End;
//---------------------------------------------------------
//Создает новый контроллер и возвращает его номер
function CreateController(ObjID:integer;it:TContItem;CngType:integer):integer;
Var i,len:integer;
    IsBone:boolean;
Begin
 PushFunction(320);
 //1. Создадим новый контроллер
 len:=length(Controllers)+1;
 SetLength(Controllers,len);
 Controllers[len-1].GlobalSeqId:=-1;
 Controllers[len-1].ContType:=DontInterp;
 case CngType of                  //определим тип контроллера
  ctTranslation,ctScaling:Controllers[len-1].SizeOfElement:=3;
  ctRotation:Controllers[len-1].SizeOfElement:=4;
  ctAlpha:Controllers[len-1].SizeOfElement:=1;
 end;//of case
 SetLength(Controllers[len-1].Items,1);
 Controllers[len-1].items[0]:=it; //записать элемент
 CreateController:=len-1;         //вернуть номер
 if ObjID<0 then begin PopFunction;exit;end;//выйти, если это - не связанный с костью к.
 //2. Разыщем объект
 IsBone:=false;
 for i:=0 to CountOfBones-1 do if Bones[i].ObjectID=ObjID then begin
  IsBone:=true;
  break;
 end;//of if/for i
 if not IsBone then for i:=0 to CountOfHelpers-1 do
    if Helpers[i].ObjectID=ObjID then begin
  IsBone:=false;break;
 end;//of if/for i/if

 //3. Свяжем контроллер с объектом (если нужно)
 case CngType of
  ctRotation:if IsBone then Bones[i].Rotation:=len-1
                       else Helpers[i].rotation:=len-1;
  ctTranslation:if IsBone then Bones[i].Translation:=len-1
                          else Helpers[i].Translation:=len-1;
  ctScaling:if IsBone then Bones[i].Scaling:=len-1
                      else Helpers[i].Scaling:=len-1;
 end;//of case
 PopFunction;
End;
//---------------------------------------------------------
//Преобразует контроллер к линейному типу
procedure TransformController(cnum:integer);
Var i,len:integer;
    its,it:TContItem;
//    PredItReady:boolean;
Begin
 len:=length(Controllers[cnum].items);
 if Controllers[cnum].ContType=255 then exit; //это подвид Альфа
 PushFunction(321);

 //Проверка на особый случай
 its:=Controllers[cnum].items[0]; //читать исходный
 if length(Controllers[cnum].items)=1 then begin //особый случай
  Controllers[cnum].ContType:=Linear;
  inc(its.Frame);
  AddKeyFrame(cnum,its);       //дополнить контроллер
//  exit;
 end;//of if

 //Проверим: вдруг это "простой" тип?
 if (Controllers[cnum].ContType=Linear) or
    (Controllers[cnum].ContType=Bezier) or
    (Controllers[cnum].ContType=Hermite)or
    (Controllers[cnum].ContType=255)  then begin
  Controllers[cnum].ContType:=Linear;//прямая замена
  PopFunction;
  exit;
 end;//of if

 i:=1;
 repeat
  it:=Controllers[cnum].items[i]; //считать элемент
  its.Frame:=it.Frame-1;          //сменить кадр
  AddKeyFrame(cnum,its);          //преобразование
  its:=it;
  inc(i);inc(i);inc(len);
 until i>len-1;
 Controllers[cnum].ContType:=Linear;
 PopFunction;
End;
//---------------------------------------------------------
//Вставляет данные из буфера, начиная с текущего кадра и до конца
//true - если что-то вставлено.
//Если IsUseFilter=true, то при вставке применяется фильтр
//(выделение кадров только активного контроллера)
//Если IsBlend=true, то вместо вставки происходит смешивание
//(блендинг) с коэффициентом BlendF
function PasteFramesFromBuffer(CurFrame,MaxFrame:integer;
                               IsUseFilter,IsBlend:boolean;
                               BlendF:GlFloat):boolean;
Var len,lenc,i,ID:integer;
Begin
 PushFunction(322);
 len:=High(FrameBuffer);
 lenc:=High(Controllers);
 Result:=false;
 for i:=0 to len do begin
  ID:=FrameBuffer[i].SizeOfElement;
  //Проверим, чтоб не выходило за рамки массива контроллеров
  if ID>lenc then continue;
  //Проверим, чтобы совпадало с глоб. последовательностями
  if (UsingGlobalSeq<0) and (FrameBuffer[i].GlobalSeqID>=0) then continue;
  if (UsingGlobalSeq>=0) and
     (FrameBuffer[i].GlobalSeqID<>UsingGlobalSeq) then continue;
  //Если нужно, применим фильтр
  if IsUseFilter and IsContrFilter and (ContrFilter.IndexOf(pointer(id))<0)
  then continue;

  //Собственно копирование
  FrameBuffer[i].SizeOfElement:=Controllers[ID].SizeOfElement;
  if IsBlend then BlendFrames(FrameBuffer[i],Controllers[ID],0,MaxFrame,CurFrame,MaxFrame,BlendF)
  else CopyFrames(FrameBuffer[i],Controllers[ID],0,MaxFrame,CurFrame,MaxFrame);
  FrameBuffer[i].SizeOfElement:=ID;
  Result:=true;
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//Делает полный слепок текущей позиции и копирует этот
//единственный кадр в буфер обмена
procedure CopyCurFrameToBuffer;
Var i,cnt,len,tp:integer;it:TContItem;
Begin
 PushFunction(323);
 len:=High(Controllers);
 cnt:=1;
 for i:=0 to len do begin
  if ((UsingGlobalSeq<0) and (Controllers[i].GlobalSeqId>=0)) or
     ((UsingGlobalSeq>=0) and (Controllers[i].GlobalSeqId<>UsingGlobalSeq))
  then continue;

  //Выделяем место для копирования
  SetLength(FrameBuffer,cnt);
  FrameBuffer[cnt-1]:=Controllers[i];
  FrameBuffer[cnt-1].Items:=nil;
  FrameBuffer[cnt-1].SizeOfElement:=i;

  //Вычисляем значение контроллера и копируем
  tp:=ctRotation;
  case Controllers[i].SizeOfElement of
   1:tp:=ctAlpha;
   3:with Controllers[i].Items[0] do
   if (Data[1]<=1) and (Data[1]>1e-4) and
      (Data[2]<=1) and (Data[2]>1e-4) and
      (Data[3]<=1) and (Data[3]>1e-4) then tp:=ctScaling
   else tp:=ctTranslation;   
   4:tp:=ctRotation;
  end;//of case
  it:=GetFrameData(i,CurFrame,tp);    
  it.Frame:=0;
  it.InTan[1]:=it.Data[1];it.InTan[2]:=it.Data[2];it.InTan[3]:=it.Data[3];it.InTan[4]:=it.Data[4];
  it.OutTan[1]:=it.Data[1];it.OutTan[2]:=it.Data[2];It.OutTan[3]:=it.Data[3];it.OutTan[4]:=it.Data[4];
  SetLength(FrameBuffer[cnt-1].Items,1);
  FrameBuffer[cnt-1].Items[0]:=it;

  inc(cnt);
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//Быстрое копирование всех кадров из cSrc в cDest
procedure QuickCopyFrames(var cSrc,cDest:TController);
Var i,j,len,len2:integer;
Begin
 PushFunction(324);
 //1. Ищем позицию вставки
 len:=High(cSrc.items);
 len2:=High(cDest.Items);
 i:=GetFramePos(cDest,cSrc.Items[0].Frame,len2);

 //2. Выделяем дополнительное пространство
 SetLength(cDest.Items,len2+1+len+1);

 //3. Сдвигаем кадры в конец
 for j:=len2 downto i do cDest.Items[j+len+1]:=cDest.Items[j];

 //4. Вставляем группу кадров
 for j:=0 to len do cDest.Items[j+i]:=cSrc.Items[j];
 PopFunction;
End;
//---------------------------------------------------------
//Копирует набор кадров из контроллера cSrc (sStart,sEnd)
//в контроллер cDest (dStart,dEnd).
//То, что выходит за границы dEnd, не копируется.
//Если типы контроллеров не совпадают, происходит
//конвертирование кадров в тип (cDest.ContType).
//Возвр. false, если ни одного кадра не скопировано
function CopyFrames(var cSrc,cDest:TController;
                    sStart,sEnd,dStart,dEnd:integer):boolean;
Var i,len,sps,spe:integer;it:TContItem;
Begin
 PushFunction(325);
 Result:=false;
 //Проверка на граничный диапазон
 if (dEnd>0) and ((sStart+dEnd-dStart)<sEnd) then sEnd:=sStart+dEnd-dStart;
 //1. Ищем первый кадр для копирования
 len:=High(cSrc.items);sps:=-1;spe:=-1;
 for i:=0 to len do if cSrc.Items[i].Frame>=sStart then begin
  sps:=i;
  break;
 end;//of if/for i
 if sps<0 then begin PopFunction;exit;end; //нечего копировать

 //2. Ищем последний кадр для копирования
 i:=sps;
 while (i<=len) and (cSrc.Items[i].Frame<=sEnd) do begin
  spe:=i;
  inc(i);
 end;//of if/for i
 if spe<sps then begin PopFunction;exit;end; //ошибка

 //3. Копируем покадрово (вставкой кадров)
 for i:=sps to spe do begin
  it:=cSrc.Items[i];
  it.Frame:=it.Frame-sStart+dStart;
  //Проверка: необходимо ли преобразовать
  if ((cDest.ContType=Hermite) or (cDest.ContType=Bezier)) and
     ((cSrc.ContType=DontInterp) or (cSrc.ContType=Linear)) then begin
   it.InTan[1]:=it.Data[1];it.OutTan[1]:=it.Data[1];
   it.InTan[2]:=it.Data[2];it.OutTan[2]:=it.Data[2];
   it.InTan[3]:=it.Data[3];it.OutTan[3]:=it.Data[3];
   it.InTan[4]:=it.Data[4];it.OutTan[4]:=it.Data[4];
  end;//of if
  //Вставка
  InsertFrame(cDest,it);
 end;//of for i
 Result:=true;
 PopFunction;
End;
//----------------------------------------------------------
//Производит смешение (блендинг) кадров из cSrc и cDest
//с коэффициентом cBlend
//Используется такая схема (A, B, C - временные переменные):
//1. Кусок sStart-sDest копируется в A
//2. Кусок dStart-dEnd копируется в B
//3. A и B смешиваются (с увеличением числа КК) в C.
//4. C копируется в sStart-sEnd.
function BlendFrames(var cSrc,cDest:TController;
                    sStart,sEnd,dStart,dEnd:integer;cBlend:GLFloat):boolean;
Var numA,numB, lenA,lenB,lenC, maxfA, ctypA,ctypB, i:integer; c:TController;
    itA,itB,itC:TContItem;
 function BlendItems(itA,itB:TContItem;BlendF:GLFloat;IsQ:boolean):TContItem;
 Var i:integer; nrm:GLFloat;
 Begin
  Result.Frame:=itA.Frame;
  for i:=1 to 4 do begin
   Result.Data[i]:=(1-BlendF)*itA.Data[i]+BlendF*itB.Data[i];
   Result.InTan[i]:=(1-BlendF)*itA.InTan[i]+BlendF*itB.InTan[i];
   Result.OutTan[i]:=(1-BlendF)*itA.OutTan[i]+BlendF*itB.OutTan[i];
  end;//of for i

  //нормирование кватерниона
  if IsQ then begin
   nrm:=sqrt(sqr(Result.Data[1])+sqr(Result.Data[2])+sqr(Result.Data[3])+sqr(Result.Data[4]));
   //нерормируемый; ставим единичный
   if nrm<1e-6 then begin
    Result.Data[1]:=0;
    Result.Data[2]:=0;
    Result.Data[3]:=0;
    Result.Data[4]:=1;
   end else begin
    nrm:=1/nrm;
    Result.Data[1]:=Result.Data[1]*nrm;
    Result.Data[2]:=Result.Data[2]*nrm;
    Result.Data[3]:=Result.Data[3]*nrm;
    Result.Data[4]:=Result.Data[4]*nrm;
   end;//of if

   //Тангенциальная часть
   for i:=1 to 4 do begin
    Result.InTan[i]:=Result.Data[i];
    Result.OutTan[i]:=Result.Data[i];
   end;//of for i
  end;//of if
 End;
Begin
 SetLength(Controllers,length(Controllers)+2);
 numB:=High(Controllers);
 numA:=numB-1;
 Controllers[numA]:=cSrc;
 Controllers[numA].Items:=nil;
 Controllers[numB]:=cDest;
 Controllers[numB].Items:=nil;
 FillChar(c,SizeOf(c),0);
 C.ContType:=Max(Controllers[numA].ContType,Controllers[numB].ContType);
 C.GlobalSeqId:=cSrc.GlobalSeqId;
 C.SizeOfElement:=Min(Controllers[numA].SizeOfElement,Controllers[numB].SizeOfElement);

 //1. Копировать в A sStart-sEnd
 CopyFrames(cSrc,Controllers[numA],sStart,sEnd,0,-1);

 //2. Копировать в B dStart-dEnd
 CopyFrames(cDest,Controllers[numB],dStart,dStart+sEnd-sStart,0,-1);

 //3. Определим тип каждого контроллера
 case cSrc.SizeOfElement of
  1:ctypA:=ctAlpha;
  3:ctypA:=ctScaling;   //если даже и ошибся, 1 для Translation - небольшая ошибка
  4:ctypA:=ctRotation;
  else ctypA:=ctScaling;
 end;//of case

 case cDest.SizeOfElement of
  1:ctypB:=ctAlpha;
  3:ctypB:=ctScaling;   //если даже и ошибся, 1 для Translation - небольшая ошибка
  4:ctypB:=ctRotation;
  else ctypB:=ctScaling;
 end;//of case

 //4. Смешение - для каждого КК А и В создать КК С.
 for i:=0 to High(Controllers[numA].items) do begin
  itA:=GetFrameData(numA,Controllers[numA].Items[i].Frame,ctypA);
  itB:=GetFrameData(numB,Controllers[numA].Items[i].Frame,ctypB);
  itC:=BlendItems(itA,itB,cBlend,(ctypB=ctRotation) or (ctypA=ctRotation));
  itC.Frame:=Controllers[numA].Items[i].Frame;
  InsertFrame(C,itC);
 end;//of for i

 maxfA:=Controllers[numA].Items[High(Controllers[numA].Items)].Frame;
 for i:=0 to High(Controllers[numB].items) do begin
  if Controllers[numB].Items[i].Frame>maxfA then break;
  itA:=GetFrameData(numA,Controllers[numB].Items[i].Frame,ctypA);
  itB:=GetFrameData(numB,Controllers[numB].Items[i].Frame,ctypB);
  itC:=BlendItems(itA,itB,cBlend,(ctypB=ctRotation) or (ctypA=ctRotation));
  itC.Frame:=Controllers[numB].Items[i].Frame;  
  InsertFrame(C,itC);
 end;//of for i

 //5. Очищаем интервал cDest:
 DeleteFrames(cDest,dStart,dStart+C.Items[High(C.Items)].Frame);

 //6. Записываем кусок С в cDest:
 CopyFrames(C,cDest,0,C.Items[High(C.Items)].Frame,dStart,dEnd);

 //Очистка
 SetLength(Controllers,numA);
End;
//---------------------------------------------------------
//Удаление всех КК из указанного диапазона.
//Массивы Undo модифицируются ей автоматически -
//нет надобности выполнять SaveUndo.
procedure DeleteKeyFrames(FrStart,FrEnd:integer);
Var Cur,i,ii,j,id,len,len2,cnt:integer;
Begin
 PushFunction(326);
 //0. Осуществить сдвиг Undo.
 Cur:=ShearUndo;
 Undo[Cur].Status1:=uDeleteKeyFrames;//метка
 Undo[Cur].Status2:=0;            //кол-во "обработанных" контроллеров
 cnt:=0;

 //Пробегаемся по всему списку контроллеров:
 ID:=-1;len:=High(Controllers);
 while GetNextController(ID,len) do begin
  //a. Выделяем место для сохранения
  inc(Undo[Cur].status2);
  inc(cnt);
  SetLength(Undo[Cur].idata,cnt);
  SetLength(Undo[Cur].Controllers,cnt);
  Undo[Cur].Controllers[cnt-1].Items:=nil;
  Undo[Cur].Controllers[cnt-1].ContType:=Controllers[ID].ContType;
  SetLength(Undo[Cur].VertexGroup,cnt);
  //1. Проверим, не весь ли контроллер удаляется
  len2:=High(Controllers[ID].Items);
  if (Controllers[ID].Items[0].Frame<FrStart) or
     (Controllers[ID].items[len2].Frame>FrEnd) then begin
   //нет, удаляем только часть контроллера
   //Сохраняем фрагмент контроллера
   if not CopyFrames(Controllers[ID],Undo[Cur].Controllers[cnt-1],
              FrStart,FrEnd,FrStart,-1) then begin
    dec(cnt);
    dec(Undo[Cur].Status2);
   end else begin
    Undo[Cur].idata[cnt-1]:=ID;   //ID контроллера
    Undo[Cur].VertexGroup[cnt-1]:=0;//удалена часть контроллера
   end;//of if
   //Удалить фрагмент контроллера
   DeleteFrames(Controllers[ID],FrStart,FrEnd);
  end else begin
   //да, будем удалять весь контроллер
   Undo[Cur].idata[cnt-1]:=ID;    //сохраним ID
   Undo[Cur].Controllers[cnt-1].Items:=Controllers[ID].Items;
   Undo[Cur].VertexGroup[cnt-1]:=DeleteAllController(ID);
  end;//of if
 end;//of while

 //Теперь проверим, что там с секцией текстурных анимаций
 //Если какие-то из них стали пустыми, сохранить их номера
 Undo[Cur].MatID:=0;
 for i:=0 to CountOfTextureAnims-1 do with TextureAnims[i] do begin
  if (RotationGraphNum<0) and (TranslationGraphNum<0) and
     (ScalingGraphNum<0) then begin
   inc(Undo[Cur].MatID);
   SetLength(Undo[Cur].VertexList,Undo[Cur].MatID);
   Undo[Cur].VertexList[Undo[Cur].MatID-1]:=i;  
  end;//of if
 end;//of for i

 //Смотрим, не нужно ли удалить такие секции
 if Undo[Cur].MatID=0 then begin PopFunction;exit;end;//не нужно

 //Сохраняем TVertexAnimID (в том же массиве)
 len:=length(Undo[Cur].VertexList);
 for i:=0 to CountOfMaterials-1 do with Materials[i] do begin
  len:=len+CountOfLayers;
  SetLength(Undo[Cur].VertexList,len);
  for ii:=0 to CountOfLayers-1 do
   Undo[Cur].VertexList[ii+len-CountOfLayers]:=Layers[ii].TVertexAnimID;
 end;//of for i

 //Наконец, удалим их, сдвинув TVertexAnimID
 for i:=Undo[Cur].MatID-1 downto 0 do begin
  len:=Undo[Cur].VertexList[i];   //ID очередной секции
  //Сдвиг самого массива секций
  for ii:=len to CountOfTextureAnims-2 do TextureAnims[ii]:=TextureAnims[ii+1];
  //Сдвиг ID в слоях
  for ii:=0 to CountOfMaterials-1 do
  for j:=0 to Materials[ii].CountOfLayers-1 do
  with Materials[ii].Layers[j] do begin
   if Materials[ii].Layers[j].TVertexAnimID=len then Materials[ii].Layers[j].TVertexAnimID:=-1;
   if Materials[ii].Layers[j].TVertexAnimID>len then dec(Materials[ii].Layers[j].TVertexAnimID);
  end;//of with/for j/for ii
  dec(CountOfTextureAnims);
 end;//of for i
 SetLength(TextureAnims,CountOfTextureAnims);
 PopFunction;
End;
//---------------------------------------------------------
//Удаление меток событий EventObjects из указанного диапазона
//Автоматически модифицируется NewUndo,
//куда и записываются удалённые фрагменты
procedure DeleteEventStamps(FrStart,FrEnd:integer);
Var ev:TDelEvStamps;pv:TPivUndo;IsNeedDel:boolean;
    i,ii,j,jj,id,count:integer;
Begin
 PushFunction(327);
 //1. Выполним сохранение
 ev:=TDelEvStamps.Create;
 ev.TypeOfUndo:=uCutKeyFrames;
 ev.Prev:=-1;
 ev.Save;
 inc(CountOfNewUndo);
 SetLength(NewUndo,CountOfNewUndo);
 NewUndo[CountOfNewUndo-1]:=ev;

 //2. Стираем кадры
 IsNeedDel:=false;
 if UsingGlobalSeq<0 then for i:=0 to CountOfEvents-1 do with Events[i] do begin
  //находим начальный кадр (с которого начинать стирание)
  ii:=0;
  while (ii<CountOfTracks) and (Tracks[ii]<FrStart) do inc(ii);
  if ii>=CountOfTracks then continue;  //нечего стирать

  //находим конечный кадр (по который нужно стереть):
  j:=ii;
  while (j<CountOfTracks-1) and (Tracks[j]<FrEnd) do inc(j);
  if Tracks[j]>FrEnd then dec(j);
  count:=j-ii+1;                  //кол-во стираемых кадров
  if count<=0 then continue;      //нечего стирать

  for jj:=j+1 to CountOfTracks-1 do Tracks[jj-count]:=Tracks[jj];
  CountOfTracks:=CountOfTracks-count;
  SetLength(Tracks,CountOfTracks);
  if CountOfTracks=0 then IsNeedDel:=true;
 end;//of for i/if

 //Теперь проверим, нужно ли удалять объекты целиком
 if not IsNeedDel then begin PopFunction;exit;end;

 //Нужно. Тогда для начала делаем слепок
 SaveNewUndo(uChangeObjects,0);
 NewUndo[CountOfNewUndo-1].Prev:=0;
 //Теперь - собственно цикл удаления
 i:=0;
 if UsingGlobalSeq<0 then while i<CountOfEvents do begin
  if Events[i].CountOfTracks=0 then begin
   id:=Events[i].Skel.ObjectID;
   pv:=TPivUndo.Create;
   pv.id:=id;
   pv.Prev:=0;
   pv.TypeOfUndo:=uCutKeyFrames;
   pv.Save;                       //сохранение
   inc(CountOfNewUndo);
   SetLength(NewUndo,CountOfNewUndo);
   NewUndo[CountOfNewUndo-1]:=pv;
   for ii:=i+1 to CountOfEvents-1 do Events[ii-1]:=Events[ii];
   for ii:=id+1 to CountOfPivotPoints-1 do PivotPoints[ii-1]:=PivotPoints[ii];
   dec(CountOfEvents);
   SetLength(Events,CountOfEvents);
   dec(CountOfPivotPoints);
   SetLength(PivotPoints,CountOfPivotPoints);
   IncDecObjectIDs(id,false);     //сдвиг ID
   continue;
  end;//of if (нужно удалять)
  inc(i);
 end;//of while /if
 PopFunction;
End;
//---------------------------------------------------------
//Сдвигает кадры (для добавления/удаления кадров)
procedure ShearFrames(CurFrame,UsingGlobalSeq,Count:integer);
Var i,ii,len,len2:integer;
Begin
 PushFunction(328);
 if UsingGlobalSeq>=0 then begin  //сдвиг только глобального
  GlobalSequences[UsingGlobalSeq]:=GlobalSequences[UsingGlobalSeq]+Count;
  len:=High(Controllers);
  for i:=0 to len do if Controllers[i].GlobalSeqId=UsingGlobalSeq then begin
   len2:=High(Controllers[i].items);
   //Ищем точку вставки
   ii:=0;
   while (ii<=len2) and (Controllers[i].Items[ii].Frame<CurFrame) do inc(ii);
   if ii>len2 then continue;
   //Итак, есть, что сдвигать
   while (ii<=len2) do begin
    Controllers[i].Items[ii].Frame:=Controllers[i].Items[ii].Frame+Count;
    inc(ii);
   end;//of while
  end;//of if/for i
 end else begin                   //общий сдвиг

  //a. Сдвиг границ анимаций (StartFrame/EndFrame):
  for i:=0 to CountOfSequences-1 do begin
   if Sequences[i].IntervalStart>CurFrame then
      Sequences[i].IntervalStart:=Sequences[i].IntervalStart+Count;
   if Sequences[i].IntervalEnd>=CurFrame then
      Sequences[i].IntervalEnd:=Sequences[i].IntervalEnd+Count;
  end;//of for i

  //b. Сдвиг неглобальных контроллеров
  len:=High(Controllers);
  for i:=0 to len do if Controllers[i].GlobalSeqId<0 then begin
   len2:=High(Controllers[i].items);
   //Ищем точку вставки
   ii:=0;
   while (ii<=len2) and (Controllers[i].Items[ii].Frame<CurFrame) do inc(ii);
   if ii>len2 then continue;
   //Итак, есть, что сдвигать
   while (ii<=len2) do begin
    Controllers[i].Items[ii].Frame:=Controllers[i].Items[ii].Frame+Count;
    inc(ii);
   end;//of while
  end;//of if/for i

  //c. Сдвиг EventObject'ов:
  for i:=0 to CountOfEvents-1 do for ii:=0 to Events[i].CountOfTracks-1 do
      if Events[i].Tracks[ii]>=CurFrame then
         Events[i].Tracks[ii]:=Events[i].Tracks[ii]+Count;
 end;//of if (сдвигs)
 PopFunction;
End;
//---------------------------------------------------------
//Добавляет в контроллер Cont элемент NewFrame,
//вставляя его в нужную позицию (по порядку номеров кадров)
//Если таковой кадр уже есть, его занные замещаются.
procedure InsertFrame(var Cont:TController;var NewFrame:TContItem);
Var i,ii,len:integer;
Begin with Cont do begin
 PushFunction(329);
 len:=High(Cont.Items);
 //1. Ищем позицию вставки
 i:=GetFramePos(Cont,NewFrame.Frame,len);
 if (Cont.Items[i].Frame<NewFrame.Frame) and (i<=len) then inc(i);
// i:=0;
// while (i<=len) and (NewFrame.Frame>Items[i].Frame) do inc(i);

 //2. Собственно процесс записи
 if (i<=len) and (NewFrame.Frame=Cont.Items[i].Frame) then Cont.Items[i]:=NewFrame
 else begin
  SetLength(Cont.Items,len+2);   //место для нового элемента
  ii:=len+1;
  while ii>i do begin Cont.Items[ii]:=Cont.Items[ii-1];dec(ii);end;
  Cont.items[i]:=NewFrame;
 end;
 PopFunction;
end;End;
//---------------------------------------------------------
//Обёртка для InsertFrame: добавляет в контроллер ContNum
//элемент NewFrame.
procedure AddKeyFrame(ContNum:integer;var NewFrame:TContItem);
Begin
 InsertFrame(Controllers[ContNum],NewFrame);
End;
//---------------------------------------------------------
//Удаляет фрагмент контроллера cont.
procedure DeleteFrames(var cont:TController;FrStart,FrEnd:integer);
Var len,i,sps,spe:integer;
Begin
 PushFunction(330);
 //1. Ищем первый кадр для удаления
 len:=High(Cont.items);sps:=-1;spe:=-1;
 for i:=0 to len do if Cont.Items[i].Frame>=FrStart then begin
  sps:=i;
  break;
 end;//of if/for i
 if sps<0 then begin PopFunction;exit;end;//нечего копировать

 //2. Ищем последний кадр для удаления
 for i:=sps to len do if Cont.Items[i].Frame>FrEnd then begin
  spe:=i;
  break;
 end;//of if/for i
 if spe<0 then begin             //контроллер можно просто усечь
  SetLength(Cont.Items,sps);
  PopFunction;
  exit;
 end;//of if
 if spe<=sps then begin PopFunction;exit;end; //ошибка

 //3. Собственно удаление
 for i:=spe to len do Cont.Items[i-spe+sps]:=Cont.Items[i];
 SetLength(Cont.Items,len-(spe-sps)+1);
 PopFunction;
End;
//---------------------------------------------------------
//Удаляет весь контроллер с указанным ID.
//Суть удаления заключается в удалении всех КК (items:=nil)
//и установке IsStaticXX в true.
//Возвращает тип объекта, контроллер которого удалён
function DeleteAllController(ID:integer):cardinal;
Var i,ii,cnt:integer;
function FindControllerInSkel(cnst:cardinal;var obj:TBone;ID:integer):cardinal;
Begin with obj do begin
  Result:=0;
  if Translation=ID then begin
   Translation:=-1;
   Result:=cnst+i;
   exit;
  end;//of if
  if Rotation=ID then begin
   Rotation:=-1;
   Result:=cnst+$1000000+i;
   exit;
  end;//of if
  if Scaling=ID then begin
   Scaling:=-1;
   Result:=cnst+$2000000+i;
   exit;
  end;//of if
  if Visibility=ID then begin
   Visibility:=-1;
   Result:=cnst+$3000000+i;
   exit;
  end;//of if
end;End;
Begin
 PushFunction(331);
 Result:=1;                       //пока ничего не замещено
 //1. Удаляем КК контроллера
 Controllers[ID].Items:=nil;
 //2. Проходим по всем объектам в поисках ссылки на
 //этот контроллер
 //Материалы->слои
 cnt:=0;
 for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1 do
 with Materials[i].Layers[ii] do begin
  //текстура
  if (not IsTextureStatic) and (NumOfTexGraph=ID) then begin
   Materials[i].Layers[ii].IsTextureStatic:=true;
   Materials[i].Layers[ii].TextureID:=0;
//   Materials[i].Layers[ii].NumOfTexGraph:=-1;
   Result:=utMatTexture+cnt;
   PopFunction;
   exit;
  end;//of if
  //прозрачность
  if (not IsAlphaStatic) and (NumOfGraph=ID) then begin
   Materials[i].Layers[ii].IsAlphaStatic:=true;
   Materials[i].Layers[ii].Alpha:=1.0;
//   Materials[i].Layers[ii].NumOfGraph:=-1;
   Result:=utMatAlpha+cnt;
   PopFunction;
   exit;
  end;//of if
  inc(cnt);
 end;//of with/for ii/for i

 //Текстурные анимации
 for i:=0 to CountOfTextureAnims-1 do with TextureAnims[i] do begin
  if TranslationGraphNum=ID then begin
   TranslationGraphNum:=-1;
   Result:=utTATranslation+i;
   PopFunction;
   exit;
  end;//of if
  if RotationGraphNum=ID then begin
   RotationGraphNum:=-1;
   Result:=utTARotation+i;
   PopFunction;
   exit;
  end;//of if
  if ScalingGraphNum=ID then begin
   ScalingGraphNum:=-1;
   Result:=utTAScaling+i;
   PopFunction;
   exit;
  end;//of if
 end;//of with/for i

 //Анимации видимости
 for i:=0 to CountOfGeosetAnims-1 do with GeosetAnims[i] do begin
  if (not IsAlphaStatic) and (AlphaGraphNum=ID) then begin
   IsAlphaStatic:=true;
   Alpha:=1.0;
   Result:=utGAAlpha+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsColorStatic) and (ColorGraphNum=ID) then begin
   IsColorStatic:=true;
   Color[1]:=1;Color[2]:=1;Color[3]:=1;
   Result:=utGAColor+i;
   PopFunction;
   exit;
  end;//of if
 end;//of for i

 //Кости
 for i:=0 to CountOfBones-1 do begin
  Result:=FindControllerInSkel(utBTranslation,Bones[i],ID);
  if Result>0 then begin PopFunction;exit;end;
 end;//of for i

 //Помощники
 for i:=0 to CountOfHelpers-1 do begin
  Result:=FindControllerInSkel(utHTranslation,Helpers[i],ID);
  if Result>0 then begin PopFunction;exit;end;
 end;//of for i

 //Источники света
 for i:=0 to CountOfLights-1 do with Lights[i] do begin
  Result:=FindControllerInSkel(utLTranslation,Lights[i].Skel,ID);
  if Result>0 then begin PopFunction;exit;end;
  if (not IsASStatic) and (round(AttenuationStart)=id) then begin
   IsASStatic:=true;
   AttenuationStart:=50;
   Result:=utLAS+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsAEStatic) and (round(AttenuationEnd)=id) then begin
   IsAEStatic:=true;
   AttenuationEnd:=100;
   Result:=utLAE+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsIStatic) and (round(Intensity)=id) then begin
   IsIStatic:=true;
   Intensity:=10;
   Result:=utLI+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsCStatic) and (round(Color[1])=id) then begin
   IsCStatic:=true;
   Color[1]:=1;Color[2]:=1;Color[3]:=1;
   Result:=utLC+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsAIStatic) and (round(AmbIntensity)=id) then begin
   IsAIStatic:=true;
   AmbIntensity:=0;
   Result:=utLAI+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsACStatic) and (round(AmbColor[1])=id) then begin
   IsACStatic:=true;
   AmbColor[1]:=1;AmbColor[2]:=1;AmbColor[3]:=1;
   Result:=utLAC+i;
   PopFunction;
   exit;
  end;//of if
 end;//of for i

 //Точки прикрепления
 for i:=0 to CountOfAttachments-1 do with Attachments[i] do begin
  Result:=FindControllerInSkel(utATranslation,Skel,ID);
  if Result>0 then begin PopFunction;exit;end;
 end;//of for i

 //Источники частиц (первая версия)
 for i:=0 to CountOfParticleEmitters1-1 do with ParticleEmitters1[i] do begin
  Result:=FindControllerInSkel(utPTranslation,Skel,ID);
  if Result>0 then begin PopFunction;exit;end;
  if (not IsERStatic) and (round(EmissionRate)=ID) then begin
   IsERStatic:=true;
   EmissionRate:=10;
   Result:=utPER+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsGStatic) and (round(Gravity)=ID) then begin
   IsGStatic:=true;
   Gravity:=0;
   Result:=utPG+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsLongStatic) and (round(Longitude)=ID) then begin
   IsLongStatic:=true;
   Longitude:=10;
   Result:=utPLong+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsLatStatic) and (round(Latitude)=ID) then begin
   IsLatStatic:=true;
   Latitude:=10;
   Result:=utPLat+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsLSStatic) and (round(LifeSpan)=ID) then begin
   IsLSStatic:=true;
   LifeSpan:=2;
   Result:=utPLS+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsIVStatic) and (round(InitVelocity)=ID) then begin
   IsIVStatic:=true;
   InitVelocity:=10;
   Result:=utPIV+i;
   PopFunction;
   exit;
  end;//of if
 end;//of for i

 //Источники частиц (вторая версия)
 for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
  Result:=FindControllerInSkel(utP2Translation,Skel,ID);
  if Result>0 then begin PopFunction;exit;end;
  if (not IsSStatic) and (round(Speed)=ID) then begin
   IsSStatic:=true;
   Speed:=10;
   Result:=utP2S+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsVStatic) and (round(Variation)=ID) then begin
   IsVStatic:=true;
   Variation:=0;
   Result:=utP2V+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsLStatic) and (round(Latitude)=ID) then begin
   IsLStatic:=true;
   Latitude:=10;
   Result:=utP2L+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsGStatic) and (round(Gravity)=ID) then begin
   IsGStatic:=true;
   Gravity:=0;
   Result:=utP2G+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsEStatic) and (round(EmissionRate)=ID) then begin
   IsEStatic:=true;
   EmissionRate:=10;
   Result:=utP2E+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsWStatic) and (round(Width)=ID) then begin
   IsWStatic:=true;
   Width:=10;
   Result:=utP2W+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsHStatic) and (round(Length)=ID) then begin
   IsHStatic:=true;
   Length:=10;
   Result:=utP2H+i;
   PopFunction;
   exit;
  end;//of if
 end;//of for i

 //Источники следа
 for i:=0 to CountOfRibbonEmitters-1 do with ribs[i] do begin
  Result:=FindControllerInSkel(utRTranslation,Skel,ID);
  if Result>0 then begin exit;end;
  if (not IsHAStatic) and (round(HeightAbove)=ID) then begin
   IsHAStatic:=true;
   HeightAbove:=1;
   Result:=utRHA+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsHBStatic) and (round(HeightBelow)=ID) then begin
   IsHBStatic:=true;
   HeightBelow:=10;
   Result:=utRHB+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsAlphaStatic) and (round(Alpha)=ID) then begin
   IsAlphaStatic:=true;
   Alpha:=1.0;
   Result:=utRA+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsColorStatic) and (round(Color[1])=ID) then begin
   IsColorStatic:=true;
   Color[1]:=1;Color[2]:=1;Color[3]:=1;
   Result:=utRC+i;
   PopFunction;
   exit;
  end;//of if
  if (not IsTSStatic) and (TextureSlot=ID) then begin
   IsTSStatic:=true;
   TextureSlot:=0;
   Result:=utRTS+i;
   PopFunction;
   exit;
  end;//of if
 end;//of for i

 //Камеры
 for i:=0 to CountOfCameras-1 do with Cameras[i] do begin
  if TranslationGraphNum=ID then begin
   TranslationGraphNum:=-1;
   Result:=utCTranslation+i;
   PopFunction;
   exit;
  end;//of if
  if RotationGraphNum=ID then begin
   RotationGraphNum:=-1;
   Result:=utCRotation+i;
   PopFunction;
   exit;
  end;//of if
  if TargetTGNum=ID then begin
   TargetTGNum:=-1;
   Result:=utCT+i;
   PopFunction;
   exit;
  end;//of if
 end;//of for i

 //Объекты событий
 for i:=0 to CountOfEvents-1 do with Events[i] do begin
  Result:=FindControllerInSkel(utETranslation,Skel,ID);
  if Result>0 then begin PopFunction;exit;end;
 end;//of for i

 //Сферы границ
 for i:=0 to CountOfCollisionShapes-1 do with Collisions[i] do begin
  Result:=FindControllerInSkel(utCSTranslation,Skel,ID);
  if Result>0 then begin PopFunction;exit;end;
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//Восстанавливает из TUndo секцию текстурных анимаций
//(если она удалялась) и TVertexAnimID в слоях.
//Используется для отмены удаления КК.
procedure RestoreTextureAnims(var u:TUndo);
Var i,ii,num:integer;
Begin
 PushFunction(332);
 //1. Восстановим ID в слоях
 num:=u.MatID;                    //номер первого элемента с ID
 if num>=length(u.VertexList) then begin PopFunction;exit;end;
 for i:=0 to CountOfMaterials-1 do
 for ii:=0 to Materials[i].CountOfLayers-1 do begin
  Materials[i].Layers[ii].TVertexAnimID:=u.VertexList[num];
  inc(num);
 end;//of for ii

 //2. Восстановим собственно секции
 CountOfTextureAnims:=CountOfTextureAnims+u.MatID;
 SetLength(TextureAnims,CountOfTextureAnims);
 for i:=0 to u.MatID-1 do begin
  num:=u.VertexList[i];           //номер секции
  for ii:=CountOfTextureAnims-2 downto num do
   TextureAnims[ii+1]:=TextureAnims[ii];
  TextureAnims[num].TranslationGraphNum:=-1;
  TextureAnims[num].RotationGraphNum:=-1;
  TextureAnims[num].ScalingGraphNum:=-1;
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//Восстанавливает КК контроллеров (и, возможно,
//целые контроллеры) из TUndo.
//Вторая стадия отмены удаления КК.
//Если QuickRestore=true, отмена осуществляется ускоренным способом,
//при котором контроллеры не копируются покадрово
procedure RestoreControllers(var u:TUndo;QuickRestore:boolean);
Var c,c2:cardinal;i,ii,j:integer;
Begin for i:=0 to u.Status2-1 do begin
 //Проверим, не весь ли контроллер нужно восстановить
 c:=u.VertexGroup[i];
 if c=0 then begin                //восстановить часть контроллера
  //в зависимости от типа восстановления
  if QuickRestore then QuickCopyFrames(u.Controllers[i],Controllers[u.idata[i]])
  else
      CopyFrames(u.Controllers[i],Controllers[u.idata[i]],0,$7FFFFFFF,0,-1);
 end else begin                   //восстановить весь контроллер
  //Собственно востановление
  Controllers[u.idata[i]].Items:=u.Controllers[i].Items;
  u.Controllers[i].items:=nil;
  //Разделяем номер и тип объекта
  c2:=c and $FF000000;
  c:=c and $FFFFFF;

  
  //Определяем, что за объект нужно восстановить
  case c2 of
   //Материал
   utMatTexture:begin
    c2:=0;
    for ii:=0 to CountOfMaterials-1 do begin
     for j:=0 to Materials[ii].CountOfLayers-1 do
     with Materials[ii].Layers[j] do begin
      if c2=c then begin
       IsTextureStatic:=false;
       NumOfTexGraph:=u.idata[i];
       c:=0;
       break;
      end;//of if
      inc(c2);
     end;//of with/for j
     if c=0 then break;
    end;//of for ii
   end;//of utMatTexture

   utMatAlpha:begin
    c2:=0;
    for ii:=0 to CountOfMaterials-1 do begin
     for j:=0 to Materials[ii].CountOfLayers-1 do
     with Materials[ii].Layers[j] do begin
      if c2=c then begin
       IsAlphaStatic:=false;
       NumOfGraph:=u.idata[i];
       c:=0;
       break;
      end;//of if
      inc(c2);
     end;//of with/for j
     if c=0 then break;
    end;//of for ii
   end;//of utMatAlpha

   //Текстурные анимации
   utTATranslation:TextureAnims[c].TranslationGraphNum:=u.idata[i];
   utTARotation:TextureAnims[c].RotationGraphNum:=u.idata[i];
   utTAScaling:TextureAnims[c].ScalingGraphNum:=u.idata[i];
   
   //Анимации видимости
   utGAAlpha:with GeosetAnims[c] do begin
    IsAlphaStatic:=false;
    AlphaGraphNum:=u.idata[i];
   end;//of utGAAlpha
   utGAColor:with GeosetAnims[c] do begin
    IsColorStatic:=false;
    ColorGraphNum:=u.idata[i];
   end;//of utGAColor

   //Кости
   utBTranslation:Bones[c].Translation:=u.idata[i];
   utBTranslation+ut:Bones[c].Rotation:=u.idata[i];
   utBTranslation+ut2:Bones[c].Scaling:=u.idata[i];
   utBTranslation+ut3:Bones[c].Visibility:=u.idata[i];

   //Помощники
   utHTranslation:Helpers[c].Translation:=u.idata[i];
   utHTranslation+ut:Helpers[c].Rotation:=u.idata[i];
   utHTranslation+ut2:Helpers[c].Scaling:=u.idata[i];
   utHTranslation+ut3:Helpers[c].Visibility:=u.idata[i];

   //Источники света
   utLTranslation:Lights[c].Skel.Translation:=u.idata[i];
   utLTranslation+ut:Lights[c].Skel.Rotation:=u.idata[i];
   utLTranslation+ut2:Lights[c].Skel.Scaling:=u.idata[i];
   utLTranslation+ut3:Lights[c].Skel.Visibility:=u.idata[i];
   utLAS:with Lights[i] do begin
    IsASStatic:=true;
    AttenuationStart:=u.idata[i];
   end;//of utLAS
   utLAE:with Lights[i] do begin
    IsAEStatic:=true;
    AttenuationEnd:=u.idata[i];
   end;//of utLAE
   utLI:with Lights[i] do begin
    IsIStatic:=true;
    Intensity:=u.idata[i];
   end;//of utLI
   utLC:with Lights[i] do begin
    IsCStatic:=true;
    Color[1]:=u.idata[i];
   end;//of utLC
   utLAI:with Lights[i] do begin
    IsAIStatic:=true;
    AmbIntensity:=u.idata[i];
   end;//of utLAI
   utLAC:with Lights[i] do begin
    IsACStatic:=true;
    AmbColor[1]:=u.idata[i];
   end;//of utLAC

   //Точки прикрепления
   utATranslation:Attachments[c].Skel.Translation:=u.idata[i];
   utATranslation+ut:Attachments[c].Skel.Rotation:=u.idata[i];
   utATranslation+ut2:Attachments[c].Skel.Scaling:=u.idata[i];
   utATranslation+ut3:Attachments[c].Skel.Visibility:=u.idata[i];

   //Источники частиц (первая версия)
   utPTranslation:ParticleEmitters1[c].Skel.Translation:=u.idata[i];
   utPTranslation+ut:ParticleEmitters1[c].Skel.Rotation:=u.idata[i];
   utPTranslation+ut2:ParticleEmitters1[c].Skel.Scaling:=u.idata[i];
   utPTranslation+ut3:ParticleEmitters1[c].Skel.Visibility:=u.idata[i];
   utPER:with ParticleEmitters1[c] do begin
    IsERStatic:=false;
    EmissionRate:=u.idata[i];
   end;//of utPER
   utPG:with ParticleEmitters1[c] do begin
    IsGStatic:=false;
    Gravity:=u.idata[i];
   end;//of utG
   utPLong:with ParticleEmitters1[c] do begin
    IsLongStatic:=false;
    Longitude:=u.idata[i];
   end;//of utLong
   utPLat:with ParticleEmitters1[c] do begin
    IsLatStatic:=false;
    Latitude:=u.idata[i];
   end;//of utLat
   utPLS:with ParticleEmitters1[c] do begin
    IsLSStatic:=false;
    LifeSpan:=u.idata[i];
   end;//of utPLS
   utPIV:with ParticleEmitters1[c] do begin
    IsIVStatic:=false;
    InitVelocity:=u.idata[i];
   end;//of utPIV

   //Источники частиц (вторая версия)
   utP2Translation:pre2[c].Skel.Translation:=u.idata[i];
   utP2Translation+ut:pre2[c].Skel.Rotation:=u.idata[i];
   utP2Translation+ut2:pre2[c].Skel.Scaling:=u.idata[i];
   utP2Translation+ut3:pre2[c].Skel.Visibility:=u.idata[i];
   utP2S:with pre2[c] do begin
    IsSStatic:=false;
    Speed:=u.idata[i];
   end;//of utS
   utP2V:with pre2[c] do begin
    IsVStatic:=false;
    Variation:=u.idata[i];
   end;//of utV
   utP2L:with pre2[c] do begin
    IsLStatic:=false;
    Latitude:=u.idata[i];
   end;//of utL
   utP2G:with pre2[c] do begin
    IsGStatic:=false;
    Gravity:=u.idata[i];
   end;//of utG
   utP2E:with pre2[c] do begin
    IsEStatic:=false;
    EmissionRate:=u.idata[i];
   end;//of utE
   utP2W:with pre2[c] do begin
    IsWStatic:=false;
    Width:=u.idata[i];
   end;//of utW
   utP2H:with pre2[c] do begin
    IsHStatic:=false;
    Length:=u.idata[i];
   end;//of utH

   //Источники следа
   utRTranslation:ribs[c].Skel.Translation:=u.idata[i];
   utRTranslation+ut:ribs[c].Skel.Rotation:=u.idata[i];
   utRTranslation+ut2:ribs[c].Skel.Scaling:=u.idata[i];
   utRTranslation+ut3:ribs[c].Skel.Visibility:=u.idata[i];
   utRHA:with ribs[c] do begin
    IsHAStatic:=false;
    HeightAbove:=u.idata[i];
   end;//of utRHA
   utRHB:with ribs[c] do begin
    IsHBStatic:=false;
    HeightBelow:=u.idata[i];
   end;//of utRHB
   utRA:with ribs[c] do begin
    IsAlphaStatic:=false;
    Alpha:=u.idata[i];
   end;//of utRA
   utRC:with ribs[c] do begin
    IsColorStatic:=false;
    Color[1]:=u.idata[i];
   end;//of utRC
   utRTS:with ribs[c] do begin
    IsTSStatic:=false;
    TextureSlot:=u.idata[i];
   end;//of utRTS

   //Камеры
   utCTranslation:Cameras[c].TranslationGraphNum:=u.idata[i];
   utCRotation:Cameras[c].RotationGraphNum:=u.idata[i];
   utCT:Cameras[c].TargetTGNum:=u.idata[i];

   //Объекты событий
   utETranslation:Events[c].Skel.Translation:=u.idata[i];
   utETranslation+ut:Events[c].Skel.Rotation:=u.idata[i];
   utETranslation+ut2:Events[c].Skel.Scaling:=u.idata[i];
   utETranslation+ut3:Events[c].Skel.Visibility:=u.idata[i];

   //Объекты границ
   utCSTranslation:Collisions[c].Skel.Translation:=u.idata[i];
   utCSTranslation+ut:Collisions[c].Skel.Rotation:=u.idata[i];
   utCSTranslation+ut2:Collisions[c].Skel.Scaling:=u.idata[i];
   utCSTranslation+ut3:Collisions[c].Skel.Visibility:=u.idata[i];
  end;//of case
 end;//of if
end;End;
//---------------------------------------------------------
//Используется сразу после открытия WoW-модели.
//Изменяет анимации так, чтобы КК были в начале
//и в конце каждой анимации
procedure NormalizeWoWAnimations;
Var i:integer;
Begin
 PushFunction(333);
 MinFrame:=0;
 MaxFrame:=$7FFFFFFF;
 UsingGlobalSeq:=-1;

 for i:=0 to CountOfSequences-1 do with Sequences[i] do begin
  CurFrame:=IntervalStart;
  CopyCurFrameToBuffer;
  PasteFramesFromBuffer(CurFrame,$7FFFFFFF,false,false,0);

  CurFrame:=IntervalEnd;
  CopyCurFrameToBuffer;
  PasteFramesFromBuffer(CurFrame,$7FFFFFFF,false,false,0);
 end;//of for i
 PopFunction;
End;
//---------------------------------------------------------
//Создаёт полный комплект анимаций видимости, если это
//нужно. Одновременно в Undo запоминается факт создания
//новых анимаций и их ID.
procedure CreateGeosetAnimsIfNeed;
Var Cur,j,i,hi:integer;IsNeedCreation,IsFound:boolean;
Begin
 PushFunction(334);
 IsNeedCreation:=false;
 Cur:=ShearUndo;
 Undo[Cur].Status1:=uCreateGAController;

 //Цикл "метки" Undo в поверхностях и проверки на необходимость
 //создания анимаций видимости
 for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
  Undo[Cur].Unselectable:=false;  //признак создания GeosetAnim
  IsFound:=false;
  if GeoObjs[j].IsSelected then for i:=0 to CountOfGeosetAnims-1 do begin
   if GeosetAnims[i].GeosetID=j then begin
    IsFound:=true;
    break;
   end;//of if
  end;//of for i/if

  //Проверим, найдена ли нужная анимация видимости
  if not IsFound then begin       //нет
   IsNeedCreation:=true;          //нужно создать
   break;
  end;//of if
 end;//of for j

 if not IsNeedCreation then begin PopFunction;exit;end; //создавать не нужно

 //Теперь - цикл создания полного комплекта
 hi:=CountOfGeosetAnims-1;
 for j:=0 to CountOfGeosets-1 do if (j>hi) or (GeosetAnims[j].GeosetID<>j)
 then begin
  ARGeosetAnim(j,j,1);            //добавить
  GeoObjs[j].Undo[Cur].Unselectable:=true;//отметить факт добавки

  with GeosetAnims[j] do begin
   GeosetID:=j;
   Alpha:=1;
   IsAlphaStatic:=true;
   IsColorStatic:=true;
   //Проверим, нужно ли создавать цвет
   if Materials[Geosets[j].MaterialID].IsConstantColor then begin
    Color[1]:=1;Color[2]:=1;Color[3]:=1;
   end else begin                 //не нужно
    Color[1]:=-1;Color[2]:=-1;Color[3]:=-1;
   end;//of if
   IsDropShadow:=false;
   AlphaGraphNum:=-1;
   ColorGraphNum:=-1;
  end;//of with

 end;//of for j
 PopFunction;
End;
//---------------------------------------------------------
//Преобразует тип контроллера.
//Предварительно сохраняет данные контроллера для отмены
procedure TranslateControllerType(ContNum,NewType:integer;var SaveC:TController);
Var len,i:integer;it:TContItem;
Begin
 PushFunction(335);
 len:=length(Controllers[ContNum].Items);
 //1. Сохраним контроллер для последующей отмены
 if Controllers[ContNum].ContType=NewType then begin
  PopFunction;
  exit;//нет смысла преобразовывать
 end;
 cpyController(Controllers[ContNum],SaveC);

 //2. Проверим, в какой тип нужно провести преобразование
 if (Controllers[ContNum].ContType=DontInterp)
 and (NewType<>DontInterp) and (NewType<>OnOff) then
 with Controllers[ContNum] do begin//преобразование
  ContType:=NewType;
  it:=Items[0];                  //нулевой кадр
  it.InTan[1]:=0;it.InTan[2]:=0;it.InTan[3]:=0;it.InTan[4]:=0;
  it.OutTan[1]:=0;it.OutTan[2]:=0;it.OutTan[3]:=0;it.OutTan[4]:=0;
  //Цикл последовательной обработки всех кадров
  i:=0;
  while i<len do begin
   inc(i);
   if it.Frame-Items[i].Frame<2 then continue; //кадры идут подряд
   it.Frame:=Items[i].Frame-1;
   InsertFrame(Controllers[ContNum],it);
   inc(len);
   it:=Items[i];
   inc(i);
  end;//of while i
  PopFunction;
  exit;                           //выход
 end;//of if (NewType=DontInterp)

 //Преобразование в "простой" тип
 if (NewType=Linear) or (NewType=DontInterp)
 then Controllers[ContNum].ContType:=NewType;

 if NewType=OnOff then Controllers[ContNum].ContType:=DontInterp;

 //Преобразование в особый тип on/off
 if NewType=OnOff then with Controllers[ContNum] do for i:=0 to High(Items) do
 begin 
  if Items[i].Data[1]<0.75 then Items[i].Data[1]:=0
                           else Items[i].Data[1]:=1;
 end;//of if

 //Преобразование в один из "сложных" типов
 if (NewType=Hermite) or (NewType=Bezier)
 then with Controllers[ContNum] do for i:=0 to High(items) do begin
  Items[i].InTan[1]:=Items[i].Data[1]; Items[i].OutTan[1]:=Items[i].Data[1];
  Items[i].InTan[2]:=Items[i].Data[2]; Items[i].OutTan[2]:=Items[i].Data[2];
  Items[i].InTan[3]:=Items[i].Data[3]; Items[i].OutTan[3]:=Items[i].Data[3];
  Items[i].InTan[4]:=Items[i].Data[4]; Items[i].OutTan[4]:=Items[i].Data[4];
  ContType:=NewType;
 end;//of for i/with/if (Hermite,Bezier)
 PopFunction;
End;
//---------------------------------------------------------
//Проверяет указанный материал на ConstantColor.
//Предназначена для работы в цикле.
//Устанавливает ConstantColor, проверяет все анимации видимости
//Устанавливает там цвет в случае его отсутствия для всех
//поверхностей, использующих данный материал.
procedure TestMaterialColors(MatID:integer);
Var j,Cur,len:integer;
Begin
 Cur:=CountOfUndo;
 if Materials[MatID].IsConstantColor then exit; //цвет уже установлен
 PushFunction(336);

 //1. Изменим цвет (отметив номер материала)
 Materials[MatID].IsConstantColor:=true;
 len:=Length(Undo[Cur].VertexGroup)+1;
 SetLength(Undo[Cur].VertexGroup,len);
 Undo[Cur].VertexGroup[len-1]:=MatID;

 //2. Теперь пробежимся по всему списку GeosetAnims,
 //выясняя, не нужно ли там прописать цвет
 len:=length(Undo[Cur].VertexList);
 for j:=0 to CountOfGeosetAnims-1 do with GeosetAnims[j] do begin
  if (Geosets[GeosetID].MaterialID=MatID) and IsColorStatic and
     (Color[1]<0) then begin
   inc(len);
   SetLength(Undo[Cur].VertexList,len);
   Undo[Cur].VertexList[len-1]:=j;
   Color[1]:=1;Color[2]:=1;Color[3]:=1;
  end;//of if
 end;//of with/for j
 PopFunction;
End;
//---------------------------------------------------------
//Сохраняет данные указанного кадра контроллера.
//Может вызываться в цикле для нескольких контроллеров
//Перед первым вызовом нужно использовать AnimSaveUndo(uChangeFrame,0);
procedure SaveContFrame(ContID,Frame:integer);
Var i,len,num:integer;it:TContItem;
Begin
 PushFunction(337);
 //1. Выделим место под сохранение кадра
 with Undo[CountOfUndo] do begin
  inc(Status2);
  len:=Status2;
  SetLength(Controllers,Status2);
  SetLength(idata,status2);
  idata[len-1]:=ContID;
 end;

 //Резервируем место под единственный кадр
 SetLength(Undo[CountOfUndo].Controllers[len-1].Items,1);

 //Ищем указанный кадр в исходном контроллере
 num:=0;
 for i:=0 to High(Controllers[ContID].Items)
 do if Controllers[ContID].Items[i].Frame>=Frame then begin
  num:=i;
  break;
 end;//of if

 //Проверяем, найдено ли
 if Controllers[ContID].Items[num].Frame<>Frame then begin
  //не найдено, отмечаем это
  it.Frame:=Frame;
  Undo[CountOfUndo].Controllers[len-1].SizeOfElement:=0;
  Undo[CountOfUndo].Controllers[len-1].Items[0]:=it;
 end else begin
  //найдено, запомним
  Undo[CountOfUndo].Controllers[len-1].SizeOfElement:=4;
  Undo[CountOfUndo].Controllers[len-1].Items[0]:=Controllers[ContID].Items[num];
 end;//of if
 PopFunction;
End;
//---------------------------------------------------------
//Изменяет имя объекта с указанным ID на NewName
//поля в cb_bonelist и lv_obj нужно изменить отдельно
procedure SetObjectName(id:integer;NewName:string);
Begin
 PushFunction(338);
 case GetTypeObjByID(id) of
  typBONE:begin
   if id>Bones[CountOfBones-1].ObjectID then begin PopFunction;exit;end;
   Bones[id-Bones[0].ObjectID].Name:=NewName;
  end;//of typBONE
  typHELP:begin
   if id>Helpers[CountOfHelpers-1].ObjectID then begin PopFunction;exit;end;
   Helpers[id-Helpers[0].ObjectID].Name:=NewName;
  end;//of typHELP
  typATCH:begin
   if id>Attachments[CountOfAttachments-1].Skel.ObjectID then begin
    PopFunction;
    exit;
   end;
   Attachments[id-Attachments[0].Skel.ObjectID].Skel.Name:=NewName;
  end;//of typATCH
  typPRE2:begin
   if id>pre2[CountOfParticleEmitters-1].Skel.ObjectID then begin
    PopFunction;
    exit;
   end;
   pre2[id-pre2[0].Skel.ObjectID].Skel.Name:=NewName;
  end;//of typPRE2
 end;//of case
 PopFunction;
End;
//---------------------------------------------------------
//Осуществляет инкремент/декремент (в зависимости от флага IsInc)
//Всех ID объектов с ID>=указанного.
//Вставить новый объект нужно отдельно
procedure IncDecObjectIDs(id:integer;IsInc:boolean);
Var i,ii,j:integer;
Begin
 PushFunction(339);
 //1. Сдвинуть ObjectID/Parent всех объектов
 //NullBone (если есть)
 if NullBone.IsExists then begin
  if NullBone.id>=id then begin
   if IsInc then begin
    inc(NullBone.id);
    inc(NullBone.IdInBones);
   end else begin
    dec(NullBone.id);
    dec(NullBone.IdInBones);
   end;//of if(else)
  end;//of if
 end;//of if

 //a. Кости
 for i:=0 to CountOfBones-1 do with Bones[i] do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i

 //b. Источники света
 for i:=0 to CountOfLights-1 do with Lights[i].Skel do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i

 //c. Помощники
 for i:=0 to CountOfHelpers-1 do with Helpers[i] do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i

 //d. Аттачи
 for i:=0 to CountOfAttachments-1 do with Attachments[i].Skel do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i

 //e. Источники частиц
 for i:=0 to CountOfParticleEmitters1-1
 do with ParticleEmitters1[i].Skel do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i

 //f. Источники частиц (вторая версия)
 for i:=0 to CountOfParticleEmitters-1 do with pre2[i].Skel do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i

 //g. Источники следа
 for i:=0 to CountOfRibbonEmitters-1 do with Ribs[i].Skel do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i

 //h. События
 for i:=0 to CountOfEvents-1 do with Events[i].Skel do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i

 //I. Объекты границ
 for i:=0 to CountOfCollisionShapes-1 do with Collisions[i].Skel do begin
  if ObjectID>=id then begin      //нужен сдвиг
   if IsInc then inc(ObjectID) else dec(ObjectID);
  end;//of if
  if Parent>=id then begin
   if IsInc then inc(Parent) else begin
    if Parent=id then Parent:=-1 else dec(Parent);
   end;//of else
  end;//of if
 end;//of for i
//-------------------------------------------------------

 //2. Изменить ID в Matrices поверхностей
 for j:=0 to CountOfGeosets-1 do for i:=0 to Geosets[j].CountOfMatrices-1
 do for ii:=0 to High(Geosets[j].Groups[i])
 do if Geosets[j].Groups[i,ii]>=id then begin
  if IsInc then inc(Geosets[j].Groups[i,ii]) else dec(Geosets[j].Groups[i,ii]);
 end;//of if/for ii/i/j
 PopFunction;
End;
//---------------------------------------------------------
//Производит сдвиг компонент массива PivotPoints так,
//чтобы освободить место под объект ObjectID
//Даже если ID находится за пределами массива,
//процедура всё равно работает, просто увеличивая массив
procedure ReservePivotSpace(id:integer);
Var i:integer;
Begin
 PushFunction(340);
 inc(CountOfPivotPoints);
 SetLength(PivotPoints,CountOfPivotPoints);

 //Теперь производим собственно сдвиг
 for i:=CountOfPivotPoints-2 downto id do PivotPoints[i+1]:=PivotPoints[i];
 PopFunction;
End;
//---------------------------------------------------------
//Удаляет повторяющиеся матрицы костей в указанной поверхности.
//VertexGroups изменяются автоматически
procedure ReduceMatrices(GeoId:integer);
 function IsGroupsEqual(g1,g2:TFace):boolean;
 Var i:integer;
 Begin
  Result:=false;
  if length(g1)<>length(g2) then exit;
  for i:=0 to High(g1) do if g1[i]<>g2[i] then exit;
  Result:=true;
 End;
Var i,ii,j:integer;IsUnused:boolean;
Begin with Geosets[GeoID] do begin
 PushFunction(341);
 i:=0;
 while i<=CountOfMatrices-1 do begin
  ii:=i+1;
  while ii<=CountOfMatrices-1 do begin
   if IsGroupsEqual(Groups[i],Groups[ii]) then begin
    //1. Удаляем повторные матрицы
    for j:=ii to CountOfMatrices-2 do Groups[j]:=Groups[j+1];
    dec(CountOfMatrices);
    SetLength(Groups,CountOfMatrices);

    //2. Модифицируем массив VertexGroup
    for j:=0 to CountOfVertices-1 do begin
     if VertexGroup[j]=ii then VertexGroup[j]:=i
     else begin
      if VertexGroup[j]>ii then dec(VertexGroup[j]);
     end;//of else
    end;//of for j

    continue;
   end;//of if
   inc(ii);
  end;//of while ii
  inc(i);
 end;//of while i

 //Удаляем неиспользуемые матрицы
 i:=0;
 while i<=CountOfMatrices-1 do begin
  IsUnused:=true;
  for ii:=0 to CountOfVertices-1 do if VertexGroup[ii]=i then begin
   IsUnused:=false;
   break;
  end;//of if/for ii

  if IsUnused then begin          //нужно удалять
   for j:=i to CountOfMatrices-2 do Groups[j]:=Groups[j+1];
   dec(CountOfMatrices);
   SetLength(Groups,CountOfMatrices);

   //2. Модифицируем массив VertexGroup
   for j:=0 to CountOfVertices-1 do if VertexGroup[j]>i
   then dec(VertexGroup[j]);
   continue;
  end;//of if(неиспользуемая матрица)
  inc(i);
 end;//of for i
 PopFunction;
end;End;
//---------------------------------------------------------
//Производит удаление скелетного объекта (полностью).
procedure DeleteSkelObj(id:integer);
Var typ,j,i,ii,Delta:integer;
    NeedNull:boolean;
Begin
 PushFunction(342);
 NeedNull:=false;                 //пока объект-"заглушка" не нужен
 //1. Чистка Matrices всех поверхностей
 //от объекта с указанным id (если это кость)
 typ:=GetTypeObjByID(id);
 if typ=typBONE then begin
  for j:=0 to CountOfGeosets-1 do with Geosets[j] do begin
   for i:=0 to CountOfMatrices-1 do begin
    Delta:=0;
    for ii:=0 to High(Groups[i]) do begin
     if Groups[i,ii]=id then begin inc(delta);continue;end;
     if Delta<>0 then Groups[i,ii-Delta]:=Groups[i,ii];
    end;//of for ii
    SetLength(Groups[i],length(Groups[i])-Delta);//изменить длину
   end;//of for i

   //Ищем: нет ли пустых массивов Matrices
   for i:=0 to CountOfMatrices-1 do if length(Groups[i])=0 then begin
    NeedNull:=true;
    break;
   end;//of if/for i
  end;//of with/for j
 end;//of if (typ=typBONE)

 //4. Если нужна null-кость - задействовать её
 if NeedNull and (typ=typBONE) then begin
  //Если таковой нет - преобразовать в неё удаляемый объект
  if not NullBone.IsExists then begin
   NullBone.IsExists:=true;
   NullBone.id:=id;
   NullBone.IdInBones:=id-Bones[0].ObjectID;
   with Bones[NullBone.IdInBones] do begin
    name:='bone_null';
    IsBillboarded:=false;
    IsCameraAnchored:=false;
    GeosetID:=Multiple;
    GeosetAnimID:=None;
    IsBillboardedLockX:=false;
    IsBillboardedLockY:=false;
    IsBillboardedLockZ:=false;
    Parent:=-1;
    Translation:=-1;
    Rotation:=-1;
    Scaling:=-1;
    Visibility:=-1;
    IsDITranslation:=false;
    IsDIRotation:=false;
    IsDIScaling:=false;
    NeedNull:=false;
   end;//of with
  end;//of if

  //Пополняем все пустые матрицы ID нулевой кости
  for j:=0 to CountOfGeosets-1 do for i:=0 to Geosets[j].CountOfMatrices-1
  do if Length(Geosets[j].Groups[i])=0 then begin
   SetLength(Geosets[j].Groups[i],1);
   Geosets[j].Groups[i,0]:=NullBone.id;
  end;//of if/for i/j
 end;//of if

 //3. Удалить Pivot с координатами объекта
 if not ((typ=typBONE) and NullBone.IsExists and (NullBone.id=id)) then begin
  for i:=id to CountOfPivotPoints-2 do PivotPoints[i]:=PivotPoints[i+1];
  dec(CountOfPivotPoints);
  SetLength(PivotPoints,CountOfPivotPoints);
 end;//of if

 //5. Собственно удаление (сдвиг объектов)
 case typ of
  typBONE:if not (NullBone.IsExists and (NullBone.id=id)) then begin
   //только если объект не преобразован
   for i:=id-Bones[0].ObjectID to CountOfBones-2 do Bones[i]:=Bones[i+1];
   dec(CountOfBones);
   SetLength(Bones,CountOfBones);
  end;//of typBONE
  typHELP:begin
   for i:=id-Helpers[0].ObjectID to CountOfHelpers-2
   do Helpers[i]:=Helpers[i+1];
   dec(CountOfHelpers);
   SetLength(Helpers,CountOfHelpers);
  end;//of typHELP
  typATCH:begin
   for i:=id-Attachments[0].Skel.ObjectID to CountOfAttachments-2
   do Attachments[i]:=Attachments[i+1];
   dec(CountOfAttachments);
   SetLength(Attachments,CountOfAttachments);
  end;//of typATCH
  typPRE2:begin
   for i:=id-pre2[0].Skel.ObjectID to CountOfParticleEmitters-2
   do pre2[i]:=pre2[i+1];
   dec(CountOfParticleEmitters);
   SetLength(pre2,CountOfParticleEmitters);
  end;//of typPRE2
 end;//of case

 if not ((typ=typBONE) and NullBone.IsExists and (NullBone.id=id)) then begin
  IncDecObjectIds(id,false);       //Проводим сдвиг массивов
 end;//of if
 //6. Если удалена кость, убираем повторяющиеся матрицы
 if typ=typBONE then for j:=0 to CountOfGeosets-1 do ReduceMatrices(j);
 PopFunction;
End;
//---------------------------------------------------------
//Производит удаление костей/помощников,
//к которым ничего не прикреплено
procedure DeleteFreeBones;
Var j,i,ii,ind:integer; lst:TList; IsChange:boolean;
procedure DeleteIfExists(id:integer);
Var index:integer;
Begin
 index:=lst.IndexOf(pointer(id));
 if index>=0 then begin
  lst.Delete(index);
  IsChange:=true;
 end;//of if
end;//of if
Begin
 PushFunction(383);
 lst:=TList.Create;
 lst.Clear;

 //1. Составим список всех помощников и всех костей
 for i:=0 to CountOfBones-1 do lst.Add(pointer(Bones[i].ObjectID));
 for i:=0 to CountOfHelpers-1 do lst.Add(pointer(Helpers[i].ObjectID));

 //2. Удалим из списка все кости, к которым
 //крепятся вершины
 for j:=0 to CountOfGeosets-1 do for i:=0 to Geosets[j].CountOfMatrices-1
 do for ii:=0 to High(Geosets[j].Groups[i])
 do DeleteIfExists(Geosets[j].Groups[i,ii]);

 //3. Удалим из списка все к/п, к которым крепятся
 //другие объекты (источники, аттачи и пр.)
 for i:=0 to CountOfLights-1 do if Lights[i].Skel.Parent>=0
 then DeleteIfExists(Lights[i].Skel.Parent);

 for i:=0 to CountOfAttachments-1 do if Attachments[i].Skel.Parent>=0
 then DeleteIfExists(Attachments[i].Skel.Parent);

 for i:=0 to CountOfParticleEmitters1-1
 do if ParticleEmitters1[i].Skel.Parent>=0
 then DeleteIfExists(ParticleEmitters1[i].Skel.Parent);

 for i:=0 to CountOfParticleEmitters-1 do if pre2[i].Skel.Parent>=0
 then DeleteIfExists(pre2[i].Skel.Parent);

 for i:=0 to CountOfRibbonEmitters-1 do if Ribs[i].Skel.Parent>=0
 then DeleteIfExists(Ribs[i].Skel.Parent);

 for i:=0 to CountOfEvents-1 do if Events[i].Skel.Parent>=0
 then DeleteIfExists(Events[i].Skel.Parent);

 for i:=0 to CountOfCollisionShapes-1 do if Collisions[i].Skel.Parent>=0
 then DeleteIfExists(Collisions[i].Skel.Parent);

 //4. Будем удалять все объекты, к которым крепится что-либо
 //из тех костей/помощников, которых уже нет в списке.
 //Удаление проводим до тех пор, пока либо не опустеет список,
 //либо содержимое списка прекратит изменяться.
 repeat
  IsChange:=false;
  for i:=0 to CountOfBones-1
  do if (Bones[i].Parent>=0) and (lst.IndexOf(pointer(Bones[i].ObjectID))<0)
  then DeleteIfExists(Bones[i].Parent);

  for i:=0 to CountOfHelpers-1
  do if (Helpers[i].Parent>=0) and (lst.IndexOf(pointer(Helpers[i].ObjectID))<0)
  then DeleteIfExists(Helpers[i].Parent);
 until (not IsChange) or (lst.Count=0);

 //5. Удалим все объекты, попавшие в список.
 if lst.Count>0 then for i:=lst.Count-1 downto 0
 do DeleteSkelObj(integer(lst.Items[i]));

 lst.Free;
 PopFunction;
End;
//---------------------------------------------------------
//Производит поиск "нулевой" кости
//В зависимости от результата устанавливает NullBone
procedure FindNullBone;
Var i:integer;
Begin
 PushFunction(343);
 NullBone.IsExists:=false;        //пока не найдена
 for i:=0 to CountOfBones-1 do with Bones[i]
 do if (Name='bone_null') and (IsBillboarded=false) and (Parent=-1) and
       (Translation<0) and (Rotation<0) and (Scaling<0) and (Visibility<0) and
       (GeosetID=Multiple) and (GeosetAnimID=None) then begin
  NullBone.IsExists:=true;
  NullBone.id:=ObjectID;
  NullBone.IdInBones:=i;
 end;//of if/with/for i
 PopFunction;
End;
//---------------------------------------------------------
//Удаляет "нулевую" кость, если она нигде не используется
procedure DeleteNullBone;
Var j,i,ii,jj,len,id:integer;
Begin
 if not NullBone.IsExists then exit; //нет нулевой кости
 PushFunction(344);

 //0. Если вершины связаны с чем-либо ещё,
 //удаляем ID заглушки из VertexGroup
 for j:=0 to CountOfGeosets-1 do for i:=0 to Geosets[j].CountOfMatrices-1
 do begin
  if length(Geosets[j].Groups[i])>1 then begin //есть ещё что-то
   ii:=0;
   while ii<High(Geosets[j].Groups[i]) do begin
    len:=High(Geosets[j].Groups[i]);
    if Geosets[j].Groups[i,ii]=NullBone.id then begin
     for jj:=ii to len-1
     do Geosets[j].Groups[i,ii]:=Geosets[j].Groups[i,ii+1];
     SetLength(Geosets[j].Groups[i],len);
     continue;
    end;//of if
    inc(ii);
   end;//of while
  end;//of if
 end;//of for j

 //1. Проверим, используется ли нулевая кость
 for j:=0 to CountOfGeosets-1 do for i:=0 to Geosets[j].CountOfMatrices-1
 do for ii:=0 to High(Geosets[j].Groups[i])
 do if Geosets[j].Groups[i,ii]=NullBone.id then begin PopFunction;exit;end;

 //2. Итак, кость не используется. Удаляем!
 id:=NullBone.id;
 NullBone.IsExists:=false;
 DeleteSkelObj(NullBone.id);      //удаление
 if SelObj.IsSelected then begin
  if SelObj.b.ObjectID>id then dec(SelObj.b.ObjectID);
  if SelObj.b.Parent>id then dec(SelObj.b.Parent);
 end;//of if
 PopFunction;
End;
//---------------------------------------------------------
//Производит связывание объектов (изменяет при необходимости
//порядок их следования, ID, матрицы и VertexGroup)
procedure AttachObject;
Var b,bTmp:TBone;
Begin
 if (not (ChObj.IsSelected and SelObj.IsSelected)) or
    ((ChObj.b.Parent=SelObj.b.Parent) and (ChObj.b.Parent>=0)) then exit;
 PushFunction(345);

 //1. Проверка, не является ли объект родителем самого себя ;)
 bTmp:=SelObj.b;
 Undo[CountOfUndo].MatID:=-1;
 if SelObj.b.Parent>=0 then begin
  b:=SelObj.b;
  while b.Parent>=0 do begin
   if b.Parent=ChObj.b.ObjectID then begin
    Undo[CountOfUndo].MatID:=b.ObjectID;
    Undo[CountOfUndo].HierID:=b.Parent;
    SelObj.b:=b;
    SelObj.b.Parent:=-1;
    SetSkelPart;
    break;
   end;//of if
   b:=GetSkelObjectByID(b.Parent);
  end;//of while
 end;//of if (Parent>=0)

 //2. Проводим присоединение
 SelObj.b:=ChObj.b;
 SelObj.b.Parent:=bTmp.ObjectID;
 ChObj.b.Parent:=bTmp.ObjectID;
 if SelObj.b.ObjectID=SelObj.b.Parent then SelObj.b.Parent:=-1;
 if ChObj.b.Parent=ChObj.b.ObjectID then ChObj.b.Parent:=-1;
 SetSkelPart;                     //присоединение
 SelObj.b:=bTmp;

 //3. Теперь проходим по списку объектов в поисках
 //нарушения порядка (каждый Child должен идти ПОСЛЕ parent)
{ case GetTypeObjByID(ChObj.b.ObjectID) of
  //При этом если тип родительского объекта не совпадает
  //с типом дочернего объекта,
  //никаких действий не выполняется
  typBONE:if GetTypeObjByID(ChObj.b.Parent)=typBONE then begin

  end;//of typBONE
 end;//of case}
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательная: конвертирует SelObj.b в кость
//(из помощника) и возвращает новый id в SelObj.b.ObjectID
procedure ConvertHelperToBone;
Var id,i:integer;pv:TVertex;
Begin
  PushFunction(346);
  pv:=PivotPoints[SelObj.b.ObjectID];  //сохранить координату
  for i:=0 to CountOfBones-1 do if Bones[i].Parent=SelObj.b.ObjectID
  then Bones[i].Parent:=-2;       //спец. флаг
  for i:=0 to CountOfLights-1 do if Lights[i].Skel.Parent=SelObj.b.ObjectID
  then Lights[i].Skel.Parent:=-2;
  for i:=0 to CountOfHelpers-1 do if Helpers[i].Parent=SelObj.b.ObjectID
  then Helpers[i].Parent:=-2;     //спец. флаг
  for i:=0 to CountOfAttachments-1
  do if Attachments[i].Skel.Parent=SelObj.b.ObjectID
  then Attachments[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfParticleEmitters1-1
  do if ParticleEmitters1[i].Skel.Parent=SelObj.b.ObjectID
  then ParticleEmitters1[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfParticleEmitters-1
  do if Pre2[i].Skel.Parent=SelObj.b.ObjectID
  then Pre2[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfRibbonEmitters-1
  do if Ribs[i].Skel.Parent=SelObj.b.ObjectID
  then Ribs[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfEvents-1
  do if Events[i].Skel.Parent=SelObj.b.ObjectID
  then Events[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfCollisionShapes-1
  do if Collisions[i].Skel.Parent=SelObj.b.ObjectID
  then Collisions[i].Skel.Parent:=-2; //спец. флаг

  DeleteSkelObj(SelObj.b.ObjectID); //удалить помощник
  with SelObj.b do if (Parent>=0) and (Parent>ObjectID) then dec(Parent);
  //создаём эквивалентную кость
  id:=Bones[CountOfBones-1].ObjectID+1;
  ReservePivotSpace(id);          //создать центр
  PivotPoints[id]:=pv;
  IncDecObjectIDs(id,true);       //сдвиг
  inc(CountOfBones);
  SetLength(Bones,CountOfBones);
  SelObj.b.GeosetAnimID:=None;
  SelObj.b.ObjectID:=id;
  with SelObj.b do if (Parent>=0) and (Parent>ObjectID) then inc(Parent);
  Bones[CountOfBones-1]:=SelObj.b;

  //Теперь устанавливаем родительские связи
  for i:=0 to CountOfBones-1 do if Bones[i].Parent=-2
  then Bones[i].Parent:=SelObj.b.ObjectID;
  for i:=0 to CountOfLights-1 do if Lights[i].Skel.Parent=-2
  then Lights[i].Skel.Parent:=SelObj.b.ObjectID;
  for i:=0 to CountOfHelpers-1 do if Helpers[i].Parent=-2
  then Helpers[i].Parent:=SelObj.b.ObjectID;
  for i:=0 to CountOfAttachments-1
  do if Attachments[i].Skel.Parent=-2
  then Attachments[i].Skel.Parent:=SelObj.b.ObjectID; //спец. флаг
  for i:=0 to CountOfParticleEmitters1-1
  do if ParticleEmitters1[i].Skel.Parent=-2
  then ParticleEmitters1[i].Skel.Parent:=SelObj.b.ObjectID; //спец. флаг
  for i:=0 to CountOfParticleEmitters-1
  do if Pre2[i].Skel.Parent=-2
  then Pre2[i].Skel.Parent:=SelObj.b.ObjectID; //спец. флаг
  for i:=0 to CountOfRibbonEmitters-1
  do if Ribs[i].Skel.Parent=-2
  then Ribs[i].Skel.Parent:=SelObj.b.ObjectID; //спец. флаг
  for i:=0 to CountOfEvents-1
  do if Events[i].Skel.Parent=-2
  then Events[i].Skel.Parent:=SelObj.b.ObjectID; //спец. флаг
  for i:=0 to CountOfCollisionShapes-1
  do if Collisions[i].Skel.Parent=-2
  then Collisions[i].Skel.Parent:=SelObj.b.ObjectID; //спец. флаг
  PopFunction;
End;

//Вспомогательная: применяется для сортировки списка
function cmpItems(Item1, Item2:pointer):integer;
Begin
 Result:=integer(Item1)-integer(Item2);
End;

//Вспомогательная: присоединяет вершины к кости.
//при этом создаются новые матрицы. Старые, если надо,
//удаляются. Может измениться также значение GeosetID в кости
procedure AttachSelectedVertices;
Var lst,lst2:TList;
    i,ii,j,vg:integer;
Begin
 PushFunction(347);
 lst:=TList.Create;
 lst2:=TList.Create;

 for j:=0 to CountOfGeosets-1 do with Geosets[j]
 do if GeoObjs[j].IsSelected then begin
  if GeoObjs[j].VertexCount=0 then continue;

  //1. Составляем список VertexGroup выделенных костей
  lst.Clear;
  for i:=0 to GeoObjs[j].VertexCount-1
  do if lst.IndexOf(pointer(VertexGroup[GeoObjs[j].VertexList[i]-1]))<0
  then lst.Add(pointer(VertexGroup[GeoObjs[j].VertexList[i]-1]));

  //2. Дублируем каждую матрицу, пополняем её ID выделенной кости
  for i:=0 to lst.Count-1 do begin
   lst2.Clear;                    //очистить список костей
   vg:=integer(lst.items[i]);     //получить ID матрицы

   //Заполнить список данными старой матрицы
   for ii:=0 to High(Groups[vg])
   do if lst2.IndexOf(pointer(Groups[vg,ii]))<0
   then lst2.Add(pointer(Groups[vg,ii]));

   //Прибавить выделенную кость
   if lst2.IndexOf(pointer(SelObj.b.ObjectID))<0
   then lst2.Add(pointer(SelObj.b.ObjectID));

   lst2.Sort(cmpItems);           //Сортировать список
   //Копируем в новую матрицу
   //создать новую матрицу, по длине совпадающую с исходной
   inc(CountOfMatrices);
   SetLength(Groups,CountOfMatrices);
   SetLength(Groups[CountOfMatrices-1],lst2.Count);
   for ii:=0 to lst2.Count-1
   do Groups[CountOfMatrices-1,ii]:=integer(lst2.Items[ii]);

   //Меняем VertexGroup для выделенных вершин
   for ii:=0 to GeoObjs[j].VertexCount-1
   do if VertexGroup[GeoObjs[j].VertexList[ii]-1]=vg
   then VertexGroup[GeoObjs[j].VertexList[ii]-1]:=CountOfMatrices-1;

   //Меняем GeosetID кости
   if SelObj.b.GeosetID<>j then begin
    SelObj.b.GeosetID:=Multiple;
    SetSkelPart;
   end;//of if
  end;//of for i

  //Теперь удаляем повторяющиеся и неиспользуемые матрицы
  ReduceMatrices(j);
 end;//of if/with/for j

 lst.Free;
 lst2.Free;
 PopFunction;
End;

//Присоединяет вершины к указанной кости.
//Если выделен помощник, он конвертируется в кость
procedure AttachVertices;
Begin
 if (not SelObj.IsSelected) or
    ((SelObj.ObjType<>typBONE) and (SelObj.ObjType<>typHELP)) then exit;
 PushFunction(348);

 //Если выделен помощник, переделать его в кость
 if SelObj.ObjType=typHELP then ConvertHelperToBone;

 //Присоединить вершины к кости путём создания новых матриц
 AttachSelectedVertices;
 DeleteNullBone;                  //если кость-заглушка не нужна - удаляем
 PopFunction;
End;
//---------------------------------------------------------

//Вспомогательная: присоединяет вершины к указанной кости,
//отсоединяя их от остальных костей
procedure ReAttachSelectedVertices;
Var ii,j:integer;
Begin
 PushFunction(349);
 for j:=0 to CountOfGeosets-1 do with Geosets[j]
 do if GeoObjs[j].IsSelected then begin
  if GeoObjs[j].VertexCount=0 then continue;

   //1. Создать новую матрицу, содержащую указанную кость
   inc(CountOfMatrices);
   SetLength(Groups,CountOfMatrices);
   SetLength(Groups[CountOfMatrices-1],1);
   Groups[CountOfMatrices-1,0]:=SelObj.b.ObjectID;

   //Меняем VertexGroup для выделенных вершин
   for ii:=0 to GeoObjs[j].VertexCount-1
   do VertexGroup[GeoObjs[j].VertexList[ii]-1]:=CountOfMatrices-1;

   //Меняем GeosetID кости
   if SelObj.b.GeosetID<>j then begin
    SelObj.b.GeosetID:=Multiple;
    SetSkelPart;
   end;//of if

  //Теперь удаляем повторяющиеся и неиспользуемые матрицы
  ReduceMatrices(j);
 end;//of if/with/for j
 PopFunction;
End;

//Вспомогательная: преобразует кость с указанным ID в помощник
procedure ConvertBoneToHelper(id:integer);
Var id2,i:integer;pv:TVertex;
    b:TBone;
Begin
  PushFunction(350);
  b:=Bones[id-Bones[0].ObjectID];
  pv:=PivotPoints[id];            //сохранить координату
  for i:=0 to CountOfBones-1 do if Bones[i].Parent=id
  then Bones[i].Parent:=-2;       //спец. флаг
  for i:=0 to CountOfLights-1 do if Lights[i].Skel.Parent=id
  then Lights[i].Skel.Parent:=-2;
  for i:=0 to CountOfHelpers-1 do if Helpers[i].Parent=id
  then Helpers[i].Parent:=-2;     //спец. флаг
  for i:=0 to CountOfAttachments-1
  do if Attachments[i].Skel.Parent=id
  then Attachments[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfParticleEmitters1-1
  do if ParticleEmitters1[i].Skel.Parent=id
  then ParticleEmitters1[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfParticleEmitters-1
  do if Pre2[i].Skel.Parent=id
  then Pre2[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfRibbonEmitters-1
  do if Ribs[i].Skel.Parent=id
  then Ribs[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfEvents-1
  do if Events[i].Skel.Parent=id
  then Events[i].Skel.Parent:=-2; //спец. флаг
  for i:=0 to CountOfCollisionShapes-1
  do if Collisions[i].Skel.Parent=id
  then Collisions[i].Skel.Parent:=-2; //спец. флаг

  DeleteSkelObj(id);              //удалить кость
  if (b.Parent>=0) and (b.Parent>id) then dec(b.Parent);
  if SelObj.b.ObjectID>id then dec(SelObj.b.ObjectID);
//  if SelObj.b.Parent>id then dec(SelObj.b.Parent);
//  with SelObj.b do if (Parent>=0) and (Parent>id) then dec(Parent);
  //создаём эквивалентный помощник
  if CountOfHelpers=0 then begin
   if CountOfLights=0 then id2:=Bones[CountOfBones-1].ObjectID+1
                      else id2:=Lights[CountOfLights-1].Skel.ObjectID+1;
  end else id2:=Helpers[CountOfHelpers-1].ObjectID+1;
  ReservePivotSpace(id2);         //создать центр
  PivotPoints[id2]:=pv;
  IncDecObjectIDs(id2,true);      //сдвиг
  inc(CountOfHelpers);
  SetLength(Helpers,CountOfHelpers);
  b.ObjectID:=id2;
  b.GeosetID:=-1;
  b.GeosetAnimID:=-1;
  if (b.Parent>=0) and (b.Parent>id2) then inc(b.Parent);
  Helpers[CountOfHelpers-1]:=b;
{  if SelObj.b.ObjectID=id then SelObj.b:=GetSkelObjectByID(id2)
  else begin}
   if SelObj.b.ObjectID>id2 then inc(SelObj.b.ObjectID);
   SelObj.b:=GetSkelObjectByID(SelObj.b.ObjectID);
{  end;//of else}

  //Теперь устанавливаем родительские связи
  for i:=0 to CountOfBones-1 do if Bones[i].Parent=-2
  then Bones[i].Parent:=id2;
  for i:=0 to CountOfLights-1 do if Lights[i].Skel.Parent=-2
  then Lights[i].Skel.Parent:=id2;
  for i:=0 to CountOfHelpers-1 do if Helpers[i].Parent=-2
  then Helpers[i].Parent:=id2;
  for i:=0 to CountOfAttachments-1
  do if Attachments[i].Skel.Parent=-2
  then Attachments[i].Skel.Parent:=id2; //спец. флаг
  for i:=0 to CountOfParticleEmitters1-1
  do if ParticleEmitters1[i].Skel.Parent=-2
  then ParticleEmitters1[i].Skel.Parent:=id2; //спец. флаг
  for i:=0 to CountOfParticleEmitters-1
  do if Pre2[i].Skel.Parent=-2
  then Pre2[i].Skel.Parent:=id2; //спец. флаг
  for i:=0 to CountOfRibbonEmitters-1
  do if Ribs[i].Skel.Parent=-2
  then Ribs[i].Skel.Parent:=id2; //спец. флаг
  for i:=0 to CountOfEvents-1
  do if Events[i].Skel.Parent=-2
  then Events[i].Skel.Parent:=id2; //спец. флаг
  for i:=0 to CountOfCollisionShapes-1
  do if Collisions[i].Skel.Parent=-2
  then Collisions[i].Skel.Parent:=id2; //спец. флаг
  PopFunction;
End;


//Вспомогательная: проходит по списку костей,
//устанавливает их GeosetID (None/номер/Multiple),
//а кости, не связанные ни с одной вершиной,
//перерабатывает в помощники
procedure OptimizeBones;
Var flg:array of integer;IsUsed:array of boolean;
    j,i,ii,num:integer;
Begin
 PushFunction(351);
 SetLength(flg,CountOfBones);
 SetLength(IsUsed,CountOfBones);
 for i:=0 to CountOfBones-1 do begin
  flg[i]:=-1;
  IsUsed[i]:=false;
 end;//of for i

 //1. Проходим по списку Matrices, проверяя используемость
 //костей
 for j:=0 to CountOfGeosets-1 do for i:=0 to Geosets[j].CountOfMatrices-1
 do for ii:=0 to High(Geosets[j].Groups[i]) do with Geosets[j] do begin
  if Groups[i,ii]<=Bones[CountOfBones-1].ObjectID then begin
   num:=Groups[i,ii]-Bones[0].ObjectID;
   IsUsed[num]:=true;
   if flg[num]<0 then flg[num]:=j else begin
    if flg[num]<>j then begin
     Bones[num].GeosetID:=Multiple;
     flg[num]:=66000;
    end;//of if
   end;//of if
  end;//of if
 end;//of with/for ii/i/j

 //Теперь проходим по списку флагов, проставляя используемость костей
 for i:=CountOfBones-1 downto 0 do begin
  if not IsUsed[i]
  then ConvertBoneToHelper(Bones[i-Bones[0].ObjectID].ObjectID)
  else begin
   if (flg[num]>=0) and (flg[num]<>66000)
   then Bones[i-Bones[0].ObjectID].GeosetID:=flg[num];
  end;//of if
 end;//of for i
 PopFunction;
End;

//Присоединяет вершины к указанной кости, отсоединя их
//от всех остальных. Тоже удаляет "нулевую" кость, если нужно
//Неиспользуемые кости конвертируются в помощники
procedure ReAttachVertices;
Begin
 if (not SelObj.IsSelected) or
    ((SelObj.ObjType<>typBONE) and (SelObj.ObjType<>typHELP)) then exit;
 PushFunction(352);

 //Если выделен помощник, переделать его в кость
 if SelObj.ObjType=typHELP then ConvertHelperToBone;

 //Присоединить вершины к кости путём создания новых матриц
 ReAttachSelectedVertices;
 DeleteNullBone;                  //если кость-заглушка не нужна - удаляем
 OptimizeBones;                   //переработать флаги костей
 PopFunction;
End;
//---------------------------------------------------------
//Создаёт нулевую кость (сдвигая прочие объекты скелета)
procedure CreateNullBone;
Var id:integer;
Begin
 PushFunction(353);
 //1. Начинаем процесс создания:
 //Выясним ID нового объекта
 id:=Bones[CountOfBones-1].ObjectID+1;

 //Сдвиг+создание нового центра
 IncDecObjectIDs(id,true);        //сдвиг объектов
 if SelObj.b.ObjectID>=id then inc(SelObj.b.ObjectID);

 ReservePivotSpace(id);           //Освободим место в массиве PivotPoints
 PivotPoints[id,1]:=0;            //координаты нового объекта
 PivotPoints[id,2]:=0;
 PivotPoints[id,3]:=0;

 //Собственно создание объекта Null
 inc(CountOfBones);
 SetLength(Bones,CountOfBones);
 FillChar(Bones[CountOfBones-1],SizeOf(TBone),0);
 NullBone.IsExists:=true;
 NullBone.id:=id;
 NullBone.IdInBones:=id-Bones[0].ObjectID;
 with Bones[NullBone.IdInBones] do begin
  ObjectID:=id;
  name:='bone_null';
  GeosetID:=Multiple;
  GeosetAnimID:=None;
  Parent:=-1;
  Translation:=-1;
  Rotation:=-1;
  Scaling:=-1;
  Visibility:=-1;
 end;//of with
 PopFunction;
End;
//---------------------------------------------------------
//Отсоединяет выделенные вершины от выделенной кости
procedure DetachVertices;
 function IsGroupsEqual(g1,g2:TFace):boolean;
 Var i:integer;
 Begin
  Result:=false;
  if length(g1)<>length(g2) then exit;
  for i:=0 to High(g1) do if g1[i]<>g2[i] then exit;
  Result:=true;
 End;
Var i,ii,j,num,cnt,dst:integer;
    mat:TFace;
    IsFound:boolean;
Begin
 if (not SelObj.IsSelected) or (SelObj.ObjType<>typBONE) then exit;
 PushFunction(354);

 //1. Собственно процесс отсоединения
 for j:=0 to CountOfGeosets-1 do with Geosets[j]
 do if GeoObjs[j].IsSelected and (GeoObjs[j].VertexCount<>0) then begin
  for ii:=0 to Geoobjs[j].VertexCount-1 do begin
   //а. Сформировать матрицу, содержащую все кости, кроме данной
   num:=VertexGroup[GeoObjs[j].VertexList[ii]-1];
   cnt:=Length(Groups[num]);
   SetLength(mat,num);            //массив матрицы (минус данная кость)
   dst:=0;
   for i:=0 to cnt-1 do if Groups[num,i]<>SelObj.b.ObjectID then begin
    mat[dst]:=Groups[num,i]; //копирование
    inc(dst);
   end;//of if/for i

   //б. Проверим, присутствовала ли в исходной группе выделенная кость
   if cnt-dst=0 then continue;    //вершина и так не присоединена к кости

   //в. Ищем: нет ли уже такой матрицы
   num:=dst;                      //уточнено кол-во костей в новой матрице
   SetLength(mat,num);
   IsFound:=false;                //пока таковые не найдены
   for i:=0 to High(Groups) do if IsGroupsEqual(Groups[i],mat) then begin
    IsFound:=true;                //найдено!
    num:=i;
   end;//of if/for

   //г. Если не найдено, добавим новую матрицу
   //При этом не забудем проверить матрицу на "пустоту".
   //И если она пустая, добавим ссылку на NullBone
   if not IsFound then begin
    if length(mat)=0 then begin   //матрица пуста
     FindNullBone;                //ищем нулевую кость
     if not NullBone.IsExists then CreateNullBone; //если её нет - создать
     SetLength(mat,1);
     mat[0]:=NullBone.id;
    end;//of if
    inc(CountOfMatrices);
    SetLength(Groups,CountOfMatrices);
    SetLength(Groups[CountOfMatrices-1],1);
    Groups[CountOfMatrices-1]:=mat;
    mat:=nil;
    num:=CountOfMatrices-1;
   end;//of if

   //д. Изменим VertexGroup
   VertexGroup[GeoObjs[j].VertexList[ii]-1]:=num;
  end;//of for ii

  //Теперь удаляем повторяющиеся и неиспользуемые матрицы
  ReduceMatrices(j);
 end;//of if/for j

 DeleteNullBone;
 PopFunction;
End;
//---------------------------------------------------------
//Вспомогательная: для сортировки списка анимок
function cmpSeqs(it1,it2:pointer):integer;
Begin
 Result:=Sequences[integer(it1)].IntervalStart-
         Sequences[integer(it2)].IntervalStart;
End;

//Проводит (если нужно) сортировку анимаций - так,
//чтобы они расположились по возрастанию IntervalStart.
//Если сортировка не нужна - возвращает true
function SortSequences:boolean;
Var i,j,Delta:integer;anm:TAnim;lst:TList;
    Seqs:ATSequence;
    Anms:ATAnim;
Begin
 PushFunction(355);
 //1. Проверим, нужна ли вообще сортировка
 Result:=true;
 for i:=1 to CountOfSequences-1
 do if Sequences[i-1].IntervalStart>Sequences[i].IntervalStart
 then begin
  Result:=false;
  break;
 end;//of if

 if Result then begin PopFunction;exit;end;

 //2. Сортировка всё-таки нужна. Укомплектуем поверхности
 //полным набором Anim'ов.
 for j:=0 to CountOfGeosets-1 do with Geosets[j]
 do if CountOfAnims<CountOfSequences then begin
  Delta:=CountOfSequences-CountOfAnims;
  CountOfAnims:=CountOfSequences;
  SetLength(Anims,CountOfAnims);
  CalcBounds(j,anm);              //расчёт границ поверхности
  for i:=CountOfAnims-Delta to CountOfAnims-1 do Anims[i]:=anm;
 end;//of for j

 //3. Заполним список индексами последовательностей
 //(для сортировки)
 lst:=TList.Create;
 lst.Clear;
 for i:=0 to CountOfSequences-1 do lst.Add(pointer(i));

 //4. Сортировка
 lst.Sort(cmpSeqs);               //теперь индексы отсортированы

 //5. Производим перестроение списка последовательностей
 SetLength(Seqs,CountOfSequences);
 for i:=0 to CountOfSequences-1 do Seqs[i]:=Sequences[integer(lst.Items[i])];
 Sequences:=Seqs;                 //копирование отсортированного масcива
 Seqs:=nil;

 //6. Точно так же перестраиваем списки Anim'ов в массивах
 for j:=0 to CountOfGeosets-1 do with Geosets[j] do begin
  SetLength(Anms,CountOfSequences);
  for i:=0 to CountOfAnims-1 do Anms[i]:=Anims[integer(lst.Items[i])];
  Anims:=Anms;
  Anms:=nil;
 end;//of for j

 lst.Free;
 PopFunction;
End;
//---------------------------------------------------------
procedure TChangeObjKFUndo.SaveContItem(ContID:integer);
Var it:TContItem;ps,len:integer;
Begin
 if ContID<0 then exit;
 PushFunction(356);

 //1. Если КК с текущим номером кадра не существует -
 //отметить этот факт Data[5]:=-1;
 len:=length(Controllers[ContID].Items);
 ps:=GetFramePos(Controllers[ContId],CurFrame,len);
 if (ps>=len) or (Controllers[ContId].Items[ps].Frame<>CurFrame) then begin
  it.Frame:=CurFrame;
  it.Data[5]:=-1;
 end else begin
  it:=Controllers[ContId].Items[ps];
  it.Data[5]:=1;
 end;//of if (else)

 //2. Запись в массив
 inc(CountOfSvCntrs);
 SetLength(SvCntrs,CountOfSvCntrs);
 SetLength(SvItems,CountOfSvCntrs);
 SvCntrs[CountOfSvCntrs-1]:=ContID;
 SvItems[CountOfSvCntrs-1]:=it;
 PopFunction;
End;

procedure TChangeObjKFUndo.Save;
Var i:integer;
Begin
 PushFunction(357);
 //1. Сохранить кол-во контроллеров
 CountOfControllers:=length(Controllers);

 //2. Для таких объектов сохранить тек. кадры ВСЕХ
 //контроллеров
 CountOfSvCntrs:=0;
 for i:=0 to CountOfObjs-1 do begin
  SaveContItem(Objs[i].Translation);
  SaveContItem(Objs[i].Rotation);
  SaveContItem(Objs[i].Scaling);
  SaveContItem(Objs[i].Visibility);
 end;//of for i
 PopFunction;
End;

procedure TChangeObjKFUndo.Restore;
Var it:TContItem; i:integer;
Begin
 PushFunction(358);
 //1. Восстановить кол-во контроллеров
 SetLength(Controllers,CountOfControllers);

 //2. Восстановить КК (или удалить их)
 for i:=0 to CountOfSvCntrs-1 do begin
  it:=SvItems[i];
  if it.Data[5]<0 then DeleteFrames(Controllers[SvCntrs[i]],it.Frame,it.Frame)
  else AddKeyFrame(SvCntrs[i],it);
 end;//of for i

 //3. Восстановить изменённые объекты
 for i:=0 to CountOfObjs-1 do SetObjSkelPart(objs[i]);
 PopFunction;
End;

//----------------------------------------------------------
procedure TSaveSmoothGroups.Save;
Var i,ii:integer;
Begin
 PushFunction(375);
 _COMidNormals:=COMidNormals;
 _COConstNormals:=COConstNormals;
 SetLength(_MidNormals,_COMidNormals);
 SetLength(_ConstNormals,_COConstNormals);

 for i:=0 to COMidNormals-1 do begin
  SetLength(_MidNormals[i],length(MidNormals[i]));
  for ii:=0 to High(MidNormals[i]) do _MidNormals[i,ii]:=MidNormals[i,ii];
 end;//of for i

 for i:=0 to COConstNormals-1 do _ConstNormals[i]:=ConstNormals[i];
 PopFunction;
end;

procedure TSaveSmoothGroups.Restore;
Var i,ii:integer;
Begin
 PushFunction(376);
 COMidNormals:=_COMidNormals;
 COConstNormals:=_COConstNormals;
 SetLength(MidNormals,COMidNormals);
 SetLength(ConstNormals,COConstNormals);

 for i:=0 to COMidNormals-1 do begin
  SetLength(MidNormals[i],length(_MidNormals[i]));
  for ii:=0 to High(_MidNormals[i]) do MidNormals[i,ii]:=_MidNormals[i,ii];
 end;//of for i

 for i:=0 to COConstNormals-1 do ConstNormals[i]:=_ConstNormals[i];
 PopFunction;
End;
//=========================================================
procedure TSaveSeq.Save;
Begin
 if AnimPanel.IsAllLine(AnimPanel.ids) then exit; //перестраховка

 Seq:=AnimPanel.Seq;
 IsGlobal:=AnimPanel.IsAnimGlob(AnimPanel.ids);
 id:=AnimPanel.ids;
 TypeOfUndo:=uCommonUndo;
 Prev:=-1;
End;

procedure TSaveSeq.Restore;
Begin
 AnimPanel.Seq:=seq;
 AnimPanel.ids:=id;
 AnimPanel.SSeq;
End;
//----------------------------------------------------------
//Для отмены вставки новой последовательности
procedure TSaveCreateSeq.Save;
Begin
 id:=AnimPanel.ids;
 TypeOfUndo:=uCommonUndo;
 Prev:=-1;
End;

procedure TSaveCreateSeq.Restore;
Begin
 AnimPanel.DelSeq(id);
 AnimPanel.ids:=FLG_ALLLINE;
End;
//----------------------------------------------------------
//Для отмены удаления очередной последовательности
procedure TDelSeqUndo.Save;
Var i,len:integer;
Begin
 PushFunction(271);
 TypeOfUndo:=uCommonUndo;
 Prev:=-1;
 AnimPanel.SelSeq(AnimPanel.ids);
 Seq:=AnimPanel.Seq;
 id:=AnimPanel.ids;
 IsGlobal:=AnimPanel.IsAnimGlob(id);
 //Если глобалка, запомним id контроллеров
 len:=0; idc:=nil; idg:=nil;
 if IsGlobal then for i:=0 to High(Controllers)
 do if Controllers[i].GlobalSeqId=(id and $FFFFFF) then begin
  inc(len);
  SetLength(idc,len);
  SetLength(idg,len);
  idc[len-1]:=i;
  idg[len-1]:=Controllers[i].GlobalSeqId;
 end;//of if/for i/if
 PopFunction;
End;

procedure TDelSeqUndo.Restore;
Var i,j:integer;
Begin
 PushFunction(272);
 AnimPanel.Seq:=Seq;
 AnimPanel.ids:=id;
 AnimPanel.InsertSeq(IsGlobal,id and $FFFFFF);

 //Восстановим GlobalSeqId в контроллерах
 for i:=0 to High(idc) do Controllers[idc[i]].GlobalSeqId:=idg[i];
 PopFunction;
End;
//=========================================================
initialization
 AnimPanel:=TAnimPanel.Create;
 ExternalBuffer.IsActive:=false;  //пока буфер пуст
 CountOfUndo:=0;//HideVertexCount:=0;
 CountOfNewUndo:=0;
end.
