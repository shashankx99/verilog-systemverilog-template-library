"use strict";

// Your public GitHub repository.
const RAW_BASE =
  "https://raw.githubusercontent.com/" +
  "shashankx99/verilog-systemverilog-template-library/main/";

// These names match your existing files.
// The number and extension are added automatically.
const templateNames = [
  ["basic_gates", "Basic Logic Gates"],
  ["half_adder", "Half Adder"],
  ["full_adder", "Full Adder"],
  ["ripple_carry_adder", "Ripple Carry Adder"],
  ["adder_subtractor", "Adder Subtractor"],
  ["mux_2to1", "2-to-1 Multiplexer"],
  ["mux_4to1", "4-to-1 Multiplexer"],
  ["demux_1to4", "1-to-4 Demultiplexer"],
  ["decoder_2to4", "2-to-4 Decoder"],
  ["priority_encoder_4to2", "4-to-2 Priority Encoder"],
  ["magnitude_comparator", "Magnitude Comparator"],
  ["binary_to_gray", "Binary to Gray Converter"],
  ["gray_to_binary", "Gray to Binary Converter"],
  ["parity_generator_checker", "Parity Generator and Checker"],
  ["basic_alu", "Basic ALU"],
  ["d_latch", "D Latch"],
  ["d_flip_flop", "D Flip-Flop"],
  ["enabled_register", "Enabled Register"],
  ["t_flip_flop", "T Flip-Flop"],
  ["jk_flip_flop", "JK Flip-Flop"],
  ["up_counter", "Up Counter"],
  ["down_counter", "Down Counter"],
  ["up_down_counter", "Up Down Counter"],
  ["mod_n_counter", "Modulo-N Counter"],
  ["universal_shift_register", "Universal Shift Register"],
  ["ring_counter", "Ring Counter"],
  ["johnson_counter", "Johnson Counter"],
  ["lfsr", "Linear Feedback Shift Register"],
  ["moore_sequence_detector", "Moore Sequence Detector"],
  ["mealy_sequence_detector", "Mealy Sequence Detector"],
  ["always_comb_example", "always_comb Example"],
  ["always_ff_example", "always_ff Example"],
  ["enum_fsm", "FSM Using Enumerated States"],
  ["sync_fifo", "Synchronous FIFO"],
  ["single_port_ram", "Single Port RAM"],
  ["packed_arrays", "Packed Arrays"],
  ["unpacked_arrays", "Unpacked Arrays"],
  ["struct_typedef", "Structures and Typedef"],
  ["dynamic_arrays", "Dynamic Arrays"],
  ["queues", "Queues"],
  ["associative_arrays", "Associative Arrays"],
  ["array_methods", "Array Methods"],
  ["tasks_functions", "Tasks and Functions"],
  ["classes_objects", "Classes and Objects"],
  ["inheritance_polymorphism", "Inheritance and Polymorphism"],
  ["constrained_randomization", "Constrained Randomization"],
  ["mailboxes", "Mailboxes"],
  ["semaphores", "Semaphores"],
  ["interfaces_modports", "Interfaces and Modports"],
  ["packages", "Packages"]
];

// Build a record for each template.
const templates = templateNames.map(([filename, title], index) => {
  const id = index + 1;
  const number = String(id).padStart(2, "0");
  const isVerilog = id <= 30;
  const folder = isVerilog ? "1.verilog" : "2.system verilog";
  const extension = isVerilog ? "v" : "sv";
  const basename = `${number}_${filename}`;

  return {
    id,
    number,
    title,
    filename,
    language: isVerilog ? "verilog" : "systemverilog",
    languageLabel: isVerilog ? "Verilog" : "SystemVerilog",
    codePath: `${folder}/${basename}.${extension}`,
    explanationPath: `3.Explanation/${basename}.md`
  };
});

// Connect JavaScript to the elements in index.html.
const searchInput = document.getElementById("search-input");
const languageFilter = document.getElementById("language-filter");
const templateList = document.getElementById("template-list");
const resultsCount = document.getElementById("results-count");
const emptyState = document.getElementById("empty-state");

const titleElement = document.getElementById("template-title");
const languageElement = document.getElementById("template-language");
const statusElement = document.getElementById("template-status");

const codeSection = document.getElementById("code-section");
const codeElement = document.getElementById("template-code");

const explanationSection =
  document.getElementById("explanation-section");
const explanationElement =
  document.getElementById("template-explanation");

const copyButton = document.getElementById("copy-code");

let selectedId = null;
let currentCode = "";
let requestNumber = 0;

// Reuse files already downloaded during this page visit.
const fileCache = new Map();

// Encode spaces in folder names while preserving slashes.
function fileUrl(path) {
  const encodedPath = path
    .split("/")
    .map(part => encodeURIComponent(part))
    .join("/");

  return RAW_BASE + encodedPath;
}

