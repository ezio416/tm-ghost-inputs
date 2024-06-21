// c 2024-06-19
// m 2024-06-20

enum DataType {
    Bool,
    Int8,
    Uint8,
    Int16,
    Uint16,
    Int32,
    Uint32,
    Int64,
    Uint64,
    Float,
    // Double,
    Vec2,
    Vec3,
    Vec4,
    // Iso3,
    Iso4,
    // Nat2,
    // Nat3,
    String
}

const string BLUE   = "\\$09D";
const string CYAN   = "\\$2FF";
const string GRAY   = "\\$888";
const string GREEN  = "\\$0D2";
const string ORANGE = "\\$F90";
const string PURPLE = "\\$F0F";
const string RED    = "\\$F00";
const string WHITE  = "\\$FFF";
const string YELLOW = "\\$FF0";
const string RESET  = "\\$G";

uint16 GetMemberOffset(const string &in className, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::GetType(className);

    if (type is null)
        throw("Unable to find reflection info for \"" + className + "\"");

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    if (member is null)
        throw("Unable to find member \"" + memberName + "\" in \"" + className + "\"");

    return member.Offset;
}

bool LooksLikePtr(CMwNod@ nod, uint offset) {
    const uint64 ptr = Dev::GetOffsetUint64(nod, offset);

    // return ptr > 0xFFFFFFFFFF
    //     && ptr < 0x0000030FFEEDDCC
    //     && ptr & 0xF == 0;

    return PointerLooksGood(ptr);
}

// bool LooksLikeString(CMwNod@ nod, uint offset) {
//     const uint64 strPtr = Dev::GetOffsetUint64(nod, offset);
//     // if (!PointerLooksGood(strPtr))
//     //     return false;

//     const uint32 strLen = Dev::GetOffsetUint32(nod, offset + 0xC);

//     return (
//         strPtr == 0 && strLen == 0
//         || (strLen < 12)
//         || (
//             strLen >= 12
//             && strLen < 128
//             && strPtr > 0xFFFFFFFFFF
//             && strPtr < 0x0000030FFEEDDCC
//         )
//     );
// }

bool LooksLikeString(CMwNod@ nod, uint offset) {
    auto strPtr = Dev::GetOffsetUint64(nod, offset);
    auto strLen = Dev::GetOffsetUint32(nod, offset + 0xC);
    return (strPtr == 0 && strLen == 0
        || (strLen < 12)
        || (strLen >= 12 && strLen < 128
            && strPtr > 0xFFFFFFFFFF && strPtr < 0x0000030FFEEDDCC)
        );
}

bool PointerLooksGood(uint64 ptr) {
    return ptr >= 0x10000000000 && ptr % 8 == 0 && ptr <= Dev::BaseAddressEnd();
}

// string[] OffsetValue(CMwNod@ Nod, uint offset, const string &in name, DataType type, bool known = true) {
//     string value;

//     switch (type) {
//         case DataType::Bool:   value = Round(    Dev::GetOffsetInt8  (Nod, offset) == 1); break;
//         case DataType::Int8:   value = Round(    Dev::GetOffsetInt8  (Nod, offset));      break;
//         case DataType::Uint8:  value = RoundUint(Dev::GetOffsetUint8 (Nod, offset));      break;
//         case DataType::Int16:  value = Round(    Dev::GetOffsetInt16 (Nod, offset));      break;
//         case DataType::Uint16: value = RoundUint(Dev::GetOffsetUint16(Nod, offset));      break;
//         case DataType::Int32:  value = Round(    Dev::GetOffsetInt32 (Nod, offset));      break;
//         case DataType::Uint32: value = RoundUint(Dev::GetOffsetUint32(Nod, offset));      break;
//         case DataType::Int64:  value = Round(    Dev::GetOffsetInt64 (Nod, offset));      break;
//         case DataType::Uint64: value = RoundUint(Dev::GetOffsetUint64(Nod, offset));      break;
//         case DataType::Float:  value = Round(    Dev::GetOffsetFloat (Nod, offset));      break;
//         // case DataType::Double: value = Round(    Dev::GetOffsetDouble(Nod, offset));      break;
//         case DataType::Vec2:   value = Round(    Dev::GetOffsetVec2  (Nod, offset));      break;
//         case DataType::Vec3:   value = Round(    Dev::GetOffsetVec3  (Nod, offset));      break;
//         case DataType::Vec4:   value = Round(    Dev::GetOffsetVec4  (Nod, offset));      break;
//         // case DataType::Iso3:   value = Round(    Dev::GetOffsetIso3  (Nod, offset));      break;
//         case DataType::Iso4:   value = Round(    Dev::GetOffsetIso4  (Nod, offset));      break;
//         // case DataType::Nat2:   value = Round(    Dev::GetOffsetNat2  (Nod, offset));      break;
//         // case DataType::Nat3:   value = Round(    Dev::GetOffsetNat3  (Nod, offset));      break;
//         case DataType::String:
//             value = LooksLikeString(Nod, offset) ? Dev::GetOffsetString(Nod, offset) : "";
//             break;
//         default:;
//     }

