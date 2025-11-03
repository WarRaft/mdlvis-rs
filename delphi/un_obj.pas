unit un_obj;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ImgList, StdCtrls, mdlwork,frmmain,mdldraw,objedut;

type
  Tfrm_obj = class(TForm)
    lv_obj: TListView;
    il_spec: TImageList;
    cb_tree: TCheckBox;
    b_ok: TButton;
    procedure FormShow(Sender: TObject);
    procedure lv_objChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormActivate(Sender: TObject);
    procedure cb_treeClick(Sender: TObject);
    procedure lv_objDblClick(Sender: TObject);
    procedure lv_objMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure b_okClick(Sender: TObject);
    procedure lv_objKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lv_objEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    //Вспомогательная: если в списке есть такой объект, что
    //его caption=s, он выделяется.
    procedure SelectLObject(s:string);
    //Вспомогательная: если в списке есть объект с object=id,
    //то он выделяется
    procedure SelectObjectByID(id:integer);
  public
    { Public declarations }
    //Строит список поверхностей
    //TypeToAdd - флаги объектов для добавления:
    //-1 - корневой список;
    //Остальное - ID иерархии (дочерний список)
    //Если флажок иерархии снят, параметр игнорируется
    procedure MakeGeosetsList(TypeToAdd:integer);
    //Удаление выделенных поверхностей
    procedure DeleteGeosets(Sender:TObject);
    //Составление списка последовательностей
    procedure MakeSequencesList;
    //Удаление выделенных анимок
    procedure DeleteSequences(Sender:TObject);
    //Смена имени анимации с указанным номером
    //из Sequences (при смене текста в списке анимок)
    procedure ChangeSeqName(id:integer);
    //Смена имени объекта с указанным ID
    //(если таковой есть в списке)
    procedure ChangeObjName(id:integer;NewName:string);
    //Строит список активных (видимых) объектов,
    //если таковые есть.
    //-1 - все объекты,
    //остальное - дочерние объекты.
    //При снятом флажке "Иерархия" параметр игнорируется.
    //Если SelID>=0, то процедура пытается выделить указанный объект
    procedure MakeObjectsList(id:integer;SelID:integer);
  end;

var
  frm_obj: Tfrm_obj;
  //Типы объектов, содержащихся в списке
  TypesOfObjects:integer;
  //Координаты курсора мыши в списке
  LMouseX,LMouseY:integer;
  IsMayChange,                  //когда true, можно производить перевыделение
  IsENTER:boolean;              //true, когда нажата ENTER
const
  //Различные типы объектов
  toSeqs=-1;
  toGeosets=0;
{  toBones=1;
  toAttachments=2;}
  toSkelObjs=1;
  //Сообщения списка
  LVM_ENSUREVISIBLE=$1000+19;
implementation