// Download a text file from GitHub.
async function loadText(path) {
  if (fileCache.has(path)) {
    return fileCache.get(path);
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 20000);

  try {
    const response = await fetch(fileUrl(path), {
      signal: controller.signal
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${path}`);
    }

    const text = await response.text();
    fileCache.set(path, text);
    return text;
  } finally {
    clearTimeout(timeout);
  }
}

// Create one labelled span for a template button.
function makeSpan(className, text) {
  const span = document.createElement("span");
  span.className = className;
  span.textContent = text;
  return span;
}

// Show templates matching both the search and language filter.
function renderTemplateList() {
  const query = searchInput.value.trim().toLowerCase();
  const language = languageFilter.value;

  const filteredTemplates = templates.filter(template => {
    const searchableText = [
      template.number,
      template.title,
      template.filename,
      template.languageLabel
    ].join(" ").toLowerCase();

    const matchesSearch = searchableText.includes(query);
    const matchesLanguage =
      language === "all" || template.language === language;

    return matchesSearch && matchesLanguage;
  });

  templateList.replaceChildren();

  for (const template of filteredTemplates) {
    const button = document.createElement("button");

    button.type = "button";
    button.className = "template-item";
    button.dataset.id = String(template.id);

    button.setAttribute(
      "aria-current",
      String(template.id === selectedId)
    );

    button.append(
      makeSpan("template-number", `TEMPLATE ${template.number}`),
      makeSpan("template-name", template.title),
      makeSpan("template-tag", template.languageLabel)
    );

    button.addEventListener("click", () => {
      openTemplate(template);
    });

    templateList.append(button);
  }

  resultsCount.textContent =
    `Showing ${filteredTemplates.length} of ${templates.length} templates`;

  emptyState.hidden = filteredTemplates.length > 0;
}

// Update selection without recreating the buttons.
function updateSelection() {
  for (const button of templateList.querySelectorAll("button")) {
    button.setAttribute(
      "aria-current",
      String(Number(button.dataset.id) === selectedId)
    );
  }
}

// Render Markdown, with a plain-text fallback.
function showExplanation(markdown) {
  explanationElement.replaceChildren();

  if (window.marked && window.DOMPurify) {
    const cleanMarkdown = markdown.replace(/^\uFEFF/, "");
    const html = window.marked.parse(cleanMarkdown, {
      gfm: true
    });

    explanationElement.innerHTML = window.DOMPurify.sanitize(html, {
      USE_PROFILES: { html: true }
    });

    return true;
  }

  const fallback = document.createElement("pre");
  fallback.textContent = markdown;
  explanationElement.append(fallback);

  return false;
}

// Load the selected template's code and explanation.
async function openTemplate(template) {
  selectedId = template.id;
  const thisRequest = ++requestNumber;

  updateSelection();

  titleElement.textContent =
    `Template ${template.number}: ${template.title}`;
  languageElement.textContent = template.languageLabel;
  statusElement.textContent = "Loading code and explanation…";

  currentCode = "";
  codeElement.textContent = "";
  explanationElement.replaceChildren();

  codeSection.hidden = true;
  explanationSection.hidden = true;
  copyButton.hidden = true;
  copyButton.disabled = false;
  copyButton.textContent = "Copy code";

  const [codeResult, explanationResult] =
    await Promise.allSettled([
      loadText(template.codePath),
      loadText(template.explanationPath)
    ]);

  // Ignore an older response if another template was selected.
  if (thisRequest !== requestNumber) {
    return;
  }

  const messages = [];

  if (codeResult.status === "fulfilled") {
    currentCode = codeResult.value;

    // textContent displays Verilog as text, not HTML.
    codeElement.textContent = currentCode;
    codeSection.hidden = false;
    copyButton.hidden = false;
  } else {
    messages.push(
      "Could not load the source code. Check your internet connection " +
      "and confirm the file exists on GitHub, then select this template again."
    );
    console.error(codeResult.reason);
  }

  if (explanationResult.status === "fulfilled") {
    const formatted = showExplanation(explanationResult.value);
    explanationSection.hidden = false;

    if (!formatted) {
      messages.push(
        "The explanation is shown as plain text because the formatting " +
        "libraries did not load. Refresh the page to retry."
      );
    }
  } else {
    messages.push(
      "Could not load the explanation. Check your internet connection " +
      "and the matching Markdown file on GitHub, then select this template again."
    );
    console.error(explanationResult.reason);
  }

  statusElement.textContent = messages.join(" ");
}

// Copy the currently displayed source code.
copyButton.addEventListener("click", async () => {
  if (!currentCode) {
    return;
  }

  const copiedTemplateId = selectedId;
  copyButton.disabled = true;

  try {
    if (!navigator.clipboard) {
      throw new Error("Clipboard access is unavailable.");
    }

    await navigator.clipboard.writeText(currentCode);

    if (selectedId === copiedTemplateId) {
      copyButton.textContent = "Copied!";
    }
  } catch (error) {
    if (selectedId === copiedTemplateId) {
      const selection = window.getSelection();
      const range = document.createRange();

      range.selectNodeContents(codeElement);
      selection.removeAllRanges();
      selection.addRange(range);

      statusElement.textContent =
        "Automatic copying is unavailable. The code is selected; " +
        "press Ctrl+C on Windows or Command+C on Mac.";
    }
  } finally {
    if (selectedId === copiedTemplateId) {
      copyButton.disabled = false;
    }
  }
});

// Connect the controls.
searchInput.addEventListener("input", renderTemplateList);
languageFilter.addEventListener("change", renderTemplateList);

// Display the list and open the first template.
renderTemplateList();
openTemplate(templates[0]);