//     return { tostring(offset), IntToHex(offset), (known ? "" : YELLOW) + name, tostring(type), value };
// }

string Round(bool b) {
    return (b ? GREEN : RED) + b;
}

string Round(int64 num) {
    return (num == 0 ? WHITE : num < 0 ? RED : GREEN) + (S_IntAsHex ? IntToHex(Math::Abs(num)) : tostring(Math::Abs(num)));
}

string Round(float num, uint precision = S_Precision) {
    return (num == 0.0f ? WHITE : num < 0.0f ? RED : GREEN) + Text::Format("%." + precision + "f", Math::Abs(num));
}

// string Round(double num, uint precision = S_Precision) {
//     return (num == 0.0 ? WHITE : num < 0.0 ? RED : GREEN) + Text::Format("%." + precision + "f", Math::Abs(num));
// }

string Round(vec2 vec, uint precision = S_Precision) {
    return Round(vec.x, precision) + "\\$G , " + Round(vec.y, precision);
}

string Round(vec3 vec, uint precision = S_Precision) {
    return Round(vec.x, precision) + "\\$G , " + Round(vec.y, precision) + "\\$G , " + Round(vec.z, precision);
}

string Round(vec4 vec, uint precision = S_Precision) {
    return Round(vec.x, precision) + "\\$G , " + Round(vec.y, precision) + "\\$G , " + Round(vec.z, precision) + "\\$G , " + Round(vec.w, precision);
}

string Round(iso4 iso, uint precision = S_Precision) {
    string ret;

    ret += Round(iso.tx, precision) + "\\$G , " + Round(iso.ty, precision) + "\\$G , " + Round(iso.tz, precision) + "\n";
    ret += Round(iso.xx, precision) + "\\$G , " + Round(iso.xy, precision) + "\\$G , " + Round(iso.xz, precision) + "\n";
    ret += Round(iso.yx, precision) + "\\$G , " + Round(iso.yy, precision) + "\\$G , " + Round(iso.yz, precision) + "\n";
    ret += Round(iso.zx, precision) + "\\$G , " + Round(iso.zy, precision) + "\\$G , " + Round(iso.zz, precision);

    return ret;
}

string RoundUint(uint64 num) {  // separate function else a uint gets converted to an int, losing data
    return (num == 0 ? WHITE : GREEN) + (S_IntAsHex ? IntToHex(num) : tostring(num));
}