{$R *.DFM}
//Вспомогательная;
//Возвращает имя иерархии по её ID
function GetNameByID(id:integer):string;
Begin
 if id<=-10 then begin            //WMO-модели
  id:=-id-10;
  if id>=1000 then begin
   id:=id-1000;
   Result:='DOODADS'+inttostr(id);
  end else Result:='WMO'+inttostr(id);
  exit;
 end;//
 case id of
 -2:Result:='Вставленные';
  0:Result:='Тело';
  1:Result:='Лысина';
  2:Result:='Причёска-A';
  3:Result:='Причёска-B';
  4:Result:='Прическа-C';
  5:Result:='Прическа-D';
  6:Result:='Причёска-E';
  7:Result:='Прическа-F';
  8:Result:='Причёска-G';
  9:Result:='Причёска-H';
  10..20:Result:='Причёска'+inttostr(id-10);
  101:Result:='Подбородок';
  102..112:Result:='Борода'+inttostr(id-102);
  201:Result:='Щёки';
  202:Result:='Атрибуты-1';
  203:Result:='Атрибуты-2';
  204:Result:='Атрибуты-3';
  205:Result:='Атрибуты-4';
  206:Result:='Атрибуты-5';
  207:Result:='Атрибуты-6';
  208:Result:='Косички';
  301:Result:='Верхня губа';
  302:Result:='Атрибуты-A';
  303:Result:='Атрибуты-B';
  304:Result:='Атрибуты-C';
  305:Result:='Атрибуты-D';
  306:Result:='Атрибуты-E';
  307:Result:='Атрибуты-F';
  308:Result:='Атрибуты-G';
  309:Result:='Атрибуты-H';
  310:Result:='Усы';
  401:Result:='Предплечье';
  402:Result:='Перчатки1';
  403:Result:='Перчатки2';
  404:Result:='Перчатки3';
  501:Result:='Голени';
  502:Result:='Сапоги1';
  503:Result:='Сапоги2';
  504:Result:='Сапоги3';
  701:Result:='[За ушами]';
  702:Result:='Уши';
  802:Result:='Рукава1';
  803:Result:='Рукава2';
  902:Result:='Концы штанин1';
  903:Result:='Концы штанин2';
  1002:Result:='Нижний край рубахи';
  1102:Result:='Короткий подол';
  1202:Result:='Накидка';
  1301:Result:='Бёдра';
  1302:Result:='Длинный подол';
  1501:Result:='Спина';
  1502:Result:='Очень длинный плащ';
  1503:Result:='Длинный плащ';
  1504:Result:='Средний плащ';
  1505:Result:='Короткий плащ';
  1506:Result:='Очень короткий плащ';
  else Result:=inttostr(id);
 end; //of case
End;

//Пересборка содержимого
procedure Tfrm_obj.FormShow(Sender: TObject);
begin
 if lv_obj.CanFocus then lv_obj.SetFocus;
 if lv_obj.tag>=0 then begin
  lv_obj.ItemFocused:=lv_obj.Items.Item[lv_obj.tag];
  SendMessage(lv_obj.Handle,LVM_ENSUREVISIBLE,lv_obj.tag,1);
 end else lv_obj.ItemFocused:=lv_obj.Selected;

 //Проверка: нужно ли выводить флажок "Иерархия"
 if (EditorMode=emVertex) or (frm1.tc_mode.TabIndex<>1)
 then cb_tree.visible:=true
 else cb_tree.visible:=false;
end;

//Вспомогательная: если в списке есть такой объект, что
//его caption=s, он выделяется.
procedure TFrm_obj.SelectLObject(s:string);
Var i:integer;
Begin
 for i:=0 to lv_obj.Items.Count-1 do if lv_obj.Items.Item[i].Caption=s
  then begin
   lv_obj.tag:=i;
   if lv_obj.CanFocus and frm_obj.visible then lv_obj.SetFocus;
   application.processmessages;
   lv_obj.ItemFocused:=lv_obj.Items.Item[i];
   lv_obj.Selected:=lv_obj.ItemFocused;
   SendMessage(lv_obj.Handle,LVM_ENSUREVISIBLE,lv_obj.tag,1);
   break;
 end;//of if/for i
End;

//Вспомогательная: если в списке есть объект с object=id,
//то он выделяется
procedure Tfrm_obj.SelectObjectByID(id:integer);
Var i:integer;
Begin
 for i:=0 to lv_obj.Items.Count-1 do if integer(lv_obj.Items.Item[i].Data)=id
  then begin
   lv_obj.tag:=i;
   if lv_obj.CanFocus and frm_obj.visible then lv_obj.SetFocus;
   application.processmessages;
   lv_obj.ItemFocused:=lv_obj.Items.Item[i];
   lv_obj.Selected:=lv_obj.ItemFocused;
   SendMessage(lv_obj.Handle,LVM_ENSUREVISIBLE,lv_obj.tag,1);
   break;
 end;//of if/for i
End;

//Строит список поверхностей
//TypeToAdd - флаги объектов для добавления:
//-1 - корневой список;
//Остальное - ID иерархии (дочерний список)
//Если флажок иерархии снят, параметр игнорируется
procedure TFrm_obj.MakeGeosetsList(TypeToAdd:integer);
Var it:TListItem;len,i,ii:integer;
    lst:array of integer;
    IsPresent:boolean;
    s:string;
