#pragma description Warcraft.mdx
#pragma magic [ 4D 44 4C 58 ] @ 0x00
#pragma endian little
#pragma array_limit 99999

// https://www.hiveworkshop.com/threads/mdx-specifications.240487/

import std.io;
import std.mem;
import std.string;
import std.core;

char magick[4] @0x00; // MDLX

u32 version = 0;

struct VERS {
    u32 v;
    version = v;
};

struct Extent {
  float boundsRadius;
  float minimum[3];
  float maximum[3];
};

struct MODL {
  char name[80];
  char animationFileName[260];
  Extent extent;
  u32 blendTime;
};

struct Sequence {
  char name[80];
  u32 interval[2];
  float moveSpeed;
  u32 flags; // 0: looping
             // 1: non looping
  float rarity;
  u32 syncPoint;
  Extent extent;
};

enum FilterMode: u32 {
    none = 0,
    transparent = 1,
    blend = 2,
    additive = 3,
    addAlpha = 4,
    modulate = 5,
    modulate2x = 6,
};

bitfield ShadingFlags {
  unshaded: 1; // 0x1
  sphereEnvironmentMap: 1; // 0x2
  unknown1: 1; // 0x4
  unknown2: 1; // 0x8
  twoSided: 1; // 0x10
  unfogged: 1; // 0x20
  noDepthTest: 1; // 0x40
  noDepthSet: 1; // 0x80
  padding: 24;
};

struct Track<T> {
  s32 frame; // Probably should be uint32, but I saw a model with negative values
  T value;
};

struct TrackEx<T>: Track<T> {
    T inTan;
    T outTan;
};

enum InterpolationType: u32 {
    none = 0,
    linear = 1,
    hermite = 2,
    bezier = 3,
};

struct TrackChunk<T> {
  u32 tracksCount;
  InterpolationType interpolationType;
  u32 globalSequenceId;

  if (interpolationType <= 1) Track<T> tracks[tracksCount];
  else TrackEx<T> tracks[tracksCount];
};

struct Vec2 {float data[2] [[inline]];};
struct Vec3 {float data[3] [[inline]];};
struct Vec4 {float data[4] [[inline]];};


enum TrackTag: u32 {
    // Node
    KGTR = 0x4b475452,//KGTR: float[3] translation
    KGRT = 0x4b475254,//KGRT: float[4] rotation
    KGSC = 0x4b475343, //KGSC: float[3] scaling
    // Layer
    KMTF = 0x4b4d5446,//KMTF: uint32 textureId
    KMTA = 0x4B4D5441,//KMTA: float alpha
    KMTE = 0x4b4d5445,//KMTE: float emissiveGain
    KFC3 = 0x4b464333,//KFC3: float[3] fresnelColor
    KFCA = 0x4b464341,//KFCA: float fresnelAlpha
    KFTC = 0x4b465443,//KFTC: float fresnelTeamColor
    // Texture animation
    KTAT = 0x4b544154,//KTAT: float[3] translation
    KTAR = 0x4b544152,//KTAR: float[4] rotation
    KTAS = 0x4b544153,//KTAS: float[3] scaling
    //Geoset animation
    KGAO = 0x4b47414f,//KGAO: float alpha
    KGAC = 0x4b474143,//KGAC: float[3] color
    // Light
    KLAS = 0x4b4c4153,//KLAS: float attenuationStart
    KLAE = 0x4b4c4145,//KLAE: float attenuationStartEnd
    KLAC = 0x4b4c4143,//KLAC: float[3] color
    KLAI = 0x4b4c4149,//KLAI: float intensity
    KLBI = 0x4b4c4249,//KLBI: float ambientIntensity
    KLBC = 0x4b4c4243,//KLBC: float[3] ambientColor
    KLAV = 0x4b4c4156,//KLAV: float visibility
    // Attachment
    KATV = 0x4b415456,//KATV: float visibility
    // Particle emitter
    KPEE = 0x4b504545,//KPEE: float emissionRate
    KPEG = 0x4b504547,//KPEG: float gravity
    KPLN = 0x4b504c4e,//KPLN: float longitude
    KPLT = 0x4b504c54,//KPLT: float latitude
    KPEL = 0x4b50454c,//KPEL: float lifespan
    KPES = 0x4b504553,//KPES: float speed
    KPEV = 0x4b504556,//KPEV: float visibility
    // Particle emitter 2
    KP2E = 0x4b503245,//KP2E: float emissionRate
    KP2G = 0x4b503247,//KP2G: float gravity
    KP2L = 0x4b50324c,//KP2L: float latitude
    KP2S = 0x4b503253,//KP2S: float speed
    KP2V = 0x4b503256,//KP2V: float visibility
    KP2R = 0x4b503252,//KP2R: float variation
    KP2N = 0x4b50324e,//KP2N: float length
    KP2W = 0x4b503257,//KP2W: float width
    // Ribbon emitter
    KRVS = 0x4b525653,//KRVS: float visibility
    KRHA = 0x4b524841,//KRHA: float heightAbove
    KRHB = 0x4b524842,//KRHB: float heightBelow
    KRAL = 0x4b52414c,//KRAL: float alpha
    KRCO = 0x4b52434f,//KRCO: float[3] color
    KRTX = 0x4b525458,//KRTX: uint32 textureSlot
    // Camera
    KCTR = 0x4b435452,//KCTR: float[3] translation
    KCRL = 0x4b43524c,//KCRL: float rotation
    KTTR = 0x4b545452,//KTTR: float[3] targetTranslation
    // Corn emitter
    KPPA = 0x4b505041,//KPPA: float alpha
    KPPC = 0x4b505043,//KPPC: float[3] color
    KPPE = 0x4b505045,//KPPE: float emissionRate
    KPPL = 0x4b50504c,//KPPL: float lifespan
    KPPS = 0x4b505053,//KPPS: float speed
    KPPV = 0x4b505056,//KPPV: float visibility
};

