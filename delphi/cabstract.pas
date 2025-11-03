unit cabstract;
//Модуль содержит набор классов, предназначенных для
//работы с объектами и их группами.
interface
uses classes,windows,SysUtils,mdlwork,OpenGL,math,crash;
const CLASS_ERROR='Ошибка при работе с объектом:'#13#10;
      FLG_GLOBAL=$80000000;
      FLG_ALLLINE=$FFFFFF;
Var
    AbsMinFrame,AbsMaxFrame:integer;
type

//Класс: список ключевых кадров.
//используется для формирования линейки этих самых кадров.
//Список ВСЕГДА отсортирован по возрастанию номеров кадров
//и повторяющихся номеров в нём нет.
TKeyFramesList=class(TList)
 public
  //позволяет получить кадр (его номер) по индексу в списке
  function GetFrame(Index:integer):integer;
  //получить предыдущий (по отношению к заданному) кадр или 0
  function GetPrevFrame(Frame:integer):integer;
  //получить следующий (по отношению к заданному) кадр или $<...>
  function GetNextFrame(Frame:integer):integer;
  //возвращает индекс кадра, ближайшего к Frame со с начала списка
  function GetNearestLEquFrameIndex(Frame:integer):integer;
  //добавляет КК в список. Frame должен быть больше нуля.
  procedure Add(Frame:integer);
end;//of type
//----------------------------------------------------------
//Используется для смещения/вращения/масштабирования всей сцены
TSceneView=class
 public
  Mat:TRotMatrix;             //матрица поворота
  ax,ay,az:GLFloat;           //углы поворота по осям
  tx,ty,tz:GLFloat;           //сдвиги по осям
  Zoom:GLFloat;               //масштаб
  Excentry:GLFloat;           //эксцентриситет рабочей плоскости
  //Копирует все свойства аналогичного объекта
  procedure Assign(Var src:TSceneView);
  //Сброс параметров объекта (установка исходных)
  procedure Reset;
  //Устанавливает указанные параметры сцены, но НЕ перерисовывает её
  procedure ApplyView;
  //Выполняет перемещение сцены
  procedure Translaton(DeltaX,DeltaY:GlFloat);
  //Выполняет масштабирование сцены
  procedure Zooming(step:GLFloat);
  //Выполняет поворот сцены
  procedure Rotation(StepX,StepY,StepZ:GLFloat);
end;//of type
//==========================================================
//Используется для расчёта тангенциальной составляющей КК
TTan=class
 private
  ds:GLFloat;              //отклонение (для расчёта)
  qcur,logNNP,logNMN:TQuaternion;//логарифмы и текущий кватернион 
 public
  tang:TContItem;                 //хранилище тангенсов
  bias,tension,continuity:GLFloat;//параметры сплайна
  prev,cur,next:TContItem;          //значения в КК
  IsLogsReady:boolean;            //true, если готовы логарифмы
  //Расчёт производных в точке Cur (для count ячеек)
  procedure CalcDerivativeXD(count:integer);
  //расчёт параметров с постоянным Bias
  //в случае обсчёта вращения, true->IsQuaternion
  procedure CalcWithConstBias(IsQuaternion:boolean;Count:integer);
  //расчёт сплайновых параметров (tension,continuity,bias)
  //по данным prev[1],cur[1],next[1]
  //в случае кватерниона задействуются ВСЕ данные cur,prev,next
  procedure CalcSplineParameters(IsQuaternion:boolean;count:integer);
  //Расчёт производных в точке Cur для кватерниона
  procedure CalcDerivative4D;
