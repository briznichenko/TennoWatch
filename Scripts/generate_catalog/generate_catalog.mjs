import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { fetchEndpoint } from "./warframe_exports.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUTPUT_PATH = process.env.CATALOG_OUTPUT_PATH
    ?? path.join(__dirname, "..", "..", "TennoWatch", "Resources", "masterycatalog.json");

const FOUNDERS_NAMES = new Set(["Excalibur Prime", "Skana Prime", "Lato Prime"]);
const EXCLUDED_UNIQUE_NAMES = new Set([
    "/Lotus/Weapons/Tenno/ThrowingWeapons/U18ThrowingKnives/U18throwingknives"
]);

const GILDED_CATEGORIES = new Set(["KITGUN", "ZAW", "AMP", "MOA", "HOUND"]);
const DOUBLE_POINTS_CATEGORIES = new Set([
    "Suits", "SpaceSuits", "MechSuits", "Sentinels", "KubrowPets",
    "MOA", "HOUND", "KDRIVE", "RAILJACK", "SpecialItems"
]);
const WEAPON_LIKE_CATEGORIES = new Set([
    "LongGuns", "Pistols", "Melee", "SpaceGuns", "SpaceMelee",
    "SentinelWeapons", "OperatorAmps", "ZAW", "KITGUN", "AMP"
]);

const DIRECT_CATEGORY_MAP = {
    Suits: "Suits",
    SpaceSuits: "SpaceSuits",
    MechSuits: "MechSuits",
    Sentinels: "Sentinels",
    KubrowPets: "KubrowPets",
    LongGuns: "LongGuns",
    Melee: "Melee",
    SpaceGuns: "SpaceGuns",
    SpaceMelee: "SpaceMelee",
    SentinelWeapons: "SentinelWeapons",
    OperatorAmps: "OperatorAmps"
};

function categorizePistol(uniqueName) {
    if (uniqueName.includes("ModularMelee")) {
        return uniqueName.includes("Tip") && !uniqueName.includes("PvPVariant") ? "ZAW" : null;
    }
    if (uniqueName.includes("ModularPrimary") || uniqueName.includes("ModularSecondary") || uniqueName.includes("InfKitGun")) {
        return uniqueName.includes("Barrel") ? "KITGUN" : null;
    }
    if (uniqueName.includes("OperatorAmplifiers")) {
        return uniqueName.includes("Barrel") ? "AMP" : null;
    }
    if (uniqueName.includes("Hoverboard")) {
        return uniqueName.includes("Deck") ? "KDRIVE" : null;
    }
    if (uniqueName.includes("MoaPets")) {
        return uniqueName.includes("MoaPetHead") ? "MOA" : null;
    }
    if (uniqueName.includes("ZanukaPets")) {
        return uniqueName.includes("ZanukaPetPartHead") ? "HOUND" : null;
    }
    return "Pistols";
}

function categorizeItem(item, sourceEndpoint) {
    if (item.productCategory === "Pistols") {
        const bucket = categorizePistol(item.uniqueName);
        if (bucket === null) return null;
        if (bucket === "Pistols") return item.slot === 0 ? "Pistols" : null;
        return bucket;
    }
    if (item.productCategory === "SpecialItems") {
        return sourceEndpoint === "Sentinels" ? "SpecialItems" : null;
    }
    return DIRECT_CATEGORY_MAP[item.productCategory] ?? null;
}

function computeFields(category, item) {
    let maxRank;
    if (category === "MechSuits") {
        maxRank = 40;
    } else if (WEAPON_LIKE_CATEGORIES.has(category)) {
        maxRank = item.maxLevelCap ?? 30;
    } else {
        maxRank = 30;
    }

    const pointsPerRank = DOUBLE_POINTS_CATEGORIES.has(category) ? 200 : 100;
    const xpPerRankSq = pointsPerRank * 5;
    const requiresGilding = GILDED_CATEGORIES.has(category);
    return { maxRank, pointsPerRank, xpPerRankSq, requiresGilding };
}

