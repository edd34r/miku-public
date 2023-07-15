package;

import flixel.util.FlxSave;
import flixel.ui.FlxButton;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.text.FlxTypeText;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class MikuOptions extends MusicBeatState
{
    var coolText:FlxTypeText;
    var currentBlock:Int = 0;

    var canUpdate:Bool = false;
    var touchAccepted:Bool = false;

    var leftButton:FlxButton;
    var rightButton:FlxButton;
    var config:Config;

    var settings:Array<Dynamic> = [
        ['main', 'Gameplay', 'Visual', 'Sons'/*, 'Otimizacao'*/#if mobile , 'Controles Mobile' #end],
        ['Gameplay', 'Downscroll', 'Middlescroll', 'Offset', 'Botplay', 'Teclado'],
        ['Visual', 'Antialiasing', 'FPS Visivel', 'FPS Cap', 'Tempo de Musica', 'Notas da CPU ativas'],
        ['Sons', 'HitSounds', 'Volume do Hitsound', 'Sons de Erro'],
        //['Otimizacao', 'GPU', 'Ultra gama baja']
    ];
    var optionText:Array<Dynamic> = [ //Poderia fazer um sistema específico para cada opção, mas isso daria mais trabalho e no momento...
        //Preguiça né?
        ['main',
            'Abre um submenu para opções de gameplay (downscroll, middlescroll essas coisas).',
            'Altere alguns efeitos visuais no mod.',
            'Configure o volume, hitsounds, etc...',
            'Faça o trabalho dos "OMG GAMA BAJA OPTIMIZERS", por conta própria.',
            'Configure os controles da forma que for mais confortável pra você. (keyboard e gamepad também disponíveis).'
        ],
        ['Gameplay',
            'Faça as setas ficarem na parte de baixo da tela',
            'Centralize as setas e elimine as do oponente (pode fazer o FPS dependendo do caso).',
            'Altere e sincronize o tempo em que as notas vem até você com a música (útil pra quem joga com fone de ouvido sem fio).',
            'Auto explicativo eu acho... (Mas você ainda pode mudar isso lá no menu de pause se quiser)\n esses caras da psych viu...',
            'Caso você esteja jogando no teclado, poderá customizar o seu input.'
        ],
        ['Visual',
            'Deixe o contorno dos personagens mais bonitos (Pode aumentar a performance se desativado)',
            'Torna o FPS do jogo visível no canto superior esquerdo da tela.',
            'Altere o limite máximo de FPS do seu jogo (Em alguns dispositivos, alterar essa opção pode deixar os menus lentos).',
            'Deixe um marcador de tempo no canto superior central da tela visivel para monitorar o progresso na música.',
            'Não faço a menor ideia do que é isso, mas estava na Kade : D (Provavelmente nem testei isso antes de lançar - Pelo menos estou sendo honesto...).',
            'Faz as strums do oponente acenderem quando ele acerta uma nota.'
        ],
        ['Sons',
            'Escolha o seu som de Hitsound preferido (caso 0, o Hitsound estará desativado).',
            'Auto explicativo será? (Ah sim... Caso o volume seja 0 ele obviamente não irá ser audível)',
            'Se ativo, ao errar, a platéia ocasionalmente irá vaiar, e um som de erro irá tocar junto (Não deixe eles mexerem com seus sentimentos).'
        ],
        ['Otimizacao',
            'Faz com que os sprites passem a ser carregados pela GPU (pode aumentar a velocidade de carregamento, mas pode não funcionar muito bem em dispositivos antigos).',
            'Limpa absolutamente tudo na gameplay : D (ok... Isso não é lá muito útil, considere isso uma opção memes).'
        ]
    ];
    var settingsBlocks:Array<OptionBar> = [];
    var infoBox:FlxSprite;
    var curSelected:Int = 0;
	var loadOut:Transition;
	var loadIn:Transition;
    var bars:FlxSprite;
    var logo:FlxSprite;
    override function create()
    {

        //init config
		config = new Config();

        FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		loadIn = new Transition(0,0,'in');
        loadIn.animation.finishCallback = function(huh:String){
        remove(loadIn);
        };
		loadOut = new Transition(0,0,'out');
		loadOut.alpha = 0;
		loadOut.scrollFactor.set(0,0);
		loadIn.scrollFactor.set(0,0);

        leftButton = new FlxButton(400, 175);
        leftButton.setGraphicSize(70, FlxG.height - 235); //Garantia
        leftButton.updateHitbox();
        add(leftButton);

        rightButton = new FlxButton(620, 175);
        rightButton.setGraphicSize(75, FlxG.height - 235); //garantia pt2
        rightButton.updateHitbox();
        add(rightButton);

        var bg:MikuBG = new MikuBG(0,0);
        add(bg);
        //var test:OptionBar = new OptionBar(20,20,'TEST OPTION','hi');
        //add(test);

        for (i in 1...settings[0].length)
        {
            var settingsBlock:OptionBar = new OptionBar(64,75 + (100 * i),settings[0][i]);
            add(settingsBlock);
            settingsBlock.ID = i;
            settingsBlock.alpha = 0;
            settingsBlock.y -= 10;
            FlxTween.tween(settingsBlock,{alpha:1, y : settingsBlock.y + 10},0.3,{ease:FlxEase.smoothStepOut,startDelay: 0.2*i});
            settingsBlocks.push(settingsBlock);

            canUpdate = true;
        }


        logo = new FlxSprite(662,-7);
        logo.frames = Paths.getSparrowAtlas('logoBumpin');
        logo.animation.addByPrefix('bump','logo bumpin',24,true);
        logo.setGraphicSize(Std.int(logo.width * 0.65));
        logo.updateHitbox();
        logo.antialiasing = FlxG.save.data.antialiasing;
        logo.animation.play('bump');
        add(logo);

        infoBox = new FlxSprite(750,439).loadGraphic(Paths.image('menuBG/textbox'));
        infoBox.antialiasing = FlxG.save.data.antialiasing;
        add(infoBox);

        coolText = new FlxTypeText(infoBox.x + 24, infoBox.y + 20, Std.int(infoBox.width),'',30);
        coolText.setFormat(Paths.font('shit.ttf'), 25, FlxColor.fromRGB(65, 77, 77), FlxTextAlign.LEFT, FlxTextBorderStyle.NONE, FlxColor.TRANSPARENT);
        coolText.antialiasing = FlxG.save.data.antialiasing;
        add(coolText);
        

        bars = new FlxSprite(0,0).loadGraphic(Paths.image('menuBG/settingsbars'));
		bars.scrollFactor.set();
		bars.antialiasing = FlxG.save.data.antialiasing;
		add(bars);

        addbackButton();

        loadIn.animation.play('transition');
        add(loadIn);
        add(loadOut);
        changeSelection();
    }


    override function update(elapsed:Float){

    super.update(elapsed);


    if (controls.DOWN_P)
        changeSelection(1);
    if (controls.UP_P)
        changeSelection(-1);
    if (controls.BACK || _backButton.justReleased){
        if(currentBlock == 0){
            var save:FlxSave = new FlxSave();
		    save.bind('miku_v2', CoolUtil.getSavePath());
		    save.flush();
            for (i in 0...settingsBlocks.length)
                FlxTween.tween(settingsBlocks[i],{x: settingsBlocks[i].x - 250},0.3,{ease:FlxEase.smoothStepIn,startDelay: 0.2*i});
            loadOut.alpha = 1;
            loadOut.animation.play('transition');
            loadOut.animation.finishCallback = function(huh:String){FlxG.switchState(new MainMenuState());};
            
        }else
            clearSelection(true);
    }

    if (currentBlock != 0 && canUpdate)
        for (i in 1...Std.int(settings[currentBlock].length)){
            settingsBlocks[i-1].optionValue = optionArray(settings[0][currentBlock])[i-1];
            }
    if(canUpdate)
        for (spr in settingsBlocks){
            if (BSLTouchUtils.apertasimples(spr)){
                changeSelection(spr.ID-1, true);
                touchAccepted = true;
            }
        }

    

    if (controls.LEFT_P || (leftButton.justPressed && touchAccepted)){
        touchAccepted = false;
        switch settings[currentBlock][curSelected+1]
            {
            case 'Downscroll':
                FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
            case 'Middlescroll':
                FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
            case 'Offset':
                if (FlxG.save.data.offset > 0)
                    FlxG.save.data.offset -= 1;
            case 'Botplay':
                FlxG.save.data.botplay = !FlxG.save.data.botplay;
            case 'Antialiasing':
                FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
                logo.antialiasing = FlxG.save.data.antialiasing;
                infoBox.antialiasing = FlxG.save.data.antialiasing;
                bars.antialiasing = FlxG.save.data.antialiasing;
            case 'FPS Visivel':
                FlxG.save.data.fps = !FlxG.save.data.fps;
                (cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
            case 'Tempo de Musica':
                FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
            case 'HitSounds':
                if (FlxG.save.data.hitSound > 1){
                    FlxG.save.data.hitSound -= 1;
                    FlxG.sound.play(Paths.sound('osu/'+Std.string(FlxG.save.data.hitSound), 'preload'), FlxG.save.data.hitSoundVolume/10);
                }
            case 'Volume do Hitsound':
                if (FlxG.save.data.hitSoundVolume > 0)
                    FlxG.save.data.hitSoundVolume -= 1;
                FlxG.sound.play(Paths.sound('osu/'+Std.string(FlxG.save.data.hitSound), 'preload'), FlxG.save.data.hitSoundVolume/10);
            case 'Sons de Erro':
                FlxG.save.data.missSounds = !FlxG.save.data.missSounds;
            case 'Notas da CPU ativas':
                FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;
            case 'FPS Cap':
                if (FlxG.save.data.fpsCap >= 60)
                    FlxG.save.data.fpsCap -= 10;
            }
    }

    if (controls.RIGHT_P || (rightButton.justPressed && touchAccepted)){
        touchAccepted = false;
        switch settings[currentBlock][curSelected+1]
            {
                case 'Downscroll':
                    FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
                case 'Middlescroll':
                    FlxG.save.data.middlescroll = !FlxG.save.data.middlescroll;
                case 'Offset':
                    if (FlxG.save.data.offset < 20)
                        FlxG.save.data.offset += 1;
                case 'Botplay':
                    FlxG.save.data.botplay = !FlxG.save.data.botplay;
                case 'Antialiasing':
                    FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
                    logo.antialiasing = FlxG.save.data.antialiasing;
                    infoBox.antialiasing = FlxG.save.data.antialiasing;
                    bars.antialiasing = FlxG.save.data.antialiasing;
                case 'FPS Visivel':
                    FlxG.save.data.fps = !FlxG.save.data.fps;
                    (cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
                case 'Tempo de Musica':
                    FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
                case 'HitSounds':
                    if (FlxG.save.data.hitSound < 4){
                        FlxG.save.data.hitSound += 1;
                        FlxG.sound.play(Paths.sound('osu/'+Std.string(FlxG.save.data.hitSound), 'preload'), FlxG.save.data.hitSoundVolume/10);
                    }
                case 'Volume do Hitsound':
                    if (FlxG.save.data.hitSoundVolume < 10)
                        FlxG.save.data.hitSoundVolume += 1;
                    FlxG.sound.play(Paths.sound('osu/'+Std.string(FlxG.save.data.hitSound), 'preload'), FlxG.save.data.hitSoundVolume/10);

                case 'Sons de Erro':
                    FlxG.save.data.missSounds = !FlxG.save.data.missSounds;
                case 'Notas da CPU ativas':
                    FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;
                case 'FPS Cap':
                    if (FlxG.save.data.fpsCap <= 270)
                        FlxG.save.data.fpsCap += 10;
           }
    }

        if ((controls.ACCEPT || touchAccepted) && (currentBlock == 0 || settings[1][curSelected+1] == 'Teclado')){
            touchAccepted = false;
            if(settings[0][curSelected+1]=='Controles Mobile'){
                #if mobile
                FlxG.switchState(new CustomControlsState());
                #end
            }else if(settings[1][curSelected+1] == 'Teclado'){
                #if desktop
                openSubState(new KeyBindMenu());
                #elseif mobile
                if (config.getcontrolmode()==2)
                    openSubState(new KeyBindMenu());
                else
                    lime.app.Application.current.window.alert("Lembre-se de ativar o modo de teclado em Controles Mobile antes de entrar aqui, e é claro... Ter um teclado obviamente...", "Aviso Amigo :D");
                #end
            }else
                clearSelection();
        }
    }

    function clearSelection(?goback = false)
        {
            canUpdate = false;
            for (spr in settingsBlocks)
                FlxTween.tween(spr,{alpha:0, x: spr.x},0.2,{ease:FlxEase.smoothStepIn,startDelay: 0.2,
                onComplete: function(twn:FlxTween){
                    remove(spr);
                }});

            while (settingsBlocks.length > 0)
                settingsBlocks.pop();

            if(!goback){
                currentBlock = curSelected + 1;
                reloadSelection(settings[curSelected+1]); //Timing purposes (Era pra ser a parte, mas assim fica mais fácil)
            }else{
                currentBlock = 0;
                reloadSelection(settings[0]);
            }

        }

    function reloadSelection(optionGroup:Array<String>)
        {
            for (i in 1...Std.int(optionGroup.length))
                {
                    var settingsBlock:OptionBar = new OptionBar(64,75 + (100 * i),optionGroup[i]);
                    add(settingsBlock);
                    settingsBlock.ID = i;
                    settingsBlock.alpha = 0;
                    settingsBlock.y -= 10;
                    FlxTween.tween(settingsBlock,{alpha:1, y : settingsBlock.y + 10},0.3,{ease:FlxEase.smoothStepOut,startDelay: 0.2*i});
                    settingsBlocks.push(settingsBlock);
                }
            canUpdate = true;
        }

    function changeSelection(change:Int = 0, ?directly = false):Void{
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        if (!directly)
            curSelected += change;
        else
            curSelected = change;

		if (curSelected >= settings[currentBlock].length-1)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = Std.int(settings[currentBlock].length - 2);

        coolText.resetText(optionText[currentBlock][curSelected+1]);
		coolText.start(0.02, true);
        for (i in 0...settingsBlocks.length)
            settingsBlocks[i].isSelected = false;

        settingsBlocks[curSelected].isSelected = true;
    }

    function optionArray(curBlock:String = ''):Array<Dynamic>
    {
        switch(curBlock)
        {
            case 'Gameplay':
                return [FlxG.save.data.downscroll, FlxG.save.data.middlescroll, FlxG.save.data.offset, FlxG.save.data.botplay];
            case 'Visual':
                return [FlxG.save.data.antialiasing, FlxG.save.data.fps, FlxG.save.data.fpsCap, FlxG.save.data.songPosition, FlxG.save.data.cpuStrums];
            case 'Sons':
                return [FlxG.save.data.hitSound, FlxG.save.data.hitSoundVolume, FlxG.save.data.missSounds];
        }
        return [];
    }

}