end;//of type
//==========================================================
//Используется для работы с последовательностями
//(через редактор анимок)
TAnimPanel=class
 public
  SeqList:TStringList;            //список всех анимаций (в т.ч. глобальных)
  Seq:TSequence;                  //выбранная последовательность
  ids:cardinal;                   //её id
  MinF,MaxF:integer;              //границы активной анимации
  ActSeqID:integer;               //ID "активной" анимации
  constructor Create;             //конструктор объекта
  procedure MakeAnimList;         //создать список анимаций
  //Возвращает true, если id принадлежит глоб. анимации.
  //Фактически, представляет собой обыкновенный AND,
  //т.к. в глоб. id установлен старший бит.
  function IsAnimGlob(id:cardinal):boolean;overload;
  function IsAnimGlob(id:pointer):boolean;overload;
  //Возвр. true, если выбран пункт "вся линейка".
  //Сравнение - ей соотв. id=$FFFF FFFF
  function IsAllLine(id:cardinal):boolean;overload;
  function IsAllLine(id:pointer):boolean;overload;
  //Выбирает в качестве текущей последовательность id
  //При этом заполняются только поля id, seq и
  //переменная UsingGlobalSeq
  procedure SelSeq(id:cardinal);overload;
  procedure SelSeq(id:pointer);overload;
  //Возвращает индекс выделенной анимки в списке SeqList
  function GSelSeqIndex:integer;
  //Возвращает макс. значение кадра (исп. для вычисления AbsMaxFrame)
  //для этого анализируются IntervalEnd для всех анимок.
  function GAbsMaxFrame:integer;
  //Записывает в текущую (выбранную) последовательность
  //данные из Seq
  procedure SSeq;
  //Добавляет новую анимацию к модели (список пересобирается отдельно,
  //выбор вновь созданной анимки тоже делается отдельно).
  //Если IsGlobal=true, создаётся глобальная анимка.
  //ind - позиция, в которую происходит вставка.
  //Новая анимка заполняется из Seq.
  //Если вставляется глоб. анимация, идёт сдвиг GlobalSeqId
  //в контроллерах
  procedure InsertSeq(IsGlobal:boolean;ind:integer);
  //Удаление либо текущей, либо (если указан id)
  //просто выбранной последовательности.
  //Удалить Всю Линейку нельзя (ничего не происх.)
  //При удалении глоб. анимации идёт сдвиг в контроллерах
  //(GlobalSeqId)
  procedure DelSeq(id:cardinal);overload;
  procedure DelSeq;overload;
  //Возвращает ID активной анимации (т.е. такой, в которой
  //находится текущий кадр). Зачастую требуется просмотр
  //всего анимационного списка. Заполняются также границы
  //анимации
  function FindActSeq(Frame:integer):integer;
end;//of TAnimPanel

//==========================================================
implementation
uses MdlDraw;
//Класс TKeyFramesList
//позволяет получить кадр (его номер) по индексу в списке
function TKeyFramesList.GetFrame(Index:integer):integer;
Begin
 Result:=0;
 if (index<0) or (index>=count)
 then Error(CLASS_ERROR+'TKeyFramesList.GetItem(%d)',index)
 else Result:=integer(items[index]);
End;

//----------------------------------------------------------

//возвращает индекс кадра, ближайшего к Frame со с начала списка
function TKeyFramesList.GetNearestLEquFrameIndex(Frame:integer):integer;
Var i,ssStart,ssEnd,ssDelta,ssMid:integer;
Begin
 //Кадр должен лежать в "разумных" пределах.
 if Frame<0
 then Error(CLASS_ERROR+'TKeyFramesList.GetNearestLEquFrameIndex(%d)',Frame);

 //Поиск индекса
 Result:=0;
 if count=0 then exit;
 PushFunction(191);

 ssStart:=0;            ssEnd:=count-1;
 ssDelta:=ssEnd-ssStart;ssMid:=(ssDelta shr 1)+ssStart;
 while ssDelta>5 do begin
    if Frame=integer(items[ssMid]) then begin
     Result:=ssMid;
     PopFunction;
     exit;
    end;
    if Frame<integer(items[ssMid]) then ssEnd:=ssMid else ssStart:=ssMid;
    ssDelta:=ssEnd-ssStart;
    ssMid:=(ssDelta shr 1)+ssStart;
 end;//of while

 for i:=ssEnd downto ssStart do begin
    if integer(items[i])<=Frame then begin
     Result:=i;
     PopFunction;
     exit;
    end;//of if
 end;//of for

 Result:=ssStart;
 PopFunction;
