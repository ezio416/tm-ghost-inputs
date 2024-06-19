// c 2024-06-18
// m 2024-06-19

uint8[]        contents;
UI::Font@      font;
CGameCtnGhost@ ghost;
const string   ghostName = "Replays/ezio.Ghost.gbx";
// const string   ghostName = "Replays/kelven.Ghost.gbx";
string[][]     rows;
const float    scale     = UI::GetScale();
const string   title     = "\\$FFF" + Icons::SnapchatGhost + "\\$G Ghost Inputs";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

void Main() {
    @font = UI::LoadFont("DroidSansMono.ttf",  16, -1, -1, true, true, true);
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
            Tab_GhostGbx();
        UI::EndTabBar();
    }

    UI::End();
}

void Tab_CGameCtnGhost() {
    if (!UI::BeginTabItem("CGameCtnGhost"))
        return;

    if (ghost is null) {
        if (UI::Button(Icons::Upload + " Load Ghost")) {
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
        if (UI::Button(Icons::Trash + " Nullify Ghost"))
            @ghost = null;
    }

    if (ghost is null) {
        UI::EndTabItem();
        return;
    }

    UI::SameLine();
    if (UI::Button(Icons::Cube + " Explore Ghost"))
        ExploreNod("ghost", ghost);

    ;

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
                    const uint columns  = 16;
                    uint       index    = 0;
                    const uint rowCount = (contents.Length / 16) + 1;

                    for (uint i = 0; i < rowCount; i++) {
                        string[] row;

                        row.InsertLast(Zpad(IntToHex(i * columns, false), 8));
                        row.InsertLast("row " + i);

                        string asciiChar = ".";
                        string asciiStr;

                        for (uint j = 0; j < columns; j++) {
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

    // const uint rowCount = (contents.Length / 16) + 1;

    // uint index = 0;

    // for (uint i = 0; i < rowCount; i++) {
    //     UI::TableNextRow();

    //     UI::TableNextColumn();
    //     UI::Text(Zpad(IntToHex(i * columnCount, false), 8));

    //     string row;
    //     string ascii = ".";

    //     for (uint j = 0; j < columnCount; j++) {
    //         if (index >= contents.Length) {
    //             UI::TableNextColumn();
    //             continue;
    //         }

    //         const uint8 val = contents[index];

    //         UI::TableNextColumn();
    //         const string uncolored = Zpad(IntToHex(val, false), 2);
    //         UI::Text((uncolored == "00" ? "\\$F00" : "\\$0F0") + uncolored);

    //         string char;

    //         if (val >= 32 && val < 128) {
    //             ascii[0] = val;
    //             char = ascii;
    //         } else
    //             char = "\\$666.\\$G";

    //         row += char;

    //         HoverTooltip(tostring(index) + " | " + IntToHex(index) + " | " + char);

    //         index++;
    //     }

    //     UI::TableNextColumn();
    //     UI::Text(row);
    // }

    UI::PopStyleColor();
    UI::EndTable();

    UI::PopFont();
}
