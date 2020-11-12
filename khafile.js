let project = new Project('New Project');
project.addAssets('assets/**', {
    nameBaseDir: 'assets',
    destination: '{dir}/{name}',
    name: '{dir}/{name}'
});
project.addShaders('Shaders/**');
project.addSources('Sources');
project.addLibrary("haxe-format-tiled")

project.addSources('overrides/haxe-format-tiled')  
// too lazy to do much about this, but I just added a way (with a single line for both files) to get the hex-string instead of letting HFT taking care of it.

resolve(project);