End;

//---------------------------------------------------------

//добавляет КК в список. Frame должен быть больше нуля.
procedure TKeyFramesList.Add(Frame:integer);
Var index:integer;
Begin
 //Кадр должен лежать в "разумных" пределах.
 if Frame<0 then Error(CLASS_ERROR+'TKeyFramesList.Add(%d)',Frame);
 if Frame<0 then exit;            //такие кадры добавлению не подлежат

 PushFunction(192);
 //вносим поправку в AbsMaxFrame (если активна НЕ глоб. анимация)
 if UsingGlobalSeq<0 then AbsMaxFrame:=Max(AbsMaxFrame,Frame);

 //собственно вставка
 index:=GetNearestLEquFrameIndex(Frame);
 if index=count then inherited Add(pointer(Frame))
 else if GetFrame(index)>Frame
 then Insert(GetNearestLEquFrameIndex(Frame),pointer(Frame))
 else if GetFrame(index)<>Frame
 then Insert(GetNearestLEquFrameIndex(Frame)+1,pointer(Frame));
 PopFunction;
End;

//----------------------------------------------------------

//получить предыдущий (по отношению к заданному) кадр
function TKeyFramesList.GetPrevFrame(Frame:integer):integer;
Var index:integer;
Begin
 Result:=0;
 if count=0 then exit;
 index:=GetNearestLEquFrameIndex(Frame);
 if GetFrame(index)=Frame then dec(index);
 if index<0 then exit else Result:=GetFrame(index);
End;

//получить следующий (по отношению к заданному) кадр
function TKeyFramesList.GetNextFrame(Frame:integer):integer;
Var index:integer;
Begin
 //1. Проверим на единственность кадра в списке
 Result:=$7000FFFF;               //достаточно большое число
 if count=0 then exit;
 if integer(items[0])>Frame then begin
  Result:=GetFrame(0);
  exit;
 end;//of if
 index:=GetNearestLEquFrameIndex(Frame)+1;
 if index>=count then exit else Result:=GetFrame(index);
End;

//==========================================================

//Копирует все свойства аналогичного объекта
procedure TSceneView.Assign(Var src:TSceneView);
Begin
 Mat:=src.Mat;
 ax:=src.ax;    ay:=src.ay;     az:=src.az;
 tx:=src.tx;    ty:=src.ty;     tz:=src.tz;
 Zoom:=src.Zoom;
 Excentry:=src.Excentry;
End;

//----------------------------------------------------------

//Сброс параметров объекта (установка исходных)
procedure TSceneView.Reset;
Begin
 PushFunction(193);
 Mat[0,0]:=1;Mat[0,1]:=0;Mat[0,2]:=0;
 Mat[1,0]:=0;Mat[1,1]:=1;Mat[1,2]:=0;
 Mat[2,0]:=0;Mat[2,1]:=0;Mat[2,2]:=1;
 ax:=180;    ay:=0;      az:=0;
 tx:=0;      ty:=0;      tz:=0;
 Zoom:=0.99;
 ApplyView;
 PopFunction;
End;

//----------------------------------------------------------

//Устанавливает указанные параметры сцены, но НЕ перерисовывает её
procedure TSceneView.ApplyView;
Begin
  PushFunction(194);
  glMatrixMode(gl_projection);    //матрица модели
  glLoadIdentity;                //загрузить единичную
  //установить масштаб
  if Zoom<1 then glScalef(Zoom*1/200/Excentry,Zoom*1/200,Zoom*1/500)
  else glScalef(Zoom*1/200/Excentry,Zoom*1/200,1/4000);
  glTranslatef(tx,ty,tz);         //перенос
  glRotatef(ax,1.0,0,0);          //поворот
  glMatrixMode(gl_modelview);     //матрица вида
  glLoadIdentity;
  glRotatef(ay,0,1.0,0);
  glRotatef(az,0,0,1.0);
  PopFunction;
