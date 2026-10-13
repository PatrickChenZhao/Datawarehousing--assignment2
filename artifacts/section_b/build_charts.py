#!/usr/bin/env python3
"""Build Q6 and Q7 charts from Oracle-exported CSV files only.

The script uses only the Python standard library and macOS sips for PNG
rendering. It contains no embedded sales values and rejects missing, empty,
malformed or duplicate-grain inputs.
"""

from __future__ import annotations

import csv
import hashlib
import html
import json
import math
import shutil
import subprocess
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
from pathlib import Path
from zoneinfo import ZoneInfo


SECTION_B_DIR = Path(__file__).resolve().parent
DATA_DIR = SECTION_B_DIR / "data"
CHART_DIR = SECTION_B_DIR / "charts"

Q6_INPUT = DATA_DIR / "q6_q1_promo_sales.csv"
Q6_FULL_INPUT = DATA_DIR / "q6_full_period_promo_sales.csv"
Q7_INPUT = DATA_DIR / "q7_monthly_product_category_sales.csv"
Q6_SVG = CHART_DIR / "q6_historical_q1_promotion_sales.svg"
Q7_SVG = CHART_DIR / "q7_monthly_product_category_sales.svg"
Q6_PNG = CHART_DIR / "q6_historical_q1_promotion_sales.png"
Q7_PNG = CHART_DIR / "q7_monthly_product_category_sales.png"
MANIFEST_OUTPUT = DATA_DIR / "chart_data_manifest.json"

