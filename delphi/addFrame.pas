unit addFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmAdd = class(TForm)
    Label1: TLabel;
    ed_count: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure ed_countKeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAdd: TfrmAdd;

implementation

{$R *.DFM}

procedure TfrmAdd.ed_countKeyPress(Sender: TObject; var Key: Char);
begin
 if not (key in ['0'..'9']) and (key>#30) then key:=#0;
end;

procedure TfrmAdd.Button2Click(Sender: TObject);
begin
 ModalResult:=mrCancel;
 Hide;
end;

procedure TfrmAdd.Button1Click(Sender: TObject);
begin
 if ed_Count.text<>'' then ModalResult:=mrOK
                      else ModalResult:=mrCancel;
 Hide;
end;

end.
