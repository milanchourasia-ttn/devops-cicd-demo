import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const readProjectFile = (name) =>
  readFile(new URL(`../${name}`, import.meta.url), "utf8");

test("website contains the required deployment message", async () => {
  const html = await readProjectFile("index.html");

  assert.match(html, /DevOps Training/);
  assert.match(html, /CI\/CD Deployment Successful/);
  assert.match(html, /Deployed automatically using GitHub Actions/);
  assert.match(html, /Version: 1\.0/);
});

test("local assets referenced by the page exist", async () => {
  const [html, css, javascript] = await Promise.all([
    readProjectFile("index.html"),
    readProjectFile("style.css"),
    readProjectFile("script.js"),
  ]);

  assert.match(html, /href="style\.css"/);
  assert.match(html, /src="script\.js"/);
  assert.ok(css.length > 100);
  assert.ok(javascript.length > 20);
});

test("page includes responsive metadata", async () => {
  const html = await readProjectFile("index.html");

  assert.match(html, /name="viewport"/);
  assert.match(html, /<html lang="en">/);
});