struct TrackParent {
    be TrackTag tag;

    match(tag){
        // Node
        (TrackTag::KGTR) : TrackChunk<Vec3> translation;
        (TrackTag::KGRT) : TrackChunk<Vec4> rotation;
        (TrackTag::KGSC) : TrackChunk<Vec3> scaling;

        // Layer
        (TrackTag::KMTF) : TrackChunk<u32> textureId;
        (TrackTag::KMTA) : TrackChunk<float> alpha;
        (TrackTag::KMTE) : TrackChunk<float> emissiveGain;
        (TrackTag::KFC3) : TrackChunk<Vec3> fresnelColor;
        (TrackTag::KFCA) : TrackChunk<float> fresnelAlpha;
        (TrackTag::KFTC) : TrackChunk<float> fresnelTeamColor;

        // Texture animation
        (TrackTag::KTAT) : TrackChunk<Vec3> translation;
        (TrackTag::KTAR) : TrackChunk<Vec4> rotation;
        (TrackTag::KTAS) : TrackChunk<Vec3> scaling;

        //Geoset animation
        (TrackTag::KGAO) : TrackChunk<float> alpha;
        (TrackTag::KGAC) : TrackChunk<Vec3> color;

        // Light
        (TrackTag::KLAS) : TrackChunk<float> attenuationStart;
        (TrackTag::KLAE) : TrackChunk<float> attenuationStartEnd;
        (TrackTag::KLAC) : TrackChunk<Vec4> color;
        (TrackTag::KLAI) : TrackChunk<float> intensity;
        (TrackTag::KLBI) : TrackChunk<float> ambientIntensity;
        (TrackTag::KLBC) : TrackChunk<Vec3> ambientColor;
        (TrackTag::KLAV) : TrackChunk<float> visibility;

        // Attachment
        (TrackTag::KATV) : TrackChunk<float> visibility;

        // Particle emitter
        (TrackTag::KPEE) : TrackChunk<float> emissionRate;
        (TrackTag::KPEG) : TrackChunk<float> gravity;
        (TrackTag::KPLN) : TrackChunk<float> longitude;
        (TrackTag::KPLT) : TrackChunk<float> latitude;
        (TrackTag::KPEL) : TrackChunk<float> lifespan;
        (TrackTag::KPES) : TrackChunk<float> speed;
        (TrackTag::KPEV) : TrackChunk<float> visibility;

        // Particle emitter 2
        (TrackTag::KP2E) : TrackChunk<float> emissionRate;
        (TrackTag::KP2G) : TrackChunk<float> gravity;
        (TrackTag::KP2L) : TrackChunk<float> latitude;
        (TrackTag::KP2S) : TrackChunk<float> speed;
        (TrackTag::KP2V) : TrackChunk<float> visibility;
        (TrackTag::KP2R) : TrackChunk<float> variation;
        (TrackTag::KP2N) : TrackChunk<float> length;
        (TrackTag::KP2W) : TrackChunk<float> width;

        // Ribbon emitter
        (TrackTag::KRVS) : TrackChunk<float> visibility;
        (TrackTag::KRHA) : TrackChunk<float> heightAbove;
        (TrackTag::KRHB) : TrackChunk<float> heightBelow;
        (TrackTag::KRAL) : TrackChunk<float> alpha;
        (TrackTag::KRCO) : TrackChunk<Vec3> color;
        (TrackTag::KRTX) : TrackChunk<u32> textureSlot;

        // Camera
        (TrackTag::KCTR) : TrackChunk<Vec3> translation;
        (TrackTag::KCRL) : TrackChunk<float> rotation;
        (TrackTag::KTTR) : TrackChunk<Vec3> targetTranslation;

        // Corn emitter
        (TrackTag::KPPA) : TrackChunk<float> alpha;
        (TrackTag::KPPC) : TrackChunk<Vec3> color;
        (TrackTag::KPPE) : TrackChunk<float> emissionRate;
        (TrackTag::KPPL) : TrackChunk<float> lifespan;
        (TrackTag::KPPS) : TrackChunk<float> speed;
        (TrackTag::KPPV) : TrackChunk<float> visibility;
        (_) : {
            $ = addressof(tag);
            std::warning("Wrong track");
            break;
        }
    }
};

