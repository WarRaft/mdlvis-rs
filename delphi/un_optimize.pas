unit un_optimize;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst;

type
  Tfrm_optimize = class(TForm)
    clb_actions: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    ed_action: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure clb_actionsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_optimize: Tfrm_optimize;

implementation
const descr:array[0..6] of string=(
'MdlVis может хранить в файле модели дополнительную информацию - например, '+
'о группах сглаживания или иерархии. Это действие удаляет такую '+
'информацию. При этом модель становится чуть меньше и другие '+
'программы (например, конвертеры) могут её загружать.',

'Полностью аналогично команде "Оптимизация->Оптимизировать". Это действие '+
'применимо только к WoW-моделям. Оно удаляет дубли поверхностей модели.',

'После удаления вершин/треугольников часто остаются свободные вершины - '+
'т.е. вершины, не входящие ни в один треугольник. Поскольку они всё равно не '+
'отображаются в Warcraft''e, их можно беспрепятственно удалить.',

'После удаления части геометрии могут остаться кости, к которым не крепится '+
'ни одной вершины и ни одного объекта. Такие кости только занимают лишнее '+
'место, и это действие удаляет их вместе с соответствующими КК.',

'После работы над анимационной линейкой часто остаются КК, которые не '+
'попадают ни в одну анимацию. Это действие удаляет такие КК (в случае моделей '+
'WoW, содержащих множество анимаций, процесс может занять 7-10 секунд).',

'Переводит все анимации модели в линейную форму. Неприменимо к моделям WoW. '+
'Позволяет существенно (иногда даже в 2 раза) уменьшить размер модели '+
'(при условии, что она содержит множество сплайновых контроллеров) за счёт '+
'небольшого снижения качества анимации.',

'Сразу после выполнения этого действия модель необходимо сохранить как MDX, '+
'иначе весь эффект потеряется. После этого модель станет эффективнее сжиматься '+
'при архивации (тип архива не имеет значения - zip, rar, MPQ и др.)'
);
{$R *.DFM}

procedure Tfrm_optimize.FormCreate(Sender: TObject);
begin
 clb_actions.State[0]:=cbChecked;
 clb_actions.State[1]:=cbChecked;
 clb_actions.State[2]:=cbChecked;
 clb_actions.State[3]:=cbChecked;
 clb_actions.State[4]:=cbChecked;
end;

procedure Tfrm_optimize.Button1Click(Sender: TObject);
begin
 frm_Optimize.ModalResult:=mrOK;
 frm_optimize.Hide;
end;

procedure Tfrm_optimize.Button2Click(Sender: TObject);
begin
 frm_optimize.ModalResult:=mrCancel;
 frm_optimize.Hide;
end;

//Вывод соотв. текста (описания действия)
procedure Tfrm_optimize.clb_actionsClick(Sender: TObject);
begin
 ed_action.Lines.text:=descr[clb_actions.ItemIndex];
end;

end.
