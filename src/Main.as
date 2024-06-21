// c 2024-06-18
// m 2024-06-19

uint8[]             contents;
UI::Font@           font;
CGameCtnGhost@      ghost;
const string        ghostName = "Replays/ezio.Ghost.gbx";
// const string        ghostName = "Replays/kelven.Ghost.gbx";
CPlugEntRecordData@ recordData;
string[][]          rows;
const float         scale     = UI::GetScale();
const string        title     = "\\$FFF" + Icons::SnapchatGhost + "\\$G Ghost Inputs";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

void Main() {
    @font = UI::LoadFont("DroidSansMono.ttf",  16, -1, -1, true, true, true);

    // startnew(RunGhostTest);
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
        || font is null
    )
        return;

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::None)) {
        UI::BeginTabBar("##tabs");
            Tab_CGameCtnGhost();
            Tab_CPlugEntRecordData();
            // Tab_GhostGbx();
        UI::EndTabBar();
    }

    UI::End();
}

void Tab_CGameCtnGhost() {
    if (!UI::BeginTabItem("CGameCtnGhost"))
        return;

    if (ghost is null) {
        if (UI::Button(CYAN + Icons::Upload + RESET + " Load Ghost")) {
            CSystemFidFile@ fid = Fids::GetUser(ghostName);
            if (fid is null)
                warn("fid null");
            else {
                @ghost = cast<CGameCtnGhost@>(Fids::Preload(fid));
                if (ghost is null)
                    warn("ghost null");
            }
        }
    } else {
        if (UI::Button(RED + Icons::Trash + RESET + " Nullify Ghost")) {
            @ghost = null;
            @recordData = null;
        }
    }

    if (ghost is null) {
        UI::EndTabItem();
        return;
    }

    UI::SameLine();
    if (UI::Button(YELLOW + Icons::Cube + RESET + " Explore Ghost"))
        ExploreNod("ghost", ghost);

    UI::SameLine();
    if (UI::Button(PURPLE + Icons::Gamepad + RESET + " Get Ghost Inputs"))
        GetInputsFromGhost(ghost);

    if (UI::Button(YELLOW + Icons::Cube + RESET + " Explore Fid"))
        ExploreNod("ghost", CGameCtnGhost_GetFidFile(ghost));

    if (UI::Button(YELLOW + Icons::Cube + RESET + " Explore Skin"))
        ExploreNod("ghost skin", CGameCtnGhost_GetSkin(ghost));

    if (recordData is null) {
        if (UI::Button(CYAN + Icons::Upload + RESET + " Get Record Data"))
            @recordData = CGameCtnGhost_GetRecordData(ghost);
    } else if (UI::Button(RED + Icons::Trash + RESET + " Nullify Record Data"))
        @recordData = null;

    UI::SameLine();
    if (UI::Button(YELLOW + Icons::Cube + RESET + " Explore Record Data"))
        ExploreNod("record data", CGameCtnGhost_GetRecordData(ghost));

    UI::BeginTabBar("##tabs-CGameCtnGhost");
        Tab_CGameCtnGhost_ApiOffsets();
        Tab_RawOffsets(ghost);
    UI::EndTabBar();

    UI::EndTabItem();
}

