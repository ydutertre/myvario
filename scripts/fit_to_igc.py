#!/usr/bin/env python3
"""Convert a Garmin FIT activity recorded by My Vario to a simple IGC file.

This produces a useful IGC track for analysis/upload workflows. It is not an
FAI-valid logger file and does not contain an approved-recorder security record.
"""

from __future__ import annotations

import argparse
import datetime as dt
import pathlib
import struct
import sys
from dataclasses import dataclass, field
from typing import Any


FIT_EPOCH = dt.datetime(1989, 12, 31, tzinfo=dt.timezone.utc)
SEMICIRCLE_SCALE = 180.0 / 2147483648.0
MYVARIO_BARO_FIELD = "BarometricAltitude"


BASE_TYPES: dict[int, tuple[str, int | None, Any]] = {
    0x00: ("enum", None, None),
    0x01: ("sint8", 1, -128),
    0x02: ("uint8", 1, 0xFF),
    0x83: ("sint16", 2, -32768),
    0x84: ("uint16", 2, 0xFFFF),
    0x85: ("sint32", 4, -2147483648),
    0x86: ("uint32", 4, 0xFFFFFFFF),
    0x07: ("string", None, None),
    0x88: ("float32", 4, float("nan")),
    0x89: ("float64", 8, float("nan")),
    0x0A: ("uint8z", 1, 0x00),
    0x8B: ("uint16z", 2, 0x0000),
    0x8C: ("uint32z", 4, 0x00000000),
    0x0D: ("byte", 1, None),
    0x8E: ("sint64", 8, -9223372036854775808),
    0x8F: ("uint64", 8, 0xFFFFFFFFFFFFFFFF),
    0x90: ("uint64z", 8, 0x0000000000000000),
}


@dataclass
class FieldDef:
    number: int
    size: int
    base_type: int


@dataclass
class DeveloperFieldDef:
    number: int
    size: int
    developer_index: int


@dataclass
class MessageDef:
    global_number: int
    endian: str
    fields: list[FieldDef] = field(default_factory=list)
    developer_fields: list[DeveloperFieldDef] = field(default_factory=list)


@dataclass
class DeveloperFieldDescription:
    name: str = ""
    units: str = ""
    scale: float | None = None
    offset: float | None = None


@dataclass
class TrackPoint:
    time: dt.datetime
    lat: float
    lon: float
    gps_altitude_m: int | None
    baro_altitude_m: int | None


def decode_value(raw: bytes, base_type: int, endian: str) -> Any:
    type_name, unit_size, invalid = BASE_TYPES.get(base_type, ("byte", 1, None))
    if not raw:
        return None
    if type_name == "string":
        return raw.split(b"\x00", 1)[0].decode("utf-8", "replace").strip()
    if unit_size is None or len(raw) % unit_size != 0:
        return raw

    values = []
    for offset in range(0, len(raw), unit_size):
        chunk = raw[offset : offset + unit_size]
        if type_name in ("enum", "uint8", "uint8z", "byte"):
            value = chunk[0]
        elif type_name == "sint8":
            value = struct.unpack("b", chunk)[0]
        else:
            fmt = {
                "sint16": "h",
                "uint16": "H",
                "sint32": "i",
                "uint32": "I",
                "float32": "f",
                "float64": "d",
                "uint16z": "H",
                "uint32z": "I",
                "sint64": "q",
                "uint64": "Q",
                "uint64z": "Q",
            }[type_name]
            value = struct.unpack(endian + fmt, chunk)[0]
        values.append(None if invalid is not None and value == invalid else value)

    return values[0] if len(values) == 1 else values


def apply_scale(value: Any, scale: Any, offset: Any) -> Any:
    if value is None:
        return None
    try:
        value = float(value)
        if scale not in (None, 0):
            value /= float(scale)
        if offset is not None:
            value -= float(offset)
        return value
    except (TypeError, ValueError):
        return value


