import { cp, mkdir, rm } from "node:fs/promises";
import { resolve } from "node:path";

const projectRoot = resolve(import.meta.dirname, "..");
const outputDirectory = resolve(projectRoot, "dist");
const siteFiles = ["index.html", "styles.css", "script.js"];

await rm(outputDirectory, { force: true, recursive: true });
await mkdir(outputDirectory, { recursive: true });

await Promise.all(
  siteFiles.map((file) =>
    cp(resolve(projectRoot, file), resolve(outputDirectory, file)),
  ),
);

console.log(`Packaged ${siteFiles.length} files in dist/`);