async function fetchAllItems() {
    const endpointNames = ["Warframes", "Weapons", "Sentinels"];
    const fetched = await Promise.all(endpointNames.map(name => fetchEndpoint(name)));

    const gameVersionParts = [];
    const items = [];
    fetched.forEach(({ data, filename }, index) => {
        gameVersionParts.push(filename);
        const key = `Export${endpointNames[index]}`;
        for (const rawItem of data[key]) {
            items.push({ raw: rawItem, source: endpointNames[index] });
        }
    });
    return { items, gameVersion: gameVersionParts.join(",") };
}

async function fetchIconLookup() {
    const { data } = await fetchEndpoint("Manifest");
    const lookup = new Map();
    for (const entry of data.Manifest) {
        lookup.set(entry.uniqueName, entry.textureLocation);
    }
    return lookup;
}

function buildManualItems() {
    return [
        {
            uniqueName: "/Lotus/Types/Game/CrewShip/RailJack/DefaultHarness",
            name: "Plexus",
            category: "RAILJACK",
            icon: null
        }
    ];
}

async function main() {
    const [{ items, gameVersion }, iconLookup] = await Promise.all([fetchAllItems(), fetchIconLookup()]);

    const catalogItemsByUniqueName = new Map();

    for (const { raw, source } of items) {
        const category = categorizeItem(raw, source);
        if (!category) continue;
        if (catalogItemsByUniqueName.has(raw.uniqueName)) continue;

        const { maxRank, pointsPerRank, xpPerRankSq, requiresGilding } = computeFields(category, raw);
        const obtainable = !FOUNDERS_NAMES.has(raw.name) && !EXCLUDED_UNIQUE_NAMES.has(raw.uniqueName);

        catalogItemsByUniqueName.set(raw.uniqueName, {
            uniqueName: raw.uniqueName,
            name: raw.name,
            category,
            maxRank,
            pointsPerRank,
            xpPerRankSq,
            icon: iconLookup.get(raw.uniqueName) ?? null,
            obtainable,
            requiresGilding
        });
    }

    const catalogItems = Array.from(catalogItemsByUniqueName.values());

    for (const manual of buildManualItems()) {
        const { maxRank, pointsPerRank, xpPerRankSq, requiresGilding } = computeFields(manual.category, {});
        catalogItems.push({
            uniqueName: manual.uniqueName,
            name: manual.name,
            category: manual.category,
            maxRank,
            pointsPerRank,
            xpPerRankSq,
            icon: iconLookup.get(manual.uniqueName) ?? manual.icon,
            obtainable: true,
            requiresGilding
        });
    }

    catalogItems.sort((a, b) => a.uniqueName.localeCompare(b.uniqueName));

    const existing = JSON.parse(fs.readFileSync(OUTPUT_PATH, "utf-8"));

    const totalMasteryMax = catalogItems.reduce((sum, it) => sum + it.maxRank * it.pointsPerRank, 0)
        + sumNonItemSources(existing.nonItemSources);
    const obtainableMasteryMax = catalogItems.filter(it => it.obtainable).reduce((sum, it) => sum + it.maxRank * it.pointsPerRank, 0)
        + sumNonItemSources(existing.nonItemSources);

    const output = {
        schemaVersion: existing.schemaVersion,
        gameVersion,
        generatedAt: new Date().toISOString().replace(/\.\d{3}Z$/, "Z"),
        totalMasteryMax,
        obtainableMasteryMax,
        items: catalogItems,
        nonItemSources: existing.nonItemSources
    };

    fs.writeFileSync(OUTPUT_PATH, JSON.stringify(output, null, 2) + "\n");
    console.log(`Wrote ${catalogItems.length} items to ${OUTPUT_PATH}`);
    console.log(`totalMasteryMax: ${totalMasteryMax}, obtainableMasteryMax: ${obtainableMasteryMax}`);
}

function sumNonItemSources(nonItemSources) {
    return Object.values(nonItemSources).reduce(
        (sum, sources) => sum + sources.reduce((s, x) => s + x.mastery, 0),
        0
    );
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});
