// c 2024-06-19
// m 2024-06-19

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

    return ptr > 0xFFFFFFFFFF
        && ptr < 0x0000030FFEEDDCC
        && ptr & 0xF == 0;
}

bool LooksLikeString(CMwNod@ nod, uint offset) {
    const uint64 strPtr = Dev::GetOffsetUint64(nod, offset);
    const uint32 strLen = Dev::GetOffsetUint32(nod, offset + 0xC);

    return (
        strPtr == 0 && strLen == 0
        || (strLen < 12)
        || (
            strLen >= 12
            && strLen < 128
            && strPtr > 0xFFFFFFFFFF
            && strPtr < 0x0000030FFEEDDCC
        )
    );
}

const uint16 O_CTNGHOST_PRESTIGE     = GetMemberOffset("CGameCtnGhost", "LightTrailColor")  - 0x10;
const uint16 O_CTNGHOST_SKINPACKDESC = GetMemberOffset("CGameCtnGhost", "ModelIdentAuthor") + 0x20;

string CGameCtnGhost_GetPrestigeOpts(CGameCtnGhost@ g) {
    if (g is null || !LooksLikeString(g, O_CTNGHOST_PRESTIGE))
        return "";

    return Dev::GetOffsetString(g, O_CTNGHOST_PRESTIGE);
}

CSystemPackDesc@ CGameCtnGhost_GetSkin(CGameCtnGhost@ g) {
    if (!LooksLikePtr(g, O_CTNGHOST_SKINPACKDESC))
        return null;

    auto nod = Dev::GetOffsetNod(g, O_CTNGHOST_SKINPACKDESC);
    if (nod !is null)
        return cast<CSystemPackDesc@>(nod);

    return null;
}