End;

//----------------------------------------------------------

//Выполняет перемещение сцены
procedure TSceneView.Translaton(DeltaX,DeltaY:GlFloat);
Begin
 PushFunction(195);
 tx:=tx+DeltaX/Zoom;
 ty:=ty+DeltaY/Zoom;
 if tx<-20000 then tx:=-20000;
 if tx>20000 then tx:=20000;
 if ty<-20000 then ty:=-20000;
 if ty>20000 then ty:=20000;
 ApplyView;
 PopFunction;
End;

//----------------------------------------------------------

//Выполняет масштабирование сцены
procedure TSceneView.Zooming(step:GLFloat);
Begin
 PushFunction(196);
 Zoom:=Zoom+0.01*Zoom*step;//новый масштаб
 if Zoom<0.001 then Zoom:=0.001; //контроль
 if Zoom>1000 then Zoom:=1000;   //контроль
 ApplyView;
 PopFunction;
End;

//----------------------------------------------------------

//Выполняет поворот сцены
procedure TSceneView.Rotation(StepX,StepY,StepZ:GLFloat);
Begin
 PushFunction(197);
 az:=az+StepZ;
 ay:=ay+StepY; //установить угол
 ax:=ax+StepX; //установить угол
 if ay<0 then ay:=ay+360;  //контроль
 if ay>360 then ay:=ay-360;
 if ax<0 then ax:=ax+360;  //контроль
 if ax>360 then ax:=ax-360;
 if az<0 then az:=az+360;  //контроль
 if az>360 then az:=az-360;
 ApplyView;
 PopFunction;
End;

//==========================================================
//Расчёт производных в точке Cur (для count ячеек)
procedure TTan.CalcDerivativeXD(count:integer);
Var g1,g2,g3,g4:GLFloat;i:integer;
Begin
 PushFunction(198);
 for i:=1 to Count do begin
  g1:=(1-tension)*(1-continuity)*(1+bias)*0.5;
  g2:=(1-tension)*(1+continuity)*(1-bias)*0.5;
  g3:=(1-tension)*(1+continuity)*(1+bias)*0.5;
  g4:=(1-tension)*(1-continuity)*(1-bias)*0.5;
  tang.InTan[i]:=g1*(cur.Data[i]-prev.Data[i])+g2*(next.Data[i]-cur.Data[i]);
  tang.OutTan[i]:=g3*(cur.Data[i]-prev.Data[i])+g4*(next.Data[i]-cur.Data[i]);
 end;//of for i
 PopFunction;
End;
//----------------------------------------------------------
//расчёт параметров с постоянным Bias
//в случае обсчёта вращения, true->IsQuaternion
procedure TTan.CalcWithConstBias(IsQuaternion:boolean;Count:integer);
Var cMin,tMin,cCur,tCur,Delta,
    cCurBeg,cCurEnd,tCurBeg,tCurEnd,step:GLFloat;
    tang2:TContItem;
    i:integer;