def parse_fit(path: pathlib.Path) -> list[TrackPoint]:
    data = path.read_bytes()
    if len(data) < 14:
        raise ValueError("FIT file is too short")

    header_size = data[0]
    if header_size not in (12, 14) or data[8:12] != b".FIT":
        raise ValueError("Input does not look like a FIT file")

    data_size = struct.unpack_from("<I", data, 4)[0]
    offset = header_size
    end = header_size + data_size
    if end > len(data):
        raise ValueError("FIT data size exceeds file length")

    definitions: dict[int, MessageDef] = {}
    developer_descriptions: dict[tuple[int, int], DeveloperFieldDescription] = {}
    records: list[tuple[dict[int, Any], dict[tuple[int, int], Any]]] = []

    while offset < end:
        record_header = data[offset]
        offset += 1
        if record_header & 0x80:
            raise ValueError("Compressed timestamp FIT records are not supported")

        local_message = record_header & 0x0F
        is_definition = bool(record_header & 0x40)
        has_developer_fields = bool(record_header & 0x20)

        if is_definition:
            offset += 1  # reserved
            architecture = data[offset]
            offset += 1
            endian = ">" if architecture else "<"
            global_number = struct.unpack_from(endian + "H", data, offset)[0]
            offset += 2
            field_count = data[offset]
            offset += 1
            fields = []
            for _ in range(field_count):
                fields.append(FieldDef(data[offset], data[offset + 1], data[offset + 2]))
                offset += 3
            developer_fields = []
            if has_developer_fields:
                developer_field_count = data[offset]
                offset += 1
                for _ in range(developer_field_count):
                    developer_fields.append(
                        DeveloperFieldDef(data[offset], data[offset + 1], data[offset + 2])
                    )
                    offset += 3
            definitions[local_message] = MessageDef(
                global_number, endian, fields, developer_fields
            )
            continue

        definition = definitions.get(local_message)
        if definition is None:
            raise ValueError(f"Data message {local_message} has no definition")

        values: dict[int, Any] = {}
        for field_def in definition.fields:
            raw = data[offset : offset + field_def.size]
            offset += field_def.size
            values[field_def.number] = decode_value(raw, field_def.base_type, definition.endian)

        developer_values: dict[tuple[int, int], Any] = {}
        for field_def in definition.developer_fields:
            raw = data[offset : offset + field_def.size]
            offset += field_def.size
            developer_values[(field_def.developer_index, field_def.number)] = decode_value(
                raw, 0x88 if field_def.size == 4 else 0x0D, definition.endian
            )

        if definition.global_number == 206:
            developer_index = values.get(0)
            field_number = values.get(1)
            if developer_index is not None and field_number is not None:
                developer_descriptions[(developer_index, field_number)] = (
                    DeveloperFieldDescription(
                        name=str(values.get(3) or ""),
                        units=str(values.get(8) or ""),
                        scale=values.get(6),
                        offset=values.get(7),
                    )
                )
        elif definition.global_number == 20:
            records.append((values, developer_values))

    return build_track(records, developer_descriptions)


def build_track(
    records: list[tuple[dict[int, Any], dict[tuple[int, int], Any]]],
    developer_descriptions: dict[tuple[int, int], DeveloperFieldDescription],
) -> list[TrackPoint]:
    track: list[TrackPoint] = []
    for values, developer_values in records:
        timestamp = values.get(253)
        semicircle_lat = values.get(0)
        semicircle_lon = values.get(1)
        if timestamp is None or semicircle_lat is None or semicircle_lon is None:
            continue

        gps_altitude = values.get(2)
        enhanced_altitude = values.get(78)
        if enhanced_altitude is not None:
            gps_altitude_m = round(float(enhanced_altitude) / 5.0 - 500.0)
        elif gps_altitude is not None:
            gps_altitude_m = round(float(gps_altitude) / 5.0 - 500.0)
        else:
            gps_altitude_m = None

        baro_altitude_m = None
        for key, raw_value in developer_values.items():
            description = developer_descriptions.get(key)
            if description is None or description.name != MYVARIO_BARO_FIELD:
                continue
            value = apply_scale(raw_value, description.scale, description.offset)
            if value is not None:
                baro_altitude_m = round(float(value))
                break

        time = FIT_EPOCH + dt.timedelta(seconds=int(timestamp))
        track.append(
            TrackPoint(
                time=time,
                lat=float(semicircle_lat) * SEMICIRCLE_SCALE,
                lon=float(semicircle_lon) * SEMICIRCLE_SCALE,
                gps_altitude_m=gps_altitude_m,
                baro_altitude_m=baro_altitude_m,
            )
        )
    return track