Begin
 //1. Определяем, не выделено ли чего
 s:='';
 if (TypesOfObjects=toGeosets) and (lv_obj.tag>=0) then begin
  s:=lv_obj.Items.Item[lv_obj.tag].Caption;
 end;//of if

 TypesOfObjects:=toGeosets;       //установка типа
 lv_obj.Items.Clear;              //очистим список
 lv_obj.tag:=-1;
 //Настройка списка для работы с поверхностями
 lv_obj.MultiSelect:=true;
 lv_obj.ReadOnly:=true;
 lv_obj.SortType:=stNone;

 //Добавим поверхности в виде обычного списка
 if (not IsWoW) or (not cb_tree.checked) then begin
  for i:=0 to CountOfGeosets-1 do begin
   it:=lv_obj.Items.Add;
   it.Caption:='Geoset'+inttostr(i+1);
   it.Data:=pointer(i);           //GeosetID
   it.ImageIndex:=0;
   it.StateIndex:=0;
  end;//of for i
  //Поиск объекта для выделения
  SelectLObject(s);
  exit;
 end;//of if

//---------------------------------------------
 //Добавка поверхностей в виде дерева (иерархия)
 //A. Корневой список (-1):
 if TypeToAdd=-1 then begin
  //1. Построение списка иерархий
  SetLength(lst,CountOfGeosets);
  len:=0;
  for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
   //Ищем: нет ли уже такой группы
   IsPresent:=false;
   for ii:=0 to len-1 do if lst[ii]=HierID then begin
    IsPresent:=true;
    break;
   end;//of for ii

   if not IsPresent then begin
    inc(len);
    lst[len-1]:=HierID;
   end;//of if
  end;//of for i

  //2. Создание корневого списка
  for i:=0 to len-1 do begin
   it:=lv_obj.Items.Add;
   it.Caption:=GetNameByID(lst[i]);
   it.Data:=pointer(lst[i]);      //ID иерархии
   it.ImageIndex:=0;
   it.StateIndex:=2;
  end;//of for i
  lv_obj.tag:=-1;
  //Сортировка корневого списка
  lv_obj.AlphaSort;
  
 end else begin                   //вложенная часть списка
  //1. Добавим "стековую" папочку
  it:=lv_obj.Items.Add;           //добавка 1-го элемента
  it.Caption:=GetNameByID(TypeToAdd);//имя
  it.Data:=pointer(TypeToAdd);    //ID иерархии
  it.ImageIndex:=0;
  it.StateIndex:=3;

  //2. Заполним список поверхностей
  for i:=0 to CountOfGeosets-1 do if Geosets[i].HierID=TypeToAdd then begin
   it:=lv_obj.Items.Add;
   it.Caption:='Geoset'+inttostr(i+1);
   it.Data:=pointer(i);           //GeosetID
   it.ImageIndex:=0;
   it.StateIndex:=0;
  end;//of if/for i
 end;//of if

 //Поиск объекта для выделения
 SelectLObject(s);
End;

//Составление списка последовательностей
procedure TFrm_obj.MakeSequencesList;
Var i:integer;it:TListItem;s:string;
Begin
 cb_tree.visible:=false;
 //0. Определяем, не выделено ли чего
 s:='';
 if (TypesOfObjects=toSeqs) and (lv_obj.tag>=0) then begin
  s:=lv_obj.Items.Item[lv_obj.tag].Caption;
 end;//of if

 TypesOfObjects:=toSeqs;          //установка типа объектов
 //1. Настройка списка для работы с последовательностями
 lv_obj.Items.Clear;
 lv_obj.MultiSelect:=true;
 lv_obj.ReadOnly:=false;          //можно редактировать
 lv_obj.tag:=-1;
  
 //2. Заполним список именами последовательностей
 //Глобальные последовательности НЕ добавляются
 for i:=0 to CountOfSequences-1 do with Sequences[i] do begin
  it:=lv_obj.Items.Add;           //добавить новый элемент
  it.Caption:=Name;
  it.Data:=pointer(i);            //ID последовательности
 end;//of with/for i

 //3. Сортировка списка
 lv_obj.SortType:=stText;

 //4. Поиск объекта для выделения
 SelectLObject(s);