Begin
 PushFunction(199);
 //Копируем параметры
 tang2:=tang;
 cMin:=0; tMin:=0;
 ds:=1e6;

 //начинаем сеточный перебор 1-го порядка
 step:=0.1;
 tCurBeg:=-1; tCurEnd:=1;
 cCurBeg:=-1; cCurEnd:=1;
 while step>0.001 do begin
  cCur:=cCurBeg;
  repeat
   tCur:=tCurBeg;
   repeat
    continuity:=cCur;
    tension:=tCur;
    if IsQuaternion then begin
     CalcDerivative4D;
     Delta:=abs(tang.OutTan[1]-tang2.OutTan[1])+
            abs(tang.OutTan[2]-tang2.OutTan[2])+
            abs(tang.OutTan[3]-tang2.OutTan[3])+
            abs(tang.OutTan[4]-tang2.OutTan[4])+
            abs(tang.InTan[1]-tang2.InTan[1])+
            abs(tang.InTan[2]-tang2.InTan[2])+
            abs(tang.InTan[3]-tang2.InTan[3])+
            abs(tang.InTan[4]-tang2.InTan[4]);
    end else begin
     CalcDerivativeXD(Count);
     Delta:=0;
     for i:=1 to count do begin
     Delta:=Delta+abs(tang.OutTan[i]-tang2.OutTan[i])+
            abs(tang.InTan[i]-tang2.InTan[i]);
     end;//of for i
    end;//of else
    if Delta<ds then begin
     ds:=Delta;
     cMin:=cCur;
     tMin:=tCur;
    end;//of if
    tCur:=tCur+step;
   until tCur>tCurEnd;
   cCur:=cCur+step;
  until cCur>cCurEnd;
  cCurBeg:=cMin-step; if cCurBeg<-1 then cCurBeg:=-1;
  cCurEnd:=cMin+step; if cCurEnd>1 then cCurEnd:=1;
  tCurBeg:=tMin-step; if tCurBeg<-1 then tCurBeg:=-1;
  tCurEnd:=tMin+step; if tCurEnd>1 then tCurEnd:=1;
  step:=step*0.1;
 end;//of while

 //Найдено!
 continuity:=cMin;
 tension:=tMin;
 tang:=tang2;
 PopFunction;
End;
//----------------------------------------------------------
//расчёт сплайновых параметров по производным.
procedure TTan.CalcSplineParameters(IsQuaternion:boolean;count:integer);
Var bMid,bStart,bEnd,vStart,vEnd,Delta:GLFloat;
Begin
 PushFunction(200);
 bStart:=-1;
 bEnd:=1;
 IsLogsReady:=false;
 repeat
  bMid:=(bEnd-bStart)*0.5+bStart;

  bias:=bStart;
  CalcWithConstBias(IsQuaternion,count);
  vStart:=ds;

  bias:=bEnd;
  CalcWithConstBias(IsQuaternion,count);
  vEnd:=ds;

  if vStart<vEnd then bEnd:=bMid else bStart:=bMid;
  Delta:=abs(bStart-bEnd);
 until Delta<0.0001;
 bias:=bMid;
 PopFunction;
End;
//----------------------------------------------------------
//Расчёт производных в точке Cur для кватерниона
//Если логарифмы уже готовы, они не перерасчитываются
procedure TTan.CalcDerivative4D;
Var qprev,qnext,q:TQuaternion;
    g1,g2,g3,g4:GLFloat;