def format_lat(lat: float) -> str:
    hemisphere = "N" if lat >= 0 else "S"
    total = int(round(abs(lat) * 60_000.0))
    degrees = total // 60_000
    minutes = total % 60_000
    return f"{degrees:02d}{minutes // 1000:02d}{minutes % 1000:03d}{hemisphere}"


def format_lon(lon: float) -> str:
    hemisphere = "E" if lon >= 0 else "W"
    total = int(round(abs(lon) * 60_000.0))
    degrees = total // 60_000
    minutes = total % 60_000
    return f"{degrees:03d}{minutes // 1000:02d}{minutes % 1000:03d}{hemisphere}"


def clamp_altitude(altitude_m: int | None) -> int:
    if altitude_m is None:
        return 0
    return max(-999, min(99999, altitude_m))


def write_igc(
    path: pathlib.Path,
    track: list[TrackPoint],
    pilot: str,
    glider_type: str,
    glider_id: str,
) -> None:
    if not track:
        raise ValueError("No timestamped position records found in FIT file")

    date = track[0].time
    lines = [
        "AXXXMYVARIO",
        f"HFDTE{date:%d%m%y}",
        f"HFPLTPILOTINCHARGE:{pilot}",
        f"HFGTYGLIDERTYPE:{glider_type}",
        f"HFGIDGLIDERID:{glider_id}",
        "HFFTYFRTYPE:Garmin Connect IQ,My Vario",
        "HFGPS:Garmin watch GPS",
        "HFPRSPRESSALTSENSOR:My Vario barometric altitude developer field",
        "HFDTM100GPSDATUM:WGS-1984",
        "HFCIDCOMPETITIONID:",
        "HFCCLCOMPETITIONCLASS:",
    ]

    for point in track:
        pressure_altitude = clamp_altitude(
            point.baro_altitude_m
            if point.baro_altitude_m is not None
            else point.gps_altitude_m
        )
        gps_altitude = clamp_altitude(
            point.gps_altitude_m
            if point.gps_altitude_m is not None
            else point.baro_altitude_m
        )
        lines.append(
            f"B{point.time:%H%M%S}{format_lat(point.lat)}{format_lon(point.lon)}A"
            f"{pressure_altitude:05d}{gps_altitude:05d}"
        )

    lines.extend(
        [
            "LXXXGenerated by My Vario FIT to IGC converter",
            "LXXXNot FAI-valid: no approved-recorder security G record",
            "",
        ]
    )
    path.write_text("\r\n".join(lines), encoding="ascii")


def default_output(input_path: pathlib.Path) -> pathlib.Path:
    return input_path.with_suffix(".igc")


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert a My Vario Garmin FIT activity to a simple IGC file."
    )
    parser.add_argument("fit_file", type=pathlib.Path)
    parser.add_argument("-o", "--output", type=pathlib.Path)
    parser.add_argument("--pilot", default="")
    parser.add_argument("--glider-type", default="")
    parser.add_argument("--glider-id", default="")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    output = args.output or default_output(args.fit_file)
    try:
        track = parse_fit(args.fit_file)
        write_igc(output, track, args.pilot, args.glider_type, args.glider_id)
    except (OSError, ValueError, struct.error) as exc:
        print(f"fit_to_igc: {exc}", file=sys.stderr)
        return 1

    baro_count = sum(1 for point in track if point.baro_altitude_m is not None)
    print(f"Wrote {output} ({len(track)} fixes, {baro_count} with barometric altitude)")
    if baro_count == 0:
        print(
            "Warning: no My Vario BarometricAltitude developer field was found; "
            "GPS altitude was used.",
            file=sys.stderr,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