End;

//При смене объекта
procedure Tfrm_obj.lv_objChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
 if item.Selected then lv_obj.tag:=lv_obj.Items.IndexOf(item);
 if (TypesOfObjects=toSeqs) and
    (frm1.sb_stop.visible)  then frm1.sb_stopClick(Sender);
 if (TypesOfObjects=toSkelObjs) and
    (Change=ctState) and (integer(item.Data)>=0) and lv_obj.visible
    and item.Selected and IsMayChange
 then frm1.GraphSelectObject(integer(item.Data));
end;

//Ещё одна пересборка
procedure Tfrm_obj.FormActivate(Sender: TObject);
begin
 FormShow(Sender);
end;

//Нажатие кнопки "Иерархия"
procedure Tfrm_obj.cb_treeClick(Sender: TObject);
begin
 //В зависимости от типа использованных объектов
 //и от включения галочки
 if TypesOfObjects=toGeosets then begin //поверхности
  //Проверим, какой тип списка нужно вывести
  if not cb_tree.checked then begin     //обычный список
   MakeGeosetsList(-1);
   exit;
  end;//of if

  //Вложенный список
  if lv_obj.tag>=0 then begin     //есть выделенное
   MakeGeosetsList(Geosets[integer(lv_obj.Items.Item[lv_obj.tag].Data)].HierID);
  end else begin
   MakeGeosetsList(-1);
  end;
  exit;
 end;//of if(toGeosets)
//----------------------------------------------
 if TypesOfObjects=toSkelObjs then begin //объекты скелета
  //Проверим, какой тип списка нужно вывести
  if not cb_tree.checked then begin     //обычный список
   MakeObjectsList(-1,-1);
   exit;
  end;//of if

  //Вложенный список
  if lv_obj.tag>=0 then begin     //есть выделенное
   MakeObjectsList(integer(lv_obj.Items.Item[lv_obj.tag].Data),-1);
  end else begin
   MakeObjectsList(-1,-1);
  end;
  exit;
 end;//of if
end;

//Двойной клик по объекту
procedure Tfrm_obj.lv_objDblClick(Sender: TObject);
Var pt:TPoint;b:TBone;
begin
 //Выделяем нужный элемент
 if not IsEnter then begin
  pt.x:=LMouseX;pt.y:=LMouseY;
  lv_obj.ItemFocused:=lv_obj.GetItemAt(LMouseX,LMouseY);
  lv_obj.Selected:=lv_obj.ItemFocused;
 end;//of if

 //А вот теперь обработка
 case TypesOfObjects of
  toGeosets:begin
   //дерево неактивно
   if not cb_tree.checked then begin b_okClick(Sender);exit;end;
   //Обрабатываем клик по дереву
   //1. Проверим, не "папка вверх" ли это
   if lv_obj.ItemFocused.StateIndex=3 then begin
    //Составим корневой список
    MakeGeosetsList(-1);
    exit;
   end;//of if

   //2. Это может быть обычная папка (вход в список поверхностей)
   if lv_obj.ItemFocused.StateIndex=2 then begin
    MakeGeosetsList(integer(lv_obj.ItemFocused.Data));
    exit;
   end;//of if

   if lv_obj.ItemFocused.StateIndex=0 then b_okClick(Sender);
  end;//of toGeosets
//--------------------------------------------------
  toSeqs:if lv_obj.SelCount=1 then b_okClick(Sender);
//--------------------------------------------------
  toSkelObjs:begin
   //если дерево неактивно - выйти
   if not cb_tree.checked then exit;

   //если это - папка "вверх", подняться на соотв. уровень
   if lv_obj.ItemFocused.StateIndex=3 then begin
    //Составим корневой список
    b:=GetSkelObjectByID(integer(lv_obj.ItemFocused.Data));
    MakeObjectsList(b.Parent,-1);
    exit;
   end;//of if

   //Если это - объект с потомками, опуститься ниже (на уровень)
   if lv_obj.ItemFocused.StateIndex=2 then begin
    MakeObjectsList(integer(lv_obj.ItemFocused.Data),-1);
    exit;
   end;//of if

  end;//of toSkelObjs
 end;//of case
