# Prototype Materials

**Prototype Materials** is a prototyping texture pack and editor tool for **Godot 4.x** that batch-generates `StandardMaterial3D` (`.tres`) files directly from the Inspector using a custom `MaterialGenerator` node.

## Features

* **Theme-Based Textures:** Includes grid and checkerboard textures organized into folders (`dark`, `green`, `light`, `orange`, and more).
* **Batch `.tres` Export:** Scans your texture folders and exports ready-to-use materials sorted into theme subfolders with one click.
* **World Triplanar Support:** Configure `World Triplanar` and `Triplanar Sharpness` globally to prevent UV stretching on scaled blocks, ramps, and floors.
* **Texture Filtering:** Set `Texture Filter` (Linear, Nearest, Mipmaps, Anisotropic) across all generated materials at once.
* **Inspector-Only Workflow:** Zero extra docks or UI clutter.

## Usage

1. Enable **Prototype Materials** in `Project > Project Settings > Plugins`.
2. Open `material_generator.tscn` scene.
3. Configure the properties in the Inspector:
   * **Textures Path:** Source folder containing your themed texture subfolders.
   * **World Triplanar / Triplanar Sharpness:** Toggle world-space projection and blend sharpness.
   * **Texture Filter:** Choose the desired sampling mode.
   * **Export Path:** Destination folder where `.tres` materials will be saved.
4. Click **Export Materials** to generate all materials and refresh the FileSystem dock.

## License

Licensed under the **MIT License**. See `LICENSE` for details.