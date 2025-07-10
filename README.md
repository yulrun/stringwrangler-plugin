<!-- Title -->
<h1 align="center">STRINGWrangler</h1>

<p align="center">
  <a href="https://tiptopjar.com/IndieGameDad">💸 Tip the Developer</a>
</p>

---

## Introduction

<strong>String Wrangler</strong> is a lightweight but powerful <em>editor plugin</em> for the <strong>Godot Engine</strong> that helps you eliminate string-related bugs by turning plain <code>String</code> and <code>Array[String]</code> properties into <strong>dropdowns in the Inspector</strong>.

In many systems — like ability tools, attribute components, registries, item databases, and gameplay logic — it's common to reference dynamic data using string names. These strings are often stored in exported variables, dictionaries, or custom resources and accessed with lookup functions like <code>get_by_name("Speed")</code> or <code>data["Health"]</code>.

But plain strings are <strong>fragile</strong>. They’re easy to mistype, hard to refactor, and prone to silent failures.

### ✅ String Wrangler solves this

Using <strong>variable prefixing</strong>, String Wrangler detects your string-based fields and replaces them with dropdowns populated from your own datasets — such as:

- Registry resources  
- Arrays inside custom resources  
- Script-exposed functions or variables  

The result is a typo-free, self-documenting, editor-integrated selection tool for any string-referenced system.

---

## Use Cases

String Wrangler is ideal for systems that <strong>cannot</strong> use Enums due to dynamic data. While Enums work well for fixed constants, this plugin excels when your data is:

- Defined in resources, not code  
- Grows or changes during development  
- Lives in registries or configuration assets  
- Driven by content creators, not programmers  

### Common Uses

- Attributes (e.g., "Health", "Stamina")  
- Effects and modifiers  
- Inventory items and crafting parts  
- Gameplay tag references  
- Ability targeting or lookup systems  
- Dynamic dictionaries and tables  

---

## Features

- ✅ Dropdowns for String/Array[String] fields  
- 🔁 Supports duplicates if needed  
- 📦 Handles raw arrays, script calls, or property bindings  
- 🧠 Editor-friendly: no runtime cost  
- ⚙️ Prefix-based mapping with full UI panel for configuration  
- 🧱 Modular and non-intrusive – use only where you need it  

---

## How It Works

1. <strong>Add a variable to your script using a prefix</strong>, e.g.:

   <pre><code>@export var SWSamp_tags: Array[String] = []</code></pre>

2. <strong>Register the prefix</strong> in the built-in <em>String Wrangler Prefix Editor</em>, including:
   <ul>
	 <li>A label (e.g., "Sample Tags")</li>
	 <li>A dataset (via raw list, script function, or variable)</li>
	 <li>Whether duplicates are allowed</li>
	 <li>Whether a “None” option is shown</li>
   </ul>

3. The plugin automatically replaces any matching <code>String</code> or <code>Array[String]</code> field with a dropdown using your configuration.

No more mistyped names. No more manual typing. Just click and go.

---

## UI & Editor Integration

String Wrangler includes a dedicated <strong>Prefix Configuration Panel</strong> accessible from the Godot Editor. From here, you can:

- Add, edit, or remove prefix handlers  
- Connect a prefix to a dataset (resource, function, or variable)  
- Configure duplicate behavior and display options  
- Instantly see changes reflected in your Inspector  

---

## Requirements

- Godot 4.4+ tested in 4.5.beta3
- Works with all projects and platforms
- Purely editor-side — no runtime performance impact  

---

## License

MIT License. Free for commercial and non-commercial use.