WIDTH = 1600
HEIGHT = 900
MARGIN = {"top": 110, "right": 390, "bottom": 135, "left": 145}
PLOT_WIDTH = WIDTH - MARGIN["left"] - MARGIN["right"]
PLOT_HEIGHT = HEIGHT - MARGIN["top"] - MARGIN["bottom"]
COLORS = [
    "#0072B2",
    "#D55E00",
    "#009E73",
    "#CC79A7",
    "#E69F00",
    "#56B4E9",
    "#F0E442",
    "#000000",
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_csv(path: Path, expected_fields: list[str]) -> list[dict[str, str]]:
    if not path.exists():
        raise FileNotFoundError(
            f"Missing Oracle export: {path}. Run oracle_section_b_chart_extract.sql first."
        )
    with path.open("r", encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != expected_fields:
            raise ValueError(
                f"Unexpected fields in {path.name}: {reader.fieldnames}; "
                f"expected {expected_fields}."
            )
        rows = list(reader)
    if not rows:
        raise ValueError(f"Oracle export {path.name} contains no data rows.")
    return rows


def parse_sales(raw_value: str, source: str) -> Decimal:
    try:
        value = Decimal(raw_value)
    except InvalidOperation as exc:
        raise ValueError(f"Invalid TOTAL_SALES value {raw_value!r} in {source}.") from exc
    if value < 0:
        raise ValueError(f"Negative TOTAL_SALES value {raw_value!r} in {source}.")
    return value


def svg_text(
    x: float,
    y: float,
    text: str,
    *,
    size: int = 18,
    anchor: str = "start",
    weight: int = 400,
    transform: str = "",
) -> str:
    transform_attribute = f' transform="{transform}"' if transform else ""
    return (
        f'<text x="{x:.1f}" y="{y:.1f}" text-anchor="{anchor}" '
        f'font-size="{size}" font-weight="{weight}" fill="#222222"'
        f'{transform_attribute}>{html.escape(text)}</text>'
    )


def svg_document(title: str, description: str, body: list[str]) -> str:
    return "\n".join(
        [
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" '
            f'viewBox="0 0 {WIDTH} {HEIGHT}" role="img" aria-labelledby="title desc">',
            f'<title id="title">{html.escape(title)}</title>',
            f'<desc id="desc">{html.escape(description)}</desc>',
            f'<rect width="{WIDTH}" height="{HEIGHT}" fill="#FFFFFF"/>',
            '<g font-family="Arial, Helvetica, sans-serif">',
            *body,
            "</g>",
            "</svg>",
            "",
        ]
    )


def nice_ceiling(value: float) -> float:
    if value <= 0:
        return 1.0
    exponent = math.floor(math.log10(value))
    fraction = value / (10**exponent)
    if fraction <= 1:
        nice_fraction = 1
    elif fraction <= 2:
        nice_fraction = 2
    elif fraction <= 5:
        nice_fraction = 5
    else:
        nice_fraction = 10
    return nice_fraction * (10**exponent)


def money_millions(value: float) -> str:
    if value >= 100:
        return f"${value:,.0f}M"
    if value >= 10:
        return f"${value:,.1f}M"
    return f"${value:,.2f}M"


def add_y_axis(body: list[str], maximum: float) -> None:
    for index in range(6):
        value = maximum * index / 5
        y = MARGIN["top"] + PLOT_HEIGHT - (value / maximum) * PLOT_HEIGHT
        body.append(
            f'<line x1="{MARGIN["left"]}" y1="{y:.1f}" '
            f'x2="{MARGIN["left"] + PLOT_WIDTH}" y2="{y:.1f}" '
            'stroke="#D9D9D9" stroke-width="1"/>'
        )
        body.append(svg_text(MARGIN["left"] - 16, y + 6, money_millions(value), anchor="end"))
    body.append(
        f'<line x1="{MARGIN["left"]}" y1="{MARGIN["top"]}" '
        f'x2="{MARGIN["left"]}" y2="{MARGIN["top"] + PLOT_HEIGHT}" '
        'stroke="#333333" stroke-width="2"/>'
    )
    body.append(
        f'<line x1="{MARGIN["left"]}" y1="{MARGIN["top"] + PLOT_HEIGHT}" '
        f'x2="{MARGIN["left"] + PLOT_WIDTH}" y2="{MARGIN["top"] + PLOT_HEIGHT}" '
        'stroke="#333333" stroke-width="2"/>'
    )


def add_legend(body: list[str], categories: list[str], title: str) -> None:
    legend_x = MARGIN["left"] + PLOT_WIDTH + 55
    legend_y = MARGIN["top"] + 20
    body.append(svg_text(legend_x, legend_y, title, size=20, weight=700))
    for index, category in enumerate(categories):
        y = legend_y + 42 + index * 42
        color = COLORS[index % len(COLORS)]
        body.append(
            f'<rect x="{legend_x:.1f}" y="{y - 17:.1f}" width="24" height="14" '
            f'fill="{color}"/>'
        )
        body.append(svg_text(legend_x + 36, y - 4, category, size=17))


def render_png(svg_path: Path, png_path: Path) -> None:
    sips = shutil.which("sips")
    if sips is None:
        raise RuntimeError("sips is unavailable; the SVG was created but PNG rendering failed.")
    result = subprocess.run(
        [sips, "-s", "format", "png", str(svg_path), "--out", str(png_path)],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0 or not png_path.exists():
        raise RuntimeError(
            f"PNG rendering failed for {svg_path.name}: "
            f"{result.stderr.strip() or result.stdout.strip()}"
        )


def build_q6(rows: list[dict[str, str]]) -> dict[str, object]:
    values: dict[tuple[str, str], Decimal] = {}
    years: set[str] = set()
    categories: set[str] = set()
    for row in rows:
        year = row["CALENDAR_YEAR"].strip()
        category = row["PROMO_CATEGORY"].strip()
        if len(year) != 4 or not year.isdigit():
            raise ValueError(f"Invalid CALENDAR_YEAR {year!r} in {Q6_INPUT.name}.")
        if not category:
            raise ValueError(f"Blank PROMO_CATEGORY in {Q6_INPUT.name}.")
        key = (year, category)
        if key in values:
            raise ValueError(f"Duplicate Q6 grain {key} in {Q6_INPUT.name}.")
        values[key] = parse_sales(row["TOTAL_SALES"], Q6_INPUT.name)
        years.add(year)
        categories.add(category)

    ordered_years = sorted(years)
    ordered_categories = sorted(categories)
    values_millions = {key: float(value) / 1_000_000 for key, value in values.items()}
    maximum = nice_ceiling(max(values_millions.values()))
    body: list[str] = []
    body.append(
        svg_text(
            WIDTH / 2,
            54,
            "Historical First-Quarter Sales by Promotion Category (1998-2001)",
            size=30,
            anchor="middle",
            weight=700,
        )
    )
    body.append(
        svg_text(
            WIDTH / 2,
            86,
            "Aggregated amount_sold from Promotion_Analysis_mv",
            size=17,
            anchor="middle",
        )
    )
    add_y_axis(body, maximum)

    group_width = PLOT_WIDTH / len(ordered_years)
    bar_gap = 5
    usable_width = group_width * 0.82
    bar_width = max(
        5,
        (usable_width - bar_gap * (len(ordered_categories) - 1))
        / len(ordered_categories),
    )
    for year_index, year in enumerate(ordered_years):
        group_start = (
            MARGIN["left"]
            + year_index * group_width
            + (group_width - usable_width) / 2
        )
        for category_index, category in enumerate(ordered_categories):
            value = values_millions.get((year, category), 0.0)
            height = (value / maximum) * PLOT_HEIGHT
            x = group_start + category_index * (bar_width + bar_gap)
            y = MARGIN["top"] + PLOT_HEIGHT - height
            color = COLORS[category_index % len(COLORS)]
            body.append(
                f'<rect x="{x:.1f}" y="{y:.1f}" width="{bar_width:.1f}" '
                f'height="{height:.1f}" fill="{color}"><title>'
                f'{html.escape(year)} - {html.escape(category)}: '
                f'{html.escape(money_millions(value))}</title></rect>'
            )
            if value > 0:
                label_y = max(MARGIN["top"] + 18, y - 9)
                body.append(
                    svg_text(
                        x + bar_width / 2,
                        label_y,
                        money_millions(value),
                        size=13,
                        anchor="middle",
                        weight=700,
                    )
                )
        center = MARGIN["left"] + (year_index + 0.5) * group_width
        body.append(svg_text(center, MARGIN["top"] + PLOT_HEIGHT + 36, year, anchor="middle"))

    body.append(
        svg_text(
            MARGIN["left"] + PLOT_WIDTH / 2,
            HEIGHT - 28,
            "Calendar year",
            size=20,
            anchor="middle",
            weight=700,
        )
    )
    body.append(
        svg_text(
            34,
            MARGIN["top"] + PLOT_HEIGHT / 2,
            "Total sales (USD millions)",
            size=20,
            anchor="middle",
            weight=700,
            transform=f"rotate(-90 34 {MARGIN['top'] + PLOT_HEIGHT / 2:.1f})",
        )
    )
    add_legend(body, ordered_categories, "Promotion category")
    Q6_SVG.write_text(
        svg_document(
            "Historical first-quarter sales by promotion category",
            "Grouped bars compare each promotion category across calendar years 1998 to 2001.",
            body,
        ),
        encoding="utf-8",
    )
    render_png(Q6_SVG, Q6_PNG)
    return {
        "row_count": len(rows),
        "fields": ["CALENDAR_YEAR", "PROMO_CATEGORY", "TOTAL_SALES"],
        "period_min": ordered_years[0],
        "period_max": ordered_years[-1],
        "category_count": len(ordered_categories),
    }


def validate_q6_full_period(rows: list[dict[str, str]]) -> dict[str, object]:
    categories: set[str] = set()
    for row in rows:
        category = row["PROMO_CATEGORY"].strip()
        if not category:
            raise ValueError(f"Blank PROMO_CATEGORY in {Q6_FULL_INPUT.name}.")
        if category in categories:
            raise ValueError(
                f"Duplicate promotion category {category!r} in {Q6_FULL_INPUT.name}."
            )
        parse_sales(row["TOTAL_SALES"], Q6_FULL_INPUT.name)
        categories.add(category)
    return {
        "row_count": len(rows),
        "fields": ["PROMO_CATEGORY", "TOTAL_SALES"],
        "category_count": len(categories),
    }


def validate_chart_rows(
    q6_rows: list[dict[str, str]],
    q7_rows: list[dict[str, str]],
) -> None:
    q6_keys: set[tuple[str, str]] = set()
    for row in q6_rows:
        year = row["CALENDAR_YEAR"].strip()
        category = row["PROMO_CATEGORY"].strip()
        if len(year) != 4 or not year.isdigit() or not category:
            raise ValueError(f"Invalid Q6 key {(year, category)} in {Q6_INPUT.name}.")
        key = (year, category)
        if key in q6_keys:
            raise ValueError(f"Duplicate Q6 grain {key} in {Q6_INPUT.name}.")
        parse_sales(row["TOTAL_SALES"], Q6_INPUT.name)
        q6_keys.add(key)

    q7_keys: set[tuple[str, str]] = set()
    for row in q7_rows:
        raw_month = row["CALENDAR_MONTH_DESC"].strip()
        category = row["PROD_CATEGORY"].strip()
        try:
            datetime.strptime(raw_month, "%Y-%m")
        except ValueError as exc:
            raise ValueError(
                f"Invalid CALENDAR_MONTH_DESC {raw_month!r} in {Q7_INPUT.name}."
            ) from exc
        if not category:
            raise ValueError(f"Blank PROD_CATEGORY in {Q7_INPUT.name}.")
        key = (raw_month, category)
        if key in q7_keys:
            raise ValueError(f"Duplicate Q7 grain {key} in {Q7_INPUT.name}.")
        parse_sales(row["TOTAL_SALES"], Q7_INPUT.name)
        q7_keys.add(key)


def build_q7(rows: list[dict[str, str]]) -> dict[str, object]:
    values: dict[tuple[datetime, str], Decimal] = {}
    months: set[datetime] = set()
    categories: set[str] = set()
    for row in rows:
        raw_month = row["CALENDAR_MONTH_DESC"].strip()
        category = row["PROD_CATEGORY"].strip()
        try:
            month = datetime.strptime(raw_month, "%Y-%m")
        except ValueError as exc:
            raise ValueError(
                f"Invalid CALENDAR_MONTH_DESC {raw_month!r} in {Q7_INPUT.name}."
            ) from exc
        if not category:
            raise ValueError(f"Blank PROD_CATEGORY in {Q7_INPUT.name}.")
        key = (month, category)
        if key in values:
            raise ValueError(
                f"Duplicate Q7 grain {(raw_month, category)} in {Q7_INPUT.name}."
            )
        values[key] = parse_sales(row["TOTAL_SALES"], Q7_INPUT.name)
        months.add(month)
        categories.add(category)

    ordered_months = sorted(months)
    ordered_categories = sorted(categories)
    values_millions = {key: float(value) / 1_000_000 for key, value in values.items()}
    maximum = nice_ceiling(max(values_millions.values()))
    body: list[str] = []
    body.append(
        svg_text(
            WIDTH / 2,
            54,
            "Monthly Sales Trend by Product Category (1998-2001)",
            size=30,
            anchor="middle",
            weight=700,
        )
    )
    body.append(
        svg_text(
            WIDTH / 2,
            86,
            "Aggregated amount_sold from Promotion_Analysis_mv",
            size=17,
            anchor="middle",
        )
    )
    add_y_axis(body, maximum)

    denominator = max(1, len(ordered_months) - 1)
    for category_index, category in enumerate(ordered_categories):
        points: list[tuple[float, float, float, datetime]] = []
        for month_index, month in enumerate(ordered_months):
            value = values_millions.get((month, category), 0.0)
            x = MARGIN["left"] + (month_index / denominator) * PLOT_WIDTH
            y = MARGIN["top"] + PLOT_HEIGHT - (value / maximum) * PLOT_HEIGHT
            points.append((x, y, value, month))
        color = COLORS[category_index % len(COLORS)]
        point_string = " ".join(f"{x:.1f},{y:.1f}" for x, y, _, _ in points)
        body.append(
            f'<polyline points="{point_string}" fill="none" stroke="{color}" '
            'stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>'
        )
        for x, y, value, month in points:
            body.append(
                f'<circle cx="{x:.1f}" cy="{y:.1f}" r="4.5" fill="{color}">'
                f'<title>{html.escape(month.strftime("%Y-%m"))} - '
                f'{html.escape(category)}: {html.escape(money_millions(value))}'
                '</title></circle>'
            )

    tick_step = 3 if len(ordered_months) <= 48 else 6
    for month_index in range(0, len(ordered_months), tick_step):
        month = ordered_months[month_index]
        x = MARGIN["left"] + (month_index / denominator) * PLOT_WIDTH
        y = MARGIN["top"] + PLOT_HEIGHT + 30
        label = month.strftime("%Y-%m")
        body.append(
            svg_text(
                x,
                y,
                label,
                size=16,
                anchor="end",
                transform=f"rotate(-45 {x:.1f} {y:.1f})",
            )
        )
    body.append(
        svg_text(
            MARGIN["left"] + PLOT_WIDTH / 2,
            HEIGHT - 24,
            "Calendar month",
            size=20,
            anchor="middle",
            weight=700,
        )
    )
    body.append(
        svg_text(
            34,
            MARGIN["top"] + PLOT_HEIGHT / 2,
            "Total sales (USD millions)",
            size=20,
            anchor="middle",
            weight=700,
            transform=f"rotate(-90 34 {MARGIN['top'] + PLOT_HEIGHT / 2:.1f})",
        )
    )
    add_legend(body, ordered_categories, "Product category")
    Q7_SVG.write_text(
        svg_document(
            "Monthly sales trend by product category",
            "Lines compare monthly product-category sales from January 1998 to December 2001.",
            body,
        ),
        encoding="utf-8",
    )
    render_png(Q7_SVG, Q7_PNG)
    return {
        "row_count": len(rows),
        "fields": ["CALENDAR_MONTH_DESC", "PROD_CATEGORY", "TOTAL_SALES"],
        "period_min": ordered_months[0].strftime("%Y-%m"),
        "period_max": ordered_months[-1].strftime("%Y-%m"),
        "category_count": len(ordered_categories),
    }


def main() -> None:
    CHART_DIR.mkdir(parents=True, exist_ok=True)
    q6_rows = load_csv(Q6_INPUT, ["CALENDAR_YEAR", "PROMO_CATEGORY", "TOTAL_SALES"])
    q6_full_rows = load_csv(Q6_FULL_INPUT, ["PROMO_CATEGORY", "TOTAL_SALES"])
    q7_rows = load_csv(
        Q7_INPUT,
        ["CALENDAR_MONTH_DESC", "PROD_CATEGORY", "TOTAL_SALES"],
    )

    q6_full_metadata = validate_q6_full_period(q6_full_rows)
    validate_chart_rows(q6_rows, q7_rows)
    q6_metadata = build_q6(q6_rows)
    q7_metadata = build_q7(q7_rows)
    manifest = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "generated_at_pacific_auckland": datetime.now(
            ZoneInfo("Pacific/Auckland")
        ).isoformat(),
        "inputs": {
            Q6_INPUT.name: {**q6_metadata, "sha256": sha256(Q6_INPUT)},
            Q6_FULL_INPUT.name: {
                **q6_full_metadata,
                "sha256": sha256(Q6_FULL_INPUT),
            },
            Q7_INPUT.name: {**q7_metadata, "sha256": sha256(Q7_INPUT)},
        },
        "outputs": [Q6_SVG.name, Q6_PNG.name, Q7_SVG.name, Q7_PNG.name],
    }
    MANIFEST_OUTPUT.write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