end;

//Отслеживание координат курсора мыши
procedure Tfrm_obj.lv_objMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 LMouseX:=x;LMouseY:=y;
end;

//Выделение объектов
procedure Tfrm_obj.b_okClick(Sender: TObject);
Var i,ii:integer;
begin
 case TypesOfObjects of
  toGeosets:begin
   //1. Снять выделение со всех поверхностей
   for i:=0 to CountOfGeosets-1 do frm1.clb_geolist.Checked[i]:=false;

   //2. Выделение поверхностей в случае корневого списка
   if lv_obj.Items.Item[0].StateIndex=2 then begin
    for i:=0 to lv_obj.Items.Count-1 do if lv_obj.Items.Item[i].Selected
    then begin
     for ii:=0 to CountOfGeosets-1 do
      if Geosets[ii].HierID=integer(lv_obj.Items.Item[i].Data)
     then frm1.clb_geolist.Checked[ii]:=true;
    end;//of for i
    frm1.cb_showallClick(Sender);
    application.processmessages;
    if frm_obj.CanFocus then frm_obj.SetFocus;
    exit;
   end;//of if

   //3. Выделение поверхностей в папках и без папок :)
   for i:=0 to lv_obj.Items.Count-1 do if (lv_obj.Items.Item[i].Selected)
   and (lv_obj.Items.Item[i].StateIndex=0) then begin
    frm1.clb_geolist.checked[integer(lv_obj.Items.Item[i].Data)]:=true;
   end;//of for i
   frm1.cb_showallClick(Sender);
   application.processmessages;
   if frm_obj.CanFocus then frm_obj.SetFocus;
  end;//of toGeoset
//---------------------------------------------------------
  toSeqs:begin                    //выбираем последовательность
   if lv_obj.SelCount<>1 then exit;//нельзя выбрать сразу несколько анимок
   //1. Выберем эту последовательность
   IsListDown:=true;
   //frm1.cb_animlist.tag:=integer(lv_obj.Selected.Data)+1;
   frm1.cb_animlist.ItemIndex:=AnimPanel.SeqList.IndexOfObject(lv_obj.Selected.Data);
   frm1.cb_animlistChange(Sender);
   //2. Активируем форму объектов
   application.processmessages;
   if frm_obj.CanFocus then frm_obj.SetFocus;
   //3. Запустим/остановим анимацию
   if frm1.sb_play.visible then frm1.sb_playClick(Sender)
                           else frm1.sb_stopClick(Sender);
  end;//of toSeqs
//---------------------------------------------------------
  toSkelObjs:lv_objDblClick(Sender);
 end;//of case
end;

//Удаление поверхностей
procedure Tfrm_obj.DeleteGeosets(Sender:TObject);
Var vt:integer;
Begin
 //1. Выделим поверхности
 b_okClick(Sender);
 //2. Выделим все точки поверхностей
 vt:=ViewType;
 frm1.CtrlA1Click(Sender);
 ViewType:=vt;
 //3. Удалить
 frm1.sb_delClick(Sender);
 //Завершение
 application.processmessages;
 if frm_obj.CanFocus then frm_obj.SetFocus;
End;

function SeqsSortProc(Item1, Item2: TListItem;
                       ParamSort: integer): integer; stdcall;
Begin
 Result:=integer(Item1.data)-integer(item2.Data);
End;

procedure Tfrm_obj.DeleteSequences(Sender:TObject);
Var i,j,jj,FStart,FEnd,cnt:integer;
    it:TListItem;nu:TUndoContainer;
    IsFirstUndo:boolean;
Begin
 cnt:=0;
 lv_obj.CustomSort(@SeqsSortProc,0);    //сортировка