struct Layer {
  u32 inclusiveSize;
  FilterMode filterMode;
  ShadingFlags shadingFlags;
  u32 textureId;
  u32 textureAnimationId;
  u32 coordId;
  float alpha;

  if (version > 800) {
    float emissiveGain;
    float fresnelColor[3];
    float fresnelOpacity;
    float fresnelTeamColor;
  }

  /*
  (KMTF)
  (KMTA)
  if (version > 800) {
    (KMTE)
  }
  if (version > 900) {
    (KFC3)
    (KFCA)
    (KFTC)
  }
  */

  TrackParent track[while ($ < addressof(this) + inclusiveSize)];

  u32 cursor = addressof(this) + inclusiveSize;
  if ($ != cursor) std::warning("Layer inclusiveSize error");
  $ = cursor;
};

struct Material {
  u32 inclusiveSize;
  u32 priorityPlane;
  u32 flags;

  if (version > 800) {
    char shader[80];
  }

  char magick[4]; // "LAYS"

  u32 layersCount;
  Layer layers[layersCount];


  u32 cursor = addressof(this) + inclusiveSize;
  if ($ != cursor) {
    std::warning("Layer size error");
    $ = cursor;
  }
};

struct Texture {
  u32 replaceableId;
  char fileName[260];
  u32 flags;
};

enum GeoKey: u32 {
    VRTX = 0x56525458,
    NRMS = 0x4E524D53,
    PTYP = 0x50545950,
    PCNT = 0x50434E54,
    PVTX = 0x50565458,
    GNDX = 0x474E4458,
    MTGC = 0x4D544743,
    MATS = 0x4D415453,
    UVAS = 0x55564153,
    UVBS = 0x55564253,
};

struct GeoData<auto tagid, T> {
    be GeoKey tag;
    if (tag != tagid) std::warning("GeoData wrong tag");
    u32 count;
    T data[count] [[inline]];
};

enum FaceTypeGroup: u32 {
    points = 0,
    lines = 1,
    lineLoop =  2,
    lineStrip = 3,
    triangles = 4,
    triangleStrip = 5,
    triangleFan = 6,
    quads = 7,
    quadStrip = 8,
    polygons = 9,
};

struct TextureCoordinateSet: GeoData<GeoKey::UVBS, Vec2> {};