Begin
 PushFunction(201);
 //1. Рассчитаем логарифмы (если нужно)
 if not IsLogsReady then begin
  //заполнение кватернионов
  qcur.x:=cur.Data[1];
  qcur.y:=cur.Data[2];
  qcur.z:=cur.Data[3];
  qcur.w:=cur.Data[4];

  qprev.x:=prev.Data[1];
  qprev.y:=prev.Data[2];
  qprev.z:=prev.Data[3];
  qprev.w:=prev.Data[4];

  qnext.x:=next.Data[1];
  qnext.y:=next.Data[2];
  qnext.z:=next.Data[3];
  qnext.w:=next.Data[4];

  //расчёт
  GetInverseQuaternion(qcur,logNNP);
  MulQuaternions(logNNP,qnext,logNNP);
  CalcLogQ(logNNP);
  GetInverseQuaternion(qprev,logNMN);
  MulQuaternions(logNMN,qcur,logNMN);
  CalcLogQ(logNMN);
  IsLogsReady:=true;              //готово!
 end;//of if

 g1:=(1-tension)*(1+continuity)*(1-bias)*0.5;
 g2:=(1-tension)*(1-continuity)*(1+bias)*0.5;
 g3:=(1-tension)*(1-continuity)*(1-bias)*0.5;
 g4:=(1-tension)*(1+continuity)*(1+bias)*0.5;
 tang.InTan[1]:=g1*LogNNP.x+g2*LogNMN.x;
 tang.OutTan[1]:=g3*LogNNP.x+g4*LogNMN.x;
 tang.InTan[2]:=g1*LogNNP.y+g2*LogNMN.y;
 tang.OutTan[2]:=g3*LogNNP.y+g4*LogNMN.y;
 tang.InTan[3]:=g1*LogNNP.z+g2*LogNMN.z;
 tang.OutTan[3]:=g3*LogNNP.z+g4*LogNMN.z;

 //Расчёт a-параметра
 q.x:=0.5*(tang.OutTan[1]-logNNP.x);
 q.y:=0.5*(tang.OutTan[2]-logNNP.y);
 q.z:=0.5*(tang.OutTan[3]-logNNP.z);
 CalcExpQ(q);
 MulQuaternions(qcur,q,q);
 tang.OutTan[1]:=q.x;     //??????????
 tang.OutTan[2]:=q.y;
 tang.OutTan[3]:=q.z;
 tang.OutTan[4]:=q.w;

 //расчёт b-параметра
 q.x:=0.5*(logNMN.x-tang.InTan[1]);
 q.y:=0.5*(logNMN.y-tang.InTan[2]);
 q.z:=0.5*(logNMN.z-tang.InTan[3]);
 CalcExpQ(q);
 MulQuaternions(qcur,q,q);
 tang.InTan[1]:=q.x;     //??????????
 tang.InTan[2]:=q.y;
 tang.InTan[3]:=q.z;
 tang.InTan[4]:=q.w;

 //2-й вариант расчёта (gemo.design)
{ g1:=prev;Slerp(-(1+bias)/3.0,cur,g1);
 g2:=next;Slerp(1-bias)/3.0,cur,g2);
 g3:=g2;Slerp(0.5+0.5*continuity,g1,g3);
 g4:=g2;Slerp(0.5-0.5*continuity,g1,g4);
 tang.InTan:=g3;Slerp((tension-1),}
 PopFunction;
End;
//==========================================================
//Сортировочная функция (для глоб. анимаций)
function GlobAnSort(List:TStringList;Index1,Index2:Integer):Integer;
Begin
 Result:=strtoint(List[index1])-strtoint(List[index2]);
End;
//----------------------------------------------------------
constructor TAnimPanel.Create;             //конструктор объекта
Begin
 SeqList:=TStringList.Create;
 ids:=FLG_ALLLINE;                          //вся линейка
End;
//----------------------------------------------------------
//создать список анимаций (в SeqList)
procedure TAnimPanel.MakeAnimList;
Var i:integer; lst:TStringList;
Begin
 SeqList.Clear;
 lst:=TStringList.Create;
 lst.Clear;

 for i:=0 to CountOfGlobalSequences-1
 do lst.AddObject(inttostr(GlobalSequences[i]),pointer(i+$80000000));
 lst.CustomSort(GlobAnSort);

 for i:=0 to CountOfSequences-1
 do SeqList.AddObject(Sequences[i].Name,pointer(i));
// SeqList.Sort;
 SeqList.AddStrings(lst);
 SeqList.InsertObject(0,'Вся линейка',pointer(FLG_ALLLINE));

 lst.Free;
End;
//----------------------------------------------------------

//Возвращает true, если id принадлежит глоб. анимации.
//Фактически, представляет собой обыкновенный AND,
//т.к. в глоб. id установлен старший бит.
function TAnimPanel.IsAnimGlob(id:cardinal):boolean;
Begin
 Result:=(id and $80000000)<>0;
