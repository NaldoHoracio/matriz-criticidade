function Component()
{
    component.loaded.connect(function() {
        if (installer.isUninstaller()) {
            return;
        }
        component.createOperations();
    });
}

Component.prototype.createOperations = function()
{
    try {
        component.createOperations();
    } catch (e) {
        component.addOperation("Extract", "@TargetDir@", "@SourceDir@");
    }

    component.addOperation("CreateShortcut",
        "@TargetDir@/MatrizCriticidade.exe",
        "@StartMenuDir@/Matriz de Criticidade.lnk",
        "iconPath=@TargetDir@/MatrizCriticidade.exe",
        "iconId=0",
        "workingDirectory=@TargetDir@");
    component.addOperation("CreateShortcut",
        "@TargetDir@/MatrizCriticidade.exe",
        "@DesktopDir@/Matriz de Criticidade.lnk",
        "iconPath=@TargetDir@/MatrizCriticidade.exe",
        "iconId=0",
        "workingDirectory=@TargetDir@");
}