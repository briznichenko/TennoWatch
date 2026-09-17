import fetch from "node-fetch";
import lzma from "lzma";

const CONTENT_URL = "https://content.warframe.com";

function decompressLZMA(buffer) {
    return new Promise((resolve, reject) => {
        lzma.decompress(buffer, (result, error) => {
            if (error) reject(error);
            else resolve(result);
        });
    });
}

function parseDamagedJSON(json) {
    return JSON.parse(json.replace(/\\\"/g, "'").replace(/\n|\r|\\/g, ""));
}

let endpointsPromise;

async function fetchEndpoints() {
    const response = await fetch(`${CONTENT_URL}/PublicExport/index_en.txt.lzma`);
    if (!response.ok) {
        throw new Error(`Failed to fetch endpoints: ${response.status} ${response.statusText}`);
    }
    const buffer = Buffer.from(await response.arrayBuffer());
    const text = await decompressLZMA(buffer);
    return text.split("\n").map(line => line.trim()).filter(Boolean);
}

export async function fetchEndpoint(endpoint) {
    if (!endpointsPromise) {
        endpointsPromise = fetchEndpoints();
    }
    const endpoints = await endpointsPromise;
    const filename = endpoints.find(e => e.startsWith(`Export${endpoint}`));
    if (!filename) {
        throw new Error(`No manifest entry found for Export${endpoint}`);
    }
    const response = await fetch(`${CONTENT_URL}/PublicExport/Manifest/${filename}`);
    if (!response.ok) {
        throw new Error(`Failed to fetch ${filename}: ${response.status} ${response.statusText}`);
    }
    const text = await response.text();
    return { data: parseDamagedJSON(text), filename };
}
