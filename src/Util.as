// c 2024-06-19
// m 2024-06-19

void HoverTooltip(const string &in msg) {
    if (!UI::IsItemHovered())
        return;

    UI::BeginTooltip();
        UI::Text(msg);
    UI::EndTooltip();
}

string IntToHex(const int64 i, const bool pre = true) {
    return (pre ? "0x" : "") + Text::Format("%llX", i);
}

MemoryBuffer@ ReadFile(const string &in path) {
    if (!IO::FileExists(path)) {
        warn("file not found: " + path);
        return null;
    }

    IO::File file(path, IO::FileMode::Read);
    MemoryBuffer@ buf = file.Read(file.Size());
    file.Close();

    return buf;
}

string Zpad(const string &in hex, const uint length) {
    if (uint(hex.Length) >= length)
        return hex;

    string res;

    for (uint i = hex.Length; i < length; i++)
        res += "0";

    return res + hex;
}