void Tab_CGameCtnGhost_ApiOffsets() {
    if (!UI::BeginTabItem("API Offsets"))
        return;

    if (UI::BeginTable("##table-api-offsets", 3, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("offset", UI::TableColumnFlags::WidthFixed, scale * 50.0f);
        UI::TableSetupColumn("name");
        UI::TableHeadersRow();

        const Reflection::MwClassInfo@ info = Reflection::GetType("CGameCtnGhost");

        for (uint i = 0; i < info.Members.Length; i++) {
            const Reflection::MwMemberInfo@ member = info.Members[i];

            UI::TableNextRow();

            UI::TableNextColumn();

            if (member.Offset < 65535) {
                UI::Text(tostring(member.Offset));
                HoverTooltip(IntToHex(member.Offset));
            }

            UI::TableNextColumn();
            UI::Text(member.Name);
        }

        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}

void Tab_RawOffsets(CMwNod@ Nod) {
    if (!UI::BeginTabItem("Raw Offsets"))
        return;

    if (UI::BeginTable("##table-offsets", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

        UI::TableSetupScrollFreeze(0, 1);
        UI::TableSetupColumn("offset", UI::TableColumnFlags::WidthFixed, scale * 100.0f);
        UI::TableSetupColumn("value (" + tostring(S_OffsetType) + ")");
        UI::TableSetupColumn("pointer");
        UI::TableSetupColumn("string");
        UI::TableHeadersRow();

        UI::ListClipper clipper((S_OffsetMax / S_OffsetSkip) + 1);
        while (clipper.Step()) {
            for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                const uint offset = i * S_OffsetSkip;

                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(tostring(offset) + " (" + IntToHex(offset) + ")");

                string value;
                try {
                    switch (S_OffsetType) {
                        case DataType::Bool:   value = Round(    Dev::GetOffsetInt8  (Nod, offset) == 1); break;
                        case DataType::Int8:   value = Round(    Dev::GetOffsetInt8  (Nod, offset));      break;
                        case DataType::Uint8:  value = RoundUint(Dev::GetOffsetUint8 (Nod, offset));      break;
                        case DataType::Int16:  value = Round(    Dev::GetOffsetInt16 (Nod, offset));      break;
                        case DataType::Uint16: value = RoundUint(Dev::GetOffsetUint16(Nod, offset));      break;
                        case DataType::Int32:  value = Round(    Dev::GetOffsetInt32 (Nod, offset));      break;
                        case DataType::Uint32: value = RoundUint(Dev::GetOffsetUint32(Nod, offset));      break;
                        case DataType::Int64:  value = Round(    Dev::GetOffsetInt64 (Nod, offset));      break;
                        case DataType::Uint64: value = RoundUint(Dev::GetOffsetUint64(Nod, offset));      break;
                        case DataType::Float:  value = Round(    Dev::GetOffsetFloat (Nod, offset));      break;
                        // case DataType::Double: value = Round(    Dev::GetOffsetDouble(Nod, offset));      break;
                        case DataType::Vec2:   value = Round(    Dev::GetOffsetVec2  (Nod, offset));      break;
                        case DataType::Vec3:   value = Round(    Dev::GetOffsetVec3  (Nod, offset));      break;
                        case DataType::Vec4:   value = Round(    Dev::GetOffsetVec4  (Nod, offset));      break;
                        // case DataType::Iso3:   value = Round(    Dev::GetOffsetIso3  (Nod, offset));      break;
                        case DataType::Iso4:   value = Round(    Dev::GetOffsetIso4  (Nod, offset));      break;
                        // case DataType::Nat2:   value = Round(    Dev::GetOffsetNat2  (Nod, offset));      break;
                        // case DataType::Nat3:   value = Round(    Dev::GetOffsetNat3  (Nod, offset));      break;
                        case DataType::String:
                            value = LooksLikeString(Nod, offset) ? Dev::GetOffsetString(Nod, offset) : "";
                            break;
                        default:;
                    }
                } catch {
                    UI::Text(YELLOW + getExceptionInfo());
                }
                UI::TableNextColumn();
                UI::Text(value);

                UI::TableNextColumn();
                if (LooksLikePtr(Nod, offset)) {
                    if (UI::Selectable("explore ptr##" + offset, false)) {
                        CMwNod@ nod = Dev::GetOffsetNod(Nod, offset);
                        if (nod is null)
                            warn("nod null");
                        else
                            ExploreNod("nod", nod);
                    }
                } else {
                    if (UI::Selectable(RED + "prob not ptr, explore anyway?##" + offset, false)) {
                        CMwNod@ nod = Dev::GetOffsetNod(Nod, offset);
                        if (nod is null)
                            warn("nod null");
                        else
                            ExploreNod("nod", nod);
                    }
                }

                UI::TableNextColumn();
                if (LooksLikeString(Nod, offset)) {
                    if (UI::Selectable("print string##" + offset, false))
                        print(tostring(offset) + " | " + IntToHex(offset) + " | " + Dev::GetOffsetString(Nod, offset));
                } else {
                    if (UI::Selectable(RED + "prob not string, print anyway?##" + offset, false))
                        print(tostring(offset) + " | " + IntToHex(offset) + " | " + Dev::GetOffsetString(Nod, offset));
                }
            }
        }

        UI::TableNextRow();
        UI::PopStyleColor();
        UI::EndTable();
    }

    UI::EndTabItem();
}

void Tab_GhostGbx() {
    if (!UI::BeginTabItem(".Ghost.Gbx"))
        return;

    if (contents.Length == 0) {
        if (UI::Button(Icons::Upload + " Load Ghost")) {
            MemoryBuffer@ buffer = ReadFile(IO::FromUserGameFolder(ghostName).Replace("\\", "/"));
            if (buffer is null)
                warn("buffer null");
            else {
                while (!buffer.AtEnd())
                    contents.InsertLast(buffer.ReadUInt8());

                if (contents.Length == 0)
                    warn("contents empty");
                else {
                    const uint columnCount = 16;
                    uint       index       = 0;
                    const uint rowCount    = (contents.Length / 16) + 1;

                    for (uint i = 0; i < rowCount; i++) {
                        string[] row;

                        row.InsertLast(Zpad(IntToHex(i * columnCount, false), 8));
                        row.InsertLast("row " + i);

                        string asciiChar = ".";
                        string asciiStr;

                        for (uint j = 0; j < columnCount; j++) {
                            if (index >= contents.Length) {
                                row.InsertLast("");
                                row.InsertLast("");
                                continue;
                            }

                            const uint8 val = contents[index];

                            const string uncolored = Zpad(IntToHex(val, false), 2);
                            row.InsertLast((uncolored == "00" ? "\\$F00" : "\\$0F0") + uncolored);

                            string char;

                            if (val >= 32 && val < 128) {
                                asciiChar[0] = val;
                                char = asciiChar;
                            } else
                                char = "\\$666.\\$G";

                            asciiStr += char;
                            row.InsertLast(tostring(index) + " | " + IntToHex(index) + " | " + char);

                            index++;
                        }

                        row.InsertLast(asciiStr);
                        rows.InsertLast(row);
                    }
                }
            }
        }
    } else if (UI::Button(Icons::Trash + " Clear Contents")) {
        contents = {};
        rows     = {};
    }

    if (contents.Length == 0) {
        UI::EndTabItem();
        return;
    }

    Table_GhostGbxMemory();

    UI::EndTabItem();
}

void Table_GhostGbxMemory() {
    UI::PushFont(font);

    const uint columnCount = 16;

    if (!UI::BeginTable("##table", columnCount + 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
        UI::PopFont();
        return;
    }

    UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

    UI::TableSetupScrollFreeze(0, 1);
    UI::TableSetupColumn("Row Start", UI::TableColumnFlags::WidthFixed, scale * 70.0f);
    for (uint i = 0; i < columnCount; i++)
        UI::TableSetupColumn(i % 4 == 0 ? IntToHex(i, false) : "", UI::TableColumnFlags::WidthFixed, 25.0f);
    UI::TableSetupColumn("ASCII");
    UI::TableHeadersRow();

    UI::ListClipper clipper(rows.Length);
    while (clipper.Step()) {
        for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
            string[] row = rows[i];

            UI::TableNextRow();

            for (uint j = 0; j < row.Length - 1; j += 2) {
                UI::TableNextColumn();
                UI::Text(row[j]);
                HoverTooltip(row[j + 1]);
            }

            UI::TableNextColumn();
            UI::Text(row[row.Length - 1]);
        }
    }

    UI::PopStyleColor();
    UI::EndTable();

    UI::PopFont();
}

void Tab_CPlugEntRecordData() {
    if (recordData is null || !UI::BeginTabItem("CPlugEntRecordData"))
        return;

    UI::BeginTabBar("##tabs-record-data");
        Tab_RawOffsets(recordData);
    UI::EndTabBar();

    UI::EndTabItem();
}