const uint16 O_CTNGHOST_FIDFILE       = 0x8;  // 8
const uint16 O_CTNGHOST_SKINPACKDESC  = GetMemberOffset("CGameCtnGhost", "ModelIdentAuthor") + 0x20;      // 0x70  112
const uint16 O_CTNGHOST_PRESTIGE      = GetMemberOffset("CGameCtnGhost", "LightTrailColor")  - 0x10;      // 0xB0  176 doesn't look like string ptr
const uint16 O_CTNGHOST_AVATARNAME    = 0xD0;  // 208
const uint16 O_CTNGHOST_NICKNAME      = GetMemberOffset("CGameCtnGhost", "GhostNickname");                // 0xE0  224
const uint16 O_CTNGHOST_CLUBTAG       = 0xF0;  // 240
const uint16 O_CTNGHOST_TRIGRAM       = GetMemberOffset("CGameCtnGhost", "GhostTrigram");                 // 0x100 256
const uint16 O_CTNGHOST_LOGIN         = GetMemberOffset("CGameCtnGhost", "GhostLogin");                   // 0x110 272 doesn't look like string ptr
const uint16 O_CTNGHOST_COUNTRYPATH   = GetMemberOffset("CGameCtnGhost", "GhostCountryPath");             // 0x120 288 doesn't look like string ptr
const uint16 O_CTNGHOST_RECCONTEXT    = GetMemberOffset("CGameCtnGhost", "RecordingContext");             // 0x140 320
const uint16 O_CTNGHOST_SCOPEID       = GetMemberOffset("CGameCtnGhost", "Validate_ScopeId");             // 0x168 360
const uint16 O_CTNGHOST_GAMEMODE      = GetMemberOffset("CGameCtnGhost", "Validate_GameMode");            // 0x178 376
const uint16 O_CTNGHOST_CUSTOMDATA    = GetMemberOffset("CGameCtnGhost", "Validate_GameModeCustomData");  // 0x188 392
const uint16 O_CTNGHOST_EXECHECKSUM   = GetMemberOffset("CGameCtnGhost", "Validate_ExeChecksum");         // 0x1C0 448
const uint16 O_CTNGHOST_OSKIND        = GetMemberOffset("CGameCtnGhost", "Validate_OsKind");              // 0x1C4 452
const uint16 O_CTNGHOST_CPUKIND       = GetMemberOffset("CGameCtnGhost", "Validate_CpuKind");             // 0x1C8 456
const uint16 O_CTNGHOST_TITLEID       = GetMemberOffset("CGameCtnGhost", "Validate_TitleId");             // 0x1D8 472
const uint16 O_CTNGHOST_EXTRATOOLINFO = GetMemberOffset("CGameCtnGhost", "Validate_ExtraTool_Info");      // 0x220 544 doesn't look like string ptr
const uint16 O_CTNGHOST_RECORDDATA    = 0x2E0;  // 736

CSystemFidFile@ CGameCtnGhost_GetFidFile(CGameCtnGhost@ ghost) {
    if (ghost is null || !LooksLikePtr(ghost, O_CTNGHOST_FIDFILE))
        return null;

    return cast<CSystemFidFile@>(Dev::GetOffsetNod(ghost, O_CTNGHOST_FIDFILE));
}

CSystemPackDesc@ CGameCtnGhost_GetSkin(CGameCtnGhost@ ghost) {
    if (ghost is null || !LooksLikePtr(ghost, O_CTNGHOST_SKINPACKDESC))
        return null;

    return cast<CSystemPackDesc@>(Dev::GetOffsetNod(ghost, O_CTNGHOST_SKINPACKDESC));
}

string CGameCtnGhost_GetPrestigeOpts(CGameCtnGhost@ ghost) {
    if (ghost is null || !LooksLikeString(ghost, O_CTNGHOST_PRESTIGE))
        return "";

    return Dev::GetOffsetString(ghost, O_CTNGHOST_PRESTIGE);
}

CPlugEntRecordData@ CGameCtnGhost_GetRecordData(CGameCtnGhost@ ghost) {
    if (ghost is null || !LooksLikePtr(ghost, O_CTNGHOST_RECORDDATA))
        return null;

    return cast<CPlugEntRecordData@>(Dev::GetOffsetNod(ghost, O_CTNGHOST_RECORDDATA));
}

void GetInputsFromGhost(CGameCtnGhost@ ghost) {
    const uint64 bufferPtr1 = Dev::GetOffsetUint64(ghost, 0x1A0);
    if (!PointerLooksGood(bufferPtr1)) {
        warn("bufferPtr1 (" + Text::FormatPointer(bufferPtr1) + ") does not look like a pointer!");
        return;
    } else
        print("bufferPtr1: " + Text::FormatPointer(bufferPtr1));

    const uint64 bufferPtr2 = ReadUint64PtrSafe(bufferPtr1, 0x10);
    if (!PointerLooksGood(bufferPtr2)) {
        warn("bufferPtr2 (" + Text::FormatPointer(bufferPtr2) + ") does not look like a pointer!");
        return;
    } else
        print("bufferPtr2: " + Text::FormatPointer(bufferPtr2));

    const uint64 dataPtr = ReadUint64PtrSafe(bufferPtr2, 0x18);
    if (!PointerLooksGood(dataPtr)) {
        warn("dataPtr (" + Text::FormatPointer(dataPtr) + ") does not look like a pointer!");
        return;
    } else
        print("dataPtr: " + Text::FormatPointer(dataPtr));

    const uint dataSize = Dev::ReadUInt32(bufferPtr2 + 0x18 + 0x8);
    print("dataSize: " + dataSize);

    ;
}