struct Geoset {
    u32 inclusiveSize;
    GeoData<GeoKey::VRTX, Vec3> vertex;
    GeoData<GeoKey::NRMS, Vec3> normal;
    GeoData<GeoKey::PTYP, FaceTypeGroup> faceTypeGroup;
    GeoData<GeoKey::PCNT, u32> faceGroup;
    GeoData<GeoKey::PVTX, u16> face;
    GeoData<GeoKey::GNDX, u8> vertexGroup;
    GeoData<GeoKey::MTGC, u32> matrixGroup;
    GeoData<GeoKey::MATS, u32> matrixIndex;

    u32 materialId;
    u32 selectionGroup;
    u32 selectionFlags;

    if (version > 800) {
        u32 lod;
        char lodName[80];
    }

    Extent extent;
    u32 extentsCount;
    Extent sequenceExtents[extentsCount];

    /*
    if (version > 800) {
        (Tangents)
        (Skin)
    }
    */

    GeoData<GeoKey::UVAS, TextureCoordinateSet> textureCoordinateSet;

    u32 cursor = addressof(this) + inclusiveSize;
    if ($ != cursor) {
        std::warning("Geoset size error");
        $ = cursor;
    }
};

bitfield NodeFlag {
    helper: 1; // 0x0: helper
    translation: 1; // 0x1: dont inherit translation
    rotation: 1; // 0x2: dont inherit rotation
    scaling: 1;// 0x4: dont inherit scaling
    billboarded : 1;// 0x8: billboarded
    lockX : 1;// 0x10: billboarded lock x
    lockY : 1;// 0x20: billboarded lock y
    lockZ : 1;// 0x40: billboarded lock z
    anchored : 1;// 0x80: camera anchored
    bone : 1;// 0x100: bone
    light : 1;// 0x200: light
    event : 1;// 0x400 event object
    attachment : 1;// 0x800: attachment
    particle : 1;// 0x1000 particle emitter
    collision : 1;// 0x2000: collision shape
    ribbon : 1;// 0x4000: ribbon emitter
    unshaded : 1;// 0x8000: if particle emitter: emitter uses mdl, if particle emitter 2: unshaded
    tga : 1;// 0x10000: if particle emitter: emitter uses tga, if particle emitter 2: sort primitives far z
    line : 1;// 0x20000: line emitter
    unfogged : 1;// 0x40000: unfogged
    space : 1;// 0x80000: model space
    quad : 1;// 0x100000: xy quad
  padding: 10;
};


struct Node {
  u32 inclusiveSize;
  char name[80];
  u32 objectId;
  u32 parentId;
  NodeFlag flag;
  //(KGTR)
  //(KGRT)
  //(KGSC)
  TrackParent track[while ($ < addressof(this) + inclusiveSize)];

  u32 cursor = addressof(this) + inclusiveSize;
  if ($ != cursor) {
    std::warning("Node size error");
    $ = cursor;
  }
};

struct Helper {
  Node node;
};

struct Bone {
  Node node;
  u32 geosetId;
  u32 geosetAnimationId;
};

struct Attachment {
  u32 inclusiveSize;
  Node node;
  char path[260];
  u32 attachmentId;
  //(KATV)
  TrackParent track[while ($ < addressof(this) + inclusiveSize)];

  u32 cursor = addressof(this) + inclusiveSize;
  if ($ != cursor) {
    std::warning("Attachment size error");
    $ = cursor;
  }
};

struct ParticleEmitter2 {
  u32 inclusiveSize;
  Node node;
  float speed;
  float variation;
  float latitude;
  float gravity;
  float lifespan;
  float emissionRate;
  float length;
  float width;
  u32 filterMode; // 0: blend
                    // 1: additive
                    // 2: modulate
                    // 3: modulate 2x
                    // 4: alpha key
  u32 rows;
  u32 columns;
  u32 headOrTail; // 0: head
                    // 1: tail
                    // 2: both
  float tailLength;
  float time;
  Vec3 segmentColor[3];
  u8 segmentAlpha[3];
  float segmentScaling[3];
  u32 headInterval[3];
  u32 headDecayInterval[3];
  u32 tailInterval[3];
  u32 tailDecayInterval[3];
  u32 textureId;
  u32 squirt;
  u32 priorityPlane;
  u32 replaceableId;
  /*
  (KP2S)
  (KP2R)
  (KP2L)
  (KP2G)
  (KP2E)
  (KP2N)
  (KP2W)
  (KP2V)
  */
  TrackParent track[while ($ < addressof(this) + inclusiveSize)];

