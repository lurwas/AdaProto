#!/usr/bin/env bash
set -euo pipefail

cat > /tmp/protobuf_compat_smoke.adb <<'ADA'
with Ada.Text_IO;
with Protobuf;

procedure Protobuf_Compat_Smoke is
   B : Protobuf.Message_Buffer;
   V : Protobuf.Parsed_Field_Vectors.Vector;
begin
   Protobuf.Add_Int32 (B, 1, 7);
   V := Protobuf.Parse_From_String (Protobuf.To_String (B));
   Ada.Text_IO.Put_Line (Integer'Image (Integer (V.Length)));
end Protobuf_Compat_Smoke;
ADA

found=0
for driver in /usr/bin/gnatmake-*; do
  if [[ -x "$driver" ]]; then
    found=1
    ver="${driver##*-}"
    echo "testing GNAT ${ver} via ${driver}"
    "$driver" -gnat2012 -I./src /tmp/protobuf_compat_smoke.adb -o "/tmp/protobuf_compat_smoke_${ver}" >/dev/null
    "/tmp/protobuf_compat_smoke_${ver}" >/dev/null
  fi
done

if [[ "$found" -eq 0 ]]; then
  echo "no versioned gnatmake-* drivers found; testing default gnatmake"
  gnatmake -gnat2012 -I./src /tmp/protobuf_compat_smoke.adb -o /tmp/protobuf_compat_smoke_default >/dev/null
  /tmp/protobuf_compat_smoke_default >/dev/null
fi

echo "compiler compatibility smoke passed"