End;
function TAnimPanel.IsAnimGlob(id:pointer):boolean;
Begin
 Result:=IsAnimGlob(cardinal(id));
End;
//----------------------------------------------------------

//Возвр. true, если выбран пункт "вся линейка".
//Сравнение - ей соотв. id=$FFFF FFFF
function TAnimPanel.IsAllLine(id:cardinal):boolean;
Begin
 Result:=id=FLG_ALLLINE;
End;
function TAnimPanel.IsAllLine(id:pointer):boolean;
Begin
 Result:=IsAllLine(cardinal(id));
End;
//----------------------------------------------------------

//Выбирает в качестве текущей последовательность id
//При этом заполняются только поля id, seq
procedure TAnimPanel.SelSeq(id:cardinal);
Begin
 ids:=id;
 UsingGlobalSeq:=-1;
 if IsAllLine(id) then begin
  Seq.Name:='Вся линейка';
  Seq.IntervalStart:=0;
  exit;
 end;
 if IsAnimGlob(id) then begin
  Seq.IntervalStart:=0;
  Seq.IntervalEnd:=GlobalSequences[id and $FFFFFF];
  Seq.Name:=inttostr(Seq.IntervalEnd);
  UsingGlobalSeq:=id and $FFFFFF;
 end else Seq:=Sequences[id];
End;
procedure TAnimPanel.SelSeq(id:pointer);
Begin
 SelSeq(cardinal(id));
End;
//----------------------------------------------------------

//Возвращает индекс выделенной анимки в списке SeqList
function TAnimPanel.GSelSeqIndex:integer;
Begin
 Result:=SeqList.IndexOfObject(pointer(ids));
End;
//----------------------------------------------------------

//Записывает в текущую (выбранную) последовательность
//данные из Seq
procedure TAnimPanel.SSeq;
Begin
 if IsAllLine(ids) then exit;
 if IsAnimGlob(ids) then GlobalSequences[ids and $FFFFFF]:=Seq.IntervalEnd
 else Sequences[ids]:=Seq;
End;
//----------------------------------------------------------

//Добавляет новую анимацию к модели (список пересобирается отдельно,
//выбор вновь созданной анимки тоже делается отдельно).
//Если IsGlobal=true, создаётся глобальная анимка.
//ind - позиция, в которую происходит вставка.
//Новая анимка заполняется из Seq.
procedure TAnimPanel.InsertSeq(IsGlobal:boolean;ind:integer);
Var i,j:integer;
Begin
 if IsGlobal then begin
  inc(CountOfGlobalSequences);
  SetLength(GlobalSequences,CountOfGlobalSequences);
  for i:=CountOfGlobalSequences-2 downto ind
  do GlobalSequences[i+1]:=GlobalSequences[i];
  GlobalSequences[ind]:=Seq.IntervalEnd;

  //Сдвиг GlobalSeqId в контроллерах
  for i:=0 to High(Controllers) do if Controllers[i].GlobalSeqId>=ind
  then inc(Controllers[i].GlobalSeqId);
 end else begin
  //Добавим запись Anim во все поверхности (если нужно)
  for j:=0 to CountOfGeosets-1 do with Geosets[j]
  do if CountOfAnims=CountOfSequences then begin
   inc(CountOfAnims);
   SetLength(Anims,CountOfAnims);
   for i:=CountOfAnims-2 downto ind do Anims[i+1]:=Anims[i];
   CalcBounds(j,Anims[ind]);

   if Seq.Bounds.MinimumExtent[1]>Anims[ind].MinimumExtent[1]
   then Seq.Bounds.MinimumExtent[1]:=Anims[ind].MinimumExtent[1];
   if Seq.Bounds.MinimumExtent[2]>Anims[ind].MinimumExtent[2]
   then Seq.Bounds.MinimumExtent[2]:=Anims[ind].MinimumExtent[2];
   if Seq.Bounds.MinimumExtent[3]>Anims[ind].MinimumExtent[3]
   then Seq.Bounds.MinimumExtent[3]:=Anims[ind].MinimumExtent[3];

   if Seq.Bounds.MaximumExtent[1]<Anims[ind].MaximumExtent[1]
   then Seq.Bounds.MaximumExtent[1]:=Anims[ind].MaximumExtent[1];
   if Seq.Bounds.MaximumExtent[2]<Anims[ind].MaximumExtent[2]
   then Seq.Bounds.MaximumExtent[2]:=Anims[ind].MaximumExtent[2];
   if Seq.Bounds.MaximumExtent[3]<Anims[ind].MaximumExtent[3]
   then Seq.Bounds.MaximumExtent[3]:=Anims[ind].MaximumExtent[3];
  end;//of for j

  //добавляем саму последовательность
  inc(CountOfSequences);
  SetLength(Sequences,CountOfSequences);
  for i:=CountOfSequences-2 downto ind do Sequences[i+1]:=Sequences[i];
  Sequences[ind]:=Seq;
 end;//of if