// lv_obj.SortType:=stData;
 //Проверка на кол-во выделенного
 IsFirstUndo:=true;
 //цикл по всем выделенным элементам списка
 for i:=lv_obj.Items.Count-1 downto 0 do begin
  //проверить, не является ли первый элемент списка
  //выделенным. Если нет, продолжить цикл
  if lv_obj.items.Item[i].Selected then it:=lv_obj.items.Item[i]
  else continue;
  //итак, выделенная анимация найдена. Стираем её поэтапно:
  //1. Удаляем все КК (сохраняем в NewUndo для отмены)
  FStart:=Sequences[integer(it.data)].IntervalStart;
  FEnd:=Sequences[integer(it.Data)].IntervalEnd;
  DeleteKeyFrames(FStart,FEnd);
  nu:=TUndoContainer.Create;      //создать новый объект
  nu.TypeOfUndo:=uNDeleteSeqs;    //тип отмены
  inc(cnt);
  if IsFirstUndo then begin
   IsFirstUndo:=false;
   nu.Prev:=-1;
  end else nu.Prev:=CountOfNewUndo-1;
  ReplaceTUndo(Undo[CountOfUndo],nu.Undo);
  inc(CountOfNewUndo);
  SetLength(NewUndo,CountOfNewUndo);
  NewUndo[CountOfNewUndo-1]:=nu;  //добавление в список
  dec(CountOfUndo);               //для последующих манипуляций

  //2. Удаляем собственно анимацию
  SaveNewUndo(uDeleteSeq,integer(it.Data)); //сохр. для отмены
  NewUndo[CountOfNewUndo-1].Prev:=0;
  AnimPanel.DelSeq(integer(it.Data));
{  AnimSaveUndo(uDeleteSeq,integer(it.data)+1);//для отмены
  nu:=TUndoContainer.Create;      //создать контейнер
  inc(cnt);
  nu.TypeOfUndo:=uNDeleteSeqs;    //тип отмены
  nu.Prev:=CountOfNewUndo-1;      //указатель на предыдущий
  ReplaceTUndo(Undo[CountOfUndo],nu.Undo);//перенос
  SetLength(nu.GeoU,CountOfGeosets);
  for j:=0 to CountOfGeosets-1 do
   ReplaceTUndo(Geoobjs[j].Undo[CountOfUndo],nu.GeoU[j]);
  dec(CountOfUndo);
  inc(CountOfNewUndo);
  SetLength(NewUndo,CountOfNewUndo);
  NewUndo[CountOfNewUndo-1]:=nu;    //запись нового объекта

//  num:=cb_animlist.tag-1;
  //Удаление
  for j:=integer(it.Data) to CountOfSequences-2 do Sequences[j]:=Sequences[j+1];
  dec(CountOfSequences);
  frm1.cb_animlist.items.Delete(integer(it.Data)+1);
  //Удаление Anim из поверхностей
  for j:=0 to CountOfGeosets-1 do with Geosets[j] do begin
   if CountOfAnims=0 then continue;
   for jj:=integer(it.Data) to CountOfAnims-2 do Anims[jj]:=Anims[jj+1];
   dec(CountOfAnims);
   SetLength(Anims,CountOfAnims);
  end;//of for j   }

 end;//of for i

 //Устанавливаем Undo
 inc(CountOfUndo);
 Undo[CountOfUndo].Status1:=uUseNewUndo;
 Undo[CountOfUndo].Status2:=cnt;  //кол-во элементов отмены
 //Теперь обновляем всякие списки
 MakeSequencesList;

 frm1.GraphSaveUndo;
{ frm1.sb_animundo.enabled:=true;
 frm1.CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;}
 AnimPanel.MakeAnimList;
 frm1.cb_animlist.items.Assign(AnimPanel.SeqList);
// frm1.cb_animlist.text:='Вся линейка';
 frm1.cb_animlist.ItemIndex:=0;
 IsListDown:=true;
 frm1.cb_animlistChange(Sender);
End;

//Смена имени анимации с указанным номером
//из Sequences (при смене текста в списке анимок)
procedure Tfrm_obj.ChangeSeqName(id:integer);
Var i:integer;
Begin
 for i:=0 to lv_obj.Items.Count-1 do
     if integer(lv_obj.Items.Item[i].Data)=id then begin
      lv_obj.Items.Item[i].Caption:=Sequences[id].Name;
      exit;
 end;//of if/for i
End;

//Смена имени объекта с указанным ID
//(если таковой есть в списке)
procedure Tfrm_obj.ChangeObjName(id:integer;NewName:string);
Var i:integer;
Begin
 for i:=0 to lv_obj.Items.Count-1 do
     if integer(lv_obj.Items.Item[i].Data)=id then begin
      lv_obj.Items.Item[i].Caption:=NewName;
      exit;
 end;//of if/for i
End;

//Строит список активных (видимых) объектов,
//если таковые есть.
//-1 - все объекты,
//остальное - дочерние объекты.
//При снятом флажке "Иерархия" параметр игнорируется.
//Если SelID>=0, то процедура пытается выделить указанный объект
procedure Tfrm_obj.MakeObjectsList(id:integer;SelID:integer);
Var i:integer;it:TListItem;b:TBone;
Begin
 IsMayChange:=false;
 if SelID<0 then begin
  if lv_obj.tag>=0 then SelID:=integer(lv_obj.Items.Item[lv_obj.tag].data)
  else SelID:=-1;
 end;//of if
 lv_obj.Items.Clear;              //очистка списка
 lv_obj.SortType:=stNone;         //сортировка не нужна
 cb_tree.visible:=true;           //проявить окно иерархий
 lv_obj.MultiSelect:=false;       //выделен м.б. только 1 объект
 lv_obj.ReadOnly:=false;          //имена объектов можно менять
 TypesOfObjects:=toSkelObjs;      //объекты скелета
 if not cb_tree.checked then begin //нет режима "иерархия"
  //Копируем объекты прямо из их списка (отсортированного)
  if frm1.cb_bonelist.Items.count=0 then begin //нет объектов
   frm_obj.Hide;
   exit;
  end;//of if
  for i:=0 to frm1.cb_bonelist.Items.count-1 do begin
   it:=lv_obj.Items.Add;
   it.Caption:=frm1.cb_bonelist.Items.Strings[i];
   it.Data:=pointer(frm1.cb_bonelist.Items.Objects[i]);
   //Получаем тип объекта
   case GetTypeObjByID(integer(it.Data)) of
    typBONE,typHELP:it.ImageIndex:=4;
    typATCH:it.ImageIndex:=5;
    typPRE2:it.ImageIndex:=6;
    else it.ImageIndex:=0;
   end;//of case
   it.StateIndex:=0;
  end;//of for i
//---------------------------------------------------------
 end else begin                    //"Иерархия включена"
  //1. Строим список объектов с открытыми папочками
  if id>=0 then begin             //если таковые есть
   b.Parent:=id;
   repeat                         //цикл добавления (доверху)
    it:=lv_obj.Items.Insert(0);   //вставить в самое начало
    b:=GetSkelObjectByID(b.Parent);
    it.Caption:=b.Name;
    it.Data:=pointer(b.ObjectID);
    it.StateIndex:=3;
    case GetTypeObjByID(b.ObjectID) of
     typBONE,typHELP:it.ImageIndex:=4;
     typATCH:it.ImageIndex:=5;
     typPRE2:it.ImageIndex:=6;
     else it.ImageIndex:=0;
    end;//of case
   until b.Parent<0;
  end;//of if (id>=0)

  //Теперь добавляем все дочерние (если есть) из списка.
  //В случае (-1) добавляем вообще все
  for i:=0 to frm1.cb_bonelist.Items.Count-1 do begin
   b:=GetSkelObjectByID(integer(frm1.cb_bonelist.Items.Objects[i]));
   //добавляются только родительские объекты (если id<0 - все объекты)
   if (id<0) or (b.Parent=id) then begin
    it:=lv_obj.Items.Add;
    it.Caption:=b.Name;
    it.Data:=pointer(b.ObjectID);
    if b.Parent<0 then it.StateIndex:=0 else it.StateIndex:=2;
    case GetTypeObjByID(b.ObjectID) of
     typBONE,typHELP:it.ImageIndex:=4;
     typATCH:it.ImageIndex:=5;
     typPRE2:it.ImageIndex:=6;
     else it.ImageIndex:=0;
    end;//of case
   end;//of if
  end;//of for i
 end;//of if

 //И, наконец, выделяем нужное (если есть)
 SelectObjectByID(SelID);
 application.processmessages;
 IsMayChange:=true;
End;


//Обработка нажатия ENTER
procedure Tfrm_obj.lv_objKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (key<>VK_RETURN) and (key<>VK_DELETE) then begin
  frm1.FormKeyDown(Sender,Key,Shift);
  exit;
 end;
 if key=VK_DELETE then begin
  if TypesOfObjects=toGeosets then DeleteGeosets(Sender);
  if TypesOfObjects=toSeqs then DeleteSequences(Sender);
  if TypesOfObjects=toSkelObjs then frm1.sb_objdelClick(Sender);
  exit;
 end;//of if

 case TypesOfObjects of
  toGeosets:begin
   //Обработаем
   if not cb_tree.checked then b_okClick(Sender)//выделение
   else begin
    //1. Выбрано несколько - выделить
    if lv_obj.SelCount>1 then begin b_okClick(Sender);exit;end;
    //выбран 1 элемент. Проверим, что это
    if (lv_obj.Selected.StateIndex=3)
    or (lv_obj.Selected.StateIndex=2) then begin
     IsENTER:=true;
     lv_objDblClick(Sender);
     IsENTER:=false;
     exit;
    end;
    //Выбрана поверхность. Выделить.
    b_okClick(Sender);
   end;//of else
  end;//of toGeosets
//--------------------------------
  toSeqs:b_okClick(Sender);
//--------------------------------
  toSkelObjs:if (lv_obj.Selected<>nil)
   and ((lv_obj.Selected.StateIndex=3)
   or (lv_obj.Selected.StateIndex=2)) then begin
    IsENTER:=true;
    lv_objDblClick(Sender);
    IsENTER:=false;
    exit;
  end;//of toSkelObjs
 end;//of case
end;

//Изменено имя объекта
procedure Tfrm_obj.lv_objEdited(Sender: TObject; Item: TListItem;
  var S: String);
begin
 case TypesOfObjects of
  toSeqs:begin
   //0. Сохраним для отмены
   AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
   frm1.GraphSaveUndo;

   //1. Выберем эту последовательность и поменяем имя
   AnimPanel.SelSeq(item.Data);
   AnimPanel.Seq.Name:=s;
   AnimPanel.SSeq;                //смена имени

   //2. Пересборка панели анимок
   AnimPanel.MakeAnimList;
   frm1.cb_animlist.items.Assign(AnimPanel.SeqList);
   frm1.cb_animlist.ItemIndex:=AnimPanel.GSelSeqIndex;
   frm1.cb_animlistChange(Sender);
{   IsListDown:=true;
   frm1.cb_animlist.tag:=integer(Item.Data)+1;
   frm1.cb_animlist.ItemIndex:=integer(Item.Data)+1;
   frm1.cb_animlistChange(Sender);
   //2. Сменим её имя
   frm1.cb_animlist.text:=s;
   frm1.cb_animlistExit(Sender);
   lv_obj.tag:=-1;
   //3. Вновь активируем окно списков
   application.processmessages;
   if frm_obj.CanFocus then frm_obj.SetFocus;}
  end;//of toSeqs

  toSkelObjs:begin                //смена имени скелетного объекта
   frm1.cb_bonelist.text:=s;      //сменим текст
   frm1.time_lvChng.enabled:=true;     //ждём...
  end;//of toSkelObjs
 end;//of case
end;

//сравнение объектов (для сортировки)
procedure Tfrm_obj.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Shift=[ssCtrl] then begin
{  if ((key=ord('z')) or (key=ord('Z')) or (key=ord('я')) or (key=ord('Я')))
     and  frm1.CtrlZ1.enabled then frm1.CtrlZ1Click(Sender);}
  if AnimEdMode=0 then begin      //редактор скелета
   frm1.FormKeyDown(Sender,Key,Shift);
  end;//of if
 end;//of if
end;

initialization
 IsMayChange:=true;
 TypesOfObjects:=toGeosets;
 IsENTER:=false;
 LMouseX:=0;LMouseY:=0;
end.
