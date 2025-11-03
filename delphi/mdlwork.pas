unit mdlwork;
//процедуры для парсинга mdl и mdx, работы с их частями
interface
uses windows,messages,OpenGL,sysUtils,glow;

type
TVertex=array[1..3] of GLFloat; //координаты (GL+War)
TNormal=TVertex;//array[1..3] of GLFloat; //нормаль (координаты)
TTVertex=array[1..2] of GLFloat;//координаты текстуры
TCrds=record                    //текстурные координаты
 TVertices:array of TTVertex;   //массив текст. вершин
 CountOfTVertices:integer;      //его длина
end;//of TCrds
TFace=array of integer;         //разворот (номера вершин)
TAnim=record                    //границы анимации
 MinimumExtent,MaximumExtent:TVertex;//границы
 BoundsRadius:GLfloat;          //граничный радиус
end;
ATAnim=array of TAnim;          //тип: массив анимаций
TMidNormal=record               //данные для "усредняемой" нормали
 GeoID,VertID:integer;          //"адрес" нормали
end;//of TMidNormal
TConstNormal=record             //тип: нормаль с постоянными координатами
 GeoId,VertID:integer;          //"адрес" нормали
 n:TNormal;                     //сама нормаль
end;//of TConstNormal                          
TTexture=record                 //тип: текстура
// ListNum:integer;               //номер текстурного списка
 FileName:string;               //имя файла текстуры
 ReplaceableID:integer;         //тип текстуры
 IsWrapWidth,IsWrapHeight:boolean;//непонятно что
 pImg:pointer;                  //указатель на изображение
 ImgWidth,ImgHeight:integer;    //параметры изображения
 ListNum:integer;               //номер списка текстуры
end;//of TTexture
TContItem=record                //тип: элемент контроллера анимации
 Frame:integer;                   //номер кадра
 Data,                            //данные в кадре
 InTan,                           //тангенсы (для нелинейных изменений)
 OutTan:array[1..5] of GLfloat;
end;//of TContItem
TController=record              //тип: контроллер анимации
 ContType:integer;                //вид контроллера
 GlobalSeqId:integer;             //ID соответствующей последовательности
 SizeOfElement:integer;           //размерность элемента данных 
 Items:array of TContItem;        //данные
end;//of TController
TTexMatrix=array[0..3,0..3] of GLDouble;
TLayer=record                   //тип: слой материала
 FilterMode:integer;            //режим смешения
 IsUnshaded,IsTwoSided,IsUnfogged,IsSphereEnvMap,
 IsNoDepthTest,IsNoDepthSet:boolean;//параметры отображения
 TextureID:integer;             //ID текстуры слоя
 IsTextureStatic:boolean;       //true, если текст. статическая
 Alpha:GLfloat;                 //прозрачность слоя
 IsAlphaStatic:boolean;         //true, если Alpha - статический
 NumOfGraph:integer;            //номер линии анимации альфа
 NumOfTexGraph:integer;         //линия анимации текстуры
 TVertexAnimID:integer;         //ID текстурной анимации
 CoordID:integer;               //ID координат, что ли?
 AAlpha:GLFloat;                //Прозрачность слоя (тек. кадр)
 TexMatrix:TTexMatrix;          //матрица текстурных преобразований
 ATextureID:integer;            //ID текстуры в кадре
end;//of TLayer
TMaterial=record                //тип: материал
 ListNum:integer;               //номер текстурного списка
 TypeOfDraw:integer;            //тип вывода (заполн. при построении модели)
 Excentry:GLFloat;              //эксцентриситет материала (для редактора текстур)
 IsConstantColor:boolean;       //указывает на анимацию цвета
 IsSortPrimsFarZ:boolean;       //сортировка примитивов
 IsFullResolution:boolean;      //? некий параметр 
 PriorityPlane:integer;         //? какой-то параметр
 CountOfLayers:integer;         //кол-во слоев
 Layers:array of TLayer;        //слои материала
end;//of TMaterial
TTextureAnim=record             //анимация текстуры
 TranslationGraphNum,
 RotationGraphNum,
 ScalingGraphNum:integer;       //преобразования
end;//of TTextureAnim
TGroup=array of TFace;          //тип: группа (соед. с костями)
TGeoset=record                  //тип: поверхность
 Vertices:array of TVertex;
 Normals:array of TNormal;      //нормали
 CountOfCoords:integer;         //кол-во массивов текстурных координат
 Crds:array of TCrds;           //текстурные координаты
 VertexGroup:array of integer;  //группы вершин
 Faces:array of TFace;          //развороты
 Groups:TGroup;                 //соединения с костями
 Anims:ATAnim;                  //границы анимаций
 MinimumExtent:TVertex;         //граница
 MaximumExtent:TVertex;
 BoundsRadius:GLfloat;          //граничный радиус
 CountOfAnims:integer;          //кол-во границ
 MaterialID:integer;            //материал поверхности
 SelectionGroup:integer;        //группа выделения
 Unselectable:boolean;          //флаг невыделяемости

 CountOfVertices:integer;       //кол-во вершин
 CountOfNormals:integer;        //кол-во нормалей
// CountOfTVertices:integer;      //кол-во текст. координат.
 CountOfFaces:integer;          //кол-во разворотов
 CountOfMatrices:integer;       //кол-во соединений с костями
 CurrentListNum:integer;        //номер текущего списка GLU
 Color4f:array[1..4] of GLfloat;//массив окраски поверхности
 ChildVertices:array of integer;//вершины, связанные с костью
 CountOfChildVertices:integer;  //их кол-во
 DirectCV:array of integer;     //вершины, вязанные непосредственно с выд. об.
 CountOfDirectCV:integer;       //кол-во таких вершин
 HierID:integer;                //id иерархии
// HierName:string;
end;//of type
TNrm=record                     //используется для расчета нормалей
 x,y,z:GLfloat;
// count:integer;
end;
TSequence=record                //тип - последовательность
 Name:string;                   //имя
 IntervalStart,IntervalEnd:integer;//интервал (кадры)
 Rarity:integer;                //Редкость
 IsNonLooping:boolean;          //флаг цикличности
 MoveSpeed:integer;             //скорость движения
 Bounds:TAnim;                  //границы
end;//of TSequence
TGeosetAnim=record              //Анимация поверхности
 Alpha:GLFloat;                 //Прозрачность
 Color:TVertex;                 //цвет (r,g,b)
 GeosetID:integer;              //ID соответствующей поверхности
 IsAlphaStatic,IsColorStatic:boolean;
 IsDropShadow:boolean;          //?
 AlphaGraphNum,ColorGraphNum:integer;//номера линеек
end;//of TGeosetAnim
TQuaternion=record           //тип: кватернион
 x,y,z,w:GLfloat;             //содержимое
end;//of TQuaternion
TRotMatrix=array [0..2,0..2] of GLfloat;//тип: матрица поворота
TBone=record                    //тип: кость/помощник
 Name:string;                   //имя
 ObjectID,GeosetID,GeosetAnimID:integer;
 IsBillboarded:boolean;
 IsBillboardedLockX,
 IsBillboardedLockY,
 IsBillboardedLockZ,
 IsCameraAnchored:boolean;
 Parent:integer;               //ID родителя
 Translation,Rotation,Scaling,Visibility:integer;//номера линий анимации
 IsDIRotation,IsDITranslation,IsDIScaling:boolean;//"не неаследование"
 //Временные (для анимаций) параметры
 IsReady:boolean;                 //true, если параметры уже посчитаны
 AbsQuaternion:TQuaternion;
 AbsMatrix:TRotMatrix;
 AbsVector:TVertex;
 AbsScaling:TVertex;
 AbsVisibility:boolean;
end;//of TBone
TLight=record                     //тип: источник света
 Skel:TBone;                       //Объект скелета
 LightType:integer;                //тип источника
 AttenuationStart:single;          //начальная граница
 AttenuationEnd:single;            //конечная граница
 Intensity:single;                 //интенсивность
 Color:TVertex;                    //цвет
 AmbIntensity:single;
 AmbColor:TVertex;                  //
 //Статичность
 IsASStatic,IsAEStatic,IsIStatic,
 IsCStatic,IsAIStatic,IsACStatic:boolean;
end;//of TLight
TAttachment=record                //точка прикрепления
 Skel:TBone;                       //объект скелета
 AttachmentID:integer;
 Path:string;                      //?
end;//of TAttachment
TParticleEmitter=record           //источник частиц 1
 Skel:TBone;                      //объект скелета
 UsesType:integer;                //тип используемого объекта
 EmissionRate,Gravity,
 Longitude,Latitude:single;
 LifeSpan,InitVelocity:single;
 Path:string;
 IsERStatic,IsGStatic,IsLongStatic,
 IsLatStatic,IsLSStatic,IsIVStatic:boolean;
end;//of TParticleEmitter
TParticleEmitter2=record          //тип: источник частиц(2-я версия)
 Skel:TBone;                      //объект скелета
 IsSortPrimsFarZ,IsUnshaded,IsLineEmitter,IsUnfogged,
 IsModelSpace,IsXYQuad:boolean;
 Speed,Variation,Latitude,Gravity:single;
 IsSquirt:boolean;
 LifeSpan,EmissionRate:single;
 Width,Length:single;
 BlendMode:integer;              //режим смешения
 Rows,Columns:integer;
 ParticleType:integer;           //тип отображения(tail/head/both)
 TailLength,Time:single;
 SegmentColor:array[1..3] of TVertex;
 Alpha:array[1..3] of integer;
 ParticleScaling:TVertex;
 LifeSpanUVAnim,DecayUVAnim,TailUVAnim,TailDecayUVAnim:array[1..3] of integer;
 TextureID:integer;
 ReplaceableId,PriorityPlane:integer;
 IsSStatic,IsVStatic,IsLStatic,IsGStatic,
 IsEStatic,IsWStatic,IsHStatic:boolean;
end;//of TParticleEmitters2
TRibbonEmitter=record             //Источник следа
 Skel:TBone;                      //объект скелета
 HeightAbove,HeightBelow:single;
 alpha:single;
 Color:TVertex;
 TextureSlot:integer;
 EmissionRate:integer;
 LifeSpan,Gravity:single;
 Rows,Columns:integer;
 MaterialID:integer;
 IsHAStatic,IsHBStatic,IsAlphaStatic,
 IsColorStatic,IsTSStatic:boolean;
end;//of TRibonEmitter
TCamera=record                    //тип: камера
 Name:string;
 Position:TVertex;
 TranslationGraphNum,RotationGraphNum:integer;
 FieldOfView,FarClip,NearClip:single;
 TargetPosition:TVertex;
 TargetTGNum:integer;
end;//of TCamera
TEventObject=record               //событие(спецэффект)
 Skel:TBone;                      //объект скелета
 CountOfTracks:integer;
 Tracks:array of integer;         //список срабатываний
end;//of TEventObject
TCollisionShape=record            //тип: объект границ
 Skel:TBone;                      //объект скелета
 objType:integer;                 //сфера/бокс
 CountOfVertices:integer;
 Vertices:array of TVertex;
 BoundsRadius:single;
end;//of TCollisionShape
TFSize=record                     //информация о размере
 fPos:integer;                    //позиция для записи
 IsI:boolean;                     //тип размера
end;//of TFSize

//Набор спец. структур для моделей WoW (m2):
TSubMesh=record                   //гибрид вида и подповерхности
 coIndices,                       //кол-во индексов (список вершин)
 ipIndices,                       //смещения
 coFaces,                         //развороты (3*число треуг.)
 ipFaces,
 ipMesh,
 coTexs,                          //текстурные записи (?)
 ipTexs,
 id:integer;                      //ID подповерхости
end;//of TSubMesh
TIJCore=record                    //структура для упаквки IJPEG
 UseIJPEGProperties:integer;      //всегда 0
 DIBBytes:pointer;                //указатель на DIB-изобр.
 width,height:integer;            //размеры
 DIBPadBytes,DIBChannels:integer;
 DIBColor,DIBSubsampling:integer;
 //IJ-свойства
 IJFile:PChar;                    //имя файл для записи
 IJBytes:pointer;                 //байты IJ
 IJSizeBytes:integer;             //размер изображения
 IJWidth,IJHeight:integer;        //параметры(размеры)
 IJChannels,IJColor:integer;
 IJSubsampling:integer;
 IJThumbWidth,IJThumbHeight:integer;
 //параметры конверсии
 IsConvRequired:integer;
 IsUnsamplingRequired:integer;
 Quality:integer;                 //коэф-т упаковки
 ijprops:array[0..20000] of byte; //паковочный буфер
end;//of TIJCore
{THierarchy=record                 //тип: WoW-иерархия
 id:integer;                      //id иерархии
 Name:string;                     //её имя
 geoids:array of integer;         //список поверхностей
end;//of THierarchy}
//Типы-массивы (для копирования)
ATTexture=array of TTexture;
ATTextureAnims=array of TTextureAnim;
ATMaterial=array of TMaterial;
ATGeoset=array of TGeoset;
ATSequence=array of TSequence;
ATI=array of integer;
ATGeosetAnim=array of TGeosetAnim;
ATBone=array of TBone;
ATAttachment=array of TAttachment;
ATVertex=array of TVertex;
ATParticleEmitter=array of TParticleEmitter;
ATParticleEmitter2=array of TParticleEmitter2;
ATRibbonEmitter=array of TRibbonEmitter;
ATEventObject=array of TEventObject;
ATCamera=array of TCamera;
ATCollisionShape=array of TCollisionShape;
ATLight=array of TLight;
ATController=array of TController;
ATMidNormal=array of array of TMidNormal;
ATConstNormal=array of TConstNormal;
TWMO=record                       //структура для открытия WMO-объектов
 pRoot,                           //указатель на открытый root-WMO
 pGroup:pointer;                  //указатель на открытый group-WMO
 ppSV,ppRoot:integer;
 //Данные модели
 Textures:ATTexture;              //массив текстур
 TextureAnims:ATTextureAnims;     //массив текстурных анимаций
 Materials:ATMaterial;            //массив материалов
 Geosets:ATGeoset;                //описание поверхностей
 Sequences:ATSequence;            //массив последовательностей
 GlobalSequences:ATI;             //глобальные последовательности
 GeosetAnims:ATGeosetAnim;        //анимации поверхностей
 Bones:ATBone;                    //список костей
 Helpers:ATBone;                  //список помощников
 Attachments:ATAttachment;        //список прикреплений
 PivotPoints:ATVertex;            //список геометрических центров
 ParticleEmitters1:ATParticleEmitter;
 pre2:ATParticleEmitter2;         //источники частиц
 Ribs:ATRibbonEmitter;            //источники следа
 Events:ATEventObject;            //события
 Cameras:ATCamera;                //камеры
 Collisions:ATCollisionShape;
 CountOfTextures:integer;    //кол-во текстур
 CountOfMaterials:integer;   //кол-во материалов
 CountOfPivotPoints:integer; //кол-то центров
 CountOfTextureAnims:integer;//кол-во текстурных анимаций
 CountOfGeosets:integer;     //кол-во поверхностей
 CountOfGeosetAnims,         //кол-во анимаций поверхностей
 CountOfLights,              //кол-во источников света
 CountOfHelpers,             //кол-во "помощников"
 CountOfBones,               //кол-во костей
 CountOfAttachments,         //кол-во прикреплений
 CountOfParticleEmitters1,   //ист. частиц 1-й версии
 CountOfParticleEmitters,    //источники частиц
 CountOfRibbonEmitters,      //источники следа
 CountOfEvents:integer;      //события
 CountOfCameras:integer;     //кол-во камер
 CountOfCollisionShapes:integer;//кол-во граничных объектов
 BlendTime:integer;          //время смешения
 CountOfSequences:integer;   //кол-во последовательностей
 CountOfGlobalSequences:integer;//кол-во глоб. п-тей
 AnimBounds:TAnim;           //границы, радиус модели
 Lights:ATLight;             //секция источников света
 Controllers:ATController;   //список контроллеров анимации
 ModelName:string;
end;//of TWMO

//Типы, использующиеся при перекодировании WMO:
const MaxElement=1000000;//макс. кол-во элементов в массивах
type TMOPY=packed array [0..MaxElement] of byte;
     PMOPY=^TMOPY;
     TMOVI=packed array [0..MaxElement*2] of word;
     PMOVI=^TMOVI;
     TMOVT=packed array [0..MaxElement*3] of single;
     PMOVT=^TMOVT;
     TMONR=packed array [0..MaxElement*3] of single;
     PMONR=^TMONR;
     TMOTV=packed array [0..MaxElement*2] of single;
     PMOTV=^TMOTV;

//константы режимов смешения
const Opaque=1;ColorAlpha=2;FullAlpha=3;Additive=4;
      Modulate=5;Modulate2X=6;AddAlpha=7;
      AlphaKey=8;

//Константы типов контроллеров
      DontInterp=1;Linear=2;Hermite=3;Bezier=4;
      OnOff=5;//особый тип (0,1)
//Константы особых ID костей/помощников
      None=-2;Multiple=-3;
//Константы типов источников света
      Omnidirectional=1;Directional=2;Ambient=3;
//Тип частицы
      EmitterUsesTGA=0;EmitterUsesMDL=1;
//Отображение частиц
      ptHead=0;ptTail=1;ptBoth=2;
//Тип граничного объекта
      cSphere=0;cBox=1;
//Константа отсутствия
      cNone=-1e6;
//Коды тегов
 TagGLBS=$53424C47;TagMTLS=$534C544D;TagTEXS=$53584554;
 TagTXAN=$4E415854;TagGEOS=$534F4547;TagGEOA=$414F4547;
 TagBONE=$454E4F42;TagLITE=$4554494C;TagHELP=$504C4548;
 TagATCH=$48435441;TagPIVT=$54564950;TagPREM=$4D455250;
 TagPRE2=$32455250;TagRIBB=$42424952;TagCAMS=$534D4143;
 TagEVTS=$53545645;TagCLID=$44494C43;TagMODL=$4C444F4D;
 TagLAYS=$5359414C;TagVRTX=$58545256;TagNRMS=$534D524E;
 TagPVTX=$58545650;TagGNDX=$58444E47;TagMTGC=$4347544D;
 TagMATS=$5354414D;TagUVAS=$53415655;TagUVBS=$53425655; 

 tagKMTA=$41544D4B;tagKMTF=$46544D4B;TagSEQS=$53514553;
 tagKTAT=$5441544B;tagKTAR=$5241544B;tagKTAS=$5341544B;
 tagKGAO=$4F41474B;tagKGAC=$4341474B;tagKGTR=$5254474B;
 tagKGRT=$5452474B;tagKGSC=$4353474B;tagKATV=$5654414B;
 tagKLAI=$49414C4B;tagKLAV=$56414C4B;tagKLAC=$43414C4B;
 tagKLBC=$43424C4B;tagKLBI=$49424C4B;tagKPEV=$5645504B;
 tagKLAS=$53414C4B;tagKLAE=$45414C4B;tagKP2S=$5332504B;
 tagKP2R=$5232504B;tagKP2L=$4C32504B;tagKP2G=$4732504B;
 tagKP2E=$4532504B;tagKP2V=$5632504B;tagKP2N=$4E32504B;
 tagKP2W=$5732504B;tagKRVS=$5356524B;tagKRHA=$4148524B;
 tagKRHB=$4248524B;tagKRAL=$4C41524B;tagKRCO=$4F43524B;
 tagKCTR=$5254434B;tagKCRL=$4C52434B;tagKTTR=$5254544B;
 tagKPEE=$4545504B;tagKPEG=$4745504B;tagKPLN=$4E4C504B;
 tagKPLT=$544C504B;tagKPEL=$4C45504B;tagKPES=$5345504B;
 tagMDVI=$4956444D;
 //спец. тэги
 tagiWoW=0; tagiSmooth=1;
 //константы объектов
 typHELP=0;typBONE=256;typLITE=512;typEVTS=1024;typATCH=2048;
 typCLID=8192;typPRE2=65536;
 //константы кодов некоторых символов
 CODE_COMMA=$2C;     //запятая
 CODE_COLON=$3A;     //Tab
 CODE_OBRACKET=$7B;  //{
 CODE_CBRACKET=$7D;  //}
 CODE_QM=$22;        //"
 //Общие строковые константы:
 scError='Ошибка:';
 //Константа умножения (для m2-моделей):
 wowmult=50;
var f:file;                     //открытый файл
    p:pointer;                  //глобальный указатель
    pp:integer;                 //целочисленная форма указателя
    ft:text;
    fm:file;
    fSizes:array[0..20] of TFSize;//массив информации
    fsCurNum:integer;           //указатель на своб. номер
    FCont,                      //содержимое файла (без смены регистра)
    FileContent:string;         //полное содержимое файла
    CurGeoPos:cardinal;         //позиция текущей поверхности
    IsShowTexError:boolean;     //показывать ли ошибку загрузки текстур
    Textures:ATTexture;         //массив текстур
    TextureAnims:ATTextureAnims;//массив текстурных анимаций
    Materials:ATMaterial;       //массив материалов
    Geosets:ATGeoset;           //описание поверхностей
    Sequences:ATSequence;       //массив последовательностей
    GlobalSequences:ATI;        //глобальные последовательности
    GeosetAnims:ATGeosetAnim;   //анимации поверхностей
    Bones:ATBone;               //список костей
    Helpers:ATBone;             //список помощников
    Attachments:ATAttachment;   //список прикреплений
    PivotPoints:ATVertex;       //список геометрических центров
    ParticleEmitters1:ATParticleEmitter;
    pre2:ATParticleEmitter2;    //источники частиц
    Ribs:ATRibbonEmitter;       //источники следа
    Events:ATEventObject;       //события
    Cameras:ATCamera;           //камеры
    Collisions:ATCollisionShape;
    CountOfTextures:integer;    //кол-во текстур
    CountOfMaterials:integer;   //кол-во материалов
    CountOfPivotPoints:integer; //кол-то центров
    //Фрагмент заголовка:
    ModelName:string;           //имя модели
    CountOfTextureAnims:integer;//кол-во текстурных анимаций
    CountOfGeosets:integer;     //кол-во поверхностей
    CountOfGeosetAnims,         //кол-во анимаций поверхностей
    CountOfLights,              //кол-во источников света
    CountOfHelpers,             //кол-во "помощников"
    CountOfBones,               //кол-во костей
    CountOfAttachments,         //кол-во прикреплений
    CountOfParticleEmitters1,   //ист. частиц 1-й версии
    CountOfParticleEmitters,    //источники частиц
    CountOfRibbonEmitters,      //источники следа
    CountOfEvents:integer;      //события
    CountOfCameras:integer;     //кол-во камер
    CountOfCollisionShapes:integer;//кол-во граничных объектов
    BlendTime:integer;          //время смешения
    CountOfSequences:integer;   //кол-во последовательностей
    CountOfGlobalSequences:integer;//кол-во глоб. п-тей
    AnimBounds:TAnim;           //границы, радиус модели
//    TextureAnims:string;        //секция текстурных анимаций
    Lights:ATLight;             //секция источников света
    nrms:array of TNrm;         //временный массив
    Controllers:ATController;   //список контроллеров анимации
    CurrentCoordID:integer;       //текущий слой текстурных вершин

//    BeginGeosetsPos:cardinal;   //позиция начала поверхностей
//    EndGeosetsPos:cardinal;     //окончание поверхностей
    CurrentListNum:integer;//номер списка
    VisGeosets:array of boolean;  //видимость поверхностей
    SFAVertices:array of array of TVertex;//сохранение вершин
//    SFATVertices:array of array of TCrds; //сохранение текстурных вершин
    SFAPivots:array of TVertex;   //сохранение центров
    CurFrame:integer;             //номер текущего кадра
    TexErr:string;                //здесь накапливаются ошибки загрузки текстур
    IsCanSaveMDVI,                //true, если разрешена запись специф. информ.
    IsWoW:boolean;                //true, если активна модель WoW
    WarPath:string;               //путь к War
    Version:integer;              //версия модели WoW

    //Усреднитель нормалей
    MidNormals:ATMidNormal;       //список усредняемых нормалей
    COMidNormals:integer;         //длина этого списка
    ConstNormals:ATConstNormal;   //список "константных" нормалей
    COConstNormals:integer;       //длина этого списка
//    Hierarchy:array of THierarchy;//массив WoW-иерархий
    //переменные-процедуры:
    ijlFree:function(p:pointer):integer;stdcall;
    ijlInit:function(p:pointer):integer;stdcall;
    ijlRead:function(p:pointer;par:integer):integer;stdcall;
    ijlWrite:function(p:pointer;par:integer):integer;stdcall;
    //процедуры из storm.dll
    IsLoadMPQ:boolean;
    hWar3,hWar3x,hWar3patch:integer;    
    SFileOpenArchive:function(lpName:PChar;dwPriority,dwFlags:integer;
                              var hMPQ:integer):boolean;stdcall;
    SFileOpenFileEx:function(hMPQ:integer;lpFileName:PChar;
                             dwSearchScope:integer;
                             var hFile:integer):boolean;stdcall;
//    SFileOpenFileEx:function(fname:PChar;var a1,a2:integer;a3,a4:integer):boolean;stdcall;
    SFileCloseFile:function(hFile:integer):boolean;stdcall;
    SFileGetFileSize:function(hFile:integer;var dwHigh:integer):integer;stdcall;
    SFileReadFile:function(hFile:integer;pBuf:pointer;dwToRead,pdwRead:integer;
                           lpOverlapped:pointer):boolean;stdcall;
//    SFileSetLocale:function(id:integer):integer;stdcall;
//--НАБОР ПРОЦЕДУР КОПИРОВАНИЯ ЭЛЕМЕНТОВ ДИНАМИЧЕСКИХ МАССИВОВ
//Копирование материалов:
procedure cpyMaterial(var src,dst:TMaterial);
//Копирует Geoset'ы.
//Копирование неполное: считается, что Faces собраны в
//1 линейку. Поля типа ChildVertices и CurrentListNum -
//не копируются.
procedure cpyGeoset(var src,dst:TGeoset);
//Копирование контроллера анимации
procedure cpyController(var src,dest:TController);
//Копирование записи Crds начиная со Start-вершины
procedure cpyCrds(var scr,dest:TCrds;Start:integer);
//Лог-процедура: создать лог-файл
//procedure CreateLogFile;
//Лог-процедура: вывести в лог строку-сообщение
procedure WriteToLog(s:string);
//-------------------------------------------------
//позволяет "вычленить" имя файла, убрав путь
function GetOnlyFileName(fname:string):string;
//открывает файл mdl, извлекая нач. информацию
procedure OpenMDL(fname:string);
//открывает файл MDX, полностью читая его
procedure OpenMDX(fname:string);
//Открывает файл M2 (модель WoW) и пытается конвертировать его.
//Изменить имя файла (для сохранения) нужно отдельно.
procedure OpenM2(fname:string);
//Открывает wmo-файлы (только RootWMO).
//Является обёрткой для OpenGroupWMO.
//Изменить имя файла для сохранения нужно отдельно.
//В случае успеха возвращает пустую строку.
//В случае ошибок/предупреждений возвр. их текст. 
function OpenWMO(fname:string):string;
//закрывает файл модели
procedure CloseMDL;
//перерасчитывает нормали для заданной поверхности
procedure RecalcNormals(geonum:integer);
//Проводит "сглаживание" путем усреднения нормалей
procedure SmoothWithNormals(geoID:integer);
//Проводит поиск вершины в ConstNormals.
//Если она там есть, возвр. ID соотв. записи. Иначе (-1).
function FindConstNormal(geoID,VertID:integer):integer;
//Применяет группы сглаживания к нормалям
procedure ApplySmoothGroups;
//Проводит "поворачивание" треугольников так,
//чтобы они соответствовали своим нормалям.
procedure NormalizeTriangles(geoID:integer);
//Осуществляет удаление нормали с указанными параметрами
//из MidNormals и ConstNormals (если там таковой уже нет,
//ничего не происходит)
procedure DeleteRecFromSmoothGroups(nrm:TMidNormal);
//Увеличивает округление моделей (везде обнуляет 2 старших байта),
//что приводит к увеличению сжимаемости.
procedure RoundModel;
//Удаляет повторяющиеся текстуры (уменьшая кол-во их записей)
procedure ReduceRepTextures;
//Удаляет повторяющиеся материалы
procedure ReduceRepMaterials;
//Сохраняет файл
procedure SaveMDL(fname:string);
//Сохраняет модель в формате MDX
procedure SaveMDX(fname:string);
//Загружает текстуру, возвращает буфер изображения
//а в width,height - размеры образа текстуры
procedure LoadTexture(dirName,fname:string;
                      var Width,Height:integer;var pReturn:pointer);
//Обертка для LoadTexture: Полностью создает списки всех текстур по слоям,
//для всех материалов
//Возвращает true при успехе
//контекст должен быть установлен, списки текстур очищены
function CreateAllTextures(dirName:string;r,g,b:GLfloat):boolean;
//Создает список GL для заданного материала
//MatID - ID материала, rgb - значение цвета команды.
//Все текстуры должны быть предварительно созданы
//(с учетом цвета команды!)
//Контекст должен быть установлен!
function MakeMaterialList(MatID:integer):boolean;
//Конвертирует текстуру WoW в blp1 (WC3).
//Информация записывается в тот же файл.
//При успешной конверсии возвращает true
function ConvertBLP2ToBLP(fname:string;IsBatch:boolean):boolean;
//Определяет границы указанной поверхности
procedure CalcBounds(geoID:integer;var anim:TAnim);
//Создаёт пустую GeosetAnim (т.е. со статичными,
//равными 1 Alpha и Color) для заданного GeosetID.
//В случае необходимости, GeosetAnimID сдвигаются
//Возвращает ID созданной анимации видимости
//или же (-1), если таковая уже существует
function CreateGeosetAnim(GeosetID:integer):integer;
//Профилировочная: считать RDTSC
function GetTSC:cardinal;

//Внешние (ассемблерные) процедуры/функции
function FindSym(StartAddr:pointer;SymCode:integer):cardinal;external;
function ExpGoToCipher(StartAddr:pointer):cardinal;external;
function GetIntVal(StartAddr:pointer;var rs:integer):integer;external;
function ExpGetFloat(StartAddr:pointer;var rs:single):integer;external;
{$L findsym.obj}
{$L gotocipher.obj}
{$L getintval.obj}
{$L expgetfloat.obj}

//Прототипы команд OpenGL (связывание текстуры):
procedure glGenTextures(n:GLsizei;textures:PGLuint);stdcall;external opengl32;
procedure glBindTexture(target:GLEnum;texture:GLuint);stdcall;external opengl32;
procedure glDeleteTextures(n:GLsizei;textures:PGLuint);stdcall;
          external opengl32;
//Ещё прототипы (массивы вершин):
procedure glVertexPointer(size:GLInt;typ:GLEnum;stride:GLSizei;p:pointer);
          stdcall;external opengl32;
procedure glEnableClientState(aarray:GLEnum);stdcall;external opengl32;
procedure glDisableClientState(aarray:GLEnum);stdcall;external opengl32;
procedure glDrawArrays(mode:GLEnum;first:GLint;count:GLsizei);stdcall;
          external opengl32;
procedure glArrayElement(index:GLint);stdcall;external opengl32;
procedure glNormalPointer(typ:GLEnum;stride:GLSizei;p:pointer);
          stdcall;external opengl32;
procedure glTexCoordPointer(size:GLInt;typ:GLEnum;stride:GLSizei;p:pointer);
          stdcall;external opengl32;
function SFileSetLocale(id:integer):integer;stdcall;
         external 'storm.dll' index 272;


const GL_VERTEX_ARRAY=$8074;
      GL_NORMAL_ARRAY=$8075;
      GL_COLOR_ARRAY =$8076;
      GL_TEXTURE_COORD_ARRAY=$8078;

//=========================================================
implementation
Var fblp:file;                    //тип: файл blp
    hIJL:hInst;

//Вспомогательная: конвертировать кватернион в матрицу поворота
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

//Набор процедур копирования сложных объектов
//Копирует материал:
procedure cpyMaterial(var src,dst:TMaterial);
Var i:integer;
Begin
 dst.ListNum:=src.ListNum;
 dst.TypeOfDraw:=src.TypeOfDraw;
 dst.Excentry:=src.Excentry;
 dst.IsConstantColor:=src.IsConstantColor;
 dst.IsSortPrimsFarZ:=src.IsSortPrimsFarZ;
 dst.IsFullResolution:=src.IsFullResolution;
 dst.PriorityPlane:=src.PriorityPlane;
 dst.CountOfLayers:=src.CountOfLayers;
 SetLength(dst.Layers,dst.CountOfLayers);
 for i:=0 to dst.CountOfLayers-1 do dst.Layers[i]:=src.Layers[i];
End;
//---------------------------------------------------------
//Копирует Geoset'ы:
procedure cpyGeoset(var src,dst:TGeoset);
Var j,i,ii,len:integer;
Begin
 dst.CountOfVertices:=src.CountOfVertices;
 SetLength(dst.Vertices,dst.CountOfVertices);
 for i:=0 to dst.CountOfVertices-1 do dst.Vertices[i]:=src.Vertices[i];

 dst.CountOfNormals:=src.CountOfNormals;
 SetLength(dst.Normals,dst.CountOfNormals);
 for i:=0 to dst.CountOfNormals-1 do dst.Normals[i]:=src.Normals[i];

 //Копируем массив текстурных координат
 dst.CountOfCoords:=src.CountOfCoords;
 SetLength(dst.Crds,dst.CountOfCoords);
 for j:=0 to dst.CountOfCoords-1 do begin
  dst.Crds[j].CountOfTVertices:=src.Crds[j].CountOfTVertices;
  SetLength(dst.Crds[j].TVertices,dst.Crds[j].CountOfTVertices);
  for i:=0 to dst.Crds[j].CountOfTVertices-1
  do dst.Crds[j].TVertices[i]:=src.Crds[j].TVertices[i];
 end;//of for j 

 len:=High(src.VertexGroup);
 SetLength(dst.VertexGroup,len+1);
 for i:=0 to len do dst.VertexGroup[i]:=src.VertexGroup[i];

 SetLength(dst.Faces,1);
 len:=High(src.Faces[0]);
 SetLength(dst.Faces[0],len+1);
 for i:=0 to len do dst.Faces[0,i]:=src.Faces[0,i];
 dst.CountOfFaces:=1;

 dst.CountOfMatrices:=src.CountOfMatrices;
 SetLength(dst.Groups,dst.CountOfMatrices);
 for i:=0 to dst.CountOfMatrices-1 do begin
  len:=High(src.Groups[i]);
  SetLength(dst.Groups[i],len+1);
  for ii:=0 to len do dst.Groups[i,ii]:=src.Groups[i,ii];
 end;//of for i

 dst.CountOfAnims:=src.CountOfAnims;
 SetLength(dst.Anims,dst.CountOfAnims);
 for i:=0 to dst.CountOfAnims-1 do dst.Anims[i]:=src.Anims[i];

 dst.MinimumExtent:=src.MinimumExtent;
 dst.MaximumExtent:=src.MaximumExtent;
 dst.BoundsRadius:=src.BoundsRadius;
 dst.MaterialID:=src.MaterialID;
 dst.SelectionGroup:=src.SelectionGroup;
 dst.Unselectable:=src.Unselectable;
End;
//---------------------------------------------------------
//Копирование контроллера анимации
procedure cpyController(var src,dest:TController);
Var i,len:integer;
Begin
 dest.ContType:=src.ContType;
 dest.GlobalSeqId:=src.GlobalSeqID;
 dest.SizeOfElement:=src.SizeOfElement;
 len:=length(src.Items);
 SetLength(dest.Items,len);
 for i:=0 to len-1 do dest.Items[i]:=src.Items[i];
End;
//---------------------------------------------------------
//Копирование записи Crds начиная со Start-вершины
procedure cpyCrds(var scr,dest:TCrds;Start:integer);
Var i:integer;
Begin
 dest.CountOfTVertices:=scr.CountOfTVertices;
 SetLength(dest.TVertices,scr.CountOfTVertices);
 for i:=Start to scr.CountOfTVertices-1 do Dest.TVertices[i]:=scr.TVertices[i];
End;
//---------------------------------------------------------
//Лог-процедура: создать лог-файл
{procedure CreateLogFile;
Var fLog:text;
Begin
 AssignFile(fLog,'mdlvis.log');
 rewrite(fLog);
 writeln(fLog,'MdlVis открывается');
 CloseFile(fLog);
End;}
//---------------------------------------------------------
//Лог-процедура: вывести в лог строку-сообщение
procedure WriteToLog(s:string);
Var fLog:text;
Begin
 AssignFile(fLog,'mdlvis.log');
 append(fLog);
 writeln(fLog,s);
 CloseFile(fLog);
End;

//=========================================================
//Вспомогательная процедура: считывает числo
function GetFloat(s:string;ps:cardinal):single;
Var si:string;i:integer;
Begin
 i:=ps;si:='';  //читаем первый символ
 while ((s[i]>='0') and (s[i]<='9')) or
       (s[i]='.') or (s[i]='-') or
       (s[i]='+') or (s[i]='e') or
       (s[i]='E') do begin
  si:=si+s[i];inc(i);
 end;//of while
 GetFloat:=strtofloat(si);//перевести в число
End;

//Вспомогательная: двигает к ближайшей цифре
//ps - позиция, начиная с которой идет поиск числа
//на выходе - позиция ближайшего числа
function GoToCipher(ps:cardinal):cardinal;
Var i:cardinal;
Begin
 i:=ps;
 while ((FileContent[i]<'0') or (FileContent[i]>'9')) and
       (FileContent[i]<>'-') do inc(i);
 GoToCipher:=i;
End;
//вспомогательная: поиск вперед по строке
//!err ошибка, если такой подстроки больше нет
function PosNext(substr,str:string;ps:cardinal):cardinal;
Var cps:cardinal;l,l2:integer;
Begin
 l2:=length(str);
 cps:=ps;l:=length(substr);
 
 while (copy(str,cps,l)<>substr) and
       (cps<l2) do begin
  inc(cps);
 end;
 PosNext:=cps;
 if cps>=l2 then PosNext:=$FFFFFFFF; //ошибка
End;

//читает координаты точки. ps - позиция файла
//NumGeo - номер поверхности, для которой идет чтение
//NumVert - собственно номер читаемой точки
procedure ReadVertex(var ps:cardinal;NumGeo,NumVert:integer);
Begin
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Vertices[NumVert-1,1]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Vertices[NumVert-1,2]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Vertices[NumVert-1,3]);
End;
//читает координаты нормали. ps - позиция файла
//NumGeo - номер поверхности, для которой идет чтение
//NumNorm - собственно номер читаемой нормали
procedure ReadNormal(var ps:cardinal;NumGeo,NumNorm:integer);
Begin
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Normals[NumNorm-1,1]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Normals[NumNorm-1,2]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Normals[NumNorm-1,3]);
End;
//читает координаты текстуры. ps - позиция файла
//NumGeo - номер поверхности, для которой идет чтение
//NumTex - собственно номер читаемой пары координат
procedure ReadTexV(var ps:cardinal;NumGeo,IdCrds,NumTex:integer);
Begin
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Crds[IdCrds].TVertices[NumTex-1,1]);
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].Crds[IdCrds].TVertices[NumTex-1,2]);
End;
//Читает номера вершин, входящих в разворот
//NumGeo - номер поверхности, для которой идет чтение
//NumFace - номер читаемого разворота
{ TODO -oАлексей -cСтранности : Кажись, глюк }
procedure ReadFace(var ps:cardinal;NumGeo,NumFace:integer);
Var EndPos:cardinal;cnt:integer;//кол-во вершин в развороте
Begin
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 EndPos:=ps+FindSym(@FileContent[ps],CODE_CBRACKET);
// ps:=PosNext('{',FileContent,ps); //Начало секции
// EndPos:=PosNext('}',FileContent,ps);//ищем конец вершины
 cnt:=1;
 repeat
  SetLength(geosets[NumGeo-1].Faces[NumFace-1],cnt);//размер
//  ps:=GoToCipher(ps);             //ищем цифру
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+GetIntVal(@FileContent[ps],Geosets[NumGeo-1].Faces[NumFace-1,cnt-1]);
  //Geosets[NumGeo-1].Faces[NumFace-1,cnt-1]:=round(GetFloat(FileContent,ps));
  //ps:=PosNext(',',FileContent,ps);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
  inc(cnt);
 until ps>EndPos;
End;

//Читает матрицы соединения с костями
procedure ReadMatrices(var ps:cardinal;NumGeo:integer);
Var i,cnt:integer;EndPos:cardinal;
Begin
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 //Определить число матриц соединения
 ps:=ps+GetIntVal(@FileContent[ps],Geosets[NumGeo-1].CountOfMatrices);
 SetLength(Geosets[NumGeo-1].Groups,Geosets[NumGeo-1].CountOfMatrices);
 for i:=0 to Geosets[NumGeo-1].CountOfMatrices-1 do begin
  ps:=PosNext('matrices',fileContent,ps);
  EndPos:=ps+FindSym(@FileContent[ps],CODE_CBRACKET);
  cnt:=1;
  repeat
   //установить размер массива
   SetLength(Geosets[NumGeo-1].Groups[i],cnt);
   ps:=ps+ExpGoToCipher(@FileContent[ps]);
   ps:=ps+GetIntVal(@FileContent[ps],Geosets[NumGeo-1].Groups[i,cnt-1]);
   ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
   inc(cnt);
  until  ps>=EndPos;
 end;//of for
End;
//Читает список границ
procedure ReadExtents(var ps:cardinal;NumGeo:integer);
Var i:integer;
Begin
 //1. Читать BoundsRadius, если он есть, для поверхности
 //ищем подходящий символ
 while (FileContent[ps]<>'a') and (FileContent[ps]<>'}') and
       (FileContent[ps]<>'b') do inc(ps);
 //какая-то ошибка
 if (FileContent[ps]='}') or
    ((FileContent[ps]='b') and (Copy(FileContent,ps,12)<>'boundsradius'))then
 begin
  Geosets[NumGeo-1].CountOfAnims:=0;
  Geosets[NumGeo-1].BoundsRadius:=0;
  exit;
 end;//of if
 if FileContent[ps]='b' then begin //радиус найден!
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[NumGeo-1].BoundsRadius);
 end;//of if
 Geosets[NumGeo-1].CountOfAnims:=0;
 //2. Искать первую Anim
repeat
 while (FileContent[ps]<>'a') and (FileContent[ps]<>'}') do inc(ps);
 if copy(FileContent,ps,4)<>'anim' then exit;
// if FileContent[ps]='}' then exit; //все
 inc(Geosets[NumGeo-1].CountOfAnims);//установить кол-во анимаций
 SetLength(Geosets[NumGeo-1].Anims,Geosets[NumGeo-1].CountOfAnims);//размер
 //Чтение параметров
 ps:=PosNext('anim',FileContent,ps);
 //ps:=PosNext('minimumextent',FileContent,ps);
 //Ищем нижнюю границу
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET)+1;
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 asm
  fninit
 end;
 for i:=1 to 3 do begin
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],
    Geosets[NumGeo-1].Anims[Geosets[NumGeo-1].CountOfAnims-1].MinimumExtent[i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for
// ps:=PosNext('maximumextent',FileContent,ps);
 //Ищем верхнюю границу
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET); 
 for i:=1 to 3 do begin
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],
    Geosets[NumGeo-1].Anims[Geosets[NumGeo-1].CountOfAnims-1].MaximumExtent[i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for
 ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 while (FileContent[ps]<>'}') and (FileContent[ps]<>'b') do inc(ps);
 if FileContent[ps]<>'}' then begin
// ps:=PosNext('boundsradius',FileContent,ps);
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],
      Geosets[NumGeo-1].Anims[Geosets[NumGeo-1].CountOfAnims-1].BoundsRadius);
 end else begin
  Geosets[NumGeo-1].Anims[Geosets[NumGeo-1].CountOfAnims-1].BoundsRadius:=600;
 end;//of if
 ps:=ps+FindSym(@FileContent[ps],CODE_CBRACKET)+1;
// ps:=PosNext('}',FileContent,ps)+1;
until false;
End;
//Читает "окончание" описания поверхности: материал, гр. выделения и др.
procedure ReadTail(var ps:cardinal;num:integer);
Begin with Geosets[num-1] do begin
 ps:=ps-300;                      //сдвигаемся от конца описания
 ps:=PosNext('materialid',FileContent,ps);//ищем ID материала
 ps:=GoToCipher(ps);              //искать число
 MaterialID:=round(GetFloat(FileContent,ps));//читать
 //чтение остального
 Unselectable:=false;SelectionGroup:=0;
repeat
 while (FileContent[ps]<>'s') and (FileContent[ps]<>'}') and
       (FileContent[ps]<>'u') do inc(ps);
 if FileContent[ps]='}' then exit;
 if FileContent[ps]='s' then begin
  ps:=GoToCipher(ps);SelectionGroup:=round(GetFloat(FileContent,ps));
 end;//of if
 if FileContent[ps]='u' then begin
  Unselectable:=true;
  exit;
 end;//of if
until false;
end;End;
//читает поверхность. num - номер, CurGeoPos-позиция в файле
//строки со словом geoset. Доб. в конец Geosets.
procedure ReadGeoset(num:integer);
Var ps{,tmpps}:cardinal;i,cnt:integer;s:string;
Begin
 //1. Читать кол-во вершин
 ps:=PosNext('vertices ',FileContent,CurGeoPos);//!err
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+GetIntVal(@FileContent[ps],Geosets[num-1].CountOfVertices);
 SetLength(Geosets[num-1].Vertices,Geosets[num-1].CountOfVertices);
 //2. Читать список вершин
 asm
  fninit
 end;
 for i:=1 to Geosets[num-1].CountOfVertices do ReadVertex(ps,num,i);
 //3. Читать кол-во нормалей
 ps:=PosNext('normals ',FileContent,CurGeoPos);//!err
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+GetIntVal(@FileContent[ps],Geosets[num-1].CountOfNormals);
 SetLength(Geosets[num-1].Normals,Geosets[num-1].CountOfNormals);
 //4. Читать список нормалей
 asm
  fninit
 end;
 for i:=1 to Geosets[num-1].CountOfNormals do ReadNormal(ps,num,i);

 //5. Читать текстурные координаты (Таких секций может быть несколько!)
 //5a. Ищем очередную секцию
// ps:=CurGeoPos; (!dbg: возможно, следует откомментировать)
 asm
  fninit
 end;
 with Geosets[num-1] do repeat
  ps:=PosNext('tvertices ',FileContent,ps);//!err
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  //ps:=GoToCipher(ps); //искать число
  inc(CountOfCoords);
  SetLength(Crds,CountOfCoords);
  ps:=ps+GetIntVal(@FileContent[ps],Crds[CountOfCoords-1].CountOfTVertices);
//  Crds[CountOfCoords-1].CountOfTVertices:=round(GetFloat(FileContent,ps));
  SetLength(Crds[CountOfCoords-1].TVertices,
            Crds[CountOfCoords-1].CountOfTVertices);
  //5b. Читать список координат текстуры.
  for i:=1 to Crds[CountOfCoords-1].CountOfTVertices
  do ReadTexV(ps,num,CountOfCoords-1,i);
  s:=copy(FileContent,ps,50);
 until pos('tvertices',s)=0;

 //7. Читать список групп
 CurGeoPos:=ps;
 ps:=PosNext('vertexgroup ',FileContent,CurGeoPos);//!err
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
// ps:=GoToCipher(ps); //искать число
 SetLength(Geosets[num-1].VertexGroup,Geosets[num-1].CountOfVertices);
 for i:=1 to Geosets[num-1].CountOfVertices do begin
  ps:=ps+GetIntVal(@FileContent[ps],Geosets[num-1].VertexGroup[i-1]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
{  Geosets[num-1].VertexGroup[i-1]:=round(GetFloat(FileContent,ps));
  ps:=PosNext(',',FileContent,ps);
  ps:=GoToCipher(ps);              //ищем число}
 end;//of for
 //8. Читать кол-во разворотов (Faces)
 ps:=PosNext('faces ',FileContent,CurGeoPos);//!err
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 //! Модифицировано: все читается в одну группу
 while FileContent[ps]<>' ' do inc(ps);
 ps:=ps+ExpGoToCipher(@FileContent[ps]);
 ps:=ps+GetIntVal(@FileContent[ps],cnt); //читаем это кол-во
 Geosets[num-1].CountOfFaces:=1;
 SetLength(Geosets[num-1].Faces,Geosets[num-1].CountOfFaces);
 SetLength(Geosets[num-1].Faces[0],cnt);//установить размер
 ps:=ps+FindSym(@FileContent[ps],CODE_OBRACKET);
 for i:=0 to cnt-1 do begin       //читаем номера вершин
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+GetIntVal(@FileContent[ps],Geosets[num-1].Faces[0,i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for i                           

 //10. Читать матрицы(соед. с костями)
 ps:=PosNext('groups',FileContent,ps);     //!err
 ReadMatrices(ps,num);
 //11. Читать границы поверхности
 ps:=PosNext('minimumextent',FileContent,ps);//искать
 for i:=1 to 3 do begin
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[num-1].MinimumExtent[i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for
 ps:=PosNext('maximumextent',FileContent,ps);//максимальная граница
 for i:=1 to 3 do begin
  ps:=ps+ExpGoToCipher(@FileContent[ps]);
  ps:=ps+ExpGetFloat(@FileContent[ps],Geosets[num-1].MaximumExtent[i]);
  ps:=ps+FindSym(@FileContent[ps],CODE_COMMA);
 end;//of for
 ReadExtents(ps,num);//читать массив Anim
 //Читаем "Хвост" описания поверхности
 ReadTail(ps,num); //чтение
 ps:=PosNext('}',FileContent,ps); //ищем окончание
// EndGeosetsPos:=ps+2;             //учесть enter
 //И, наконец, инициируем списки:
 Geosets[num-1].CurrentListNum:=1; //нет списка
 CurGeoPos:=ps;
End;
//Загружает имена файлов текстуры в массив Textures,
//устанавливает CountOfTextures
{procedure LoadTexturesNames;
Var i,len,ps,ps2:cardinal;s:string;
Begin
 i:=1;len:=length(FileContent)-8;
 //Поиск слова "Textures"
 repeat
  if (FileContent[i]='t') or (FileContent[i]='T') then begin
   if lowercase(copy(FileContent,i,8))='textures' then break;
  end;//of if
  inc(i);
 until i>=len;
 //Проверяем, найдены ли текстуры
 if lowercase(copy(FileContent,i,8))<>'textures' then begin
  CountOfTextures:=0;             //нет текстур
  MessageBox(0,'Секция текстур не найдена',scError,
                MB_ICONEXCLAMATION or MB_APPLMODAL);
  exit;                           //выйти
 end;//of if
 //Текстуры найдены! определим их количество
 ps:=GoToCipher(i);               //цифра
 CountOfTextures:=round(GetFloat(FileContent,ps));
 SetLength(Textures,CountOfTextures);//установить размер массива
 //Теперь читаем имена каждой текстуры
 i:=0;
 while i<CountOfTextures do begin
  ps:=PosNext('"',FileContent,ps);inc(ps);//ищем имя
  //Проверим, действительно ли это - имя текстуры
  s:=lowercase(copy(FileContent,ps-20,20));
  if pos('image',s)=0 then begin  //текстуры неожиданно кончились
   CountOfTextures:=i;
   break;
  end;//of if
  ps2:=PosNext('"',FileContent,ps);//dec(ps);
  Textures[i].FileName:=copy(FileContent,ps,ps2-ps);
  ps:=ps2+1;
  inc(i);
 end;//of while
 //Теперь проверим, нет ли дополнительных текстур
 repeat
  s:=lowercase(copy(FileContent,ps,100));
  if pos('bitmap',s)<>0 then begin //есть доп. текстуры
   inc(CountOfTextures);
   SetLength(Textures,CountOfTextures);
   //читаем данные новой текстуры
   ps:=PosNext('"',FileContent,ps);inc(ps);//ищем имя
   ps2:=PosNext('"',FileContent,ps);//dec(ps);
   Textures[CountOfTextures-1].FileName:=copy(FileContent,ps,ps2-ps);
   ps:=ps2+1;
  end else break;
 until false;
End;          }
//--------------------------------------------------------
//Загружает имена и параметры текстур
procedure LoadTextures;
Var i:integer;ps:cardinal;
Begin
 ps:=pos('textures ',FileContent);
 if ps=0 then begin
  MessageBox(0,'Текстуры не найдены.','Ошибка',MB_ICONSTOP);
  CountOfTextures:=0;
  exit;
 end;//of if
 //цикл загрузки
 i:=-1;
 repeat
  inc(i);
  SetLength(Textures,i+1);        //выделяем память
  FillChar(Textures[i],SizeOf(Textures[i]),0);
  Textures[i].FileName:='';
  //Чтение имени текстуры
  ps:=PosNext('image',FileContent,ps);
  ps:=ps+FindSym(@FileContent[ps],CODE_QM)+1;
  while FCont[ps]<>'"' do begin
   Textures[i].FileName:=Textures[i].FileName+FCont[ps];
   inc(ps);
  end;//of while

  ps:=PosNext(',',FileContent,ps);//выход на нужные параметры
  while FileContent[ps]<>'}' do begin
   inc(ps);
   if (FileContent[ps]='w') or (FileContent[ps]='r') then begin
    if copy(FileContent,ps,13)='replaceableid' then begin
     ps:=GoToCipher(ps);          //идти к числу
     Textures[i].ReplaceableID:=round(GetFloat(FileContent,ps));
    end;//of if ReplID
    if copy(FileContent,ps,9)='wrapwidth' then begin
     Textures[i].IsWrapWidth:=true;
     ps:=PosNext(',',FileContent,ps);
    end;//of if
    if copy(FileContent,ps,10)='wrapheight' then begin
     Textures[i].IsWrapHeight:=true;
     ps:=PosNext(',',FileContent,ps);
    end;//of if
   end;//of if
  end;//of while
  inc(ps);

  while (FileContent[ps]<>'}') and (FileContent[ps]<>'{') do inc(ps);
 Until FileContent[ps]='}';
 CountOfTextures:=i+1;
End;
//---------------------------------------------------------
//Осуществляет загрузку контроллера в массив Controllers
//и возвращает номер нового контроллера
//ps-позиция в FileContent (начиная со "{")
//CountOfKeyFrames - кол-во ключевых кадров контроллера
//SizeOfElement - ширина строки контроллера
function LoadController(var ps:cardinal;CountOfKeyFrames,
                        SizeOfElement:integer):integer;
Var len,i,ii:integer;psIn,SavePs:cardinal;
Begin
 //1. Создать новый элемент-контроллер
 len:=length(Controllers);
 SetLength(Controllers,len+1);
 LoadController:=len;             //вернуть номер элемента
 Controllers[len].GlobalSeqId:=-1;//пока нет глобального ID
 //2. Создать набор элементов контроллера
 Controllers[len].SizeOfElement:=SizeOfElement;
 SetLength(Controllers[len].Items,CountOfKeyFrames);
 //3. Определить тип контроллера
 psIn:=ps;
 repeat
  while (FileContent[psIn]<>'l') and (FileContent[psIn]<>'d') and
        (FileContent[psIn]<>'b') and (FileContent[psIn]<>'h') do inc(psIn);
 until (copy(FileContent,psIn,6)='linear') or
       (copy(FileContent,psIn,10)='dontinterp') or
       (copy(FileContent,psIn,6)='bezier') or
       (copy(FileContent,psIn,7)='hermite');
 if FileContent[psIn]='l' then Controllers[len].ContType:=Linear;
 if FileContent[psIn]='d' then Controllers[len].ContType:=DontInterp;
 if FileContent[psIn]='b' then Controllers[len].ContType:=Bezier;
 if FileContent[psIn]='h' then Controllers[len].ContType:=Hermite;
 //Читаем GlobalSeqID
 SavePs:=psIn;                      //пока сохраним позицию
 while (FileContent[psIn]<>':') and (FileContent[psIn]<>'g') do inc(psIn);
 if copy(FileContent,psIn,11)='globalseqid' then begin//найдено!
  psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
  psIn:=psIn+GetIntVal(@FileContent[psIn],Controllers[len].GlobalSeqId);
  psIn:=psIn+FindSym(@FileContent[psIn],CODE_COMMA);
 end else psIn:=SavePs;                    //восстановление
 //4. Собственно загрузка (в зависимости от типа)
 asm
  fninit
 end;
 for i:=0 to CountOfKeyFrames-1 do begin
  psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
  psIn:=psIn+GetIntVal(@FileContent[psIn],Controllers[len].Items[i].Frame);
  psIn:=psIn+FindSym(@FileContent[psIn],CODE_COLON);
  for ii:=1 to SizeOfElement do begin
   psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
   asm
    fninit
   end;
   psIn:=psIn+ExpGetFloat(@FileContent[psIn],Controllers[len].Items[i].Data[ii]);
   psIn:=psIn+FindSym(@FileContent[psIn],CODE_COMMA);
  end;//of for ii
  //Если есть тангенсы углов, читаем их
  if (Controllers[len].ContType=Bezier) or
     (Controllers[len].ContType=Hermite) then begin
   //Читаем InTan
   for ii:=1 to SizeOfElement do begin
    psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
    psIn:=psIn+ExpGetFloat(@FileContent[psIn],Controllers[len].Items[i].InTan[ii]);
    psIn:=psIn+FindSym(@FileContent[psIn],CODE_COMMA);
   end;//of for ii
   //Читаем OutTan
   for ii:=1 to SizeOfElement do begin
    psIn:=psIn+ExpGoToCipher(@FileContent[psIn]);
    psIn:=psIn+ExpGetFloat(@FileContent[psIn],Controllers[len].Items[i].OutTan[ii]);
    psIn:=psIn+FindSym(@FileContent[psIn],CODE_COMMA);
   end;//of for ii
  end;//of if
 end;//of for i
 //Ищем закрывающую скобку
 psIn:=psIn+FindSym(@FileContent[psIn],CODE_CBRACKET);

 //Вернуть новую позицию
 ps:=psIn;
End;
//---------------------------------------------------------
//читает слой для материала с номером mnum
procedure ReadLayer(mnum:integer;var ps:cardinal);
Var lnum{,tmp}:integer;StaticFound:boolean;
Begin with Materials[mnum-1] do begin
 lnum:=CountOfLayers;             //слой для доступа
 inc(CountOfLayers);              //на 1 слой больше
 SetLength(Layers,CountOfLayers); //установить размер списка слоев
 ps:=PosNext('filtermode',FileContent,ps);//запись режима смешения
 ps:=ps+10;                       //пропуск FilterMode
 while FileContent[ps]=' ' do inc(ps);//пропуск пробелов
 //собственно анализ режима
 if copy(FileContent,ps,4)='none' then layers[lnum].FilterMode:=Opaque;
 if copy(FileContent,ps,11)='transparent' then layers[lnum].FilterMode:=ColorAlpha;
 if copy(FileContent,ps,5)='blend' then layers[lnum].FilterMode:=FullAlpha;
 if copy(FileContent,ps,8)='additive' then layers[lnum].FilterMode:=Additive;
 if copy(FileContent,ps,8)='addalpha' then layers[lnum].FilterMode:=AddAlpha;
 if copy(FileContent,ps,8)='modulate' then layers[lnum].FilterMode:=Modulate;
 if copy(FileContent,ps,10)='modulate2x' then layers[lnum].FilterMode:=Modulate2X;
 //идем дальше
 ps:=PosNext(',',FileContent,ps);
 Layers[lnum].IsUnshaded:=false;Layers[lnum].IsTwoSided:=false;
 Layers[lnum].IsUnfogged:=false;Layers[lnum].IsNoDepthTest:=false;
 Layers[lnum].IsSphereEnvMap:=false;
 Layers[lnum].IsNoDepthSet:=false;Layers[lnum].Alpha:=-1;
 Layers[lnum].IsAlphaStatic:=true;
 Layers[lnum].CoordID:=-1;
 //Добавлено:
 Layers[lnum].IsTextureStatic:=true;
 Layers[lnum].TextureID:=-1;
 Layers[lnum].TVertexAnimID:=-1;
 StaticFound:=false; //Пока не найдено это слово
 repeat                           //бесконечный цикл
  while (FileContent[ps]<>'u') and (FileContent[ps]<>'t')
         and (FileContent[ps]<>'n') and (FileContent[ps]<>'s')
         and (FileContent[ps]<>'c') and (FileContent[ps]<>'a')
         and (FileContent[ps]<>'}') do inc(ps);
  if FileContent[ps]='}' then break; //достигнут конец секции
  if copy(FileContent,ps,8)='unshaded' then Layers[lnum].IsUnshaded:=true;
  if copy(FileContent,ps,8)='twosided' then Layers[lnum].IsTwoSided:=true;
  if copy(FileContent,ps,8)='unfogged' then Layers[lnum].IsUnfogged:=true;
  if copy(FileContent,ps,11)='nodepthtest' then Layers[lnum].IsNoDepthTest:=true;
  if copy(FileContent,ps,10)='nodepthset' then Layers[lnum].IsNoDepthSet:=true;
  if copy(FileContent,ps,12)='sphereenvmap' then Layers[lnum].IsSphereEnvMap:=true;
  if copy(FileContent,ps,6)='static' then begin //текстура, альфа
   ps:=ps+7;//!
   StaticFound:=true;
  end;

  if copy(FileContent,ps,9)='textureid' then begin//дошли до текстуры
   ps:=GoToCipher(ps);            //ищем число
   Layers[lnum].TextureID:=round(GetFloat(FileContent,ps));//читаем ID
   Layers[lnum].IsTextureStatic:=true;
   if not StaticFound then begin  //текстура анимированная
    Layers[lnum].IsTextureStatic:=false;
    while FileContent[ps]<>'{' do inc(ps);//подготовка к чтению
    Layers[lnum].NumOfTexGraph:=LoadController(ps,Layers[lnum].TextureID,1);
    inc(ps);
   end;//of if (NotStatic)
   StaticFound:=false;            //флаг уже использован
   Continue;                      //продолжить цикл
  end;//of if(TextureID)

  if copy(FileContent,ps,5)='alpha' then begin//дошли до текстуры
   ps:=GoToCipher(ps);            //ищем число
   Layers[lnum].Alpha:=GetFloat(FileContent,ps);//читаем ID
   Layers[lnum].IsAlphaStatic:=true;
   if not StaticFound then begin  //текстура анимированная
    Layers[lnum].IsAlphaStatic:=false;
    while FileContent[ps]<>'{' do inc(ps);//подготовка к чтению
    Layers[lnum].NumOfGraph:=LoadController(ps,round(Layers[lnum].Alpha),1);
    inc(ps);
   end;//of if (NotStatic)
   StaticFound:=false;            //флаг уже использован
   Continue;                      //Продолжить цикл
  end;//of if(TextureID)

  if copy(FileContent,ps,13)='tvertexanimid' then begin//найдена аним.
   ps:=GoToCipher(ps);
   Layers[lnum].TVertexAnimID:=round(GetFloat(FileContent,ps));
  end;//of if(TVertexAnimID)

  if copy(FileContent,ps,7)='coordid' then begin
   ps:=GoToCipher(ps);
   Layers[lnum].CoordID:=round(GetFloat(FileContent,ps));
  end;//of if(CoordId)

  ps:=PosNext(',',FileContent,ps);//стандартный конец итерации
 until false;                     //конец БЦ
 inc(ps);                         //пропуск конечной скобки
end;End;

//Загружает (послойно) материалы и устанавливает их кол-во
procedure LoadMaterials;
Var ps:cardinal;m:integer;
Begin
 ps:=pos('materials',FileContent);//ищем секцию материалов
 ps:=GoToCipher(ps);              //число
 if ps=0 then begin               //при ошибке
  MessageBox(0,'Секция материалов не найдена',scError,
                mb_iconexclamation or mb_applmodal);
  CountOfMaterials:=0;exit;
 end;//of if      
 CountOfMaterials:=round(GetFloat(FileContent,ps));//читать кол-во материалов
 SetLength(Materials,CountOfMaterials);//резервируем место
 //цикл чтения материалов
 for m:=0 to CountOfMaterials-1 do begin
  Materials[m].ListNum:=-1;
  Materials[m].Layers:=nil;Materials[m].CountOfLayers:=0;
  Materials[m].IsConstantColor:=false;
  Materials[m].PriorityPlane:=-1;
  Materials[m].IsSortPrimsFarZ:=false;
  Materials[m].IsFullResolution:=false;
  ps:=PosNext('material',FileContent,ps);//начало записи
  ps:=ps+9;                       //пропуск слова "material"
  repeat                          //бесконечный цикл
  //ищем слой или цветовой параметр
  while (FileContent[ps]<>'c') and (FileContent[ps]<>'l')
        and (FileContent[ps]<>'}')
        and (FileContent[ps]<>'m')
        and (FileContent[ps]<>'p')
        and (FileContent[ps]<>'s')
        and (FileContent[ps]<>'f') do inc(ps);
  if FileContent[ps]='m' then break;//выход из БЦ
  if FileContent[ps]='c' then begin
   Materials[m].IsConstantColor:=true;
{   ps:=PosNext('layer',FileContent,ps);//идти к слою
   ReadLayer(m+1,ps);                 //читать слой}
   ps:=ps+13;
//   ps:=PosNext('}',FileContent,ps);
  end;//of if
  if copy(FileContent,ps,13)='priorityplane' then begin
   ps:=GoToCipher(ps);
   Materials[m].PriorityPlane:=round(GetFloat(FileContent,ps));
   //ps:=ps+13;
  end;//of if

  if copy(FileContent,ps,13)='sortprimsfarz' then begin
   Materials[m].IsSortPrimsFarZ:=true;
   ps:=ps+13;
  end;//of if (SortPrimsFarZ)

  if copy(FileContent,ps,14)='fullresolution' then begin
   Materials[m].IsFullResolution:=true;
   ps:=ps+14;
  end;//of if
  if FileContent[ps]='}' then break;//выход из БЦ
  //читать слой
  if FileContent[ps]='l' then ReadLayer(m+1,ps);
  until false;                    //конец БЦ
 end;//of for (m)
End;

//Вспомогательная: читает содержимое поля с заданным именем
//и возвращает его в виде float-числа
function ReadField(FieldName:string):single;
Var ps:cardinal;
Begin
 ReadField:=0;
 ps:=pos(FieldName,FileContent);  //ищем поле
 if ps=0 then exit;               //не найдено
 if copy(FileContent,ps,20)='numparticleemitters2' then begin
  FileContent[ps+20]:='x';
  ps:=GoToCipher(ps);inc(ps);
//  while FileContent[ps]<>' ' do inc(ps);
 end;//of if
 ps:=GoToCipher(ps);              //искать число
 ReadField:=GetFloat(FileContent,ps);//считать значение
End;      
//Загружает анимацию (границы, радиус)
procedure LoadAnimBounds(var ps:cardinal;var a:Tanim);
Var psIn:cardinal;i:integer;
Begin
 psIn:=ps;
 a.MinimumExtent[1]:=0;a.MinimumExtent[2]:=0;a.MinimumExtent[3]:=0;
 a.MaximumExtent[1]:=0;a.MaximumExtent[2]:=0;a.MaximumExtent[3]:=0;
 a.BoundsRadius:=0;
 //Цикл анализа
 repeat
 while (FileContent[psIn]<>'}') and (FileContent[psIn]<>'m')
       and (FileContent[psIn]<>'b') do inc(psIn);
 if FileContent[psIn]='}' then break;//конец секции
 //чтение границы мин.
 if copy(FileContent,psIn,13)='minimumextent' then begin
  for i:=1 to 3 do begin
   psIn:=GoToCipher(psIn);
   a.MinimumExtent[i]:=GetFloat(FileContent,psIn);
   psIn:=PosNext(',',FileContent,psIn);
  end;//of for
  inc(psIn);                      //пропуск запятой
 end;//of if
 //чтение границы макс.
 if copy(FileContent,psIn,13)='maximumextent' then begin
  for i:=1 to 3 do begin
   psIn:=GoToCipher(psIn);
   a.MaximumExtent[i]:=GetFloat(FileContent,psIn);
   psIn:=PosNext(',',FileContent,psIn);
  end;//of for
  inc(psIn);                      //пропуск запятой
 end;//of if
 //граничный радиус
 if copy(FileContent,psIn,12)='boundsradius' then begin
  psIn:=GoToCipher(psIn);
  a.BoundsRadius:=GetFloat(FileContent,psIn);
 end;//of if
 inc(psIn);
 until false;

 ps:=psIn;
End;
//Грузит кол-во последовательностей и их имена
(*procedure LoadSeqNames;
Var ps,len:cardinal;i:integer;s:string;
Begin
 //1. Найдем секцию последовательностей
 ps:=pos('}',FileContent);        //начало поиска
 repeat
  inc(ps);
  while (FileContent[ps]<>'S') and (FileContent[ps]<>'s') do begin
   inc(ps);
   if ps>=length(FileContent) then begin
    CountOfSequences:=0;
    exit;
   end;//of if
  end;//of while
 until lowercase(copy(FileContent,ps,10))='sequences ';
 //2. Считаем кол-во последовательностей
 ps:=GoToCipher(ps);
 CountOfSequences:=round(GetFloat(FileContent,ps));
 SetLength(Sequences,CountOfSequences);
 //3. Цикл чтения имен
 i:=0;len:=Length(FileContent);
 while i<CountOfSequences do begin
  while (FileContent[ps]<>'"') and (ps<len) do inc(ps);//поиск имени
  //проверим, не кончились ли последовательности
  s:=lowercase(copy(FileContent,ps-40,40));
  if pos('anim',s)=0 then begin   //они кончились
   CountOfSequences:=i;
   break;
  end;//of if
  Sequences[i].Name:='';          //инициализация
  inc(ps);
  while FileContent[ps]<>'"' do begin//цикл чтения
   Sequences[i].Name:=Sequences[i].Name+FileContent[ps];
   inc(ps);
  end;//of while
  inc(ps);
  inc(i);
 end;//of while

 //проверим, не осталось ли их за концом секции
 repeat
  s:=lowercase(copy(FileContent,ps,256));
  if pos('anim',s)<>0 then begin
   inc(CountOfSequences);
   SetLength(Sequences,CountOfSequences);
   while (FileContent[ps]<>'"') and (ps<len) do inc(ps);//поиск имени
   Sequences[CountOfSequences-1].Name:=''; //инициализация
   inc(ps);
   while FileContent[ps]<>'"' do begin//цикл чтения
    Sequences[CountOfSequences-1].Name:=
             Sequences[CountOfSequences-1].Name+FileContent[ps];
    inc(ps);
   end;//of while
   inc(ps);
  end else break;
 until false;
End;                 *)
//----------------------------------------------------------
//Загрузка данных (в т.ч. имена) последовательностей
procedure LoadSeqData;
Var ps:cardinal;i:integer;
Begin
 //if CountOfSequences=0 then exit;
 //1. Подготовка к считыванию
 ps:=pos('sequences ',FileContent);
 if ps=0 then begin
  CountOfSequences:=0;
  exit;
 end;//of if

 //2. Цикл чтения
 i:=-1;
 repeat
  inc(i);
  SetLength(Sequences,i+1);
  Sequences[i].Name:='';
  Sequences[i].IntervalStart:=0;
  Sequences[i].IntervalEnd:=0;
  Sequences[i].Rarity:=-1;        //инициализация
  Sequences[i].IsNonLooping:=false;
  Sequences[i].MoveSpeed:=-1;
  Sequences[i].Bounds.BoundsRadius:=0;
  //Прежде всего читаем имя
  ps:=PosNext('anim ',FileContent,ps);//начало подсекции
  ps:=ps+FindSym(@FileContent[ps],CODE_QM)+1;
  while FCont[ps]<>'"' do begin
   Sequences[i].Name:=Sequences[i].Name+FCont[ps];
   inc(ps);
  end;//of while

  ps:=PosNext('{',FileContent,ps);//заходим в секцию
  repeat                          //сканирование
   while (FileContent[ps]<>'i') and (FileContent[ps]<>'r')
         and (FileContent[ps]<>'}') and (FileContent[ps]<>'m')
         and (FileContent[ps]<>'n') and (FileContent[ps]<>'b') do inc(ps);
   if FileContent[ps]='}' then break;//конец подсекции
   if copy(FileContent,ps,8)='interval' then begin//чтение интервала
    ps:=GoToCipher(ps);//ищем число
    Sequences[i].IntervalStart:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>',' do inc(ps);
    ps:=GoToCipher(ps);//ищем число
    Sequences[i].IntervalEnd:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>',' do inc(ps);    
   end;//of if
   if copy(FileContent,ps,10)='nonlooping' then Sequences[i].IsNonLooping:=true;
   if copy(FileContent,ps,6)='rarity' then begin
    ps:=GoToCipher(ps);
    Sequences[i].Rarity:=round(GetFloat(FileContent,ps));
   end;//of if (rarity)
   if copy(FileContent,ps,9)='movespeed' then begin
    ps:=GoToCipher(ps);
    Sequences[i].MoveSpeed:=round(GetFloat(FileContent,ps));
   end;//of if
   if (copy(FileContent,ps,13)='minimumextent') or
      (copy(FileContent,ps,13)='maximumextent') or
      (copy(FileContent,ps,12)='boundsradius') then begin
    LoadAnimBounds(ps,Sequences[i].Bounds);
    inc(ps);
    break;                        //конец цикла
   end;//of if
   inc(ps);                       //для продолжения
  until false;
  while (FileContent[ps]<>'a') and (FileContent[ps]<>'}') do inc(ps);
 until FileContent[ps]='}';

 CountOfSequences:=i+1;
End;
//----------------------------------------------------------
//Загрузка глобальных последовательностей
procedure LoadGlobalSequences;
Var ps:cardinal;i:integer;
Begin
 ps:=pos('globalsequences',FileContent);//искать секцию
 if ps=0 then begin               //нет такой секции
  CountOfGlobalSequences:=0;
  GlobalSequences:=nil;           //освободить память
  exit;                           //выйти
 end;//of if
 //если секция есть
 ps:=GoToCipher(ps);              //найти их кол-во
 CountOfGlobalSequences:=round(GetFloat(FileContent,ps));
 SetLength(GlobalSequences,CountOfGlobalSequences);
 while FileContent[ps]<>'{' do inc(ps);//заход в секцию
 for i:=0 to CountOfGlobalSequences-1 do begin
  ps:=GoTocipher(ps);             //поиск числа
  GlobalSequences[i]:=round(GetFloat(FileContent,ps));
//  if GlobalSequences[i]=0 then GlobalSequences[i]:=2;
  while FileContent[ps]<>',' do inc(ps);
 end;//of for
End;
//Читает секции GeosetAnims в соответствующий массив
procedure ReadGeosetAnims;
Var i,ii:integer;ps:cardinal;IsStatic:boolean;s:string;
Begin
 ps:=pos('geosetanim ',FileContent);//искать начало секции
 if ps=0 then begin               //вообще нет таких секций
  CountOfGeosetAnims:=0;
  exit;
 end;//of if
 SetLength(GeosetAnims,CountOfGeosetAnims);//выделить место
 i:=0;
 while i<CountOfGeosetAnims do with GeosetAnims[i] do begin
  //1. Инициализация
  Alpha:=-1;
  Color[1]:=-1;Color[2]:=-1;Color[3]:=-1;
  GeosetID:=-1;
  IsAlphaStatic:=true;IsColorStatic:=true;
  IsStatic:=false;IsDropShadow:=false;
  //2. Ищем начало секции
  while FileContent[ps]<>'{' do inc(ps);
  //3. Поиск+анализ найденного
  //Для начала проверим, не кончились ли секции
  s:=copy(FileContent,ps-40,40);
  if pos('geosetanim',s)=0 then begin //кончились
   CountOfGeosetAnims:=i;
   break;
  end;//of if
  repeat                          //БЦ анализа
   while (FileContent[ps]<>'a') and (FileContent[ps]<>'c') and
         (FileContent[ps]<>'g') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'}') and (FileContent[ps]<>'d') do inc(ps);
   if FileContent[ps]='}' then break;//конец секции
   if copy(FileContent,ps,10)='dropshadow' then begin
    ps:=ps+10;
    continue;
   end;//of if (DropShadow)

   if copy(FileContent,ps,6)='static' then begin
    IsStatic:=true;ps:=ps+6;
   end;//of if (static)

   if copy(FileContent,ps,8)='geosetid' then begin
    ps:=GoToCipher(ps);
    GeosetID:=round(GetFloat(FileContent,ps));//читать ID
   end;//of if

   if copy(FileContent,ps,5)='alpha' then begin
    ps:=GoToCipher(ps);           //сначала считаем
    Alpha:=GetFloat(FileContent,ps);
    if IsStatic then begin        //статический вариант 
     IsAlphaStatic:=true;IsStatic:=false;
    end else begin                //динамический вариант
     IsAlphaStatic:=false;
     while FileContent[ps]<>'{' do inc(ps);
     AlphaGraphNum:=LoadController(ps,round(alpha),1);
     inc(ps);
    end;//of if (static/dynamic)
   end;//of if (alpha)

   if copy(FileContent,ps,5)='color' then begin
    ps:=GoToCipher(ps);           //позиция числа
    if IsStatic then begin        //статический вариант
     IsColorStatic:=true;IsStatic:=false;
     for ii:=1 to 3 do begin
      ps:=GoToCipher(ps);
      Color[ii]:=GetFloat(FileContent,ps);
      ps:=PosNext(',',FileContent,ps);
     end;//of for ii
    end else begin                //динамический вариант
     Color[1]:=GetFloat(FileContent,ps);//чтение кол-ва кадров
     IsColorStatic:=false;
     while FileContent[ps]<>'{' do inc(ps);
     ColorGraphNum:=LoadController(ps,round(Color[1]),3);
     inc(ps);
    end;//of if (static/dynamic)
   end;//of if (color)
  until false;                    //конец БЦ

  //Смотрим, нет ли чего за концом секции
  if i=CountOfGeosetAnims-1 then begin
   s:=copy(FileContent,ps,100);
   if pos('geosetanim',s)<>0 then begin
    inc(CountOfGeosetAnims);
    SetLength(GeosetAnims,CountOfGeosetAnims);
   end;//of if
  end;//of if
  inc(i);
 end;//of with/while i
End;
//Вспомогательная: считывает параметры кости/помощника
//и возвращает их. ps-позиция "Bone" или "Helper"
function ReadTBone(var ps:cardinal):TBone;
Var b:TBone;{i:integer;}psIn,psStart,psEnd:cardinal;
    s:string;
Begin
 //0. Инициализация
 b.ObjectID:=-1;b.GeosetID:=-1;b.GeosetAnimID:=-1;
 b.IsBillboarded:=false;b.Parent:=-1;
 b.IsBillboardedLockX:=false;
 b.IsBillboardedLockY:=false;
 b.IsBillboardedLockZ:=false;
 b.IsCameraAnchored:=false;
 b.Translation:=-1;b.Rotation:=-1;b.Scaling:=-1;b.Visibility:=-1;
 b.IsDIRotation:=false;b.IsDITranslation:=false;b.IsDIScaling:=false;
 //1. Читаем имя
 s:='';
 while FileContent[ps]<>'"' do inc(ps);//поиск имени
 inc(ps);                         //ps-указатель на имя
 psStart:=ps;
 while FileContent[ps]<>'"' do inc(ps);
 psEnd:=ps;
 b.Name:=copy(FCont,psStart,psEnd-psStart);                       //имя прочитано
 //2. Начинаем чтение всего остального
 while FileContent[ps]<>'{' do inc(ps);//начало секции
 repeat                           //БЦ поиска
  while (FileContent[ps]<>'o') and (FileContent[ps]<>'g') and
        (FileContent[ps]<>'b') and (FileContent[ps]<>'p') and
        (FileContent[ps]<>'t') and (FileContent[ps]<>'r') and
        (FileContent[ps]<>'s') and (FileContent[ps]<>'v') and
        (FileContent[ps]<>'}') and (FileContent[ps]<>'/') and
        (FileContent[ps]<>'d') and (FileContent[ps]<>'c') do inc(ps);
  //Проверим, что такое найдено
  if FileContent[ps]='}' then break;//конец секции
  if FileContent[ps]='/' then begin //комментарий
   while FileContent[ps]<>#13 do inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,8)='objectid' then begin
   ps:=GoToCipher(ps);
   b.ObjectID:=round(GetFloat(FileContent,ps));
   continue;
  end;//of if

  if copy(FileContent,ps,8)='geosetid' then begin
   psIn:=ps+8;                    //проверим на "Multiple"
   while (FileContent[psIn]<>'m') and (FileContent[psIn]<>',') do inc(psIn);
   if FileContent[psIn]=',' then begin//номер
    ps:=GoToCipher(ps);
    b.GeosetID:=round(GetFloat(FileContent,ps));
   end else begin                 //Multiple
    b.GeosetID:=Multiple;
   end;//of if(тип GeosetID)
   ps:=psIn;
   continue;
  end;//of if

  if copy(FileContent,ps,12)='geosetanimid' then begin
   psIn:=ps+12;                   //проверим на "None"
   while (FileContent[psIn]<>'n') and (FileContent[psIn]<>',') do inc(psIn);
   if FileContent[psIn]=',' then begin//номер
    ps:=GoToCipher(ps);
    b.GeosetAnimID:=round(GetFloat(FileContent,ps));
   end else begin                 //Multiple
    b.GeosetAnimID:=None;
   end;//of if(тип GeosetID)
   ps:=psIn;
   continue;
  end;//of if

  if copy(FileContent,ps,16)='billboardedlockz' then begin
   b.IsBillboardedLockZ:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if
  if copy(FileContent,ps,16)='billboardedlockx' then begin
   b.IsBillboardedLockX:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if
  if copy(FileContent,ps,16)='billboardedlocky' then begin
   b.IsBillboardedLockY:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,11)='billboarded' then begin
   b.IsBillboarded:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,13)='cameraanchored' then begin
   b.IsCameraAnchored:=true;
   while FileContent[ps]<>',' do inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,6)='parent' then begin
   ps:=GoToCipher(ps);
   b.Parent:=round(GetFloat(FileContent,ps));
   continue;
  end;//of if

  if copy(FileContent,ps,11)='dontinherit' then begin
   ps:=ps+11;                     //пропуск самой директивы
   repeat
   while (FileContent[ps]<>'r') and (FileContent[ps]<>'}') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'s') do inc(ps);
    if FileContent[ps]='r' then begin
     b.IsDIRotation:=true;ps:=ps+8;
    end;//of if (Rotation)
    if FileContent[ps]='t' then begin 
     b.IsDITranslation:=true;ps:=ps+11;
    end;//of if (Translation)
    if FileContent[ps]='s' then begin
     b.IsDIScaling:=true;ps:=ps+7;
    end;//of if
   until FileContent[ps]='}';
  end;//of if

  //Теперь - различные преобразования
  if copy(FileContent,ps,11)='translation' then begin
   ps:=GoToCipher(ps);
   b.Translation:=round(GetFloat(FileContent,ps));
   while FileContent[ps]<>'{' do inc(ps);
   b.Translation:=LoadController(ps,b.Translation,3);
   inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,8)='rotation' then begin
   ps:=GoToCipher(ps);
   b.Rotation:=round(GetFloat(FileContent,ps));
   while FileContent[ps]<>'{' do inc(ps);
   b.Rotation:=LoadController(ps,b.Rotation,4);
   inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,7)='scaling' then begin
   ps:=GoToCipher(ps);
   b.Scaling:=round(GetFloat(FileContent,ps));
   while FileContent[ps]<>'{' do inc(ps);
   b.Scaling:=LoadController(ps,b.Scaling,3);
   inc(ps);
   continue;
  end;//of if

  if copy(FileContent,ps,10)='visibility' then begin
   ps:=GoToCipher(ps);
   b.Visibility:=round(GetFloat(FileContent,ps));
   while FileContent[ps]<>'{' do inc(ps);
   b.Visibility:=LoadController(ps,b.Visibility,1);
   inc(ps);
   continue;
  end;//of if

  //MessageBox
  inc(ps);
 until false;                     //конец БЦ
 ReadTBone:=b;                    //вернуть значение
End;
//Загружает список костей
procedure ReadBones;
Var ps:cardinal;i:integer;
Begin
 ps:=pos('bone ',FileContent);
 SetLength(bones,CountOfBones);
 //цикл загрузки
 for i:=0 to CountOfBones-1 do begin
  ps:=PosNext('bone',FileContent,ps);
  bones[i]:=ReadTBone(ps);        //чтение
 end;//of for
 inc(ps);
 while (FileContent[ps]=#13) or (FileContent[ps]=#10)
       or (FileContent[ps]=' ') do inc(ps);
 //В случае единственного объекта прописать ObjectID=0
 if (CountOfBones=1) and (Bones[0].ObjectID<0) then Bones[0].ObjectID:=0;
// EndGeosetsPos:=ps-1;
end;
//Загрузка списка помощников
procedure ReadHelpers;
Var ps:cardinal;i:integer;
Begin
 ps:=pos('helper ',FileContent);
 SetLength(helpers,CountOfHelpers);
 //цикл загрузки
 for i:=0 to CountOfHelpers-1 do begin
  ps:=PosNext('helper',FileContent,ps);
  helpers[i]:=ReadTBone(ps);        //чтение
 end;//of for
 if CountOfHelpers<>0 then begin
  inc(ps);
  while (FileContent[ps]=#13) or (FileContent[ps]=#10)
        or (FileContent[ps]=' ') do inc(ps);
//  EndGeosetsPos:=ps-1;
 end;//of if
end;
//Считывает секцию геометрических центров
procedure LoadPivotPoints;
Var i,ii:integer;ps:cardinal;
Begin
 //1. Найти секцию и узнать кол-во центров
 ps:=pos('pivotpoints ',FileContent);
 ps:=GoToCipher(ps);
 CountOfPivotPoints:=round(GetFloat(FileContent,ps));
 while FileContent[ps]<>'{' do inc(ps);
 //2. Загрузка точек
 SetLength(pivotPoints,CountOfPivotPoints);
 for i:=0 to CountOfPivotPoints-1 do begin
  for ii:=1 to 3 do begin
   ps:=GoToCipher(ps);
   PivotPoints[i,ii]:=GetFloat(FileContent,ps);
   while FileContent[ps]<>',' do inc(ps);
  end;//of for ii
 end;//of for
End;

//Вспомогательная: инициализировать объект TBone
procedure InitTBone(var b:TBone);
Begin
 b.Name:='';
 b.ObjectID:=-1;
 b.GeosetID:=-1;
 b.GeosetAnimID:=-1;
 b.IsBillboarded:=false;
 b.IsBillboardedLockX:=false;
 b.IsBillboardedLockY:=false;
 b.IsBillboardedLockZ:=false;
 b.IsCameraAnchored:=false;
 b.Parent:=-1;
 b.Translation:=-1;
 b.Rotation:=-1;
 b.Scaling:=-1;
 b.Visibility:=-1;
 b.IsDIRotation:=false;
 b.IsDITranslation:=false;
 b.IsDIScaling:=false;
End;

//загружает источники света
procedure LoadLights(var ps:cardinal);
Var {ps,}{len:cardinal;}i,ii:integer;StaticFound:boolean;
Begin
 //1. Резервируем место и находим секцию источников
 if CountOfLights=0 then exit;     //нет источников света
 SetLength(Lights,CountOfLights);  //резерв. места
 ps:=pos('light ',FileContent);    //ищем секцию

 //Чтение всех источников
 for i:=0 to CountOfLights-1 do begin
  ps:=PosNext('light ',FileContent,ps);
  //1. Установить начальные значения
  InitTBone(Lights[i].Skel);
  Lights[i].AttenuationStart:=-1;Lights[i].AttenuationEnd:=-1;
  Lights[i].Intensity:=-1;
  Lights[i].Color[1]:=-1;Lights[i].Color[2]:=-1;Lights[i].Color[3]:=-1;
  Lights[i].IsASStatic:=true;Lights[i].IsAEStatic:=true;
  Lights[i].IsIStatic:=true;Lights[i].IsCStatic:=true;
  Lights[i].IsAIStatic:=true;Lights[i].IsACStatic:=true;
  //2. Считываем имя источника
  while FileContent[ps]<>'"' do inc(ps); //ищем имя
  inc(ps);Lights[i].Skel.Name:='';
  while FCont[ps]<>'"' do begin
   Lights[i].Skel.Name:=Lights[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while

  //3. Основной цикл чтения полей
  StaticFound:=false;
  repeat
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'b') and
         (FileContent[ps]<>'c') and (FileContent[ps]<>'d') and
         (FileContent[ps]<>'a') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'i') and (FileContent[ps]<>'v') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') do inc(ps);
   if FileContent[ps]='}' then break;//конец секции
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if

   if copy(FileContent,ps,16)='billboardedlockz' then begin
    ps:=ps+16;
    Lights[i].Skel.IsBillboardedLockZ:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,16)='billboardedlockx' then begin
    ps:=ps+16;
    Lights[i].Skel.IsBillboardedLockX:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,16)='billboardedlocky' then begin
    ps:=ps+16;
    Lights[i].Skel.IsBillboardedLockY:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,11)='billboarded' then begin
    ps:=ps+11;
    Lights[i].Skel.IsBillboarded:=true;
    Continue;
   end;//of if

   //Продолжаем
   if copy(FileContent,ps,14)='cameraanchored' then begin
    ps:=ps+14;
    Lights[i].Skel.IsCameraAnchored:=true;
    Continue;
   end;//of if

   //чтение наследования
   if copy(FileContent,ps,11)='dontinherit' then begin
    ps:=ps+11;
    repeat                        //БЦ
     while (FileContent[ps]<>'}') and (FileContent[ps]<>'r') and
           (FileContent[ps]<>'t') and (FileContent[ps]<>'s') do inc(ps);
     if copy(FileContent,ps,8)='rotation' then begin
      Lights[i].Skel.IsDIRotation:=true;
      ps:=ps+8;
      continue;
     end;//of if
     if copy(FileContent,ps,11)='translation' then begin
      Lights[i].Skel.IsDITranslation:=true;
      ps:=ps+11;
      continue;
     end;//of if
     if copy(FileContent,ps,7)='scaling' then begin
      Lights[i].Skel.IsDIScaling:=true;
      ps:=ps+7;
      continue;
     end;//of if
     inc(ps);
    until false;                  //конец БЦ
    inc(ps);
   end;//of if

   //Продолжаем. Тип источника:
   if copy(FileContent,ps,15)='omnidirectional' then begin
    ps:=ps+15;
    Lights[i].LightType:=Omnidirectional;
    continue;
   end;//of if
   if copy(FileContent,ps,11)='directional' then begin
    ps:=ps+11;
    Lights[i].LightType:=Directional;
    continue;
   end;//of if
   if copy(FileContent,ps,7)='ambient' then begin
    ps:=ps+7;
    Lights[i].LightType:=Ambient;
    continue;
   end;//of if

   //Анализ статичности
   if copy(FileContent,ps,6)='static' then begin
    ps:=ps+6;
    StaticFound:=true;
    continue;
   end;//of if

   //Интенсивности
   if copy(FileContent,ps,16)='attenuationstart' then begin
    ps:=GoToCipher(ps);
    Lights[i].AttenuationStart:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].AttenuationStart:=LoadController(ps,
                                 round(Lights[i].AttenuationStart),1);
     inc(ps);
     Lights[i].IsASStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end; //of if (AttenuationStart)
   if copy(FileContent,ps,14)='attenuationend' then begin
    ps:=GoToCipher(ps);
    Lights[i].AttenuationEnd:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].AttenuationEnd:=LoadController(ps,
                                round(Lights[i].AttenuationEnd),1);
     inc(ps);
     Lights[i].IsAEStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (AttenuationEnd)
   if copy(FileContent,ps,9)='intensity' then begin
    ps:=GoToCipher(ps);
    Lights[i].Intensity:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].Intensity:=LoadController(ps,round(Lights[i].Intensity),1);
     inc(ps);
     Lights[i].IsIStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Intensity)

   //чтение цвета
   if copy(FileContent,ps,5)='color' then begin
    if StaticFound then begin     //статический цвет
     for ii:=1 to 3 do begin      //чтение компонент
      ps:=GoToCipher(ps);
      Lights[i].Color[ii]:=GetFloat(FileContent,ps);
      ps:=PosNext(',',FileContent,ps);
     end;//of for ii
     StaticFound:=false;
    end else begin                //цвет анимирован
     ps:=GoToCipher(ps);
     Lights[i].Color[1]:=round(GetFloat(FileContent,ps));
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].Color[1]:=LoadController(ps,round(Lights[i].Color[1]),3);
     inc(ps);
     Lights[i].IsCStatic:=false;
    end;//of if(ColorStatic)
   end;//of if(Color)

   //еще одна интенсивность
   if copy(FileContent,ps,12)='ambintensity' then begin
    ps:=GoToCipher(ps);
    Lights[i].AmbIntensity:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].AmbIntensity:=LoadController(ps,round(Lights[i].AmbIntensity),1);
     inc(ps);
     Lights[i].IsAIStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Intensity)

   //еще один цвет
   if copy(FileContent,ps,8)='ambcolor' then begin
    if StaticFound then begin     //статический цвет
     for ii:=1 to 3 do begin      //чтение компонент
      ps:=GoToCipher(ps);
      Lights[i].AmbColor[ii]:=GetFloat(FileContent,ps);
      ps:=PosNext(',',FileContent,ps);
     end;//of for ii
     StaticFound:=false;
    end else begin                //цвет анимирован
     ps:=GoToCipher(ps);
     Lights[i].AmbColor[1]:=round(GetFloat(FileContent,ps));
     while FileContent[ps]<>'{' do inc(ps);
     Lights[i].AmbColor[1]:=LoadController(ps,round(Lights[i].AmbColor[1]),3);
     inc(ps);
     Lights[i].IsACStatic:=false;
    end;//of if(ColorStatic)
   end;//of if(Color)

   //Теперь - контроллеры преобразований
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Lights[i].Skel.Visibility:=LoadController(ps,Lights[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Lights[i].Skel.Translation:=LoadController(ps,Lights[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Lights[i].Skel.Rotation:=LoadController(ps,Lights[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Lights[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Lights[i].Skel.Scaling:=LoadController(ps,Lights[i].Skel.Scaling,3);
    inc(ps);
   end;//of if
   inc(ps);//!
  until false;                    //Конец БЦ
 end;//of for i
End;

//Загружает текстурные анимации
procedure LoadTextureAnims;
Var i,KeyNum:integer;
    ps:cardinal;
Begin
 //1. Находим нужную секцию
 ps:=pos('textureanims ',FileContent);//!
 if ps=0 then begin               //секция не найдена
  CountOfTextureAnims:=0;
  TextureAnims:=nil;
  exit;
 end;//of if (TextureAnims Not Found)

 //2. Узнаем количество элементов секции
 ps:=GoToCipher(ps);
 CountOfTextureAnims:=round(GetFloat(FileContent,ps));
 SetLength(TextureAnims,CountOfTextureAnims);//резервируем место

 //3. Собственно чтение (поэлементное)
 for i:=0 to CountOfTextureAnims-1 do begin
  TextureAnims[i].TranslationGraphNum:=-1;
  TextureAnims[i].RotationGraphNum:=-1;
  TextureAnims[i].ScalingGraphNum:=-1;
  //Ищем начало подсекции
  ps:=PosNext('tvertexanim {',FileContent,ps)+13;
  //Цикл парсинга подсекции
  repeat
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'t') and
         (FileContent[ps]<>'r') and (FileContent[ps]<>'s') do inc(ps);
   if FileContent[ps]='}' then break;//выход, конец секции
   //Чтение контроллеров
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    KeyNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    TextureAnims[i].TranslationGraphNum:=LoadController(ps,KeyNum,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    KeyNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    TextureAnims[i].RotationGraphNum:=LoadController(ps,KeyNum,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    KeyNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    TextureAnims[i].ScalingGraphNum:=LoadController(ps,KeyNum,3);
    inc(ps);
   end;//of if
  until false;                    //конец БЦ
 end;//of for i
End;

{procedure LoadAttachmentsNames;//загрузка имен прикреплений
Var i:integer;len,ps:cardinal;s:string;
Begin
 if CountOfAttachments=0 then exit;//нет точек
 SetLength(Attachments,CountOfAttachments);
 len:=length(FileContent);ps:=0;
 i:=0;
 while i<CountOfAttachments do begin
  //1. Ищем точку
  repeat
   while (FileContent[ps]<>'a') and (FileContent[ps]<>'A')
         and (ps<len) do inc(ps);
   if lowercase(copy(FileContent,ps,11))='attachment ' then break;
   if ps>=len then begin          //ошибка
    MessageBox(0,'Не найдены имена Attachments:'#13#10+
               'возможно, файл MDL поврежден',scError,mb_applmodal);
    exit;
   end;//of if
   inc(ps);
  until false;

  //2. Точка найдена
  while (FileContent[ps]<>'"') and (ps<len) do inc(ps);
  //проверим, не закончились ли точки прикрепления
  s:=lowercase(copy(FileContent,ps-40,40));
  if pos('attachment',s)=0 then begin//закончились
   CountOfAttachments:=i;
   break;
  end;//of if
  InitTBone(Attachments[i].Skel);
  Attachments[i].Skel.Name:='';inc(ps);
  while FileContent[ps]<>'"' do begin
   Attachments[i].Skel.Name:=Attachments[i].Skel.Name+FileContent[ps];
   inc(ps);
  end;//of while
  inc(i);
 end;//of while
End;         }
//Загружает список точек прикрепления
procedure LoadAttachments;
Var i:integer;ps:cardinal;
Begin
 CountOfAttachments:=0;           //пока нет таких точек
 //Начинаем сканирование
 ps:=pos('attachment ',FileContent);
 if ps=0 then exit;               //их действительно нет

 i:=-1;
 repeat
  inc(i);
  SetLength(Attachments,i+1);

  //инициализация
  InitTBone(Attachments[i].Skel);
  Attachments[i].Path:='';
  Attachments[i].AttachmentID:=-1;

  //чтение имени
  ps:=ps+FindSym(@FileContent[ps],CODE_QM)+1;
  while FCont[ps]<>'"' do begin
   Attachments[i].Skel.Name:=Attachments[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while

  //Читаем остальные данные
  while FileContent[ps]<>'{' do inc(ps);//ищем начало секции
  repeat                          //основной цикл анализа
   while (FileContent[ps]<>'o') and (FileContent[ps]<>'}') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'b') and
         (FileContent[ps]<>'c') and (FileContent[ps]<>'d') and
         (FileContent[ps]<>'a') and (FileContent[ps]<>'t') and
         (FileContent[ps]<>'r') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'v') do inc(ps);
   if FileContent[ps]='}' then break;
   //Стандартные элементы объекта
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   if copy(FileContent,ps,16)='billboardedlockz' then begin
    ps:=ps+16;
    Attachments[i].Skel.IsBillboardedLockZ:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,16)='billboardedlockx' then begin
    ps:=ps+16;
    Attachments[i].Skel.IsBillboardedLockX:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,16)='billboardedlocky' then begin
    ps:=ps+16;
    Attachments[i].Skel.IsBillboardedLockY:=true;
    Continue;
   end;//of if
   if copy(FileContent,ps,11)='billboarded' then begin
    ps:=ps+11;
    Attachments[i].Skel.IsBillboarded:=true;
    Continue;
   end;//of if

   //Продолжаем
   if copy(FileContent,ps,14)='cameraanchored' then begin
    ps:=ps+14;
    Attachments[i].Skel.IsCameraAnchored:=true;
    Continue;
   end;//of if

   //чтение наследования
   if copy(FileContent,ps,11)='dontinherit' then begin
    ps:=ps+11;
    repeat                        //БЦ
     while (FileContent[ps]<>'}') and (FileContent[ps]<>'r') and
           (FileContent[ps]<>'t') and (FileContent[ps]<>'s') do inc(ps);
     if FileContent[ps]='}' then break;
     if copy(FileContent,ps,8)='rotation' then begin
      Attachments[i].Skel.IsDIRotation:=true;
      ps:=ps+8;
      continue;
     end;//of if
     if copy(FileContent,ps,11)='translation' then begin
      Attachments[i].Skel.IsDITranslation:=true;
      ps:=ps+11;
      continue;
     end;//of if
     if copy(FileContent,ps,7)='scaling' then begin
      Attachments[i].Skel.IsDIScaling:=true;
      ps:=ps+7;
      continue;
     end;//of if
     inc(ps);
    until false;                  //конец БЦ
    inc(ps);
   end;//of if (DontInh)

   //Читаем далее
   if copy(FileContent,ps,12)='attachmentid' then begin
    ps:=GoToCipher(ps);
    Attachments[i].AttachmentID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   //Путь
   if copy(FileContent,ps,4)='path' then begin
    while FileContent[ps]<>'"' do inc(ps);
    Attachments[i].Path:='';inc(ps);
    while FCont[ps]<>'"' do begin
     Attachments[i].Path:=Attachments[i].Path+FCont[ps];
     inc(ps);
    end;//of while
    continue;
   end;//of if(Path)

   //контроллеры
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Attachments[i].Skel.Visibility:=
                   LoadController(ps,Attachments[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Attachments[i].Skel.Translation:=LoadController(ps,
                   Attachments[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Attachments[i].Skel.Rotation:=
                        LoadController(ps,Attachments[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Attachments[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Attachments[i].Skel.Scaling:=
                        LoadController(ps,Attachments[i].Skel.Scaling,3);
    inc(ps);
   end;//of if
   inc(ps);
  until false;                    //конец БЦ
  while (FileContent[ps]<>'p') and (FileContent[ps]<>'a') do inc(ps);
 Until FileContent[ps]='p';

 CountOfAttachments:=i+1;
End;

//Загрузка 1-й версии источников частиц
procedure LoadParticleEmitters;
Var ps:cardinal;i:integer;StaticFound,SubSection:boolean;
Begin
 if CountOfParticleEmitters1=0 then exit;//нет таких источников
 SetLength(ParticleEmitters1,CountOfParticleEmitters1);
 //Цикл чтения Источников частиц-1
 ps:=pos('particleemitter ',FileContent);
 for i:=0 to CountOfParticleEmitters1-1 do begin
  ps:=PosNext('particleemitter ',FileContent,ps);
  //Инициализация
  InitTBone(ParticleEmitters1[i].Skel);
  ParticleEmitters1[i].UsesType:=EmitterUsesTGA;
  ParticleEmitters1[i].EmissionRate:=-1;ParticleEmitters1[i].Gravity:=cNone;
  ParticleEmitters1[i].Longitude:=-1;ParticleEmitters1[i].Latitude:=-1;
//  ParticleEmitters1[i].VisibilityGraphNum:=-1;
  ParticleEmitters1[i].LifeSpan:=-1;
  ParticleEmitters1[i].InitVelocity:=cNone;
  ParticleEmitters1[i].Path:='';
  ParticleEmitters1[i].IsERStatic:=true;
  ParticleEmitters1[i].IsGStatic:=true;
  ParticleEmitters1[i].IsLongStatic:=true;
  ParticleEmitters1[i].IsLatStatic:=true;
  ParticleEmitters1[i].IsLSStatic:=true;
  ParticleEmitters1[i].IsIVStatic:=true;
//  ParticleEmitters1[i].TranslationGraphNum:=-1;
//  ParticleEmitters1[i].RotationGraphNum:=-1;
//  ParticleEmitters1[i].ScalingGraphNum:=-1;
//  ParticleEmitters1[i].Parent:=-1;
  StaticFound:=false;
  //чтение имени
  while FileContent[ps]<>'"' do inc(ps); //ищем имя
  inc(ps);ParticleEmitters1[i].Skel.Name:='';
  while FCont[ps]<>'"' do begin
   ParticleEmitters1[i].Skel.Name:=
           ParticleEmitters1[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while

  //начинаем сам цикл чтения
  while FileContent[ps]<>'{' do inc(ps);//начало секции
  repeat                          //БЦ
   while (FileContent[ps]<>'o') and (FileContent[ps]<>'p') and
         (FileContent[ps]<>'e') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'g') and (FileContent[ps]<>'l') and
         (FileContent[ps]<>'v') and (FileContent[ps]<>'}') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') and
         (FileContent[ps]<>'i') do inc(ps);
   if FileContent[ps]='}' then begin
    if not SubSection then break; //конец секции
    SubSection:=false;
    inc(ps);
    continue;
   end;//of if

   //Стандартные элементы объекта
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   if copy(FileContent,ps,14)='emitterusesmdl' then begin
    ParticleEmitters1[i].UsesType:=EmitterUsesMDL;
    ps:=ps+14;
   end;//of if

   if copy(FileContent,ps,6)='static' then begin
    ps:=ps+6;
    StaticFound:=true;
   end;//of if(Static)

   //Чтение полей
   if copy(FileContent,ps,12)='emissionrate' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].EmissionRate:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].EmissionRate:=
        LoadController(ps,round(ParticleEmitters1[i].EmissionRate),1);
     inc(ps);
     ParticleEmitters1[i].IsERStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (EmisionRate)
   if copy(FileContent,ps,7)='gravity' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Gravity:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].Gravity:=
        LoadController(ps,round(ParticleEmitters1[i].Gravity),1);
     inc(ps);
     ParticleEmitters1[i].IsGStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Gravity)
   if copy(FileContent,ps,9)='longitude' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Longitude:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].Longitude:=
        LoadController(ps,round(ParticleEmitters1[i].Longitude),1);
     inc(ps);
     ParticleEmitters1[i].IsLongStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Longitude)
   if copy(FileContent,ps,8)='latitude' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Latitude:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].Latitude:=
        LoadController(ps,round(ParticleEmitters1[i].Latitude),1);
     inc(ps);
     ParticleEmitters1[i].IsLatStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (Latitude)

   //Подсекция описания частицы
   if copy(FileContent,ps,8)='particle' then begin
    SubSection:=true;             //обработка подсекции
    ps:=ps+8;
    continue;
   end;//of if (Particle)

   //Поля подсекции
   if copy(FileContent,ps,8)='lifespan' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].LifeSpan:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].LifeSpan:=
        LoadController(ps,round(ParticleEmitters1[i].LifeSpan),1);
     inc(ps);
     ParticleEmitters1[i].IsLSStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (LifeSpan)
   if copy(FileContent,ps,12)='initvelocity' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].InitVelocity:=GetFloat(FileContent,ps);
    if not StaticFound then begin //чтение контроллера
     while FileContent[ps]<>'{' do inc(ps);
     ParticleEmitters1[i].InitVelocity:=
        LoadController(ps,round(ParticleEmitters1[i].InitVelocity),1);
     inc(ps);
     ParticleEmitters1[i].IsIVStatic:=false;
    end;//of if (not Static)
    StaticFound:=false;
   end;//of if (InitVelocity)

   //Путь
   if copy(FileContent,ps,4)='path' then begin
    while FileContent[ps]<>'"' do inc(ps);
    ParticleEmitters1[i].Path:='';inc(ps);
    while FileContent[ps]<>'"' do begin
     ParticleEmitters1[i].Path:=ParticleEmitters1[i].Path+FileContent[ps];
     inc(ps);
    end;//of while
    continue;
   end;//of if(Path)

   //контроллеры
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    ParticleEmitters1[i].Skel.Visibility:=
        LoadController(ps,ParticleEmitters1[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    ParticleEmitters1[i].Skel.Translation:=LoadController(ps,
                                   ParticleEmitters1[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    ParticleEmitters1[i].Skel.Rotation:=
                        LoadController(ps,ParticleEmitters1[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    ParticleEmitters1[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    ParticleEmitters1[i].Skel.Scaling:=
                        LoadController(ps,ParticleEmitters1[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //конец БЦ
 end;//of for i
End;

//Вспомогательная: загружает нужный элемент и возвращает его
//номер или номер контроллера
function GetSingleData(var ps:cardinal;IsStat:boolean):single;
Var rtn:single;
Begin
 ps:=GoToCipher(ps);
 rtn:=GetFloat(FileContent,ps);
 if not IsStat then begin //чтение контроллера
  while FileContent[ps]<>'{' do inc(ps);
  rtn:=LoadController(ps,round(rtn),1);
  inc(ps);
//     ParticleEmitters1[i].IsLatStatic:=false;
 end;//of if (not Static)
// StaticFound:=false;
 GetSingleData:=rtn;
End;
//Вспомогательная: загрузить объект TVertex
procedure LoadTVertex(var ps:cardinal;var v:TVertex);
Var i:integer;
Begin
 for i:=1 to 3 do begin
  ps:=GoToCipher(ps);
  v[i]:=GetFloat(FileContent,ps);
  ps:=PosNext(',',FileContent,ps);
 end;//of for i
End;
//загрузка 2-й версии источников частиц
procedure LoadParticleEmitters2;
Var i,ii:integer;ps:cardinal;StaticFound:boolean;
Begin
 if CountOfParticleEmitters=0 then exit;//нечего загружать
 SetLength(Pre2,CountOfParticleEmitters);//размер
 ps:=pos('particleemitter2 ',FileCOntent);
 for i:=0 to CountOfParticleEmitters-1 do begin
  ps:=posNext('"',FileContent,ps);
  //инициализация
  InitTBone(pre2[i].Skel);
//  pre2[i].Name:='';
//  pre2[i].IsDIRotation:=false;pre2[i].IsDiTranslation:=false;
  {pre2[i].IsDIScaling:=false;}pre2[i].IsSortPrimsFarZ:=false;
  pre2[i].IsUnshaded:=false;pre2[i].IsLineEmitter:=false;
  pre2[i].IsUnfogged:=false;pre2[i].IsModelSpace:=false;
  pre2[i].IsXYQuad:=false;pre2[i].Speed:=cNone;
  pre2[i].Variation:=-1;pre2[i].Latitude:=cNone;
  pre2[i].Gravity:=cNone;pre2[i].IsSquirt:=false;
  pre2[i].LifeSpan:=cNone;pre2[i].EmissionRate:=cNone;
  pre2[i].Width:=0;pre2[i].Length:=0;
  pre2[i].BlendMode:=FullAlpha;
  pre2[i].Rows:=1;pre2[i].Columns:=1;
  pre2[i].ParticleType:=ptHead;
  pre2[i].TailLength:=cNone;pre2[i].Time:=cNone;
  pre2[i].TextureID:=0;
  pre2[i].ReplaceableId:=0;pre2[i].PriorityPlane:=-1;
//  pre2[i].TranslationGraphNum:=-1;pre2[i].RotationGraphNum:=-1;
//  pre2[i].ScalingGraphNum:=-1;pre2[i].VisibilityGraphNum:=-1;
  pre2[i].IsSStatic:=true;pre2[i].IsVStatic:=true;
  pre2[i].IsLStatic:=true;pre2[i].IsGStatic:=true;
  pre2[i].IsEStatic:=true;pre2[i].IsWStatic:=true;
  pre2[i].IsHStatic:=true;
//  pre2[i].Parent:=-1;
  StaticFound:=false;
  //Чтение имени
  inc(ps);
  while FCont[ps]<>'"' do begin
   pre2[i].Skel.Name:=pre2[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while
  repeat                          //основной цикл чтения
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'d') and
         (FileContent[ps]<>'s') and (FileContent[ps]<>'u') and
         (FileContent[ps]<>'l') and (FileContent[ps]<>'m') and
         (FileContent[ps]<>'x') and (FileContent[ps]<>'v') and
         (FileContent[ps]<>'g') and (FileContent[ps]<>'e') and
         (FileContent[ps]<>'w') and (FileContent[ps]<>'b') and
         (FileContent[ps]<>'a') and (FileContent[ps]<>'r') and
         (FileContent[ps]<>'c') and (FileContent[ps]<>'h') and
         (FileContent[ps]<>'t') do inc(ps);
   if FileContent[ps]='}' then break; //выход
   //Стандартные элементы объекта
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Pre2[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Pre2[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   //чтение наследования
   if copy(FileContent,ps,11)='dontinherit' then begin
    ps:=ps+11;
    repeat                        //БЦ
     while (FileContent[ps]<>'}') and (FileContent[ps]<>'r') and
           (FileContent[ps]<>'t') and (FileContent[ps]<>'s') do inc(ps);
     if copy(FileContent,ps,8)='rotation' then begin
      Pre2[i].Skel.IsDIRotation:=true;
      ps:=ps+8;
      continue;
     end;//of if
     if copy(FileContent,ps,11)='translation' then begin
      Pre2[i].Skel.IsDITranslation:=true;
      ps:=ps+11;
      continue;
     end;//of if
     if copy(FileContent,ps,7)='scaling' then begin
      Pre2[i].Skel.IsDIScaling:=true;
      ps:=ps+7;
      continue;
     end;//of if
     inc(ps);
    until false;                  //конец БЦ
    inc(ps);
   end;//of if (DontInh)

   //еще ряд флагов
   if copy(FileContent,ps,13)='sortprimsfarz' then begin
    ps:=ps+13;
    pre2[i].IsSortPrimsFarZ:=true;
    continue;
   end;//of if (SortPrimsFarZ)

   if copy(FileContent,ps,8)='unshaded' then begin
    ps:=ps+8;
    pre2[i].IsUnshaded:=true;
    continue;
   end;//of if(Unshaded)

   if copy(FileContent,ps,11)='lineemitter' then begin
    ps:=ps+11;
    pre2[i].IsLineEmitter:=true;
    continue;
   end;//of if

   if copy(FileContent,ps,8)='unfogged' then begin
    ps:=ps+8;
    pre2[i].IsUnfogged:=true;
    continue;
   end;//of if

   if copy(FileContent,ps,10)='modelspace' then begin
    ps:=ps+10;
    pre2[i].IsModelSpace:=true;
    continue;
   end;//of if

   if copy(FileContent,ps,6)='xyquad' then begin
    ps:=ps+6;
    pre2[i].IsXYQuad:=true;
    continue;                
   end;//of if

   if copy(FileContent,ps,6)='static' then begin
    ps:=ps+6;
    StaticFound:=true;
    continue;
   end;//of if

   if copy(FileContent,ps,5)='speed' then begin
    pre2[i].Speed:=GetSingleData(ps,StaticFound);
    pre2[i].IsSStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,9)='variation' then begin
    pre2[i].Variation:=GetSingleData(ps,StaticFound);
    pre2[i].IsVStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,8)='latitude' then begin
    pre2[i].Latitude:=GetSingleData(ps,StaticFound);
    pre2[i].IsLStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,7)='gravity' then begin
    pre2[i].Gravity:=GetSingleData(ps,StaticFound);
    pre2[i].IsGStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,6)='squirt' then begin
    pre2[i].IsSquirt:=true;
    ps:=ps+6;
    continue;
   end;//of if

   if copy(FileContent,ps,9)='lifespan ' then begin
    ps:=GoToCipher(ps);
    pre2[i].LifeSpan:=GetFloat(FileContent,ps);
    continue;
   end;//of if

   if copy(FileContent,ps,12)='emissionrate' then begin
    pre2[i].EmissionRate:=GetSingleData(ps,StaticFound);
    pre2[i].IsEStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,5)='width' then begin
    pre2[i].Width:=GetSingleData(ps,StaticFound);
    pre2[i].IsWStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   if copy(FileContent,ps,6)='length' then begin
    pre2[i].Length:=GetSingleData(ps,StaticFound);
    pre2[i].IsHStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   //Тип смешения
   if copy(FileContent,ps,5)='blend' then begin
    pre2[i].BlendMode:=FullAlpha;
    ps:=ps+5;
    continue;
   end;//of if
   if copy(FileContent,ps,8)='additive' then begin
    pre2[i].BlendMode:=Additive;
    ps:=ps+8;
    continue;
   end;//of if
   if copy(FileContent,ps,8)='modulate' then begin
    pre2[i].BlendMode:=Modulate;
    ps:=ps+8;
    continue;
   end;//of if
   if copy(FileContent,ps,8)='alphakey' then begin
    pre2[i].BlendMode:=AlphaKey;
    ps:=ps+8;
    continue;
   end;//of if

   //Строки, колонки...
   if copy(FileContent,ps,4)='rows' then begin
    ps:=GoToCipher(ps);
    pre2[i].Rows:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,7)='columns' then begin
    ps:=GoToCipher(ps);
    pre2[i].Columns:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if

   //Способ отображения частицы
   if copy(FileContent,ps,4)='head' then begin
    ps:=ps+4;
    pre2[i].ParticleType:=ptHead;
    continue;
   end;//of if
   if copy(FileContent,ps,5)='tail ' then begin
    ps:=ps+4;
    pre2[i].ParticleType:=ptTail;
    continue;
   end;//of if
   if copy(FileContent,ps,4)='both' then begin
    ps:=ps+4;
    pre2[i].ParticleType:=ptBoth;
    continue;
   end;//of if

   //Продолжаем перечислять поля
   if copy(FileContent,ps,10)='taillength' then begin
    ps:=GoToCipher(ps);
    pre2[i].TailLength:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,4)='time' then begin
    ps:=GoToCipher(ps);
    pre2[i].Time:=GetFloat(FileContent,ps);
    continue;
   end;//of if

   //Читаем цвет
   if copy(FileContent,ps,12)='segmentcolor' then begin
    for ii:=1 to 3 do LoadTVertex(ps,pre2[i].SegmentColor[ii]);
    while FileContent[ps]<>'}' do inc(ps);//ищем конец подсекции
    inc(ps);
    continue;
   end;//of if

   //Чтение TVertex-полей
   if copy(FileContent,ps,5)='alpha' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].Alpha[ii]:=round(GetFloat(FileCOntent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if
   if copy(FileContent,ps,15)='particlescaling' then begin
    LoadTVertex(ps,pre2[i].ParticleScaling);
    continue;
   end;//of if
   if copy(FileContent,ps,14)='lifespanuvanim' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].LifeSpanUVAnim[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if
   if copy(FileContent,ps,11)='decayuvanim' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].DecayUVAnim[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if
   if copy(FileContent,ps,10)='tailuvanim' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].TailUVAnim[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if
   if copy(FileContent,ps,15)='taildecayuvanim' then begin
    for ii:=1 to 3 do begin
     ps:=GoToCipher(ps);
     pre2[i].TailDecayUVAnim[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    continue;
   end;//of if

   //Опять числовые поля
   if copy(FileContent,ps,9)='textureid' then begin
    ps:=GoToCipher(ps);
    pre2[i].TextureID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,13)='replaceableid' then begin
    ps:=GoToCipher(ps);
    pre2[i].ReplaceableId:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,13)='priorityplane' then begin
    ps:=GoToCipher(ps);
    pre2[i].PriorityPlane:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if

   //ну и, наконец, набор контроллеров
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    pre2[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Pre2[i].Skel.Visibility:=LoadController(ps,Pre2[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    pre2[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Pre2[i].Skel.Translation:=LoadController(ps,Pre2[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Pre2[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Pre2[i].Skel.Rotation:=LoadController(ps,Pre2[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Pre2[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Pre2[i].Skel.Scaling:=LoadController(ps,Pre2[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //конец БЦ
 end;//of for i
End;

//Загружает источники следа
procedure LoadRibbonEmitters;
Var ps:cardinal;i,ii:integer;StaticFound:boolean;
Begin
 if CountOfRibbonEmitters=0 then exit;
 SetLength(Ribs,CountOfRibbonEmitters);
 ps:=pos('ribbonemitter ',FileContent);
 for i:=0 to CountOfRibbonEmitters-1 do begin
  ps:=PosNext('"',FileContent,ps);
  //инициализация
  InitTBone(ribs[i].Skel);
//  ribs[i].Name:='';ribs[i].Parent:=-1;
  ribs[i].HeightAbove:=cNone;ribs[i].HeightBelow:=cNone;
  ribs[i].alpha:=-1;ribs[i].TextureSlot:=-1;
  ribs[i].EmissionRate:=-1;
  ribs[i].LifeSpan:=-1;ribs[i].Gravity:=cNone;
  ribs[i].Rows:=1;ribs[i].Columns:=1;
  ribs[i].MaterialID:=0;
  ribs[i].IsHAStatic:=true;ribs[i].IsHBStatic:=true;
  ribs[i].IsAlphaStatic:=true;
  ribs[i].IsColorStatic:=true;
  ribs[i].IsTSStatic:=true;
//  ribs[i].VisibilityGraphNum:=-1;ribs[i].TranslationGraphNum:=-1;
//  ribs[i].RotationGraphNum:=-1;ribs[i].ScalingGraphNum:=-1;
  StaticFound:=false;
  //чтение имени
  inc(ps);
  while FCont[ps]<>'"' do begin
   ribs[i].Skel.Name:=ribs[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while
  inc(ps);

  //основной цикл чтения
  repeat                          //БЦ
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'s') and
         (FileContent[ps]<>'h') and (FileContent[ps]<>'a') and
         (FileContent[ps]<>'c') and (FileContent[ps]<>'t') and
         (FileContent[ps]<>'v') and (FileContent[ps]<>'e') and
         (FileContent[ps]<>'l') and (FileContent[ps]<>'g') and
         (FileContent[ps]<>'r') and (FileContent[ps]<>'m') do inc(ps);
   if FileContent[ps]='}' then break;

   //Стандартные элементы объекта
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   if copy(FileContent,ps,6)='static' then begin
    StaticFound:=true;
    ps:=ps+6;
    continue;
   end;//of if

   //читаем поля высот
   if copy(FileContent,ps,11)='heightabove' then begin
    Ribs[i].HeightAbove:=GetSingleData(ps,StaticFound);
    Ribs[i].IsHAStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if
   if copy(FileContent,ps,11)='heightbelow' then begin
    Ribs[i].HeightBelow:=GetSingleData(ps,StaticFound);
    Ribs[i].IsHBStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if
   if copy(FileContent,ps,5)='alpha' then begin
    Ribs[i].Alpha:=GetSingleData(ps,StaticFound);
    Ribs[i].IsAlphaStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   //считываем цвет
   if copy(FileContent,ps,5)='color' then begin
    ps:=GoToCipher(ps);           //позиция числа
    if StaticFound then begin        //статический вариант
     Ribs[i].IsColorStatic:=true;//IsStatic:=false;
     for ii:=1 to 3 do begin
      ps:=GoToCipher(ps);
      Ribs[i].Color[ii]:=GetFloat(FileContent,ps);
      ps:=PosNext(',',FileContent,ps);
     end;//of for ii
    end else begin                //динамический вариант
     Ribs[i].Color[1]:=GetFloat(FileContent,ps);//чтение кол-ва кадров
     Ribs[i].IsColorStatic:=false;
     while FileContent[ps]<>'{' do inc(ps);
     Ribs[i].Color[1]:=LoadController(ps,round(Ribs[i].Color[1]),3);
     inc(ps);
    end;//of if (static/dynamic)
    StaticFound:=false;
   end;//of if (color)

   //Слот текстуры
   if copy(FileContent,ps,11)='textureslot' then begin
    Ribs[i].TextureSlot:=round(GetSingleData(ps,StaticFound));
    Ribs[i].IsTSStatic:=StaticFound;
    StaticFound:=false;
    continue;
   end;//of if

   //Считываем оставшиеся поля
   if copy(FileContent,ps,12)='emissionrate' then begin
    ps:=GoToCipher(ps);
    Ribs[i].EmissionRate:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,8)='lifespan' then begin
    ps:=GoToCipher(ps);
    Ribs[i].LifeSpan:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,7)='gravity' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Gravity:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,4)='rows' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Rows:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,7)='columns' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Columns:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if
   if copy(FileContent,ps,10)='materialid' then begin
    ps:=GoToCipher(ps);
    Ribs[i].MaterialID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if

   //Теперь - контроллеры
   if copy(FileContent,ps,10)='visibility' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Visibility:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Ribs[i].Skel.Visibility:=LoadController(ps,Ribs[i].Skel.Visibility,1);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Ribs[i].Skel.Translation:=LoadController(ps,Ribs[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Ribs[i].Skel.Rotation:=LoadController(ps,Ribs[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Ribs[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Ribs[i].Skel.Scaling:=LoadController(ps,Ribs[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //конец БЦ
 end;//of for i
End;

//Загрузка событий (спецэффектов)
procedure LoadEvents;
Var ps:cardinal;i,ii:integer;
Begin
 if CountOfEvents=0 then exit;
 SetLength(Events,CountOfEvents);
 ps:=pos('eventobject ',FileContent);
 for i:=0 to CountOfEvents-1 do begin
  //Инициализация
  InitTBone(Events[i].Skel);
  Events[i].CountOfTracks:=0;
  //Чтение имени
  while FileContent[ps]<>'"' do inc(ps);
  inc(ps);
  while FCont[ps]<>'"' do begin
   Events[i].Skel.Name:=Events[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while

  //основной цикл чтения
  repeat
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'e') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') and
         (FileContent[ps]<>'s') do inc(ps);
   if FileContent[ps]='}' then break;//конец секции
   //Читаем ID
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   //Читаем собственно список событий
   if copy(FileContent,ps,10)='eventtrack' then begin
    ps:=GoToCipher(ps);
    Events[i].CountOfTracks:=round(GetFloat(FileContent,ps));
    SetLength(Events[i].Tracks,Events[i].CountOfTracks);
    while FileContent[ps]<>'{' do inc(ps);//начало секции
    //читаем все события списка
    for ii:=0 to Events[i].CountOfTracks-1 do begin
     ps:=GoToCipher(ps);
     Events[i].Tracks[ii]:=round(GetFloat(FileContent,ps));
     ps:=PosNext(',',FileContent,ps);
    end;//of for i
    //Выходим за пределы секции
    while FileContent[ps]<>'}' do inc(ps);
    inc(ps);
    continue;
   end;//of if(EventTrack)

   //Читаем контроллеры
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Events[i].Skel.Translation:=LoadController(ps,Events[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Events[i].Skel.Rotation:=LoadController(ps,Events[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Events[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Events[i].Skel.Scaling:=LoadController(ps,Events[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //конец БЦ
 end;//of for i
End;

procedure LoadCameras;            //загрузка камер
Var ps:cardinal;i:integer;
Begin
 CountOfCameras:=0;               //пока их нет
 ps:=pos('camera ',FileContent);
 if ps=0 then exit;               //нет камер
 repeat
  inc(CountOfCameras);            //кол-во камер
  SetLength(Cameras,CountOfCameras);
  i:=CountOfCameras-1;            //счетчик цикла
  Cameras[i].TranslationGraphNum:=-1;
  Cameras[i].RotationGraphNum:=-1;
  Cameras[i].TargetTGNum:=-1;
  Cameras[i].Name:='';
  Cameras[i].FieldOfView:=-1;
  Cameras[i].FarClip:=cNone;
  Cameras[i].NearClip:=cNone;
  while FileContent[ps]<>'"' do inc(ps);
  inc(ps);
  while FCont[ps]<>'"' do begin
   Cameras[i].Name:=Cameras[i].Name+FCont[ps];
   inc(ps);
  end;//of while
  repeat                          //основной цикл чтения
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'p') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') and
         (FileContent[ps]<>'f') and (FileContent[ps]<>'n') do inc(ps);
   if FileContent[ps]='}' then break;//конец секции
   if copy(FileContent,ps,8)='position' then begin
    LoadTVertex(ps,Cameras[i].Position);
    continue;
   end;//of if

   //Читаем контроллеры
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Cameras[i].TranslationGraphNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Cameras[i].TranslationGraphNum:=LoadController(ps,
                                   Cameras[i].TranslationGraphNum,3);
    inc(ps);
    continue;
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Cameras[i].RotationGraphNum:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Cameras[i].RotationGraphNum:=LoadController(ps,Cameras[i].RotationGraphNum,1);
    inc(ps);
    continue;
   end;//of if

   //Продолжаем чтение полей
   if copy(FileContent,ps,11)='fieldofview' then begin
    ps:=GoToCipher(ps);
    Cameras[i].FieldOfView:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,7)='farclip' then begin
    ps:=GoToCipher(ps);
    Cameras[i].FarClip:=GetFloat(FileContent,ps);
    continue;
   end;//of if
   if copy(FileContent,ps,8)='nearclip' then begin
    ps:=GoToCipher(ps);
    Cameras[i].NearClip:=GetFloat(FileContent,ps);
    continue;
   end;//of if

   //Целевой объект
   if copy(FileContent,ps,6)='target' then begin
    while FileContent[ps]<>'p' do inc(ps);//запись позиции
    LoadTVertex(ps,Cameras[i].TargetPosition);
    while (FileContent[ps]<>'}') and (FileContent[ps]<>'t') do inc(ps);
    if FileContent[ps]='t' then begin//чтение контроллера
     ps:=GoToCipher(ps);
     Cameras[i].TargetTGNum:=round(GetFloat(FileContent,ps));
     while FileContent[ps]<>'{' do inc(ps);
     Cameras[i].TargetTGNum:=LoadController(ps,Cameras[i].TargetTGNum,3);
     inc(ps);
     while FileContent[ps]<>'}' do inc(ps);
     inc(ps);
    end;//of if(Translation)
   end;//of if
   inc(ps);
  until false;                    //конец БЦ
  //Теперь - ищем следующий объект "камера"
  ps:=PosNext('camera ',FileContent,ps);
 until ps>=length(FileContent);
End;

procedure LoadCollisionShapes;
Var ps:cardinal;i,ii,k:integer;
Begin
 CountOfCollisionShapes:=0;       //пока их нет
 ps:=pos('collisionshape ',FileContent);
 if ps=0 then exit;               //нет объектов
 repeat
  inc(CountOfCollisionShapes);            //кол-во камер
  SetLength(Collisions,CountOfCollisionShapes);
  i:=CountOfCollisionShapes-1;            //счетчик цикла
  //инициализация
  InitTBone(Collisions[i].Skel);
  Collisions[i].objType:=cSphere;
  Collisions[i].CountOfVertices:=0;
  Collisions[i].BoundsRadius:=-1;
  //чтение имени
  while FileContent[ps]<>'"' do inc(ps);
  inc(ps);
  while FCont[ps]<>'"' do begin
   Collisions[i].Skel.Name:=Collisions[i].Skel.Name+FCont[ps];
   inc(ps);
  end;//of while
  repeat                          //основной цикл чтения
   while (FileContent[ps]<>'}') and (FileContent[ps]<>'o') and
         (FileContent[ps]<>'p') and (FileContent[ps]<>'b') and
         (FileContent[ps]<>'s') and (FileContent[ps]<>'v') and
         (FileContent[ps]<>'t') and (FileContent[ps]<>'r') do inc(ps);
   if FileContent[ps]='}' then break;//конец секции
   //Чтение стандартных полей
   if copy(FileContent,ps,8)='objectid' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.ObjectID:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (ObjectID)

   if copy(FileContent,ps,6)='parent' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.Parent:=round(GetFloat(FileContent,ps));
    continue;
   end;//of if (Parent)

   //Читаем тип объекта
   if copy(FileContent,ps,3)='box' then begin
    ps:=ps+3;
    Collisions[i].objType:=cBox;
    continue;
   end;//of if
   if copy(FileContent,ps,6)='sphere' then begin
    ps:=ps+6;
    Collisions[i].objType:=cSphere;
    continue;
   end;//of if

   //Чтение вершин
   if copy(FileContent,ps,8)='vertices' then begin
    ps:=GoToCipher(ps);
    Collisions[i].CountOfVertices:=round(GetFloat(FileContent,ps));
    SetLength(Collisions[i].Vertices,Collisions[i].CountOfVertices);
    ps:=PosNext('{',FileContent,ps);
    //Читаем весь список вершин
    for ii:=0 to Collisions[i].CountOfVertices-1 do for k:=1 to 3 do begin
     ps:=GoToCipher(ps);
     Collisions[i].Vertices[ii,k]:=GetFloat(FileContent,ps);
     ps:=PosNext(',',FileContent,ps);
    end;//of for ii
    while FileContent[ps]<>'}' do inc(ps);
    inc(ps);
    continue;
   end;//of if(Vertices)

   //Радиус
   if copy(FileContent,ps,12)='boundsradius' then begin
    ps:=GoToCipher(ps);
    Collisions[i].BoundsRadius:=GetFloat(FileContent,ps);
    continue;
   end;//of if

   //Контроллеры
   if copy(FileContent,ps,11)='translation' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.Translation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Collisions[i].Skel.Translation:=
     LoadController(ps,Collisions[i].Skel.Translation,3);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,8)='rotation' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.Rotation:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Collisions[i].Skel.Rotation:=
     LoadController(ps,Collisions[i].Skel.Rotation,4);
    inc(ps);
   end;//of if
   if copy(FileContent,ps,7)='scaling' then begin
    ps:=GoToCipher(ps);
    Collisions[i].Skel.Scaling:=round(GetFloat(FileContent,ps));
    while FileContent[ps]<>'{' do inc(ps);
    Collisions[i].Skel.Scaling:=LoadController(ps,Collisions[i].Skel.Scaling,3);
    inc(ps);
   end;//of if

   inc(ps);
  until false;                    //конец БЦ
  //Теперь - ищем следующий объект "камера"
  ps:=PosNext('collisionshape ',FileContent,ps);
 until ps>=length(FileContent);
End;
//----------------------------------------------------
//Читает иерархию (если есть), связанную с моделью.
//fname - имя файла модели.
//Если иерархия есть, IsWoW:=true
procedure ReadHierarchy(fname:string);
Var fh:file of integer;tmp:PChar;i:integer;
Begin
 fname[length(fname)]:='h';       //MDH
 //Проверяем, существут ли файл
 if SearchPath(nil,PChar(fname),nil,0,nil,tmp)=0 then exit;
 //Существует. Читаем.
 AssignFile(fh,fname);
 reset(fh);
// read(fh,i);
 for i:=0 to CountOfGeosets-1 do begin
  if EOF(fh) then begin
   IsWoW:=false;
   CloseFile(fh);
   exit;
  end;//of if
  read(fh,Geosets[i].HierID);
 end;//of for i
 CloseFile(fh);
 IsWoW:=true;
End;
//----------------------------------------------------
//Ищет в загруженной модели различные ошибки
//и пытается их исправить
procedure FixModel;
Var i,j,len:integer;
Begin
 //1. Глюк после обработки AnimTransfer:
 //если нет глобальных последовательностей, то не должно быть
 //и ссылок на них
 len:=High(Controllers);
 if CountOfGlobalSequences=0 then for i:=0 to len
 do if Controllers[i].GlobalSeqId>=0 then Controllers[i].GlobalSeqId:=-1;

 //2. Глюк с VertexGroup (когда индексы матриц выходят
 //за пределы массива Matrices).
 for j:=0 to CountOfGeosets-1 do for i:=0 to Geosets[j].CountOfVertices-1
 do if Geosets[j].VertexGroup[i]>=Geosets[j].CountOfMatrices
 then Geosets[j].VertexGroup[i]:=0;

 //3. Глюк с ненулевыми (оч. малыми) Alpha и проч. параметрами
 len:=High(Controllers);
 for j:=0 to len do for i:=0 to High(Controllers[j].Items) do
 with Controllers[j].Items[i] do begin
  if abs(Controllers[j].Items[i].Data[1])<1e-23 then Data[1]:=0;
  if abs(Controllers[j].Items[i].Data[2])<1e-23 then Data[2]:=0;
  if abs(Controllers[j].Items[i].Data[3])<1e-23 then Data[3]:=0;
  if abs(Controllers[j].Items[i].Data[4])<1e-23 then Data[4]:=0;
  if abs(Controllers[j].Items[i].Data[5])<1e-23 then Data[5]:=0;
 end;//of with/for i/j

 //4. Глюк с отрицательными GeosetId:
 for j:=0 to CountOfGeosetAnims-1 do if GeosetAnims[j].GeosetID<0
 then GeosetAnims[j].GeosetId:=0;

 //5. Глюк с отрицательными текстурами эмиттеров
 for i:=0 to CountOfParticleEmitters-1 do if pre2[i].TextureID<0
 then pre2[i].TextureID:=0;

 //Замедление вдвое всех анимаций
 //! Не забыть об увеличении длительности GlobalSeq.
{ for i:=0 to High(Controllers) do for j:=0 to High(Controllers[i].Items)
 do Controllers[i].Items[j].Frame:=Controllers[i].Items[j].Frame*2;
 for i:=0 to CountOfSequences-1 do begin
  Sequences[i].IntervalStart:=Sequences[i].IntervalStart*2;
  Sequences[i].IntervalEnd:=Sequences[i].IntervalEnd*2;
 end;//of for i}
End;

//Чтение информации из секции MdlVis
function MDLReadMdlVisInformation:boolean;
Var ps,ps2,len,i,ii,lng:cardinal;
Begin
 IsCanSaveMDVI:=true;             //теперь можно проводить запись

 //Ищем секцию MDLVisInformation
 //Если нет - выходим
 ps:=pos('mdlvisinformation',FileContent);
 if ps=0 then begin
  COMidNormals:=0;
  COConstNormals:=0;
  MidNormals:=nil;
  ConstNormals:=nil;
  IsWoW:=false;
  Result:=false;
  exit;
 end;

 //1. Пытаемся прочесть WoW-иерархию
 ps2:=PosNext('wowhierarchy',FileContent,ps);
 len:=length(FileContent);
 if ps2<len then begin
  IsWoW:=true;
  ps:=ps2;
  for i:=0 to CountOfGeosets-1 do begin
   ps:=GoToCipher(ps);
   Geosets[i].HierID:=round(GetFloat(FileContent,ps));
   ps:=PosNext(',',FileContent,ps);
  end;//of for i
 end;//of if

 //2. Пытаемся прочесть группы сглаживания
 ps2:=PosNext('smoothgroups ',FileContent,ps);
 if ps2<len then begin
  ps:=GoToCipher(ps2);
  COMidNormals:=round(GetFloat(FileContent,ps));
  SetLength(MidNormals,COMidNormals);
  for i:=0 to COMidNormals-1 do begin
   ps:=PosNext('sgroup ',FileContent,ps);
   ps:=GoToCipher(ps);
   lng:=round(GetFloat(FileContent,ps));
   SetLength(MidNormals[i],lng);
   ps:=PosNext('{',FileContent,ps);
   for ii:=0 to lng-1 do begin
    ps:=GoToCipher(ps);
    MidNormals[i,ii].GeoID:=round(GetFloat(FileContent,ps));
    ps:=PosNext(',',FileContent,ps);
    ps:=GoToCipher(ps);
    MidNormals[i,ii].VertID:=round(GetFloat(FileContent,ps));
    ps:=PosNext(',',FileContent,ps);
   end;//of for i
  end;//of for i
 end;//of if

 //3. Пытаемся прочесть изменённые нормали
 ps2:=PosNext('editednormals',FileContent,ps);
 if ps2<len then begin
  ps:=GoToCipher(ps2);
  COConstNormals:=round(GetFloat(FileContent,ps));
  SetLength(ConstNormals,COConstNormals);
  for i:=0 to COConstNormals-1 do begin
   ps:=PosNext('{',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].GeoId:=round(GetFloat(FileContent,ps));
   ps:=PosNext(',',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].VertId:=round(GetFloat(FileContent,ps));
   ps:=PosNext(',',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].n[1]:=GetFloat(FileContent,ps);
   ps:=PosNext(',',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].n[2]:=GetFloat(FileContent,ps);
   ps:=PosNext(',',FileContent,ps);
   ps:=GoToCipher(ps);
   ConstNormals[i].n[3]:=GetFloat(FileContent,ps);
  end;//of for i
 end;//of if
End;

//позволяет "вычленить" имя файла, убрав путь
function GetOnlyFileName(fname:string):string;
Var i:integer; s:string;
Begin
 s:='';
 for i:=length(fname) downto 0 do begin
  if (fname[i]='\') or (fname[i]='/') then break;
  insert(fname[i],s,1);
 end;//of for i
 Result:=s;
End;

//открывает файл mdl, извлекая нач. информацию
procedure OpenMDL(fname:string);
Var ps{,ps2}:cardinal;i,j:integer;IsFound:boolean;
Begin
 Controllers:=nil;
 IsWoW:=false;
 FileContent:='';   //пока информации нет
 FCont:='';         //то же самое
 assign(f,fname);
 reset(f,1);
 SetLength(FileContent,FileSize(f));
 BlockRead(f,FileContent[1],FileSize(f));
 //--------------------------------------------------------
 FCont:=FileContent;              //содержимое файла без искажения регистра
 FileContent:=lowercase(FileContent); //в нижний регистр
 close(f);

 //0. Грузим имя модели
 ps:=pos('model ',FileContent);   //позиция в файле
 ps:=ps+FindSym(@FileContent[ps],CODE_QM);
 ModelName:='';
 inc(ps);
 while FCont[ps]<>'"' do begin
  ModelName:=ModelName+FCont[ps];
  inc(ps);
 end;//of while

 //Парсинг: загрузка текстур
 {if CountOfTextures<>0 then} LoadTextures;
 //Парсинг: загрузка материалов
 LoadMaterials;
 LoadTextureAnims;                //загрузка текстурных анимаций
 //парсинг файла:
 //1. Читаем заголовок (что есть):
 CountOfGeosets:=round(ReadField('numgeosets '));
 if CountOfGeosets=0 then begin
  MessageBox(0,'Модель не содержит поверхностей,'#13#10+
               'эта версия редактора не поддреживает такой формат.'#13#10+
               '(Возможно, это - модель спецэффекта).',
               scError,mb_iconexclamation or mb_applmodal);
  exit;
 end;//of if
 CountOfGeosetAnims:=round(ReadField('numgeosetanims '));
 CountOfLights:=round(ReadField('numlights '));
 CountOfHelpers:=round(ReadField('numhelpers '));
 CountOfBones:=round(ReadField('numbones '));
// CountOfAttachments:=round(ReadField('numattachments '));
 CountOfParticleEmitters:=round(ReadField('numparticleemitters2 '));
 CountOfParticleEmitters1:=round(ReadField('numparticleemitters '));
 CountOfRibbonEmitters:=round(ReadField('numribbonemitters '));
 ps:=pos('model ',FileContent);
 CountOfEvents:=round(ReadField('numevents '));
 BlendTime:=round(ReadField('blendtime '));
 LoadAnimBounds(ps,AnimBounds);   //границы модели (заголовок)
 //Загрузка данных последовательностей
 LoadSeqData;
 LoadGlobalSequences;
 //2. Установить длину массива
 SetLength(Geosets,CountOfGeosets);//установить длину массива
 //3. Читать данные всех поверхностей
 CurGeoPos:=pos('geoset ',FileContent);
 i:=1;//CountOfGeosets:=1;
 While i<=CountOfGeosets do begin
  ReadGeoset(i);
  IsFound:=false;
  for j:=0 to 10 do if copy(FileContent,CurGeoPos+j,7)='geoset ' then begin
   IsFound:=true;
   CurGeoPos:=CurGeoPos+j;
   break;
  end;//of if/for j

  if not IsFound then begin
   CountOfGeosets:=i;SetLength(Geosets,CountOfGeosets);//установить длину массива
   break;
  end;//of if
  inc(i);
  if i=CountOfGeosets+1 then begin
   inc(CountOfGeosets);
   SetLength(Geosets,CountOfGeosets);
  end;//of if
 end;//of while

// ReadHierarchy(fname);
 //Чтение анимаций поверхностей
 ReadGeosetAnims;
 //чтение костей
 ReadBones;                       //кости
 LoadLights(ps);                  //чтение источников света
 ReadHelpers;                     //помощники
 LoadAttachments;                 //точки прикрепления
 //Чтение геом. центров
 LoadPivotPoints;
 //Чтение всех остальных объектов
 LoadParticleEmitters;            //источники частиц (старая версия)
 LoadParticleEmitters2;           //источники частиц (новая версия)
 LoadRibbonEmitters;              //источники следа
 LoadCameras;                     //камеры
 LoadEvents;                      //загрузка событий
 LoadCollisionShapes;             //загрузка объектов границ
 MDLReadMdlVisInformation;        //загрузка информации MdlVis

 FileContent:=''; //освободить память
 FCont:='';       //освободить память
 //Заполнить оставшиеся массивы
 SetLength(VisGeosets,CountOfGeosets);
 for i:=0 to CountOfGeosets-1 do VisGeosets[i]:=true;
 FixModel;                        //исправить модель
End;
//---------------------------------------------------------
//Небольшие процедуры для чтения элементов
function ReadLong:integer;
Var q:integer;
Begin
 move(pointer(pp)^,q,4);          //копируем
 pp:=pp+4;                        //сдвиг указателя
 ReadLong:=q;                     //вернуть число
End;

function ReadShort:integer;
Var q:word;
Begin
 move(pointer(pp)^,q,2);          //копируем
 pp:=pp+2;                        //сдвиг указателя
 ReadShort:=q;                     //вернуть число
End;

function ReadByte:integer;
Var q:byte;qi:integer;
Begin
 move(pointer(pp)^,q,1);          //копируем
 inc(pp);                         //сдвиг указателя
 qi:=q;
 ReadByte:=qi;                    //вернуть число
End;

function ReadFloat:single;
Var q:single;
Begin
 move(pointer(pp)^,q,4);          //копируем
 pp:=pp+4;                        //сдвиг указателя
 ReadFloat:=q;                    //вернуть число
End;

function ReadASCII(size:integer):string;
Var s:string;i,p2:integer;
    c:char;
Begin
 s:='';p2:=pp;
 for i:=1 to size do begin
  Move(pointer(pp)^,c,1);
  inc(pp);
  if c=#0 then break else s:=s+c;
 end;//of for
 ReadASCII:=s;
 pp:=p2+size;                     //исправить указатель
End;
//---------------------------------------------------------
//Читает заголовок MDX
procedure MDXReadHeader;
Var i:integer;
Begin
 pp:=pp+8;                        //пропуск тега MODL и размера
 ModelName:=ReadASCII($150);      //прочесть имя модели
 pp:=pp+4;                        //пропустить 0
 //Читаем границы
 AnimBounds.BoundsRadius:=ReadFloat;
 if floattostr(AnimBounds.BoundsRadius)='INF' then AnimBounds.BoundsRadius:=-1;
 for i:=1 to 3 do AnimBounds.MinimumExtent[i]:=ReadFloat;
 for i:=1 to 3 do AnimBounds.MaximumExtent[i]:=ReadFloat;
 //Время смешения
 BlendTime:=ReadLong;
End;
//---------------------------------------------------------
procedure MDXReadSequences;
Var i,ii,tmp,num:integer;
Const SizeOfSeq=$50+13*4;         //размер одной последовательности
Begin
// pp:=pp+4;                        //пропуск тега SEQS
 num:=ReadLong;                   //считать размер секции
 CountOfSequences:=num div SizeOfSeq; //определить кол-во последовательностей
 SetLength(Sequences,CountOfSequences);
 //Основной цикл чтения
 for i:=0 to CountOfSequences-1 do begin
  Sequences[i].Name:=ReadASCII($50);
  Sequences[i].IntervalStart:=ReadLong;
  Sequences[i].IntervalEnd:=ReadLong;
  Sequences[i].MoveSpeed:=round(ReadFloat); //!
  if Sequences[i].MoveSpeed=0 then Sequences[i].MoveSpeed:=-1;
  tmp:=ReadLong;
  if tmp=0 then Sequences[i].IsNonLooping:=false
           else Sequences[i].IsNonLooping:=true;
  Sequences[i].Rarity:=round(ReadFloat);       //!
  if Sequences[i].Rarity=0 then Sequences[i].Rarity:=-1;
  pp:=pp+4;                       //пропуск 0
  with Sequences[i].Bounds do begin
   BoundsRadius:=ReadFloat;
   if floattostr(BoundsRadius)='INF' then BoundsRadius:=-1;
   for ii:=1 to 3 do MinimumExtent[ii]:=ReadFloat;
   for ii:=1 to 3 do MaximumExtent[ii]:=ReadFloat;   
  end;//of with
 end;//of for i
End;
//---------------------------------------------------------
procedure MDXReadGlobalSeq;
Var i,num:integer;
Begin
 num:=ReadLong;
 CountOfGlobalSequences:=num shr 2;
 SetLength(GlobalSequences,CountOfGlobalSequences);
 for i:=0 to CountOfGlobalSequences-1 do GlobalSequences[i]:=ReadLong;
End;
//---------------------------------------------------------
//Вспомог.: читает контроллер
//Считывает контроллер с указанным тегом.
//Если попадается др. контроллер - ничего не происходит
//и возвращается true (static).
//Иначе возвращается false, в Result заносится номер контроллера.
function MDXReadController(tag,SizeOfElement:integer;IsStateLong:boolean;
                           var Rsult:integer):boolean;
Var tmp,CntNum,COF,i,ii:integer;
Begin
 //1. Проверим, тот ли контроллер найден
 tmp:=ReadLong;                   //читаем тег
 if tmp<>tag then begin           //не тот контроллер
  pp:=pp-4;                       //исправить указатель
  MDXReadController:=true;        //static
  exit;                           //выход
 end;//of if

 //2. Все в порядке. Работаем дальше.
 CntNum:=Length(Controllers);
 SetLength(Controllers,CntNum+1); //выделить память под контроллер
 Rsult:=CntNum;                   //результат
 Controllers[CntNum].SizeOfElement:=SizeOfElement;
 with Controllers[CntNum] do begin
  COF:=ReadLong;                  //кол-во кадров
  SetLength(items,COF);           //выделить память под кадры
  ContType:=ReadLong+1;           //тип контроллера
  GlobalSeqID:=ReadLong;
  //Теперь читаем кадры
  //цвета читаем в обратном порядке
{  if (tag=tagKGAC) or (tag=tagKLAC) or
     (tag=tagKLBC) or (tag=tagKRCO) then begin
   for i:=0 to COF-1 do begin
    items[i].Frame:=ReadLong;      //читаем
    for ii:=SizeOfElement downto 1 do if IsStateLong then items[i].Data[ii]:=ReadLong
                                             else items[i].Data[ii]:=ReadFloat;
    if (ContType=Bezier) or (ContType=Hermite) then begin
     for ii:=SizeOfElement downto 1 do items[i].InTan[ii]:=ReadFloat;
     for ii:=SizeOfElement downto 1 do items[i].OutTan[ii]:=ReadFloat;
    end;//of if (ContType)
   end;//of for i
  end else begin}
   for i:=0 to COF-1 do begin
    items[i].Frame:=ReadLong;      //читаем
    for ii:=1 to SizeOfElement do if IsStateLong then items[i].Data[ii]:=ReadLong
                                             else items[i].Data[ii]:=ReadFloat;
    if (ContType=Bezier) or (ContType=Hermite) then begin
     for ii:=1 to SizeOfElement do items[i].InTan[ii]:=ReadFloat;
     for ii:=1 to SizeOfElement do items[i].OutTan[ii]:=ReadFloat;
    end;//of if (ContType)
   end;//of for i
{  end;//of if(CGAC)}
 end;//of with

 MDXReadController:=false;        //Вернуть результат
End;
//---------------------------------------------------------
//Вспомог.: чтение указанного слоя
procedure MDXReadLayer(var l:TLayer);
Var tmp:integer;
Begin
 pp:=pp+4;                        //пропуск размера
 tmp:=ReadLong;                   //чтение типа смешения
 case tmp of                      //его анализ
  0:l.FilterMode:=Opaque;
  1:l.FilterMode:=ColorAlpha;
  2:l.FilterMode:=FullAlpha;
  3:l.FilterMode:=Additive;
  4:l.FilterMode:=AddAlpha;
  5:l.FilterMode:=Modulate;
  else l.FilterMode:=Modulate2X;
 end;//of case

 //Читать флаги
 tmp:=ReadLong;
 if (tmp and 1)<>0 then l.IsUnshaded:=true
                   else l.IsUnshaded:=false;
 if (tmp and 2)<>0 then l.IsSphereEnvMap:=true
                   else l.IsSphereEnvMap:=false;
 if (tmp and 16)<>0 then l.IsTwoSided:=true
                    else l.IsTwoSided:=false;
 if (tmp and 32)<>0 then l.IsUnfogged:=true
                    else l.IsUnfogged:=false;
 if (tmp and 64)<>0 then l.IsNoDepthTest:=true
                    else l.IsNoDepthTest:=false;
 if (tmp and 128)<>0 then l.IsNoDepthSet:=true
                     else l.IsNoDepthSet:=false;
 //Читаем поле текстуры
 l.TextureID:=ReadLong;
// l.TextureID:=l.TextureID and ($FFFFFFFF-128-64-32);
 //Читаем далее
 l.TVertexAnimID:=ReadLong;
 l.CoordID:=ReadLong;
 if l.CoordID=0 then l.CoordID:=-1;
 l.Alpha:=ReadFloat;if l.Alpha=1 then l.Alpha:=-1;

 //Читаем контроллеры и статичность
 l.NumOfGraph:=-1;l.NumOfTexGraph:=-1;
 l.IsAlphaStatic:=MDXReadController(tagKMTA,1,false,l.NumOfGraph);
 l.IsTextureStatic:=MDXReadController(tagKMTF,1,true,l.NumOfTexGraph);
End;
//---------------------------------------------------------
//Чтение материалов
procedure MDXReadMaterials;
Var tmp,pEnd,i:integer;
Begin
 CountOfMaterials:=0;
 tmp:=ReadLong;                   //читать размер секции
 pEnd:=pp+tmp;                    //вычислить посл. байт
 repeat                           //основной цикл чтения
  inc(CountOfMaterials);
  SetLength(Materials,CountOfMaterials);
  with Materials[CountOfMaterials-1] do begin
   ListNum:=-1;
   pp:=pp+4;                      //пропуск размера структуры
   PriorityPlane:=ReadLong;
   if PriorityPlane=0 then PriorityPlane:=-1;
   //Читаем флаги материала
   tmp:=ReadLong;
   if (tmp and 1)<>0 then IsConstantColor:=true
                     else IsConstantColor:=false;
   if (tmp and 16)<>0 then IsSortPrimsFarZ:=true
                      else IsSortPrimsFarZ:=false;
   if (tmp and 32)<>0 then IsFullResolution:=true
                      else IsFullResolution:=false;
   //Читаем структуру LAYS (слои)
   pp:=pp+4;                      //пропуск тега LAYS
   CountOfLayers:=ReadLong;       //кол-во слоев
   SetLength(Layers,CountOfLayers);//выделить память под слои
   for i:=0 to CountOfLayers-1 do MDXReadLayer(Layers[i]);
  end;//of with
//  Materials[CountOfMaterials-1]
 until pp>=pEnd;
End;
//---------------------------------------------------------
//Читает список текстур
procedure MDXReadTextures;
Const TEXSize=$100+3*4;
Var tmp,i:integer;
Begin
 tmp:=ReadLong;                   //читать размер секции
 CountOfTextures:=tmp div TEXSize;//вычислить кол-во текстур
 SetLength(Textures,CountOfTextures);
 for i:=0 to CountOfTextures-1 do begin
  FillChar(Textures[i],SizeOf(TTexture),0);
  Textures[i].ReplaceableID:=ReadLong;
  Textures[i].FileName:=ReadASCII($100);
  pp:=pp+4;                       //пропуск 0
  //Читаем флаги
  tmp:=ReadLong;
  if (tmp and 1)<>0 then Textures[i].IsWrapWidth:=true
                    else Textures[i].IsWrapWidth:=false;
  if (tmp and 2)<>0 then Textures[i].IsWrapHeight:=true
                    else Textures[i].IsWrapHeight:=false;
 end;
End;
//---------------------------------------------------------
//чтение текстурных анимаций
procedure MDXReadTexAnims;
Var pEnd:integer;
Begin
 pEnd:=pp+ReadLong;               //находим конец секции
 CountOfTextureAnims:=0;
 repeat                           //основной цикл чтения
  inc(CountOfTextureAnims);
  SetLength(TextureAnims,CountOfTextureAnims);
  pp:=pp+4;                       //пропуск размера
  with TextureAnims[CountOfTextureAnims-1] do begin
   TranslationGraphNum:=-1;
   RotationGraphNum:=-1;
   ScalingGraphNum:=-1;
   MDXReadController(tagKTAT,3,false,TranslationGraphNum);
   MDXReadController(tagKTAR,4,false,RotationGraphNum);
   MDXReadController(tagKTAS,3,false,ScalingGraphNum);
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//Читает поверхности модели
procedure MDXReadGeosets;
Var pEnd,j,i,ii,tmp:integer;
Begin
 pEnd:=pp+ReadLong;               //вычислить конец секции
 CountOfGeosets:=0;
 repeat                           //основной цикл чтения
  inc(CountOfGeosets);
  SetLength(Geosets,CountOfGeosets);
  pp:=pp+4;                       //пропуск размера
  //1. Читаем список вершин
  pp:=pp+4;                       //пропуск тега VRTX
  with Geosets[CountOfGeosets-1] do begin
   CountOfVertices:=ReadLong;     //читаем кол-во точек
   SetLength(Vertices,CountOfVertices);
   for i:=0 to CountOfVertices-1 do for ii:=1 to 3 do Vertices[i,ii]:=ReadFloat;

   //2. Читаем список нормалей
   pp:=pp+4;                      //пропуск тега NRMS
   CountOfNormals:=ReadLong;     //читаем кол-во точек
   SetLength(Normals,CountOfNormals);
   for i:=0 to CountOfNormals-1 do for ii:=1 to 3 do Normals[i,ii]:=ReadFloat;

   //3. Пропускаем тип примитива (он один и тот же)
   pp:=pp+4;                      //пропуск тега PTYP
   tmp:=ReadLong;                 //кол-во типов
   pp:=pp+4*tmp;                  //пропуск записей
   pp:=pp+4;                      //пропуск тега PCNT
   tmp:=ReadLong;                 //кол-во записей
   pp:=pp+4*tmp;                  //пропуск

   //4. Читаем всю кучу треугольников:
   pp:=pp+4;                      //пропуск тега PVTX
   SetLength(Faces,1);            //всего 1 группа
   CountOfFaces:=1;
   tmp:=ReadLong;                 //кол-во точек
   SetLength(Faces[0],tmp);       //выделить память
   for i:=0 to tmp-1 do Faces[0,i]:=ReadShort;

   //5. Читаем список номеров групп (VertexGroup)
   pp:=pp+4;                      //пропуск тега GNDX
   tmp:=ReadLong;                 //читаем кол-во групп
   SetLength(VertexGroup,tmp);
   for i:=0 to tmp-1 do VertexGroup[i]:=ReadByte;
   SetLength(VertexGroup,CountOfVertices);

   //6. Читаем массив длин групп
   pp:=pp+4;                      //пропуск тега MTGC
   CountOfMatrices:=ReadLong;
   SetLength(Groups,CountOfMatrices);
   //Теперь установим длины каждой матрицы:
   for i:=0 to CountOfMatrices-1 do begin
    tmp:=ReadLong;                //читать длину
    SetLength(Groups[i],tmp);     //установить ее
   end;//of for i

   //7. Чтение самих матриц
   pp:=pp+8;                      //пропуск тега MATS и длины
   for i:=0 to CountOfMatrices-1 do for ii:=0 to length(Groups[i])-1 do begin
    Groups[i,ii]:=ReadLong;
   end;//of for i

   //8. Чтение ряда полей
   MaterialID:=ReadLong;
   SelectionGroup:=ReadLong;
   tmp:=ReadLong;
   if tmp=4 then Unselectable:=true else Unselectable:=false;

   //9. Чтение границ
   BoundsRadius:=ReadFloat;
   if floattostr(BoundsRadius)='INF' then BoundsRadius:=-1;
   for i:=1 to 3 do MinimumExtent[i]:=ReadFloat;
   for i:=1 to 3 do MaximumExtent[i]:=ReadFloat;
   //10. Чтение границ анимаций (Anim)
   CountOfAnims:=ReadLong;
   SetLength(Anims,CountOfAnims);
   for i:=0 to CountOfAnims-1 do with Anims[i] do begin
    BoundsRadius:=ReadFloat;      
//    MessageBox(0,PChar(floattostr(BoundsRadius)),'',0);
    if floattostr(BoundsRadius)='0' then BoundsRadius:=-1;
    for ii:=1 to 3 do MinimumExtent[ii]:=ReadFloat;
    for ii:=1 to 3 do MaximumExtent[ii]:=ReadFloat;
   end;//of for i
            
   //11. Чтение секции TVertices (текстурные вершины)
   //11a. Чтение UVBA - кол-во координатных секций
   pp:=pp+4;                      //пропуск тега
   CountOfCoords:=ReadLong;       //считать кол-во
   SetLength(Crds,CountOfCoords);
   //11b. Чтение каждой такой секции
   for j:=0 to CountOfCoords-1 do with Crds[j] do begin
    pp:=pp+2*4;                    //пропуск всех тегов и длин
    CountOfTVertices:=CountOfVertices;
    SetLength(TVertices,CountOfTVertices);
    for i:=0 to CountOfTVertices-1 do begin
     TVertices[i,1]:=ReadFloat;
     TVertices[i,2]:=ReadFloat;
    end;//of for i
   end;//of for j

  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//Читать цветовые анимации поверхностей
procedure MDXReadGeosetAnims;
Var pEnd,tmp:integer;
Begin
 pEnd:=pp+ReadLong;               //определить конец секции
 CountOfGeosetAnims:=0;
 repeat                           //основной цикл чтения
  inc(CountOfGeosetAnims);
  SetLength(GeosetAnims,CountOfGeosetAnims);
  with GeosetAnims[CountOfGeosetAnims-1] do begin
   pp:=pp+4;                      //пропуск размера
   Alpha:=ReadFloat;              //прозрачность
   //Читаем флаги
   tmp:=ReadLong;
   if (tmp and 1)<>0 then IsDropShadow:=true
                     else IsDropShadow:=false;
   if (tmp and 2)<>0 then begin   //присутствует цвет
    Color[3]:=ReadFloat;          //Обратный порядок!
    Color[2]:=ReadFloat;
    Color[1]:=ReadFloat;
   end else begin                 //цвет отсутствует!
    Color[1]:=-1;Color[2]:=-1;Color[3]:=-1;
    pp:=pp+3*4;                   //пропуск цвета
    IsColorStatic:=true;
   end;//of if

   GeosetID:=ReadLong;
   IsAlphaStatic:=MDXReadController(TagKGAO,1,false,AlphaGraphNum);
   IsColorStatic:=MDXReadController(TagKGAC,3,false,ColorGraphNum);
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//Вспомогательная: чтение объекта
//Возвращает все параметры обхъекта
{procedure MDXReadOBJ(Var name:string;Var ObjectID,Parent:integer;
                     Var IsDITranslation,IsDIRotation,IsDIScaling,
                     IsBillboarded,IsBillboardedLockX,
                     IsBillboardedLockY,IsBillboardedLockZ,
                     IsCameraAnchored:boolean;var t,r,s,v:integer);}
procedure MDXReadOBJ(var b:TBone);                     
Var tmp:integer;
Begin with b do begin
 InitTBone(b);                    //инициализация
 pp:=pp+4;                        //пропуск размера
 name:=ReadASCII($50);            //имя
 ObjectID:=ReadLong;              //ID объекта
 Parent:=ReadLong;                //ID родителя
 //Читаем тип (он не нужен) и флаги:
 tmp:=ReadLong;
 if (tmp and 1)<>0 then IsDITranslation:=true
                   else IsDITranslation:=false;
 if (tmp and 2)<>0 then IsDIScaling:=true
                   else ISDIScaling:=false;
 if (tmp and 4)<>0 then IsDIRotation:=true
                   else IsDIRotation:=false;
 if (tmp and 8)<>0 then IsBillboarded:=true
                   else IsBillboarded:=false;
 if (tmp and 16)<>0 then IsBillboardedLockX:=true
                    else IsBillboardedLockX:=false;
 if (tmp and 32)<>0 then IsBillboardedLockY:=true
                    else IsBillboardedLockY:=false;
 if (tmp and 64)<>0 then IsBillboardedLockZ:=true
                    else IsBillboardedLockZ:=false;
 if (tmp and 128)<>0 then IsCameraAnchored:=true
                     else IsCameraAnchored:=false;
 //Теперь контроллеры
// Rotation:=-1;Translation:=-1;Scaling:=-1;Visibility:=-1;
 MDXReadController(tagKGTR,3,false,Translation);
 MDXReadController(tagKGRT,4,false,Rotation);
 MDXReadController(tagKGSC,3,false,Scaling);
 MDXReadController(tagKATV,1,false,Visibility);
end;End;
//---------------------------------------------------------
//Чтение костей
procedure MDXReadBones;
Var pEnd:integer;
Begin
 pEnd:=pp+ReadLong;               //вычислить конец секции
 CountOfBones:=0;
 repeat                           //цикл чтения
  inc(CountOfBones);
  SetLength(Bones,CountOfBones);
  with Bones[CountOfBones-1] do begin
   //Читаем OBJ
   MDXReadObj(Bones[CountOfBones-1]);
   //Остаточные поля
   GeosetID:=ReadLong;if GeosetID=-1 then GeosetID:=-3;
   GeosetAnimID:=ReadLong;if GeosetAnimID=-1 then GeosetAnimID:=-2;
  end;//of with
 until pp>=pEnd;
 //В случае единственного объекта прописать ObjectID=0
 if (CountOfBones=1) and (Bones[0].ObjectID<0) then Bones[0].ObjectID:=0;
End;
//---------------------------------------------------------
//Чтение источников света
procedure MDXReadLights;
Var pEnd,tmp,i:integer;
Begin
 pEnd:=pp+ReadLong;
 CountOfLights:=0;
 repeat
  inc(CountOfLights);
  SetLength(Lights,CountOfLights);
  with Lights[CountOfLights-1] do begin
   pp:=pp+4;                      //пропуск размера
   MDXReadObj(Skel);
   //Читаем тип источника света
   LightType:=ReadLong+1;         //читаем тип источника
   AttenuationStart:=ReadFloat;
   AttenuationEnd:=ReadFloat;

   //Читаем цвет
   for i:=3 downto 1 do Color[i]:=ReadFloat;
   Intensity:=ReadFloat;
   for i:=3 downto 1 do AmbColor[i]:=ReadFloat;
   AmbIntensity:=ReadFloat;

   //Установка static-полей
{   IsASStatic:=true;
   IsAEStatic:=true;}
   //Читаем набор контроллеров
   IsASStatic:=MDXReadController(tagKLAS,1,false,tmp);
   if not IsASStatic then AttenuationStart:=tmp;
   IsAEStatic:=MDXReadController(tagKLAE,1,false,tmp);
   if not IsAEStatic then AttenuationEnd:=tmp;

   IsIStatic:=MDXReadController(tagKLAI,1,false,tmp);
   if not IsIStatic then Intensity:=tmp;
   MDXReadController(tagKLAV,1,false,Skel.Visibility);
   IsCStatic:=MDXReadController(tagKLAC,3,false,tmp);
   if not IsCStatic then Color[1]:=tmp;
   IsACStatic:=MDXReadController(tagKLBC,3,false,tmp);
   if not IsACStatic then AmbColor[1]:=tmp;
   IsAIStatic:=MDXReadController(tagKLBI,1,false,tmp);
   if not IsAIStatic then AmbIntensity:=tmp;
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//Чтение помощников
procedure MDXReadHelpers;
Var pEnd:integer;
Begin
 pEnd:=pp+ReadLong;               //конец секции
 CountOfHelpers:=0;
 repeat
  inc(CountOfHelpers);
  SetLength(Helpers,CountOfHelpers);
  with Helpers[CountOfHelpers-1] do begin
   //Читаем OBJ
   MDXReadObj(Helpers[CountOfHelpers-1]);
   GeosetID:=-1;
   GeosetAnimID:=-1;
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//Читает точеи прикрепления
procedure MDXReadAttachments;
Var pEnd{,tmp}:integer;
Begin
 pEnd:=pp+ReadLong;
 CountOfAttachments:=0;
 repeat
  inc(CountOfAttachments);
  SetLength(Attachments,CountOfAttachments);
  with Attachments[CountOfAttachments-1] do begin
   pp:=pp+4;                      //пропуск размера
   MDXReadObj(Skel);
   Path:=ReadASCII($100);
   pp:=pp+4;                      //пропуск 0
   AttachmentID:=ReadLong;

   //Читаем контроллер видимости
   MdxReadController(TagKATV,1,false,Skel.Visibility);
  end;//of with
 until pp>=pEnd;   
End;
//---------------------------------------------------------
//Загрузка геометрических центров
procedure MDXReadPivotPoints;
Var i,ii:integer;
Const PivSize=4*3;
Begin
 CountOfPivotPoints:=ReadLong div PivSize; //кол-во точек
 SetLength(PivotPoints,CountOfPivotPoints);
 for i:=0 to CountOfPivotPoints-1 do
     for ii:=1 to 3 do PivotPoints[i,ii]:=ReadFloat;
End;
//---------------------------------------------------------
//Читает источники частиц старой версии
//! не тестировалась
procedure MDXReadParticleEmitters1;
Var pEnd,tmp:integer;
Begin
 pEnd:=pp+ReadLong;               //конец секции
 if pEnd=pp then exit;
 CountOfParticleEmitters1:=0;
 repeat
  inc(CountOfParticleEmitters1);
  SetLength(ParticleEmitters1,CountOfParticleEmitters1);
  with ParticleEmitters1[CountOfParticleEmitters1-1] do begin
   pp:=pp+2*4;                    //пропуск размеров
   Skel.Name:=ReadASCII($50);     //читать имя
   Skel.ObjectID:=ReadLong;
   Skel.Parent:=ReadLong;
   //Читаем флаги
   tmp:=ReadLong;
   if (tmp and $8000)<>0 then UsesType:=EmitterUsesMDL;
   if (tmp and $10000)<>0 then UsesType:=EmitterUsesTGA;

   //Читаем контроллеры
{   Skel.Translation:=-1;
   Skel.Rotation:=-1;
   Skel.Scaling:=-1;}
   InitTBone(Skel);
   MDXReadController(TagKGTR,3,false,Skel.Translation);
   MDXReadController(TagKGRT,4,false,Skel.Rotation);
   MDXReadController(TagKGSC,3,false,Skel.Scaling);

   //Статические параметры
   IsERStatic:=true;
   IsGStatic:=true;
   IsLongStatic:=true;
   IsLatStatic:=true;
   IsLSStatic:=true;
   IsIVStatic:=true;
   //Продолжаем чтение
   EmissionRate:=ReadFloat;
   Gravity:=ReadFloat;
   Longitude:=ReadFloat;
   Latitude:=ReadFloat;
   Path:=ReadASCII($100);
   pp:=pp+4;                      //пропуск 0
   LifeSpan:=ReadFloat;
   InitVelocity:=ReadFloat;
   //Читаем контроллеры
   IsERStatic:=MDXReadController(tagKPEE,1,false,tmp);
   if not IsERStatic then EmissionRate:=tmp;
   IsGStatic:=MDXReadController(tagKPEG,1,false,tmp);
   if not IsGStatic then Gravity:=tmp;
   IsLongStatic:=MDXReadController(tagKPLN,1,false,tmp);
   if not IsLongStatic then Longitude:=tmp;
   IsLatStatic:=MDXReadController(tagKPLT,1,false,tmp);
   if not IsLatStatic then Latitude:=tmp;
   IsLSStatic:=MDXReadController(tagKPEL,1,false,tmp);
   if not IsLSStatic then LifeSpan:=tmp;
   IsIVStatic:=MDXReadController(tagKPES,1,false,tmp);
   if not IsIVStatic then InitVelocity:=tmp;

   MDXReadController(TagKPEV,1,false,Skel.Visibility);
  end;//of with
 until pp>=pEnd;    
End;
//---------------------------------------------------------
//Чтение "продвинутых" источников частиц
procedure MDXReadParticleEmitters2;
Var pEnd,tmp,OldPP,i,ii:integer;bTmp:boolean;
Begin
 pEnd:=pp+ReadLong;
 CountOfParticleEmitters:=0;
 repeat                           //цикл чтения
  inc(CountOfParticleEmitters);
  SetLength(pre2,CountOfParticleEmitters);
  with pre2[CountOfParticleEmitters-1] do begin
   pp:=pp+2*4;                    //пропуск размеров
   //инициализация:
   InitTBone(Skel);
{   TranslationGraphNum:=-1;
   RotationGraphNum:=-1;
   ScalingGraphNum:=-1;
   VisibilityGraphNum:=-1;}
   Skel.Name:=ReadASCII($50);
   Skel.ObjectID:=ReadLong;
   Skel.Parent:=ReadLong;
   //Читаем флаги
   tmp:=ReadLong;
   if (tmp and 1)<>0 then Skel.IsDITranslation:=true
                     else Skel.IsDITranslation:=false;
   if (tmp and $2)<>0 then Skel.IsDIScaling:=true
                      else Skel.ISDIScaling:=false;
   if (tmp and $4)<>0 then Skel.IsDIRotation:=true
                      else Skel.IsDIRotation:=false;
   if (tmp and $8000)<>0 then IsUnshaded:=true
                         else IsUnshaded:=false;
   if (tmp and $100000)<>0 then IsXYQuad:=true
                           else IsXYQuad:=false;
   if (tmp and $80000)<>0 then IsModelSpace:=true
                          else IsModelSpace:=false;
   if (tmp and $40000)<>0 then IsUnfogged:=true
                          else IsUnfogged:=false;
   if (tmp and $20000)<>0 then IsLineEmitter:=true
                          else IsLineEmitter:=false;
   if (tmp and $10000)<>0 then IsSortPrimsFarZ:=true
                          else IsSortPrimsFarZ:=false;

   //Набор контроллеров
   MDXReadController(TagKGTR,3,false,Skel.Translation);
   MDXReadController(TagKGRT,4,false,Skel.Rotation);
   MDXReadController(TagKGSC,3,false,Skel.Scaling);

   //Продолжаем чтение полей
   Speed:=ReadFloat;
   Variation:=ReadFloat;
   Latitude:=ReadFloat;
   Gravity:=ReadFloat;
   Lifespan:=ReadFloat;
   EmissionRate:=ReadFloat;
   Length:=ReadFloat;
   Width:=ReadFloat;
   //Чтение фильтров и режима
   tmp:=ReadLong;
   BlendMode:=FullAlpha;
   if tmp=0 then BlendMode:=FullAlpha;
   if tmp=1 then BlendMode:=Additive;
   if tmp=2 then BlendMode:=Modulate;
   if tmp=4 then BlendMode:=AlphaKey;
   Rows:=ReadLong;
   Columns:=ReadLong;

   ParticleType:=ReadLong;
   TailLength:=ReadFloat;
   Time:=ReadFloat;
   //Чтение цвета сегмента
   for i:=1 to 3 do for ii:=3 downto 1 do SegmentColor[i,ii]:=ReadFloat;
   //Чтение прозрачности
   for i:=1 to 3 do Alpha[i]:=ReadByte;
   //Масштабные множители
   for i:=1 to 3 do ParticleScaling[i]:=ReadFloat;
   //Набор параметров (по тройкам)
   for i:=1 to 3 do LifeSpanUVAnim[i]:=ReadLong;
   for i:=1 to 3 do DecayUVAnim[i]:=ReadLong;
   for i:=1 to 3 do TailUVAnim[i]:=ReadLong;
   for i:=1 to 3 do TailDecayUVAnim[i]:=ReadLong;

   //Еще поля
   TextureID:=ReadLong;
   tmp:=ReadLong;if tmp=1 then IsSquirt:=true
                          else IsSquirt:=false;
   PriorityPlane:=ReadLong;
   if PriorityPlane=0 then PriorityPlane:=-1;
   ReplaceableID:=ReadLong;

   //Теперь - заключительный набор контроллеров
   IsVStatic:=true; IsLStatic:=true; IsGStatic:=true;
   IsEStatic:=true; IsSStatic:=true; IsHStatic:=true;
   IsWStatic:=true;
   repeat
    oldPP:=pp;
    if not MDXReadController(tagKP2R,1,false,tmp) then begin
     IsVStatic:=false;
     Variation:=tmp;
    end;//of if
    if not MDXReadController(tagKP2L,1,false,tmp) then begin
     IsLStatic:=false;
     Latitude:=tmp;     
    end;//of if
    if not MDXReadController(tagKP2G,1,false,tmp) then begin
     IsGStatic:=false;
     Gravity:=tmp;
    end;//of if

    MDXReadController(tagKP2V,1,false,Skel.Visibility);

    if not MDXReadController(tagKP2E,1,false,tmp) then begin
     IsEStatic:=false;
     EmissionRate:=tmp;
    end;//of if
    if not MDXReadController(tagKP2S,1,false,tmp) then begin
     IsSStatic:=false;
     Speed:=tmp;
    end;//of if
    if not MDXReadController(tagKP2N,1,false,tmp) then begin
     IsHStatic:=false;
     Length:=tmp;
    end;//of if
    if not MDXReadController(tagKP2W,1,false,tmp) then begin
     IsWStatic:=false;
     Width:=tmp;
    end;//of if
   until pp=oldPP;
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//Чтение источников следа
procedure MDXReadRibbonEmitters;
Var pEnd,tmp,i:integer;
Begin
 pEnd:=pp+ReadLong;
 CountOfRibbonEmitters:=0;
 repeat
  inc(CountOfRibbonEmitters);
  SetLength(ribs,CountOfRibbonEmitters);
  with ribs[CountOfRibbonEmitters-1] do begin
   pp:=pp+2*4;                    //пропуск размера
   InitTBone(Skel);
{   TranslationGraphNum:=-1;
   RotationGraphNum:=-1;
   ScalingGraphNum:=-1;
   VisibilityGraphNum:=-1;}
   Skel.Name:=ReadASCII($50);
   Skel.ObjectID:=ReadLong;
   Skel.Parent:=ReadLong;
   pp:=pp+4;                      //пропуск поля
   //Набор контроллеров
   MDXReadController(TagKGTR,3,false,Skel.Translation);
   MDXReadController(TagKGRT,4,false,Skel.Rotation);
   MDXReadController(TagKGSC,3,false,Skel.Scaling);
   //поля
   HeightAbove:=ReadFloat;
   HeightBelow:=ReadFloat;
   Alpha:=ReadFloat;
   for i:=3 downto 1 do Color[i]:=ReadFloat;
   LifeSpan:=ReadFloat;
   TextureSlot:=ReadLong;
   EmissionRate:=ReadLong;
   Rows:=ReadLong;
   Columns:=ReadLong;
   MaterialID:=ReadLong;
   Gravity:=ReadFloat;

   //Теперь - специфические контроллеры
   IsTSStatic:=true; //тут есть сложность...
   IsHAStatic:=MDXReadController(tagKRHA,1,false,tmp);
   if not IsHAStatic then HeightAbove:=tmp;
   IsHBStatic:=MDXReadController(tagKRHB,1,false,tmp);
   if not IsHBStatic then HeightBelow:=tmp;
   IsAlphaStatic:=MDXReadController(tagKRAL,1,false,tmp);
   if not IsAlphaStatic then Alpha:=tmp;
   IsColorStatic:=MDXReadController(tagKRCO,3,false,tmp);
   if not IsColorStatic then Color[1]:=tmp;
   //контроллер видимости
   MDXReadController(tagKRVS,1,false,Skel.Visibility);
  end;//of with
 until pp>=pEnd;    
End;
//---------------------------------------------------------
//Загружает список камер
procedure MDXReadCameras;
Var pEnd,i:integer;
Begin
 pEnd:=pp+ReadLong;
 CountOfCameras:=0;
 repeat
  inc(CountOfCameras);
  SetLength(Cameras,CountOfCameras);
  with Cameras[CountOfCameras-1] do begin
   pp:=pp+4;                      //пропуск размера
   Name:=ReadASCII($50);
   for i:=1 to 3 do Position[i]:=ReadFloat;
   FieldOfView:=ReadFloat;
   FarClip:=ReadFloat;
   NearClip:=ReadFloat;
   //Считываем цель
   for i:=1 to 3 do TargetPosition[i]:=ReadFloat;
   TargetTGNum:=-1;
   RotationGraphNum:=-1;
   TranslationGraphNum:=-1;
   MDXReadController(tagKCTR,3,false,TargetTGNum);
   //Список контроллеров
   MDXReadController(tagKCRL,1,false,RotationGraphNum);
   MDXReadController(tagKTTR,3,false,TranslationGraphNum);
  end;//of with
 until pp>=pEnd;  
End;
//---------------------------------------------------------
//Чтение событий
procedure MDXReadEvents;
Var pEnd{,tmp},i:integer;//bN:boolean;
Begin
 pEnd:=pp+ReadLong;
 CountOfEvents:=0;
 repeat
  inc(CountOfEvents);
  SetLength(Events,CountOfEvents);
  with Events[CountOfEvents-1] do begin
//   bN:=true;//tmp:=0;
   MDXReadOBJ(Skel);
   pp:=pp+4;                      //пропуск KEVT
   CountOfTracks:=ReadLong;
   SetLength(Tracks,CountOfTracks);
   pp:=pp+4;                      //пропуск (-1)
   for i:=0 to CountOfTracks-1 do Tracks[i]:=ReadLong;
  end;//of with
 until pp>=pEnd; 
End;
//---------------------------------------------------------
//Чтение объектов границ
procedure MDXReadCollisionObjects;
Var pEnd,tmp,i,ii:integer;//bN:boolean;
Begin
 pEnd:=pp+ReadLong;
 CountOfCollisionShapes:=0;
 repeat
  inc(CountOfCollisionShapes);
  SetLength(Collisions,CountOfCollisionShapes);
  with Collisions[CountOfCollisionShapes-1] do begin
{   TranslationGraphNum:=-1;
   RotationGraphNum:=-1;
   ScalingGraphNum:=-1;
   bN:=false;
   tmp:=0;}
   MDXReadOBJ(Skel);
   //Читаем форму объекта (тип)           
   tmp:=ReadLong;
   objType:=cSphere;
   if tmp=0 then objType:=cBox;
   if tmp=2 then objType:=cSphere;
   //Считываем данные объекта
   if objType=cBox then begin
    CountOfVertices:=2;
    SetLength(Vertices,CountOfVertices);
    for i:=0 to 1 do for ii:=1 to 3 do Vertices[i,ii]:=ReadFloat;
   end else begin
    CountOfVertices:=1;
    SetLength(Vertices,CountOfVertices);
    for ii:=1 to 3 do Vertices[0,ii]:=ReadFloat;
    BoundsRadius:=ReadFloat;
    if floattostr(BoundsRadius)='INF' then BoundsRadius:=-1;
   end;//of if
  end;//of with
 until pp>=pEnd;
End;
//---------------------------------------------------------
//Осуществляет загрузку секции с информацией MdlVis.
//Если таковая не найдена, возвр. false
//и параметры устанавливаются как для пустой секции
function MDXReadMdlVisInformation:boolean;
Var tmp,i,ii,len:integer;
Begin
 IsCanSaveMDVI:=true;             //теперь можно проводить запись
 pp:=pp-4;                        //переходим к тегу
 //Читаем тег. Если нет инф. секции - выходим
 if ReadLong<>tagMDVI then begin
  COMidNormals:=0;
  COConstNormals:=0;
  MidNormals:=nil;
  ConstNormals:=nil;
  IsWoW:=false;
  Result:=false;
  exit;
 end;

 //пропускаем поле длины
 pp:=pp+4;
 //Читаем секцию WoW-иерархии (если есть)
 tmp:=ReadLong;
 if tmp=tagiWoW then begin
  IsWoW:=true;
  for i:=0 to CountOfGeosets-1 do Geosets[i].HierID:=ReadLong;
  tmp:=ReadLong;
 end;//of if

 //Читаем группы сглаживания
 if tmp=tagiSmooth then begin
  COMidNormals:=ReadLong;
  SetLength(MidNormals,COMidNormals);
  for i:=0 to COMidNormals-1 do begin
   len:=ReadLong;
   SetLength(MidNormals[i],len);
   for ii:=0 to len-1 do begin
    MidNormals[i,ii].GeoID:=ReadLong;
    MidNormals[i,ii].VertID:=ReadLong;
   end;//of for ii
  end;//of for i

  COConstNormals:=ReadLong;
  SetLength(ConstNormals,COConstNormals);
  for i:=0 to COConstNormals-1 do begin
   ConstNormals[i].GeoId:=ReadLong;
   ConstNormals[i].VertID:=ReadLong;
   ConstNormals[i].n[1]:=ReadFloat;
   ConstNormals[i].n[2]:=ReadFloat;
   ConstNormals[i].n[3]:=ReadFloat;
  end;//of for i

{  tmp:=ReadLong;! не забыть включить после доб. нового куска}
 end;//of if
 Result:=true;
End;
//---------------------------------------------------------
//открывает файл MDX, полностью читая его
procedure OpenMDX(fname:string);
Var tag,i:integer;
Begin
 IsWoW:=false;
 //1. Открыть сам файл
 assignFile(f,fname);
 reset(f,1);                      //побайтовое чтение
 //2. Выделить память под файл
 GetMem(p,FileSize(f)+8);         //выделяем с резервом
 //3. Прочесть весь файл в память
 BlockRead(f,p^,FileSize(f));
 tag:=0;
 move(tag,pointer(integer(p)+FileSize(f))^,4);//запись нуля
 //4. Закрыть файл
 CloseFile(f);
 Controllers:=nil;
 FileContent:='';   //пока информации нет
//------------------Собственно чтение----------
 pp:=integer(p);                  //получить адрес
 pp:=pp+$10;                      //добавим 10 долларов :)
 MDXReadHeader;                   //чтение заголовка
 tag:=ReadLong;                   //читаем тег
 if tag=TagSEQS then begin
  MDXReadSequences;               //чтение анимаций
  tag:=ReadLong;
 end else CountOfSequences:=0;
 if tag=TagGLBS then begin
  MDXReadGlobalSeq;               //чтение глобальных посл.
  tag:=ReadLong;
 end else CountOfGlobalSequences:=0;
 if tag=TagMTLS then begin
  MDXReadMaterials;               //чтение материалов
  tag:=ReadLong;
 end else CountOfMaterials:=0;
 if tag=TagTEXS then begin
  MDXReadTextures;               //чтение текстур
  tag:=ReadLong;
 end else CountOfTextures:=0;
 if tag=TagTXAN then begin
  MDXReadTexAnims;               //чтение текстурных анимаций
  tag:=ReadLong;
 end else CountOfTextureAnims:=0;
 if tag=TagGEOS then begin
  MDXReadGeosets;                //чтение поверхностей
  tag:=ReadLong;
 end else begin                  //нет поверхностей, ошибка
  CountOfGeosets:=0;
  MessageBox(0,'Модель не содержит поверхностей.'+
               'Возможно, это модель спецэффекта.'+
               'MdlVis не умеет работать с такими моделями',
               scError,MB_APPLMODAL or MB_ICONSTOP);
  exit;
 end;//of if
// ReadHierarchy(fname);
 if tag=TagGEOA then begin
  MDXReadGeosetAnims;               //чтение анимаций видимости
  tag:=ReadLong;
 end else CountOfGeosetAnims:=0;
 if tag=TagBONE then begin
  MDXReadBones;                     //чтение костей
  tag:=ReadLong;
 end else CountOfBones:=0;
 if tag=TagLITE then begin
  MDXReadLights;                    //чтение источников света
  tag:=ReadLong;
 end else CountOfLights:=0;
 if tag=TagHELP then begin
  MDXReadHelpers;                   //чтение помощников
  tag:=ReadLong;
 end else CountOfHelpers:=0;
 if tag=TagATCH then begin
  MDXReadAttachments;               //чтение точек прикрепления
  tag:=ReadLong;
 end else CountOfAttachments:=0;
 if tag=TagPIVT then begin
  MDXReadPivotPoints;               //чтение геометрических центров
  tag:=ReadLong;
 end else CountOfPivotPoints:=0;
 if tag=TagPREM then begin
  MDXReadParticleEmitters1;         //чтение источников частиц (v.1)
  tag:=ReadLong;
 end else CountOfParticleEmitters1:=0;
 if tag=TagPRE2 then begin
  MDXReadParticleEmitters2;         //чтение источников частиц (v.2)
  tag:=ReadLong;
 end else CountOfParticleEmitters:=0;
 if tag=TagRIBB then begin
  MDXReadRibbonEmitters;            //чтение источников следа
  tag:=ReadLong;
 end else CountOfRibbonEmitters:=0;
 if tag=TagCAMS then begin
  MDXReadCameras;                   //чтение камер
  tag:=ReadLong;
 end else CountOfCameras:=0;
 if tag=TagEVTS then begin
  MDXReadEvents;                    //чтение событий
  tag:=ReadLong;
 end else CountOfEvents:=0;
 if tag=TagCLID then begin
  MDXReadCollisionObjects;          //чтение граничных объектов
  tag:=ReadLong;
 end else CountOfCollisionShapes:=0;
 //Завершающая проверка на камеры:
 if tag=TagCAMS then MDXReadCameras;
 MDXReadMdlVisInformation;          //загрузка секции MdlVis
//---------------------------------------------
 //Освободить память
 FreeMem(p);
// CountOfGeosetAnims:=0;
 //Заполнить оставшиеся массивы
 SetLength(VisGeosets,CountOfGeosets);
 for i:=0 to CountOfGeosets-1 do VisGeosets[i]:=true;
 FixModel;                        //исправить баги модели (если есть)
 //Создать линейность анимаций
{ for i:=0 to High(Controllers) do
  if Controllers[i].ContType>2 then Controllers[i].ContType:=2;}
End;
//---------------------------------------------------------
//Вспомогательные (модели M2)
//Для указанной поверхности (Geoset) проверяет, какой
//индекс имеет данный список костей. Если такой матрицы
//ещё нет, она создаётся.
function GetMakedGroupNum(geo,bn1,bn2,bn3,bn4:integer):integer;
Var i,ii,j,ln:integer;
    a:array [0..3] of integer;
    IsFound:boolean;
Begin with Geosets[geo] do begin
 ln:=0;
// GetMakedGroupNum:=0;
 if bn1>=0 then begin a[ln]:=bn1;inc(ln);end;
 if bn2>=0 then begin a[ln]:=bn2;inc(ln);end;
 if bn3>=0 then begin a[ln]:=bn3;inc(ln);end;
 if bn4>=0 then begin a[ln]:=bn4;inc(ln);end;
{ if ln=0 then begin               //проверка на ошибку
  MessageBox(0,'Найдены независимые вершины:'#13#10+
               'возможно, ошибка конверсии.'#13#10+
               'Отошлите эту модель разработчику MdlVis','Внимание:',
               mb_iconexclamation);
  exit;
 end;//of if}

 //Поиск в списках костей (Groups)
 IsFound:=false;                  //пока не найдено
 for i:=0 to CountOfMatrices-1 do begin
  if ln<>length(Groups[i]) then continue; //длины списков не совпадают
  for ii:=0 to ln-1 do begin
   IsFound:=false;                //пока что кость не найдена
   for j:=0 to length(Groups[i])-1 do if Groups[i,ii]=a[j] then begin
    IsFound:=true;                //кость есть в списке
    break;                        //закончить поиск
   end;//of if/for j
   if IsFound=false then break;   //одна из костей не найдена
  end;//of for ii
  if IsFound=true then begin      //найдено! Вернуть индекс и выйти
   GetMakedGroupNum:=i;
   exit;
  end;//of if
 end;//of for i

 //Группа не найдена, сформируем её
 inc(CountOfMatrices);
 SetLength(Groups,CountOfMatrices);
 SetLength(Groups[CountOfMatrices-1],ln);
 for i:=0 to ln-1 do Groups[CountOfMatrices-1,i]:=a[i];
 GetMakedGroupNum:=CountOfMatrices-1;
end;End;
//---------------------------------------------------------
//Составляет список текстур из M2-файла (WoW)
procedure M2ReadTextures(ct,it:integer);
Var i,id,flg,flen,fofs,pps:integer;
Begin
 CountOfTextures:=ct;
 SetLength(Textures,CountOfTextures);
 pp:=it;                          //переходим к первой текстуре
 //Загрузка всех текстур
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  FillChar(Textures[i],SizeOf(TTexture),0);
  id:=ReadLong;                   //чтение ID текстуры
  flg:=ReadShort;                 //флаги текстуры
  if (flg and 1)<>0 then IsWrapWidth:=true else IsWrapWidth:=false;
  if (flg and 2)<>0 then IsWrapHeight:=true else IsWrapHeight:=false;
  pp:=pp+2;                       //пропуск 0
  flen:=ReadLong;                 //длина имени файла
  fofs:=ReadLong+integer(p);      //имя файла

  //Установка ряда параметров
  ReplaceableID:=0;
  pImg:=nil;

  //Узнаём имя файла текстуры
  FileName:='';
  if id=0 then begin              //сразу читаем имя файла
   pps:=pp;
   pp:=fofs;
   FileName:=ReadASCII(flen);
   pp:=pps;
   continue;
  end;//of if

  //Придется поработать...
  FileName:=ModelName;            //начало - имя модели
  case id of
   1:FileName:=FileName+'Body.blp';
   2:FileName:=FileName+'Cape.blp';
   6:FileName:=FileName+'Hair.blp';
   8:FileName:=FileName+'Tauren.blp';
   11:FileName:=FileName+'_Skin01.blp';
   12:FileName:=FileName+'_Skin02.blp';
   13:FileName:=FileName+'_Skin03.blp';
   else FileName:='Unknown.ERR';//на всякий случай
  end;//of case
 end;//of for i
End;
//---------------------------------------------------------
//Набор процедур для чтения анимационных контроллеров:
//(На момент вызова pp указывает на начало записи,
//после вызова - на след. поле)
//В случае отсутствия анимации в контроллере, возвр. -1
//1. Чтение float-контроллера
function M2ReadControllerf(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers:integer;
Begin
 iofs:=integer(p);
 CountOfControllers:=length(Controllers)+1;
// inc(CountOfControllers);
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //Читаем тип интерполяции
  GlobalSeqID:=ReadShort;         //читать глоб. посл.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //пропуск InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //кол-во кадров
  ipFrames:=ReadLong+iofs;        //смещение записей кадров
  pp:=pp+4;                       //пропуск кол-ва кадров
  ipValues:=ReadLong+iofs;        //смещение значений
  SetLength(items,coFrames);      //выделяем место под кадры
  if coFrames<=1 then begin       //нет анимации
   M2ReadControllerf:=-1;
   if coFrames<1 then begin
    dec(CountOfControllers);
    SetLength(Controllers,CountOfControllers);
    exit;
   end;//of if
  end;//of if
  svpp:=pp;                       //сохраняем значение
  pp:=ipFrames;                   //список кадров
  //Читаем метки времени (значения времён кадров)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //переходим к списку значений
  //Чтение float-значений
  for i:=0 to coFrames-1 do begin 
   for ii:=1 to count do Items[i].Data[ii]:=ReadFloat;
   //читаем тангенсы (если нужно)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadFloat;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadFloat;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //восстановить позицию
 end;//of with

 if coFrames>1 then M2ReadControllerf:=CountOfControllers-1
              else Result:=-2;
End;

//1. Чтение short(word)-контроллера с масштабированием [0..1]
function M2ReadControllerw(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers:integer;
Begin
 iofs:=integer(p);
// inc(CountOfControllers);
 CountOfControllers:=length(Controllers)+1;
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //Читаем тип интерполяции
  GlobalSeqID:=ReadShort;         //читать глоб. посл.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //пропуск InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //кол-во кадров
  ipFrames:=ReadLong+iofs;        //смещение записей кадров
  pp:=pp+4;                       //пропуск кол-ва кадров
  ipValues:=ReadLong+iofs;        //смещение значений
  SetLength(items,coFrames);      //выделяем место под кадры
  if coFrames<=1 then begin       //нет анимации
   M2ReadControllerw:=-1;
   dec(CountOfControllers);
   SetLength(Controllers,CountOfControllers);
   exit;
  end;//of if
  svpp:=pp;                       //сохраняем значение
  pp:=ipFrames;                   //список кадров
  //Читаем метки времени (значения времён кадров)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //переходим к списку значений
  //Чтение float-значений
  for i:=0 to coFrames-1 do begin
   for ii:=1 to count do Items[i].Data[ii]:=ReadShort/32767;
   //читаем тангенсы (если нужно)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadShort/32767;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadShort/32767;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //восстановить позицию
 end;//of with

 M2ReadControllerw:=CountOfControllers-1;
End;
//---------------------------------------------------------
//Экспериментальный (debug)
function M2ReadControllerExp(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers,r:integer; px:pointer; pw:PWord;
Begin
 iofs:=integer(p);
// inc(CountOfControllers);
 CountOfControllers:=length(Controllers)+1;
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //Читаем тип интерполяции
  GlobalSeqID:=ReadShort;         //читать глоб. посл.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //пропуск InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //кол-во кадров
  ipFrames:=ReadLong+iofs;        //смещение записей кадров
  pp:=pp+4;                       //пропуск кол-ва кадров
  ipValues:=ReadLong+iofs;        //смещение значений
  SetLength(items,coFrames);      //выделяем место под кадры
  if coFrames<=1 then begin       //нет анимации
   M2ReadControllerExp:=-1;
   if coFrames<1 then begin
    dec(CountOfControllers);
    SetLength(Controllers,CountOfControllers);
    exit;
   end;//of if
  end;//of if
  svpp:=pp;                       //сохраняем значение
  pp:=ipFrames;                   //список кадров
  //Читаем метки времени (значения времён кадров)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //переходим к списку значений
  //Чтение float-значений
  for i:=0 to coFrames-1 do begin
   for ii:=1 to count do begin
    R:=ReadShort;
    Items[i].Data[ii]:=r/32767-1;
   end;//of for i
   //читаем тангенсы (если нужно)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadShort/32767-1;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadShort/32767-1;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //восстановить позицию
 end;//of with

 if coFrames>1 then Result:=CountOfControllers-1
               else Result:=-2;
End;
//---------------------------------------------------------
//Чтение целого (int) контроллера (масшт. 0..1)
function M2ReadControlleri(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers:integer;
Begin
 iofs:=integer(p);
// inc(CountOfControllers);
 CountOfControllers:=length(Controllers)+1;
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //Читаем тип интерполяции
  GlobalSeqID:=ReadShort;         //читать глоб. посл.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //пропуск InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //кол-во кадров
  ipFrames:=ReadLong+iofs;        //смещение записей кадров
  pp:=pp+4;                       //пропуск кол-ва кадров
  ipValues:=ReadLong+iofs;        //смещение значений
  SetLength(items,coFrames);      //выделяем место под кадры
  if coFrames<=1 then begin       //нет анимации
   M2ReadControlleri:=-1;
   dec(CountOfControllers);
   SetLength(Controllers,CountOfControllers);
   exit;
  end;//of if
  svpp:=pp;                       //сохраняем значение
  pp:=ipFrames;                   //список кадров
  //Читаем метки времени (значения времён кадров)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //переходим к списку значений
  //Чтение float-значений
  for i:=0 to coFrames-1 do begin
   for ii:=1 to count do Items[i].Data[ii]:=ReadLong/32767;
   //читаем тангенсы (если нужно)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadLong/32767;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadLong/32767;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //восстановить позицию
 end;//of with

 M2ReadControlleri:=CountOfControllers-1;
End;
//---------------------------------------------------------
//Чтение 1-байтовых контроллеров
function M2ReadControllerb(count:integer):integer;
Var iofs,i,ii,svpp,coFrames,ipFrames,ipValues,
    CountOfControllers:integer;
Begin
 iofs:=integer(p);
 CountOfControllers:=length(Controllers)+1;
 SetLength(Controllers,CountOfControllers);
 with Controllers[CountOfControllers-1] do begin
  ContType:=ReadShort+1;          //Читаем тип интерполяции
  GlobalSeqID:=ReadShort;         //читать глоб. посл.
  if GlobalSeqID>$8888 then GlobalSeqID:=-1;
  pp:=pp+2*4;                     //пропуск InterpolationRanges
  SizeOfElement:=count;
  coFrames:=ReadLong;             //кол-во кадров
  ipFrames:=ReadLong+iofs;        //смещение записей кадров
  pp:=pp+4;                       //пропуск кол-ва кадров
  ipValues:=ReadLong+iofs;        //смещение значений
  SetLength(items,coFrames);      //выделяем место под кадры
  if coFrames<=1 then begin       //нет анимации
   M2ReadControllerb:=-1;
   dec(CountOfControllers);
   SetLength(Controllers,CountOfControllers);
   exit;
  end;//of if
  svpp:=pp;                       //сохраняем значение
  pp:=ipFrames;                   //список кадров
  //Читаем метки времени (значения времён кадров)
  for i:=0 to coFrames-1 do Items[i].Frame:=ReadLong;
  pp:=ipValues;                   //переходим к списку значений
  //Чтение byte-значений
  for i:=0 to coFrames-1 do begin
   for ii:=1 to count do Items[i].Data[ii]:=ReadByte;
   //читаем тангенсы (если нужно)
   if (ContType=Hermite) or (ContType=Bezier) then begin
    for ii:=1 to count do Items[i].InTan[ii]:=ReadByte;
    for ii:=1 to count do Items[i].OutTan[ii]:=ReadByte;
   end;//of if ii
  end;//of for i
  pp:=svpp;                       //восстановить позицию
 end;//of with

 M2ReadControllerb:=CountOfControllers-1;
End;

//---------------------------------------------------------
//Вспомогательная: сравнивает 2 материала.
//В случае совпадения возвращает true.
function IsMatsEqual(var m1,m2:TMaterial):boolean;
Var i:integer;
Begin
 IsMatsEqual:=false;              //пока нет совпадения
 if (m1.IsConstantColor<>m2.IsConstantColor) or
    (m1.CountOfLayers<>m2.CountOfLayers) then exit;
 //Теперь сличаем слои:
 for i:=0 to m1.CountOfLayers-1 do begin
  if m1.Layers[i].FilterMode<>m2.Layers[i].FilterMode then exit;
  if (m1.Layers[i].IsUnshaded<>m2.Layers[i].IsUnshaded) or
     (m1.Layers[i].IsTwoSided<>m2.Layers[i].IsTwoSided) or
     (m1.Layers[i].IsUnfogged<>m2.Layers[i].IsUnfogged) or
     (m1.Layers[i].IsNoDepthTest<>m2.Layers[i].IsNoDepthTest) or
     (m1.Layers[i].IsNoDepthSet<>m2.Layers[i].IsNoDepthSet) then exit;
  if m1.Layers[i].TextureID<>m2.Layers[i].TextureID then exit;
  if m1.Layers[i].IsAlphaStatic<>m2.Layers[i].IsAlphaStatic then exit;
  if m1.Layers[i].Alpha<>m1.Layers[i].Alpha then exit;
  if m1.Layers[i].TVertexAnimID<>m2.Layers[i].TVertexAnimID then exit;
  if (m1.Layers[i].NumOfGraph<0) and (m2.Layers[i].NumOfGraph<0) then continue;
  if (m1.Layers[i].NumOfGraph<0) and
     (m1.Layers[i].NumOfGraph<>m2.Layers[i].NumOfGraph) then exit; 
  if length(Controllers[m1.Layers[i].NumOfGraph].items)<>
     length(Controllers[m2.Layers[i].NumOfGraph].items) then exit;
  if Controllers[m1.Layers[i].NumOfGraph].GlobalSeqId<>
     Controllers[m2.Layers[i].NumOfGraph].GlobalSeqId then exit;
 end;//of for i
 IsMatsEqual:=true;
End;
//---------------------------------------------------------
//Вспомогательная: читает материал из M2-файла (WoW).
//Возвращает ID прочитанного материала
//lCount - кол-во записей слоёв для чения.
//В момент вызова pp должно указывать на начало записи слоя,
//CountOfMaterials - содержать кол-во мат-лов.
function M2ReadMaterial(lCount,MeshID,GeoID,ipColors,ipRender,
                        ipTexUnits,ipTransp,ipAnLookup,
                        ipTexLookup:integer):integer;
Var i,ii,j,iofs,flg,tmp,svpp:integer;
    lr:TLayer;IsGACreated:boolean;
//извлекает из 0 кадра последнего контроллера
//тройку чисел Color и убирает этот контроллер
procedure PopFloatColor(var color:TVertex);
Begin
 Color[1]:=Controllers[High(Controllers)].Items[0].Data[1];
 Color[2]:=Controllers[High(Controllers)].Items[0].Data[2];
 Color[3]:=Controllers[High(Controllers)].Items[0].Data[3];
 SetLength(Controllers,High(Controllers));
End;
Begin
 IsGACreated:=false;
 inc(CountOfMaterials);
 SetLength(Materials,CountOfMaterials);//создать материал
 Materials[CountOfMaterials-1].CountOfLayers:=0;//пока нет слоёв
 Materials[CountOfMaterials-1].IsConstantColor:=false;
 Materials[CountOfMaterials-1].ListNum:=-1;
 //Начинаем читать записи слоёв:
 for i:=1 to lCount do begin
  flg:=ReadShort;                 //читать флаги (впрочем, они не нужны)
//  if flg>0 then lr.IsTextureStatic:=true else lr.IsTextureStatic:=false;
  pp:=pp+2;                       //PriorityPlane?
  tmp:=ReadShort;                 //читаем ID поверхности
  if tmp<>MeshID then begin       //это не тот слой
   pp:=pp+24-6;
   continue;
  end;//of if

  //Найден нужный слой. Можно считать его.
  pp:=pp+2;                       //пропуск повторяющегося MeshID
  tmp:=ReadShort;                 //читаем индекс цвета
  if (CountOfGeosetAnims=0) or (not IsGACreated) then begin
   inc(CountOfGeosetAnims);        //создать GeosetAnim
   SetLength(GeosetAnims,CountOfGeosetAnims);
   with GeosetAnims[CountOfGeosetAnims-1] do begin
    GeosetID:=GeoID;
    IsDropShadow:=false;
    IsColorStatic:=true;
    IsAlphaStatic:=true;
    Alpha:=1;Color[1]:=1;Color[2]:=1;Color[3]:=1;
   end;//of with
   IsGACreated:=true;
  end;//of if
  if tmp<$8888 then begin
   //Цвет динамический, нужно создать GeosetAnim.
   Materials[CountOfMaterials-1].IsConstantColor:=true;
   with GeosetAnims[CountOfGeosetAnims-1] do begin
    //Установка ряда параметров
    IsColorStatic:=false;
    IsAlphaStatic:=false;
    //чтение
    svpp:=pp;                      //сохранить позицию
    pp:=ipColors+$38*tmp;          //нужная цветовая запись
    ColorGraphNum:=M2ReadControllerf(3);
    if ColorGraphNum<0 then begin //статический цвет
     IsColorStatic:=true;
     Color[1]:=1;Color[2]:=1;Color[3]:=1;
    end;//of if(ColorStatic)
    if ColorGraphNum<-1 then PopFloatColor(Color);
    AlphaGraphNum:=M2ReadControllerw(1);//читать прозрачность(альфа)
    if AlphaGraphNum<0 then begin
     IsAlphaStatic:=true;
     Alpha:=1;
    end;//of if(AlphaStatic)
    pp:=svpp;                     //восстановить позицию
   end;//of with
  end;//of if(нужно создание видимости)

  //Читаем флаги рендеринга:
  tmp:=ReadShort;                 //индекс в таблице флагов
  svpp:=pp;                       //сохранить позицию
  pp:=ipRender+4*tmp;             //найти пару флагов
  flg:=ReadShort;                 //читать общие флаги
  //Анализ флагов
  if (flg and 1)<>0 then lr.IsUnshaded:=true else lr.IsUnshaded:=false;//!att
  if (flg and 2)<>0 then lr.IsUnfogged:=true else lr.IsUnfogged:=false;
  if (flg and 4)<>0 then lr.IsTwoSided:=true else lr.IsTwoSided:=false;
  {if (flg and 16)<>0 then lr.IsNoDepthSet:=true else} lr.IsNoDepthSet:=false;
  //Доустановка остальных флагов
  lr.IsSphereEnvMap:=false;
  lr.IsNoDepthTest:=false;
  //Читаем флаги режима смешения:
  flg:=ReadShort;     //чтение
  case flg of
   0:lr.FilterMode:=Opaque;
   1:lr.FilterMode:=ColorAlpha;
   2:lr.FilterMode:=FullAlpha;
   3:lr.FilterMode:=Additive;
   4:begin lr.FilterMode:=Additive;end;
   5:lr.FilterMode:=Modulate;
   else lr.FilterMode:=Additive;
  end;//of case
  pp:=svpp;                       //возврат к коду материала

  //Читаем номер слоя в материале (-1,0,1)
  tmp:=ReadShort;
  svpp:=pp;
  pp:=ipTexUnits+2*tmp;           //идти к таблице значений
  lr.CoordID:=ReadShort;          //читать (пока - в неиспользуемое поле слоя)
//  if lr.CoordID>$8888 then lr.CoordID:=-1;
  pp:=svpp+2;                     //возврат+пропуск поля

  lr.TextureID:=ReadShort;        //текстура слоя
  //Вычисляем истинный ID текстуры (по Lookup-таблице):
  svpp:=pp;
  pp:=ipTexLookup+2*lr.TextureID;
  lr.TextureID:=ReadShort;
  pp:=svpp;

  pp:=pp+2;                       //пропуск поля

  //Прозрачность (альфа) и её анимация
  tmp:=ReadShort;                 //номер анимации альфа
  svpp:=pp;
  pp:=ipTransp+tmp*$1C;           //ищем контроллер
  lr.IsAlphaStatic:=false;
  lr.NumOfGraph:=M2ReadControllerw(1);//читать контроллер
  if lr.NumOfGraph<0 then begin
   lr.Alpha:=1;
   lr.IsAlphaStatic:=true;
  end;//of if
  //Проверим, чтоб не было линейности в контроллере непрозрачности
  if (lr.FilterMode=Opaque) and (not lr.IsAlphaStatic) then begin
   if Controllers[lr.NumOfGraph].ContType<>DontInterp
   then lr.FilterMode:=ColorAlpha;
  end;//of if
  pp:=svpp;

  //Доустановка остатка
  lr.NumOfTexGraph:=-1;
  lr.IsTextureStatic:=true;

  //Теперь читаем ID текстурной анимации (если таковая есть)
  tmp:=ReadShort;                 //опять индекс
  svpp:=pp;
  pp:=ipAnLookup+2*tmp;           //начало чтения
  lr.TVertexAnimID:=ReadShort;
  if lr.TVertexAnimID>$8888 then lr.TVertexAnimID:=-1;
  pp:=svpp;

  //Ура! Чтение слоя в общем окончено.
  //Теперь его нужно добавить к материалу в правильное место

  //Слои уже есть. Ищем, куда вставлять (по порядку CoordID):
  with Materials[CountOfMaterials-1] do begin
   for ii:=0 to CountOfLayers do begin

    if ii=CountOfLayers then begin//конец, нужно добавить
     inc(CountOfLayers);              //простое добавление
     SetLength(Layers,CountOfLayers);
     Layers[CountOfLayers-1]:=lr;
     break;                       //выйти из цикла
    end;//of if

    if lr.CoordID<Layers[ii].CoordID then begin//вставка
     inc(CountOfLayers);
     SetLength(Layers,CountOfLayers);
     for j:=CountOfLayers-2 downto ii do Layers[j+1]:=Layers[j];
     Layers[ii]:=lr;
     break; 
    end;//of if

   end;//of for ii

  end;//of with

 end;//of for i

 //Теперь - сброс CoordID для всех слоёв
 with Materials[CountOfMaterials-1] do
      for ii:=0 to CountOfLayers-1 do Layers[ii].CoordID:=-1;
 //поиск: вдруг есть такой материал?
 for i:=0 to CountOfMaterials-2 do
  if IsMatsEqual(Materials[i],Materials[CountOfMaterials-1]) then begin
  M2ReadMaterial:=i;
  dec(CountOfMaterials);
  exit;
 end;//of for i
 //нет такого
 M2ReadMaterial:=CountOfMaterials-1;
// Materials[CountOfMaterials-1]
End;
//---------------------------------------------------------
//Вспомогательная: создаёт материал-пустышку и возвр. его ID
function CreateFakedMaterial:integer;
Begin
 MessageBox(0,'Не найден материал поверхности.'#13#10+
              'Отправьте эту модель автору MdlVis',
              scError,mb_iconstop);
 CreateFakedMaterial:=0;
End;
//---------------------------------------------------------
//Вспомогательная: читать текстурные анимации WoW
procedure M2ReadTextureAnims(coTexAnims,ipTexAnims:integer);
Var i:integer;
Begin
 CountOfTextureAnims:=coTexAnims;
 SetLength(TextureAnims,CountOfTextureAnims);
 pp:=ipTexAnims;
 for i:=0 to CountOfTextureAnims-1 do with TextureAnims[i] do begin
  TranslationGraphNum:=M2ReadControllerf(3);
  //Вращение пока не читаем:
  pp:=pp+$1C;
  RotationGraphNum:=-1;
  ScalingGraphNum:=M2ReadControllerf(3);
//  RotationGraphNum:=M2ReadControllerf(3);
 end;//of with/for
End;
//---------------------------------------------------------
//Вспомогательная: чтение списка глобальных последовательностей
procedure M2ReadGlobalSequences(coGlb,ipGlb:integer);
Var i:integer;
Begin
 pp:=ipGlb;
 CountOfGlobalSequences:=coGlb;
 SetLength(GlobalSequences,CountOfGlobalSequences);
 for i:=0 to CountOfGlobalSequences-1 do GlobalSequences[i]:=ReadLong;
End;
//---------------------------------------------------------
//Вспомогательная: читать список анимаций (Sequences),
//Создать Anim'ы в каждой поверхности
procedure M2ReadSequences(coSeq,ipSeq:integer);
Var i,ii,j,id,flg,coCin,coSeqs:integer;
    minx,miny,minz,maxx,maxy,maxz:GLFloat;
Const sst='Cinematic';
Begin
 coCin:=1;
 CountOfSequences:=coSeq;
 SetLength(Sequences,CountOfSequences);
 pp:=ipSeq;
 for i:=0 to CountOfSequences-1 do with Sequences[i] do begin
  id:=ReadLong;                   //ID анимации
  IntervalStart:=ReadLong;
  IntervalEnd:=ReadLong;
  MoveSpeed:=round(ReadFloat);
  flg:=ReadLong;
  if (flg and 1)<>0 then IsNonLooping:=true else IsNonLooping:=false;
  pp:=pp+4*4;                     //пропуск части полей
  //--Здесь будет формирование имени из ID
  case id of
   0:Name:='Stand';
   1:Name:='Death';
   2:Name:='Spell';
   3:Name:='Cinematic Stop';
   4:Name:='Walk';
   5:Name:='Walk Fast';
   6:Name:='Decay Flesh';
   7:Name:=sst+' Rise';
   8:Name:='Stand Hit';
   9:Name:='Stand Hit Large';
   10:Name:='Stand Hit Critical';
   11:Name:=sst+' ShuffleLeft';
   12:Name:=sst+' ShuffleRight';
   13:Name:=sst+' WalkBackward';
   14:Name:='Stand Wounded';
   15:Name:=sst+' HandsClosed';
   16:Name:='Attack';{ Alternate'}
   17:Name:='Attack First';
   18:Name:='Attack Second';
   19:Name:='Attack Third';
   20:Name:='Stand Hit Medium';
   21:Name:='Stand Hit Medium First';
   22:Name:='Stand Hit Medium Second';
   23:Name:='Stand Hit Medium Third';
   24:Name:='Stand Hit Defend';
   25:Name:='Stand Ready';
   26:Name:='Stand Ready First';
   27:Name:='Stand Ready Second';
   28:Name:='Stand Ready Third';
   29:Name:='Stand Gold Fourth';
   30:Name:='Stand Hit Small';
   31:Name:='Spell Second';
   32:Name:='Spell Channel Second';
   33:Name:='Spell Channel Second';
   34:Name:=sst+' Welcome';
   35:Name:=sst+' Goodbye';
   36:Name:='Stand Hit';
   37:Name:=sst+' JumpStart';
   38:Name:=sst+' Jump';
   39:Name:=sst+' JumpEnd';
   40:Name:=sst+' Fall';
   41:Name:='Stand Swim';
   42:Name:='Walk Swim';
   43:Name:='Walk Right Swim';
   44:Name:='Walk Left Swim';
   45:Name:=sst+' SwimBackward';
   46:Name:='Attack Fourth';
   47:Name:='Attack Fourth';
   48:Name:='Stand Gold Fifth';
   49:Name:='Attack Fifth';
   50:Name:='Stand Victory';
   51:Name:='Spell Ready Throw';
   52:Name:='Spell Ready';
   53:Name:='Spell Throw';
   54:Name:='Spell';
   55:Name:='Spell Slam';
   56:Name:='Stand Ready Second';
   57:Name:='Attack Slam First';
   58:Name:='Attack Slam Second';
   59:Name:='Attack Off Two';
   60:Name:='Portrait Talk';
   61:Name:=sst+' Eat';
   62:Name:='Stand Work';
   63:Name:='Portrait';
   64:Name:='Portrait Talk';
   65:Name:='Portrait Talk';
   66:Name:=sst+' EmoteBow';
   67:Name:=sst+' EmoteWave';
   68:Name:=sst+' EmoteCheer';
   69:Name:=sst+' EmoteDance';
   70:Name:=sst+' EmoteLaugh';
   71:Name:=sst+' EmoteSleep';
   85:Name:='Attack First';
   86:Name:='Attack Third';
   87:Name:='Attack Off';
   88:Name:='Attack Off';
   95:Name:='Attack Upgrade';
   100:Name:='Sleep';
   105:Name:='Stand Ready Fourth';
   106:Name:='Stand Ready Fifth';
   107:Name:='Attack Puke';
   108:Name:='Stand Gold Alternate';
   109:Name:='Stand Lumber Fourth';
   110:Name:='Stand Lumber Fifth';
   111:Name:='Stand Lumber Alternate';
   112:Name:='Stand Ready Alternate';
   113:Name:='Stand Victory';
   117:Name:='Attack Off Alternate';
   118:Name:='Attack Slam';
   119:Name:='Walk Moderate';
   120:Name:='Stand Moderate';
   121:Name:='Stand Hit Slam';
   124:Name:='Stand Channel Throw';
   125:Name:='Spell Ready';
   126:Name:='Attack Walk Stand Spin';
   127:Name:='Birth';
   131:Name:='Death Swim';
   132:Name:='Decay Swim';
   135:Name:='Stand';
   143:Name:='Walk Fast';
   144:Name:='Walk';
   146:Name:=sst+' Close';
   147:Name:=sst+' Closed';
   158:Name:='Stand Lumber';
   159:Name:='Decay';
   160:Name:=sst+' BowPull';
   161:Name:=sst+' BowRelease';
   181:Name:='Attack Slam Large';
   190:Name:='Stand';
   194:Name:='Stand Victory';
   else begin                     //остальное
    Name:='Cinematic '+inttostr(id)+inttostr(coCin);
    inc(coCin);
   end;
  end;//of case

  //Чтение границ
  for ii:=1 to 3 do Bounds.MinimumExtent[ii]:=ReadFloat*wowmult;
  for ii:=1 to 3 do Bounds.MaximumExtent[ii]:=ReadFloat*wowmult;
  Bounds.BoundsRadius:=ReadFloat*wowmult;
  pp:=pp+4;                       //пропуск ещё двух полей
 end;//of with/for i

 //Доводка анимаций (исключение пересекающихся и правка имён)
 i:=0;
 while i<CountOfSequences do begin
  ii:=i+1;coSeqs:=1;
  while ii<CountOfSequences do begin
   //Проверка на пересечение
   if (Sequences[ii].IntervalStart<=Sequences[i].IntervalEnd) and
      (Sequences[ii].IntervalStart>=Sequences[i].IntervalStart) then begin
    for j:=ii+1 to CountOfSequences-1 do Sequences[j-1]:=Sequences[j];
    dec(CountOfSequences);
    SetLength(Sequences,CountOfSequences);
    continue;
   end;//of if

   //Проверка на совпадение имён
   if Sequences[i].Name=Sequences[ii].Name then begin
    inc(coSeqs);
    Sequences[ii].Name:=Sequences[ii].Name+' '+inttostr(coSeqs);
//    Sequences[ii].IsNonLooping:=true;
   end;//of if
   inc(ii);
  end;//of while

  //Установка флагов
  if pos('Attack',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=true;
  if pos('Stand',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=false;
  if pos('Walk',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=false;
  if pos('Channel',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=false;
  if pos('Portrait',Sequences[i].Name)<>0 then Sequences[i].IsNonLooping:=false;        
  inc(i);
 end;//of while
 //Теперь разыщем ограничивающий объем для поверхностей:
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  minx:=1000;miny:=1000;minz:=1000;
  maxx:=-1000;maxy:=-1000;maxz:=-1000;
  //Поиск границ:
  for ii:=0 to CountOfVertices-1 do begin
   if Vertices[ii,1]<minx then minx:=Vertices[ii,1];
   if Vertices[ii,1]>maxx then maxx:=Vertices[ii,1];
   if Vertices[ii,2]<miny then miny:=Vertices[ii,2];
   if Vertices[ii,2]>maxy then maxy:=Vertices[ii,2];
   if Vertices[ii,3]<minz then minz:=Vertices[ii,3];
   if Vertices[ii,3]>maxz then maxz:=Vertices[ii,3];
  end;//of for ii
  MinimumExtent[1]:=minx;
  MinimumExtent[2]:=miny;
  MinimumExtent[3]:=minz;
  MaximumExtent[1]:=maxx;
  MaximumExtent[2]:=maxy;
  MaximumExtent[3]:=maxz;
  //Граничный радиус
  BoundsRadius:=sqrt(sqr(MaximumExtent[1]-MinimumExtent[1])+
                sqr(MaximumExtent[2]-MinimumExtent[2])+
                sqr(MaximumExtent[3]-MinimumExtent[3]))*0.5;
  //Теперь заполняем границы анимаций Anim:
  CountOfAnims:=CountOfSequences;
  SetLength(Anims,CountOfAnims);
  for ii:=0 to CountOfAnims-1 do begin
   Anims[ii].MinimumExtent:=MinimumExtent;
   Anims[ii].MaximumExtent:=MaximumExtent;
   Anims[ii].BoundsRadius:=BoundsRadius;
  end;//of for ii
 end;//of with/for i

 //Теперь определим границы для всей модели
 //как 1.5 максимума границ
 AnimBounds.MinimumExtent:=Geosets[0].MinimumExtent;
 AnimBounds.MaximumExtent:=Geosets[0].MaximumExtent;
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  if MinimumExtent[1]<AnimBounds.MinimumExtent[1] then
     AnimBounds.MinimumExtent[1]:=MinimumExtent[1];
  if MinimumExtent[2]<AnimBounds.MinimumExtent[2] then
     AnimBounds.MinimumExtent[2]:=MinimumExtent[2];
  if MinimumExtent[3]<AnimBounds.MinimumExtent[3] then
     AnimBounds.MinimumExtent[3]:=MinimumExtent[3];

  if MaximumExtent[1]>AnimBounds.MaximumExtent[1] then
     AnimBounds.MaximumExtent[1]:=MaximumExtent[1];
  if MaximumExtent[2]>AnimBounds.MaximumExtent[2] then
     AnimBounds.MaximumExtent[2]:=MaximumExtent[2];
  if MaximumExtent[3]>AnimBounds.MaximumExtent[3] then
     AnimBounds.MaximumExtent[3]:=MaximumExtent[3];
 end;//of with/for i
 with AnimBounds do
  BoundsRadius:=sqrt(sqr(MaximumExtent[1]-MinimumExtent[1])+
                sqr(MaximumExtent[2]-MinimumExtent[2])+
                sqr(MaximumExtent[3]-MinimumExtent[3]))*0.5;
End;
//---------------------------------------------------------
//Вспомогательная: умножает все элементы контроллера ContID
//на указанное число
procedure MultController(ContID:integer;m:single);
Var l,i,ii:integer;
Begin
 l:=High(Controllers[ContID].Items);
 for i:=0 to l do
  for ii:=1 to 5 do with Controllers[ContID].Items[i] do begin
   Data[ii]:=Data[ii]*m;
   InTan[ii]:=InTan[ii]*m;
  end;//of with/for ii/i
End;
//---------------------------------------------------------
//Чтение всех объектов скелета (костей).
//CurID при этом изменяется на ближайший свободный
procedure M2ReadBones(coB,ipB:integer;var CurID:integer);
Var i,ii{,j},flg:integer;
Begin
 CountOfHelpers:=0;               //нет помощников
 CountOfBones:=coB;
 CountOfPivotPoints:=coB;
 SetLength(Bones,CountOfBones);
 SetLength(PivotPoints,CountOfPivotPoints);
 //Собственно чтение
 pp:=ipB;
 for i:=0 to CountOfBones-1 do with Bones[i] do begin
  Name:='bone_b'+inttostr(CurID); //имя кости
  ObjectID:=CurID;                //ID кости
  GeosetID:=Multiple;
  GeosetAnimID:=-1;

  pp:=pp+4;                       //пропуск индекса F
  flg:=ReadLong;                  //читать флаги
  if (flg and 8)<>0 then IsBillboarded:=true else IsBillboarded:=false;
  Parent:=ReadShort;
  if Parent>$8888 then Parent:=-1;
  pp:=pp+2;                       //пропуск поля
  if Version>=$104 then pp:=pp+4; //пропуск ещё одного поля


  //Доустановка ряда параметров
  IsBillboardedLockX:=false;IsBillboardedLockY:=false;IsBillboardedLockX:=false;
  IsCameraAnchored:=false;
  IsDIRotation:=false;IsDITranslation:=false;IsDIScaling:=false;

  //Чтение контроллеров
  Translation:=M2ReadControllerf(3);
//  Translation:=-1;
  if Translation=-2 then Translation:=High(Controllers);
  if Version>=$104 then Rotation:=M2ReadControllerExp(4)
  else Rotation:=M2ReadControllerf(4);
  if Rotation=-2 then Rotation:=High(Controllers);
  Scaling:=M2ReadControllerf(3);
  if Scaling=-2 then Scaling:=High(Controllers);  
  Visibility:=-1;
  //Масштабирование контроллера переноса (Translation):

  if Translation>=0 then MultController(Translation,wowmult);

  //Считываем точку центра (Pivot):
  for ii:=1 to 3 do PivotPoints[CurID,ii]:=ReadFloat*wowmult;
  inc(CurID);
 end;//of with/for i
// Bones[0]
End;
//---------------------------------------------------------
//Вспомогательная: частичное сравнение двух поверхностей.
//true, если они эквивалентны
{function IsGeosEqual(var g1,g2:TGeoset):boolean;
Var i,ii,len:integer;
Begin
 IsGeosEqual:=false;              //пока считаются неравными
 if (g1.CountOfVertices<>g2.CountOfVertices) or
    (g1.MaterialID<>g2.MaterialID) or
    (g1.CountOfMatrices<>g2.CountOfMatrices) then exit;
 //Проверка матриц
 for i:=0 to g1.CountOfMatrices-1 do begin
  if length(g1.Groups[i])<>length(g2.Groups[i]) then exit;
  len:=length(g1.Groups[i])-1;
  for ii:=0 to len do if g1.Groups[i,ii]<>g2.Groups[i,ii] then exit;
 end;//of for i
 //Проверка списков разворотов
 if length(g1.Faces[0])<>length(g2.Faces[0]) then exit;
 len:=length(g1.Faces[0])-1;
 for i:=0 to len do if g1.Faces[0,i]<>g2.Faces[0,i] then exit;
 //Набор вершин по группам
 for i:=0 to g1.CountOfVertices-1 do
  if g1.VertexGroup[i]<>g2.VertexGroup[i] then exit;

 IsGeosEqual:=true;
End;}
//---------------------------------------------------------
//Вспомогательная: конвертирует все текстуры модели
//fname - имя файла модели (используется для получения пути)
procedure M2ConvertTextures(name,fname:string);
Var //fi:_Win32_Find_Data;
    path,tname:string;
    ps,i:integer;
    sr:TSearchRec;
    buf:array[0..512] of char;
    pBuf:PChar;
Begin
 //0. Проверим, доступна ли IJL:
 if (@ijlInit=nil) or (@ijlWrite=nil) or (@ijlFree=nil) then begin
   MessageBox(0,'Библиотека ijl15.dll не найдена,'#13#10+
                'Упаковка blp-текстур невозможна.',
                'ВНИМАНИЕ:',mb_iconstop or mb_applmodal);
   exit;                           //продолжать нет смысла
 end;//of if
 //1. Находим путь
 ps:=length(fname);
 while (ps>0) and (fname[ps]<>'\') do dec(ps);
 path:=copy(fname,1,ps);
 //1. Находим все файлы, начинающиеся с имени модели
 if FindFirst(path+name+'*.blp',faAnyFile,sr)=0 then begin//есть!
  ConvertBLP2ToBLP(sr.Name,true);//конвертировать найденное
  //Далее - цикл конвертирования всех текстур
  while FindNext(sr)=0 do ConvertBLP2ToBLP(sr.Name,true);
  FindClose(sr);
 end;//of if (файл найден)

 //2. Ищем дополнительные файлы (указанные в виде имени файла)
 for i:=0 to CountOfTextures-1 do begin
  //Определяем имя файла текстуры (без пути):
  ps:=length(Textures[i].FileName);
  while (ps>0) and (Textures[i].FileName[ps]<>'\') do dec(ps);
  tname:=Textures[i].FileName;
  Delete(tname,1,ps);
  //Ищем, есть ли такой файл
  if SearchPath(PChar(path),PChar(tname),nil,512,buf,pBuf)<>0 then
     ConvertBLP2ToBLP(path+tname,true);
 end;//of for i
End;
//---------------------------------------------------------
//Вспомогательная: считывает набор точек прикрепления
procedure M2ReadAttachments(coA,ipA:integer;var CurID:integer);
Var i,ii,id:integer;
Begin
 pp:=ipA;
 CountOfAttachments:=coA;
 SetLength(Attachments,CountOfAttachments);
 CountOfPivotPoints:=CountOfPivotPoints+coA;
 SetLength(PivotPoints,CountOfPivotPoints);
 for i:=0 to CountOfAttachments-1 do with Attachments[i] do begin
  InitTBone(Skel);
  Skel.ObjectID:=CurID;
  id:=ReadLong;                   //читать ID точки
  //Определяем тип точки прикрепления:
  with Skel do case id of
   0:Name:='Hand Second Left Ref';
   1,21,35:Name:='Hand First Right Ref';
   2,22:Name:='Hand First Left Ref';
   3:Name:='Hand Third Right Ref';
   4:Name:='Hand Third Left Ref';
   5:Name:='Hand Fourth Right Ref';
   6:Name:='Hand Fourth Left Ref';
   7:Name:='Foot Second Right Ref';
   8:Name:='Foot Second Left Ref';
   9:Name:='Unk1 Right Ref';      //пояс(внутри)
   10:Name:='Unk1 Left Ref';      //пояс(внутри), совп.
   11:Name:='Head Ref';
   12:Name:='Chest Rear Ref';
   13:Name:='Unk2 Right Ref';     //плечо
   14:Name:='Unk2 Left Ref';      //плечо
   15:Name:='Chest Left Ref';     //!
   16:Name:='Chest Second Ref';   //!
   17:Name:='Head Second Ref';
   18:Name:='Overhead Ref';
   19:Name:='Origin Ref';
   20:Name:='Head First Ref';

   23:Name:='Unk3 Ref';
   24:Name:='Unk4 Ref';
   25:Name:='Unk5 Ref';

   26:Name:='Weapon Rear Right Ref';
   27:Name:='Weapon Rear Left Ref';
   28:Name:='Weapon Ref';
   29:Name:='Chest Ref';
   30:Name:='Back Left Ref';
   31:Name:='Back Right Ref';
   32:Name:='Weapon Mount Left Ref';
   33:Name:='Weapon Mount Right Ref';
   34:Name:='Chest Right Ref';
   else Name:='Unk'+inttostr(ID);
  end;//of case
  //ID кости:
  Skel.Parent:=ReadLong and $FFFF;
  if Skel.Parent>$8888 then Skel.Parent:=-1;
  if Skel.Parent<0 then Skel.Parent:=-1;
  //Координата (позиция точки)
  for ii:=1 to 3 do PivotPoints[CurID,ii]:=ReadFloat*wowmult;
  //Блок анимации
  Skel.Visibility:=M2ReadControlleri(1);
  if Skel.Visibility>=0 then
     for ii:=0 to High(Controllers[Skel.Visibility].Items) do begin
     if Controllers[Skel.Visibility].Items[ii].Data[1]<0.007 then
      Controllers[Skel.Visibility].Items[ii].Data[1]:=0
     else Controllers[Skel.Visibility].Items[ii].Data[1]:=1;
  end;//of for/if
{  //Доустановка значений:
  IsBillboardedLockX:=false;
  IsBillboardedLockY:=false;
  IsBillboardedLockZ:=false;
  IsBillboarded:=false;
  IsCameraAnchored:=false;
  IsDITranslation:=false;
  IsDIRotation:=false;
  IsDIScaling:=false;}
  AttachmentID:=-1;
  Path:='';
{  TranslationGraphNum:=-1;
  RotationGraphNum:=-1;
  ScalingGraphNum:=-1;}
  inc(CurID);
 end;//of for i
End;
//---------------------------------------------------------
//Вспомогательная: читать объекты-камеры в моделях WoW
procedure M2ReadCameras(coC,ipC:integer);
Var i,ii:integer;
Begin
 pp:=ipC;
 CountOfCameras:=coC;
 SetLength(Cameras,CountOfCameras);
 for i:=0 to CountOfCameras-1 do with Cameras[i] do begin
  pp:=pp+4;                       //пропуск -1
  FieldOfView:=ReadFloat*35*2*0.01745329;//поле зрения
  FarClip:=ReadFloat*wowmult;
  NearClip:=ReadFloat*wowmult;

  TranslationGraphNum:=M2ReadControllerf(3);
  if TranslationGraphNum>=0 then MultController(TranslationGraphNum,wowmult);
  for ii:=1 to 3 do Position[ii]:=ReadFloat*wowmult;

  TargetTGNum:=M2ReadControllerf(3);
  if TargetTGNum>=0 then MultController(TargetTGNum,wowmult);
  for ii:=1 to 3 do TargetPosition[ii]:=ReadFloat*wowmult;

  RotationGraphNum:=M2ReadControllerf(1);
  Name:='Camera'+inttostr(i);
 end;//of for i
End;
//---------------------------------------------------------
procedure M2FindTextures(fn,mn:string);
Var i,ps:integer;
    path,fnd,fnd2:string;
    IsPolyTex:boolean;
    ffnd:TSearchRec;
Begin
 //Находим путь
 ps:=length(fn);
 while (ps>0) and (fn[ps]<>'\') do dec(ps);
 path:=copy(fn,1,ps);
 IsPolyTex:=false;

 //1. Проверим, используются ли там скины
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  if pos('\',FileName)<>0 then continue;//статичные текстуры
  if pos('Skin',FileName)=0 then continue;//это не "животная" текстура
  if (pos('2',FileName)<>0) or (pos('3',FileName)<>0) then begin
   IsPolyTex:=true;
   break;
  end;//of if
 end;//of for i

 //2. Собственно цикл поиска:
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  if pos('Skin',FileName)=0 then continue;//только для скиновых текстур
  fnd:=path+ModelName+'*'+'Skin';
  if IsPolyTex then begin         //сейчас проверим ВСЕ текстуры
   if pos('1',FileName)<>0 then fnd2:=fnd+'*1*.blp';
   if pos('2',FileName)<>0 then fnd2:=fnd+'*2*.blp';
   if pos('3',FileName)<>0 then fnd2:=fnd+'*3*.blp';
   if FindFirst(fnd2,faAnyFile,ffnd)=0 then begin//файл найден!
    FileName:=ffnd.Name;
    FindClose(ffnd);
   end;//of if
  end else begin
   fnd2:=fnd+'*.blp';
   if FindFirst(fnd2,faAnyFile,ffnd)=0 then begin//файл найден!
    FileName:=ffnd.Name;
    FindClose(ffnd);
   end;//of if
  end;//of if(IsPolyTex)
 end;//of for i

End;
//-------------------------------------------------------
//Вспомогательная:
//Конвертирование источников частиц WoW
procedure M2ReadParticleEmitters(coP,ipP:integer;
          var CurID:integer);
Var i,ii:integer;flg,tmp:integer;ftmp:GLFloat;
Const speedmult=3;ERmult=5;Reduct=0.5;
procedure ReduceFloatController;//пропустить контроллер
Var tmp:integer;
Begin
  tmp:=M2ReadControllerf(1);
  if tmp>=0 then begin
   tmp:=length(Controllers)-1;
   if tmp<0 then tmp:=0;
   SetLength(Controllers,tmp);
  end;//of if
End;
//извлекает из 0 кадра последнего контроллера
//Data-число и убирает этот контроллер
function PopFloatValue:single;
Begin
 Result:=Controllers[High(Controllers)].Items[0].Data[1];
 SetLength(Controllers,High(Controllers));
End;
Begin
 CountOfParticleEmitters:=coP;
 SetLength(pre2,CountOfParticleEmitters);
 CountOfPivotPoints:=CountOfPivotPoints+coP;
 SetLength(PivotPoints,CountOfPivotPoints);
 pp:=ipP;
 for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
  //инициализация источника
  FillChar(pre2[i],SizeOf(pre2[i]),0);
  pre2[i].Speed:=cNone;
  pre2[i].Variation:=-1;pre2[i].Latitude:=cNone;
  pre2[i].Gravity:=cNone;
  pre2[i].LifeSpan:=cNone;pre2[i].EmissionRate:=cNone;
  pre2[i].Width:=0;pre2[i].Length:=0;
  pre2[i].BlendMode:=FullAlpha;
  pre2[i].Rows:=1;pre2[i].Columns:=1;
  pre2[i].ParticleType:=ptHead;
  pre2[i].TailLength:=cNone;pre2[i].Time:=cNone;
  pre2[i].PriorityPlane:=-1;
  pre2[i].IsSStatic:=true;pre2[i].IsVStatic:=true;
  pre2[i].IsLStatic:=true;pre2[i].IsGStatic:=true;
  pre2[i].IsEStatic:=true;pre2[i].IsWStatic:=true;
  pre2[i].IsHStatic:=true;
  pre2[i].LifeSpanUVAnim[3]:=1;
  pre2[i].DecayUVAnim[3]:=1;
  pre2[i].TailUVAnim[3]:=1;
  pre2[i].TailDecayUVAnim[3]:=1;
  pp:=pp+4;                       //пропуск ID
  flg:=ReadLong;                  //читать флаг линейности
  IsXYQuad:=(flg and $1000)<>0;
  IsLineEmitter:=true;
//  pre2[i].IsModelSpace:=true;
  //читаем позицию источника
  for ii:=1 to 3 do PivotPoints[CurID,ii]:=ReadFloat*wowmult;
  //Инициализируем "скелетные" поля источника
  InitTBone(Skel);
  Skel.ObjectID:=CurID;
  Skel.Parent:=ReadShort;         //родитель
  Skel.Name:='Particle_'+inttostr(i);
  TextureID:=ReadShort;           //ID текстуры
  //Пропуск неких списков
  pp:=pp+4*4;                     //4 поля

  //Режим смешения
  flg:=ReadShort;     //чтение
  case flg of
   0:BlendMode:=Opaque;
   1:BlendMode:=ColorAlpha;
   2:BlendMode:=FullAlpha;
   3:BlendMode:=Additive;
   4:begin BlendMode:=Additive;end;
   5:BlendMode:=Modulate;
   else BlendMode:=Additive;
  end;//of case

  pp:=pp+2;                       //пропуск формы частиц
  pp:=pp+2;                       //пропуск типа частиц
  pp:=pp+2;                       //TileRotation

  //колонки/строки
  Rows:=ReadShort;
  Columns:=ReadShort;
  
  //читаем набор анимационных параметров
  Speed:=M2ReadControllerf(1);
  IsSStatic:=(Speed<0);
  if Speed<-1 then Speed:=PopFloatValue*speedmult;
  Variation:=M2ReadControllerf(1);
  IsVStatic:=(Variation<0);
  if Variation<-1 then Variation:=PopFloatValue*100;
  Latitude:=M2ReadControllerf(1);
  IsLStatic:=(Latitude<0);
  if Latitude<-1 then Latitude:=PopFloatValue*57.29578*Reduct;
  //пропускаем контроллер
  ReduceFloatController;
  //продолжаем чтение. На очереди - гравитация
  Gravity:=M2ReadControllerf(1);
  IsGStatic:=(Gravity<0);
  if Gravity<-1 then Gravity:=PopFloatValue*wowmult*speedmult;
  if not IsGStatic then MultController(round(Gravity),wowmult*speedmult);
  LifeSpan:=M2ReadControllerf(1);//War не поддерживает анимацию
  LifeSpan:=PopFloatValue;
  EmissionRate:=M2ReadControllerf(1);
  IsEStatic:=(EmissionRate<0);
  if EmissionRate<-1 then EmissionRate:=PopFloatValue;
  if not IsEStatic then MultController(round(EmissionRate),ERmult);
  Length:=M2ReadControllerf(1);
  IsHStatic:=(Length<0);
  if Length<-1 then Length:=PopFloatValue*wowmult*Reduct;
  if not IsHStatic then MultController(round(Length),wowmult*Reduct);
  Width:=M2ReadControllerf(1);
  IsWStatic:=(Width<0);
  if Width<-1 then Width:=PopFloatValue*wowmult*Reduct;
  if not IsWStatic then MultController(round(Width),wowmult*Reduct);
//  tmp:=M2ReadControllerf(1);
//  if tmp<>-1 then Gravity:=Gravity+PopFloatValue;
  ReduceFloatController;          //пропуск Gravity2

  Time:=ReadFloat;                //серединная точка
  //Читаем цветовые составляющие
  for ii:=1 to 3 do begin
   tmp:=ReadLong;             
   SegmentColor[ii,1]:=(tmp and $0FF)/255;
   SegmentColor[ii,2]:=((tmp and $0FF00) shr 8)/255;
   SegmentColor[ii,3]:=((tmp and $0FF0000) shr 16)/255;
   Alpha[ii]:=(tmp and $FF000000) shr 24;
  end;//of for ii

  //Читаем размеры частиц
  for ii:=1 to 3 do ParticleScaling[ii]:=ReadFloat*wowmult*reduct;

  for ii:=1 to 3 do LifeSpanUVAnim[ii]:=ReadShort;
  for ii:=1 to 3 do DecayUVAnim[ii]:=ReadShort;
  pp:=pp+4*2;                    //пропуск ряда параметров
  pp:=pp+3*4;                     //3 float
  //Читаем Scaling2
//  for ii:=1 to 3 do ParticleScaling[ii]:=ReadFloat;
  pp:=pp+3*4;                     //Scaling2 (float)
  //Читаем SlowDown (нет аналогов в WC3).
  ftmp:=ReadFloat;
//  Gravity:=Gravity+((Speed/abs(Speed))*exp(-ftmp*LifeSpan))/LifeSpan;


  pp:=pp+1*4;                     //Rotation
  pp:=pp+10*4;                    //10 float
  pp:=pp+6*4;                     //6 float

  Skel.Visibility:=M2ReadControllerb(1);
  inc(CurID);
 end;//of for i
End;
//-------------------------------------------------------
//Вспомогательная:
//1. Читает тег
//2. Сравнивает его с указанной строкой
//3. Если не совпадает - выходит (возвр. false).
//4. Возвращает длину тега в tagLength
//5. Возвращает указатель на данные тега в pData
//6. Переходит к следующему тегу
//В случае успеха возвр. true
function GetTAGPointer(tag:string;var tagLength:integer;var p:pointer):boolean;
var s:string;
Begin
 s:=ReadASCII(4);
 if s<>tag then begin
  MessageBox(0,'Ошибка чтения тегов WMO.'#13#10+
               'Пришлите эту модель разработчику MdlVis.','Ошибка',MB_ICONSTOP);
  Result:=false;
 end else Result:=true;

 tagLength:=ReadLong;
 p:=pointer(pp);
 pp:=pp+tagLength;
End;
//-------------------------------------------------------
//Вспомогательная: делит треугольники геометрии WMO
//по поверхностям. Переиндексирование НЕ производится.
procedure WMOFormGeosetFaces(var w:TWMO;mt:PMOPY;fc:PMOVI;coFaces:integer);
Var i,ii,GeoID,OldGeoCount,len:integer;IsFound:boolean;
Begin
 OldGeoCount:=w.CountOfGeosets;
 for i:=0 to coFaces-1 do begin
  IsFound:=false;                 //пока что не найдено
  GeoID:=0;

  //1. Поиск поверхности с данным материалом
  for ii:=w.CountOfGeosets-1 downto OldGeoCount
  do if w.Geosets[ii].MaterialID=mt^[i*2+1] then begin //найдено!
   IsFound:=true;
   GeoID:=ii;                     //запомнить её ID
   break;
  end;

  //2. Если не найдена, создать её
  if not IsFound then begin
   inc(w.CountOfGeosets);
   SetLength(w.Geosets,w.CountOfGeosets);
   GeoID:=w.CountOfGeosets-1;
   w.Geosets[GeoID].MaterialID:=mt^[i*2+1];
   w.Geosets[GeoID].CountOfFaces:=1;
   SetLength(w.Geosets[GeoID].Faces,1);
   w.Geosets[GeoID].Faces[0]:=nil;
  end;//of if

  //3. Добавить в поверхность очередной треугольник
  len:=length(w.Geosets[GeoID].Faces[0]);
  SetLength(w.Geosets[GeoID].Faces[0],len+3);
  w.Geosets[GeoID].Faces[0,len]  :=fc^[i*3];
  w.Geosets[GeoID].Faces[0,len+1]:=fc^[i*3+1];
  w.Geosets[GeoID].Faces[0,len+2]:=fc^[i*3+2];
 end;//of for i
End;
//-------------------------------------------------------
//Вспомогательная: на основании индексов треугльников
//формирует массивы данных вершин (Vertices, Normals, TVertices)
//для каждой поверхности.
procedure WMOFormVerticesData(var w:TWMO;vt:PMOVT;mr:PMONR;tvt:PMOTV;
                              OldGeoCount,gHierID:integer);
Var b:array of boolean;
    i,ii,j,len,ind:integer;
Begin
 for i:=OldGeoCount to w.CountOfGeosets-1 do begin
  len:=length(w.Geosets[i].Faces[0]);
  SetLength(b,len);               //выделение памяти
  FillChar(b[0],len*sizeof(boolean),true);        //заполнить значением true

  //Переиндексирование с одновременным извлечением данных вершин
  w.Geosets[i].CountOfVertices:=0;
  w.Geosets[i].CountOfCoords:=1;  //1 текстурная плоскость
  SetLength(w.Geosets[i].Crds,1); //выделить под неё память
  for ii:=0 to len-1 do if b[ii] then with w.Geosets[i] do begin
   inc(CountOfVertices);          //увеличить кол-во вершин на 1
   SetLength(Vertices,CountOfVertices);
   SetLength(Normals,CountOfVertices);
   SetLength(Crds[0].TVertices,CountOfVertices);
   ind:=Faces[0,ii];              //читать индекс вершины в WMO
   //Читаем координаты вершины
   Vertices[CountOfVertices-1,1]:=vt^[ind*3]*wowmult;
   Vertices[CountOfVertices-1,2]:=vt^[ind*3+1]*wowmult; 
   Vertices[CountOfVertices-1,3]:=vt^[ind*3+2]*wowmult;
   //Читаем координаты нормали
   Normals[CountOfVertices-1,1]:=mr^[ind*3];
   Normals[CountOfVertices-1,2]:=mr^[ind*3+1];
   Normals[CountOfVertices-1,3]:=mr^[ind*3+2];
   //Читаем координаты текстурных вершин
   Crds[0].TVertices[CountOfVertices-1,1]:=tvt^[ind*2];
   Crds[0].TVertices[CountOfVertices-1,2]:=tvt^[ind*2+1];
   //Исправим индексы треугольников
   for j:=0 to len-1 do if b[j] and (Faces[0,j]=ind) then begin
    Faces[0,j]:=CountOfVertices-1;
    b[j]:=false;                  //уже обработано
   end;//of with/if/for j   
  end;//of if/for ii

  //Доустановить количественные поля поверхности
  with w.Geosets[i] do begin
   CountOfNormals:=CountOfVertices;
   Crds[0].CountOfTVertices:=CountOfVertices;
   SetLength(VertexGroup,CountOfVertices);
   FillChar(VertexGroup[0],CountOfVertices*4,0);
   SetLength(Groups,1);
   SetLength(Groups[0],1);
   Groups[0,0]:=0;
   SelectionGroup:=0;
   Unselectable:=false;
   CountOfMatrices:=1;
   HierID:=gHierID;
  end;//of with

 end;//of for i
End;
//-------------------------------------------------------
//Переносит все данные из TWMO в глобальные переменные модели
procedure WMOToModel(w:TWMO);
Begin
 Textures:=w.Textures;
 TextureAnims:=w.TextureAnims;
 Materials:=w.Materials;
 Geosets:=w.Geosets;
 Sequences:=w.Sequences;
 GlobalSequences:=w.GlobalSequences;
 GeosetAnims:=w.GeosetAnims;
 Bones:=w.Bones;
 Helpers:=w.Helpers;
 Attachments:=w.Attachments;
 PivotPoints:=w.PivotPoints;
 ParticleEmitters1:=w.ParticleEmitters1;
 pre2:=w.pre2;
 Ribs:=w.Ribs;
 Events:=w.Events;
 Cameras:=w.Cameras;
 Collisions:=w.Collisions;
 CountOfTextures:=w.CountOfTextures;
 CountOfMaterials:=w.CountOfMaterials;
 CountOfPivotPoints:=w.CountOfPivotPoints;
 CountOfTextureAnims:=w.CountOfTextureAnims;
 CountOfGeosets:=w.CountOfGeosets;
 CountOfGeosetAnims:=w.CountOfGeosetAnims;
 CountOfLights:=w.CountOfLights;
 CountOfHelpers:=w.CountOfHelpers;
 CountOfBones:=w.CountOfBones;
 CountOfAttachments:=w.CountOfAttachments;
 CountOfParticleEmitters1:=w.CountOfParticleEmitters1;
 CountOfParticleEmitters:=w.CountOfParticleEmitters;
 CountOfRibbonEmitters:=w.CountOfRibbonEmitters;
 CountOfEvents:=w.CountOfEvents;
 CountOfCameras:=w.CountOfCameras;
 CountOfCollisionShapes:=w.CountOfCollisionShapes;
 BlendTime:=w.BlendTime;
 CountOfSequences:=w.CountOfSequences;
 CountOfGlobalSequences:=w.CountOfGlobalSequences;
 AnimBounds:=w.AnimBounds;
 Lights:=w.Lights;
 Controllers:=w.Controllers;
 ModelName:=w.ModelName;
End;
//-------------------------------------------------------
//Добавляет к W содержимое, считанное из указанного GroupWMO.
//W предварительно инициализируется из Root WMO
//При ошибке имя файла добавляется к err с указанием причины ошибки
procedure OpenGroupWMO(var w:TWMO;fname:string;var err:string;gHierID:integer);
Var {i,}itmp,tagLength,tagNext,CountOfTriangles,
    coLights,coDoodads,OldGeoCount:integer;
    s:string;tmp:PChar; pt:pointer;
    IsLights,IsDoodads:boolean;
    mt:PMOPY; fc,li,di:PMOVI; vt:PMOVT; nr:PMONR; tvt:PMOTV;
Begin
 //Проверяем, существует ли указанный WMO--файл
 if SearchPath(nil,PChar(fname),nil,0,nil,tmp)=0 then begin
  err:=err+#13#10+fname;          //пополнить список не найденных файлов
  exit;
 end;//of if

 //Откроем его и прочтём
 assignFile(f,fname);
 reset(f,1);                      //побайтовое чтение
 GetMem(w.pGroup,FileSize(f)+8);   //выделяем с резервом
 BlockRead(f,w.pGroup^,FileSize(f));
 CloseFile(f);
 p:=w.pGroup;
 pp:=integer(p);

 //Итак, групповой файл открыт. Проверим его тип.
 s:=ReadASCII(4);                 //читаем MagID заголовка
 if s<>'REVM' then begin          //ошибка: это не WMO-модель
  err:=err+#13#10+fname+' [Неверный формат]';
  FreeMem(w.pGroup);
  exit;
 end;//of if

 pp:=pp+8;                        //на первый тег
 s:=ReadASCII(4);
 if s<>'PGOM' then begin
  err:=err+#13#10+fname+' [Неверный формат]';
  FreeMem(w.pGroup);
  exit;
 end;//of if

 //Формат верен.
 //2. Анализ тега MOGP:
 pp:=pp+4;                        //пропуск длины
 tagLength:=68;                   //длина самого заголовка
 tagNext:=pp+tagLength;           //адрес следующего тега
 pp:=pp+8;                        //пропуск имён групп
 itmp:=ReadLong;                  //чтение флагов
 IsLights:=(itmp and $200)<>0;
 IsDoodads:=(itmp and $800)<>0;

 //3. Установка указателей на данные геометрии.
 //a. Материалы треугольников
 pp:=tagNext;
 if not GetTAGPointer('YPOM',tagLength,pt) then begin
  FreeMem(w.pRoot);
  exit;
 end;//of if
 mt:=pt;
 CountOfTriangles:=tagLength shr 1; //кол-во треугольников в модели

 //б. Индексы вершин в треугольниках
 if not GetTAGPointer('IVOM',tagLength,pt) then begin
  FreeMem(w.pGroup);
  exit;
 end;//of if
 fc:=pt;

 //в. Данные вершин
 if not GetTAGPointer('TVOM',tagLength,pt) then begin
  FreeMem(w.pGroup);
  exit;
 end;//of if
 vt:=pt;

 //г. Нормали
 if not GetTAGPointer('RNOM',tagLength,pt) then begin
  FreeMem(w.pGroup);
  exit;
 end;//of if
 nr:=pt;

 //д. Текстурные координаты
 if not GetTAGPointer('VTOM',tagLength,pt) then begin
  FreeMem(w.pGroup);
  exit;
 end;//of if
 tvt:=pt;

 //е. Пакеты пока пропускаем
 s:=ReadASCII(4);                 //заголовок тега
 tagLength:=ReadLong;             //его длина
 if s='ABOM' then pp:=pp+tagLength
             else pp:=pp-8;       //возврат к тегу

 //ж. Индексы источников света (если есть):
 coLights:=0;
 if IsLights then begin           //есть тег источников
  if not GetTAGPointer('RLOM',tagLength,pt) then begin
   FreeMem(w.pGroup);
   exit;
  end;//of if
  li:=pt;
  coLights:=tagLength shr 1;      //кол-во источников света
 end;//of if (IsLights)

 //и. Индексы декораций (если есть):
 coDoodads:=0;
 if IsDoodads then begin
  if not GetTAGPointer('RDOM',tagLength,pt) then begin
   FreeMem(w.pGroup);
   exit;
  end;//of if
  di:=pt;
  coDoodads:=tagLength shr 1;     //кол-во декораций
 end;//of if (IsDoodads)

 //4. Читаем внутреннюю WMO-геометрию (разбивая на поверхности)
 OldGeoCount:=w.CountOfGeosets;
 WMOFormGeosetFaces(w,mt,fc,CountOfTriangles); //разбить по поверхностям
 WMOFormVerticesData(w,vt,nr,tvt,OldGeoCount,gHierID);//считать данные вершин

 FreeMem(w.pGroup);               //освободить память
 //debug: скопировать в модель
// WMOToModel(w);                   //перенести данные TWMO в основную модель
End;
//-------------------------------------------------------
//Читает указанное кол-во источников света из Root WMO.
//pp должен быть настроен на начало данных
procedure WMOReadLights(var w:TWMO;coLights:integer;var LastObjID:integer);
Var i,tmp:integer;ftmp:GLFloat;
const C_DV=1/255;
Begin
 if coLights=0 then exit;
 w.CountOfLights:=coLights;
 SetLength(w.Lights,coLights);
 i:=0;
 repeat with w.Lights[i] do begin
  //1. Читаем и анализируем тип источника
  tmp:=ReadByte;                  //чтение
  case tmp of
   0:LightType:=Omnidirectional;
   2:LightType:=Directional;
   3:LightType:=Ambient;
   else begin                     //точечный источник, пропустить
    pp:=pp+47;
    dec(w.CountOfLights);
   end;
  end;
  pp:=pp+3;                       //пропуск полей типа

  //2. Читаем цвета источника
  Color[1]:=ReadByte*C_DV;
  Color[2]:=ReadByte*C_DV;
  Color[3]:=ReadByte*C_DV;
  ftmp:=ReadByte*C_DV;
  Color[1]:=Color[1]*ftmp;
  Color[2]:=Color[2]*ftmp;
  Color[3]:=Color[3]*ftmp;

  //3. Читаем позицию источника света и формируем его "скелет"
  inc(w.CountOfPivotPoints);
  SetLength(w.PivotPoints,w.CountOfPivotPoints);
  w.PivotPoints[LastObjID,1]:=ReadFloat*wowmult;
  w.PivotPoints[LastObjID,2]:=ReadFloat*wowmult;
  w.PivotPoints[LastObjID,3]:=ReadFloat*wowmult;
  FillChar(Skel,sizeof(TBone),0);
  Skel.Name:='Light'+inttostr(i);
  Skel.ObjectID:=LastObjID;
  Skel.GeosetID:=-1;
  Skel.GeosetAnimID:=-1;
  Skel.Parent:=-1;
  Skel.Translation:=-1;
  Skel.Rotation:=-1;
  Skel.Scaling:=-1;
  Skel.Visibility:=-1;
  inc(LastObjID);

  //4. Читаем ещё ряд параметров источника света
  Intensity:=ReadFloat;
  AttenuationStart:=ReadFloat*wowmult;
  AttenuationEnd:=ReadFloat*wowmult;

  pp:=pp+4*4;                     //пропуск полей

  //5. Доустановка оставшихся параметров источника
  AmbIntensity:=0;
  AmbColor[1]:=1; AmbColor[2]:=1; AmbColor[3]:=1;
  IsASStatic:=true;
  IsAEStatic:=true;
  IsIStatic:=true;
  IsCStatic:=true;
  IsAIStatic:=true;
  IsACStatic:=true;

  inc(i);
 end; until i=w.CountOfLights;
 SetLength(w.Lights,w.CountOfLights);//переустановка размера массива
End;
//-------------------------------------------------------
//Вспомогательная: осуществляет преобразование вершины
//(масштабирование, поворот, перенос)
procedure TransformVertex(var v:TVertex;rot:TRotMatrix;sc:GLFloat;ps:TVertex);
Var vx,vy,vz:GLFloat;
Begin
 v[1]:=v[1]*sc;                   //масштабирование
 v[2]:=v[2]*sc;
 v[3]:=v[3]*sc;

 //поворот
 vx:=v[1]*rot[0,0]+v[2]*rot[1,0]+v[3]*rot[2,0];
 vy:=v[1]*rot[0,1]+v[2]*rot[1,1]+v[3]*rot[2,1];
 vz:=v[1]*rot[0,2]+v[2]*rot[1,2]+v[3]*rot[2,2];

 //перенос
 v[1]:=vx+ps[1];
 v[2]:=vy+ps[2];
 v[3]:=vz+ps[3];
End;
//-------------------------------------------------------
//Вспомогательная: сдвигает кадры контроллера так, чтобы
//анимация начиналась с 0 (для последующей глобальной аним.)
procedure GlobalizeController(c:TController);
Var i,len,sb:integer;
Begin
 len:=High(c.Items);
 sb:=c.Items[0].Frame;
 for i:=0 to len do c.Items[i].Frame:=c.Items[i].Frame-sb;
End;
//-------------------------------------------------------
//Добавляет геометрию/материалы из текущей открытой модели
//в TWMO. rot - матрица поворота
//ps - позиция (точка "0") для импортируемой геометрии
//sc - фактор масштаба
procedure WMOAddFromModel(var w:TWMO;rot:TRotMatrix;ps:TVertex;sc:GLFLoat;
                          HierID:integer;var LastObjID:integer);
Var i,ii,coTextures,coMaterials,coTexAnims,coGeosets,
    coControllers,coLights,coEmitters,coGeosetAnims,
    FrameMax,FrNum,len,len2:integer;
Begin
 coTextures:=w.CountOfTextures;
 coMaterials:=w.CountOfMaterials;
 coTexAnims:=w.CountOfTextureAnims;
 coGeosets:=w.CountOfGeosets;
 coLights:=w.CountOfLights;
 coEmitters:=w.CountOfParticleEmitters;
 coGeosetAnims:=w.CountOfGeosetAnims;
 coControllers:=length(w.Controllers);
 //1. Увеличим размеры массивов
 w.CountOfTextures:=w.CountOfTextures+CountOfTextures;
 w.CountOfMaterials:=w.CountOfMaterials+CountOfMaterials;
 w.CountOfGeosets:=w.CountOfGeosets+CountOfGeosets;
 w.CountOfTextureAnims:=w.CountOfTextureAnims+CountOfTextureAnims;
// w.CountOfLights:=w.CountOfLights+CountOfLights;
// w.CountOfParticleEmitters:=w.CountOfParticleEmitters+CountOfParticleEmitters;
 w.CountOfGeosetAnims:=w.CountOfGeosetAnims+CountOfGeosetAnims;
 SetLength(w.Textures,w.CountOfTextures);
 SetLength(w.Materials,w.CountOfMaterials);
 SetLength(w.TextureAnims,w.CountOfTextureAnims);
 SetLength(w.Geosets,w.CountOfGeosets);
 SetLength(w.GeosetAnims,w.CountOfGeosetAnims);
// SetLength(w.Lights,w.CountOfLights);
// SetLength(w.pre2,w.CountOfParticleEmitters);

 //2. Скопируем объекты (текстуры и материалы)
 for i:=coTextures to w.CountOfTextures-1
 do w.Textures[i]:=Textures[i-coTextures];
 
 for i:=coMaterials to w.CountOfMaterials-1 do begin
  w.Materials[i]:=Materials[i-coMaterials];
  FillChar(Materials[i-coMaterials],sizeof(TMaterial),0);
  for ii:=0 to w.Materials[i].CountOfLayers-1
  do with w.Materials[i].Layers[ii] do begin
   //Превращаем анимированные параметры в статические
   if not IsTextureStatic then begin
    TextureID:=round(Controllers[NumOfTexGraph].Items[0].Data[1]);
    IsTextureStatic:=true;
   end;//of if
   if not IsAlphaStatic then begin
    Alpha:=1;
    IsAlphaStatic:=true;
   end;//of if
   TextureID:=TextureID+coTextures;
   TVertexAnimID:=TVertexAnimID+coTexAnims;
  end;//of with/for
 end;//of for i

 //3. Скопируем текстурные анимации (если таковые есть):
 for i:=coTexAnims to w.CountOfTextureAnims-1 do begin
  w.TextureAnims[i]:=TextureAnims[i-coTexAnims];
  FrameMax:=0;                    //пока нет кадров
  //Теперь копируем контроллеры и создаём глоб. последовательности
  if w.TextureAnims[i].TranslationGraphNum>=0 then begin
   len:=length(w.Controllers)+1;
   SetLength(w.Controllers,len);
   cpyController(Controllers[w.TextureAnims[i].TranslationGraphNum],
                 w.Controllers[len-1]);
   GlobalizeController(w.Controllers[len-1]);
   FrNum:=w.Controllers[len-1].Items[High(w.Controllers[len-1].Items)].Frame;
   w.Controllers[len-1].GlobalSeqId:=w.CountOfGlobalSequences;
   if FrNum>FrameMax then FrameMax:=FrNum;
   w.TextureAnims[i].TranslationGraphNum:=len-1;
  end;//of if(Translation)
  if w.TextureAnims[i].RotationGraphNum>=0 then begin
   len:=length(w.Controllers)+1;
   SetLength(w.Controllers,len);
   cpyController(Controllers[w.TextureAnims[i].RotationGraphNum],
                 w.Controllers[len-1]);
   GlobalizeController(w.Controllers[len-1]);
   FrNum:=w.Controllers[len-1].Items[High(w.Controllers[len-1].Items)].Frame;
   w.Controllers[len-1].GlobalSeqId:=w.CountOfGlobalSequences;
   if FrNum>FrameMax then FrameMax:=FrNum;
   w.TextureAnims[i].RotationGraphNum:=len-1;
  end;//of if(Rotation)
  if w.TextureAnims[i].ScalingGraphNum>=0 then begin
   len:=length(w.Controllers)+1;
   SetLength(w.Controllers,len);
   cpyController(Controllers[w.TextureAnims[i].ScalingGraphNum],
                 w.Controllers[len-1]);
   GlobalizeController(w.Controllers[len-1]);
   FrNum:=w.Controllers[len-1].Items[High(w.Controllers[len-1].Items)].Frame;
   w.Controllers[len-1].GlobalSeqId:=w.CountOfGlobalSequences;
   if FrNum>FrameMax then FrameMax:=FrNum;
   w.TextureAnims[i].ScalingGraphNum:=len-1;
  end;//of if(Scaling)

  //Теперь создаём глобальную последовательность
  inc(w.CountOfGlobalSequences);
  SetLength(w.GlobalSequences,w.CountOfGlobalSequences);
  w.GlobalSequences[w.CountOfGlobalSequences-1]:=FrameMax;
 end;//of for i

 //4. Копируем поверхности (частично)
 for i:=coGeosets to w.CountOfGeosets-1 do begin
  w.Geosets[i]:=Geosets[i-coGeosets];
  FillChar(Geosets[i-coGeosets],SizeOf(TGeoset),0);
  for ii:=0 to w.Geosets[i].CountOfVertices-1 do begin
   TransformVertex(w.Geosets[i].Vertices[ii],rot,sc,ps);
//   TransformVertex(w.Geosets[i].Normals[ii],rot,sc,ps);
  end;//of for ii
  w.Geosets[i].MaterialID:=w.Geosets[i].MaterialID+coMaterials;
  w.Geosets[i].HierID:=HierID;
 end;//of for i

 //Копируем источники света и частиц
 //(пока не реализовано)
{ w.CountOfPivotPoints:=w.CountOfPivotPoints+CountOfLights+
                       CountOfParticleEmitters;
 SetLength(w.PivotPoints,w.CountOfPivotPoints);
 for i:=coLights to w.CountOfLights-1 do begin
  w.Lights[i]:=Lights[i-coLights];
  w.Lights[i].Skel.Name:='Light_'+inttostr(i);
  w.Lights[i]
 end;//of for i}

 //Копируем анимации видимости
 for i:=coGeosetAnims to w.CountOfGeosetAnims-1 do begin
  w.GeosetAnims[i]:=GeosetAnims[i-coGeosetAnims];
  w.GeosetAnims[i].GeosetID:=i;
  if not w.GeosetAnims[i].IsAlphaStatic then begin
   w.GeosetAnims[i].Alpha:=1;
   w.GeosetAnims[i].IsAlphaStatic:=true;
   w.GeosetAnims[i].AlphaGraphNum:=-1;
  end;//of if (AlphaStatic)
  if not w.GeosetAnims[i].IsColorStatic then begin
   w.GeosetAnims[i].Color[1]:=
     Controllers[w.GeosetAnims[i].ColorGraphNum].Items[0].Data[1];
   w.GeosetAnims[i].Color[2]:=
     Controllers[w.GeosetAnims[i].ColorGraphNum].Items[0].Data[2];
   w.GeosetAnims[i].Color[3]:=
     Controllers[w.GeosetAnims[i].ColorGraphNum].Items[0].Data[3];
   w.GeosetAnims[i].IsColorStatic:=true;
   w.GeosetAnims[i].ColorGraphNum:=-1;  
  end;//of if
 end;//of for i
End;
//-------------------------------------------------------
//Открывает wmo-файлы (только RootWMO).
//Является обёрткой для OpenGroupWMO.
//Изменить имя файла для сохранения нужно отдельно.
//В случае успеха возвращает пустую строку.
//Если есть какие-то ошибки/предупреждения,
//возвр. их текст.
function OpenWMO(fname:string):string;
type TDoodad=record               //тип массива для хранения преобразований дек.
 Name,ShortName:string;
 Position:TVertex;
 Orient:TRotMatrix;
 Scale:GLFloat;
end;//of type
Var w:TWMO;s,s2,fnf,sTextures,sDoodads,fpath:string;
    cTmp:PChar;
    coTextures,coGroups,coLights,coModels,coDoodads,coSets,
    i,ii,j,tmp,tmp2,tagNext,tagLength,LastObjID:integer;
    ptmp:pointer;
    q:TQuaternion;
    Min,Max:TVertex;              //для расчёта границ модели
    br:GlFloat;                   //граничный радиус
    matColors:array of TVertex;   //цвета материалов (RGB)
    matAlpha:array of GLFloat;    //прозрачности мат.
    ddata:array of TDoodad;       //данные о декорациях
Begin
 Result:='';                      //пока всё нормально

 //1. Прежде всего, откроем файл
 assignFile(f,fname);
 reset(f,1);                      //побайтовое чтение
 //2. Выделить память под файл
 GetMem(p,FileSize(f)+8);         //выделяем с резервом
 //3. Прочесть весь файл в память
 BlockRead(f,p^,FileSize(f));
 //4. Закрыть файл
 CloseFile(f);
// Controllers:=nil;
 FileContent:='';   //пока информации нет
 //Дополнительная инициализация:
//------------------Собственно чтение----------
 LastObjID:=0;                    //нет объектов
 FillChar(w,SizeOf(w),0);         //сбрасываем поля WMO
 w.pRoot:=p;                      //указатель на Root
 pp:=integer(p);                  //получить адрес
 w.ppRoot:=pp;                    //ещё одно сохранение
 //1. Проверим, действительно ли это модель WoW-WMO-Root:
 s:=ReadASCII(4);                 //читаем MagID заголовка
 if s<>'REVM' then begin          //ошибка: это не WMO-модель
  FreeMem(p);
  MessageBox(0,'Неверный формат модели',scError,mb_iconstop);
  exit;
 end;//of if

 //2. Определяем тип модели
 pp:=pp+8;                        //на первый тег
 s:=ReadASCII(4);
 if s<>'DHOM' then begin          //не Root-WMO
  FreeMem(p);
  MessageBox(0,'Неверный формат модели (Group WMO)',scError,mb_iconstop);
  exit;
 end;//of if
 tmp:=ReadLong;                   //пропуск длины
 tagNext:=pp+64;                  //указатель на следующий тег

 //3. Читаем заголовок (тег MOHD)
 coTextures:=ReadLong;            //текстуры
 coGroups:=ReadLong;
 pp:=pp+4;                        //пропуск порталов
 coLights:=ReadLong;
 coModels:=ReadLong;
 coDoodads:=ReadLong;
 coSets:=ReadLong;

 //4. Копирование списка текстур в единую строку
 pp:=tagNext;
 if not GetTAGPointer('XTOM',tagLength,ptmp) then begin
  FreeMem(w.pRoot);
  exit;
 end;//of if
 SetLength(sTextures,tagLength);
 Move(ptmp^,sTextures[1],tagLength); //копирование

 //5. Формируем секции текстур и материалов
 s:=ReadASCII(4);                 //читать очередной тег
 if s<>'TMOM' then begin
  MessageBox(0,'Ошибка чтения тегов WMO.'#13#10+
               'Пришлите эту модель разработчику MdlVis.','Ошибка',MB_ICONSTOP);
  FreeMem(w.pRoot);
  exit;             
 end;//of if
 tagLength:=ReadLong;
 tagNext:=pp+tagLength;
 w.CountOfTextures:=coTextures;
 w.CountOfMaterials:=coTextures;
 SetLength(w.Textures,coTextures);
 SetLength(w.Materials,coTextures);
 SetLength(matColors,coTextures+1); //+резервный белый цвет
 SetLength(matAlpha,coTextures+1);    //+резервная Alpha=1
 for i:=0 to coTextures-1 do begin //читаем 64-байтные записи
  FillChar(w.Materials[i],sizeof(TMaterial),0);
  w.Materials[i].PriorityPlane:=-1;
  w.Materials[i].CountOfLayers:=1;
  SetLength(w.Materials[i].Layers,1);
  FillChar(w.Materials[i].Layers[0],SizeOf(TLayer),0);
  w.Materials[i].IsConstantColor:=true;
  with w.Materials[i].Layers[0] do begin
   tmp:=ReadLong;                 //читаем флаги
   IsTwoSided:=(tmp and 4)<>0;
   IsUnshaded:=(tmp and $10)<>0;
   pp:=pp+4;                      //пропуск поля (???)
   tmp:=ReadLong;                 //читать режим смешения
   if tmp=0 then FilterMode:=Opaque else FilterMode:=Transparent;
   //Читаем позиции текстурных имён
   tmp:=ReadLong;
   pp:=pp+8;
   tmp2:=ReadLong;
   FillChar(w.Textures[i],sizeof(TTexture),0);
   w.Textures[i].ReplaceableID:=0;
   w.Textures[i].FileName:=copy(sTextures,tmp+1,tmp2-tmp+1);
   //Удаляем нулевые символы из текстурного имени
   while pos(#0,w.Textures[i].FileName)<>0
   do Delete(w.Textures[i].FileName,pos(#0,w.Textures[i].FileName),1);
   w.Textures[i].IsWrapWidth:=true;
   w.Textures[i].IsWrapHeight:=true;
   //Читаем цвета материала
   matColors[i,1]:=ReadByte/255;
   matColors[i,2]:=ReadByte/255;
   matColors[i,3]:=ReadByte/255;
   matAlpha[i]:=ReadByte/255;
   //Доустанавливаем поля
   TextureID:=i;
   IsTextureStatic:=true;
   Alpha:=1.0;
   IsAlphaStatic:=true;
   NumOfGraph:=-1;
   NumOfTexGraph:=-1;
   TVertexAnimID:=-1;
   CoordID:=-1;
  end;//of with
  pp:=pp+$20;
 end;//of for i
 //Дополняем резервными цветом/видимостью
 matColors[coTextures,1]:=1;
 matColors[coTextures,2]:=1;
 matColors[coTextures,3]:=1;
 matAlpha[coTextures]:=1;

 //Пропуск всех неподходящих тегов
 repeat                           //цикл пропуска
  pp:=tagNext;
  s:=ReadASCII(4);                //читать имя тега
  tagLength:=ReadLong;
  tagNext:=pp+tagLength;
 until (s='TLOM') or (s='NDOM') or (s='DDOM') or
       (s='GOFM') or (s='PVCM');

 //Создать root-кость (для последующего крепления всех поверхностей)
 LastObjID:=1;                    //0 уже занят
 w.CountOfPivotPoints:=1;
 SetLength(w.PivotPoints,1);      //1 центр
 FillChar(w.PivotPoints[0],sizeof(TVertex),0);
 w.CountOfBones:=1;
 SetLength(w.Bones,1);
 FillChar(w.Bones[0],SizeOf(TBone),0);
 w.Bones[0].Name:='bone_root';
 w.Bones[0].GeosetID:=Multiple;
 w.Bones[0].GeosetAnimID:=None;
 w.Bones[0].Parent:=-1;
 w.Bones[0].Translation:=-1;
 w.Bones[0].Rotation:=-1;
 w.Bones[0].Scaling:=-1;
 w.Bones[0].Visibility:=-1;

 //Читаем источники света (если они есть)
 if s='TLOM' then begin
  WMOReadLights(w,coLights,LastObjID);
  pp:=tagNext;
  s:=ReadASCII(4);
  tagLength:=ReadLong;
  tagNext:=pp+tagLength;
 end;//of if
 if s='SDOM' then begin           //пропуск наборов декораций
  pp:=tagNext;
//  s:=ReadASCII(4);
//  tagLength:=ReadLong;
//  tagNext:=pp+tagLength;
 end;//of if

 if coDoodads<>0 then begin       //читаем теги, если есть декорации
  //Копируем (если возможно) имена M2 в единую строку
  if not GetTAGPointer('NDOM',tagLength,ptmp) then begin
   FreeMem(w.pRoot);
   exit;
  end;//of if
  SetLength(sDoodads,tagLength);
  Move(ptmp^,sDoodads[1],tagLength); //копирование

  //Читаем данные о каждой декорации
  if not GetTAGPointer('DDOM',tagLength,ptmp) then begin
   FreeMem(w.pRoot);
   exit;
  end;//of if
  //Учесть, что в силу некоторых причин декораций может быть меньше,
  //чем указано в заголовке:
  if (tagLength div 40)<coDoodads then coDoodads:=tagLength div 40;
  //Выделяем память под данные
  SetLength(ddata,coDoodads);
  pp:=integer(ptmp);
  for i:=0 to coDoodads-1 do with ddata[i] do begin //цикл чтения данных
   tmp:=ReadLong;                 //смещение имени модели
   Name:='';
   while (tmp<length(sDoodads)) and (sDoodads[tmp+1]<>'.') do begin
    Name:=Name+sDoodads[tmp+1];
    inc(tmp);
   end;//of while
   Name:=Name+'.m2';
   ShortName:=Name;
   while pos('\',ShortName)<>0 do Delete(ShortName,1,pos('\',ShortName));

   for ii:=1 to 3 do Position[ii]:=ReadFloat*wowmult; //позиция
//   q.w:=ReadFloat;
   q.x:=ReadFloat;
   q.y:=ReadFloat;
   q.z:=ReadFloat;
   q.w:=ReadFloat;
   QuaternionToMatrix(q,Orient);
   Scale:=ReadFloat;
   pp:=pp+4;                      //пропуск подцветки
  end;//of with/for i
 end;//of if (coDoodads<>0)

 //Производим конверсию всех GroupWMO:
 w.ppSV:=pp;                      //сохраним указатель (debug)
 fnf:='';                         //пока нет не найденных файлов
 for i:=0 to coGroups-1 do begin
  //Генерация префикса имени
  s:=inttostr(i);
  while length(s)<3 do s:='0'+s;
  s:='_'+s;
  s2:=fname;
  insert(s,s2,length(s2)-3);      //имя_XXX.wmo
  OpenGroupWMO(w,s2,fnf,-i-10);   //читать этот файл
 end;//of for i

 //Смотрим, что там со спец. материалами.
 //Поверхности с таким материалом лучше удалить
 //(выглядят отвратно - возможно, предназначены для служебных целей).
 //Тем не менее, блок кода создания такого материала
 //пока не удаляю (закомментировано)
 i:=0;
 while i<w.CountOfGeosets do begin
  if w.Geosets[i].MaterialID=255 then begin
   for ii:=i to w.CountOfGeosets-2 do w.Geosets[ii]:=w.Geosets[ii+1];
   dec(w.CountOfGeosets);
   SetLength(w.Geosets,w.CountOfGeosets);
   continue;
  end;//of if
  inc(i);
 end;//of while


{ //Смотрим, что там с материалами - нет ли "Специальных"
 for i:=0 to w.CountOfGeosets-1 do if w.Geosets[i].MaterialID=255 then begin
  //Создать дополнительную текстуру
  inc(w.CountOfTextures);
  SetLength(w.Textures,w.CountOfTextures);
  w.Textures[coTextures].FileName:=
                        'ReplaceableTextures\TeamColor\TeamColor08.blp';
  w.Textures[coTextures].ReplaceableID:=0;
  w.Textures[coTextures].IsWrapWidth:=true;
  w.Textures[coTextures].IsWrapHeight:=true;
  //Создать дополнительный материал
  inc(w.CountOfMaterials);
  SetLength(w.Materials,w.CountOfMaterials);
  with w.Materials[coTextures] do begin
   IsConstantColor:=true;
   IsSortPrimsFarZ:=false;
   IsFullResolution:=false;
   PriorityPlane:=-1;
   CountOfLayers:=1;
   SetLength(Layers,1);
   Layers[0].FilterMode:=Additive;
   Layers[0].IsUnshaded:=true;
   Layers[0].IsTwoSided:=true;
   Layers[0].IsUnfogged:=false;
   Layers[0].IsSphereEnvMap:=false;
   Layers[0].IsNoDepthTest:=false;
   Layers[0].IsNoDepthSet:=false;
   Layers[0].TextureID:=coTextures;
   Layers[0].IsTextureStatic:=true;
   Layers[0].Alpha:=1;
   Layers[0].IsAlphaStatic:=true;
   Layers[0].NumOfGraph:=-1;
   Layers[0].NumOfTexGraph:=-1;
   Layers[0].TVertexAnimID:=-1;
   Layers[0].CoordID:=-1;
   for j:=i to w.CountOfGeosets-1
   do if w.Geosets[j].MaterialID=255 then w.Geosets[j].MaterialID:=coTextures;
  end;//of with
  break;
 end;//of for i}

 //Создаём анимации видимости
 w.CountOfGeosetAnims:=w.CountOfGeosets;
 SetLength(w.GeosetAnims,w.CountOfGeosetAnims);
 for i:=0 to w.CountOfGeosetAnims-1 do with w.GeosetAnims[i] do begin
  Alpha:=matAlpha[w.Geosets[i].MaterialID];
  Color:=matColors[w.Geosets[i].MaterialID];
  GeosetID:=i;
  IsAlphaStatic:=true;
  IsColorStatic:=true;
  IsDropShadow:=false;
  AlphaGraphNum:=-1;
  ColorGraphNum:=-1;
 end;//of for i

 //Теперь произведём импорт геометрии всех декораций
 for i:=0 to coDoodads-1 do with ddata[i] do begin
  //1. Проверим, существует ли данный файл
  fpath:=fname;
  while fpath[length(fpath)]<>'\' do Delete(fpath,length(fpath),1);
  if SearchPath(nil,PChar(fpath+ShortName),nil,0,nil,ctmp)=0 then begin
   fnf:=fnf+#13#10+Name;          //пополнить список не найденных файлов
//    exit;
  end else begin                 //файл существует. Импортируем!
   OpenM2(fpath+ShortName);      //собственно открытие
   if CountOfGeosets=0 then fnf:=fnf+#13#10+Name+' [Ошибка]'
   else WMOAddFromModel(w,ddata[i].Orient,ddata[i].Position,ddata[i].Scale,
                        -i-1010,LastObjID);
  end;//of if (существует ли файл)
 end;//of for i

 //Теперь доформировываем поверхности
 for i:=0 to w.CountOfGeosets-1 do with w.Geosets[i] do begin
  SetLength(VertexGroup,CountOfVertices);
  FillChar(VertexGroup[0],CountOfVertices*4,0);
  SetLength(Groups,1);
  SetLength(Groups[0],1);
  Groups[0,0]:=0;                 //единственная root-кость
  SetLength(Anims,1);
  CountOfAnims:=1;
  CountOfMatrices:=1;
 end;//of for i

 //Создать единственную анимацию Stand
 w.CountOfSequences:=1;
 SetLength(w.Sequences,1);
 with w.Sequences[0] do begin
  Name:='Stand';
  IntervalStart:=10;
  IntervalEnd:=1010;
  Rarity:=-1;
  IsNonLooping:=false;
  MoveSpeed:=-1;
 end;//of with

 //Доводим до ума массивы
 SetLength(VisGeosets,w.CountOfGeosets);
 for i:=0 to w.CountOfGeosets-1 do VisGeosets[i]:=true;
 //Копируем в модель
 WMOToModel(w);

 //Рассчитываем границы и доформировываем поля модели
 Min[1]:= 1e6;Min[2]:= 1e6;Min[3]:=1e6;
 Max[1]:=-1e6;Max[2]:=-1e6;Max[3]:=-1e6;
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  CalcBounds(i,Geosets[i].Anims[0]);
  if Anims[0].MaximumExtent[1]>Max[1] then Max[1]:=Anims[0].MaximumExtent[1];
  if Anims[0].MaximumExtent[2]>Max[2] then Max[2]:=Anims[0].MaximumExtent[2];
  if Anims[0].MaximumExtent[3]>Max[3] then Max[3]:=Anims[0].MaximumExtent[3];
  if Anims[0].MinimumExtent[1]<Min[1] then Min[1]:=Anims[0].MinimumExtent[1];
  if Anims[0].MinimumExtent[2]<Min[2] then Min[2]:=Anims[0].MinimumExtent[2];
  if Anims[0].MinimumExtent[3]<Min[3] then Min[3]:=Anims[0].MinimumExtent[3];
  if Anims[0].MaximumExtent[1]<Min[1] then Min[1]:=Anims[0].MaximumExtent[1];
  if Anims[0].MaximumExtent[2]<Min[2] then Min[2]:=Anims[0].MaximumExtent[2];
  if Anims[0].MaximumExtent[3]<Min[3] then Min[3]:=Anims[0].MaximumExtent[3];
  if Anims[0].MinimumExtent[1]>Max[1] then Max[1]:=Anims[0].MinimumExtent[1];
  if Anims[0].MinimumExtent[2]>Max[2] then Max[2]:=Anims[0].MinimumExtent[2];
  if Anims[0].MinimumExtent[3]>Max[3] then Max[3]:=Anims[0].MinimumExtent[3];
  MinimumExtent:=Anims[0].MinimumExtent;
  MaximumExtent:=Anims[0].MaximumExtent;
  BoundsRadius:=Anims[0].BoundsRadius;
  ReCalcNormals(i+1);
 end;//of for i
 AnimBounds.MinimumExtent:=Min;
 AnimBounds.MaximumExtent:=Max;
 AnimBounds.BoundsRadius:=sqrt(sqr(Max[1]-Min[1])+sqr(Max[2]-Min[2])+
                          sqr(Max[3]-Min[3]))*0.5;
 Sequences[0].Bounds:=AnimBounds;
 ModelName:=fname;
 while pos('\',ModelName)<>0 do Delete(ModelName,1,pos('\',ModelName));
 ModelName[pos('.',ModelName)]:='_';

 //Оптимизация
 ReduceRepTextures;               //удалить повт. текстуры
 ReduceRepMaterials;              //удалить повт. материалы

 //Освобождаем память
 Freemem(w.pRoot);
 //Конвертируем все текстуры, исп. моделью:
 M2ConvertTextures('__$$$___',fname);

{ if fnf<>'' then MessageBox(0,PChar('Не удаётся найти или загрузить:'+fnf),
                            'ВНИМАНИЕ:',MB_ICONEXCLAMATION);}
 if fnf<>'' then Result:='Не удаётся найти или загрузить:'+fnf;
End;
//-------------------------------------------------------
//Открывает файл M2 (модель WoW) и пытается конвертировать его.
//Изменить имя файла (для сохранения) нужно отдельно.
procedure OpenM2(fname:string);
Var i,ii,j,tmp,iofs,coGlobalSequences,ipGlobalSequences,
    coAnims,ipAnims,coBones,ipBones,coVertices,ipVertices,
    coViews,ipViews,coColors,ipColors,coTextures,
    ipTextures,coTransparency,ipTransparency,
    coTexAnims,ipTexAnims,coRenderFlags,ipRenderFlags,
    coTexLookup,ipTexLookup,coTexUnits,ipTexUnits,coTexAnimLookup,
    ipTexAnimLookup,coAtch,ipAtch,coLights,ipLights,coCameras,ipCameras,
    coRibbons,ipRibbons,coParticles,ipParticles:integer;
    s:string;
    svnum,vnum,tnum,tcount,bn1,bn2,bn3,bn4,pp2:integer;
    CountOfSubmeshes,CurID:integer;
    CurSubmesh:TSubmesh;          //для временного пользования
    submeshes:array of TSubMesh;  //массив подповерхностей
    tmpGeo:TGeoset;tmpGA:TGeosetAnim;
Begin
 IsWoW:=true;
 //1. Откроем файл модели:
 assignFile(f,fname);
 reset(f,1);                      //побайтовое чтение
 //2. Выделить память под файл
 GetMem(p,FileSize(f)+8);         //выделяем с резервом
 //3. Прочесть весь файл в память
 BlockRead(f,p^,FileSize(f));
 //4. Закрыть файл
 CloseFile(f);
 Controllers:=nil;
 FileContent:='';   //пока информации нет
 //Дополнительная инициализация:
 CountOfTextures:=0;
 CountOfMaterials:=0;
 CountOfPivotPoints:=0;
 CountOfTextureAnims:=0;
 CountOfGeosets:=0;
 CountOfGeosetAnims:=0;
 CountOfLights:=0;
 CountOfHelpers:=0;
 CountOfBones:=0;
 CountOfAttachments:=0;
 CountOfParticleEmitters1:=0;
 CountOfParticleEmitters:=0;
 CountOfRibbonEmitters:=0;
 CountOfEvents:=0;
 CountOfCameras:=0;
 CountOfCollisionShapes:=0;
//------------------Собственно чтение----------
 pp:=integer(p);                  //получить адрес
 //1. Проверим, действительно ли это модель WoW:
 s:=ReadASCII(4);                 //читаем MagID заголовка
 if s<>'MD20' then begin          //ошибка: это не WoW-модель
  //CountOfGeosets:=0;
  if p<>nil then Freemem(p);
  MessageBox(0,'Неверный формат модели',scError,mb_iconstop);
  exit;
 end;//of if

 //2. Модель распознана. Читаем её имя:
 Version:=ReadLong;               //версия формата M2
// pp:=integer(p)+$4;               //смещение длины
 tmp:=ReadLong;                   //читать длину имени
 iofs:=ReadLong;                  //читать смещение имени
 pp:=integer(p)+iofs;
 ModelName:=ReadASCII(tmp);       //читать имя модели
 BlendTime:=150;

 //3. Загружаем необходимые указатели, заполняем
 //счетчики и готовимся к конверсии
 iofs:=integer(p);                //для получения абсолютных смещений
 pp:=iofs+$14;                    //пропуск части заголовка
 coGlobalSequences:=ReadLong;     //кол-во глоб. последовательностей
 ipGlobalSequences:=ReadLong+iofs;//смещение
 coAnims:=ReadLong;               //ну и т.д.
 ipAnims:=ReadLong+iofs;
 pp:=pp+4*4;                      //пропуск 4 полей
 coBones:=ReadLong;
 ipBones:=ReadLong+iofs;
 pp:=pp+2*4;
 coVertices:=ReadLong;
 ipVertices:=ReadLong+iofs;
 coViews:=ReadLong;
 ipViews:=ReadLong+iofs;
 coColors:=ReadLong;
 ipColors:=ReadLong+iofs;
 coTextures:=ReadLong;
 ipTextures:=ReadLong+iofs;
 coTransparency:=ReadLong;
 ipTransparency:=ReadLong+iofs;
 pp:=pp+2*4;
 coTexAnims:=ReadLong;
 ipTexAnims:=ReadLong+iofs;
 pp:=pp+2*4;
 coRenderFlags:=ReadLong;
 ipRenderFlags:=ReadLong+iofs;
 pp:=pp+2*4;
 coTexLookup:=ReadLong;
 ipTexLookup:=ReadLong+iofs;
 coTexUnits:=ReadLong;
 ipTexUnits:=ReadLong+iofs;
 pp:=pp+2*4;
 coTexAnimLookup:=ReadLong;
 ipTexAnimLookup:=ReadLong+iofs;
 pp:=iofs+$104;
 coAtch:=ReadLong;
 ipAtch:=ReadLong+iofs;
 pp:=iofs+$11C;                   //пропуск большого куска
 coLights:=ReadLong;
 ipLights:=ReadLong+iofs;
 coCameras:=ReadLong;
 ipCameras:=ReadLong+iofs;
 pp:=pp+2*4;
 coRibbons:=ReadLong;
 ipRibbons:=ReadLong+iofs;
 coParticles:=ReadLong;
 ipParticles:=ReadLong+iofs;

 //Читаем список текстур
 M2ReadTextures(coTextures,ipTextures);
 M2ConvertTextures(ModelName,fname);
 M2FindTextures(fname,ModelName); //поиск текстур и коррекция их имён
 CountOfMaterials:=0;
 CountOfGeosetAnims:=0;
 CountOfTextureAnims:=0;
 Controllers:=nil;
 //Читаем сразу же список текстурных анимаций:
 M2ReadTextureAnims(coTexAnims,ipTexAnims);

 //4. Заполняем список подповерхностей (Submeshes).
 CountOfSubmeshes:=0;             //пока таковых нет
 pp:=ipViews;
 for i:=1 to coViews do begin     //обработка всех "видов"
  CurSubMesh.coIndices:=ReadLong;
  CurSubMesh.ipIndices:=ReadLong+iofs;
  CurSubMesh.coFaces:=ReadLong;
  CurSubMesh.ipFaces:=ReadLong+iofs;
  pp:=pp+2*4;                     //пропуск поля
  tmp:=ReadLong;                  //читать кол-во подповерхностей
  //Выделить для них меcто
  CountOfSubmeshes:=CountOfSubmeshes+tmp;
  SetLength(Submeshes,CountOfSubmeshes);
  CurSubMesh.ipMesh:=ReadLong+iofs;//смещение первой подповерхности
  CurSubMesh.id:=0;
  CurSubMesh.coTexs:=ReadLong;
  CurSubMesh.ipTexs:=ReadLong+iofs;
  for ii:=tmp downto 1 do begin //заполняем массив подповерхностей
   Submeshes[CountOfSubmeshes-ii]:=CurSubMesh;
   if Version>=$104 then CurSubMesh.ipMesh:=CurSubMesh.ipMesh+48
   else CurSubMesh.ipMesh:=CurSubMesh.ipMesh+32;//двигаемся далее
   inc(CurSubMesh.id);
  end;//of for ii
  pp:=pp+4;                       //Пропуск поля
 end;//of for i

 //5. Приступаем к формированию MDX-поверхностей (Geosets)
 CountOfGeosets:=CountOfSubmeshes;
 if CountOfGeosets=0 then begin   //какая-то ошибка
  MessageBox(0,'Ошибка конверсии',scError,mb_iconstop);
  exit;
 end;//of if
 SetLength(Geosets,CountOfGeosets);//выделить место

 //Цикл создания поверхностей
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  pp:=Submeshes[i].ipMesh;        //данные подповерхности
  HierID:=ReadLong;               //ID
  vnum:=ReadShort;                //номер первой вершины
  svnum:=vnum;
  CountOfVertices:=ReadShort;     //кол-во вершин поверхности
  tnum:=ReadShort;                //стартовый индекс треуг.
  tcount:=ReadShort;              //кол-во вершин в разворотах
  CountOfNormals:=CountOfVertices;
  CountOfCoords:=1;
  SetLength(Crds,1);
  Crds[0].CountOfTVertices:=CountOfVertices;
  CountOfFaces:=1;
  CountOfMatrices:=0;             //пока нет матриц костей
  //Установить длины массивов
  SetLength(Vertices,CountOfVertices);
  SetLength(Normals,CountOfVertices);
  SetLength(Crds[0].TVertices,CountOfVertices);
  SetLength(VertexGroup,CountOfVertices);
  SetLength(Faces,1);             //все треугольники собираем в кучу
  SetLength(Faces[0],tcount);     //кол-во вершин в треугольниках
  //Извлечь "вершинные" данные
  pp2:=submeshes[i].ipIndices;    //индексы вершин
  pp2:=pp2+vnum*2;                //переход

  //Извлекаем вершины:
  for ii:=0 to CountOfVertices-1 do begin
   vnum:=0;Move(pointer(pp2)^,vnum,2);pp2:=pp2+2;
   pp:=ipVertices+vnum*48;
   Vertices[ii,1]:=ReadFloat*wowmult;//координаты вершины
   Vertices[ii,2]:=ReadFloat*wowmult;
   Vertices[ii,3]:=ReadFloat*wowmult;
   //Читаем веса (и индексы) костей:
   bn1:=ReadByte;
   bn2:=ReadByte;
   bn3:=ReadByte;
   bn4:=ReadByte;
   //Отсев костей с низким весом
   if bn1>1 then bn1:=ReadByte else begin
    bn1:=-1;pp:=pp+1;
   end;//of if
   if bn2>1 then bn2:=ReadByte else begin
    bn2:=-1;pp:=pp+1;
   end;//of if
   if bn3>1 then bn3:=ReadByte else begin
    bn3:=-1;pp:=pp+1;
   end;//of if
   if bn4>1 then bn4:=ReadByte else begin
    bn4:=-1;pp:=pp+1;
   end;//of if
   //Исходя из списка костей строим матрицу:
//!dbg   if (bn1<0) and (bn2<0) and (bn3<0) and (bn4<0) then MessageBox(0,'df','dfg',0);
   VertexGroup[ii]:=GetMakedGroupNum(i,bn1,bn2,bn3,bn4);
   pp:=pp+3*4;                    //пропуск нормали
   Crds[0].TVertices[ii,1]:=ReadFloat;//Текстурные координаты
   Crds[0].TVertices[ii,2]:=ReadFloat;
   pp:=pp+2*4;                    //пропуск 0
  end;//of for ii

  //Мы всё ещё в цикле по i, где i - номер подповерхности
  //(а для MDX - номер поверхности). Теперь создаем
  //список разворотов (треугольники):
  pp:=Submeshes[i].ipFaces;       //список разворотов
  pp:=pp+tnum*2;                  //к первой вершине разворота
  for ii:=0 to tcount-1 do begin
   Faces[0,ii]:=ReadShort-svnum;
  end;//of for ii

  //По-прежнему цикл i (номер подповерхности).
  //Теперь ищем запись материала подповерхности:
  MaterialID:=-1;                 //пока нет материала
  pp:=Submeshes[i].ipTexs;
  for ii:=1 to Submeshes[i].coTexs do begin
   pp:=pp+4;                      //переход к полю MeshID
   tmp:=ReadShort;                //читаем этот ID
   pp:=pp+2;
   if Submeshes[i].id=tmp then begin//материал(слой) найден
    pp:=pp-8;                     //на начало слоя материала
    //читать материал (все слои)
    MaterialID:=M2ReadMaterial(Submeshes[i].coTexs-ii+1,tmp,
                i,ipColors,ipRenderFlags,ipTexUnits,
                ipTransparency,ipTexAnimLookup,ipTexLookup);
    break;                        //выход из цикла
   end;//of if
   pp:=pp+24-8;                   //ищем далее
  end;//of for ii
  if MaterialID<0 then MaterialID:=CreateFakedMaterial;//если нет материала

 end;//of for i

 //Читаем анимационные данные:
 M2ReadGlobalSequences(coGlobalSequences,ipGlobalSequences);
 M2ReadSequences(coAnims,ipAnims);

 CurID:=0;                        //пока нет объектов
 M2ReadBones(coBones,ipBones,CurID);//чтение объектов скелета

 //Читаем прочие объекты
 M2ReadAttachments(coAtch,ipAtch,CurID);
 M2ReadParticleEmitters(coParticles,ipParticles,CurID);
 M2ReadCameras(coCameras,ipCameras);
//----------Освободить память------------------
 FreeMem(p);
 //Заполнить оставшиеся массивы
 SetLength(VisGeosets,CountOfGeosets);
 for i:=0 to CountOfGeosets-1 do VisGeosets[i]:=true;

 //И, наконец, рассортировать поверхности
 i:=0;
 while i<CountOfGeosets do begin
  coVertices:=Geosets[i].CountOfVertices;
  //Ищем поверхности с таким же кол-вом вершин
  ii:=i+1;
  while ii<CountOfGeosets do begin
   if Geosets[ii].CountOfVertices=coVertices then begin
    tmpGeo:=Geosets[ii];
    tmpGA:=GeosetAnims[ii];
    inc(i);
    Geosets[ii]:=Geosets[i];
    GeosetAnims[ii]:=GeosetAnims[i];
    GeosetAnims[ii].GeosetID:=ii;
    Geosets[i]:=tmpGeo;
    GeosetAnims[i]:=tmpGA;
    GeosetAnims[i].GeosetID:=i;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of for i

// Freemem(p);
End;
//---------------------------------------------------------
//закрывает файл модели
procedure CloseMDL;
Var i:integer;
Begin
 for i:=0 to CountOfGeosets-1 do if Geosets[i].CurrentListNum<>-1 then
   glDeleteLists(Geosets[i].CurrentListNum,1);
 Geosets:=nil;
End;
//=========================================================
//Вспомогательная: Сохранить секцию Vertices
procedure SaveVertices(geonum:integer);
//Const sSpace1=#09;
Var s:string;i:integer;
Begin
 s:=#09'Vertices '+inttostr(Geosets[geonum-1].CountOfVertices)+' {';
 writeln(ft,s);
 //Запись вершин
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  s:=#09#09'{ ';                  //начало
  s:=s+floattostrf(Geosets[geonum-1].Vertices[i,1],ffGeneral,7,5)+', '+
       floattostrf(Geosets[geonum-1].Vertices[i,2],ffGeneral,7,5)+', '+
       floattostrf(Geosets[geonum-1].Vertices[i,3],ffGeneral,7,5)+' },';
  writeln(ft,s);                  //запись
 end;//of for
 s:=#09'}';
 writeln(ft,s);   //конец секции
End;
//---------------------------------------------------------
//перерасчитывает нормали для заданной поверхности
procedure RecalcNormals(geonum:integer);
Var i,ii:integer;
    nnum,num:integer;
    num1,num2,num3:integer;
    x1,y1,z1,x2,y2,z2,x3,y3,z3:GLfloat;
    vx1,vy1,vz1,vx2,vy2,vz2,nx,ny,nz,wrki:GLfloat;
Begin
 nnum:=1;
 SetLength(nrms,Geosets[geonum-1].CountOfVertices);//размер массива
 //инициализация
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  nrms[i].x:=0;nrms[i].y:=0;nrms[i].z:=0;
//  nrms[i].count:=0;
 end;//of for
 //1. Расчет нормалей к треугольным граням
 for i:=0 to Length(geosets[geonum-1].Faces)-1 do begin
  for ii:=0 to length(geosets[geonum-1].Faces[i])-1 do begin
   num:=Geosets[geonum-1].Faces[i,ii];
   case nnum of
    1:begin
     x1:=Geosets[geonum-1].Vertices[num,1];
     y1:=Geosets[geonum-1].Vertices[num,2];
     z1:=Geosets[geonum-1].Vertices[num,3];
     num1:=num;inc(nnum);
    end;//of 1
    2:begin
     x2:=Geosets[geonum-1].Vertices[num,1];
     y2:=Geosets[geonum-1].Vertices[num,2];
     z2:=Geosets[geonum-1].Vertices[num,3];
     num2:=num;inc(nnum);
    end;//of 1
    3:begin
     x3:=Geosets[geonum-1].Vertices[num,1];
     y3:=Geosets[geonum-1].Vertices[num,2];
     z3:=Geosets[geonum-1].Vertices[num,3];
     num3:=num;
     //Теперь - собственно нормаль
     nnum:=1;                     //сброс
     vx1:=x1-x2;vy1:=y1-y2;vz1:=z1-z2;
     vx2:=x2-x3;vy2:=y2-y3;vz2:=z2-z3;
     nx:=vy1*vz2-vz1*vy2;
     ny:=vz1*vx2-vx1*vz2;
     nz:=vx1*vy2-vy1*vx2;
     wrki:=sqrt(nx*nx+ny*ny+nz*nz);
     if wrki=0 then wrki:=1;
     //занести ее
//     inc(nrms[num1].count);
     nrms[num1].x:=nrms[num1].x+nx/wrki;
     nrms[num1].y:=nrms[num1].y+ny/wrki;
     nrms[num1].z:=nrms[num1].z+nz/wrki;

//     inc(nrms[num2].count);
     nrms[num2].x:=nrms[num2].x+nx/wrki;
     nrms[num2].y:=nrms[num2].y+ny/wrki;
     nrms[num2].z:=nrms[num2].z+nz/wrki;

//     inc(nrms[num3].count);
     nrms[num3].x:=nrms[num3].x+nx/wrki;
     nrms[num3].y:=nrms[num3].y+ny/wrki;
     nrms[num3].z:=nrms[num3].z+nz/wrki;
    end;//of 1
   end;//of case
//   inc(nnum);
  end;//of for ii
 end;//of for i
 //2. Уф. Теперь уже совсем просто: усредняем к-ты и нормируем к 1
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
{  if nrms[i].count=0 then begin
   nrms[i].x:=1;nrms[i].y:=0;nrms[i].z:=0;
   wrki:=1;
  end else begin}
{   if (sqr(nrms[i].x)+sqr(nrms[i].y)+sqr(nrms[i].z))<0.2 then begin
    nrms[i].x:=1;nrms[i].count:=1;
   end;//of if}
{   nrms[i].x:=nrms[i].x/nrms[i].count;
   nrms[i].y:=nrms[i].y/nrms[i].count;
   nrms[i].z:=nrms[i].z/nrms[i].count;}
   wrki:=sqrt(sqr(nrms[i].x)+sqr(nrms[i].y)+sqr(nrms[i].z));
   if wrki=0 then wrki:=1;
//  end;//of if
   Geosets[geonum-1].Normals[i,1]:=nrms[i].x/wrki;
   Geosets[geonum-1].Normals[i,2]:=nrms[i].y/wrki;
   Geosets[geonum-1].Normals[i,3]:=nrms[i].z/wrki;
  if pos('NAN',floattostrf(Geosets[geonum-1].Normals[i,1]
               ,ffFixed,10,5))<>0 then Geosets[geonum-1].Normals[i,1]:=0;
  if pos('NAN',floattostrf(Geosets[geonum-1].Normals[i,2]
               ,ffFixed,10,5))<>0 then Geosets[geonum-1].Normals[i,2]:=0;
  if pos('NAN',floattostrf(Geosets[geonum-1].Normals[i,3]
               ,ffFixed,10,5))<>0 then Geosets[geonum-1].Normals[i,3]:=0;
 end;//of for
End;
//---------------------------------------------------------
//Проводит "поворачивание" треугольников так,
//чтобы они соответствовали своим нормалям.
procedure NormalizeTriangles(geoID:integer);
Var i,ii,len,tmp:integer;
    x1,x2,x3,y1,y2,y3,z1,z2,z3,
    vx1,vx2,vy1,vy2,vz1,vz2,nx,ny,nz,sp1,sp2,sp3:single;
Const OFF_LINE=0.5;//определяет границу суммы нормали
Begin with Geosets[GeoID] do begin
 for i:=0 to High(Faces) do begin
  len:=High(Faces[i]);
  ii:=0;
  repeat
   //1. Считываем координаты вершин
   x1:=Vertices[Faces[i,ii],1];
   y1:=Vertices[Faces[i,ii],2];
   z1:=Vertices[Faces[i,ii],3];
   x2:=Vertices[Faces[i,ii+1],1];
   y2:=Vertices[Faces[i,ii+1],2];
   z2:=Vertices[Faces[i,ii+1],3];
   x3:=Vertices[Faces[i,ii+2],1];
   y3:=Vertices[Faces[i,ii+2],2];
   z3:=Vertices[Faces[i,ii+2],3];
   //2. Рассчитываем нормаль (грубо, ускоренно)
   vx1:=x1-x2;vy1:=y1-y2;vz1:=z1-z2;
   vx2:=x2-x3;vy2:=y2-y3;vz2:=z2-z3;
   nx:=vy1*vz2-vz1*vy2;
   ny:=vz1*vx2-vx1*vz2;
   nz:=vx1*vy2-vy1*vx2;
   //Складываем рассчитанную нормаль с канонической
   //Находим скалярные произведения
   sp1:=nx*Normals[Faces[i,ii],1]+ny*Normals[Faces[i,ii],2]+
        nz*Normals[Faces[i,ii],3];
   sp2:=nx*Normals[Faces[i,ii+1],1]+ny*Normals[Faces[i,ii+1],2]+
        nz*Normals[Faces[i,ii+1],3];
   sp3:=nx*Normals[Faces[i,ii+2],1]+ny*Normals[Faces[i,ii+2],2]+
        nz*Normals[Faces[i,ii+2],3];
   if (abs(sp1)<1e-6) or (abs(sp2)<1e-6) or (abs(sp3)<1e-6) then begin
    ii:=ii+3;
    continue;
   end;//of if
   //Проверим, не нужно ли перевернуть треугольник
   if ((abs(sp1)/sp1)+(abs(sp2)/sp2)+(abs(sp3)/sp3))<0 then begin
    tmp:=Faces[i,ii];
    Faces[i,ii]:=Faces[i,ii+2];
    Faces[i,ii+2]:=tmp;
   end;//of if (переворот треуг.)
   ii:=ii+3;
  until ii>=len;
 end;//of for i
end;End;
//---------------------------------------------------------
//Осуществляет удаление нормали с указанными параметрами
//из MidNormals и ConstNormals (если там таковой уже нет,
//ничего не происходит)
procedure DeleteRecFromSmoothGroups(nrm:TMidNormal);
Var i,ii,j,len:integer;
Begin
 //1. Удаляем из групп усреднения:
 i:=0;
 while i<COMidNormals do begin
  len:=length(MidNormals[i]);
  ii:=0;
  while ii<len do begin
   if (MidNormals[i,ii].GeoID=nrm.GeoID) and
      (MidNormals[i,ii].VertID=nrm.VertID)
   then begin
    for j:=ii to len-2 do MidNormals[i,j]:=MidNormals[i,j+1];
    dec(len);
    SetLength(MidNormals[i],len);
    if len=0 then begin           //удалить всю группу
     for j:=i to COMidNormals-2 do MidNormals[j]:=MidNormals[j+1];
     dec(COMidNormals);
     SetLength(MidNormals,COMidNormals);
    end;
    exit;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of while

 //2. Удаляем из групп установки
 i:=0;
 while i<COConstNormals do begin
  if (ConstNormals[i].GeoId=nrm.GeoID) and (ConstNormals[i].VertID=nrm.VertID)
  then begin
   for ii:=i to CoConstNormals-2 do ConstNormals[ii]:=ConstNormals[ii+1];
   dec(COConstNormals);
   exit;
  end;//of if
  inc(i);
 end;//of while
End;
//---------------------------------------------------------
//Увеличивает округление моделей (везде обнуляет 2 старших байта),
//что приводит к увеличению сжимаемости.
procedure RoundModel;
Var i,ii,j,jj,len:integer;pw:PWord;
Begin
 //1. Поверхности
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  for ii:=0 to CountOfVertices-1 do for j:=1 to 3 do begin
   pw:=@Geosets[i].Vertices[ii,j];
   pw^:=0;
  end;//of for ii

  for ii:=0 to CountOfNormals-1 do for j:=1 to 3 do begin
   pw:=@Normals[ii,j];
   pw^:=0;
  end;//of for ii

  for ii:=0 to CountOfCoords-1
  do for j:=0 to Crds[ii].CountOfTVertices-1 do for jj:=1 to 2 do begin
   pw:=@Crds[ii].TVertices[j,jj];
   pw^:=0;
  end;//of for jj/j/ii
 end;//of for i

 //Теперь анимации
 len:=High(Controllers);
 for i:=0 to len do for ii:=0 to High(Controllers[i].Items)
 do with Controllers[i].Items[ii] do for j:=1 to 4 do begin
  pw:=@Controllers[i].Items[ii].Data[j];
  pw^:=0;
  pw:=@Controllers[i].Items[ii].InTan[j];
  pw^:=0;
  pw:=@Controllers[i].Items[ii].OutTan[j];
  pw^:=0;
 end;//of with/for ii/i
End;
//---------------------------------------------------------
//Удаляет повторяющиеся текстуры (уменьшая кол-во их записей)
procedure ReduceRepTextures;
Var i,ii,j,jj,TexID:integer;
Begin
 i:=1;
 while i<CountOfTextures do begin
  ii:=0;
  while ii<i do begin
   if (Textures[i].FileName=Textures[ii].FileName) and
    (Textures[i].ReplaceableID=Textures[ii].ReplaceableID) then begin
    //Текстуры совпадают. Удаляем старшую
    for j:=i to CountOfTextures-2 do Textures[j]:=Textures[j+1];
    dec(CountOfTextures);
    //Теперь сдвигаем ID текстур
    for j:=0 to CountOfMaterials-1
    do for jj:=0 to Materials[j].CountOfLayers-1
    do begin
     if Materials[j].Layers[jj].TextureID=i
     then Materials[j].Layers[jj].TextureID:=ii;
     if Materials[j].Layers[jj].TextureID>i
     then dec(Materials[j].Layers[jj].TextureID);
    end;//of if/for jj/for j
    //Также сдвигаются ID текстур в источниках частиц
    for j:=0 to CountOfParticleEmitters-1 do begin
     if pre2[j].TextureID=i then pre2[j].TextureID:=ii;
     if pre2[j].TextureID>i then dec(pre2[j].TextureID);
    end;//of for j
    ii:=-1;
    dec(i);
    break;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of while
 SetLength(Textures,CountOfTextures);
End;
//---------------------------------------------------------
//Удаляет повторяющиеся материалы
procedure ReduceRepMaterials;
Var i,ii,j:integer;
Begin
 i:=1;
 while i<CountOfMaterials do begin
  ii:=0;
  while ii<i do begin
   if IsMatsEqual(Materials[i],Materials[ii]) then begin
    //Материалы совпадают. Удаляем старший
    for j:=i to CountOfMaterials-2 do Materials[j]:=Materials[j+1];
    dec(CountOfMaterials);
    //Теперь сдвигаем ID материалов
    for j:=0 to CountOfGeosets-1 do begin
     if Geosets[j].MaterialID=i then Geosets[j].MaterialID:=ii;
     if Geosets[j].MaterialID>i then dec(Geosets[j].MaterialID);
    end;//of if/for j
    //Также сдвигаются ID материалов в источниках следа
    for j:=0 to CountOfRibbonEmitters-1 do begin
     if Ribs[j].MaterialID=i then Ribs[j].MaterialID:=ii;
     if Ribs[j].MaterialID>i then dec(Ribs[j].MaterialID);
    end;//of for j
    ii:=-1;
    dec(i);
    break;
   end;//of if
   inc(ii);
  end;//of while
  inc(i);
 end;//of while
 SetLength(Materials,CountOfMaterials);
End;
//---------------------------------------------------------
//Проводит "сглаживание" путем усреднения нормалей
procedure SmoothWithNormals(geoID:integer);
Var i,ii:integer;
    v:TVertex;
    n:TNormal;
    wrki:GlFloat;
    sm:array of boolean;
Const Delta=3;
Begin with Geosets[geoid] do begin
 //exit;
 //заполним массив сглаженности
 SetLength(sm,CountOfVertices);
 for i:=0 to CountOfVertices-1 do sm[i]:=false;
 //Цикл усреднения
 for i:=0 to CountOfVertices-1 do begin
  if sm[i] then continue;
  v:=Vertices[i];                 //читаем к-ты вершины
  n:=Normals[i];                  //нормаль
  //Цикл анализа вершин
  for ii:=i+1 to CountOfVertices-1 do begin
   if sqr(Vertices[ii,1]-v[1])+sqr(Vertices[ii,2]-v[2])+
      sqr(Vertices[ii,3]-v[3])<Delta then begin
    //вершина близкая, усредним нормали
    n[1]:=n[1]+Normals[ii,1];
    n[2]:=n[2]+Normals[ii,2];
    n[3]:=n[3]+Normals[ii,3];
   end;//of if
  end;//of for ii
  //Нормируем полученное усреднение:
  wrki:=sqrt(sqr(n[1])+sqr(n[2])+sqr(n[3]));
  if wrki=0 then wrki:=1;
  n[1]:=n[1]/wrki;
  n[2]:=n[2]/wrki;
  n[3]:=n[3]/wrki;
  //Записываем
  for ii:=i to CountOfVertices-1 do begin
   if sqr(Vertices[ii,1]-v[1])+sqr(Vertices[ii,2]-v[2])+
      sqr(Vertices[ii,3]-v[3])<Delta then begin
    Normals[ii,1]:=n[1];
    Normals[ii,2]:=n[2];
    Normals[ii,3]:=n[3];
    sm[ii]:=true;  
   end;//of if
  end;//of for ii
 end;//of for i
end;End;
//---------------------------------------------------------
//Проводит поиск вершины в ConstNormals.
//Если она там есть, возвр. ID соотв. записи. Иначе (-1).
function FindConstNormal(geoID,VertID:integer):integer;
Var i:integer;
Begin
 Result:=-1;
 for i:=0 to COConstNormals-1
 do if (ConstNormals[i].GeoID=GeoID) and (ConstNormals[i].VertID=VertID)
 then begin
  Result:=i;
  exit;
 end;//of if/for i
End;
//---------------------------------------------------------
//Применяет группы сглаживания к нормалям
procedure ApplySmoothGroups;
Var i,ii:integer; snrm,nrm:TVertex; n:GLFloat;
Begin
 //1. Применение всех групп сглаживания:
 //a. Найти усреднённую нормаль для каждой группы
 //b. Применить её ко всем вершинам группы
 for i:=0 to COMidNormals-1 do begin
  nrm[1]:=0;
  nrm[2]:=0;
  nrm[3]:=0;
  for ii:=0 to High(MidNormals[i]) do begin
   snrm:=Geosets[MidNormals[i,ii].GeoID].Normals[MidNormals[i,ii].VertID];
   nrm[1]:=nrm[1]+snrm[1];
   nrm[2]:=nrm[2]+snrm[2];
   nrm[3]:=nrm[3]+snrm[3];
  end;//of for ii
  if abs(nrm[1])+abs(nrm[2])+abs(nrm[3])<1e-6 then nrm[1]:=1;
  n:=1/sqrt(nrm[1]*nrm[1]+nrm[2]*nrm[2]+nrm[3]*nrm[3]);
  nrm[1]:=nrm[1]*n;
  nrm[2]:=nrm[2]*n;
  nrm[3]:=nrm[3]*n;

  for ii:=0 to High(MidNormals[i]) do with Geosets[MidNormals[i,ii].GeoID]
  do begin
   Normals[MidNormals[i,ii].VertID,1]:=nrm[1];
   Normals[MidNormals[i,ii].VertID,2]:=nrm[2];
   Normals[MidNormals[i,ii].VertID,3]:=nrm[3];
  end;//of for ii   
 end;//of for i

 //2. Применить "константную" нормаль ко всем соотв. вершинам
 for i:=0 to COConstNormals-1
 do Geosets[ConstNormals[i].GeoId].Normals[ConstNormals[i].VertID]:=
    ConstNormals[i].n;
End;
//---------------------------------------------------------
//Создает секцию нормалей
procedure SaveNormals(geonum:integer);
Var s,s2:string;i:integer;
Begin
 s:=#09'Normals '+inttostr(Geosets[geonum-1].CountOfVertices)+' {';
 writeln(ft,s);
 //Запись нормалей
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  s:=#09#09'{ ';                  //начало
  s2:=floattostrf(Geosets[geonum-1].Normals[i,1],ffGeneral,7,5)+', '+
       floattostrf(Geosets[geonum-1].Normals[i,2],ffGeneral,7,5)+', '+
       floattostrf(Geosets[geonum-1].Normals[i,3],ffGeneral,7,5)+' },';
  if pos('NAN',s2)<>0 then s2:='0, 0, 0 },';//отсев исключений
  s:=s+s2;
  writeln(ft,s);                  //запись
 end;//of for
 s:=#09'}';
 writeln(ft,s);   //конец секции
End;
//---------------------------------------------------------
procedure SaveTVertices(geonum:integer);//сохранить к-ты текстуры
Var s:string;i,j:integer;
Begin
 for j:=0 to Geosets[Geonum-1].CountOfCoords-1 do begin
  s:=#09'TVertices '+inttostr(Geosets[geonum-1].CountOfVertices)+' {';
  writeln(ft,s);
  //Запись текстурных вершин
  for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
   s:=#09#09'{ ';                  //начало
   s:=s+floattostrf(Geosets[geonum-1].Crds[j].TVertices[i,1],ffGeneral,7,5)+
      ', '+
      floattostrf(Geosets[geonum-1].Crds[j].TVertices[i,2],ffGeneral,7,5)+
      ' },';
   writeln(ft,s);                  //запись
  end;//of for i
  s:=#09'}';
  writeln(ft,s);   //конец секции
 end;//of for j
End;
//---------------------------------------------------------
procedure SaveVertexGroup(geonum:integer);//сохранить группы вершин
Var s:string;i:integer;
Begin
 s:=#09'VertexGroup {';
 writeln(ft,s);
 //Запись нормалей
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  s:=#09#09;                      //начало
  s:=s+inttostr(Geosets[geonum-1].VertexGroup[i])+',';
  writeln(ft,s);                  //запись
 end;//of for
 s:=#09'}';
 writeln(ft,s);   //конец секции
End;
//---------------------------------------------------------
procedure SaveFaces(geonum:integer);//сохранить развороты
Var s:string;i,ii,count:integer;
Begin
 //начало формирования заголовка
 s:=#09'Faces '+inttostr(Length(Geosets[geonum-1].Faces))+' ';
 //подсчет кол-ва треугольников
 count:=0;
 for i:=0 to Length(Geosets[geonum-1].Faces)-1 do count:=count+
             Length(Geosets[geonum-1].Faces[i]);
// count:=count div 3; //теперь узнаем число треуг.
 s:=s+inttostr(count)+' {';
 writeln(ft,s);                   //записпть заголовок
 s:=#09#09'Triangles {';
 writeln(ft,s);                   //записать подсекцию
 for i:=0 to Length(Geosets[geonum-1].Faces)-1 do begin
  s:=#09#09#09'{ ';               //начало
  for ii:=0 to Length(Geosets[geonum-1].Faces[i])-1 do begin
   if ii<>0 then s:=s+', ';       //оканчиваем подсекции
   s:=s+inttostr(Geosets[geonum-1].Faces[i,ii]);
  end;//of for ii
  s:=s+' },';                     //окончание подсекции
  writeln(ft,s);
 end;//of for i
 s:=#09#09'}';writeln(ft,s);      //Triangles
 s:=#09'}';writeln(ft,s);         //Faces
End;
//---------------------------------------------------------
//Создает секцию групп (группировка по костям)
procedure SaveGroups(geonum:integer);
Var s:string;i,ii,count:integer;
Begin
 //начало формирования заголовка
 s:=#09'Groups '+inttostr(Geosets[geonum-1].CountOfMatrices)+' ';
 //подсчет кол-ва номеров костей
 count:=0;
 for i:=0 to Length(Geosets[geonum-1].Groups)-1 do count:=count+
             Length(Geosets[geonum-1].Groups[i]);
 s:=s+inttostr(count)+' {';
 writeln(ft,s);                   //записпть заголовок
// s:=#09#09'Triangles {';
// writeln(ft,s);                   //записать подсекцию
 for i:=0 to Geosets[geonum-1].CountOfMatrices-1 do begin
  s:=#09#09'Matrices { ';               //начало
  for ii:=0 to Length(Geosets[geonum-1].Groups[i])-1 do begin
   if ii<>0 then s:=s+', ';       //оканчиваем подсекции
   s:=s+inttostr(Geosets[geonum-1].Groups[i,ii]);
  end;//of for ii
  s:=s+' },';                     //окончание подсекции
  writeln(ft,s);
 end;//of for i
// s:=#09#09'}';writeln(ft,s);      //Triangles
 s:=#09'}';writeln(ft,s);         //Groups
End;
//---------------------------------------------------------
{ TODO -oАлексей -cДоработка : Сделать перерасчет и сохранение границ в заглоловке }
//Перерасчитывает границы модели
procedure RecalcBounds(geonum:integer);
Var xmin,ymin,zmin,xmax,ymax,zmax:GLfloat;
    DeltaXMin,DeltaYMin,DeltaZMin,
    DeltaXMax,DeltaYMax,DeltaZMax:GLfloat;
    i:integer;
Begin
 xmin:=1000;ymin:=1000;zmin:=1000;
 xmax:=-1000;ymax:=-1000;zmax:=-1000;
 //Поиск границ
 for i:=0 to Geosets[geonum-1].CountOfVertices-1 do begin
  if Geosets[geonum-1].Vertices[i,1]<xmin then
                       xmin:=Geosets[geonum-1].Vertices[i,1];
  if Geosets[geonum-1].Vertices[i,1]>xmax then
                       xmax:=Geosets[geonum-1].Vertices[i,1];
  if Geosets[geonum-1].Vertices[i,2]<ymin then
                       ymin:=Geosets[geonum-1].Vertices[i,2];
  if Geosets[geonum-1].Vertices[i,2]>ymax then
                       ymax:=Geosets[geonum-1].Vertices[i,2];
  if Geosets[geonum-1].Vertices[i,3]<zmin then
                       zmin:=Geosets[geonum-1].Vertices[i,3];
  if Geosets[geonum-1].Vertices[i,3]>zmax then
                       zmax:=Geosets[geonum-1].Vertices[i,3];
 end;//of for
{ //Сравнение границ
 DeltaXMin:=xmin-Geosets[geonum-1].MinimumExtent[1];
 DeltaYMin:=ymin-Geosets[geonum-1].MinimumExtent[2];
 DeltaZMin:=zmin-Geosets[geonum-1].MinimumExtent[3];

 DeltaXMax:=xmax-Geosets[geonum-1].MaximumExtent[1];
 DeltaYMax:=ymax-Geosets[geonum-1].MaximumExtent[2];
 DeltaZMax:=zmax-Geosets[geonum-1].MaximumExtent[3];
 //проверим, нужна ли корректировка границ
 if (DeltaXMin<0) or (DeltaYMin<0) or (DeltaZMin<0) or
    (DeltaXMax<0) or (DeltaYMax<0) or (DeltaZMax<0) then begin
  //корректировка
  if DeltaXMax>0 then DeltaXMax:=0;
  if DeltaYMax>0 then DeltaYMax:=0;
  if DeltaZMax>0 then DeltaZMax:=0;
  if DeltaXMin>0 then DeltaXMin:=0;
  if DeltaYMin>0 then DeltaYMin:=0;
  if DeltaZMin>0 then DeltaZMin:=0;}
  Geosets[geonum-1].MinimumExtent[1]:=xmin;
  Geosets[geonum-1].MinimumExtent[2]:=ymin;
  Geosets[geonum-1].MinimumExtent[3]:=zmin;
  Geosets[geonum-1].MaximumExtent[1]:=xmax;
  Geosets[geonum-1].MaximumExtent[2]:=ymax;
  Geosets[geonum-1].MaximumExtent[3]:=zmax;
  for i:=0 to Geosets[geonum-1].CountOfAnims-1 do begin
   Geosets[geonum-1].Anims[i].MinimumExtent[1]:=xmin;
   Geosets[geonum-1].Anims[i].MinimumExtent[2]:=ymin;
   Geosets[geonum-1].Anims[i].MinimumExtent[3]:=zmin;
   Geosets[geonum-1].Anims[i].MaximumExtent[1]:=xmax;
   Geosets[geonum-1].Anims[i].MaximumExtent[2]:=ymax;
   Geosets[geonum-1].Anims[i].MaximumExtent[3]:=zmax;
  end;//of for
  //Теперь вычисляем граничный радиус
  for i:=0 to Geosets[geonum-1].CountOfAnims-1 do
  with Geosets[geonum-1].Anims[i] do begin
   BoundsRadius:=sqrt(sqr(MinimumExtent[1]-MaximumExtent[1])+
                 sqr(MinimumExtent[2]-MaximumExtent[2])+
                 sqr(MinimumExtent[3]-MaximumExtent[3]));
  end;//of with/for
  //граница всей поверхности
  with Geosets[geonum-1] do BoundsRadius:=
    sqrt(sqr(MinimumExtent[1]-MaximumExtent[1])+
                 sqr(MinimumExtent[2]-MaximumExtent[2])+
                 sqr(MinimumExtent[3]-MaximumExtent[3]));
End;
//---------------------------------------------------------
//Сохраняет границы модели и анимаций
procedure SaveBounds(geonum:integer);
Var i:integer;s:string;
Begin with geosets[geonum-1] do begin
 //Минимальная граница поверхности
 s:=#09'MinimumExtent { '+floattostrf(MinimumExtent[1],ffGeneral,10,5)+
    ', '+floattostrf(MinimumExtent[2],ffGeneral,7,5)+
    ', '+floattostrf(MinimumExtent[3],ffGeneral,7,5)+' },';
 writeln(ft,s);
 s:=#09'MaximumExtent { '+floattostrf(MaximumExtent[1],ffGeneral,10,5)+
    ', '+floattostrf(MaximumExtent[2],ffGeneral,7,5)+
    ', '+floattostrf(MaximumExtent[3],ffGeneral,7,5)+' },';
 writeln(ft,s);
 s:=#09'BoundsRadius '+floattostrf(BoundsRadius,ffFixed,10,5)+',';
 if pos('INF',s)=0 then writeln(ft,s);
 //теперь - список анимаций
 for i:=0 to CountOfAnims-1 do begin
  s:=#09'Anim {';writeln(ft,s);
  s:=#09#09'MinimumExtent { '
         +floattostrf(Anims[i].MinimumExtent[1],ffGeneral,10,5)+
     ', '+floattostrf(Anims[i].MinimumExtent[2],ffGeneral,10,5)+
     ', '+floattostrf(Anims[i].MinimumExtent[3],ffGeneral,10,5)+' },';
  writeln(ft,s);
  s:=#09#09'MaximumExtent { '
         +floattostrf(Anims[i].MaximumExtent[1],ffGeneral,7,5)+
     ', '+floattostrf(Anims[i].MaximumExtent[2],ffGeneral,7,5)+
     ', '+floattostrf(Anims[i].MaximumExtent[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
  s:=#09#09'BoundsRadius '+floattostrf(Anims[i].BoundsRadius,ffGeneral,7,5)+',';
  if pos('INF',s)=0 then writeln(ft,s);
//  writeln(ft,s);
  s:=#09'}';writeln(ft,s);
 end;//of for
end;End;
//---------------------------------------------------------
procedure SaveTail(geonum:integer);
Var s:string;
Begin
 s:=#09'MaterialID '+inttostr(Geosets[geonum-1].MaterialID)+',';
 writeln(ft,s);
 s:=#09'SelectionGroup '+inttostr(Geosets[geonum-1].SelectionGroup)+',';
 writeln(ft,s);
 if Geosets[geonum-1].Unselectable then begin
  s:=#09'Unselectable,';writeln(ft,s);
 end;//of if
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//Записывает границы анимации из A.
//sBeg - начальная строка (Tab'ы)
procedure SaveAnimBounds(a:TAnim;sBeg:string);
Var s:string;//i:integer;
Begin with a do begin
 //нижняя граница
 if (MinimumExtent[1]<>0) or (MinimumExtent[2]<>0) or
    (MinimumExtent[3]<>0) then begin
  s:=sBeg+'MinimumExtent { '+floattostrf(MinimumExtent[1],ffGeneral,7,5)+
     ', '+floattostrf(MinimumExtent[2],ffGeneral,7,5)+', '+
     floattostrf(MinimumExtent[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
 end;//of if
 //Верхняя граница
 if (MaximumExtent[1]<>0) or (MaximumExtent[2]<>0) or
    (MaximumExtent[3]<>0) then begin
  s:=sBeg+'MaximumExtent { '+floattostrf(MaximumExtent[1],ffGeneral,7,5)+
     ', '+floattostrf(MaximumExtent[2],ffGeneral,7,5)+', '+
     floattostrf(MaximumExtent[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
 end;//of if
 //Граничный радиус
 if BoundsRadius<>0 then begin
  s:=sBeg+'BoundsRadius '+floattostrf(BoundsRadius,ffGeneral,7,5)+',';
  if pos('INF',s)=0 then writeln(ft,s);
//  writeln(ft,s);
 end;//of if
end;End;
//---------------------------------------------------------
//Создает (записывает) заголовок MDL-файла
//Gz - кол-во "пустых" поверхностей
procedure SaveHeader(Gz:integer);
Var s:string;
Begin
 s:='//Modified with MdlVis.';    //начальный комментарий
 writeln(ft,s);
 s:='Version {'#13#10#09'FormatVersion 800,'#13#10'}';
 writeln(ft,s);                   //секция версии
 //Собственно описание модели
 s:='Model "'+ModelName+'" {';writeln(ft,s);
 s:=#09'NumGeosets '+inttostr(CountOfGeosets-Gz)+',';
 writeln(ft,s);
 if CountOfGeosetAnims<>0 then begin
  s:=#09'NumGeosetAnims '+inttostr(CountOfGeosetAnims)+',';
  writeln(ft,s);
 end;//of if
 if CountOfHelpers<>0 then begin
  s:=#09'NumHelpers '+inttostr(CountOfHelpers)+',';
  writeln(ft,s);
 end;//of if
 if CountOfLights<>0 then begin
  s:=#09'NumLights '+inttostr(CountOfLights)+',';
  writeln(ft,s);
 end;//of if
 if CountOfBones<>0 then begin
  s:=#09'NumBones '+inttostr(CountOfBones)+',';
  writeln(ft,s);
 end;//of if
 if CountOfAttachments<>0 then begin
  s:=#09'NumAttachments '+inttostr(CountOfAttachments)+',';
  writeln(ft,s);
 end;//of if
 if CountOfParticleEmitters1<>0 then begin
  s:=#09'NumParticleEmitters '+inttostr(CountOfParticleEmitters1)+',';
  writeln(ft,s);
 end;//of if
 if CountOfParticleEmitters<>0 then begin
  s:=#09'NumParticleEmitters2 '+inttostr(CountOfParticleEmitters)+',';
  writeln(ft,s);
 end;//of if
 if CountOfRibbonEmitters<>0 then begin
  s:=#09'NumRibbonEmitters '+inttostr(CountOfRibbonEmitters)+',';
  writeln(ft,s);
 end;//of if
 if CountOfEvents<>0 then begin
  s:=#09'NumEvents '+inttostr(CountOfEvents)+',';
  writeln(ft,s);
 end;//of if
 s:=#09'BlendTime 150,';writeln(ft,s);
 //Теперь - остаток
 SaveAnimBounds(AnimBounds,#09);
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//Сохранение списка последовательностей
procedure SaveSequences;
Var s:string;i:integer;
Begin
 if CountOfSequences=0 then exit;
 //Заголовок секции
 s:='Sequences '+inttostr(CountOfSequences)+' {';
 writeln(ft,s);
 //Все последовательности
 for i:=0 to CountOfSequences-1 do begin
  s:=#09'Anim "'+Sequences[i].Name+'" {';
  writeln(ft,s);                  //имя последовательности
  s:=#09#09'Interval { '+inttostr(Sequences[i].IntervalStart)+
     ', '+inttostr(Sequences[i].IntervalEnd)+' },';
  writeln(ft,s);                  //интервал
  //Запись необязательных компонент
  if Sequences[i].IsNonLooping then begin
   s:=#09#09'NonLooping,';writeln(ft,s);
  end;//of if
  if Sequences[i].Rarity>0 then begin
   s:=#09#09'Rarity '+inttostr(Sequences[i].Rarity)+',';
   writeln(ft,s);
  end;//of if
  if Sequences[i].MoveSpeed>0 then begin
   s:=#09#09'MoveSpeed '+inttostr(Sequences[i].MoveSpeed)+',';
   writeln(ft,s);
  end;//of if
  //Запись границ
  SaveAnimBounds(Sequences[i].Bounds,#09#09);
  s:=#09'}';writeln(ft,s);
 end;//of for i
 //конец секции
 s:='}';writeln(ft,s);

 //Теперь - глобальные последовательности
 if CountOfGlobalSequences=0 then exit;
 s:='GlobalSequences '+inttostr(CountOfGlobalSequences)+' {';
 writeln(ft,s);
 for i:=0 to CountOfGlobalSequences-1 do begin
  s:=#09'Duration '+inttostr(GlobalSequences[i])+',';
  writeln(ft,s);
 end;//of for i
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
procedure SaveTextures;
Var s:string;i:integer;
Begin
 //Начало секции
 s:='Textures '+inttostr(CountOfTextures)+' {';
 writeln(ft,s);
 //Подсекции изображений
 for i:=0 to CountOfTextures-1 do begin
  s:=#09'Bitmap {';writeln(ft,s);
  s:=#09#09'Image "'+Textures[i].FileName+'",';
  writeln(ft,s);
  //Необязательные компоненты
  if Textures[i].ReplaceableID<>0 then begin
   s:=#09#09'ReplaceableId '+inttostr(Textures[i].ReplaceableID)+',';
   writeln(ft,s);
  end;//of if
  if Textures[i].IsWrapWidth then begin
   s:=#09#09'WrapWidth,';writeln(ft,s);
  end;//of if
  if Textures[i].IsWrapHeight then begin
   s:=#09#09'WrapHeight,';writeln(ft,s);
  end;//of if
  s:=#09'}';writeln(ft,s);        //закрыть подсекцию
 end;//of for
 s:='}';writeln(ft,s);            //конец секции
End;
//---------------------------------------------------------
//Сохраняет контроллер из массива Controllers с номером cnum
//Отступает с помощью строки sBeg.
//sFirst - начало первой (вступительной) строки контроллера
procedure SaveController(cnum:integer;sBeg,sFirst:string);
Var i,ii:integer;s:string;
Begin
 //Начало секции контроллера
 s:=sFirst+inttostr(Length(Controllers[cnum].Items))+' {';
 writeln(ft,s);
 s:=sBeg;
 //Запишем тип контроллера:
 case Controllers[cnum].ContType of
  Linear:    s:=s+'Linear,';
  DontInterp:s:=s+'DontInterp,';
  Bezier:    s:=s+'Bezier,';
  Hermite:   s:=s+'Hermite,';
 end;//of case
 writeln(ft,s);
 //Глобальный ID
 if Controllers[cnum].GlobalSeqId>=0 then begin
  s:=sBeg+'GlobalSeqId '+inttostr(Controllers[cnum].GlobalSeqId)+',';
  writeln(ft,s);
 end;//of if
 //Запись каждого ключевого кадра
 for i:=0 to length(Controllers[cnum].Items)-1 do with Controllers[cnum] do begin
  s:=sBeg+inttostr(items[i].Frame)+': ';
  //Определение и запись элементов разного размера
  if SizeOfElement>1 then s:=s+'{ ';
  for ii:=1 to SizeOfElement do begin
   s:=s+floattostrf(items[i].data[ii],ffGeneral,7,0);
   if ii<SizeOfElement then s:=s+', ';
  end;//of for ii
  if SizeOfElement>1 then s:=s+' },' else s:=s+',';
  writeln(ft,s);
  //Запись тангенсов углов (если они есть)
  if (ContType=Hermite) or (ContType=Bezier) then begin
   s:=sBeg+#09'InTan ';
//   if SizeOfElement>1 then s:=s+' {';
   //Определение и запись элементов разного размера
   if SizeOfElement>1 then s:=s+'{ ';
   for ii:=1 to SizeOfElement do begin
    s:=s+floattostrf(items[i].InTan[ii],ffGeneral,7,0);
    if ii<SizeOfElement then s:=s+', ';
   end;//of for ii
   if SizeOfElement>1 then s:=s+' },' else s:=s+',';
   writeln(ft,s);
   s:=sBeg+#09'OutTan ';
//   if SizeOfElement>1 then s:=s+' {';
   //Определение и запись элементов разного размера
   if SizeOfElement>1 then s:=s+'{ ';
   for ii:=1 to SizeOfElement do begin
    s:=s+floattostrf(items[i].OutTan[ii],ffGeneral,7,0);
    if ii<SizeOfElement then s:=s+', ';
   end;//of for ii
   if SizeOfElement>1 then s:=s+' },' else s:=s+',';
   writeln(ft,s);
  end;//of if
 end;//of with/for
 //Завершение: закрыть секцию контроллера
 Delete(sBeg,1,1);
 s:=sBeg+'}';writeln(ft,s);
End;
//---------------------------------------------------------
procedure SaveMaterials;
Var s:string;i,ii:integer;
Begin
 s:='Materials '+inttostr(CountOfMaterials)+' {';
 writeln(ft,s);
 //Запись каждого материала
 for i:=0 to CountOfMaterials-1 do begin
  s:=#09'Material {';writeln(ft,s);//заголовок
  if Materials[i].IsConstantColor then begin
   s:=#09#09'ConstantColor,';writeln(ft,s);
  end;//of if
  if Materials[i].IsSortPrimsFarZ then begin
   s:=#09#09'SortPrimsFarZ,';writeln(ft,s);
  end;//of if
  if Materials[i].IsFullResolution then begin
   s:=#09#09'FullResolution,';writeln(ft,s);
  end;
  if Materials[i].PriorityPlane>=0 then begin
   s:=#09#09'PriorityPlane '+inttostr(Materials[i].PriorityPlane)+',';
   writeln(ft,s);
  end;//of if(PriorityPlane)
  //Запись слоев
  for ii:=0 to Materials[i].CountOfLayers-1 do with Materials[i].Layers[ii]do begin
   s:=#09#09'Layer {';writeln(ft,s);
   //Фильтр
   s:=#09#09#09'FilterMode '{+inttostr(FilterMode)};
   case FilterMode of
    Opaque:    s:=s+'None,';
    ColorAlpha:s:=s+'Transparent,';
    FullAlpha: s:=s+'Blend,';
    Additive:  s:=s+'Additive,';
    AddAlpha:  s:=s+'AddAlpha,';
    Modulate:  s:=s+'Modulate,';
    Modulate2X:s:=s+'Modulate2x,';
   end;//of case
   writeln(ft,s);
   //Необязательные компоненты слоя
   if IsUnshaded then begin
    s:=#09#09#09'Unshaded,';writeln(ft,s);
   end;//of if
   if IsSphereEnvMap then begin
    s:=#09#09#09'SphereEnvMap,';writeln(ft,s);
   end;
   if IsUnfogged then begin
    s:=#09#09#09'Unfogged,';writeln(ft,s);
   end;//of if
   if IsTwoSided then begin
    s:=#09#09#09'TwoSided,';writeln(ft,s);
   end;//of if
   if IsNoDepthTest then begin
    s:=#09#09#09'NoDepthTest,';writeln(ft,s);
   end;//of if
   if IsNoDepthSet then begin
    s:=#09#09#09'NoDepthSet,';writeln(ft,s);
   end;//of if
   //Текстура (ID)
   if IsTextureStatic then begin
    s:=#09#09#09'static TextureID '+inttostr(TextureID)+',';
    writeln(ft,s);
   end else begin
    s:=#09#09#09'TextureID ';        //начальная строка
    SaveController(NumOfTexGraph,#09#09#09#09,s);
   end;//of if (texture)
   //TVertexAnimID (если есть)
   if TVertexAnimID>=0 then begin
    s:=#09#09#09'TVertexAnimId '+inttostr(TVertexAnimID)+',';
    writeln(ft,s);
   end;//of if
   //CoordID:
   if CoordID>=0 then begin
    s:=#09#09#09'CoordId '+inttostr(CoordID)+',';
    writeln(ft,s);
   end;//of if
   //Альфа-компонент
//   if Alpha>=0 then begin
   if IsAlphaStatic then begin   //альфа постоянен
    if Alpha>=0 then begin
     s:=#09#09#09'static Alpha '+floattostrf(Alpha,ffGeneral,7,5)+',';
     writeln(ft,s);
    end;//of if
   end else begin                //альфа изменяется
     s:=#09#09#09'Alpha ';        //начальная строка
     SaveController(NumOfGraph,#09#09#09#09,s);
   end;//of if (AlphaStatic)
//   end;//of if (Alpha)
   //Конец подсекции
   s:=#09#09'}';writeln(ft,s);
  end;//of with/for ii
  s:=#09'}';writeln(ft,s);
 end;//of for i
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//Сохраняет секцию текстурных анимаций
procedure SaveTextureAnims;
Var i:integer;s:string;
Begin
 if CountOfTextureAnims=0 then exit;//нечего сохранять
 //Заголовок секции
 s:='TextureAnims '+inttostr(CountOfTextureAnims)+' {';
 writeln(ft,s);
 for i:=0 to CountOfTextureAnims-1 do begin
  s:=#09'TVertexAnim {';writeln(ft,s);//заголовок подсекции
  if TextureAnims[i].TranslationGraphNum>=0 then begin
   s:=#09#09'Translation ';
   SaveController(TextureAnims[i].TranslationGraphNum,#09#09#09,s);
  end;//of if (Translation)
  if TextureAnims[i].RotationGraphNum>=0 then begin
   s:=#09#09'Rotation ';
   SaveController(TextureAnims[i].RotationGraphNum,#09#09#09,s);
  end;//of if (Translation)
  if TextureAnims[i].ScalingGraphNum>=0 then begin
   s:=#09#09'Scaling ';
   SaveController(TextureAnims[i].ScalingGraphNum,#09#09#09,s);
  end;//of if (Translation)
  //конец подсекции
  s:=#09'}';writeln(ft,s);
 end;//of for i
 s:='}';writeln(ft,s);            //конец секции
End;
//---------------------------------------------------------
//Сохраняет анимации видимости поверхностей
procedure SaveGeosetAnims;
Var i:integer;s:string;
Begin
 for i:=0 to CountOfGeosetAnims-1 do begin
  s:='GeosetAnim {';writeln(ft,s);

  //0. Флаг DropShadow
  if GeosetAnims[i].IsDropShadow then begin
   s:=#09'DropShadow,';writeln(ft,s);
  end;//of if(IsDropShadow)
  //1. Альфа-компонент
  if GeosetAnims[i].IsAlphaStatic then begin //static
   if GeosetAnims[i].Alpha>=0 then begin
    s:=#09'static Alpha '+floattostrf(GeosetAnims[i].Alpha,ffGeneral,7,0)+
      ',';
    writeln(ft,s);
   end;//of if
  end else begin                  //dynamic
   s:=#09'Alpha ';
   SaveController(GeosetAnims[i].AlphaGraphNum,#09#09,s);
  end;//of if

  //2. Цветовой компонент
  if GeosetAnims[i].IsColorStatic then begin //static
   if GeosetAnims[i].Color[1]>=0 then begin
    s:=#09'static Color { '+floattostrf(GeosetAnims[i].Color[1],ffGeneral,7,0)+
      ', '+floattostrf(GeosetAnims[i].Color[2],ffGeneral,7,0)+
      ', '+floattostrf(GeosetAnims[i].Color[3],ffGeneral,7,0)+
      ' },';
    writeln(ft,s);
   end;//of if
  end else begin                  //dynamic
   s:=#09'Color ';
   SaveController(GeosetAnims[i].ColorGraphNum,#09#09,s);
  end;//of if

  //3. GeosetID
  s:=#09'GeosetId '+inttostr(GeosetAnims[i].GeosetID)+',';
  writeln(ft,s);
  s:='}';writeln(ft,s); 
 end;//of for
End;
//---------------------------------------------------------
//Вспомогательная: сохраняет элемент TBone
//Записывает в файл элемент b.
//Если IsBone=true, он помечается как Bone,
//иначе - как Helper.
procedure SaveTBone(IsBone:boolean;b:TBone);
Var s:string;
Begin
 //1. Запись начала секции
 if IsBone then s:='Bone ' else s:='Helper ';
 s:=s+'"'+b.Name+'" {';writeln(ft,s);
 //2. По порядку все компоненты:
 if b.ObjectID>=0 then begin
  s:=#09'ObjectId '+inttostr(b.ObjectID)+',';
  writeln(ft,s);
 end;//of if

 if b.Parent>=0 then begin
  s:=#09'Parent '+inttostr(b.Parent)+',';
  writeln(ft,s);
 end;//of if

 if b.IsBillboardedLockZ then begin
  s:=#09'BillboardedLockZ,';writeln(ft,s);
 end;//of if
 if b.IsBillboardedLockY then begin
  s:=#09'BillboardedLockY,';writeln(ft,s);
 end;//of if
 if b.IsBillboardedLockX then begin
  s:=#09'BillboardedLockX,';writeln(ft,s);
 end;//of if
 if b.IsBillboarded then begin
  s:=#09'Billboarded,';writeln(ft,s);
 end;//of if
 if b.IsCameraAnchored then begin
  s:=#09'CameraAnchored,';writeln(ft,s);
 end;//of if

 if (b.GeosetID>=0) or (b.GeosetID=Multiple) then begin
  s:=#09'GeosetId ';
  if b.GeosetID=Multiple then s:=s+'Multiple,'
                         else s:=s+inttostr(b.GeosetID)+',';
  writeln(ft,s);
 end;//of if

 if (b.GeosetAnimID=None) or (b.GeosetAnimID>=0) then begin
  s:=#09'GeosetAnimId ';
  if b.GeosetAnimID=None then s:=s+'None,'
                         else s:=s+inttostr(b.GeosetAnimID)+',';
  writeln(ft,s);
 end;//of if

 //Запись списка "не-наследований"
 if b.IsDIRotation or b.IsDITranslation or b.IsDIScaling then begin
  s:=#09'DontInherit { ';
  if b.IsDIRotation then s:=s+'Rotation';
  if b.IsDITranslation then begin
   if length(s)>16 then s:=s+', ';
   s:=s+'Translation';
  end;//of if (Translation)
  if b.IsDIScaling then begin
   if length(s)>16 then s:=s+', ';
   s:=s+'Scaling';
  end;//of if (Translation)
  s:=s+' },';
  writeln(ft,s);
 end;//of if

 //Теперь - преобразования
 if b.Translation>=0 then begin
  s:=#09'Translation ';
  SaveController(b.Translation,#09#09,s);
 end;//of if

 if b.Rotation>=0 then begin
  s:=#09'Rotation ';
  SaveController(b.Rotation,#09#09,s);
 end;//of if

 if b.Scaling>=0 then begin
  s:=#09'Scaling ';
  SaveController(b.Scaling,#09#09,s);
 end;//of if

 if b.Visibility>=0 then begin
  s:=#09'Visibility ';
  SaveController(b.Visibility,#09#09,s);
 end;//of if

 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//Сохраняет список костей
procedure SaveBones;
Var i:integer;
Begin
 for i:=0 to CountOfBones-1 do SaveTBone(true,bones[i]);
End;
//---------------------------------------------------------
//Сохраняет список помощников
procedure SaveHelpers;
Var i:integer;
Begin
 for i:=0 to CountOfHelpers-1 do SaveTBone(false,helpers[i]);
End;
//---------------------------------------------------------
//Сохраняет источники света
procedure SaveLights;
Var i:integer;s,s2:string;
Begin
 if CountOfLights=0 then exit;    //нечего сохранять
 for i:=0 to CountOfLights-1 do begin
  //Заголовок Источника
  s:='Light "'+Lights[i].Skel.Name+'" {';
  writeln(ft,s);
  s:=#09'ObjectId '+inttostr(Lights[i].Skel.ObjectID)+',';
  writeln(ft,s);
  if Lights[i].Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Lights[i].Skel.Parent)+',';
   writeln(ft,s);
  end;//of if(Parent)

  //Флаги Billboard
  if Lights[i].Skel.IsBillboardedLockZ then begin
   s:=#09'BillboardedLockZ,';writeln(ft,s);
  end;//of if
  if Lights[i].Skel.IsBillboardedLockY then begin
   s:=#09'BillboardedLockY,';writeln(ft,s);
  end;//of if
  if Lights[i].Skel.IsBillboardedLockX then begin
   s:=#09'BillboardedLockX,';writeln(ft,s);
  end;//of if
  if Lights[i].Skel.IsBillboarded then begin
   s:=#09'Billboarded,';writeln(ft,s);
  end;//of if
  if Lights[i].Skel.IsCameraAnchored then begin
   s:=#09'CameraAnchored,';writeln(ft,s);
  end;//of if

  //Блок DontInherit
  if Lights[i].Skel.IsDIRotation or Lights[i].Skel.IsDITranslation or
     Lights[i].Skel.IsDIScaling then begin
   s:=#09'DontInherit { ';s2:='';
   if Lights[i].Skel.IsDIRotation then s2:='Rotation';
   if Lights[i].Skel.IsDITranslation then s2:='Translation';
   if Lights[i].Skel.IsDIScaling then s2:='Scaling';
   s:=s+s2+' },';
   writeln(ft,s);
  end;//of if (Inherit)

  //Тип источника света
  case Lights[i].LightType of
   Omnidirectional:s:=#09'Omnidirectional,';
   Directional:s:=#09'Directional,';
   Ambient:s:=#09'Ambient,';
  end;//of case
  writeln(ft,s);

  //Интенсивность и цвет
  if Lights[i].AttenuationStart<>-1 then begin
   if Lights[i].IsASStatic then begin
    s:=#09'static AttenuationStart '+floattostrf(Lights[i].AttenuationStart,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Lights[i].AttenuationStart),
            #09#09,#09'AttenuationStart ');
  end;//of if(AttStart)
  if Lights[i].AttenuationEnd<>-1 then begin
   if Lights[i].IsAEStatic then begin
    s:=#09'static AttenuationEnd '+floattostrf(Lights[i].AttenuationEnd,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Lights[i].AttenuationEnd),
            #09#09,#09'AttenuationEnd ');
  end;//of if(AttEnd)

  if Lights[i].Intensity<>-1 then begin
   if Lights[i].IsIStatic then begin
    s:=#09'static Intensity '+floattostrf(Lights[i].Intensity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Lights[i].Intensity),
            #09#09,#09'Intensity ');
  end;//of if(Intensity)

  if Lights[i].Color[1]>-1 then begin
   if Lights[i].IsCStatic then begin
    s:=#09'static Color { '+floattostrf(Lights[i].Color[1],ffGeneral,7,5)+', '
                           +floattostrf(Lights[i].Color[2],ffGeneral,7,5)+', '
                           +floattostrf(Lights[i].Color[3],ffGeneral,7,5)+' },';
    writeln(ft,s);
   end else SaveController(round(Lights[i].Color[1]),
            #09#09,#09'Color ');
  end;//of if(Color)

  //И еще интенсивность+цвет
  if Lights[i].AmbIntensity<>-1 then begin
   if Lights[i].IsAIStatic then begin
    s:=#09'static AmbIntensity '+floattostrf(Lights[i].AmbIntensity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Lights[i].AmbIntensity),
            #09#09,#09'AmbIntensity ');
  end;//of if(AmbInt)
  if Lights[i].AmbColor[1]>-1 then begin
   if Lights[i].IsACStatic then begin
    s:=#09'static AmbColor { '+floattostrf(Lights[i].AmbColor[1],ffGeneral,7,5)+', '
                           +floattostrf(Lights[i].AmbColor[2],ffGeneral,7,5)+', '
                           +floattostrf(Lights[i].AmbColor[3],ffGeneral,7,5)+' },';
    writeln(ft,s);
   end else SaveController(round(Lights[i].AmbColor[1]),
            #09#09,#09'AmbColor ');
  end;//of if(AmbColor)

  //Теперь - контроллеры трансформаций
  if Lights[i].Skel.Visibility>=0 then
     SaveController(Lights[i].Skel.Visibility,#09#09,#09'Visibility ');
  if Lights[i].Skel.Translation>=0 then
     SaveController(Lights[i].Skel.Translation,#09#09,#09'Translation ');
  if Lights[i].Skel.Rotation>=0 then
     SaveController(Lights[i].Skel.Rotation,#09#09,#09'Rotation ');
  if Lights[i].Skel.Scaling>=0 then
     SaveController(Lights[i].Skel.Scaling,#09#09,#09'Scaling ');
  s:='}';
  writeln(ft,s);   
 end;//of for i
End;
//---------------------------------------------------------
//Сохраняет точки прикрепления
procedure SaveAttachments;
Var i:integer;s,s2:string;
Begin
 for i:=0 to CountOfAttachments-1 do with Attachments[i] do begin
  //1. Заголовок секции
  s:='Attachment "'+Skel.Name+'" {';
  writeln(ft,s);
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //Флаги Billboard
  if Skel.IsBillboardedLockZ then begin
   s:=#09'BillboardedLockZ,';writeln(ft,s);
  end;//of if
  if Skel.IsBillboardedLockY then begin
   s:=#09'BillboardedLockY,';writeln(ft,s);
  end;//of if
  if Skel.IsBillboardedLockX then begin
   s:=#09'BillboardedLockX,';writeln(ft,s);
  end;//of if
  if Skel.IsBillboarded then begin
   s:=#09'Billboarded,';writeln(ft,s);
  end;//of if
  if Skel.IsCameraAnchored then begin
   s:=#09'CameraAnchored,';writeln(ft,s);
  end;//of if

    //Блок DontInherit
  if Skel.IsDIRotation or Skel.IsDITranslation or
     Skel.IsDIScaling then begin
   s:=#09'DontInherit { ';s2:='';
   if Skel.IsDIRotation then s2:='Rotation';
   if Skel.IsDITranslation then s2:='Translation';
   if Skel.IsDIScaling then s2:='Scaling';
   s:=s+s2+' },';
   writeln(ft,s);
  end;//of if (Inherit)

  //Оставшиеся поля
  if AttachmentID>=0 then begin
   s:=#09'AttachmentID '+inttostr(AttachmentID)+',';
   writeln(ft,s);
  end;//of if
  if Path<>'' then begin
   s:=#09'Path "'+path+'",';
   writeln(ft,s);
  end;//of if

  //Теперь - контроллеры трансформаций
  if Skel.Visibility>=0 then
     SaveController(Skel.Visibility,#09#09,#09'Visibility ');
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  //Конец секции
  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//Сохранение геометрических центров
procedure SavePivots;
Var i:integer;s:string;
Begin
 s:='PivotPoints '+inttostr(CountOfPivotPoints)+' {';
 writeln(ft,s);
 for i:=0 to CountOfPivotPoints-1 do begin
  s:=#09'{ '+floattostrf(PivotPoints[i,1],ffGeneral,7,5)+
        ', '+floattostrf(PivotPoints[i,2],ffGeneral,7,5)+
        ', '+floattostrf(PivotPoints[i,3],ffGeneral,7,5)+' },';
  writeln(ft,s); //floattostrf
 end;//of for i
 //закрываем секцию
 s:='}';writeln(ft,s);
End;
//---------------------------------------------------------
//Сохраняет источники частиц старой версии
procedure SaveParticleEmitters1;
Var i:integer;s:string;
Begin
 for i:=0 to CountOfParticleEmitters1-1 do with ParticleEmitters1[i] do begin
  //Запись заголовка
  s:='ParticleEmitter "'+Skel.name+'" {';
  writeln(ft,s);
  //Начинаем запись полей
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if
  //Флаг модели
  if UsesType=EmitterUsesTGA then s:=#09'EmitterUsesTGA,'
                             else s:=#09'EmitterUsesMDL,';
  writeln(ft,s);

  //статикодинамические свойства
  if EmissionRate<>-1 then begin
   if IsERStatic then begin
    s:=#09'static EmissionRate '+floattostrf(EmissionRate,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(EmissionRate),
            #09#09,#09'EmissionRate ');
  end;
  if Gravity<>cNone then begin
   if IsGStatic then begin
    s:=#09'static Gravity '+floattostrf(Gravity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Gravity),
            #09#09,#09'Gravity ');
  end;
  if Longitude<>-1 then begin
   if IsLongStatic then begin
    s:=#09'static Longitude '+floattostrf(Longitude,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Longitude),
            #09#09,#09'Longitude ');
  end;
  if Latitude<>-1 then begin
   if IsLatStatic then begin
    s:=#09'static Latitude '+floattostrf(Latitude,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Latitude),
            #09#09,#09'Latitude ');
  end;

  //Записываем контроллер видимости
  if Skel.Visibility>=0 then
     SaveController(Skel.Visibility,#09#09,#09'Visibility ');

  //Теперь - подсекцию параметров частицы
  s:=#09'Particle {';writeln(ft,s);//заголовок
  if LifeSpan<>-1 then begin
   if IsLSStatic then begin
    s:=#09#09'static LifeSpan '+floattostrf(LifeSpan,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(LifeSpan),
            #09#09#09,#09#09'LifeSpan ');
  end;//of if(LifeSpan)
  if InitVelocity<>cNone then begin
   if IsIVStatic then begin
    s:=#09#09'static InitVelocity '+floattostrf(InitVelocity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(InitVelocity),
            #09#09#09,#09#09'InitVelocity ');
  end;//of if(InitVelocity)
  if Path<>'' then begin
   s:=#09#09'Path "'+path+'",';
   writeln(ft,s);
  end;//of if(Path)
  //Закрываем подсекцию
  s:=#09'}';writeln(ft,s);

  //Оставшиеся контроллеры
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  //Закрыть секцию:
  s:='}';writeln(ft,s);
//  ParticleEmitters1[i]
 end;//of for i
End;
//---------------------------------------------------------
//Сохраняет источники частиц новой версии
procedure SaveParticleEmitters2;
Var i,ii{,j}:integer;s,s2:string;
Begin
 for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
  //Записать заголовок
  s:='ParticleEmitter2 "'+Skel.name+'" {';
  writeln(ft,s);
  //Стандартные ID
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //Наследование
  if Skel.IsDIRotation or Skel.IsDITranslation or
     Skel.IsDIScaling then begin
   s:=#09'DontInherit { ';s2:='';
   if Skel.IsDIRotation then s2:='Rotation';
   if Skel.IsDITranslation then s2:='Translation';
   if Skel.IsDIScaling then s2:='Scaling';
   s:=s+s2+' },';
   writeln(ft,s);
  end;//of if (Inherit)

  if IsSortPrimsFarZ then begin
   s:=#09'SortPrimsFarZ,';writeln(ft,s);
  end;//of if
  if IsUnshaded then begin
   s:=#09'Unshaded,';writeln(ft,s);
  end;//of if
  if IsLineEmitter then begin
   s:=#09'LineEmitter,';writeln(ft,s);
  end;//of if
  if IsUnfogged then begin
   s:=#09'Unfogged,';writeln(ft,s);
  end;//of if
  if IsModelSpace then begin
   s:=#09'ModelSpace,';writeln(ft,s);
  end;//of if
  if IsXYQuad then begin
   s:=#09'XYQuad,';writeln(ft,s);
  end;//of if

  //Запись статикодинамических параметров
  if Speed<>cNone then begin
   if IsSStatic then begin
    s:=#09'static Speed '+floattostrf(Speed,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Speed),
            #09#09,#09'Speed ');
  end;//of if(Speed)
  if Variation<>-1 then begin
   if IsVStatic then begin
    s:=#09'static Variation '+floattostrf(Variation,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Variation),
            #09#09,#09'Variation ');
  end;//of if(Variation)
  if Latitude<>cNone then begin
   if IsLStatic then begin
    s:=#09'static Latitude '+floattostrf(Latitude,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Latitude),
            #09#09,#09'Latitude ');
  end;//of if(Latitude)
  if Gravity<>cNone then begin
   if IsGStatic then begin
    s:=#09'static Gravity '+floattostrf(Gravity,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Gravity),
            #09#09,#09'Gravity ');
  end;//of if(Gravity)

  //контроллер видимости
  if Skel.Visibility>=0 then
     SaveController(Skel.Visibility,#09#09,#09'Visibility ');
  //Флаг струи
  if IsSquirt then begin
   s:=#09'Squirt,';writeln(ft,s);
  end;//of if
  //Время жизни:
  if LifeSpan<>cNone then begin
   s:=#09'LifeSpan '+floattostrf(LifeSpan,ffGeneral,7,5)+',';
   writeln(ft,s);
  end;//of if(LifeSpan)

  //еще порция статикодинамических параметров
  if EmissionRate<>cNone then begin
   if IsEStatic then begin
    s:=#09'static EmissionRate '+floattostrf(EmissionRate,
                ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(EmissionRate),
            #09#09,#09'EmissionRate ');
  end;//of if(EmissionRate)
  //ширина, высота
  if IsWStatic then begin
   s:=#09'static Width '+floattostrf(Width,ffGeneral,7,5)+',';
   writeln(ft,s);
  end else SaveController(round(Width),#09#09,#09'Width ');
  if IsHStatic then begin
   s:=#09'static Length '+floattostrf(Length,ffGeneral,7,5)+',';
   writeln(ft,s);
  end else SaveController(round(Length),#09#09,#09'Length ');

  //режим смешения
  case BlendMode of
   FullAlpha:s:=#09'Blend,';
   Additive:s:=#09'Additive,';
   Modulate:s:=#09'Modulate,';
   AlphaKey:s:=#09'AlphaKey,';
  end;//of case
  writeln(ft,s);

  //строки, столбцы
  s:=#09'Rows '+inttostr(Rows)+',';
  writeln(ft,s);
  s:=#09'Columns '+inttostr(Columns)+',';
  writeln(ft,s);

  //Тип отображения
  case ParticleType of
   ptHead:s:=#09'Head,';
   ptTail:s:=#09'Tail,';
   ptBoth:s:=#09'Both,';
  end;//of case
  writeln(ft,s);

  //Длина хвоста, время
  if TailLength>=0 then begin
    s:=#09'TailLength '+floattostrf(TailLength,ffGeneral,7,5)+',';
    writeln(ft,s);
  end;//of if(TailLength)
  if Time>=0 then begin
    s:=#09'Time '+floattostrf(Time,ffGeneral,7,5)+',';
    writeln(ft,s);
  end;//of if(Time)

  //Окраска
  s:=#09'SegmentColor {';writeln(ft,s); //заголовок
  for ii:=1 to 3 do begin
   s:=#09#09'Color { '+floattostrf(SegmentColor[ii,1],ffGeneral,7,5)+
            ', '+floattostrf(SegmentColor[ii,2],ffGeneral,7,5)+
            ', '+floattostrf(SegmentColor[ii,3],ffGeneral,7,5)+' },';
   writeln(ft,s);
  end;//of for ii
  s:=#09'},';writeln(ft,s);        //закрыть подсекцию

  //Прозрачность
  s:=#09'Alpha {'+inttostr(Alpha[1])+', '+inttostr(Alpha[2])+', '+
        inttostr(Alpha[3])+'},';
  writeln(ft,s);
  //Масштаб
  s:=#09'ParticleScaling {'+floattostrf(ParticleScaling[1],ffGeneral,7,5)+
        ', '+floattostrf(ParticleScaling[2],ffGeneral,7,5)+', '+
             floattostrf(ParticleScaling[3],ffGeneral,7,5)+'},';
  writeln(ft,s);
  //UV-параметры
  s:=#09'LifeSpanUVAnim {'+inttostr(LifeSpanUVAnim[1])+', '
        +inttostr(LifeSpanUVAnim[2])+', '
        +inttostr(LifeSpanUVAnim[3])+'},';
  writeln(ft,s);
  s:=#09'DecayUVAnim {'+inttostr(DecayUVAnim[1])+', '
        +inttostr(DecayUVAnim[2])+', '
        +inttostr(DecayUVAnim[3])+'},';
  writeln(ft,s);
  s:=#09'TailUVAnim {'+inttostr(TailUVAnim[1])+', '
        +inttostr(TailUVAnim[2])+', '
        +inttostr(TailUVAnim[3])+'},';
  writeln(ft,s);
  s:=#09'TailDecayUVAnim {'+inttostr(TailDecayUVAnim[1])+', '
        +inttostr(TailDecayUVAnim[2])+', '
        +inttostr(TailDecayUVAnim[3])+'},';
  writeln(ft,s);

  //Текстура и ряд ID
  if TextureID>=0 then begin
   s:=#09'TextureID '+inttostr(TextureID)+',';
   writeln(ft,s);
  end;//of if (Texture)
  if ReplaceableId>0 then begin
   s:=#09'ReplaceableId '+inttostr(ReplaceableId)+',';
   writeln(ft,s);
  end;//of if (ReplaceableId)
  if PriorityPlane>=0 then begin
   s:=#09'PriorityPlane '+inttostr(PriorityPlane)+',';
   writeln(ft,s);
  end;//of if (PriorityPlane)

  //И, наконец, контроллеры анимации
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  s:='}';writeln(ft,s);           //закрыть секцию
 end;//of for i
End;
//---------------------------------------------------------
//Сохраняет источники следа
procedure SaveRibbonEmitters;
Var s:string;i:integer;
Begin
 for i:=0 to CountOfRibbonEmitters-1 do with ribs[i] do begin
  s:='RibbonEmitter "'+Skel.Name+'" {';
  writeln(ft,s);                  //запись
  //Стандартные ID
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //Статикодинамические параметры
  if HeightAbove<>cNone then begin
   if IsHAStatic then begin
    s:=#09'static HeightAbove '+floattostrf(HeightAbove,ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(HeightAbove),#09#09,#09'HeightAbove ');
  end;//of if
  if HeightBelow<>cNone then begin
   if IsHBStatic then begin
    s:=#09'static HeightBelow '+floattostrf(HeightBelow,ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(HeightBelow),#09#09,#09'HeightBelow ');
  end;//of if
  if Alpha>-1 then begin
   if IsAlphaStatic then begin
    s:=#09'static Alpha '+floattostrf(Alpha,ffGeneral,7,5)+',';
    writeln(ft,s);
   end else SaveController(round(Alpha),#09#09,#09'Alpha ');
  end;//of if

   if IsColorStatic then begin
    s:=#09'static Color { '+floattostrf(Color[1],ffGeneral,7,5)+', '+
                           floattostrf(Color[2],ffGeneral,7,5)+', '+
                           floattostrf(Color[3],ffGeneral,7,5)+' },';
    writeln(ft,s);
   end else SaveController(round(Color[1]),#09#09,#09'Color ');

  if TextureSlot>-1 then begin
   if IsTSStatic then begin
    s:=#09'static TextureSlot '+inttostr(TextureSlot)+',';
    writeln(ft,s);
   end else SaveController(TextureSlot,#09#09,#09'TextureSlot ');
  end;//of if

  //Контроллер видимости
  if Skel.Visibility>=0 then
     SaveController(Skel.Visibility,#09#09,#09'Visibility ');

  //Ряд других параметров
  if EmissionRate<>cNone then begin
    s:=#09'EmissionRate '+inttostr(EmissionRate)+',';
    writeln(ft,s);
  end;//of if(EmissionRate)
  if LifeSpan>=0 then begin
    s:=#09'LifeSpan '+floattostrf(LifeSpan,ffGeneral,7,5)+',';
    writeln(ft,s);
  end;//of if(LifeSpan)
  if Gravity<>cNone then begin
    s:=#09'Gravity '+floattostrf(Gravity,ffGeneral,7,5)+',';
    writeln(ft,s);
  end;//of if(Gravity)
  if Rows>0 then begin
    s:=#09'Rows '+inttostr(Rows)+',';
    writeln(ft,s);
  end;//of if(Rows)
  if Columns>0 then begin
    s:=#09'Columns '+inttostr(Columns)+',';
    writeln(ft,s);
  end;//of if(Columns)
  if MaterialID>=0 then begin
    s:=#09'MaterialID '+inttostr(MaterialID)+',';
    writeln(ft,s);
  end;//of if(MaterialID)

  //Оставшиеся контроллеры
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  //Закрыть секцию
  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//Сохраняет камеры
procedure SaveCameras;
Var s:string;i:integer;
Begin
 for i:=0 to CountOfCameras-1 do with Cameras[i] do begin
  //Заголовок секции
  s:='Camera "'+name+'" {';
  writeln(ft,s);

  //Запись позиции
  s:=#09'Position { '+floattostrf(position[1],ffGeneral,7,5)+', '+
                      floattostrf(position[2],ffGeneral,7,5)+', '+
                      floattostrf(position[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
  //Запись контроллеров позиции
  if TranslationGraphNum>=0 then
     SaveController(TranslationGraphNum,#09#09,#09'Translation ');
  if RotationGraphNum>=0 then
     SaveController(RotationGraphNum,#09#09,#09'Rotation ');

  //Поля камеры
  if FieldOfView>=0 then begin
   s:=#09'FieldOfView '+floattostrf(FieldOfView,ffGeneral,7,5)+',';
   writeln(ft,s);
  end;//of if FieldOfView
  if FarClip<>cNone then begin
   s:=#09'FarClip '+floattostrf(FarClip,ffGeneral,7,5)+',';
   writeln(ft,s);
  end;//of if FarClip
  if NearClip<>cNone then begin
   s:=#09'NearClip '+floattostrf(NearClip,ffGeneral,7,5)+',';
   writeln(ft,s);
  end;//of if NearClip

  //Цель камеры
  s:=#09'Target {';writeln(ft,s); //заголовок подсекции
  s:=#09#09'Position { '+floattostrf(Targetposition[1],ffGeneral,7,5)+', '+
                      floattostrf(Targetposition[2],ffGeneral,7,5)+', '+
                      floattostrf(Targetposition[3],ffGeneral,7,5)+' },';
  writeln(ft,s);
  if TranslationGraphNum>=0 then
     SaveController(TargetTGNum,#09#09#09,#09#09'Translation ');
  //закрыть подсекцию
  s:=#09'}';writeln(ft,s);
  //Закрыть секцию
  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//Сохраняет события (спецэффекты)
procedure SaveEvents;
Var s:string;i,ii:integer;
Begin
 for i:=0 to CountOfEvents-1 do with events[i] do begin
  s:='EventObject "'+uppercase(Skel.name)+'" {';
  writeln(ft,s);
  //Начальная часть
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //Собственно список кадров срабатывания
  s:=#09'EventTrack '+inttostr(CountOfTracks)+' {';
  writeln(ft,s);
  for ii:=0 to CountOfTracks-1 do begin
   s:=#09#09+inttostr(Tracks[ii])+',';
   writeln(ft,s);
  end;//of for ii
  s:=#09'}';writeln(ft,s);

  //Контроллеры
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//Запись объектов границ
procedure SaveCollisionObjects;
Var s:string;i,ii:integer;
Begin
 for i:=0 to CountOfCollisionShapes-1 do with Collisions[i] do begin
  s:='CollisionShape "'+Skel.name+'" {';
  writeln(ft,s);

  //Начальная часть
  if Skel.ObjectID>=0 then begin
   s:=#09'ObjectId '+inttostr(Skel.objectID)+',';
   writeln(ft,s);
  end;//of if
  if Skel.Parent>=0 then begin
   s:=#09'Parent '+inttostr(Skel.Parent)+',';
   writeln(ft,s);
  end;//of if

  //Тип объекта
  if objType=cBox then s:=#09'Box,' else s:=#09'Sphere,';
  writeln(ft,s);
  //Список вершин
  s:=#09'Vertices '+inttostr(Collisions[i].CountOfVertices)+' {';
  writeln(ft,s);
  //Записываем каждую вершину
  for ii:=0 to Collisions[i].CountOfVertices-1 do begin
   s:=#09#09'{ '+floattostrf(Collisions[i].Vertices[ii,1],ffGeneral,7,5)+
            ', '+floattostrf(Collisions[i].Vertices[ii,2],ffGeneral,7,5)+
            ', '+floattostrf(Collisions[i].Vertices[ii,3],ffGeneral,7,5)+
            ' },';
   writeln(ft,s);
  end;//of for ii
  s:=#09'}';writeln(ft,s);

  //Граничный радиус
  if (objType=cSphere) and (BoundsRadius>=0) then begin
   s:=#09'BoundsRadius '+floattostrf(BoundsRadius,ffGeneral,7,5)+',';
   if pos('INF',s)=0 then writeln(ft,s);
  end;//of if BoundsRadius

  //контроллеры
  if Skel.Translation>=0 then
     SaveController(Skel.Translation,#09#09,#09'Translation ');
  if Skel.Rotation>=0 then
     SaveController(Skel.Rotation,#09#09,#09'Rotation ');
  if Skel.Scaling>=0 then
     SaveController(Skel.Scaling,#09#09,#09'Scaling ');

  //конец секции
  s:='}';writeln(ft,s);
 end;//of for i
End;
//---------------------------------------------------------
//Сохраняет иерархию WoW для последующей загрузки
//fname - имя файла модели
{procedure SaveHierarchy(fName:string);
Var fh:file of integer;i:integer;
Begin
 //1. Сделаем файл "MDH"
 fname[length(fname)]:='h';
 //2. Создадим его
 AssignFile(fh,fname);
 rewrite(fh);
 //3. Запись всех HierID
 for i:=0 to CountOfGeosets-1 do write(fh,Geosets[i].HierID);
 CloseFile(fh);
End;
//---------------------------------------------------------
procedure DeleteHierarchy(fName:string);
Begin
 //1. Сделаем файл "MDH"
 fname[length(fname)]:='h';
 DeleteFile(fname);
End;}
//---------------------------------------------------------

//запись спец. информации MdlVis
procedure MDLSaveMdlVisInformation;
Var s:string; i,ii,len:integer;
Begin
 if not IsCanSaveMDVI then exit;
 if (not IsWoW) and (COMidNormals=0) and (COConstNormals=0) then exit;
 
 s:='MDLVisInformation {'; writeln(ft,s);

 //1. Если нужно, запишем WoW-иерархию
 if IsWoW then begin
  s:=#09'WoWHierarchy {'; writeln(ft,s);
  s:=#09#09;
  for i:=0 to CountOfGeosets-1 do s:=s+inttostr(Geosets[i].HierID)+',';
  writeln(ft,s);
  s:=#09'}'; writeln(ft,s);
 end;//of if

 //2.0. Проверим, есть ли группы сглаживания
 i:=0;
 while i<COMidNormals do begin
  if length(MidNormals[i])=0 then begin
   for ii:=i to COMidNormals-2 do MidNormals[ii]:=MidNormals[ii+1];
   dec(COMidNormals);
   SetLength(MidNormals,COMidNormals);
   continue;
  end;//of if
  inc(i);
 end;//of while
 
 //2. Если нужно, запишем группы сглаживания
 if COMidNormals>0 then begin
  s:=#09'SmoothGroups '+inttostr(COMidNormals)+' {';
  writeln(ft,s);
  for i:=0 to COMidNormals-1 do begin
   len:=length(MidNormals[i]);
   s:=#09#09'SGroup '+inttostr(len)+' { ';
   for ii:=0 to len-1 do begin
    s:=s+inttostr(MidNormals[i,ii].GeoID)+', '+
         inttostr(MidNormals[i,ii].VertID)+',  ';
   end;//of for ii
   s:=s+'},'; writeln(ft,s);
  end;//of for i
  s:=#09'}';
  writeln(ft,s);
 end;//of if

 //3. Если нужно, выпишем константные нормали
 if COConstNormals>0 then begin
  s:=#09'EditedNormals '+inttostr(COConstNormals)+' {';
  writeln(ft,s);
  for i:=0 to COConstNormals-1 do begin
   s:=#09#09'{ '+inttostr(ConstNormals[i].GeoID)+', '+
                 inttostr(ConstNormals[i].VertID)+',  '+
      floattostrf(ConstNormals[i].n[1],ffGeneral,7,5)+', '+
      floattostrf(ConstNormals[i].n[1],ffGeneral,7,5)+', '+
      floattostrf(ConstNormals[i].n[1],ffGeneral,7,5)+' },';
   writeln(ft,s);
  end;//of for i
  s:=#09'}'; writeln(ft,s);
 end;//of if
 s:='}'; writeln(ft,s);
End;
//---------------------------------------------------------
//Сохраняет файл
procedure SaveMDL(fname:string);
Var i,Gz:integer;//sEnd:string;
Begin
 assignFile(ft,fname);             //открыть файл
 rewrite(ft);                      //сделать пустым
 //Проверка: все ли поверхности содержат вершины
 //! тут должна быть процедура выкидывания пустых пов.
 Gz:=0;
 for i:=0 to CountOfGeosets-1 do if Geosets[i].CountOfVertices=0 then inc(Gz);
 //Запись иерархий (если есть)
 //(вынесено в запись спец. информации)
// if IsWoW then SaveHierarchy(fname) else DeleteHierarchy(fname);
 //Запись заголовка
 SaveHeader(Gz);
 //Запись последовательностей
 SaveSequences;
 //Запись текстур
 SaveTextures;
 //Запись материалов
 SaveMaterials;
 //Запись секции текстурных анимаций
 SaveTextureAnims;

 //Расчёт нормалей для поверхностей
 for i:=1 to CountOfGeosets-1 do begin
  RecalcNormals(i);                 //пересчитать нормали
  SmoothWithNormals(i-1);           //сгладить
 end;//of for i
 ApplySmoothGroups;

 //Запись всех поверхностей
 for i:=1 to CountOfGeosets do begin
  if Geosets[i-1].CountOfVertices=0 then continue;
  writeln(ft,'Geoset {');           //писать заголовок
  SaveVertices(i);                  //создать секцию вершин
  SaveNormals(i);                   //создать секцию нормалей
  SaveTVertices(i);                 //секция текстурных к-т
  SaveVertexGroup(i);               //создать секцию групп
  SaveFaces(i);                     //записать развороты
  SaveGroups(i);                    //записать группировку по костям
  RecalcBounds(i);                  //пересчитать границы
  SaveBounds(i);                    //записать границы
  SaveTail(i);                      //записать остаток
 end;//of for
 SaveGeosetAnims;
 SaveBones;
 SaveLights;
 SaveHelpers;
 SaveAttachments;
 SavePivots;
 SaveParticleEmitters1;
 SaveParticleEmitters2;
 SaveRibbonEmitters;              //источники следа
 SaveCameras;
 SaveEvents;
 SaveCollisionObjects;
 MDLSaveMdlVisInformation;        //запись информации MdlVis (спец. секция)
 closeFile(ft);
End;
//===============Набор процедур сохранения MDX=============
//Вспомогательная: записать целое число
procedure SaveLong(l:integer);
Begin
 BlockWrite(fm,l,4);              //запись
End;
procedure SaveFloat(f:single);
Begin
 BlockWrite(fm,f,4);
End;
procedure SaveShort(s:integer);
Var s2:word;
Begin
 s2:=LoWord(s);
 BlockWrite(fm,s2,2);
End;
procedure SaveByte(b:integer);
Var b2:byte;
Begin
 b2:=LoByte(LoWord(b));
 BlockWrite(fm,b2,1);
End;
//запись строки указанного размера
procedure SaveASCII(s:string;sz:integer);
var c:array[0..$200] of char;
Begin
 FillChar(c[0],$200,0);           //заполнение нулями
 Move(s[1],c[0],length(s));       //копирование
 BlockWrite(fm,c[0],sz);          //запись
End;
//Запомнить позицию байта размера
procedure MemorizeSizePos(IsI:boolean);
Begin
 fSizes[fsCurNum].fPos:=FilePos(fm);
 fSizes[fsCurNum].IsI:=IsI;
 inc(fsCurNum);
End;
//Записать байт размера
procedure SaveSize;
Var ps,sz:integer;
Begin
 ps:=FilePos(fm);
 sz:=ps-fSizes[fsCurNum-1].fPos;
 if not fSizes[fsCurNum-1].IsI then sz:=sz-4;
 Seek(fm,fSizes[fsCurNum-1].fPos);
 SaveLong(sz);
 Seek(fm,ps);
 dec(fsCurnum);
End;
//---------------------------------------------------------
//Вспомог.: сохранение границ
procedure MDXSaveAnimBounds(b:TAnim);
Var i:integer;
Begin
 //1. Проверка
{ for i:=1 to 3 do if b.MinimumExtent[i]<0 then b.MinimumExtent[i]:=0;
 for i:=1 to 3 do if b.MaximumExtent[i]<0 then b.MaximumExtent[i]:=0;}
 if b.BoundsRadius<0 then b.BoundsRadius:=0;
 //2. Запись
 SaveFloat(b.BoundsRadius);
 for i:=1 to 3 do SaveFloat(b.MinimumExtent[i]);
 for i:=1 to 3 do SaveFloat(b.MaximumExtent[i]);
End;
//---------------------------------------------------------
//Запись анимационных последовательностей
procedure MDXSaveSequences;
Const sqSize=$50+13*4;
Var i:integer;
Begin
 if CountOfSequences=0 then exit; //нет последовательностей
 SaveLong(TagSEQS);               //запись тега
 SaveLong(CountOfSequences*sqSize);//размер секции
 for i:=0 to CountOfSequences-1 do with Sequences[i] do begin
  SaveASCII(Name,$50);
  SaveLong(IntervalStart);
  SaveLong(IntervalEnd);
  if MoveSpeed<=0 then SaveFloat(0)
                  else SaveFloat(MoveSpeed);
  if IsNonLooping then SaveLong(1)
                  else SaveLong(0);
  if Rarity<=0 then SaveFloat(0)
               else SaveFloat(Rarity);
  SaveLong(0);                    //???
  MDXSaveAnimBounds(Bounds);
 end;//of for i
End;
//---------------------------------------------------------
//Запись глобальных последоватльеностей
procedure MDXSaveGlobalSequences;
Var i:integer;
Begin
 if CountOfGlobalSequences=0 then exit;
 SaveLong(TagGLBS);
 SaveLong(CountOfGlobalSequences*4);//запись размера секции
 for i:=0 to CountOfGlobalSequences-1 do SaveLong(GlobalSequences[i]);
End;
//---------------------------------------------------------
//Запись контроллера
procedure MDXSaveController(tag,ContNum:integer;IsColor,IsStateLong:boolean);
Var i,ii:integer;
Begin
 if ContNum<0 then exit;          //запись не нужна
 SaveLong(tag);                   //запись тега
 with Controllers[ContNum] do begin
  SaveLong(length(items));        //кол-во элементов
  SaveLong(ContType-1);           //тип контроллера
  SaveLong(GlobalSeqID);
  //Теперь - покадровая запись
  for i:=0 to Length(items)-1 do begin
   SaveLong(Items[i].Frame);      //запись номера кадра
   if IsColor then begin          //запись в стиле цвета
    for ii:=SizeOfElement downto 1 do SaveFloat(items[i].Data[ii]);
    if (ContType=Bezier) or (ContType=Hermite) then begin
     for ii:=SizeOfElement downto 1 do SaveFloat(items[i].InTan[ii]);
     for ii:=SizeOfElement downto 1 do SaveFloat(items[i].OutTan[ii]);
    end;//of if
   end else begin                 //обычная запись
    if IsStateLong then SaveLong(round(items[i].Data[1])) else begin
     for ii:=1 to SizeOfElement do SaveFloat(items[i].Data[ii]);
     if (ContType=Bezier) or (ContType=Hermite) then begin
      for ii:=1 to SizeOfElement do SaveFloat(items[i].InTan[ii]);
      for ii:=1 to SizeOfElement do SaveFloat(items[i].OutTan[ii]);
     end;//of if(ContType)
    end;//of if(IsStateLong)
   end;//of if (IsColor)
  end;//of for i
 end;//of with
End;
//---------------------------------------------------------
//Запись слоя
procedure MDXSaveLayer(l:TLayer);
Var tmp:integer;
Begin
 MemorizeSizePos(true);           //запись позиции
 SaveLong(0);                     //резерв места
 case l.FilterMode of             //анализ фильтра смешения
  Opaque:tmp:=0;
  ColorAlpha:tmp:=1;
  FullAlpha:tmp:=2;
  Additive:tmp:=3;
  AddAlpha:tmp:=4;
  Modulate:l.FilterMode:=5;
  else tmp:=Modulate2X;
 end;//of case
 SaveLong(tmp);                   //его запись

// SaveLong(l.FilterMode-1);        //запись режима смешения
 //Формируем флаги
 tmp:=0;
 if l.IsUnshaded then tmp:=tmp or 1;
 if l.IsSphereEnvMap then tmp:=tmp or 2;
 if l.IsTwoSided then tmp:=tmp or 16;
 if l.IsUnfogged then tmp:=tmp or 32;
 if l.IsNoDepthTest then tmp:=tmp or 64;
 if l.IsNoDepthSet then tmp:=tmp or 128;
 SaveLong(tmp);
 if l.IsTextureStatic then SaveLong(l.TextureID)
                    else SaveLong(0);
 SaveLong(l.TVertexAnimID);
 if l.CoordID<=0 then SaveLong(0)
                 else SaveLong(l.CoordID);
 if l.IsAlphaStatic then begin
  if l.Alpha<=0 then SaveFloat(1) else SaveFloat(l.Alpha);
 end else SaveFloat(1);
 //Запись контроллеров
 if not l.IsAlphaStatic then
        MDXSaveController(tagKMTA,l.NumOfGraph,false,false);
 if not l.IsTextureStatic then
        MDXSaveController(tagKMTF,l.NumOfTexGraph,false,true);
 //Записать размер
 SaveSize;
End;
//---------------------------------------------------------
//Сохранение материалов
procedure MDXSaveMaterials;
Var i,ii,tmp:integer;
Const mtSize=3*4;
Begin
 if CountOfMaterials=0 then exit;
 SaveLong(TagMTLS);               //запись тега
 //Резервируем место под раздел секции
 MemorizeSizePos(false);          //сохранить позицию
 SaveLong(0);                     //резерв места
 for i:=0 to CountOfMaterials-1 do with Materials[i] do begin
  MemorizeSizePos(true);          //позиция размера
  SaveLong(0);
  if PriorityPlane<=0 then SaveLong(0)
                      else SaveLong(PriorityPlane);
  //Формируем флаги
  tmp:=0;
  if IsConstantColor then tmp:=tmp or 1;
  if IsSortPrimsFarZ then tmp:=tmp or 16;
  if IsFullResolution then tmp:=tmp or 32;
  SaveLong(tmp);                  //запись флагов

  //Теперь пишем слои
  SaveLong(TagLAYS);              //запись тега
  SaveLong(CountOfLayers);        //запись кол-ва слоев
  for ii:=0 to CountOfLayers-1 do MDXSaveLayer(Layers[ii]);

  SaveSize;                       //размер записи материала
 end;//of for i
 SaveSize;                        //пишем размер секции
End;
//---------------------------------------------------------
//Сохраняет текстуры
procedure MDXSaveTextures;
Var i,tmp:integer;
Const txSize=$100+3*4;
Begin
 if CountOfTextures=0 then exit;
 SaveLong(TagTEXS);               //тег секции
 SaveLong(txSize*CountOfTextures);//размер секции
 for i:=0 to CountOfTextures-1 do with Textures[i] do begin
  if ReplaceableID<=0 then SaveLong(0)
                      else SaveLong(ReplaceableID);
  SaveASCII(FileName,$100);
  SaveLong(0);                    //???
  //Формируем флаги
  tmp:=0;
  if IsWrapWidth then tmp:=tmp or 1;
  if IsWrapHeight then tmp:=tmp or 2;
  SaveLong(tmp);
 end;//of for i
End;
//---------------------------------------------------------
//Запись секции текстурных анимций
procedure MDXSaveTextureAnims;
Var i:integer;
Begin
 if CountOfTextureAnims=0 then exit;
 SaveLong(TagTXAN);               //запись тега
 MemorizeSizePos(false);          //запомнить позицию
 SaveLong(0);                     //резерв места
 for i:=0 to CountOfTextureAnims-1 do with TextureAnims[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  //Запись контроллеров
  MDXSaveController(tagKTAT,TranslationGraphNum,false,false);
  MDXSaveController(tagKTAR,RotationGraphNum,false,false);
  MDXSaveController(tagKTAS,ScalingGraphNum,false,false);
  SaveSize;
 end;//of for i
 SaveSize;
End;
//---------------------------------------------------------
//Сохранение всех поверхностей
procedure MDXSaveGeosets;
Var i,ii,j,tmp:integer;
const a:array[1..20] of byte=(
      $50, $54, $59, $50, $01, $00, $00, $00,
      $04, $00, $00, $00, $50, $43, $4E, $54,
      $01, $00, $00, $00);
Begin
 if CountOfGeosets=0 then begin
  MessageBox(0,'В модели отсутствуют поверхности','ВНИМАНИЕ!',mb_iconstop);
  exit;
 end;//of if
 //Начинаем запись
 SaveLong(TagGEOS);               //запись тега
 MemorizeSizePos(false);
 SaveLong(0);                     //место под размер

 for i:=0 to CountOfGeosets-1 do begin
  RecalcNormals(i+1);             //расчет нормалей
  SmoothWithNormals(i);
 end;//of for i
 ApplySmoothGroups;

 //Запись каждой поверхности
 for i:=0 to CountOfGeosets-1 do with Geosets[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);                    //место под размер поверхности
  //1. Запись секции вершин
  SaveLong(tagVRTX);
  SaveLong(CountOfVertices);      //запись кол-ва вершин
  for ii:=0 to CountOfVertices-1 do for j:=1 to 3 do SaveFloat(Vertices[ii,j]);
  //2. Расчет и запись нормалей
  SaveLong(TagNRMS);              //запись тега
  SaveLong(CountOfNormals);       //кол-во нормалей
  for ii:=0 to CountOfNormals-1 do for j:=1 to 3 do SaveFloat(Normals[ii,j]);
  //3. Запись секций, связанных с треугольниками
  BlockWrite(fm,a[1],20);         //запись секций примитивов
  SaveLong(length(Faces[0]));     //запись кол-ва треуг.
  SaveLong(TagPVTX);              //тег секции
  SaveLong(length(Faces[0]));     //запись размеров
  for ii:=0 to length(Faces[0])-1 do SaveShort(Faces[0,ii]);
  //4. Запись номеров групп вершин
  SaveLong(TagGNDX);              //тег
  SaveLong(CountOfVertices);      //! надо бы кол-во групп
  for ii:=0 to CountOfVertices-1 do SaveByte(VertexGroup[ii]);
  //5. Массив длин матриц
  SaveLong(TagMTGC);
  SaveLong(CountOfMatrices);
  for ii:=0 to CountOfMatrices-1 do SaveLong(length(Groups[ii]));
  //6. Собственно список матриц
  SaveLong(TagMATS);
  tmp:=0;                         //вычислим кол-во чисел
  for ii:=0 to CountOfMatrices-1 do tmp:=tmp+length(Groups[ii]);
  SaveLong(tmp);                  //запись кол-ва
  for ii:=0 to CountOfMatrices-1 do
        for j:=0 to length(Groups[ii])-1 do SaveLong(Groups[ii,j]);

  //7. Ряд дополнительных полей
  SaveLong(MaterialID);           //материал
  if SelectionGroup<=0 then SaveLong(0)
                       else SaveLong(SelectionGroup);
  if Unselectable then SaveLong(4)
                  else SaveLong(0);
  //8. Границы поверхности
  RecalcBounds(i+1);              //пересчитать их
  if BoundsRadius<0 then SaveFloat(0)
                    else SaveFloat(BoundsRadius);
  for ii:=1 to 3 do SaveFloat(MinimumExtent[ii]);
  for ii:=1 to 3 do SaveFloat(MaximumExtent[ii]);
  //9. Набор анимационных границ
  SaveLong(CountOfAnims);
  for ii:=0 to CountOfAnims-1 do MDXSaveAnimBounds(anims[ii]);

  //10. Секция текстур
  SaveLong(TagUVAS);SaveLong(CountOfCoords);
  for j:=0 to CountOfCoords-1 do begin
   SaveLong(TagUVBS);
   SaveLong(Crds[j].CountOfTVertices);
   for ii:=0 to Crds[j].CountOfTVertices-1 do begin
    SaveFloat(Crds[j].TVertices[ii,1]);
    SaveFloat(Crds[j].TVertices[ii,2]);
   end;//of for ii
  end;//of for j

  SaveSize;                       //запись размера поверхности
 end;//of for i
 SaveSize;                        //размер секции поверхностей
End;
//---------------------------------------------------------
//Сохранение анимации видимости поверхности
procedure MDXSaveGeosetAnims;
Var i,tmp:integer;
Begin
 if CountOfGeosetAnims=0 then exit;
 SaveLong(TagGEOA);               //записать тег
 MemorizeSizePos(false);
 SaveLong(0);                     //место под размер
 for i:=0 to CountOfGeosetAnims-1 do with GeosetAnims[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);                    //место размера секции
  if IsAlphaStatic then SaveFloat(Alpha)
                   else SaveFloat(1);
  //Формируем флаги
  tmp:=0;
  if IsDropShadow then tmp:=tmp or 1;
  if (not IsColorStatic) or (Color[1]>=0) then tmp:=tmp or 2;
  SaveLong(tmp);
  if IsColorStatic and (Color[1]>=0) then begin
   SaveFloat(Color[3]);
   SaveFloat(Color[2]);
   SaveFloat(Color[1]);
  end else begin
   SaveFloat(1);
   SaveFloat(1);
   SaveFloat(1);
  end;//of if

  SaveLong(GeosetID);
  //Запись контроллеров анимации
  if not IsAlphaStatic then MDXSaveController(tagKGAO,AlphaGraphNum,false,false);
  if not IsColorStatic then MDXSaveController(tagKGAC,ColorGraphNum,false,false);
  SaveSize;                       //запись размера
 end;//of for i
 SaveSize;                        //записать размер секции
End;
//---------------------------------------------------------
//Вспомогательная: сохраняет структуру OBJ
{procedure MDXSaveOBJ(name:string;ObjectID,Parent,objType:integer;
                  IsDITranslation,IsDIRotation,IsDIScaling,
                  IsBillboarded,IsBillboardedLockX,IsBillboardedLockY,
                  IsBillboardedLockZ,IsCameraAnchored:boolean;
                  r,t,s,v:integer);}
procedure MDXSaveOBJ(b:TBone;objType:integer);
Var tmp:integer;
Begin with b do begin
 MemorizeSizePos(true);
 SaveLong(0);                     //резерв места под размер
 SaveASCII(Name,$50);             //имя объекта
 SaveLong(ObjectID);
 SaveLong(Parent);
 //Формируем флаги
 tmp:=objType;
 if IsDITranslation then tmp:=tmp or 1;
 if IsDIScaling then tmp:=tmp or 2;
 if IsDIRotation then tmp:=tmp or 4;
 if IsBillboarded then tmp:=tmp or 8;
 if IsBillboardedLockX then tmp:=tmp or 16;
 if IsBillboardedLockY then tmp:=tmp or 32;
 if IsBillboardedLockZ then tmp:=tmp or 64;
 if IsCameraAnchored then tmp:=tmp or 128;
 SaveLong(tmp);                   //запись флагов
 MDXSaveController(tagKGTR,Translation,false,false);
 MDXSaveController(tagKGRT,Rotation,false,false);
 MDXSaveController(tagKGSC,Scaling,false,false);
 if (objType=typHELP) and (objType=typBONE) and
    (objType=typLITE) and (objType=typEVTS) and
    (objType=typATCH) then
  MDXSaveController(tagKATV,Visibility,false,false);

 SaveSize;                        //запись размера
end;End;
//---------------------------------------------------------
//Сохраняет список костей
procedure MDXSaveBones;
Var i:integer;
Begin
 if CountOfBones=0 then exit;
 SaveLong(TagBONE);               //запись тега
 MemorizeSizePos(false);
 SaveLong(0);                     //резерв места под размер
 for i:=0 to CountOfBones-1 do with Bones[i] do begin
  //Сохраняем объект
  MDXSaveOBJ(Bones[i],typBONE);
  //Сохранение GeosetID
  if GeosetID=Multiple then SaveLong(-1)
                       else begin
   if GeosetID>=0 then SaveLong(GeosetID) else SaveLong(0);
  end;//of if
  //Сохранение GeosetAnimID:
  if GeosetAnimID=None then SaveLong(-1)
                       else begin
   if GeosetAnimID>=0 then SaveLong(GeosetAnimID) else SaveLong(-1);
  end;//of if

 end;//of for i
 SaveSize;                        //сохранить размер секции
End;
//---------------------------------------------------------
//Сохранение источников света
procedure MDXSaveLights;
Var i:integer;
Begin
 if CountOfLights=0 then exit;
 SaveLong(tagLITE);
 MemorizeSizePos(false);
 SaveLong(0);                     //место под размер
 for i:=0 to CountOfLights-1 do with Lights[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  MDXSaveOBJ(Skel,typLITE);
  SaveLong(LightType-1);          //тип источника

  //Запись статикодинамических полей
  if IsASStatic and (AttenuationStart>=0) then SaveFloat(AttenuationStart)
                                          else SaveFloat(0);
  if IsAEStatic and (AttenuationEnd>=0) then SaveFloat(AttenuationEnd)
                                        else SaveFloat(0);
  if IsCStatic and (Color[1]>=0) then begin
   SaveFloat(Color[3]);
   SaveFloat(Color[2]);
   SaveFloat(Color[1]);
  end else begin
   SaveFloat(1);SaveFloat(1);SaveFloat(1);
  end;//of if(IsCStatic)
  if IsIStatic and (Intensity>=0) then SaveFloat(Intensity)
                                  else SaveFloat(0);
  if IsACStatic and (AmbColor[1]>=0) then begin
   SaveFloat(AmbColor[3]);
   SaveFloat(AmbColor[2]);
   SaveFloat(AmbColor[1]);
  end else begin
   SaveFloat(1);SaveFloat(1);SaveFloat(1);
  end;//of if(IsACStatic)
  if IsAIStatic and (AmbIntensity>=0) then SaveFloat(AmbIntensity)
                                      else SaveFloat(0);

  //Запись контроллеров
  if not IsASStatic then
         MDXSaveController(tagKLAS,round(AttenuationStart),false,false);
  if not IsAEStatic then
         MDXSaveController(tagKLAE,round(AttenuationEnd),false,false);
  if not IsIStatic then
         MDXSaveController(tagKLAI,round(Intensity),false,false);
  MDXSaveController(tagKLAV,Skel.Visibility,false,false);
  if not IsCStatic then
         MDXSaveController(tagKLAC,round(Color[1]),true,false);
  if not IsACStatic then
         MDXSaveController(tagKLBC,round(AmbColor[1]),true,false);
  if not IsAIStatic then
         MDXSaveController(tagKLBI,round(AmbIntensity),false,false);

  SaveSize;                       //сохранить размер подсекции
 end;//of for i
 SaveSize;                        //сохранить размер секции
End;
//---------------------------------------------------------
procedure MDXSaveHelpers;
Var i:integer;
Begin
 if CountOfHelpers=0 then exit;
 SaveLong(tagHELP);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfHelpers-1 do with Helpers[i] do begin
  //Сохраняем объект
  MDXSaveOBJ(Helpers[i],typBONE);
 end;//of for i
 SaveSize;                        //сохранить размер секции
End;
//---------------------------------------------------------
//Сохранение точек прикрепления
procedure MDXSaveAttachments;
Var i,AttID:integer;
Begin
 if CountOfAttachments=0 then exit;
 AttID:=0;
 SaveLong(TagATCH);               //тег секции
 MemorizeSizePos(false);
 SaveLong(0);                     //место под размер
 for i:=0 to CountOfAttachments-1 do with Attachments[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);                     //место под размер
  MDXSaveOBJ(Skel,typATCH);
  SaveASCII(Path,$100);
  SaveLong(0);                     //???
//  if AttachmentID<=0 then begin
   SaveLong(AttID);inc(AttID);
//  end else SaveLong(AttachmentID);

  SaveSize;                        //размер записи
 end;//of for i
 SaveSize;                        //сохранить размер секции
End;
//---------------------------------------------------------
//сохранение геометрических центров
procedure MDXSavePivotPoints;
Var i,ii:integer;
Const pvtSize=3*4;
Begin
 if CountOfPivotPoints=0 then exit;
 SaveLong(TagPIVT);
 SaveLong(CountOfPivotPoints*pvtSize);//размер секции
 for i:=0 to CountOfPivotPoints-1 do
     for ii:=1 to 3 do SaveFloat(PivotPoints[i,ii]);
End;
//---------------------------------------------------------
//Сохранение источников частиц старой версии
procedure MDXSaveParticleEmitters;
Var i,tmp:integer;
Begin
 if CountOfParticleEmitters1=0 then exit;
 SaveLong(TagPREM);               //тег секции
 MemorizeSizePos(false);
 SaveLong(0);                     //место под размер
 for i:=0 to CountOfParticleEmitters1-1 do with ParticleEmitters1[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);                     //место под размер
  //формируем флаги
  tmp:=$1000;
  if UsesType=EmitterUsesMDL then tmp:=tmp or $8000
                             else tmp:=tmp or $10000;
  MDXSaveOBJ(Skel,tmp);

  //Сохранение статикодинамических полей
  if IsERStatic and (EmissionRate>=0) then SaveFloat(EmissionRate)
                                      else SaveFloat(0);
  if IsGStatic and (Gravity<>cNone) then SaveFloat(Gravity)
                                    else SaveFloat(0);
  if IsLongStatic and (Longitude>=0) then SaveFloat(Longitude)
                                     else SaveFloat(0);
  if IsLatStatic and (Latitude>=0) then SaveFloat(Latitude)
                                   else SaveFloat(0);
  SaveASCII(Path,$100);
  SaveLong(0);                    //???
  if IsLSStatic and (LifeSpan>=0) then SaveFloat(LifeSpan)
                                  else SaveFloat(0);
  if IsIVStatic and (InitVelocity<>cNone) then SaveFloat(InitVelocity)
                                          else SaveFloat(0);
  //Запись контроллеров
  if not IsERStatic then
         MDXSaveController(TagKPEE,round(EmissionRate),false,false);
  if not IsGStatic then
         MDXSaveController(TagKPEG,round(Gravity),false,false);
  if not IsLongStatic then
         MDXSaveController(TagKPLN,round(Longitude),false,false);
  if not IsLatStatic then
         MDXSaveController(TagKPLT,round(Latitude),false,false);
  if not IsLSStatic then
         MDXSaveController(TagKPEL,round(LifeSpan),false,false);
  if not IsIVStatic then
         MDXSaveController(TagKPES,round(InitVelocity),false,false);
  MDXSaveController(TagKPEV,Skel.Visibility,false,false);

  SaveSize;                       //размер записи
 end;//of for i
 SaveSize;                        //сохранить размер всей секции
End;
//---------------------------------------------------------
//Сохранение источников частиц второй версии
procedure MDXSaveParticleEmitters2;
Var i,ii,j,tmp:integer;
Begin
 if CountOfParticleEmitters=0 then exit;
 SaveLong(TagPRE2);
 MemorizeSizePos(false);
 SaveLong(0);                     //место под размер
 for i:=0 to CountOfParticleEmitters-1 do with pre2[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  //Формируем флаги
  tmp:=$1000;
  if IsUnshaded then tmp:=tmp or $8000;
  if IsXYQuad then tmp:=tmp or $100000;
  if IsModelSpace then tmp:=tmp or $80000;
  if IsUnfogged then tmp:=tmp or $40000;
  if IsLineEmitter then tmp:=tmp or $20000;
  if IsSortPrimsFarZ then tmp:=tmp or $10000;
  MDXSaveOBJ(Skel,tmp);
  //Запись статикодинамических полей
  if IsSStatic and (Speed<>cNone) then SaveFloat(Speed)
                                  else SaveFloat(0);
  if IsVStatic and (Variation>=0) then SaveFloat(Variation)
                                  else SaveFloat(0);
  if IsLStatic and (Latitude<>cNone) then SaveFloat(Latitude)
                                     else SaveFloat(0);
  if IsGStatic and (Gravity<>cNone) then SaveFloat(Gravity)
                                    else SaveFloat(0);
  if LifeSpan<>cNone then SaveFloat(LifeSpan)
                     else SaveFloat(0);
  if IsEStatic and (EmissionRate<>cNone) then SaveFloat(EmissionRate)
                                        else SaveFloat(0);
  if IsHStatic then SaveFloat(Length)
               else SaveFloat(0);
  if IsWStatic then SaveFloat(Width)
               else SaveFloat(0);
  //Запись режима смешения
  if BlendMode=FullAlpha then tmp:=0;
  if BlendMode=Additive then tmp:=1;
  if BlendMode=Modulate then tmp:=2;
  if BlendMode=AlphaKey then tmp:=4;
  SaveLong(tmp);

  //Запись полей
  SaveLong(Rows);
  SaveLong(Columns);
  SaveLong(ParticleType);
  if TailLength<>cNone then SaveFloat(TailLength)
                       else SaveFloat(0);
  if Time<>cNone then SaveFloat(Time)
                 else SaveFloat(0);
  //Запись цветового сегмента
  for ii:=1 to 3 do for j:=3 downto 1 do SaveFloat(SegmentColor[ii,j]);

  //Запись троек полей
  for ii:=1 to 3 do SaveByte(Alpha[ii]);
  for ii:=1 to 3 do SaveFloat(ParticleScaling[ii]);
  for ii:=1 to 3 do SaveLong(LifeSpanUVAnim[ii]);
  for ii:=1 to 3 do SaveLong(DecayUVAnim[ii]);
  for ii:=1 to 3 do SaveLong(TailUVAnim[ii]);
  for ii:=1 to 3 do SaveLong(TailDecayUVAnim[ii]);
  //еще поля
  SaveLong(TextureID);
  if IsSquirt then SaveLong(1)
              else SaveLong(0);
  if PriorityPlane>=0 then SaveLong(PriorityPlane)
                      else SaveLong(0);
  if ReplaceableID>=0 then SaveLong(ReplaceableID)
                      else SaveLong(0);

  //Запись контроллеров
  if not IsSStatic then
         MDXSaveController(tagKP2S,round(Speed),false,false);
  if not IsVStatic then
         MDXSaveController(tagKP2R,round(Variation),false,false);
  if not IsLStatic then
         MDXSaveController(tagKP2L,round(Latitude),false,false);
  if not IsGStatic then
         MDXSaveController(tagKP2G,round(Gravity),false,false);
  if not IsEStatic then
         MDXSaveController(tagKP2E,round(EmissionRate),false,false);
  MDXSaveController(tagKP2V,Skel.Visibility,false,false);
  if not IsHStatic then
         MDXSaveController(tagKP2N,round(Length),false,false);
  if not IsWStatic then
         MDXSaveController(tagKP2W,round(Width),false,false);

  SaveSize;                       //размер записи
 end;
 SaveSize;                        //размер секции
End;
//---------------------------------------------------------
//Запись источников ствета
procedure MDXSaveRibbonEmitters;
Var i:integer;
Begin
 if CountOfRibbonEmitters=0 then exit;
 SaveLong(TagRIBB);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfRibbonEmitters-1 do with Ribs[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  MDXSaveOBJ(Skel,$4000);
  //Запись статикодинамических полей
  if IsHAStatic and (HeightAbove<>cNone) then SaveFloat(HeightAbove)
                                         else SaveFloat(0);
  if IsHBStatic and (HeightBelow<>cNone) then SaveFloat(HeightBelow)
                                         else SaveFloat(0);
  if IsAlphaStatic and (Alpha>=0) then SaveFloat(Alpha)
                                  else SaveFloat(1);
  if IsColorStatic and (Color[1]>=0) then begin
   SaveFloat(Color[3]);
   SaveFloat(Color[2]);
   SaveFloat(Color[1]);
  end else begin
   SaveFloat(1);SaveFloat(1);SaveFloat(1);
  end;//of if(IsColorStatic)

  //Еще поля
  if LifeSpan>=0 then SaveFloat(LifeSpan)
                 else SaveFloat(0);
  if IsTSStatic and (TextureSlot>=0) then SaveLong(TextureSlot)
                                     else SaveLong(0);
  if EmissionRate>=0 then SaveLong(EmissionRate)
                    else SaveLong(0);
  SaveLong(Rows);
  SaveLong(Columns);
  if MaterialID>=0 then SaveLong(MaterialID)
                   else SaveLong(0);
  if Gravity<>cNone then SaveFloat(Gravity)
                    else SaveFloat(0);

  //записать контроллеры
  if not IsHAStatic then
         MDXSaveController(TagKRHA,round(HeightAbove),false,false);
  if not IsHBStatic then
         MDXSaveController(TagKRHB,round(HeightBelow),false,false);
  if not IsAlphaStatic then
         MDXSaveController(TagKRAL,round(Alpha),false,false);
  if not IsColorStatic then
         MDXSaveController(TagKRCO,round(Color[1]),true,false);
  MDXSaveController(TagKRVS,Skel.Visibility,false,false);

  SaveSize;                       //размер записи
 end;//of for i
 SaveSize;                        //запись размера секции
End;
//---------------------------------------------------------
//Сохранить камеры
procedure MDXSaveCameras;
Var i,ii:integer;
Begin
 if CountOfCameras=0 then exit;
 SaveLong(TagCAMS);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfCameras-1 do with Cameras[i] do begin
  MemorizeSizePos(true);
  SaveLong(0);
  SaveASCII(Name,$50);
  for ii:=1 to 3 do SaveFloat(Position[ii]);
  SaveFloat(FieldOfView);
  SaveFloat(FarClip);
  SaveFloat(NearClip);
  //Точка цели:
  for ii:=1 to 3 do SaveFloat(TargetPosition[ii]);
  MDXSaveController(tagKCTR,TargetTGNum,false,false);

  //Запись контроллеров
  MDXSaveController(tagKCRL,RotationGraphNum,false,false);
  MDXSaveController(tagKTTR,TranslationGraphNum,false,false);

  SaveSize;                       //размер записи
 end;//of for i
 SaveSize;                        //размер секции
End;
//---------------------------------------------------------
//Сохраняет список событий (спецэффектов)
procedure MDXSaveEvents;
Var i,ii:integer;
const tgKEVT=$5456454B;
Begin
 if CountOfEvents=0 then exit;
 SaveLong(TagEVTS);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfEvents-1 do with Events[i] do begin
  MDXSaveOBJ(Skel,typEVTS);
  SaveLong(tgKEVT);               //мини-тег
  SaveLong(CountOfTracks);
  SaveLong(-1);                   //???
  for ii:=0 to CountOfTracks-1 do SaveLong(Tracks[ii]);
 end;//of for i
 SaveSize;
End;
//---------------------------------------------------------
procedure MDXSaveCollisionShapes;
Var i,ii:integer;
Begin
 if CountOfCollisionShapes=0 then exit;
 SaveLong(tagCLID);
 MemorizeSizePos(false);
 SaveLong(0);
 for i:=0 to CountOfCollisionShapes-1 do with Collisions[i] do begin
  MDXSaveOBJ(Skel,typCLID);
  if objType=cSphere then SaveLong(2)
                     else SaveLong(0);
  //Сохранить первую вершину
  for ii:=1 to 3 do SaveFloat(Vertices[0,ii]);
  if objType=cSphere then SaveFloat(BoundsRadius)
                     else begin
   for ii:=1 to 3 do SaveFloat(Vertices[1,ii]);
  end;//of if
 end;//of for i
 SaveSize;
End;
//---------------------------------------------------------
procedure MDXSaveMdlVisInformation; //пока на стадии отладки
Var i,ii,len:integer;
Begin
 if not IsCanSaveMDVI then exit;  //запрещена запись спец. инфы
 if (COMidNormals=0) and (COConstNormals=0) and (not IsWoW) then exit;
 SaveLong(tagMDVI);               //тег секции
 MemorizeSizePos(false);
 SaveLong(0);                     //запись места под размер

 //1. Запись иерархий WoW
 if IsWoW then begin
  SaveLong(tagiWoW);               //тег секции WoW-иерархии
  for i:=0 to CountOfGeosets-1 do SaveLong(Geosets[i].HierID);
 end;//of if 

 //2. Запись информации о группах сглаживания
 if (COMidNormals>0) or (COConstNormals>0) then begin
  SaveLong(tagiSmooth);            //тег секции сглаживания
  SaveLong(COMidNormals);          //кол-во усреднённых нормалей
  for i:=0 to COMidNormals-1 do begin
   len:=length(MidNormals[i]);
   SaveLong(len);
   for ii:=0 to len-1 do begin
    SaveLong(MidNormals[i,ii].GeoID);
    SaveLong(MidNormals[i,ii].VertID);
   end;//of for ii
  end;//of for i

  //теперь - информация об изменённых нормалях
  SaveLong(COConstNormals);
  for i:=0 to COConstNormals-1 do begin
   SaveLong(ConstNormals[i].GeoId);
   SaveLong(ConstNormals[i].VertId);
   SaveFloat(ConstNormals[i].n[1]);
   SaveFloat(ConstNormals[i].n[2]);
   SaveFloat(ConstNormals[i].n[3]);
  end;//of for i
 end;//of if

 SaveSize;
End;
//---------------------------------------------------------
//Сохраняет модель в формате MDX
procedure SaveMDX(fname:string);
//Версия MDX:
Const vrs:array[0..15] of byte=(
      $4D, $44, $4C, $58, $56, $45, $52, $53,
      $04, $00, $00, $00, $20, $03, $00, $00);
      hdrSize=$150+9*4;           //размер заголовка
//Var i:integer;
Begin
 assignFile(fm,fname);            //открыть файл
 rewrite(fm,1);                   //сделать пустым
 fsCurNum:=0;                     //нет записей о размере
 //0. Запишем версию формата
 BlockWrite(fm,vrs,16);           //запись
 //1. Запись секции MODL
 SaveLong(TagMODL);               //запись тега
 SaveLong(hdrSize);               //запись размера
 SaveASCII(ModelName,$150);       //имя модели
 SaveLong(0);                     //???
 MDXSaveAnimBounds(AnimBounds);   //границы
 SaveLong(BlendTime);             //время смешения
 //Запись иерархий (если есть)
 //(перенесено в запись информации MdlVis)
// if IsWoW then SaveHierarchy(fname) else DeleteHierarchy(fname);
 //2. Запись всего остального
 MDXSaveSequences;                //запись анимаций
 MDXSaveGlobalSequences;          //запись глобальных последовательностей
 MDXSaveMaterials;                //запись материалов
 MDXSaveTextures;                 //запись текстур
 MDXSaveTextureAnims;             //запись текстурных анимаций
 MDXSaveGeosets;                  //запись поверхностей
 MDXSaveGeosetAnims;              //запись анимаций видимости
 MDXSaveBones;                    //запись костей
 MDXSaveLights;                   //запись источников света
 MDXSaveHelpers;                  //Сохранение помощников
 MDXSaveAttachments;              //сохранение точек прикрепления
 MDXSavePivotPoints;              //сохранение геометрических центров
 MDXSaveParticleEmitters;         //сохранение источников частиц (v.1)
 MDXSaveParticleEmitters2;        //сохранение источников частиц (v.2)
 MDXSaveRibbonEmitters;           //запись источников следа
 MDXSaveCameras;                  //запись камер
 MDXSaveEvents;                   //сохранение событий
 MDXSaveCollisionShapes;          //запись объектов границ
 MDXSaveMdlVisInformation;        //запись дополнительной информации MdlVis
 closeFile(fm);                   //закрыть файл
End;
//---------------------------------------------------------
//вспомогательная: загружает неупакованный blp,
//выделив предварительно память под буфер.
procedure LoadUnpackingBLP(p:pointer;var pRet:pointer;var Width,Height:integer);
Var i{,ii}:integer;
    ps,psImg,psPal,psAlpha,psDest,dta,r,g,b,tmp:cardinal;
    IsAlphaPresent:boolean;
Begin
 //1. Получаем указатели на пиксели, палитру и альфа-слой
 //а также Width и Height изображения
 ps:=integer(p);                  //позиция blp в памяти
 Move(pointer(ps+$1C)^,psImg,4);  //позиция пикселей blp
 psPal:=psImg-$400;               //позиция данных палитры
 Move(pointer(ps+08)^,tmp,4);     //присутствие альфа
 IsAlphaPresent:=tmp<>0;
 Move(pointer(ps+$0C)^,Width,4);  //ширина образа текстуры
 Move(pointer(ps+$10)^,Height,4); //высота образа текстуры
 psAlpha:=psImg+Width*Height;     //позиция альфа-канала
 //получение абсолютных позиций
 psImg:=psImg+ps;
 psPal:=psPal+ps;
 psAlpha:=psAlpha+ps;

 //2. Выделяем память (буфер декодирования)
 GetMem(pRet,Width*Height*4);
 psDest:=integer(pRet);           //позиция в буфере
 //3. Конвертируем в 32-битный формат
 for i:=1 to Width*Height-1 do begin
  dta:=0;tmp:=0;
  Move(pointer(psImg)^,dta,1);    //читаем код цвета
  Move(pointer(psPal+dta*4)^,dta,4);//читаем BGR0-код из палитры
  r:=GetRValue(dta);
  g:=GetGValue(dta);
  b:=GetBValue(dta);
  dta:=b+(g shl 8)+(r shl 16);
  if IsAlphaPresent then Move(pointer(psAlpha)^,tmp,1)
                    else tmp:=255;  
  dta:=dta+(tmp shl 24);          //получаем RGBA-код
  Move(dta,pointer(psDest)^,4);   //пишем его в буфер
  //сдвигаем указатели
  psImg:=psImg+1;
  psDest:=psDest+4;
  psAlpha:=psAlpha+1;
 end;//of for i
End;

//Вспомогательная: грузит файл из MPQ, если это возможно
function LoadFileFromMPQs(fname:PChar;var hFile:integer):boolean;
Begin
 Result:=false;
 if not IsLoadMPQ then exit;      //MPQ не загружены
 Result:=true;
 if SFileOpenFileEx(hWar3patch,fname,0,hFile) then exit;
 if SFileOpenFileEx(hWar3x,fname,0,hFile) then exit;
 if SFileOpenFileEx(hWar3,fname,0,hFile) then exit;
 Result:=false;
End;

//Вспомогательная: загружает текстуру в буфер P
//(предварительно выделив память).
//При ошибке возвращает false.
function LoadTexInBuf(dirName,fname:string;var p:pointer;CInt:integer;
                      var len:integer):boolean;
Var ps,hFile,tmp:integer;f:file;oldname:string;
Begin
 Result:=false;
 oldname:=fname;
 //1. Пытаемся загрузить из файла
  assignFile(f,dirName+'\'+fname);
  {$I-}
  reset(f,1);                     //попытка открытия файла
  if IOResult<>0 then begin       //если файл не найден
   ps:=length(fname);
   while (fname[ps]<>'\') and (ps>0) do dec(ps);
   delete(fname,1,ps);
   assignFile(f,dirName+'\'+fname);
   reset(f,1);                    //попробуем по-другому...
   if IOResult<>0 then begin      //если все-таки не вышло
    //Что ж, пробуем подгрузить из MPQ...
    if not LoadFileFromMPQs(PChar(oldname),hFile) then begin
     TexErr:=TexErr+fname+#13#10;  //добавить к списку ошибок
     //Тем не менее, буфер заполним...
     GetMem(p,8*8*4);
     FillChar(p^,8*8*4,CInt); //заполнить буфер
     exit;
    end;//of if

    len:=SFileGetFileSize(hFile,tmp);
    if len<=0 then begin
     TexErr:=TexErr+fname+#13#10;  //добавить к списку ошибок
     //Тем не менее, буфер заполним...
     GetMem(p,8*8*4);
     FillChar(p^,8*8*4,CInt); //заполнить буфер
     exit;
    end;//of if (len equ Err)
    
    GetMem(p,len);
    if not SFileReadFile(hFile,p,len,0,nil) then begin
     TexErr:=TexErr+fname+#13#10;  //добавить к списку ошибок
     //Буфер уже выделен, только заполняем
     FillChar(p^,8*8*4,CInt); //заполнить буфер
     exit;
    end;//of if(ErrRead)
    SFileCloseFile(hFile);        //закрыть файл
    Result:=true;                 //считывание успешно
    exit;                         //выйти
   end;//of if
  end;//of if
  {$I+}
  //2. Файл должен быть уже открыт
  len:=fileSize(f);
  GetMem(p,len);          //выделить память
  BlockRead(f,p^,len);    //прочитать файл
  //Закроем файл
  closeFile(f);
  Result:=true;
End;

//Загружает текстуру, возвращает буфер изображения
//а в width,height - размеры образа текстуры
procedure LoadTexture(dirName,fname:string;
                      var Width,Height:integer;var pReturn:pointer);
Var f:file;ps,texWidth,texHeight,len,{ListNum,}i,ii,
    lOfs,lZero,spos,dpos,tmp,r,g,b,a:integer;
    wWidth,wHeight:word;
    p,ppos,pposs,pImg:pointer;
    pWrk1,pWrk2:PByte;
    bTmp:byte;
    BLP_INFO:array[0..6000] of integer;
Const CIntensity=200;//интенсивность цвета при ошибках текстуры
Begin
 pReturn:=nil;                    //пока ничего не загружено
 Width:=8;
 Height:=8;
 if length(fname)<3 then begin
//  MessageBox(0,'Неверное имя текстуры.','Ошибка',mb_iconstop or mb_applmodal);
  TexErr:='Модель повреждена'#13#10;
  GetMem(pReturn,8*8*4);
  FillChar(pReturn^,8*8*4,CIntensity); //заполнить буфер
  exit;
 end;//of if
 //Определим тип файла текстуры
 if LowerCase(copy(fname,length(fname)-3,4))='.blp' then begin //это - BLP
  if (@ijlInit=nil) or (@ijlRead=nil) or (@ijlFree=nil) then begin
   MessageBox(0,'Библиотека ijl15.dll не найдена,'#13#10+
                'загрузка blp-текстур невозможна.',
                'ВНИМАНИЕ:',mb_iconstop or mb_applmodal);
   exit;                           //продолжать нет смысла
  end;//of if
(*  //1. Ищем сам файл на диске
  assignFile(f,dirName+'\'+fname);
  {$I-}
  reset(f,1);                     //попытка открытия файла
  if IOResult<>0 then begin       //если файл не найден
   ps:=length(fname);
   while (fname[ps]<>'\') and (ps>0) do dec(ps);
   delete(fname,1,ps);
   assignFile(f,dirName+'\'+fname);
   reset(f,1);                    //попробуем по-другому...
   if IOResult<>0 then begin      //если все-таки не вышло
    TexErr:=TexErr+fname+#13#10;  //добавить к списку ошибок
{    MessageBox(0,PChar('Файл '+fname+' не найден.'),
               'Ошибка:',mb_iconexclamation or mb_applmodal);}
    //Тем не менее, буфер заполним...
    GetMem(pReturn,8*8*4);
    FillChar(pReturn^,8*8*4,CIntensity); //заполнить буфер
    exit;
   end;//of if
  end;//of if
  {$I+}
  //2. Файл должен быть уже открыт
  len:=fileSize(f);
  GetMem(p,len);          //выделить память
  BlockRead(f,p^,len);    //прочитать файл
  //Закроем файл
  closeFile(f);  *)
  if not LoadTexInBuf(dirName,fname,p,CIntensity,len) then begin
   pReturn:=p;
   exit;
  end;//of if
  //2.4 Смотрим, не WoW ли это blp
  ppos:=pointer(integer(p));
  Move(ppos^,lZero,4);
  if lZero<>$31504C42 then begin
    TexErr:=TexErr+fname+' [не WC3-формат]'#13#10;  //добавить к списку ошибок
    GetMem(pReturn,8*8*4);
    FillChar(pReturn^,8*8*4,CIntensity); //заполнить буфер
    exit;
  end;//of if
  //2.5 Смотрим, что это за тип текстуры (разрядность blp)
  ppos:=pointer(integer(p)+4);
  Move(ppos^,lZero,4);            //читаем поле типа
  if lZero=1 then begin           //неупакованный blp
   LoadUnpackingBLP(p,pReturn,width,height);//грузим его
   FreeMem(p);
   exit;                          //готово
  end;//of if (неупакованный blp)
  //3. Инициализируем IJL
  if ijlInit(@BLP_INFO)<>0 then begin
   MessageBox(0,'Не удается инициализировать IJL.',
                scError,mb_iconstop or mb_applmodal);
   FreeMem(p);                     //освободить память
   exit;
  end;//of if
  //Сдвинем фрагменты IJPEG вплотную
  ppos:=pointer(integer(p)+$1C);
  move(ppos^,lofs,4);
  ppos:=pointer(integer(p)+$310); //проверка на 0
  move(ppos^,lZero,4);
  if (lOfs>$310) and (lZero=0) then begin
   ppos:=pointer(integer(p)+$49C);
   pposs:=pointer(integer(p)+$310);
   move(ppos^,pposs^,len-$49C);        //смещение
  end;//of if
  //4. Заполним структуру BLP_INFO
  ppos:=pointer(integer(p)+12);move(ppos^,texWidth,4);//считываем размеры
  ppos:=pointer(integer(p)+16);move(ppos^,texHeight,4);
  GetMem(pImg,texWidth*texHeight*8);//память для распаковки
  BLP_INFO[0]:=0;                 //!
  BLP_INFO[1]:=integer(pImg);     //указатель на память для распаковки
  BLP_INFO[2]:=texWidth;
  BLP_INFO[3]:=texHeight;
  BLP_INFO[4]:=0;                 //!
  BLP_INFO[5]:=4;
  BLP_INFO[6]:=$0FF;
  BLP_INFO[7]:=0;
  BLP_INFO[8]:=0;                 //!
  BLP_INFO[9]:=integer(p)+$0A0;   //позиция JFIF
  BLP_INFO[10]:=len-$0A0;         //?
  BLP_INFO[11]:=texWidth;
  BLP_INFO[12]:=texHeight;
  BLP_INFO[13]:=4;
  BLP_INFO[14]:=$0FF;
  BLP_INFO[15]:=0;
  BLP_INFO[18]:=1;
  BLP_INFO[19]:=1;
  BLP_INFO[20]:=$64;
  //5. Попытаемся провести распаковку
  if ijlRead(@BLP_INFO,3)<>0 then begin
   MessageBox(0,'Не удалось распаковать BLP.',
                scError,mb_iconstop or mb_applmodal);
   FreeMem(p);                     //освободить память
   FreeMem(pImg);
   GetMem(pReturn,8*8*4);         //вернуть белый буфер
   FillChar(pReturn^,8*8*4,CIntensity);  //заполнить буфер
   exit;
  end;//of if
  //6. Ура!!! Файл распакован. Теперь приведем цветовую гамму в норму
  pWrk1:=PByte(pImg);
  pWrk2:=PByte(integer(pImg)+2);
  for i:=0 to texWidth*texHeight do begin
   bTmp:=pWrk1^;
   pWrk1^:=pWrk2^;
   pWrk2^:=bTmp;
   pWrk1:=PByte(integer(pWrk1)+4);
   pWrk2:=PByte(integer(pWrk2)+4);
  end;//of for
  //7. Вернем нужные значения
  pReturn:=pImg;                  //вернуть
  width:=texWidth;height:=texHeight;//вернуть размеры
  //Освободить память
  FreeMem(p);                     //освободить память
//  FreeMem(pImg);
 end else begin                   //это TGA-файл
  //1. Ищем сам файл на диске
  assignFile(f,dirName+'\'+fname);
  {$I-}
  reset(f,1);                     //попытка открытия файла
  if IOResult<>0 then begin       //если файл не найден
   ps:=length(fname);
   while (fname[ps]<>'\') and (ps>0) do dec(ps);
   delete(fname,1,ps);
   assignFile(f,dirName+'\'+fname);
   reset(f,1);                    //попробуем по-другому...
   if IOResult<>0 then begin      //если все-таки не вышло
    TexErr:=TexErr+fname+#13#10;
{    MessageBox(0,PChar('Файл '+fname+' не найден.'),
               'Ошибка:',mb_iconexclamation or mb_applmodal);}
    GetMem(pReturn,8*8*4);        //вернуть белый буфер
    FillChar(pReturn^,8*8*4,CIntensity); //заполнить буфер
    exit;
   end;//of if
  end;//of if
  {$I+}
  //2. Файл должен быть уже открыт
  len:=fileSize(f);
  GetMem(p,len);          //выделить память
  BlockRead(f,p^,len);    //прочитать файл
  ppos:=pointer(integer(p)+$0C); //считать параметры
  move(ppos^,wWidth,2);
  ppos:=pointer(integer(p)+$0E);
  move(ppos^,wHeight,2);
  width:=wWidth;height:=wHeight;
  wWidth:=0;
  ppos:=pointer(integer(p)+$10);
  move(ppos^,wWidth,1);           //копируем разрядность TGA
  ppos:=pointer(integer(p)+$11);
  tmp:=0;
  move(ppos^,tmp,1);              //читаем флаги TGA
  ppos:=pointer(integer(p)+$12);  //получаем указатель на данные
  //Закроем файл
  closeFile(f);
  //6. Теперь приведем цветовую гамму в норму
  if (tmp and 32)<>0 then begin   //обычный порядок строк
   if wWidth=32 then begin
    GetMem(pReturn,width*height*4);
    spos:=integer(ppos);
    dpos:=integer(pReturn);
    for i:=0 to Width*Height do begin
     move(pointer(spos)^,lOfs,4); //читать RGBA
     r:=GetRValue(lOfs);
     g:=GetGValue(lOfs);
     b:=GetBValue(lOfs);
     a:=(lOfs and $FF000000);
     lOfs:=(b+(g shl 8)+(r shl 16)) or a;
     move(lOfs,pointer(dpos)^,4);
     dpos:=dpos+4;
     spos:=spos+4;
    end;//of for i
   end else begin
    GetMem(pReturn,width*height*4);
    spos:=integer(ppos);
    dpos:=integer(pReturn);
    for i:=0 to width*height do begin
     lOfs:=0;
     move(pointer(spos)^,lOfs,3); //читать RGB
     r:=GetRValue(lOfs);
     g:=GetGValue(lOfs);
     b:=GetBValue(lOfs);
     lOfs:=(b+(g shl 8)+(r shl 16)) or $FF000000;
     move(lOfs,pointer(dpos)^,4); //записать RGBA
     spos:=spos+3;
     dpos:=dpos+4;
    end;//of for i
   end;//of if
  end else begin                  //обратный порядок строк
   if wWidth=32 then begin
    GetMem(pReturn,width*height*4);
    //копируем строки в обратном порядке
    spos:=integer(ppos)+width*height*4-width*4;//источник
    dpos:=integer(pReturn);        //приемник
    for ii:=height-1 downto 0 do begin
     for i:=0 to width-1 do begin
      tmp:=0;
      Move(pointer(spos)^,tmp,4);
      r:=GetRValue(tmp);
      g:=GetGValue(tmp);
      b:=GetBValue(tmp);
      a:=(tmp and $FF000000);
      tmp:=(b+(g shl 8)+(r shl 16)) or a;
      Move(tmp,pointer(dpos)^,4);   //записать
      spos:=spos+4;                 //сдвиг счетчиков
      dpos:=dpos+4;
     end;//of for i
     spos:=spos-width*8;
    end; //of for ii
   end else begin
    GetMem(pReturn,width*height*4);
    spos:=integer(ppos)+width*height*3-width*3;//источник
    dpos:=integer(pReturn);        //приемник
    for ii:=height-1 downto 0 do begin
     for i:=0 to width-1 do begin
      tmp:=0;
      Move(pointer(spos)^,tmp,3);
      r:=GetRValue(tmp);
      g:=GetGValue(tmp);
      b:=GetBValue(tmp);
      tmp:=(b+(g shl 8)+(r shl 16)) or $FF000000;
      Move(tmp,pointer(dpos)^,4);   //записать
      spos:=spos+3;                 //сдвиг счетчиков
      dpos:=dpos+4;
     end;//of for i
     spos:=spos-width*6;
    end; //of for ii
   end; //of if(Depth)
  end;//of if(порядок строк)
   FreeMem(p);
 end;//of if
End;
//---------------------------------------------------------
//Набор вспомогательных процедур для текстурного смешения
//простое заполнение непрозрачным
procedure AddOpaque(pBuf,pTex:pointer;xt,yt,xb,yb,iAlpha:integer);
Var i,ii,j,jj,cntx,cnty,dta,psBuf,psTex:integer;
Begin
 cntx:=xb div xt;
 cnty:=yb div yt;
 psBuf:=integer(pBuf);
 psTex:=integer(pTex);
 for jj:=1 to yt do begin            //построчный вывод
  for j:=1 to cnty do begin          //повторение строк
   for ii:=1 to xt do begin          //запись строки
    Move(pointer(psTex)^,dta,4);     //читать пиксел
    dta:=dta and $00FFFFFF;
    dta:=dta or (iAlpha shl 24);     //установить прозрачность слоя
    for i:=1 to cntx do begin        //запись пиксела
     Move(dta,pointer(psBuf)^,4);    //пишем
     psBuf:=psBuf+4;                 //идем далее
    end;//of for i
    psTex:=psTex+4;                  //следующий пиксель
   end;//of for ii
   psTex:=psTex-xt*4;                //вернемся к началу
  end;//of for j
  psTex:=psTex+xt*4;
 end;//of jj
end;

//Прозрачность 75% (Transparent)
procedure Add2Alpha(pBuf,pTex:pointer;xt,yt,xb,yb,iAlpha:integer);
Var i,ii,j,jj,cntx,cnty,psBuf,psTex:integer;
    dta:cardinal;//alpha:GLFloat;
Begin
 cntx:=xb div xt;
 cnty:=yb div yt;
 psBuf:=integer(pBuf);
 psTex:=integer(pTex);
 for jj:=1 to yt do begin            //построчный вывод
  for j:=1 to cnty do begin          //повторение строк
   for ii:=1 to xt do begin          //запись строки
    Move(pointer(psTex)^,dta,4);     //читать пиксел
    if (dta and $FF000000)<$C0000000 then begin
     psTex:=psTex+4;                 //пропуск пикселя
     psBuf:=psBuf+4*cntx;
     continue;                       //продолжить (нет вывода)
    end;//of if
//    alpha:=(dta shr 8*3)*iAlpha*0.00392;
    dta:=dta and $00FFFFFF;
    if iAlpha>191 then iAlpha:=255
    else iAlpha:=0;
    dta:=dta or (iAlpha shl 24);     //установить прозрачность слоя
    for i:=1 to cntx do begin        //запись пиксела
     Move(dta,pointer(psBuf)^,4);    //пишем
     psBuf:=psBuf+4;                 //идем далее
    end;//of for i
    psTex:=psTex+4;                  //следующий пиксель
   end;//of for ii
   psTex:=psTex-xt*4;                //вернемся к началу
  end;//of for j
  psTex:=psTex+xt*4;
 end;//of jj
end;

//Полное смешение
procedure BlendTex(pBuf,pTex:pointer;xt,yt,xb,yb:integer;fAlpha:GLFloat);
Var i,ii,j,jj,cntx,cnty,dta,dta2,psBuf,psTex:integer;
    r1,r2,g1,g2,b1,b2,a1,a2,dl:GLfloat;
Const dv=1/255;
Begin
 cntx:=xb div xt;
 cnty:=yb div yt;
 psBuf:=integer(pBuf);
 psTex:=integer(pTex);
 for jj:=1 to yt do begin            //построчный вывод
  for j:=1 to cnty do begin          //повторение строк
   for ii:=1 to xt do begin          //запись строки
    Move(pointer(psTex)^,dta,4);     //читать пиксел
    Move(pointer(psBuf)^,dta2,4);    //читать пиксел из буфера
    r1:=(dta and $FF);
    g1:=(dta and $FF00) shr 8;
    b1:=(dta and $FF0000) shr 16;
    a1:=((dta and $FF000000) shr 24)*dv*fAlpha;
    r2:=(dta2 and $FF);
    g2:=(dta2 and $FF00) shr 8;
    b2:=(dta2 and $FF0000) shr 16;
    a2:=((dta2 and $FF000000) shr 24)*dv;
    dl:=1-a1;
    r2:=r1*a1+r2*dl;
    g2:=g1*a1+g2*dl;
    b2:=b1*a1+b2*dl;
    a2:=a1+a2;if a2>1 then a2:=1;
    dta2:=round(a2*255) shl 8;
    dta2:=(dta2+round(b2)) shl 8;
    dta2:=(dta2+round(g2)) shl 8;
    dta2:=dta2+round(r2);
    dta:=dta2;
    for i:=1 to cntx do begin        //запись пиксела
     Move(dta,pointer(psBuf)^,4);    //пишем
     psBuf:=psBuf+4;                 //идем далее
    end;//of for i
    psTex:=psTex+4;                  //следующий пиксель
   end;//of for ii
   psTex:=psTex-xt*4;                //вернемся к началу
  end;//of for j
  psTex:=psTex+xt*4;
 end;//of jj
end;

//Добавка (Additive)
procedure AddAdd(pBuf,pTex:pointer;xt,yt,xb,yb,iAlpha:integer);
Var i,ii,j,jj,cntx,cnty,dta,psBuf,psTex:integer;
    r1,g1,b1,r2,g2,b2,a2:integer;
Begin
 cntx:=xb div xt;
 cnty:=yb div yt;
 psBuf:=integer(pBuf);
 psTex:=integer(pTex);
 for jj:=1 to yt do begin            //построчный вывод
  for j:=1 to cnty do begin          //повторение строк
   for ii:=1 to xt do begin          //запись строки
    r1:=0;r2:=0;g1:=0;g2:=0;
    b1:=0;b2:=0;{a1:=0;}a2:=0;
    Move(pointer(psTex)^,r1,1);inc(psTex);
    Move(pointer(psTex)^,g1,1);inc(psTex);
    Move(pointer(psTex)^,b1,1);inc(psTex);inc(psTex);
    psTex:=psTex-4;
    Move(pointer(psBuf)^,r2,1);inc(psBuf);
    Move(pointer(psBuf)^,g2,1);inc(psBuf);
    Move(pointer(psBuf)^,b2,1);inc(psBuf);
    Move(pointer(psBuf)^,a2,1);inc(psBuf);
    psBuf:=psBuf-4;
    r2:=r2+r1;g2:=g2+g1;b2:=b2+b1;a2:=a2+iAlpha;
    if r2>255 then r2:=255;
    if g2>255 then g2:=255;
    if b2>255 then b2:=255;
    if a2>255 then a2:=255;
    dta:=a2 shl 8;
    dta:=(dta+b2) shl 8;
    dta:=(dta+g2) shl 8;
    dta:=dta+r2;
    for i:=1 to cntx do begin        //запись пиксела
     Move(dta,pointer(psBuf)^,4);    //пишем
     psBuf:=psBuf+4;                 //идем далее
    end;//of for i
    psTex:=psTex+4;                  //следующий пиксель
   end;//of for ii
   psTex:=psTex-xt*4;                //вернемся к началу
  end;//of for j
  psTex:=psTex+xt*4;
 end;//of jj
end;

//Создает список GL для заданного материала
//MatID - ID материала, rgb - значение цвета команды.
//Все текстуры должны быть предварительно созданы
//(с учетом цвета команды!)
//Контекст должен быть установлен!
function MakeMaterialList(MatID:integer):boolean;
Var i,x,y,TexID{,ipos}:integer;
    pBuf{,ppos}:pointer;
Begin with Materials[MatID] do begin
 MakeMaterialList:=true;
// glDeleteLists(ListNum,1);
 if ListNum>0 then glDeleteTextures(1,@ListNum);
 //1. Выясняем размер блока "суммарной" текстуры
 x:=0;y:=0;
 for i:=0 to CountOfLayers-1 do if Layers[i].IsTextureStatic then begin
  TexID:=Layers[i].TextureID;
  if Textures[TexID].ImgWidth>x then x:=Textures[TexID].ImgWidth;
  if Textures[TexID].ImgHeight>y then y:=Textures[TexID].ImgHeight;
 end else begin                   //для динамической текстуры
  //!dbg: пока не будем мучаться с интерполяцией
  TexID:=round(Controllers[Layers[i].NumOfTexGraph].Items[0].Data[1]);
  if Textures[TexID].ImgWidth>x then x:=Textures[TexID].ImgWidth;
  if Textures[TexID].ImgHeight>y then y:=Textures[TexID].ImgHeight;
 end;//of if/for

 Excentry:=x/y;
 //2. Создаем подходящий буфер
 GetMem(pBuf,x*y*4);              //буфер RGBA
 FillChar(pBuf^,x*y*4,0);         //забить нулями

 //3. Послойное формирование материала
 //(пока что цвет и прозрачность не анимируются,
 //а часть фильтров игнорируется).
 TypeOfDraw:=Additive;
 for i:=0 to CountOfLayers-1 do begin
  if Layers[i].IsTextureStatic then TexID:=Layers[i].TextureID
     else TexID:=round(Controllers[Layers[i].NumOfTexGraph].Items[0].Data[1]);
  //Проверим: созданы ли текстуры   
  if Textures[TexID].pImg=nil then begin
   MakeMaterialList:=false;
   exit;
  end;//of if
  case Layers[i].FilterMode of
   Opaque:begin
    AddOpaque(pBuf,Textures[TexID].pImg,Textures[TexID].ImgWidth,
              Textures[TexID].ImgHeight,x,y,255);
    TypeOfDraw:=Opaque;
   end;//of Opaque
   ColorAlpha:begin
    Add2Alpha(pBuf,Textures[TexID].pImg,Textures[TexID].ImgWidth,
              Textures[TexID].ImgHeight,x,y,255);
    if TypeOfDraw<>Opaque then TypeOfDraw:=ColorAlpha;
   end;//of 2 Color Alpha
   FullAlpha,5,6,8:begin
    BlendTex(pBuf,Textures[TexID].pImg,Textures[TexID].ImgWidth,
             Textures[TexID].ImgHeight,x,y,1.0);
    //TypeOfDraw:=FullAlpha;
    if TypeOfDraw<>Opaque then TypeOfDraw:=FullAlpha;
   end;//of FullAlpha
   Additive,AddAlpha:begin
    AddAdd(pBuf,Textures[TexID].pImg,Textures[TexID].ImgWidth,
             Textures[TexID].ImgHeight,x,y,255);
   end;//of Additive
  end;//of for case
 end;//of for i

 //Смесь готова. Теперь создаем список:
 glGenTextures(1,@ListNum);       //номер текстурного списка
// ListNum:=glGenLists(1);
// glNewList(ListNum,GL_COMPILE);  //создаем список текстуры
 glBindTexture(GL_TEXTURE_2D,ListNum);//создание списка
  glTexImage2D(GL_TEXTURE_2D,0,4,x,y,0,GL_RGBA,GL_UNSIGNED_BYTE,pBuf);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
// glEndList;                      //конец списка
                 
 FreeMem(pBuf);
end;End;
//---------------------------------------------------------
//Обертка для LoadTexture: Полностью создает списки всех текстур по слоям,
//для всех материалов
//Возвращает true при успехе
function CreateAllTextures(dirName:string;r,g,b:GLfloat):boolean;
Var i,j,w,h{,d}:integer;sName:string;
    a:array[1..8*8*4] of byte;
    ag:array[1..32*32*4] of byte;
    pRet:pointer;
Begin
 CreateAllTextures:=false;        //пока текстур нет
 TexErr:='';                      //нет ошибок
 //1. Освободить память, если она уже занята:
 for i:=0 to CountOfTextures-1 do if Textures[i].pImg<>nil then begin
  FreeMem(Textures[i].pImg);
  Textures[i].pImg:=nil;
 end;//of for i
 //цикл по всем текстурам
 for i:=0 to CountOfTextures-1 do begin
  case Textures[i].ReplaceableID of
   0:begin                        //собственно текстура
    sName:=Textures[i].FileName;  //имя текстуры
    LoadTexture(dirName,sName,w,h,pRet);
    Textures[i].pImg:=pRet;
    if pRet=nil then exit;
    Textures[i].ImgWidth:=w;
    Textures[i].ImgHeight:=h;
   end;//of 0
   1:begin                        //Цвет команды
    j:=1;
    repeat
     a[j]:=round(r*255);
     a[j+1]:=round(g*255);
     a[j+2]:=round(b*255);a[j+3]:=255;
     j:=j+4;
    until j>8*8*4;
    //Копирование в буфер
    GetMem(Textures[i].pImg,8*8*4);
    Move(a,Textures[i].pImg^,8*8*4);
    Textures[i].ImgWidth:=8;
    Textures[i].ImgHeight:=8;
   end;//of 1
   2:begin                          //Сияние (аура)
    j:=1;
    repeat
     ag[j+3]:=TeamGlowAlpha[(j shr 2)+1];//интенсивность сияния
     ag[j]:=round(r*ag[j+3]);
     ag[j+1]:=round(g*ag[j+3]);
     ag[j+2]:=round(b*ag[j+3]);
     j:=j+4;
    until j>32*32*4;
    //Копирование в буфер
    GetMem(Textures[i].pImg,32*32*4);
    Move(ag,Textures[i].pImg^,32*32*4);
    Textures[i].ImgWidth:=32;
    Textures[i].ImgHeight:=32;
   end;//of TeamGlow;
  end;//of case
  if Textures[i].ReplaceableID>=3 then begin //обработка древесных текстур
   case Textures[i].ReplaceableID of
    11:sName:='ReplaceableTextures\Cliff\Cliff0.blp';
    31:sName:='ReplaceableTextures\LordaeronTree\LordaeronSummerTree.blp';
    32:sName:='ReplaceableTextures\AshenvaleTree\AshenTree.blp';
    33:sName:='ReplaceableTextures\BarrensTree\BarrensTree.blp';
    34:sName:='ReplaceableTextures\NorthrendTree\NorthTree.blp';
    35:sName:='ReplaceableTextures\Mushroom\MushroomTree.blp';
   else sName:='ReplaceableTextures\LordaeronTree\LordaeronSummerTree.blp';
   end;//of case
   LoadTexture(dirName,sName,w,h,pRet);
   Textures[i].pImg:=pRet;
   if pRet=nil then exit;
   Textures[i].ImgWidth:=w;
   Textures[i].ImgHeight:=h;
  end;//of if
 end;//of for
 //Если есть сообщения об ошибках - вывети:
 if (TexErr<>'') and IsShowTexError then begin
    MessageBox(0,
    PChar('Не найдены файлы текстур:'+#13#10+TexErr),
    scError,mb_iconexclamation);
    IsShowTexError:=false;        //больше не отображать ошибку
 end;//of if
 CreateAllTextures:=true;         //все готово
End;

//---------------------------------------------------------
//Вспомогательная: распаковать DXT1 и DXT3-упакованное
//изображение. pSrc - указатель на изображение
//w,h - его размеры (в пикселях), frmt - тип упаковки
//(0,1 - DXT1, 8 - DXT3).
//Выделяет память в pDest и распаковывает изображение
//в этот буфер.
procedure DecompressDXT(pSrc:pointer;w,h,frmt:integer;var pDest:pointer);
type TClr=record
 r,g,b:byte;
end;//of TClr
Var i,j,x,y,psSrc,psDest,dd,c0,c1:integer;
    index:byte;
    alp,a:int64;
    Color:array [0..3] of TClr;
Begin
 GetMem(pDest,w*h*4);             //выделить память
 psSrc:=integer(pSrc);
 psDest:=integer(pDest);
 //Начинаем декодирование
 y:=0;
 repeat                           //цикл по y
  x:=0;
  repeat                          //цикл по x
   //1. Читаем альфа-блок, если он есть
   if frmt=8 then begin
    Move(pointer(psSrc)^,alp,8); //чтение всего блока
    psSrc:=psSrc+8;               //двигаем указатель
   end;//of if (DXT3)
   //2. Читаем коэффициенты цвета: c0 и c1
   c0:=0;c1:=0;
   Move(pointer(psSrc)^,c0,2);psSrc:=psSrc+2;
   Move(pointer(psSrc)^,c1,2);psSrc:=psSrc+2;
   //3. Вычислим цветовой блок
   color[0].b:=((c0 shr 11) and $1f) shl 3;
   color[0].g:=((c0 shr  5) and $3f) shl 2;
   color[0].r:=(c0 and $1f) shl 3;
   color[1].b:=((c1 shr 11) and $1f) shl 3;
   color[1].g:=((c1 shr  5) and $3f) shl 2;
   color[1].r:=(c1 and $1f) shl 3;
   if c0>c1 then begin
    color[2].r:=(color[0].r * 2 + color[1].r) div 3;
    color[2].g:=(color[0].g * 2 + color[1].g) div 3;
    color[2].b:=(color[0].b * 2 + color[1].b) div 3;
    color[3].r:=(color[0].r + color[1].r * 2) div 3;
    color[3].g:=(color[0].g + color[1].g * 2) div 3;
    color[3].b:=(color[0].b + color[1].b * 2) div 3;
   end else begin
    color[2].r:=(color[0].r + color[1].r) shr 1;
    color[2].g:=(color[0].g + color[1].g) shr 1;
    color[2].b:=(color[0].b + color[1].b) shr 1;
    color[3].r:=0;
    color[3].g:=0;
    color[3].b:=0;
   end;//of if

   //Запишем прочитанное
   for j:=0 to 3 do begin
    Move(pointer(psSrc)^,index,1);inc(psSrc);
    dd:=psDest+(w*(y+j)+x)*4;
    for i:=0 to 3 do begin
     Move(Color[index and 3].r,pointer(dd)^,1);inc(dd);
     Move(Color[index and 3].g,pointer(dd)^,1);inc(dd);
     Move(Color[index and 3].b,pointer(dd)^,1);inc(dd);
     if frmt=8 then begin         //пишем альфа
      a:=(alp and $0F) shl 4;
      Move(a,pointer(dd)^,1);inc(dd);
      alp:=alp shr 4;
     end else begin
      if ((index and 3)=3) and (c0 <= c1) then a:=0
                                          else a:=255;
      Move(a,pointer(dd)^,1);inc(dd);
     end;//of if(format)
     index:=index shr 2;
    end;//of for i
   end;//of for j

   x:=x+4;                        //двигаемя далее (блок 4x4)
  until x>=w;                     //конец чтения по X
  y:=y+4;                         //двигаемся далее (блок 4x4)
 until y>=h;
End;
//---------------------------------------------------------
//Вспомогательная: записывает в указанную позицию (ips)
//упакованное изображение (ссылка на него и его параметры
//идет в dblp).
//true, если всё в порядке
function WriteMipMap(var ips:integer;hdrSize,bufSize:integer;
                     var dblp:TIJCore):boolean;
Begin
 //1. Установим параметры и упакуем изображение
 WriteMipMap:=true;
 dblp.IJBytes:=pointer(ips);
 dblp.IJSizeBytes:=bufSize;

{ dblp.ijprops[0]:=255;
 dblp.ijprops[1]:=255;
 dblp.ijprops[2]:=255;
 dblp.ijprops[3]:=255;
 dblp.ijprops[4]:=$0B;
 dblp.ijprops[5]:=0;
 dblp.ijprops[6]:=0;
 dblp.ijprops[7]:=0;}
 if ijlWrite(@dblp,13)<>0 then begin
  WriteMipMap:=false;
  exit;
 end;//of if (Err)
 
 Move(pointer(integer(dblp.IJBytes)+4)^,dblp.IJBytes^,dblp.IJSizeBytes-4);
 ips:=ips+dblp.IJSizeBytes-4;
End;
//---------------------------------------------------------
//Вспомогательная: уменьшает изображение pImg в 2 раза
//по осям x и y. Корректирует поля width/height в dblp.
//Если уменьшать уже некуда, возвращает false
function MinimizeImage(pImg:pointer;var dblp:TIJCore):boolean;
Var i,ii,psSrc,psDst:integer;
Begin
 MinimizeImage:=true;
 if (dblp.width=1) and (dblp.height=1) then begin
  MinimizeImage:=false;
  exit;
 end;//of if
 if dblp.width=1 then begin
  dblp.height:=dblp.height shr 1;
  exit;
 end;//of dblp.width
 if dblp.height=1 then begin
  dblp.width:=dblp.width shr 1;
  exit;
 end;//of dblp.height

 i:=0;psSrc:=integer(pImg);psDst:=psSrc;
 repeat                           //цикл по y
  ii:=0;
  repeat                          //цикл по x
   Move(pointer(psSrc)^,pointer(psDst)^,4);
   psSrc:=psSrc+8;                //пропуск 1 пикселя
   psDst:=psDst+4;
   ii:=ii+2;
  until ii>=dblp.width;
  i:=i+2;                         //смещение
  psSrc:=psSrc+4*dblp.width;      //пропуск 1 строки
 until i>=dblp.height;

 dblp.width:=dblp.width shr 1;
 dblp.height:=dblp.height shr 1;
 dblp.IJWidth:=dblp.width;
 dblp.IJHeight:=dblp.height;
End;
//---------------------------------------------------------
//Вспомогательная: распаковать изображение,
//основанное на палитре
procedure DecompressPAL(pDta:pointer;width,height,m2:integer;var pImg:pointer);
Var psPal,psSrc,psDest,psAlpha,i,tmp,a:integer;
Begin
 GetMem(pImg,width*height*4);     //выделить память
 psSrc:=integer(pDta);            //указатель на байты цвета
 psPal:=psSrc-256*4;              //указатель на палитру
 psDest:=integer(pImg);           //позиция в буфере
 if m2=8 then psAlpha:=psSrc+width*height; //позиция альфа-блока
 //Цикл распаковки
 for i:=1 to width*height do begin
  tmp:=0;a:=0;
  Move(pointer(psSrc)^,tmp,1);    //читать код цвета
  inc(psSrc);
  Move(pointer(psPal+tmp*4)^,tmp,4);//читать RGB цвета
  if m2=8 then Move(pointer(psAlpha)^,a,1)//читать альфа
          else a:=255;
  inc(psAlpha);
  tmp:=tmp or (a shl 24);        //получить RGBA
  Move(tmp,pointer(psDest)^,4);   //записать
  psDest:=psDest+4;
 end;//of for i
End;
//---------------------------------------------------------
//Конвертирует текстуру WoW в blp1 (WC3).
//Информация записывается в тот же файл.
//Если IsBatch=true, то не-BLP файлы пропускаются
//без выдачи сообщений об ошибкахs
//Возвращает true в случае успешной конверсии
function ConvertBLP2ToBLP(fname:string;IsBatch:boolean):boolean;
type TBlpHeader=record
 sign,tp,cd,w,h,d,one:integer;
end;//of TBlpHeader
Var i,ips,tmp,width,height,hdrSize:integer;
    p,pImg,pBuf:pointer;
    m1,m2:byte;
    blph:TBlpHeader;
    mipofs:array[0..15] of integer;//смещения mip-карт
    miplengths:array[0..15] of integer;//длины mip-карт
//    pmips:pointer;
    dblp:TIJCore;
Begin
 Result:=false;
 AssignFile(fblp,fname);
 {$I-}
 reset(fblp,1);                   //открыть файл
 if IOResult<>0 then exit;
 {$I+}
 //Теперь читаем исходный файл
 GetMem(p,FileSize(fblp)+10);
 BlockRead(fblp,p^,FileSize(fblp));
 CloseFile(fblp);                 //закрыть файл

 //Начинаем анализ файла.
 //1. Проверить, тот ли это blp.
 ips:=integer(p);
 Move(p^,tmp,4);                  //читать ID файла
 if tmp<>$32504C42 then begin     //ошибка
  if not IsBatch then MessageBox(0,'Неверный формат файла',scError,mb_iconstop);
  FreeMem(p);
  exit;
 end;//of if(err)

 //2. Определяем способ упаковки изображения.
 Move(pointer(ips+4)^,tmp,4);     //читать тип формата
 Move(pointer(ips+8)^,m1,1);      //читать подтипы
 Move(pointer(ips+9)^,m2,1);
 if (tmp<>1) or ((m1<>2) and (m1<>1)) then begin
  MessageBox(0,'IJ-текстуры не поддерживаются',scError,mb_iconstop);
  FreeMem(p);
  exit;
 end;//of if(err)

 Move(pointer(ips+$0C)^,width,4);    //x
 Move(pointer(ips+$10)^,height,4);   //y
 Move(pointer(ips+$14)^,tmp,4);      //смещение изображения

 //Анализ подформата и декодирование:
 if m1=1 then DecompressPAL(pointer(tmp+ips),width,height,m2,pImg) else
 case m2 of
  0,1,8:DecompressDXT(pointer(tmp+ips),width,height,m2,pImg);
  else begin
   MessageBox(0,'Формат сжатия не распознан',scError,mb_iconstop);
   FreeMem(p);
   exit;
  end;
 end;//of case

 //Теперь нужно вновь закодировать, только уже в WC3-blp.
 //a. Инициализируем IJL:
 if (@ijlInit=nil) or (@ijlWrite=nil) or (@ijlFree=nil) then begin
  MessageBox(0,'Библиотека ijl15.dll не найдена.'#13#10+
               'Упаковка blp-текстур невозможна.',
               scError,mb_iconstop);
  FreeMem(pImg);
  FreeMem(p);
  exit;
 end;//of if
 FillChar(dblp,SizeOf(dblp),0);
 if ijlInit(@dblp)<>0 then begin
  MessageBox(0,'Ошибка инициализации IJL.'#13#10+
               'Упаковка blp-текстур невозможна.',
               scError,mb_iconstop);
  FreeMem(pImg);
  FreeMem(p);
  exit;
 end;//of if

 //b. выделяем буфер достаточной ёмкости.
 GetMem(pBuf,4*width*height*5);   //надеюсь, хватит :)
 FillChar(pBuf^,4*width*height,0);

 dblp.UseIJPEGProperties:=0;
 dblp.DIBBytes:=pImg;
 dblp.width:=width;
 dblp.height:=height;
 dblp.DIBPadBytes:=0;
 dblp.DIBChannels:=4;
 dblp.DIBColor:=$0FF;         //?
 dblp.DIBSubsampling:=0;

 ips:=integer(pBuf)+sizeof(blph)+16*4*2+4;
 dblp.IJBytes:=pointer(ips);//смещение
 dblp.IJSizeBytes:=4*width*height*5;
 dblp.IJWidth:=width;
 dblp.IJHeight:=height;
 dblp.IJChannels:=4;
 dblp.IJColor:=$0FF;
 dblp.IJSubsampling:=0;
 dblp.IsConvRequired:=1;
 dblp.IsUnsamplingRequired:=1;
 dblp.Quality:=75;

 //Записываем в буфер заголовок IJPEG
 if ijlWrite(@dblp,11)<>0 then begin
  MessageBox(0,'Ошибка упаковки:'#13#10+
               'Упаковка blp-текстур невозможна.',
               scError,mb_iconstop);
  FreeMem(pImg);
  FreeMem(pBuf);
  FreeMem(p);
  exit;
 end;//of if
 hdrSize:=dblp.IJSizeBytes;       //узнать размер заголовка
 FillChar(pointer(integer(pBuf)+$30F)^,1,$C0);//DBG!

 //c. Цикл формирования всех mip-карт текстуры
// FillChar(integer(pBuf)^,
 ips:=integer(pBuf)+$49C;
 FillChar(mipofs,sizeof(mipofs),0);
 FillChar(miplengths,sizeof(miplengths),0);
 for i:=0 to 15 do begin
  mipofs[i]:=ips-integer(pBuf);
  if not WriteMipMap(ips,hdrSize,4*width*height*5,dblp) then begin
   MessageBox(0,'Ошибка упаковки:'#13#10+
                'Упаковка blp-текстур невозможна.',
                scError,mb_iconstop);
   FreeMem(pImg);
   FreeMem(pBuf);
   FreeMem(p);
   exit;
  end;//of if
  miplengths[i]:=dblp.IJSizeBytes-4;
  if not MinimizeImage(pImg,dblp) then break;
 end;//of for i

 //d. Добавляем к буферу всю информацию
 blph.sign:=$31504C42;            //сигнатура
 blph.tp:=0;
 blph.cd:=8;
 blph.w:=width;
 blph.h:=height;
 blph.d:=4;
 blph.one:=1;
 Move(blph,pBuf^,SizeOf(blph));   //заголовок готов!
 Move(mipofs[0],pointer(integer(pBuf)+SizeOf(blph))^,16*4);
 Move(miplengths[0],pointer(integer(pBuf)+SizeOf(blph)+16*4)^,16*4);
 Move(hdrSize,pointer(integer(pBuf)+SizeOf(blph)+16*4*2)^,4);

 AssignFile(fblp,fname);
 Rewrite(fblp,1);
 BlockWrite(fblp,pBuf^,ips-integer(pBuf));
 CloseFile(fblp);

 ijlFree(@dblp);                  //освободить библиотеку
 FreeMem(pImg);
 FreeMem(pBuf);
 FreeMem(p);
 Result:=true;
End;
//----------------------------------------------------------
//Определяет границы указанной поверхности
procedure CalcBounds(geoID:integer;var anim:TAnim);
Var minx,maxx,miny,maxy,minz,maxz:GLFloat;
    ii:integer;
Begin with Geosets[geoID],anim do begin
  if geoID>length(Geosets)-1 then MessageBox(0,'asf','asdf',0); 
  minx:=Vertices[0,1];miny:=Vertices[0,2];minz:=Vertices[0,3];
  maxx:=Vertices[0,1];maxy:=Vertices[0,2];maxz:=Vertices[0,3];
  //Поиск границ:
  for ii:=0 to CountOfVertices-1 do begin
   if Vertices[ii,1]<minx then minx:=Vertices[ii,1];
   if Vertices[ii,1]>maxx then maxx:=Vertices[ii,1];
   if Vertices[ii,2]<miny then miny:=Vertices[ii,2];
   if Vertices[ii,2]>maxy then maxy:=Vertices[ii,2];
   if Vertices[ii,3]<minz then minz:=Vertices[ii,3];
   if Vertices[ii,3]>maxz then maxz:=Vertices[ii,3];
  end;//of for ii
  if MinimumExtent[1]<0 then MinimumExtent[1]:=minx*2;
  if MinimumExtent[2]<0 then MinimumExtent[2]:=miny*2;
  if MinimumExtent[3]<0 then MinimumExtent[3]:=minz*2;
  MaximumExtent[1]:=maxx*2;
  MaximumExtent[2]:=maxy*2;
  MaximumExtent[3]:=maxz*2;
  //Граничный радиус
  BoundsRadius:=sqrt(sqr(MaximumExtent[1]-MinimumExtent[1])+
                sqr(MaximumExtent[2]-MinimumExtent[2])+
                sqr(MaximumExtent[3]-MinimumExtent[3]))*0.5;
end;End;

//----------------------------------------------------
//Создаёт пустую GeosetAnim (т.е. со статичными,
//равными 1 Alpha и Color) для заданного GeosetID.
//В случае необходимости, GeosetAnimID сдвигаются
//Возвращает ID созданной анимации видимости
//или же (-1), если таковая уже существует
function CreateGeosetAnim(GeosetID:integer):integer;
Var {ID,}i:integer;
Begin
 //1. Проверим, существует ли уже такая GeosetAnim.
 //Заодно определим место GeosetAnim в списке
 Result:=-1;
 for i:=0 to CountOfGeosetAnims-1 do with GeosetAnims[i] do begin
//  if
 end;//of for i
End;
//----------------------------------------------------
//Профилировочная: считать RDTSC
function GetTSC:cardinal;
Var tsc:cardinal;
Begin
 asm
  db 0Fh,31h
  mov tsc,eax
 end;
 GetTSC:=tsc;
End;

//Вспомогательная: возвращает путь к папке War'а
function GetWarPath:string;
Var hndKey:HKEY;tmp,num:integer;
    a:array[1..1000] of Char;
    pc:PChar;
Begin
 pc:=@a;
 num:=1000;
 FillChar(a[1],1000,0);
 RegOpenKeyEx(HKEY_CURRENT_USER,'Software\Blizzard Entertainment\Warcraft III',
              0,KEY_READ,hndKey);
 RegQueryValueEx(hndKey,'InstallPath',nil,@tmp,@a[1],@num);
 RegCloseKey(hndKey);
 GetWarPath:=string(pc)+'\';  //вернуть строку
End;

//Загрузка storm.dll и MPQ-архивов
procedure InitMPQs;
Var hStorm:integer;stui:TStartupInfo;pi:_Process_Information;
Begin
 IsLoadMPQ:=false;                //пока MPQ не загружены

// CreateProcess('readmpq.mvp',nil,nil,nil,false,0,nil,nil,stui,pi);
 hStorm:=LoadLibrary('storm.dll');
 if hStorm=0 then hStorm:=LoadLibrary(PChar(WarPath+'storm.dll'));
 if hStorm=0 then exit;           //ошибка загрузки

 //Storm загружена. Получаем адреса функций
 @SFileOpenArchive:=GetProcAddress(hStorm,pointer(266));
 @SFileOpenFileEx:=GetProcAddress(hStorm,pointer(268));
// @SFileOpenFileEx:=GetProcAddress(hStorm,pointer(279));
 @SFileGetFileSize:=GetProcAddress(hStorm,pointer(265));
 @SFileCloseFile:=GetProcAddress(hStorm,pointer(253));
 @SFileReadFile:=GetProcAddress(hStorm,pointer(269));
// @SFileSetLocale:=GetProcAddress(hStorm,pointer(272));
 if (@SFileOpenArchive=nil) or (@SFileOpenFileEx=nil) or
    (@SFileGetFileSize=nil) or (@SFileCloseFile=nil) or
    (@SFileReadFile=nil) or (@SFileSetLocale=nil) then exit;

 //Адреса получены. Теперь пытаемся подгрузить MPQ:
 SFileSetLocale($409);
 if not SFileOpenArchive('war3.mpq',0,0,hWar3)
 then SFileOpenArchive(PChar(WarPath+'war3.mpq'),0,0,hWar3);

 if not SFileOpenArchive('war3x.mpq',1,0,hWar3x)
 then SFileOpenArchive(PChar(WarPath+'war3x.mpq'),0,0,hWar3x);

 if not SFileOpenArchive('war3patch.mpq',8,0,hWar3patch)
 then SFileOpenArchive(PChar(WarPath+'war3patch.mpq'),0,0,hWar3patch);

 IsLoadMPQ:=true;
End;

//Вспомогательная
//Дополнение реестра набором ключей, соответствующих расширению
procedure AddExtension(StrtKey,StrtKey2:PChar;descr:string);
Var Disp,tmp:integer;
    Key,Key2,Key3,Key4:HKey;
    s:string;
    a:array[0..1024] of char;
    pc:PChar;
Begin
 //1. Считать имя раздела для MDL-файлов (или создать этот раздел)
 pc:=@a[0];
 RegCreateKeyEx(HKEY_CLASSES_ROOT,StrtKey,0,nil,0,KEY_ALL_ACCESS,nil,Key,@Disp);
 if Disp=REG_CREATED_NEW_KEY then begin //ключ не существовал
  s:=string(StrtKey2)+#0;
  RegSetValueEx(Key,nil,0,REG_SZ,@s[1],length(s));
  s:=string(StrtKey2);            //имя нового раздела
 end else begin                   //ключ есть. Читаем имя раздела
  Disp:=1024;
  if RegQueryValueEx(Key,nil,nil,@tmp,@a[0],@Disp)<>ERROR_SUCCESS then exit;
  s:=string(pc);  
 end;//of if
 RegCloseKey(Key);                //закрыть уже ненужный ключ

 //2. Разобраться с разделом mdl_auto_file
 RegCreateKeyEx(HKEY_CLASSES_ROOT,PChar(s),0,nil,0,KEY_ALL_ACCESS,
                nil,Key,@Disp);
 if Disp=REG_CREATED_NEW_KEY then begin //ключ не существовал
  //Присвоим значение
  s:=descr+#0;
  RegSetValueEx(Key,nil,0,REG_SZ,@s[1],length(s));
  //Добавим все необходимые подключи
  RegCreateKeyEx(Key,'shell',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key2,@Disp);
  RegCreateKeyEx(Key2,'open',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key3,@Disp);
  RegCreateKeyEx(Key3,'command',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key4,@Disp);
  //И установим командную строку
  s:='"'+ParamStr(0)+'" "%1"'#0;
  RegSetValueEx(Key4,nil,0,REG_SZ,@s[1],length(s));
  //Теперь позакрываем ключи
  RegCloseKey(Key4);
  RegCloseKey(Key3);
 end else begin                   //Всё уже есть. Откроем ключ "Shell"
  RegCreateKeyEx(Key,'shell',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key2,@Disp);
 end;

 //Теперь есть 2 открытых ключа. Можно досоздавать далее.
 RegCreateKeyEx(Key2,'Open with MdlVis',0,nil,0,KEY_ALL_ACCESS,
                nil,Key3,@Disp);
 if Disp=REG_CREATED_NEW_KEY then begin  //раздел нужно создавать
  RegCreateKeyEx(Key3,'command',0,nil,0,KEY_ALL_ACCESS,
                 nil,Key4,@Disp);
  //И установим командную строку
  s:='"'+ParamStr(0)+'" "%1"'#0;
  RegSetValueEx(Key4,nil,0,REG_SZ,@s[1],length(s));
  //Теперь позакрываем ключи
  RegCloseKey(Key4);
//  RegCloseKey(Key3);
 end;//of if

 RegCloseKey(Key3);
 RegCloseKey(Key2);
 RegCloseKey(Key);
 
End;

initialization
 IsShowTexError:=true;
 IsCanSaveMDVI:=true;
 //Находим путь к папке War:
 WarPath:=GetWarPath;
 InitMPQs;                        //загрузка MPQ и Storm.dll
 AddExtension('.mdl','mdl_auto_file','Модель War');
 AddExtension('.mdx','mdx_auto_file','Модель War [Бинарный формат]'); 
 //Попытаемся загрузить все нужные библиотеки
 hIJL:=LoadLibrary('ijl15.dll');  //попытка загрузки
 if hIJL=0 then begin
  hIJL:=LoadLibrary(PChar(WarPath+'ijl15.dll'));
 end;//of if
 @ijlInit:=GetProcAddress(hIJL,'ijlInit');
 @ijlRead:=GetProcAddress(hIJL,'ijlRead');
 @ijlFree:=GetProcAddress(hIJL,'ijlFree');
 @ijlWrite:=GetProcAddress(hIJL,'ijlWrite');
end.