  u32 cursor = addressof(this) + inclusiveSize;
  if ($ != cursor) {
    std::warning("ParticleEmitter2 size error");
    $ = cursor;
  }
};

struct RibbonEmitter {
  u32 inclusiveSize;
  Node node;
  float heightAbove;
  float heightBelow;
  float alpha;
  float color[3];
  float lifespan;
  u32 textureSlot;
  u32 emissionRate;
  u32 rows;
  u32 columns;
  u32 materialId;
  float gravity;
  /*
  (KRHA)
  (KRHB)
  (KRAL)
  (KRCO)
  (KRTX)
  (KRVS)
  */
  TrackParent track[while ($ < addressof(this) + inclusiveSize)];

  u32 cursor = addressof(this) + inclusiveSize;
  if ($ != cursor) {
    std::warning("RibbonEmitter size error");
    $ = cursor;
  }
};

struct EventObject {
  Node node;
  char tag[4]; //"KEVT"
  u32 tracksCount;
  u32 globalSequenceId;
  u32 tracks[tracksCount];
};

enum Collision: u32 {
    cube = 0,
    plane = 1,
    sphere = 2,
    cylinder = 3,
};

struct CollisionShape {
  Node node;
  Collision type;

  match(type){
    (Collision::cube): {
        Vec2 vertices[3];
    }
    (Collision::plane): {
        Vec2 vertices[3];
    }
    (Collision::sphere): {
        float vertices[3];
        float radius;
    }
    (Collision::cylinder): {
        Vec2 vertices[3];
        float radius;
    }
  }
};

enum Tag: u32 {
    VERS = 0x56455253,
    MODL = 0x4D4F444C,
    SEQS = 0x53455153,
    GLBS = 0x474C4253,
    MTLS = 0x4D544C53,
    TEXS = 0x54455853,
    GEOS = 0x47454F53,
    BONE = 0x424F4E45,
    HELP = 0x48454C50,
    ATCH = 0x41544348,
    PIVT = 0x50495654,
    PRE2 = 0x50524532,
    RIBB = 0x52494242,
    EVTS = 0x45565453,
    CLID = 0x434C4944,
};

struct Chunk {
    be Tag tag;
    u32 size;

    auto pos = $;

    match(tag){
        (Tag::VERS): VERS vers;
        (Tag::MODL): MODL modl;
        (Tag::SEQS): Sequence sequence[size / 132];
        (Tag::GLBS): u32 globalSequences[size / 4];
        (Tag::TEXS): Texture texture[size / 268];
        (Tag::PIVT): Vec3 points[size / 12];
        (Tag::MTLS): Material material[while ($ < addressof(size) + sizeof(size) + size)];
        (Tag::GEOS): Geoset geoset[while ($ < addressof(size) + sizeof(size) + size)];
        (Tag::BONE): Bone bone[while ($ < addressof(size) + sizeof(size) + size)];
        (Tag::HELP): Helper helper[while ($ < addressof(size) + sizeof(size) + size)];
        (Tag::ATCH): Attachment attachment[while ($ < addressof(size) + sizeof(size) + size)];
        (Tag::PRE2): ParticleEmitter2 particleEmitter2[while ($ < addressof(size) + sizeof(size) + size)];
        (Tag::RIBB): RibbonEmitter ribbonEmitter[while ($ < addressof(size) + sizeof(size) + size)];

        (Tag::EVTS): EventObject eventObject[while ($ < addressof(size) + sizeof(size) + size)];
        (Tag::CLID): CollisionShape collisionShape[while ($ < addressof(size) + sizeof(size) + size)];
    }

    $ = pos;
    padding[size];
};

Chunk chunk[while (!std::mem::eof())] @ 0x04;