EntRecordDelta@[]@ GetSamplesFromGhost(CGameCtnGhost@ ghost) {
    CPlugEntRecordData@ entRecordData = CGameCtnGhost_GetRecordData(ghost);

    uint64 samplesAllPtr = Dev::GetOffsetUint64(ghost, O_CTNGHOST_RECORDDATA + 0x8);
    uint64 samples1PtrAlt = ReadUint64PtrSafe(samplesAllPtr, 0);

    if (entRecordData is null) {
        warn("Null ent record data");
        return {};
    }

    uint64 visSampleDataPtr = Dev::GetOffsetUint64(entRecordData, 0x40);

    while (visSampleDataPtr != 0 && Dev::ReadUInt8(visSampleDataPtr + 0x8) != 0x2) {
        trace("found samples of type: " + Dev::ReadUInt8(visSampleDataPtr + 0x8) + " at " + Text::FormatPointer(visSampleDataPtr));
        visSampleDataPtr = ReadUint64PtrSafe(visSampleDataPtr, 0);
    }

    if (visSampleDataPtr == 0 || Dev::ReadUInt8(visSampleDataPtr + 0x8) != 0x2) {
        warn("Failed to find samples of type 0x2 (vehicle); next ptr: " + Text::FormatPointer(visSampleDataPtr));
        return {};
    }

    if (visSampleDataPtr + 0x8 != samples1PtrAlt)
        warn("Alt ptr: " + Text::FormatPointer(samples1PtrAlt) + "\nGot Ptr: " + Text::FormatPointer(visSampleDataPtr + 0x8));

    uint64 nextSamplePtr = ReadUint64PtrSafe(samples1PtrAlt, 0x10);

    EntRecordDelta@[] data;

    uint64 now = Time::Now;

    while (nextSamplePtr > 0) {
        uint time = Dev::ReadUInt32(nextSamplePtr + 0x8);
        uint64 dataPtr = ReadUint64PtrSafe(nextSamplePtr, 0x10);
        uint dataLen = Dev::ReadUInt32(nextSamplePtr + 0x18);
        data.InsertLast(EntRecordDelta(time, dataPtr, dataLen));
        // yield();
        if (Time::Now - now > 50) {
            now = Time::Now;
            yield();
        }
        nextSamplePtr = ReadUint64PtrSafe(nextSamplePtr, 0);
    }

    return data;
}

uint64 ReadUint64PtrSafe(const uint64 ptr, const uint16 offset) {
    if (ptr == 0) {
        trace('ptr == 0');
        return 0;
    }

    if (ptr & 0x7 != 0) {
        trace('ptr & 0x7 != 0');
        return 0;
    }

    if (ptr <= 0xFFFFFFFF) {
        trace('ptr <= 0xFFFFFFFF');
        return 0;
    }

    if (ptr > 0xF0F0FFFFFFFF) {
        trace('ptr > 0xF0F0FFFFFFFF');
        return 0;
    }

    return Dev::ReadUInt64(ptr + offset);
}

// conveniently the same format as in gbx files
class EntRecordDelta {
    protected uint64 ptr;
    protected uint len;
    uint time;

    EntRecordDelta(uint time, uint64 ptr, uint len) {
        this.ptr = ptr;
        this.len = len;
        this.time = time;
        ReadFromPtr();
        trace('Instantiated EntRecordDelta @ ' + Text::FormatPointer(ptr) + ' // time: ' + time + ' // pos: ' + position.ToString());
    }

    float brake;
    float gas;
    vec3  position;
    quat  rotation;
    float speed;
    vec3  velocity;

    protected void ReadFromPtr() {
        // read pos, speed, rotation, velocity
        Seek(47);
        position = ReadVec3();
        float angle = ReadUInt16ToFloat(Math::PI, 0xFFFF);
        float axisHeading = ReadInt16ToFloat(Math::PI, 0x7FFF);
        float axisPitch = ReadInt16ToFloat(Math::PI / 2.0f, 0x7FFF);
        speed = Math::Exp(ReadInt16ToFloat(1.0f, 1000));
        float velHeading = ReadInt8ToFloat(Math::PI, 0x7F);
        float velPitch = ReadInt8ToFloat(Math::PI / 2.0f, 0x7F);
        vec3 axis = vec3(
            Math::Sin(angle) * Math::Cos(axisPitch) * Math::Cos(axisHeading),
            Math::Sin(angle) * Math::Cos(axisPitch) * Math::Sin(axisHeading),
            Math::Sin(angle) * Math::Sin(axisPitch)
        );
        rotation = quat(axis, Math::Cos(angle));
        velocity = speed * vec3(
            Math::Cos(velPitch) * Math::Cos(velHeading),
            Math::Cos(velPitch) * Math::Sin(velHeading),
            Math::Sin(velPitch)
        );

        // read braking and gas
        Seek(15);
        gas = ReadUInt8ToFloat(1.0f, 255);
        Seek(18);
        brake = ReadUInt8ToFloat(1.0f, 255);
        gas += brake;
    }

