unit un_warn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  Tfrm_warn = class(TForm)
    mm: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_warn: Tfrm_warn;

implementation

{$R *.DFM}

procedure Tfrm_warn.Button1Click(Sender: TObject);
begin
 frm_warn.ModalResult:=1; 
end;

end.