End;
//----------------------------------------------------------

//Удаление либо текущей, либо (если указан id)
//просто выбранной последовательности.
//Удалить Всю Линейку нельзя (ничего не происх.)
procedure TAnimPanel.DelSeq(id:cardinal);
Var i,j:integer;ind:cardinal;
Begin
 if IsAllLine(id) then exit;
 if IsAnimGlob(id) then begin
  ind:=id and $FFFFFF;
  for i:=ind to CountOfGlobalSequences-2
  do GlobalSequences[i]:=GlobalSequences[i+1];
  dec(CountOfGlobalSequences);
  SetLength(GlobalSequences,CountOfGlobalSequences);

  //Сдвиг ID в контроллерах
  for i:=0 to High(Controllers) do begin
   if Controllers[i].GlobalSeqId=ind then Controllers[i].GlobalSeqId:=-1;
   if Controllers[i].GlobalSeqId>ind then dec(Controllers[i].GlobalSeqId);
  end;//of for i
 end else begin
  for i:=id to CountOfSequences-2 do Sequences[i]:=Sequences[i+1];
  dec(CountOfSequences);
  SetLength(Sequences,CountOfSequences);

  //Удаляем Anim-запись
  for j:=0 to CountOfGeosets-1 do with Geosets[j]
  do if id<CountOfAnims then begin
   for i:=id to CountOfAnims-2 do Anims[i]:=Anims[i+1];
   dec(CountOfAnims);
   SetLength(Anims,CountOfAnims);
  end;//of if/with/for j
 end;//of if
End;

procedure TAnimPanel.DelSeq;
Begin
 DelSeq(ids);
End;
//----------------------------------------------------------

//Возвращает макс. значение кадра (исп. для вычисления AbsMaxFrame)
//для этого анализируются IntervalEnd для всех анимок.
function TAnimPanel.GAbsMaxFrame:integer;
Var i:integer;
Begin
 Result:=0;
 for i:=0 to CountOfSequences-1 do if Sequences[i].IntervalEnd>Result
 then Result:=Sequences[i].IntervalEnd;
End;
//----------------------------------------------------------

//Возвращает ID активной анимации (т.е. такой, в которой
//находится текущий кадр). Зачастую требуется просмотр
//всего анимационного списка. Заполняются также границы
//анимации
function TAnimPanel.FindActSeq(Frame:integer):integer;
Var i:integer;
Begin
 Result:=-1;
 for i:=0 to CountOfSequences-1
 do if (Sequences[i].IntervalStart<=Frame) and (Sequences[i].IntervalEnd>=Frame)
 then begin
  Result:=i;
  MinF:=Sequences[i].IntervalStart;
  MaxF:=Sequences[i].IntervalEnd;
  ActSeqID:=i;
  exit;
 end;//of if/for
End;
end.