    protected uint currOffset = 0;
    void Seek(uint offset) {
        // should only be 107 long
        if (offset >= 120)
            throw('offset too large');
        currOffset = offset;
    }

    vec3 ReadVec3() {
        auto v = Dev::ReadVec3(ptr + currOffset);
        currOffset += 0xC;
        return v;
    }

    float ReadUInt16ToFloat(float coef, int divisor) {
        uint16 v = Dev::ReadUInt16(ptr + currOffset);
        currOffset += 0x2;
        return float(v) * coef / float(divisor);
    }

    float ReadInt16ToFloat(float coef, int divisor) {
        uint16 v = Dev::ReadInt16(ptr + currOffset);
        currOffset += 0x2;
        return float(v) * coef / float(divisor);
    }

    float ReadInt8ToFloat(float coef, int divisor) {
        int8 v = Dev::ReadInt8(ptr + currOffset);
        currOffset += 0x1;
        return float(v) * coef / float(divisor);
    }

    float ReadUInt8ToFloat(float coef, int divisor) {
        uint8 v = Dev::ReadUInt8(ptr + currOffset);
        currOffset += 0x1;
        return float(v) * coef / float(divisor);
    }
}

void RunGhostTest() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    if (App.RootMap !is null && App.RootMap.ModPackDesc !is null)
        Fids::Preload(App.RootMap.ModPackDesc.Fid);

    sleep(250);
    while (App.PlaygroundScript is null)
        yield();
    while (App.PlaygroundScript !is null && Ghosts_PP::GetCurrentGhosts(App) is null)
        yield();
    while (App.PlaygroundScript !is null && Ghosts_PP::GetCurrentGhosts(App).Length == 0)
        yield();
    if (App.PlaygroundScript !is null) {
        auto ghosts = Ghosts_PP::GetCurrentGhosts(App);
        auto bestGhost = ghosts[0];
        for (uint i = 0; i < ghosts.Length; i++) {
            if (bestGhost.RaceTime > ghosts[i].RaceTime)
                @bestGhost = ghosts[i];
        }
        EntRecordDelta@[]@ entDeltas = GetSamplesFromGhost(bestGhost);
        print("Got deltas of length: " + entDeltas.Length);
        while (App.PlaygroundScript !is null) {
            nvg_DrawGhostPath(entDeltas);
            yield();
        }
    }
}

void nvg_DrawGhostPath(EntRecordDelta@[]@ samples) {
    if (samples.Length == 0)
        return;
    nvg::Reset();
    nvg::BeginPath();
    nvg::StrokeWidth(3.0);
    nvg::StrokeColor(vec4(1));
    nvgMoveToWorldPos(samples[0].position);
    for (uint i = 0; i < samples.Length; i++)
        nvgToWorldPos(samples[i].position, samples[i].brake > 0 ? vec4(1.0f, 0.5f, 0.5f, 1.0f) : vec4(0.2f, 1.0f, 0.2f, 1.0f));
}

bool nvgWorldPosLastVisible = false;
vec3 nvgLastWorldPos = vec3();

void nvgWorldPosReset() {
    nvgWorldPosLastVisible = false;
}

void nvgToWorldPos(vec3 &in pos, vec4 &in col = vec4(1)) {
    nvgLastWorldPos = pos;
    vec3 uv = Camera::ToScreen(pos);
    if (uv.z > 0) {
        nvgWorldPosLastVisible = false;
        return;
    }
    if (nvgWorldPosLastVisible)
        nvg::LineTo(uv.xy);
    else
        nvg::MoveTo(uv.xy);
    nvgWorldPosLastVisible = true;
    nvg::StrokeColor(col);
    nvg::Stroke();
    nvg::ClosePath();
    nvg::BeginPath();
    nvg::MoveTo(uv.xy);
}

void nvgMoveToWorldPos(vec3 pos) {
    nvgLastWorldPos = pos;
    vec3 uv = Camera::ToScreen(pos);
    if (uv.z > 0) {
        nvgWorldPosLastVisible = false;
        return;
    }
    nvg::MoveTo(uv.xy);
    nvgWorldPosLastVisible = true;
}
