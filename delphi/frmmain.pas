unit frmmain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,OpenGL,GLInst, Menus,mdlwork,mdlDraw, ComCtrls, {ToolWin,} Buttons,
  StdCtrls,objedut,math,real3D, CheckLst,inifiles,shellapi,cabstract,guic,
  crash{, tests};
                
type                    
  Tfrm1 = class(TForm)
    GLWorkArea: TPanel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    od_file: TOpenDialog;
    status: TStatusBar;
    sb_instrum: TScrollBox;
    sb_open: TSpeedButton;
    sb_cross: TSpeedButton;
    sb_zoom: TSpeedButton;
    sb_rot: TSpeedButton;
    sb_move: TSpeedButton;
    pn_stat: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ed_x: TEdit;
    Label3: TLabel;
    ed_y: TEdit;
    Label4: TLabel;
    ed_z: TEdit;
    pn_zoom: TPanel;
    Label5: TLabel;
    ed_zoom: TEdit;
    PopupMenu1: TPopupMenu;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    pn_instr: TPanel;
    Label6: TLabel;
    l_vcount: TLabel;
    l_vselect: TLabel;
    N10: TMenuItem;
    CtrlZ1: TMenuItem;
    sb_undo: TSpeedButton;
    Label7: TLabel;
    Label8: TLabel;
    ed_ix: TEdit;
    Label9: TLabel;
    ed_iy: TEdit;
    Label10: TLabel;
    ed_iz: TEdit;
    pn_objs: TPanel;
    sb_select: TSpeedButton;
    rb_xy: TRadioButton;
    rb_xz: TRadioButton;
    rb_yz: TRadioButton;
    sb_imove: TSpeedButton;
    sb_irot: TSpeedButton;
    sb_izoom: TSpeedButton;
    sb_save: TSpeedButton;
    StrlS1: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    XZ1: TMenuItem;
    YZ1: TMenuItem;
    XY1: TMenuItem;
    sd_file: TSaveDialog;
    N13: TMenuItem;
    sb_del: TSpeedButton;
    b_collapse: TButton;
    b_weld: TButton;
    b_tex: TButton;
    b_hide: TButton;
    b_showall: TButton;
    l_vhide: TLabel;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    sb_triangle: TSpeedButton;
    Label14: TLabel;
    cb_color: TComboBox;
    CtrlC1: TMenuItem;
    CtrlV1: TMenuItem;
    N17: TMenuItem;
    sb_copy: TSpeedButton;
    sb_paste: TSpeedButton;
    clb_geolist: TCheckListBox;
    cb_showall: TCheckBox;
    N18: TMenuItem;
    F11: TMenuItem;
    F21: TMenuItem;
    F31: TMenuItem;
    pn_anim: TPanel;
    pb_anim: TPaintBox;
    l_MaxFrame: TLabel;
    pn_seq: TPanel;
    Label15: TLabel;
    cb_animlist: TComboBox;
    pn_animparam: TPanel;
    cb_nonlooping: TCheckBox;
    cb_UseRarity: TCheckBox;
    pn_rarity: TPanel;
    Label17: TLabel;
    ed_rarity: TEdit;
    UpDown1: TUpDown;
    cb_UseMoveSpeed: TCheckBox;
    pn_MoveSpeed: TPanel;
    Label18: TLabel;
    ed_MoveSpeed: TEdit;
    Label19: TLabel;
    ed_fnum: TEdit;
    Label20: TLabel;
    ed_minframe: TEdit;
    ed_maxframe: TEdit;
    Label21: TLabel;
    sb_animcross: TSpeedButton;
    sb_play: TSpeedButton;
    cb_FPS: TCheckBox;
    ed_FPS: TEdit;
    sb_stop: TSpeedButton;
    b_animDelete: TButton;
    b_animCreate: TButton;
    pn_boneedit: TPanel;
    l_childv: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    ed_bonex: TEdit;
    ed_boney: TEdit;
    ed_bonez: TEdit;
    Label23: TLabel;
    cb_bonelist: TComboBox;
    Label30: TLabel;
    sb_animundo: TSpeedButton;
    pn_info: TPanel;
    sb_animcopy: TSpeedButton;
    sb_animpaste: TSpeedButton;
    pb_redraw: TPaintBox;
    N19: TMenuItem;
    od_3ds: TOpenDialog;
    CtrlA1: TMenuItem;
    cb_light: TCheckBox;
    PopupMenuFrames: TPopupMenu;
    N20: TMenuItem;
    WoW1: TMenuItem;
    od_blp2: TOpenDialog;
    Label11: TLabel;
    PM_geosets: TPopupMenu;
    N21: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    sb_uncouple: TSpeedButton;
    N24: TMenuItem;
    b_GlobalCreate: TButton;
    ud_frame: TUpDown;
    N25: TMenuItem;
    pn_Color: TPanel;
    Panel2: TPanel;
    Label34: TLabel;
    bb_AlphaCreate: TBitBtn;
    ed_alpha: TEdit;
    cb_filter: TCheckBox;
    Panel1: TPanel;
    Label35: TLabel;
    bb_ColorCreate: TBitBtn;
    pn_colorEnter: TPanel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    ed_r: TEdit;
    ed_g: TEdit;
    ed_b: TEdit;
    sb_coll1: TSpeedButton;
    Label16: TLabel;
    sb_coll1p: TSpeedButton;
    sb_coll2: TSpeedButton;
    sb_coll2p: TSpeedButton;
    N26: TMenuItem;
    sb_mirror: TSpeedButton;
    sb_swap: TSpeedButton;
    sb_deltr: TSpeedButton;
    l_triangles: TLabel;
    CtrlC2: TMenuItem;
    C1: TMenuItem;
    CtrlV2: TMenuItem;
    Panel3: TPanel;
    Label12: TLabel;
    cb_VisOn: TCheckBox;
    bb_VisCreate: TBitBtn;
    N27: TMenuItem;
    N28: TMenuItem;
    N29: TMenuItem;
    N30: TMenuItem;
    N31: TMenuItem;
    N32: TMenuItem;
    CtrlC3: TMenuItem;
    C2: TMenuItem;
    CtrlV3: TMenuItem;
    Del1: TMenuItem;
    Del2: TMenuItem;
    H1: TMenuItem;
    N33: TMenuItem;
    N34: TMenuItem;
    N35: TMenuItem;
    cb_vertices: TCheckBox;
    N36: TMenuItem;
    N37: TMenuItem;
    b_extrude: TSpeedButton;
    b_detach: TSpeedButton;
    tc_mode: TTabControl;
    Timer1: TTimer;
    N38: TMenuItem;
    FF1: TMenuItem;
    FF2: TMenuItem;
    FF3: TMenuItem;
    FF4: TMenuItem;
    FF5: TMenuItem;
    cb_workplane: TCheckBox;
    N39: TMenuItem;
    N40: TMenuItem;
    N41: TMenuItem;
    N42: TMenuItem;
    N43: TMenuItem;
    Label13: TLabel;
    time_lvChng: TTimer;
    N44: TMenuItem;
    CtrlB1: TMenuItem;
    CtrlA2: TMenuItem;
    pn_workplane: TPanel;
    rb_bxy: TRadioButton;
    rb_bxz: TRadioButton;
    rb_byz: TRadioButton;
    pn_binstrum: TPanel;
    Label22: TLabel;
    sb_selbone: TSpeedButton;
    sb_objdel: TSpeedButton;
    sb_bonemove: TSpeedButton;
    sb_bonerot: TSpeedButton;
    sb_bonescale: TSpeedButton;
    cb_workplane2: TCheckBox;
    pn_boneprop: TPanel;
    Label24: TLabel;
    cb_billboard: TCheckBox;
    sb_objcollapse: TSpeedButton;
    sb_decollapsebo: TSpeedButton;
    sb_instcollapse: TSpeedButton;
    sb_instdecollapse: TSpeedButton;
    sb_wpcollapse: TSpeedButton;
    SpeedButton2: TSpeedButton;
    sb_wpdecollapse: TSpeedButton;
    sb_bpcollapse: TSpeedButton;
    sb_bpdecollapse: TSpeedButton;
    pn_atchprop: TPanel;
    Label29: TLabel;
    sb_apcollapse: TSpeedButton;
    sb_apdecollapse: TSpeedButton;
    cb_abillboard: TCheckBox;
    Label32: TLabel;
    ed_path: TEdit;
    sb_begattach: TSpeedButton;
    sb_endattach: TSpeedButton;
    sb_detach: TSpeedButton;
    pn_listbones: TPanel;
    Label31: TLabel;
    Label33: TLabel;
    lb_bones: TListBox;
    sb_vattach: TSpeedButton;
    sb_vreattach: TSpeedButton;
    sb_vdetach: TSpeedButton;
    cb_multiselect: TCheckBox;
    lb_selected: TListBox;
    pn_view: TButton;
    sb_selexpand: TSpeedButton;
    N45: TMenuItem;
    N46: TMenuItem;
    pn_vertcoords: TPanel;
    Label39: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    pn_propobj: TPanel;
    Label44: TLabel;
    sb_propobjcollapse: TSpeedButton;
    sb_propobjdecollapse: TSpeedButton;
    cb_objvis: TCheckBox;
    b_visanimate: TButton;
    Label45: TLabel;
    cb_mover: TCheckBox;
    cb_rotationr: TCheckBox;
    cb_scalingr: TCheckBox;
    b_cancel: TButton;
    pn_contrprops: TPanel;
    Label46: TLabel;
    sb_cpcollapse: TSpeedButton;
    sb_cpdecollapse: TSpeedButton;
    l_object: TLabel;
    l_conttype: TLabel;
    rg_conttype: TRadioGroup;
    cb_showkey: TCheckBox;
    b_delcontr: TButton;
    pn_spline: TPanel;
    Label47: TLabel;
    sb_scollapse: TSpeedButton;
    sb_sdecollapse: TSpeedButton;
    pb_spline: TPaintBox;
    Label48: TLabel;
    Label49: TLabel;
    Label50: TLabel;
    ed_t: TEdit;
    ed_c: TEdit;
    ed_bias: TEdit;
    N47: TMenuItem;
    pn_pre2prop: TPanel;
    Label51: TLabel;
    sb_pre2collapse: TSpeedButton;
    sb_pre2decollapse: TSpeedButton;
    cb_pre2bilb: TCheckBox;
    N210: TMenuItem;
    N48: TMenuItem;
    sb_nsmooth: TSpeedButton;
    sb_nrot: TSpeedButton;
    sb_nrestore: TSpeedButton;
    N49: TMenuItem;
    K1: TMenuItem;
    N50: TMenuItem;
    N51: TMenuItem;
    N52: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
//    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sb_crossClick(Sender: TObject);
    procedure sb_zoomClick(Sender: TObject);
    procedure GLWorkAreaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GLWorkAreaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GLWorkAreaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_rotClick(Sender: TObject);
    procedure sb_moveClick(Sender: TObject);
{    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);}
    procedure ed_zoomEnter(Sender: TObject);
    procedure ed_zoomKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_xKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_xExit(Sender: TObject);
    procedure ed_yKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_yExit(Sender: TObject);
    procedure ed_zExit(Sender: TObject);
    procedure ed_zKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N9Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure CtrlZ1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
//    procedure cb_objChange(Sender: TObject);
    procedure sb_selectClick(Sender: TObject);
    procedure sb_imoveClick(Sender: TObject);
    procedure ed_ixExit(Sender: TObject);
    procedure ed_ixKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sb_irotClick(Sender: TObject);
    procedure sb_izoomClick(Sender: TObject);
    procedure StrlS1Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure XZ1Click(Sender: TObject);
    procedure YZ1Click(Sender: TObject);
    procedure XY1Click(Sender: TObject);
    procedure cb_showallClick(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure sb_delClick(Sender: TObject);
    procedure b_collapseClick(Sender: TObject);
    procedure b_weldClick(Sender: TObject);
    procedure b_extrudeClick(Sender: TObject);
    procedure b_texClick(Sender: TObject);
    procedure b_hideClick(Sender: TObject);
    procedure b_showallClick(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure sb_triangleClick(Sender: TObject);
    procedure cb_colorChange(Sender: TObject);
    procedure CtrlC1Click(Sender: TObject);
    procedure CtrlV1Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure sb_mirrorClick(Sender: TObject);
    procedure F11Click(Sender: TObject);
    procedure pb_animPaint(Sender: TObject);
    procedure pb_animMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pb_animMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pb_animMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure F31Click(Sender: TObject);
    procedure ed_fnumExit(Sender: TObject);
    procedure ed_fnumKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cb_animlistChange(Sender: TObject);
    procedure sb_animcrossClick(Sender: TObject);
    procedure sb_playClick(Sender: TObject);
    procedure sb_stopClick(Sender: TObject);
    procedure cb_FPSClick(Sender: TObject);
    procedure ed_FPSExit(Sender: TObject);
    procedure ed_FPSKeyPress(Sender: TObject; var Key: Char);
    procedure ed_FPSKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cb_nonloopingClick(Sender: TObject);
    procedure cb_UseRarityClick(Sender: TObject);
    procedure cb_UseMoveSpeedClick(Sender: TObject);
    procedure ed_MoveSpeedExit(Sender: TObject);
    procedure ed_MoveSpeedKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_minframeExit(Sender: TObject);
    procedure ed_minframeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_maxframeExit(Sender: TObject);
    procedure cb_animlistExit(Sender: TObject);
    procedure cb_animlistKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure b_animCreateClick(Sender: TObject);
    procedure b_animDeleteClick(Sender: TObject);
    procedure cb_bonelistChange(Sender: TObject);
    procedure sb_selvertClick(Sender: TObject);
    procedure sb_vattachClick(Sender: TObject);
    procedure sb_bonerotClick(Sender: TObject);
    procedure DrawFrame(num:integer);
    procedure ed_bonexExit(Sender: TObject);
    procedure ed_bonexKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sb_bonemoveClick(Sender: TObject);
    procedure bBeginTrans(Sender:TObject);
    procedure sb_bonescaleClick(Sender: TObject);
    procedure ed_maxframeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure pb_redrawPaint(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure CtrlA1Click(Sender: TObject);
    procedure cb_lightClick(Sender: TObject);
    procedure N20Click(Sender: TObject);
    procedure WoW1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure clb_geolistMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N21Click(Sender: TObject);
    procedure N22Click(Sender: TObject);
    procedure N23Click(Sender: TObject);
//    procedure FindWorkPlane(x,y:integer;Shift:TShiftState);
    procedure ed_ixKeyPress(Sender: TObject; var Key: Char);
    procedure sb_uncoupleClick(Sender: TObject);
    procedure cb_animlistDropDown(Sender: TObject);
    procedure N24Click(Sender: TObject);
    procedure AnimUndo(Sender:TObject);
    procedure AnimLineRefresh(Sender:TObject);
    procedure ud_frameClick(Sender: TObject; Button: TUDBtnType);
    procedure b_GlobalCreateClick(Sender: TObject);
    procedure N25Click(Sender: TObject);
    procedure ReFormStamps;
    procedure SetColorPanelState(Sender:TObject);
    procedure cb_filterClick(Sender: TObject);
    procedure BuildPanels;
    procedure sb_coll1Click(Sender: TObject);
    procedure sb_coll1pClick(Sender: TObject);
    procedure sb_coll2Click(Sender: TObject);
    procedure sb_coll2pClick(Sender: TObject);
    procedure N26Click(Sender: TObject);
    procedure RefreshWorkArea(Sender:TObject);
    procedure sb_swapClick(Sender: TObject);
    procedure sb_deltrClick(Sender: TObject);
    procedure CtrlC2Click(Sender: TObject);
    procedure CtrlV2Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure N27Click(Sender: TObject);
    procedure Del2Click(Sender: TObject);
    procedure bb_VisCreateClick(Sender: TObject);
    procedure bb_AlphaCreateClick(Sender: TObject);
    procedure bb_ColorCreateClick(Sender: TObject);
    procedure cb_VisOnClick(Sender: TObject);
    procedure ed_alphaKeyPress(Sender: TObject; var Key: Char);
    procedure ed_alphaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_alphaExit(Sender: TObject);
    procedure ed_rExit(Sender: TObject);
    procedure ed_rKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure H1Click(Sender: TObject);
    procedure N36Click(Sender: TObject);
    procedure N37Click(Sender: TObject);
    procedure b_detachClick(Sender: TObject);
    procedure tc_modeDrawTab(Control: TCustomTabControl; TabIndex: Integer;
      const Rect: TRect; Active: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure FF1Click(Sender: TObject);
    procedure cb_workplaneClick(Sender: TObject);
    procedure N39Click(Sender: TObject);
    procedure tc_modeChange(Sender: TObject);
    procedure N34Click(Sender: TObject);
    procedure N35Click(Sender: TObject);
    procedure N40Click(Sender: TObject);
    procedure cb_bonelistExit(Sender: TObject);
    procedure cb_bonelistKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cb_bonelistDropDown(Sender: TObject);
    procedure time_lvChngTimer(Sender: TObject);
    procedure sb_objdelClick(Sender: TObject);
    procedure sb_objcollapseClick(Sender: TObject);
    procedure sb_decollapseboClick(Sender: TObject);
    procedure cb_workplane2Click(Sender: TObject);
    procedure sb_instcollapseClick(Sender: TObject);
    procedure sb_instdecollapseClick(Sender: TObject);
    procedure sb_wpcollapseClick(Sender: TObject);
    procedure sb_wpdecollapseClick(Sender: TObject);
    procedure sb_bpcollapseClick(Sender: TObject);
    procedure sb_bpdecollapseClick(Sender: TObject);
    procedure sb_apcollapseClick(Sender: TObject);
    procedure sb_apdecollapseClick(Sender: TObject);
    procedure cb_billboardClick(Sender: TObject);
    procedure cb_abillboardClick(Sender: TObject);
    procedure ed_pathExit(Sender: TObject);
    procedure ed_pathKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CtrlB1Click(Sender: TObject);
    procedure CtrlA2Click(Sender: TObject);
    procedure sb_begattachClick(Sender: TObject);
    procedure sb_endattachClick(Sender: TObject);
    procedure sb_detachClick(Sender: TObject);
    procedure lb_bonesDblClick(Sender: TObject);
    procedure sb_vreattachClick(Sender: TObject);
    procedure sb_vdetachClick(Sender: TObject);
    procedure rb_bxyClick(Sender: TObject);
    procedure rb_bxzClick(Sender: TObject);
    procedure rb_byzClick(Sender: TObject);
    procedure rb_xyClick(Sender: TObject);
    procedure rb_xzClick(Sender: TObject);
    procedure rb_yzClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure cb_multiselectClick(Sender: TObject);
    procedure lb_selectedDblClick(Sender: TObject);
    procedure pn_viewClick(Sender: TObject);
    procedure sb_selexpandClick(Sender: TObject);
    procedure N45Click(Sender: TObject);
    procedure N46Click(Sender: TObject);
    procedure sb_propobjcollapseClick(Sender: TObject);
    procedure sb_propobjdecollapseClick(Sender: TObject);
    procedure b_cancelClick(Sender: TObject);
    procedure cb_moverClick(Sender: TObject);
    procedure cb_rotationrClick(Sender: TObject);
    procedure cb_scalingrClick(Sender: TObject);
    procedure sb_cpdecollapseClick(Sender: TObject);
    procedure sb_cpcollapseClick(Sender: TObject);
    procedure cb_showkeyClick(Sender: TObject);
    procedure b_visanimateClick(Sender: TObject);
    procedure cb_objvisClick(Sender: TObject);
    procedure b_delcontrClick(Sender: TObject);
    procedure rg_conttypeClick(Sender: TObject);
    procedure sb_scollapseClick(Sender: TObject);
    procedure sb_sdecollapseClick(Sender: TObject);
    procedure pb_splinePaint(Sender: TObject);
    procedure ed_tKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ed_tExit(Sender: TObject);
    procedure sb_pre2decollapseClick(Sender: TObject);
    procedure sb_pre2collapseClick(Sender: TObject);
    procedure N47Click(Sender: TObject);
    procedure N210Click(Sender: TObject);
    procedure N48Click(Sender: TObject);
    procedure sb_nsmoothClick(Sender: TObject);
    procedure sb_nrotClick(Sender: TObject);
    procedure sb_nrestoreClick(Sender: TObject);
    procedure sd_fileTypeChange(Sender: TObject);
    procedure K1Click(Sender: TObject);
    procedure N50Click(Sender: TObject);
    procedure UpDown1ChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Smallint; Direction: TUpDownDirection);
    procedure cb_animlistDblClick(Sender: TObject);
    procedure N51Click(Sender: TObject);
    procedure N52Click(Sender: TObject);
  private
    //Обработчик сообщения WM_DROPFILES
    procedure FileDrop(var msg:TWMDropFiles);message WM_DROPFILES;
    //Загружает список ранее открытых файлов
    procedure LoadRecentFiles(Sender:TObject);
    //Сохраняет список ранее открытых файлов
    procedure SaveRecentFiles(Sender:TObject);
    //загружает параметры из mdlvis.ini, если таковой есть
    procedure LoadParams(Sender:TObject);
    //Добавляет указанный файл в список файлов (в меню),
    //и массив RecentsFiles
    procedure AddFileToMenuList(s:string;Sender:TObject);
    //Устанавливает флаг видимости объекта на панели свойств
    //Предварительно необходимо сбросить тег заголовка панели
    procedure SetObjVisibilityProp;
    { Private declarations }
  public
    //Вспомогательная: составляет список объектов
    //(куда включаются все объекты).
    //Этот список сортируется по алфавиту(+по типу объектов)
    //С каждой строкой списка связывается ID объекта
    //И весь список засовывается в cb_bonelist.
    procedure MakeTextObjList(Sender:TObject);
    //производит перерисовку и обновление списка
    //поверхностей после их удаления
    procedure RefreshGeoList(Sender:TObject;dltFlg:boolean);
    //Выполняет все графические преобразования,
    //связанные с выделением объекта+собственно выделение
    procedure GraphSelectObject(id:integer);
    //Осуществляет выделение множественных объектов
    //меняет список выделения на указанный (TFace)
    //если len=-1, проходит инициализация БЕЗ смены списка
    //и БЕЗ сохранения в Undo
    procedure GraphMultiSelectObject(lst:TFace;len:integer);
    //Заполняет список костей, влияющих на выделенные вершины
    //и делает соотв. панель видимой
    procedure FillBonesList;
    //Привести в соответствие инструменты присоединения вершин
    procedure EnableAttachInstrums;
    //Отмена, сохранённая в NewUndo
    procedure ReleaseNewUndo(Sender:TObject);
    //Снять выделение со всех объектов
    //(затрагивает только панели инструментов)
    procedure DeselectObject;
    //Начать премещение кости (изменение PivotPoint)
    procedure bBeginMove(Sender:TObject);
    //Устанавливает видимость кнопок видимости
    procedure SetVisPanelActive;
    //Изменить доступность инструментов в соответствии с
    //ограничениями
    procedure ApplyInstrumRestrictions;
    //пересобрать панели свойств объектов
    procedure ReMakeObjPropPanels;
    //Установить все свойства анимационной панели
    //из последовательности, выбранной в TAnimPanel
    procedure SAnimPanelProps;
    //Используется совместно с SaveAnimUndo -
    //устанавливает кнопки/элементы меню undo и save
    procedure GraphSaveUndo;
    { Public declarations }
  end;

var
  frm1: Tfrm1;
  IsObjsDown,           //отслеживание списка объектов
  IsListDown:boolean;   //отслеживание списков
  fLog:text;            //лог-файл
  IsSlowHighlight:boolean;//когда true, подсветка рисуется через glCallList
  dc:hdc; //контекст рабочей панели
  hrc:HGLRC;//контекст воспроизведения
const
  //Режимы редактирования
  emVertex=1;emAnims=2;
//проверка строки: не число ли это.
function IsCipher(s:string):boolean;
//Вспомогательная: вычисление определителя матрицы поворота
function GetDeterminant(m:TRotMatrix):GLfloat;
//Вспомогательная: возвращает расстояние от точки (x,y)
//до прямой, заданной x1,y1,x2,x2
function GetDistance(x,y,x1,y1,x2,y2:GLFloat):GLFloat;
//Вспомогательная: возвращает угол поворота вектора,
//заданного (vx,vy)
function AngleOfVector(vx,vy:single):single;
implementation

uses unTex, addFrame, unAbout, un_obj, un_optimize, un_warn;

{$R *.DFM}
type TStamp=record                //тип: анимационная метка
 Color:TColor;                    //цвет
 Pos:integer;                     //позиция
end;//of TStamp
Var ftst:text;   //файл
    IsParFile:boolean;
    IsMouseDown,IsLeftMouseDown:boolean;//true, если клавиша мыши нажата
    IsWheel:boolean;    //true, если колесико вертится
    IsKeyDown:boolean;  //true, если клавиша клавиатуры наж.
    IsArea:boolean;     //true, если идет работа с площадью
    IsShift,IsAnimShift:boolean;    //true, если нажат Shift
    IsPlay:boolean;     //true, если проигрывается анимация
    IsParamsLoaded:boolean;//true, если параметры загружены
    bExit:boolean;
    OldMouseX,OldMouseY:integer;//старые к-ты мыши
    ClickX,ClickY:integer;  //к-ты клика
    olGeosets:string;     //список поверхностей
    GlobalX,GlobalY,GlobalZ:GLfloat;//глобальные переменные (для инструментов)
    DeltaX,DeltaY,DeltaZ:GLfloat;
    r,g,b:GLfloat;        //текущие цвета
    //Данные для анимационной шкалы
    hBitmap:integer;              //хэндл совместимого изображения
    Division:integer; //межотметочное расстояние
    IsAnimMouseDown:boolean;//отслеживание мыши
    stamps:TKeyFramesList;
    GlShift:TShiftState;
    RecentFiles:array [1..5] of string; //массив недавно открытых файлов
    CountOfRF:integer;            //кол-во этих файлов
    CurNewBoneNum:integer;        //при создании новой кости увеличивается
    //Переменные для полей цвета и прозрачности
    MidAlpha,cr,cg,cb:GLFloat;
    ObjAnimate:TObjAnimate;
    ContrProps:TContrProps;
    SplinePanel:TSpline;
    WorkPlane:TWorkPlane;
    NInstrum:TNInstrum;
    
const crZoomCur=10;   //курсоры
      crRotCur=11;
//проверка строки: не число ли это.
function IsCipher(s:string):boolean;
Var IsPoint:boolean;i:integer;
Begin
 PushFunction(1);
 IsCipher:=false; //пока не число
 IsPoint:=false;
 if (s='') or (s='.') or (s='-') then begin PopFunction;exit;end;
 //проверка каждого символа
 for i:=1 to length(s) do begin
  if IsPoint and (s[i]='.') then begin PopFunction;exit;end;//не м.б. двух точек
  if ((s[i]<'0') or (s[i]>'9')) and (s[i]<>'.') and (s[i]<>'-')
  then begin PopFunction;exit;end;
  //минус не м.б. в середине
  if (s[i]='-') and (i>1) then begin PopFunction;exit;end;
  //не м. начинаться с точки
  if (s[i]='.') and (i=1) then begin PopFunction;exit;end;
  if s[i]='.' then IsPoint:=true;
 end;//of for
 IsCipher:=true;//успешно, это число
 PopFunction;
End;

//Загружает список ранее открытых файлов
procedure TFrm1.LoadRecentFiles(Sender:TObject);
Var inif:TIniFile;a:array[1..1000] of Char;
    pa:PChar;s:string;
    i:integer;
const sect='Params';sectf='RecentFiles';
Begin
 PushFunction(2);
 pa:=@a;
 GetModuleFileName(hInstance,pa,1000);
 s:=string(pa);
 Delete(s,length(s)-2,3);
 inif:=TIniFile.Create(s+'ini');

 RecentFiles[1]:=inif.ReadString(sectf,'File1','');
 RecentFiles[2]:=inif.ReadString(sectf,'File2','');
 RecentFiles[3]:=inif.ReadString(sectf,'File3','');
 RecentFiles[4]:=inif.ReadString(sectf,'File4','');
 RecentFiles[5]:=inif.ReadString(sectf,'File5','');
 for i:=1 to 5 do begin
  if length(RecentFiles[i])<3 then break;
  inc(CountOfRF);
 end;//of for i

 inif.Free;
 PopFunction;
End;

//загружает параметры из mdlvis.ini, если таковой есть
procedure TFrm1.LoadParams(Sender:TObject);
Var inif:TIniFile;a:array[1..1000] of Char;
    pa:PChar;s:string;
//    i:integer;
const sect='Params';sectf='RecentFiles';
      sectO='Other';  
Begin
 if IsParamsLoaded then exit;     //параметры уже загружены
 PushFunction(3);
 pa:=@a;
 GetModuleFileName(hInstance,pa,1000);
 s:=string(pa);
 Delete(s,length(s)-2,3);
 inif:=TIniFile.Create(s+'ini');

 //начинаем чтение
 if inif.ReadBool(sect,'SaveDialogStyle',false)
 then sd_file.Options:=[ofHideReadOnly,ofEnableSizing,ofOldStyleDialog]
 else sd_file.Options:=[ofHideReadOnly,ofEnableSizing];
 IsLowGrid:=inif.ReadBool(sect,'SmallGrid',false);
 N12.checked:=IsLowGrid;
 IsXZGrid:=inif.ReadBool(sect,'XZGrid',false);
 XZ1.checked:=IsXZGrid;
 IsYZGrid:=inif.ReadBool(sect,'YZGrid',false);
 YZ1.checked:=IsYZGrid;
 IsXYGrid:=inif.ReadBool(sect,'XYGrid',true);
 XY1.checked:=IsXYGrid;

 //подсветка
 IsXYZ:=inif.ReadBool(sect,'AxisHighlight',true);
 cb_workplane.checked:=not IsXYZ;
 cb_workplane2.checked:=not IsXYZ;
 //Вывод осей
 IsAxes:=inif.ReadBool(sect,'Axes',true);
 N39.checked:=IsAxes;

 //тени+вершины
 IsLight:=inif.ReadBool(sect,'Shades',true);
 cb_light.tag:=1;
 cb_light.checked:=IsLight;
 IsVertices:=inif.ReadBool(sect,'Vertices',false);
 cb_vertices.checked:=IsVertices;
 cb_light.tag:=0;

 //режим подсветки
 IsSlowHighlight:=inif.ReadBool(sect,'SlowHighlight',false);

 //Видимость объектов
 VisObjs.VisBones:=inif.ReadBool(sect,'BonesVisibility',true);
 N34.checked:=VisObjs.VisBones;
 VisObjs.VisAttachments:=inif.ReadBool(sect,'AtchVisibility',true);
 N35.checked:=VisObjs.VisAttachments;
 VisObjs.VisParticles:=inif.ReadBool(sect,'PartEmVisibility',false);
 VisObjs.VisSkel:=inif.ReadBool(sect,'SkelVisibility',false);
 N40.checked:=VisObjs.VisSkel;
 VisObjs.VisOrient:=inif.ReadBool(sect,'OrientVisibility',false);
 N46.checked:=VisObjs.VisOrient;

 //Спец. параметры:
 IsDisp:=inif.ReadBool(sectO,'DisplaceInsertedByZ',true);

 //Читаем имена последних открытых файлов
 inif.Free;
 LoadRecentFiles(Sender);

 IsParamsLoaded:=true;            //параметры загружены
 PopFunction;
End;

//при создании формы
procedure Tfrm1.FormCreate(Sender: TObject);
Var clr:TColor;
begin
 PushFunction(4);

 //Создание (именование) меню.
 N2.caption:='Открыть'#09#09#09'Ctrl+O';
 N52.caption:='Выход'#09#09#09#09'Ctrl+X';
 StrlS1.caption:='Сохранить'#09#09#09'Ctrl+S';
 CtrlZ1.caption:='Отменить'#09#09'Ctrl+Z';
 CtrlA1.caption:='Выделить все'#09#09'Ctrl+A';
 CtrlC1.caption:='&Копировать'#09#09'Ctrl+C';
 CtrlV1.caption:='В&ставить'#09#09'Ctrl+V';
 N15.caption:='Поверхность'#09'S';
 N16.caption:='Общий вид'#09'F';
 N26.caption:='Нормали'#09'N';
 H1.caption:='Иерархия'#09'H';
 F11.caption:='Редактор вершин'#09'F1';
 F21.caption:='Редатор текстур'#09'F2';
 F31.caption:='Редактор анимаций'#09'F3';

 N29.caption:='Очистить'#09'Ctrl+D';
 Del1.caption:='Удалить'#09'Del';
 CtrlC3.caption:='Копировать'#09'Ctrl+C';
 C2.caption:='Копировать кадр'#09'C';
 CtrlV3.caption:='Вставить'#09'Ctrl+V';
 N51.caption:='Смешать'#09'Ctrl+B';

 CtrlB1.caption:='Кость'#09#09#09#09'Ctrl+B';
 CtrlA2.caption:='Крепление'#09#09#09'Ctrl+A';
 N210.caption:='ИЧ-2'#09'Ctrl+P';
 N45.caption:='Клонировать объект'#09#09'Ctrl+V';

 K1.caption:='Канонизация'#09'K';

 N20.caption:=N29.caption;
 Del2.caption:=Del1.caption;
 CtrlC2.caption:=CtrlC3.caption;
 C1.caption:=C2.caption;
 CtrlV2.caption:=CtrlV3.caption;


 //создание объектов
 SplinePanel:=TSpline.Create;
// CreateLogFile;
// Test_TKeyFramesList;
// Test_TTan;
 //разделитель чисел
 if DecimalSeparator <> '.' then DecimalSeparator := '.';
 Excentry_:=GLWorkArea.width/GLWorkArea.height;//эксцентриситет
 dc:=GetDC(GLWorkArea.handle);//получить контекст
 giSetPixFormat(dc,f_stand);  //установить формат пикселя
 hrc:=wglCreateContext(dc); //получить контекст воспроизведения
 wglMakeCurrent(dc,hrc);    //сделать контекст текущим
  clr:=frm1.Color;
  glClearColor((clr and $0FF)/255,((clr and $0FF00) shr 8)/255,
               ((clr and $0FF0000) shr 16)/255,1.0);//цвет фона
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  SwapBuffers(dc);

 //установить источники света:

 //создать совместимый контекст
 pb_anim.tag:=CreateCompatibleDC(pb_anim.Canvas.Handle);
 hbitmap:=CreateCompatibleBitmap(pb_anim.canvas.handle,pb_anim.width,
                                 pb_anim.height);
 SelectObject(pb_anim.tag,hBitmap);
 //загрузка объектов
 Screen.Cursors[crZoomCur] := LoadCursor(HInstance, 'ZoomCur');
 Screen.Cursors[crRotCur] := LoadCursor(HInstance, 'RotCur');

 //Разворот окна на весь экран
 SendMessage(frm1.handle,WM_SYSCOMMAND,SC_MAXIMIZE,0);
 pn_info.visible:=false;
 DragAcceptFiles(frm1.handle,true); //разрешить Drag&Drop
 PopFunction;
end;

//Добавляет указанный файл в список файлов (в меню),
//и массив RecentsFiles
procedure TFrm1.AddFileToMenuList(s:string;Sender:TObject);
Var i:integer;IsFound:boolean;stmp:string;
function cpysp(var s:string):string;
Begin
 if length(s)<26 then Result:=s
 else Result:='...'+copy(s,length(s)-25,26);
End;
Begin
 PushFunction(5);
 if s<>'?' then begin
  //0. Ищем: вдруг такой файл уже есть?
  IsFound:=false;
  for i:=1 to CountOfRF do if RecentFiles[i]=s then begin
   IsFound:=true;
   stmp:=RecentFiles[1];
   RecentFiles[1]:=s;
   RecentFiles[i]:=stmp;
   break;
  end;//of for i

  if not IsFound then begin
   //1. Сдвигаем все предыдущие имена к концу
   for i:=4 downto 1 do RecentFiles[i+1]:=RecentFiles[i];
   //2. Если массив не заполнен - добавить новый элемент
   if CountOfRF<5 then inc(CountOfRF);
   //3. Помещаем строку на самый верх
   RecentFiles[1]:=s;
  end;//of if
 end;//of if

 //4. Приводим в порядок меню
 if CountOfRF>=1 then N38.visible:=true;  //полоса-разделитель
 if CountOfRF>=1 then begin
  FF1.caption:=cpysp(RecentFiles[1]);
  FF1.visible:=true;
 end;
 if CountOfRF>=2 then begin
  FF2.caption:=cpysp(RecentFiles[2]);
  FF2.visible:=true;
 end;
 if CountOfRF>=3 then begin
  FF3.caption:=cpysp(RecentFiles[3]);
  FF3.visible:=true;
 end;
 if CountOfRF>=4 then begin
  FF4.caption:=cpysp(RecentFiles[4]);
  FF4.visible:=true;
 end;
 if CountOfRF>=5 then begin
  FF5.caption:=cpysp(RecentFiles[5]);
  FF5.visible:=true;
 end;
 PopFunction;
End;

//клик "открыть файл"
procedure Tfrm1.N2Click(Sender: TObject);
Var i,j:integer;
    fext,stmp:string;
    IsOptimize:boolean;
const position:array[0..3] of GLfloat=(80,150,150,1.0);
      position1:array[0..3] of GLfloat=(0,0,0,1.0);
      amb:array[0..3] of GLFloat=(0.6,0.6,0.6,1);
begin
 PushFunction(6);
 IsPlay:=false;
// application.HandleMessage;
 if EditorMode<>emVertex then F11Click(Sender);
// application.processmessages;
 IsOptimize:=false;
 if IsParFile or od_file.Execute then begin//модель выбрана
  sModelName:=frmAbout.label2.caption+#13#10+od_file.FileName; //для крэш-дампа
  IsParFile:=false;
  assignFile(ftst,od_file.FileName); //проверка наличия файла
  {$I-}reset(ftst);{$I+}
  if IOResult<>0 then begin
   MessageBox(frm1.handle,'Файл не найден','Ошибка',mb_applmodal or mb_iconstop);
   PopFunction;
   exit;
  end;//of if
  closeFile(ftst);
  //Проверка на "открытость" файла
  if sb_cross.enabled then begin
   if MessageBox(frm1.handle,'Открыть новую модель?','Открытие модели',
                 MB_APPLMODAL or MB_ICONQUESTION or MB_YESNO)=idno then begin
    PopFunction;             
    exit;
   end;//of if
   closeMDL;
  end;//of if
  AddFileToMenuList(od_file.FileName,Sender);//добавить в список менюшных файлов
  SaveRecentFiles(Sender);        //записать список открытого
  pn_info.visible:=true;
  application.processmessages;
  IsShowTexError:=true;
  wglMakeCurrent(dc,hrc);
  glDeleteLists(0,255);
  for i:=0 to CountOfTextures-1 do
   if Textures[i].pImg<>nil then begin
    FreeMem(Textures[i].pImg);
    Textures[i].pImg:=nil;
   end;
  for i:=0 to CountOfMaterials-1 do if Materials[i].ListNum>0 then begin
   glDeleteTextures(1,@Materials[i].ListNum);
   Materials[i].ListNum:=0;
  end;//of if/for
  AnimEdMode:=1;
  iAnimEdMode:=AnimEdMode;        //для крэш-дампа
  ObjAnimate.ClearRestricts;
  //Открыть файл
  if length(od_file.FileName)<4 then OpenMDL(od_file.FileName)
                                else begin
  //Так, длина достаточна. Проверим формат:
   fext:=lowercase(copy(od_file.FileName,length(od_file.FileName)-3,4));
   if fext='.mdx' then OpenMDX(od_file.FileName)
   else begin
    if fext='.mdl' then OpenMDL(od_file.FileName)
    else begin
     if fext<>'.wmo' then begin
      OpenM2(od_file.FileName);//WoW-модель
      NormalizeWoWAnimations;      //привести в порядок анимации
      //изменить файл (для последующей записи)
      od_file.filename:=Copy(od_file.FileName,1,length(od_file.FileName)-3)
                        +'.mdx';
     end else begin               //wmo-модель
      stmp:=OpenWMO(od_file.FileName);
      if stmp<>'' then begin
       frm_warn.mm.lines.Text:=stmp;
       frm_warn.ShowModal;
      end;//of if
      //изменить файл (для последующей записи)
      od_file.filename:=Copy(od_file.FileName,1,length(od_file.FileName)-4)
                        +'.mdx';
      IsOptimize:=true;
     end;//of if
    end;//of if
   end;//of if(MDX/другое)
  end;//of if/else
//  RoundModel;//debug
  if IsWoW then begin
   frm_obj.MakeGeosetsList(-1); //сформировать иерархический список
   H1.Enabled:=true;
  end else H1.Enabled:=false;
  frm_obj.Hide;
//  WriteToLog('Файл '+od_file.FileName+' открылся');
  application.processmessages;
  for i:=0 to CountOfTextures-1 do Textures[i].pImg:=nil;
//  WriteToLog('Текстурные указатели обнулены');
  for i:=0 to CountOfMaterials-1 do Materials[i].ListNum:=0;
  pn_info.visible:=false;
  if CountOfGeosets=0 then begin PopFunction;exit;end;
  //Поставить в "сохранить"
  i:=length(od_file.FileName);
  while (od_file.FileName[i]<>'\') and (i>1) do dec(i);
  sd_file.InitialDir:=copy(od_file.FileName,1,i);
  CountOfDelObjs:=0;
  CurView.Reset;                 //сброс старых параметров вида
  CurView.Zoom:=0.1;
  IsModified:=false;             //пока модель не модифицирована
  sb_save.enabled:=false;
  StrlS1.enabled:=false;
  frm1.caption:='Редактор MDL-моделей: '+od_file.FileName;
  sd_file.FileName:=od_file.FileName;
  pn_view.Caption:='Перспектива';
  l_vcount.caption:='Всего вершин: '+
                    inttostr(Geosets[0].CountOfVertices);//!dbg
  l_vselect.caption:='Выделено: 0';
  CountOfUndo:=0;          //понятно, после загрузки что отменять?!
  CountOfNewUndo:=0;
  NewUndo:=nil;
  ResetBuffer;                    //сброс анимаций в буфере
  //Сбросить цвета поверхностей
  for i:=0 to CountOfGeosets-1 do begin
   Geosets[i].Color4f[1]:=1;
   Geosets[i].Color4f[2]:=1;
   Geosets[i].Color4f[3]:=1;
   Geosets[i].Color4f[4]:=1;
  end;//of for ii
  SetLength(Geoobjs,CountOfGeosets);
  glLightfv(GL_LIGHT0,GL_POSITION,@position);
  glLightfv(GL_LIGHT1,GL_POSITION,@position1);
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT,@amb);

  pn_zoom.visible:=false;
  pn_instr.visible:=true;
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   VertexCount:=0;HideVertexCount:=0;
   IsSelected:=false;
   VertexList:=nil;
  end;//of for j
  IsShowAll:=true;
  clb_geolist.enabled:=true;
  geoobjs[0].IsSelected:=true;
  l_triangles.caption:='Треугольников: '+inttostr(GetSumCountOfTriangles);
  FindCoordCenter;
  CurView.Reset;
  DrawVertices(dc,hrc);
  if N36.checked then
     for i:=0 to CountOfGeosets-1 do NormalizeTriangles(i);
  N9Click(Sender);                //прорисовка
  N26.checked:=false;             //не показывать нормали
  IsNormals:=false;               //не показывать нормали

  pb_redraw.tag:=1;
//  gluLookAt(64.466, 23.2254, 91.3755, 10.5232, 2.70627, 78.3585, 0,0,-1);

//  DrawVertices(dc,hrc);
  pb_redrawPaint(Sender);         //перерисовка

  //Проявляем недоступные ранее кнопки
  sb_save.enabled:=false;
  sb_cross.down:=true;InstrumStatus:=isSelect;
  CtrlA1.enabled:=true;
  N10.enabled:=true;CtrlZ1.enabled:=false;sb_undo.enabled:=false;
  N37.enabled:=true;
  N11.enabled:=true;
  N13.enabled:=true;
  N18.enabled:=true;
  StrlS1.enabled:=false;
  //Эмулируем cross
  pn_stat.visible:=false;
  Status.SimpleText:='Инструменты: кликните мышью по вершинам для их выделения';
  GLWorkArea.Cursor:=crDefault;
  pn_objs.visible:=true;
  label14.enabled:=true;cb_color.enabled:=true;cb_light.enabled:=true;
  cb_vertices.enabled:=true;
  sb_cross.enabled:=true;sb_zoom.enabled:=true;sb_rot.enabled:=true;
  sb_move.enabled:=true;
  sb_select.down:=true;
  InstrumStatus:=isSelect;
  CtrlA1.enabled:=true;
  sb_del.enabled:=false;
  sb_nsmooth.enabled:=false;
  sb_nrot.enabled:=false;
  sb_nrestore.enabled:=false;
  b_detach.Enabled:=false;
  sb_uncouple.enabled:=false;
  b_tex.enabled:=false;
  F21.enabled:=false;
  b_hide.enabled:=false;
  sb_imove.enabled:=false;
  sb_mirror.enabled:=false;
  N17.enabled:=false;
  N19.enabled:=false;
  CtrlC1.enabled:=false;
  sb_copy.enabled:=false;
  b_collapse.enabled:=false;
  sb_nsmooth.enabled:=false;
  b_weld.enabled:=false;
  b_extrude.enabled:=false;
  sb_deltr.enabled:=false;  
  sb_swap.enabled:=false;
  sb_triangle.enabled:=false;
  sb_izoom.enabled:=false;
  sb_irot.enabled:=false;
  pn_view.visible:=true;sb_instrum.visible:=true;
  //Устанавливаем ряд значений
  ed_x.text:='0';ed_y.text:='0';ed_z.text:='0';
  ed_zoom.text:='100';
  //Теперь работаем с объектами (поля выбора объектов)
  //Заполнить список объектов:
  olGeosets:='1';
  for i:=2 to CountOfGeosets do olGeosets:=olGeosets+#13#10+inttostr(i);
  clb_geolist.items.text:=olGeosets;
  for i:=0 to clb_geolist.Items.Count-1 do clb_geolist.Checked[i]:=false;
  clb_geolist.Checked[0]:=true;
  application.processmessages;
  cb_ShowAll.checked:=true;
 end else begin PopFunction;exit;end;//of if

 //Проверка режима редактирования
 if EditorMode=emAnims then F31Click(Sender);
 sb_zoomClick(sender);
 sb_crossClick(Sender);
 BuildPanels;
 if IsOptimize then begin
  N37Click(Sender);
 end;//of if
 PopFunction;
end;     

//при событии прорисовки
procedure Tfrm1.FormPaint(Sender: TObject);
begin
 pb_redrawPaint(Sender);         //перерисовка
end;

//Выполняет простое перестроение списков
//и перерисовку рабочей области
procedure TFrm1.RefreshWorkArea(Sender:TObject);
Var flgs:integer;
Begin
 if CountOfGeosets=0 then exit;
 PushFunction(7);
 //Проверить, нужно ли отображать вершины
 if cb_vertices.checked then flgs:=4 else flgs:=0;
 //Проверка типа перерисовки
 case ViewType of
  2:begin         //общий вид
{   if EditorMode=emVertex then begin
    FormPrimitives(GLWorkArea.ClientHeight);//сформировать список примитивов
    SortPrimitives(PrSorted1,PrLength1);//пересортировка
    SortPrimitives(PrSorted2,PrLength2);//пересортировка
    Make3DListFill(dc,hrc,flgs+1);      //создать 3D-список
   end else begin}
    AReFormPrimitives(GLWorkArea.ClientHeight);//сформировать список примитивов
    SortPrimitives(PrSorted1,PrLength1);//пересортировка
    SortPrimitives(PrSorted2,PrLength2);//пересортировка
    AMake3DListFill;       //создать 3D-список
{   end;//of if}
  end;//of 2
  1:AMake3DListFill{(dc,hrc,flgs)};  //создать 3D-список
  else begin
   DrawVertices(dc,hrc);
  end;
 end;//of case
 //прорисовка
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
End;

//при уничтожении формы
procedure Tfrm1.FormDestroy(Sender: TObject);
Var i:integer;
begin
 PushFunction(8);
 CloseMDL;                      //закрыть файл
 wglMakeCurrent(dc,hrc);
  glDeleteLists(0,255); //удаление списков
  for i:=0 to CountOfTextures-1 do
   if Textures[i].pImg<>nil then begin
    FreeMem(Textures[i].pImg);
    Textures[i].pImg:=nil;
   end;
 //Удаление списков материала:
 for i:=0 to CountOfMaterials-1 do
     if Materials[i].ListNum>0 then glDeleteTextures(1,@Materials[i].ListNum);

 //Удаление текстурных списков:
 if EditorMode=emAnims then
 for i:=0 to CountOfTextures-1 do
 with Textures[i] do if ListNum>0 then glDeleteTextures(1,@ListNum);

 wglMakeCurrent(0,0);   //освободить контекст
 wglDeleteContext(hrc); //удалить его
 DeleteObject(hBitmap);
 DeleteDC(pb_anim.tag);
 bExit:=true;
 PopFunction;
end;

procedure Tfrm1.sb_crossClick(Sender: TObject);
begin
 PushFunction(9);
 //Появится, только если что-то выделено.
 pn_instr.Visible:=true;
 pn_objs.visible:=true;
 //расчет проекций вершин
 CalcVertex2D(GLWorkArea.ClientHeight);//!dbg
 pn_stat.visible:=false;
 pn_zoom.visible:=false;
 Status.SimpleText:='Инструменты: кликните мышью по вершинам для их выделения';
 GLWorkArea.Cursor:=crDefault;
 PopFunction;
end;

procedure Tfrm1.sb_zoomClick(Sender: TObject);
begin
 PushFunction(10);
 pn_boneedit.visible:=false;
 pn_color.visible:=false;
 pn_seq.visible:=false;
 pn_instr.Visible:=false;
 pn_objs.visible:=false;
 pn_listbones.visible:=false;
 pn_vertcoords.visible:=false;
 pn_listbones.tag:=1;
 ed_zoom.text:=inttostr(round(CurView.zoom*100));
 pn_zoom.visible:=true;
 pn_stat.visible:=false;
 pn_workplane.visible:=false;
 pn_binstrum.visible:=false;
 pn_boneprop.visible:=false;
 pn_propobj.visible:=false;
 pn_contrprops.visible:=false;
 pn_spline.visible:=false;
 pn_atchprop.visible:=false;
 pn_pre2prop.visible:=false;
 status.SimpleText:='Двигайте мышь с зажатой левой кнопкой для масштабирования';
 GLWorkArea.Cursor:=crZoomCur;
 PopFunction;
end;

procedure EnableInstrums;
Begin with frm1 do begin
 PushFunction(11);
 if CountOfUndo=0 then begin
  sb_undo.enabled:=false;
  CtrlZ1.enabled:=false;
  sb_animundo.enabled:=false;
 end else begin
  sb_undo.enabled:=true;
  CtrlZ1.enabled:=true;
  sb_animundo.enabled:=true;
 end;//of if
 if (GetSumCountOfSelVertices>0) and (AnimEdMode=3) then begin
 
 end;//of if
 if GetSumCountOfSelVertices<2 then begin
  b_collapse.enabled:=false;
  sb_nsmooth.enabled:=false;
  b_weld.enabled:=false;
 end;//of if
 if GetSumCountOfSelVertices=3 then begin
  sb_triangle.enabled:=true;
 end else begin
  sb_triangle.enabled:=false;
 end;
 if GetSumCountOfSelVertices<3 then begin
  b_extrude.enabled:=false;
  sb_deltr.enabled:=false;
  sb_swap.enabled:=false;
 end;//of if
 if GetSumCountOfSelVertices=0 then begin
  sb_del.enabled:=false;
  sb_nrot.enabled:=false;
  sb_nrestore.enabled:=false;
  b_detach.enabled:=false;
  sb_uncouple.enabled:=false;
  b_tex.enabled:=false;
  F21.enabled:=false;
  b_hide.enabled:=false;
  sb_imove.enabled:=false;
  sb_mirror.enabled:=false;
  N17.enabled:=false;
  N19.enabled:=false;    
  CtrlC1.enabled:=false;
  sb_copy.enabled:=false;  
  b_collapse.enabled:=false;
  sb_nsmooth.enabled:=false;
  b_weld.enabled:=false;
  sb_irot.enabled:=false;
  sb_izoom.enabled:=false;
 end else begin
  if GetSumCountOfSelVertices=3 then begin
   sb_triangle.enabled:=true;
  end else begin
   sb_triangle.enabled:=false;
  end;
  if GetSumCountOfSelVertices>=3 then begin
   b_extrude.enabled:=true;
   sb_deltr.enabled:=true;   
   sb_swap.enabled:=true;
  end;//of if
  if GetSumCountOfSelVertices>=2 then begin
   b_collapse.enabled:=true;
   sb_nsmooth.enabled:=true;
   b_weld.enabled:=true;
  end;//of if
  sb_del.enabled:=true;
  sb_nrot.enabled:=true;
  if IsSmoothVerticesInSelection then sb_nrestore.enabled:=true
  else sb_nrestore.enabled:=false;
  if GetCountOfSelGeosets=1 then b_detach.enabled:=true
  else b_detach.enabled:=false;
  sb_uncouple.enabled:=true;  
  b_tex.enabled:=true;
  F21.enabled:=true;
  b_hide.enabled:=true;
  sb_imove.enabled:=true;
  sb_mirror.enabled:=true;
  if (GetSumCountOfSelVertices=1) and
      ExternalBuffer.IsActive then N17.enabled:=true;
  if GetSumCountOfSelVertices=1 then N19.enabled:=true;
  CtrlC1.enabled:=true;
  sb_copy.enabled:=true;
  sb_irot.enabled:=true;
  sb_izoom.enabled:=true;
 end;//of if
 l_vcount.caption:='Всего вершин: '+
                    inttostr(GetSumCountOfVertices);
 l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelVertices);
 label13.caption:='Выделено вершин: '+inttostr(GetSumCountOfSelVertices);
 if AnimEdMode<>1 then begin
  FillBonesList;
  EnableAttachInstrums;
 end;//of if
 l_vhide.caption:='Скрыто: '+inttostr(GetSumCountOfHideVertices);
 l_triangles.caption:='Треугольников: '+inttostr(GetSumCountOfTriangles);
 sb_save.enabled:=true;
 StrlS1.enabled:=true;
 PopFunction;
end;End;

procedure TestFullView;
Var flgs:integer;
Begin
  PushFunction(12);
  //Проверить, нужно ли отображать вершины
  if frm1.cb_vertices.checked then flgs:=4 else flgs:=0;
  //Теперь - проверка на общий вид
  if ViewType<>2 then begin PopFunction;exit;end;
{  if EditorMode=emVertex then begin
   ReFormPrimitives(frm1.GLWorkArea.ClientHeight);
   SortPrimitives(PrSorted1,PrLength1);//пересортировка
   SortPrimitives(PrSorted2,PrLength2);//пересортировка
   Make3DListFill(dc,hrc,flgs+1);      //создать 3D-список
  end else begin//of if (Общий Вид)}
   AReFormPrimitives(frm1.GLWorkArea.ClientHeight);
   SortPrimitives(PrSorted1,PrLength1);//пересортировка
   SortPrimitives(PrSorted2,PrLength2);//пересортировка
   AMake3DListFill;                    //создать 3D-список
{  end;}
  PopFunction;
End;
//проверяет к-ты: x-OldMouseX,y-OldMouseY.
//Возвращает приращение мировых к-т DeltaX,DeltaY,DeltaZ
procedure CheckXYZ(x,y:integer;IsShift:TShiftState);
Var Viewport:array[0..3] of GLfloat;
    mvMatrix,ProjMatrix:array[0..15] of GLdouble;
//    i:integer;
    wx,wy,wz,wx1,wy1,wz1,wx2,wy2,wz2,
    DeltaX1,DeltaX2{,DeltaY1,DeltaY2}:double;
Begin with frm1 do begin
 PushFunction(13);
 //1. Читаем матрицы
 glGetIntegerv(GL_VIEWPORT,@Viewport);
 glGetDoublev(GL_MODELVIEW_MATRIX,@mvMatrix);
 glGetDoublev(GL_PROJECTION_MATRIX,@ProjMatrix);
 gluUnProject(10,10,0.5,@mvMatrix,@ProjMatrix,@Viewport,wx,wy,wz);
  gluUnProject(20,10,0.5,@mvMatrix,@ProjMatrix,@Viewport,wx1,wy1,wz1);
  gluUnProject(10,20,0.5,@mvMatrix,@ProjMatrix,@Viewport,wx2,wy2,wz2);
 if rb_xy.checked then begin
  DeltaZ:=0;                      //ось Z не трогаем
  //x-координата: определяем вклад
  DeltaX1:=wx1-wx;DeltaX2:=wx2-wx;
  if abs(DeltaX1)>abs(DeltaX2) then begin //больший вклад от X
   DeltaX:=x-OldMouseX;if DeltaX1<0 then DeltaX:=-DeltaX;
   DeltaY:=OldMouseY-y;if (wy2-wy)>0 then DeltaY:=-DeltaY;
  end else begin
   DeltaX:=OldMouseY-y;if DeltaX2<0 then DeltaX:=-DeltaX;
   DeltaY:=x-OldMouseX;if (wy1-wy)>0 then DeltaY:=-DeltaY;
  end;//of if
 end;//of if

 if rb_xz.checked then begin
  DeltaY:=0;                      //ось Y не трогаем
  //x-координата: определяем вклад
  DeltaX1:=wz1-wz;DeltaX2:=wz2-wz;
  if abs(DeltaX1)<abs(DeltaX2) then begin //больший вклад от X
   DeltaX:=x-OldMouseX;if (wx1-wx)<0 then DeltaX:=-DeltaX;
   DeltaZ:=OldMouseY-y;if (wz2-wz)<0 then DeltaZ:=-DeltaZ;
  end else begin
   DeltaX:=OldMouseY-y;if (wx2-wx)<0 then DeltaX:=-DeltaX;
   DeltaZ:=x-OldMouseX;if (wz1-wz)<0 then DeltaZ:=-DeltaZ;
  end;//of if
 end;//of if

 if rb_yz.checked then begin
  DeltaX:=0;                      //ось X не трогаем
  //y-координата: определяем вклад
  DeltaX1:=wy1-wy;DeltaX2:=wy2-wy;
  if abs(DeltaX1)<abs(DeltaX2) then begin //больший вклад от X
   DeltaZ:=x-OldMouseX;if (wz1-wz)<0 then DeltaZ:=-DeltaZ;
   DeltaY:=OldMouseY-y;if (wy2-wy)>0 then DeltaY:=-DeltaY;
  end else begin
   DeltaZ:=OldMouseY-y;if (wz2-wz)<0 then DeltaZ:=-DeltaZ;
   DeltaY:=x-OldMouseX;if (wy1-wy)>0 then DeltaY:=-DeltaY;
  end;//of if
 end;//of if

 //Теперь - проверка, не нужно ли двигать вершины
 //только по осям.
 if ssShift in IsShift then begin//ограничим движение
  if rb_xy.checked then DeltaY:=0;
  if rb_xz.checked then DeltaX:=0;
  if rb_yz.checked then DeltaZ:=0;
 end;//of if
 PopFunction;
end;End;

procedure vMove(x,y:integer;IsShift:TShiftState);//перемещение объектов
Var i,j:integer;
Begin with frm1 do begin
 PushFunction(14);
 CheckXYZ(x,y,IsShift);           //проверка, по каким к-там двигаться.
 FindCoordCenter;
 GlobalX:=ccX;
 GlobalY:=ccY;
 GlobalZ:=ccZ;
 DeltaX:=DeltaX/CurView.Zoom;
 DeltaY:=DeltaY/CurView.Zoom;
 DeltaZ:=DeltaZ/CurView.Zoom;
 GlobalX:=GlobalX+DeltaX;GlobalY:=GlobalY+DeltaY;
 GlobalZ:=GlobalZ+DeltaZ;
 ed_ix.text:=floattostrf(GlobalX,ffFixed,10,5);
 ed_iy.text:=floattostrf(GlobalY,ffFixed,10,5);
 ed_iz.text:=floattostrf(GlobalZ,ffFixed,10,5);
 //2. Модификация координат выделенных вершин
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
  if not IsSelected then continue;
  for i:=0 to VertexCount-1 do begin
   Geosets[j].Vertices[VertexList[i]-1,1]:=
    Geosets[j].Vertices[VertexList[i]-1,1]+DeltaX;
   Geosets[j].Vertices[VertexList[i]-1,2]:=
    Geosets[j].Vertices[VertexList[i]-1,2]+DeltaY;
   Geosets[j].Vertices[VertexList[i]-1,3]:=
    Geosets[j].Vertices[VertexList[i]-1,3]+DeltaZ;
  end;//of for
 end;//of for j
 //3. Прорисовка вершин
{ if (ViewType=2) then TestFullView else begin
  DrawVertices(dc,hrc);
 end;//of if (FullView)
 glCallList(CurrentListNum);
 SwapBuffers(dc);}
 PopFunction;
end;End;

procedure vRotate(x,y:integer);//поворачивает вершины
Var az,tx,ty,dax,day,daz:Glfloat;i,j:integer;
Begin with frm1 do begin
 PushFunction(15);
 //для каждой вершины
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do begin
  if not IsSelected then continue;
  for i:=0 to Undo[CountOfUndo].status2-1 do begin    //обратный пересчет
   //1. Вычислить относительные к-ты поворачиваемых вершин
   Vertices[Undo[CountOfUndo].idata[i]-1,1]:=Undo[CountOfUndo].data1[i]-ccX;
   Vertices[Undo[CountOfUndo].idata[i]-1,2]:=Undo[CountOfUndo].data2[i]-ccY;
   Vertices[Undo[CountOfUndo].idata[i]-1,3]:=Undo[CountOfUndo].data3[i]-ccZ;
  end;//of for
 end;//of for j
 
 //2. Определение плоскости вращения
 WorkPlane.FindAngles(x,y,OldMouseX,OldMouseY,dax,day,daz);
 if rb_xy.checked then begin
  GlobalZ:=GlobalZ+daz;
  az:=GlobalZ*0.01745;      //угол поворота (радианы)
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to VertexCount-1 do begin //расчет новых к-т
    tx:=Geosets[j].vertices[VertexList[i]-1,1]*cos(az)+
     Geosets[j].vertices[VertexList[i]-1,2]*sin(az);
    ty:=Geosets[j].vertices[VertexList[i]-1,2]*cos(az)-
     Geosets[j].vertices[VertexList[i]-1,1]*sin(az);
    Geosets[j].vertices[VertexList[i]-1,1]:=tx;
    Geosets[j].vertices[VertexList[i]-1,2]:=ty;
   end;//of for
  end;//of for j
 end;//of if

 if rb_xz.checked then begin
  GlobalY:=GlobalY+day;
  az:=GlobalY*0.01745;      //угол поворота (радианы)
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to VertexCount-1 do begin //расчет новых к-т
    tx:=Geosets[j].vertices[VertexList[i]-1,1]*cos(az)+
     Geosets[j].vertices[VertexList[i]-1,3]*sin(az);
    ty:=Geosets[j].vertices[VertexList[i]-1,3]*cos(az)-
     Geosets[j].vertices[VertexList[i]-1,1]*sin(az);
    Geosets[j].vertices[VertexList[i]-1,1]:=tx;
    Geosets[j].vertices[VertexList[i]-1,3]:=ty;
   end;//of for
  end;//of for j
 end;//of if

 if rb_yz.checked then begin
  GlobalX:=GlobalX+dax;
  az:=GlobalX*0.01745;      //угол поворота (радианы)
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to VertexCount-1 do begin //расчет новых к-т
    tx:=Geosets[j].vertices[VertexList[i]-1,2]*cos(az)+
     Geosets[j].vertices[VertexList[i]-1,3]*sin(az);
    ty:=Geosets[j].vertices[VertexList[i]-1,3]*cos(az)-
     Geosets[j].vertices[VertexList[i]-1,2]*sin(az);
    Geosets[j].vertices[VertexList[i]-1,2]:=tx;
    Geosets[j].vertices[VertexList[i]-1,3]:=ty;
   end;//of for
  end;//of for j
 end;//of if
//=================Завершение==============================
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do begin
  if not IsSelected then continue;
  for i:=0 to VertexCount-1 do begin    //обратный пересчет
   //1. Вычислить относительные к-ты поворачиваемых вершин
   Vertices[VertexList[i]-1,1]:=Vertices[VertexList[i]-1,1]+ccX;
   Vertices[VertexList[i]-1,2]:=Vertices[VertexList[i]-1,2]+ccY;
   Vertices[VertexList[i]-1,3]:=Vertices[VertexList[i]-1,3]+ccZ;
  end;//of for
 end;//of for j
 ed_ix.text:=floattostrf(GlobalX,ffFixed,10,5);
 ed_iy.text:=floattostrf(GlobalY,ffFixed,10,5);
 ed_iz.text:=floattostrf(GlobalZ,ffFixed,10,5);
 PopFunction;
end;End;

procedure nRotate(x,y:integer);//поворачивает нормали
Var dax,day,daz:Glfloat;
Begin with frm1 do begin
 PushFunction(377);  
 //для каждой вершины

 //2. Определение плоскости вращения+собственно поворот
 WorkPlane.FindAngles(x,y,OldMouseX,OldMouseY,dax,day,daz);
 GlobalX:=GlobalX+dax;
 GlobalY:=GlobalY+day;
 GlobalZ:=GlobalZ+daz;
 NInstrum.Rotate(dax,day,daz);
 if ViewType=0 then ApplySmoothGroups;
// RefreshWorkArea(Sender);
//=================Завершение==============================
 ed_ix.text:=floattostrf(GlobalX,ffFixed,10,5);
 ed_iy.text:=floattostrf(GlobalY,ffFixed,10,5);
 ed_iz.text:=floattostrf(GlobalZ,ffFixed,10,5);
 PopFunction;
end;End;

procedure vZoom(zx,zy,zz:GLfloat);
Var i,j:integer;xc,yc,zc:GLfloat;
Begin with frm1 do begin
 PushFunction(16);
 //для каждой вершины
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do begin
  if not IsSelected then continue;
  for i:=0 to Undo[CountOfUndo].Status2-1 do begin    //обратный пересчет
   //1. Вычислить относительные к-ты поворачиваемых вершин
   Vertices[Undo[CountOfUndo].idata[i]-1,1]:=Undo[CountOfUndo].data1[i]-ccX;
   Vertices[Undo[CountOfUndo].idata[i]-1,2]:=Undo[CountOfUndo].data2[i]-ccY;
   Vertices[Undo[CountOfUndo].idata[i]-1,3]:=Undo[CountOfUndo].data3[i]-ccZ;
  end;//of for
 end;//of for j

 //Масштабные множители
 GlobalX:=GlobalX+zx;
 GlobalY:=GlobalY+zy;GlobalZ:=GlobalZ+zz;
 if GlobalX<0 then GlobalX:=0;
 if GlobalY<0 then GlobalY:=0;
 if GlobalZ<0 then GlobalZ:=0;
 xc:=GlobalX/100;
 yc:=GlobalY/100;
 zc:=GlobalZ/100; //множитель
// if ccx<-100 then MessageBox(0,'szgd','sdg',0);
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do begin
  if not IsSelected then continue;
  for i:=0 to VertexCount-1 do begin
   vertices[VertexList[i]-1,1]:=vertices[VertexList[i]-1,1]*xc;
   vertices[VertexList[i]-1,2]:=vertices[VertexList[i]-1,2]*yc;
   vertices[VertexList[i]-1,3]:=vertices[VertexList[i]-1,3]*zc;
  end;//of for i
 end;//of for j
 //Обратный пересчет
//=================Завершение==============================
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do begin
  if not IsSelected then continue;
  for i:=0 to VertexCount-1 do begin    //обратный пересчет
   //1. Вычислить относительные к-ты поворачиваемых вершин
   Vertices[VertexList[i]-1,1]:=Vertices[VertexList[i]-1,1]+ccX;
   Vertices[VertexList[i]-1,2]:=Vertices[VertexList[i]-1,2]+ccY;
   Vertices[VertexList[i]-1,3]:=Vertices[VertexList[i]-1,3]+ccZ;
  end;//of for
 end;//of for j
 ed_ix.text:=floattostrf(GlobalX,ffFixed,10,5);
 ed_iy.text:=floattostrf(GlobalY,ffFixed,10,5);
 ed_iz.text:=floattostrf(GlobalZ,ffFixed,10,5);
 //Прорисовка вершин
{ if ViewType=2 then TestFullView else DrawVertices(dc,hrc);
 glCallList(CurrentListNum);
 SwapBuffers(dc);}
 PopFunction;
end;End;

//Группа преобразований кости
procedure bBeginRot(Sender:TObject;x,y:integer);//начать вращение
Var t,c,b:GLFloat;
Begin
 if IsPlay then exit;
 PushFunction(17);
 //1. Сохраним для отмены
 ObjAnimate.SaveUndo;
 frm1.GraphSaveUndo;
 Stamps.Add(CurFrame);

 //2. Получим тангенсы (если нужно)
 if SplinePanel.IsVisible then begin
  SplinePanel.GetTCB(t,c,b);
  ObjAnimate.SetTCB(t,c,b);
  ObjAnimate.SplineUsed:=true;
 end else ObjAnimate.SplineUsed:=false;

 //3. Сохранение начальной точки для поворота
 WorkPlane.PrepareForRotation(x,y);
 GlobalX:=0;
 GlobalY:=0;
 GlobalZ:=0; 
 frm1.ed_bonex.text:='0';
 frm1.ed_boney.text:='0';
 frm1.ed_bonez.text:='0';
 frm1.pb_animPaint(Sender);
 frm1.ed_fnum.Font.Color:=clBlue;
 PopFunction;
End;

procedure TFrm1.bBeginTrans(Sender:TObject);
Var t,c,b:GLFloat;
Begin
 if IsPlay then exit;
 PushFunction(18);
 //1. Сохранение для отмены (сложное)
 ObjAnimate.SaveUndo;               //сохранение для отмены
 frm1.GraphSaveUndo;
 
{ frm1.sb_animundo.enabled:=true;
 frm1.CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;}
 Stamps.Add(CurFrame);            //добавить в список КК
 if SplinePanel.IsVisible then begin
  SplinePanel.GetTCB(t,c,b);
  ObjAnimate.SetTCB(t,c,b);
  ObjAnimate.SplineUsed:=true;
 end else ObjAnimate.SplineUsed:=false;
 PopFunction;
End;

//вместо него используется bBeginTrans, т.к. они
//полностью идентичны (по крайней мере, пока).
{procedure bBeginZoom(Sender:TObject);//начало масштабирования
Var it:TContItem;
    num,i:integer;
    t,c,b:GLFloat;
Begin
 //1. Сохранение для отмены (сложное)
 ObjAnimate.SaveUndo;               //сохранение для отмены

 frm1.sb_animundo.enabled:=true;
 frm1.CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;
 Stamps.Add(CurFrame);            //добавить в список КК
 if SplinePanel.IsVisible then begin
  SplinePanel.GetTCB(t,c,b);
  ObjAnimate.SetTCB(t,c,b);
  ObjAnimate.SplineUsed:=true;
 end else ObjAnimate.SplineUsed:=false;
End;
end;}

//Вспомогательная: вычисление определителя матрицы поворота
function GetDeterminant(m:TRotMatrix):GLfloat;
Begin
 GetDeterminant:=m[0,0]*m[1,1]*m[2,2]+m[0,1]*m[1,2]*m[2,0]+
                 m[0,2]*m[1,0]*m[2,1]-m[0,2]*m[1,1]*m[2,0]-
                 m[0,1]*m[1,0]*m[2,2]-m[0,0]*m[1,2]*m[2,1];
End;

//Вращение кости
procedure bRot(dax,day,daz:GLFloat);      //осуществить вращение
Begin
 if IsPlay then exit;
 PushFunction(19);
 //не забудем перевести в радианы!
 ObjAnimate.Rotate(dax*0.01745329,day*0.01745329,daz*0.01745329);
 frm1.DrawFrame(CurFrame);        //перечертить
 GlobalX:=GlobalX+dax;
 GlobalY:=GlobalY+day;
 GlobalZ:=GlobalZ+daz;
 frm1.ed_bonex.text:=floattostrf(GlobalX,ffFixed,10,2);
 frm1.ed_boney.text:=floattostrf(GlobalY,ffFixed,10,2);
 frm1.ed_bonez.text:=floattostrf(GlobalZ,ffFixed,10,2);
 PopFunction;
End;

procedure bTrans(x,y:integer;IsShift:TShiftState);//движение (перенос) кости
Begin
 if IsPlay then exit;
 PushFunction(20);
 //1. Вычислим новые координаты кости
 with frm1 do begin
 if rb_bxy.checked then rb_xy.checked:=true;
 if rb_bxz.checked then rb_xz.checked:=true;
 if rb_byz.checked then rb_yz.checked:=true;
 end;//of with
 CheckXYZ(x,y,IsShift);           //проверка, по каким к-там двигаться.
 DeltaX:=DeltaX/CurView.Zoom;
 DeltaY:=DeltaY/CurView.Zoom;
 DeltaZ:=DeltaZ/CurView.Zoom;
 ObjAnimate.Move(DeltaX,DeltaY,DeltaZ);
 frm1.DrawFrame(CurFrame);        //перечертить
 PopFunction;
End;

procedure bZoom(dZoom:integer;IsShift:TShiftState);//масштаб кости
Begin
 if IsPlay then exit;
 PushFunction(21);
 if ssShift in IsShift then begin //по одной оси
  if frm1.rb_xy.checked then GlobalX:=GlobalX+dZoom
  else if frm1.rb_xz.checked then GlobalZ:=GlobalZ+dZoom
  else GlobalY:=GlobalY+dZoom;
 end else begin
  GlobalX:=GlobalX+dZoom;
  GlobalY:=GlobalY+dZoom;
  GlobalZ:=GlobalZ+dZoom;
 end;//of if

 if GlobalX<-5000 then GlobalX:=-5000;
 if GlobalY<-5000 then GlobalY:=-5000;
 if GlobalZ<-5000 then GlobalZ:=-5000;
 if GlobalX>5000 then GlobalX:=5000;
 if GlobalY>5000 then GlobalY:=5000;
 if GlobalZ>5000 then GlobalZ:=5000;
 ObjAnimate.Scale(0.01*GlobalX,0.01*GlobalY,0.01*GlobalZ);
 frm1.DrawFrame(CurFrame);        //перечертить
 frm1.ed_bonex.text:=floattostrf(GlobalX,ffFixed,10,2);
 frm1.ed_boney.text:=floattostrf(GlobalY,ffFixed,10,2);
 frm1.ed_bonez.text:=floattostrf(GlobalZ,ffFixed,10,2);
 PopFunction;
End;

//Начать премещение кости (изменение PivotPoint)
procedure TFrm1.bBeginMove(Sender:TObject);
Begin
 if IsPlay then exit;
 PushFunction(22);
 //Сохранить для отмены
 AnimSaveUndo(uPivotChange,0);
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;
 StrlS1.enabled:=true;}
 PopFunction;
End;

//Мышь вниз, что-то происходит
procedure Tfrm1.GLWorkAreaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if CountOfGeosets=0 then exit;
 PushFunction(23);
 if Button=mbRight then begin   //нажата правая кнопка
  IsLeftMouseDown:=true;          //обозначить это
  ClickX:=x;ClickY:=y;OldMouseX:=x;OldMouseY:=y;
  PopFunction;
  exit;
 end;//of if
 IsShift:=ssShift in Shift;
 if (not IsMouseDown) and not (ssAlt in Shift) then begin
  if sb_irot.down or sb_nrot.down then begin
   GlobalX:=0;GlobalY:=0;GlobalZ:=0; //сбросить
  end;//of if
  if sb_izoom.down then begin
   GlobalX:=100;GlobalY:=100;GlobalZ:=100;
  end;//of if
  if sb_animcross.down then begin
   if AnimEdMode=0 then begin
    if sb_bonemove.down then bBeginMove(Sender);
   end else begin//of if
    if sb_bonerot.down then bBeginRot(Sender,x,y);//начать вращение кости
    if sb_bonemove.down or sb_bonescale.down then bBeginTrans(Sender);
   end;
  end;//of if (animcross_down)
  FindCoordCenter; //найти центр к-т
  ClickX:=x;ClickY:=y;      //позиция клика
  if (sb_cross.down) and
     (sb_imove.down or sb_irot.down or
      sb_izoom.down) then begin
   SaveUndo(uVertexTrans);
   if sb_irot.down then WorkPlane.PrepareForRotation(x,y);
   frm1.StrlS1.enabled:=true;
   frm1.sb_save.enabled:=true;
  end;//of if
  if sb_nrot.down then begin      //вращение нормалей
   SaveUndo(uSmoothGroups);
   frm1.StrlS1.enabled:=true;
   frm1.sb_save.enabled:=true;
   WorkPlane.PrepareForRotation(x,y);
   sb_nrestore.enabled:=true;
  end;//of if
 end;//of if
 IsMouseDown:=true; //если какой-то инструмент
 OldMouseX:=x;OldMouseY:=y;//запомнить к-ты курсора
 if ssAlt in Shift then begin ClickX:=x;ClickY:=y;end;
 PopFunction;
end;

//Вспомогательные:
//проверяет, выделена ли вершина и:
//Ctrl/Shift не нажаты - инвертирует ее выделение
//Shift нажата - добавляет к выд.
//Ctrl нажата - убирает из выд.
procedure DoSelect(geoID,vnum:integer;act:TShiftState);
Var i,j:integer;
Begin
 PushFunction(24);
 //При определенном значении флага act очистить список выделенного
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do
  if (act=[]) and IsSelected then begin
   VertexList:=nil;
   VertexCount:=0;
 end;//of if/with/for
 //ищем нужную вершину
 with geoobjs[geoID] do begin
  for i:=0 to VertexCount-1 do if VertexList[i]=vnum then begin//вершина выделена
   if ssShift in act then begin PopFunction;exit;end; //вершина уже в списке
   VertexList[i]:=VertexList[VertexCount-1];
   dec(VertexCount);
   SetLength(VertexList,VertexCount);//убрать из выделения
   PopFunction;
   exit;                             //готово
  end;//of if/for
  //не выделена!
  if ssCtrl in act then begin PopFunction;exit;end; //выйти, вершины уже нет
  //не выделять скрытые
  if IsVertexHide(geoID,vnum) then begin PopFunction;exit;end;
  inc(VertexCount);    //теперь вершин выделено на 1 больше
  SetLength(VertexList,VertexCount);//увеличить список
  VertexList[VertexCount-1]:=vNum;
 end;//of with
 PopFunction;
End;
//Используя список выделенных вершин,
//находит координаты центра выделения
//путем усреднения координат выделенных вершин
procedure SetCoordCenter;
Var i,j,SumCount:integer;MidX,MidY,MidZ:GLfloat;
Begin with frm1 do begin
 PushFunction(25);
 MidX:=0;MidY:=0;MidZ:=0;
 SumCount:=GetSumCountOfSelVertices;
 if SumCount=0 then begin      //нет вершин
  ed_ix.text:='';ed_iy.text:='';ed_iz.text:='';
  PopFunction;
  exit;
 end;//of if
 for j:=0 to CountOfGeosets-1 do if geoobjs[j].IsSelected then
 with geoobjs[j],geosets[j] do
 for i:=0 to VertexCount-1 do begin
  MidX:=MidX+Vertices[VertexList[i]-1,1];
  MidY:=MidY+Vertices[VertexList[i]-1,2];
  MidZ:=MidZ+Vertices[VertexList[i]-1,3];
 end;//of for
 MidX:=MidX/SumCount;MidY:=MidY/SumCount;
 MidZ:=MidZ/SumCount;
 ed_ix.text:=floattostrf(MidX,ffFixed,5,5);
 ed_iy.text:=floattostrf(MidY,ffFixed,5,5);
 ed_iz.text:=floattostrf(MidZ,ffFixed,5,5);
 PopFunction;
end;End;

//Пытается выделить самый верхний треугольник,
//в который попадает вершина (x,y).
//Если это ей удаётся, вызывается SaveUndo(uSelect)
//выделяется треугольник и возвращается true.
function MakeTriangleSelection(x,y:integer;act:TShiftState):boolean;
Var i,j,NumFound,GeoFound:integer;zMin,z:GlFloat;
    v,vt1,vt2,vt3:TVertex;
Begin
 PushFunction(26);
 Result:=false;v[1]:=x;v[2]:=y;
 zMin:=1e6;NumFound:=-1;GeoFound:=-1; 
 for j:=0 to CountOfGeosets-1 do with Geosets[j],GeoObjs[j] do begin
  if not IsSelected then continue;
  //Цикл поиска верхнего теугольника
  i:=0;
  repeat
   z:=0.333333*(Vertices2D[Faces[0,i]].z+Vertices2D[Faces[0,i+1]].z+
      Vertices2D[Faces[0,i+2]].z);
   vt1[1]:=Vertices2D[Faces[0,i]].x;
   vt1[2]:=Vertices2D[Faces[0,i]].y;
   vt2[1]:=Vertices2D[Faces[0,i+1]].x;
   vt2[2]:=Vertices2D[Faces[0,i+1]].y;
   vt3[1]:=Vertices2D[Faces[0,i+2]].x;
   vt3[2]:=Vertices2D[Faces[0,i+2]].y;
   if (zMin>z) and IsVertexInTriangle(v,vt1,vt2,vt3) then begin
    NumFound:=i;GeoFound:=j;
    zMin:=z;Result:=true;
   end;//of if
   i:=i+3;                        //к следующему треугольнику
  until i>High(Faces[0]);
 end;//of for j

 //если что-либо найдено, выделим
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;
 if Result then with Geosets[GeoFound] do begin
  SaveUndo(uSelect);
  if act=[] then begin
   for i:=0 to CountOfGeosets-1 do begin
    GeoObjs[i].VertexCount:=0;
    GeoObjs[i].VertexList:=nil;
   end;//of for
   act:=[ssShift];
  end;//of if
  DoSelect(GeoFound,Faces[0,NumFound]+1,act);
  DoSelect(GeoFound,Faces[0,NumFound+1]+1,act);
  DoSelect(GeoFound,Faces[0,NumFound+2]+1,act);
 end;//of if
 PopFunction;
End;
//отпущена клавиша мыши
procedure Tfrm1.GLWorkAreaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var fDelta,fDelta2:GLDouble;
    NumFound,GeoFound,i,j,len:integer;
    MinX,MinY,MaxX,MaxY:integer;
    lst:TFace;
Const BN_AREA=10;
begin
 if CountOfGeosets=0 then exit;
 PushFunction(27);
 pn_View.SetFocus;
 if Button=mbMiddle then begin
  if EditorMode=emVertex then begin
   if not sb_rot.down then begin
    sb_rot.down:=true;
    sb_rotClick(Sender);
   end else begin     
    sb_cross.down:=true;
    sb_crossClick(Sender);
   end;//of if
  end else begin
   if not sb_rot.down then begin
    sb_rot.down:=true;
    sb_rotClick(Sender);
   end else begin
    sb_animcross.down:=true;
    sb_animcrossClick(Sender);
   end;//of if
  end;
  IsMouseDown:=false;
  PopFunction;
  exit;
 end;//of if
 if button=mbRight then begin
  IsLeftMouseDown:=false;
  PopFunction;
  exit;
 end;//of if
 if ssAlt in Shift then begin
  if sb_animcross.visible then begin
   sb_animcross.down:=true;
   sb_animcrossClick(sender);
  end else begin
   sb_cross.down:=true;
   sb_crossClick(Sender);
  end;//of if
  IsArea:=false;
  IsMouseDown:=false;
  ClickX:=x;ClickY:=y;
  OldMouseX:=x;OldMouseY:=y;
  PopFunction;
  Exit;
 end;//of if
 if (InstrumStatus=isZoom) {or (InstrumStatus=isBoneScaling)} then begin
  ed_ix.text:='100';ed_iy.text:='100';ed_iz.text:='100';
  GlobalX:=0;GlobalY:=0;GlobalZ:=0;
 end;//of if
 if (InstrumStatus=isRotate) or (InstrumStatus=isBoneRot) then begin
  ed_ix.text:='0';ed_iy.text:='0';ed_iz.text:='0';
  GlobalX:=0;GlobalY:=0;GlobalZ:=0;
 end;//of if
 IsMouseDown:=false;//клавиша отпущена
 fDelta2:=100;NumFound:=0;GeoFound:=0;
 //---------------------------------------------------------
 //Выделение объекта
 if (AnimEdMode<>1) and sb_selbone.down and sb_animcross.down and
    (not IsArea) then begin
  CalcObjs2D(GLWorkArea.ClientHeight); //рассчитать координаты объектов

  //Проверка: не включен ли режим множественного выделения
  if SelObj.IsSelected and SelObj.IsMultiSelect then begin
   SelObj.CountOfCompObjs:=0;
   MakeCompetitorObjsList(x,y);   //строить список подкурсорных объектов
   if SelObj.CountOfCompObjs=0 then begin PopFunction;exit;end; //таковых нет
   //Копируем список уже выделенного
   len:=SelObj.CountOfSelObjs;
   SetLength(lst,len);
   for i:=0 to len-1 do lst[i]:=SelObj.SelObjs[i];
   //Итак, под курсором есть объекты. Смотрим, что с ними делать
   if ssShift in Shift then begin //добавить к уже выделенному
    AddTFace(SelObj.CompetitorObjs,lst,SelObj.CountOfCompObjs,len);
    GraphMultiSelectObject(lst,length(lst)); //выделить
    PopFunction;
    exit;
   end;//of if

   if ssCtrl in Shift then begin
    SubTFace(SelObj.CompetitorObjs,lst,SelObj.CountOfCompObjs,len);
    GraphMultiSelectObject(lst,length(lst)); //выделить
    PopFunction;
    exit;
   end;//of if

   //И, наконец, простое замещение
   GraphMultiSelectObject(SelObj.CompetitorObjs,SelObj.CountOfCompObjs);
   PopFunction;
   exit;                          //выход
  end;//of if

  //Проверка: не нужно ли просто выделить следующий
  //"подкурсорный" объект
  if SelObj.IsSelected and (SelObj.CountOfCompObjs<>0) and (SelObj.IDInComps>=0)
  then begin
   for i:=0 to CountOfObjs do if (Objs2D[i].id=SelObj.b.ObjectID)
   and ((abs(Objs2D[i].x-x)+abs(Objs2D[i].y-y))<BN_AREA) then begin
    //Выделить следующий (по цепочке) объект
    inc(SelObj.IDInComps);
    if SelObj.IDInComps>SelObj.CountOfCompObjs-1 then SelObj.IDInComps:=0;
    //собственно выделение
    GraphSelectObject(SelObj.CompetitorObjs[SelObj.IDInComps]);
    frm_obj.MakeObjectsList(SelObj.CompetitorObjs[SelObj.IDInComps],
                            SelObj.CompetitorObjs[SelObj.IDInComps]);
    //выход
    PopFunction;
    exit;
   end;//of if/for
  end;//of if (объект находится в цепочке выделения)

  //Объект не в цепочке. Ищем ближайшие:
//  SelObj.IsSelected:=false;       //для начала снимаем выделение
  SelObj.CountOfCompObjs:=0;
  MakeCompetitorObjsList(x,y);   //строить список подкурсорных объектов
  if SelObj.CountOfCompObjs<>0 then begin
   i:=SelObj.IDInComps;
   GraphSelectObject(SelObj.CompetitorObjs[0]);//выделить объект
   frm_obj.MakeObjectsList(SelObj.CompetitorObjs[0],SelObj.CompetitorObjs[0]);
   if SelObj.CountOfCompObjs=1 then SelObj.IDInComps:=-1;
   if SelObj.CountOfCompObjs>1 then SelObj.IDInComps:=i;
   PopFunction;
   exit;
  end;//of if
 end;//of if (выделение объекта)
 //---------------------------------------------------------
 //Проверка: нужно ли производить выделение объекта
 if ((InstrumStatus=isSelect) and
     ((sb_cross.down) or (sb_animcross.down and sb_selbone.down))) and
     (not IsArea) and (not cb_multiselect.checked) then begin//выделение нужно
  //Искать ближайшую вершину
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do if IsSelected then begin
   for i:=0 to Length(Vertices2D)-1 do begin
   fDelta:=(abs(Vertices2D[i].x-x)+abs(Vertices2D[i].y-y));
    if fDelta<5 then begin
     //Подходящая вершина найдена
     if (fDelta-Vertices2D[i].z*5)<fDelta2 then begin
      GeoFound:=j;
      NumFound:=i+1;fDelta2:=fDelta-Vertices2D[i].z*5;
     end;//of if
    end;//of if
   end;//of for
  end;//of for j
  if fDelta2=100 then begin
   //Попытаемся выделить целый треугольник.
   //Эта функция сама вызывает SaveUndo
   if (not MakeTriangleSelection(x,y,Shift)) and
      (not (ssShift in Shift)) and (not (ssCtrl in Shift)) then begin
    frm1.StrlS1.enabled:=true;
    frm1.sb_save.enabled:=true;
    SaveUndo(uSelect);
    for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do VertexCount:=0;
   end;//ничего не найдено
  end else begin//of if
   //Есть, нашли! Добавим в список выделенных (или уберем)
   SaveUndo(uSelect);
   DoSelect(GeoFound,NumFound,Shift);
  end;//of if/else
  CtrlZ1.enabled:=true;sb_undo.enabled:=true;
  sb_animundo.enabled:=true;
  frm1.StrlS1.enabled:=true;
  frm1.sb_save.enabled:=true;
  l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelVertices);
  label13.caption:='Выделено вершин: '+inttostr(GetSumCountOfSelVertices);
  EnableInstrums; //появить инструменты/спрятать их
  //Теперь перечертим картинку
  FindCoordCenter;
  RefreshWorkArea(Sender);
  SetCoordCenter;
  PopFunction;
  exit;                           //выйти
 end;//of if
//---------------------------------------------------------
  //Выделение всех вершин в области
 if (InstrumStatus=isSelect) and
    (sb_cross.down or sb_selbone.down) and IsArea {and
    (not cb_multiselect.checked)} then begin
  IsArea:=false;                  //сбросить область
  //1. Найдем максимум/минимум координат
  MinX:=Min(x,ClickX);MinY:=Min(y,ClickY);
  MaxX:=Max(x,ClickX);MaxY:=Max(y,ClickY);
  SaveUndo(uSelect);
  //2. Очистка списка выделения
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do
  if (Shift=[]) and IsSelected then begin
   VertexList:=nil;
   VertexCount:=0;
  end;//of if
  //3. Поиск вершин, попавших в область
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to Length(Vertices2D)-1 do
    if (round(Vertices2D[i].x)>=MinX) and
       (round(Vertices2D[i].x)<=MaxX) and
       (round(Vertices2D[i].y)<=MaxY) and
       (round(Vertices2D[i].y)>=MinY) then begin
    DoSelect(j,i+1,Shift+[ssAlt]);CtrlZ1.enabled:=true;sb_undo.enabled:=true;
    frm1.StrlS1.enabled:=true;
    frm1.sb_save.enabled:=true;
   end;//of if/for
  end;//of for j
  //Перерисовать
  FindCoordCenter;
  RefreshWorkArea(Sender);
  l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelVertices);
  EnableInstrums;
  SetCoordCenter;
  PopFunction;
  exit;                           //выйти
 end;//of if

 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;

//Вспомогательная: возвращает расстояние от точки (x,y)
//до прямой, заданной x1,y1,x2,x2
function GetDistance(x,y,x1,y1,x2,y2:GLFloat):GLFloat;
Var a,c:GLFloat;
Begin
 //1. Найдём уравнение прямой.
 if (x2-x1)=0 then A:=1e7
 else A:=(y2-y1)/(x1-x2);
 C:=-A*x1-y1;
 //2. Найдём расстояние от точки до прямой
 if (A*A+1)=0 then begin
  Result:=0;
  exit;
 end;//of if
 Result:=abs((A*x+y+C)/sqrt(A*A+1));
End;

//Вспомогательная: возвращает угол поворота вектора,
//заданного (vx,vy)
function AngleOfVector(vx,vy:single):single;
Var len,a:single;
Begin
 len:=sqrt(vx*vx+vy*vy);
 if len<1e-6 then len:=1;
 vx:=vx/len;

 a:=arccos(vx);
 if vy<=0 then a:=2*Pi-a;
 Result:=a;
End;

procedure bMove(x,y:integer;IsShift:TShiftState);//перемещение объекта
Var i:integer;
Begin with frm1 do begin
 PushFunction(28);
 CheckXYZ(x,y,IsShift);           //проверка, по каким к-там двигаться.
 FindCoordCenter;
 GlobalX:=ccX;
 GlobalY:=ccY;
 GlobalZ:=ccZ;
 DeltaX:=DeltaX/CurView.Zoom;
 DeltaY:=DeltaY/CurView.Zoom;
 DeltaZ:=DeltaZ/CurView.Zoom;
 GlobalX:=GlobalX+DeltaX;GlobalY:=GlobalY+DeltaY;
 GlobalZ:=GlobalZ+DeltaZ;
 ed_bonex.text:=floattostrf(GlobalX,ffFixed,10,5);
 ed_boney.text:=floattostrf(GlobalY,ffFixed,10,5);
 ed_bonez.text:=floattostrf(GlobalZ,ffFixed,10,5);
 //2. Модификация центра выделенных объектов
 if SelObj.IsMultiSelect then for i:=0 to SelObj.CountOfSelObjs-1 do begin
  PivotPoints[SelObj.SelObjs[i],1]:=PivotPoints[SelObj.SelObjs[i],1]+DeltaX;
  PivotPoints[SelObj.SelObjs[i],2]:=PivotPoints[SelObj.SelObjs[i],2]+DeltaY;
  PivotPoints[SelObj.SelObjs[i],3]:=PivotPoints[SelObj.SelObjs[i],3]+DeltaZ;
 end else begin
  PivotPoints[SelObj.b.ObjectID,1]:=PivotPoints[SelObj.b.ObjectID,1]+DeltaX;
  PivotPoints[SelObj.b.ObjectID,2]:=PivotPoints[SelObj.b.ObjectID,2]+DeltaY;
  PivotPoints[SelObj.b.ObjectID,3]:=PivotPoints[SelObj.b.ObjectID,3]+DeltaZ;
 end;//of if
 PopFunction;
end;End;


//дижется мышь
procedure Tfrm1.GLWorkAreaMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var hBrush,flgs:integer;//ts1,ts2,ts3,ts4:cardinal;
    UseRefresh:boolean;
    dax,day,daz:GLFloat;
begin
 if CountOfGeosets=0 then exit;
 PushFunction(29);
 
 //если мышь не нажата:
 if ((not IsMouseDown) and (not IsLeftMouseDown)) and
 (sb_cross.down or (sb_animcross.down and (AnimEdMode<>1) and (not IsPlay)))
 then begin
  if (InstrumStatus=isRotate) or (InstrumStatus=isBoneRot) or
     (InstrumStatus=isNormalRot)
  then WorkPlane.FindRot(x,y)
  else WorkPlane.Find(x,y,Shift);
  PopFunction;
  exit;
 end;//of if

 //Проверка на прокрутку колёсика
 if (not (ssRight in Shift)) and (not (ssLeft in Shift))
     and (not IsWheel) then begin PopFunction;exit;end;

 //Проверка на движение с зажатым Alt.
 if (ssAlt in Shift) and (not sb_rot.down) then begin
  sb_rot.down:=true;
  GLWorkAreaMouseMove(Sender,[ssShift,ssLeft,ssRight,ssMiddle,ssDouble]*Shift,x,y);
  sb_cross.down:=true;
  sb_animcross.down:=true;
  PopFunction;
  Exit;
 end;//of if

 //3. Смещение (перенос)
 if (not IsWheel) and ((sb_move.down) or IsLeftMouseDown) then begin
  CurView.Translaton(x-OldMouseX,OldMouseY-y); //собственно смещение
  if not IsPlay then glCallList(CurrentListNum);//!dbg
   //расчет проекций вершин
  if IsLeftMouseDown then CalcVertex2D(GLWorkArea.Clientheight);
  if IsLeftMouseDown and (AnimEdMode<>1) then CalcObjs2D(GLWorkArea.ClientHeight);
  if not IsPlay then SwapBuffers(dc);
  OldMouseY:=y;OldMouseX:=x;
  ed_x.text:=inttostr(round(CurView.tx));
  ed_y.text:=inttostr(round(CurView.ty));
  PopFunction;
  exit;                           //выход
 end;//of if

 if (sb_zoom.down) or IsWheel then begin    //масштабирование
  CurView.Zooming(OldMouseY-y);
  OldMouseY:=y;OldMouseX:=x;
  if (AnimEdMode=1) and (not IsXYZ) then glCallList(CurrentListNum)  //вывод
  else begin
   RefreshWorkArea(Sender);
  end;//of if
  //!err
  if IsWheel then CalcVertex2D(GLWorkArea.Clientheight);
  if IsWheel and (AnimEdMode<>1) then CalcObjs2D(GLWorkArea.ClientHeight);
  SwapBuffers(dc);                //модели
  ed_zoom.text:=inttostr(round(CurView.zoom*100));//вывод
  PopFunction;
  exit;                           //дальше не идем
 end;//of if

 //2. Поворот
 if sb_rot.down and IsMouseDown then begin
  if IsShift then CurView.Rotation(OldMouseY-y,x-OldMouseX,0)
  else CurView.Rotation(OldMouseY-y,0,OldMouseX-x);
  //Теперь - проверка на общий вид
  if not IsPlay then begin
   if ViewType=2 then begin
    if EditorMode=emVertex then begin
     AReFormPrimitives(GLWorkArea.ClientHeight);
     SortPrimitives(PrSorted1,PrLength1);//пересортировка
     SortPrimitives(PrSorted2,PrLength2);//пересортировка
     //Проверить, нужно ли отображать вершины
     if cb_vertices.checked then flgs:=4 else flgs:=0;
     AMake3DListFill{(dc,hrc,flgs+1)};      //создать 3D-список
    end else begin
     AReFormPrimitives(frm1.GLWorkArea.ClientHeight);
     SortPrimitives(PrSorted1,PrLength1);//пересортировка
     SortPrimitives(PrSorted2,PrLength2);//пересортировка
     AMake3DListFill;                    //создать 3D-список
    end;
   end;//of if (Общий Вид)
   glCallList(CurrentListNum);//!dbg
   SwapBuffers(dc);
  end;//of if
  OldMouseY:=y;OldMouseX:=x;
  ed_x.text:=inttostr(round(CurView.ax));//вывод значений
  ed_y.text:=inttostr(round(CurView.ay));
  ed_z.text:=inttostr(round(CurView.az));
  PopFunction;
  exit;                           //выход
 end;//of if(rotate)

if (sb_cross.down or ((EditorMode<>1) and sb_selbone.down)
   and (AnimEdMode<>1)) and
   sb_cross.enabled and (InstrumStatus=isSelect) and
   ((abs(ClickX-x)>5) or (abs(ClickY-y)>5)) then begin       //область выделения
 IsArea:=true;               //обрабатываем площадь
 SwapBuffers(dc);            //обновить картинку
 wglMakeCurrent(0,0);
 hBrush:=CreateSolidBrush($080808);
 SelectObject(dc,hBrush);
 MoveToEx(dc,ClickX,ClickY,nil);      //рисуем рамку
 LineTo(dc,X,ClickY);LineTo(dc,x,y);
 LineTo(dc,ClickX,y);LineTo(dc,ClickX,ClickY);
 DeleteObject(hBrush);
 OldMouseX:=x;OldMouseY:=y;
 wglMakeCurrent(dc,hrc);
 PopFunction;
 exit;
end;//of if

//Двигать вершины
if IsMouseDown and sb_cross.down and sb_cross.enabled
   and (InstrumStatus=isMove) then vMove(x,y,shift);
//Повернуть вершины
if IsMouseDown and sb_cross.down and sb_cross.enabled
   and (InstrumStatus=isRotate) then vRotate(x,y);
//Повернуть нормали
if IsMouseDown and sb_cross.down and sb_cross.enabled
   and (InstrumStatus=isNormalRot) then nRotate(x,y);
//Масштабировать
if IsMouseDown and sb_cross.down and sb_cross.enabled
   and (InstrumStatus=isZoom) then begin
 if (ssShift in shift) then begin //масштаб вдоль оси
  if rb_xy.checked then vZoom(x-OldMouseX,0,0);
  if rb_xz.checked then vZoom(0,0,x-OldMouseX);
  if rb_yz.checked then vZoom(0,x-OldMouseX,0);
 end else vZoom(x-OldMouseX,x-OldMouseX,x-OldMouseX);
end;//of if (масштаб)
RefreshWorkArea(Sender);   

//Теперь - инструменты редактора анимаций
if IsPlay then begin PopFunction;exit;end;
UseRefresh:=false;
if AnimEdMode=0 then begin        //редактор скелета
 if IsMouseDown and sb_animcross.down and sb_animcross.visible
    and sb_bonemove.down
 then begin
  bMove(x,y,Shift);
  UseRefresh:=true;
 end;
 //Перерисовка
 if UseRefresh then begin
  if SelObj.IsSelected and (SelObj.b.ObjectID>=0)
  then SelObj.b.AbsVector:=PivotPoints[SelObj.b.ObjectID];
  DrawFrame(CurFrame);
  CalcObjs2D(frm1.GLWorkArea.ClientHeight);
  CalcVertex2D(frm1.GLWorkArea.ClientHeight);
  UseRefresh:=false;
 end;//of if
end;//of if

if AnimEdMode=2 then begin        //редактор движения
 if IsMouseDown and sb_animcross.down and sb_animcross.visible and
    (InstrumStatus=isBoneRot) then begin
  WorkPlane.FindAngles(x,y,OldMouseX,OldMouseY,dax,day,daz);  
  bRot(dax,day,daz);
 end;//of if
 if IsMouseDown and sb_animcross.down and sb_animcross.visible and
    (InstrumStatus=isBoneMove) then bTrans(x,y,Shift);
 if IsMouseDown and sb_animcross.down and sb_animcross.visible and
    (InstrumStatus=isBoneScaling) then bZoom(x-OldMouseX,Shift);
end;//of if

OldMouseX:=x;OldMouseY:=y;
PopFunction;
end;

//Нажата кнопка поворота
procedure Tfrm1.sb_rotClick(Sender: TObject);
begin
 PushFunction(30);
 pn_listbones.visible:=false;
 pn_vertcoords.visible:=false;
 pn_listbones.tag:=1;
 pn_boneedit.visible:=false;
 pn_color.visible:=false;
 pn_seq.visible:=false;
 pn_instr.Visible:=false;
 pn_objs.visible:=false;
 label4.visible:=true;ed_z.visible:=true;
 label1.caption:='Поворот вокруг оси';
 pn_zoom.visible:=false;
 pn_stat.visible:=true;
 pn_workplane.visible:=false;
 pn_binstrum.visible:=false;
 pn_boneprop.visible:=false;
 pn_propobj.visible:=false;
 pn_contrprops.visible:=false;
 pn_spline.visible:=false;
 pn_atchprop.visible:=false;
 pn_pre2prop.visible:=false;
 ed_x.text:=inttostr(round(CurView.ax));
 ed_y.text:=inttostr(round(CurView.ay));
 ed_z.text:=inttostr(round(CurView.az));
 status.SimpleText:='Двигайте мышь с зажатой левой кнопкой для поворота';
 GLWorkArea.Cursor:=crRotCur;
 PopFunction;
end;

procedure Tfrm1.sb_moveClick(Sender: TObject);
begin
 PushFunction(31);
 pn_listbones.visible:=false;
 pn_vertcoords.visible:=false; 
 pn_listbones.tag:=1;
 pn_boneedit.visible:=false;
 pn_color.visible:=false; 
 pn_seq.visible:=false;
 pn_instr.Visible:=false;
 pn_objs.visible:=false; 
 label4.visible:=false;ed_z.visible:=false;
 label1.caption:='Смещение';
 ed_x.text:=inttostr(round(CurView.tx));
 ed_y.text:=inttostr(round(CurView.ty));
 pn_zoom.visible:=false;
 pn_stat.visible:=true;
 pn_workplane.visible:=false;
 pn_binstrum.visible:=false;
 pn_boneprop.visible:=false;
 pn_propobj.visible:=false;
 pn_contrprops.visible:=false;
 pn_spline.visible:=false;
 pn_atchprop.visible:=false;
 pn_pre2prop.visible:=false;
 status.SimpleText:='Двигайте мышь с зажатой левой кнопкой для перемещения'#13#10+
                    'рисунка';
 GLWorkArea.Cursor:=crHandPoint;
 PopFunction;
end;

procedure Tfrm1.ed_zoomEnter(Sender: TObject);
Var zm:GLfloat;
begin
 PushFunction(32);
 if not IsCipher(ed_zoom.text) then begin
  ed_zoom.text:=inttostr(round(CurView.zoom*100));
  PopFunction;
  exit;
 end;
 zm:=strtofloat(ed_zoom.text)/100;
 if (zm<0.02) or (zm>1000) then begin
  ed_zoom.text:=inttostr(round(CurView.zoom*100));
  PopFunction;
  exit;
 end;//of if
 CurView.Zoom:=zm;
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
end;

procedure Tfrm1.ed_zoomKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if key=vk_return then ed_zoomenter(sender);
end;
 


//здесь будут "горячие" клавиши
procedure Tfrm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
const VK_A=$41; VK_B=$42; VK_C=$43; VK_D=$44; VK_E=$45;
      VK_F=$46;           VK_H=$48;
      VK_K=$4B;           VK_M=$4D; VK_N=$4E; VK_O=$4F;
                VK_Q=$51; VK_R=$52; VK_S=$53; VK_T=$54;
      VK_U=$55; VK_V=$56; VK_W=$57; VK_X=$58;
      VK_Z=$5A;
      VK_OEM=$C0;
begin
// frm1.caption:=inttostr(key);
 PushFunction(33);
 if (key=VK_PRIOR) or (key=VK_NEXT) or (key=VK_END) or
    (key=VK_HOME) or (key=VK_LEFT) or (key=VK_UP) or
    (key=VK_RIGHT) or (key=VK_DOWN) or
    (key=VK_INSERT) {or (key=VK_DELETE)} or
    (key in [VK_NUMPAD0..VK_NUMPAD9]) or (key=VK_DECIMAL) then begin
  PopFunction;
  exit;
 end;
 if Shift=[ssCtrl] then begin
  if key=VK_X then N52Click(Sender);
  if N2.enabled and (key=VK_O) then N2Click(Sender);
  if CtrlZ1.enabled and (key=VK_Z) then CtrlZ1Click(Sender);
  if StrlS1.enabled and (key=VK_S) then begin
   StrlS1Click(Sender);
   PopFunction;
   exit;
  end;
  if CtrlC1.enabled and (key=VK_C) then CtrlC1Click(Sender);
  if CtrlV1.enabled and (key=VK_V) then CtrlV1Click(Sender);
  if CtrlA1.enabled and (key=VK_A) then CtrlA1Click(Sender);
  if sb_animcross.visible and (key=VK_D) then N20Click(Sender);
  if (AnimEdMode=0) and sb_animcross.down then begin
   if (key=VK_B) and N44.enabled then CtrlB1Click(Sender);
   if (key=VK_A) and N44.enabled then CtrlA2Click(Sender);
   if (key=VK_V) and N44.enabled then N45Click(Sender);
  end;//of if
  if key<>VK_CONTROL then IsKeyDown:=true;
  PopFunction;
  exit;
 end;//of if (Ctrl)

 //Клавиша Del и всё, что с ней связано
 if (key=vk_delete) then begin
  if (GetSumCountOfSelVertices<>0) and
     (not ed_ix.Focused) and (not ed_iy.Focused)
     and (not ed_iz.Focused) and (EditorMode=emVertex) then sb_delClick(Sender);
  if (EditorMode=emAnims) then begin
   if AnimEdMode>0 then Del2Click(Sender);
   if (AnimEdMode=0) and (not cb_bonelist.Focused) and
      (not ed_bonex.focused) and (not ed_boney.focused)
      and (not ed_bonex.focused)
      and sb_objdel.enabled then sb_objdelClick(Sender);
  end;//of emAnims
 end;//of if

 if (not cb_animlist.Focused) and N11.enabled
 and (not cb_bonelist.focused) and (not ed_path.focused) then begin
  if key=VK_S then N15Click(Sender);
  if (key=VK_F) or (key=VK_OEM) then N16Click(Sender);
  if key=VK_K then K1Click(Sender);
  if (key<>VK_DECIMAL) and (key=VK_N) then N26Click(Sender);
  if (key=VK_H) and H1.enabled then H1Click(Sender);
  //Переключение режима: выделение/вращение
  if (key=VK_W) then begin
   if sb_cross.down or sb_animcross.down then begin
    sb_rot.down:=true;
    sb_rotClick(Sender);
   end else begin
    if sb_animcross.visible then begin
     sb_animcross.down:=true;
     sb_animcrossClick(Sender);
    end else begin
     sb_cross.down:=true;
     sb_crossClick(Sender);
    end;//of if
   end;//of if
  end;//of if
 end;//of if (not Focused)

 if F21.enabled and (key=VK_F2) then b_texClick(Sender);
 if N18.enabled and (key=VK_F3) then F31Click(Sender);
 if N18.enabled and (key=VK_F1) then F11Click(Sender);
 //"горячие клавиши" инструментов:
 if EditorMode=emVertex then begin
  if (key=VK_A) then begin
   sb_Select.down:=true;
   sb_SelectClick(Sender);
  end;
  if ((key=VK_M) or (key=VK_Q)) and sb_imove.enabled  and
     (not ed_ix.focused) and (not ed_iy.focused) and
     (not ed_iz.focused) then begin
   sb_imove.down:=true;
   sb_imoveClick(Sender);
  end;
  if (key=VK_R) and sb_irot.enabled then begin
   sb_irot.down:=true;
   sb_irotClick(Sender);
  end;
  if (key=VK_Z) and sb_izoom.enabled then begin
   sb_izoom.down:=true;
   sb_izoomClick(Sender);
  end;
  if (key=VK_T) and sb_triangle.enabled then sb_triangleClick(Sender);
  if (key=VK_U) and sb_uncouple.enabled then sb_uncoupleClick(Sender);
  if (key=VK_C) and b_collapse.enabled then b_collapseClick(Sender);
  if (key=VK_B) and b_weld.enabled then b_weldClick(Sender);
 end else begin                   //emAnims
  if AnimEdMode=0 then begin      //редактор скелета
   if cb_bonelist.focused then begin PopFunction;exit;end;
   //"Горячие клавиши" инструментов
   if (key=VK_A) then begin
    sb_Selbone.down:=true;
    sb_SelectClick(Sender);
   end;//of if
   if ((key=VK_M) or (key=VK_Q)) and sb_bonemove.enabled then begin
    sb_bonemove.down:=true;
    sb_bonemoveClick(Sender);
   end;//of if
   if (key=VK_V) and sb_vdetach.enabled then sb_vdetachClick(Sender);
   if (key=VK_E) and sb_selexpand.enabled and sb_selexpand.visible
   then sb_selexpandClick(Sender);
   if key=VK_T then begin
    if sb_begattach.visible and sb_begattach.enabled then begin
     sb_begattachClick(Sender);
     PopFunction;
     exit;
    end;//of (начать связывание)
    if sb_endattach.visible then sb_endattachClick(Sender);
   end;//of if (T)
   if (key=VK_D) and sb_detach.enabled then begin
    sb_detachClick(Sender);
    PopFunction;
    exit;
   end;//of if
   if (key=VK_C) and sb_vattach.enabled then sb_vattachClick(Sender);
  end else begin
   if cb_animlist.Focused then begin PopFunction;exit;end;
   if key=VK_C then C1Click(Sender);
   if (key=VK_A) then begin
    sb_Selbone.down:=true;
    sb_SelectClick(Sender);
   end;//of if
   if ((key=VK_M) or (key=VK_Q)) and sb_bonemove.enabled then begin
    sb_bonemove.down:=true;
    sb_bonemoveClick(Sender);
   end;//of if
   if (key=VK_R) and sb_bonerot.enabled then begin
    sb_bonerot.down:=true;
    sb_bonerotClick(Sender);
   end;//of if
   if (key=VK_Z) and sb_bonescale.enabled then begin
    sb_bonescale.down:=true;
    sb_bonescaleClick(Sender);
   end;//of if
  end;//of if
 end;//of if
 if key<>VK_CONTROL then IsKeyDown:=true;
 PopFunction;
end;

procedure Tfrm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 IsKeyDown:=false;
end;

//Enter на поле X
procedure Tfrm1.ed_xKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=vk_return then ed_xExit(sender);
end;
//Обработка поля X
procedure Tfrm1.ed_xExit(Sender: TObject);
var ax:GLfloat;
begin
 PushFunction(34);
 if not IsCipher(ed_x.text) then begin
  ed_x.text:=inttostr(round(CurView.ay));
  PopFunction;
  exit;
 end;//of if
 //Итак, число подходит
 ax:=strtofloat(ed_x.text);
 //теперь два варианта: вращение и смещение
if sb_rot.down then begin         //вращение
 if (ax<0) or (ax>360) then begin
  ed_x.text:=inttostr(round(CurView.ax));
  PopFunction;
  exit;
 end;//of if
 //все в порядке
 CurView.ax:=ax;
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
 exit;
end;//of if

if sb_move.down then begin        //смещение
 if (ax<-400) or (ax>400) then begin
  ed_x.text:=inttostr(round(CurView.tx));
  PopFunction;
  exit;
 end;//of if
 CurView.tx:=ax;
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
 exit;
end;//of if
PopFunction;
end;

procedure Tfrm1.ed_yKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=vk_return then ed_yExit(sender);
end;

procedure Tfrm1.ed_yExit(Sender: TObject);
var ay:GLfloat;
begin
 PushFunction(35);
 if not IsCipher(ed_y.text) then begin
  ed_y.text:=inttostr(round(CurView.ay));
  PopFunction;
  exit;
 end;//of if
 //Итак, число подходит
 ay:=strtofloat(ed_y.text);
if sb_rot.down then begin
 if (ay<0) or (ay>360) then begin
  ed_y.text:=inttostr(round(CurView.ay));
  PopFunction;
  exit;
 end;//of if
 //все в порядке
 CurView.ay:=ay;
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
 exit;
end;//of if

if sb_move.down then begin        //смещение
 if (ay<-400) or (ay>400) then begin
  ed_x.text:=inttostr(round(CurView.ty));
  PopFunction;
  exit;
 end;//of if
 CurView.ty:=ay;
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
 exit;
end;//of if
PopFunction;
end;

procedure Tfrm1.ed_zExit(Sender: TObject);
var az:GLfloat;
begin
 PushFunction(36);
 if not IsCipher(ed_z.text) then begin
  ed_z.text:=inttostr(round(CurView.az));
  PopFunction;
  exit;
 end;//of if
 //Итак, число подходит
 az:=strtofloat(ed_z.text);
 if (az<0) or (az>360) then begin
  ed_z.text:=inttostr(round(CurView.az));
  PopFunction;
  exit;
 end;//of if
 //все в порядке
 CurView.az:=az;
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
end;

procedure Tfrm1.ed_zKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=vk_return then ed_zExit(sender);
end;

//Меню "Сброс": сбросить парметры вида
procedure Tfrm1.N9Click(Sender: TObject);
begin
 PushFunction(37);
 CurView.Reset;
 ed_zoom.text:='100';
 ed_x.text:='0';ed_y.text:='0';ed_z.text:='0';
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.Clientheight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;

//Вид слева
procedure Tfrm1.N3Click(Sender: TObject);
begin
 PushFunction(38);
 CurView.ax:=90;CurView.ay:=180;CurView.az:=0;
 if sb_rot.down then begin
  ed_x.text:='90';ed_y.text:='180';ed_z.text:='0';
 end;//of if
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.Clientheight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;

//Право
procedure Tfrm1.N4Click(Sender: TObject);
begin
 PushFunction(39);
 CurView.ax:=270;CurView.ay:=0;CurView.az:=0;
 if sb_rot.down then begin
  ed_x.text:='270';ed_y.text:='0';ed_z.text:='0';
 end;//of if
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.Clientheight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;

//Низ
procedure Tfrm1.N5Click(Sender: TObject);
begin
 PushFunction(40);
 CurView.ax:=0;CurView.ay:=0;CurView.az:=0;
 if sb_rot.down then begin
  ed_x.text:='0';ed_y.text:='0';ed_z.text:='0';
 end;//of if
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.Clientheight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;

//Верх
procedure Tfrm1.N6Click(Sender: TObject);
begin
 PushFunction(41);
 CurView.ax:=180;CurView.ay:=0;CurView.az:=0;
 if sb_rot.down then begin
  ed_x.text:='180';ed_y.text:='0';ed_z.text:='0';
 end;//of if
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.Clientheight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;

//Перед
procedure Tfrm1.N7Click(Sender: TObject);
begin
 PushFunction(42);
 CurView.ax:=270;CurView.ay:=0;CurView.az:=270;
 if sb_rot.down then begin
  ed_x.text:='270';ed_y.text:='0';ed_z.text:='270';
 end;//of if
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.Clientheight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;

procedure Tfrm1.N8Click(Sender: TObject);
begin
 PushFunction(43);
 CurView.ax:=270;CurView.ay:=0;CurView.az:=90;
 if sb_rot.down then begin
  ed_x.text:='270';ed_y.text:='0';ed_z.text:='90';
 end;//of if
 CurView.ApplyView;
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.Clientheight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;


//Вспомогательная: отмена удаления анимации
{procedure UndoDeleteSeq;
Var i,j,len:integer;
Begin
   PushFunction(44);
   //1. Сдвиг самих записей анимаций
   inc(CountOfSequences);
   SetLength(Sequences,CountOfSequences);
   for i:=CountOfSequences-2 downto Undo[CountOfUndo].Status2 do
       Sequences[i+1]:=Sequences[i];
   Sequences[Undo[CountOfUndo].Status2]:=Undo[CountOfUndo].Sequence;
   //2. Сдвиг Anim'ов в поверхностях
   len:=Undo[CountOfUndo].Status2;
   for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
    if length(Undo[CountOfUndo].Anims)=0 then continue;
    inc(Geosets[j].CountOfAnims);
    SetLength(Geosets[j].Anims,Geosets[j].CountOfAnims);
    for i:=Geosets[j].CountOfAnims-2 downto len do
        Geosets[j].Anims[i+1]:=Geosets[j].Anims[i];
    Geosets[j].Anims[len]:=Undo[CountOfUndo].Anims[0];
   end;//of with/for j
   //3. Установка списка
   frm1.cb_animlist.Items.AddObject(Sequences[len].Name,pointer(len));
//   frm1.cb_animlist.text:=Sequences[len].Name;
   frm1.cb_animlist.ItemIndex:=len+1;
   PopFunction;
End;  }

//Заполняет список костей, влияющих на выделенные вершины
//и делает соотв. панель видимой
procedure TFrm1.FillBonesList;
Var j,i,ii,num:integer;
    lst:TList;
Begin
 PushFunction(45);
 //1. Начальная проверка и очистка
 lb_bones.Items.Clear;
 if GetSumCountOfSelVertices=0 then begin
  pn_listbones.visible:=false;
  pn_vertcoords.visible:=false;
  PopFunction;
  exit;
 end;//of if

 //2. Начинаем заполнение
 lst:=TList.Create;               //создать список
 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected then begin
  //a. Составить список индеков матриц для поверхности
  lst.Clear;
  for i:=0 to GeoObjs[j].VertexCount-1 do begin
   if lst.IndexOf(pointer(Geosets[j].VertexGroup[GeoObjs[j].VertexList[i]-1]))<0
   then lst.Add(pointer(Geosets[j].VertexGroup[GeoObjs[j].VertexList[i]-1]));
  end;//of for i

  //b. Добавить содержимое матриц в список костей
  for i:=0 to lst.Count-1 do begin
   num:=integer(lst.Items[i]);
   for ii:=0 to High(Geosets[j].Groups[num]) do with Geosets[j] do begin
    if (lb_bones.Items.IndexOfObject(TObject(Groups[num,ii]))<0) and
       ((not NullBone.IsExists) or (NullBone.id<>Groups[num,ii]))
    then lb_bones.Items.AddObject(Bones[Groups[num,ii]-Bones[0].ObjectID].Name,
                                  TObject(Groups[num,ii]));
   end;//of for ii
  end;//of for i
 end;//of for j

 lst.Destroy;
 pn_listbones.visible:=true;
 pn_vertcoords.visible:=true;
 FindVertCoordCenter;
 label41.caption:='X='+floattostrf(ccVX,ffFixed,10,5);
 label42.caption:='Y='+floattostrf(ccVY,ffFixed,10,5);
 label43.caption:='Z='+floattostrf(ccVZ,ffFixed,10,5);
 PopFunction;
End;

//Привести в соответствие инструменты присоединения вершин
procedure TFrm1.EnableAttachInstrums;
Var i,j:integer;
Begin
 PushFunction(46);
 //Фильтрование по количеству выделенных вершин. Также
 //анализируем тип объекта - должен быть помощник или кость
 if (GetSumCountOfSelVertices=0) or (not SelObj.IsSelected) or
    ((SelObj.ObjType<>typBONE) and (SelObj.ObjType<>typHELP)) then begin
  sb_vattach.enabled:=false;
  sb_vreattach.enabled:=false;
  sb_vdetach.enabled:=false;
  PopFunction;
  exit;
 end;//of if

 sb_vattach.enabled:=true;
 sb_vreattach.enabled:=true;
 //Если есть дочерние вершины, активировать инструмент
 if SelObj.IsSelected and (SelObj.ObjType=typBONE) and
    (GetSumCountOfChildVertices>0) then begin
  sb_vdetach.enabled:=true;
 end else sb_vdetach.enabled:=false;

 //Теперь проверяем кол-во костей в каждой матрице.
 //если их больше 6, связывание не выполняется - только пересвязывание
 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected then begin
  for i:=0 to GeoObjs[j].VertexCount-1 do with GeoObjs[j] do begin
   if length(Geosets[j].Groups[Geosets[j].VertexGroup[VertexList[i]-1]])>5
   then begin
    sb_vattach.enabled:=false;
    PopFunction;
    exit;
   end;//of if
  end;//of with/if/for i
 end;//of if/for j
 PopFunction;
End;

//Отмена, задействующая NewUndo
procedure TFrm1.ReleaseNewUndo(Sender:TObject);
Var und:TUndoContainer;bu:TBoneUndo;au:TAtchUndo;pr:TPre2Undo;
    pu:TPivUndo;su:TStampObjUndo;sg:TStampGeoUndo;
    j,i,ii:integer;
    NotDec:boolean;
Begin
 PushFunction(47);
 if CountOfNewUndo=0 then begin
  MessageBox(frm1.handle,PChar('Внутренняя ошибка: CountOfNewUndo=0.'#13#10+
             'Лог (сообщить разработчику):'#13#10+
             'CountOfUndo='+inttostr(CountOfUndo)+#13#10+
             'Undo[CountOfUndo].Status1='+inttostr(Undo[CountOfUndo].status1)),
             'Ошибка',MB_ICONEXCLAMATION or MB_APPLMODAL);
 end;//of if
 case TNewUndo(NewUndo[CountOfNewUndo-1]).TypeOfUndo of
  uNDeleteSeqs:begin              //отмена удаления группы последовательностей
   repeat
    //получим объект
    if TNewUndo(NewUndo[CountOfNewUndo-1]).TypeOfUndo<>uNDeleteSeqs then begin
     ReleaseNewUndo(Sender);
     continue;
    end;//of if
    und:=TUndoContainer(NewUndo[CountOfNewUndo-1]);
    //скопируем его содержимое в TUndo
    ReplaceTUndo(und.Undo,Undo[CountOfUndo]);
    //Если нужно, копируем вспомогательные Undo-массивы
{    if Undo[CountOfUndo].status1=uDeleteSeq then begin
     for j:=0 to CountOfGeosets-1 do
      ReplaceTUndo(und.GeoU[j],GeoObjs[j].Undo[CountOfUndo]);
     UndoDeleteSeq;               //отмена удаления поверхности
    end;//of fi}

    //или же это - удаление группы КК
    if Undo[CountOfUndo].status1=uDeleteKeyFrames then begin
     RestoreTextureAnims(Undo[CountOfUndo]);//восстановить секцию текст. аним.
     RestoreControllers(Undo[CountOfUndo],true);//восстановить контроллеры
    end;//of if

    NewUndo[CountOfNewUndo-1].Free;
    dec(CountOfNewUndo);
    SetLength(NewUndo,CountOfNewUndo);
   until und.Prev<0;
   frm_obj.MakeSequencesList;     //пересоздать список поверхностей
  end;//of uNDeleteSeqs
//----------------------------------------------------------
  uChangeObject:begin             //восстановить состояние объекта
   cb_billboard.tag:=1;           //для запрета срабатывания событий
   cb_abillboard.tag:=1;
   case TObjUndo(NewUndo[CountOfNewUndo-1]).typ of
    typBONE:begin
     bu:=TBoneUndo(NewUndo[CountOfNewUndo-1]);
     Bones[bu.b.ObjectID]:=bu.b;
     Undo[CountOfUndo].status2:=0;    //сброс
     GraphSelectObject(bu.b.ObjectID);
     dec(CountOfUndo);
    end;//of typBONE

    typHELP:begin
     bu:=TBoneUndo(NewUndo[CountOfNewUndo-1]);
     Helpers[bu.IdInArray]:=bu.b;
     GraphSelectObject(bu.b.ObjectID);
     dec(CountOfUndo);
    end;//of typHELP

    typATCH:begin
     au:=TAtchUndo(NewUndo[CountOfNewUndo-1]);
     Attachments[au.IdInArray]:=au.atch;
     GraphSelectObject(au.atch.Skel.ObjectID);
     dec(CountOfUndo);
    end;//of typBONE

    typPRE2:begin
     pr:=TPre2Undo(NewUndo[CountOfNewUndo-1]);
     pre2[pr.IdInArray]:=pr.pre2;
     GraphSelectObject(pr.pre2.Skel.ObjectID);
     dec(CountOfUndo);
    end;//of typPRE2
   end;//of case (тип объекта)

   NewUndo[CountOfNewUndo-1].Free;
   dec(CountOfNewUndo);
   SetLength(NewUndo,CountOfNewUndo);
   cb_billboard.tag:=0;
   cb_abillboard.tag:=0;
  end;//of uChangeObject
//------------------------------------------------

  uCreateObject:begin             //создание объекта
   pu:=TPivUndo(NewUndo[CountOfNewUndo-1]);
   dec(CountOfNewUndo);

   //1. Сдвинуть масив PivotPoints:
   if pu.IsDel then begin         //"обратный" сдвиг
    ReservePivotSpace(pu.id);     //собственно сдвиг
    PivotPoints[pu.id]:=pu.pt;    //восстановить координаты
   end else begin                 //"прямой" сдвиг
    for i:=pu.id to CountOfPivotPoints-2 do PivotPoints[i]:=PivotPoints[i+1];
    dec(CountOfPivotPoints);
    SetLength(PivotPoints,CountOfPivotPoints);
   end;//of if

   //2. Выделить некий объект
   cb_abillboard.tag:=-1;
   cb_billboard.tag:=-1;
   MakeTextObjList(Sender);       //построить список объектов
   GraphSelectObject(pu.SelId);
   frm_obj.MakeObjectsList(pu.SelId,pu.SelId);
   if pu.SelID>=0 then dec(CountOfUndo);
   cb_abillboard.tag:=0;
   cb_billboard.tag:=0;

   //3. Освободить NewUndo
   NewUndo[CountOfNewUndo].Free;
   SetLength(NewUndo,CountOfNewUndo); //dec сделан выше
  end;//of uCreateObject
//-------------------------------------------------------

  uChangeObjects:begin            //восстановить состояние объектов
   su:=TStampObjUndo(NewUndo[CountOfNewUndo-1]);
   dec(CountOfNewUndo);

   //копирование объектов
   //кости
   CountOfBones:=su.CountOfBones;
   SetLength(Bones,CountOfBones);
   for i:=0 to CountOfBones-1 do Bones[i]:=su.Bones[i];

   //Источники света
   CountOfLights:=su.CountOfLights;
   SetLength(Lights,CountOfLights);
   for i:=0 to CountOfLights-1 do Lights[i]:=su.Lights[i];

   //Помощники
   CountOfHelpers:=su.CountOfHelpers;
   SetLength(Helpers,CountOfHelpers);
   for i:=0 to CountOfHelpers-1 do Helpers[i]:=su.Helpers[i];

   //аттачи
   CountOfAttachments:=su.CountOfAttachments;
   SetLength(Attachments,CountOfAttachments);
   for i:=0 to CountOfAttachments-1 do Attachments[i]:=su.Attachments[i];

   //Источники частиц
   CountOfParticleEmitters1:=su.CountOfParticleEmitters1;
   SetLength(ParticleEmitters1,CountOfParticleEmitters1);
   for i:=0 to CountOfParticleEmitters1-1
   do ParticleEmitters1[i]:=su.ParticleEmitters1[i];

   //Источники частиц (вторая версия)
   CountOfParticleEmitters:=su.CountOfParticleEmitters;
   SetLength(pre2,CountOfParticleEmitters);
   for i:=0 to CountOfParticleEmitters-1 do pre2[i]:=su.pre2[i];

   //Источники следа
   CountOfRibbonEmitters:=su.CountOfRibbonEmitters;
   SetLength(Ribs,CountOfRibbonEmitters);
   for i:=0 to CountOfRibbonEmitters-1 do Ribs[i]:=su.Ribs[i];

   //События
   CountOfEvents:=su.CountOfEvents;
   SetLength(Events,CountOfEvents);
   for i:=0 to CountOfEvents-1 do Events[i]:=su.Events[i];

   //Объекты границ
   CountOfCollisionShapes:=su.CountOfCollisionShapes;
   SetLength(Collisions,CountOfCollisionShapes);
   for i:=0 to CountOfCollisionShapes-1 do Collisions[i]:=su.Collisions[i];

   NewUndo[CountOfNewUndo].Free;
   SetLength(NewUndo,CountOfNewUndo);
   if su.Prev>=0 then ReleaseNewUndo(Sender); //восстановить, если есть что
  end;//of uChangeObjects
//---------------------------------------------------------

  uSaveObjChange:begin            //восстановить состояние объектов
   sg:=TStampGeoUndo(NewUndo[CountOfNewUndo-1]);
   dec(CountOfNewUndo);

   //Восстановить VertexGroup и Matrices
   for j:=0 to CountOfGeosets-1 do begin
    for i:=0 to Geosets[j].CountOfVertices-1
    do Geosets[j].VertexGroup[i]:=sg.Geo[j].VertexGroup[i];

    Geosets[j].CountOfMatrices:=sg.Geo[j].CountOfMatrices;
    SetLength(Geosets[j].Groups,Geosets[j].CountOfMatrices);
    for i:=0 to sg.Geo[j].CountOfMatrices-1 do begin
     SetLength(Geosets[j].Groups[i],length(sg.Geo[j].Groups[i]));
     for ii:=0 to High(Geosets[j].Groups[i])
     do Geosets[j].Groups[i,ii]:=sg.Geo[j].Groups[i,ii];
    end;//of for i
   end;//of for j

   //Восстановить PivotPoints
   CountOfPivotPoints:=sg.CountOfPivotPoints;
   SetLength(PivotPoints,CountOfPivotPoints);
   for i:=0 to CountOfPivotPoints-1 do PivotPoints[i]:=sg.PivotPoints[i];

   cb_abillboard.tag:=-1;
   cb_billboard.tag:=-1;
   FindNullBone;                  //проверить, нет ли нулевой кости
   MakeTextObjList(Sender);       //построить список объектов
   NotDec:=SelObj.b.ObjectID<0;
   if SelObj.IsMultiSelect then begin
    GraphMultiSelectObject(sg.lst,sg.len);
    dec(CountOfUndo);
   end else GraphSelectObject(sg.SelId);
   FillBonesList;
   frm_obj.MakeObjectsList(sg.SelId,sg.SelId);
   if not NotDec then dec(CountOfUndo);
   cb_abillboard.tag:=0;
   cb_billboard.tag:=0;
   NewUndo[CountOfNewUndo].Free;
   SetLength(NewUndo,CountOfNewUndo);
  end;//of uSaveObjChange
//----------------------------------------------------------
  uCreateController,uDeleteController,uCutKeyFrames,uTransBone,
  uSmoothGroups,uCommonUndo:begin
   i:=NewUndo[CountOfNewUndo-1].Prev;
   NewUndo[CountOfNewUndo-1].Restore; //восстановление
   NewUndo[CountOfNewUndo-1].Free;
   dec(CountOfNewUndo);
   SetLength(NewUndo,CountOfNewUndo);
   if i>=0 then ReleaseNewUndo(Sender);
  end;//of uCommonUndo
 end;//of case
 PopFunction;
End;

//Отмена, действующая в редакторе анимаций
procedure TFrm1.AnimUndo(Sender:TObject);
Var i,len,len2,ii,j,ID:integer;und:TUndoContainer;
    bTmp:TBone;lst:TFace;
    s:string;
//    it:TContItem;
Begin
 PushFunction(48);
 case Undo[CountOfUndo].status1 of
  uFrameAdd:with Undo[CountOfUndo] do begin//добавление кадров
   ShearFrames(MatID,SelGroup,-status2);
   AbsMaxFrame:=AbsMaxFrame-status2;
  end;//of uFrameAdd

  uSeqPropChange,uCreateSeq,uCreateGlobalSeq,
  uSeqDurationChange,uDeleteGlobalSeq,uDeleteSeq:MessageBox(0,'Err','Err',0);

  uEmittersOff:begin
   len:=High(Undo[CountOfUndo].idata);
   for i:=0 to len do
       cpyController(Undo[CountOfUndo].Controllers[i],
                     Controllers[Undo[CountOfUndo].idata[i]]);
   ReFormStamps;
  end;//of uEmittersOff

  uDeleteKeyFrames:begin          //удаление части КК
   RestoreTextureAnims(Undo[CountOfUndo]);//восстановить секцию текст. анимаций
   RestoreControllers(Undo[CountOfUndo],false);//восстановить контроллеры
  end;//of uDeleteKeyFrames

  uPasteFrames:begin              //отмена вставки кадров
   len:=High(Undo[CountOfUndo].Controllers);
   for i:=0 to len do begin
    ID:=Undo[CountOfUndo].VertexGroup[i];
    //Удалить вставленный участок
    DeleteFrames(Controllers[ID],Undo[CountOfUndo].idata[i*2],
                 Undo[CountOfUndo].idata[i*2+1]);
    //Восстановить собственный
    if Undo[CountOfUndo].Controllers[i].SizeOfElement=0 then continue;
    CopyFrames(Undo[CountOfUndo].Controllers[i],Controllers[ID],
               Undo[CountOfUndo].idata[i*2],Undo[CountOfUndo].idata[i*2+1],
               Undo[CountOfUndo].idata[i*2],-1);
   end;//of for i
   ReFormStamps;
  end;

  uCutKeyFrames:begin             //вырезан фрагмент
   //Восстановление кадров, секций и т.п.
   i:=CountOfSequences;
   ShearFrames(Undo[CountOfUndo].Sequence.IntervalStart,
               Undo[CountOfUndo].Sequence.MoveSpeed,
               Undo[CountOfUndo].Sequence.IntervalEnd);
   RestoreTextureAnims(Undo[CountOfUndo]);//восстановить секцию текст. анимаций
   RestoreControllers(Undo[CountOfUndo],false);//восстановить контроллеры
   //восстановление Event'ов, анимок и пр.
   ReleaseNewUndo(Sender);

   //формирование списка анимок
   if AnimEdMode=1 then ReFormStamps;
   MaxFrame:=MaxFrame+Undo[CountOfUndo].Sequence.IntervalEnd;
   AbsMaxFrame:=AbsMaxFrame+Undo[CountOfUndo].Sequence.IntervalEnd;
   if i<>CountOfSequences then begin
    AnimPanel.MakeAnimList;
    cb_animlist.items.Assign(AnimPanel.SeqList);
    cb_animlist.ItemIndex:=0;
    cb_animlistChange(Sender);
    if AnimEdMode=1 then frm_obj.MakeSequencesList; //создать список анимок
   end;//of if
  end;//of uCutKeyFrames


  uCreateGAController:begin //создание контроллера/анимации видимости
   //Восстановить свойства материалов (для цветовых контроллеров)
   if Undo[CountOfUndo].Sequence.IsNonLooping then begin
     for i:=0 to High(Undo[CountOfUndo].VertexGroup)
     do Materials[Undo[CountOfUndo].VertexGroup[i]].IsConstantColor:=false;
     for i:=0 to High(Undo[CountOfUndo].VertexList)
     do GeosetAnims[Undo[CountOfUndo].VertexList[i]].Color[1]:=-1;
   end;  
   //1. Проходим по всем GeosetAnim
   for j:=0 to CountOfGeosetAnims-1 do begin
    if Undo[CountOfUndo].Sequence.IsNonLooping then begin
     //Отменить создание цветовых контроллеров
     if GeoObjs[j].Undo[CountOfUndo].Status2=3 then begin
      GeosetAnims[j].Color[1]:=-1;
      GeosetAnims[j].IsColorStatic:=true;
      GeosetAnims[j].ColorGraphNum:=-1;
     end;//of if(CreateController)
    end else begin//of if(Color)
     //Отменить создание контроллеров
     if GeoObjs[j].Undo[CountOfUndo].Status2=1 then begin
      GeosetAnims[j].Alpha:=1;
      GeosetAnims[j].IsAlphaStatic:=true;
      GeosetAnims[j].AlphaGraphNum:=-1;
     end;//of if(CreateController)
    end;//of if(Color?)
   end;//of for j

   //Отменить создание контроллеров
   SetLength(Controllers,Undo[CountOfUndo].MatID);
   //Отменить все преобразования контроллеров
   len:=high(Undo[CountOfUndo].idata);
   for i:=0 to len do cpyController(Undo[CountOfUndo].Controllers[i],
                                    Controllers[Undo[CountOfUndo].idata[i]]);

   //Отменить создание анимаций видимости
   for j:=CountOfGeosets-1 downto 0
   do if GeoObjs[j].Undo[CountOfUndo].Unselectable then ARGeosetAnim(j,j,-1);
  end;//of uCreateGAController

  uChangeFrame:begin              //восстановление содержимого кадра
   for j:=0 to Undo[CountOfUndo].Status2-1 do begin
    if Undo[CountOfUndo].Controllers[j].SizeOfElement=0
    then DeleteFrames(Controllers[Undo[CountOfUndo].idata[j]],
                      Undo[CountOfUndo].Controllers[j].Items[0].Frame,
                      Undo[CountOfUndo].Controllers[j].Items[0].Frame)
    else InsertFrame(Controllers[Undo[CountOfUndo].idata[j]],
                     Undo[CountOfUndo].Controllers[j].Items[0]);
   end;//of for j
  end;//of uChangeFrame

  uUseNewUndo:begin               //отмена сохранена в NewUndo
   if not SelObj.IsMultiSelect then ReleaseNewUndo(Sender) //отдельная процедура
   else begin
    CountOfNewUndo:=0;
    CountOfUndo:=1;
   end;

   //В случае вкладки "анимки" перерисовать список
   if AnimEdMode=1 then begin
    SAnimPanelProps;
    AnimPanel.MakeAnimList;
    cb_animlist.items.Assign(AnimPanel.SeqList);
    cb_animlist.ItemIndex:=AnimPanel.GSelSeqIndex;
    frm_obj.MakeSequencesList;
   end;//of if
  end;//of uUseNewUndo

  uSelectObject:begin             //отмена выделения объекта
   if SelObj.IsSelected and SelObj.IsMultiSelect then begin
    //Если множественное выделение - выделить как список
    SetLength(lst,1); lst[0]:=Undo[CountOfUndo].status2;
    GraphMultiSelectObject(lst,1);
   end else begin
    //иначе - как стандартный одиночный объект
    frm_obj.MakeObjectsList(Undo[CountOfUndo].status2,Undo[CountOfUndo].status2);
    GraphSelectObject(Undo[CountOfUndo].status2);
   end;//of if
   dec(CountOfUndo);              //компенсировать дополнительную запись
  end;//of uSelectObject

  uSelectObjects:begin            //выделение группы объектов
   if SelObj.IsSelected and SelObj.IsMultiSelect then begin
    //Если множественное выделение - выделить как список
    GraphMultiSelectObject(Undo[CountOfUndo].Faces[0],
                           Undo[CountOfUndo].status2);
   end else begin
    if Undo[CountOfUndo].status2>0 then begin
     //иначе - как стандартный одиночный объект
     frm_obj.MakeObjectsList(Undo[CountOfUndo].Faces[0,0],
                             Undo[CountOfUndo].Faces[0,0]);
     GraphSelectObject(Undo[CountOfUndo].Faces[0,0]);
    end;//of if
   end;//of if
   dec(CountOfUndo);              //компенсировать дополнительную запись
  end;//of uSelectObjects

  uChangeObjName:begin            //смена имени объекта
   if not SelObj.IsMultiSelect then begin
    cb_bonelist.text:=Undo[CountOfUndo].Sequence.Name;
    cb_bonelistExit(Sender);         //сменить имя объекта
    FillBonesList;
    dec(CountOfUndo);
   end;//of if
  end;//of uChangeObjName

  //восстановить геом. центр объекта
  uPivotChange:begin
   if Undo[CountOfUndo].Unselectable then begin //множественное перемещение
    for i:=0 to Undo[CountOfUndo].status2-1 do begin
     PivotPoints[Undo[CountOfUndo].idata[i]]:=Undo[CountOfUndo].Vertices[i];
    end;//of for i
    FindCoordCenter;
    ed_bonex.text:=floattostrf(ccX,ffFixed,10,5);
    ed_boney.text:=floattostrf(ccY,ffFixed,10,5);
    ed_bonez.text:=floattostrf(ccZ,ffFixed,10,5);
    if not SelObj.IsMultiSelect then begin
     SelObj.b:=GetSkelObjectByID(SelObj.b.ObjectID);
     SelObj.b.AbsVector:=PivotPoints[SelObj.b.ObjectID];
    end;//of if
   end else begin//of if
    if not SelObj.IsMultiSelect then begin
     if Undo[CountOfUndo].status2>=0 then begin
      PivotPoints[Undo[CountOfUndo].Status2]:=
       Undo[CountOfUndo].Sequence.Bounds.MinimumExtent;
      SelObj.b.AbsVector:=PivotPoints[Undo[CountOfUndo].Status2];
      ed_bonex.text:=floattostrf(SelObj.b.AbsVector[1],ffFixed,10,5);
      ed_boney.text:=floattostrf(SelObj.b.AbsVector[2],ffFixed,10,5);
      ed_bonez.text:=floattostrf(SelObj.b.AbsVector[3],ffFixed,10,5);
      ccX:=SelObj.b.AbsVector[1];
      ccY:=SelObj.b.AbsVector[2];
      ccZ:=SelObj.b.AbsVector[3];
     end;//of if
    end;//of if
   end;//of if
  end;//of uPivotChange

  //отмена связывания объектов
  uAttachObject:if not SelObj.IsMultiSelect then begin
   bTmp:=SelObj.b;
   SelObj.b:=GetSkelObjectByID(Undo[CountOfUndo].Status2);
   SelObj.b.Parent:=Undo[CountOfUndo].SelGroup;
   SetSkelPart;
   if Undo[CountOfUndo].MatID>=0 then begin
    SelObj.b:=GetSkelObjectByID(Undo[CountOfUndo].MatID);
    SelObj.b.Parent:=Undo[CountOfUndo].HierID;
    SetSkelPart;
   end;//of if
   SelObj.b:=bTmp;
   GraphSelectObject(SelObj.b.ObjectID);
   dec(CountOfUndo);
  end;//of if/uAttachObject

  uDetachObject:if not SelObj.IsMultiSelect then begin
   SelObj.b.Parent:=Undo[CountOfUndo].status2;
   SetSkelPart;
   GraphSelectObject(SelObj.b.ObjectID);
   dec(CountOfUndo);
  end;//of if/uDetachObject

  uDeleteObjects:begin            //удаление группы объектов
//   SelObj.IsMultiSelect:=true;
   ReleaseNewUndo(Sender);
  end;//of uDeleteObjects

  uSaveController:begin           //восстановление состояния контроллера
   Controllers[Undo[CountOfUndo].status2]:=Undo[CountOfUndo].Controllers[0];
   Undo[CountOfUndo].Controllers[0].items:=nil;
  end;//of uSaveController
 end;//of case

 //Перерисовка
 if (AnimEdMode=2) and SelObj.IsSelected and (not SelObj.IsMultiSelect)
 then begin
  DrawFrame(CurFrame);            //тек. кадр+пересчёт
  SelObj.b:=GetSkelObjectById(SelObj.b.ObjectID);
  if sb_bonescale.Down then begin
   ObjAnimate.GetAbsScale(SelObj.b.ObjectID,GlobalX,GlobalY,GlobalZ);
   GlobalX:=GlobalX*100;
   GlobalY:=GlobalY*100;
   GlobalZ:=GlobalZ*100;
   ed_bonex.text:=floattostrf(GlobalX,ffFixed,10,5);
   ed_boney.text:=floattostrf(GlobalY,ffFixed,10,5);
   ed_bonez.text:=floattostrf(GlobalZ,ffFixed,10,5);
  end;//of if
{  label44.tag:=1;
   cb_objvis.enabled:=SelObj.b.Visibility>=0;
   b_visanimate.visible:=not cb_objvis.enabled;
   if cb_objvis.enabled then begin
    it:=GetFrameData(SelObj.b.Visibility,CurFrame,ctAlpha);
    cb_objvis.checked:=it.Data[1]>=0.5;
   end else cb_objvis.checked:=true;
  label44.tag:=0;}
  GraphSelectObject(SelObj.b.ObjectId);
  dec(CountOfUndo);
  AnimLineRefresh(Sender);
 end else AnimLineRefresh(Sender);

 dec(CountOfUndo);
 if CountOfUndo<=0 then begin
  sb_animundo.enabled:=false;
  CtrlZ1.enabled:=false;
 end;//of if
 PopFunction;
End;

//Щелчок по кнопке "отмена (Ctrl+Z)";
procedure Tfrm1.CtrlZ1Click(Sender: TObject);
Var i,ii,j,len:integer;IsBone:boolean;
    txt:string;
begin
if CountOfUndo=0 then exit;  //перестрахуемся
PushFunction(49);
StrlS1.enabled:=true;
sb_save.enabled:=true;
//анимации
if (EditorMode=emAnims) and (Undo[CountOfUndo].status1<>uSelect) then begin
 {if sb_animcross.down then} AnimUndo(Sender);
 PopFunction;
 exit;
end;//of if
case Undo[CountOfUndo].Status1 of //проверим, что отменяется
 uSelect:for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
  VertexCount:=Undo[CountOfUndo].Status2;
  SetLength(VertexList,VertexCount);
  for i:=0 to VertexCount-1 do VertexList[i]:=round(Undo[CountOfUndo].Data1[i]);
  if VertexCount=0 then begin
   sb_select.down:=true;    //нажать исходную
   InstrumStatus:=isSelect; //инструмент: выделение;
   CtrlA1.enabled:=true;
  end;//of if
  SetCoordCenter;
 end;//of uSelect

 uVertexTrans:for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
  for i:=0 to Undo[CountOfUndo].Status2-1 do begin
   Geosets[j].Vertices[Undo[CountOfUndo].idata[i]-1,1]:=
        Undo[CountOfUndo].data1[i];
   Geosets[j].Vertices[Undo[CountOfUndo].idata[i]-1,2]:=
        Undo[CountOfUndo].data2[i];
   Geosets[j].Vertices[Undo[CountOfUndo].idata[i]-1,3]:=
        Undo[CountOfUndo].data3[i];
  end;//of for
  if sb_select.down or sb_imove.down then SetCoordCenter
                    else begin
   ed_ix.text:='0';
   ed_iy.text:='0';
   ed_iz.text:='0';
  end;//of if
 end;//of uVertexTrans

 uVertexDelete:begin
  ReleaseNewUndo(Sender);
  for j:=0 to CountOfGeosets-1 do with Geosets[j],Geoobjs[j] do begin
   CountOfVertices:=length(Undo[CountOfUndo].Vertices);
   CountOfNormals:=CountOfVertices;
   CountOfFaces:=length(Undo[CountOfUndo].Faces);
   CountOfMatrices:=length(Undo[CountOfUndo].Groups);
   //установка длин массивов
   SetLength(Vertices,CountOfVertices);
   SetLength(Normals,CountOfVertices);
   SetLength(VertexGroup,CountOfVertices);
   SetLength(Faces,length(Undo[CountOfUndo].Faces));
   SetLength(Groups,length(Undo[CountOfUndo].Groups));
   //копируем массивы поверхности
   for i:=0 to CountOfVertices-1 do for ii:=1 to 3 do begin
    Vertices[i,ii]:=Undo[CountOfUndo].Vertices[i,ii];
    Normals[i,ii]:=Undo[CountOfUndo].Normals[i,ii];
   end;//of for ii/i
   //текстурные вершины
   for ii:=0 to CountOfCoords-1 do with Crds[ii] do begin
    CountOfTVertices:=CountOfVertices;
    SetLength(TVertices,CountOfVertices);
    for i:=0 to CountOfVertices-1
    do Crds[ii].TVertices[i]:=Undo[CountOfUndo].Crds[ii].TVertices[i];
   end;//of for ii

   for i:=0 to CountOfVertices-1 do
               VertexGroup[i]:=Undo[CountOfUndo].VertexGroup[i];
   for i:=0 to Length(Faces)-1 do begin
    SetLength(Faces[i],length(Undo[CountOfUndo].Faces[i]));
    for ii:=0 to Length(Undo[CountOfUndo].Faces[i])-1 do
                 Faces[i,ii]:=Undo[CountOfUndo].Faces[i,ii];
   end;//of for
   for i:=0 to Length(Undo[CountOfUndo].Groups)-1 do begin
    SetLength(Groups[i],length(Undo[CountOfUndo].Groups[i]));
    for ii:=0 to Length(Undo[CountOfUndo].Groups[i])-1 do
                 Groups[i,ii]:=Undo[CountOfUndo].Groups[i,ii];
   end;//of for ii/i
   SetLength(VertexList,length(Undo[CountOfUndo].VertexList));
   for i:=0 to length(Undo[CountOfUndo].VertexList)-1 do
               VertexList[i]:=Undo[CountOfUndo].VertexList[i];
   VertexCount:=length(VertexList);
   if sb_select.down or sb_imove.down then SetCoordCenter
                     else begin
    ed_ix.text:='0';
    ed_iy.text:='0';
    ed_iz.text:='0';
   end;//of if
   ReCalcNormals(j+1);
   SmoothWithNormals(j);
  end;//of for j
 end;//of uVertexDelete

 uGeosetDetach:begin              //отделение части поверхности
  Undo[CountOfUndo].status1:=uVertexDelete;//для последующей отмены
  //чистим список поверхностей
  clb_geolist.Items.Delete(clb_geolist.Items.Count-1);
  //Удаляем анимацию видимости
  if (CountOfGeosetAnims>0) and
     (GeosetAnims[CountOfGeosetAnims-1].GeosetID=CountOfGeosets-1) then begin
   dec(CountOfGeosetAnims);
   SetLength(GeosetAnims,CountOfGeosetAnims);  
  end;//of if
  //Удаляем поверхность и связанные с ней объекты
  dec(CountOfGeosets);
  SetLength(Geosets,CountOfGeosets);
  SetLength(GeoObjs,CountOfGeosets);
  SetLength(VisGeosets,CountOfGeosets);
  CtrlZ1Click(Sender);            //"стандартная" отмена
  PopFunction;
  exit;
 end;//of uGeosetDetach

 uCreateTriangle:for j:=0 to CountOfGeosets-1 do with Geoobjs[j] do begin            //создать треугольник
  i:=length(Geosets[j].Faces);
  SetLength(Geosets[j].Faces[i-1],Undo[CountOfUndo].Status2);
 end;//of uCreateTriangle

 uCreateGeoset:begin              //создание (вставка) поверхности
  CountOfGeosets:=Undo[CountOfUndo].Status2;
  SetLength(Geosets,CountOfGeosets);
  SetLength(GeoObjs,CountOfGeosets);
  CountOfMaterials:=Undo[CountOfUndo].idata[1];
  SetLength(Materials,CountOfMaterials);
  CountOfTextures:=Undo[CountOfUndo].idata[0];
  SetLength(Textures,CountOfTextures);
  //Теперь - список выделенного
  for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
   VertexCount:=length(Undo[CountOfUndo].VertexList);
   SetLength(VertexList,VertexCount);
   for i:=0 to VertexCount-1 do VertexList[i]:=Undo[CountOfUndo].VertexList[i];
  end;//of for j
  //Обновим список
  txt:='1';
  for i:=2 to CountOfGeosets do txt:=txt+#13#10+inttostr(i);
  clb_geolist.Items.Text:=txt;
  for i:=0 to clb_geolist.Items.Count-1 do clb_geolist.Checked[i]:=false;
  clb_geolist.Checked[0]:=true;
  //Переключим поверхность
  cb_showallClick(Sender);
  SetCoordCenter;
 end;//of uCreateGeoset

 uGeosetDelete:begin              //удаление поверхности
  SaveNewUndo(uSmoothGroups,0);   //сохранить группы сглаживания
  if CountOfUndo=1 then begin     //невозможна отмена
   dec(CountOfUndo);
   EnableInstrums;
   PopFunction;
   exit;
  end;//of if
  for j:=CountOfDelObjs-1 downto CountOfDelObjs-Undo[CountOfUndo].idata[0] do
  with DelGeoObjs[j] do begin
   //1. Создаем "дырку" для новой поверхности
   SetLength(Geosets,CountOfGeosets+1);
   SetLength(GeoObjs,CountOfGeosets+1);
   for i:=CountOfGeosets-1 downto Undo[CountOfUndo].status2 do begin
    Geosets[i+1]:=Geosets[i];
    GeoObjs[i+1]:=GeoObjs[i];
   end;//of for i
   inc(CountOfGeosets);            //исправим счетчик поверхности
   GeoObjs[Undo[CountOfUndo].status2]:=DelGeoObjs[j];
   with Geosets[Undo[CountOfUndo].status2] do begin//копируем параметры
    MinimumExtent:=Undo[CountOfUndo].Ext.MinimumExtent;
    MaximumExtent:=Undo[CountOfUndo].Ext.MaximumExtent;
    BoundsRadius:=Undo[CountOfUndo].Ext.BoundsRadius;
    CountOfAnims:=length(Undo[CountOfUndo].Anims);
    SetLength(Anims,CountOfAnims); //выделить память
    for i:=0 to CountOfAnims-1 do Anims[i]:=Undo[CountOfUndo].Anims[i];
    MaterialID:=Undo[CountOfUndo].MatID;
    SelectionGroup:=Undo[CountOfUndo].SelGroup;
    Unselectable:=Undo[CountOfUndo].Unselectable;
    HierID:=Undo[CountOfUndo].HierID;
    CountOfVertices:=0;
    CountOfNormals:=0;
    CountOfCoords:=DelGeoObjs[j].Undo[CountOfUndo].Sequence.IntervalStart;
    SetLength(Crds,CountOfCoords);
    for ii:=0 to CountOfCoords-1 do Crds[ii].CountOfTVertices:=0;
    CountOfFaces:=0;
    CountOfMatrices:=0;
    Color4f[1]:=1;Color4f[2]:=1;Color4f[3]:=1;Color4f[4]:=1;
   end;//of with
   //2. Сдвинуть GeosetID в анимациях видимости
   for i:=0 to CountOfGeosetAnims-1 do
    if GeosetAnims[i].GeosetID>=Undo[CountOfUndo].status2 then
       inc(GeosetAnims[i].GeosetID);
   //3. Создаем дыру под анимацию видимости (если нужно)
   if (length(DelGeoObjs[j].Undo[CountOfUndo].idata)>0) and
      (DelGeoObjs[j].Undo[CountOfUndo].idata[0]<>-1) then begin //нужно!
    SetLength(GeosetAnims,CountOfGeosetAnims+1);
    for i:=CountOfGeosetAnims-1 downto Undo[CountOfUndo].idata[0] do
            GeosetAnims[i+1]:=GeosetAnims[i];
    inc(CountOfGeosetAnims);            //исправим счетчик поверхности
    GeosetAnims[Undo[CountOfUndo].idata[0]]:=Undo[CountOfUndo].GeosetAnim;
   end;//of if (вставка GeosetAnim)
   //4. Восстановить в костях/помощниках ID:
   len:=length(Undo[CountOfUndo].Vertices);
   for i:=0 to len-1 do
    with Bones[round(Undo[CountOfUndo].Vertices[i,3])] do begin
     GeosetID:=round(Undo[CountOfUndo].Vertices[i,1]);
     GeosetAnimID:=round(Undo[CountOfUndo].Vertices[i,2]);
   end;//of with/for i
   len:=length(Undo[CountOfUndo].Normals);
   for i:=0 to len-1 do
    with Helpers[round(Undo[CountOfUndo].Normals[i,3])] do begin
     GeosetID:=round(Undo[CountOfUndo].Normals[i,1]);
     GeosetAnimID:=round(Undo[CountOfUndo].Normals[i,2]);
   end;//of with/for i
  end;//of for j
  CountOfDelObjs:=CountOfDelObjs-Undo[CountOfUndo].idata[0];
  //увеличить кол-во поверхностей
  txt:='';
  for i:=1 to CountOfGeosets-1 do txt:=txt+inttostr(i)+#13#10;
  txt:=txt+inttostr(CountOfGeosets);
  clb_geolist.items.text:=txt;
  for i:=0 to clb_geolist.Items.Count-1 do clb_geolist.Checked[i]:=false;
  clb_Geolist.Checked[0]:=true;
  //И восстановим все вершины
  dec(CountOfUndo);
  CtrlZ1Click(Sender);
  inc(CountOfUndo);
  //Переключим поверхность
  cb_showallClick(Sender);
 end;//of uGeosetDelete

 uUncouple,uTexUncouple:begin
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do begin
  if Undo[CountOfUndo].Unselectable then continue;
  VertexCount:=Length(Undo[CountOfUndo].VertexList);
  SetLength(VertexList,VertexCount);
  for i:=0 to VertexCount-1 do begin
   VertexList[i]:=Undo[CountOfUndo].VertexList[i]+1;
   Vertices[Undo[CountOfUndo].VertexList[i]]:=Undo[CountOfUndo].Vertices[i];
  end;//of for i
  CountOfVertices:=Undo[CountOfUndo].MatID;
  CountOfNormals:=CountOfVertices;
  for i:=0 to CountOfCoords-1 do begin
   Crds[i].CountOfTVertices:=CountOfVertices;
   SetLength(Crds[i].TVertices,CountOfVertices);
  end;//of for i
  SetLength(Vertices,CountOfVertices);
  SetLength(Normals,CountOfVertices);
  SetLength(VertexGroup,CountOfVertices);
  SetLength(Geosets[j].Faces[0],length(Undo[CountOfUndo].Faces[0]));
  for i:=0 to length(Undo[CountOfUndo].Faces[0])-1 do
            Geosets[j].Faces[0,i]:=Undo[CountOfUndo].Faces[0,i];
 end;//of for j
 if sb_select.down or sb_imove.down then SetCoordCenter
 else begin
   ed_ix.text:='0';
   ed_iy.text:='0';
   ed_iz.text:='0';
  end;//of if
 end;//of uUncouple

 uSwapNormals:begin               //перевернуть нормали
  for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
   SelFaces:=Undo[CountOfUndo].Faces[0];
   Undo[CountOfUndo].Faces:=nil;
  end;//of for j
  SwapNormals;
  for j:=0 to CountOfGeosets-1 do GeoObjs[j].SelFaces:=nil; 
 end;//of uSwapNormals

 uDeleteTriangle:begin            //удалены треугольники
  for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
   if Undo[CountOfUndo].Status2<=0 then continue;
   SetLength(Geosets[j].Faces[0],Undo[CountOfUndo].Status2);
   for i:=0 to Undo[CountOfUndo].Status2-1 do
    Geosets[j].Faces[0,i]:=Undo[CountOfUndo].idata[i];
  end;//of for j
 end;//of uDeleteTriangle

 uSmoothGroups:begin
  ReleaseNewUndo(Sender);
  for i:=0 to CountOfGeosets-1 do begin
   ReCalcNormals(i+1);
   SmoothWithNormals(i);
  end;//of for i
  ApplySmoothGroups;
 end;//of uSmoothGroups
end;//of case
dec(CountOfUndo);       //глобальная переменная
//Обновить второй (иерархический) список
if EditorMode<>emAnims then begin
 if (frm_obj.cb_tree.checked) and (frm_obj.lv_obj.Items.Item[0].StateIndex=3)
 then frm_obj.MakeGeosetsList(integer(frm_obj.lv_obj.Items.Item[0].Data))
 else frm_obj.MakeGeosetsList(-1);
end;//of if

if CountOfUndo=0 then begin
 CtrlZ1.enabled:=false;
 sb_undo.enabled:=false;
 sb_animundo.enabled:=false;
end;//of if
//Теперь перечертим картинку
if EditorMode=emVertex then RefreshWorkArea(Sender) else DrawFrame(CurFrame);
EnableInstrums;
CalcVertex2D(GlWorkArea.Clientheight);
if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
if (AnimEdMode<>1) and (sb_selbone.down or sb_bonemove.down) and
   SelObj.IsSelected then begin
 ed_bonex.text:=floattostrf(Selobj.b.AbsVector[1],ffFixed,10,5);
 ed_boney.text:=floattostrf(Selobj.b.AbsVector[2],ffFixed,10,5);
 ed_bonez.text:=floattostrf(Selobj.b.AbsVector[3],ffFixed,10,5);
end;//of if
if (AnimEdMode<>1) and sb_bonerot.down then begin
 ed_bonex.text:='0';
 ed_boney.text:='0';
 ed_bonez.text:='0';
end;//of if
PopFunction;
end;

//Вспомогательная: снимает (если нужно) связку объектов
procedure EndAttachObj;
Begin with frm1 do begin
 PushFunction(50);
 if ChObj.IsSelected then begin
  ChObj.IsSelected:=false;
  sb_begattach.visible:=true;
  sb_endattach.visible:=false;
  DrawFrame(CurFrame);
 end;//of if
 PopFunction;
end;End;

procedure Tfrm1.sb_selectClick(Sender: TObject);
begin
 PushFunction(51);
 InstrumStatus:=isSelect; //выделение
 pn_contrprops.visible:=false;
 pn_spline.visible:=false;
 ContrProps.OnlyOnOff:=false;
 if (AnimEdMode=2) and SelObj.IsSelected and (not SelObj.IsMultiSelect) and
    (SelObj.b.Visibility>=0)
 then begin
  ContrProps.OnlyOnOff:=true;
  ContrProps.SetCaptionAndId(SelObj.b.Name,'Видимость',SelObj.b.Visibility);
 end;//of if
 if not pn_contrprops.visible then begin
  ContrProps.Hide;
  SplinePanel.Hide;
 end;//of if

 CtrlA1.enabled:=true;
 CalcVertex2D(GLWorkArea.Clientheight);
 EndAttachObj;
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 ed_ix.enabled:=false;
 ed_iy.enabled:=false;
 ed_iz.enabled:=false;
 ed_bonex.enabled:=false; ed_bonex.ReadOnly:=true;
 ed_boney.enabled:=false; ed_boney.ReadOnly:=true;
 ed_bonez.enabled:=false; ed_bonez.ReadOnly:=true;
 SetCoordCenter;
 RefreshWorkArea(Sender);
 PopFunction;
end;

procedure Tfrm1.sb_imoveClick(Sender: TObject);
begin
 PushFunction(52);
 InstrumStatus:=isMove;//перемещение
 CtrlA1.enabled:=false;
 ed_ix.text:='0';
 ed_iy.text:='0';
 ed_iz.text:='0';
 ed_ix.enabled:=true;
 ed_iy.enabled:=true;
 ed_iz.enabled:=true;
 SetCoordCenter;
 PopFunction;
end;

//Инструменты
procedure Tfrm1.ed_ixExit(Sender: TObject);
Var sx,sy,sz:string;DeltaX,DeltaY,DeltaZ:GLfloat;
    i,j:integer;bx,by,bz:boolean;
begin
 if InstrumStatus=isSelect then exit;
 PushFunction(53);
  //Считать значения из полей и запомнить
   sx:=ed_ix.text;sy:=ed_iy.text;sz:=ed_iz.text;
   if (not IsCipher(sx)) or (not IsCipher(sy)) or //ошибка
      (not IsCipher(sz))  then begin
    if InstrumStatus=isMove then begin
     GlobalX:=ccX;GlobalY:=ccY;GlobalZ:=ccZ;
    end;//of if
    ed_ix.text:=floattostrf(GlobalX,ffFixed,10,5);
    ed_iy.text:=floattostrf(GlobalY,ffFixed,10,5);
    ed_iz.text:=floattostrf(GlobalZ,ffFixed,10,5);
    PopFunction;
    exit;
   end;//of if
 if InstrumStatus=isNormalRot then SaveUndo(uSmoothGroups)
 else SaveUndo(uVertexTrans);        //запомнить состояние
 FindCoordCenter;
 DeltaX:=strtofloat(sx)-ccX;
 DeltaY:=strtofloat(sy)-ccY;
 DeltaZ:=strtofloat(sZ)-ccZ;

 case InstrumStatus of
  isMove:begin        //Движение вершин, поворот
   if (DeltaX<-5000) or (DeltaY<-5000) or (DeltaZ<-5000) or
      (DeltaX>5000) or (DeltaY>5000) or (DeltaZ>5000) then begin
       FindCoordCenter;
       PopFunction;
       exit;
   end;
   //2. Модификация координат выделенных вершин
   for j:=0 to CountOfGeosets-1 do
   with geoobjs[j],geosets[j] do if IsSelected then
   for i:=0 to VertexCount-1 do begin
    Vertices[VertexList[i]-1,1]:=Vertices[VertexList[i]-1,1]+DeltaX;
    Vertices[VertexList[i]-1,2]:=Vertices[VertexList[i]-1,2]+DeltaY;
    Vertices[VertexList[i]-1,3]:=Vertices[VertexList[i]-1,3]+DeltaZ;
   end;//of for i/if/with/j
  end;//of isMove

  isZoom:begin
   DeltaX:=(DeltaX+ccX);
   DeltaY:=(DeltaY+ccY);
   DeltaZ:=(DeltaZ+ccZ);
   if (DeltaX>1000) or (DeltaY>1000) or (DeltaZ>1000) or
      (DeltaX<5) or (DeltaY<5) or (DeltaZ<5) then begin
    GlobalX:=100;GlobalY:=100;GlobalZ:=100;
    ed_ix.text:='100';ed_iy.text:='100';ed_iz.text:='100';
    PopFunction;
    exit;
   end;//of if
   GlobalX:=0;GlobalY:=0;GlobalZ:=0;
   vZoom(DeltaX,DeltaY,DeltaZ); //масштабирование
   RefreshWorkArea(Sender);
   GlobalX:=100;GlobalY:=100;GlobalZ:=100;
   ed_ix.text:='100';ed_iy.text:='100';ed_iz.text:='100';
   PopFunction;
   exit;
  end;//of isZoom

  isRotate:begin
   bx:=rb_xy.checked;by:=rb_yz.checked;bz:=rb_xz.checked;
   GlobalX:=0;GlobalY:=0;GlobalZ:=0;
   if not (Sender is TEdit) then begin PopFunction;exit;end;
   if TEdit(Sender)=ed_ix then begin
    rb_yz.checked:=true;
    GlobalX:=strtofloat(sx);
   end;//of if
   if TEdit(Sender)=ed_iy then begin
    rb_xz.checked:=true;
    GlobalY:=strtofloat(sy);
   end;//of if
   if TEdit(Sender)=ed_iz then begin
    rb_xy.checked:=true;
    GlobalZ:=strtofloat(sz);
   end;//of if
   OldMouseX:=0;OldMouseY:=0;
   vRotate(0,0);
   ed_ix.text:='0';
   ed_iy.text:='0';
   ed_iz.text:='0';
   rb_xy.checked:=bx;rb_yz.checked:=by;rb_xz.checked:=bz;
  end;//of isRotate

  isNormalRot:begin               //поворот нормалей
   bx:=rb_xy.checked;by:=rb_yz.checked;bz:=rb_xz.checked;
   GlobalX:=0;GlobalY:=0;GlobalZ:=0;
   if not (Sender is TEdit) then begin PopFunction;exit;end;
   if TEdit(Sender)=ed_ix then begin
    rb_yz.checked:=true;
    GlobalX:=strtofloat(sx);
   end;//of if
   if TEdit(Sender)=ed_iy then begin
    rb_xz.checked:=true;
    GlobalY:=strtofloat(sy);
   end;//of if
   if TEdit(Sender)=ed_iz then begin
    rb_xy.checked:=true;
    GlobalZ:=strtofloat(sz);
   end;//of if
   OldMouseX:=0;OldMouseY:=0;
   NInstrum.Rotate(GlobalX,GlobalY,GlobalZ);
   ApplySmoothGroups;
   ed_ix.text:='0';
   ed_iy.text:='0';
   ed_iz.text:='0';
   rb_xy.checked:=bx;rb_yz.checked:=by;rb_xz.checked:=bz;
  end;//of isNormalRot
 end;//of case


 //3. Прорисовка вершин
 FindCoordCenter;
 RefreshWorkArea(Sender);
 PopFunction;
end;

procedure Tfrm1.ed_ixKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=VK_RETURN then ed_ixExit(Sender);
end;

procedure Tfrm1.sb_irotClick(Sender: TObject);
begin
 PushFunction(54);
 InstrumStatus:=isRotate;
 CtrlA1.enabled:=false;
 ed_ix.text:='0';
 ed_iy.text:='0';
 ed_iz.text:='0';
 ed_ix.enabled:=true;
 ed_iy.enabled:=true;
 ed_iz.enabled:=true;
 GlobalX:=0;GlobalY:=0;GlobalZ:=0;
 PopFunction;
end;

procedure Tfrm1.sb_izoomClick(Sender: TObject);
begin
 InstrumStatus:=isZoom; //Масштабирование
 CtrlA1.enabled:=false;
 ed_ix.text:='100';ed_iy.text:='100';ed_iz.text:='100';
 ed_ix.enabled:=true;ed_iy.enabled:=true;ed_iz.enabled:=true;
end;

//Нажата кнопка "Сохранить"
procedure Tfrm1.StrlS1Click(Sender: TObject);
Var i,ii:integer;s:string;
begin
 PushFunction(55);
 IsModified:=false;               //все сохранено, нет модифицированного
 StrlS1.enabled:=false;
 sb_save.enabled:=false;
 //Вначале - скопируем обратно вершины
 if sb_animcross.visible then for i:=0 to CountOfGeosets-1 do
 for ii:=0 to Geosets[i].CountOfVertices-1 do begin
  Geosets[i].Vertices[ii]:=SFAVertices[i,ii];
 end;//of if/for i

 //Теперь проверим, отсортированы ли анимации.
 //Если нет - отсортируем их.
 if not SortSequences then begin
  if (EditorMode=emAnims) and (AnimEdMode=1) then begin
   sb_animundo.enabled:=false;
   CountOfUndo:=0;
   CountOfNewUndo:=0;
   NewUndo:=nil;
   CtrlZ1.enabled:=false;

{  s:='Вся линейка';
  for i:=0 to CountOfSequences-1 do s:=s+#13#10+Sequences[i].Name;
  for i:=0 to CountOfGlobalSequences-1 do
      s:=s+#13#10+inttostr(GlobalSequences[i]);
  cb_animlist.items.text:=s;
  cb_animlist.text:='Вся линейка';
  cb_animlist.tag:=0;
  cb_animlist.Font.Color:=clBlack;
  frm_obj.MakeSequencesList;       //создать список анимок
  IsListDown:=true;
  cb_animlist.ItemIndex:=0;
  cb_animlistChange(Sender);}
  end;//of if
 end;//of if

 //!dbg пока идет отладка
 if length(od_file.FileName)<4 then SaveMDL(od_file.FileName)
                               else begin
 //Так, длина достаточна. Проверим формат:
 if lowercase(copy(od_file.FileName,length(od_file.FileName)-3,4))='.mdx' then
    SaveMDX(od_file.FileName)
    else SaveMDL(od_file.FileName);
 end;//of if/else
 StrlS1.enabled:=false;
 sb_save.enabled:=false;
 if EditorMode=emAnims then DrawFrame(CurFrame);
 PopFunction;
end;

//Мелкая сетка
procedure Tfrm1.N12Click(Sender: TObject);
begin
 PushFunction(56);
 N12.Checked:=not N12.Checked;    //переключить состояние
 if N12.Checked then begin
  IsLowGrid:=true;
 end else begin//of if
  IsLowGrid:=false;
  glDisable(GL_DEPTH_TEST);
 end;//of if
 FindCoordCenter;
 RefreshWorkArea(Sender);
 PopFunction;
end;

//Сетка XZ
procedure Tfrm1.XZ1Click(Sender: TObject);
begin
 XZ1.checked:=not XZ1.Checked;
 IsXZGrid:=XZ1.checked;        //сетка
 RefreshWorkArea(Sender);
end;

procedure Tfrm1.YZ1Click(Sender: TObject);
begin
 YZ1.checked:=not YZ1.Checked;
 IsYZGrid:=YZ1.checked;        //сетка
 RefreshWorkArea(Sender);
end;

procedure Tfrm1.XY1Click(Sender: TObject);
begin
 XY1.checked:=not XY1.Checked;
 IsXYGrid:=XY1.checked;        //сетка
 RefreshWorkArea(Sender);
end;

//ShowAll
procedure Tfrm1.cb_showallClick(Sender: TObject);
Var i:integer;
begin
 PushFunction(57);
 IsShowAll:=cb_ShowAll.checked;
 pn_View.SetFocus;
 for i:=0 to clb_geolist.items.count-1 do with geoobjs[i] do begin
  IsSelected:=clb_geolist.Checked[i];//активность
  if IsShowAll then VisGeosets[i]:=true
               else VisGeosets[i]:=clb_geolist.Checked[i];
 end;//of for i
 //Теперь установка кнопок/инструментов
   l_childv.caption:='Связанных вершин: '+inttostr(GetSumCountOfChildVertices);
   l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelVertices);
   l_vcount.caption:='Всего вершин: '+inttostr(GetSumCountOfVertices);
   l_vhide.caption:='Скрыто: '+inttostr(GetSumCountOfHideVertices);
   l_triangles.caption:='Треугольников: '+inttostr(GetSumCountOfTriangles);
   EnableInstrums;
   if (GetSumCountOfSelVertices=0) and (EditorMode=emVertex) then begin
    sb_select.Down:=true;
    sb_selectClick(Sender);
   end;//of if
   SetCoordCenter;                //сброс координат
   CalcVertex2D(GLWorkArea.Clientheight);
   if AnimEdMode<>1 then begin
    CalcObjs2D(GLWorkArea.ClientHeight);//расчет координат
   end;//of if
 if EditorMode=emAnims then begin
  SetColorPanelState(Sender);
  if cb_filter.checked then cb_filterClick(Sender);
 end;//of if
 if ViewType=1 then begin
  ViewType:=0;
  N15Click(Sender);
  PopFunction;
  exit;
 end;//of if
 if ViewType=2 then begin
  ViewType:=0;
  IsShowTexError:=false;
  N16Click(Sender);
  IsShowTexError:=true;
 end else begin
  FindCoordCenter;
  DrawVertices(dc,hrc);
  glCallList(CurrentListNum);
  SwapBuffers(dc);
 end;//of if
 PopFunction;
end;

//сохранение под другим именем
procedure Tfrm1.N13Click(Sender: TObject);
begin
 PushFunction(58);
 if sd_file.execute then begin
  frm1.caption:='Редактор моделей - '+sd_file.filename;
  CopyFile(PChar(od_file.FileName),PChar(sd_file.FileName),false);
  od_file.filename:=sd_file.FileName;
  StrlS1Click(Sender);//сохранение
 end;//of if
 PopFunction;
end;

//производит перерисовку и обновление списка
//поверхностей после их удаления
procedure TFrm1.RefreshGeoList(Sender:TObject;dltFlg:boolean);
Var txt:string;i:integer;
    sv:array of boolean;
Begin
 PushFunction(59);
 //Если удалялись поверхности, обновить их список
 if dltFlg then begin
   txt:='';
   for i:=0 to CountOfGeosets-2 do txt:=txt+inttostr(i+1)+#13#10;
   txt:=txt+inttostr(CountOfGeosets);
   SetLength(sv,clb_geolist.Items.Count);
   for i:=0 to clb_geolist.Items.Count-1 do sv[i]:=clb_geolist.Checked[i];
   clb_geolist.items.text:=txt;
   if (Sender is TSpeedButton) and ((Sender as TSpeedButton)=b_detach)
   then begin
    for i:=0 to clb_geolist.Items.Count-2 do clb_geolist.Checked[i]:=sv[i];
    sv:=nil;
   end else begin
    for i:=0 to clb_geolist.Items.Count-1 do clb_geolist.Checked[i]:=false;
    clb_geolist.Checked[0]:=true;
   end;
   //Обновить второй (иерархический) список
   if (frm_obj.cb_tree.checked) and (frm_obj.lv_obj.Items.Item[0].StateIndex=3)
   then frm_obj.MakeGeosetsList(integer(frm_obj.lv_obj.Items.Item[0].Data))
   else frm_obj.MakeGeosetsList(-1);
 end;//of if
 //5. Приводим в соответствие кнопки
 EnableInstrums;
 //6. Прорисовываем новый вид поверхности
 cb_showallClick(Sender);
 PopFunction;
End;

//Удалить группу вершин
procedure Tfrm1.sb_delClick(Sender: TObject);
Var i,j:integer;
    dltFlg:boolean;
begin
 PushFunction(60);
 dltFlg:=false;
 //1. Сохраним для отмены
 SaveUndo(uVertexDelete);
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
  if not IsSelected then continue;
  //2. Удаляем все вершины последовательно
  for i:=0 to VertexCount-1 do DeleteVertex(j+1,VertexList[i]);
  //3. Удаляем остаток
  FinalizeDeleting(j+1);
  //4. Очищаем список выделенного
  VertexList:=nil;VertexCount:=0;
 end;//of for j
 for j:=0 to CountOfGeosets-1 do
  if Geosets[j].CountOfVertices=0 then begin
  GeoObjs[j].IsDelete:=true;
  dltFlg:=true;
 end;//of if/for
 if dltFlg then SaveUndo(uGeosetDelete);
 j:=0;
 while j<=CountOfGeosets-1 do with geoobjs[j] do begin
  //4a. Если не осталось вершин, удалить всю поверхность.
  if (Geosets[j].CountOfVertices=0) and (CountOfGeosets>1) then begin
   DeleteGeoset(j+1); //удалить поверхность со всеми атрибутами
   dltFlg:=true;
   j:=0;
   continue;
  end;//of if
  inc(j);
 end;//of while(j)

 //Если удалялись поверхности, обновить их список
 RefreshGeoList(Sender,dltFlg);
 PopFunction;
end;

//Сжать точки
procedure Tfrm1.b_collapseClick(Sender: TObject);
Var i,j:integer;
begin
 PushFunction(61);
 //1. Сохранить для отмены изменений
 SaveUndo(uVertexTrans);          //сохранение
 //2. Найти координаты центра выделенных вершин
 FindCoordCenter;                 //к-ты: ccX,ccY,ccZ
 for j:=0 to CountOfGeosets-1 do with geoobjs[j],geosets[j] do
 if IsSelected then
  //3. Все вершины сместить в центр
  for i:=0 to VertexCount-1 do begin
   Vertices[VertexList[i]-1,1]:=ccX;
   Vertices[VertexList[i]-1,2]:=ccY;
   Vertices[VertexList[i]-1,3]:=ccZ;
  end;//of for
 //4. Перерисовать
 FindCoordCenter;
 RefreshWorkArea(Sender);
 CalcVertex2D(GLWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

//слить вершины в одну
procedure Tfrm1.b_weldClick(Sender: TObject);
Var i,ii,j,jj,num,len:integer;
begin
 PushFunction(62);
 SaveUndo(uVertexDelete);         //сохранить для отмены
 FindCoordCenter;                 //найти к-ты центра вершин
 for jj:=0 to CountOfGeosets-1 do with Geosets[jj],geoobjs[jj] do begin
  if not IsSelected then continue;
  //1. Сдвигаем последнюю вершину
  Vertices[VertexList[VertexCount-1]-1,1]:=ccX;
  Vertices[VertexList[VertexCount-1]-1,2]:=ccY;
  Vertices[VertexList[VertexCount-1]-1,3]:=ccZ;
  num:=VertexList[VertexCount-1]-1;//запомним номер вершины
  //2. Удаляем ее из списка выделенных
  dec(VertexCount);
  //3. Во всех треугольниках все выделенные вершины
  //заменяем на данную
  for i:=0 to length(Faces)-1 do for ii:=0 to length(Faces[i])-1 do
   for j:=0 to VertexCount-1 do begin
    if Faces[i,ii]=(VertexList[j]-1) then Faces[i,ii]:=num;
  end;//of for j/ii/i
  //4. Удаляем остальные вершины
  for i:=0 to VertexCount-1 do DeleteVertex(jj+1,VertexList[i]);
  //5. Пометить треугольники, состоящие из совпадающих вершин
  //как "для удаления"
  for i:=0 to length(Faces)-1 do begin
   len:=length(Faces[i])-1;ii:=0;
   repeat
    if (Faces[i,ii]=Faces[i,ii+1]) and (Faces[i,ii]=Faces[i,ii+2]) then begin
     Faces[i,ii]:=-1;Faces[i,ii+1]:=-1;Faces[i,ii+2]:=-1;
    end;//of if
    ii:=ii+3;
   until ii>=len;
  end;//of for i
  //6. Завершить удаление
  FinalizeDeleting(jj+1);
  VertexList:=nil;VertexCount:=0;
 end;//of for jj
 //7. Привести в соответствие кнопки
 EnableInstrums;
 //8. Прорисовываем новый вид поверхности
 FindCoordCenter;
 RefreshWorkArea(Sender);
 CalcVertex2D(GLWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

//"Выдавливание" поверхности
procedure Tfrm1.b_extrudeClick(Sender: TObject);
Var j:integer;
begin
 PushFunction(63);
 //должен быть хотя бы 1 треугольник
{ if length(SelFaces)<3 then begin
  MessageBox(frm1.handle,'Нет полностью выделенных треугольников!',
             'Ошибка',MB_ICONEXCLAMATION or MB_APPLMODAL);
  exit;
 end;//of if}
 SaveUndo(uVertexDelete);
//2. Добавим новые точки (удвоение выделенного)
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
  if not IsSelected then continue;
  //1. Найти полностью выделенные треугольники
  FindSelectedFaces(j+1);
  if length(SelFaces)<3 then continue;
  OldCountOfVertices:=Geosets[j].CountOfVertices;
  AddVertices(j+1);
  //3. "Вытянуть" новые грани (добавить треугольники)
  Extrude(j+1);
 end;//of for j
 //4. Обновить поверхность
 l_vcount.caption:='Всего вершин: '+inttostr(GetSumCountOfVertices);
 l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelVertices);
 l_triangles.caption:='Треугольников: '+inttostr(GetSumCountOfTriangles);
 FindCoordCenter;
 RefreshWorkArea(Sender);
 CalcVertex2D(GLWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

procedure Tfrm1.b_texClick(Sender: TObject);
begin
 PushFunction(64);
 IsShowTexError:=true; //однократно
 IsExit:=false;
 frm_obj.Hide;
 frmTex.ShowModal;
 while (CountOfUndo>0) and
       ((Undo[CountOfUndo].Status1=uTexSelect) or
       (Undo[CountOfUndo].Status1=uTexVertexTrans) or
       (Undo[CountOfUndo].Status1=uTexUncouple)) do begin
  if Undo[CountOfUndo].Status1=uTexUncouple then begin
   CountOfUndo:=0;
   break;
  end;//of if
  dec(CountOfUndo);
 end;//of while
 EnableInstrums;
 wglMakeCurrent(dc,hrc);
 FindCoordCenter;
 DrawVertices(dc,hrc);
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
end;

//Спрятать выделенные вершины
procedure Tfrm1.b_hideClick(Sender: TObject);
Var i,j:integer;
begin
 PushFunction(65);
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do begin
  if not IsSelected then continue;
  for i:=0 to VertexCount-1 do if not IsVertexHide(j,VertexList[i]) then begin
   //Вершина не скрыта
   inc(HideVertexCount);
   SetLength(HideVertices,HideVertexCount);//подготовить место
   HideVertices[HideVertexCount-1]:=VertexList[i];//обозначить как скрытую
  end;//of for/if
  //Очистить список выделения
  VertexList:=nil;
  VertexCount:=0;
 end;//of for j
 b_hide.enabled:=false;
 b_showall.enabled:=true;
 sb_select.down:=true;sb_selectClick(Sender);
 EnableInstrums;
 FindCoordCenter;
 DrawVertices(dc,hrc);
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

//Показать все вершины
procedure Tfrm1.b_showallClick(Sender: TObject);
Var j:integer;
begin
 PushFunction(66);
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do if IsSelected then begin
  HideVertexCount:=0;HideVertices:=nil;
 end;//of for j
 l_vhide.caption:='Скрыто: 0';
 FindCoordCenter;
 DrawVertices(dc,hrc);
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GLWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

//включить рисование поверхности, а не сетки
procedure Tfrm1.N15Click(Sender: TObject);
Var flgs:integer;
begin
 PushFunction(67);
 if IsPlay then IsPlay:=false;
 if ViewType=1 then begin
  ViewType:=0;
  RefreshWorkArea(Sender);
  PopFunction;
  exit;
 end;//of if
 ViewType:=1; //Surface
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 CalcVertex2D(GlWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 glEnable(GL_DEPTH_TEST);        //глубина
 //Проверить, нужно ли отображать вершины
 if cb_vertices.checked then flgs:=4 else flgs:=0;
 AMake3DListFill{(dc,hrc,flgs)};    //создать 3D-список
 pb_redrawPaint(Sender);         //перерисовка
 PopFunction;
end;
{ TODO 2 -oАлексей -cГлюк : Общий вид иногда глючит! }
//Показ общего вида (с текстурой) моделей
procedure Tfrm1.N16Click(Sender: TObject);
Var dirName:string;ps,i,flgs:integer;
begin
 PushFunction(68);
 //Если Общий вид уже включен, убрать его
 if ViewType=2 then begin
  ViewType:=0;
  CalcVertex2D(GLWorkArea.Clientheight);
  if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
  FindCoordCenter;
  DrawVertices(dc,hrc);//чертить
  pb_redrawPaint(Sender);         //перерисовка
  PopFunction;
  exit;
 end;//of IsFullView
 //находим имя каталога с моделью
 CalcVertex2D(GlWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 dirName:=frm1.od_file.FileName;
 ps:=length(dirName);
 while (dirName[ps]<>'\') and (ps>0) do dec(ps);
 Delete(dirName,ps,length(dirName)-ps+1);
 //1. Создать списки текстур
 wglMakeCurrent(dc,hrc);
 IsShowTexError:=IsShowTexError and (EditorMode=emVertex);
 if not CreateAllTextures(dirName,r,g,b) then begin
  for i:=0 to CountOfTextures-1 do
      if Textures[i].pImg<>nil then begin
       FreeMem(Textures[i].pImg);
       Textures[i].pImg:=nil;
      end;//of if
  PopFunction;
  exit;
 end;//of if
 if EditorMode=emVertex then begin
  InitMatTransp;
  //Создание списка материалов
{  for i:=0 to CountOfMaterials-1 do if not MakeMaterialList(i) then begin
   PopFunction;
   exit;
  end;//of if/for
  AFormPrimitives(GLWorkArea.ClientHeight);//сформировать список примитивов
  SortPrimitives(PrSorted1,PrLength1);//пересортировка
  SortPrimitives(PrSorted2,PrLength2);//пересортировка
  //Проверить, нужно ли отображать вершины
  if cb_vertices.checked then flgs:=4 else flgs:=0;}
 end;//of if
 //Создание списка материалов
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  if ListNum>0 then glDeleteTextures(1,@ListNum);
  glGenTextures(1,@ListNum);       //номер текстурного списка
  glBindTexture(GL_TEXTURE_2D,ListNum);//создание списка
   glTexImage2D(GL_TEXTURE_2D,0,4,ImgWidth,
                ImgHeight,0,GL_RGBA,GL_UNSIGNED_BYTE,pImg);
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
   glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
 end;//of with/for i
 AFormPrimitives(GLWorkArea.ClientHeight);//сформировать список примитивов
 SortPrimitives(PrSorted1,PrLength1);//пересортировка
 SortPrimitives(PrSorted2,PrLength2);//пересортировка
 AMake3DListFill;       //создать 3D-список
 ViewType:=2;                    //общий вид включен
 pb_redrawPaint(Sender);         //перерисовка
 PopFunction;
end;

//При изменении размеров окна
procedure Tfrm1.FormResize(Sender: TObject);
const position:array[0..3] of GLfloat=(80,150,150,1.0);
      position1:array[0..3] of GLfloat=(0,0,0,1.0);
      amb:array[0..3] of GLFloat=(0.6,0.6,0.6,1);
var  clr:TColor;
begin
 if bExit then exit;
 PushFunction(69);
 sb_instrum.left:=frm1.ClientWidth-168;//инструменты
 GLWorkArea.width:=frm1.ClientWidth-168-GLWorkArea.left;

 pn_anim.top:=frm1.ClientHeight-78;
 GLWorkArea.height:=frm1.ClientHeight-78-GLWorkArea.top;
 pn_anim.width:=GLWorkArea.width;
 ud_frame.left:=pn_anim.width-17;
 ed_fnum.left:=ud_frame.left-49;
 label19.left:=ud_frame.left-39;
 ed_fps.left:=ed_fnum.left-55;
 cb_FPS.left:=ed_FPS.left;

 sb_instrum.height:=(pn_anim.top-sb_instrum.top)+pn_anim.height;
 //
 pn_objs.height:=sb_instrum.height-pn_objs.top-10;
 pn_objs.tag:=pn_objs.height;
 clb_geolist.height:=pn_objs.height-clb_geolist.top-2;
 CurView.Excentry:=GLWorkArea.width/GLWorkArea.height;//эксцентриситет
  wglMakeCurrent(0,0);
  wglDeleteContext(hrc);
  ReleaseDC(GLWorkArea.handle,dc);
  dc:=GetDC(GLWorkArea.handle);
  hrc:=wglCreateContext(dc);
  wglMakeCurrent(dc,hrc);         //начать вывод
  CurView.ApplyView;
  glLightfv(GL_LIGHT0,GL_POSITION,@position);
  glLightfv(GL_LIGHT1,GL_POSITION,@position1);
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT,@amb);
  clr:=frm1.Color;
  glClearColor((clr and $0FF)/255,((clr and $0FF00) shr 8)/255,
               ((clr and $0FF0000) shr 16)/255,1.0);//цвет фона
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  if length(geosets)=0 then SwapBuffers(dc);
  if length(geosets)<>0 then begin
   CalcVertex2D(GLWorkArea.ClientHeight);
   FindCoordCenter;
   DrawVertices(dc,hrc);
   glCallList(CurrentListNum); //вывод
   SwapBuffers(dc);
  end;//of if
  l_MaxFrame.left:=pb_anim.left+pb_anim.width;
  ed_FPS.left:=l_MaxFrame.left+8;
  cb_FPS.left:=l_MaxFrame.left+8;
  ud_frame.left:=ed_fnum.left+ed_fnum.width;
  pn_Color.top:=pn_objs.top+pn_objs.height;
  //создать совместимый контекст
  DeleteDC(pb_anim.tag);
  pb_anim.tag:=CreateCompatibleDC(pb_anim.Canvas.Handle);
  hbitmap:=CreateCompatibleBitmap(pb_anim.canvas.handle,pb_anim.width,
                                  pb_anim.height);
  SelectObject(pb_anim.tag,hBitmap);
  PopFunction;
end;

//Проверяет, не находится ли курсор мыши внутри
//рабочей области. Если да, возвр. false.
//Иначе - true
function IsNotMouseInWorkArea:boolean;
Var DeltaX,DeltaY:integer;pt:TPoint;
Begin with frm1 do begin
 GetCursorPos(pt);
 DeltaY:=frm1.top+frm1.height-frm1.ClientHeight;
 DeltaX:=frm1.left+frm1.width-frm1.ClientWidth;
 Result:=false;
 if pt.x>(DeltaX+GLWorkArea.left+GLWorkArea.width) then Result:=true;
 if pt.y>(DeltaY+GLWorkArea.top+GLWorkArea.height) then Result:=true;
end;End;

//Вращение колесика (масштаб)
procedure Tfrm1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
 if IsNotMouseInWorkArea or (length(GeoObjs)=0) then exit;
 PushFunction(70);
 if cb_animlist.focused then pn_View.SetFocus;
 OldMouseY:=20;                   //для вызова масшт.
 IsMouseDown:=true;IsWheel:=true;
 GLWorkAreaMouseMove(Sender,shift,0,0);//масштабирование
 IsMouseDown:=false;IsWheel:=false;
 CalcVertex2D(GLWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

procedure Tfrm1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
 if IsNotMouseInWorkArea or (length(GeoObjs)=0) then exit;
 PushFunction(71);
 if cb_animlist.focused or cb_bonelist.focused then pn_View.SetFocus;
 //Проверка на список поверхностей

 OldMouseY:=0;                   //для вызова масшт.
 IsMouseDown:=true;IsWheel:=true;
 GLWorkAreaMouseMove(Sender,shift,0,20);//масштабирование
 IsMouseDown:=false;IsWheel:=false;
 CalcVertex2D(GLWorkArea.ClientHeight);
 if AnimEdMode<>1 then CalcObjs2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

//Построение треугольника
procedure Tfrm1.sb_triangleClick(Sender: TObject);
Var len,len2,j:integer;
begin
 PushFunction(72);
 SaveUndo(uCreateTriangle);       //сохранить для отмены
 for j:=0 to CountOfGeosets-1 do with Geosets[j],geoobjs[j] do begin
  if not IsSelected or (VertexCount<>3) then continue; //проверка на ошибку
  len:=length(Faces);              //длина массива
  len2:=length(Faces[len-1]);
  SetLength(Faces[len-1],len2+3);  //увеличить на 3 (новый треуг.)
  //добавка нового треугольника
  Faces[len-1,len2]:=VertexList[0]-1;
  Faces[len-1,len2+1]:=VertexList[1]-1;
  Faces[len-1,len2+2]:=VertexList[2]-1;
 end;//of for j
 l_triangles.caption:='Треугольников: '+inttostr(GetSumCountOfTriangles);
 RefreshWorkArea(Sender);
 PopFunction;
end;

procedure Tfrm1.cb_colorChange(Sender: TObject);
Var index:integer;
const colors:array[1..13,1..3] of GLfloat=
      ((1,0,0),(0,0,1),(24/255,231/255,189/255),
       (82/255,0,132/255),(1,1,0),(1,138/255,8/255),
       (0,1,0),(231/255,89/255,173/255),(148/255,150/255,148/255),
       (123/255,190/255,247/255),
       (8/255,97/255,66/255),(74/255,40/2550,0),(0,0,0));
begin
 PushFunction(73);
 pn_view.SetFocus;
 //Определим цвет
 index:=cb_color.ItemIndex+1;
 cb_color.text:=cb_color.Items.Strings[index-1];
 if Index=0 then begin index:=1;cb_color.text:='Красный';end;
 r:=colors[index,1];g:=colors[index,2];b:=colors[index,3];
 ViewType:=0;
 N16Click(Sender);                //перерисовать
 PopFunction;
end;

//Копировать кусок поверхности в буфер
procedure Tfrm1.CtrlC1Click(Sender: TObject);
begin
 PushFunction(74);
 if sb_animcross.visible then begin//копирование кадра
  CtrlC2Click(Sender);
  PopFunction;
  exit;
 end;//of if
 CopyToInternalBuffer;            //во внутренний буфер
 CopyToExternalBuffer;            //во "внешний" буфер
 CtrlV1.enabled:=true;            //открыть пункт "вставить"
 sb_paste.enabled:=true;
 PopFunction;
end;

//Вставка куска текущей поверхности из буфера
procedure Tfrm1.CtrlV1Click(Sender: TObject);
begin
 PushFunction(75);
 if sb_animcross.visible then begin
  pn_view.SetFocus;
  CtrlV2Click(Sender);
  PopFunction;
  exit;
 end;//of if
 SaveUndo(uVertexDelete);         //сохранить для отмены
 sb_undo.enabled:=true;           //открыть кнопку
 CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;
 PasteFromInternalBuffer;         //произвести вставку
 EnableInstrums;
 //исправить информационные поля
 l_vcount.caption:='Всего вершин: '+
         inttostr(GetSumCountOfVertices);
 l_vselect.caption:='Выделено: '+inttostr(GetSumCountOfSelVertices);
 l_triangles.caption:='Треугольников: '+inttostr(GetSumCountOfTriangles);
 FindCoordCenter;
 CalcVertex2D(GLWorkArea.ClientHeight);
 DrawVertices(dc,hrc);
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
end;

//вставка новой поверхности из буфера
procedure Tfrm1.N17Click(Sender: TObject);
Var num,i:integer;
    txt:string;
begin
 PushFunction(76);
 num:=CountOfGeosets;
 SaveUndo(uCreateGeoset);         //сохранить для отмены
 PasteFromExternalBuffer;         //вставить новую поверхность
 if CountOfGeosets=num then begin PopFunction;exit;end;
 Geosets[CountOfGeosets-1].HierID:=-2;
 txt:='1';
 for i:=2 to CountOfGeosets do txt:=txt+#13#10+inttostr(i);
 //увеличить кол-во поверхностей
 clb_geolist.items.text:=txt;
 for i:=0 to clb_geolist.Items.Count-1 do clb_geolist.Checked[i]:=false;
 clb_geolist.checked[0]:=true;
 SetLength(VisGeosets,CountOfGeosets);//видимость поверхностей
 for i:=0 to CountOfGeosets-1 do with geosets[i],geoobjs[i] do begin
  VisGeosets[i]:=true;//видима новая поверхность
  color4f[1]:=1;
  color4f[2]:=1;
  color4f[3]:=1;
  color4f[4]:=1;
 end;//of with/for i
 //исправить информационные поля
 cb_showallClick(Sender);
 EnableInstrums;
 //Обновить второй (иерархический) список
 if (frm_obj.cb_tree.checked) and (frm_obj.lv_obj.Items.Item[0].StateIndex=3)
 then frm_obj.MakeGeosetsList(integer(frm_obj.lv_obj.Items.Item[0].Data))
 else frm_obj.MakeGeosetsList(-1);
 PopFunction;
end;

//Зеркало: отразить выделенные вершины
//относительно рабочей плоскости
procedure Tfrm1.sb_mirrorClick(Sender: TObject);
Var DeltaX,DeltaY,DeltaZ:GLfloat;
    i,j,num:integer;
begin
 PushFunction(77);
 SaveUndo(uVertexTrans);          //сохранить
 //1. Определяем плоскость отражения
 DeltaX:=0;DeltaY:=0;DeltaZ:=0;
 if rb_xy.checked then DeltaZ:=1;
 if rb_xz.checked then DeltaY:=1;
 if rb_yz.checked then DeltaX:=1;
 //2. Найти к-ты центра
 FindCoordCenter;                 //в ccX,ccY,ccZ
 //3. Отражение (нормали рассч. позже)
 for j:=0 to CountOfGeosets-1 do with geoobjs[j] do if IsSelected then 
 for i:=0 to VertexCount-1 do with Geosets[j] do begin
  num:=VertexList[i]-1;
  if DeltaX<>0 then Vertices[num,1]:=2*ccX-Vertices[num,1];
  if DeltaY<>0 then Vertices[num,2]:=2*ccY-Vertices[num,2];
  if DeltaZ<>0 then Vertices[num,3]:=2*ccZ-Vertices[num,3];
 end;//of with/for
 //4. Перерисовка
 FindCoordCenter;
 RefreshWorkArea(Sender);
 PopFunction;
end;

//Переключение на редактор Вершин
procedure Tfrm1.F11Click(Sender: TObject);
Var i,ii,jj:integer;
begin
 if EditorMode=emVertex then exit;
 PushFunction(78);
 sb_stopClick(Sender);
 application.processmessages;
 ObjAnimate.ClearRestricts;
 AnimEdMode:=1;
 iAnimEdMode:=AnimEdMode;        //для крэш-дампа
 frm_obj.Hide;
 if IsWoW then begin
  frm_obj.MakeGeosetsList(-1); //сформировать иерархический список
  H1.Enabled:=true;
  frm_obj.cb_tree.visible:=true;
  frm_obj.cb_tree.checked:=false;
 end else H1.Enabled:=false;
 pn_View.SetFocus;
 pn_Color.Visible:=false;
 InstrumStatus:=isSelect;
 CtrlA1.enabled:=true;
 IsPlay:=false;
 //кнопки/панели
 pn_anim.visible:=false;
 sb_cross.visible:=true;
 sb_copy.visible:=true;
 sb_paste.visible:=true;
 pn_instr.visible:=true;
 pn_seq.visible:=false;
 sb_animcross.visible:=false;
 b_hide.visible:=true;
 b_showall.visible:=true;
 tc_mode.visible:=false;
 sb_cross.visible:=true;
 sb_cross.down:=true;
 CtrlZ1.enabled:=false;
 CtrlV1.enabled:=false;
 CtrlC1.enabled:=true;
 N28.visible:=false;
 N2.enabled:=true;
 N17.enabled:=false;
 N19.enabled:=false;
 N37.visible:=true;
 pn_workplane.visible:=false;
 pn_binstrum.visible:=false;
 pn_boneprop.visible:=false;    //панели свойств
 pn_propobj.visible:=false;
 pn_contrprops.Hide;
 SplinePanel.Hide;
 pn_atchprop.visible:=false;
 pn_pre2prop.visible:=false;
 //Меню "Объекты":
 N33.visible:=false;              //скрыть само меню
 N44.visible:=false;
 pn_listbones.visible:=false;
 pn_vertcoords.visible:=false;

 sb_vattach.enabled:=false;
 sb_detach.enabled:=false;
 sb_crossClick(Sender);
 sb_undo.enabled:=false;
 sb_open.visible:=true;
 sb_undo.visible:=true;
 pn_boneedit.enabled:=false;
 pn_boneedit.visible:=false;
 sb_animundo.enabled:=false;
 sb_animundo.visible:=false;
 sb_undo.visible:=true;
 cb_filter.checked:=false;
 IsContrFilter:=false;
 cb_bonelist.Style:=csDropDown;
 application.ProcessMessages;  
 for i:=0 to CountOfGeosets-1 do begin
  Geosets[i].Color4f[1]:=1;
  Geosets[i].Color4f[2]:=1;
  Geosets[i].Color4f[3]:=1;
  Geosets[i].Color4f[4]:=1;
  Geosets[i].CountOfChildVertices:=0;
 end;//of for ii
 for jj:=0 to CountOfGeosets-1 do with geoobjs[jj] do begin
  CountOfUndo:=0;
  CountOfNewUndo:=0;
  NewUndo:=nil;
  VertexCount:=0;
 end;//of for jj
 pn_animparam.visible:=false;
 sb_crossClick(Sender);
 for i:=0 to CountOfGeosets-1 do
 for ii:=0 to Geosets[i].CountOfVertices-1 do begin
  Geosets[i].Vertices[ii]:=SFAVertices[i,ii];
 end;//of if/for i
 //Удаление текстурных списков:
 if EditorMode=emAnims then
 for i:=0 to CountOfTextures-1 do
 with Textures[i] do if ListNum>0 then glDeleteTextures(1,@ListNum);
 EditorMode:=emVertex;
 iEditorMode:=EditorMode;         //для крэш-дампа
 BuildPanels;
 cb_showallClick(Sender);
 CalcVertex2D(GLWorkArea.ClientHeight);
 FindCoordCenter;
 if ViewType<>2 then DrawVertices(dc,hrc);
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 frm_obj.lv_obj.tag:=-1;
 PopFunction;
end;


procedure TFrm1.DrawFrame(num:integer); //вывод кадра
Var flgs,svMinF,svMaxF:integer;
Begin
 PushFunction(79);
 if sb_animcross.visible then begin
  //Для всей линейки расчёт чуть другой
  svMinF:=MinFrame;
  svMaxF:=MaxFrame;
  if (CurFrame>0) and AnimPanel.IsAllLine(AnimPanel.ids) and
     (AnimPanel.FindActSeq(CurFrame)>=0) then begin
   MinFrame:=AnimPanel.MinF;
   MaxFrame:=AnimPanel.MaxF;
  end;//of if
  CalcAnimCoords(CurFrame);      //вывод кадра
  MinFrame:=svMinF;
  MaxFrame:=svMaxF;

//  CalcAnimCoords(num);                //нулевой кадр
 end;//of if

 //если нужно, пересчитать к-ты выделенных вершин
 if (AnimEdMode<>1) and pn_vertcoords.visible then begin
  FindVertCoordCenter;
  label41.caption:='X='+floattostrf(ccVX,ffFixed,10,5);
  label42.caption:='Y='+floattostrf(ccVY,ffFixed,10,5);
  label43.caption:='Z='+floattostrf(ccVZ,ffFixed,10,5);
 end;//of if

 //В редакторе движения изменить к-ты центра выделенных костей
 if (AnimEdMode=2) and SelObj.IsSelected and
    (InstrumStatus<>isBoneRot) and (InstrumStatus<>isBoneScaling) then begin
  if SelObj.IsMultiSelect then begin
   FindObjCoordCenter;
   ed_bonex.text:=floattostrf(ccX,ffFixed,10,5);
   ed_boney.text:=floattostrf(ccY,ffFixed,10,5);
   ed_bonez.text:=floattostrf(ccZ,ffFixed,10,5);
  end else begin
   SelObj.b:=GetSkelObjectById(SelObj.b.ObjectID);
   ed_bonex.text:=floattostrf(SelObj.b.AbsVector[1],ffFixed,10,5);
   ed_boney.text:=floattostrf(SelObj.b.AbsVector[2],ffFixed,10,5);
   ed_bonez.text:=floattostrf(SelObj.b.AbsVector[3],ffFixed,10,5);
  end;//of if 
 end;//of if

 TestFullView;
 if ViewType<>2 then begin
  if SelObj.IsSelected and SelObj.IsMultiSelect and (AnimEdMode<>1)
  then FindObjCoordCenter else FindCoordCenter;
  //Проверить, нужно ли отображать вершины
  if cb_vertices.checked then flgs:=4 else flgs:=0;
  if ViewType=1 then AMake3DListFill{(dc,hrc,flgs+2)}
                else DrawVertices(dc,hrc);
 end;//of if
 
 glCallList(CurrentListNum);
 SwapBuffers(dc);
 PopFunction;
End;

//Прорисовка анимационной шкалы
procedure DrawCurPos(CurFrame,dv:integer;PixelPerFrame:GLfloat);
Begin with frm1 do begin
 PushFunction(80);
 //Вывод текущей позиции
 pb_anim.Canvas.Pen.Color:=$FF;
 pb_anim.Canvas.Pen.Width:=2;
 pb_anim.Canvas.MoveTo(round(PixelPerFrame*(CurFrame-MinFrame)),1);
 pb_anim.Canvas.LineTo(round(PixelPerFrame*(CurFrame-MinFrame)),dv-1);
 pb_anim.Canvas.Pen.Color:=$888888;
 pb_anim.Canvas.Brush.Color:=$888888;
 pb_anim.Canvas.Rectangle(round(PixelPerFrame*(SelMinFrame-MinFrame)),dv shr 1,
         round(PixelPerFrame*(SelMaxFrame-MinFrame)),dv-1);
 PopFunction;
end;End;

procedure Tfrm1.pb_animPaint(Sender: TObject);
Var rect:TRect;i{,ii,MinDivision}:integer;
    dv,dv2:integer;
    PixelPerFrame:GLfloat;
    cdc:HDC;
begin
 //Очистка
 PushFunction(81);
 Division:=(MaxFrame-MinFrame) div 10;
 if Division=0 then begin
  Division:=1;
 end;
 pb_anim.Canvas.Pen.Width:=1;
 pb_anim.Canvas.Brush.Color:=pb_anim.Color;
 rect.Top:=0;rect.Left:=0;rect.Right:=pb_anim.width;
 rect.bottom:=pb_anim.height;
 pb_anim.Canvas.FillRect(rect);
 //рамка - прямоугольник
 pb_anim.Canvas.Brush.Color:=$FFFFFF; //цвет - белый
 pb_anim.canvas.Pen.Color:=$EE8888;
 rect.Left:=0;rect.Top:=0;rect.right:=pb_anim.width;
 rect.Bottom:=pb_anim.height shr 1;
 pb_anim.Canvas.FillRect(rect);
 pb_anim.canvas.Rectangle(rect);
 //Основная шкала
 pb_anim.Canvas.Pen.Color:=0;
 i:=MinFrame;dv2:=(pb_anim.height*3) shr 2;
 dv:=pb_anim.height shr 1;
 if abs(MaxFrame-MinFrame)<=1 then PixelPerFrame:=pb_anim.width
 else PixelPerFrame:=pb_anim.width/(MaxFrame-MinFrame);
 repeat
  asm
   fninit
  end;
  pb_anim.Canvas.MoveTo(round(PixelPerFrame*(i-MinFrame)),dv);
  pb_anim.Canvas.LineTo(round((i-MinFrame)*PixelPerFrame),dv2);
  pb_anim.Canvas.TextOut(round(PixelPerFrame*(i-MinFrame)),dv2-2,inttostr(i));
  i:=i+Division;
 until i>=MaxFrame;
 //Вывод последней черты
  pb_anim.Canvas.MoveTo(pb_anim.width-1,dv);
  pb_anim.Canvas.LineTo(pb_anim.width-1,dv2);
  l_maxFrame.caption:=inttostr(MaxFrame);
 //Вывод отметок ключевых кадров
 pb_anim.Canvas.Pen.Color:=clBlue;
 pb_anim.Canvas.pen.Width:=1;
 for i:=0 to Stamps.Count-1 do begin
  pb_anim.Canvas.MoveTo(trunc(PixelPerFrame*(Stamps.GetFrame(i)-MinFrame)),1);
  pb_anim.Canvas.LineTo(trunc(PixelPerFrame*(Stamps.GetFrame(i)-MinFrame)),dv-1);
 end;//of for i
 //Вывод последней отметки
 if (Stamps.Count>0) and
    (Stamps.GetFrame(Stamps.GetNearestLEquFrameIndex(MaxFrame))=MaxFrame)
 then begin
  pb_anim.Canvas.MoveTo(pb_anim.width-1,1);
  pb_anim.Canvas.LineTo(pb_anim.width-1,dv-1);
 end;//of if

 //Вывод выделения:
 //Копирование в массив слепка
 cdc:=pb_anim.tag;
 BitBlt(cdc,0,0,pb_anim.width,pb_anim.height,pb_anim.canvas.handle,0,0,SRCCOPY);
 DrawCurPos(CurFrame,dv,PixelPerFrame);
 //Вывести номер кадра
 ed_fnum.text:=inttostr(CurFrame);
 application.ProcessMessages;
 PopFunction;
end;

//Выделение блока кадров
procedure ReSelectFrames(OldCurFrame:integer;Shift:TShiftState);
Begin
  PushFunction(82);
  //Если нужно, выделить кадры
{  if (OldCurFrame<>SelMinFrame) and (OldCurFrame<>SelMaxFrame) then begin
   SelMinFrame:=CurFrame;
   SelMaxFrame:=CurFrame;
  end;//of if}
  if (ssShift in Shift) and
     not (((OldCurFrame=SelMinFrame) and (CurFrame=SelMaxFrame))
     or ((CurFrame=SelMinFrame) and (OldCurFrame=SelMaxFrame))) then begin
   if (OldCurFrame=SelMinFrame) or (OldCurFrame=SelMaxFrame) and
      (SelMaxFrame>CurFrame) then SelMinFrame:=CurFrame;
   if (OldCurFrame=SelMaxFrame) and
      (SelMinFrame<CurFrame) then SelMaxFrame:=CurFrame;
  end else begin     //выделять не нужно
   SelMinFrame:=CurFrame;
   SelMaxFrame:=CurFrame;
  end;//of if
  PopFunction;
End;

procedure Tfrm1.pb_animMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var PixelPerFrame:GLfloat;
    OldCurFrame:integer;
begin
 PushFunction(83);
 pn_view.SetFocus;
 //Проверка: может, нужно просто вызвать меню?
 if (not IsAnimMouseDown) and
    (pb_anim.Cursor=crArrow) and (button=mbRight) then begin
  PopupMenuFrames.Popup(pn_anim.left+pb_anim.left+x,
                        pn_anim.top+pb_anim.top+y);
  PopFunction;
  exit;
 end;//of if
 OldCurFrame:=CurFrame;
 
 //проверка кликов по шкале
 if (not IsAnimMouseDown) and (pb_anim.Cursor=crArrow) then begin
  PixelPerFrame:=pb_anim.width/(MaxFrame-MinFrame);

  //Проверим, где находится позиция клика:
  //Если на линейке, просто установить текущую позицию
  if y<=(pb_anim.height shr 1) then begin
   CurFrame:=round(x/PixelPerFrame)+MinFrame;
   if CurFrame>MaxFrame then CurFrame:=MaxFrame;
   if CurFrame<MinFrame then CurFrame:=MinFrame;
  end else begin
   //Ниже линейки. Сдвинуть к ближайшему КК
   if (round((CurFrame-MinFrame)*PixelPerFrame)>x)
   then CurFrame:=Stamps.GetPrevFrame(CurFrame)
   else CurFrame:=Stamps.GetNextFrame(CurFrame);
  end;//of if (тип сдвига)
  if CurFrame>MaxFrame then CurFrame:=MaxFrame;
  if CurFrame<MinFrame then CurFrame:=MinFrame;
  //Если нужно, выделить кадры
  ReSelectFrames(OldCurFrame,Shift);
  DrawFrame(CurFrame);
 end;//of if

 if not IsAnimMouseDown then begin
  pb_animpaint(Sender);
  pb_animMouseUp(Sender,mbLeft,[],0,0);
 end;
 IsAnimMouseDown:=true;
 if button=mbRight then IsAnimShift:=true;
 PopFunction;
end;

procedure Tfrm1.pb_animMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 PushFunction(84);
 IsAnimMouseDown:=false;IsAnimShift:=false;
 if (GLWorkArea.Cursor=crDefault) or
    (GLWorkArea.Cursor=crArrow) then SetColorPanelState(Sender);
 if (AnimEdMode=2) and ContrProps.IsVisible then begin
  label44.tag:=1;
  SetObjVisibilityProp;
  if ContrProps.IsVisible then begin
   SplinePanel.InitFromKF(ContrProps.id);
   BuildPanels;
  end;//of if
  label44.tag:=0;
 end;//of if
 ed_fnum.font.color:=clBlack;
 //Проверить, не ключевой ли кадр выбран
 if Stamps.IndexOf(pointer(CurFrame))>=0 then ed_fnum.font.color:=clBlue;
 DrawFrame(CurFrame);
 CalcObjs2D(frm1.GLWorkArea.ClientHeight);
 CalcVertex2D(frm1.GLWorkArea.ClientHeight);
 PopFunction;
end;

//Движение мыши по шкале
procedure Tfrm1.pb_animMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var PixelPerFrame:GLFloat;OldCurFrame:integer;
begin
 PushFunction(85);
 PixelPerFrame:=pb_anim.width/(MaxFrame-MinFrame);
 if Y>(pb_anim.height shr 1) then begin //мышь не на шкале
  IsAnimMouseDown:=false;
  pb_anim.Cursor:=crArrow;
  PopFunction;
  exit;
 end;//of if
 //Мышь на шкале. Проверим...
 if (not (ssRight in Shift)) and
    (not (ssLeft in Shift)) then IsAnimMouseDown:=false;
 if IsAnimMouseDown and (pb_anim.Cursor=crSizeWE) then begin
  OldCurFrame:=CurFrame;
  //передвинуть указатель позиции
  CurFrame:=round(x/PixelPerFrame)+MinFrame;
  if CurFrame>MaxFrame then CurFrame:=MaxFrame;
  if CurFrame<MinFrame then CurFrame:=MinFrame;
  if IsAnimShift then ReSelectFrames(OldCurFrame,[ssShift])
                 else ReSelectFrames(OldCurFrame,Shift);
  ed_fnum.text:=inttostr(CurFrame);//вывод номера кадра
//  pb_animPaint(Sender);
  BitBlt(pb_anim.Canvas.Handle,0,0,
         pb_anim.width,pb_anim.height,pb_anim.tag,0,0,SRCCOPY);
  DrawCurPos(CurFrame,pb_anim.height shr 1,PixelPerFrame);
 end;//of if
 if (x>=(round(PixelPerFrame*(CurFrame-MinFrame))-2)) and
    (x<=(round(PixelPerFrame*(CurFrame-MinFrame))+2)) then pb_anim.Cursor:=crSizeWE
    else pb_anim.Cursor:=crArrow;
 PopFunction;
end;

//Вспомогательная: пересобрать список КК
procedure TFrm1.ReFormStamps;
Var i,ii,len:integer;
Begin
 PushFunction(86);
 Stamps.Clear;                    //очистить список
 len:=length(Controllers);
 //Не добавляем глобальные последовательности
 for i:=0 to len-1 do begin
  if (Controllers[i].GlobalSeqId<>UsingGlobalSeq) or
     (IsContrFilter and (ContrFilter.IndexOf(pointer(i))<0))
  then continue;
  for ii:=0 to High(Controllers[i].Items)
  do Stamps.Add(Controllers[i].Items[ii].Frame);
 end;//of for i
 PopFunction;
End;

//Переключение режима
procedure Tfrm1.F31Click(Sender: TObject);
Var i,ii,jj,ps:integer;
    s,dirName:string;
begin
 if EditorMode=emAnims then exit; //уже в редакторе анимаций
 PushFunction(87);
 EditorMode:=emAnims;
 iEditorMode:=EditorMode;         //для крэш-дампа
 H1.enabled:=true;                //включить в любом случае
 frm_obj.Hide;                    //спрятать окно
 InstrumStatus:=-1;
 CtrlA1.enabled:=false;
 //Привести в соответствие режимы и кнопки
 sb_cross.visible:=false;
 pn_instr.visible:=false;
 sb_copy.visible:=false;
 sb_paste.visible:=false;
 F21.enabled:=false;
// N2.enabled:=false;
 pn_listbones.visible:=false;
 pn_vertcoords.visible:=false;
 N28.visible:=true;
 N37.visible:=false;
 //Меню "Объекты":
 N33.visible:=false;               //скрыть само меню
 CtrlZ1.enabled:=false;
 CtrlV1.enabled:=false;
 CtrlV2.enabled:=false;
 CtrlV3.enabled:=false;
 N17.enabled:=false;
 N19.enabled:=false;
 sb_animcopy.visible:=true;
 sb_animpaste.visible:=true;
 sb_animpaste.enabled:=false;
 sb_undo.visible:=false;
 pn_anim.visible:=true;
// sb_open.visible:=false;
 sb_animcross.visible:=true;sb_animcross.down:=true;
 b_hide.visible:=false;
 b_showall.visible:=false;
 tc_mode.visible:=true;
 tc_mode.TabIndex:=1;             //редактор анимок
 AnimEdMode:=1;                   //режим работы
 iAnimEdMode:=AnimEdMode;        //для крэш-дампа
 sb_undo.visible:=false;
 sb_animundo.visible:=true;
 sb_animundo.enabled:=false;
 IsContrFilter:=false;
 cb_filter.checked:=false;
 sb_animcrossClick(Sender);
 for jj:=0 to CountOfGeosets-1 do with geoobjs[jj] do begin
  VertexCount:=0;                  //сбросить выделение
  CountOfUndo:=0;                  //и это сбросить
  CountOfNewUndo:=0;
  NewUndo:=nil;
  HideVertexCount:=0;
 end;//of for jj     

 //Определить протяженность анимаций:
 MinFrame:=0;MaxFrame:=0;SumFrame:=0;
 for i:=0 to CountOfSequences-1 do begin
  if Sequences[i].IntervalEnd>MaxFrame then MaxFrame:=Sequences[i].IntervalEnd;
 end;//of for
 AbsMaxFrame:=MaxFrame;AbsMinFrame:=MinFrame;
 //Заполнить список ключевых кадров (из Controllers)
 UsingGlobalSeq:=-1;
 ReFormStamps;
 Division:=MaxFrame div 10;       //настройка
 CurFrame:=0;
 SelMinFrame:=0;SelMaxFrame:=0;
 pb_animPaint(Sender);            //перерисовать
 cb_animlist.tag:=0;
 EnableInstrums;
 //Заполнить список последовательностей.
 pn_seq.visible:=true;
{ s:='Вся линейка';
 for i:=0 to CountOfSequences-1 do s:=s+#13#10+Sequences[i].Name;
 for i:=0 to CountOfGlobalSequences-1 do
     s:=s+#13#10+inttostr(GlobalSequences[i]);
 cb_animlist.items.text:=s;}
 AnimPanel.MakeAnimList;
 cb_animlist.Items.Assign(AnimPanel.SeqList);
 cb_animlist.text:='Вся линейка';
 cb_animlist.tag:=0;
 cb_animlist.Font.Color:=clBlack;
 frm_obj.MakeSequencesList;       //создать список анимок
 CtrlC1.enabled:=true;
 //Инициализировать массив вершин SfaVertices
 SetLength(SFAVertices,CountOfGeosets);//размер

 //? Не знаю, почему, но при сборе этого кода
 //в единственный цикл, некоторые модели начинают глючить
 //Ладно, пока забудем...
{ for i:=0 to CountOfGeosets-1
 do SetLength(SFAVertices[i],Geosets[i].CountOfVertices);
 for i:=0 to CountOfGeosets-1 do for ii:=0 to Geosets[i].CountOfVertices-1
 do SFAVertices[i,ii]:=Geosets[i].Vertices[ii];}

 for i:=0 to CountOfGeosets-1 do begin
  SetLength(SFAVertices[i],Geosets[i].CountOfVertices);
  for ii:=0 to Geosets[i].CountOfVertices-1
  do SFAVertices[i,ii]:=Geosets[i].Vertices[ii];
 end;//of for i

 //Создать список всех текстур по слоям.
 //находим имя каталога с моделью
 dirName:=frm1.od_file.FileName;
 ps:=length(dirName);
 while (dirName[ps]<>'\') and (ps>0) do dec(ps);
 Delete(dirName,ps,length(dirName)-ps+1);
 //1. Создать списки текстур
 wglMakeCurrent(dc,hrc);
 if not CreateAllTextures(dirName,r,g,b) then begin
  for i:=0 to CountOfTextures-1 do
      if Textures[i].pImg<>nil then begin
       FreeMem(Textures[i].pImg);
       Textures[i].pImg:=nil;
      end;//of if
  PopFunction;
  exit;
 end;//of if
  //Создание списков текстур
  for i:=0 to CountOfTextures-1 do with Textures[i] do begin
   if ListNum>0 then glDeleteTextures(1,@ListNum);
   glGenTextures(1,@ListNum);       //номер текстурного списка
   glBindTexture(GL_TEXTURE_2D,ListNum);//создание списка
    glTexImage2D(GL_TEXTURE_2D,0,4,ImgWidth,
                 ImgHeight,0,GL_RGBA,GL_UNSIGNED_BYTE,pImg);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  end;//of with/for i
  //Заполнение полей слоёв - AAlpha и ATextureID.
  for i:=0 to CountOfMaterials-1 do for ii:=0 to Materials[i].CountOfLayers-1 do
  with Materials[i].Layers[ii] do begin
   if IsTextureStatic then ATextureID:=TextureID
   else ATextureID:=round(Controllers[NumOfTexGraph].Items[0].Data[1]);
   Materials[i].Layers[ii].AAlpha:=1; //если полагаться на With - сглючит!
  end;//of with/for ii/i
 //Формируем начальный список
 AFormPrimitives(frm1.GLWorkArea.ClientHeight);

 //Вывод соответствующего кадра
 NumOfSelBone:=0;
 IsListDown:=true;
 cb_animlist.ItemIndex:=0;
 cb_AnimlistChange(Sender);
 PopFunction;
end;

procedure Tfrm1.ed_fnumExit(Sender: TObject);
Var num,OldCurFrame:integer;
begin
 PushFunction(88);
 //Проверка: не цифра ли тут
 if not IsCipher(ed_fnum.text) then begin
  ed_fnum.text:=inttostr(CurFrame);
  ed_fnum.SelectAll;
  PopFunction;
  exit;
 end;//of if
 num:=round(strtofloat(ed_fnum.text));
 if (num<MinFrame) or (num>MaxFrame) then begin
  ed_fnum.text:=inttostr(CurFrame);
  ed_fnum.SelectAll;
  PopFunction;
  exit;
 end;//of if
 //Смена кадра
 OldCurFrame:=CurFrame;
 CurFrame:=num;
 ReSelectFrames(OldCurFrame,GlShift);
 pb_animpaint(Sender);
 pb_animMouseUp(Sender,mbLeft,[],0,0);
 ed_fnum.SelectAll;
 DrawFrame(CurFrame);
 PopFunction;
end;

procedure Tfrm1.ed_fnumKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=VK_RETURN then begin
  GlShift:=Shift;
  ed_fnumExit(Sender);
  GlShift:=[];
 end;
end;

//Смена анимационной линейки
procedure Tfrm1.cb_animlistChange(Sender: TObject);
Var index,GlSeqID:integer;
begin
 PushFunction(89);
 IsAnimShift:=false;

 //Выбрать нужную анимацию и установить содержимое панели
 //редактирования
 if cb_animlist.ItemIndex<0 then cb_animlist.ItemIndex:=0;
 AnimPanel.SelSeq(AnimPanel.SeqList.Objects[cb_animlist.ItemIndex]);
 SAnimPanelProps;
 pb_animpaint(Sender);
 pb_animMouseUp(Sender,mbLeft,[],0,0);
 PopFunction;
end;

//инструменты анимации
procedure Tfrm1.sb_animcrossClick(Sender: TObject);
begin
 PushFunction(90);
 if AnimEdMode<>1 then begin
  if pn_listbones.tag=1 then begin
   FindVertCoordCenter;
   label41.caption:='X='+floattostrf(ccVX,ffFixed,10,5);
   label42.caption:='Y='+floattostrf(ccVY,ffFixed,10,5);
   label43.caption:='Z='+floattostrf(ccVZ,ffFixed,10,5);
   pn_vertcoords.visible:=true;
   pn_listbones.visible:=true;
   pn_listbones.tag:=0;
  end;//of if
  pn_boneedit.visible:=true;
  pn_workplane.visible:=true;
  pn_binstrum.visible:=true;
  if SelObj.IsSelected and (not SelObj.IsMultiSelect)
  then case GetTypeObjByID(SelObj.b.ObjectID) of
   typHELP,typBONE:pn_boneprop.visible:=true;
   typATCH:pn_atchprop.visible:=true;
   typPRE2:pn_pre2prop.visible:=true;
  end;//of case/if
  if SelObj.IsSelected and (AnimEdMode=2) and (not SelObj.IsMultiSelect)
  then begin
   pn_boneprop.visible:=false;
   pn_atchprop.visible:=false;
   pn_pre2prop.visible:=false;
   pn_propobj.visible:=true;
   SetVisPanelActive;
   if ContrProps.IsVisible then pn_contrprops.visible:=true;
   if SplinePanel.IsVisible then pn_spline.visible:=true;
  end;
 end else begin
  pn_seq.visible:=true;
  pn_color.visible:=true;
 end;
 BuildPanels;
 pn_objs.visible:=true;
 pn_stat.visible:=false;
 pn_zoom.visible:=false;
 GLWorkArea.Cursor:=crArrow;
 //пересчитать вершины
 CalcVertex2D(GLWorkArea.ClientHeight);
 CalcObjs2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

//Проигрывать анимцию
procedure Tfrm1.sb_playClick(Sender: TObject);
Var i,ii,time,svMinF,svMaxF:integer;
    PixelPerFrame:GLfloat;
    OldInstVis:boolean;
begin
 //Приводим панели:
 PushFunction(91);
 OldInstVis:=pn_binstrum.Visible;
 pn_binstrum.Visible:=false;
 sb_selbone.down:=true;
 BuildPanels;
 pn_Color.visible:=false;
 sb_play.visible:=false;
 sb_stop.visible:=true;
 pb_animpaint(Sender);
 pb_animMouseUp(Sender,mbLeft,[],0,0);
 SumFrame:=0;

 //Смотрим, как должны увеличиваться кадры
 IsPlay:=true;                    //анимация идет
 if cb_FPS.checked then time:=round(strtofloat(ed_FPS.text))
 else time:=GetTickCount-CurFrame;    //считать время
 repeat                          //цикл анимации
  if cb_FPS.checked then begin
   SumFrame:=SumFrame+time;
   CurFrame:=CurFrame+time;
  end else begin
   SumFrame:=GetTickCount;
   CurFrame:=GetTickCount-time;   //вычислить номер кадра
  end;//of if
  if (CurFrame>MaxFrame) or (CurFrame<MinFrame) then begin//конец линейки
   CurFrame:=MinFrame;
   if not cb_FPS.checked then time:=GetTickCount-CurFrame;    //считать время
  end;//of if

  svMinF:=MinFrame;
  svMaxF:=MaxFrame;
  //Для всей линейки расчёт чуть другой
  if AnimPanel.IsAllLine(AnimPanel.ids) and (AnimPanel.FindActSeq(CurFrame)>=0)
  then begin
   MinFrame:=AnimPanel.MinF;
   MaxFrame:=AnimPanel.MaxF;
  end;//of if
  CalcAnimCoords(CurFrame);      //вывод кадра
  MinFrame:=svMinF;
  MaxFrame:=svMaxF;
  TestFullView;
  if ViewType<>2 then begin
   if ViewType=0 then DrawVertices(dc,hrc)
                 else AMake3DListFill{(dc,hrc,2)};
  end;//of if (not FullView)
  glCallList(CurrentListNum);
  SwapBuffers(dc);
  PixelPerFrame:=pb_anim.width/(MaxFrame-MinFrame);
  BitBlt(pb_anim.Canvas.Handle,0,0,
         pb_anim.width,pb_anim.height,pb_anim.tag,0,0,SRCCOPY);
  pb_anim.Canvas.Pen.Color:=$FF;
  pb_anim.Canvas.Pen.Width:=2;
  pb_anim.Canvas.MoveTo(round(PixelPerFrame*(CurFrame-MinFrame)),1);
  pb_anim.Canvas.LineTo(round(PixelPerFrame*(CurFrame-MinFrame)),
                        (pb_anim.height shr 1)-1);
  application.processmessages;   //обработать сообщения
 until not IsPlay;               //пока не остановят

 //Проигрывание окончено
 //Вернуть вершины на место
 if EditorMode=emVertex then begin PopFunction;exit; end else begin
  for i:=0 to CountOfGeosets-1 do
  for ii:=0 to Geosets[i].CountOfVertices-1 do begin
   Geosets[i].Vertices[ii]:=SFAVertices[i,ii];
  end;//of for i

  sb_stop.visible:=false;sb_play.visible:=true;
  SelMinFrame:=CurFrame;SelMaxFrame:=CurFrame;
  if AnimEdMode=2 then begin
   if OldInstVis then pn_binstrum.visible:=true;
   case InstrumStatus of
    isBoneMove:sb_bonemove.down:=true;
    isBoneRot:sb_bonerot.down:=true;
    isBoneScaling:sb_bonescale.down:=true;
   end;//of case
  end;//of if
  BuildPanels;
  pb_animPaint(Sender);
  pb_animMouseUp(Sender,mbLeft,[],0,0);
 end;//of if
 PopFunction;
end;

//Остановить анимацию
procedure Tfrm1.sb_stopClick(Sender: TObject);
begin
 IsPlay:=false;
 if (GLWorkArea.Cursor=crArrow) or
    (GLWorkArea.Cursor=crDefault) then pn_Color.visible:=true;
end;

procedure Tfrm1.cb_FPSClick(Sender: TObject);
begin
 IsPlay:=false;
 ed_FPS.visible:=cb_FPS.checked;
end;

//Ввод нового интервала
procedure Tfrm1.ed_FPSExit(Sender: TObject);
Var num:integer;
begin
 PushFunction(92);
 if not IsCipher(ed_FPS.text) then begin
  ed_FPS.text:='10';
  ed_FPS.SelectAll;
  PopFunction;
  exit;
 end;//of if
 //Введено число
 num:=round(strtofloat(ed_FPS.text));
 if (num>100) or (num<1) then begin
  ed_FPS.text:='10';
  ed_FPS.SelectAll;
  PopFunction;
  exit;
 end;//of if
 IsPlay:=false;                   //отключить проигрывание
 ed_FPS.text:=inttostr(num);
 ed_FPS.SelectAll;
 PopFunction;
end;

//Фильтр: ключевые клавиши не сработают!
procedure Tfrm1.ed_FPSKeyPress(Sender: TObject; var Key: Char);
begin
 if (not (key in ['0'..'9'])) and (key>#30) then key:=#0;
end;

procedure Tfrm1.ed_FPSKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=VK_RETURN then ed_FPSExit(Sender);
end;

//Смена однократности
procedure Tfrm1.cb_nonloopingClick(Sender: TObject);
begin
 PushFunction(93);
 if pn_seq.tag=0 then begin
  AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
  GraphSaveUndo;
  AnimPanel.Seq.IsNonLooping:=cb_nonlooping.checked;
  AnimPanel.SSeq;
 end;//of if
 PopFunction;
end;

//Редкость
procedure Tfrm1.cb_UseRarityClick(Sender: TObject);
begin
 PushFunction(94);
 if pn_seq.tag=0 then begin
  AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
  GraphSaveUndo;

  pn_rarity.visible:=cb_UseRarity.checked;
  if cb_UseRarity.checked then AnimPanel.Seq.Rarity:=strtoint(ed_rarity.text)
                          else AnimPanel.Seq.Rarity:=-1;
  AnimPanel.SSeq;
 end;//of if
 PopFunction;
end;

//Изменение скорости
procedure Tfrm1.cb_UseMoveSpeedClick(Sender: TObject);
begin
 PushFunction(95);
 if pn_seq.tag=0 then begin
  AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
  GraphSaveUndo;

  pn_MoveSpeed.visible:=cb_UseMoveSpeed.checked;
  if cb_UseMoveSpeed.checked then AnimPanel.Seq.MoveSpeed:=strtoint(ed_MoveSpeed.text)
                             else AnimPanel.Seq.MoveSpeed:=-1;
  AnimPanel.SSeq;
 end;//of if
 PopFunction;
end;

procedure Tfrm1.ed_MoveSpeedExit(Sender: TObject);
Var num:integer;
begin
 PushFunction(96);
 if ed_MoveSpeed.text='' then begin
  ed_MoveSpeed.text:=inttostr(AnimPanel.Seq.MoveSpeed);
  ed_MoveSpeed.SelectAll;
  PopFunction;
  exit;
 end;//of if
 num:=round(strtofloat(ed_MoveSpeed.text));
 if (Num<0) or (num>700) or
    (abs(num-AnimPanel.Seq.MoveSpeed)<1) then begin
  ed_MoveSpeed.text:=inttostr(AnimPanel.Seq.MoveSpeed);
  ed_MoveSpeed.SelectAll;
  PopFunction;
  exit;
 end;//of if
 if pn_seq.tag=0 then begin
  AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
  GraphSaveUndo;

  ed_MoveSpeed.text:=inttostr(num);
  ed_MoveSpeed.SelectAll;
  AnimPanel.Seq.MoveSpeed:=num;
  AnimPanel.SSeq;
 end;//of if
 PopFunction;
end;

procedure Tfrm1.ed_MoveSpeedKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (key=vk_delete) then key:=0;
 if key=VK_RETURN then ed_MoveSpeedExit(Sender);
end;

procedure Tfrm1.ed_minframeExit(Sender: TObject);
Var num:integer;
begin
 if pn_seq.tag<>0 then exit;
 PushFunction(97);
 if ed_minframe.text='' then begin
  ed_MinFrame.text:=inttostr(AnimPanel.Seq.IntervalStart);
  ed_MinFrame.SelectAll;
  PopFunction;
  exit;
 end;//of if
 num:=round(strtofloat(ed_MinFrame.text));
 //Тест: изменилось ли вообще число и не меньше ли оно нуля 
 if (Num<=0) or (num=AnimPanel.Seq.IntervalStart) then begin
  ed_MinFrame.text:=inttostr(AnimPanel.Seq.IntervalStart);
  ed_MinFrame.SelectAll;
  PopFunction;
  exit;
 end;//of if

 //Теперь начинаем работу...
 AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
 GraphSaveUndo;
 //Тест на превышение макс. кадра
 if (num>AbsMaxFrame) or
    (num>=strtoint(ed_MaxFrame.text)) then begin
  ed_MaxFrame.text:=inttostr(num);
  MaxFrame:=num;
  if MaxFrame>AbsMaxFrame then AbsMaxFrame:=MaxFrame;
  AnimPanel.Seq.IntervalEnd:=num;
 end;//of if
 ed_MinFrame.text:=inttostr(num);
 ed_MinFrame.SelectAll;
 //Применить новые настройки
 MinFrame:=num;
 AnimPanel.Seq.IntervalStart:=num;
 AnimPanel.SSeq;
 if CurFrame<MinFrame then CurFrame:=MinFrame;
 if CurFrame>MaxFrame then CurFrame:=MaxFrame;
 IsListDown:=true;
 cb_animlistChange(Sender);
 PopFunction;
end;

procedure Tfrm1.ed_minframeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (key=vk_delete) then key:=0;
 if key=VK_RETURN then ed_minframeExit(sender);
end;

//Верхний кадр последовательности
procedure Tfrm1.ed_maxframeExit(Sender: TObject);
Var num,GlSeqID:integer;
begin
 if pn_seq.tag<>0 then exit;
 PushFunction(98);
 if ed_maxframe.text='' then num:=0
 else num:=round(strtofloat(ed_MaxFrame.text));

 //"обычная" последовательность
 if (num>3600000) or (ed_maxframe.text='') or
    (num=AnimPanel.Seq.IntervalEnd) then begin
  ed_MaxFrame.text:=inttostr(AnimPanel.Seq.IntervalEnd);
  ed_MaxFrame.SelectAll;
  PopFunction;
  exit;
 end;
 AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
 GraphSaveUndo;

 if (num<=MinFrame) then begin
  MinFrame:=num;
  ed_MinFrame.text:=inttostr(MinFrame);
  AnimPanel.Seq.IntervalStart:=num;
  if MinFrame>CurFrame then CurFrame:=MinFrame;
 end;//of if
 //Применить параметры
 if MaxFrame>AbsMaxFrame then AbsMaxFrame:=MaxFrame;
 AnimPanel.Seq.IntervalEnd:=num;
 AnimPanel.SSeq;
 if AnimPanel.IsAnimGlob(AnimPanel.ids) then begin
  AnimPanel.SeqList.Strings[AnimPanel.GSelSeqIndex]:=inttostr(AnimPanel.Seq.IntervalEnd);
  cb_animlist.items.Assign(AnimPanel.SeqList);
  cb_animlist.ItemIndex:=AnimPanel.GSelSeqIndex;
 end;//of if
 if CurFrame>MaxFrame then CurFrame:=MaxFrame;
 IsListDown:=true;
 cb_animlistChange(Sender);
 PopFunction;
end;

//Смена имени последовательности
procedure Tfrm1.cb_animlistExit(Sender: TObject);
begin
 PushFunction(99);
 //0. Отслеживание особых ситуаций
 if cb_animlist.text='' then begin
  cb_animlist.text:=AnimPanel.Seq.Name;
 end;//of if

 //1. При ошибке
 if (cb_animlist.ItemIndex<0) and
    (AnimPanel.IsAllLine(AnimPanel.ids) or AnimPanel.IsAnimGlob(AnimPanel.ids))
 then begin
  cb_animlist.ItemIndex:=AnimPanel.GSelSeqIndex;
  PopFunction;
  exit;
 end;

 //4. Проверка: изменилось ли имя
 if cb_animlist.text=AnimPanel.Seq.Name then begin
  PopFunction;
  exit;
 end;

 //Изменилось. Меняем.
 cb_animlist.SelectAll;
 AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
 GraphSaveUndo;
{ sb_animundo.enabled:=true;
 CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;}

 AnimPanel.Seq.Name:=cb_animlist.text;
 AnimPanel.SSeq;
 AnimPanel.MakeAnimList;
 cb_animlist.items.Assign(AnimPanel.SeqList);
 cb_animlist.ItemIndex:=AnimPanel.GSelSeqIndex;

 application.processmessages;
 frm_obj.ChangeSeqName(AnimPanel.ids);
 PopFunction;
end;

procedure Tfrm1.cb_animlistKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (key=vk_delete) or (key=192) then key:=0;
 if key=VK_RETURN then cb_animlistExit(Sender);
end;

//Создать новую последовательность
procedure Tfrm1.b_animCreateClick(Sender: TObject);
Var i:integer;bGl:boolean;
begin
 PushFunction(100);
 bGl:=(Sender is TButton) and (TButton(Sender)=b_GlobalCreate);

 if bGl then AnimSaveUndo(uCreateSeq,FLG_GLOBAL or CountOfGlobalSequences)
 else AnimSaveUndo(uCreateSeq,CountOfSequences);
 GraphSaveUndo;

 //Установим парметры
 with AnimPanel.Seq do begin
  Name:='New';
  //Страртовый интервал округляется по границе 1000 кадров
  if bGl then IntervalStart:=0
  else IntervalStart:=AbsMaxFrame+1000-(AbsMaxFrame mod 1000);
  //Определить размер новой анимации
  if CtrlV2.enabled and (length(FrameBuffer)>0) then
   IntervalEnd:=IntervalStart+GetLenOfFrameBuffer
  else IntervalEnd:=IntervalStart+10;
  if not bGl then AbsMaxFrame:=IntervalEnd;
  Rarity:=-1;
  IsNonLooping:=false;
  Bounds:=AnimBounds;             //границы анимации
 end;//of with
 if bGl then AnimPanel.InsertSeq(true,CountOfGlobalSequences)
 else AnimPanel.InsertSeq(false,CountOfSequences);
 AnimPanel.MakeAnimList;
 cb_animlist.items.Assign(AnimPanel.SeqList);
 if bGl then AnimPanel.SelSeq(FLG_GLOBAL or CountOfGlobalSequences-1)
 else AnimPanel.SelSeq(CountOfSequences-1);
 cb_animlist.ItemIndex:=AnimPanel.GSelSeqIndex;
 frm_obj.MakeSequencesList;

 IsListDown:=true;
 cb_animlistChange(Sender);
 PopFunction;
end;

//Удаление последовательности
procedure Tfrm1.b_animDeleteClick(Sender: TObject);
Var num,i,j,len:integer;
begin
 PushFunction(101);
 AnimSaveUndo(uDeleteSeq,AnimPanel.ids);

 GraphSaveUndo;
 AnimPanel.DelSeq;                //удалить последовательность
 AnimPanel.MakeAnimList;
 cb_animlist.items.Assign(AnimPanel.SeqList);
 cb_animlist.ItemIndex:=0;
 IsListDown:=true;
 cb_animlistChange(Sender);
 PopFunction;
end;

//Функция, используемая для сортировки списка
function CmpFunc(List:TStringList;num1,num2:integer):integer;
Var nn1,nn2:integer;
Begin
 PushFunction(102);
 Result:=0;
 nn1:=GetTypeObjByID(integer(List.Objects[num1]));
 nn2:=GetTypeObjByID(integer(List.Objects[num2]));
 nn1:=nn1 and $FFFFFF00;
 nn2:=nn2 and $FFFFFF00;
 if nn1=nn2 then begin
  if List.Strings[num1]<List.Strings[num2] then begin
   Result:=-1;
   PopFunction;
   exit;
  end;//of if
  if List.Strings[num1]=List.Strings[num2] then begin
   Result:=0;
   PopFunction;
   exit;
  end;//of if
  if List.Strings[num1]>List.Strings[num2] then begin
   Result:=1;
   PopFunction;
   exit;
  end;//of if
 end;//of if
 if nn1<nn2 then begin
  Result:=-1;
  PopFunction;
  exit;
 end;//of if
 if nn1>nn2 then begin
  Result:=1;
  PopFunction;
  exit;
 end;//of if
 PopFunction;
End;

//Вспомогательная: составляет список объектов
//(куда включаются все объекты).
//Этот список сортируется по алфавиту(+по типу объектов)
//С каждой строкой списка связывается ID объекта
//И весь список засовывается в cb_bonelist.
procedure Tfrm1.MakeTextObjList(Sender:TObject);
Var lst:TStringList;i:integer;
Begin
 PushFunction(103);
 lst:=TStringList.Create;         //создать временный список

 //Начинаем заполнение списка (кость-заглушку не включать!)
 for i:=0 to CountOfBones-1
 do if (not NullBone.IsExists) or (NullBone.IdInBones<>i)
 then lst.AddObject(Bones[i].Name,TObject(Bones[i].ObjectID));
 
 for i:=0 to CountOfHelpers-1
 do lst.AddObject(Helpers[i].Name,TObject(Helpers[i].ObjectID));
 for i:=0 to CountOfAttachments-1
 do lst.AddObject(Attachments[i].Skel.Name,
                  TObject(Attachments[i].Skel.ObjectID));
 for i:=0 to CountOfParticleEmitters-1
 do lst.AddObject(pre2[i].Skel.Name,TObject(pre2[i].Skel.ObjectID));
 //Теперь сортируем полученный список
 lst.CustomSort(CmpFunc);
 //Переносим его в ComboBox
 cb_bonelist.Items.Assign(lst);

 lst.Free;                        //освободить временный список
 PopFunction;
End;

//Снять выделение со всех объектов
//(затрагивает только панели инструментов)
procedure TFrm1.DeselectObject;
Begin
  PushFunction(104);
  sb_objdel.enabled:=false;
  sb_bonemove.enabled:=false;
  sb_bonerot.enabled:=false;
  sb_bonescale.enabled:=false;
  sb_begattach.enabled:=false;
  sb_detach.enabled:=false;
  cb_bonelist.tag:=1;
  cb_bonelist.text:='';
  cb_bonelist.tag:=0;
  pn_atchprop.visible:=false;
  pn_pre2prop.visible:=false;
  pn_boneprop.visible:=false;
  pn_propobj.visible:=false;
  pn_contrprops.Hide;
  SplinePanel.Hide;
  l_childv.caption:='Связанных вершин: 0';
  ed_bonex.enabled:=false; ed_bonex.text:='';
  ed_boney.enabled:=false; ed_boney.text:='';
  ed_bonez.enabled:=false; ed_bonez.text:='';
  SelObj.IsSelected:=false;
  SelObj.b.ObjectID:=-1;
  BuildPanels;
  PopFunction;
End;


//Выделяет объект с указанным ID (+ графика)
procedure TFrm1.GraphSelectObject(ID:integer);
Var iTmp:integer;
    IsChain:boolean;
const tpo='Тип объекта - ';
Begin
 IsMayChange:=false;

 //-1. Проверить на особые ситуации
 if id<0 then begin
  DeselectObject;
  exit;
 end;//of if

 //0. Сохранить для отмены
 PushFunction(105);
 if SelObj.b.ObjectID>=0 then begin
  AnimSaveUndo(uSelectObject,0);   //выделение нового объекта
  sb_animundo.enabled:=true;
  CtrlZ1.enabled:=true;
 end;//of if
 //1. Собственно выделение (заполнение массивов)
 IsChain:=SelObj.IsSelected and (SelObj.IDInComps>=0);//учёт цепочки
 iTmp:=SelObj.IDInComps;          //сохранить значение
 SelectSkelObj(id);               //Начальное заполнение
 if IsChain then SelObj.IDInComps:=iTmp;//восстановить значение
 CalcObjs2D(GLWorkArea.ClientHeight);//расчёт данных объектов

 //2. Установка панелей и пр.
 cb_billboard.tag:=1;
 cb_abillboard.tag:=0;
 case GetTypeObjByID(id) of
  typHELP:begin
   label30.caption:=tpo+'Помощник';
   pn_boneprop.visible:=true;
   pn_atchprop.visible:=false;
   pn_pre2prop.visible:=false;
   cb_billboard.checked:=SelObj.b.IsBillboarded;
  end;                            //of typHELP
  typBONE:begin
   label30.caption:=tpo+'Кость';
   pn_boneprop.visible:=true;
   pn_atchprop.visible:=false;
   pn_pre2prop.visible:=false;
   cb_billboard.checked:=SelObj.b.IsBillboarded;
  end;                            //of typBONE
  typATCH:begin
   label30.caption:=tpo+'Крепление';
   pn_boneprop.visible:=false;
   pn_atchprop.visible:=true;
   pn_pre2prop.visible:=false;
   cb_abillboard.checked:=SelObj.b.IsBillboarded;
   ed_path.text:=
     Attachments[SelObj.b.ObjectID-Attachments[0].Skel.ObjectID].Path;
  end;                            //of typATCH
  typPRE2:begin
   label30.caption:=tpo+'Ист. частиц';
   pn_boneprop.visible:=false;
   pn_atchprop.visible:=false;
   pn_pre2prop.visible:=true;
  end;                            //of typPRE2
 end;//of case

 //добавочная (общая) панель свойств
 if AnimEdMode=2 then begin
  label44.Tag:=1;
  sb_bonemove.enabled:=true;
  sb_bonerot.enabled:=true;
  sb_bonescale.enabled:=true;
  pn_atchprop.visible:=false;
  pn_pre2prop.visible:=false;
  pn_boneprop.visible:=false;
  pn_propobj.visible:=true;
  SetVisPanelActive;
  cb_objvis.tag:=1;

  //Установка параметров свойств объекта
  if SelObj.b.Visibility<0 then begin  //видимость объекта
   cb_objvis.enabled:=false;
   cb_objvis.checked:=true;
   cb_objvis.tag:=0;
   b_visanimate.visible:=true;
  end else begin
   cb_objvis.enabled:=true;
   cb_objvis.checked:=false;
   cb_objvis.tag:=0;
   b_visanimate.visible:=false;
  end;//of if

  //Установка флажков ограничений и видимости

  SetObjVisibilityProp;
  SetVisPanelActive;
  if ContrProps.IsVisible then begin
   SplinePanel.InitFromKF(ContrProps.id);
{ TODO -oАлексей -cГлюк : Здесь находится глюк от MG }
   BuildPanels;
  end;//of if
  cb_mover.checked:=ObjAnimate.IsMoveRestrict(SelObj.b.ObjectID);
  cb_rotationr.checked:=ObjAnimate.IsRotRestrict(SelObj.b.ObjectID);
  cb_scalingr.checked:=ObjAnimate.IsScRestrict(SelObj.b.ObjectID);
  ApplyInstrumRestrictions;
  label44.tag:=0;

  //Высвечивание панели свойств контроллера
  pn_contrprops.visible:=false;
  ContrProps.OnlyOnOff:=false;
  if sb_selbone.down and (SelObj.b.Visibility>=0)
  then begin
   ContrProps.OnlyOnOff:=true;
   ContrProps.SetCaptionAndId(SelObj.b.Name,'Видимость',
                                  SelObj.b.Visibility);
   SplinePanel.InitFromKF(SelObj.b.Visibility);
  end;//of if
  if sb_bonemove.down and (SelObj.b.Translation>=0)
  then ContrProps.SetCaptionAndId(SelObj.b.Name,'Движение',
                                  SelObj.b.Translation);
  if sb_bonerot.down and (SelObj.b.Rotation>=0)
  then ContrProps.SetCaptionAndId(SelObj.b.Name,'Вращение',
                                  SelObj.b.Rotation);
  if sb_bonescale.down then begin
   ObjAnimate.GetAbsScale(SelObj.b.ObjectID,GlobalX,GlobalY,GlobalZ);
   GlobalX:=GlobalX*100;
   GlobalY:=GlobalY*100;
   GlobalZ:=GlobalZ*100;
   ed_bonex.text:=floattostrf(GlobalX,ffFixed,10,5);
   ed_boney.text:=floattostrf(GlobalY,ffFixed,10,5);
   ed_bonez.text:=floattostrf(GlobalZ,ffFixed,10,5);
  end;//of if                                
  if sb_bonescale.down and (SelObj.b.Scaling>=0)
  then ContrProps.SetCaptionAndId(SelObj.b.Name,'Масштабирование',
                                  SelObj.b.Scaling);
  if not pn_contrprops.visible then pn_contrprops.Hide;
  pn_spline.visible:=false;
  if pn_contrprops.visible then SplinePanel.InitFromKF(ContrProps.Id);
  if not pn_spline.visible then SplinePanel.Hide;
 end;//of if

 BuildPanels;                     //выстроить панели в ряд
 cb_billboard.tag:=0;
 cb_abillboard.tag:=0;
 sb_objdel.enabled:=true;         //включить инструменты
 sb_detach.enabled:=SelObj.b.Parent>=0;
 //Создаем список связанных вершин:
 FindChildVertices;
 EnableAttachInstrums;

 cb_bonelist.ItemIndex:=
    cb_bonelist.items.IndexOfObject(TObject(SelObj.b.ObjectID));
 cb_bonelist.tag:=cb_bonelist.items.IndexOfObject(TObject(SelObj.b.ObjectID));

 //Запись координат (если нужно)
 if sb_selbone.down or sb_bonemove.down then begin
  ed_bonex.text:=floattostrf(SelObj.b.AbsVector[1],ffGeneral,10,5);
  ed_boney.text:=floattostrf(SelObj.b.AbsVector[2],ffGeneral,10,5);
  ed_bonez.text:=floattostrf(SelObj.b.AbsVector[3],ffGeneral,10,5);
 end;//of if
 if AnimEdMode<>2 then sb_boneMove.enabled:=true;
 sb_begattach.enabled:=true;
 sb_endattach.enabled:=true;
 sb_endattach.flat:=true;

 label30.visible:=true;

 l_childv.caption:='Связанных вершин: '+inttostr(GetSumCountOfChildVertices);

 if AnimEdMode=2 then begin
  ccX:=SelObj.b.AbsVector[1];
  ccY:=SelObj.b.AbsVector[2];
  ccZ:=SelObj.b.AbsVector[3];
 end else begin
  ccX:=PivotPoints[SelObj.b.ObjectID,1];
  ccY:=PivotPoints[SelObj.b.ObjectID,2];
  ccZ:=PivotPoints[SelObj.b.ObjectID,3];
 end;//of if

 //Перечертим картинку
 DrawFrame(CurFrame);

 application.processmessages;
 IsMayChange:=true;
 PopFunction;
End;

//Осуществляет выделение множественных объектов
//меняет список выделения на указанный (TFace)
//если len=-1, проходит инициализация БЕЗ смены списка
//и БЕЗ сохранения в Undo
procedure TFrm1.GraphMultiSelectObject(lst:TFace;len:integer);
Var i:integer;b:TBone;
Begin
 PushFunction(106);
 IsMayChange:=false;              //снять возможность перевыбора объекта
 //1. Если не инициализация - сохранить для отмены
 if len>=0 then begin
  AnimSaveUndo(uSelectObjects,0);
  sb_animundo.enabled:=true;
  CtrlZ1.enabled:=true;

  //2. Собственно выделение (изменение списка выделенных объектов)
  SelObj.CountOfSelObjs:=len;
  SelObj.SelObjs:=lst;
 end {else SelObj.CountOfSelObjs:=0};//of if

  //2.2: Установка фильтра (для редактора движения)
  if AnimEdMode=2 then begin
   ContrFilter.Clear;
   for i:=0 to SelObj.CountOfSelObjs-1 do with SelObj do begin
    b:=GetSkelObjectByID(SelObjs[i]);
    if b.Translation>=0 then ContrFilter.Add(pointer(b.Translation));
    if b.Rotation>=0 then ContrFilter.Add(pointer(b.Rotation));
    if b.Scaling>=0 then ContrFilter.Add(pointer(b.Scaling));
    if b.Visibility>=0 then ContrFilter.Add(pointer(b.Visibility));
//    ContrFilter.Add(pointer(SelObj.SelObjs[i]));
   end;//of for i
//   if SelObj.CountOfSelObjs=0
  end;//of if

 //3. Установка панелей/информационных полей
 frm_obj.Hide;                    //скрыть список объектов
 H1.enabled:=false;               //скрыть отображение иерархии
 cb_bonelist.enabled:=false;      //сделать недоступным список костей
 label30.caption:='[Группа объектов]';
 pn_boneprop.visible:=false;      //скрыть панели свойств
 pn_propobj.visible:=false;
 pn_contrprops.Hide;
 SplinePanel.Hide;
 pn_atchprop.visible:=false;
 pn_pre2prop.visible:=false;
 BuildPanels;                     //выстроить отдельные панели

 //4. Установка инструментов
 sb_objdel.enabled:=false;
 sb_bonemove.enabled:=false;
 sb_begattach.enabled:=false;
 sb_endattach.enabled:=false;
 sb_detach.enabled:=false;
 sb_vattach.enabled:=false;
 sb_vreattach.enabled:=false;
 //есть выделенные объекты
 if (SelObj.CountOfSelObjs>0) and (AnimEdMode<>2) then begin
  sb_objdel.enabled:=true;
  sb_bonemove.enabled:=true;
 end;//of if

 //5. Создаём списки дочерних объектов/связанных вершин
 SelObj.CountOfChilds:=0;         //сброс массива
 for i:=0 to SelObj.CountOfSelObjs-1 do FindChilds(SelObj.SelObjs[i]);
 FindChildVertices;
 l_childv.caption:='Связанных вершин: '+inttostr(GetSumCountOfChildVertices);
 if SelObj.CountOfChilds>0 then sb_selexpand.enabled:=true
 else sb_selexpand.enabled:=false;

 //6. Устанавливаем информационные поля
 cb_bonelist.tag:=1;
 cb_bonelist.ItemIndex:=-1;
 cb_bonelist.text:='';
 cb_bonelist.tag:=0;

 //7. Заполним окно-список выделенными объектами
 lb_selected.Clear;
 for i:=0 to SelObj.CountOfSelObjs-1 do begin
  b:=GetSkelObjectByID(SelObj.SelObjs[i]);
  lb_selected.Items.AddObject(b.Name,TObject(b.ObjectID));
 end;//of for i

 if AnimEdMode=2 then AnimLineRefresh(Self)
 else DrawFrame(CurFrame);        //перечертить рисунок
 application.processmessages;     //обработать сообщения
 IsMayChange:=true;               //разрешить перевыбор объекта
 PopFunction;
End;


procedure Tfrm1.cb_bonelistChange(Sender: TObject);
Var i:integer;
begin
 PushFunction(107);
 //0. Отслеживание ошибок
 if (cb_bonelist.ItemIndex<0) or (cb_bonelist.tag=-2)
 or (cb_bonelist.ItemIndex>cb_bonelist.Items.Count-1)
 or (cb_bonelist.Items.Strings[cb_bonelist.ItemIndex]<>cb_bonelist.text)
 then begin PopFunction;exit;end;

 //1. Отслеживание движений колёсика мыши
 if IsObjsDown then IsObjsDown:=false
 else begin
  cb_bonelist.text:=cb_bonelist.Items.Strings[cb_bonelist.tag];
  cb_bonelist.ItemIndex:=cb_bonelist.tag;
  PopFunction;
  exit;
 end;
 //Определим, что выбрано (ID выбранного объекта)
 i:=integer(cb_bonelist.Items.Objects[cb_bonelist.ItemIndex]);
 cb_bonelist.tag:=cb_bonelist.ItemIndex;
 GraphSelectObject(i);
 frm_obj.MakeObjectsList(i,i);
 PopFunction;
end;

//Статус: выделение
procedure Tfrm1.sb_selvertClick(Sender: TObject);
begin
 InstrumStatus:=isSelect;
 CtrlA1.enabled:=true;
 ed_bonex.enabled:=false;
 ed_boney.enabled:=false;
 ed_bonez.enabled:=false;
end;

//Сверка списков
function CompareMatrices(m1,m2:TFace):boolean;
Var i,ii,len1,len2:integer;
Begin
 PushFunction(108);
 CompareMatrices:=false;
 len1:=length(m1);len2:=length(m2);
 if len1<>len2 then begin PopFunction;exit;end; //списки не совпадают
 for i:=0 to len1-1 do begin
  for ii:=0 to len2-1 do if m1[i]=m2[ii] then break;
  if (ii=len2) or (m1[i]<>m2[ii]) then begin
   PopFunction;
   exit;     //нет совпадения
  end;
 end;//of for i
 CompareMatrices:=true;           //совпали
 PopFunction;
End;

//Присоединение вершин к кости
procedure Tfrm1.sb_vattachClick(Sender: TObject);
begin
 PushFunction(109);
 EndAttachObj;
 //Сохранить для отмены
 AnimSaveUndo(uDeleteObject,0);
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;
 StrlS1.enabled:=true;}

 //1. Выполняем присоединение
 AttachVertices;

 //2. Пересоставление списка (ибо может "поехать" иерархия)
 ChObj.IsSelected:=false;         //всё, объект уже связан
 IsMayChange:=false;
 MakeTextObjList(Sender);       //построить список объектов
 GraphSelectObject(SelObj.b.ObjectID);
 dec(CountOfUndo);
 frm_obj.MakeObjectsList(SelObj.b.ObjectID,SelObj.b.ObjectID);
 IsMayChange:=true;
 FillBonesList;
 PopFunction;
end;

//Инструмент: вращение кости
procedure Tfrm1.sb_bonerotClick(Sender: TObject);
begin
 PushFunction(110);
 pn_view.SetFocus;
 application.processmessages;
 InstrumStatus:=isBoneRot;
 pn_contrprops.visible:=false;
 pn_spline.visible:=false;
 ContrProps.OnlyOnOff:=false;
 if (AnimEdMode=2) and SelObj.IsSelected and (not SelObj.IsMultiSelect) and
    (SelObj.b.Rotation>=0)
 then ContrProps.SetCaptionAndId(SelObj.b.Name,'Вращение',SelObj.b.Rotation);
 if not pn_contrprops.visible then ContrProps.Hide
 else SplinePanel.InitFromKF(ContrProps.id);
 if not pn_spline.visible then SplinePanel.Hide;

 CtrlA1.enabled:=false;
 ed_bonex.enabled:=true; ed_bonex.ReadOnly:=false;
 ed_boney.enabled:=true; ed_boney.ReadOnly:=false;
 ed_bonez.enabled:=true; ed_bonez.ReadOnly:=false;
 ed_bonex.text:='0';
 ed_boney.text:='0';
 ed_bonez.text:='0';
 RefreshWorkArea(Sender);
 PopFunction;
end;

//поле редактирования
procedure Tfrm1.ed_bonexExit(Sender: TObject);
Var sx,sy,sz:GLfloat;
    tmp,i:integer;
begin
 PushFunction(111);
 //1. Читаем координаты (и проверяем на ошибку)
  Val(ed_bonex.text,sx,tmp);
 if (tmp<>0) or (sx<-10000) or (sx>10000) then begin
  ed_bonex.text:=floattostrf(SelObj.b.AbsVector[1],ffFixed,10,5);
  ed_bonex.SelectAll;
  PopFunction;
  exit;
 end;//of if
 Val(ed_boney.text,sy,tmp);
 if (tmp<>0) or (sy<-10000) or (sy>10000) then begin
  ed_boney.text:=floattostrf(SelObj.b.AbsVector[2],ffFixed,10,5);
  ed_boney.SelectAll;
  PopFunction;
  exit;
 end;//of if
 Val(ed_bonez.text,sz,tmp);
 if (tmp<>0) or (sz<-10000) or (sz>10000) then begin
  ed_bonez.text:=floattostrf(SelObj.b.AbsVector[3],ffFixed,10,5);
  ed_bonez.SelectAll;
  PopFunction;
  exit;
 end;//of if

 //В зависимости от режима действуем по-разному
 if AnimEdMode=0 then begin       //редактор скелета
  if SelObj.IsMultiSelect then begin  //если выделена группа объектов
   FindObjCoordCenter;            //найти центр координат
   //Сохранить для отмены
   AnimSaveUndo(uPivotChange,0);
   GraphSaveUndo;
{   CtrlZ1.enabled:=true;
   sb_animundo.enabled:=true;
   sb_save.enabled:=true;
   StrlS1.enabled:=true;}
   for i:=0 to SelObj.CountOfSelObjs-1 do begin
    //Собственно движение   
    PivotPoints[SelObj.SelObjs[i],1]:=PivotPoints[SelObj.SelObjs[i],1]+sx-ccX;
    PivotPoints[SelObj.SelObjs[i],2]:=PivotPoints[SelObj.SelObjs[i],2]+sy-ccY;
    PivotPoints[SelObj.SelObjs[i],3]:=PivotPoints[SelObj.SelObjs[i],3]+sz-ccZ;
   end;//of for i
   AnimLineRefresh(Sender);
   PopFunction;
   exit;
  end;//of if

  //Проверить корректность значений
  if SelObj.b.ObjectID<0 then begin PopFunction;exit;end;
  if (abs(PivotPoints[SelObj.b.ObjectID,1]-sx)<1e-5) and
     (abs(PivotPoints[SelObj.b.ObjectID,2]-sy)<1e-5) and
     (abs(PivotPoints[SelObj.b.ObjectID,3]-sz)<1e-5) then begin
   PopFunction;
   exit;
  end;

  //Сохранить для отмены
  AnimSaveUndo(uPivotChange,0);
  GraphSaveUndo;
{  CtrlZ1.enabled:=true;
  sb_animundo.enabled:=true;
  sb_save.enabled:=true;
  StrlS1.enabled:=true;}

  //Модификация геом. центра выделенного объекта
  PivotPoints[SelObj.b.ObjectID,1]:=sx;
  PivotPoints[SelObj.b.ObjectID,2]:=sy;
  PivotPoints[SelObj.b.ObjectID,3]:=sz;

  //Перерисовка экрана
  SelObj.b.AbsVector:=PivotPoints[SelObj.b.ObjectID];
  AnimLineRefresh(Sender);
  PopFunction;
  exit;
 end;//of if

 //Проверим, что за инструмент выбран
 if InstrumStatus=isBoneMove then begin
  //Проверить корректность значений
  if SelObj.b.ObjectID<0 then begin PopFunction;exit;end;
  if (abs(SelObj.b.AbsVector[1]-sx)<1e-5) and
     (abs(SelObj.b.AbsVector[2]-sy)<1e-5) and
     (abs(SelObj.b.AbsVector[3]-sz)<1e-5) then begin
   PopFunction;
   exit;
  end;
  //собственно перенос
  bBeginTrans(Sender);
  ObjAnimate.Move(sx-SelObj.b.AbsVector[1],sy-SelObj.b.AbsVector[2],
                  sz-SelObj.b.AbsVector[3]);
  frm1.DrawFrame(CurFrame);        //перечертить
  PopFunction;
  exit;
 end;//of if

 if InstrumStatus=isBoneRot then begin
  //Проверить корректность значений
  if SelObj.b.ObjectID<0 then begin PopFunction;exit;end;
  //собственно поворот
  bBeginRot(Sender,0,0);
  ObjAnimate.Rotate(sx*0.01745329,sy*0.01745329,sz*0.01745329);
  ed_bonex.text:='0';
  ed_boney.text:='0';
  ed_bonez.text:='0';
  frm1.DrawFrame(CurFrame);        //перечертить
  PopFunction;
  exit;
 end;//of if

 if InstrumStatus=isBoneScaling then begin
  if SelObj.b.ObjectID<0 then begin PopFunction;exit;end;
  if (abs(GlobalX-sx)<1e-5) and
     (abs(GlobalY-sy)<1e-5) and
     (abs(GlobalZ-sz)<1e-5) then begin PopFunction;exit;end;
  //собственно масштабирование
  bBeginTrans(Sender);
  ObjAnimate.Scale(0.01*sx,0.01*sy,0.01*sz);
  GlobalX:=sx;
  GlobalY:=sy;
  GlobalZ:=sz;
  frm1.DrawFrame(CurFrame);        //перечертить
  ed_bonex.text:=floattostrf(GlobalX,ffFixed,10,5);
  ed_boney.text:=floattostrf(GlobalY,ffFixed,10,5);
  ed_bonez.text:=floattostrf(GlobalZ,ffFixed,10,5);
  PopFunction;
  exit;
 end;//of if
 PopFunction;
end;

procedure Tfrm1.ed_bonexKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=VK_RETURN then ed_bonexExit(Sender);
end;

procedure Tfrm1.sb_bonemoveClick(Sender: TObject);
begin
 PushFunction(112);
 pn_view.SetFocus;
 application.ProcessMessages;
 InstrumStatus:=isBoneMove;
 CtrlA1.enabled:=false;
 EndAttachObj;
 pn_contrprops.visible:=false;
 pn_spline.visible:=false;
 ContrProps.OnlyOnOff:=false;
 if (AnimEdMode=2) and SelObj.IsSelected and (not SelObj.IsMultiSelect) and
    (SelObj.b.Translation>=0)
 then ContrProps.SetCaptionAndId(SelObj.b.Name,'Движение',SelObj.b.Translation);
 if not pn_contrprops.visible then ContrProps.Hide
 else SplinePanel.InitFromKF(ContrProps.id);
 if not pn_spline.visible then SplinePanel.Hide;


 if SelObj.IsMultiSelect then begin
  ed_bonex.text:=floattostrf(ccX,ffGeneral,10,5);
  ed_boney.text:=floattostrf(ccY,ffGeneral,10,5);
  ed_bonez.text:=floattostrf(ccZ,ffGeneral,10,5);
 end else begin
  ed_bonex.text:=floattostrf(Selobj.b.AbsVector[1],ffGeneral,10,5);
  ed_boney.text:=floattostrf(Selobj.b.AbsVector[2],ffGeneral,10,5);
  ed_bonez.text:=floattostrf(Selobj.b.AbsVector[3],ffGeneral,10,5);
 end;//of if 
 ed_bonex.enabled:=true; ed_bonex.ReadOnly:=false;
 ed_boney.enabled:=true; ed_boney.ReadOnly:=false;
 ed_bonez.enabled:=true; ed_bonez.ReadOnly:=false;
 RefreshWorkArea(Sender);
 PopFunction;
end;

procedure Tfrm1.sb_bonescaleClick(Sender: TObject);
begin
 PushFunction(113);
 InstrumStatus:=isBoneScaling;
 pn_contrprops.visible:=false;
 pn_spline.visible:=false;
 ContrProps.OnlyOnOff:=false;
 if (AnimEdMode=2) and SelObj.IsSelected and (not SelObj.IsMultiSelect) and
    (SelObj.b.Scaling>=0)
 then ContrProps.SetCaptionAndId(SelObj.b.Name,'Масштабирование',
                                 SelObj.b.Scaling);
 if not pn_contrprops.visible then ContrProps.Hide
 else SplinePanel.InitFromKF(ContrProps.Id);
 if not pn_spline.visible then SplinePanel.Hide;

 CtrlA1.enabled:=false;
 ed_bonex.enabled:=true; ed_bonex.ReadOnly:=false;
 ed_boney.enabled:=true; ed_boney.ReadOnly:=false;
 ed_bonez.enabled:=true; ed_bonez.ReadOnly:=false;
 //Читаем абсолютный масштаб
 ObjAnimate.GetAbsScale(SelObj.b.ObjectID,GlobalX,GlobalY,GlobalZ);
 GlobalX:=GlobalX*100;
 GlobalY:=GlobalY*100;
 GlobalZ:=GlobalZ*100;
 ed_bonex.text:=floattostrf(GlobalX,ffGeneral,10,5);
 ed_boney.text:=floattostrf(GlobalY,ffGeneral,10,5);
 ed_bonez.text:=floattostrf(GlobalZ,ffGeneral,10,5);
 RefreshWorkArea(Sender);
 PopFunction;
end;

procedure Tfrm1.ed_maxframeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=VK_RETURN then ed_maxframeExit(Sender);
end;

//Сохраняет список ранее открытых файлов
procedure TFrm1.SaveRecentFiles(Sender:TObject);
Var inif:TIniFile;
    a:array[1..1000] of char;
    pa:PChar;s:string;
    i:integer;
Const sect='Params';sectf='RecentFiles';
Begin
 PushFunction(114);
 pa:=@a;
 GetModuleFileName(hInstance,pa,1000);
 s:=string(pa);
 Delete(s,length(s)-2,3);
 inif:=TIniFile.Create(s+'ini');
 if CountOfRF>5 then CountOfRF:=5;
 for i:=1 to CountOfRF do begin
  inif.WriteString(sectf,'File'+inttostr(i),RecentFiles[i]);
 end;
 inif.UpdateFile;
 inif.Free;
 PopFunction;
End;


procedure Tfrm1.FormClose(Sender: TObject; var Action: TCloseAction);
Var mb:integer;inif:TIniFile;
    a:array[1..1000] of char;
    pa:PChar;s:string;
    i:integer;
Const sect='Params';sectf='RecentFiles';sectO='Other';
begin
 PushFunction(115);
 IsPlay:=false;
 //Запрос: сохранить модель?
 if sb_save.enabled and IsModified then begin
  mb:=MessageBox(frm1.handle,'Сохранить модель?','Выход из MdlVis',
                 MB_APPLMODAL or
                 MB_ICONQUESTION or MB_YESNOCANCEL);
  if mb=idyes then StrlS1Click(Sender);
  if mb=idcancel then begin Action:=caNone;PopFunction;exit;end;
 end;//of if

 //Теперь сохраним параметры
 pa:=@a;
 GetModuleFileName(hInstance,pa,1000);
 s:=string(pa);
 Delete(s,length(s)-2,3);
 inif:=TIniFile.Create(s+'ini');

 inif.WriteBool(sect,'SmallGrid',IsLowGrid);
 inif.WriteBool(sect,'XZGrid',IsXZGrid);
 inif.WriteBool(sect,'YZGrid',IsYZGrid);
 inif.WriteBool(sect,'XYGrid',IsXYGrid);
 inif.WriteBool(sect,'AxisHighlight',IsXYZ);
 inif.WriteBool(sect,'Shades',IsLight);
 inif.WriteBool(sect,'Vertices',cb_vertices.checked);
 inif.WriteBool(sect,'SlowHighlight',IsSlowHighlight);
 inif.WriteBool(sect,'Axes',IsAxes);
 inif.WriteBool(sect,'BonesVisibility',VisObjs.VisBones);
 inif.WriteBool(sect,'AtchVisibility',VisObjs.VisAttachments);
 inif.WriteBool(sect,'PartEmVisibility',VisObjs.VisAttachments);
 inif.WriteBool(sect,'SkelVisibility',VisObjs.VisSkel);
 inif.WriteBool(sect,'OrientVisibility',VisObjs.VisOrient);

 //Спец. параметры:
 inif.WriteBool(sectO,'DisplaceInsertedByZ',IsDisp);

 //Сохранение имён последних откр. файлов
 if CountOfRF>5 then CountOfRF:=5;
 for i:=1 to CountOfRF do begin
  inif.WriteString(sectf,'File'+inttostr(i),RecentFiles[i]);
 end;
 inif.UpdateFile;
 inif.Free;
 PopFunction;
end;

procedure Tfrm1.pb_redrawPaint(Sender: TObject);
begin
 if length(Geosets)=0 then exit;
 PushFunction(116);
 if pb_redraw.tag<>0 then begin
  glCallList(CurrentListNum);
  SwapBuffers(dc);
 end;//of if
 PopFunction;
end;

//Вставка из 3DS-файла
procedure Tfrm1.N19Click(Sender: TObject);
Var num,i:integer; s:string;
begin
 if GetSumCountOfSelVertices<>1 then exit;     //перестраховка
 PushFunction(117);
 if od_3ds.execute then begin     //запуск диалога
  num:=CountOfGeosets;
  SaveUndo(uCreateGeoset);        //сохранить для отмены
  Import3DS(od_3ds.FileName);
  //ничего не вставилось
  if CountOfGeosets=num then begin PopFunction;exit;end;
  //увеличить кол-во поверхностей
  s:='1';
  for i:=1 to CountOfGeosets-1 do s:=s+#13#10+inttostr(i+1);
  clb_geolist.items.text:=s;
  for i:=0 to clb_geolist.Items.Count-1 do clb_geolist.Checked[i]:=false;
  clb_geolist.Checked[0]:=true;
 end;//of if
 PopFunction;
end;

//Выделить все вершины поверхности
procedure Tfrm1.CtrlA1Click(Sender: TObject);
Var i,j:integer;
begin
 if AnimEdMode=2 then exit;
 PushFunction(118);
 SaveUndo(uSelect);
 sb_undo.enabled:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;
 for j:=0 to CountOfGeosets-1 do
 with Geosets[j],geoobjs[j] do if IsSelected then begin
  if InstrumStatus<>isSelect then begin PopFunction;exit;end;
  //1. Заполним список вершин:
  SetLength(VertexList,CountOfVertices);
  VertexCount:=CountOfVertices;
  for i:=0 to CountOfVertices-1 do VertexList[i]:=i+1;
 end;
 //2. Дополним выделение
 IsArea:=true;
 ClickX:=0;ClickY:=0;
 GLWorkAreaMouseUp(sender,mbLeft,[ssShift],20,20);
 dec(CountOfUndo);
 PopFunction;
end;

//вкл/выкл. освещенность
procedure Tfrm1.cb_lightClick(Sender: TObject);
begin
 if cb_light.tag<>0 then exit;
 PushFunction(119);
 IsVertices:=cb_vertices.checked;
 IsLight:=cb_light.checked;
 case ViewType of
  1:begin
   ViewType:=0;
   N15Click(Sender);
  end;//of 1
  2:begin
   ViewType:=0;
   N16Click(Sender);                //перерисовать
  end;//of 2
 end;//of case
 PopFunction;
end;

//Очистить (Удаление КК)
procedure Tfrm1.N20Click(Sender: TObject);
Var FrameS,FrameE:integer;
begin
 PushFunction(120);
 if SelMinFrame<SelMaxFrame then begin
  FrameS:=SelMinFrame;
  FrameE:=SelMaxFrame;
 end else begin
  FrameS:=SelMaxFrame;
  FrameE:=SelMinFrame;
 end;//of if
 if FrameS=FrameE then DeleteKeyFrames(MinFrame,MaxFrame)
                  else DeleteKeyFrames(FrameS,FrameE);
 if (AnimEdMode=2) and (SelObj.IsSelected) then begin
  SelObj.b:=GetSkelObjectByID(SelObj.b.ObjectID);
  label44.Tag:=1;
  sb_bonemove.enabled:=true;
  sb_bonerot.enabled:=true;
  sb_bonescale.enabled:=true;
  ContrProps.Hide;
  SetVisPanelActive;
  cb_objvis.tag:=1;

  //Установка параметров свойств объекта
  if SelObj.b.Visibility<0 then begin  //видимость объекта
   cb_objvis.enabled:=false;
   cb_objvis.checked:=true;
   b_visanimate.visible:=true;
  end else begin
   cb_objvis.enabled:=true;
   cb_objvis.checked:=false;
   b_visanimate.visible:=false;
  end;//of if
  cb_objvis.tag:=0;
  label44.tag:=0;
  //Установка флажков ограничений и видимости

  SetObjVisibilityProp;
  SetVisPanelActive;
  if ContrProps.IsVisible then begin
   SplinePanel.InitFromKF(ContrProps.id);
   BuildPanels;
  end;//of if
  cb_mover.checked:=ObjAnimate.IsMoveRestrict(SelObj.b.ObjectID);
  cb_rotationr.checked:=ObjAnimate.IsRotRestrict(SelObj.b.ObjectID);
  cb_scalingr.checked:=ObjAnimate.IsScRestrict(SelObj.b.ObjectID);
  ApplyInstrumRestrictions;
  label44.tag:=0;
 end;//of if
{ IsModified:=true;}
 GraphSaveUndo;
 AnimLineRefresh(Sender);
 PopFunction;
end;

//Конверсия WoW-текстуры в blp (WC3)
procedure Tfrm1.WoW1Click(Sender: TObject);
Var IsErr:boolean; i:integer;
begin
 if od_blp2.execute then begin
  IsErr:=false;
  for i:=0 to od_blp2.Files.Count-1
  do IsErr:=IsErr or (not ConvertBLP2ToBLP(od_blp2.Files.Strings[i],false)); 
  if not IsErr then
  MessageBox(frm1.handle,'Конверсия завершена.','MdlVis',
             mb_iconinformation);
 end;//of if
end;

procedure Tfrm1.FormShow(Sender: TObject);
Var sPar:string;
begin
 PushFunction(121);
 LoadParams(Sender);             //загрузка параметров
 AddFileToMenuList('?',Sender);//добавить в список менюшных файлов
 //Проверяем: нет ли связанного файла
 sPar:=ParamStr(1);               //считать параметр
 if length(sPar)<4 then begin PopFunction;exit;end;//это не файл
 od_file.FileName:=sPar;
 IsParFile:=true;
 application.processmessages;
 N2Click(Sender);                 //загрузить
 PopFunction;
end;

procedure Tfrm1.clb_geolistMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var pt:TPoint;
begin
 GetCursorPos(pt);
 if Button=mbRight then PM_geosets.Popup(pt.x,pt.y);
end;

//Сделать активными все поверхности
procedure Tfrm1.N21Click(Sender: TObject);
Var i:integer;
begin
 for i:=0 to clb_geolist.Items.Count-1 do clb_geolist.Checked[i]:=true;
 cb_showallClick(Sender);
end;

procedure Tfrm1.N22Click(Sender: TObject);
Var i:integer;
begin
 for i:=0 to clb_geolist.Items.Count-1 do clb_geolist.Checked[i]:=false;
 cb_showallClick(Sender);
end;

procedure Tfrm1.N23Click(Sender: TObject);
Var i:integer;
begin
 for i:=0 to clb_geolist.Items.Count-1 do
             clb_geolist.Checked[i]:=not clb_geolist.Checked[i];
 cb_showallClick(Sender);
end;

procedure Tfrm1.ed_ixKeyPress(Sender: TObject; var Key: Char);
begin
 if (key in ['a'..'Z']) or
    (key in ['A'..'Я']) or
    (key in ['а'..'я'])then Key:=#0;
end;

//Вспомогательная: уменьшает длины 2 сторон треугольника
procedure TransferTriangle(geoID,num:integer);
Var md,dv,num2,num3:integer;
    x1,y1,z1,x2,y2,z2,pwr:GLFloat;
Const pwr2=0.9;
Begin with Geosets[geoID] do begin
 PushFunction(122);
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

 num:=Faces[0,num]; pwr:=abs(0.9-pwr2/(CurView.Zoom));
 //2. Собственно усреднение
  x1:=(1-Pwr)*Vertices[num2,1]+Pwr*Vertices[num,1];
  y1:=(1-Pwr)*Vertices[num2,2]+Pwr*Vertices[num,2];
  z1:=(1-Pwr)*Vertices[num2,3]+Pwr*Vertices[num,3];
  x2:=(1-Pwr)*Vertices[num3,1]+Pwr*Vertices[num,1];
  y2:=(1-Pwr)*Vertices[num3,2]+Pwr*Vertices[num,2];
  z2:=(1-Pwr)*Vertices[num3,3]+Pwr*Vertices[num,3];
  Vertices[num,1]:=0.5*(x1+x2);
  Vertices[num,2]:=0.5*(y1+y2);
  Vertices[num,3]:=0.5*(z1+z2);
  PopFunction;
end;End;

//Разъединяет выделенные вершины, раскрывая все
//треугольники, которые в этих вершинах пересекаются.
procedure Tfrm1.sb_uncoupleClick(Sender: TObject);
Var j,i,ii,jj,k,num,len1:integer;
begin
 PushFunction(123);
 SaveUndo(uUncouple);
 for j:=0 to CountOfGeosets-1 do with Geosets[j],GeoObjs[j] do
 if IsSelected and (VertexCount>0) then begin
  ReCalcNormals(j+1);
  SmoothWithNormals(j);
  OldCountOfVertices:=CountOfVertices;
  for i:=0 to VertexCount-1 do begin
   num:=VertexList[i]-1;          //считать номер очередной вершины
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
     Normals[CountOfVertices-1]:=Normals[num];
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
 end;//of if/with/for j
 EnableInstrums;
 //4. Перерисовать
 FindCoordCenter;
 RefreshWorkArea(Sender);
 CalcVertex2D(GLWorkArea.ClientHeight);
 PopFunction;
end;

procedure Tfrm1.cb_animlistDropDown(Sender: TObject);
begin
 cb_animlist.Font.Color:=clBlack;
 IsListDown:=true;
 Timer1.enabled:=true;
end;

//Обновить анимационную шкалу
procedure TFrm1.AnimLineRefresh(Sender:TObject);
Begin
 PushFunction(124);
 //Заполнить список ключевых кадров (из Controllers)
 ReFormStamps;
 IsListDown:=true;
 if AnimEdMode=1 then frm1.cb_animlistChange(Sender)
 else pb_animMouseUp(Sender,mbMiddle,[],0,0);
 frm1.pb_animPaint(Sender);
 PopFunction;
End;

//Добавка пустых кадров в контроллеры
procedure Tfrm1.N24Click(Sender: TObject);
Var Count:integer;
begin
 PushFunction(125);
 //1. Считать кол-во вставляемых кадров
 frmAdd.ShowModal;
 if (frmAdd.ModalResult<>mrOK) or
    (not IsCipher(frmAdd.ed_count.text)) then begin PopFunction;exit;end;
 Count:=strtoint(frmAdd.ed_count.text);
 if Count>$FFFFFF then begin PopFunction;exit;end;
 //2. Сохранить для отмены
 AnimSaveUndo(Count or uFrameAdd,0);
 GraphSaveUndo;

 //3. Собственно вставка
 ShearFrames(CurFrame,UsingGlobalSeq,Count);
 MaxFrame:=MaxFrame+Count;
 //Теперь - обновление
 AbsMaxFrame:=AbsMaxFrame+Count;
 AnimLineRefresh(Sender);
 PopFunction;
end;

procedure Tfrm1.ud_frameClick(Sender: TObject; Button: TUDBtnType);
Var i:integer;
begin
 if ed_fnum.text='' then exit;
 PushFunction(127);
 i:=strtoint(ed_fnum.text);
 if Button=btNext then ed_fnum.text:=inttostr(i+1);
 if (Button=btPrev) and (i>0) then ed_fnum.text:=inttostr(i-1);
 application.processmessages;
 ed_fnumExit(Sender);
 PopFunction;
end;

//Создать глобальную последовательность
procedure Tfrm1.b_GlobalCreateClick(Sender: TObject);
begin
 PushFunction(128);
 AnimSaveUndo(uCreateGlobalSeq,0);
 GraphSaveUndo;
 inc(CountOfGlobalSequences);
 SetLength(GlobalSequences,CountOfGlobalSequences);
 GlobalSequences[CountOfGlobalSequences-1]:=1;
 cb_animlist.Items.Add('1');
 cb_animlist.text:='1';
 cb_animlist.ItemIndex:=cb_animlist.Items.Count-1;
 IsListDown:=true;
 cb_animlistChange(Sender);
 PopFunction;
end;

//"Выключение" источников частиц путём установки
//контроллеров видимости
procedure Tfrm1.N25Click(Sender: TObject);
Var i:integer;Frame:TContItem;
begin
 if UsingGlobalSeq>=0 then exit;  //выбрана глоб. последовательность
 PushFunction(129);
 AnimSaveUndo(uEmittersOff,0);
 GraphSaveUndo;
{ sb_animundo.enabled:=true;
 CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;
 IsModified:=true;}
 Frame.Frame:=MinFrame;
 Frame.Data[1]:=0;
 Frame.InTan[1]:=0;
 Frame.OutTan[1]:=0;
 Stamps.Add(Frame.Frame);
 for i:=0 to CountOfParticleEmitters1-1 do with ParticleEmitters1[i] do begin
  if Skel.Visibility<0 then continue;
  if Controllers[Skel.Visibility].GlobalSeqId>=0 then continue;
  AddKeyFrame(Skel.Visibility,Frame);
 end;//of for i

 for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
  if Skel.Visibility<0 then continue;
  if Controllers[Skel.Visibility].GlobalSeqId>=0 then continue;
  AddKeyFrame(Skel.Visibility,Frame);
 end;//of for i

 //Перерисовка
 pb_animPaint(Sender);
 pb_animMouseUp(Sender,mbLeft,[],0,0);
 PopFunction;
end;

//Установить все элементы панели цвета/видимости
procedure TFrm1.SetColorPanelState(Sender:TObject);
Var j,i,num,acount,ccount:integer;
    VisPresent,AlphaPresent,IsGeosPresent,
    IsColorPresent,GeoOFF,GeoON:boolean;
    ct:TContItem;r,g,b:GLFloat;
Begin
 //0. Проверим, надо ли вообще отображать панель цветов
 if AnimEdMode<>1 then begin
  pn_color.visible:=false;
  exit;
 end;//of if
 //1. Проверим, что с видимостью в выделенных поверхностях
 PushFunction(130);
 VisPresent:=true;                //считаем, что контроллеры видимости есть
 AlphaPresent:=true;              //контроллеры прозрачности
 IsColorPresent:=true;            //контроллеры цвета
 GeoOFF:=false;
 GeoON:=false;
 IsGeosPresent:=false;
 MidAlpha:=0;acount:=0;
 r:=0;g:=0;b:=0;ccount:=0;
 for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
  if not IsSelected then continue;//обрабатываем только выделенные
  IsGeosPresent:=true;
  //Поиск анимации видимости
  num:=-1;
  for i:=0 to CountOfGeosetAnims-1 do if GeosetAnims[i].GeosetID=j then num:=i;
  if num<0 then begin
   VisPresent:=false;
   AlphaPresent:=false;
   IsColorPresent:=false;
   break;
  end;//нет GeosetAnim
  //Анимация видимости найдена! Смотрим, есть ли там Alpha и Color
  if GeosetAnims[num].IsAlphaStatic then begin
   VisPresent:=false;
   AlphaPresent:=false;
  end else begin //of if
   //Контроллер тоже есть.
   //Смотрим теперь тип контроллера
   if (Controllers[GeosetAnims[num].AlphaGraphNum].ContType<>DontInterp)
   then VisPresent:=false
   else AlphaPresent:=false;

   //Проверим, соответствует ли контроллер нужной последовательности
   if (Controllers[GeosetAnims[num].AlphaGraphNum].GlobalSeqID<>UsingGlobalSeq)
   then begin
    VisPresent:=false;
    AlphaPresent:=false;
   end;//of if
   //Теперь читаем значение вкл/выкл.
   ct:=GetFrameData(GeosetAnims[num].AlphaGraphNum,CurFrame,ctAlpha);
   if ct.Data[1]>0.75 then GeoON:=true
                      else GeoOFF:=true;
   inc(acount);
   MidAlpha:=MidAlpha+ct.Data[1];
  end;//of IsAlphaStatic
  if GeosetAnims[num].IsColorStatic then IsColorPresent:=false else begin
   //Проверим, соответствует ли контроллер нужной последовательности
   if (Controllers[GeosetAnims[num].AlphaGraphNum].GlobalSeqID<>UsingGlobalSeq)
   then IsColorPresent:=false;
   //Читаем значение подцветки:
   ct:=GetFrameData(GeosetAnims[num].ColorGraphNum,CurFrame,ctTranslation);
   r:=r+ct.Data[3];
   g:=g+ct.Data[2];
   b:=b+ct.Data[1];
   inc(ccount);
  end;//of if
 end;//of for j
 if acount>0 then MidAlpha:=MidAlpha/acount;
 if ccount>0 then begin
  r:=r/ccount;
  g:=g/ccount;
  b:=b/ccount;
 end;//of if

 //Проверим, есть ли выбранные поверхности
 pn_Color.visible:=IsGeosPresent;
 //Итак, устанавливаем всё, связанное с видимостью
 if VisPresent then begin
  bb_VisCreate.visible:=false;
  cb_VisOn.visible:=true;
  cb_VisOn.tag:=1;                //защита от срабатывания клика
  //Устанавливаем собственно видимость:
  if GeoOFF and GeoON then cb_VisOn.State:=cbGrayed
  else if GeoOFF then cb_VisOn.State:=cbUnChecked
                 else cb_VisOn.State:=cbchecked;
  cb_VisOn.tag:=0;
 end else begin
  bb_VisCreate.visible:=true;
  cb_VisOn.visible:=false;
 end;//of if

 //С видимостью покончено. Устанавливаем прозрачность (альфа).
 if AlphaPresent then begin
  bb_AlphaCreate.Visible:=false;
  ed_Alpha.visible:=true;
  ed_Alpha.text:=floattostrf(MidAlpha,ffFixed,10,5);
 end else begin
  ed_Alpha.Visible:=false;
  //Проверим, допускают ли материалы создание контроллера
  //прозрачности
  bb_AlphaCreate.visible:=true;
  for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do begin
   if not IsSelected then continue;
   for i:=0 to Materials[Geosets[j].MaterialID].CountOfLayers-1 do
       if Materials[Geosets[j].MaterialID].Layers[i].FilterMode<3 then begin
    bb_AlphaCreate.visible:=false;
    break;
   end;//of if/for i
  end;//of with/for i
 end;//of if

 //Теперь смотрим, что там с цветовым контроллером
 if IsColorPresent then begin
  bb_ColorCreate.visible:=false;
  pn_ColorEnter.visible:=true;
  ed_r.text:=inttostr(round(r*255));
  ed_g.text:=inttostr(round(g*255));
  ed_b.text:=inttostr(round(b*255));
  cr:=r;cg:=g;cb:=b;
 end else begin
  bb_ColorCreate.visible:=true;
  pn_ColorEnter.visible:=false;
 end;
 PopFunction;
End;

//Выделение КК, принадлежащих контроллерам видимости/
//прозрачности/цвета
procedure Tfrm1.cb_filterClick(Sender: TObject);
Var j:integer;
begin
 PushFunction(131);
 //Отключена фильтрация
 IsContrFilter:=cb_filter.checked;
 //Пересобрать список КК (применив фильтр)
 if cb_filter.checked then begin
  //1. Создаём фильтр.
  ContrFilter.Clear;
  for j:=0 to CountOfGeosetAnims-1 do with GeosetAnims[j] do
      if GeoObjs[GeosetID].IsSelected then begin
   //1a. Пробегаем контроллеры Alpha
   if not IsAlphaStatic then ContrFilter.Add(pointer(AlphaGraphNum));
   if not IsColorStatic then ContrFilter.Add(pointer(ColorGraphNum));
  end;//of with/if/for j

 end;//of if

 AnimLineRefresh(Sender);
 PopFunction;
end;

//Перемещение панелей
procedure Tfrm1.BuildPanels;
Begin
 PushFunction(132);
 if EditorMode=emVertex then pn_objs.top:=pn_instr.top+pn_instr.height
 else begin
  if AnimEdMode=1 then pn_objs.top:=pn_seq.top+pn_seq.height;
 end;//of if
 if EditorMode<>emAnims then begin PopFunction;exit;end;
 if AnimEdMode=1 then begin
  pn_Color.top:=pn_objs.top+pn_objs.height;
 end else begin
  //0. Панель свойств (если есть):
  pn_boneprop.top:=pn_boneedit.top+pn_boneedit.height;
  pn_atchprop.top:=pn_boneedit.top+pn_boneedit.height;
  pn_pre2prop.top:=pn_boneedit.top+pn_boneedit.height;
  //1. Панель рабочей плоскости
  if pn_boneprop.visible
   then pn_workplane.top:=pn_boneprop.top+pn_boneprop.height;
  if pn_atchprop.visible
   then pn_workplane.top:=pn_atchprop.top+pn_atchprop.height;
  if pn_pre2prop.visible
   then pn_workplane.top:=pn_pre2prop.top+pn_pre2prop.height;
  if not (pn_boneprop.visible or pn_atchprop.visible or pn_pre2prop.visible)
   then pn_workplane.top:=pn_boneedit.top+pn_boneedit.height;
  //2. Панель инструментов
  pn_binstrum.top:=pn_workplane.top+pn_workplane.height;
  //2.5: Панель свойств объекта
  if not pn_binstrum.visible then pn_propobj.top:=pn_workplane.top+
                              pn_workplane.height
  else pn_propobj.top:=pn_binstrum.top+pn_binstrum.height;
  //2.8: Панель свойств контроллера
  pn_contrprops.top:=pn_propobj.top+pn_propobj.height;
  //2.9: Панель свойств кривой
  pn_spline.top:=pn_contrprops.top+pn_contrprops.height;
  //3. Панель объектов
  if pn_spline.visible then pn_objs.top:=pn_spline.top+pn_spline.height
  else if pn_contrprops.visible
  then pn_objs.top:=pn_contrprops.top+pn_contrprops.height
  else if pn_propobj.visible then pn_objs.top:=pn_propobj.top+pn_propobj.height
  else if pn_binstrum.visible then pn_objs.top:=pn_binstrum.top+pn_binstrum.height
  else pn_objs.top:=pn_workplane.top+pn_workplane.height;
  //4. Панель списка костей
  pn_listbones.top:=pn_objs.top+pn_objs.height;
  //5. Панель координатного центра (для вершин):
  pn_vertcoords.top:=pn_listbones.top+pn_listbones.height;
 end;//of if
 PopFunction;
End;

//Сворачивание панели анимаций
procedure Tfrm1.sb_coll1Click(Sender: TObject);
begin
 PushFunction(133);
 sb_coll1.visible:=false;
 sb_coll1p.visible:=true;
 label15.tag:=pn_seq.height;
 pn_seq.height:=55;//305
 BuildPanels;
 PopFunction;
end;
//разворачивание панели анимаций
procedure Tfrm1.sb_coll1pClick(Sender: TObject);
begin
 PushFunction(134);
 sb_coll1p.visible:=false;
 sb_coll1.visible:=true;
 pn_seq.height:=label15.tag;
 BuildPanels;
 PopFunction;
end;
//Сворачивание панели поверхностей
procedure Tfrm1.sb_coll2Click(Sender: TObject);
begin
 PushFunction(135);
 sb_coll2.visible:=false;
 sb_coll2p.visible:=true;
 pn_objs.tag:=pn_objs.height;
 pn_objs.height:=16;
 BuildPanels;
 PopFunction;
end;
//разворачивание панели поверхностей
procedure Tfrm1.sb_coll2pClick(Sender: TObject);
begin
 sb_coll2p.visible:=false;
 sb_coll2.visible:=true;
 pn_objs.height:=pn_objs.tag;
 BuildPanels;
end;

//Отображение нормалей
procedure Tfrm1.N26Click(Sender: TObject);
Var i:integer;
begin
 PushFunction(136);
 N26.checked:=not N26.Checked;
 IsNormals:=N26.checked;
 //перерасчёт нормалей
 for i:=0 to CountOfGeosets-1 do begin
  ReCalcNormals(i+1);   //Num
  SmoothWithNormals(i); //ID
 end;//of for i
 RefreshWorkArea(Sender);
 PopFunction;
end;

//Обратить нормали
procedure Tfrm1.sb_swapClick(Sender: TObject);
var i:integer;
begin
 PushFunction(137);
 SaveUndo(uSwapNormals);          //сохранить для отмены
 //Кроме того, после SaveUndo заполнены SelFaces.
 SwapNormals;                     //обратить нормали
 //Теперь обнулим SelFaces (на всякий случай)
 for i:=0 to CountOfGeosets-1 do GeoObjs[i].SelFaces:=nil;
 RefreshWorkArea(Sender);         //перерисовка рабочей плоскости
 PopFunction;
end;

//Удаление ранее созданного треугольника
procedure Tfrm1.sb_deltrClick(Sender: TObject);
begin
 PushFunction(138);
 if DeleteTriangles then begin
  sb_undo.enabled:=true;
  IsModified:=true;
  CtrlZ1.enabled:=true;
  l_triangles.caption:='Треугольников: '+inttostr(GetSumCountOfTriangles);
  RefreshWorkArea(Sender);
 end;//of if
 PopFunction;
end;

//Копирование выделенных кадров в буфер обмена
procedure Tfrm1.CtrlC2Click(Sender: TObject);
Var len,ID,BufLen,FrameS,FrameE:integer;
    IsCopied:boolean;
begin
 PushFunction(139);
 ID:=-1;len:=High(Controllers);
 BufLen:=0;IsCopied:=false;
  if SelMinFrame<SelMaxFrame then begin
   FrameS:=SelMinFrame;
   FrameE:=SelMaxFrame;
  end else begin
   FrameS:=SelMaxFrame;
   FrameE:=SelMinFrame;
  end;//of if
 while GetNextController(ID,len) do begin
  //1. Выделим место в буфере
  inc(BufLen);
  SetLength(FrameBuffer,BufLen);
  //2. Скопируем "шапку" контроллера
  FrameBuffer[BufLen-1]:=Controllers[ID];
  FrameBuffer[BufLen-1].Items:=nil;
  //3. Копируем сами кадры
  if CopyFrames(Controllers[ID],FrameBuffer[BufLen-1],FrameS,FrameE,
                0,-1) then begin
   FrameBuffer[BufLen-1].SizeOfElement:=ID;
   IsCopied:=true;
  end else dec(BufLen);
 end;//of while

 SetLength(FrameBuffer,BufLen);   //подгоним под длину
 //Установим кнопки, если скопировалось
 if IsCopied then begin
  sb_animpaste.enabled:=true;
  CtrlV1.enabled:=true;
  CtrlV2.enabled:=true;
  CtrlV3.enabled:=true;
 end else begin
  sb_animpaste.enabled:=false;
  CtrlV1.enabled:=false;
  CtrlV2.enabled:=false;
  CtrlV3.enabled:=false;
 end;
 PopFunction;
end;

//Вставляет содержимое буфера обмена
procedure Tfrm1.CtrlV2Click(Sender: TObject);
begin
 PushFunction(140);
 AnimSaveUndo(uPasteFrames,0);
 if not PasteFramesFromBuffer(CurFrame,MaxFrame,true,false,0) then begin
  PopFunction;
  exit;
 end;
 GraphSaveUndo;
 AnimLineRefresh(Sender);
 PopFunction;
end;

//Копирование в буфер обмена позиции кадра.
procedure Tfrm1.C1Click(Sender: TObject);
begin
 PushFunction(141);
 CopyCurFrameToBuffer;
 sb_animpaste.enabled:=true;
 CtrlV1.enabled:=true;
 CtrlV2.enabled:=true;
 CtrlV3.enabled:=true;
 PopFunction;
end;

procedure Tfrm1.ReMakeObjPropPanels;
Begin
 PushFunction(142);
 if (AnimEdMode=2) and (SelObj.IsSelected) then begin
  SelObj.b:=GetSkelObjectByID(SelObj.b.ObjectID);
  label44.Tag:=1;
  sb_bonemove.enabled:=true;
  sb_bonerot.enabled:=true;
  sb_bonescale.enabled:=true;
  if sb_selbone.down then ContrProps.Hide;
  SetVisPanelActive;
  cb_objvis.tag:=1;

  //Установка параметров свойств объекта
  if SelObj.b.Visibility<0 then begin  //видимость объекта
   cb_objvis.enabled:=false;
   cb_objvis.checked:=true;
   b_visanimate.visible:=true;
  end else begin
   cb_objvis.enabled:=true;
   cb_objvis.checked:=false;
   b_visanimate.visible:=false;
  end;//of if
  cb_objvis.tag:=0;
  label44.tag:=0;
  //Установка флажков ограничений и видимости

  SetObjVisibilityProp;
  SetVisPanelActive;
  if ContrProps.IsVisible then begin
   SplinePanel.InitFromKF(ContrProps.id);
   BuildPanels;
  end;//of if
  cb_mover.checked:=ObjAnimate.IsMoveRestrict(SelObj.b.ObjectID);
  cb_rotationr.checked:=ObjAnimate.IsRotRestrict(SelObj.b.ObjectID);
  cb_scalingr.checked:=ObjAnimate.IsScRestrict(SelObj.b.ObjectID);
  ApplyInstrumRestrictions;
  label44.tag:=0;
 end;//of if
 PopFunction;
End;

//Вырезание куска линейки
procedure Tfrm1.N27Click(Sender: TObject);
Var bSaveFilter,IsDel:boolean;Count,cnt2,FrameS,FrameE,i,ii,j,jj:integer;
    su:TDelSeqUndo;
begin
 PushFunction(143);
 if SelMinFrame<SelMaxFrame then begin
  FrameS:=SelMinFrame;
  FrameE:=SelMaxFrame;
 end else begin
  FrameS:=SelMaxFrame;
  FrameE:=SelMinFrame;
 end;//of if
 //Проверка на пересечение концов линейки
 if FrameS=MinFrame then inc(FrameS);
 if FrameE=MaxFrame then dec(FrameE);
 if FrameE<FrameS then begin PopFunction;exit;end;//какая-то ошибка
 Count:=FrameE-FrameS+1;          //когда совпадают - 1 кадр

 //Что ж, можно удалять кадры
 bSaveFilter:=IsContrFilter;
 IsContrFilter:=false;            //временно снимаем фильтрацию

 //Удаление меток EventObject'ов (с сохранением в NewUndo,
 //если нужно - удаляются все объекты):
 DeleteEventStamps(FrameS,FrameE);

 DeleteKeyFrames(FrameS,FrameE);  //удаление+SaveUndo
 Undo[CountOfUndo].Status1:=uCutKeyFrames;
 Undo[CountOfUndo].Sequence.IntervalStart:=FrameS;
 Undo[CountOfUndo].Sequence.MoveSpeed:=UsingGlobalSeq;
 Undo[CountOfUndo].Sequence.IntervalEnd:=Count;

 //Удаление анимаций, границы которых лежат в удаляемой области
 //(Если, конечно, есть такие анимации)
 cnt2:=CountOfSequences;
 if UsingGlobalSeq<0 then begin
  i:=0; IsDel:=false;
  while i<CountOfSequences do begin
   if ((Sequences[i].IntervalStart>=FrameS) and
       (Sequences[i].IntervalStart<=FrameE)) or
      ((Sequences[i].IntervalEnd>=FrameS) and
       (Sequences[i].IntervalEnd<=FrameE)) then begin
    //Попадание границ. Удаляем:
    SaveNewUndo(uDeleteSeq,i);    //сохранить для отмены
    NewUndo[CountOfNewUndo-1].Prev:=0;
    AnimPanel.DelSeq(i);          //удалить
    IsDel:=true;
{    su:=TDelSeqUndo.Create;

    su.TypeOfUndo:=uCutKeyFrames;
    su.Prev:=0;
    su.id:=i;
    su.Save;
    inc(CountOfNewUndo);
    SetLength(NewUndo,CountOfNewUndo);
    NewUndo[CountOfNewUndo-1]:=su;
    //b. Собственно удаление
    for ii:=i+1 to CountOfSequences-1 do begin
     Sequences[ii-1]:=Sequences[ii];
     for j:=0 to CountOfGeosets-1 do with Geosets[j] do begin
      for jj:=i+1 to CountOfAnims-1 do Anims[jj-1]:=Anims[jj];
      if i<CountOfAnims then begin
       dec(CountOfAnims);
       SetLength(Anims,CountOfAnims);
      end;//of if
     end;//of for j
    end;//of for ii
    dec(CountOfSequences);
    SetLength(Sequences,CountOfSequences);
    cb_animlist.Items.Delete(i+1);}
    continue;
   end;//of if
   inc(i);
  end;//of while

  //Удаление анимаций закончено.
  //Теперь, если хоть что-то удалилось, пересоберём список анимаций
  if IsDel then begin
   AnimPanel.MakeAnimList;
   cb_animlist.items.Assign(AnimPanel.SeqList);
   cb_animlist.ItemIndex:=0;
   cb_animlistChange(Sender);
  end;//of if
 end;//of if(НЕглобальная анимация)
 if cnt2<>CountOfSequences then frm_obj.MakeSequencesList; //пересоздать список

 ShearFrames(FrameS,UsingGlobalSeq,-Count);
 //Восстановить фильтр
 IsContrFilter:=bSaveFilter;

{ IsModified:=true;
 sb_animundo.enabled:=true;
 CtrlZ1.enabled:=true;
 frm1.StrlS1.enabled:=true;
 frm1.sb_save.enabled:=true;}
 GraphSaveUndo;
 MaxFrame:=MaxFrame-Count;
 //Теперь - обновление
 AbsMaxFrame:=AbsMaxFrame-Count;
 SelMinFrame:=CurFrame;
 SelMaxFrame:=CurFrame;
 ReMakeObjPropPanels;
 AnimLineRefresh(Sender);
 PopFunction;
end;

//Удаление выделенного
procedure Tfrm1.Del2Click(Sender: TObject);
Var FrameS,FrameE:integer;
begin
 if (EditorMode=emVertex) or (AnimEdMode=0) then exit;

 PushFunction(144);
 if SelMinFrame<SelMaxFrame then begin
  FrameS:=SelMinFrame;
  FrameE:=SelMaxFrame;
 end else begin
  FrameS:=SelMaxFrame;
  FrameE:=SelMinFrame;
 end;//of if
 DeleteKeyFrames(FrameS,FrameE);

 GraphSaveUndo;
 ReMakeObjPropPanels;

 AnimLineRefresh(Sender);
 PopFunction;
end;


//Создание контроллера видимости
procedure Tfrm1.bb_VisCreateClick(Sender: TObject);
Var j,coC:integer;it:TContItem;
begin
 PushFunction(145);
 //1. Проверим, нужно ли создавать анимации видимости
 //При необходимости они создаются
 CreateGeosetAnimsIfNeed;
 coC:=0;
 Undo[CountOfUndo].Sequence.IsNonLooping:=false;//альфа
 Undo[CountOfUndo].MatID:=length(Controllers); //сохранить кол-во контроллеров
 //2. Проверим все анимации видимости.
 for j:=0 to CountOfGeosets-1 do begin
  GeoObjs[j].Undo[CountOfUndo].Status2:=0;
  if GeoObjs[j].IsSelected then begin
   //(а)-создадим новый контроллер
   if GeosetAnims[j].IsAlphaStatic then begin
    GeosetAnims[j].IsAlphaStatic:=false;
    it.Frame:=0;
    it.Data[1]:=1;
    GeosetAnims[j].AlphaGraphNum:=CreateController(-1,it,ctAlpha);
    if UsingGlobalSeq>=0
    then Controllers[GeosetAnims[j].AlphaGraphNum].GlobalSeqId:=UsingGlobalSeq;
    GeoObjs[j].Undo[CountOfUndo].Status2:=1;//создание контроллера
    continue;
   end;//of if(создать новый контроллер)

   //(б)-ничего не сделаем(он уже есть)
   //[...] - соответственно, нет вообще никаких действий, даже проверки

   //б2 - проверяем, что там с глобальными последовательностями
   with GeosetAnims[j]
   do if Controllers[AlphaGraphNum].GlobalSeqID<>UsingGlobalSeq then begin
    inc(coC);
    SetLength(Undo[CountOfUndo].Controllers,coC);
    SetLength(Undo[CountOfUndo].idata,coC);
    Undo[CountOfUndo].idata[coC-1]:=GeosetAnims[j].AlphaGraphNum;
    GeoObjs[j].Undo[CountOfUndo].Status2:=2;//преобразование контроллера
    
    cpyController(Controllers[AlphaGraphNum],
                  Undo[CountOfUndo].Controllers[coC-1]);
    Controllers[AlphaGraphNum].ContType:=DontInterp;
    Controllers[AlphaGraphNum].GlobalSeqId:=UsingGlobalSeq;
    SetLength(Controllers[AlphaGraphNum].Items,1);
    Controllers[AlphaGraphNum].Items[0].Frame:=0;
    Controllers[AlphaGraphNum].Items[0].Data[1]:=1;        
   end;//of with/if

   //(в)-преобразуем контроллер к типу DontInterp.
   if Controllers[GeosetAnims[j].AlphaGraphNum].ContType<>DontInterp then begin
    inc(coC);
    SetLength(Undo[CountOfUndo].Controllers,coC);
    SetLength(Undo[CountOfUndo].idata,coC);
    Undo[CountOfUndo].Controllers[coC-1].Items:=nil;
    Undo[CountOfUndo].idata[coC-1]:=GeosetAnims[j].AlphaGraphNum;
    GeoObjs[j].Undo[CountOfUndo].Status2:=2;//преобразование контроллера
    TranslateControllerType(GeosetAnims[j].AlphaGraphNum,OnOff,
                            Undo[CountOfUndo].Controllers[coC-1]);
   end;//of if(преобразование контроллера)
  end;//of if(IsSelected)
 end;//of for j

 //3. Привести в порядок панели, всё перерисовать.
{ sb_animundo.enabled:=true;IsModified:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}
 GraphSaveUndo;
 AnimLineRefresh(Sender);
 PopFunction;
end;

//Создание контроллеров прозрачности
procedure Tfrm1.bb_AlphaCreateClick(Sender: TObject);
Var coC,j:integer;it:TContItem;
begin
 PushFunction(146);
 //1. Проверим, нужно ли создавать анимации видимости
 //При необходимости они создаются
 CreateGeosetAnimsIfNeed;
 coC:=0;
 Undo[CountOfUndo].Sequence.IsNonLooping:=false;//альфа
 Undo[CountOfUndo].MatID:=length(Controllers); //сохранить кол-во контроллеров
 //2. Проверим все анимации видимости.
 for j:=0 to CountOfGeosets-1 do begin
  GeoObjs[j].Undo[CountOfUndo].Status2:=0;
  if GeoObjs[j].IsSelected then begin
   //(а)-создадим новый контроллер
   if GeosetAnims[j].IsAlphaStatic then begin
    GeosetAnims[j].IsAlphaStatic:=false;
    it.Frame:=0;
    it.Data[1]:=1;
    GeosetAnims[j].AlphaGraphNum:=CreateController(-1,it,ctAlpha);
    Controllers[GeosetAnims[j].AlphaGraphNum].ContType:=Linear;
    if UsingGlobalSeq>=0
    then Controllers[GeosetAnims[j].AlphaGraphNum].GlobalSeqId:=UsingGlobalSeq;
    GeoObjs[j].Undo[CountOfUndo].Status2:=1;//создание контроллера
    continue;
   end;//of if(создать новый контроллер)

   //(б)-ничего не сделаем(он уже есть)
   //[...] - соответственно, нет вообще никаких действий, даже проверки
   
   //б2 - проверяем, что там с глобальными последовательностями
   with GeosetAnims[j]
   do if Controllers[AlphaGraphNum].GlobalSeqID<>UsingGlobalSeq then begin
    inc(coC);
    SetLength(Undo[CountOfUndo].Controllers,coC);
    SetLength(Undo[CountOfUndo].idata,coC);
    Undo[CountOfUndo].idata[coC-1]:=GeosetAnims[j].AlphaGraphNum;
    GeoObjs[j].Undo[CountOfUndo].Status2:=2;//преобразование контроллера
    
    cpyController(Controllers[AlphaGraphNum],
                  Undo[CountOfUndo].Controllers[coC-1]);
    Controllers[AlphaGraphNum].ContType:=Linear;
    Controllers[AlphaGraphNum].GlobalSeqId:=UsingGlobalSeq;
    SetLength(Controllers[AlphaGraphNum].Items,1);
    Controllers[AlphaGraphNum].Items[0].Frame:=0;
    Controllers[AlphaGraphNum].Items[0].Data[1]:=1;        
   end;//of with/if

   //(в)-преобразуем контроллер к типу Linear.
   if Controllers[GeosetAnims[j].AlphaGraphNum].ContType=DontInterp then begin
    inc(coC);
    SetLength(Undo[CountOfUndo].Controllers,coC);
    SetLength(Undo[CountOfUndo].idata,coC);
    Undo[CountOfUndo].Controllers[coC-1].Items:=nil;
    Undo[CountOfUndo].idata[coC-1]:=GeosetAnims[j].AlphaGraphNum;
    GeoObjs[j].Undo[CountOfUndo].Status2:=2;//преобразование контроллера
    TranslateControllerType(GeosetAnims[j].AlphaGraphNum,Linear,
                            Undo[CountOfUndo].Controllers[coC-1]);
   end;//of if(преобразование контроллера)
  end;//of if(IsSelected)
 end;//of for j

 //3. Привести в порядок панели, всё перерисовать.
{ sb_animundo.enabled:=true;IsModified:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}
 GraphSaveUndo;
 AnimLineRefresh(Sender);
 PopFunction;
end;

//Создать цветовую анимацию
procedure Tfrm1.bb_ColorCreateClick(Sender: TObject);
Var coC,j,i:integer;it:TContItem;
begin
 PushFunction(147);
 //1. Проверим, нужно ли создавать анимации видимости
 //При необходимости они создаются
 CreateGeosetAnimsIfNeed;
 coC:=0;
 Undo[CountOfUndo].Sequence.IsNonLooping:=true;//цвет
 Undo[CountOfUndo].MatID:=length(Controllers); //сохранить кол-во контроллеров
 Undo[CountOfUndo].VertexList:=nil;
 Undo[CountOfUndo].VertexGroup:=nil;
 //2. Проверим все анимации видимости.
 for j:=0 to CountOfGeosets-1 do begin
  GeoObjs[j].Undo[CountOfUndo].Status2:=0;
  if GeoObjs[j].IsSelected then begin
   //(а)-создадим новый контроллер
   if GeosetAnims[j].IsColorStatic then begin
    GeosetAnims[j].IsColorStatic:=false;
    it.Frame:=0;
    if GeosetAnims[j].Color[1]<0 then begin
     it.Data[1]:=1;it.Data[2]:=1;it.Data[3]:=1;
    end else with GeosetAnims[j] do begin
     it.Data[1]:=Color[1];it.Data[2]:=Color[2];it.Data[3]:=Color[3];
    end;//of with/if
    GeosetAnims[j].ColorGraphNum:=CreateController(-1,it,ctTranslation);
    Controllers[GeosetAnims[j].ColorGraphNum].ContType:=Linear;
    if UsingGlobalSeq>=0
    then Controllers[GeosetAnims[j].ColorGraphNum].GlobalSeqId:=UsingGlobalSeq;
    GeoObjs[j].Undo[CountOfUndo].Status2:=3;//создание цветового контроллера
    //Дополним контроллер кадрами в каждой анимации
    if UsingGlobalSeq<0 then for i:=0 to CountOfSequences-1 do begin
     it.Frame:=Sequences[i].IntervalStart;
     InsertFrame(Controllers[GeosetAnims[j].ColorGraphNum],it);
    end;//of for i/if
    //Проверим все материалы.
    TestMaterialColors(Geosets[j].MaterialID);
    continue;
   end;//of if(создать новый контроллер)

   //(б)-ничего не сделаем(он уже есть)
   //[...] - соответственно, нет вообще никаких действий, даже проверки

   //б2 - проверяем, что там с глобальными последовательностями
   with GeosetAnims[j]
   do if Controllers[ColorGraphNum].GlobalSeqID<>UsingGlobalSeq then begin
    inc(coC);
    SetLength(Undo[CountOfUndo].Controllers,coC);
    SetLength(Undo[CountOfUndo].idata,coC);
    Undo[CountOfUndo].idata[coC-1]:=GeosetAnims[j].ColorGraphNum;
    GeoObjs[j].Undo[CountOfUndo].Status2:=2;//преобразование контроллера

    cpyController(Controllers[ColorGraphNum],
                  Undo[CountOfUndo].Controllers[coC-1]);
    Controllers[ColorGraphNum].ContType:=Linear;
    Controllers[ColorGraphNum].GlobalSeqId:=UsingGlobalSeq;
    SetLength(Controllers[ColorGraphNum].Items,1);
    Controllers[ColorGraphNum].Items[0].Frame:=0;
    Controllers[ColorGraphNum].Items[0].Data[1]:=1;
   end;//of with/if

   //(в)-преобразуем контроллер к типу Linear.
   if Controllers[GeosetAnims[j].ColorGraphNum].ContType=DontInterp then begin
    inc(coC);
    SetLength(Undo[CountOfUndo].Controllers,coC);
    SetLength(Undo[CountOfUndo].idata,coC);
    Undo[CountOfUndo].Controllers[coC-1].Items:=nil;
    Undo[CountOfUndo].idata[coC-1]:=GeosetAnims[j].ColorGraphNum;
    GeoObjs[j].Undo[CountOfUndo].Status2:=2;//преобразование контроллера
    TranslateControllerType(GeosetAnims[j].ColorGraphNum,Linear,
                            Undo[CountOfUndo].Controllers[coC-1]);
   end;//of if(преобразование контроллера)
  end;//of if(IsSelected)
 end;//of for j

 //3. Привести в порядок панели, всё перерисовать.
{ sb_animundo.enabled:=true;IsModified:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}
 GraphSaveUndo;
 AnimLineRefresh(Sender);
 PopFunction;
end;

//Изменение контроллеров видимости
procedure Tfrm1.cb_VisOnClick(Sender: TObject);
Var j:integer;it:TContItem;
begin
 if cb_VisOn.tag<>0 then exit;    //защита
 PushFunction(148);
 //Установка видимости (вкл/выкл)
 if cb_VisOn.checked then it.Data[1]:=1
                     else it.Data[2]:=0;
 it.Frame:=CurFrame;

 //1. Сохранимся для последующей отмены
 AnimSaveUndo(uChangeFrame,0);    //инициализировать сохранение для отмены
 
 //2. Сохранение и модификация текущего кадра проводятся параллельно
 for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do if IsSelected then begin
  SaveContFrame(GeosetAnims[j].AlphaGraphNum,CurFrame);
  InsertFrame(Controllers[GeosetAnims[j].AlphaGraphNum],it);
 end;//of for j

 //3. Привести в порядок панели, всё перерисовать.
{ sb_animundo.enabled:=true;IsModified:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}
 GraphSaveUndo;
 AnimLineRefresh(Sender);
 PopFunction;
end;

//Фильтр "неправильных" клавиш
procedure Tfrm1.ed_alphaKeyPress(Sender: TObject; var Key: Char);
begin
 if (not (key in ['0'..'9'])) and (key<>'-') and (key<>'.')
    and (key>#30) then key:=#0;
end;

procedure Tfrm1.ed_alphaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=vk_delete then key:=0;
 if key=VK_RETURN then ed_alphaExit(Sender);
end;

//Установка прозрачности
procedure Tfrm1.ed_alphaExit(Sender: TObject);
Var num:GLFloat;j:integer;it:TContItem;
begin
 if pn_seq.tag<>0 then exit;
 PushFunction(149);
 //1. Проверки на правильность ввода
 if not IsCipher(ed_Alpha.text) then begin
  ed_alpha.text:=floattostrf(MidAlpha,ffFixed,10,5);
  ed_Alpha.SelectAll;
  PopFunction;
  exit;
 end;//of if
 num:=strtofloat(ed_alpha.text);
 if abs(num-MidAlpha)<0.001 then begin //нечего менять
  ed_Alpha.SelectAll;
  PopFunction;
  exit;
 end;//of if
 if (num<0) or (num>1) then begin   //неверное значение
  ed_alpha.text:=floattostrf(MidAlpha,ffFixed,10,5);
  ed_Alpha.SelectAll;
  PopFunction;
  exit;
 end;//of if

 //2. Установка прозрачности в кадре.
 it.Frame:=CurFrame;
 it.Data[1]:=num;
 it.InTan[1]:=0;it.OutTan[1]:=0;
 AnimSaveUndo(uChangeFrame,0);
 for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do if IsSelected then begin
  SaveContFrame(GeosetAnims[j].AlphaGraphNum,CurFrame);
  InsertFrame(Controllers[GeosetAnims[j].AlphaGraphNum],it);
 end;//of for j

 //3. Привести в порядок панели, всё перерисовать.
{ sb_animundo.enabled:=true;IsModified:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}
 GraphSaveUndo;
 AnimLineRefresh(Sender);
 application.processmessages;
 ed_Alpha.SetFocus;
 ed_alpha.SelectAll;
 PopFunction;
end;

//Установка цветов
procedure Tfrm1.ed_rExit(Sender: TObject);
Var j:integer;it:TContItem;
    r,g,b:GLFloat;
begin
 //1. Начальная проверка
 if pn_seq.tag<>0 then exit;
 PushFunction(150);
 //2. Проверка чисел
 if ed_r.text='' then begin
  ed_r.text:=inttostr(round(cr*255));
  ed_r.SelectAll;
  PopFunction;
  exit;
 end;//of if
 if ed_g.text='' then begin
  ed_g.text:=inttostr(round(cg*255));
  ed_g.SelectAll;
  PopFunction;
  exit;
 end;//of if
 if ed_b.text='' then begin
  ed_b.text:=inttostr(round(cb*255));
  ed_b.SelectAll;
  PopFunction;
  exit;
 end;//of if

 //3. Получение чисел и ещё одна проверка
 r:=strtoint(ed_r.text);
 g:=strtoint(ed_g.text);
 b:=strtoint(ed_b.text);
 if r>255 then begin
  ed_r.text:=inttostr(round(cr*255));
  ed_r.SelectAll;
  PopFunction;
  exit;
 end;//of if
 if g>255 then begin
  ed_g.text:=inttostr(round(cg*255));
  ed_g.SelectAll;
  PopFunction;
  exit;
 end;//of if
 if b>255 then begin
  ed_b.text:=inttostr(round(cb*255));
  ed_b.SelectAll;
  PopFunction;
  exit;
 end;//of if

 //4. Проверка на необходимость изменения
 r:=r/255; g:=g/255; b:=b/255;
 if (abs(r-cr)<0.001) and (abs(g-cg)<0.001) and (abs(b-cb)<0.001) then begin
  ed_r.SelectAll;
  ed_g.SelectAll;
  ed_b.SelectAll;
  PopFunction;
  exit;
 end;//of if

 //5. Приступаем к добавлению
 it.Frame:=CurFrame;
 it.Data[1]:=b;  it.Data[2]:=g;  it.Data[3]:=r;
 it.InTan[1]:=0; it.InTan[2]:=0; it.InTan[3]:=0;
 it.OutTan[1]:=0;it.OutTan[2]:=0;it.OutTan[3]:=0;
 AnimSaveUndo(uChangeFrame,0);
 for j:=0 to CountOfGeosets-1 do with GeoObjs[j] do if IsSelected then begin
  SaveContFrame(GeosetAnims[j].ColorGraphNum,CurFrame);
  InsertFrame(Controllers[GeosetAnims[j].ColorGraphNum],it);
 end;//of for j

 //3. Привести в порядок панели, всё перерисовать.
{ sb_animundo.enabled:=true;IsModified:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}
 GraphSaveUndo;
 AnimLineRefresh(Sender);
 application.processmessages;
 PopFunction;
end;

procedure Tfrm1.ed_rKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=vk_delete then key:=0;
 if key=VK_RETURN then ed_rExit(Sender);
end;

//Высвечивание окна иерархий
procedure Tfrm1.H1Click(Sender: TObject);
begin
 PushFunction(151);
 if (AnimEdMode=0) and (EditorMode=emAnims) and (cb_bonelist.items.count=0)
 then begin PopFunction;exit;end;
 frm_obj.Show;
 PopFunction;
end;

//клик по меню "нормализовать при загрузке"
procedure Tfrm1.N36Click(Sender: TObject);
begin
 N36.checked:=not N36.Checked;
end;

//Заготовка оптимизатора: удаление повторяющихся
//поверхностей
procedure Tfrm1.N37Click(Sender: TObject);
Var i,ii:integer;dltFlg:boolean;
begin
 PushFunction(152);
 dltFlg:=false;
 //цикл по всем поверхностям (кроме 0-й)
 i:=0;
 while i<CountOfGeosets do begin
  ii:=i+1;
  while ii<CountOfGeosets do begin
   if CompareGeosets(i,ii) then begin
    DeleteGeoset(ii+1);
    dltFlg:=true;
    continue;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of while
 sb_undo.enabled:=false;
 CountOfUndo:=0;
 CtrlZ1.enabled:=false;
 RefreshGeoList(Sender,true);
 PopFunction;
end;

//Вынос выделенных частей поверхностей
//в отдельные поверхности
procedure Tfrm1.b_detachClick(Sender: TObject);
Var GeoID,VertID,i,ii:integer;bnd:TAnim;IsDec:boolean;
begin
 PushFunction(153);
 GeoID:=GetIDOfSelGeoset;
 //Если выделены все вершины поверхности - ошибка (нечего отделять)
 if GeoObjs[GeoID].VertexCount=Geosets[GeoID].CountOfVertices then begin
  PopFunction;
  exit;
 end;
 //Сохраняем для отмены:
 SaveUndo(uVertexDelete);         //сохраним как удаление
 Undo[CountOfUndo].Status1:=uGeosetDetach;//пометим как "отсоединение"

 //1. Создаём новую поверхность (пока пустую)
 inc(CountOfGeosets);
 SetLength(Geosets,CountOfGeosets);
 SetLength(GeoObjs,CountOfGeosets);
 SetLength(VisGeosets,CountOfGeosets);
 VisGeosets[CountOfGeosets-1]:=true;
 FillChar(GeoObjs[CountOfGeosets-1],SizeOf(TGeoObj),0);
 FillChar(Geosets[CountOfGeosets-1],SizeOf(TGeoset),0);

 //2. Копируем выделенный кусок в новую поверхность
 with Geosets[CountOfGeosets-1] do begin
  CountOfVertices:=GeoObjs[GeoID].VertexCount;
  CountOfNormals:=CountOfVertices;
  SetLength(Vertices,CountOfVertices);
  SetLength(Normals,CountOfNormals);
  SetLength(VertexGroup,CountOfVertices);
  HierID:=-2;                     //вставленная поверхность

  for i:=0 to CountOfVertices-1 do begin
   VertID:=GeoObjs[GeoID].VertexList[i]-1;
   Vertices[i]:=Geosets[GeoID].Vertices[VertID];
   Normals[i]:=Geosets[GeoID].Normals[VertID];
   //Формирование групп (+их номеров)
   VertexGroup[i]:=GetBoneGroupID(
         Geosets[GeoID].Groups[Geosets[GeoID].VertexGroup[VertID]],Groups);
  end;//of for i

  //текстурные плоскости
  CountOfCoords:=Geosets[GeoID].CountOfCoords;
  SetLength(Crds,CountOfCoords);
  for i:=0 to CountOfCoords-1 do begin
   Crds[i].CountOfTVertices:=CountOfVertices;
   SetLength(Crds[i].TVertices,CountOfVertices);
   for ii:=0 to CountOfVertices-1 do Crds[i].TVertices[ii]:=
       Geosets[GeoID].Crds[i].TVertices[GeoObjs[GeoID].VertexList[ii]-1];
  end;//of for i
 end;//of with

 FindSelectedFaces(GeoID+1);     //список выделенных треугольников
 //Копируем их
 with GeoObjs[GeoID] do begin
  SetLength(Geosets[CountOfGeosets-1].Faces,1);
  SetLength(Geosets[CountOfGeosets-1].Faces[0],length(SelFaces));
  //Ищем ID вершины в списке
  for i:=0 to High(SelFaces) do for ii:=0 to VertexCount-1 do
   if SelFaces[i]=VertexList[ii]-1 then begin
    Geosets[CountOfGeosets-1].Faces[0,i]:=ii;
    break;
  end;//of if/for ii/for i
 end;//of with

 GeoObjs[GeoID].SelFaces:=nil;   //освободить память

 //Продолжаем заполнение поверхности
 with Geosets[CountOfGeosets-1] do begin
  CalcBounds(CountOfGeosets-1,bnd); //рассчитать границы
  MinimumExtent:=bnd.MinimumExtent;
  MaximumExtent:=bnd.MaximumExtent;
  BoundsRadius:=bnd.BoundsRadius;
  //Заполняем список Anim-границ
  CountOfAnims:=Geosets[GeoID].CountOfAnims;
  SetLength(Anims,CountOfAnims);
  for i:=0 to CountOfAnims-1 do Anims[i]:=bnd;
  //заполняем оставшиеся поля
  MaterialID:=Geosets[GeoID].MaterialID;
  SelectionGroup:=Geosets[GeoID].SelectionGroup;
  Unselectable:=Geosets[GeoID].Unselectable;
  CountOfFaces:=1;
  CountOfMatrices:=length(Groups);
  Color4f[1]:=1;Color4f[2]:=1;Color4f[3]:=1;Color4f[4]:=1;
  //Если нужно, создаём фиктивный треугольник
  if length(Faces[0])=0 then begin
   SetLength(Faces[0],3);
   Faces[0,1]:=0;Faces[0,2]:=0;Faces[0,3]:=0;
  end;//of if
 end;//of with

 //3. Копируем анимацию видимости поверхности
 //(если у поверхности-источника есть таковая)
 for i:=0 to CountOfGeosetAnims-1 do if GeosetAnims[i].GeosetID=GeoID then begin
  inc(CountOfGeosetAnims);
  SetLength(GeosetAnims,CountOfGeosetAnims);
  GeosetAnims[CountOfGeosetAnims-1]:=GeosetAnims[i];
  with GeosetAnims[CountOfGeosetAnims-1] do begin
   GeosetID:=CountOfGeosets-1;
   if not IsAlphaStatic then begin
    SetLength(Controllers,length(Controllers)+1);
    cpyController(Controllers[AlphaGraphNum],Controllers[High(Controllers)]);
    AlphaGraphNum:=High(Controllers);
   end;//of if
   if not IsColorStatic then begin
    SetLength(Controllers,length(Controllers)+1);
    cpyController(Controllers[ColorGraphNum],Controllers[High(Controllers)]);
    ColorGraphNum:=High(Controllers);
   end;//of if
  end;//of with
 end;//of if/for i

 //4. Помечаем все выделенные треугольники
 //исходной поверхности как (-1) для удаления
 FindNumbersSelFaces(GeoID+1);    //индексы в SelFaces
 for i:=0 to High(GeoObjs[GeoID].SelFaces)
 do with Geosets[GeoID] do begin
  Faces[0,GeoObjs[GeoID].SelFaces[i]]  :=-1;
  Faces[0,GeoObjs[GeoID].SelFaces[i]+1]:=-1;
  Faces[0,GeoObjs[GeoID].SelFaces[i]+2]:=-1;
 end;//of for i

 //5. Снимаем выделение с вершин, ещё попадающих
 //в треугольники, затем удалим оставшиеся вершины
 i:=0;
 with GeoObjs[GeoId],Geosets[GeoID] do begin
  while i<VertexCount do begin
   IsDec:=false;
   for ii:=0 to High(Faces[0]) do if VertexList[i]-1=Faces[0,ii] then begin
    VertexList[i]:=VertexList[VertexCount-1];
    dec(VertexCount);IsDec:=true;
    if VertexCount=0 then break;
   end;//of for ii
   if not IsDec then inc(i);
  end;//of while
  for i:=0 to VertexCount-1 do DeleteVertex(GeoID+1,VertexList[i]);
  //удаляем остаток
  FinalizeDeleting(GeoID+1);
  VertexList:=nil;VertexCount:=0;
 end;//of with

 //Перерисовка
 CalcVertex2D(GlWorkArea.ClientHeight);
 RefreshGeoList(Sender,true);
 PopFunction;
end;

//Рисование закладочек
procedure Tfrm1.tc_modeDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
//204
begin
 tc_mode.Canvas.Brush.Color:=$CCCCCC;
 tc_mode.Canvas.FillRect(Rect);
 tc_mode.Canvas.TextRect(Rect,rect.left+5,rect.top+3,
                         tc_mode.Tabs.Strings[TabIndex]);
end;

//Очередной шкуринг: выделение нужной строки списка анимок
procedure Tfrm1.Timer1Timer(Sender: TObject);
begin
 PostMessage(cb_animlist.handle,CB_SETCURSEL,
             AnimPanel.SeqList.IndexOfObject(pointer(AnimPanel.ids)),0);
 Timer1.enabled:=false;
end;

//Попытка открытия старого файла
procedure Tfrm1.FF1Click(Sender: TObject);
Var s:string;
begin
 PushFunction(154);
 s:=TMenuItem(Sender).Name;       //получить имя меню
 Delete(s,1,2);                   //удалить "FF"
 od_file.FileName:=RecentFiles[strtoint(s)];
 IsParFile:=true;
 application.processmessages;
 N2Click(Sender);                 //загрузить
 PopFunction;
end;

//Изменение состояния рабочей плоскости
procedure Tfrm1.cb_workplaneClick(Sender: TObject);
begin
 PushFunction(155);
 IsXYZ:=not cb_workplane.Checked;
 cb_workplane2.tag:=1;
 cb_workplane2.checked:=cb_workplane.checked;
 application.ProcessMessages;
 rb_xy.enabled:=cb_workplane.checked;
 rb_xz.enabled:=cb_workplane.checked;
 rb_yz.enabled:=cb_workplane.checked;
 rb_bxy.enabled:=cb_workplane2.checked;
 rb_bxz.enabled:=cb_workplane2.checked;
 rb_byz.enabled:=cb_workplane2.checked;
 if EditorMode=emVertex then RefreshWorkArea(Sender)
 else begin
  pb_animMouseUp(Sender,mbLeft,[],0,0);//перечертить кадр
 end;//of else
 cb_workplane2.tag:=0;
 PopFunction;
end;

//Показать/скрыть оси координат
procedure Tfrm1.N39Click(Sender: TObject);
begin
 IsAxes:=not N39.checked;
 N39.checked:=IsAxes;
 RefreshWorkArea(Sender);
end;

//Переключение режима работы редактора анимаций
procedure Tfrm1.tc_modeChange(Sender: TObject);
Var j:integer;
begin
 PushFunction(156);
 AnimEdMode:=tc_mode.TabIndex;    //установить режим работы
 iAnimEdMode:=AnimEdMode;        //для крэш-дампа
 sb_animcross.down:=true;         //сбросить режим
 sb_animcrossClick(Sender);
 ccX:=0; ccY:=0; ccZ:=0;
 SplinePanel.Hide;
 ContrProps.Hide;
 pn_boneedit.enabled:=true;
 pn_propobj.visible:=false;
 cb_bonelist.Style:=csDropDown;

 if not sb_coll2p.visible then begin
  pn_objs.height:=160;
  clb_geolist.height:=121;
 end;//of if

 //Очистить списки дочерних вершин
 for j:=0 to CountOfGeosets-1 do begin
  Geosets[j].CountOfChildVertices:=0;
  Geosets[j].CountOfDirectCV:=0;
  GeoObjs[j].VertexCount:=0;
  GeoObjs[j].VertexList:=nil;
 end;//of for j

 N28.visible:=false;

 case AnimEdMode of               //настройка окон/панелей
  0:begin                         //Скелет
   ObjAnimate.ClearRestricts;
   sb_bonerot.visible:=false;
   sb_bonescale.visible:=false;
   sb_begattach.visible:=true;
   sb_objdel.visible:=true;
   sb_detach.visible:=true;
   sb_vattach.visible:=true;
   sb_vreattach.visible:=true;
   sb_vdetach.visible:=true;

   sb_animcopy.enabled:=false;
   sb_animpaste.enabled:=false;
   CtrlV2.enabled:=false;
   CtrlC1.enabled:=false;
   CtrlV1.enabled:=false;
   CtrlA1.enabled:=false;
   SelObj.IsSelected:=false;      //ничего не выбрано
   SelObj.IsMultiSelect:=false;
   N44.enabled:=true;
   sb_selexpand.visible:=false;
   cb_multiselect.tag:=1;
   cb_multiselect.checked:=false;
   cb_multiselect.tag:=0;
   cb_bonelist.enabled:=true;
   pn_boneedit.height:=185;
   ChObj.IsSelected:=false;
   SelObj.b.ObjectID:=-1;
   cb_bonelist.tag:=-1;           //ничего не выделено
   frm_obj.lv_obj.tag:=-1;
   InstrumStatus:=isSelect;       //для возможности выбора
   ccX:=0;ccY:=0;ccZ:=0;          //сброс координат подсветки
   FindNullBone;                  //искать кость-заглушку
   IsObjsDown:=false;
   pn_boneedit.enabled:=true;     //открыть доступ к панели инстр.
   sb_objdel.Enabled:=false;      //закрыть инструменты
   sb_detach.enabled:=false;
   label13.caption:='Выделено вершин: 0';
   sb_vattach.enabled:=false;
   sb_vreattach.enabled:=false;
   sb_vdetach.enabled:=false;
   pn_listbones.visible:=false;
   pn_vertcoords.visible:=false;
   if sb_stop.visible then sb_stopClick(Sender);//остановить проигрывание
   pn_boneedit.visible:=true;     //включить инструменты скелета
   pn_seq.visible:=false;         //выключить инструменты анимаций
   pn_color.visible:=false;       //выключить инструменты видимости
   label30.visible:=false;
   N44.visible:=true;             //меню "Создать"
   N46.visible:=false;            //пункт "Направления"
   cb_bonelist.text:='';
   ed_bonex.text:=''; ed_bonex.ReadOnly:=true;
   ed_boney.text:=''; ed_boney.ReadOnly:=true;
   ed_bonez.text:=''; ed_bonez.ReadOnly:=true;
   pn_listbones.visible:=false;
   pn_vertcoords.visible:=false;
   lb_bones.items.Clear;
   sb_selbone.down:=true;
   MakeTextObjList(Sender);       //построить список объектов
   pn_anim.visible:=false;        //убрать панель анимаций (не нужна)
   CurFrame:=0;                   //нулевой кадр
   MinFrame:=0;MaxFrame:=1;       //задание кадров
   N33.Visible:=true;
   frm_obj.lv_obj.tag:=-1;
   frm_obj.MakeObjectsList(-1,-1);//заполнить список объектами
   pb_animMouseUp(Sender,mbLeft,[],0,0);//перечертить кадр
   pn_workplane.visible:=true;
   pn_binstrum.visible:=true;
   sb_begattach.enabled:=false;
   sb_begattach.visible:=true;
   sb_endattach.visible:=false;
   BuildPanels;
  end;//of (скелет)
  1:begin                         //Анимки
   N28.visible:=true;
   CtrlA1.enabled:=false;
   sb_animcopy.enabled:=true;
   CtrlC1.enabled:=true;
   pn_listbones.visible:=false;
   pn_vertcoords.visible:=false;
   lb_bones.items.clear;
   N44.visible:=false;            //меню "Создать"
   frm_obj.MakeSequencesList;     //сформировать их список
   IsListDown:=true;
   InstrumStatus:=-1;
   cb_animlistChange(Sender);
   pn_anim.visible:=true;         //включить панель кадров
   pn_boneedit.visible:=false;    //выключить инструменты скелета
   pn_seq.visible:=true;          //включить инструменты анимаций
   N33.Visible:=false;            //скрыть пункт "Вид->Объекты"
   pn_workplane.visible:=false;
   pn_binstrum.visible:=false;
   pn_boneprop.visible:=false;    //панели свойств
   pn_propobj.visible:=false;
   pn_contrprops.Hide;
   SplinePanel.Hide;
   pn_atchprop.visible:=false;
   pn_pre2prop.visible:=false;
   BuildPanels;                   //выровнять панели
  end;//of (анимки)

  2:begin                         //движение
   N28.visible:=true;
   //Обработать кнопки инструментов
   IsListDown:=true;
   cb_animlistChange(Sender);
   sb_selbone.down:=true;
   pn_seq.visible:=false;
   sb_bonerot.visible:=true;
   sb_bonescale.visible:=true;
   sb_bonerot.enabled:=false;
   sb_bonemove.enabled:=false;
   sb_bonescale.enabled:=false;
   if ChObj.IsSelected then ChObj.IsSelected:=false;
   sb_begattach.visible:=false;
   sb_endattach.visible:=false;
   sb_objdel.visible:=false;
   sb_detach.visible:=false;
   sb_vattach.visible:=false;
   sb_vreattach.visible:=false;
   sb_vdetach.visible:=false;
   sb_selexpand.visible:=false;
   N33.visible:=true;             //меню "Объекты"
   N46.visible:=true;             //пункт "Направления"
   label30.caption:='';           //"Тип объекта"
   cb_bonelist.text:='';
   ed_bonex.text:=''; ed_bonex.ReadOnly:=true;
   ed_boney.text:=''; ed_boney.ReadOnly:=true;
   ed_bonez.text:=''; ed_bonez.ReadOnly:=true;
   cb_bonelist.style:=csDropDownList; 

   SelObj.IsSelected:=false;      //ничего не выбрано
   SelObj.IsMultiSelect:=false;
   N44.enabled:=false;
   pn_anim.visible:=true;
   InstrumStatus:=isSelect;       //для возможности выбора
   ccX:=0;ccY:=0;ccZ:=0;          //сброс координат подсветки
   FindNullBone;                  //искать кость-заглушку
   IsObjsDown:=false;
   ChObj.IsSelected:=false;
   SelObj.b.ObjectID:=-1;
   cb_bonelist.tag:=-1;           //ничего не выделено
   frm_obj.lv_obj.tag:=-1;
   MakeTextObjList(Sender);       //построить список объектов
   frm_obj.MakeObjectsList(-1,-1);//заполнить список объектами

   pn_vertcoords.visible:=false;
   BuildPanels;
   pb_animMouseUp(Sender,mbLeft,[],0,0);//перечертить кадр
  end;//of (движение)
 end;//of case

 ccX:=0; ccY:=0; ccZ:=0;
 //Сброс стека отмен
 sb_animundo.enabled:=false;
 CtrlZ1.enabled:=false;
 CountOfUndo:=0;CountOfNewUndo:=0;
 NewUndo:=nil;
 PopFunction;
end;

//Клик по пункту меню "Кости"(видимость)
procedure Tfrm1.N34Click(Sender: TObject);
begin
 PushFunction(157);
 VisObjs.VisBones:=not N34.checked;
 N34.checked:=not N34.checked;
 RefreshWorkArea(Sender);
 PopFunction;
end;

//Клик по пункту меню "Точки прикрепления"
procedure Tfrm1.N35Click(Sender: TObject);
begin
 PushFunction(158);
 VisObjs.VisAttachments:=not N35.checked;
 N35.checked:=not N35.checked;
 RefreshWorkArea(Sender);
 PopFunction;
end;

//Клик по пункту меню "Скелет"
procedure Tfrm1.N40Click(Sender: TObject);
begin
 PushFunction(159);
 VisObjs.VisSkel:=not N40.checked;
 N40.Checked:=not N40.checked;
 RefreshWorkArea(Sender);
 PopFunction;
end;

//Смена имени объекта
procedure Tfrm1.cb_bonelistExit(Sender: TObject);
Var ind:integer;
begin
 PushFunction(160);
 if (not SelObj.IsSelected) or
    (cb_bonelist.text=cb_bonelist.Items.Strings[
    cb_bonelist.items.IndexOfObject(TObject(SelObj.b.ObjectID))]) then begin
  PopFunction;
  exit;
 end;

 if AnimEdMode=2 then begin
  PopFunction;
  exit;
 End;
 cb_bonelist.tag:=-2;
 //1. Сохраним для отмены
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}
 AnimSaveUndo(uChangeObjName,0);
 GraphSaveUndo;

 //2. Изменим имя
 SetObjectName(SelObj.b.ObjectID,cb_bonelist.text);
 SelObj.b.Name:=cb_bonelist.text;
 MakeTextObjList(Sender);         //построить список объектов заново
 ind:=cb_bonelist.items.IndexOfObject(TObject(SelObj.b.ObjectID));
 cb_bonelist.Items.Strings[ind]:=cb_bonelist.text;
 cb_bonelist.itemindex:=ind;
 cb_bonelist.tag:=cb_bonelist.itemindex;
 frm_obj.MakeObjectsList(SelObj.b.ObjectID,SelObj.b.ObjectID);
 PopFunction;
end;

procedure Tfrm1.cb_bonelistKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=VK_RETURN then begin
  cb_bonelistExit(Sender);
  cb_bonelist.SelectAll;
 end;
end;

//Разворачивается список объектов
procedure Tfrm1.cb_bonelistDropDown(Sender: TObject);
begin
 IsObjsDown:=true;                //отметить этот факт
end;

//Необходимо сменить имя объекта
procedure Tfrm1.time_lvChngTimer(Sender: TObject);
begin
 PushFunction(161);
 time_lvChng.enabled:=false;
 cb_bonelistExit(Sender);         //сменить имя объекта
 frm_obj.lv_obj.tag:=-1;
 //Вновь активируем окно списков
 application.processmessages;
 if frm_obj.CanFocus then frm_obj.SetFocus;
 PopFunction;
end;

//Удаление объекта скелета
procedure Tfrm1.sb_objdelClick(Sender: TObject);
Var j:integer;lst:TList;lf:TFace;
begin
 PushFunction(162);
 EndAttachObj;
 if not SelObj.IsSelected then begin PopFunction;exit;end;  //перестраховка

 //Если выделено несколько объектов - удалить их все
 if SelObj.IsMultiSelect then begin
  AnimSaveUndo(uDeleteObjects,0); //сохранить для отмены
  GraphSaveUndo;
{  CtrlZ1.enabled:=true;
  sb_animundo.enabled:=true;
  sb_save.enabled:=true;}

  //Переносим все ID объектов в список
  lst:=TList.Create;
  for j:=0 to SelObj.CountOfSelObjs-1 do lst.Add(pointer(SelObj.SelObjs[j]));
  lst.Sort(cmpItems);             //сортируем по возрастанию

  //Удаляем все объекты (от конца списка - чтобы не "поехали" ID):
  for j:=lst.Count-1 downto 0 do DeleteSkelObj(integer(lst.Items[j]));
  lst.Free;                       //освобождаем список

  //Приводим в порядок выделение
  lf:=nil;
  GraphMultiSelectObject(lf,0);
  dec(CountOfUndo);

//  BuildPanels;
  IsObjsDown:=false;
  IsMayChange:=false;
  MakeTextObjList(Sender);         //построить список объектов
  frm_obj.MakeObjectsList(-1,-1);  //перестроение списка
  FillBonesList;
  cb_billboard.tag:=0;
  cb_abillboard.tag:=0;
  IsMayChange:=true;
  PopFunction;
  exit;
 end;//of if

 AnimSaveUndo(uDeleteObject,0);   //сохранить для отмены
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}

 DeleteSkelObj(SelObj.b.ObjectID);//удаление
 ccX:=0;ccY:=0;ccZ:=0;

 SelObj.IsSelected:=false;        //ничего не выбрано
 SelObj.b.ObjectID:=-1;
 cb_bonelist.tag:=-1;             //ничего не выделено
 frm_obj.lv_obj.tag:=-1;
 cb_billboard.tag:=-1;
 cb_abillboard.tag:=-1;
 IsObjsDown:=false;
 IsMayChange:=false;
 MakeTextObjList(Sender);         //построить список объектов
 frm_obj.MakeObjectsList(-1,-1);  //перестроение списка
 pn_boneedit.enabled:=true;       //открыть доступ к панели инстр.
 sb_objdel.Enabled:=false;        //закрыть инструменты
 sb_detach.enabled:=false;
 sb_begattach.enabled:=false;
 sb_bonemove.enabled:=false;
 cb_bonelist.text:='';
 ed_bonex.text:=''; ed_bonex.ReadOnly:=true;
 ed_boney.text:=''; ed_boney.ReadOnly:=true;
 ed_bonez.text:=''; ed_bonez.ReadOnly:=true;
 //Очистить списки дочерних вершин
 for j:=0 to CountOfGeosets-1 do begin
  Geosets[j].CountOfChildVertices:=0;
  Geosets[j].CountOfDirectCV:=0;
 end;//of for j
 sb_selbone.down:=true;
 pn_boneprop.visible:=false;    //панели свойств
 pn_propobj.visible:=false;
// pn_contrprops.Hide;
 pn_atchprop.visible:=false;
 pn_pre2prop.visible:=false;
 BuildPanels;
 pn_listbones.visible:=false;
 pn_vertcoords.visible:=false;
 pb_animMouseUp(Sender,mbLeft,[],0,0);//перечертить кадр
 cb_billboard.tag:=0;
 cb_abillboard.tag:=0;
 IsMayChange:=true;
 EnableAttachInstrums;
 FillBonesList;
 PopFunction;
end;

//Сворачивание панели с данными объекта
procedure Tfrm1.sb_objcollapseClick(Sender: TObject);
begin
 pn_boneedit.tag:=pn_boneedit.height;
 pn_boneedit.height:=15;
 sb_objcollapse.visible:=false;
 sb_decollapsebo.visible:=true;
 BuildPanels;
end;

//Разворачивание панели с данными объекта
procedure Tfrm1.sb_decollapseboClick(Sender: TObject);
begin
 pn_boneedit.height:=pn_boneedit.tag;
 sb_objcollapse.visible:=true;
 sb_decollapsebo.visible:=false;
 BuildPanels;
end;

procedure Tfrm1.cb_workplane2Click(Sender: TObject);
begin
 if cb_workplane2.tag<>0 then exit;
 cb_workplane.checked:=cb_workplane2.checked;
end;

//Сворачивание панели инструментов
procedure Tfrm1.sb_instcollapseClick(Sender: TObject);
begin
 pn_binstrum.tag:=pn_binstrum.height;
 pn_binstrum.height:=15;
 sb_instcollapse.visible:=false;
 sb_instdecollapse.visible:=true;
 BuildPanels;
end;

//Разворачивание панели инструментов
procedure Tfrm1.sb_instdecollapseClick(Sender: TObject);
begin
 pn_binstrum.height:=pn_binstrum.tag;
 sb_instcollapse.visible:=true;
 sb_instdecollapse.visible:=false;
 BuildPanels;
end;

//Свернуть панель рабочей плоскости
procedure Tfrm1.sb_wpcollapseClick(Sender: TObject);
begin
 pn_workplane.tag:=pn_workplane.height;
 pn_workplane.height:=17;
 sb_wpcollapse.visible:=false;
 sb_wpdecollapse.visible:=true;
 BuildPanels;
end;

//развернуть панель рабочей плоскости
procedure Tfrm1.sb_wpdecollapseClick(Sender: TObject);
begin
 pn_workplane.height:=pn_workplane.tag;
 sb_wpcollapse.visible:=true;
 sb_wpdecollapse.visible:=false;
 BuildPanels;
end;

//Свернуть панель свойств кости
procedure Tfrm1.sb_bpcollapseClick(Sender: TObject);
begin
 pn_boneprop.tag:=pn_boneprop.height;
 pn_boneprop.height:=15;
 sb_bpcollapse.visible:=false;
 sb_bpdecollapse.visible:=true;
 BuildPanels;
end;

//Развернуть панель свойств кости
procedure Tfrm1.sb_bpdecollapseClick(Sender: TObject);
begin
 pn_boneprop.height:=pn_boneprop.tag;
 sb_bpcollapse.visible:=true;
 sb_bpdecollapse.visible:=false;
 BuildPanels;
end;

//Свернуть панель свойств аттача
procedure Tfrm1.sb_apcollapseClick(Sender: TObject);
begin
 pn_atchprop.tag:=pn_atchprop.height;
 pn_atchprop.height:=15;
 sb_apcollapse.visible:=false;
 sb_apdecollapse.visible:=true;
 BuildPanels;
end;

procedure Tfrm1.sb_apdecollapseClick(Sender: TObject);
begin
 pn_atchprop.height:=pn_atchprop.tag;
 sb_apcollapse.visible:=true;
 sb_apdecollapse.visible:=false;
 BuildPanels;
end;


//Установка свойства Billboarded кости
procedure Tfrm1.cb_billboardClick(Sender: TObject);
begin
 if (not SelObj.IsSelected) or (cb_billboard.tag<>0) then exit;
 PushFunction(163);
 AnimSaveUndo(uChangeObject,0);   //сохранить для отмены
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}
 SelObj.b.IsBillboarded:=cb_billboard.Checked;
 SetSkelPart;                     //скопировать в скелетный объект
 pb_animMouseUp(Sender,mbLeft,[],0,0);//перечертить кадр
 PopFunction;
end;

procedure Tfrm1.cb_abillboardClick(Sender: TObject);
begin
 if (not SelObj.IsSelected) or (cb_abillboard.tag<>0) then exit;
 PushFunction(164);
 AnimSaveUndo(uChangeObject,0);   //сохранить для отмены
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}
 SelObj.b.IsBillboarded:=cb_abillboard.Checked;
 SetSkelPart;                     //скопировать в скелетный объект
 pb_animMouseUp(Sender,mbLeft,[],0,0);//перечертить кадр
 PopFunction;
end;

//Смена пути аттача
procedure Tfrm1.ed_pathExit(Sender: TObject);
begin
 PushFunction(165);
 if (not SelObj.IsSelected) or (GetTypeObjByID(SelObj.b.ObjectID)<>typATCH)
 then begin PopFunction;exit;end;
 if Attachments[SelObj.b.ObjectID-Attachments[0].Skel.ObjectID].Path=
    ed_path.text then begin PopFunction;exit;end;
 AnimSaveUndo(uChangeObject,0);   //сохранить для отмены
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}
 Attachments[SelObj.b.ObjectID-Attachments[0].Skel.ObjectID].Path:=ed_path.text;
 PopFunction;
end;

procedure Tfrm1.ed_pathKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=VK_RETURN then begin
  ed_pathExit(Sender);
  ed_path.SelectAll;
 end;
end;

//Создание кости (по умолчанию создаётся помощник)
procedure Tfrm1.CtrlB1Click(Sender: TObject);
Var id:integer;
begin
 PushFunction(166);
 EndAttachObj;
 //1. Начинаем процесс создания:
 //Выясним ID нового объекта
 if CountOfHelpers=0 then begin
  if CountOfLights=0 then id:=Bones[CountOfBones-1].ObjectID+1
  else id:=Lights[CountOfLights-1].Skel.ObjectID+1;
 end else id:=Helpers[CountOfHelpers-1].ObjectID+1;

 //2. Сохранить для отмены
 AnimSaveUndo(uCreateObject,id);
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}

 IncDecObjectIDs(id,true);

 ReservePivotSpace(id);           //Освободим место в массиве PivotPoints
 if GetSumCountOfSelVertices>0 then begin
  FindVertCoordCenter;
  PivotPoints[id,1]:=ccVX;
  PivotPoints[id,2]:=ccVY;
  PivotPoints[id,3]:=ccVZ;
 end else begin
  PivotPoints[id,1]:=0;            //координаты нового объекта
  PivotPoints[id,2]:=0;
  PivotPoints[id,3]:=0;
 end;

 //Создать ещё один помощник:
 inc(CountOfHelpers);
 SetLength(Helpers,CountOfHelpers);
 FillChar(Helpers[CountOfHelpers-1],SizeOf(TBone),0);
 with Helpers[CountOfHelpers-1] do begin
  Name:='bone_new'+inttostr(CurNewBoneNum);
  inc(CurNewBoneNum);
  ObjectID:=id;
  GeosetID:=-1;
  GeosetAnimID:=-1;
  Parent:=-1;
  Translation:=-1;
  Rotation:=-1;
  Scaling:=-1;
  Visibility:=-1;
 end;//of with

 //Пересобрать списки объектов и выделить новый объект
 SelObj.IsSelected:=false;        //ничего не выбрано
 SelObj.b.ObjectID:=-1;
 cb_bonelist.tag:=-1;             //ничего не выделено
 frm_obj.lv_obj.tag:=-1;
 cb_billboard.tag:=-1;
 cb_abillboard.tag:=-1;
 IsObjsDown:=false;
 IsMayChange:=false;
 MakeTextObjList(Sender);         //построить список объектов
 GraphSelectObject(id);           //выделение
 frm_obj.MakeObjectsList(id,id);  //перестроение списка
// dec(CountOfUndo);
 cb_billboard.tag:=0;
 cb_abillboard.tag:=0;
 IsMayChange:=true;
 PopFunction;
end;

procedure Tfrm1.CtrlA2Click(Sender: TObject);
Var id:integer;
begin
 PushFunction(167);
 EnableAttachInstrums;
 //1. Начинаем процесс создания:
 //Выясним ID нового объекта
 if CountOfAttachments=0 then begin    //ещё нет аттачей
  if CountOfHelpers=0 then begin       //нет помощников
   if CountOfLights=0 then id:=Bones[CountOfBones-1].ObjectID+1
   else id:=Lights[CountOfLights-1].Skel.ObjectID+1;
  end else id:=Helpers[CountOfHelpers-1].ObjectID+1;
 end else id:=Attachments[CountOfAttachments-1].Skel.ObjectID+1;

 //2. Сохранить для отмены
 AnimSaveUndo(uCreateObject,id);
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}

 IncDecObjectIDs(id,true);

 ReservePivotSpace(id);           //Освободим место в массиве PivotPoints
 if GetSumCountOfSelVertices>0 then begin
  FindVertCoordCenter;
  PivotPoints[id,1]:=ccVX;
  PivotPoints[id,2]:=ccVY;
  PivotPoints[id,3]:=ccVZ;
 end else begin
  PivotPoints[id,1]:=0;            //координаты нового объекта
  PivotPoints[id,2]:=0;
  PivotPoints[id,3]:=0;
 end;//of if

 //Создать ещё один аттач:
 inc(CountOfAttachments);
 SetLength(Attachments,CountOfAttachments);
 FillChar(Attachments[CountOfAttachments-1],SizeOf(TAttachment),0);
 with Attachments[CountOfAttachments-1].Skel do begin
  Name:='New Ref';
  ObjectID:=id;
  GeosetID:=-1;
  GeosetAnimID:=-1;
  Parent:=-1;
  Translation:=-1;
  Rotation:=-1;
  Scaling:=-1;
  Visibility:=-1;
 end;//of with
 Attachments[CountOfAttachments-1].AttachmentID:=-1;
 Attachments[CountOfAttachments-1].Path:='';

 //Пересобрать списки объектов и выделить новый объект
 SelObj.IsSelected:=false;        //ничего не выбрано
 SelObj.b.ObjectID:=-1;
 cb_bonelist.tag:=-1;             //ничего не выделено
 frm_obj.lv_obj.tag:=-1;
 IsObjsDown:=false;
 IsMayChange:=false;
 cb_billboard.tag:=-1;
 cb_abillboard.tag:=-1;
 MakeTextObjList(Sender);         //построить список объектов
 GraphSelectObject(id);           //выделение
 frm_obj.MakeObjectsList(id,id);  //перестроение списка
 cb_billboard.tag:=0;
 cb_abillboard.tag:=0;
 IsMayChange:=true;
 PopFunction;
end;

//Начать процедуру связывания объектов
procedure Tfrm1.sb_begattachClick(Sender: TObject);
begin
 PushFunction(168);
 sb_selbone.down:=true;
 ChObj:=SelObj;  //1. Скопировать данные о выделенном объекте
 DeselectObject; //2. Сбросить данные о выделении
 DrawFrame(CurFrame);//перечертить

 //3. Сменить видимость инструментов
 sb_begattach.visible:=false;
 sb_endattach.visible:=true;
 sb_endattach.enabled:=false;
 sb_endattach.flat:=false;
 PopFunction;
end;

//Завершение процесса связывания
procedure Tfrm1.sb_endattachClick(Sender: TObject);
begin
 PushFunction(169);
 //Сменить видимость инструментов
 sb_begattach.visible:=true;
 sb_endattach.visible:=false;
 sb_endattach.enabled:=false;
 sb_endattach.flat:=false;

 //Сохранить для отмены
 AnimSaveUndo(uAttachObject,0);
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}

 //Провести связывание (воздействует на SaveUndo[CountOfUndo])
 AttachObject;
 ChObj.IsSelected:=false;         //всё, объект уже связан
 GraphSelectObject(SelObj.b.ObjectID);
 dec(CountOfUndo);
 frm_obj.MakeObjectsList(SelObj.b.ObjectID,SelObj.b.ObjectID);
 PopFunction;
end;

//Отсоединение от родительского объекта
procedure Tfrm1.sb_detachClick(Sender: TObject);
begin
 PushFunction(170);
 //Сохранить для отмены
 AnimSaveUndo(uDetachObject,0);
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;
 StrlS1.enabled:=true;}

 //Провести отсоединение
 SelObj.b.Parent:=-1;
 SetSkelPart;

 //перерисовка
 GraphSelectObject(SelObj.b.ObjectID);
 dec(CountOfUndo);
 frm_obj.MakeObjectsList(SelObj.b.ObjectID,SelObj.b.ObjectID);
 PopFunction;
end;

//Выбор кости с помощью списка влияющих костей
procedure Tfrm1.lb_bonesDblClick(Sender: TObject);
Var ind:integer;lst:TFace;
begin
 //1. Найти выделенный элемент
 ind:=SendMessage(lb_bones.handle,LB_GETCURSEL,0,0);
 if ind=LB_ERR then exit;
 PushFunction(171);

 //2. Провести выделение объекта
 if SelObj.IsMultiSelect and SelObj.IsSelected then begin
  SetLength(lst,1);
  lst[0]:=integer(lb_bones.Items.Objects[ind]);
  GraphMultiSelectObject(lst,1);
 end else GraphSelectObject(integer(lb_bones.Items.Objects[ind]));
 PopFunction;
end;

//Переприсоединение кости (присоединение к указанной
//и отсоединение от всех остальных)
procedure Tfrm1.sb_vreattachClick(Sender: TObject);
begin
 PushFunction(172);
 EndAttachObj;
 //Сохранить для отмены
 AnimSaveUndo(uDeleteObject,0);
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;
 StrlS1.enabled:=true;}

 //1. Выполняем присоединение
 ReAttachVertices;

 //2. Пересоставление списка (ибо может "поехать" иерархия)
 ChObj.IsSelected:=false;         //всё, объект уже связан
 IsMayChange:=false;
 MakeTextObjList(Sender);       //построить список объектов
 GraphSelectObject(SelObj.b.ObjectID);
 dec(CountOfUndo);
 frm_obj.MakeObjectsList(SelObj.b.ObjectID,SelObj.b.ObjectID);
 IsMayChange:=true;
 FillBonesList;
 PopFunction;
end;

//Обработчик сообщения WM_DROPFILES
procedure TFrm1.FileDrop(var msg:TWMDropFiles);
Var a:array[0..1024] of char;
    pc:PChar;
Begin
 PushFunction(173);
 pc:=@a[0];
 DragQueryFile(msg.Drop,0,pc,1024);
 od_file.FileName:=string(pc);
 IsParFile:=true;
 application.processmessages;
 N2Click(frm1);                   //загрузить
 PopFunction;
End;

//Осуществляет отсоединение выделенных вершин
//от выделенной кости
procedure Tfrm1.sb_vdetachClick(Sender: TObject);
begin
 PushFunction(174);
 EndAttachObj;
 if not SelObj.IsSelected then begin PopFunction;exit;end;  //перестраховка
 AnimSaveUndo(uDeleteObject,0);   //сохранить для отмены
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}

 //1. Осуществление отсоединения
 DetachVertices;

 //2. Пересоставление списка (ибо может "поехать" иерархия)
 ChObj.IsSelected:=false;         //всё, объект уже связан
 IsMayChange:=false;
 GraphSelectObject(SelObj.b.ObjectID);
 dec(CountOfUndo);
 frm_obj.MakeObjectsList(SelObj.b.ObjectID,SelObj.b.ObjectID);
 IsMayChange:=true;
 FillBonesList;
 PopFunction;
end;

procedure Tfrm1.rb_bxyClick(Sender: TObject);
begin
 if EditorMode=emAnims then rb_xy.checked:=rb_bxy.checked;
end;

procedure Tfrm1.rb_bxzClick(Sender: TObject);
begin
 if EditorMode=emAnims then rb_xz.checked:=rb_bxz.checked;
end;

procedure Tfrm1.rb_byzClick(Sender: TObject);
begin
 if EditorMode=emAnims then rb_yz.checked:=rb_byz.checked;
end;

procedure Tfrm1.rb_xyClick(Sender: TObject);
begin
 if EditorMode=emVertex then rb_bxy.checked:=rb_xy.checked;
end;

procedure Tfrm1.rb_xzClick(Sender: TObject);
begin
 if EditorMode=emVertex then rb_bxz.checked:=rb_xz.checked;
end;

procedure Tfrm1.rb_yzClick(Sender: TObject);
begin
 if EditorMode=emVertex then rb_byz.checked:=rb_yz.checked;
end;

//Клик по меню "Файл" (считать список ранее открытых файлов)
procedure Tfrm1.N1Click(Sender: TObject);
begin
 PushFunction(175);
 CountOfRF:=0;
 LoadRecentFiles(Sender);         //считать список файлов
 AddFileToMenuList('?',Sender);//добавить в список менюшных файлов
 PopFunction;
end;

//Переключение возможности множественного выбора объектов
procedure Tfrm1.cb_multiselectClick(Sender: TObject);
Var lst:TFace;
begin
 if cb_multiselect.tag<>0 then exit;
 PushFunction(176);
 EndAttachObj;                    //снять связывание объектов
 if cb_multiselect.checked then begin
  //1. Привести в соответствие панели, метки, инструменты
  IsContrFilter:=true;
  sb_bonemove.enabled:=false;
  sb_bonerot.enabled:=false;
  sb_bonescale.enabled:=false;
  label30.visible:=true;
  SelObj.IsMultiSelect:=true;     //включить мультивыделение
  N44.enabled:=false;
  sb_selexpand.visible:=true;
  sb_selexpand.enabled:=false;
  //Если объект уже выделен - добавить его в список
  if SelObj.IsSelected then begin
   SelObj.CountOfSelObjs:=1;
   SetLength(SelObj.SelObjs,1);
   SelObj.SelObjs[0]:=SelObj.b.ObjectID;
  end else begin                  //иначе - очистить список
   SelObj.IsSelected:=true;       //выделение есть всегда!
   SelObj.CountOfSelObjs:=0;
   SelObj.SelObjs:=nil;
  end;
  //Установить видимость панелей/инструментов
  pn_boneedit.height:=331;
  GraphMultiSelectObject(lst,-1);
 end else begin                   //снять выделение
  IsContrFilter:=false;
  SelObj.IsMultiSelect:=false;    //выделяется только 1 объект за раз
  N44.enabled:=true;
  cb_bonelist.enabled:=true;
  sb_selexpand.visible:=false;
  H1.enabled:=true;               //разрешить отображение иерархии
  label30.caption:='[Error - report to author]';
  pn_boneprop.visible:=false;      //скрыть панели свойств
  pn_propobj.visible:=false;
  pn_contrprops.Hide;
  SplinePanel.Hide;
  pn_atchprop.visible:=false;
  pn_pre2prop.visible:=false;
  pn_boneedit.height:=185;
  BuildPanels;                     //выстроить отдельные панели

  //Если есть выделенные объекты - выбрать первый из них
  if SelObj.IsSelected and (SelObj.CountOfSelObjs>0) then begin
   frm_obj.MakeObjectsList(SelObj.SelObjs[0],SelObj.SelObjs[0]);
   GraphSelectObject(SelObj.SelObjs[0]);
   dec(CountOfUndo);
  end else begin
   GraphSelectObject(-1);
  end;//of if
  if AnimEdMode=2 then AnimLineRefresh(Sender);
 end;//of if
 PopFunction;
end;

//Исключить объект из списка выделения
procedure Tfrm1.lb_selectedDblClick(Sender: TObject);
Var lst:TFace;i,len:integer;
begin
 //1. Удалить объект из списка
 PushFunction(177);
 lb_selected.Items.Delete(lb_selected.ItemIndex);

 //2. Переписать все оставшиеся объекты в TFace-список
 len:=lb_selected.Items.Count;
 SetLength(lst,len);
 for i:=0 to len-1 do lst[i]:=integer(lb_selected.Items.Objects[i]);

 //3. Произвести перевыделение
 GraphMultiSelectObject(lst,len);
 PopFunction;
end;

procedure Tfrm1.pn_viewClick(Sender: TObject);
Var pt:TPoint;
begin
 GetCursorPos(pt);
 PopupMenu1.Popup(pt.x,pt.y);
end;

//Выделить все дочерние объекты
procedure Tfrm1.sb_selexpandClick(Sender: TObject);
Var i:integer;lst:TList;tf:TFace;
begin
 PushFunction(178);
 //1. Составим список всех дочерних объектов
 lst:=TList.Create;
 for i:=0 to SelObj.CountOfChilds-1 do lst.Add(pointer(SelObj.ChildObjects[i]));
 lst.Sort(cmpItems);              //сортировка

 //2. Переносим список в TFace
 SetLength(tf,lst.Count);
 for i:=0 to lst.Count-1 do tf[i]:=integer(lst.Items[i]);

 //3. Выделяем все эти объекты
 GraphMultiSelectObject(tf,lst.Count);

 lst.Free;
 PopFunction;
end;

//Осуществляет полное клонирование объекта
//(кроме имени и контроллеров)
procedure Tfrm1.N45Click(Sender: TObject);
Var v:TVertex; b:TBone; s:string;
    //pr:TParticleEmitter2;
    iSrc,iDest:integer;
begin
 //1. Скопируем данные текущего объекта
 if (not SelObj.IsSelected) or SelObj.IsMultiSelect then exit;
 PushFunction(179);
 b:=SelObj.b;
 v:=PivotPoints[SelObj.b.ObjectID];

 //2. Создаём новый объект указанного типа
 case GetTypeObjByID(SelObj.b.ObjectID) of
  typATCH:begin                   //крепление
   s:=Attachments[SelObj.b.ObjectID-Attachments[0].Skel.ObjectID].Path;
   CtrlA2Click(Sender);           //создание
   Attachments[SelObj.b.ObjectID-Attachments[0].Skel.ObjectID].Path:=s;
  end;//of typATCH

  typHELP,typBONE:CtrlB1Click(Sender);
  typPRE2:N210Click(Sender);
 end;//of case

 //3. Копируем общий набор параметров
 if GetTypeObjByID(SelObj.b.ObjectID)=typPRE2 then begin
  iSrc:=b.ObjectID-pre2[0].Skel.ObjectID;
  iDest:=SelObj.b.ObjectID-pre2[0].Skel.ObjectID;
  pre2[iDest]:=pre2[iSrc];        //копирование
  //восстановление ID+установка полей
  with pre2[iDest] do begin
   Skel.ObjectID:=SelObj.b.ObjectID;
   Skel.Name:=SelObj.b.Name;
   if not IsSStatic then begin
    IsSStatic:=true;
    Speed:=Controllers[round(Speed)].Items[0].data[1];
   end;//of if
   if not IsVStatic then begin
    IsVStatic:=true;
    Variation:=Controllers[round(Variation)].Items[0].data[1];
   end;//of if
   if not IsLStatic then begin
    IsLStatic:=true;
    Latitude:=Controllers[round(Latitude)].Items[0].data[1];
   end;//of if
   if not IsGStatic then begin
    IsGStatic:=true;
    Gravity:=Controllers[round(Gravity)].Items[0].data[1];
   end;//of if
   if not IsEStatic then begin
    IsEStatic:=true;
    EmissionRate:=Controllers[round(EmissionRate)].Items[0].data[1];
   end;//of if
   if not IsWStatic then begin
    IsWStatic:=true;
    Width:=Controllers[round(Width)].Items[0].data[1];
   end;//of if
   if not IsHStatic then begin
    IsHStatic:=true;
    Length:=Controllers[round(Length)].Items[0].data[1];
   end;//of if
  end;//of with
  with pre2[iDest].Skel do begin
   Translation:=-1;
   Rotation:=-1;
   Scaling:=-1;
   Visibility:=-1;
  end;//of with
  SelObj.b:=pre2[iDest].Skel;
 end else begin
  if abs(PivotPoints[SelObj.b.ObjectID,1])+
     abs(PivotPoints[SelObj.b.ObjectID,2])+
     abs(PivotPoints[SelObj.b.ObjectID,3])<1e-6
  then PivotPoints[SelObj.b.ObjectID]:=v; //геометрический центр
  SelObj.b.Parent:=b.Parent;
  SelObj.b.IsBillboarded:=b.IsBillboarded;
  SelObj.b.IsBillboardedLockX:=b.IsBillboardedLockX;
  SelObj.b.IsBillboardedLockY:=b.IsBillboardedLockY;
  SelObj.b.IsBillboardedLockZ:=b.IsBillboardedLockZ;
  SetSkelPart;
 end;//of if

 //4. Проводим очередную перерисовку
 CalcObjs2D(GLWorkArea.ClientHeight);//расчёт данных объектов
 ccX:=PivotPoints[SelObj.b.ObjectID,1];
 ccY:=PivotPoints[SelObj.b.ObjectID,2];
 ccZ:=PivotPoints[SelObj.b.ObjectID,3];
 SelObj.b.AbsVector[1]:=ccX;
 SelObj.b.AbsVector[2]:=ccY;
 SelObj.b.AbsVector[3]:=ccZ;

 DrawFrame(CurFrame);
 if sb_selbone.down or sb_bonemove.down then begin
  ed_bonex.text:=floattostrf(SelObj.b.AbsVector[1],ffGeneral,10,5);
  ed_boney.text:=floattostrf(SelObj.b.AbsVector[2],ffGeneral,10,5);
  ed_bonez.text:=floattostrf(SelObj.b.AbsVector[3],ffGeneral,10,5);
 end;//of if
 PopFunction;
end;

procedure Tfrm1.N46Click(Sender: TObject);
begin
 VisObjs.Visorient:=not N46.checked;
 N46.checked:=not N46.checked;
 RefreshWorkArea(Sender);
end;

procedure Tfrm1.sb_propobjcollapseClick(Sender: TObject);
begin
 pn_propobj.tag:=pn_propobj.height;
 pn_propobj.height:=15;
 sb_propobjcollapse.visible:=false;
 sb_propobjdecollapse.visible:=true;
 BuildPanels;
end;

procedure Tfrm1.sb_propobjdecollapseClick(Sender: TObject);
begin
 pn_propobj.height:=pn_propobj.tag;
 sb_propobjcollapse.visible:=true;
 sb_propobjdecollapse.visible:=false;
 BuildPanels;
end;

//полная отмена всех ограничений
procedure Tfrm1.b_cancelClick(Sender: TObject);
begin
 PushFunction(180);
 ObjAnimate.ClearRestricts;
 label44.tag:=1;
 cb_mover.checked:=false;
 cb_scalingr.checked:=false;
 cb_rotationr.checked:=false;
 label44.tag:=0;
 PopFunction;
end;

//Изменить ограничение на движение объекта
procedure Tfrm1.cb_moverClick(Sender: TObject);
begin
 if label44.tag<>0 then exit;  //защита от переключения
 ObjAnimate.SetMoveRestrict(SelObj.b.ObjectID,cb_mover.checked);
end;

//Изменить ограничение на вращение для объекта
procedure Tfrm1.cb_rotationrClick(Sender: TObject);
begin
 if label44.tag<>0 then exit;  //защита от переключения
 ObjAnimate.SetRotRestrict(SelObj.b.ObjectID,cb_rotationr.checked);
end;

//Изменить ограничение на масштабирование объекта
procedure Tfrm1.cb_scalingrClick(Sender: TObject);
begin
 if label44.tag<>0 then exit;  //защита от переключения
 ObjAnimate.SetScRestrict(SelObj.b.ObjectID,cb_scalingr.checked);
end;

//развернуть панель свойств контроллера
procedure Tfrm1.sb_cpdecollapseClick(Sender: TObject);
begin
 pn_contrprops.height:=pn_contrprops.tag;
 sb_cpcollapse.visible:=true;
 sb_cpdecollapse.visible:=false;
 BuildPanels;
end;

//свернуть панель свойств контроллера
procedure Tfrm1.sb_cpcollapseClick(Sender: TObject);
begin
 pn_contrprops.tag:=pn_contrprops.height;
 pn_contrprops.height:=15;
 sb_cpcollapse.visible:=false;
 sb_cpdecollapse.visible:=true;
 BuildPanels;
end;

procedure Tfrm1.cb_showkeyClick(Sender: TObject);
begin
 if label46.tag<>0 then exit;
 PushFunction(181);
 if cb_showkey.checked then ContrProps.SetFilter
 else begin
  IsContrFilter:=false;
  ReFormStamps;
  pb_animMouseUp(Sender,mbMiddle,[],0,0);
  pb_animpaint(Sender);
 end;//of if
 PopFunction;
end;

//Устанавливает флаг видимости объекта на панели свойств
//Предварительно необходимо установить тег заголовка панели
procedure TFrm1.SetObjVisibilityProp;
Var it:TContItem;
Begin
 if SelObj.b.Visibility<0 then exit; //нечего устанавливать
 PushFunction(182);
 //проверить на соответствие GlobalSeq
 if (Controllers[SelObj.b.Visibility].GlobalSeqId<>UsingGlobalSeq)
    or (GetTypeObjByID(SelObj.b.ObjectID)=typBONE)
    or (GetTypeObjByID(SelObj.b.ObjectID)=typHELP) then begin
  cb_objvis.enabled:=false;
  cb_objvis.checked:=true;
  b_visanimate.visible:=false;
  PopFunction;
  exit;
 end;//of if
 it:=GetFrameData(SelObj.b.Visibility,CurFrame,ctAlpha);
 if it.Data[1]<0.1 then cb_objvis.checked:=false
 else cb_objvis.checked:=true;
 PopFunction;
End;

//создать контроллер видимости объекта
procedure Tfrm1.b_visanimateClick(Sender: TObject);
Var it:TContItem;
begin
 if label44.tag<>0 then exit;     //защита от случайного срабатывания
 PushFunction(183);

 AnimSaveUndo(uCreateController,0);//сохранить для отмены
 GraphSaveUndo;
{ sb_animundo.enabled:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}

 //Теперь - собственно создание
 it.Frame:=CurFrame;
 it.Data[1]:=1;                   //видимость
 SelObj.b.Visibility:=CreateController(-1,it,ctAlpha);
 SetSkelPart;
 if UsingGlobalSeq>=0
 then Controllers[SelObj.b.Visibility].GlobalSeqId:=UsingGlobalSeq;
 Stamps.Add(CurFrame);            //добавить КК на шкалу

 //Перерисовка
 if sb_selbone.down
 then begin
  ContrProps.OnlyOnOff:=true;
  ContrProps.SetCaptionAndId(SelObj.b.Name,'Видимость',SelObj.b.Visibility);
 end;//of if
 label44.tag:=1;
  b_visanimate.visible:=false;
  cb_objvis.enabled:=true;
  cb_objvis.checked:=true;
 label44.tag:=0;
 pb_animMouseUp(Self,mbMiddle,[],0,0);
 pb_animPaint(Sender);
 PopFunction;
end;

//Установить видимость
procedure Tfrm1.cb_objvisClick(Sender: TObject);
Var it:TContItem;
begin
 if (label44.tag<>0) or SelObj.IsMultiSelect then exit;
 PushFunction(184);
 AnimSaveUndo(uChangeFrame,0);//сохранить для отмены
 GraphSaveUndo;
{ sb_animundo.enabled:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}

 it.Frame:=CurFrame;
 if cb_objvis.checked then it.Data[1]:=1 else it.Data[1]:=0;
 SaveContFrame(SelObj.b.Visibility,CurFrame);
 AddKeyFrame(SelObj.b.Visibility,it);
 Stamps.Add(CurFrame);
 pb_animMouseUp(Self,mbMiddle,[],0,0);
 pb_animPaint(Sender);
 PopFunction;
end;

//Удалить весь контроллер
procedure Tfrm1.b_delcontrClick(Sender: TObject);
begin
 PushFunction(185);
 //Сохранение для отмены приводит всего лишь
 //к копированию ссылки на Controllers[xx].Items
 //всё остальное нужно выполнять исходя из этого
 AnimSaveUndo(uDeleteController,ContrProps.id);//сохранить для отмены
 GraphSaveUndo;
{ sb_animundo.enabled:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}

 if SelObj.b.Visibility=ContrProps.id then begin
  label44.tag:=1;
  label44.tag:=0;
  b_visanimate.visible:=true;
  cb_objvis.checked:=true;
  cb_objvis.enabled:=false;
  SelObj.b.Visibility:=-1;
 end;//of if
 if SelObj.b.Rotation=ContrProps.id then SelObj.b.Rotation:=-1;
 if SelObj.b.Translation=ContrProps.id then SelObj.b.Translation:=-1;
 if SelObj.b.Scaling=ContrProps.id then SelObj.b.Scaling:=-1;
 SetSkelPart;

 ContrProps.DeleteController;
 PopFunction;
end;

//Смена типа контроллера
procedure Tfrm1.rg_conttypeClick(Sender: TObject);
Var cur,tp:integer;
begin
 if label46.tag<>0 then exit;
 PushFunction(186);

 Cur:=ShearUndo;
 Undo[Cur].Status1:=uSaveController;
 Undo[Cur].Status2:=ContrProps.id;
 SetLength(Undo[Cur].Controllers,1);
 case rg_conttype.ItemIndex of
  0:tp:=DontInterp;
  1:tp:=Linear;
  2:tp:=Bezier;
  3:tp:=Hermite;
 end;//of case
 TranslateControllerType(ContrProps.id,tp,Undo[Cur].Controllers[0]);

{ sb_animundo.enabled:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;}
 GraphSaveUndo;
 ReFormStamps;
 pb_animMouseUp(Self,mbMiddle,[],0,0);
 pb_animPaint(Sender);
 PopFunction;
end;

//свернуть панель свойств кривой
procedure Tfrm1.sb_scollapseClick(Sender: TObject);
begin
 pn_spline.tag:=pn_spline.height;
 pn_spline.height:=15;
 sb_scollapse.visible:=false;
 sb_sdecollapse.visible:=true;
 BuildPanels;
end;

//развернуть панель свойств кривой
procedure Tfrm1.sb_sdecollapseClick(Sender: TObject);
begin
 pn_spline.height:=pn_spline.tag;
 sb_scollapse.visible:=true;
 sb_sdecollapse.visible:=false;
 BuildPanels;
end;

procedure Tfrm1.pb_splinePaint(Sender: TObject);
begin
 SplinePanel.Render;
end;

//нажатие Enter в одном из полей
procedure Tfrm1.ed_tKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key=VK_RETURN then
end;

//Изменение параметров TCB
procedure Tfrm1.ed_tExit(Sender: TObject);
Var NewT,NewC,NewB,t,c,b:GLFloat;
    code1,code2,code3:integer;
begin
 if label47.tag<>0 then exit;     //защита от случ. изменения
 PushFunction(187);

 //считываем (и проверяем корректность параметров)
 Val(ed_t.text,NewT,code1);
 Val(ed_c.text,NewC,code2);
 Val(ed_bias.text,NewB,code3);
 SplinePanel.GetTCB(t,c,b);
 if (code1<>0) or (code2<>0) or (code3<>0) then begin
  ed_t.text:=inttostr(round(t*100));
  ed_c.text:=inttostr(round(c*100));
  ed_bias.text:=inttostr(round(b*100));
  PopFunction;
  exit;
 end;//of if
 if NewT<-100 then begin ed_t.text:='-100';PopFunction;exit;end;
 if NewT>100 then begin ed_t.text:='100';PopFunction;exit;end;

 if NewC<-100 then begin ed_c.text:='-100';PopFunction;exit;end;
 if NewC>100 then begin ed_c.text:='100';PopFunction;exit;end;

 if NewB<-100 then begin ed_bias.text:='-100';PopFunction;exit;end;
 if NewB>100 then begin ed_bias.text:='100';PopFunction;exit;end;

 //параметры корректны. Установим их.
 SplinePanel.SetTCB(0.01*NewT,0.01*NewC,0.01*NewB);
 PopFunction;
end;

//Устанавливает видимость кнопок видимости
procedure TFrm1.SetVisPanelActive;
Begin
 PushFunction(188);
 if (GetTypeObjByID(SelObj.b.ObjectID)=typHELP) or
    (GetTypeObjByID(SelObj.b.ObjectID)=typBONE) then begin
  cb_objvis.enabled:=false;
  b_visanimate.visible:=false;
 end;//of if
 PopFunction;
End;

//Изменить доступность инструментов в соответствии с
//ограничениями
procedure TFrm1.ApplyInstrumRestrictions;
Begin
 PushFunction(189);
 if (sb_bonemove.down and cb_mover.checked) or
    (sb_bonerot.down and cb_rotationr.checked) or
    (sb_bonescale.down and cb_scalingr.checked) then begin
  sb_selbone.down:=true;
  sb_selectClick(Self);
 end;//of if
 sb_bonemove.enabled:=not cb_mover.checked;
 sb_bonerot.enabled:=not cb_rotationr.checked;
 sb_bonescale.enabled:=not cb_scalingr.checked;
 if (not sb_bonemove.down) and (not sb_bonerot.down) and
    (not sb_bonescale.down) then begin
  sb_selbone.down:=true;
  sb_selectClick(Self);
 end;//of if
 PopFunction;
End;

//Развернуть панель свойств ИЧ-2
procedure Tfrm1.sb_pre2decollapseClick(Sender: TObject);
begin
 pn_pre2prop.height:=pn_pre2prop.tag;
 sb_pre2collapse.visible:=true;
 sb_pre2decollapse.visible:=false;
 BuildPanels;
end;

//Свернуть панель свойств ИЧ-2
procedure Tfrm1.sb_pre2collapseClick(Sender: TObject);
begin
 pn_pre2prop.tag:=pn_pre2prop.height;
 pn_pre2prop.height:=15;
 sb_pre2collapse.visible:=false;
 sb_pre2decollapse.visible:=true;
 BuildPanels;
end;

procedure Tfrm1.N47Click(Sender: TObject);
begin
 VisObjs.VisParticles:=not N47.checked;
 N47.checked:=not N47.checked;
 RefreshWorkArea(Sender);
end;

//Создание ИЧ-2
procedure Tfrm1.N210Click(Sender: TObject);
Var id:integer;
begin
 PushFunction(190);
 EnableAttachInstrums;
 //1. Начинаем процесс создания:
 //Выясним ID нового объекта
 if CountOfParticleEmitters=0 then begin   //ещё нет ИЧ-2
  if CountOfParticleEmitters1=0 then begin //ещё нет ИЧ-1
   if CountOfAttachments=0 then begin    //ещё нет аттачей
    if CountOfHelpers=0 then begin       //нет помощников
     if CountOfLights=0 then id:=Bones[CountOfBones-1].ObjectID+1
     else id:=Lights[CountOfLights-1].Skel.ObjectID+1;
    end else id:=Helpers[CountOfHelpers-1].ObjectID+1;
   end else id:=Attachments[CountOfAttachments-1].Skel.ObjectID+1;
  end else id:=ParticleEmitters1[CountOfParticleEmitters1-1].Skel.ObjectID+1;
 end else id:=pre2[CountOfParticleEmitters-1].Skel.ObjectID+1;
 
 //2. Сохранить для отмены
 AnimSaveUndo(uCreateObject,id);
 GraphSaveUndo;
{ CtrlZ1.enabled:=true;
 sb_animundo.enabled:=true;
 sb_save.enabled:=true;}

 IncDecObjectIDs(id,true);

 ReservePivotSpace(id);           //Освободим место в массиве PivotPoints
 if GetSumCountOfSelVertices>0 then begin
  FindVertCoordCenter;
  PivotPoints[id,1]:=ccVX;
  PivotPoints[id,2]:=ccVY;
  PivotPoints[id,3]:=ccVZ;
 end else begin
  PivotPoints[id,1]:=0;            //координаты нового объекта
  PivotPoints[id,2]:=0;
  PivotPoints[id,3]:=0;
 end;//of if

 //Создать ещё один ИЧ-2:
 inc(CountOfParticleEmitters);
 SetLength(pre2,CountOfParticleEmitters);
 FillChar(pre2[CountOfParticleEmitters-1],SizeOf(TParticleEmitter2),0);
 with pre2[CountOfParticleEmitters-1].Skel do begin
  Name:='New PRE2';
  ObjectID:=id;
  GeosetID:=-1;
  GeosetAnimID:=-1;
  Parent:=-1;
  Translation:=-1;
  Rotation:=-1;
  Scaling:=-1;
  Visibility:=-1;
 end;//of with

 //Пересобрать списки объектов и выделить новый объект
 SelObj.IsSelected:=false;        //ничего не выбрано
 SelObj.b.ObjectID:=-1;
 cb_bonelist.tag:=-1;             //ничего не выделено
 frm_obj.lv_obj.tag:=-1;
 IsObjsDown:=false;
 IsMayChange:=false;
 cb_billboard.tag:=-1;
 cb_abillboard.tag:=-1;
 MakeTextObjList(Sender);         //построить список объектов
 GraphSelectObject(id);           //выделение
 frm_obj.MakeObjectsList(id,id);  //перестроение списка
 cb_billboard.tag:=0;
 cb_abillboard.tag:=0;
 IsMayChange:=true;
 PopFunction;
end;

//Диалог "О программе"
procedure Tfrm1.N48Click(Sender: TObject);
begin
 frmAbout.ShowModal;
end;

//Провести усреднение нормалей выделенных вершин
procedure Tfrm1.sb_nsmoothClick(Sender: TObject);
Var i,j,num:integer; n:TMidNormal;
begin
 PushFunction(372);
 //1. Сохранить для отмены
 SaveUndo(uSmoothGroups);
 StrlS1.Enabled:=true;
 sb_save.enabled:=true;

 //2. Каждую вершину удалить из уже имеющихся групп сглаживания
 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected
 then for i:=0 to GeoObjs[j].VertexCount-1 do begin
  n.GeoID:=j;
  n.VertID:=GeoObjs[j].VertexList[i]-1;
  DeleteRecFromSmoothGroups(n);
 end;//of for i/if/j

 //3. Создать новую группу сглаживания
 //(по числу выделенных вершин)
 inc(COMidNormals);
 SetLength(MidNormals,COMidNormals);
 SetLength(MidNormals[COMidNormals-1],GetSumCountOfSelVertices);

 //4. Добавить вершины в группу.
 num:=0;
 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected
 then for i:=0 to GeoObjs[j].VertexCount-1 do begin
  n.GeoID:=j;
  n.VertID:=GeoObjs[j].VertexList[i]-1;
  MidNormals[COMidNormals-1,num]:=n;
  inc(num);
 end;//of for i/if/j

 //5. Перерисовать модель
 sb_nrestore.enabled:=true;
 ApplySmoothGroups;
 RefreshWorkArea(Sender);
 PopFunction;
end;

//Включить инструмент вращения нормали
procedure Tfrm1.sb_nrotClick(Sender: TObject);
begin
 PushFunction(373);
 InstrumStatus:=isNormalRot;
 CtrlA1.enabled:=false;

 ed_ix.text:='0';
 ed_iy.text:='0';
 ed_iz.text:='0';
 ed_ix.enabled:=true;
 ed_iy.enabled:=true;
 ed_iz.enabled:=true;
 GlobalX:=0;GlobalY:=0;GlobalZ:=0;
 PopFunction;
end;

//Отменить модификатор нормалей
procedure Tfrm1.sb_nrestoreClick(Sender: TObject);
Var i,j:integer; n:TMidNormal;
begin
 PushFunction(374);
 //1. Сохранить для отмены
 SaveUndo(uSmoothGroups);
 StrlS1.Enabled:=true;
 sb_save.enabled:=true;

 for j:=0 to CountOfGeosets-1 do if GeoObjs[j].IsSelected
 then for i:=0 to GeoObjs[j].VertexCount-1 do begin
  n.GeoID:=j;
  n.VertID:=GeoObjs[j].VertexList[i]-1;
  DeleteRecFromSmoothGroups(n);
 end;//of for i/if/j

 sb_nrestore.enabled:=false;
 RefreshWorkArea(Sender);

 PopFunction;
end;

//Смена типа файла модели в окне "Сохранить как"
procedure Tfrm1.sd_fileTypeChange(Sender: TObject);
Var s:string; h:HWND;
begin
 PushFunction(380);
 //Читаем имя файла
 s:=GetOnlyFileName(sd_file.FileName);
 if (length(s)>4) and (lowercase(copy(s,length(s)-2,2))='md') then begin
  case sd_file.FilterIndex of
   1:s[length(s)]:='x';
   2:s[length(s)]:='l';
  end;//of case
  //Пытаемся "загнать" новое имя вручную
  h:=GetActiveWindow;
  h:=FindWindowEx(h,0,'EDIT',nil);
  if h<>0 then SetWindowText(h,PChar(s));
 end;//of if
 PopFunction;
end;

procedure Tfrm1.K1Click(Sender: TObject);
begin
 IsCanSaveMDVI:=false;
end;

//Установить все свойства анимационной панели
//из последовательности, выбранной в TAnimPanel
procedure TFrm1.SAnimPanelProps;
Begin
 //0. Запрет срабатывания событий
 pn_seq.tag:=1;

 //1. Установка содержимого списка
 

 //2. Установка параметров в случае глобальной анимации
 if AnimPanel.IsAnimGlob(AnimPanel.ids) then begin
  cb_nonlooping.Visible:=false;
  cb_userarity.visible:=false;
  pn_rarity.visible:=false;
  cb_UseMoveSpeed.visible:=false;
  pn_movespeed.visible:=false;
  cb_animlist.Font.Color:=clRed;  
 end else begin              //не глобальная анимация
  cb_UseMoveSpeed.visible:=true;
  cb_animlist.Font.Color:=clBlack;
  pn_Color.Visible:=true;
  cb_nonlooping.visible:=true;
  cb_nonlooping.checked:=AnimPanel.Seq.IsNonLooping;
  with cb_userarity do begin
   visible:=true;
   checked:=AnimPanel.Seq.Rarity>=0;
   pn_rarity.visible:=checked;
   if checked then begin
    ed_rarity.text:=inttostr(AnimPanel.Seq.Rarity);
    UPDown1.Position:=AnimPanel.Seq.Rarity;
   end;//of if
  end;//of with
  with cb_UseMoveSpeed do begin
   checked:=AnimPanel.Seq.MoveSpeed>=0;
   pn_moveSpeed.visible:=checked;
   if checked then ed_MoveSpeed.text:=inttostr(AnimPanel.Seq.MoveSpeed);
  end;//of with
 end;//of if

 //Интервал кадров
 if AnimPanel.IsAllLine(AnimPanel.ids) then begin
  pn_animparam.visible:=false;
  b_animDelete.visible:=false;
  MinFrame:=0;
  MaxFrame:=AbsMaxFrame;
 end else begin
  MinFrame:=AnimPanel.Seq.IntervalStart;
  MaxFrame:=AnimPanel.Seq.IntervalEnd;
  with ed_minframe do begin
   enabled:=false;
    text:=inttostr(AnimPanel.Seq.IntervalStart);
   if not AnimPanel.IsAnimGlob(AnimPanel.ids) then enabled:=true;
  end;//of with
  ed_minframe.visible:=not AnimPanel.IsAllLine(AnimPanel.ids);
  ed_maxframe.visible:=ed_minframe.visible;
  if ed_maxframe.visible then ed_maxframe.text:=inttostr(AnimPanel.Seq.IntervalEnd);
  pn_animparam.visible:=true;
  b_AnimDelete.visible:=true;
 end;//of if

 //Восстановить массив КК
 ReFormStamps;
 if CurFrame<MinFrame then CurFrame:=MinFrame;
 if CurFrame>MaxFrame then CurFrame:=MaxFrame;
 SelMinFrame:=CurFrame;
 SelMaxFrame:=CurFrame;
 SumFrame:=0;                     //кол-во проиграных кадров
 AbsMaxFrame:=AnimPanel.GAbsMaxFrame;

 pn_seq.tag:=0;
End;


//Запуск оптимизатора (глубокая оптимизация модели)
procedure Tfrm1.N50Click(Sender: TObject);
Var i,ii,j,iStart,iEnd:integer;
begin
 PushFunction(384);
 //1. Вывести диалог
 frm_Optimize.ShowModal;
 if frm_Optimize.ModalResult=mrCancel then exit;

 //2. Проверить, не нужно ли канонизировать модель
 if frm_optimize.clb_actions.State[0]=cbChecked then IsCanSaveMDVI:=false;

 //3. Проверить, не нужно ли удалить повт. поверхности
 if frm_optimize.clb_actions.State[1]=cbChecked then N37Click(Sender);

 //4. Проверить, не нужно ли удалить свободные вершины
 if frm_optimize.clb_actions.State[2]=cbChecked
 then for j:=0 to CountOfGeosets-1 do begin
  i:=Geosets[j].CountOfVertices-1;
  GeoObjs[j].HideVertexCount:=0;
  GeoObjs[j].HideVertices:=nil;
  repeat                          //цикл проверки/удаления
   if IsVertexFree(j,i) then DeleteVertex(j+1,i+1);
   dec(i);
  until i<=0;
 end;//of for j/if

 //5. Проверить, не нужно ли удалять несвязанные кости
 if frm_optimize.clb_actions.State[3]=cbChecked then DeleteFreeBones;

 //6. Проверить, не нужно ли удалять ничейные КК
 if frm_optimize.clb_actions.State[4]=cbChecked then begin
  SortSequences;
  for i:=0 to CountOfSequences-2
  do if Sequences[i].IntervalEnd<Sequences[i+1].IntervalStart then begin
   iStart:=Sequences[i].IntervalEnd;
   iEnd:=Sequences[i+1].IntervalStart;
   if iEnd-iStart-2<=0 then continue;
   for ii:=0 to CountOfSequences-1
   do if ((Sequences[ii].IntervalStart>=iStart) and
         (Sequences[ii].IntervalStart<=iEnd)) or
         ((Sequences[ii].IntervalEnd>=iStart) and
         (Sequences[ii].IntervalEnd<=iEnd))
   then continue;

   //Итак, диапазон КК успешно найден
   UsingGlobalSeq:=-1;
   DeleteKeyFrames(iStart+1,iEnd-1);
  end;//of if/for i
 end;//of if

 //7. Проверить, не нужно ли линеаризовывать анимацию
 if frm_optimize.clb_actions.State[5]=cbChecked
 then for i:=0 to High(Controllers) do Controllers[i].ContType:=Linear;

 //8. Проверить, не нужно ли увеличить сжимаемость
 if frm_optimize.clb_actions.State[6]=cbChecked then RoundModel;

 CountOfUndo:=0;
 CountOfNewUndo:=0;
 NewUndo:=nil;
 sb_undo.Enabled:=false;
 CtrlZ1.Enabled:=false;
 sb_save.Enabled:=true;
 StrlS1.enabled:=true;
 EnableInstrums;
 RefreshWorkArea(Sender);

 PopFunction;
end;


//Используется совместно с SaveAnimUndo -
//устанавливает кнопки/элементы меню undo и save
procedure TFrm1.GraphSaveUndo;
Begin
 sb_animundo.enabled:=true;
 CtrlZ1.enabled:=true;
 StrlS1.enabled:=true;
 sb_save.enabled:=true;
 IsModified:=true;
End;

//Изменена редкость анимации
procedure Tfrm1.UpDown1ChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Smallint;
  Direction: TUpDownDirection);
begin
 PushFunction(126);
 if pn_seq.tag=0 then begin
  AnimSaveUndo(uSeqPropChange,AnimPanel.ids);
  GraphSaveUndo;

  AnimPanel.Seq.Rarity:=NewValue;
  AnimPanel.SSeq;
 end;//of if
 PopFunction;
end;

procedure Tfrm1.cb_animlistDblClick(Sender: TObject);
begin
 //??
end;

//Смешивает кадры текущей линейки с тем,
//что находится в буфере обмена
procedure Tfrm1.N51Click(Sender: TObject);
begin
 AnimSaveUndo(uPasteFrames,0);
 if not PasteFramesFromBuffer(CurFrame,MaxFrame,true,true,0.5) then begin
  PopFunction;
  exit;
 end;
 GraphSaveUndo;
 AnimLineRefresh(Sender);
end;

//Выход из MdlVis
procedure Tfrm1.N52Click(Sender: TObject);
begin
 SendMessage(frm1.handle,WM_SYSCOMMAND,SC_CLOSE,0);
end;

initialization
 //создание объектов
 stamps:=TKeyFramesList.Create;
 ObjAnimate:=TObjAnimate.Create;
 ContrProps:=TContrProps.Create;
 WorkPlane:=TWorkPlane.Create;
 NInstrum:=TNInstrum.Create;

 IsPlay:=false;bExit:=false;
 EditorMode:=emVertex;
 iEditorMode:=EditorMode;         //для крэш-дампа
 IsAnimMouseDown:=false;
 CurFrame:=500;
 Division:=3333 div 10;
 IsParFile:=false;                //нет параметра
 InstrumStatus:=isSelect;IsKeyDown:=false;
 IsMouseDown:=false;
 IsLeftMouseDown:=false;
 IsWheel:=false;
 IsArea:=false;IsShift:=false;
 r:=1;g:=0;b:=0;
 IsListDown:=false;
 IsParamsLoaded:=false;
 IsSlowHighlight:=false; //по умолчанию - быстрая подсветка
 CountOfRF:=0;           //пока нет открытых файлов
 CurNewBoneNum:=0;       //для создания New-объекта
end.
